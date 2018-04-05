#!/usr/bin/env ruby
require 'io/console'
require 'json'
require 'yaml'
require 'erb'

require 'rest-client'
require 'hashie'
require 'active_support'
require 'active_support/core_ext'

$responses = []

## Exceptions

# 主にフック内で関連レコードの検索を行った際に投げられる
# 投稿処理を終了する
class RelatedRecordNotFoundError < StandardError
  # endpoint: 探索先エンドポイントのシンボル
  # key: 探索キー(find_byの引数)
  def initialize(key:, endpoint:)
    @endpoint = endpoint.to_sym
    @key = key

    super("#{@key} is not found in :#{@endpoint}")
  end

  attr_reader :endpoint
  attr_reader :key
end


## class extensions

class Hash
  extend Hashie::Extensions::DeepFind
  extend Hashie::Extensions::DeepFetch
  include Hashie::Extensions::MethodAccess

  alias :symbolize_keys :deep_symbolize_keys

  # { a: 10, b: 20 }.has_keys?(:a, :b)
  def has_keys?(*arg_keys)
    (arg_keys - keys).empty?
  end
  alias includes? has_keys?
  alias members? has_keys?
end

class Array
  def ===(value)
    case value
    when Array
      self == value
    else
      include?(value)
    end
  end

  def symbolize_keys
    map(&:deep_symbolize_keys)
  end

  def where(opts = {})
    select do |elem|
      opts.all? {|key, value| value === elem[key] }
    end
  end

  def where_not(opts = {})
    select do |elem|
      opts.none? {|key, value| value === elem[key] }
    end
  end

  def find_by(opts = {})
    find do |elem|
      opts.all? {|key, value| value === elem[key] }
    end
  end

  def find_index_by(opts = {})
    find_index do |elem|
      opts.all? {|key, value| value === elem[key] }
    end
  end

  def update(**params)
    each{|elem| elem.update(block_given? ? yield(elem) : params) }
  end
end

class Symbol
  def pluralize
    to_s.pluralize.to_sym
  end

  def singularize
    to_s.singularize.to_sym
  end
end

class Object
  def try_send(name, *args)
    respond_to?(name) ? send(name, *args) : nil
  end

  def try_send!(name, *args)
    respond_to?(name) ? send(name, *args) : self
  end
end

class RestClient::Response
  def successful?
    code / 100 == 2
  end

  def failed?
    [4, 5].include?(code / 100)
  end
end


## utils

module Utils
  module_function

  def error(message)
    warn "[!] #{message}"
  end

  def input_secret(name = 'password')
    print "#{name}: "
    STDIN.noecho(&:gets).chomp
  end

  def build_url(path)
    File.join($base_url, path.to_s)
  end

  def response
    $responses.last
  end

  def request(method, path, payload = {}, headers = {})
    headers[:cookies] ||= response&.cookies

    begin
      $responses << RestClient::Request.execute(method: method.to_sym, url: build_url(path), payload: payload, headers: headers)
    rescue RestClient::RequestFailed => e
      $responses << e.response
      error e.message
    end

    case response.code
    when 204
      true
    else
      JSON.parse(response, symbolize_names: true) if response.body.present?
    end
  end

  def read_erb(filepath)
    ERB.new(File.read(filepath)).result
  end

  def load_file(filepath)
    filepath = File.expand_path(filepath)

    unless File.exist? filepath
      error '"%s" does not exist' % filepath
      return
    end

    unless File.file? filepath
      error '"%s" is not a file' % filepath
      return
    end

    data = case File.extname(filepath)
      when '.yml', '.yaml'
        YAML.load(read_erb(filepath)).symbolize_keys
      when '.json'
        JSON.parse(read_erb(filepath), symbolize_names: true)
      when '.txt', '.md'
        read_erb(filepath)
      else
        error 'Unsupported file type'
        return
      end

    data
  end
end

include Utils


## shell commands

module ShellCommands
  module_function

  def _pwd
    puts Dir.pwd
  end

  def _ls(*args)
    system(*(['ls', '--color=always', '-F'] | args))
  end

  def _cd(dir)
    Dir.chdir(dir)
  end

  def _cat(filepath)
    puts File.read(filepath)
  end
end


## API endpoints

