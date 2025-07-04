class MainController < BaseController
  def index
    render_view('previewer/index')
  end

  def show
    token = params["token"] or return bad_request("No token")

    begin
      decoded = Base64.urlsafe_decode64(token)
      data    = JSON.parse(decoded)
      rel_paths =
        if data.is_a?(Hash) && data["paths"]
          Array(data["paths"])
        else
          # backward-compat: token used to be a single string path
          Array(data)
        end
    rescue ArgumentError, JSON::ParserError
      return bad_request("Invalid preview token")
    end

    render_view("result", preview_paths: rel_paths)
  rescue ArgumentError
    bad_request("Invalid preview token")
  end
end