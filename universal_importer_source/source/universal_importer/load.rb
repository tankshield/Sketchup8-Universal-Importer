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
require 'universal_importer/mayo_conv'
require 'universal_importer/assimp'
require 'universal_importer/meshlab'
require 'universal_importer/app_observer'
require 'universal_importer/model_observer'
require 'universal_importer/menu'
require 'universal_importer/toolbar'

# Universal Importer plugin namespace.
module UniversalImporter

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

  MayoConv.set_executable_path

  if self.platform == :platform_osx
    Assimp.ensure_executable
    MeshLab.ensure_executable
  end

  Sketchup.add_observer(AppObserver.new)
  Sketchup.active_model.add_observer(ModelObserver.new)

  Menu.add
  Toolbar.new.prepare.show


  # Load complete.

end
