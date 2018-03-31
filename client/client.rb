require 'io/console'
require 'json'
require 'yaml'

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

def build_url(path)
  File.join($base_url, path)
end

def request(method, path, payload_hash = {}, headers = { content_type: :json })
  headers[:cookies] ||= $responses.last&.cookies
  payload = headers[:content_type] == :json ? payload_hash.to_json : payload_hash

  $responses << RestClient::Request.execute(method: method.to_sym, url: build_url(path), payload: payload, headers: headers)
  JSON.parse($responses.last)
end

def load_file(filepath)
  filepath = File.expand_path(filepath)
  case File.extname(filepath)
  when '.yml', '.yaml'
    YAML.load(File.read(filepath))
  when '.json'
    JSON.parse(File.read(filepath))
  end
end


def login(login:, password:)
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
  problem_groups.each do |g|
    puts add_problem_group(
      name: g['name'],
      description: g['description'],
      visible: g['visible'],
      completing_bonus_point: g['completing_bonus_point'],
      icon_url: g['icon_url'],
      order: g['order'],
    )
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
  problems.each do |p|
    if p.key?('text_file')
      # TODO: 固有
      filepath =  File.join('./ictsc9/', '/problem-text', (p['text_file']))
      p['text'] = File.read(filepath)
    end
  end

  problems.each do |p|
    puts add_problem(
      title: p['title'],
      text: p['text'],
      secret_text: p['secret_text'],
      order: p['order'],
      reference_point: p['reference_point'],
      perfect_point: p['perfect_point'],
      team_private: p['team_private'],
      creator_id: p['creator_id'],
      problem_must_solve_before_id: p['problem_must_solve_before_id'],
      problem_group_ids: p['problem_group_ids'],
    )
  end
end

# def update_problem(id:, title:, text:, reference_point:, perfect_point:, creator_id:, problem_group_ids:, problem_must_solve_before_id:)
def update_problem(problem_hash)
  request(:put, "problems/#{problem_hash['id']}", problem_hash)
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
  teams.each do |t|
    puts add_team(
      name: t['name'],
      organization: t['organization'],
      registration_code: t['registration_code'],
    )
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
# participantはrole_idを指定しないでもいい
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
  members.each do |m|
    puts add_member(
      name: m['name'],
      login: m['login'],
      password: m['password'],
      team_id: m['team_id'],
      registration_code: m['registration_code'],
      role_id: m['role_id'],
    )
  end
end

def update_member(member_hash)
  request(:put, "members/#{member_hash['id']}", member_hash)
end

#### 特定の処理に特化したちょい便利メソッドたち

def update_only_problem_group(problem_id:, group_id:)
  problem = list_problems.find{|e| e['id'] == problem_id }
  problem['problem_group_ids'] = [group_id]
  update_problem(problem)
end

# afterをbeforeに依存させる
def change_depends_problem(before_id:, after_id:)
  after_problem = list_problems.find {|e| e['id'] == after_id }
  after_problem['problem_must_solve_before_id'] = before_id
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
  Dir.glob(File.join(file_dir, '/*')).select{|file_path| File.file?(file_path) }.each do |file_path|
    p add_attachments(file_path)['url']
  end
end

def change_password(login:, password: input_password())
  member_hash = list_members.find{|m| m['login'] == login }
  member_hash['password'] = password
  update_member(member_hash)
end

def input_password()
  print 'password: '
  STDIN.noecho(&:gets).chomp
end

$base_url = ARGV[0] || 'http://localhost:3000/api'
$responses = []

login(login: :admin, password: input_password())

require 'pry'
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
problem['title'] = 'this is a title'
puts update_problem(problem)

# YAMLから問題を読み込んでまとめて追加
add_problems(load_file('./sample-problem-groups.yml'))

# ファイルをアップロード(ダウンロードリンクを返す)
attachment = add_attachments('./pry_r.rb')
download_attachment(id: attachment[:id], access_token: attachment[:access_token])