# required: クライアントからPOSTリクエストを投げるときに必要なキー
# optional: 未指定の場合デフォルト値が入るキー
# hooks:
#   underscore: `_` から始まるキーをフックする
#   blank: 値が `Object#blank?` ならフックする
API_ENDPOINTS = {
  answers: {},
  attachments: {
    required: %i(file),
    hooks: {
      underscore: {
        _filepath: :attachment_file_by_filepath,
      },
    },
  },
  comments: {},
  contests: {},
  issues: {},
  members: {
    required: %i(login password),
    optional: { name: nil, team_id: nil, registration_code: nil, role_id: nil, },
    hooks: {
      underscore: {
        _role: :member_role_by_name,
      },
      blank: {
        name: :member_name_by_login,
      },
    },
  },
  notices: {},
  problems: {
    required: %i(title text reference_point perfect_point order creator_id),
    optional: { secret_text: '', team_private: false, problem_must_solve_before_id: nil, problem_group_ids: [], },
    hooks: {
      underscore: {
        _creator: :problem_creator_by_login,
        _problem_must_solve_before_id: :problem_dependency_problem_by_title,
      },
      blank: {
        order: :order_auto,
        problem_must_solve_before_id: :problem_dependency_problem_auto,
      },
    },
  },
  problem_groups: {
    required: %i(name),
    optional: { order: 0, description: nil, visible: true, completing_bonus_point: 0, icon_url: '', },
    hooks: {
      blank: {
        order: :order_auto,
      },
    },
  },
  scores: {},
  scoreboard: {},
  teams: {
    required: %i(name organization registration_code),
  },
}

# API_ENDPOINTSに登録されたフックの本体
# 引数
#   value: フックしたキーの値
#   this:  処理中のハッシュ
#   list:  一括処理中ならそのリスト
#   index: 一括処理中ならlist内のthisのインデックス
module Hooks
  module_function

  # _role, _role_idで文字列かシンボルでRoleを指定できる
  def member_role_by_name(value:, this:, list:, index:)
    this[:role_id] = get_roles[value.to_sym.downcase]
  end

  # nameを省略したらloginを使用する
  def member_name_by_login(value:, this:, list:, index:)
    this[:name] = this[:login]
  end

  # creator_idをloginで指定できる
  def problem_creator_by_login(value:, this:, list:, index:)
    member = get_members.find_by(login: value)
    raise RelatedRecordNotFoundError.new(key: { login: value }, endpoint: :members) if member.nil?
    this[:creator_id] = member[:id]
  end

  # titleから依存問題を求める
  def problem_dependency_problem_by_title(value:, this:, list:, index:)
    problem = get_problems.find_by(title: value)
    this[:problem_must_solve_before_id] = problem[:id]
  end

  # 一括投稿時の問題順で依存問題を設定する
  def problem_dependency_problem_auto(value:, this:, list:, index:)
    # 一括投稿でないなら終了
    return if list.blank?

    # 最初の問題の依存関係は無し
    if index == 0
      this[:problem_must_solve_before_id] = nil
      return
    end

    dependency_problem_id = list[index - 1][:id]

    this[:problem_must_solve_before_id] = dependency_problem_id
  end

  # 一括投稿時にorderを省略すると並び順になる
  def order_auto(value:, this:, list:, index:)
    # 一括投稿でないなら終了
    return if list.blank?

    this[:order] = (index + 1) * 100
  end

  # attachmentの投稿をファイルパス指定で行う
  def attachment_file_by_filepath(value:, this:, list:, index:)
    abs_filepath = File.expand_path(value)
    this[:file] = File.open(abs_filepath, 'rb')
  end
end

