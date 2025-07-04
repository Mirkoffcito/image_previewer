require 'vips'
require_relative 'base_previewer'

class VipsPreviewer < BasePreviewer
  def convert(path, options = {})
    ext = @format == :jpeg ? 'jpeg' : 'png'
    filename = options[:filename] || path
    output_basename = File.basename(filename, '.*')
    out = output_path(output_basename, ext)
    mime = Marcel::MimeType.for(Pathname.new(path))

    image = case mime
    when 'application/pdf'
      Vips::Image.pdfload(path, dpi: 300, n: 1)
    else
      Vips::Image.new_from_file(path, access: :sequential)
    end

    # CMYK → SWOP
    if image.interpretation == :cmyk
      image = image.icc_import(
        input_profile:  SWOP_ICC,
        embedded:       false,
        intent:         :perceptual
      )
    end

    # target colorspace
    case @colorspace
    when :srgb
      image = image.colourspace(:srgb)
      image = image.icc_export(
        output_profile: SRGB_ICC,
        intent:         :perceptual
      )
    when :cmyk
      image = image.colourspace(:cmyk)
      image = image.icc_export(
        output_profile: SWOP_ICC,
        intent:         :perceptual
      )
    end

    # flatten alpha
    if image.has_alpha?
      bg = @colorspace == :cmyk ? ([0] * (image.bands - 1)) : ([255] * (image.bands - 1))
      image = image.flatten(background: bg)
    end

    image = image.sharpen(sigma: 0.25, x1: 8, y2: 0.065)
    
    # save
    if @format == :png
      image.pngsave(out, compression: 9, strip: true, interlace: false)
    elsif @format == :jpeg
      image.jpegsave(out, strip: true, interlace: false, Q: 90)
    end
    out
  end
end

## require "./lib/vips_previewer"
## VipsPreviewer.new.convert(File.join("./lib/examples", "ABQTours23.psd"))