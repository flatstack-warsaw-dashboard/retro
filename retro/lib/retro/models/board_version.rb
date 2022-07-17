module Retro
  class BoardVersion < Model
    DEFAULT_COLUMNS = %w[good bad improve].freeze

    table_name DATA_TABLE

    def board
      @board ||= Retro::Board.si_query(
        key_condition_expression: "#{CID} = :board_id",
        expression_attribute_values: { ":board_id" => self.parent_identifier }
      ).first
    end

    def version
      identifier
    end

    def retro_columns
      attributes["retro_columns"]
    end

    private

    def defaults
      { "retro_columns" => DEFAULT_COLUMNS }
    end
  end
end
