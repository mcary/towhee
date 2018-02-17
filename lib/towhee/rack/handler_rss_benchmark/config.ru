require './rss'

class App
  def call(env)
    [200, { }, ["#{rss}"]]
  end
end

app = App.new
run app
