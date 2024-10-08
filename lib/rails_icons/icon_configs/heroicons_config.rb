# frozen_string_literal: true

module RailsIcons
  # Defines the configuration options for the heroicons icon pack
  class HeroiconsConfig
    def config
      options = ActiveSupport::OrderedOptions.new
      setup_heroicons_outline_config(options)
      setup_heroicons_solid_config(options)
      setup_heroicons_mini_config(options)
      setup_heroicons_micro_config(options)
      options
    end

    private

    def setup_heroicons_solid_config(options)
      options.solid = ActiveSupport::OrderedOptions.new
      options.solid.default = default_solid_options
    end

    def setup_heroicons_outline_config(options)
      options.outline = ActiveSupport::OrderedOptions.new
      options.outline.default = default_outline_options
    end

    def setup_heroicons_mini_config(options)
      options.mini = ActiveSupport::OrderedOptions.new
      options.mini.default = default_mini_options
    end

    def setup_heroicons_micro_config(options)
      options.micro = ActiveSupport::OrderedOptions.new
      options.micro.default = default_micro_options
    end

    def default_solid_options
      options = ActiveSupport::OrderedOptions.new
      options.css = 'w-6 h-6'
      options.data = {}
      options
    end

    def default_outline_options
      options = ActiveSupport::OrderedOptions.new
      options.stroke_width = 1.5
      options.css = 'w-6 h-6'
      options.data = {}
      options
    end

    def default_mini_options
      options = ActiveSupport::OrderedOptions.new
      options.css = 'w-5 h-5'
      options.data = {}
      options
    end

    def default_micro_options
      options = ActiveSupport::OrderedOptions.new
      options.css = 'w-4 h-4'
      options.data = {}
      options
    end
  end
end
