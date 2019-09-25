# frozen_string_literal: true

# Answer#bodiesとProblemBody#correctsは同じフォーマットなため共通部分を抜き出した
RSpec.shared_context 'answer_bodies_variables' do # rubocop:disable Metrics/BlockLength, RSpec/ContextWording
  # rubocop:disable Style/WordArray
  let(:candidates_list) do
    cands = [['one', 'two', 'three'], ['foo', 'bar', 'hoge', 'fuga']].freeze

    {
      textbox: [],
      radio_button: cands,
      checkbox: cands
    }
  end

  let(:valid_radio_button) do
    [
      [['two'], ['fuga']],
      [['three'], ['hoge']]
    ]
  end

  let(:valid_checkbox) do
    [
      # 空
      [[], []],
      [[], ['fuga']],
      # 全要素
      [['one', 'two', 'three'], ['foo', 'bar', 'hoge', 'fuga']],
      # 順序入れ替え
      [['three', 'one'], ['fuga', 'foo']]
    ]
  end

  let(:invalid_radio_button) do
    [
      # 構造的間違い
      '', nil, 10, [], ['foo', 'hoge'], [10, 20], [[], ''], [[''], [10]], [[''], ['fuga']],
      # 不足
      [['one']],
      # 空
      [['one'], []],
      # 余分
      [['one'], ['foo', 'bar']],
      # 選択肢外
      [['one'], ['hogehogehoge']],
      # 順序間違い
      [['hoge'], ['one']]
    ]
  end

  let(:invalid_checkbox) do
    [
      # 構造的間違い
      '', nil, 10, [], ['foo', 'hoge'], [10, 20], [[], ''], [[''], [10]], [['', 10], ['hoge', 'fuga']],
      # 不足
      [['one', 'two']],
      # 重複
      [['one'], ['foo', 'foo']],
      [['one'], ['foo', 'hoge', 'hoge']],
      # 選択肢外
      [['one'], ['hogehogehoge']],
      # 順序間違い
      [['hoge'], ['one']]
    ]
  end

  let(:valid_list) do
    {
      textbox: valid_textbox,
      radio_button: valid_radio_button,
      checkbox: valid_checkbox
    }
  end

  let(:invalid_list) do
    {
      textbox: invalid_textbox,
      radio_button: invalid_radio_button,
      checkbox: invalid_checkbox
    }
  end

  # rubocop:enable Style/WordArray
end
