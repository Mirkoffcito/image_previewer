class PreviewerController < BaseController
  def index
    render_view('./previewer/index')
  end
  
  def preview
    upload      = params["files"][0]    or return bad_request("No file provided")

    @engine     = params["engine"]     || "vips"
    @format     = (params["format"]    || "png").to_sym
    @colorspace = (params["colorspace"] || "srgb").to_sym
    
    tempfiles_data    = upload.map { |k, v| { tempfile: v["tempfile"], filename: v["filename"] } }
    out_paths = tempfiles_data.map { |tmp_data| convert(tmp_data[:tempfile].path, {filename: tmp_data[:filename]}) }
    
    # Paths relative to 'web' root
    rel_paths = out_paths.map { |path| relative_to_public(path) }

    # Base64-encode your relative path as the token
    payload = { v: 1, paths: rel_paths }
    token   = Base64.urlsafe_encode64(JSON.generate(payload))

    # Return JSON instead of HTML
    res["content-type"] = "application/json"
    res.write({ redirect_url: token }.to_json)
  end

  private

  def previewer
    @previewer ||= case @engine
    when "magick"
      MagickPreviewer.new(
        output_dir:  output_dir,
        format:      @format,
        colorspace:  @colorspace
      )
    when "vips"
      VipsPreviewer.new(
        output_dir:  output_dir,
        format:      @format,
        colorspace:  @colorspace
      )
    else
      bad_request("Unknown engine #{@engine}")
    end
  end

  def convert(input, options = {})
    previewer.convert(input, options)
  rescue => e
    server_error(e)
  end
end