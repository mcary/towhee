require 'towhee/blog/repository'
require 'towhee/blog/site'

RSpec.describe Towhee::Blog::Repository do
  context "no sites" do
    it "returns none" do
      repo = repository(sites: [])
      expect(repo.all_sites).to eq []
    end
  end

  context "one site" do
    it "returns one" do
      repo = repository(sites: [Towhee::Blog::Site.new(name: "TestSite")])
      expect(repo.all_sites.size).to eq 1
      expect(repo.all_sites.first.name).to eq "TestSite"
    end
  end

  def repository(*args)
    described_class.new(*args)
  end
end
