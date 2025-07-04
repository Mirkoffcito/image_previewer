import { Controller } from "@hotwired/stimulus"
import Splide from "@splidejs/splide"

// Custom Splide extension to adjust height per slide
function AdjustableHeight(SplideInstance, Components, options) {
  const track = Components.Elements.track;
  const list  = Components.Elements.list;

  // Default settings
  const defaults = { whileSliding: true, speed: '0.4s' };
  const settings = { ...defaults, ...(options.adjustableHeight || {}) };

  function mount() {
    const eventType = settings.whileSliding
      ? 'move active resize'
      : 'active resized';
    SplideInstance.on(eventType, adjustHeight);
  }

  function adjustHeight() {
    const slide = Components.Slides.getAt(SplideInstance.index).slide;
    const slideHeight = slide.offsetHeight;

    // Calculate padding if adjusting track
    const style = track.currentStyle || window.getComputedStyle(track);
    const padding = parseInt(style.paddingTop) + parseInt(style.paddingBottom);
    const totalHeight = settings.whileSliding ? slideHeight + padding : slideHeight;

    // Allow flex items to vary height
    list.style.alignItems = 'flex-start';

    // Apply transition and height
    const element = settings.whileSliding ? track : list;
    element.style.transition = `height ${settings.speed}`;
    element.style.height     = `${totalHeight}px`;
  }

  return { mount };
}

// Connects to data-controller="shared--splide"
export default class extends Controller {
  static targets = ["root", "link"]
  static values = {
    options: Object,    // pass Splide options via data-splide-options-value
    paths:   Array      // pass preview paths via data-splide-paths-value
  }

  connect() {
    console.log("🔌 SplideController connected");
    this.splide = this._buildSplide();
    this.splide.on('mounted move', () => this.updateDownload());
    this.splide.mount({AdjustableHeight});
  }

  disconnect() {
    if (this.splide) {
      this.splide.destroy(true);
    }
  }

  _buildSplide() {
    const defaultOptions = {
      type:       'slide',
      perPage:    1,
      arrows:     true,
      pagination: true,
      gap:        '1rem',
      rewind:     true,
      autoHeight: false,            // disable built-in autoHeight
      extensions: { AdjustableHeight },
    };

    const config = { ...defaultOptions, ...this.optionsValue };
    return new Splide(this.rootTarget, config);
  }

  updateDownload() {
    console.log("paths Value", this.pathsValue)
    const url = this.pathsValue[this.splide.index];
    console.log(url)
    this.linkTarget.href = url;
  }
}
