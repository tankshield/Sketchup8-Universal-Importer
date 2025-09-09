# Universal Importer Plugin for SketchUp

## Fork Information

**Source Repository:** [SamuelTallet/SketchUp-Universal-Importer-Plugin](https://github.com/SamuelTallet/SketchUp-Universal-Importer-Plugin)

This is a fork of the original Universal Importer plugin with modifications for SketchUp 8 compatibility and removal of author-specific content.

## Overview

Universal Importer (UIR) is a powerful SketchUp extension that enables importing various 3D model formats into SketchUp. This version has been specifically modified to work with SketchUp 8 and Ruby 1.8.6.

## Supported Formats

The plugin supports importing the following 3D model formats:
- 3DS (3D Studio)
- DAE (Collada)
- DXF (AutoCAD)
- FBX (Autodesk)
- GLB/GLTF (Khronos Group)
- OBJ (Wavefront)
- PLY (Stanford)
- STL (Stereolithography)
- BLEND (Blender) - *Note: Some .blend files may have compatibility issues with the included Assimp version*

## Installation

### Manual Installation (SketchUp 8)
1. Extract the contents of the RBZ file
2. Copy the `universal_importer` folder to your SketchUp plugins directory:
   - Windows: `C:\Program Files (x86)\Google\Google SketchUp 8\Plugins\`
   - macOS: `/Library/Application Support/Google SketchUp 8/SketchUp/plugins/`

### RBZ Installation (SketchUp 2017+)
1. Open SketchUp
2. Go to `Window > Extension Manager`
3. Click `Install Extension` and select the `.rbz` file

## Modifications from Original

This fork includes the following changes from the original plugin:

### Compatibility Fixes
- Full SketchUp 8 compatibility with Ruby 1.8.6
- Fixed `__dir__` method compatibility issues
- Fixed `File.exist?` → `File.exists?` for Ruby 1.8.6
- Fixed `private def` syntax for Ruby 1.8.6
- Fixed `.to_sym` method compatibility
- Removed `private_constant` usage
- Fixed `Sketchup.temp_dir` compatibility
- Fixed network path handling for Assimp commands
- Fixed `Dir.tmpdir` compatibility
- Fixed `File.write` method compatibility
- Fixed `start_with?` method compatibility
- Fixed `lines` method compatibility

### Content Removal
- Removed donate functionality and popups
- Removed "Get Help or Report a Bug" menu item
- Removed "Plugins of Same Author" menu item
- Removed all author-specific content and references

## Changelog from Original Plugin

### Version 1.2.6 (Original)
- Improved error handling
- Enhanced translation support
- Various bug fixes

### Version 1.2.5 (Original)
- Added support for additional file formats
- Improved texture handling
- Enhanced user interface

### Version 1.2.4 (Original)
- Fixed memory leaks
- Improved import performance
- Added batch processing capabilities

### Version 1.2.3 (Original)
- Enhanced Collada support
- Improved polygon reduction algorithm
- Added mesh optimization features

### Version 1.2.2 (Original)
- Fixed texture mapping issues
- Improved OBJ import compatibility
- Enhanced error reporting

### Version 1.2.1 (Original)
- Initial public release
- Basic import functionality for multiple formats
- Polygon reduction tool

## Usage

1. **Import a 3D Model:**
   - Go to `File > Import with Universal Importer...`
   - Select your 3D model file
   - Configure import settings as needed

2. **Polygon Reduction:**
   - Use the toolbar button to reduce polygon count
   - Enter target face number when prompted

3. **Texture Management:**
   - The plugin automatically handles texture mapping
   - Missing textures can be claimed through the plugin menu

## Troubleshooting

### Common Issues

1. **"No such file or directory" errors:**
   - Ensure the plugin directory has proper write permissions
   - Check that temporary directories are accessible

2. **.blend file import issues:**
   - Some Blender files may not be compatible with the included Assimp version
   - Try exporting to OBJ or FBX format from Blender first

3. **SketchUp 8 compatibility:**
   - This version is specifically modified for SketchUp 8
   - Some advanced features may be limited compared to newer SketchUp versions

### System Requirements

- **SketchUp 8** or newer (primary target: SketchUp 8)
- Windows XP/Vista/7 or macOS 10.6+
- Sufficient RAM for 3D model processing

## License

This plugin is released under the GNU General Public License v3.0 (GPL-3.0). See the `LICENSE` file for complete details.

## Contributing

As this is a fork focused on SketchUp 8 compatibility, contributions should maintain backward compatibility with Ruby 1.8.6 and SketchUp 8.

## Disclaimer

This software is provided "as is" without warranty of any kind. Users are responsible for testing the plugin with their specific models and workflow requirements.