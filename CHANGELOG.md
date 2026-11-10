# Changelog

## v1.0.4 — 2026-11-10

- Added a minimap button to open or close the character export window with a left-click.
- Added dragging around the minimap with a saved position, including support for square minimaps.
- Added `/fcontext minimap` to hide or show the button; visibility is saved between sessions.
- Added an English tooltip explaining the controls. No additional addon libraries are required.
- Updated all 13 READMEs and added six minimap interaction and persistence tests.

Validation: 23 simulated Lua 5.1 tests passed. In-game verification of this version is still pending.

## v1.0.3 — 2026-11-10

- Fixed an invalid scroll-frame type and template name that stopped the export window from loading completely.
- Restored the correct WoW scroll methods used when displaying, scrolling, and selecting the report.
- Corrected the simulated UI client so invalid frame types and template names cause test failures.
- Added regression checks for the report area, footer buttons, and selecting long reports.

Validation: 17 simulated Lua 5.1 tests passed. The corrected version still requires in-game verification.

To update, close WoW, replace the existing `ForeverContext` addon folder with the folder from the new ZIP, restart the game, and run `/fcontext`.
