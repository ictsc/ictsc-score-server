# frozen_string_literal: true

module SessionHelpers
  mattr_accessor :staff_id
  mattr_accessor :audience_id
  mattr_accessor :player1_id
  mattr_accessor :player2_id
  mattr_accessor :team99_id

  class << self
    # チームを作成する
    def set_teams!
      self.staff_id    = FactoryBot.create(:team, :staff,    name: Team.special_team_name_staff).id
      self.audience_id = FactoryBot.create(:team, :audience, name: 'audience').id
      self.player1_id  = FactoryBot.create(:team, :player,   name: 'player1', beginner: false).id
      self.player2_id  = FactoryBot.create(:team, :player,   name: 'player2', beginner: false).id
      self.team99_id   = FactoryBot.create(:team, :player,   name: Team.special_team_name_team99, beginner: false).id
    end

    # 事前に作成されたチームを参照するletを定義する
    def define_let
      context_name = "#{self} Define teams let"

      RSpec.shared_context context_name do
        # passwordは取得できないがFactoryBotで作成しているならnameと同じ
        let(:staff)    { Team.find(SessionHelpers.staff_id) }
        let(:audience) { Team.find(SessionHelpers.audience_id) }
        let(:player1)  { Team.find(SessionHelpers.player1_id) }
        let(:player2)  { Team.find(SessionHelpers.player2_id) }
        let(:team99)   { Team.find(SessionHelpers.team99_id) }
      end

      context_name
    end
  end

  ## 以降はrspecにextendされてcontextと同じ文脈で使えるようになる

  def context_as(team_name, &block)
    context "when #{team_name}でログイン" do # rubocop:disable RSpec/EmptyExampleGroup
      let(:current_team) { public_send(team_name) }

      # このコンテキスト内ではログイン済みとしてクエリを処理する
      # ログイン周りの仕様検証はsessions_spec.rbとgraphql_spec.rbで行う
      before(:each) do
        allow_any_instance_of(ApplicationController).to receive(:current_team).and_return(current_team) # rubocop:disable RSpec/AnyInstance
      end

      class_eval(&block)
    end
  end

  def context_as_staff(&block)
    context_as('staff', &block)
  end

  def context_as_audience(&block)
    context_as('audience', &block)
  end

  def context_as_player1(&block)
    context_as('player1', &block)
  end

  def context_as_player2(&block)
    context_as('player2', &block)
  end

  def context_as_team99(&block)
    context_as('team99', &block)
  end
end
