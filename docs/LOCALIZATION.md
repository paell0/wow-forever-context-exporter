# Interface languages

[Main README](../README.md) · [Community tools](COMMUNITY-TOOLS.md)

ForeverContext follows the game language by default. Choose another language in **Settings → Language**, or open the selector directly with `/fcontext language`. The choice takes effect immediately, without reloading the UI.

## Available languages

| Interface | Locale |
| --- | --- |
| English | `enUS` (also `enGB`) |
| Español | `esES` (also `esMX`) |
| Português (Brasil) | `ptBR` |
| Français | `frFR` |
| Deutsch | `deDE` |
| Italiano | `itIT` |
| Русский | `ruRU` |
| 简体中文 | `zhCN` |
| 繁體中文 | `zhTW` |
| 한국어 | `koKR` |

Unsupported game locales fall back to English. Spanish variants share one catalog. `ptPT` is accepted as an alias for Brazilian Portuguese. README translations in Japanese, Hindi and Thai are documentation translations; these three languages are not included in the addon interface.

Use `/fcontext language esES` to select Spanish, `/fcontext language enUS` for English, or `/fcontext language auto` to follow the game again. Commands and locale codes remain unchanged in every language. The selector is unavailable during combat, like the other addon tools.

## What changes

Buttons, headings, option labels, validation/status messages, progress checks, source-notebook labels and minimap help use the selected interface language. Native language names in the selector remain recognizable.

**Reports and AI instructions stay English.** Report previews, item-detail export buffers, `FCPLAN/1`, `FCLOADOUT/1` and native talent codes retain their existing formats. Names and descriptions supplied by the game retain the client's language. Goals, task titles, item names, source locations, references, keep reasons and activity names are never translated. Changing the interface language does not regenerate the report or advance its reference snapshot.

The language choice is stored account-wide in `ForeverContextDB.language`; each character uses the same preference. Character-specific export settings, plans, profiles and notes remain in `ForeverContextCharacterDB`. **Restore defaults** resets export options, preserving the language choice and saved character data. Select Automatic explicitly to reset the language preference.

## Translation quality and client fonts

Catalogs are bundled with the addon. No translation service, network connection or API key is used by the game. The initial translations are machine-assisted drafts, with common controls and Spanish terminology reviewed manually. Native-speaker corrections are welcome through a pull request; grammatical quality is not claimed to have been reviewed by native speakers in every language.

For Chinese, Korean and Russian, addon-owned translated text requests the corresponding font shipped by the client while preserving its size and style. Other game UI fonts are not modified. Missing font files are handled without interrupting the addon. Actual glyph rendering, wrapping and layouts in each client still require in-game verification.

## Updating translations

1. Edit `locales/<locale>.json` in the repository, using `locales/enUS.json` as the complete key list.
2. Preserve every `{1}`-style placeholder, command, protocol identifier and import-field name. Placeholders may move to suit the language, but must not be removed or duplicated. Do not translate player data or game API identifiers.
3. Run `python scripts/build_locales.py`. The offline compiler checks key coverage and protected tokens, then writes `ForeverContext/Locales.lua` deterministically.
4. Run the tests and `python scripts/build_release.py`. Packaging also compiles and validates catalogs, so a stale generated file cannot enter the ZIP.

Use `NS.SetText(widget, "English key {1}", value)` for addon labels and status messages. Use `NS.BindText` for labels derived from current state. Pass player/game text as arguments rather than translation keys. Keep report generation independent from the UI translator. Only the controlled English validation patterns in `locales/patterns.json` support translation of existing backend messages; do not translate arbitrary report text with these patterns.

The release includes generated Lua catalogs and this guide. JSON sources and the Python compiler are development files, not runtime dependencies. The existing [contribution and license terms](../CONTRIBUTING.md) apply to translations too.
