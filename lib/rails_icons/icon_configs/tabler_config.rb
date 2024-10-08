# frozen_string_literal: true

module RailsIcons
  # Defines the configuration options for the Tabler icon pack
  class TablerConfig
    def config
      options = ActiveSupport::OrderedOptions.new
      setup_tabler_filled_config(options)
      setup_tabler_outline_config(options)

      options
    end

    private

    def setup_tabler_filled_config(options)
      options.filled = ActiveSupport::OrderedOptions.new
      options.filled.default = default_filled_options
    end

    def setup_tabler_outline_config(options)
      options.outline = ActiveSupport::OrderedOptions.new
      options.outline.default = default_outline_options
    end

    def default_filled_options
      options = ActiveSupport::OrderedOptions.new
      options.css = 'w-6 h-6'
      options.data = {}
      options
    end

    def default_outline_options
      options = ActiveSupport::OrderedOptions.new
      options.stroke_width = 2
      options.css = 'w-6 h-6'
      options.data = {}
      options
    end
  end
end
