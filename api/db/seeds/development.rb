# frozen_string_literal: true

include FactoryBot::Syntax::Methods # rubocop:disable Style/MixinUsage

def create_config
  print 'creating configs...'

  configs = [
    { key: :competition_section1_start_at,  value_type: :date,    value: Time.zone.parse('2012-09-03 10:00:00') },
    { key: :competition_section1_end_at,    value_type: :date,    value: Time.zone.parse('2112-09-03 12:00:00') },
    { key: :competition_section2_start_at,  value_type: :date,    value: Time.zone.parse('2112-09-03 13:00:00') },
    { key: :competition_section2_end_at,    value_type: :date,    value: Time.zone.parse('2112-09-03 18:00:00') },
    { key: :competition_section3_start_at,  value_type: :date,    value: Time.zone.parse('2112-09-04 10:00:00') },
    { key: :competition_section3_end_at,    value_type: :date,    value: Time.zone.parse('2112-09-04 12:00:00') },
    { key: :competition_section4_start_at,  value_type: :date,    value: Time.zone.parse('2112-09-04 13:00:00') },
    { key: :competition_section4_end_at,    value_type: :date,    value: Time.zone.parse('2112-09-04 18:00:00') },

    { key: :guide_page,                     value_type: :string,  value: Array.new(Random.rand(10..30)) { Faker::Books::Dune.quote }.join("\n") },
    { key: :grading_delay_sec,              value_type: :integer, value: 30 },
    { key: :hide_all_score,                 value_type: :boolean, value: false },
    { key: :realtime_grading,               value_type: :boolean, value: true },
    { key: :competition_stop,               value_type: :boolean, value: false },
    { key: :text_size_limit,                value_type: :integer, value: 8192 },
    { key: :delete_time_limit_sec,          value_type: :integer, value: 60 },

    { key: :all_problem_force_open_at,      value_type: :date,    value: Time.zone.parse('2112-09-03 11:00:00') },
    { key: :scoreboard_hide_at,             value_type: :date,    value: Time.zone.parse('2112-09-03 12:00:00') },
    { key: :scoreboard_top,                 value_type: :integer, value: 3 },
    { key: :scoreboard_display_top_team,    value_type: :boolean, value: true },
    { key: :scoreboard_display_top_score,   value_type: :boolean, value: true },
    { key: :scoreboard_display_above_team,  value_type: :boolean, value: false },
    { key: :scoreboard_display_above_score, value_type: :boolean, value: true }
  ].map {|obj| Config.new(**obj) }

  Config.import!(configs)
  puts 'done'
  configs
end

def create_teams
  print 'creating teams...'

  # staffはseeds.rbで作成
  # 'team a' ~ 'team zz' を作成
  # パスワードはチーム名同じ
  players = build_stubbed_list(:team, 70, :player)
  audience = build_stubbed(:team, :audience, name: 'audience', number: 80)

  Team.import!([audience] + players)
  puts 'done'
  [players, audience]
end

def create_categories
  print 'creating categories...'

  categories = build_stubbed_list(:category, 10)
  categories.first.order = 0

  Category.import!(categories)
  puts 'done'
  categories
end

