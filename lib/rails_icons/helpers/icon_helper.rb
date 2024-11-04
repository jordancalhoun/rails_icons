# frozen_string_literal: true

require_relative "../configuration"

module RailsIcons
  module Helpers
    # Define the "icon" helper to generate and display icons
    module IconHelper
      def icon(name, library: RailsIcons.configuration.default_library, set: nil, variant: set, **args)
        RailsIcons::Icon.new(
          name: name,
          library: library,
          set: set.to_s,
          args: args
        ).svg
      end
    end
  end
end
