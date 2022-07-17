module Retro
  module Serializers
    class TokenSerializer < ApplicationSerializer
      set_type :jwt
      set_id :id

      attributes :token
    end

    class UserSerializer < ApplicationSerializer
      has_many :boards do |o|
        o.boards
      end

      has_one :jwt_token,
              serializer: TokenSerializer,
              if: ->(user, _params) { !user.new? } do |o, _params|
        JwtToken.new(o)
      end

      set_type :users

      attributes :name

      DEFAULT_OPTIONS = { fields: { users: %i[name] } }.freeze
    end
  end
end
