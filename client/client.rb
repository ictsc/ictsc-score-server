#!/usr/bin/env ruby
require 'io/console'
require 'json'
require 'yaml'
require 'erb'
require 'singleton'

require 'rest-client'
require 'hashie'
require 'active_support'
require 'active_support/core_ext'

$responses = []


## class extensions

class Hash
  include Hashie::Extensions::DeepFind
  include Hashie::Extensions::DeepFetch
  include Hashie::Extensions::MethodAccess

  alias :symbolize_keys :deep_symbolize_keys

  # { a: 10, b: 20 }.has_keys?(:a, :b)
  def has_keys?(*arg_keys)
    (arg_keys - keys).empty?
  end
  alias includes? has_keys?
  alias members? has_keys?

  # 既存の値優先でmerge
  def append(**other_hash)
    merge(other_hash) {|key, old, new| old }
  end

  def append!(**other_hash)
    merge!(other_hash) {|key, old, new| old }
  end
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


## exceptions

# フック処理失敗
class HookError < StandardError
  attr_accessor :hook

  def initialize(error_message, hook:)
    @hook = hook
    super("#{hook}: #{error_message}")
  end
end

# フック内での関連レコード検索失敗
class HookRelatedRecordNotFound < HookError
  attr_reader :endpoint
  attr_reader :key

  # endpoint: 探索先エンドポイントのシンボル
  # key: 探索キー(find_byの引数)
  def initialize(hook:, key:, endpoint:)
    @endpoint = endpoint.to_sym
    @key = key

    super("#{@key} not found in #{@endpoint}", hook: hook)
  end
end

# 投稿処理を終了する
class HookRelatedRecordNotFoundError < HookRelatedRecordNotFound
end

# 投稿処理は継続される
class HookRelatedRecordNotFoundWarning < HookRelatedRecordNotFound
end

# フック内の外部ファイル読み込み失敗
# 投稿処理を終了する
class HookFileNotFound < HookError
  attr_reader :filepath

  def initialize(hook:, filepath:)
    @filepath = filepath

    super("#{filepath} not found", hook: hook)
  end
end

# フック内でPOSTなどのリクエストを送信した際にwarningsやerrorが発生
# 投稿処理は継続される
class HookNestedRequestWarning < HookError
  attr_reader :result

  def initialize(hook:, result:)
    @result = result
    super(result, hook: hook)
  end
end


## utils

module Utils
  module_function

  # カレントディレクトリとファイルを読み込んだことのあるディレクトリからファイルを探索する
  class UsedDirs
    include Singleton
    @@dirs = []

    def self.dirs
      @@dirs
    end

    # ディレクトリを追加する(引数はファイルでもディレクトリでも可)
    def self.push(path)
      abs_path = File.expand_path(path)
      abs_path = File.dirname(abs_path) unless File.directory?(abs_path)
      @@dirs.unshift(abs_path) unless @@dirs.include?(abs_path)
    end

    # ファイルを探索する
    # 見つかったなら、そのディレクトリを記憶する
    def self.find(filepath)
      # ホームディレクトリなどを解釈してファイルが見つかったならそれを使用する
      expand_path = File.expand_path(filepath)
      if File.file?(expand_path)
        push(expand_path)
        return expand_path
      end

      # カレントディレクトリと過去使用したディレクトリから探す
      dir = ([Dir.pwd] + @@dirs).find {|dirname| File.file?(File.join(dirname, filepath)) }

      if dir.nil?
        error "\"#{filepath}\" does not exist"
        return
      end

      abs_filepath = File.join(dir, filepath)
      push(abs_filepath)
      abs_filepath
    end
  end

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

  def request(http_method, path, payload = {}, headers = {})
    headers[:cookies] ||= response&.cookies

    begin
      $responses << RestClient::Request.execute(method: http_method.to_sym, url: build_url(path), payload: payload, headers: headers)
    rescue RestClient::RequestFailed => e
      $responses << e.response
      error e.message
    end

    {
      response: response,
      body: response.body.present? ? JSON.parse(response, symbolize_names: true) : {},
    }
  end

  def read_erb(filepath)
    ERB.new(File.read(filepath)).result
  end

  def load_file(filepath)
    filepath = UsedDirs.find(filepath)

    return if filepath.nil?

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
    system(*(['ls', '--color=always', '-F'] | args.map(&File.method(:expand_path))))
  end

  def _cd(dir)
    Dir.chdir(File.expand_path(dir))
    _ls
  end

  def _cat(filepath)
    puts File.read(File.expand_path(filepath))
  end
