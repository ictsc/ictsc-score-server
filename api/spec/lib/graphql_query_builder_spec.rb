# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GraphqlQueryBuilder do
  describe '#build_query' do
    subject { described_class.build_query(name: name, field: field, operation_name: operation_name) }

    let(:name) { 'team' }
    let(:field) { 'FIELD_STRING' }
    let(:operation_name) { 'OP_NAME' }

    let(:result_query) do
      <<~QUERY
        query OP_NAME($id: ID!) {
          team(id: $id) {
            FIELD_STRING
          }
        }
      QUERY
    end

    it '引数からクエリを構築する' do
      is_expected.to eq(result_query)
    end
  end

  describe '#build_mutation' do
    subject { described_class.build_mutation(name: name, field: field, operation_name: operation_name) }

    let(:name) { 'pinNotice' }
    let(:field) { 'FIELD_STRING' }
    let(:operation_name) { 'OP_NAME' }

    let(:result_query) do
      <<~QUERY
        mutation OP_NAME($input: PinNoticeInput!) {
          pinNotice(input: $input) {
            FIELD_STRING
          }
        }
      QUERY
    end

    it '引数からミューテーションのクエリを構築する' do
      is_expected.to eq(result_query)
    end
  end

  describe '#build_query_field_query' do
    # 他のメソッドにほぼそのまま引数を渡すだけなので細かくはテストしない
    subject { described_class.build_query_field_query(name: name, nest_fields: nest_fields) }

    let(:name) { 'me' }
    let(:nest_fields) { %w[attachments penalties] }

    before(:each) do
      allow(described_class).to receive(:find_root_query_type_by_name).with(name).and_return(Types::TeamType)
      allow(described_class).to receive(:fields_to_query).with(fields: Types::TeamType.fields, nest_fields: nest_fields)
    end

    it 'nameをfind_root_query_type_by_nameに渡す' do
      subject # rubocop:disable RSpec/NamedSubject
      expect(described_class).to have_received(:find_root_query_type_by_name).with(name)
    end

    it 'nest_fieldsをfields_to_queryに渡す' do
      subject # rubocop:disable RSpec/NamedSubject
      expect(described_class).to have_received(:fields_to_query).with(fields: Types::TeamType.fields, nest_fields: nest_fields)
    end
  end

  describe '#build_mutation_field_query' do
    subject { described_class.build_mutation_field_query(name: name, nest_fields: nest_fields) }

    let(:name) { 'addIssueComment' }
    let(:nest_fields) { { 'issue' => ['comments'] } }

    # テスト書くのが大変なため、実際の値で検証する
    # 依存しているTypeの定義が変わったら生成し直す必要がある
    let(:result_query) do
      # 生成コード
      # puts GraphqlQueryBuilder.build_mutation_field_query(name: 'addIssueComment', nest_fields: { 'issue' => ['comments'] })'
      <<~QUERY
        clientMutationId
        issue { id status problemId teamId updatedAt
        comments { id issueId text fromStaff createdAt } }
        issueComment { id issueId text fromStaff createdAt }
      QUERY
        .chomp
    end

    # 無いよりまし
    it '期待されるクエリが得られる' do
      is_expected.to eq(result_query)
    end
  end

  describe '#fields_to_query' do
    subject { described_class.fields_to_query(fields: fields, nest_fields: nest_fields) }

    dummy_type_child = Class.new(Types::BaseObject) do |_klass|
      field :composite, Types::TeamType, null: false
      field :non_composite, GraphQL::Types::String, null: false

      def self.graphql_name
        'dummy_type_child'
      end
    end

    dummy_type = Class.new(Types::BaseObject) do |_klass|
      field :child, dummy_type_child, null: false
      field :children, [dummy_type_child], null: false
      field :non_composite, GraphQL::Types::String, null: false
    end

    context 'when nest_fieldsを省略' do
      subject { described_class.fields_to_query(fields: fields) }

      let(:fields) { dummy_type.fields }

      it 'compositeではないフィールドのみ含まれる' do
        is_expected.to eq('nonComposite')
      end
    end

    context 'when nest_fieldsに全てのcomposite fieldを指定' do
      let(:fields) { dummy_type.fields }
      let(:nest_fields) { %w[child children] }
      let(:result_query) do
        <<~QUERY
          nonComposite
          child { nonComposite }
          children { nonComposite }
        QUERY
          .chomp
      end

      it '全てのフィールドが含まれる' do
        is_expected.to eq(result_query)
      end
    end
  end

  describe '#build_composite_fields_query' do
    subject { described_class.build_composite_fields_query(fields: fields, nest_field_names: nest_field_names) }

    dummy_type_child = Class.new(Types::BaseObject) do |_klass|
      field :composite, Types::TeamType, null: false
      field :non_composite, GraphQL::Types::String, null: false

      def self.graphql_name
        'dummy_type_child'
      end
    end

    dummy_type = Class.new(Types::BaseObject) do |_klass|
      field :child, dummy_type_child, null: false
      field :children, [dummy_type_child], null: false
      field :non_composite, GraphQL::Types::String, null: false
    end

    context 'when nest_field_namesが空' do
      let(:fields) { dummy_type.fields }
      let(:nest_field_names) { [] }

      it '空文字列が返る' do
        is_expected.to eq('')
      end
    end

    context 'when nest_field_namesに1つのcomposite fieldを指定' do
      let(:fields) { dummy_type.fields }
      let(:nest_field_names) { ['child'] }
      let(:result_query) { 'child { nonComposite }' }

      it '指定した要素のみクエリに含まれる' do
        is_expected.to eq(result_query)
      end
    end

    context 'when nest_field_namesに2つのcomposite fieldを指定' do
      let(:fields) { dummy_type.fields }
      let(:nest_field_names) { %w[child children] }
      let(:result_query) do
        <<~QUERY
          child { nonComposite }
          children { nonComposite }
        QUERY
          .chomp
      end

      it '指定した2つの要素がクエリに含まれる' do
        is_expected.to eq(result_query)
      end
    end
  end

  describe '#build_arguments_query' do
    subject { described_class.build_arguments_query(name: name, type: type) }

    context 'when 引数がない' do
      let(:name) { 'me' }
      let(:type) { Types::QueryType }

      it '空文字列が返る' do
        is_expected.to eq('')
      end
    end

    context 'when 引数がある(QueryType)' do
      let(:name) { 'team' }
      let(:type) { Types::QueryType }

      it 'クエリの引数部分の文字列が返る' do
        is_expected.to eq('(id: $id)')
      end
    end

    context 'when 引数がある(MutationType)' do
      let(:name) { 'pinNotice' }
      let(:type) { Types::MutationType }

      it 'クエリの引数部分の文字列が返る' do
        is_expected.to eq('(input: $input)')
      end
    end
  end

  describe '#build_operation_arguments_query' do
    subject { described_class.build_operation_arguments_query(name: name, type: type) }

    context 'when 引数がない' do
      let(:name) { 'me' }
      let(:type) { Types::QueryType }

      it '空文字列が返る' do
        is_expected.to eq('')
      end
    end

    context 'when 引数がある(QueryType)' do
      let(:name) { 'team' }
      let(:type) { Types::QueryType }

      it 'クエリの引数部分の文字列が返る' do
        is_expected.to eq('($id: ID!)')
      end
    end

    context 'when 引数がある(MutationType)' do
      let(:name) { 'pinNotice' }
      let(:type) { Types::MutationType }

      it 'クエリの引数部分の文字列が返る' do
        is_expected.to eq('($input: PinNoticeInput!)')
      end
    end
  end

  describe '#find_mutation_class_by_name' do
    subject { described_class.find_mutation_class_by_name(name) }

    let(:name) { 'applyTeam' }

    it '文字列に対応するミューテーションを取得できる' do
      is_expected.to eq(Mutations::ApplyTeam)
    end
  end

  describe '#find_root_query_type_by_name' do
    subject { described_class.find_root_query_type_by_name(name) }

    let(:name) { 'teams' }

    it '文字列に対応するルートクエリのunwrapされたTypeを取得できる' do
      is_expected.to eq(Types::TeamType)
    end
  end

  describe '#reject_composite_fields' do
    subject { described_class.reject_composite_fields(dummy_type.fields) }

    let!(:dummy_type) do
      # テスト用にcompositeなフィールドとnon compositeなフィールを持つTypeを作る
      # compositeなフィールドとしてTeamTypeを使っているが特に意味はない
      Class.new(Types::BaseObject) do |_klass|
        field :non_composite, GraphQL::Types::String, null: false
        field :composite, Types::TeamType, null: false
      end
    end

    it 'compositeではないフィールドのみになる' do
      is_expected.to match({ 'nonComposite' => dummy_type.fields.fetch('nonComposite') })
    end
  end
end
