# frozen_string_literal: true

require 'fileutils'

require_relative 'icon_repos/tabler_sync_engine'
module RailsIcons
  class SyncGenerator < Rails::Generators::Base
    ICON_VAULT_REPO_URL = 'https://github.com/Rails-Designer/rails_icons_vault.git'

    REPOSITORIES = {
      heroicons: {
        name: 'heroicons',
        repo_url: 'https://github.com/tailwindlabs/heroicons.git',
        icon_dir: 'src/24'
      },
      tabler: {
        name: 'tabler',
        repo_url: 'https://github.com/tabler/tabler-icons.git',
        icon_dir: 'icons'
      },
      lucide: {
        name: 'lucide',
        repo_url: 'https://github.com/lucide-icons/lucide.git',
        icon_dir: 'icons'
      }
    }

    argument :libraries, type: :array, default: [], banner: 'heroicons lucide tabler'

    class_option :destination, type: :string, default: nil,
                               desc: 'Custom destination folder for icons (default: `app/assets/svg/icons/`)'

    desc 'Sync a specified icon set(s) from the Rails Icons Vault (https://github.com/Rails-Designer/rails_icons_vault)'
    source_root File.expand_path('templates', __dir__)

    def sync_icons
      icons_dir = options[:destination] || Rails.root.join('app/assets/svg/icons')
      tmp_dir = Rails.root.join('tmp/icons')

      # Prepare temp directory for sync
      FileUtils.rm_rf(tmp_dir) if Dir.exist?(tmp_dir)

      libraries.each do |set|
        repo = REPOSITORIES[set.to_sym]
        IconSyncEngine.new(tmp_dir, repo).sync

        set_path = File.join(tmp_dir, set)

        if Dir.exist?(set_path)
          destination_path = File.join(icons_dir, set)

          FileUtils.mkdir_p(destination_path)
          FileUtils.cp_r(Dir.glob("#{set_path}/*"), destination_path)

          say "Synced `#{set}` icons for set", :green
        else
          say "Icon set `#{set}` not found", :red

          exit 1
        end
      end

      # Clean up temp directory
      FileUtils.rm_rf(tmp_dir)

      say 'Icons synced successfully', :green
    end

    private

    def oldsync
      icons_dir = options[:destination] || Rails.root.join('app/assets/svg/icons')
      tmp_dir = Rails.root.join('tmp/icons')

      FileUtils.rm_rf(tmp_dir) if Dir.exist?(tmp_dir)
      FileUtils.mkdir_p(tmp_dir)

      if system("git clone '#{ICON_VAULT_REPO_URL}' '#{tmp_dir}'")
        say 'Repository cloned successfully.', :green
      else
        say 'Failed to clone repository.', :red

        exit 1
      end

      libraries.each do |set|
        set_path = File.join(tmp_dir, 'icons', set)

        if Dir.exist?(set_path)
          destination_path = File.join(icons_dir, set)

          FileUtils.mkdir_p(destination_path)
          FileUtils.cp_r(Dir.glob("#{set_path}/*"), destination_path)

          say "Synced `#{set}` icons for set", :green
        else
          say "Icon set `#{set}` not found", :red

          exit 1
        end
      end

      FileUtils.rm_rf(tmp_dir)

      say 'Icons synced successfully', :green
    end
  end
end
