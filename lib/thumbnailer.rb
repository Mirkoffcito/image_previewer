# lib/thumbnailer.rb
require "vips"
require "fileutils"

class Thumbnailer
  attr_reader :input, :output_dir, :format, :size, :engine

  def initialize(input:, output_dir:, format: :webp, size: [200,200], engine: :magick)
    raise ArgumentError, "size must be [w,h]" unless size.is_a?(Array) && size.size == 2
    @input      = input
    @output_dir = output_dir
    @format     = format.to_s
    @width, @height = size
    @engine = engine.to_sym
  end

  def call
    FileUtils.mkdir_p(output_dir)
    basename = File.basename(input, ".*")
    out_path = File.join(output_dir, "#{basename}.#{format}")
    
    if engine == :vips
      image = Vips::Image.new_from_file(input, access: :random)
      thumb = image.thumbnail_image(@width)
      thumb.write_to_file(out_path)
    elsif engine == :magick
      image = MiniMagick::Image.open(input)
      image.resize("#{@width}x#{@height}")
      image.format(format)
      image.write(out_path)
    end

    out_path
  end

end
