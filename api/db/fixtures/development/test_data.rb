# rubocop:disable Metrics/BlockLength
require 'open3'
require 'sinatra/crypt_helpers'

extend Sinatra::CryptHelpers # rubocop:disable Style/MixinUsage:

srand(1)

alnum    = ->(i) { [*1..i].map { ([*'a'..'z'] + [*'A'..'Z'] + [*'0'..'9']).sample }.join } # rubocop:disable Lint/UselessAssignment
hiragana = ->(i) { [*1..i].map { [*'あ'..'ん'].sample }.join }

# rubocop:disable Layout/ExtraSpacing, Layout/IndentArray
Config.seed(:key, [
  { key: :competition_time_day1_start_at, value_type: :date,    value: DateTime.parse('2012-09-03 10:00:00 +0900') },
  { key: :competition_time_day1_end_at,   value_type: :date,    value: DateTime.parse('2112-09-03 18:00:00 +0900') },
  { key: :competition_time_day2_start_at, value_type: :date,    value: DateTime.parse('2112-09-03 10:00:00 +0900') },
  { key: :competition_time_day2_end_at,   value_type: :date,    value: DateTime.parse('2112-09-03 18:00:00 +0900') },
  { key: :competition_stop,               value_type: :boolean, value: false },
  { key: :problem_open_all_at,            value_type: :date,    value: DateTime.parse('2112-09-03 11:00:00 +0900') },
  { key: :grading_delay_sec,              value_type: :integer, value: 30 },
  { key: :scoreboard_hide_at,             value_type: :date,    value: DateTime.parse('2112-09-03 12:00:00 +0900') },
  { key: :scoreboard_top,                 value_type: :integer, value: 3 },
  { key: :scoreboard_display_top_team,    value_type: :boolean, value: true },
  { key: :scoreboard_display_top_score,   value_type: :boolean, value: true },
  { key: :scoreboard_display_above_team,  value_type: :boolean, value: false },
  { key: :scoreboard_display_above_score, value_type: :boolean, value: true },
])

Team.seed(:id, [
  { id: 1,  name: 'Team 1',        organization: 'A学校',              hashed_registration_code: hash_password('teama') },
  { id: 2,  name: 'Team 2',        organization: 'B学校',              hashed_registration_code: hash_password('teamb') },
  { id: 3,  name: 'Team 3',        organization: 'C学校',              hashed_registration_code: hash_password('teamc') },
  { id: 4,  name: 'Team 4',        organization: 'D学校',              hashed_registration_code: hash_password('teamd') },
  { id: 5,  name: 'Team 5',        organization: 'E学校',              hashed_registration_code: hash_password('teame') },
  { id: 6,  name: 'Team 6',        organization: 'F学校',              hashed_registration_code: hash_password('teamf') },
  { id: 20, name: 'Daydream Café', organization: 'Rabbit house',       hashed_registration_code: hash_password('pyonpyon') },
  { id: 21, name: 'fourfolium',    organization: 'イーグルジャンプ',   hashed_registration_code: hash_password('zoi') },
  { id: 22, name: "\u{1F338}",     organization: 'ロゴが変わった会社', hashed_registration_code: hash_password('sakura') },
  { id: 23, name: 'らびりんず',    organization: '棗屋',               hashed_registration_code: hash_password('kurou') },
])

