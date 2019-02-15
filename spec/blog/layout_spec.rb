require 'towhee/blog/layout'
require 'towhee/html/writer'
require 'towhee/blog/site'
require 'rexml/document'
require 'rexml/xpath'

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

  describe "structure" do
    it "renders heading inside full width column" do
      find(view.render, ".container .col-12", contains: "A Site")
    end

    it "renders main content inside main column" do
      find(view.render, ".container .col-8", contains: "Main content")
    end

    it "renders sidebar inside side column" do
      find(view.render, ".container .col-4", contains: "Module 1")
    end
  end

  def find(markup, selector, contains: nil)
    matches = css(markup, selector, contains: contains)
    custom_msg = "Expected to find selector '#{selector}' in:\n#{markup}"
    expect(matches.size).to eq(1), custom_msg
    matches.first
  end

  # Only a subset of CSS is supported: .class1 .class2 ...
  def css(markup, selector, contains: nil)
    path = compile_css_to_xpath(selector, contains: contains)
    xpath(markup, path)
  end

  # Not sure REXML is the way to go here... but it avoids a dependency on
  # a C library (nokogiri).
  def xpath(markup, path)
    node = REXML::Document.new(markup).root
    REXML::XPath.match(node, path)
  end

  def compile_css_to_xpath(selector, contains: nil)
    exprs = selector.split
    path = exprs.inject("") do |path, expr|
      if expr.start_with?(".")
        klass = expr.sub(".", "")
        path += "//*[@class='#{klass}']"
      else
        raise "Unsupported CSS expression: #{expr} in: #{selector}"
      end
    end
    path += "[contains(., '#{contains}')]" if contains
    path
  end
end