end


## API endpoints

# required: クライアントからPOSTリクエストを投げるときに必要なキー
# optional: 未指定の場合デフォルト値が入るキー
# cache: 一括投稿系の実行前にキャッシュするエンドポイントを指定
# hooks:
#   underscore: `_` から始まるキーをフックする
#   blank: 値が `Object#blank?` ならフックする
#   after: リクエスト成功後に実行する
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
    cache: %i(members),
    hooks: {
      underscore: {
        _text: :text_by_filepath,
        _secret_text: :text_by_filepath,
        _creator: :member_id_by_login,
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
      after: {
        _problems: :problem_group_problems,
      },
    },
  },
  scores: {},
  scoreboard: {},
  teams: {
    required: %i(name organization registration_code),
  },
}

def get_api_endpoints
  API_ENDPOINTS
end
alias list_api_endpoints get_api_endpoints

# API_ENDPOINTSに登録されたフックの本体
# 引数
#   key: フックしたキー(hook名)
#   value: フックしたキーの値
#   this:  処理中のハッシュ
#   list:  一括処理中ならそのリスト
#   index: 一括処理中ならlist内のthisのインデックス
module Hooks
  module_function

  # _role, _role_idで文字列かシンボルでRoleを指定できる
  def member_role_by_name(key:, value:, this:, list:, index:)
    value = value.to_sym.downcase
    role_id = get_roles[value]
    # 明示的にRoleを指定しようとして失敗したならエラーにする
    raise HookRelatedRecordNotFoundError.new(hook: key, key: { role_key: value }, endpoint: :roles) if role_id.nil?
    this[:role_id] = role_id
  end

  # nameを省略したらloginを使用する
  def member_name_by_login(key:, value:, this:, list:, index:)
    this[:name] = this[:login]
  end

  # creator_idをloginで指定できる
  def member_id_by_login(key:, value:, this:, list:, index:)
    member = get_members.find_by(login: value)
    raise HookRelatedRecordNotFoundError.new(hook: key, key: { login: value }, endpoint: :members) if member.nil?

    # _creator -> creator_id
    actual_key = (key.to_s.delete_prefix('_') + '_id').to_sym
    this[actual_key] = member[:id]
  end

  # titleから依存問題を求める
  def problem_dependency_problem_by_title(key:, value:, this:, list:, index:)
    problem = get_problems.find_by(title: value)
    raise HookRelatedRecordNotFoundWarning.new(hook: key, key: { title: value }, endpoint: :problems) if problem.nil?
    this[:problem_must_solve_before_id] = problem[:id]
  end

  # 一括投稿時の問題順で依存問題を設定する
  def problem_dependency_problem_auto(key:, value:, this:, list:, index:)
    # 一括投稿でないなら終了
    return if list.blank?

    # 最初の問題の依存関係は無し
    if index == 0
      this[:problem_must_solve_before_id] = nil
      return
    end

    dependency_problem_id = list[index - 1][:id]

    raise HookRelatedRecordNotFoundWarning.new(hook: key, key: { list_index: index - 1 }, endpoint: :problems) if dependency_problem_id.nil?

    this[:problem_must_solve_before_id] = dependency_problem_id
  end

  # 問題グループ投稿時に、問題も投稿する(problem_group_idsが自動で付与される)
  def problem_group_problems(key:, value:, this:, list:, index:)
    problem_group_id = this[:id]
    raise HookRelatedRecordNotFoundWarning.new(hook: key, key: 'this', endpoint: :problem_group) if problem_group_id.nil?
    value.update(problem_group_ids: [problem_group_id])
    results = post_problems(value)

    warnings = results.select {|e| e.has_key?(:error) || e.has_key?(:warnings) }
    raise HookNestedRequestWarning.new(hook: key, result: warnings) unless warnings.empty?
  end

  # 一括投稿時にorderを省略すると並び順になる
  def order_auto(key:, value:, this:, list:, index:)
    # 一括投稿でないなら終了
    return if list.blank?

    this[:order] = (index + 1) * 100
  end

  # ファイルパスからテキストを読み込む
  def text_by_filepath(key:, value:, this:, list:, index:)
    text = load_file(value)

    raise HookFileNotFound.new(hook: key, filepath: value) if text.nil?

    # _text -> text
    actual_key = key.to_s.delete_prefix('_').to_sym
    this[actual_key] = text
  end

  # attachmentの投稿をファイルパス指定で行う
  def attachment_file_by_filepath(key:, value:, this:, list:, index:)
    filepath = UsedDirs.find(value)

    raise HookFileNotFound.new(hook: key, filepath: value) if filepath.nil?

    this[:file] = File.open(filepath, 'rb')
  end