Member.seed(:login, [
  { name: 'admin',   login: 'admin',   hashed_password: hash_password('admin'),               role: Role.admin! },
  { name: 'writer1', login: 'writer1', hashed_password: hash_password('writer1'),             role: Role.writer! },
  { name: 'writer2', login: 'writer2', hashed_password: hash_password('writer2'),             role: Role.writer! },
  { name: 'writer3', login: 'writer3', hashed_password: hash_password('writer3'),             role: Role.writer! },
  { name: 'a_1',     login: 'a_1',     hashed_password: hash_password('a_1'),    team_id: 1,  role: Role.participant! },
  { name: 'a_2',     login: 'a_2',     hashed_password: hash_password('a_2'),    team_id: 1,  role: Role.participant! },
  { name: 'b_1',     login: 'b_1',     hashed_password: hash_password('b_1'),    team_id: 2,  role: Role.participant! },
  { name: 'b_2',     login: 'b_2',     hashed_password: hash_password('b_2'),    team_id: 2,  role: Role.participant! },
  { name: 'c_1',     login: 'c_1',     hashed_password: hash_password('c_1'),    team_id: 3,  role: Role.participant! },
  { name: 'c_2',     login: 'c_2',     hashed_password: hash_password('c_2'),    team_id: 3,  role: Role.participant! },
  { name: 'd_1',     login: 'd_1',     hashed_password: hash_password('d_1'),    team_id: 4,  role: Role.participant! },
  { name: 'd_2',     login: 'd_2',     hashed_password: hash_password('d_2'),    team_id: 4,  role: Role.participant! },
  { name: 'e_1',     login: 'e_1',     hashed_password: hash_password('e_1'),    team_id: 5,  role: Role.participant! },
  { name: 'e_2',     login: 'e_2',     hashed_password: hash_password('e_2'),    team_id: 5,  role: Role.participant! },
  { name: 'f_1',     login: 'f_1',     hashed_password: hash_password('f_1'),    team_id: 6,  role: Role.participant! },
  { name: 'f_2',     login: 'f_2',     hashed_password: hash_password('f_2'),    team_id: 6,  role: Role.participant! },
  { name: 'cocoa',   login: 'cocoa',   hashed_password: hash_password('cocoa'),  team_id: 20, role: Role.participant! },
  { name: 'chino',   login: 'chino',   hashed_password: hash_password('chino'),  team_id: 20, role: Role.participant! },
  { name: 'rise',    login: 'rise',    hashed_password: hash_password('rise'),   team_id: 20, role: Role.participant! },
  { name: 'aoba',    login: 'aoba',    hashed_password: hash_password('aoba'),   team_id: 21, role: Role.participant! },
  { name: 'hajime',  login: 'hajime',  hashed_password: hash_password('hajime'), team_id: 21, role: Role.participant! },
  { name: 'hifumi',  login: 'hifumi',  hashed_password: hash_password('hifumi'), team_id: 21, role: Role.participant! },
  { name: 'yun',     login: 'yun',     hashed_password: hash_password('yun'),    team_id: 21, role: Role.participant! },
  { name: 'kou',     login: 'kou',     hashed_password: hash_password('kou'),    team_id: 21, role: Role.participant! },
  { name: 'sakura',  login: 'sakura',  hashed_password: hash_password('sakura'), team_id: 22, role: Role.participant! },
  { name: 'chiya',   login: 'chiya',   hashed_password: hash_password('chiya'),  team_id: 23, role: Role.participant! },
  { name: 'kon',     login: 'kon',     hashed_password: hash_password('kon'),    team_id: 23, role: Role.participant! },
  { name: 'koume',   login: 'koume',   hashed_password: hash_password('koume'),  team_id: 23, role: Role.participant! },
  { name: 'nono',    login: 'nono',    hashed_password: hash_password('nono'),   team_id: 23, role: Role.participant! },
  { name: 'viewer',  login: 'viewer',  hashed_password: hash_password('viewer'),              role: Role.viewer! },
])
# rubocop:enable Layout/ExtraSpacing, Layout/IndentArray

admin   = Role.admin!.members.first
writers = Role.writer!.members

# 全20問を作成
# Problem (10, 20, ... 10n) を作成
# Problem (11, 21, ... 10n+1) を作成
# Problem (12, 22, ... 10n+2) を作成
# Problem (15, 25, ... 10n+5) を作成

def create_problem(id, text, creator, must_solve_before, max, group_id = []) # rubocop:disable Metrics/ParameterLists
  Problem.seed(:id) do |p|
    p.id                           = id
    p.title                        = "問題#{id}"
    p.text                         = text
    p.creator                      = creator
    p.problem_must_solve_before_id = must_solve_before
    p.reference_point              = max * 0.8
    p.perfect_point                = max
    p.problem_group_ids            = group_id
    p.created_at                   = DateTime.now
    p.updated_at                   = DateTime.now
  end
end

5.times do |i|
  x = (i + 1) * 10

  group = ProblemGroup.seed(:id) do |pg|
    pg.id          = i + 1
    pg.name        = "問題グループ#{i + 1}"
    pg.description = hiragana[120]
    pg.completing_bonus_point = rand(10) * 10
  end.first

  create_problem(x,     hiragana[20], writers.sample, nil,   rand(5) * 30 + 100, [group.id])
  create_problem(x + 1, hiragana[20], writers.sample, x,     rand(5) * 40 + 200, [group.id])
  create_problem(x + 2, hiragana[20], writers.sample, x + 1, rand(5) * 60 + 300, [group.id])
  create_problem(x + 3, hiragana[20], writers.sample, x + 2, rand(5) * 50 + 500, [group.id])
  create_problem(x + 5, hiragana[20], writers.sample, x,     rand(11) * 5 + 38,  [group.id])
end

(6..10).each do |i|
  group = ProblemGroup.seed(:id) do |pg|
    pg.id          = i
    pg.name        = "問題グループ#{i} (non-visible)"
    pg.description = hiragana[120]
    pg.completing_bonus_point = rand(10) * 10
    pg.visible = false
  end.first

  Problem.all.shuffle.take(3).each do |problem|
    problem.problem_groups << group
  end
end

