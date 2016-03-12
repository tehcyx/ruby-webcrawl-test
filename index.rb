require 'open-uri'
require 'uri'
require 'thread'

if ARGV[0].nil? && !(ARGV[0] =~ /\A#{URI::regexp(['http', 'https'])}\z/) then
  puts "No URL parameter passed."
  exit
end

threadPool = []

linkQueue = []
linkQueue << ARGV[0]

visited = []

def crawl_url(url)
  puts "visiting: #{url}"
  content = open(url,
     "User-Agent" => "Daniel Roth / ruby web crawler 0.0.1",
     "From" => "foo@bar.invalid",
     "Referer" => "127.0.0.1") { |f|
       f.read
  }

  content.gsub!(/<head.*>.*<\/head>/i, '')

  content.each_line { |line|
    captures = line.match(URI::regexp(['http', 'https']))
    puts captures if !captures.nil?
    # .each { |s|
    #   puts "found #{s}"
    #   linkQueue << s if !linkQueue.include?(s) && !visited.include?(s)
    # }
  }
end

10.times do |i|
  threadPool[i] = Thread.new {
    until linkQueue.empty?
      url = linkQueue.pop
      if !url.nil? then
        visited << url
        crawl_url(url)
      end
    end
  }
end

threadPool.each {|t| t.join }
