# Changelog

## v1.0.5 — 2026-11-10

- Fixed phantom off-hand damage and attack speed when no off-hand weapon is equipped. Shields are not treated as weapons; missing metadata is marked unavailable.
- Read talent descriptions with the current-rank trait tooltip, including client-reported bonus ranks. Generic descriptions are explicitly marked unverified instead of being presented as current-rank effects.
- Marked set bonuses as active, inactive, or unknown, using equipped-piece counts, localized client set text, and client disabled-line information. Inactive thresholds such as 3/5, 4/5, and 5/5 are no longer left unlabelled when only two pieces are equipped.
- Collapsed equal resistance-stat aliases and retained conflicting values with a warning.
- Cleaned two-form plural markup, removed armor duplicated as a resistance, clarified the raw client-stat label, and added guidance against adding repeated shared talent-currency balances.
- Added 14 precision regression tests and updated documentation in all 13 languages. The minimap button is retained.

Validation: 37 simulated Lua 5.1 tests passed. The corrections use cases identified in a live v1.0.3 export; verification of this new version in game is still pending.

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
