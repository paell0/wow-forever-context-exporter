# ForeverContext

[![Version 1.0.1](https://img.shields.io/static/v1?label=version&message=1.0.1&color=D4A64A&labelColor=162033&style=for-the-badge)](https://github.com/paell0/wow-forever-context-exporter/releases/tag/v1.0.1) [![Public preview](https://img.shields.io/static/v1?label=status&message=public+preview&color=E8A838&labelColor=162033&style=for-the-badge)](https://github.com/paell0/wow-forever-context-exporter#privacy-and-limitations) [![Lua 5.1](https://img.shields.io/static/v1?label=Lua&message=5.1&color=2C2D72&labelColor=162033&style=for-the-badge&logo=lua&logoColor=white)](https://github.com/paell0/wow-forever-context-exporter/tree/main/ForeverContext) [![MIT license](https://img.shields.io/static/v1?label=license&message=MIT&color=2EA66F&labelColor=162033&style=for-the-badge)](../LICENSE) [![15 simulated tests; not verified in game](https://img.shields.io/static/v1?label=tests&message=15+simulated&color=3B82B6&labelColor=162033&style=for-the-badge)](https://github.com/paell0/wow-forever-context-exporter/blob/main/tests/test_addon.py)

<!-- language-selector:start -->

[![English](https://img.shields.io/static/v1?label=EN&message=English&color=334155&labelColor=162033&style=flat-square)](../README.md) [![Español](https://img.shields.io/static/v1?label=ES&message=Espa%C3%B1ol&color=334155&labelColor=162033&style=flat-square)](README.es.md) [![Português (Brasil)](https://img.shields.io/static/v1?label=PT-BR&message=Portugu%C3%AAs+%28Brasil%29&color=334155&labelColor=162033&style=flat-square)](README.pt-BR.md) [![Français](https://img.shields.io/static/v1?label=FR&message=Fran%C3%A7ais&color=334155&labelColor=162033&style=flat-square)](README.fr.md) [![Deutsch (selected)](https://img.shields.io/static/v1?label=DE&message=Deutsch&color=D4A64A&labelColor=162033&style=flat-square)](README.de.md)

[![简体中文](https://img.shields.io/static/v1?label=ZH-CN&message=%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87&color=334155&labelColor=162033&style=flat-square)](README.zh-CN.md) [![繁體中文](https://img.shields.io/static/v1?label=ZH-TW&message=%E7%B9%81%E9%AB%94%E4%B8%AD%E6%96%87&color=334155&labelColor=162033&style=flat-square)](README.zh-TW.md) [![日本語](https://img.shields.io/static/v1?label=JA&message=%E6%97%A5%E6%9C%AC%E8%AA%9E&color=334155&labelColor=162033&style=flat-square)](README.ja.md) [![हिन्दी](https://img.shields.io/static/v1?label=HI&message=%E0%A4%B9%E0%A4%BF%E0%A4%A8%E0%A5%8D%E0%A4%A6%E0%A5%80&color=334155&labelColor=162033&style=flat-square)](README.hi.md)

[![ไทย](https://img.shields.io/static/v1?label=TH&message=%E0%B9%84%E0%B8%97%E0%B8%A2&color=334155&labelColor=162033&style=flat-square)](README.th.md) [![한국어](https://img.shields.io/static/v1?label=KO&message=%ED%95%9C%EA%B5%AD%EC%96%B4&color=334155&labelColor=162033&style=flat-square)](README.ko.md) [![Русский](https://img.shields.io/static/v1?label=RU&message=%D0%A0%D1%83%D1%81%D1%81%D0%BA%D0%B8%D0%B9&color=334155&labelColor=162033&style=flat-square)](README.ru.md) [![Italiano](https://img.shields.io/static/v1?label=IT&message=Italiano&color=334155&labelColor=162033&style=flat-square)](README.it.md)

<!-- language-selector:end -->

Exportiere Talente, Berufe, Ausrüstung und Werte deines WoW-Forever-Charakters als Text, um eine KI um Rat zu fragen.

## Installation und Verwendung

1. Lade `ForeverContext-1.0.1.zip` unter [Releases](https://github.com/paell0/wow-forever-context-exporter/releases) herunter.
2. Schließe das Spiel und entpacke den Ordner `ForeverContext` nach `World of Warcraft/_forever_/Interface/AddOns/`.
3. Prüfe den Pfad `AddOns/ForeverContext/ForeverContext.toc` und aktiviere das Addon. Entferne gegebenenfalls den alten ContextoPJ-Ordner.
4. Gib außerhalb eines Kampfes **`/fcontext`** ein.
5. Trage bei Bedarf dein Ziel ein. Klicke auf **Generate / refresh**, dann auf **Select all**, und drücke **Strg+C**. Füge den Bericht mit **Strg+V** in die KI ein.

Aliasse: `/forevercontext` und `/pjia`. Hilfe: `/fcontext help`.

## Inhalt

Klasse, Volk, Stufe, Erfahrung, aktive Talente und verfügbare Punkte; Berufe und Fertigkeitsstände; angelegte Gegenstände mit Werten, Effekten, Verzauberungen, Edelsteinen und Haltbarkeit; Buffs und beschworener Begleiter. Optional werden Fertigkeiten, bekannte Zauber, Quests und abfragbare Rufwerte ergänzt. Eine Analyseanfrage ist bereits enthalten.

## Status und Grenzen

Öffentliche Vorabversion für Interface **16001**. **15 simulierte Lua-5.1-Tests** bestanden; noch kein Test in einer echten WoW-Forever-Sitzung.

Der Charaktername wird standardmäßig ausgelassen. Das Addon überträgt keine Daten und benötigt keinen API-Schlüssel. Taschen und Bank werden nicht exportiert. Nicht übernommene Talentänderungen werden nicht als aktiv dargestellt. Fehlende Daten werden markiert: Öffne Talente/Berufe und erstelle den Bericht erneut.

Bedienelemente und Berichtsbeschriftungen sind englisch; Spieltexte behalten die Sprache des Clients. Dies ist eine Übersetzung der Dokumentation. Entwicklung und vollständige Grenzen stehen im [Haupt-README](../README.md). Lizenz: [MIT](../LICENSE).
