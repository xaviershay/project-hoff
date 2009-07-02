require 'rubygems'
require 'RMagick'

resized_dir = File.dirname(__FILE__) + '/../img/resized'
greyscaled_dir = File.dirname(__FILE__) + '/../img/greyscaled'

FileUtils.mkdir_p(greyscaled_dir)

img_sizes = []
Dir.new(resized_dir).entries.each do |filename|
  next unless filename =~ /\.jpg$/

  greyscaled_file_name = File.join(greyscaled_dir, filename)
  next if File.exists?(greyscaled_file_name)

  img = Magick::Image.read(File.join(resized_dir, filename)).first

  img = img.quantize(256, Magick::GRAYColorspace)
  img.write(greyscaled_file_name)
  puts greyscaled_file_name
end
