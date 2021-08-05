require 'towhee/cms/repository'
require 'towhee/multi_table_inheritance/memory_adapter'

RSpec.describe Towhee::Cms::Repository do
  it "exists" do
    repository
  end

  it "round-trips entity types" do
    repo = repository
    entity_id = repo.create(EntityType.new(name: "Foo"))
    entity_type = repo.find(entity_id)
    expect(entity_type.name).to eq "Foo"
  end

  it "round-trips entity attribute types" do
    repo = repository
    type_id = repo.create(EntityType.new(name: "Foo"))
    repo.create(EntityTypeAttribute.new(
      name: "bar",
      type_id: type_id,
    ))
    attrs = repo.query("EntityTypeAttribute", "type_id", type_id)
    expect(attrs.length).to eq 1
    attr = attrs.first
    expect(attr.name).to eq "bar"
  end

  class EntityType < Struct.new(:name)
    def initialize(name:, **rest)
      self.name = name
    end
  end

  class EntityTypeAttribute < Struct.new(:name, :type_id)
    def initialize(name:, type_id:, **rest)
      self.name = name
      self.type_id = type_id
    end
  end

  def repository
    described_class.new(
      adapter: Towhee::MultiTableInheritance::MemoryAdapter.new,
    )
  end
end
