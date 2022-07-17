module Retro
  class Board < Model
    table_name DATA_TABLE

    def user
      @user ||= if attributes[CID]
        Retro::User.find(attributes[CID])
      end
    end
  end
end
