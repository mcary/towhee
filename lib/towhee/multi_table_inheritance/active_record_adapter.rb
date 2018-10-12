require 'towhee/multi_table_inheritance'

module Towhee::MultiTableInheritance
  class ActiveRecordAdapter
    def initialize(connection_adapter:)
      @adapter = connection_adapter
    end

    def select_all_from(table, key, vals)
      @adapter.select_all(
        "select * from #{table} where #{key} in :#{key}s",
        key => vals,
      )
    end

    def select_from(table, key, val)
      @adapter.select_one(
        "select * from #{table} where #{key} = :#{key}",
        key => val,
      )
    end

    def insert(table, row)
      cols = row.keys.join(", ")
      vals = row.keys.map {|k| ":#{k}" }.join(", ")
      @adapter.exec_insert(
        "insert into #{table} (#{cols}) values (#{vals})",
        row,
      )
    end

    def update(table, entity_id, row)
      assigns = row.keys.map {|k| "#{k} = :#{k}" }.join(", ")
      @adapter.exec_update(
        "update #{table} set #{assigns} where entity_id = :entity_id",
        row.merge(entity_id: entity_id),
      )
    end
  end
end
