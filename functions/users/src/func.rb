require "aws-sdk-dynamodb"
require "retro"

module Retro
  class UsersController < Retro::Controller
    def create(event:)
      params = parse_event_body_params(event)
      logger.info params

      user = Retro::User.new(params["data"]["attributes"].slice("name"))

      if user.save
        { statusCode: 200, body: user.to_json }
      else
        { statusCode: 400, body: {}.to_json }
      end
    end

    def show(event:)
      user = Retro::User.find(cid: event["id"])

      { statusCode: 200, body: user.to_json }
    end
  end

  def self.route(event:, context:)
    action  = event["queryStringParameters"]["action"]

    UsersController.new(context).public_send(action, event: event)
  end
end
