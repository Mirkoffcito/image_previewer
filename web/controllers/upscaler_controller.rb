class UpscalerController < BaseController
  def index
    render_view('./upscaler/index')
  end

  def upscale
    upload      = params["files"][0]    or return bad_request("No file provided")

    # Parse and coerce params
    @scale  = (params["scale"]  || '2').to_i
    @noise  = (params["noise"]  || '2').to_i
    @tile   = (params["tile"]   || '0').to_i
    @model  = params["model"]   || 'models-cunet'      # e.g. 'models-cunet'
    @format = (params["format"] || 'png').to_sym

    # Run the upscaler
    tempfiles_data    = upload.map { |k, v| { tempfile: v["tempfile"], filename: v["filename"] } }
    out_paths = tempfiles_data.map { |tmp_data| convert(tmp_data[:tempfile].path, {filename: tmp_data[:filename]}) }

    # Paths relative to 'web' root
    rel_paths = out_paths.map { |path| relative_to_webroot(path) }

    # Base64-encode your relative path as the token
    payload = { v: 1, paths: rel_paths }
    token   = Base64.urlsafe_encode64(JSON.generate(payload))

    # Return JSON instead of HTML
    res["content-type"] = "application/json"
    res.write({ redirect_url: token }.to_json)
  end

  private

  def upscaler
    @upscaler ||= Waifu2xUpscaler.new(
      output_dir: output_dir,
      format:     @format,
      scale:      @scale,
      noise:      @noise,
      tile:       @tile,
      model:      @model
    )
  rescue => e
    bad_request("Upscaler initialization failed: #{e.message}")
  end

  def convert(input, options = {})
    upscaler.convert(input, options)
  rescue => e
    server_error(e)
  end
end
