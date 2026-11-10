# ForeverContext

[English](../README.md) | [Español](README.es.md) | [Português (Brasil)](README.pt-BR.md) | [Français](README.fr.md) | [Deutsch](README.de.md) | [简体中文](README.zh-CN.md) | [繁體中文](README.zh-TW.md) | [日本語](README.ja.md) | [हिन्दी](README.hi.md) | [ไทย](README.th.md) | [한국어](README.ko.md) | [Русский](README.ru.md) | [Italiano](README.it.md)

Exportez les talents, métiers, équipements et statistiques de votre personnage de WoW Forever sous forme de texte pour demander conseil à une IA.

## Installation et utilisation

1. Téléchargez `ForeverContext-1.0.1.zip` depuis les [Releases](https://github.com/paell0/wow-forever-context-exporter/releases).
2. Fermez le jeu et extrayez le dossier `ForeverContext` dans `World of Warcraft/_forever_/Interface/AddOns/`.
3. Vérifiez le chemin `AddOns/ForeverContext/ForeverContext.toc` et activez l’addon. Supprimez l’ancien dossier ContextoPJ si nécessaire.
4. Hors combat, saisissez **`/fcontext`**.
5. Indiquez éventuellement votre objectif, puis cliquez sur **Generate / refresh**, **Select all** et appuyez sur **Ctrl+C**. Collez le rapport dans votre IA avec **Ctrl+V**.

Alias : `/forevercontext` et `/pjia`. Aide : `/fcontext help`.

## Contenu du rapport

Classe, race, niveau, expérience, talents actifs et points disponibles ; métiers et niveaux ; objets équipés avec statistiques, effets, enchantements, gemmes et durabilité ; améliorations et familier invoqué. Le mode étendu ajoute les compétences, sorts connus, quêtes et réputations consultables. Une demande d’analyse est déjà incluse.

## État et limites

Version préliminaire publique pour l’interface **16001**. **15 tests Lua 5.1 simulés** réussis ; aucun test dans une session réelle de WoW Forever pour le moment.

Le nom du personnage est masqué par défaut. L’addon ne transmet aucune donnée et ne demande aucune clé API. Il n’exporte ni sacs ni banque. Les changements de talents non appliqués ne sont pas présentés comme actifs. Les données manquantes sont signalées : ouvrez Talents/Métiers et générez à nouveau.

Les commandes visuelles et les libellés sont en anglais ; les textes du jeu restent dans la langue du client. Cette traduction concerne la documentation. Voir le [README principal](../README.md) pour le développement et les limites détaillées. Licence [MIT](../LICENSE).
