require 'towhee/html/writer'

RSpec.describe Towhee::HTML::Writer do
  it "writes spans without indentation" do
    result = subject.span { "hello" }
    expect(result.to_s).to eq "<span>hello</span>"
  end

  it "writes spans with class" do
    result = subject.span(class: "foo") { "hello" }
    expect(result.to_s).to eq "<span class=\"foo\">hello</span>"
  end

  it "writes divs with indentation" do
    result = subject.div { "hello" }
    expect(result.to_s).to eq "<div>\n  hello\n</div>\n"
  end

  it "writes divs with class" do
    result = subject.div(class: "foo") { "hello" }
    expect(result.to_s).to eq "<div class=\"foo\">\n  hello\n</div>\n"
  end

  it "writes paragraphs" do
    result = subject.p { "hello" }
    expect(result.to_s).to eq "<p>\n  hello\n</p>\n"
  end

  it "writes links" do
    result = subject.a(href: "/path") { "text" }
    expect(result.to_s).to eq "<a href=\"/path\">text</a>"
  end

  it "writes line break tags with a newline" do
    result = subject.br
    expect(result.to_s).to eq "<br />\n"
  end

  it "writes header tags" do
    (1..6).each do |n|
      result = subject.public_send("h#{n}") { "hello" }
      expect(result.to_s).to eq "<h#{n}>\n  hello\n</h#{n}>\n"
    end
  end

  it "writes ul with li" do
    result = subject.ul { subject.li { "hi" } }
    expect(result.to_s).to eq "<ul>\n  <li>\n    hi\n  </li>\n  \n</ul>\n"
  end

  it "writes html, head, and body" do
    result = subject.html { subject.head {} + subject.body {} }
    expect(result.to_s).to eq "
      <html>
        <head>
        </head>
        <body>
        </body>
        
      </html>
    ".gsub("\n" + " "*6, "\n").strip + "\n"
  end

  it "writes title" do
    result = subject.title { "Site » Page" }
    expect(result.to_s).to eq "<title>Site » Page</title>\n"
  end

  it "writes link" do
    result = subject.link(href: "style.css", rel: "stylesheet")
    expect(result.to_s).to eq "<link href=\"style.css\" rel=\"stylesheet\" />\n"
  end

  it "writes script with unescaped content" do
    result = subject.script { "alert('hello');" }
    expect(result.to_s).to eq "<script>\n  alert('hello');\n</script>\n"
  end

  it "writes empty script as inline with newline" do
    result = subject.script(src: "foo.js")
    expect(result.to_s).to eq "<script src=\"foo.js\"></script>\n"
  end

  it "writes style with unescaped content" do
    result = subject.style { "h1 { font-family: \"Arial\" }" }
    expect(result.to_s).to eq \
      "<style>\n  h1 { font-family: \"Arial\" }\n</style>\n"
  end

  it "nests block-in-block" do
    result = subject.div { subject.p { "hello" } }
    expect(result.to_s).to eq "<div>\n  <p>\n    hello\n  </p>\n  \n</div>\n"
  end

  it "nests inline-in-block" do
    result = subject.div { subject.span { "hello" } }
    expect(result.to_s).to eq "<div>\n  <span>hello</span>\n</div>\n"
  end

  it "nests empty-in-block" do
    result = subject.div { subject.br }
    expect(result.to_s).to eq "<div>\n  <br />\n  \n</div>\n"
  end

  it "div escapes child content" do
    result = subject.div { "<script>" }
    expect(result.to_s).to eq "<div>\n  &lt;script&gt;\n</div>\n"
  end

  it "span escapes child content" do
    result = subject.span { "<script>" }
    expect(result.to_s).to eq "<span>&lt;script&gt;</span>"
  end

  it "div escapes attribute values" do
    result = subject.div(class: "\"><script>") { }
    expect(result.to_s).to include "<div class=\"&quot;&gt;&lt;script&gt;\">\n"
  end

  it "protects from invalid attribute names" do
    expect {
      subject.div("><script>" => "foo") { }
    }.to raise_error("Invalid attribute name")
  end

  it "contains multiple children" do
    result = subject.div { subject.text("Here: ") + subject.span { "foo" } }
    expect(result.to_s).to eq "<div>\n  Here: <span>foo</span>\n</div>\n"
  end

  it "joins fragments" do
    result = subject.ul do
      subject.join_fragments([
        subject.li { "one" },
        subject.li { "two" },
      ])
    end
    expect(result.to_s).to eq \
      "<ul>\n  <li>\n    one\n  </li>\n  <li>\n    two\n  </li>\n  \n</ul>\n"
  end

  it "raises on String::+" do
    expect {
      subject.div { "Here: " + subject.span { "foo" } }
    }.to raise_error(
      TypeError,
      "no implicit conversion of Towhee::HTML::Fragment into String",
    )
  end

  it "runs fast" do
    long_str = "asdfasdf " * 12 # Enough to allocate on the heap
    result = benchmark "writer spec" do
      subject.div class: "container" do
        10.times.map do
          subject.p {
            subject.a(href: "http://example.com/") { "Example Link" } +
              subject.text(long_str)
          }
        end.inject(subject.text(""), &:+)
      end
    end
    lines = result.to_s.split("\n")
    expect(lines.grep(/>Example Link</).count).to eq 10
  end
end
