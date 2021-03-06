require 'towhee/multi_table_inheritance'

module Towhee::MultiTableInheritance
  class Repository
    def initialize(storage_adapter:, schemas:)
      @adapter = storage_adapter
      @schemas = schemas
      @root_table = "entities"
    end

    def find(id)
      row = @adapter.select_from(@root_table, :id, id)
      raise KeyError, "entity not found: #{id}" unless row
      type = row.fetch("type")

      walk_lineage(type) do |type, schema|
        type_row = @adapter.select_from(schema.table_name, :entity_id, id)
        raise unless type_row
        row = row.merge(type_row)
      end

      schema_for(type).load(row)
    end

    def find_all(ids)
      rows = @adapter.select_all_from(@root_table, :id, ids)
      types_by_id = rows.map(&values_at("id", "type")).to_h
      types = types_by_id.values.uniq

      rows_by_type = {}
      types.each do |type|
        walk_lineage(type) do |type, schema|
          unless already_covered?(type, rows_by_type)
            type_rows =
              @adapter.select_all_from(schema.table_name, :entity_id, ids)
            rows_by_type[type] = index_by("entity_id", type_rows)
          end
        end
      end

      rows.map do |row|
        type = row.fetch("type")
        id = row.fetch("id")
        walk_lineage(type) do |type, schema|
          row = row.merge(rows_by_type.
                          fetch(type).
                          fetch(id))
          id = row.fetch("entity_id")
        end
        schema_for(type).load(row)
      end
    end

    def query(type, col, val)
      joins = []
      table = nil
      walk_lineage(type) do |type, schema|
        #joins.push [[schema.table_name, "entity_id"], ["entities", "id"]]
        joins.push schema.table_name
        table = schema.table_name if !table && schema.has?(col)
      end
      rows = @adapter.join("entities", joins, [table, col], "=", val)
      rows.map do |row|
        schema_for(type).load(row)
      end
    end

    def create(obj)
      type = obj.class.name
      entity_id = @adapter.insert(@root_table, type: type)
      row_defaults = { entity_id: entity_id }
      walk_lineage(type) do |type, schema|
        row = schema.dump(obj)
        @adapter.insert(schema.table_name, row_defaults.merge(row))
      end
      entity_id
    end

    def update(obj)
      type = obj.class.name
      entity_id = obj.entity_id
      walk_lineage(type) do |type, schema|
        row = schema.dump(obj)
        @adapter.update(schema.table_name, entity_id, row)
      end
    end

    def delete(id)
      row = @adapter.select_from(@root_table, :id, id)
      type = row.fetch("type")

      walk_lineage(type) do |type, schema|
        type_row = @adapter.delete_from(schema.table_name, :entity_id, id)
      end

      @adapter.delete_from(@root_table, :id, id)
    end

    private

    def walk_lineage(type)
      begin
        schema = schema_for(type)
        yield type, schema
      end while type = schema.parent_type # Walk up the ancestor chain
    end

    def already_covered?(type, rows_by_type)
      rows_by_type.key?(type)
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
