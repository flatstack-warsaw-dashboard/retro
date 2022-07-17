module Retro
  module Serializers
    class BoardVersionSerializer < ApplicationSerializer
      DEFAULT_OPTIONS = { fields: { board_versions: %i[retro_columns version board] } }.freeze

      belongs_to :board, id_method_name: :parent_identifier

      set_type :board_versions

      attribute :version do |object|
        o.identifier
      end

      attribute :retro_columns do |object|
        object.retro_columns
      end
    end
  end
end
