module Retro
  class User < Model
    table_name DATA_TABLE

    def boards
      @boards ||= db.query(
        table_name: Retro::User.dynamo_table_name,
        key_condition_expression: "#{PID} = :user_id",
        expression_attribute_values: { ":user_id" => identifier }
      ).items.map { |ba| Retro::Board.new(ba) }
    rescue Aws::DynamoDB::Errors::ResourceNotFoundException
      []
    end

    def name
      attributes["name"]
    end
  end
end
