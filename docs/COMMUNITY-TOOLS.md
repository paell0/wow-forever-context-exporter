# Sources, talent profiles, bags and export preferences

[Main README](../README.md) · [Progress plans](PROGRESS-PLAN.md) · [Implementation plan](IMPLEMENTATION-PLAN-1.2.md)

Version 1.2.0 implements seven community-requested improvements. Since v1.3.0, controls follow the game language or your manual selection; reports stay English and game-provided text keeps the client's language. See the [language guide](LOCALIZATION.md). These tools assist your decisions and never apply talents, equip/move/sell/destroy items or contact an AI.

## Open the tools

Open `/fcontext` or click the minimap button. The second button row contains:

| Button / command | Purpose |
| --- | --- |
| **Export options** / `/fcontext options` | Select report categories and spoiler preferences. |
| **Browse bags** / `/fcontext bags` | Inspect carried items and choose A/B comparison candidates. |
| **Keep items** / `/fcontext keep` | Protect item IDs and record why you want to keep them. |
| **Item sources** / `/fcontext sources` | Manage equipment-origin references and review the notebook with AI. |
| **Talent profiles** / `/fcontext loadouts` | Save/copy activity-specific talent targets and compare them with your current build. |

Only one addon window is visible at a time. Closing a tool returns to the existing report if it was open. Changing export preferences, candidates or recorded advice context marks that report outdated; click **Generate / refresh** before copying updated advice. Entering combat closes all tools without reopening the report.

## 1. Record where equipment comes from

In **Item sources**:

1. Enter an item ID or paste its game link; you can also drop a carried/equipped item onto **Drop item**.
2. Choose **Dungeon**, **Quest**, **Vendor**, **Profession**, or **Other** with the source-type button.
3. Enter the location, dungeon/boss, quest or recipe. Add the exact HTTPS page supporting the claim when one is available.
4. Leave confirmation unchecked for an AI suggestion or an unverified note. Check **I checked this source in Forever on this client build** only after doing that yourself, then **Save source**.
5. Use **Filter / refresh** to find that item's records. Clear the item field to browse the whole notebook. **Edit selected** loads an existing record for review; confirmation is deliberately reset.

Multiple origins can be recorded for one item. **Review sources with AI** exports the notebook with your selected character categories, so you can discuss future upgrades whose sources you have recorded. Regular reports include sources matching the equipped items, optional bag contents or A/B candidates that are actually exported.

The addon also observes readable merchant offers when you visit a merchant and reward/choice items displayed during quest interactions. **Observe current offers** refreshes an open merchant or quest-reward window. The observation records an offer/reward, not ownership, purchase, quest completion, boss loot or a guaranteed drop rate. You can disable this helper in **Export options**.

Statuses distinguish provenance:

| Status | Meaning |
| --- | --- |
| **OBSERVED IN GAME** | The client exposed a merchant offer or displayed quest reward on the recorded build. |
| **PLAYER-CONFIRMED** | You explicitly checked the claim; the addon has not independently fetched or verified its webpage. |
| **UNCONFIRMED** | A note/reference, including a possible AI suggestion, that you have not confirmed. |
| **OUTDATED / RECHECK** | Recorded for another build; the original provenance remains visible. |
| **Origin NOT CONFIRMED** | No source record exists for that item. |

This is a source notebook with observed evidence, not a complete bundled loot database. Dungeon drops and crafting sources can be entered with references; the addon does not substitute Classic loot tables or invent missing Forever data. Maximum 300 records per character. Remove an old record if the notebook reaches its limit. NPC names and source locations are included when you export those records.

## 2. Save talents for a dungeon or activity

1. Apply or cancel pending changes in the game's talent window.
2. Open **Talent profiles**, enter a profile name and a dungeon/activity, then **Save current build**.
3. Capture other committed configurations with other names as needed. Use **Previous / Next** to select a target profile.
4. **Copy profile** selects a portable `FCLOADOUT/1` block for Ctrl+C. **Copy game code** selects the game's native talent import string if the client provided one when the profile was captured.
5. **Compare with AI** generates a Talent points report with current-to-target ranks and entry-selection differences.

The game code and `FCLOADOUT/1` are different formats. The game code belongs in the game's talent UI, where you must check compatibility and confirm changes yourself. A profile block belongs in ForeverContext: paste it into the text area, **Preview import**, review its class/build/name, then **Import profile**. Draft edits never replace a saved profile. Native game codes alone cannot be imported as addon profiles.

Profiles do not change talents or automatically switch when entering a dungeon. They are player-supplied targets, not endorsed builds. Wrong classes, old builds, unreadable current talents, missing target nodes, targets above the client node's maximum and incompatible available entries are labelled. A missing target node does not imply a reset. A profile name replaces the saved profile with that name; keep distinct names for distinct activities. Up to 12 profiles, each with up to 512 nodes.

**Clear selection** stops including a target profile in reports until you select another one. Disabling either Current talents or Selected talent profile also omits profile comparisons.

Portable profile example (illustrative IDs, not a recommended build):

```text
FCLOADOUT/1
NAME|Dungeon profile
ACTIVITY|My dungeon - damage
CLASS|WARRIOR
BUILD|70862
LEVEL|25
NODE|10|3|100
NODE|11|0|101
```

