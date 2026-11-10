# ForeverContext

[English](../README.md) | [Español](README.es.md) | [Português (Brasil)](README.pt-BR.md) | [Français](README.fr.md) | [Deutsch](README.de.md) | [简体中文](README.zh-CN.md) | [繁體中文](README.zh-TW.md) | [日本語](README.ja.md) | [हिन्दी](README.hi.md) | [ไทย](README.th.md) | [한국어](README.ko.md) | [Русский](README.ru.md) | [Italiano](README.it.md)

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