end

# APIを叩くメソッドの本体
module EndpointRequests
  module_function

  # GET allのキャッシュをする
  # 参照カウンタ方式でキャッシュを管理する
  class EndpointCache
    include Singleton

    # e.g. endpoint: { count: 0, data: nil }
    @@cache = {}

    def self.cache
      @@cache
    end

    def self.get(endpoint_sym)
      @@cache[endpoint_sym] ||= { count: 0, data: nil }

      endpoint = @@cache[endpoint_sym]
      return if endpoint[:count] <= 0

      # 有効後初回アクセス時に取得
      if endpoint[:data].blank?
        endpoint[:data] = EndpointRequests.gets(endpoint_sym: endpoint_sym, params: {}, use_cache: false)
      end

      endpoint[:data]
    end

    def self.set(endpoint_sym)
      @@cache[endpoint_sym] ||= { count: 0, data: nil }
      @@cache[endpoint_sym][:count] += 1
    end

    def self.unset(endpoint_sym)
      endpoint = @@cache[endpoint_sym]
      endpoint[:count] -= 1
      endpoint[:data] = nil if endpoint[:count] <= 0
    end
  end

  def gets(endpoint_sym:, params:, use_cache: true)
    data = use_cache && EndpointCache.get(endpoint_sym)
    return data if data.present?

    params = params.deep_dup

    # 配列でも文字列でもいい
    params[:with] &&= params[:with].try_send!(:join, ',')

    params_str = params
      .map {|key, value| "#{key}=#{value}" }
      .join('&')

    request(:get, "#{endpoint_sym}?#{params_str}")[:body]
  end

  # POST, PUT, PATCH, DELETE
  # エイリアス名からHTTPメソッドを判断
  # paramsは非破壊
  def request_base(http_method: __callee__, endpoint_sym:, params:, list: nil, index: nil)
    params = params.deep_dup
    endpoint = API_ENDPOINTS[endpoint_sym]

    # キーチェックより先に処理する
    warnings = call_underscore_hooks(this: params, endpoint: endpoint, list: list, index: index)

    case http_method
    when :post
      warnings += call_blank_hooks(this: params, endpoint: endpoint, list: list, index: index)

      # 必要なキーを指定しているか
      unless (endpoint.fetch(:required, []) - params.keys).empty?
        show_keys(endpoint: endpoint, keys: params.keys)
        return
      end

      # 未指定のoptionalを取り込む
      params.append!(endpoint.fetch(:optional, {}))

      url = endpoint_sym
    when :put, :patch, :delete
      url = "#{endpoint_sym}/#{params[:id]}"
    end

    result = request(http_method, url, params)

    if result[:response]&.successful?
      # レスポンスの値をマージしてafterフックを呼び出す
      warnings += call_after_hooks(this: params.merge(result[:body]), endpoint: endpoint, list: list, index: index)
    end

    result.merge!(warnings: warnings, params: params) unless warnings.empty?
    result
  rescue HookError => e
    { error: e, params: params }
  end

  alias post   request_base
  alias put    request_base
  alias patch  request_base
  alias delete request_base
  # エイリアスは明示する必要がある
  module_function :post, :put, :patch, :delete

  # POST, PUT, PATCHの一括リクエスト
  def request_list(http_method:, endpoint_sym:, list:)
    list = list.deep_dup

    # キャッシュを取得
    API_ENDPOINTS.dig(endpoint_sym, :cache)&.each(&EndpointCache.method(:set))

    list.map.with_index do |params, index|
      result = request_base(http_method: http_method, endpoint_sym: endpoint_sym, params: params, list: list, index: index)

      # 投稿して取得した値で更新する(IDなどを取得)
      params.append!(result[:body]) if result&.fetch(:response, nil)&.successful?

      result
    end

  ensure
    # キャッシュを開放
    API_ENDPOINTS.dig(endpoint_sym, :cache)&.each(&EndpointCache.method(:unset))
  end

  # 指定できるキーの情報を出力する
  def show_keys(endpoint:, keys:)
    required_keys  = endpoint.fetch(:required, [])
    optional_keys = endpoint.fetch(:optional, {}).keys
    hooks = endpoint.fetch(:hooks, {})
    underscore_hook_keys = hooks.fetch(:underscore, {}).keys
    blank_hook_keys = hooks.fetch(:blank, {}).keys

    puts 'required keys:        %p' % [required_keys - keys]
    puts 'optional keys:        %p' % [optional_keys - keys]

    # hooksは減算しない
    # underscore_hooksは先に処理されて消えるから減算できない
    puts 'underscore hook keys: %p' % [underscore_hook_keys]
    puts 'blank hook keys:      %p' % [blank_hook_keys]

    # blank_hooksはrequired_keysかoptional_keysに必ず含まれてる
    puts 'unknown keys:         %p' % [keys - required_keys - optional_keys - underscore_hook_keys]
  end

  # hooksを実行し、warningsを返す
  def call_hooks(hooks:, this:, endpoint:, list:, index:)
    warnings = []

    hooks&.each do |key, method_sym|
      Hooks
        .method(method_sym)
        .call(key: key, value: this[key], this: this, list: list, index: index)

    rescue HookRelatedRecordNotFoundWarning, HookNestedRequestWarning => e
      # フック処理を継続
      warnings << e
    end

    warnings
  end

  # _ から始まるキーのフックを実行する
  def call_underscore_hooks(this:, endpoint:, list:, index:)
    underscore_hooks = endpoint.dig(:hooks, :underscore)&.select{|key, _value| this.keys.include?(key) }
    warnings = call_hooks(hooks: underscore_hooks, endpoint: endpoint, this: this, list: list, index: index)
    # thisからunderscore_hooksを取り除く
    underscore_hooks&.each_key(&this.method(:delete))
    warnings
  end

  # リクエスト成功後に実行されるフック
  def call_after_hooks(this:, endpoint:, list:, index:)
    after_hooks = endpoint.dig(:hooks, :after)&.select{|key, _value| this.keys.include?(key) }
    warnings = call_hooks(hooks: after_hooks, endpoint: endpoint, this: this, list: list, index: index)
    warnings
  end

  # キーが空だった場合のフックを実行する
  def call_blank_hooks(this:, endpoint:, list:, index:)
    blank_hooks = endpoint.dig(:hooks, :blank)&.select{|key, _value| this[key].blank? }
    warnings = call_hooks(hooks: blank_hooks, endpoint: endpoint, this: this, list: list, index: index)
    warnings
  end
