require 'rubygems'
require 'RMagick'
require File.dirname(__FILE__) + '/file_cache'

greyscaled_dir = File.dirname(__FILE__) + '/../img/greyscaled'
hoff_in_jocks = {
  :filename => 'hoff-in-jocks',
  :columns  => 34,
  :rows     => 50
}
hoff_face = {
  :filename => 'hoff-face',
  :columns  => 80,
  :rows     => 120
}

input = hoff_face
src_image = File.dirname(__FILE__) + '/../img/src/' + input[:filename] + '.jpg'
out_image = File.dirname(__FILE__) + '/../img/out/' + input[:filename] + '-mosaic.jpg' 

tile_size = 200

puts "Analyzing source image"
src = Magick::Image.read(src_image).first
src.resize!(input[:columns], input[:rows])
src_colors = Hash.new { 0 }
(0..src.rows-1).each do |y|
  (0..src.columns-1).each do |x|
    src_colors[src.pixel_color(x,y).intensity.to_i] += 1
  end
end

puts "Analyzing component images"
image_data = file_cache("image_data_greyscale_jocks") do
  Dir.new(greyscaled_dir).entries.collect do |filename|
    next unless filename =~ /\.jpg$/
    filename = File.join(greyscaled_dir, filename)

    mean, std_dev = Magick::Image.read(filename).first.channel_mean(Magick::AllChannels)
    [filename, mean, std_dev]
  end.compact
end

image_data = image_data * ((src.rows * src.columns) / image_data.length)
image_data = image_data.sort_by {|x| x[1] }
src_colors.keys.sort.each do |k|
  src_colors[k] = image_data.slice!(0..src_colors[k]-1).compact
end

puts "Compositing mosaic"
x = 0; y = 0;
background = Magick::Image.new(src.columns * tile_size, src.rows * tile_size)
(0..src.rows*src.columns-1).each do |count|
  tmp = src_colors[src.pixel_color(x,y).intensity.to_i]

  i = rand(tmp.length)
  (f, mean, std_dev) = tmp[i]
  img = Magick::Image.read(f).first

  background.composite!(img, x*tile_size, y*tile_size, Magick::OverCompositeOp)

  x += 1
  if x == src.columns
    y += 1;x = 0
    puts "Row: #{y}"
  end
end

puts "Writing mosaic"
background.write(out_image) { self.quality = 100; self.sampling_factor = '1x1' }
