require "jwt"

module Retro
  class JwtToken
    ALGORITHM = "HS256".freeze
    USER_IDENTFIER = "user_id".freeze

    attr_reader :user_id, :token

    def id
      @id ||= token[0..5]
    end

    def initialize(user)
      @user_id = user.identifier
      @token = self.class.encode({ "user_id" => user.identifier, "iat" => user.created_at.to_i })
    end

    def self.decode(token, secret = ENV["JWT_SECRET"])
      JWT.decode(token, secret, true, { algorithm: ALGORITHM }).first
    end

    def self.encode(payload = {}, secret = ENV["JWT_SECRET"])
      raise(ArgumentError, "Payload should contain user identifier!") unless payload[USER_IDENTFIER]

      JWT.encode payload, secret, ALGORITHM
    end
  end
end
