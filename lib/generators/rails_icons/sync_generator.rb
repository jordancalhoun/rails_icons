require 'fileutils'

module RailsIcons
  class SyncGenerator < Rails::Generators::Base
    ICON_VAULT_REPO_URL = 'https://github.com/Rails-Designer/rails_icons_vault.git'.freeze

    argument :libraries, type: :array, default: [], banner: 'heroicons lucide tabler'

    class_option :destination, type: :string, default: nil,
                               desc: 'Custom destination folder for icons (default: `app/assets/svg/icons/`)'

    desc 'Sync a specified icon set(s) from the Rails Icons Vault (https://github.com/Rails-Designer/rails_icons_vault)'
    source_root File.expand_path('templates', __dir__)

    def sync_icons
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
