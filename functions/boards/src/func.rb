require "aws-sdk-dynamodb"
require "retro"

module Retro
  class BoardsController < Retro::Controller
    def_action :create do |event:|
      authenticate!

      params = parse_event_body_params(event)
      board = Retro::Board.new(params["data"]["attributes"].slice("name"))
      board.parent = current_user
      if board.save
        { statusCode: 201, body: Retro::Serializers::BoardSerializer.new(board).serializable_hash.to_json }
      end
    end

    def_action :show do |event:|
      authenticate!

      board = Retro::Board.si_query(
        key_condition_expression: "#{CID} = :board_id",
        expression_attribute_values: { ":board_id" => "fillme" }
      ).first

      if board
        { statusCode: 200, body: Retro::Serilaizers::BoardSerializer.new(board).serializable_hash.to_json }
      end
    end
  end

  def self.route(event:, context:)
    action  = event["queryStringParameters"]["action"]

    BoardsController.new(context).public_send(action, event: event)
  end
end
