#!/usr/bin/env ruby
#
# bin/previewer (inside the container)
#
# Usage:
#   bin/previewer [--format=jpeg|png] [--colorspace=srgb|cmyk] [magick|vips] convert <file>

require 'optparse'
require_relative '../lib/base_previewer'
require_relative '../lib/magick_previewer'
require_relative '../lib/vips_previewer'

options = { format: :png, colorspace: :srgb, output_dir: nil }
parser = OptionParser.new do |opts|
  opts.banner = "Usage: previewer [options] [magick|vips] convert <file>"

  opts.on("-fFMT", "--format=FMT", "Output format: jpeg or png") do |f|
    unless %w[jpeg png].include?(f)
      warn "Invalid format #{f}; must be jpeg or png"
      exit 1
    end
    options[:format] = f.to_sym
  end

  opts.on("-cCS", "--colorspace=CS", "Colorspace: srgb or cmyk") do |cs|
    unless %w[srgb cmyk].include?(cs)
      warn "Invalid colorspace #{cs}; must be srgb or cmyk"
      exit 1
    end
    options[:colorspace] = cs.to_sym
  end

  opts.on("-o DIR", "--output-dir=DIR", "Where to put previews") do |d|
    options[:output_dir] = d
  end
end

# strip out any flags, leave [engine, command, file]
parser.order!(ARGV)
engine, command, file = ARGV

unless %w[magick vips].include?(engine) && command == 'convert' && file
  warn parser.banner
  exit 1
end

out = case engine
when 'magick'
  MagickPreviewer.new(output_dir: options[:output_dir], format: options[:format], colorspace: options[:colorspace]).convert(file)

when 'vips'
  VipsPreviewer.new(output_dir: options[:output_dir], format: options[:format], colorspace: options[:colorspace]).convert(file)
end

puts out