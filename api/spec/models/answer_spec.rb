# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Answer, type: :model do
  describe '#bodies' do
    include_context 'answer_bodies_variables'

    # rubocop:disable Style/WordArray
    let(:valid_textbox) do
      [
        [['hogehog']]
      ]
    end

    let(:invalid_textbox) do
      [
        nil, [[]], [[nil]], [[1]], [[[]]], [['']], [['foo', 'bar']]
      ]
    end

    let(:corrects_list) do
      {
        textbox: [],
        radio_button: [['two'], ['foo']],
        checkbox: [['one', 'two', 'three'], ['fuga']]
      }
    end
    # rubocop:enable Style/WordArray

    shared_examples 'valid' do |mode|
      subject { build_stubbed(:answer, problem: problem, team: player) }

      let!(:problem_body) { build(:problem_body, mode: mode, candidates: candidates_list[mode], corrects: corrects_list[mode]) }
      let!(:problem) { create(:problem, body: problem_body) }

      context "when #{mode}" do
        it { is_expected.to allow_values(*valid_list[mode]).for(:bodies) }
      end
    end

    shared_examples 'invalid' do |mode|
      subject { build_stubbed(:answer, problem: problem, team: player) }

      let!(:problem_body) { build(:problem_body, mode: mode, candidates: candidates_list[mode], corrects: corrects_list[mode]) }
      let!(:problem) { create(:problem, body: problem_body) }

      context "when #{mode}" do
        it { is_expected.not_to allow_values(*invalid_list[mode]).for(:bodies) }
      end
    end

    it_behaves_like 'valid', :textbox
    it_behaves_like 'valid', :radio_button
    it_behaves_like 'valid', :checkbox
    it_behaves_like 'invalid', :textbox
    it_behaves_like 'invalid', :radio_button
    it_behaves_like 'invalid', :checkbox
  end
end
