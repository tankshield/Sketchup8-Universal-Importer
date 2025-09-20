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
require 'import'

# Universal Importer plugin namespace.
module UniversalImporter

  # Connects Universal Importer plugin menu to SketchUp user interface.
  module Menu

    # Adds menu.
    def self.add

      file_menu = UI.menu('File')

      file_menu.add_item(UniversalImporter::TRANSLATE['Import with'] + ' ' + UniversalImporter::PLUGIN_NAME + '...') do
        Import.last = Import.new
      end

      plugin_menu = UI.menu('Plugins').add_submenu(UniversalImporter::PLUGIN_NAME)

      plugin_menu.add_item(UniversalImporter::TRANSLATE['Import a 3D Model...']) do
        Import.last = Import.new
      end

      ppr_menu_item = plugin_menu.add_item(UniversalImporter::TRANSLATE['Propose Polygon Reduction']) do
        Import.propose_polygon_reduction = !Import.propose_polygon_reduction?
      end

      plugin_menu.set_validation_proc(ppr_menu_item) do
        Import.propose_polygon_reduction? ? MF_CHECKED : MF_UNCHECKED
      end

      cmt_menu_item = plugin_menu.add_item(UniversalImporter::TRANSLATE['Claim Missing Textures']) do
        Import.claim_missing_textures = !Import.claim_missing_textures?
      end

      plugin_menu.set_validation_proc(cmt_menu_item) do
        Import.claim_missing_textures? ? MF_CHECKED : MF_UNCHECKED
      end


    end

  end

end
