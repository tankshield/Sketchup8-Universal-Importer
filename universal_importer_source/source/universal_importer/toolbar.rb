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

# require 'fileutils' # Removed for SketchUp 8 compatibility
require 'sketchup'
require 'poly_reduction'

# Universal Importer plugin namespace.
module UniversalImporter


  # Toolbar of Universal Importer plugin.
  class Toolbar

    # Absolute path to icons.
    ICONS_PATH = File.join(File.dirname(__FILE__), 'Toolbar Icons').freeze

    # private_constant not available in Ruby 1.8.6 - removed for compatibility

    # Initializes instance.
    def initialize

      @toolbar = UI::Toolbar.new(PLUGIN_NAME)

    end

    # Returns extension of icons depending on platform...
    #
    # @return [String] Extension. PDF (Mac) or SVG (Win).
    def icon_extension

      if UniversalImporter.platform == :platform_osx
        '.pdf'
      else
        '.svg'
      end

    end

    # Adds "Reduce Polygon Count..." command.
    def add_reduce_polygon_count

      command = UI::Command.new('rpc') do
        PolyReduction.last = PolyReduction.new
      end

      command.small_icon = File.join(ICONS_PATH, 'rpc'.concat(icon_extension))
      command.large_icon = File.join(ICONS_PATH, 'rpc'.concat(icon_extension))
      command.tooltip = TRANSLATE['Reduce Polygon Count...']

      @toolbar.add_item(command)

    end

    # Prepares.
    #
    # @return [UI::Toolbar] Toolbar instance.
    def prepare

      add_reduce_polygon_count

      @toolbar

    end

    # Make methods private
    private :icon_extension, :add_reduce_polygon_count

  end

end
