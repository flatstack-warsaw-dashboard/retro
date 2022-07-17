# frozen_string_literal: true

require "forwardable"
require_relative "retro/version"
require_relative "retro/model"
Dir[File.join(__dir__, "retro/models/*.rb")].each { |f| require(f) if File.file?(f) }

module Retro
  autoload :Controller, "retro/controller"
  autoload :Serializers, "retro/serializers"

  class Error < StandardError; end
  # Your code goes here...
end
