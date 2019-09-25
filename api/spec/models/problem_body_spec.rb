# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProblemBody, type: :model do
  describe '#candidates' do
    # rubocop:disable Style/WordArray
    let(:valid_select_mode_candidates_list) do
      [
        [['foo', 'bar']],
        [['foo', 'bar', 'hoge']],
        [['foo', 'bar'], ['hoge', 'fuga']],
        [['foo', 'bar'], ['hoge', 'fuga'], ['one', 'two']],
        [['foo', 'bar'], ['foo', 'bar']],
        [['foo', 'bar'], ['foo', 'bar'],  ['foo', 'bar']],
        [['10', '20']], [['1.1', '2.2']], [['null', 'undefined']]
      ]
    end

    let(:invalid_select_mode_candidates_list) do
      [
        nil, '', 10, [], [nil], [10], [''], [[]], [['']], [[nil]], [[[]]], [['foo']], [[['foo', 'bar']]],
        [['foo', 'foo']], [['foo', 'foo', 'foo']], [['foo', 'bar', 'foo']],
        [['', '']], [[nil, nil]], [[10, 20]], [['', nil]],
        [['foo', '']], [['foo', nil]], [['foo', 10]],
        [['foo', 'bar', '']], [['foo', 'bar', nil]], [['foo', 'bar', 10]],
        [['foo', 'bar'], nil], [['foo', 'bar'], ''], [['foo', 'bar'], 10], [['foo', 'bar'], []],
        [['foo', 'bar'], ['hoge']], [['foo', 'bar'], ['foo', 'foo']], [['foo', 'bar'], [10, 20]]
      ]
    end

    let(:valid_candidates) do
      {
        textbox: [[]],
        radio_button: valid_select_mode_candidates_list,
        checkbox: valid_select_mode_candidates_list
      }
    end

    let(:invalid_candidates) do
      {
        textbox: [nil, [[]], [['']], [[nil]], [[[]]], [[1]], [['foo', 'bar']]],
        radio_button: invalid_select_mode_candidates_list,
        checkbox: invalid_select_mode_candidates_list
      }
    end
    # rubocop:enable Style/WordArray

    shared_examples 'valid' do |mode|
      subject { build_stubbed(:problem_body, mode: mode) }

      context "when #{mode}" do
        it { is_expected.to allow_values(*valid_candidates[mode]).for(:candidates) }
      end
    end

    shared_examples 'invalid' do |mode|
      subject { build_stubbed(:problem_body, mode: mode) }

      context "when #{mode}" do
        it { is_expected.not_to allow_values(*invalid_candidates[mode]).for(:candidates) }
      end
    end

    it_behaves_like 'valid', :textbox
    it_behaves_like 'valid', :radio_button
    it_behaves_like 'valid', :checkbox
    it_behaves_like 'invalid', :textbox
    it_behaves_like 'invalid', :radio_button
    it_behaves_like 'invalid', :checkbox
  end

  describe '#corrects' do
    include_context 'answer_bodies_variables'

    let(:valid_textbox) do
      [
        []
      ]
    end

    let(:invalid_textbox) do
      [
        nil, [[]], [[nil]], [[1]], [[[]]], [['']], [['foo']]
      ]
    end

    shared_examples 'valid' do |mode|
      subject { build_stubbed(:problem_body, mode: mode, candidates: candidates_list[mode]) }

      context "when #{mode}" do
        it { is_expected.to allow_values(*valid_list[mode]).for(:corrects) }
      end
    end

    shared_examples 'invalid' do |mode|
      subject { build_stubbed(:problem_body, mode: mode, candidates: candidates_list[mode]) }

      context "when #{mode}" do
        it { is_expected.not_to allow_values(*invalid_list[mode]).for(:corrects) }
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
