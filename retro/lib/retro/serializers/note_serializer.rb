module Retro
  module Serializers
    class NoteSerializer < ApplicationSerializer
      belongs_to :user
      belongs_to :board

      set_type :notes

      attributes :retro_column, :text

      DEFAULT_OPTIONS = { fields: { users: %i[name] }, include: [:user] }.freeze
    end
  end
end
