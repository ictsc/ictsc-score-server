# frozen_string_literal: true

module Mutations
  class DeleteTeam < BaseMutation
    field :team, Types::TeamType, null: true

    argument :number, Integer, required: true

    def resolve(number:)
      # 削除時は事前にフィルタする必要がある
      team = Team
        .readables(team: self.current_team!)
        .find_by(number: number)

      raise RecordNotExists.new(Team, number: number) if team.nil?

      Acl.permit!(mutation: self, args: { team: team })

      if team.destroy
        { team: team }
      else
        add_errors(team)
      end
    end
  end
end
