Image Previewer is a small image processing project. It uses tools such as ImageMagick, Libvips and Waifu2x to provide features such as:

## Features

- Convert many input formats (.psd, .gif, .tiff, .eps, .svg, .webp, .png, .jpg, multi-page PDF) to PNG or JPEG using libvips or ImageMagick.
- Convert images between sRGB and CMYK color spaces (ICC-aware).
- WIP: combine multiple images into one printable PDF with options:
  - page orientation
  - page size (A3, A4, Letter, etc.)
  - layout (grid, one-per-page, all-in-one)
  - scale modes: fit (preserve aspect ratio) or fill (cover & crop)
  - DPI and margins
- Upscale images with waifu2x via the ncnn Vulkan implementation (waifu2x-ncnn-vulkan).

### Instructions for the web UI

```bash
# 1. Clone (replace with your repository URL)
git clone https://github.com/Mirkoffcito/image_previewer.git
cd image-previewer

# 2. Build the image and install dependencies (uses Docker)
bin/setup

# 3. Start the web UI (bundles assets and starts the server)
bin/run_server

# 4. Open the web UI in your browser:
# http://localhost:9292
```
That's it! You can try for yourself.
