# ForeverContext

[![Version 1.1.2](https://img.shields.io/static/v1?label=version&message=1.1.2&color=D4A64A&labelColor=162033&style=for-the-badge)](https://github.com/paell0/wow-forever-context-exporter/releases/tag/v1.1.2) [![Public preview](https://img.shields.io/static/v1?label=status&message=public+preview&color=E8A838&labelColor=162033&style=for-the-badge)](https://github.com/paell0/wow-forever-context-exporter#privacy-and-limitations) [![Lua 5.1](https://img.shields.io/static/v1?label=Lua&message=5.1&color=2C2D72&labelColor=162033&style=for-the-badge&logo=lua&logoColor=white)](https://github.com/paell0/wow-forever-context-exporter/tree/main/ForeverContext) [![All Rights Reserved; prior MIT material retains its permissions](https://img.shields.io/static/v1?label=license&message=All+Rights+Reserved&color=B45309&labelColor=162033&style=for-the-badge)](LICENSE) [![78 simulated tests; not verified in game](https://img.shields.io/static/v1?label=tests&message=78+simulated&color=3B82B6&labelColor=162033&style=for-the-badge)](https://github.com/paell0/wow-forever-context-exporter/blob/main/tests/test_addon.py)

<!-- language-selector:start -->

[![English (selected)](https://img.shields.io/static/v1?label=EN&message=English&color=D4A64A&labelColor=162033&style=flat-square)](README.md) [![Español](https://img.shields.io/static/v1?label=ES&message=Espa%C3%B1ol&color=334155&labelColor=162033&style=flat-square)](docs/README.es.md) [![Français](https://img.shields.io/static/v1?label=FR&message=Fran%C3%A7ais&color=334155&labelColor=162033&style=flat-square)](docs/README.fr.md) [![Deutsch](https://img.shields.io/static/v1?label=DE&message=Deutsch&color=334155&labelColor=162033&style=flat-square)](docs/README.de.md) [![Italiano](https://img.shields.io/static/v1?label=IT&message=Italiano&color=334155&labelColor=162033&style=flat-square)](docs/README.it.md) [![Русский](https://img.shields.io/static/v1?label=RU&message=%D0%A0%D1%83%D1%81%D1%81%D0%BA%D0%B8%D0%B9&color=334155&labelColor=162033&style=flat-square)](docs/README.ru.md)

[![Português (Brasil)](https://img.shields.io/static/v1?label=PT-BR&message=Portugu%C3%AAs+%28Brasil%29&color=334155&labelColor=162033&style=flat-square)](docs/README.pt-BR.md)

[![简体中文](https://img.shields.io/static/v1?label=ZH-CN&message=%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87&color=334155&labelColor=162033&style=flat-square)](docs/README.zh-CN.md) [![繁體中文](https://img.shields.io/static/v1?label=ZH-TW&message=%E7%B9%81%E9%AB%94%E4%B8%AD%E6%96%87&color=334155&labelColor=162033&style=flat-square)](docs/README.zh-TW.md) [![日本語](https://img.shields.io/static/v1?label=JA&message=%E6%97%A5%E6%9C%AC%E8%AA%9E&color=334155&labelColor=162033&style=flat-square)](docs/README.ja.md) [![한국어](https://img.shields.io/static/v1?label=KO&message=%ED%95%9C%EA%B5%AD%EC%96%B4&color=334155&labelColor=162033&style=flat-square)](docs/README.ko.md) [![हिन्दी](https://img.shields.io/static/v1?label=HI&message=%E0%A4%B9%E0%A4%BF%E0%A4%A8%E0%A5%8D%E0%A4%A6%E0%A5%80&color=334155&labelColor=162033&style=flat-square)](docs/README.hi.md) [![ไทย](https://img.shields.io/static/v1?label=TH&message=%E0%B9%84%E0%B8%97%E0%B8%A2&color=334155&labelColor=162033&style=flat-square)](docs/README.th.md)

<!-- language-selector:end -->

Export your WoW Forever character's talents, professions, gear, and stats as plain text for AI advice.

**Status: public preview.** Targets Forever interface **16001**. The addon passes 78 simulated Lua 5.1 tests. **This build still needs live verification.** Earlier builds have produced live character exports and revealed client-specific UI issues. Please report issues with your build number.

[Changelog](CHANGELOG.md)

## Install

1. Download `ForeverContext-1.1.2.zip` from [Releases](https://github.com/paell0/wow-forever-context-exporter/releases).
2. Close the game and extract the archive into `World of Warcraft/_forever_/Interface/AddOns/`.
3. Check that the final path is `AddOns/ForeverContext/ForeverContext.toc`.
4. Start Forever and enable **ForeverContext** in the AddOns list.

If you download the repository source instead, copy only the `ForeverContext` folder into `AddOns`. The repository ZIP itself is not an installable addon package.

If you installed the previous `ContextoPJ` version, remove that addon folder first so both exporters do not register `/pjia`.

## Use

1. Outside combat, click the **minimap button** or type **`/fcontext`**.
2. Choose **Overview**, **Talent points**, **Gear advice**, **Next session**, or **Review plan** and enter your goal.
3. Click **Generate / refresh**, then **Select all** and **Ctrl+C**. Paste into your AI with **Ctrl+V**.
4. If the AI returns a plan block, open **Progress plan**, paste that block, click **Preview plan**, and review it before clicking **Accept plan**.

### Four connected features

- **Track a progress plan:** up to 32 tasks saved per character. Current level, skills, equipped slots/items, committed talent ranks, and gold balance can be checked automatically; other tasks have manual checkboxes.
- **Compare two items:** open **Compare items**, drag in candidates A and B or paste their full game links, then click **Compare with AI**. The report includes both items and your current character context.
- **Ask a focused question:** purpose buttons select relevant sections and tailor the AI request. The overview keeps the broader export available.
- **Review previous advice:** exports include accepted goals, current completion checks, and observed changes since the plan's reference snapshot. Replaced/cleared plans are archived, with the two most recent retained.

Unknown data is labelled **UNKNOWN** rather than completed or failed. Automatic checks reflect the current state, so removing an item or spending gold may make a task pending again. Previewing a plan never replaces the active plan; acceptance is explicit. Imported text is parsed as data and never executed.

Plans, goals, selected candidates, and snapshots are **per character**. Existing account-level goal/options become initial migration defaults. Your minimap position/visibility remain account-level settings.

Opening **Progress plan** or **Compare items** temporarily hides the report and closes the other editor. Close the editor to return to the same report and options. Returning does not generate a new reference snapshot; interrupted data loading can be resumed with **Generate / refresh**.

Accepting or archiving a plan, or changing a manual checkbox, marks the restored report as outdated. Click **Generate / refresh** to include those changes; **Select all** stays disabled until the report is refreshed. Draft edits do not change accepted progress.

Read the [complete workflow guide, task format, and command list](docs/PROGRESS-PLAN.md).

**Commands:** `/fcontext plan`, `/fcontext compare`, `/fcontext talents`, `/fcontext gear`, `/fcontext session`, `/fcontext review`, and `/fcontext overview`. `/forevercontext` and `/pjia` remain aliases.

**Minimap controls:** left-click to open or close the report; drag to move the button. Use **`/fcontext minimap`** to hide/show it. No additional addon libraries are required.

No AI subscription, API key, or companion application is required by the addon. You choose where to paste reports and copy plan blocks back manually. The addon does not access your system clipboard, contact an AI, apply talents, equip items, or spend gold for you.

## Exported information

- Class, race, faction, level, experience, zone, money, and client version.
- Active talent build, branches, ranks, available points, IDs, and available descriptions.
- Queryable Forever Legacy trees.
- Primary and secondary professions, current ranks, caps, and bonuses.
- Every equipped slot: item name, ID, type, quality, item level, requirements, durability, and stats.
- Client-provided item tooltips, including readable equip/use effects, enchants, and gem IDs.
- Set bonuses explicitly marked active, inactive, or unknown, with piece requirements when available.
- Off-hand attack values only when an off-hand weapon is confirmed; duplicate resistance aliases are collapsed when their values agree.
- Current character stats, readable buffs, and the currently summoned pet.
- Optional extended context: skills, weapon proficiencies, known spells, quests, and queryable reputations.
- Your goal, coverage warnings, and a ready-to-use request to the AI.

**Language:** addon controls and report labels are English. Names and descriptions returned by the game remain in your client's language. The README translations describe the same addon; they do not imply localized game support or translated game data.

## Privacy and limitations

Your character name is excluded by default. The addon does not export your account, BattleTag, chat, friends, or guild data, and does not transmit your report. Character goals/options, accepted plans, candidate references, and snapshots are saved locally in `ForeverContextCharacterDB`; minimap preferences remain in `ForeverContextDB`. Player-entered goals and accepted task labels are included when you export their context.

Reports describe currently equipped gear and the active build, with selected comparison candidates and plan context added separately. The addon does not scan entire bag/bank inventories, preserve full old item tooltips, or record combat performance or every historical talent decision. Current stats may include temporary buffs or forms. Snapshot comparisons record level, gold balance, equipped item IDs, readable skills and committed talent ranks; the plan reference is the most recently generated report at acceptance, or a fresh snapshot when none exists.

Unapplied talent changes are not reported as committed talents. Unavailable data is marked explicitly; missing values must not be interpreted as zero or empty slots. Item data is retried briefly. If warnings remain, open Talents/Professions, hover over gear, and generate again. Collapsed groups may limit skill, quest, or reputation coverage.

AI advice still needs verification against the current Forever rules. The report explicitly asks the AI to identify uncertainty and avoid inventing item effects, locations, or rewards.

## Development

Requires Python 3.10+ for development; the game itself needs no Python installation.

```sh
python -m pip install -r requirements-dev.txt
python -m unittest discover -s tests -v
python scripts/build_release.py
```

The build writes `dist/ForeverContext-1.1.2.zip` with the correct addon folder. Tests use `lupa.lua51` and a simulated client. Some fixtures deliberately use Spanish game data to verify that localized client text is preserved.

An earlier v1.0.3 build produced a live character export on Forever build 70862 with an esES client. The current planner, comparison UI, and focused workflow still require live verification.

The API contracts were checked against [Blizzard's exported Forever UI source](https://github.com/Gethe/wow-ui-source/tree/forever), including the [Camelot talent UI](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_PlayerSpells/Camelot/ClassTalents/Blizzard_ClassTalentsFrame.lua) and [profession UI](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_ProfessionsBook/Camelot/Blizzard_ProfessionsBook.lua).

## Contributing

Bug reports, client verification, and translation improvements are welcome. Include the game build, addon version, reproduction steps, and the exact Lua error when available. Remove identifying information before sharing reports. See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

[All Rights Reserved — custom use and contribution terms](LICENSE) for new original material starting with v1.0.2. Personal use of official unmodified releases is allowed. Changes may be developed and tested solely for a pull request to this repository, and only the maintainer decides which changes become an official release. Separate modified releases, rehosting, and commercial exploitation require prior written permission, subject to existing licenses and applicable law.

**Previously published MIT material remains MIT-licensed.** The v1.0.1 release and its code were already made available under MIT; this change does not retract those permissions, even when that code appears in a later version. The original notice is preserved in [LICENSE-MIT-v1.0.1.txt](LICENSE-MIT-v1.0.1.txt). This licensing change cannot make that existing code exclusive retroactively. GitHub's platform permissions for viewing and forking public repositories also remain unaffected.

For CurseForge, select **All Rights Reserved** and include the custom license file. This is a source-available community project, not an open-source project under the new terms, and is not affiliated with Blizzard Entertainment.

Current-rank descriptions use the client’s [GetTraitEntry API](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated/TooltipInfoDocumentation.lua), following the rank selection used by Blizzard’s talent UI. Generic fallback descriptions are labelled **REFERENCE ONLY**; the addon never multiplies their numbers to guess a higher-rank effect.
