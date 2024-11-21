# frozen_string_literal: true

require "fileutils"

require_relative "helpers/icon_sync_engine"
module RailsIcons
  class SyncGenerator < Rails::Generators::Base
    SETS = {
      heroicons: {
        name: "heroicons",
        url: "https://github.com/tailwindlabs/heroicons.git",
        variants: {
          outline: "optimized/24/outline",
          solid: "optimized/24/solid",
          mini: "optimized/20/solid",
          micro: "optimized/16/solid"
        }
      },
      tabler: {
        name: "tabler",
        url: "https://github.com/tabler/tabler-icons.git",
        variants: {
          filled: "icons/filled",
          outline: "icons/outline"
        }
      },
      lucide: {
        name: "lucide",
        url: "https://github.com/lucide-icons/lucide.git",
        variants: {
          outline: "icons"
        }
      }
    }.freeze

    argument :libraries, type: :array, default: [], banner: "heroicons lucide tabler"

    class_option :destination, type: :string, default: nil,
      desc: "Custom destination folder for icons (default: `app/assets/svg/icons/`)"

    desc "Sync a specified icon set(s) from their respective git repos."
    source_root File.expand_path("templates", __dir__)

    def sync_icons
      clean_temp_directory

      libraries.each { |set_name| sync_icon_set(set_name) }

      clean_temp_directory
    end

    private

    def icons_directory
      options[:destination] || Rails.root.join("app/assets/svg/icons")
    end

    def temp_icons_directory
      Rails.root.join("tmp/icons")
    end

    def clean_temp_directory
      FileUtils.rm_rf(temp_icons_directory) if Dir.exist?(temp_icons_directory)
    end

    def sync_icon_set(set_name)
      set = SETS[set_name.to_sym]

      IconSyncEngine.new(temp_icons_directory, set).sync

      icon_set_path = File.join(temp_icons_directory, set[:name])

      if Dir.exist?(icon_set_path)
        copy_icon_set(set[:name], icon_set_path)
      else
        log_icon_set_not_found(set_name)
      end
    end

    def copy_icon_set(set_name, source)
      destination = File.join(icons_directory, set_name)

      # Create icon set directory if it doesn't exist.
      FileUtils.mkdir_p(destination)

      # Move icon set from the temp_icons_directory to icons_directory
      FileUtils.cp_r(Dir.glob("#{source}/*"), destination)

      say "Synced `#{set_name}` icons successfully.", :green
    end

    def log_icon_set_not_found(set)
      say "Icon set `#{set}` not found.", :red
      exit 1
    end
  end
end
