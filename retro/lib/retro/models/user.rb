module Retro
  class User < Model
    table_name DATA_TABLE

    def boards
      @boards ||= Retro::Board.query(
        key_condition_expression: "#{PID} = :user_id",
        filter_expression: "#type = :model_type",
        expression_attribute_names: { "#type" => "type" },
        expression_attribute_values: { ":user_id" => identifier, ":model_type" => Retro::Board.model_type }
      )
    end

    def name
      attributes["name"]
    end
  end
end
