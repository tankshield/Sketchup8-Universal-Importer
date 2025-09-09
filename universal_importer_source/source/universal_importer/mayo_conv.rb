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

# Universal Importer plugin namespace.
module UniversalImporter


  # A wrapper for the Mayo Conv(erter) CLI.
  #
  # @see https://github.com/fougue/mayo
  module MayoConv

    # Absolute path to Mayo Conv executable.
    #
    # @type [String, nil]
    @@executable_path = nil

    # Sets absolute path to Mayo Conv executable.
    # Ensures it has correct permission on macOS.
    #
    # @raise [RuntimeError]
    def self.set_executable_path
      app_dir = File.join(File.dirname(__FILE__), 'Applications', 'Mayo')
  
      if UniversalImporter.platform == :platform_osx
        @@executable_path = File.join(app_dir, 'Mac', 'mayo-conv')
        # FileUtils.chmod replacement for SketchUp 8 compatibility
        # Make file executable - in Ruby 1.8.6, we use File.chmod
        # Get current permissions and add executable bit
        current_mode = File.stat(@@executable_path).mode
        File.chmod(current_mode | 0111, @@executable_path)
      elsif UniversalImporter.platform == :platform_win
        @@executable_path = File.join(app_dir, 'Win', 'mayo-conv.exe')
      else
        raise ('unsupported platform: ' + UniversalImporter.platform.to_s)
      end
    end

    # Exports a 3D model file with Mayo Conv.
    #
    # @param [String] input_model_path Absolute
    # @param [String] output_model_path Absolute
    # @raise [ArgumentError]
    #
    # @raise [RuntimeError]
    def self.export_model(input_model_path, output_model_path)
      raise ArgumentError, 'input model path must be a string' \
        unless input_model_path.is_a?(String)
      raise ArgumentError, 'output model path must be a string' \
        unless output_model_path.is_a?(String)

      raise 'executable path must be set' if @@executable_path.nil?

      command = '"' + @@executable_path + '"'
      command += ' --export "' + output_model_path + '"'
      command += ' "' + input_model_path + '"'

      status = system(command)

      raise ('command failed: ' + command) unless true == status
    end

    # Gets face count from a Wavefront OBJ file output by Mayo Conv.
    #
    # @param [String] obj_path Absolute path to the OBJ file.
    # @raise [ArgumentError]
    #
    # @return [Integer, String] Face count found in the OBJ file, otherwise "n".
    def self.get_face_count(obj_path)
      raise ArgumentError, 'obj_path must be a string' \
        unless obj_path.is_a?(String)

      File.foreach(obj_path) do |line|
        return $1.to_i if line =~ /^#\s+Faces:\s+(\d+)/
      end

      'n'
    end
    
  end

end