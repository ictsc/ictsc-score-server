# frozen_string_literal: true

# rubocop:disable Metrics/MethodLength

def create_config
  configs = [
    { key: :competition_section1_start_at,  value_type: :date,    value: Time.zone.parse('2012-09-03 10:00:00') },
    { key: :competition_section1_end_at,    value_type: :date,    value: Time.zone.parse('2112-09-03 12:00:00') },
    { key: :competition_section2_start_at,  value_type: :date,    value: Time.zone.parse('2112-09-03 13:00:00') },
    { key: :competition_section2_end_at,    value_type: :date,    value: Time.zone.parse('2112-09-03 18:00:00') },
    { key: :competition_section3_start_at,  value_type: :date,    value: Time.zone.parse('2112-09-04 10:00:00') },
    { key: :competition_section3_end_at,    value_type: :date,    value: Time.zone.parse('2112-09-04 12:00:00') },
    { key: :competition_section4_start_at,  value_type: :date,    value: Time.zone.parse('2112-09-04 13:00:00') },
    { key: :competition_section4_end_at,    value_type: :date,    value: Time.zone.parse('2112-09-04 18:00:00') },
    { key: :competition_stop,               value_type: :boolean, value: false },
    { key: :all_problem_force_open_at,      value_type: :date,    value: Time.zone.parse('2112-09-03 11:00:00') },
    { key: :grading_delay_sec,              value_type: :integer, value: 30 },
    { key: :hide_all_score,                 value_type: :boolean, value: false },
    { key: :scoreboard_hide_at,             value_type: :date,    value: Time.zone.parse('2112-09-03 12:00:00') },
    { key: :scoreboard_top,                 value_type: :integer, value: 3 },
    { key: :scoreboard_display_top_team,    value_type: :boolean, value: true },
    { key: :scoreboard_display_top_score,   value_type: :boolean, value: true },
    { key: :scoreboard_display_above_team,  value_type: :boolean, value: false },
    { key: :scoreboard_display_above_score, value_type: :boolean, value: true }
  ].map {|obj| Config.new(**obj) }

  Config.import!(configs)
  configs
end

def create_teams
  # staffはseeds.rbで作成
  teams = ('A'..'ZZ').take(50).map.with_index(1) do |alphabet, i|
    Team.new(
      role: 'player',
      name: "team #{alphabet.downcase}",
      password: "team #{alphabet.downcase}",
      organization: "#{alphabet}学校",
      number: i,
      color: Faker::Color.hex_color
    )
  end
  teams.unshift(Team.new(role: 'audience', name: 'audience', password: 'audience', organization: '見学者', number: 80))

  Team.import!(teams)
  teams
end

def create_categories
  categories = ('AAA'..).take(10).map.with_index(1) do |code, i|
    Category.new(code: code.reverse, title: "グループ#{i}", description: Faker::Books::Dune.saying, order: Random.rand(10..1000))
  end
  categories.first.order = 0
  Category.import!(categories)
  categories
end

def create_problems(categories, first_category)
  problems = ('AAA'...).take(50).map do |code|
    Problem.new(
      code: code.reverse,
      writer: Faker::Book.author,
      secret_text: Faker::Books::Dune.planet,
      order: Random.rand(1000),
      category: categories.sample,
      team_private: false
    )
  end

  problems.take(5).each.with_index {|p, i| p.attributes = { category: first_category, order: i } }
  Problem.import!(problems)

  categories.each do |category|
    category.problems.sort_by(&:order).each_cons(2) do |previous, current|
      current.update!(previous_problem: previous)
    end
  end

  problems
end

def create_problem_bodies(problems, example_problems)
  problem_body_textbox       = ProblemBody.new(mode: 'textbox',      title: '01. textbox',       text: Faker::Books::Dune.quote, perfect_point: 100, problem: example_problems[0])
  problem_body_radio_button  = ProblemBody.new(mode: 'radio_button', title: '02. radio_button',  text: Faker::Books::Dune.quote, perfect_point: 100, problem: example_problems[1])
  problem_body_radio_buttons = ProblemBody.new(mode: 'radio_button', title: '03. radio_buttons', text: Faker::Books::Dune.quote, perfect_point: 100, problem: example_problems[2])
  problem_body_checkbox      = ProblemBody.new(mode: 'checkbox',     title: '04. checkbox',      text: Faker::Books::Dune.quote, perfect_point: 100, problem: example_problems[3])
  problem_body_checkboxs     = ProblemBody.new(mode: 'checkbox',     title: '05. checkboxs',     text: Faker::Books::Dune.quote, perfect_point: 100, problem: example_problems[4])

  problem_body_radio_button.candidates  = [%w[a b c d e f]]
  problem_body_radio_button.corrects    = [%w[f]]
  problem_body_radio_buttons.candidates = [%w[a b c d e f], %w[G H I J]]
  problem_body_radio_buttons.corrects   = [%w[c], %w[J]]
  problem_body_checkbox.candidates      = [%w[a b c d e f]]
  problem_body_checkbox.corrects        = [%w[f a c]]
  problem_body_checkboxs.candidates     = [%w[a b c d e f], %w[G H I J]]
  problem_body_checkboxs.corrects       = [%w[f a c], %w[J H]]

  problem_bodies = problems.map.with_index(6) do |problem, i|
    ProblemBody.new(
      mode: 'textbox',
      title: '%2d. %s' % [i, Faker::Book.title],
      text: Faker::Books::Dune.quote,
      perfect_point: Random.rand(10..1000),
      problem: problem
    )
  end

  problem_bodies.unshift(problem_body_textbox, problem_body_radio_button, problem_body_radio_buttons, problem_body_checkbox, problem_body_checkboxs)
  ProblemBody.import!(problem_bodies)
  problem_bodies
end

def create_answer_bodies(problem_body)
  case problem_body.mode
  when 'textbox'
    [[Faker::Books::Dune.quote]]
  when 'radio_button'
    problem_body.candidates.map {|c| [c.sample] }
  when 'checkbox'
    problem_body.candidates.map {|c| c.sample(Random.rand(1..c.size)) }
  end
end

def create_answers(problems, example_problems, teams)
  answers = example_problems.flat_map do |problem|
    Array.new(Random.rand(1..3)) do
      # unique制約から逃れるため適当にずらす
      created_at = Time.current + Random.rand(60).minutes + Random.rand(60).seconds
      Answer.new(problem: problem, team: teams.last, confirming: false, bodies: create_answer_bodies(problem.body), created_at: created_at)
    end
  end

  answers += problems.flat_map do |problem|
    Array.new(Random.rand(4)) do
      # unique制約から逃れるため適当にずらす
      created_at = Time.current + Random.rand(60).minutes + Random.rand(60).seconds
      Answer.new(problem: problem, team: teams.last, confirming: false, bodies: create_answer_bodies(problem.body), created_at: created_at)
    end
  end

  Answer.import!(answers)
  answers
end

def create_scores(answers)
  scores = answers.map do |answer|
    # TODO: textbox以外は自動採点だし...
  end

  Score.import!(scores)
  scores
end

create_config
teams = create_teams
categories = create_categories
first_category = categories.shift
problems = create_problems(categories, first_category)
example_problems = problems.shift(5)
create_problem_bodies(problems, example_problems)
answers = create_answers(problems, example_problems, teams) # rubocop:disable Lint/UselessAssignment
# scores, issue, issue_comment, notices

# rubocop:enable Metrics/MethodLength
