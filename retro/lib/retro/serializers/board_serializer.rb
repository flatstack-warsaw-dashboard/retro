module Retro
  module Serializers
    class BoardSerializer < ApplicationSerializer
      DEFAULT_OPTIONS = { fields: { users: [:name] }, include: %i[user] }.freeze

      belongs_to :user
      has_many :notes
      has_many :board_versions

      set_type :boards

      attributes :name

      attribute :version do |object|
        object.current_version.version
      end

      attribute :retro_columns do |object|
        object.current_version.retro_columns.to_a
      end

      attribute :updated_at do |object|
        object.current_version.updated_at
      end
    end
  end
end
