require 'rubygems'
require 'RMagick'

raw_dir = File.dirname(__FILE__) + '/../img/raw'
cropped_dir = File.dirname(__FILE__) + '/../img/cropped'

FileUtils.mkdir_p(cropped_dir)

Dir.new(raw_dir).entries.each do |filename|
  next unless filename =~ /\.jpg$/

  cropped_file_name = File.join(cropped_dir, filename)
  next if File.exists?(cropped_file_name)

  img = Magick::Image.read(File.join(raw_dir, filename)).first

  if img.columns > img.rows
    # Landscape, crop centre
    img.crop!(Magick::CenterGravity, img.rows, img.rows)
  else
    # Portrait, crop top square
    img.crop!(Magick::NorthGravity, img.columns, img.columns)
  end
  img.write(cropped_file_name)
  puts cropped_file_name
end
