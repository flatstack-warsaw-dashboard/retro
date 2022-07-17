module Retro
  class Board < Model
    table_name DATA_TABLE

    def name
      attributes["name"]
    end

    def user
      @user ||= if parent_identifier
        Retro::User.find(cid: parent_identifier)
      end
    end

    def version
      attributes["version"]
    end

    def current_version
      @current_version ||= Retro::BoardVersion.find(pid: identifier, cid: version) ||
        Retro::BoardVersion.new(PID => identifier, CID => version)
    end

    def versions
      Retro::BoardVersion.query(
        key_condition_expression: "#{PID} = :board_id",
        filter_expression: "#type = :model_type",
        expression_attribute_names: { "#type" => "type" },
        expression_attribute_values: { ":board_id" => identifier, ":model_type" => Retro::BoardVersion.model_type }
      )
    end

    private

    def defaults
      { "version" => "0" }
    end

    def after_save
      current_version.save
    end
  end
end