module EndpointRequests
  module_function

  def gets(endpoint_sym:, **params)
    # 配列でも文字列でもいい
    params[:with] &&= params[:with].try_send!(:join, ',')

    params_str = params
      .map {|key,value| "#{key}=#{value}" }
      .join('&')

    request(:get, '%s?%s' % [endpoint_sym, params_str])
  end

  def post(endpoint_sym:, args:, list: nil, index: nil)
    endpoint = API_ENDPOINTS[endpoint_sym]

    # キーチェックより先に処理する
    call_underscore_hooks(this: args, endpoint: endpoint, list: list, index: index)

    # 必要なキーを指定しているか
    unless (endpoint.fetch(:required, []) - args.keys).empty?
      show_keys(endpoint: endpoint, keys: args.keys)
      return
    end

    call_blank_hooks(this: args, endpoint: endpoint, list: list, index: index)

    # 未指定のoptionalを取り込む(args優先)
    args = endpoint.fetch(:optional, {}).merge(args)

    result = request(:post, endpoint_sym, args)

    case response.code
    when 400
      result.merge(data: args)
    else
      result
    end
  end

  def put(endpoint_sym:, args:, list: nil, index: nil)
    simple_request(method: :put, endpoint_sym: endpoint_sym, args: args, list: list, index: index)
  end

  def patch(endpoint_sym:, args:, list: nil, index: nil)
    simple_request(method: :patch, endpoint_sym: endpoint_sym, args: args, list: list, index: index)
  end

  def delete(endpoint_sym:, args:, list: nil, index: nil)
    simple_request(method: :delete, endpoint_sym: endpoint_sym, args: args, list: list, index: index)
  end

  def simple_request(method:, endpoint_sym:, args:, list: nil, index: nil)
    endpoint = API_ENDPOINTS[endpoint_sym]

    call_underscore_hooks(this: args, endpoint: endpoint, list: list, index: index)

    result = request(method, '%s/%d' % [endpoint_sym, args[:id]], args)

    case response.code
    when 400
      result.merge(data: args)
    when 404
      { data: args }
    else
      result
    end
  end

  # 指定できるキーの情報を出力する
  def show_keys(endpoint:, keys:)
    puts 'required keys:    %p' % [endpoint.fetch(:required, []) - keys]
    puts 'optional keys:    %p' % [endpoint.fetch(:optional, {}).keys - keys]

    # hooksは減算しない
    # underscore_hooksは先に処理されて消えるから減算できない
    hooks = endpoint.fetch(:hooks, {})
    puts 'underscore hooks: %p' % [hooks.fetch(:underscore, {}).keys]
    puts 'blank hooks:      %p' % [hooks.fetch(:blank, {}).keys]
  end

  # _ から始まるキーのフックを実行する
  def call_underscore_hooks(this:, endpoint:, list:, index:)
    underscore_hooks = endpoint.dig(:hooks, :underscore)&.select{|key, _value| this.keys.include?(key) }

    underscore_hooks&.each do |key, method_sym|
      Hooks
        .method(method_sym)
        .call(value: this[key], this: this, list: list, index: index)

      this.delete(key)
    end
  end

  # キーが空だった場合のフック
  def call_blank_hooks(this:, endpoint:, list:, index:)
    blank_hooks = endpoint.dig(:hooks, :blank)&.select{|key, _value| this[key].blank? }

    blank_hooks&.each do |key, method_sym|
      Hooks
        .method(method_sym)
        .call(value: this[key], this: this, list: list, index: index)
    end
  end
end

# 各エンドポイントのメソッドを自動定義する
# 一部のエンドポイントは汎用的に定義できないため、別途定義する
# 一部のメソッドには別名も定義される
API_ENDPOINTS.each do |endpoint_sym, value|
  # POST,PUT,PATCH,DELETEのリクエスト用Procを生成する
  gen_send_proc = lambda do |method_name|
    lambda do |**args|
      EndpointRequests.send(method_name, endpoint_sym: endpoint_sym, args: args)
    rescue RelatedRecordNotFoundError => e
      { error: e, data: args }
    end
  end

  # POST,PUT,PATCHの一括リクエスト用Procを生成する
  gen_send_list_proc = lambda do |method_name|
    lambda do |list|
      list.map.with_index do |args, index|
        EndpointRequests.send(method_name, endpoint_sym: endpoint_sym, args: args, list: list, index: index)
      rescue RelatedRecordNotFoundError => e
        { error: e, data: args }
      end
    end
  end

  # エイリアス(ソフトリンク)を動的に生成する
  # alias_methodだとハードリンクになる
  # ソフトリンクで定義すれば、オリジナルを独自に再定義した場合でも意図した通りに動く
  gen_alias_proc = lambda do |method_name|
    case method(method_name).arity
    when -1
      lambda {|**params| send(method_name, **params) }
    when 1
      lambda {|arg1| send(method_name, arg1) }
    end
  end

  ## GET all
  # e.g.
  #   get_problems(with: 'answers,comments')
  gets_method_name = "get_#{endpoint_sym.pluralize}"
  proc_gets = lambda {|**params| EndpointRequests.gets(endpoint_sym: endpoint_sym, **params) }
  define_method(gets_method_name, proc_gets)
  define_method("list_#{endpoint_sym.pluralize}", gen_alias_proc.call(gets_method_name))

  ## POST
  # e.g.
  #   post_problem(title: 'hello', text: 'world', reference_point: 10, perfect_point: 20, creator_id: 2)
  post_method_name = "post_#{endpoint_sym.singularize}"
  define_method(post_method_name, gen_send_proc.call(:post))
  define_method("add_#{endpoint_sym.singularize}", gen_alias_proc.call(post_method_name))

  ## POST list
  posts_method_name = "post_#{endpoint_sym.pluralize}"
  define_method(posts_method_name, gen_send_list_proc.call(:post))
  define_method("add_#{endpoint_sym.pluralize}", gen_alias_proc.call(posts_method_name))

  ## PUT
  define_method("put_#{endpoint_sym.singularize}", gen_send_proc.call(:put))

  ## PUT list
  define_method("put_#{endpoint_sym.pluralize}", gen_send_list_proc.call(:put))

  ## PATCH
  patch_method_name = "patch_#{endpoint_sym.singularize}"
  define_method(patch_method_name, gen_send_proc.call(:patch))
  define_method("update_#{endpoint_sym.singularize}", gen_alias_proc.call(patch_method_name))

  ## PATCH list
  patches_method_name = "patch_#{endpoint_sym.pluralize}"
  define_method(patches_method_name, gen_send_list_proc.call(:patch))
  define_method("update_#{endpoint_sym.pluralize}", gen_alias_proc.call(patches_method_name))

  ## DELETE
  define_method("delete_#{endpoint_sym.singularize}", gen_send_proc.call(:delete))
