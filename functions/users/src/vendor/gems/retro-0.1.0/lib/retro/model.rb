module Retro
  class Model
    attr_reader :attributes

    def initialize(attributes = {})
      @attributes = attributes
    end

    class << self
      def dynamo_table_name
        @table_name
      end

      def all
        db.scan(table_name: dynamo_table_name)
      end

      def db
        @db ||= Aws::DynamoDB::Client.new
      end

      def table_name(name)
        @table_name = "retro-#{name}"
      end
    end
  end
end
