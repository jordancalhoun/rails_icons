# frozen_string_literal: true

module RailsIcons
  # Defines the configuration options for the Lucide icon pack
  class LucideConfig
    def config
      options = ActiveSupport::OrderedOptions.new
      setup_lucide_outlined_config(options)

      options
    end

    private

    def setup_lucide_outlined_config(options)
      options.outline = ActiveSupport::OrderedOptions.new
      options.outline.default = default_outlined_options
    end

    def default_outlined_options
      options = ActiveSupport::OrderedOptions.new
      options.stroke_width = "1.5"
      options.css = "w-6 h-6"
      options.data = {}
      options
    end
  end
end
