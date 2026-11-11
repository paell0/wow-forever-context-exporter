# Changelog

## v1.3.0 — 2026-11-11

- Added automatic interface-language detection and an immediate manual selector in Export options → Language, also available through `/fcontext language`, `/fcontext language <locale>` and `/fcontext language auto`.
- Bundled 232 UI strings in English, Spanish, Brazilian Portuguese, French, German, Italian, Russian, Simplified Chinese, Traditional Chinese and Korean. Unsupported locales fall back to English; enGB/esMX share English/Spanish catalogs.
- Saved language preferences account-wide without resetting per-character plans, profiles, notes, goals or export options. Switching updates existing controls without a reload or a new report snapshot.
- Kept report labels, AI instructions and import/export protocols in English. Game names/descriptions and player-authored text remain untouched.
- Translated tool labels, statuses, validation messages, progress checks and minimap help. Added client-font selection for addon-owned CJK/Cyrillic text, retained exclusive-window/combat handling, and reserved more space in export options for translated labels.
- Added offline catalog compilation with key/token validation, integrated it into packaging and documented translation editing and quality limits. Updated all 13 README languages. Catalogs include machine-assisted drafts and curated common controls; native-speaker review is welcome.
- Added 18 localization checks, including switching languages across all tools, account-wide overrides, English report preservation, item/draft integrity, native font contracts and cleared-candidate/keep-row/status refresh regressions.

Validation: 132 simulated Lua 5.1 tests passed. Actual client rendering, wrapping and translated layouts still need in-game verification.

## v1.2.0 — 2026-11-11

- Added a per-character item-source notebook: referenced dungeon/quest/vendor/profession origins, explicit player confirmation, direct merchant/displayed-quest-reward observations, and unconfirmed/outdated status. Unknown origins stay unknown; no complete loot database is claimed.
- Added activity talent profiles with capture of committed nodes, native game export codes when available, bounded FCLOADOUT/1 preview/import/export, selection and rank/entry comparison. Profiles never apply talents. Wrong classes, old builds and impossible client targets are flagged.
- Added client-build/date freshness information and explicit plan-review acknowledgement without changing the original snapshot reference. No automatic internet rule-update service is implied.
- Added opt-in carried-bag reports and a browser with item quantities, exact variants, reagent/equipment metadata, known vendor prices and A/B selection. Bank/mail/other characters are excluded; unknown data is not zero or empty.
- Added per-character keep reasons covering all variants/copies of an item ID, editable protected lists and an unprotected-alternatives filter. Exports ask before disposal; no inventory action is automated.
- Added spoiler-free exports that suppress quest/source discovery details and ask the AI to avoid future rewards, plot, boss names and routes.
- Added 16 report-category switches, source-observation controls, commands and toolbar buttons. Profession data and plan deltas respect category choices. Existing defaults migrate with bags off.
- Unified all tool windows under the existing exclusive-window navigation, cache/focus guards and combat closure. Reference snapshots remain stable when returning without refreshing.
- Added 36 community-tool checks, expanded documentation in all 13 README languages, and included the implementation plan and full workflow guide.

Validation: 114 simulated Lua 5.1 tests passed. Live verification of the new tools and layouts remains pending.

## v1.1.2 — 2026-11-10

- Use the same equipment-slot reader for reports and progress snapshots. A pending item ID no longer records an occupied slot as empty or invents an equipment removal; a readable item link can resolve its ID. Failed texture reads cannot confirm an empty slot.
- Treat restricted or malformed staged-talent data as unverifiable in both exports and progress checks, instead of assuming there are no unapplied changes.
- Mark an existing report outdated after accepting/archiving a plan or changing a manual task. Returning preserves the reference snapshot and asks for Generate / refresh; Select all stays disabled until refreshed.
- Stop scanning equipment, professions and talents on every draft keystroke. Editing a preview invalidates it once while retaining the accepted plan.
- Added eight regression checks, including background-report consistency and all three staged-talent lists. All eight detect the previous v1.1.1 behavior.

Validation: 78 simulated Lua 5.1 tests passed. Live verification remains pending.

## v1.1.1 — 2026-11-10

- Fixed Progress plan and Compare items appearing underneath the report's scroll text. Editors now use a higher frame strata and an opaque background.
- Show only one addon window at a time. Editors temporarily hide the report, close each other when switching, and restore the same report/options when dismissed.
- Pause report cache retries while editing so background loading cannot steal keyboard focus. Interrupted reports can be refreshed after returning; closing an editor does not advance the snapshot reference.
- Keep focused-report navigation and combat closure from reopening an unwanted window.
- Added six window-navigation checks and improved the simulated client to account for inherited visibility, frame strata and native close-button behavior. Five targeted regressions also fail against v1.1.0.

Validation: 70 simulated Lua 5.1 tests passed. Live confirmation of the window fix is pending.

## v1.1.0 — 2026-11-10

- Added a per-character progress planner with preview-before-acceptance, automatic checks for level, skill, equipment, committed talent ranks and gold balance, plus player-controlled manual tasks.
- Added comparison of two dragged/pasted item candidates. Full item references are preserved, uncached data is retried, and hypothetical loadout effects are distinguished from current-character effects.
- Added focused Overview, Talent points, Gear advice, Next session and Review plan reports with purpose-specific AI requests.
- Added accepted-plan reviews, reference snapshots, observed changes, and the two most recent archived plans. New reports do not overwrite the active plan's reference.
- Added a bounded FCPLAN/1 data format requested in exported prompts. Imports are never executed and invalid drafts cannot replace an accepted plan.
- Moved goals/options, plans, candidates and snapshots into per-character saved variables, with migration of existing goal/options defaults. Minimap settings remain account-level.
- Added planner/comparison windows, task pagination, relevant game-event refreshes, combat guards, documentation and commands. Previous precision fixes and the minimap button are retained.

Validation: 64 simulated Lua 5.1 tests passed. Live verification of this larger feature update is pending.

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
