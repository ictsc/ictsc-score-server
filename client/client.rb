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

    {
      data: data,
      filedir: File.dirname(filepath),
    }
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
        _filepath: :attachment_filepath,
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
        _role: :member_role,
      },
      blank: {
        name: :member_name,
      },
    },
  },
  notices: {},
  problems: {
    required: %i(title text reference_point perfect_point order creator_id),
    optional: { secret_text: '', team_private: false, problem_must_solve_before_id: nil, problem_group_ids: [], },
    hooks: {
      underscore: {
        _creator: :problem_creator,
      },
      blank: {
        order: :auto_order,
      },
    },
  },
  problem_groups: {
    required: %i(name),
    optional: { order: 0, description: nil, visible: true, completing_bonus_point: 0, icon_url: '', },
    hooks: {
      blank: {
        order: :auto_order,
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
  def member_role(value:, this:, list:, index:)
    this[:role_id] = get_roles[value.to_sym.downcase]
  end

  # nameを省略したらloginを使用する
  def member_name(value:, this:, list:, index:)
    this[:name] = this[:login]
  end

  # creator_idをloginで指定できる
  def problem_creator(value:, this:, list:, index:)
    this[:creator_id] = list_members.find_by(login: value)[:id]
  end

  # 一括登録時にorderを省略すると並び順になる
  def auto_order(value:, this:, list:, index:)
    this[:order] = index * 100 if list.present?
  end

  # attachmentの投稿をファイルパス指定で行う
  def attachment_filepath(value:, this:, list:, index:)
    abs_filepath = File.expand_path(value)
    this[:file] = File.open(abs_filepath, 'rb')
    this[:multipart] = true
  end
end

module EndpointRequetrs
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
      puts_keys(endpoint: endpoint, keys: args.keys)
      return
    end

    call_blank_hooks(this: args, endpoint: endpoint, list: list, index: index)

    # 未指定のoptionalを取り込む(args優先)
    data = endpoint.fetch(:optional, {}).merge(args)

    result = request(:post, endpoint_sym, data)

    case response.code
    when 400
      result.merge!(data: args)
    else
      result
    end
  end

  def put(endpoint_sym:, args:, list: nil, index: nil)
    endpoint = API_ENDPOINTS[endpoint_sym]

    # 取得した値を使ってputを呼ぶからrequiredやoptionalのチェックは無し

    # underscoreフックは有効
    call_underscore_hooks(this: args, endpoint: endpoint, list: list, index: index)

    result = request(:put, '%s/%d' % [endpoint_sym, args[:id]], args)

    case response.code
    when 400
      result.merge(data: args)
    when 404
      { data: args }
    else
      result
    end
  end

  def patch(endpoint_sym:, args:, list: nil, index: nil)
    endpoint = API_ENDPOINTS[endpoint_sym]

    # 取得した値を使ってpatchを呼ぶからrequiredやoptionalのチェックは無し

    # underscoreフックは有効
    call_underscore_hooks(this: args, endpoint: endpoint, list: list, index: index)

    result = request(:patch, '%s/%d' % [endpoint_sym, args[:id]], args)

    case response.code
    when 400
      result.merge(data: args)
    when 404
      { data: args }
    else
      result
    end
  end

  def delete(endpoint_sym:, args:, list: nil, index: nil)
    endpoint = API_ENDPOINTS[endpoint_sym]

    # underscoreフックは有効
    call_underscore_hooks(this: args, endpoint: endpoint, list: list, index: index)

    result = request(:delete, '%s/%d' % [endpoint_sym, args[:id]], args)

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
  def puts_keys(endpoint:, keys:)
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
  ## GET all
  # e.g.
  #   get_problems(with: 'answers,comments')
  gets_method_name = 'get_%s' % endpoint_sym.pluralize
  proc_gets = proc {|**params| EndpointRequetrs.gets(endpoint_sym: endpoint_sym, **params) }
  proc_alias_gets = proc {|**params| send(gets_method_name, **params) }
  define_method(gets_method_name, proc_gets)
  define_method('list_%s' % endpoint_sym.pluralize, proc_alias_gets)

  ## POST
  # e.g.
  #   post_problem(title: 'hello', text: 'world', reference_point: 10, perfect_point: 20, creator_id: 2)
  post_method_name = 'post_%s' % endpoint_sym.singularize
  proc_post = proc {|**args| EndpointRequetrs.post(endpoint_sym: endpoint_sym, args: args) }
  proc_alias_post = proc {|**args| send(post_method_name, **args) }
  define_method(post_method_name, proc_post)
  define_method('add_%s' % endpoint_sym.singularize, proc_alias_post)

  ## POST list
  posts_method_name = 'post_%s' % endpoint_sym.pluralize
  proc_posts = proc {|list| list.map.with_index(1) {|args, index| EndpointRequetrs.post(endpoint_sym: endpoint_sym, args: args, list: list, index: index) } }
  proc_alias_posts = proc {|list| send(posts_method_name, list) }
  define_method(posts_method_name, proc_posts)
  define_method('add_%s' % endpoint_sym.pluralize, proc_alias_posts)

  ## PUT
  proc_put = proc {|**args| EndpointRequetrs.put(endpoint_sym: endpoint_sym, args: args) }
  define_method('put_%s' % endpoint_sym.singularize, proc_put)

  ## PUT list
  proc_puts = proc {|list| list.map.with_index(1) {|args, index| EndpointRequetrs.put(endpoint_sym: endpoint_sym, args: args, list: list, index: index) } }
  define_method('put_%s' % endpoint_sym.pluralize, proc_puts)

  ## PATCH
  patch_method_name = 'patch_%s' % endpoint_sym.singularize
  proc_patch = proc {|**args| EndpointRequetrs.patch(endpoint_sym: endpoint_sym, args: args) }
  proc_alias_patch = proc {|**args| send(patch_method_name, **args) }
  define_method(patch_method_name, proc_patch)
  define_method('update_%s' % endpoint_sym.singularize, proc_alias_patch)

  ## PATCH list
  patches_method_name = 'patch_%s' % endpoint_sym.pluralize
  proc_patches = proc {|list| list.map.with_index(1) {|args, index| EndpointRequetrs.patch(endpoint_sym: endpoint_sym, args: args, list: list, index: index) } }
  proc_alias_patches = proc {|list| send(patches_method_name, list) }
  define_method(patches_method_name, proc_patches)
  define_method('update_%s' % endpoint_sym.pluralize, proc_alias_patches)

  ## DELETE
  proc_delete = proc {|**args| EndpointRequetrs.delete(endpoint_sym: endpoint_sym, args: args) }
  define_method('delete_%s' % endpoint_sym.singularize, proc_delete)
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


## 特定の処理に特化したちょい便利メソッドたち

def update_only_problem_group(problem_id:, group_id:)
  problem = get_problems
    .find_by(id: problem_id)
    .merge(problem_group_ids: [group_id])

  update_problem(problem)
end

# problem_idをbefore_idに依存させる
def change_depends_problem(problem_id:, before_id:)
  problem = get_problems
    .find_by(id: problem_id)
    .merge(problem_must_solve_before_id: before_id)

  update_problem(problem)
end

# グループに複数の問題を依存させる
def register_problems_to_group(group_id:, problem_ids: [])
  problem_ids.each do |id|
    update_only_problem_group(problem_id: id, group_id: group_id)
  end
end

def change_password(login:, password: input_secret)
  member = get_members
    .find_by(login: login)
    .merge(password: password)

  update_member(member)
end

def download_attachment(id:, access_token:)
  request(:get, "/api/attachments/#{id}/#{access_token}")
end

def upload(*filepathes)
  post_attachments(filepathes.flatten.map {|filepath| { _filepath: filepath } })
end

def upload_dir_files(filedir)
  filepathes = Dir.glob(File.join(filedir, '/*'))
    .select(&File.method(:file?))

  upload(filepathes)
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
add_problems(load_file('./sample-problem-groups.yml').data)

# ファイルをアップロード(ダウンロードリンクを返す)
attachment = add_attachments('./pry_r.rb')
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
