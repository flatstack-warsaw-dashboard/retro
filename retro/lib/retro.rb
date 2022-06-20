# frozen_string_literal: true

require_relative "retro/version"
require_relative "retro/model"
require_relative "retro/models/user"
require "forwardable"

module Retro
  autoload :Controller, "retro/controller"

  class Error < StandardError; end
  # Your code goes here...
end
