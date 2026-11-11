# Seven community-requested improvements

Target: v1.2.0, WoW Forever interface 16001. Addon UI and exports remain English. Existing saved plans and the single-visible-window workflow must survive this update.

| Step | Implementation | Acceptance |
| --- | --- | --- |
| 1. Equipment origins | Per-character source notebook with item, source type, location/boss/quest/recipe, reference, observed/confirmed status, timestamp and client build. Observe readable merchant offers and displayed quest rewards. Export matching records; unknown origins stay unconfirmed. | No guessed Classic loot tables. Player confirmation is distinguishable from direct observation. |
| 2. Activity talent profiles | Save current committed talents with a named activity; import/export bounded profile data; copy the game's talent code when available; compare ranks and selections with the active build. | Profiles never apply talents. Class/build mismatches and unreadable/staged changes are explicit. |
| 3. Patch freshness | Record client build on sources, profiles and plan reviews; show outdated status and explicit review controls. | Acknowledging a review never rewrites the original plan reference or silently verifies old sources. No addon network/update service is implied. |
| 4. Bag context | Optional carried-bag export with counts, metadata, item effects, equipment/reagent classification and vendor price. Add paged browsing and A/B candidate selection. | Exclude bank/mail/other characters; preserve variants; unknown data is not a zero price or empty bag. |
| 5. Keep list | Per-character protected item IDs and reasons; editable list and protection from the bag browser; include preservation instructions in exports. | All copies/variants of a protected item ID are covered. No item is sold, moved or destroyed. |
| 6. Spoiler-free mode | Suppress quest/source discovery information and ask the AI to avoid future rewards, story, undiscovered places and routes. | Game data and all appended report sections honor the option; third-party AI compliance is not guaranteed. |
| 7. Optional modules | Export-options window with category switches and explicit defaults/migration. Keep the focused purposes and extended-details switch. | Disabled categories cannot leak through extra sections, prompts or legacy fallback paths. |

Implementation order: shared settings and window helpers; sources/freshness; profiles; bags/keep list; options and spoiler integration; regression checks; documentation in the existing languages; package and public preview release.

Validation: strict Lua 5.1 simulation of API contracts, imports, source provenance, stale data, profile differences, inventory cache failures, preservation and spoiler filtering, category isolation, navigation/combat closure and migration. Live client verification is reported separately.

Implementation completed on 2026-11-11. All seven steps are implemented, with 114 passing simulated Lua 5.1 tests. The source notebook intentionally distinguishes observed/player-confirmed/unconfirmed evidence and does not claim a complete loot database. The installable preview package is prepared; live client verification remains pending.
