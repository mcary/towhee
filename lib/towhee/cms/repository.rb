require 'towhee'
require 'towhee/multi_table_inheritance/repository'

module Towhee::Cms
  class Repository
    def initialize(adapter:)
      @repo = Towhee::MultiTableInheritance::Repository.new(
        storage_adapter: adapter,
        schemas: schemas,
      )
    end

    def find(entity_id)
      @repo.find(entity_id)
    end

    def create(obj)
      @repo.create(obj)
    end

    def query(type, col, val)
      @repo.query(type, col, val)
    end

    private

    def schemas
      {
        "EntityType" => Schema.new("entity_types", nil, [:name]),
        "EntityTypeAttribute" => 
          Schema.new("entity_type_attributes", nil, [:name, :type_id]),
      }
    end

    # Copied from mti::repo
    # - extracted class_name method to add support for multi-word names
    # - removed comment and symbolized keys
    class Schema < Struct.new(:table_name, :parent_type, :attributes)
      def load(row)
        Object.const_get(class_name).new(symbolize_keys(row))
      end

      def dump(obj)
        row = attributes.each_with_object({}) do |attr, row|
          row[attr] = obj.public_send(attr)
        end
      end

      def has?(attr)
        attributes.include? attr.to_sym
      end

      private

      # row["type"] is another candidate for this info, but it is not
      # correct in the case of #query.
      def class_name
        singular = table_name.sub(/s$/, "")
        camel = singular.split("_").each do |word|
          word[0] = word[0].upcase
        end.join
        camel
      end

      def symbolize_keys(hash)
        hash.each_pair.each_with_object({}) do |pair, h|
          key, val = pair
          h[key.to_sym] = val
        end
      end
    end
  end
end
