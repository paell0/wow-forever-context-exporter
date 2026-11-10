# ForeverContext

[![Version 1.0.1](https://img.shields.io/static/v1?label=version&message=1.0.1&color=D4A64A&labelColor=162033&style=for-the-badge)](https://github.com/paell0/wow-forever-context-exporter/releases/tag/v1.0.1) [![Public preview](https://img.shields.io/static/v1?label=status&message=public+preview&color=E8A838&labelColor=162033&style=for-the-badge)](https://github.com/paell0/wow-forever-context-exporter#privacy-and-limitations) [![Lua 5.1](https://img.shields.io/static/v1?label=Lua&message=5.1&color=2C2D72&labelColor=162033&style=for-the-badge&logo=lua&logoColor=white)](https://github.com/paell0/wow-forever-context-exporter/tree/main/ForeverContext) [![MIT license](https://img.shields.io/static/v1?label=license&message=MIT&color=2EA66F&labelColor=162033&style=for-the-badge)](../LICENSE) [![15 simulated tests; not verified in game](https://img.shields.io/static/v1?label=tests&message=15+simulated&color=3B82B6&labelColor=162033&style=for-the-badge)](https://github.com/paell0/wow-forever-context-exporter/blob/main/tests/test_addon.py)

<!-- language-selector:start -->

[![English](https://img.shields.io/static/v1?label=EN&message=English&color=334155&labelColor=162033&style=flat-square)](../README.md) [![Español](https://img.shields.io/static/v1?label=ES&message=Espa%C3%B1ol&color=334155&labelColor=162033&style=flat-square)](README.es.md) [![Português (Brasil)](https://img.shields.io/static/v1?label=PT-BR&message=Portugu%C3%AAs+%28Brasil%29&color=334155&labelColor=162033&style=flat-square)](README.pt-BR.md) [![Français](https://img.shields.io/static/v1?label=FR&message=Fran%C3%A7ais&color=334155&labelColor=162033&style=flat-square)](README.fr.md) [![Deutsch](https://img.shields.io/static/v1?label=DE&message=Deutsch&color=334155&labelColor=162033&style=flat-square)](README.de.md)

[![简体中文](https://img.shields.io/static/v1?label=ZH-CN&message=%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87&color=334155&labelColor=162033&style=flat-square)](README.zh-CN.md) [![繁體中文](https://img.shields.io/static/v1?label=ZH-TW&message=%E7%B9%81%E9%AB%94%E4%B8%AD%E6%96%87&color=334155&labelColor=162033&style=flat-square)](README.zh-TW.md) [![日本語](https://img.shields.io/static/v1?label=JA&message=%E6%97%A5%E6%9C%AC%E8%AA%9E&color=334155&labelColor=162033&style=flat-square)](README.ja.md) [![हिन्दी](https://img.shields.io/static/v1?label=HI&message=%E0%A4%B9%E0%A4%BF%E0%A4%A8%E0%A5%8D%E0%A4%A6%E0%A5%80&color=334155&labelColor=162033&style=flat-square)](README.hi.md)

[![ไทย](https://img.shields.io/static/v1?label=TH&message=%E0%B9%84%E0%B8%97%E0%B8%A2&color=334155&labelColor=162033&style=flat-square)](README.th.md) [![한국어](https://img.shields.io/static/v1?label=KO&message=%ED%95%9C%EA%B5%AD%EC%96%B4&color=334155&labelColor=162033&style=flat-square)](README.ko.md) [![Русский](https://img.shields.io/static/v1?label=RU&message=%D0%A0%D1%83%D1%81%D1%81%D0%BA%D0%B8%D0%B9&color=334155&labelColor=162033&style=flat-square)](README.ru.md) [![Italiano (selected)](https://img.shields.io/static/v1?label=IT&message=Italiano&color=D4A64A&labelColor=162033&style=flat-square)](README.it.md)

<!-- language-selector:end -->

Esporta talenti, professioni, equipaggiamento e statistiche del tuo personaggio di WoW Forever come testo per chiedere consigli a un’IA.

## Installazione e utilizzo

1. Scarica `ForeverContext-1.0.1.zip` da [Releases](https://github.com/paell0/wow-forever-context-exporter/releases).
2. Chiudi il gioco ed estrai la cartella `ForeverContext` in `World of Warcraft/_forever_/Interface/AddOns/`.
3. Verifica il percorso `AddOns/ForeverContext/ForeverContext.toc` e attiva l’addon. Se hai installato il vecchio ContextoPJ, rimuovi prima la sua cartella.
4. Fuori dal combattimento, digita **`/fcontext`**.
5. Se vuoi, indica il tuo obiettivo. Premi **Generate / refresh**, poi **Select all** e **Ctrl+C**. Incolla il testo nell’IA con **Ctrl+V**.

Alias: `/forevercontext` e `/pjia`. Aiuto: `/fcontext help`.

## Informazioni esportate

Classe, razza, livello, esperienza, talenti attivi e punti disponibili; professioni e livelli; oggetti equipaggiati con statistiche, effetti, incantamenti, gemme e integrità; potenziamenti leggibili e famiglio evocato. L’opzione estesa aggiunge abilità, incantesimi conosciuti, missioni e reputazioni consultabili. Il rapporto contiene già una richiesta di analisi per l’IA.

## Stato e limiti

Anteprima pubblica per l’interfaccia **16001**. Superati **15 test simulati con Lua 5.1**; l’addon non è ancora stato provato in una sessione reale di WoW Forever.

Il nome del personaggio è escluso per impostazione predefinita. L’addon non trasmette dati e non richiede chiavi API. Borse e banca non sono incluse. Le modifiche ai talenti non applicate non vengono presentate come attive. I dati mancanti sono segnalati: apri Talenti/Professioni e genera di nuovo il rapporto.

Pulsanti ed etichette del rapporto sono in inglese; nomi e descrizioni del gioco mantengono la lingua del client. Questa è una traduzione della documentazione. Consulta il [README principale](../README.md) per sviluppo e limiti completi. Licenza [MIT](../LICENSE).
