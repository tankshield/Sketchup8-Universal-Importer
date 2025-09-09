# Universal Importer extension for SketchUp 2017 or newer.
# Copyright: © Universal Importer Contributors
# 
# This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation, either version 3.0 of the License, or (at your option) any later version.
# 
# If you release a modified version of this program TO THE PUBLIC, the GPL requires you to MAKE THE MODIFIED SOURCE CODE
# AVAILABLE to the program's users, UNDER THE GPL.
# 
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
# of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# 
# Get a copy of the GPL here: https://www.gnu.org/licenses/gpl.html

require 'sketchup'
# require 'fileutils' # Removed for SketchUp 8 compatibility

# Universal Importer plugin namespace.
module UniversalImporter


  # Assimp wrapper.
  #
  # @see https://github.com/assimp/assimp
  module Assimp

    # Returns absolute path to Assimp executable.
    #
    # @param [Boolean] shell_escape Escape executable path with double quotes?
    # @raise [StandardError]
    #
    # @return [String]
    def self.exe(shell_escape = true)

      raise ArgumentError, 'Shell Escape must is a Boolean'\
        unless shell_escape == true || shell_escape == false

      if UniversalImporter.platform == :platform_osx

        exe_path = File.join(File.dirname(__FILE__), 'Applications', 'Assimp', 'Mac', 'assimp')

      elsif UniversalImporter.platform == :platform_win

        exe_path = File.join(File.dirname(__FILE__), 'Applications', 'Assimp', 'Win', 'assimp.exe')

      else
        raise StandardError.new(
          'Unsupported platform: ' + UniversalImporter.platform.to_s
        )
      end

      if shell_escape
        exe_path = '"' + exe_path + '"'
      end
      
      exe_path

    end

    # Ensures Assimp is executable. Relevant only to macOS.
    def self.ensure_executable

      # FileUtils.chmod replacement for SketchUp 8 compatibility
      exe_path = exe(shell_escape = false)
      # Make file executable - in Ruby 1.8.6, we use File.chmod
      # Get current permissions and add executable bit
      current_mode = File.stat(exe_path).mode
      File.chmod(current_mode | 0111, exe_path)

    end

    # Converts a 3D model.
    #
    # @param [String] working_dir
    # @param [String] in_filename
    # @param [String] out_filename
    # @param [String] log_filename
    # @raise [ArgumentError]
    #
    # @raise [StandardError]
    def self.convert_model(working_dir, in_filename, out_filename, log_filename)

      raise ArgumentError, 'Working Dir must be a String' unless working_dir.is_a?(String)
      raise ArgumentError, 'In Filename must be a String' unless in_filename.is_a?(String)
      raise ArgumentError, 'Out Filename must be a String' unless out_filename.is_a?(String)
      raise ArgumentError, 'Log Filename must be a String' unless log_filename.is_a?(String)

      log_path = File.join(working_dir, log_filename)

      # Check if working directory is a network path (UNC path starting with //)
      if working_dir =~ /^\/\//
        # For network paths, copy files to local temp directory first
        # Ruby 1.8.6 compatibility - Dir.tmpdir not available, use ENV['TEMP'] or ENV['TMP']
        temp_dir_base = ENV['TEMP'] || ENV['TMP'] || (RUBY_PLATFORM =~ /mswin|mingw|cygwin/ ? 'C:/Temp' : '/tmp')
        temp_dir = File.join(temp_dir_base, 'UniversalImporter')
        # Ensure we use proper platform-specific path separators
        if RUBY_PLATFORM =~ /mswin|mingw|cygwin/
          temp_dir.gsub!('/', '\\')
        end
        
        # Create directory recursively for SketchUp 8 compatibility with proper path handling
        if RUBY_PLATFORM =~ /mswin|mingw|cygwin/
          # Windows path handling
          parts = temp_dir.split('\\')
        else
          # Unix path handling
          parts = temp_dir.split('/')
        end
        
        current_path = ''
        parts.each do |part|
          next if part.empty?
          current_path = File.join(current_path, part)
          # Use proper path separator for the platform
          if RUBY_PLATFORM =~ /mswin|mingw|cygwin/
            current_path.gsub!('/', '\\')
          end
          Dir.mkdir(current_path) unless File.exists?(current_path)
        end
        
        local_in_path = File.join(temp_dir, in_filename)
        local_out_path = File.join(temp_dir, out_filename)
        local_log_path = File.join(temp_dir, log_filename)
        
        # Copy input file to local temp directory - FileUtils replacement for SketchUp 8
        source_path = File.join(working_dir, in_filename)
        File.open(source_path, 'rb') do |source|
          File.open(local_in_path, 'wb') do |dest|
            dest.write(source.read)
          end
        end
        
        # Escape paths with double quotes
        local_in_path = '"' + local_in_path + '"'
        local_out_path = '"' + local_out_path + '"'
        
        command = "#{exe} export #{local_in_path} #{local_out_path} -tri"
        
        # After command execution, copy results back to original location
        status = system(command)
        
        if status == true
          # Copy output file back to network location
          if File.exist?(local_out_path)
            File.open(local_out_path, 'rb') do |source|
              File.open(File.join(working_dir, out_filename), 'wb') do |dest|
                dest.write(source.read)
              end
            end
          end
          
          # Copy log file if it exists
          if File.exist?(local_log_path)
            File.open(local_log_path, 'rb') do |source|
              File.open(log_path, 'wb') do |dest|
                dest.write(source.read)
              end
            end
          end
        end
        
        # Return the status directly since we already handled the command execution
        if status != true
          if File.exist?(local_log_path)
            result = File.read(local_log_path)
          else
            result = 'No log available.'
          end

          raise StandardError.new('Command failed: ' + command + "\n\n" + result)
        end
        
        return status
      else
        # Use full paths for local directories
        full_in_path = File.join(working_dir, in_filename)
        full_out_path = File.join(working_dir, out_filename)

        # Escapes paths with double quotes, since they can contain spaces.
        full_in_path = '"' + full_in_path + '"'
        full_out_path = '"' + full_out_path + '"'

        command = "#{exe} export #{full_in_path} #{full_out_path} -tri"
        
        status = system(command)

        if status != true
          system("#{command} > #{log_filename}")

          if File.exist?(log_path)
            result = File.read(log_path)
          else
            result = 'No log available.'
          end

          raise StandardError.new('Command failed: ' + command + "\n\n" + result)
        end
      end

    end

    # If they exist: extracts embedded textures from a 3D model.
    #
    # @param [String] working_dir
    # @param [String] in_filename
    # @param [String] log_filename
    # @raise [ArgumentError]
    #
    # @raise [StandardError]
    def self.extract_textures(working_dir, in_filename, log_filename)

      raise ArgumentError, 'Working Dir must be a String' unless working_dir.is_a?(String)
      raise ArgumentError, 'In Filename must be a String' unless in_filename.is_a?(String)
      raise ArgumentError, 'Log Filename must be a String' unless log_filename.is_a?(String)

      log_path = File.join(working_dir, log_filename)

      # Use full paths instead of changing directories - better for network paths
      full_in_path = File.join(working_dir, in_filename)

      # Escapes paths with double quotes, since they can contain spaces.
      full_in_path = '"' + full_in_path + '"'

      # Use full paths to avoid directory changing issues with network paths
      command = "#{exe} extract #{full_in_path}"

      status = system(command)

      if status != true
        system("#{command} > #{log_filename}")

        if File.exist?(log_path)
          result = File.read(log_path) 
        else
          result = 'No log available.'
        end

        raise StandardError.new('Command failed: ' + command + "\n\n" + result)
      end

    end

    # If they exist: gets external texture references of a 3D model.
    #
    # @param [String] working_dir
    # @param [String] in_filename
    # @param [String] log_filename
    # @raise [ArgumentError]
    #
    # @raise [StandardError]
    #
    # @return [Array<String>]
    def self.get_texture_refs(working_dir, in_filename, log_filename)

      raise ArgumentError, 'Working Dir must be a String' unless working_dir.is_a?(String)
      raise ArgumentError, 'In Filename must be a String' unless in_filename.is_a?(String)
      raise ArgumentError, 'Log Filename must be a String' unless log_filename.is_a?(String)

      log_path = File.join(working_dir, log_filename)

      # Use full paths instead of changing directories - better for network paths
      full_in_path = File.join(working_dir, in_filename)

      # Escapes paths with double quotes, since they can contain spaces.
      full_in_path = '"' + full_in_path + '"'
      log_filename = '"' + log_filename + '"'

      texture_refs = []

      # Use full paths to avoid directory changing issues with network paths
      command = "#{exe} info #{full_in_path} > #{log_filename}"

      status = system(command)

      if status != true
        if File.exist?(log_path)
          result = File.read(log_path) 
        else
          result = 'No log available.'
        end

        raise StandardError.new('Command failed: ' + command + "\n\n" + result)
      end

      info = File.read(log_path)

      if info.include?('Texture Refs:')

        if info.include?('Named Animations:')

          tex_nfo = info.split('Texture Refs:')[1].split('Named Animations:')[0]

        else
          tex_nfo = info.split('Texture Refs:')[1].split('Node hierarchy:')[0]
        end

        # lines.each replacement for SketchUp 8 compatibility
        tex_nfo.split("\n").each do |line|

          cleaned_line = line.strip.sub("'", '').sub(/.*\K'/, '')

          # Skips references to embedded textures. Examples: *0, *1
          # start_with? replacement for SketchUp 8 compatibility
          if !cleaned_line.empty? && cleaned_line[0, 1] != '*'
            texture_refs.push(cleaned_line)
          end

        end

      end

      texture_refs.uniq

    end

    # Gets face count of a 3D model, thanks to log file output by Assimp.
    # @see Assimp.get_texture_refs
    #
    # @param [String] working_dir
    # @param [String] log_filename
    # @raise [ArgumentError]
    #
    # @raise [StandardError]
    #
    # @return [Integer]
    def self.get_face_count(working_dir, log_filename)

      raise ArgumentError, 'Working Dir must be a String' unless working_dir.is_a?(String)
      raise ArgumentError, 'Log Filename must be a String' unless log_filename.is_a?(String)

      log_path = File.join(working_dir, log_filename)

      raise "Can't get model face count because following file doesn't exist: #{log_path}"\
        unless File.exist?(log_path)

      face_count = 0
      info = File.read(log_path)

      info.split("\n").each do |line|

        if line[0, 6] == 'Faces:'
          return line.gsub(/[^0-9]/, '').to_i
        end

      end

      face_count

    end

  end

end
