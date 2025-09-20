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

      # Check if working directory is a network path (UNC path starting with // or mapped drive letter)
      # For Windows: UNC paths start with //, mapped drives are like Z:\
      # For network paths, copy files to local temp directory first to avoid Assimp issues
      is_network_path = false
      
      if RUBY_PLATFORM =~ /mswin|mingw|cygwin/
        # Windows: check for UNC paths (//server/share) or mapped drives (Z:\)
        is_network_path = (working_dir =~ /^\/\//) || (working_dir =~ /^[A-Za-z]:\\/ && working_dir =~ /^[A-Za-z]:\\[^\\]/)
      else
        # macOS/Linux: only UNC paths
        is_network_path = (working_dir =~ /^\/\//)
      end
      
      if is_network_path
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
        # Check if source file exists before trying to copy
        unless File.exists?(source_path)
          raise StandardError.new("Source file does not exist: #{source_path}")
        end
        
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
          if File.exists?(local_out_path)
            File.open(local_out_path, 'rb') do |source|
              File.open(File.join(working_dir, out_filename), 'wb') do |dest|
                dest.write(source.read)
              end
            end
          end
          
          # Copy log file if it exists
          if File.exists?(local_log_path)
            File.open(local_log_path, 'rb') do |source|
              File.open(log_path, 'wb') do |dest|
                dest.write(source.read)
              end
            end
          end
        end
        
        # Return the status directly since we already handled the command execution
        if status != true
          if File.exists?(local_log_path)
            result = File.read(local_log_path)
          else
            result = 'No log available.'
          end

          # Check for XML parsing errors in DAE files for network paths too
          # Ruby 1.8.6 compatible end_with? replacement
          is_dae_file = in_filename.length >= 4 && in_filename.downcase[in_filename.length-4, 4] == '.dae'
          if result.include?('malformed XML') && is_dae_file
            enhanced_result = result + "\n\nDAE FILE XML ERROR:\n" +
              "This Collada (.dae) file contains malformed XML that Assimp cannot parse.\n" +
              "This is typically caused by:\n" +
              "1. Missing or mismatched XML tags\n" +
              "2. Invalid XML characters or encoding issues\n" +
              "3. File corruption during export or transfer\n\n" +
              "SOLUTIONS:\n" +
              "1. Try re-exporting the DAE file from the original software\n" +
              "2. Open the file in a text editor and check for XML syntax errors\n" +
              "3. Use an XML validator tool to identify and fix issues\n" +
              "4. Export to a different format like OBJ or FBX instead"
            
            raise StandardError.new('Command failed: ' + command + "\n\n" + enhanced_result)
          else
            raise StandardError.new('Command failed: ' + command + "\n\n" + result)
          end
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

          if File.exists?(log_path)
            result = File.read(log_path)
          else
            result = 'No log available.'
          end

          # Check for specific Blender format compatibility issues
          if result.include?('BlenderDNA: Expected TYPE field')
            # This is a known issue with older Assimp versions and newer Blender files
            # Provide specific guidance for Blender file issues
            enhanced_result = result + "\n\nBLENDER FILE COMPATIBILITY ISSUE:\n" +
              "The included Assimp version cannot read this Blender (.blend) file.\n" +
              "This is likely because the file was created with a newer version of Blender.\n\n" +
              "SOLUTIONS:\n" +
              "1. Open the file in Blender and export to OBJ or FBX format instead\n" +
              "2. Use an older version of Blender (2.7x or earlier) to export\n" +
              "3. The file may be corrupted or use unsupported Blender features"
            
            raise StandardError.new('Command failed: ' + command + "\n\n" + enhanced_result)
          # Check for XML parsing errors in DAE files
          # Ruby 1.8.6 compatible end_with? replacement
          is_dae_file = in_filename.length >= 4 && in_filename.downcase[in_filename.length-4, 4] == '.dae'
          elsif result.include?('malformed XML') && is_dae_file
            enhanced_result = result + "\n\nDAE FILE XML ERROR:\n" +
              "This Collada (.dae) file contains malformed XML that Assimp cannot parse.\n" +
              "This is typically caused by:\n" +
              "1. Missing or mismatched XML tags\n" +
              "2. Invalid XML characters or encoding issues\n" +
              "3. File corruption during export or transfer\n\n" +
              "SOLUTIONS:\n" +
              "1. Try re-exporting the DAE file from the original software\n" +
              "2. Open the file in a text editor and check for XML syntax errors\n" +
              "3. Use an XML validator tool to identify and fix issues\n" +
              "4. Export to a different format like OBJ or FBX instead"
            
            raise StandardError.new('Command failed: ' + command + "\n\n" + enhanced_result)
          else
            raise StandardError.new('Command failed: ' + command + "\n\n" + result)
          end
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

      # Check if working directory is a network path (UNC path starting with // or mapped drive letter)
      is_network_path = false
      
      if RUBY_PLATFORM =~ /mswin|mingw|cygwin/
        # Windows: check for UNC paths (//server/share) or mapped drives (Z:\)
        is_network_path = (working_dir =~ /^\/\//) || (working_dir =~ /^[A-Za-z]:\\/ && working_dir =~ /^[A-Za-z]:\\[^\\]/)
      else
        # macOS/Linux: only UNC paths
        is_network_path = (working_dir =~ /^\/\//)
      end
      
      if is_network_path
        # For network paths, copy files to local temp directory first
        temp_dir_base = ENV['TEMP'] || ENV['TMP'] || (RUBY_PLATFORM =~ /mswin|mingw|cygwin/ ? 'C:/Temp' : '/tmp')
        temp_dir = File.join(temp_dir_base, 'UniversalImporter')
        if RUBY_PLATFORM =~ /mswin|mingw|cygwin/
          temp_dir.gsub!('/', '\\')
        end
        
        # Create directory recursively
        if RUBY_PLATFORM =~ /mswin|mingw|cygwin/
          parts = temp_dir.split('\\')
        else
          parts = temp_dir.split('/')
        end
        
        current_path = ''
        parts.each do |part|
          next if part.empty?
          current_path = File.join(current_path, part)
          if RUBY_PLATFORM =~ /mswin|mingw|cygwin/
            current_path.gsub!('/', '\\')
          end
          Dir.mkdir(current_path) unless File.exists?(current_path)
        end
        
        local_in_path = File.join(temp_dir, in_filename)
        local_log_path = File.join(temp_dir, log_filename)
        
        # Copy input file to local temp directory
        source_path = File.join(working_dir, in_filename)
        unless File.exists?(source_path)
          raise StandardError.new("Source file does not exist: #{source_path}")
        end
        
        File.open(source_path, 'rb') do |source|
          File.open(local_in_path, 'wb') do |dest|
            dest.write(source.read)
          end
        end
        
        # Escape paths with double quotes
        local_in_path = '"' + local_in_path + '"'
        
        command = "#{exe} extract #{local_in_path}"
        
        status = system(command)
        
        if status != true
          system("#{command} > #{local_log_path}")
          
          if File.exists?(local_log_path)
            result = File.read(local_log_path)
          else
            result = 'No log available.'
          end

          # Check for specific Blender format compatibility issues
          if result.include?('BlenderDNA: Expected TYPE field')
            enhanced_result = result + "\n\nBLENDER FILE COMPATIBILITY ISSUE DETECTED\n" +
              "The Assimp library cannot read this Blender file format.\n" +
              "Please try exporting from Blender to OBJ or FBX format first."
            
            raise StandardError.new('Command failed: ' + command + "\n\n" + enhanced_result)
          else
            raise StandardError.new('Command failed: ' + command + "\n\n" + result)
          end
        end
      else
        # Use full paths instead of changing directories - better for network paths
        full_in_path = File.join(working_dir, in_filename)

        # Escapes paths with double quotes, since they can contain spaces.
        full_in_path = '"' + full_in_path + '"'

        # Use full paths to avoid directory changing issues with network paths
        command = "#{exe} extract #{full_in_path}"

        status = system(command)

        if status != true
          system("#{command} > #{log_filename}")

          if File.exists?(log_path)
            result = File.read(log_path)
          else
            result = 'No log available.'
          end

          # Check for specific Blender format compatibility issues
          if result.include?('BlenderDNA: Expected TYPE field')
            enhanced_result = result + "\n\nBLENDER FILE COMPATIBILITY ISSUE DETECTED\n" +
              "The Assimp library cannot read this Blender file format.\n" +
              "Please try exporting from Blender to OBJ or FBX format first."
            
            raise StandardError.new('Command failed: ' + command + "\n\n" + enhanced_result)
          else
            raise StandardError.new('Command failed: ' + command + "\n\n" + result)
          end
        end
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

      # Check if working directory is a network path (UNC path starting with // or mapped drive letter)
      is_network_path = false
      
      if RUBY_PLATFORM =~ /mswin|mingw|cygwin/
        # Windows: check for UNC paths (//server/share) or mapped drives (Z:\)
        is_network_path = (working_dir =~ /^\/\//) || (working_dir =~ /^[A-Za-z]:\\/ && working_dir =~ /^[A-Za-z]:\\[^\\]/)
      else
        # macOS/Linux: only UNC paths
        is_network_path = (working_dir =~ /^\/\//)
      end
      
      texture_refs = []
      
      if is_network_path
        # For network paths, copy files to local temp directory first
        temp_dir_base = ENV['TEMP'] || ENV['TMP'] || (RUBY_PLATFORM =~ /mswin|mingw|cygwin/ ? 'C:/Temp' : '/tmp')
        temp_dir = File.join(temp_dir_base, 'UniversalImporter')
        if RUBY_PLATFORM =~ /mswin|mingw|cygwin/
          temp_dir.gsub!('/', '\\')
        end
        
        # Create directory recursively
        if RUBY_PLATFORM =~ /mswin|mingw|cygwin/
          parts = temp_dir.split('\\')
        else
          parts = temp_dir.split('/')
        end
        
        current_path = ''
        parts.each do |part|
          next if part.empty?
          current_path = File.join(current_path, part)
          if RUBY_PLATFORM =~ /mswin|mingw|cygwin/
            current_path.gsub!('/', '\\')
          end
          Dir.mkdir(current_path) unless File.exists?(current_path)
        end
        
        local_in_path = File.join(temp_dir, in_filename)
        local_log_path = File.join(temp_dir, log_filename)
        
        # Copy input file to local temp directory
        source_path = File.join(working_dir, in_filename)
        unless File.exists?(source_path)
          raise StandardError.new("Source file does not exist: #{source_path}")
        end
        
        File.open(source_path, 'rb') do |source|
          File.open(local_in_path, 'wb') do |dest|
            dest.write(source.read)
          end
        end
        
        # Escape paths with double quotes
        local_in_path = '"' + local_in_path + '"'
        local_log_filename = '"' + File.basename(local_log_path) + '"'

        command = "#{exe} info #{local_in_path} > #{local_log_filename}"

        status = system(command)

        if status != true
          if File.exists?(local_log_path)
            result = File.read(local_log_path)
          else
            result = 'No log available.'
          end

          # Check for specific Blender format compatibility issues
          if result.include?('BlenderDNA: Expected TYPE field')
            enhanced_result = result + "\n\nBLENDER FILE FORMAT ISSUE\n" +
              "Unable to extract textures due to Blender file format incompatibility."
            
            raise StandardError.new('Command failed: ' + command + "\n\n" + enhanced_result)
          else
            raise StandardError.new('Command failed: ' + command + "\n\n" + result)
          end
        end

        info = File.read(local_log_path)
      else
        # Use full paths instead of changing directories - better for network paths
        full_in_path = File.join(working_dir, in_filename)

        # Escapes paths with double quotes, since they can contain spaces.
        full_in_path = '"' + full_in_path + '"'
        log_filename = '"' + log_filename + '"'

        # Use full paths to avoid directory changing issues with network paths
        command = "#{exe} info #{full_in_path} > #{log_filename}"

        status = system(command)

        if status != true
          if File.exists?(log_path)
            result = File.read(log_path)
          else
            result = 'No log available.'
          end

          # Check for specific Blender format compatibility issues
          if result.include?('BlenderDNA: Expected TYPE field')
            enhanced_result = result + "\n\nBLENDER FILE FORMAT ISSUE\n" +
              "Unable to extract textures due to Blender file format incompatibility."
            
            raise StandardError.new('Command failed: ' + command + "\n\n" + enhanced_result)
          else
            raise StandardError.new('Command failed: ' + command + "\n\n" + result)
          end
        end

        info = File.read(log_path)
      end

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
        unless File.exists?(log_path)

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
