require 'rubygems'
require 'RMagick'

cropped_dir = File.dirname(__FILE__) + '/../img/cropped'
resized_dir = File.dirname(__FILE__) + '/../img/resized'

FileUtils.mkdir_p(resized_dir)

size = 100
img_sizes = []
Dir.new(cropped_dir).entries.each do |filename|
  next unless filename =~ /\.jpg$/

  resized_file_name = File.join(resized_dir, filename)
  next if File.exists?(resized_file_name)

  img = Magick::Image.read(File.join(cropped_dir, filename)).first
  next unless img.columns >= size

  img.resize!(100, 100)
  img.write(resized_file_name)
  puts resized_file_name
end
