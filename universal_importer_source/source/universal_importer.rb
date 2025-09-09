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
# require 'extensions' # Removed for SketchUp 8 compatibility - extensions module doesn't exist in SU8

# SketchUp 8 compatibility - remove version check
# raise 'Universal Importer plugin requires at least SketchUp 2017.'\
#   unless Sketchup.version.to_i >= 17

# Universal Importer plugin namespace.
module UniversalImporter

  VERSION = '1.2.6'

  # SketchUp 8 compatibility - simple translation fallback
  PLUGIN_NAME = 'Universal Importer'
  
  # Simple translation hash for SketchUp 8 compatibility
  TRANSLATE = {
    'Import with' => 'Import with',
    'Import a 3D Model...' => 'Import a 3D Model...',
    'Propose Polygon Reduction' => 'Propose Polygon Reduction',
    'Claim Missing Textures' => 'Claim Missing Textures',
    'Select a 3D Model' => 'Select a 3D Model',
    '3D Models' => '3D Models',
    'Source model units' => 'Source model units',
    'Scaling' => 'Scaling',
    'Select a Texture for Material:' => 'Select a Texture for Material:',
    'Images' => 'Images',
    'Model has' => 'Model has',
    'faces' => 'faces',
    'Reduce polygon count?' => 'Reduce polygon count?',
    'Target face number' => 'Target face number',
    'Polygon Reduction' => 'Polygon Reduction',
    'Selection must be empty!' => 'Selection must be empty!',
    'Current face count:' => 'Current face count:',
    'Face count before reduction:' => 'Face count before reduction:',
    'Face count after reduction:' => 'Face count after reduction:',
    'Reduce Polygon Count...' => 'Reduce Polygon Count...',
    'Rotate Component' => 'Rotate Component',
    'Change Component Units' => 'Change Component Units',
  }

  # SketchUp 8 compatibility - direct loading instead of extension registration
  # In SketchUp 8, we need to load the plugin directly
  begin
    require 'universal_importer/load'
  rescue LoadError => e
    # Show error message in SketchUp 8 (puts won't be visible)
    UI.messagebox("Universal Importer Plugin Error: #{e.message}\n\nPlease check the plugin installation.")
  end

end
