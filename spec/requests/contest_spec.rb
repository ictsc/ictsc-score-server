require_relative '../spec_helper.rb'

describe 'Contest' do
  include ApiHelpers

  describe 'GET /api/contest' do
    let(:response) { get '/api/contest' }
    subject { response.status }

    it { is_expected.to eq 200 }

    describe '#keys' do
      let(:response) { get '/api/contest' }
      subject { json_response.keys }
      let(:expected_keys) {
        %w(
          answer_reply_delay_sec
          competition_start_at
          scoreboard_hide_at
          competition_end_at
        )
      }

      it { is_expected.to match_array(expected_keys) }
    end
  end
end
