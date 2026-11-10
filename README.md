# ForeverContext

[English](README.md) | [Español](docs/README.es.md) | [Português (Brasil)](docs/README.pt-BR.md) | [Français](docs/README.fr.md) | [Deutsch](docs/README.de.md) | [简体中文](docs/README.zh-CN.md) | [繁體中文](docs/README.zh-TW.md) | [日本語](docs/README.ja.md) | [हिन्दी](docs/README.hi.md) | [ไทย](docs/README.th.md) | [한국어](docs/README.ko.md) | [Русский](docs/README.ru.md) | [Italiano](docs/README.it.md)

Export your WoW Forever character's talents, professions, gear, and stats as plain text for AI advice.

**Status: public preview.** Targets Forever interface **16001**. The addon passes 15 simulated Lua 5.1 tests, but has **not been tested in a live WoW Forever session**. Please report client-specific issues with your build number.

## Install

1. Download `ForeverContext-1.0.1.zip` from [Releases](https://github.com/paell0/wow-forever-context-exporter/releases).
2. Close the game and extract the archive into `World of Warcraft/_forever_/Interface/AddOns/`.
3. Check that the final path is `AddOns/ForeverContext/ForeverContext.toc`.
4. Start Forever and enable **ForeverContext** in the AddOns list.

If you download the repository source instead, copy only the `ForeverContext` folder into `AddOns`. The repository ZIP itself is not an installable addon package.

If you installed the previous `ContextoPJ` version, remove that addon folder first so both exporters do not register `/pjia`.

## Use

1. Outside combat, type **`/fcontext`**.
2. Optionally enter your goal, such as “solo leveling on a small budget” or “healing dungeons with friends.”
3. Click **Generate / refresh** after changing goals or options.
4. Click **Select all**, press **Ctrl+C**, then paste into your AI with **Ctrl+V**.

The report already includes a request for prioritized, version-specific advice. `/forevercontext` is an alias; `/pjia` remains available for existing users. `/fcontext help` displays help.

No AI subscription, API key, or companion application is required by the addon. You choose where to paste the text. WoW requires a manual copy action; the addon does not directly access your system clipboard or send anything to an AI.

## Exported information

- Class, race, faction, level, experience, zone, money, and client version.
- Active talent build, branches, ranks, available points, IDs, and available descriptions.
- Queryable Forever Legacy trees.
- Primary and secondary professions, current ranks, caps, and bonuses.
- Every equipped slot: item name, ID, type, quality, item level, requirements, durability, and stats.
- Client-provided item tooltips, including readable equip/use effects, set text, enchants, and gem IDs.
- Current character stats, readable buffs, and the currently summoned pet.
- Optional extended context: skills, weapon proficiencies, known spells, quests, and queryable reputations.
- Your goal, coverage warnings, and a ready-to-use request to the AI.

**Language:** addon controls and report labels are English. Names and descriptions returned by the game remain in your client's language. The README translations describe the same addon; they do not imply localized game support or translated game data.

## Privacy and limitations

Your character name is excluded by default. The addon does not export your account, BattleTag, chat, friends, or guild data, and does not transmit your report. Your goal and checkbox preferences are saved locally in `ForeverContextDB`.

This is a snapshot of currently equipped gear and the active build. It does not include bag or bank inventories, alternate sets, stabled pets, historical talent choices, or combat performance. Current stats may include temporary buffs or forms.

Unapplied talent changes are not reported as committed talents. Unavailable data is marked explicitly; missing values must not be interpreted as zero or empty slots. Item data is retried briefly. If warnings remain, open Talents/Professions, hover over gear, and generate again. Collapsed groups may limit skill, quest, or reputation coverage.

AI advice still needs verification against the current Forever rules. The report explicitly asks the AI to identify uncertainty and avoid inventing item effects, locations, or rewards.

## Development

Requires Python 3.10+ for development; the game itself needs no Python installation.

```sh
python -m pip install -r requirements-dev.txt
python -m unittest discover -s tests -v
python scripts/build_release.py
```

The build writes `dist/ForeverContext-1.0.1.zip` with the correct addon folder. Tests use `lupa.lua51` and a simulated client. Some fixtures deliberately use Spanish game data to verify that localized client text is preserved.

The API contracts were checked against [Blizzard's exported Forever UI source](https://github.com/Gethe/wow-ui-source/tree/forever), including the [Camelot talent UI](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_PlayerSpells/Camelot/ClassTalents/Blizzard_ClassTalentsFrame.lua) and [profession UI](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_ProfessionsBook/Camelot/Blizzard_ProfessionsBook.lua).

## Contributing

Bug reports, client verification, and translation improvements are welcome. Include the game build, addon version, reproduction steps, and the exact Lua error when available. Remove identifying information before sharing reports. See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

[MIT](LICENSE). This is an independent community project and is not affiliated with Blizzard Entertainment.
