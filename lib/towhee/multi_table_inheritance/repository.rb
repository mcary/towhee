require 'towhee/multi_table_inheritance'

module Towhee::MultiTableInheritance
  class Repository
    def initialize(adapter:, schemas:)
      @adapter = adapter
      @schemas = schemas
      @root_table = "entities"
    end

    def find(id)
      row = select_from(@root_table, :id, id)
      type = row.fetch("type")

      walk_lineage(type) do |type, schema|
        type_row = select_from(schema.table_name, :entity_id, id)
        row = row.merge(type_row)
      end

      schema_for(type).load(row)
    end

    def find_all(ids)
      rows = select_all_from(@root_table, :id, ids)
      types_by_id = rows.map(&values_at("id", "type")).to_h
      types = types_by_id.values.uniq

      rows_by_type = {}
      types.each do |type|
        walk_lineage(type) do |type, schema|
          unless already_covered?(type, rows_by_type)
            type_rows = select_all_from(schema.table_name, :entity_id, ids)
            rows_by_type[type] = index_by("entity_id", type_rows)
          end
        end
      end

      rows.map do |row|
        type = row.fetch("type")
        walk_lineage(type) do |type, schema|
          row = row.merge(rows_by_type.
                          fetch(type).
                          fetch(row.fetch("id")))
        end
        schema_for(type).load(row)
      end
    end

    private

    def select_all_from(table, key, vals)
      @adapter.select_all(
        "select * from #{table} where #{key} in :#{key}s",
        key => vals,
      )
    end

    def walk_lineage(type)
      begin
        schema = schema_for(type)
        yield type, schema
      end while type = schema.parent_type # Walk up the ancestor chain
    end

    def already_covered?(type, rows_by_type)
      rows_by_type.key?(type)
    end

    def select_from(table, key, val)
      @adapter.select_one(
        "select * from #{table} where #{key} = :#{key}",
        key => val,
      )
    end

    def schema_for(type)
      @schemas.fetch(type)
    end

    def values_at(*keys)
      # Use inject+fetch instead of Hash#values_at to raise on missing key.
      proc { |row| keys.map { |key| row.fetch(key) } }
    end

    def index_by(key, rows)
      rows.map { |row| [row.fetch(key), row] }.to_h
    end
  end
end
