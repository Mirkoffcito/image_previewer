require 'marcel'
require 'fileutils'
require 'byebug'

class BasePreviewer
  SUPPORTED_EXTENSIONS = %w[.psd .tif .tiff .eps .pdf]
  CONTENT_TYPES = %w[
                      application/illustrator application/pdf application/photoshop
                      application/postscript application/x-ai application/x-eps
                      application/x-photoshop application/x-psd image/eps image/psd
                      image/tiff image/vnd.adobe.photoshop image/x-eps
                      image/x-photoshop image/x-psd
                    ].freeze

  PROFILES_DIR = File.expand_path('./profiles', __dir__)
  SWOP_ICC      = File.join(PROFILES_DIR, 'USWebCoatedSWOP.icc')
  SRGB_ICC      = File.join(PROFILES_DIR, 'sRGB.icc')
  OUTPUT_DIR    = File.expand_path('../output', __dir__)

  attr_reader :output_dir, :format, :colorspace

  class << self
    def accept?(path)
      CONTENT_TYPES.include? Marcel::MimeType.for(Pathname.new(path))
    end
  end

  # format: :png or :jpeg (default: :png)
  # colorspace: :srgb or :cmyk (default: :srgb)
  def initialize(output_dir: nil, format: :png, colorspace: :srgb)
    output_dir = output_dir || OUTPUT_DIR
    @output_dir = output_dir
    @format     = format.to_sym
    @colorspace = colorspace.to_sym
    FileUtils.mkdir_p(@output_dir)
  end

  def convert(path)
    raise NotImplementedError, "#{self.class} must implement #convert(path)"
  end

  private

  # Build an output filename under the output_dir, given an extension
  def output_path(basename, ext)
    File.join(output_dir, "#{basename}.#{ext}")
  end
end