class ConverterController < BaseController
  def index
    render_view('converter/index')
  end

  def convert_to_pdf
    upload      = params["files"][0]    or return bad_request("No file provided")

    @engine     = params["engine"]     || "vips"

    # Sends one or multiple files to the converter and returns a PDF
    tempfiles_data    = upload.map { |k, v| { tempfile: v["tempfile"], filename: v["filename"] } }
    out_path = convert(tempfiles_data.map { |tmp_data| tmp_data[:tempfile].path }, filename: 'pdf_output')
    pdf_rel_path = relative_to_webroot(out_path)

    # Base64-encode your relative path as the token
    payload = { paths: Array(pdf_rel_path) }
    token = Base64.urlsafe_encode64(payload.to_json)

    # Return JSON instead of HTML
    res["content-type"] = "application/json"
    res.write({ redirect_url: token }.to_json)
  end

  private

  def converter
    @converter ||= PdfConverter.new(output_dir:  output_dir, engine: @engine)
  end

  def convert(input, options = {})
    converter.convert(input, options)
  rescue => e
    server_error(e)
  end
end