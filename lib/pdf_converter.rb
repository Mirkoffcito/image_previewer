require 'mini_magick'
require 'marcel'
require 'fileutils'
require 'byebug'

class PdfConverter
    CONTENT_TYPES = %w[
                      application/illustrator application/photoshop
                      application/postscript application/x-ai application/x-eps
                      application/x-photoshop application/x-psd image/eps image/psd
                      image/tiff image/vnd.adobe.photoshop image/x-eps
                      image/x-photoshop image/x-psd image/png image/jpeg image/gif
                    ].freeze

  OUTPUT_DIR    = File.expand_path('../output', __dir__)

  attr_reader :output_dir, :format, :colorspace

  class << self
    def accept?(path)
      CONTENT_TYPES.include? Marcel::MimeType.for(Pathname.new(path))
    end
  end

  def initialize(output_dir: nil, engine: nil)
    output_dir = output_dir || OUTPUT_DIR
    @output_dir = output_dir
    FileUtils.mkdir_p(@output_dir)
  end

  # Convert any supported file → PDF.
  # Returns the absolute path of the new PDF.
  def convert(input, options = {})
    input = input.is_a?(Array) ? input : Array(input)
    filename = options[:filename]
    output_basename = File.basename(filename, '.*')
    out = output_path(output_basename, 'pdf')

    # Otherwise, invoke ImageMagick to wrap/rasterize into PDF
    MiniMagick::Tool::Convert.new do |cmd|
      input.each { |p| cmd << p }
      cmd << out
    end

    out
  end

  private

  # Build a name like "foo.pdf" in your output_dir
  def output_path(input_path, ext)
    base = File.basename(input_path, File.extname(input_path))
    File.join(@output_dir, "#{base}.#{ext}")
  end
end