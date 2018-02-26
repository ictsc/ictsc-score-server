require_relative '../spec_helper.rb'

describe 'Nested entity' do
  include ApiHelpers

  before(:each) {
    time = DateTime.parse("2017-07-07T21:00:00+09:00")
    allow(DateTime).to receive(:now).and_return(time)
    allow(Setting).to receive(:competition_start_at).and_return(time - 3.year)
    allow(Setting).to receive(:competition_end_at).and_return(time + 3.year)
    allow(Setting).to receive(:answer_reply_delay_sec).and_return(10.seconds)
  }

  %w(member member-team).each do |with_param|
    describe "/api/session?with=#{with_param}" do
      let(:response) { get "/api/session?with=#{with_param}" }
      subject { response.status }

      by_participant { is_expected.to eq 200 }
    end
  end

  resource_with_params = {
    problem: %w(answers answers-score answers-team issues issues-comments creator comments problem_groups),
    score: %w(answer answer-problem),
    team: %w(members answers answers-score issues issues-comments issues-comments-member),
    member: %w(team),
    # comment: %w(member),
    issue: %w(comments comments-member comments-member-team team problem),
    answer: %w(score),
    notice: %w(member),
  }

  resource_with_params.each do |resource_name, with_params|
    pluralized_name = resource_name.to_s.downcase.pluralize

    with_params.each do |with_param|
      describe pluralized_name do
        let!(:resource) do
          case resource_name
          when :issue, :answer
            create(resource_name, team: current_member.team)
          when :score
            answer = create(:answer, team: current_member.team, created_at: DateTime.now - Setting.answer_reply_delay_sec)
            create(resource_name, answer: answer)
          when :member
            current_member
          when :team
            current_member.team
          else
            create(resource_name)
          end
        end

        describe "/api/#{pluralized_name}?with=#{with_param}" do
          let(:response) { get "/api/#{pluralized_name}?with=#{with_param}" }
          subject { response.status }

          by_participant { is_expected.to eq 200 }
        end

        describe "/api/#{pluralized_name}/:id?with=#{with_param}" do
          let(:response) {
            get "/api/#{pluralized_name}/#{resource.id}?with=#{with_param}" }
          subject { response.status }

          by_participant { is_expected.to eq 200 }
        end
      end
    end
  end
end
