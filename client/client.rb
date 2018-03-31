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

def input_password()
  print 'password: '
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


## API endpoints

API_ENDPOINTS = {
  answers: {},
  attachments: {},
  comments: {},
  contests: {},
  issues: {},
  members: {},
  notices: {},
  problems: {},
  problem_groups: {},
  scores: {},
  scoreboard: {},
  teams: {},
}

## session

def login(login:, password: input_password)
  request(:post, 'session', { login: login, password: password })
end

def logout
  request(:delete, 'session')
end

## problem groups

def list_problem_groups()
  request(:get, 'problem_groups')
end

def add_problem_group(name:, description:, visible: true, completing_bonus_point: 0, icon_url: '', order:)
  data = {
    name: name,
    description: description,
    visible: visible,
    completing_bonus_point: completing_bonus_point,
    icon_url: icon_url,
    order: order,
  }

  request(:post, 'problem_groups', data)
end

def add_problem_groups(problem_groups)
  problem_groups.each do |problem_group|
    puts add_problem_group(problem_group)
  end
end

## problems

def list_problems(with: [])
  with_params = with.empty? ? '' : "?with=#{with.join(',')}"
  request(:get, 'problems' + with_params)
end

def add_problem(title:, text:, secret_text: '', reference_point:, perfect_point:, creator_id:, problem_group_ids:, problem_must_solve_before_id:, order: 0, team_private: false)
  data = {
    title: title,
    text: text,
    secret_text: secret_text,
    reference_point: reference_point,
    perfect_point: perfect_point,
    order: order,
    creator_id: creator_id,
    team_private: team_private,
    problem_must_solve_before_id: problem_must_solve_before_id,
    problem_group_ids: problem_group_ids,
  }

  request(:post, 'problems', data)
end

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

# def update_problem(id:, title:, text:, reference_point:, perfect_point:, creator_id:, problem_group_ids:, problem_must_solve_before_id:)
def update_problem(problem)
  request(:put, "problems/#{problem[:id]}", problem)
end

## teams

def list_teams
  request(:get, 'teams')
end

def add_team(name:, organization:, registration_code:)
  data = {
    name: name,
    organization: organization,
    registration_code: registration_code,
  }
  request(:post, 'teams', data)
end

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

def list_attachments
  request(:get, 'attachments')
end

def download_attachment(id:, access_token:)
  request(:get, "/api/attachments/#{id}/#{access_token}")
end

## members

def list_members()
  request(:get, 'members')
end

# role_id: 2=admin, 3=writer 4=participant 5=viewer
# writer,admin,viewerは team_idとregistration_codeをnullにしてrole_idを指定する
# participantはrole_idを指定できない
def add_member(name:, login:, password:, team_id: nil, registration_code: nil, role_id: nil)
  data = {
    name: name,
    login: login,
    password: password,
    team_id: team_id,
    registration_code: registration_code,
    role_id: role_id,
  }
  request(:post, 'members', data)
end

def add_members(members)
  members.each do |member|
    puts add_member(member)
  end
end

def update_member(member_hash)
  request(:put, "members/#{member_hash[:id]}", member_hash)
end

#### 特定の処理に特化したちょい便利メソッドたち

def update_only_problem_group(problem_id:, group_id:)
  problem = list_problems.find {|problem| problem[:id] == problem_id }
  problem[:problem_group_ids] = [group_id]
  update_problem(problem)
end

# afterをbeforeに依存させる
def change_depends_problem(before_id:, after_id:)
  after_problem = list_problems.find {|problem| problem[:id] == after_id }
  after_problem[:problem_must_solve_before_id] = before_id
  update_problem(after_problem)
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
  Dir.glob(File.join(file_dir, '/*'))
    .select {|file_path| File.file?(file_path) }
    .map {|file_path| add_attachments(file_path) }
end

def change_password(login:, password: input_password())
  member_hash = list_members.find{|m| m[:login] == login }
  member_hash[:password] = password
  update_member(member_hash)
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
