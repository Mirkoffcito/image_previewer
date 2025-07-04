require 'open3'

class Waifu2xUpscaler
  OUTPUT_DIR    = File.expand_path('../output', __dir__)

  attr_reader :output_dir, :format, :scale, :noise, :tile, :model
  # scale: Integer (1=no resize, 2=2x, 4=4x)
  # noise: Integer (0=no denoise, 1..3)
  # tile: Integer (tile size, 0 = no tiling)
  # model: String (e.g. 'models-upconv_7_photo', 'models-cunet')
  def initialize(output_dir:, format: 'png', scale: 2, noise: 2, tile: 0, model: nil)
    output_dir = output_dir || OUTPUT_DIR
    @output_dir = output_dir
    @scale = scale
    @noise = noise
    @tile  = tile
    @model = model
    FileUtils.mkdir_p(@output_dir)
  end

  def convert(input_path, options = {})
    filename        = options[:filename] || input_path
    output_basename = File.basename(filename, '.*')
    out = output_path(output_basename, 'png')

    cmd = ['waifu2x-ncnn-vulkan',
           '-i', input_path,
           '-o', out,
           '-s', @scale.to_s,
           '-n', @noise.to_s]

    # specify tile size if provided
    cmd += ['-t', @tile.to_s] if @tile > 0

    # specify model directory if provided
    cmd += ['-m', @model] if @model

    stdout_str, stderr_str, status = Open3.capture3(*cmd)
    unless status.success?
      raise "waifu2x-ncnn-vulkan failed: #{stderr_str}"  
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
