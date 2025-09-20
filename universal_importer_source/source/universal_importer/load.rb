# Universal Importer extension for SketchUp 8 or newer.
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

# SketchUp UI constants for compatibility with SketchUp 8
MB_YESNO = 4 unless defined?(MB_YESNO)
IDYES = 6 unless defined?(IDYES)
MF_CHECKED = 1 unless defined?(MF_CHECKED)
MF_UNCHECKED = 0 unless defined?(MF_UNCHECKED)

# Universal Importer plugin namespace.
module UniversalImporter
  
  # Plugin name constant
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

  # Platform detection for Ruby 1.8.6 compatibility
  def self.platform
    case RUBY_PLATFORM
    when /darwin/, /mac/
      :platform_osx
    when /mswin/, /mingw/, /cygwin/, /bccwin/, /wince/, /emx/
      :platform_win
    else
      :unknown
    end
  end

end

require 'mayo_conv'
require 'assimp'
require 'meshlab'
require 'app_observer'
require 'model_observer'
require 'menu'
require 'toolbar'

UniversalImporter::MayoConv.set_executable_path

if UniversalImporter.platform == :platform_osx
  UniversalImporter::Assimp.ensure_executable
  UniversalImporter::MeshLab.ensure_executable
end

Sketchup.add_observer(UniversalImporter::AppObserver.new)
Sketchup.active_model.add_observer(UniversalImporter::ModelObserver.new)

UniversalImporter::Menu.add
UniversalImporter::Toolbar.new.prepare.show


# Load complete.
