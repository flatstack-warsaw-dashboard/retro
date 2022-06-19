require "logger"
require "json"
require "forwardable"
require "aws-sdk-dynamodb"
require "retro"

module Retro
  class UsersController
    extend Forwardable

    attr_reader :context

    def_delegator :"self.class", :logger

    def initialize(context)
      @context = context
    end

    def create(event:)
      logger.info event
      user = Retro::User.new(event.slice("name"))

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

    def self.logger
      @logger ||= Logger.new($stdout)
    end
  end

  def self.route(event:, context:)
    action  = event["queryStringParameters"]["action"]

    UsersController.new(context).public_send(action, event: event)
  end
end
