class BaseController
  include Controllable

  private

  def bad_request(message)
    res.status = 400
    res.write message
    res.finish
  end

  def server_error(exception)
    res.status = 500
    res.write "Error: #{ exception.message }"
    res.finish
  end

  def relative_to_public(full_path)
    full_path.sub(/\A#{Regexp.escape(settings[:root])}/, "").sub("/public", "")
  end

  def output_dir
    @output_dir ||= File.join(
      settings[:root],
      "public",
      "tmp"
    )
  end
end
