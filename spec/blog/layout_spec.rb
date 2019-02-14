require 'towhee/blog/layout'
require 'towhee/html/writer'
require 'towhee/blog/site'

RSpec.describe Towhee::Blog::Layout do
  let(:view) do
    described_class.new(
      title: "The Title",
      main: html.div { "Main content" },
      sidebar_modules: [
        html.h1 { "Module 1" },
        html.h1 { "Module 2" },
      ],
      site: site,
    )
  end
  let(:html) { Towhee::HTML::Writer.new }
  let(:site) { Towhee::Blog::Site.new(name: "A Site") }

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

  it "renders a header with site name" do
    expect(view.render).to match %r{<h1 class="display-1">\s*A Site\s*</h1>}
  end
end
