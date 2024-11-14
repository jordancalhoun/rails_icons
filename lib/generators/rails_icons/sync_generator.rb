# frozen_string_literal: true

require "fileutils"

require_relative "helpers/icon_sync_engine"
module RailsIcons
  class SyncGenerator < Rails::Generators::Base
    REPOSITORIES = {
      heroicons: {
        name: "heroicons",
        repo_url: "https://github.com/tailwindlabs/heroicons.git",
        icon_dir: "src/24",
        dir_wrapper: ""
      },
      tabler: {
        name: "tabler",
        repo_url: "https://github.com/tabler/tabler-icons.git",
        icon_dir: "icons",
        dir_wrapper: ""
      },
      lucide: {
        name: "lucide",
        repo_url: "https://github.com/lucide-icons/lucide.git",
        icon_dir: "icons",
        dir_wrapper: "/outline"
      }
    }.freeze

    argument :libraries, type: :array, default: [], banner: "heroicons lucide tabler"

    class_option :destination, type: :string, default: nil,
      desc: "Custom destination folder for icons (default: `app/assets/svg/icons/`)"

    desc "Sync a specified icon set(s) from their respective git repos."
    source_root File.expand_path("templates", __dir__)

    def sync_icons
      icons_dir = options[:destination] || default_icons_dir
      tmp_dir = tmp_icons_dir

      clean_tmp_dir(tmp_dir)

      libraries.each { |set| sync_icon_set(set, tmp_dir, icons_dir) }

      clean_tmp_dir(tmp_dir)
    end

    private

    def default_icons_dir
      Rails.root.join("app/assets/svg/icons")
    end

    def tmp_icons_dir
      Rails.root.join("tmp/icons")
    end

    def clean_tmp_dir(tmp_dir)
      FileUtils.rm_rf(tmp_dir) if Dir.exist?(tmp_dir)
    end

    def sync_icon_set(set, tmp_dir, icons_dir)
      repo = REPOSITORIES[set.to_sym]
      IconSyncEngine.new(tmp_dir, repo).sync
      icon_set_path = File.join(tmp_dir, set)

      if Dir.exist?(icon_set_path)
        copy_icon_set(set, icon_set_path, icons_dir)
      else
        log_icon_set_not_found(set)
      end
    end

    def copy_icon_set(set, set_path, icons_dir)
      destination_path = File.join(icons_dir, set)
      FileUtils.mkdir_p(destination_path)
      FileUtils.cp_r(Dir.glob("#{set_path}/*"), destination_path)
      say "Synced `#{set}` icons successfully.", :green
    end

    def log_icon_set_not_found(set)
      say "Icon set `#{set}` not found.", :red
      exit 1
    end
  end
end
