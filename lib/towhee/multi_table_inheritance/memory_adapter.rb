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
      rows = @data[table].select do |row|
        vals.include? row[key]
      end
      clone rows
    end

    def select_from(table, key, val)
      select_all_from(table, key, [val]).first
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
      internal_row = @data[table].find do |row|
        entity_id == row["entity_id"]
      end
      internal_row.merge!(clone(row))
      nil
    end

    def delete_from(table, key, val)
      key = sanitize_key(key)
      rows = @data[table].reject! do |row|
        val == row[key]
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

