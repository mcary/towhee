require 'towhee/multi_table_inheritance'

module Towhee::MultiTableInheritance
  class MemoryAdapter
    def initialize
      # table => array of row hashes
      @data = Hash.new {|hsh, key| hsh[key] = [] }
      @last_id = 0
    end

    def select_all_from(table, key, vals)
      key = sanitize_key(key)
      rows = @data.fetch(table).select do |row|
        vals.include? row.fetch(key)
      end
      clone rows
    end

    def select_from(table, key, val)
      select_all_from(table, key, [val]).first
    end

    def join(table, joins, filter_col, filter_op, filter_val)
      filter_table, filter_column = filter_col
      table, filter_table, filter_column =
        [table, filter_table, filter_column].map(&method(:sanitize_key))
      joins = joins.map(&method(:sanitize_key))

      op_methods = { "=" => :== }
      op_method = op_methods.fetch(filter_op)
      rows = @data.fetch(filter_table).select do |row|
        row.fetch(filter_column).public_send(op_method, filter_val)
      end
      id_col = table == filter_table ? "id" : "entity_id"
      ids = rows.map { |row| row.fetch(id_col) }

      rows = ids.map do |id|
        [table, *joins].reverse.inject(Hash.new) do |merged_row, t|
          id_col = table == t ? "id" : "entity_id"
          row = @data.fetch(t).find do |row|
            row.fetch(id_col) == id
          end
          merged_row.merge(row)
        end
      end

      clone rows
    end

    def insert(table, row)
      row = normalize_row(row)
      internal_row = clone(row)
      id = next_id
      internal_row["id"] = id
      @data[table].push internal_row
      id
    end

    def update(table, entity_id, row)
      row = normalize_row(row)
      internal_row = @data.fetch(table).find do |row|
        entity_id == row.fetch("entity_id")
      end
      internal_row.merge!(clone(row))
      nil
    end

    def delete_from(table, key, val)
      key = sanitize_key(key)
      rows = @data.fetch(table).reject! do |row|
        val == row.fetch(key)
      end
      nil
    end

    private

    def next_id
      @last_id += 1
    end

    def normalize_row(row)
      Hash[row.map {|k,v| [sanitize_key(k), sanitize_val(v)] }]
    end

    def clone(data)
      Marshal.load(Marshal.dump(data))
    end

    def sanitize_val(val)
      raise unless val.is_a?(String) || val.is_a?(Numeric)
      val
    end

    def sanitize_key(key)
      raise unless key.is_a?(String) || key.is_a?(Symbol)
      key.to_s
    end
  end
end

