require_relative "image_previewer"

ImagePreviewer.define do
  on csrf.unsafe? do
    csrf.reset!
    res.status = 403
    res.write "Not authorized"
    halt res.finish
  end

  on get,root do
    route "main#index"
  end

  ############ PREVIEWER ###############
  on get, "preview" do
    route "previewer#index"
  end

  on post, "preview" do
    route "previewer#preview"
  end

  ############ PDF CONVERTER ###############
  on get, "converter" do
    route "converter#index"
  end

  on post, "convert" do
    route "converter#convert_to_pdf"
  end

  ############ UPSCALER ###############

  on get, "upscale" do
    route "upscaler#index"
  end

  on post, "upscale" do
    route "upscaler#upscale"
  end

  on get, ":token" do |token|
    req.params["token"] = token
    route "main#show"
  end
end
