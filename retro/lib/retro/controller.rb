require "logger"
require "json"

module Retro
  class Controller
    extend Forwardable

    attr_reader :context

    def_delegator :"self.class", :logger

    def initialize(context)
      @context = context
    end

    def self.logger
      @logger ||= Logger.new($stdout)
    end

    def parse_event_body_params(event)
      JSON.parse(event["isBase64Encoded"] ? Base64.decode64(event["body"]) : event["body"])
    end
  end
end
