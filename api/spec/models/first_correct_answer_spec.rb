require_relative '../spec_helper.rb'

describe FirstCorrectAnswer do
  include ApiHelpers

  describe '#valid_relation' do
    let(:answer) { create(:answer) }
    let(:problem) { answer.problem }
    let(:team) { answer.team }
    let(:other_answer) { create(:answer) }
    let(:other_problem) { create(:problem) }
    let(:other_team) { create(:team) }

    it 'valid relation' do
      fca = FirstCorrectAnswer.new(answer: answer, problem: problem, team: team)
      expect(fca).to be_valid
    end

    it 'different answer.problem and problem' do
      fca = FirstCorrectAnswer.new(answer: answer, problem: problem, team: other_team)
      expect(fca).to be_invalid
    end

    it 'different answer.team and team' do
      fca = FirstCorrectAnswer.new(answer: answer, problem: other_problem, team: team)
      expect(fca).to be_invalid
    end
  end

  describe 'uniqueness' do
    let(:answer) { create(:answer) }
    let(:problem) { answer.problem }
    let(:team) { answer.team }
    let(:other_answer) { create(:answer) }
    let(:other_problem) { other_answer.problem }
    let(:other_team) {  other_answer.team  }

    it 'success create FCA' do
      fca = FirstCorrectAnswer.new(answer: answer, problem: problem, team: team)
      expect(fca).to be_valid
      expect(fca.save).to eq true

      other_fca = FirstCorrectAnswer.new(answer: other_answer, problem: other_problem, team: other_team)
      expect(other_fca).to be_valid
      expect(other_fca.save).to eq true
    end

    it 'failed create duplicate FCA' do
      fca = FirstCorrectAnswer.new(answer: answer, problem: problem, team: team)
      expect(fca).to be_valid
      expect(fca.save).to eq true

      fca = FirstCorrectAnswer.new(answer: answer, problem: problem, team: team)
      expect(fca).to be_invalid
      expect(fca.save).to eq false
    end
  end
end
