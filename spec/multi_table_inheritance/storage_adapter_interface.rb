RSpec.shared_examples "StorageAdapter interface" do
  describe "StorageAdapter interface" do
    def self.must(&block)
      it "[dynamic]" do |example|
        matcher = instance_eval &block
        desc = "must #{matcher.description}"
        example.metadata[:description] = desc
        example.metadata[:full_description].sub!("[dynamic]", desc)
        expect(subject).to matcher
      end
    end

    must { respond_to(:insert).with(2).arguments }
    must { respond_to(:update).with(3).arguments }
    must { respond_to(:select_from).with(3).arguments }
    must { respond_to(:select_all_from).with(3).arguments }
    must { respond_to(:delete_from).with(3).arguments }
    must { respond_to(:join).with(5).arguments }
  end
end
