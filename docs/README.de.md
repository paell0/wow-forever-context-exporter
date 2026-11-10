# ForeverContext

[English](../README.md) | [Español](README.es.md) | [Português (Brasil)](README.pt-BR.md) | [Français](README.fr.md) | [Deutsch](README.de.md) | [简体中文](README.zh-CN.md) | [繁體中文](README.zh-TW.md) | [日本語](README.ja.md) | [हिन्दी](README.hi.md) | [ไทย](README.th.md) | [한국어](README.ko.md) | [Русский](README.ru.md) | [Italiano](README.it.md)

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
