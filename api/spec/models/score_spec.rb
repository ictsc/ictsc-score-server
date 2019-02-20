require_relative '../spec_helper.rb'

describe Score do
  include ApiHelpers

  describe '#refresh_first_correct_answer' do
    let(:team) { create(:team) }
    let(:problem) { create(:problem) }
    let(:answer) { create(:answer, problem: problem, team: team) }
    let(:marker) { create(:member, :writer) }

    it 'when score is mark as solved' do
      score = Score.new(solved: true, answer: answer, team: team, problem: problem, point: 0, marker: marker)

      expect { score.save! }.to change { FirstCorrectAnswer.exists?(answer: answer) }.from(false).to(true)
    end

    it 'when score is mark as unsolved' do
      score = Score.new(solved: false, answer: answer, team: team, problem: problem, point: 0, marker: marker)

      expect { score.save! }.to_not change { FirstCorrectAnswer.exists?(answer: answer) }.from(false)
    end

    context 'when mark as solved, but FCA already exists' do
      let(:pre_score) { Score.new(solved: true, answer: pre_answer, team: team, problem: problem, point: 0, marker: marker) }
      let(:score) { Score.new(solved: true, answer: answer, team: team, problem: problem, point: 0, marker: marker) }

      context "existing FCA's score is older than new score, keep FCA" do
        let(:pre_answer) { create(:answer, problem: problem, team: team, created_at: answer.created_at - 1.minute) }

        it do
          expect { pre_score.save! }.to change { FirstCorrectAnswer.exists?(answer: pre_answer) }.from(false).to(true)
          expect { score.save! }.to_not change { FirstCorrectAnswer.exists?(answer: answer) }.from(false)
          expect( FirstCorrectAnswer.exists?(answer: pre_answer)).to eq true
          expect( FirstCorrectAnswer.exists?(answer: answer)).to eq false
        end
      end

      context "when new answer older than pre_answer, replace FCA" do
        let(:pre_answer) { create(:answer, problem: problem, team: team, created_at: answer.created_at + 1.minute) }

        it do
          expect { pre_score.save! }.to change { FirstCorrectAnswer.exists?(answer: pre_answer) }.from(false).to(true)
          expect { score.save! }.to change { FirstCorrectAnswer.exists?(answer: answer) }.from(false).to(true)
          expect( FirstCorrectAnswer.exists?(answer: pre_answer)).to eq false
        end
      end
    end

    context 'change to unsolved' do
      let(:pre_answer) { create(:answer, problem: problem, team: team, created_at: answer.created_at - 1.minute) }
      let(:pre_score) { Score.new(solved: true, answer: pre_answer, team: team, problem: problem, point: 0, marker: marker) }
      let(:score) { Score.new(solved: true, answer: answer, team: team, problem: problem, point: 0, marker: marker) }

      # unsolvedしたら削除されて、別のanswerがFCAになる
      it do
        # pre_answer, answerがsolved -> FCA == pre_answer
        expect { pre_score.save! }.to change { FirstCorrectAnswer.exists?(answer: pre_answer) }.from(false).to(true)
        expect { score.save! }.to_not change { FirstCorrectAnswer.exists?(answer: answer) }.from(false)

        # pre_answer->unsolved -> FCA == pre_answer
        expect(pre_score.update(solved: false)).to eq true
        expect(FirstCorrectAnswer.exists?(answer: pre_answer)).to eq false
        expect(FirstCorrectAnswer.exists?(answer: answer)).to eq true
      end
    end

    context 'change to solved' do
      let(:pre_answer) { create(:answer, problem: problem, team: team, created_at: answer.created_at - 1.minute) }
      let(:pre_score) { Score.new(solved: false, answer: pre_answer, team: team, problem: problem, point: 0, marker: marker) }
      let(:score) { Score.new(solved: true, answer: answer, team: team, problem: problem, point: 0, marker: marker) }

      # 先に提出された解答が後でsolvedされても正常にFCAが更新される
      it do
        # pre_answer, answerがsolved -> FCA == pre_answer
        expect { pre_score.save! }.to_not change { FirstCorrectAnswer.exists?(answer: pre_answer) }.from(false)
        expect { score.save! }.to change { FirstCorrectAnswer.exists?(answer: answer) }.from(false).to(true)

        # pre_answer->solved -> FCA == pre_answer
        expect(pre_score.update(solved: true)).to eq true
        expect(FirstCorrectAnswer.exists?(answer: pre_answer)).to eq true
        expect(FirstCorrectAnswer.exists?(answer: answer)).to eq false
      end
    end

    context 'when delete solved score' do
      let(:score) { Score.new(solved: true, answer: answer, team: team, problem: problem, point: 0, marker: marker) }
      it do
        expect { score.save! }.to change { FirstCorrectAnswer.exists?(answer: answer) }.from(false).to(true)
        expect { score.destroy! }.to change { FirstCorrectAnswer.exists?(answer: answer) }.from(true).to(false)
      end
    end
  end
end