end


## session

def login(login:, password: input_secret)
  request(:post, 'session', { login: login, password: password })
rescue Errno::ECONNREFUSED => e
  error e.message
end

def logout
  request(:delete, 'session')
end


## role
ROLE_ID = {
  admin: 2,
  writer: 3,
  participant: 4,
  viewer: 5,
  nologin: 1,
}

def get_roles
  ROLE_ID
end
alias list_roles get_roles


## 特定の処理に特化した便利メソッド

def change_belongs_problem_group(problem_id:, group_id:)
  problem = get_problems
    .find_by(id: problem_id)
    .merge(problem_group_ids: [group_id])

  update_problem(problem)
end

# グループに複数の問題を所属させる
def change_belonging_problems(group_id:, problem_ids: [])
  problem_ids.map {|id| change_belongs_problem_group(problem_id: id, group_id: group_id) }
end

# problem_idをbefore_idに依存させる
def change_dependency_problem(problem_id:, before_id:)
  problem = get_problems
    .find_by(id: problem_id)
    .merge(problem_must_solve_before_id: before_id)

  patch_problem(problem)
end

def change_password(login:, password: input_secret)
  member = get_members
    .find_by(login: login)
    .merge(password: password)

  patch_member(member)
end

def download_attachment(id:, access_token:)
  request(:get, "/api/attachments/#{id}/#{access_token}")
end

def upload_files(*filepathes)
  post_attachments(filepathes.flatten.map {|filepath| { _filepath: filepath } })
end

def upload_dir_files(filedir)
  filepathes = Dir.glob(File.join(filedir, '/*'))
    .select(&File.method(:file?))

  upload_files(filepathes)
end


## run

$base_url = ARGV[0] || 'http://localhost:3000/api'

login(login: :admin)

require 'pry'
extend ShellCommands
binding.pry
puts '[*] end binding'

__END__

#### 操作サンプル


# ログイン/ログアウト
login(login: 'admin', password: 'admin')
logout

# 問題の追加
add_problem(title: '10時間寝たい', text: 'マジ?', reference_point: 80, perfect_point: 0x80, creator_id: 3, problem_group_ids: [1], problem_must_solve_before_id: 12)

# 問題を更新する
problem = get_problems[0]
problem[:title] = 'this is a title'
puts update_problem(problem)

# YAMLから問題を読み込んでまとめて追加
add_problems(load_file('./sample-problem-groups.yml'))

# ファイルをアップロード
attachment = upload_files('./Gemfile')[0]
# ダウンロードリンクを表示(相対URL)
puts attachment[:url]
# ダウンロード
download_attachment(id: attachment[:id], access_token: attachment[:access_token])


# メンバーの追加
# role_id:  ROLE_ID(1~5)を指定する代わりに _role: 'writer' が使える
#   writer,admin,viewer: team_idとregistration_codeをnullにしてrole_idを指定する
#   participant: role_idを指定不可
add_member(login: 'foobar', password: 'foobar', _role: 'writer')

# Writerのみ削除する
list_members.where(role_id: list_roles[:writer]).each(&method(:delete_member))

# Writerのパスワードを一括変更する
update_members(list_members.where(role_id: list_roles[:writer]).update(password: 'new_password'))