`NODE` fields are node ID, committed rank and entry ID. Positive ranks require a nonzero entry ID. Required fields are NAME, ACTIVITY, CLASS, BUILD, LEVEL and at least one NODE. An optional NATIVE line contains the client-generated code. Names/activity labels cannot contain pipes or line breaks. Imports are at most 40,000 bytes, native strings at most 8,192 bytes; duplicate or unknown fields are rejected. Text is parsed as data, never executed.

## 3. Review advice after patches

Every report identifies the client build and addon version. Source records and talent profiles retain their recorded build; accepted plans retain their original reference. A build mismatch produces an outdated/recheck warning.

Recheck a source in **Item sources** and save with explicit confirmation, or revisit its actual merchant/quest offer. Recapture a talent profile after checking the current tree. In **Progress plan**, **Mark build reviewed** records that you reviewed the plan on the current build; it does not rewrite the original reference snapshot or verify old source records/profiles.

There is no background internet rule-update service. Build matches and timestamps are provenance, not proof that every rule or server-side hotfix is unchanged. Reports ask the AI to cite Forever references and distinguish unsupported claims. A new addon release must still be installed in the normal way.

## 4. Include and browse carried bags

Carried-bag export is **off by default**. Enable **Carried bags (opt-in)** in **Export options**, then generate a report. Only equipped carried bags are read: no bank, mail or other-character inventories.

Reports include item references/variants, stack quantities, item type, equipment slot, known reagent status and available vendor price. Vendor price is not auction value or usefulness; missing prices and data remain unknown. Equipment effects/stats are detailed for the first 80 carried equipment entries; remaining references and quantities are still included. The scan has a 400-item safety limit and reports incomplete data explicitly.

**Browse bags** works on demand even if automatic bag export is off. Use Previous/Next, **Equipment only**, and **Hide kept items / show alternatives**. Record a reason and click **Keep this item**, or select **Use as A / Use as B** and **Open Compare**. Nothing is moved, equipped or disposed of. Bag-update events refresh a visible browser once per update frame; closed tools do not poll.

## 5. Keep items and consider alternatives

In **Keep items**, paste/drop an item, enter your reason and **Save keep preference**. This protects every copy/variant of that item ID in the exported advice, including alternative sets, profession materials or items reserved for personal plans. Use the Remove button to clear a preference. Maximum 100 item IDs; reasons are at most 240 bytes.

The keep list is an instruction to the AI, not an in-game item lock. There is no automatic selling, disenchanting, consuming or destruction. Unlisted items are not automatically disposable. Bag browsing can hide protected items to help you inspect alternatives. If you disable Keep-list preferences, reports withhold the list and instruct the AI to ask before recommending disposal.

## 6. Request spoiler-free advice

Enable **Spoiler-free advice** in **Export options**. The export suppresses active quest details and source-notebook contents, including the notebook-review report. It asks the AI to avoid future rewards, plot, boss names, undiscovered locations and routes, and to ask before revealing specifics. Freshness instructions do not request source-location spoilers in this mode.

This filters exported discovery information and sets the requested reply style. It does not control third-party AI replies, remove every hint from already-owned item names/tooltips, or redact text you wrote yourself in goals, tasks, keep reasons or profile activity names. Opening the source-management window deliberately lets you review your saved notes. Use the report preview before sharing it.

## 7. Select report categories and helpers

Export options contains independent switches for Current talents, Legacy trees, Professions, Equipped items, Character stats, Buffs, Summoned pet, Skills/proficiencies, Known spells, Active quests, Reputations, Carried bags, Item source notebook, Accepted plan/changes, Selected talent profile and Keep-list preferences.

Identity/client basics remain included. The purpose buttons and **Include extra details for this question** still determine which enabled optional categories are relevant. Disabled categories are omitted rather than assumed absent. Profession ranks do not reappear through skill fallback queries when Professions is disabled, and plan details/deltas respect the related category choices. Player-authored text may mention any topic and is not automatically rewritten.

**Record sources from visited merchants / displayed quest rewards** is a separate helper switch. **Restore defaults** restores category defaults, enables observations and turns spoiler-free mode off; it does not delete saved plans, profiles, sources or keep preferences. Existing goal/name/extra-detail settings migrate without resetting them. New category defaults preserve previous report content, with bags remaining opt-in.

## Storage, limits and validation

All new settings, source records, keep preferences and profiles are local and per character in `ForeverContextCharacterDB`. Minimap and language preferences remain account-level. Choose **Export options → Language** or use `/fcontext language`; changes take effect immediately. Restoring export defaults preserves this account-wide choice. Plans retain the two-archive limit. No API key, desktop helper, clipboard-access permission or AI account is required by the addon; you manually choose which AI receives the copied text.

Validation uses strict Lua 5.1 simulation, including the documented Forever [Container API](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated/ContainerDocumentation.lua), [item metadata](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated/ItemDocumentation.lua), [native talent export API](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated/SharedTraitsDocumentation.lua), and the client's [merchant](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_UIPanels_Game/Mainline/MerchantFrame.lua) and [quest-reward UI](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_UIPanels_Game/Mainline/QuestInfo.lua). Live client verification is still pending for this release.