end

# 各エンドポイントのメソッドを自動定義する
# 一部のエンドポイントは汎用的に定義できないため、別途定義する
# 一部のメソッドには別名も定義される
API_ENDPOINTS.each do |endpoint_sym, value|
  # GET all, POST, PUT, PATCH, DELETEのリクエスト用Procを生成する
  gen_send_proc = lambda do |http_method|
    lambda do |**params|
      EndpointRequests.send(http_method, endpoint_sym: endpoint_sym, params: params)
    end
  end

  # POST, PUT, PATCHの一括リクエスト用Procを生成する
  gen_send_list_proc = lambda do |http_method|
    lambda do |list|
      EndpointRequests.request_list(http_method: http_method, endpoint_sym: endpoint_sym, list: list)
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
  define_method(gets_method_name, gen_send_proc.call(:gets))
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
  request(:get, "/api/attachments/#{id}/#{access_token}")[:body]
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

login(login: 'admin', password: 'admin')

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
add_problem(title: '10時間寝たい', text: 'マジ?', reference_point: 80, perfect_point: 0x80, _creator: 'writer1', problem_group_ids: [1], problem_must_solve_before_id: 12)

# 問題のタイトルを更新する
problem = get_problems[0].update(title: 'this is a title')
update_problem(problem)

# YAMLから問題を読み込んでまとめて追加
add_problems(load_file('./sample-problem-groups.yml'))

# ファイルをアップロード
attachment = upload_files('./Gemfile')[0][:body]
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
