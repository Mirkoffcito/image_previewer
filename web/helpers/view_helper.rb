require "erb"

module ViewHelper
  include ERB::Util

  # Generates an HTML image tag
  def image_tag(src, alt: "", **options)
    attrs = options.map { |key, value| "#{key}=\"#{h(value)}\"" }.join(" ")
    
    "<img src=\"#{h(src)}\" alt=\"#{h(alt)}\" #{attrs}>"
  end

  # Generates a thumbnail image tag
  def thumbnail_image(src, size: [200, 200])
    thumbnailer = Thumbnailer.new(
      input: "#{ImagePreviewer.settings[:public]}#{src}",
      output_dir: output_dir, # Temporary directory for thumbnails
      format: :webp,
      size: size
    )
    thumbnailer.call
  end

  def thumbnail_image_tag(src, size)
    img_src = thumbnail_image(src, size: size)
    image_tag(relative_to_public(img_src), alt: "preview thumbnail", class: "w-full h-auto block")
  end

  def filename(src)
    File.basename(src, '.*')
  end

  private

  def output_dir
    @output_dir ||= File.join(
      ImagePreviewer.settings[:public],
      "tmp"
    )
  end

  def relative_to_public(full_path)
    full_path.sub(/\A#{Regexp.escape(settings[:root])}/, "").sub("/public", "")
  end
end

