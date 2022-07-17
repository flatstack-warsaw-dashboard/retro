module Retro
  class Model
    extend Forwardable

    def_delegators :"self.class", :api_params, :db

    RETURN_OPTIONS = {
      none: "NONE", all_old: "ALL_OLD", updated_old: "UPDATED_OLD", all_new: "ALL_NEW", updated_new: "UPDATED_NEW"
    }.freeze
    ATTR_TRANSFORMATIONS = { add: "ADD", put: "PUT", delete: "DELETE" }.freeze
    DATA_TABLE = "data".freeze

    ROOT_PID = "-".freeze
    PID = "pid".freeze
    CID = "cid".freeze
    TYPE = "type".freeze

    attr_reader :attributes
    attr_accessor :parent

    def initialize(attributes = defaults)
      @attributes = attributes.merge(defaults)
    end

    def identifier
      attributes[CID]
    end

    def parent_identifier
      parent&.identifier || attributes[PID]
    end

    def new?
      identifier.nil?
    end

    def destroy
      db.delete_item(api_params.merge(key: identifier_params, return_values: RETURN_OPTIONS[:all_old])).attributes
    end

    def put
      push_attributes = item_attributes
      push_attributes["updated_at"] = Time.now.to_i
      db.put_item(api_params.merge(item: push_attributes, return_values: RETURN_OPTIONS[:all_old]))
      @attributes = push_attributes
      after_save
      attributes
    end
    alias :save :put

    def update(method: ATTR_TRANSFORMATIONS[:put], **updates)
      attribute_updates = prepare_attributes(updates).transform_values do |value|
        { value: value, action: method }
      end

      response = db.update_item(api_params.merge(
        key: identifier_params,
        attribute_updates: attribute_updates,
        return_values: RETURN_OPTIONS[:all_new])
      )
      @attributes = response.attributes
      after_save
      attributes
    end

    def identifier_params
      { CID => identifier, PID => parent_identifier }.tap do |attrs|
        attrs[PID] ||= ROOT_PID
        attrs[CID] ||= generate_id
      end
    end

    def to_json
      attributes.to_json
    end

    def assign(attrs)
      attributes.merge!(prepare_attributes(attrs))
      self
    end

    def created_at
      Time.at(attributes["created_at"]) if attributes["created_at"]
    end

    def updated_at
      Time.at(attributes["updated_at"]) if attributes["updated_at"]
    end

    def defaults
      {}
    end

    private

    def after_save; end

    def prepare_attributes(attrs)
      attrs.transform_keys!(&:to_sym)
      attrs.delete(CID)
      attrs.delete(PID)
      attrs.delete(TYPE)
      attrs
    end

    def generate_id
      SecureRandom.uuid
    end

    def item_attributes
      attributes.dup.tap do |attrs|
        attrs.merge! identifier_params
        attrs[TYPE] ||= self.class.model_type
        attrs["created_at"] ||= Time.now.to_i
      end
    end

    class << self
      def model_type
        name.split("::").last.downcase
      end

      def api_params
        { table_name: dynamo_table_name }
      end

      def dynamo_table_name
        @table_name
      end

      def find(cid:, pid: ROOT_PID)
        db.get_item(**api_params, key: { pid: pid, cid: cid }).item.yield_self do |item|
          new(item) if item && item["type"] == model_type
        end
      end

      def scan
        db.scan(
          **api_params,
          scan_filter: { "type" => { attribute_value_list: [model_type], comparison_operator: "EQ" } }
        ).items.map { |attrs| new(attrs) }
      end

      def query(**params)
        db.query(table_name: dynamo_table_name, **params).items.map do |m|
          new(m) if m && (!m.key?("type") || m["type"] == model_type)
        end.compact
      rescue Aws::DynamoDB::Errors::ResourceNotFoundException
        []
      end

      def si_query(**params)
        query(index_name: "cid_si", **params).map { |keys| find(pid: keys.parent_identifier, cid: keys.identifier) }
      end

      def db
        @db ||= ::Aws::DynamoDB::Client.new
      end

      def table_name(name)
        @table_name = "retro-#{name}"
      end
    end
  end
end
