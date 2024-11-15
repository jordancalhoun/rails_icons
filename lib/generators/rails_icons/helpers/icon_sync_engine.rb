# frozen_string_literal: true

require "fileutils"

module RailsIcons
  # Pulls the latest set of icon svgs from the given repository
  class IconSyncEngine < Rails::Generators::Base
    def initialize(temp_dir, repository)
      super
      @temp_dir = File.join(temp_dir, repository[:name])
      @repository = repository
    end

    def sync
      clone_repo
      filter_icons_from_repo
      remove_non_svg_files
    rescue => e
      say "Failed to sync icons: #{e.message}", :red
      clean_up
      raise
    end

    private

    # If sync fails offer to clean up any files that were downloaded
    def clean_up
      if yes?("Do you want to remove the temp files? ('#{@temp_dir}')")
        say "Cleaning up..."
        FileUtils.rm_rf(@temp_dir)
      else
        say("Leaving files at: '#{@temp_dir}'")
      end
    end

    # Clone the given repo into temp_dir/<Icon set name>
    def clone_repo
      raise "Failed to clone Icon repository" unless system("git clone '#{@repository[:repo_url]}' '#{@temp_dir}'")
      say "#{@repository[:name]} repository cloned successfully.", :green
    end

    def filter_icons_from_repo
      # Store the list of current items in the root directory for reference
      # when deleting files later
      original_temp_dir_items = Dir.entries(@temp_dir) - [ ".", ".." ]

      @repository[:variants].each do |folder_name, repo_path|
        source_dir = File.join(@temp_dir, repo_path)
        dest_dir = File.join(@temp_dir, folder_name.to_s)

        raise "Failed to find the icons directory: '#{source_dir}'" unless Dir.exist?(source_dir)

        move_icons(source_dir, dest_dir)
      end

      # Remove everything in the root directory (@temp_dir) that was originally there
      # TODO: Edge case: The variant for the icons name is the same as a folder that already exists, this will delete the variant on clean up.  Update method check against the variant directories and ignore them on removal.
      remove_files_and_folders(original_temp_dir_items)
      say "Icon variants filtered successfully.", :green
    end

    def move_icons(source_dir, dest_dir)
      # Move all contents of the variant source directory to the parent directory/variant (temp_dir)
      Dir.foreach(source_dir) do |item|
        next if [ ".", ".." ].include?(item) # Skip special directories
        item_path = File.join(source_dir, item)

        # Ensure the variant directory exists, create it if needed
        FileUtils.mkdir_p(dest_dir)

        # Move the item to the variants directory at the root level
        FileUtils.mv(item_path, dest_dir)
      end
    end

    def remove_files_and_folders(dir_items)
      # Remove everything in the root directory (@temp_dir) that was originally there
      dir_items.each do |item|
        item_path = File.join(@temp_dir, item)
        if File.directory?(item_path)
          FileUtils.rm_rf(item_path) # Remove directory and its contents
        else
          FileUtils.rm(item_path) # Remove file
        end
      end
    end

    # Some repositories have .json files inside their icon directories
    # Remove everything but the .svg files
    def remove_non_svg_files
      Dir.glob("#{@temp_dir}/**/*") do |file|
        if File.file?(file) && File.extname(file) != ".svg"
          FileUtils.rm(file) # Remove the file
        end
      end

      say "Non-SVG files removed successfully.", :green
    end
  end
end
