require "fast_jsonapi"

module Retro
  require_relative "jwt_token"

  module Serializers
    class ApplicationSerializer
      extend Forwardable
      include FastJsonapi::ObjectSerializer

      DEFAULT_OPTIONS = {}.freeze

      set_id :identifier

      private

      def process_options(options)
        super(options.empty? ? self.class::DEFAULT_OPTIONS : options)
      end
    end

    Dir[File.join(__dir__, "serializers/*.rb")].each { |f| require(f) if File.file?(f) }
  end
end
