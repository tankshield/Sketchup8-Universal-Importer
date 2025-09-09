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

  # Things shared by imports, such as count of processed imports.
  module Imports

    # Absolute path to "imports.count" file.
    # @type [String]
    @@count_file = File.join(File.dirname(__FILE__), 'User Data', 'imports.count')

    # Increments "imports.count" file.
    def self.increment_counter
      # File.write replacement for SketchUp 8 compatibility
      unless File.exist?(@@count_file)
        File.open(@@count_file, 'w') { |f| f.write('0') }
      end
      counter = File.read(@@count_file).to_i

      counter += 1
      # File.write replacement for SketchUp 8 compatibility
      File.open(@@count_file, 'w') { |f| f.write(counter.to_s) }
    end

    # Gets imports count.
    # @return [Integer]
    def self.count
      return 0 unless File.exist?(@@count_file)

      File.read(@@count_file).to_i
    end

  end

end
