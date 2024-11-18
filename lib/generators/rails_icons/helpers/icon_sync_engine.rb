# frozen_string_literal: true

require "fileutils"

module RailsIcons
  # Pulls the latest set of icon svgs from the given repository
  class IconSyncEngine < Rails::Generators::Base
    def initialize(temp_icons_directory, set)
      super
      @temp_set_directory = File.join(temp_icons_directory, set[:name])
      @set = set
    end

    def sync
      clone_set
      filter_variants_from_directory
      remove_non_svg_files
    rescue => e
      say "Failed to sync icons: #{e.message}", :red
      clean_up
      raise
    end

    private

    def special_directories
      [ ".", ".." ]
    end

    # Clone the given set into temp_directory/<icon set name>
    def clone_set
      raise "Failed to clone repository" unless system("git clone '#{@set[:url]}' '#{@temp_set_directory}'")
      say "#{@set[:name]} repository cloned successfully.", :green
    end

    def filter_variants_from_directory
      # Store the list of current items for reference when deleting files later
      original_set_list = Dir.entries(@temp_set_directory) - special_directories

      @set[:variants].each do |variant_name, variant_source_path|
        source = File.join(@temp_set_directory, variant_source_path)
        destination = File.join(@temp_set_directory, variant_name.to_s)

        # Whitelist variant directory if present in original_set_list to prevent deletion
        original_set_list.delete(variant_name.to_s)

        raise "Failed to find the icons directory: '#{source}'" unless Dir.exist?(source)

        move_icons(source, destination)
      end

      remove_files_and_folders(original_set_list)
      say "Icon variants filtered successfully.", :green
    end

    def move_icons(source, destination)
      # Move all contents of the variant source directory to the parent directory/variant (temp_dir)
      Dir.foreach(source) do |item|
        next if special_directories.include?(item)
        item_path = File.join(source, item)

        # Ensure the variant directory exists, create it if needed
        FileUtils.mkdir_p(destination)

        # Move the item to the variants directory at the root level
        FileUtils.mv(item_path, destination)
      end
    end

    def remove_files_and_folders(paths)
      paths.each do |path|
        full_path = File.join(@temp_set_directory, path)

        if File.directory?(full_path)
          FileUtils.rm_rf(full_path) # Remove directory and its contents
        else
          FileUtils.rm(full_path) # Remove file
        end
      end
    end

    # Some repositories have .json files inside their icon directories
    # Remove everything but the .svg files
    def remove_non_svg_files
      Dir.glob("#{@temp_set_directory}/**/*") do |file|
        if File.file?(file) && File.extname(file) != ".svg"
          FileUtils.rm(file) # Remove the file
        end
      end

      say "Non-SVG files removed successfully.", :green
    end

    # If sync fails offer to clean up any files that were downloaded
    def clean_up
      if yes?("Do you want to remove the temp files? ('#{@temp_set_directory}')")
        say "Cleaning up..."
        FileUtils.rm_rf(@temp_set_directory)
      else
        say("Leaving files at: '#{@temp_set_directory}'")
      end
    end
  end
end
