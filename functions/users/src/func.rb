require "logger"
require "json"
require "forwardable"

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

      { statusCode: 200, body: { "action": "create" }.to_json }
    end

    def show(event:)

      { statusCode: 200 }
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
