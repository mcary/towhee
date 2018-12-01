require 'towhee/multi_table_inheritance/memory_adapter'
require_relative 'storage_adapter_interface'

RSpec.describe Towhee::MultiTableInheritance::MemoryAdapter do
  include_examples "StorageAdapter interface"

  it "round-trips a row" do
    id = subject.insert("foos", "attr1" => "val1")
    row = subject.select_from("foos", "attr1", "val1")
    expect(row).to include("attr1" => "val1")
    expect(id).to eq 1
    expect(row).to include("id" => 1)
  end

  it "clones data" do
    val = "val1"
    id = subject.insert("foos", "attr1" => val)
    row = subject.select_from("foos", "attr1", "val1")
    expect(row["attr1"]).to eq val
    expect(row["attr1"]).not_to equal val # Compare object idenity
  end

  it "returns a symbol row by symbols" do
    id = subject.insert("foos", attr1: "val1")
    row = subject.select_from("foos", :attr1, "val1")
    expect(row).to include("attr1" => "val1")
  end

  it "returns a string row by symbols" do
    id = subject.insert("foos", "attr1" => "val1")
    row = subject.select_from("foos", :attr1, "val1")
    expect(row).to include("attr1" => "val1")
  end

  describe "#insert" do
    it "returns auto-incremented IDs" do
      id1 = subject.insert("foos", "attr1" => "val1")
      id2 = subject.insert("foos", "attr1" => "val2")
      row = subject.select_from("foos", "attr1", "val1")
      expect(id1).to eq 1
      expect(id2).to eq 2
      expect(row).to include("id" => 1)
    end
  end

  describe "#select_from" do
    it "returns nil if none match" do
      subject.insert("foos", "attr1" => "val1")
      row = subject.select_from("foos", "attr1", "val2")
      expect(row).to eq nil
    end

    it "clones" do
      id = subject.insert("foos", "attr1" => "val1")
      row = subject.select_from("foos", "id", id)
      row["attr1"] = "val2" # mutate
      row = subject.select_from("foos", "id", id)
      expect(row["attr1"]).to eq "val1"
    end
  end

  describe "#select_all_from" do
    it "finds all matches" do
      subject.insert("foos", "attr1" => "val1")
      subject.insert("foos", "attr1" => "val1")
      rows = subject.select_all_from("foos", "attr1", ["val1"])
      expect(rows.size).to eq 2
      rows.sort_by! {|row| row["id"] }
      expect(rows.first).to include("attr1" => "val1")
      expect(rows.last).to include("attr1" => "val1")
      expect(rows.first).to include("id" => 1)
      expect(rows.last).to include("id" => 2)
    end

    it "finds only matches" do
      subject.insert("foos", "attr1" => "val1")
      subject.insert("foos", "attr1" => "val2")
      rows = subject.select_all_from("foos", "attr1", ["val1"])
      expect(rows.size).to eq 1
      expect(rows.first).to include("attr1" => "val1")
    end

    it "finds none if no matches" do
      subject.insert("foos", "attr1" => "val1")
      rows = subject.select_all_from("foos", "attr1", ["val2"])
      expect(rows.size).to eq 0
    end

    it "clones" do
      id = subject.insert("foos", "attr1" => "val1")
      rows = subject.select_all_from("foos", "id", [id])
      rows.first["attr1"] = "val2" # mutate
      rows = subject.select_all_from("foos", "id", [id])
      expect(rows.first["attr1"]).to eq "val1"
    end
  end

  describe "#update" do
    it "mutates a row" do
      entity_id = "3"
      id = subject.insert("foos", "entity_id" => entity_id, "attr1" => "val1")
      subject.update("foos", entity_id, "attr1" => "val2")
      row = subject.select_from("foos", "id", id)
      expect(row).to include("attr1" => "val2")
    end

    it "mutates only matches" do
      subject.insert("foos", "entity_id" => "3", "a1" => "v1")
      subject.insert("foos", "entity_id" => "4", "a1" => "v1")
      subject.update("foos", "3", "a1" => "v2")
      expect(subject.select_from("foos", "entity_id", "3")["a1"]).to eq "v2"
      expect(subject.select_from("foos", "entity_id", "4")["a1"]).to eq "v1"
    end
  end

  describe "#insert" do
    it "clones" do
      row = { "attr1" => "val1" }
      id = subject.insert("foos", row)
      row["attr1"] = "val2" # mutate
      row = subject.select_from("foos", "id", id)
      expect(row["attr1"]).to eq "val1"
    end
  end
end
