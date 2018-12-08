require 'towhee/multi_table_inheritance/active_record_adapter'
require_relative 'storage_adapter_interface'

RSpec.describe Towhee::MultiTableInheritance::ActiveRecordAdapter do
  include_examples "StorageAdapter interface"
  let(:site_id) { 1 }
  let(:connection_adapter) { double(:connection_adapter) }
  subject do
    Towhee::MultiTableInheritance::ActiveRecordAdapter.new(
      connection_adapter: connection_adapter,
    )
  end

  describe "#select_from" do
    before do
      query = "select * from entities where id = :id"
      allow(connection_adapter).to receive(:select_one).
        with(query, id: site_id).
        and_return({"type" => "Blog"})
    end

    it "loads a row" do
      row = subject.select_from("entities", :id, site_id)
      expect(row).to eq("type" => "Blog")
    end
  end

  describe "#select_all_from" do
    let(:ids) { [1, 2] }

    before do
      query = "select * from entities where id in :ids"
      allow(connection_adapter).to receive(:select_all).
        with(query, id: ids).
        and_return([
          {"id" => 2, "type" => "Site"},
          {"id" => 1, "type" => "Blog"},
        ])
    end

    it "loads rows" do
      rows = subject.select_all_from("entities", :id, ids)
      expect(rows.size).to eq 2
      expect(rows.first).to eq("id" => 2, "type" => "Site")
      expect(rows.last).to eq("id" => 1, "type" => "Blog")
    end
  end

  describe "#insert" do
    before do
      query = "insert into entities (type) values (:type)"
      allow(connection_adapter).to receive(:exec_insert).
        with(query, type: "Blog").
        and_return(site_id)
    end

    it "stores a record" do
      id = subject.insert("entities", type: "Blog")
      expect(id).to eq site_id
    end
  end

  describe "#update" do
    before do
      query = "update blogs set author = :author where entity_id = :entity_id"
      expect(connection_adapter).to receive(:exec_update).
        with(query, entity_id: site_id, author: "Someone Else").
        and_return(nil) # Might return something; we don't need it.
    end

    it "updates a row" do
      subject.update("blogs", site_id, author: "Someone Else")
    end
  end

  describe "#delete_from" do
    before do
      query = "delete from entities where id = :id"
      expect(connection_adapter).to receive(:exec_delete).
        with(query, id: site_id)
    end

    it "loads a row" do
      subject.delete_from("entities", :id, site_id)
    end
  end
end
