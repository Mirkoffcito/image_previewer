require 'mini_magick'
require_relative 'base_previewer'

class MagickPreviewer < BasePreviewer
  def convert(path, options = {})
    img = MiniMagick::Image.open(path)
    filename = options[:filename] || path
    output_basename = File.basename(filename, '.*')
    output = output_path(output_basename, @format == :jpeg ? 'jpeg' : 'png')

    MiniMagick.mogrify do |mogrify|
      mogrify << "-density" << "300"
      mogrify << "-strip"
      bg = (@colorspace == :cmyk) ? "cmyk(0,0,0,0)" : "white"
      mogrify << "-background" << bg
      mogrify << "-flatten"
      mogrify << "-profile" << SWOP_ICC if img.colorspace =~ /CMYK/i
      
      # export to desired colorspace
      case @colorspace
      when :srgb
        mogrify << '-profile' << SRGB_ICC
      when :cmyk
        mogrify << '-profile' << SWOP_ICC
      end

      # sharpen, posterize, etc.
      mogrify << "-filter" << "Triangle" << "-define" << "filter:support=2"
      mogrify << "-unsharp" << "0.25x0.25+8+0.065"
      mogrify << "-dither"  << "None"
      mogrify << "-posterize" << "136"

      # quality and PNG/JPEG options
      mogrify << "-quality" << "82"
      mogrify << "-interlace" << "none"
      if @format == :jpeg
        mogrify << "-define" << "jpeg:fancy-upsampling=off"
      elsif @format == :png
        mogrify << "-define" << "png:compression-filter=5"
        mogrify << "-define" << "png:compression-level=9"
        mogrify << "-define" << "png:compression-strategy=1"
        mogrify << "-define" << "png:exclude-chunk=all"
      end

      # output format and destination
      mogrify << '-format' << @format
      # mogrify << '-path'   << output_dir
      mogrify << '-write' << output
      mogrify << path
    end

    # return final path
    output
  end
end

## require "./lib/magick_previewer"
## MagickPreviewer.new.convert(File.join("./lib/examples", "ABQTours23.psd"))