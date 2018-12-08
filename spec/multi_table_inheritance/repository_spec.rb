require 'towhee/multi_table_inheritance/repository'
require 'towhee/multi_table_inheritance/memory_adapter'

RSpec.describe Towhee::MultiTableInheritance::Repository do
  subject do
    described_class.new(
      storage_adapter: adapter,
      schemas: {
        "Site" => Schema.new("sites", nil, [:name]),
        "Blog" => Schema.new("blogs", "Site", [:author]),
      },
    )
  end

  let(:site_id) { 1 }
  let(:adapter) { Towhee::MultiTableInheritance::MemoryAdapter.new }

  context "existing record" do
    before do
      id = adapter.insert("entities", type: "Blog")
      adapter.insert("blogs", author: "Someone", entity_id: id)
      adapter.insert("sites", name: "My Site", entity_id: id)
    end

    it "loads a record" do
      obj = subject.find(site_id)
      expect(obj).not_to be_nil
      expect(obj).to be_a Blog
      expect(obj.name).to eq "My Site"
      expect(obj.author).to eq "Someone"
    end
  end

  context "invalid type" do
    before do
      adapter.insert("entities", type: "NonExistent")
    end

    it "notices missing type early" do
      expect {
        obj = subject.find(site_id)
      }.to raise_error(KeyError, 'key not found: "NonExistent"')
    end
  end

  context "multiple records" do
    before do
      @ids = []

      id = adapter.insert("entities", type: "Site")
      adapter.insert("sites", name: "Site", entity_id: id)
      @ids.push id

      id = adapter.insert("entities", type: "Blog")
      adapter.insert("sites", name: "Blog", entity_id: id)
      adapter.insert("blogs", author: "Someone", entity_id: id)
      @ids.push id
    end

    it "loads a record" do
      objs = subject.find_all(@ids)
      expect(objs).not_to be_nil
      expect(objs.size).to eq 2
      objs.sort_by! { |obj| obj.name }
      expect(objs.first).to be_a Blog
      expect(objs.first.name).to eq "Blog"
      expect(objs.last).to be_a Site
      expect(objs.last.name).to eq "Site"
    end
  end

  context "empty repository" do
    it "creates a record" do
      id = subject.create(Blog.new("name" => "My Site", "author" => "Someone"))

      row = adapter.select_from("entities", :id, id)
      expect(row).to eq("id" => id, "type" => "Blog")
      row = adapter.select_from("blogs", :entity_id, id)
      expect(row).to include("entity_id" => id, "author" => "Someone")
      row = adapter.select_from("sites", :entity_id, id)
      expect(row).to include("entity_id" => id, "name" => "My Site")
    end

    it "raises on non-existent ID" do
      non_existent = 42
      expect {
        subject.find(non_existent)
      }.to raise_error(KeyError, "entity not found: #{non_existent}")
    end
  end

  context "existing rows" do
    before do
      id = adapter.insert("entities", type: "Blog")
      adapter.insert("sites", name: "Blog", entity_id: id)
      adapter.insert("blogs", author: "Someone", entity_id: id)
      @id = id

      id = adapter.insert("entities", type: "Blog")
      adapter.insert("sites", name: "Other Blog", entity_id: id)
      adapter.insert("blogs", author: "Other Someone", entity_id: id)
      @other_id = id
    end

    it "updates the record" do
      new_author = "Someone Else"
      blog = Blog.new("name" => "My Site", "author" => new_author)
      class << blog
        # Updatable models need this additional attribute
        attr_accessor :entity_id
      end
      blog.entity_id = @id
      subject.update(blog)

      row = adapter.select_from("blogs", :entity_id, @id)
      expect(row).to include("author" => new_author)
      row = adapter.select_from("blogs", :entity_id, @other_id)
      expect(row).to include("author" => "Other Someone") # unchanged
    end

    it "deletes a record" do
      expect {
        subject.delete(@id)
      }.to change {
        record_exists(@id)
      }.from(true).to(false)
      expect(record_exists(@other_id)).to eq true
    end

    def record_exists(id)
      subject.find_all([id]).any?
    end
  end


  class Schema < Struct.new(:table_name, :parent_type, :attributes)
    def load(row)
      # If we passed a symbol-keyed Hash, the receiver could
      # use kwargs to destructure it.  However, typically the receiver
      # will not know about _all_ the keys and will forward some to
      # its parent class.  So maybe the flexibility of String keys
      # is important.
      Object.const_get(row["type"]).new(row)
    end

    def dump(obj)
      row = attributes.each_with_object({}) do |attr, row|
        row[attr] = obj.public_send(attr)
      end
    end
  end

  class Site
    def initialize(attrs)
      @name = attrs["name"]
    end
    attr_reader :name
  end

  # Doesn't necessarily have to extend Site.
  class Blog
    def initialize(attrs)
      @name = attrs["name"]
      @author = attrs["author"]
    end
    attr_reader :name, :author
  end
end
