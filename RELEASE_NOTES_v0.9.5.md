# Universal Importer v0.9.5 Beta Release Notes

## 🚀 Overview
Universal Importer v0.9.5-Beta-SU8 represents a significant update from v0.9.2-Beta-SU8, focusing on enhanced compatibility, improved error handling, and better user experience for SketchUp 8 users.

## 📋 Version Information
- **Current Version**: v0.9.5-Beta-SU8
- **Previous Version**: v0.9.2-Beta-SU8
- **Target Platform**: SketchUp 8 + Ruby 1.8.6
- **Release Type**: Beta

## 🎯 What's New Since v0.9.2

### ✨ Major Enhancements

#### 1. **Ruby 1.8.6 Full Compatibility**
- Fixed all `File.exist?` → `File.exists?` method calls throughout codebase
- Replaced `start_with?` methods with Ruby 1.8.6 compatible string indexing patterns
- Converted `lines` method usage to `split("\n")` for compatibility
- Removed all `__dir__` method usage
- Fixed private method syntax compatibility issues
- Enhanced file system operation compatibility

#### 2. **Enhanced Error Handling System**
- **Blender File Support**: Added comprehensive error handling for "BlenderDNA: Expected TYPE field" errors
- **DAE XML Support**: New error detection for "Unable to read file, malformed XML" in Collada files
- **User-Friendly Messages**: Transformed technical errors into actionable guidance with solutions

#### 3. **Network Path Support**
- Added support for mapped network drives (Z:\) in addition to UNC paths
- Enhanced network path detection across all Assimp methods
- Implemented smart file copying strategy: files copied to local temp directory for processing, then results copied back to network location

#### 4. **Proactive User Warnings**
- Added warning dialog before importing Blender (.blend) files to prevent unexpected errors
- Improved user experience with clear guidance on file format limitations

### 🐛 Bug Fixes
- Fixed RBZ file structure issues (files now properly organized at top level)
- Resolved network path accessibility problems
- Addressed various Ruby 1.8.6 syntax compatibility issues
- Fixed error message display and logging consistency

### 📁 File Format Support Improvements
- **.blend files**: Enhanced compatibility messaging and user guidance
- **.dae files**: Added XML validation error handling with repair suggestions
- **Network files**: Full support for files on mapped drives and UNC paths
- **All formats**: Improved error recovery and user communication

## 🛠️ Technical Details

### Compatibility Matrix
| Feature | v0.9.2 | v0.9.5 | Improvement |
|---------|--------|--------|-------------|
| Ruby 1.8.6 | Partial | Full | ✅ Complete compatibility |
| Network Paths | UNC only | UNC + Mapped drives | ✅ Expanded support |
| Error Handling | Basic | Enhanced with guidance | ✅ User-friendly |
| Blender Files | Error-prone | Guided experience | ✅ Proactive warnings |
| DAE Files | Technical errors | Actionable solutions | ✅ Better UX |

### Error Handling Enhancements
- **Blender Files**: Specific guidance for version compatibility issues
- **DAE Files**: XML validation error detection with repair options
- **Network Files**: Automatic local processing with transparent file handling
- **All Errors**: Context-specific solutions rather than technical messages

## 📦 Installation
1. Download `Universal_Importer_v0.9.5-Beta-SU8.rbz`
2. Install via SketchUp 8 Extension Manager
3. Restart SketchUp if prompted

## ⚠️ Known Limitations
- Blender file support limited by included Assimp version capabilities
- Very large network files may experience slower processing due to copy operations
- Some edge case file format variations may still require manual conversion

## 🔄 Upgrade Instructions
Users upgrading from v0.9.2 should:
1. Uninstall the previous version
2. Install v0.9.5
3. No data migration required - all settings preserved

## 🙏 Acknowledgments
Special thanks to the SketchUp community for feedback and bug reports that helped shape this release.

---
**Release Date**: September 2025  
**Compatibility**: SketchUp 8 + Ruby 1.8.6  
**Status**: Beta - Community Testing  
**Support**: GitHub Issues & Community Forum