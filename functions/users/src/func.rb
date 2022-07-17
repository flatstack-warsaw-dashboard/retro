require "aws-sdk-dynamodb"
require "retro"

module Retro
  class UsersController < Retro::Controller
    def_action :create do |event:|
      params = parse_event_body_params(event)
      user = Retro::User.new(params["data"]["attributes"].slice("name"))

      if user.save
        { statusCode: 200, body: Retro::Serializers::UserSerializer.new(user, include: [:jwt_token]).serializable_hash.to_json }
      else
        { statusCode: 400, body: {}.to_json }
      end
    end

    def_action :show do |event:|
      authenticate!
      user = event.dig("queryStringParameters", "id") ? Retro::User.find(cid: event["queryStringParameters"]["id"]) : current_user

      serialization_options = {}
      serialization_options[:include] = [:boards] if user == current_user

      { statusCode: 200, body: Retro::Serializers::UserSerializer.new(user, serialization_options).serializable_hash.to_json }
    end
  end

  def self.route(event:, context:)
    action  = event["queryStringParameters"]["action"]

    UsersController.new(context).public_send(action, event: event)
  end
end
