# ForeverContext

[![Version 1.4.0](https://img.shields.io/static/v1?label=version&message=1.4.0&color=D4A64A&labelColor=162033&style=for-the-badge)](https://github.com/paell0/wow-forever-context-exporter/releases/tag/v1.4.0) [![Public preview](https://img.shields.io/static/v1?label=status&message=public+preview&color=E8A838&labelColor=162033&style=for-the-badge)](https://github.com/paell0/wow-forever-context-exporter#privacy-and-limitations) [![Lua 5.1](https://img.shields.io/static/v1?label=Lua&message=5.1&color=2C2D72&labelColor=162033&style=for-the-badge&logo=lua&logoColor=white)](https://github.com/paell0/wow-forever-context-exporter/tree/main/ForeverContext) [![All Rights Reserved; prior MIT material retains its permissions](https://img.shields.io/static/v1?label=license&message=All+Rights+Reserved&color=B45309&labelColor=162033&style=for-the-badge)](../LICENSE) [![144 simulated tests; not verified in game](https://img.shields.io/static/v1?label=tests&message=144+simulated&color=3B82B6&labelColor=162033&style=for-the-badge)](https://github.com/paell0/wow-forever-context-exporter/blob/main/tests/test_addon.py)

<!-- language-selector:start -->

[![English](https://img.shields.io/static/v1?label=EN&message=English&color=334155&labelColor=162033&style=flat-square)](../README.md) [![Español](https://img.shields.io/static/v1?label=ES&message=Espa%C3%B1ol&color=334155&labelColor=162033&style=flat-square)](README.es.md) [![Français](https://img.shields.io/static/v1?label=FR&message=Fran%C3%A7ais&color=334155&labelColor=162033&style=flat-square)](README.fr.md) [![Deutsch](https://img.shields.io/static/v1?label=DE&message=Deutsch&color=334155&labelColor=162033&style=flat-square)](README.de.md) [![Italiano (selected)](https://img.shields.io/static/v1?label=IT&message=Italiano&color=D4A64A&labelColor=162033&style=flat-square)](README.it.md) [![Русский](https://img.shields.io/static/v1?label=RU&message=%D0%A0%D1%83%D1%81%D1%81%D0%BA%D0%B8%D0%B9&color=334155&labelColor=162033&style=flat-square)](README.ru.md)

[![Português (Brasil)](https://img.shields.io/static/v1?label=PT-BR&message=Portugu%C3%AAs+%28Brasil%29&color=334155&labelColor=162033&style=flat-square)](README.pt-BR.md)

[![简体中文](https://img.shields.io/static/v1?label=ZH-CN&message=%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87&color=334155&labelColor=162033&style=flat-square)](README.zh-CN.md) [![繁體中文](https://img.shields.io/static/v1?label=ZH-TW&message=%E7%B9%81%E9%AB%94%E4%B8%AD%E6%96%87&color=334155&labelColor=162033&style=flat-square)](README.zh-TW.md) [![日本語](https://img.shields.io/static/v1?label=JA&message=%E6%97%A5%E6%9C%AC%E8%AA%9E&color=334155&labelColor=162033&style=flat-square)](README.ja.md) [![한국어](https://img.shields.io/static/v1?label=KO&message=%ED%95%9C%EA%B5%AD%EC%96%B4&color=334155&labelColor=162033&style=flat-square)](README.ko.md) [![हिन्दी](https://img.shields.io/static/v1?label=HI&message=%E0%A4%B9%E0%A4%BF%E0%A4%A8%E0%A5%8D%E0%A4%A6%E0%A5%80&color=334155&labelColor=162033&style=flat-square)](README.hi.md) [![ไทย](https://img.shields.io/static/v1?label=TH&message=%E0%B9%84%E0%B8%97%E0%B8%A2&color=334155&labelColor=162033&style=flat-square)](README.th.md)

<!-- language-selector:end -->

Esporta talenti, professioni, equipaggiamento e statistiche del tuo personaggio di WoW Forever come testo per chiedere consigli a un’IA.

Puoi aprire o chiudere il rapporto anche con il pulsante della minimappa. Trascinalo per cambiarne la posizione, che viene salvata tra le sessioni. Usa `/fcontext minimap` per nascondere o mostrare il pulsante.

Il rapporto richiede le descrizioni dei talenti al grado attuale e segnala i riferimenti generici non verificati. Distingue i bonus di completo attivi, inattivi o sconosciuti e omette i danni della mano secondaria se non contiene un’arma. Gli alias di resistenza duplicati con valori uguali vengono unificati.

La versione 1.1.0 aggiunge piani per personaggio, confronto tra due oggetti, rapporti mirati e revisione dei consigli precedenti. Incolla il blocco dell’IA in **Progress plan**, controllalo con **Preview plan** e confermalo con **Accept plan**. Gli obiettivi verificabili usano i dati del personaggio; gli altri si spuntano manualmente. Trascina due oggetti in **Compare items**. Scegli **Talent points**, **Gear advice**, **Next session** o **Review plan**. I rapporti includono gli obiettivi accettati e i cambiamenti osservati rispetto al riferimento. [Guida completa e formato dei piani in inglese](PROGRESS-PLAN.md).


La versione 1.2.0 aggiunge sette funzioni: fonti degli oggetti con riferimenti e conferma, profili talenti per attività, avvisi di versione, esportazione facoltativa delle borse, elenco degli oggetti da conservare, modalità senza spoiler e categorie configurabili. Apri **Item sources**, **Talent profiles**, **Browse bags**, **Keep items** e **Export options**. Osservazioni del gioco, conferme del giocatore e note non confermate sono distinte; non è incluso un database completo del bottino. [Guida dei sette strumenti in inglese](COMMUNITY-TOOLS.md).


La versione 1.4 semplifica l’uso: **1. Prepara il testo → 2. Seleziona il testo → Ctrl+C**, poi incolla nella tua IA con **Ctrl+V**. **Altri strumenti** spiega le funzioni facoltative. Le impostazioni mostrano prima le opzioni semplici. Confronti e piani hanno passaggi numerati. [Guida iniziale in inglese](QUICKSTART.md).

## Installazione e utilizzo

1. Scarica `ForeverContext-1.4.0.zip` da [Releases](https://github.com/paell0/wow-forever-context-exporter/releases).
2. Chiudi il gioco ed estrai la cartella `ForeverContext` in `World of Warcraft/_forever_/Interface/AddOns/`.
3. Verifica il percorso `AddOns/ForeverContext/ForeverContext.toc` e attiva l’addon. Se hai installato il vecchio ContextoPJ, rimuovi prima la sua cartella.
4. Fuori dal combattimento, digita **`/fcontext`**.
5. Se vuoi, indica il tuo obiettivo. Premi **1. Prepare text**, poi **2. Select text** e **Ctrl+C**. Incolla il testo nell’IA con **Ctrl+V**.

Alias: `/forevercontext` e `/pjia`. Aiuto: `/fcontext help`.

## Informazioni esportate

Classe, razza, livello, esperienza, talenti attivi e punti disponibili; professioni e livelli; oggetti equipaggiati con statistiche, effetti, incantamenti, gemme e integrità; potenziamenti leggibili e famiglio evocato. L’opzione estesa aggiunge abilità, incantesimi conosciuti, missioni e reputazioni consultabili. Il rapporto contiene già una richiesta di analisi per l’IA.

## Stato e limiti

Anteprima pubblica per l’interfaccia **16001**. Superati **144 test simulati con Lua 5.1**; l’addon non è ancora stato provato in una sessione reale di WoW Forever.

Il nome del personaggio è nascosto per impostazione predefinita. Non vengono trasmessi dati e non serve una chiave API. Le borse sono esportate solo se abilitate; banca, posta e altri personaggi sono esclusi. Profili, fonti e preferenze sono salvati per personaggio. La modalità senza spoiler filtra il rapporto e istruisce l’IA, ma non controlla la risposta né elimina i tuoi testi. I dati mancanti restano sconosciuti. Questa versione richiede ancora verifica nel gioco.

L’interfaccia segue la lingua del gioco e permette di cambiarla nelle opzioni di esportazione o con `/fcontext language`. Sono disponibili 10 lingue; il rapporto resta in inglese e i nomi del gioco mantengono la lingua del client. La scelta si applica subito a tutto l’account. [Guida alle lingue](LOCALIZATION.md). [README](../README.md) · [All Rights Reserved](../LICENSE).

Tutti i diritti sui nuovi contenuti originali dalla v1.0.2 sono riservati, salvo i permessi indicati. Sono consentiti l’uso personale delle versioni ufficiali non modificate e le modifiche preparate esclusivamente per una PR al repository ufficiale; l’accettazione spetta al manutentore. Non sono autorizzate la commercializzazione o la pubblicazione di versioni alternative. I contenuti già pubblicati sotto MIT mantengono quei permessi: questa modifica non li revoca. Termini completi in inglese: [LICENSE](../LICENSE).
