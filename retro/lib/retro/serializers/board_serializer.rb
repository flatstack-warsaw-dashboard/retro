module Retro
  module Serializers
    class BoardSerializer < ApplicationSerializer
      DEFAULT_OPTIONS = { fields: { users: [:name] }, include: %i[user] }.freeze

      belongs_to :user, id_method_name: :parent_identifier
      #has_many :notes
      has_many :board_versions, id_method_name: :identifier do |object|
        object.versions
      end

      set_type :boards

      attributes :name

      attribute :version do |object|
        object.current_version.identifier
      end

      attribute :retro_columns do |object|
        object.current_version.retro_columns
      end

      attribute :updated_at do |object|
        object.current_version.updated_at
      end
    end
  end
end
