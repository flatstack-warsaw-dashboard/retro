module Retro
  module Serializers
    class BoardVersionSerializer < ApplicationSerializer
      DEFAULT_OPTIONS = { fields: { board_versions: %i[retro_columns version board] } }.freeze

      belongs_to :board

      set_type :board_versions

      attributes :version

      attribute :retro_columns do |object|
        object.retro_columns.to_a
      end
    end
  end
end
