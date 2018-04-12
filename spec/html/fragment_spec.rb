require 'towhee/html/fragment'

RSpec.describe Towhee::HTML::Fragment do
  let(:klass) { described_class }

  it "converts to string" do
    expect(klass.new("foo").to_s).to eq "foo"
  end

  it "adds by concatenating" do
    sum = klass.new("foo") + klass.new("bar")
    expect(sum.to_s).to eq "foobar"
  end

  it "is closed under addition" do
    sum = klass.new("foo") + klass.new("bar")
    expect(sum).to be_a klass
  end

  # This would lead to unintuitive escaping of string content:
  it "refuses to be added to a string" do
    expect {
      "foo" + klass.new("bar")
    }.to raise_error(
      TypeError,
      "no implicit conversion of Towhee::HTML::Fragment into String",
    )
  end

  it "refuses to add a string" do
    expect {
      klass.new("foo") + "bar"
    }.to raise_error(
      TypeError,
      "no implicit conversion of String into Towhee::HTML::Fragment\n" +
        "Call Writer#text for untrusted text or Writer#trust for " +
        "content that you know is clean of malicious markup.",
    )
  end
end
