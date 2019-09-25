# frozen_string_literal: true

module Mutations
  class UpdateConfig < BaseMutation
    field :config, Types::ConfigType, null: true

    argument :key,   ID,     required: false
    argument :value, String, required: false

    def resolve(key:, value:)
      Acl.permit!(mutation: self, args: {})

      config = Config.find_by(key: key)
      raise RecordNotExists.new(Config, key: key) if config.nil?

      if config.update(value: value)
        { config: config.readable(team: self.current_team!) }
      else
        add_errors(config)
      end
    end
  end
end
