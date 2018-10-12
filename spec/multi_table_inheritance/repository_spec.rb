require 'towhee/multi_table_inheritance/repository'
require 'towhee/multi_table_inheritance/active_record_adapter'

RSpec.describe Towhee::MultiTableInheritance::Repository do
  subject do
    described_class.new(
      adapter: active_record_adapter,
      schemas: {
        "Site" => Schema.new("sites", nil, [:name]),
        "Blog" => Schema.new("blogs", "Site", [:author]),
      },
    )
  end

  let(:site_id) { 1 }
  let(:adapter) { double(:adapter) }
  let :active_record_adapter do
    Towhee::MultiTableInheritance::ActiveRecordAdapter.new(adapter: adapter)
  end

  context "loading happy path" do
    before do
      query = "select * from entities where id = :id"
      allow(adapter).to receive(:select_one).with(query, id: site_id).
        and_return({"type" => "Blog"})

      query = "select * from blogs where entity_id = :entity_id"
      allow(adapter).to receive(:select_one).with(query, entity_id: site_id).
        and_return({"author" => "Someone"})

      query = "select * from sites where entity_id = :entity_id"
      allow(adapter).to receive(:select_one).with(query, entity_id: site_id).
        and_return({"name" => "My Site"})
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
      query = "select * from entities where id = :id"
      allow(adapter).to receive(:select_one).with(query, id: site_id).
        and_return({"type" => "NonExistent"})
    end

    it "notices missing type early" do
      expect {
        obj = subject.find(site_id)
      }.to raise_error(KeyError, 'key not found: "NonExistent"')
    end
  end

  context "multiple records" do
    let(:ids) { [1, 2] }

    before do
      query = "select * from entities where id in :ids"
      allow(adapter).to receive(:select_all).with(query, id: ids).
        and_return([
          {"id" => 2, "type" => "Site"},
          {"id" => 1, "type" => "Blog"},
        ])

      query = "select * from sites where entity_id in :entity_ids"
      allow(adapter).to receive(:select_all).with(query, entity_id: ids).
        and_return([
          {"entity_id" => 1, "name" => "Blog"},
          {"entity_id" => 2, "name" => "Site"},
        ])

      query = "select * from blogs where entity_id in :entity_ids"
      allow(adapter).to receive(:select_all).with(query, entity_id: ids).
        and_return([
          {"entity_id" => 1, "author" => "Someone"},
        ])
    end

    it "loads a record" do
      objs = subject.find_all(ids)
      expect(objs).not_to be_nil
      expect(objs.size).to eq 2
      objs.sort_by! { |obj| obj.name }
      expect(objs.first).to be_a Blog
      expect(objs.first.name).to eq "Blog"
      expect(objs.last).to be_a Site
      expect(objs.last.name).to eq "Site"
    end
  end

  context "creating a record" do
    before do
      query = "insert into entities (type) values (:type)"
      allow(adapter).to receive(:exec_insert).with(query, type: "Blog").
        and_return(site_id)

      query = "insert into blogs (entity_id, author) values (:entity_id, :author)"
      allow(adapter).to receive(:exec_insert).
        with(query, entity_id: site_id, author: "Someone").
        and_return(nil) # Might return something; we don't need it.

      query = "insert into sites (entity_id, name) values (:entity_id, :name)"
      allow(adapter).to receive(:exec_insert).
        with(query, entity_id: site_id, name: "My Site").
        and_return(nil) # Might return something; we don't need it.
    end

    it "stores a record" do
      id = subject.create(Blog.new("name" => "My Site", "author" => "Someone"))
      expect(id).to eq site_id
    end
  end

  context "updating a record" do
    before do
      query = "update blogs set author = :author where entity_id = :entity_id"
      allow(adapter).to receive(:exec_update).
        with(query, entity_id: site_id, author: "Someone Else").
        and_return(nil) # Might return something; we don't need it.

      query = "update sites set name = :name where entity_id = :entity_id"
      allow(adapter).to receive(:exec_update).
        with(query, entity_id: site_id, name: "My Site"). # (no change)
        and_return(nil) # Might return something; we don't need it.
    end

    it "stores a record" do
      blog = Blog.new("name" => "My Site", "author" => "Someone")
      class << blog
        attr_writer :author
        attr_accessor :entity_id
      end
      blog.author = "Someone Else"
      blog.entity_id = site_id
      subject.update(blog)
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
