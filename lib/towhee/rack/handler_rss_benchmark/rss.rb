def rss
  `ps -p #$$ -o rss`.split("\n")[1].strip.to_i
end
