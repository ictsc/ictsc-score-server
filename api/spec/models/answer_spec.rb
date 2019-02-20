require_relative '../spec_helper.rb'

describe Answer do
  include ApiHelpers

  describe 'uniqueness' do
    let(:problem) { create(:problem) }
    let(:team) {  create(:team) }
    let(:other_problem) { create(:problem) }
    let(:created_at) { DateTime.parse('2012-09-03 12:00:00 +0900') }
    let(:other_problem) { create(:problem) }
    let(:other_team) {  create(:team) }
    let(:other_created_at) { created_at + 100.minute }

    it 'success create answer' do
      answer = Answer.new(text: 'hello', problem: problem, team: team, created_at: created_at)
      expect(answer).to be_valid
      expect(answer.save).to eq true
      expect(answer.created_at).to eq created_at

      other_answer = Answer.new(text: 'hello', problem: other_problem, team: other_team, created_at: other_created_at)
      expect(other_answer).to be_valid
      expect(other_answer.save).to eq true
      expect(other_answer.created_at).to eq other_created_at
    end

    it 'failed to create duplicated answer' do
      answer = Answer.new(text: 'hello', problem: problem, team: team, created_at: created_at)
      expect(answer).to be_valid
      expect(answer.save).to eq true
      expect(answer.created_at).to eq created_at


      other_answer = Answer.new(text: 'hello', problem: problem, team: team, created_at: created_at)
      expect(other_answer).to be_invalid
      expect(other_answer.save).to eq false
      expect(other_answer.created_at).to eq created_at
    end
  end
end
