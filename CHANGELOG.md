# Changelog

All notable changes to BetterTransmog will be documented in this file.

## [1.1.0] - 2026-01-05

### Added
- **Settings Panel**: New in-game settings accessible via Options → AddOns → BetterTransmog
  - Adjustable collection frame model count (18-30 items)
  - Adjustable sets frame model count (8-12 sets)
  - Character model width percentage slider
  - Reload UI prompt when settings are changed
- **Account-wide Settings**: Preferences are saved per-account using SavedVariables
- **Dynamic Sets Grid Layout**: Sets frame now intelligently positions models based on available space
  - Automatically adjusts grid rows/columns during resize
  - Maintains proper spacing matching Blizzard's design (13px horizontal, 14px vertical)
  - Creates additional set models on-demand (8-12 sets)

### Fixed
- Fixed flickering during resize by splitting positioning and refresh logic
- Fixed circular anchor errors when opening Collections Journal
- Fixed nil reference errors for transmogLocation and activeCategory
- Fixed filteredVisualsList initialization
- Improved frame initialization to prevent edge case crashes

### Performance
- Optimized resize handler to only update geometry during drag
- Content refresh (pagination, visuals) now occurs only after resize completes
- Reduced unnecessary model updates during frame resizing

### Technical
- Converted ResizeButton to class pattern with EventFrame mixin
- Fixed EventFrame to properly pass event names to callbacks
- Improved code organization and consistency across frame handlers
- Enhanced error handling and validation

---

## [1.0.0] - Initial Release

### Added
- Resizable Transmog frame
- Resizable Collections Journal frame
- Custom frame layout system
- LibRu framework integration
