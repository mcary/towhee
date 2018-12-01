RSpec.shared_examples "StorageAdapter interface" do
  describe "StorageAdapter interface" do
    def self.must(&block)
      it "hi" do |example|
        matcher = instance_eval &block
        example.metadata[:description] = "must #{matcher.description}"
        expect(subject).to matcher
      end
    end

    must { respond_to(:insert).with(2).arguments }
    must { respond_to(:update).with(3).arguments }
    must { respond_to(:select_from).with(3).arguments }
    must { respond_to(:select_all_from).with(3).arguments }
  end
end
