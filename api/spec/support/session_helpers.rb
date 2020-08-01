# frozen_string_literal: true

module SessionHelpers
  mattr_accessor :staff
  mattr_accessor :audience
  mattr_accessor :player
  mattr_accessor :other_player

  # context_as_* をdescribe,contextレベルで使えるようにする
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def context_as(team_name, &block)
      context "when logged-in as #{team_name}" do # rubocop:disable RSpec/EmptyExampleGroup
        let(:current_team) { SessionHelpers.public_send(team_name) }

        # このコンテキスト内ではログイン済みとしてクエリを処理する
        # ログイン周りの仕様検証はsessions_spec.rbとgraphql_spec.rbで行う
        before(:each) do
          # rubocop:disable RSpec/AnyInstance
          allow_any_instance_of(ApplicationController).to receive(:current_team).and_return(current_team)
          allow_any_instance_of(ApplicationController).to receive(:logged_in?).and_return(true)
          # rubocop:enable RSpec/AnyInstance
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

    def context_as_player(&block)
      context_as('player', &block)
    end

    def context_as_other_player(&block)
      context_as('other_player', &block)
    end
  end

  class << self
    def set_teams!
      self.staff = FactoryBot.create(:team, :staff, name: Team.special_team_name_staff)
      self.audience = FactoryBot.create(:team, :audience)
      self.player = FactoryBot.create(:team, :player)
      self.other_player = FactoryBot.create(:team, :player)
    end
  end
end