def markdown_sample_text
  <<~'MD'
    # Markdown

    * item1
    * item2

    I love `Markdown` :heart:


    ## Table

    | Item | Price |
    |:------|:-------|
    | bronze sword | 10G |
    | iron sword | 100G |
    | platinum sword | 1000G |


    ## Code

    ```
    def hello
      puts 'world'
    end
    ```

    ## Link

    Short
    https://blog.icttoracon.net/2019/03/21/ictsc2018-f-18/

    Long
    https://blog.icttoracon.net/hogehogehogehoge-hogehogehogehoge-hogehogehogehoge-hogehogehogehoge-hogehogehogehoge-hogehogehogehoge-hogehogehogehoge-hogehogehogehoge

    ## Image

    ![hoge](https://pbs.twimg.com/profile_banners/3034263978/1519868555/1080x360)

    ## Quote

    > hogehoge
    > foobar

    ## Blank line

    aa
    bb

    cc
    &nbsp;
    ee


    ## Normal text
  MD
end

def long_text(lines)
  Array.new(Random.rand(lines..lines + 10)) { Faker::Books::Dune.quote }.join("\n")
end

def create_problems(categories)
  print 'creating problems...'

  example_problems = [
    build_stubbed(:problem, body: build_stubbed(:problem_body, :textbox, title: '01. textbox', text: markdown_sample_text + long_text(40))),
    build_stubbed(:problem, body: build_stubbed(:problem_body, :radio_button,  title: '02. radio_button', candidates_count: 1)),
    build_stubbed(:problem, body: build_stubbed(:problem_body, :radio_button,  title: '03. radio_buttons', candidates_count: 5)),
    build_stubbed(:problem, body: build_stubbed(:problem_body, :checkbox,  title: '04. checkbox', candidates_count: 1)),
    build_stubbed(:problem, body: build_stubbed(:problem_body, :checkbox,  title: '05. checkboxs', candidates_count: 5))
  ]
  example_problems.each.with_index {|p, i| p.attributes = { category: categories.first, order: i } }

  problems = build_stubbed_list(:problem, 45)
  problems.each {|problem| problem.category = categories.sample }

  problems.prepend(*example_problems)

  Problem.import!(problems)
  ProblemBody.import!(problems.map(&:body))

  categories.each do |category|
    category.problems.sort_by(&:order).each_cons(2) do |previous, current|
      current.update!(previous_problem: previous)
    end
  end

  puts 'done'
  problems
end

def build_answers(problems, teams, count_range)
  problems.each_with_object([]) do |problem, answers|
    teams.each do |team|
      Random.rand(count_range).times { answers << build_stubbed(:answer, problem: problem, team: team) }
    end
  end
end

def create_answers(problems, players)
  print 'creating answers...'

  top_players = players[0...10]
  middle_players = players[10...-10]
  bottom_players = players[-10..]

  answers = [
    *build_answers(problems, top_players, 0..4),
    *build_answers(problems.sample(problems.size / 6), middle_players, 0..1),
    *build_answers(problems.sample(1), bottom_players, 0..1)
  ].shuffle

  # 雑な大量生成なので、未開放問題への解答を作成している
  Answer.import!(answers)

  # 面倒なのでScoreはbulk insertしない
  answers.each do |answer|
    if answer.problem.body.textbox?
      answer.grade(percent: [nil, Random.rand(0..100)].sample)
    else
      answer.grade(percent: nil)
    end
  end

  puts 'done'
  answers
end

def create_problem_environments(problems, teams)
  print 'creating problem_environments...'
  envs = problems.take(10).each_with_object([]) {|problem, memo|
    teams.each do |team|
      memo << build_stubbed(:problem_environment, problem: problem, team: team)
    end

    Random.rand(1..4).times { memo << build_stubbed(:problem_environment, problem: problem, team: nil) }
  }
    .shuffle

  ProblemEnvironment.import!(envs)
  puts 'done'
  envs
end

def create_problem_supplements(problems)
  print 'creating problem_supplements...'

  supplements = problems
    .take(10)
    .flat_map {|problem| build_stubbed_list(:problem_supplement, Random.rand(1..4), problem: problem) }
    .shuffle

  ProblemSupplement.import!(supplements)
  puts 'done'
  supplements
end

def create_notices(teams)
  print 'creating notices...'

  notices = build_stubbed_list(:notice, Random.rand(7..20))
  notices += build_stubbed_list(:notice, 3, target_team: teams.first)
  notices += teams.sample(teams.size / 3).map {|team| build_stubbed(:notice, target_team: team) }
  notices.shuffle!

  Notice.import!(notices)
  puts 'done'
  notices
end

def create_issues(problems, teams)
  print 'creating issues...'

  issues = problems.take(10).each_with_object([]) do |problem, memo|
    teams.take(10).each do |team|
      memo << build(:issue, comment_count: Random.rand(2..6), problem: problem, team: team)
    end
  end
  issues.shuffle!

  Issue.import!(issues)
  IssueComment.import!(issues.flat_map(&:comments))
  puts 'done'
  issues
end

# rubocop:disable Lint/UselessAssignment
create_config
players, audience = create_teams
categories = create_categories
problems = create_problems(categories)
answers = create_answers(problems, players)
problem_environments = create_problem_environments(problems, players)
problem_supplements = create_problem_supplements(problems)
notices = create_notices(players)
issues = create_issues(problems, players)
# TODO: attachments
# rubocop:enable Lint/UselessAssignment
