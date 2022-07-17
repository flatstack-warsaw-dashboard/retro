require "logger"
require "json"
require_relative "jwt_token"

module Retro
  class Controller
    extend Forwardable

    class NotAuthenticatedError < RuntimeError; end

    AUTH_TYPE = "Bearer".freeze

    attr_reader :context, :headers

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

    def current_user
      return unless authentication_token

      @current_user ||= Retro::User.find(cid: Retro::JwtToken.decode(authentication_token)["user_id"])
    end

    protected

    def authenticate!
      raise(NotAuthenticatedError) unless current_user
    end

    private

    def parse_event_headers(headers)
      @headers ||= headers
    end

    def authentication_token
      @authentication_token = parse_authentication_token_header(
        headers["authorization"]
      )
    end

    def parse_authentication_token_header(header)
      return if !header || !header.index(AUTH_TYPE)

      header.split(AUTH_TYPE).last.strip
    end

    class << self
      def def_action(action, &block)
        define_method(action) do |event:|
          parse_event_headers(event["headers"])
          instance_exec(event: event, &block)
        end
      end
    end
  end
end
