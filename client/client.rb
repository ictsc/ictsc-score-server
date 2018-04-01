require 'io/console'
require 'json'
require 'yaml'
require 'erb'

require 'rest-client'
require 'hashie'
require 'active_support'
require 'active_support/core_ext'

## utils

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

def request(method, path, payload_hash = {}, headers = { content_type: :json })
  headers[:cookies] ||= $responses.last&.cookies
  payload = headers[:content_type] == :json ? payload_hash.to_json : payload_hash

  $responses << RestClient::Request.execute(method: method.to_sym, url: build_url(path), payload: payload, headers: headers)
  JSON.parse($responses.last, symbolize_names: true)
end

def read_erb(filepath)
  ERB.new(File.read(filepath)).result
end

def load_file(filepath)
  filepath = File.expand_path(filepath)

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


## Role
ROLE_ID = {
  admin: 2,
  writer: 3,
  participant: 4,
  viewer: 5,
  nologin: 1,
}

def list_roles
  ROLE_ID
end
alias get_roles list_roles


## API endpoints

# required: クライアントからPOSTリクエストを投げるときに必要なキー
# optional: 未指定の場合デフォルト値が入るキー
# hooks:
#   underscore: `_` から始まるキーをフックする
#   blank: 値が `Object#blank?` ならフックする
API_ENDPOINTS = {
  answers: {},
  attachments: {},
  comments: {},
  contests: {},
  issues: {},
  members: {
    required: %i(login password),
    optional: { name: nil, team_id: nil, registration_code: nil, role_id: nil, },
    hooks: {
      underscore: {
        _role: :member_role,
        _role_id: :member_role,
      },
      blank: {
        name: :member_name,
      },
    },
  },
  notices: {},
  problems: {
    required: %i(title text reference_point perfect_point creator_id),
    optional: { secret_text: '', team_private: false, order: 0, problem_must_solve_before_id: nil, problem_group_ids: [], },
  },
  problem_groups: {
    required: %i(name),
    optional: { order: 0, description: nil, visible: true, completing_bonus_point: 0, icon_url: '', },
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
    this[:role_id] = ROLE_ID[value.to_sym.downcase]
  end

  # nameを省略したらloginを使用する
  def member_name(value:, this:, list:, index:)
    this[:name] = this[:login]
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

  def post(endpoint_sym:, list: nil, index: nil, **args)
    endpoint = API_ENDPOINTS[endpoint_sym]

    insufficient_keys = endpoint.fetch(:required, []) - args.keys
    unless insufficient_keys.empty?
      puts 'required keys: %p' % [insufficient_keys]
      puts 'optional keys: %p' % [endpoint.fetch(:optional, {}).keys - args.keys]
      return
    end

    call_underscore_hooks(this: args, endpoint: endpoint, list: list, index: index)

    call_blank_hooks(this: args, endpoint: endpoint, list: list, index: index)

    # 未指定のoptionalを取り込む(args優先)
    data = endpoint.fetch(:optional, {}).merge(args)

    request(:post, endpoint_sym, data)
  end

  def put(endpoint_sym:, list: nil, index: nil, **args)
    endpoint = API_ENDPOINTS[endpoint_sym]

    # 取得した値を使ってputを呼ぶからrequiredやoptionalのチェックは無し

    # underscoreフックは有効
    call_underscore_hooks(this: args, endpoint: endpoint, list: list, index: index)

    request(:put, '%s/%d' % [endpoint_sym, args[:id]], args)
  end

  def delete(endpoint_sym:, list: nil, index: nil, **args)
    endpoint = API_ENDPOINTS[endpoint_sym]

    # underscoreフックは有効
    call_underscore_hooks(this: args, endpoint: endpoint, list: list, index: index)

    request(:delete, '%s/%d' % [endpoint_sym, args[:id]], args)
  end
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

API_ENDPOINTS.each do |endpoint_sym, args|
  ## GET all
  # e.g.
  #   get_problems(with: 'answers,comments')
  proc_gets = Proc.new{|**params| EndpointRequetrs.gets(endpoint_sym: endpoint_sym, **params) }
  define_method('get_%s' % endpoint_sym, proc_gets)
  define_method('list_%s' % endpoint_sym, proc_gets)

  ## POST
  proc_post = Proc.new{|**params| EndpointRequetrs.post(endpoint_sym: endpoint_sym, **params) }
  define_method('post_%s' % endpoint_sym.singularize, proc_post)
  define_method('add_%s' % endpoint_sym.singularize, proc_post)

  ## PUT
  proc_put = Proc.new{|**params| EndpointRequetrs.put(endpoint_sym: endpoint_sym, **params) }
  define_method('put_%s' % endpoint_sym.singularize, proc_put)
  define_method('update_%s' % endpoint_sym.singularize, proc_put)

  ## DELETE
  proc_delete = Proc.new{|**params| EndpointRequetrs.delete(endpoint_sym: endpoint_sym, **params) }
  define_method('delete_%s' % endpoint_sym.singularize, proc_delete)
end


## session

def login(login:, password: input_secret)
  request(:post, 'session', { login: login, password: password })
end

def logout
  request(:delete, 'session')
end

## problem groups

def add_problem_groups(problem_groups)
  problem_groups.each do |problem_group|
    puts add_problem_group(problem_group)
  end
end

## problems

def add_problems(problems)
  # 先にまとめて読み込みチェック
  problems.each do |problem|
    if problem.key?('text_file')
      # TODO: 固有
      filepath =  File.join('./ictsc9/', '/problem-text', (problem[:text_file]))
      problem[:text] = File.read(filepath)
    end
  end

  problems.each do |problem|
    puts add_problem(problem)
  end
end

## teams

def add_teams(teams)
  teams.each do |team|
    puts add_team(team)
  end
end

## attachments

def add_attachment(filepath)
  full_filepath = File.expand_path(filepath)
  request(:post, 'attachments', { file: File.open(full_filepath, 'rb'),  multipart: true }, {})
end

def add_attachments(filepathes)
  filepathes.each {|filepath| add_attachments(filepath) }
end

def download_attachment(id:, access_token:)
  request(:get, "/api/attachments/#{id}/#{access_token}")
end

## members

# role_id: 2=admin, 3=writer 4=participant 5=viewer
# writer,admin,viewerは team_idとregistration_codeをnullにしてrole_idを指定する
# participantはrole_idを指定できない

def add_members(members)
  members.each do |member|
    puts add_member(member)
  end
end

#### 特定の処理に特化したちょい便利メソッドたち

def update_only_problem_group(problem_id:, group_id:)
  problem = list_problems
    .find_by(id: problem_id)
    .merge(problem_group_ids: [group_id])

  update_problem(problem)
end

# problem_idをbefore_idに依存させる
def change_depends_problem(problem_id:, before_id:)
  problem = list_problems
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

## misc

# 指定ディレクトリをまとめてアップロードする
def upload_dir_files(file_dir)
  filepathes = Dir.glob(File.join(file_dir, '/*'))
    .select {|file_path| File.file?(file_path) }

  add_attachments(filepathes)
end

def change_password(login:, password: input_secret())
  member = list_members
    .find_by(login: login)
    .merge(password: password)

  update_member(member)
end

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

$base_url = ARGV[0] || 'http://localhost:3000/api'
$responses = []

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
problem = list_problems[0]
problem[:title] = 'this is a title'
puts update_problem(problem)

# YAMLから問題を読み込んでまとめて追加
add_problems(load_file('./sample-problem-groups.yml'))

# ファイルをアップロード(ダウンロードリンクを返す)
attachment = add_attachments('./pry_r.rb')
download_attachment(id: attachment[:id], access_token: attachment[:access_token])
