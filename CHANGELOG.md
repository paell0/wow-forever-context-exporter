# Changelog

## v1.0.3 — 2026-11-10

- Fixed an invalid scroll-frame type and template name that stopped the export window from loading completely.
- Restored the correct WoW scroll methods used when displaying, scrolling, and selecting the report.
- Corrected the simulated UI client so invalid frame types and template names cause test failures.
- Added regression checks for the report area, footer buttons, and selecting long reports.

Validation: 17 simulated Lua 5.1 tests passed. The corrected version still requires in-game verification.

To update, close WoW, replace the existing `ForeverContext` addon folder with the folder from the new ZIP, restart the game, and run `/fcontext`.