Team.all.each do |team|
  5.times do |i|
    x = (i + 1) * 10
    problems = Problem.where(id: x..(x + 9))
    last_answer = nil

    problems.each do |p|
      next if Problem.readables(user: team.members.first).where(id: p.id).to_a.empty?

      last_answer = nil if (p.id % 10).zero?

      answer_id = 5 * (p.id * 100 + team.id)
      is_rabbithouse = team.id == 20

      last_answer = Answer.seed(:id) do |a|
        a.id           = answer_id
        a.problem_id   = p.id
        a.team_id      = team.id
        a.text         = hiragana[100]

        if last_answer
          date = last_answer.created_at + 1.minutes + rand(120).seconds
          a.created_at = date
          a.updated_at = date
        end
      end.first

      will_marked = is_rabbithouse || (rand(8) != 4) # 7/8
      next unless will_marked

      point = if is_rabbithouse
                p.perfect_point
              else
                p.perfect_point * (rand(10) / 10.0)
              end

      last_score = Score.seed(:answer_id) do |s|
        s.point      = point
        s.answer_id  = last_answer.id
        s.marker     = admin
        date = last_answer.created_at + rand(60).seconds
        s.created_at = date
        s.updated_at = date
        s.solved     = point >= p.reference_point
      end.first

      next if is_rabbithouse

      # second answer
      second_point = p.perfect_point * (rand(8) / 10.0)
      second_point = p.perfect_point if p.perfect_point < (point + second_point)

      # is_marked = is_rabbithouse || (rand(8) != 4) # 7/8

      last_answer = Answer.seed(:id) do |a|
        a.id         = answer_id + 1
        a.problem_id = p.id
        a.team_id    = team.id
        a.text       = hiragana[100]
        date = last_score.created_at + 1.minutes + rand(120).seconds
        a.created_at = date
        a.updated_at = date
      end.first

      will_marked = rand(8) != 4 # 7/8
      next unless will_marked

      Score.seed(:answer_id) do |s|
        s.point      = second_point
        s.answer_id  = last_answer.id
        s.marker     = admin
        date = last_answer.created_at + rand(60).seconds
        s.created_at = date
        s.updated_at = date
        s.solved     = second_point >= p.reference_point
      end
    end
  end
end

# problem_comments
Problem.find(Problem.ids.shuffle.take(10)).each do |problem|
  # create 0 or 1 or 2 problems per problem
  rand(3).times do |n|
    Comment.seed(:id) do |c|
      c.id          = problem.id * 100 + n + 500_000
      c.text        = hiragana[50]
      c.member_id   = problem.creator_id
      c.commentable = problem
      c.created_at  = problem.created_at + 5.minutes
      c.updated_at  = problem.created_at + 10.minutes
    end
  end
end

# issue_comments
Problem.all.each do |problem|
  # create 0..4 issues per problem
  rand(5).times do |n|
    team       = Team.find(Team.ids.sample)
    closed     = rand(2) == 1
    created_at = problem.created_at + rand(1440).minutes
    updated_at = created_at + (closed ? 2.hours : 0)

    issue = Issue.seed(:id) do |i|
      i.id         = 10 * (problem.id * 100 + team.id) + n
      i.title      = hiragana[16]
      i.closed     = closed
      i.problem_id = problem.id
      i.created_at = created_at
      i.updated_at = updated_at
      i.team_id    = team.id
    end.first

    members = team.members
    creator = [problem.creator]

    rand(1..4).times do |m|
      time   = issue.created_at + m * rand(20).minutes
      member = m.zero? ? members.sample : [members, creator].sample.sample

      Comment.seed(:id) do |c|
        c.id          = 10 * issue.id + m + 600_000
        c.text        = hiragana[50]
        c.member_id   = member.id
        c.commentable = issue
        c.created_at  = time
        c.updated_at  = time
      end
    end

    next unless issue.closed

    # closed comments might have comment by problem creator
    Comment.seed(:id) do |c|
      c.id          = 10 * issue.id + 9 + 600_000
      c.text        = hiragana[50]
      c.member_id   = problem.creator.id
      c.commentable = issue
      c.created_at  = issue.created_at + 5 * rand(20).minutes
      c.updated_at  = issue.created_at + 5 * rand(20).minutes
    end
  end
end

10.times do |i|
  member = Member.joins(:role).where(roles: { name: %w[Admin Writer] }).sample
  Notice.seed(:id) do |n|
    n.id        = i + 1
    n.title     = hiragana[10]
    n.text      = hiragana[50]
    n.pinned    = rand(3).zero? # 1/3
    n.member_id = member.id
    date = DateTime.now + rand(480).minutes
    n.created_at = date
    n.updated_at = date
  end
end
# rubocop:enable Metrics/BlockLength
