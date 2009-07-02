require 'rubygems'
require 'open-uri'
require 'hpricot'
require 'net/http'

require 'file_cache'

photo_pages = []
page = 1
while true
  url = "http://www.davidhasselhoff.com/photo/photo/search?q=hasselhoff&page=#{page}" 
  data = file_cache(url) { Net::HTTP.get(URI.parse(url)) }
  doc = Hpricot(data)
  new_elements = []
  (doc / ".xg_list_photo_main" / "h3 a").each do |element|
    new_elements << element["href"]
  end

  break if new_elements.empty?

  photo_pages += new_elements

  page += 1
end

puts photo_pages.size
image_urls = file_cache("image_urls") { 
  photo_pages.collect do |page|
    data = file_cache(page) { Net::HTTP.get(URI.parse(page)) }
    doc = Hpricot(data)
    
    photos = (doc / ".photo img")
      
    photos.first['src'] unless photos.empty?
  end.compact
}


image_urls.each_slice(4) do |urls|
  Thread.new(urls) do |urls|
    urls.each do |url|
      base = File.dirname(__FILE__) + "/../img/raw"
      FileUtils.mkdir_p(base)
      uri = URI.parse(url)
      file_name = base + '/' + uri.path.split('/').last.split("?").first.downcase
      next if File.exists?(file_name)
      puts file_name
      File.open(file_name, "w") {|f| f.write(Net::HTTP.get(URI.parse(url))) }
    end
  end.join
end
