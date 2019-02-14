require 'towhee/blog/layout'
require 'towhee/html/writer'

RSpec.describe Towhee::Blog::Layout do
  let(:view) do
    described_class.new(
      title: "The Title",
      main: html.div { "Main content" },
      sidebar_modules: [
        html.h1 { "Module 1" },
        html.h1 { "Module 2" },
      ],
    )
  end
  let(:html) { Towhee::HTML::Writer.new }

  it "renders HTML title" do
    expect(view.render).to match %r{<title>\s*The Title\s*</title>}
  end

  it "renders main content" do
    expect(view.render).to match %r{Main content}
  end

  it "renders sidebar modules in sections" do
    expect(view.render).to match %r{
      <section>\s*<h1>\s*Module\s1\s*</h1>\s*</section>\s*
      <section>\s*<h1>\s*Module\s2\s*</h1>\s*</section>\s*
    }x
  end
end
