# ForeverContext

[![Version 1.3.0](https://img.shields.io/static/v1?label=version&message=1.3.0&color=D4A64A&labelColor=162033&style=for-the-badge)](https://github.com/paell0/wow-forever-context-exporter/releases/tag/v1.3.0) [![Public preview](https://img.shields.io/static/v1?label=status&message=public+preview&color=E8A838&labelColor=162033&style=for-the-badge)](https://github.com/paell0/wow-forever-context-exporter#privacy-and-limitations) [![Lua 5.1](https://img.shields.io/static/v1?label=Lua&message=5.1&color=2C2D72&labelColor=162033&style=for-the-badge&logo=lua&logoColor=white)](https://github.com/paell0/wow-forever-context-exporter/tree/main/ForeverContext) [![All Rights Reserved; prior MIT material retains its permissions](https://img.shields.io/static/v1?label=license&message=All+Rights+Reserved&color=B45309&labelColor=162033&style=for-the-badge)](../LICENSE) [![132 simulated tests; not verified in game](https://img.shields.io/static/v1?label=tests&message=132+simulated&color=3B82B6&labelColor=162033&style=for-the-badge)](https://github.com/paell0/wow-forever-context-exporter/blob/main/tests/test_addon.py)

<!-- language-selector:start -->

[![English](https://img.shields.io/static/v1?label=EN&message=English&color=334155&labelColor=162033&style=flat-square)](../README.md) [![Español](https://img.shields.io/static/v1?label=ES&message=Espa%C3%B1ol&color=334155&labelColor=162033&style=flat-square)](README.es.md) [![Français (selected)](https://img.shields.io/static/v1?label=FR&message=Fran%C3%A7ais&color=D4A64A&labelColor=162033&style=flat-square)](README.fr.md) [![Deutsch](https://img.shields.io/static/v1?label=DE&message=Deutsch&color=334155&labelColor=162033&style=flat-square)](README.de.md) [![Italiano](https://img.shields.io/static/v1?label=IT&message=Italiano&color=334155&labelColor=162033&style=flat-square)](README.it.md) [![Русский](https://img.shields.io/static/v1?label=RU&message=%D0%A0%D1%83%D1%81%D1%81%D0%BA%D0%B8%D0%B9&color=334155&labelColor=162033&style=flat-square)](README.ru.md)

[![Português (Brasil)](https://img.shields.io/static/v1?label=PT-BR&message=Portugu%C3%AAs+%28Brasil%29&color=334155&labelColor=162033&style=flat-square)](README.pt-BR.md)

[![简体中文](https://img.shields.io/static/v1?label=ZH-CN&message=%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87&color=334155&labelColor=162033&style=flat-square)](README.zh-CN.md) [![繁體中文](https://img.shields.io/static/v1?label=ZH-TW&message=%E7%B9%81%E9%AB%94%E4%B8%AD%E6%96%87&color=334155&labelColor=162033&style=flat-square)](README.zh-TW.md) [![日本語](https://img.shields.io/static/v1?label=JA&message=%E6%97%A5%E6%9C%AC%E8%AA%9E&color=334155&labelColor=162033&style=flat-square)](README.ja.md) [![한국어](https://img.shields.io/static/v1?label=KO&message=%ED%95%9C%EA%B5%AD%EC%96%B4&color=334155&labelColor=162033&style=flat-square)](README.ko.md) [![हिन्दी](https://img.shields.io/static/v1?label=HI&message=%E0%A4%B9%E0%A4%BF%E0%A4%A8%E0%A5%8D%E0%A4%A6%E0%A5%80&color=334155&labelColor=162033&style=flat-square)](README.hi.md) [![ไทย](https://img.shields.io/static/v1?label=TH&message=%E0%B9%84%E0%B8%97%E0%B8%A2&color=334155&labelColor=162033&style=flat-square)](README.th.md)

<!-- language-selector:end -->

Exportez les talents, métiers, équipements et statistiques de votre personnage de WoW Forever sous forme de texte pour demander conseil à une IA.

Vous pouvez également ouvrir ou fermer le rapport avec le bouton de la minicarte. Faites-le glisser pour déplacer sa position, conservée entre les sessions. Utilisez `/fcontext minimap` pour masquer ou afficher le bouton.

Le rapport consulte les descriptions des talents au rang actuel et signale les références génériques non vérifiées. Il distingue les bonus d’ensemble actifs, inactifs ou inconnus et omet les dégâts de main gauche sans arme dans cet emplacement. Les alias de résistance identiques sont dédupliqués.

La version 1.1.0 ajoute des plans par personnage, la comparaison de deux objets, des rapports ciblés et la révision des conseils précédents. Dans **Progress plan**, collez le bloc fourni par l’IA, vérifiez-le avec **Preview plan**, puis acceptez-le avec **Accept plan**. Les objectifs vérifiables utilisent les données du personnage ; les tâches manuelles ont des cases. **Compare items** accepte deux objets glissés. Choisissez **Talent points**, **Gear advice**, **Next session** ou **Review plan** pour cibler le rapport. Les objectifs acceptés et les changements observés sont inclus. [Guide complet et format des plans, en anglais](PROGRESS-PLAN.md).


La version 1.2.0 ajoute sept améliorations : sources des objets avec références et confirmation, profils de talents par activité, avertissements de version, export facultatif des sacs, liste des objets à conserver, mode sans spoilers et catégories configurables. Ouvrez **Item sources**, **Talent profiles**, **Browse bags**, **Keep items** et **Export options**. Les observations du jeu, confirmations du joueur et notes non confirmées restent distinctes ; aucune base de butin complète n’est fournie. [Guide des sept outils en anglais](COMMUNITY-TOOLS.md).

## Installation et utilisation

1. Téléchargez `ForeverContext-1.3.0.zip` depuis les [Releases](https://github.com/paell0/wow-forever-context-exporter/releases).
2. Fermez le jeu et extrayez le dossier `ForeverContext` dans `World of Warcraft/_forever_/Interface/AddOns/`.
3. Vérifiez le chemin `AddOns/ForeverContext/ForeverContext.toc` et activez l’addon. Supprimez l’ancien dossier ContextoPJ si nécessaire.
4. Hors combat, saisissez **`/fcontext`**.
5. Indiquez éventuellement votre objectif, puis cliquez sur **Generate / refresh**, **Select all** et appuyez sur **Ctrl+C**. Collez le rapport dans votre IA avec **Ctrl+V**.

Alias : `/forevercontext` et `/pjia`. Aide : `/fcontext help`.

## Contenu du rapport

Classe, race, niveau, expérience, talents actifs et points disponibles ; métiers et niveaux ; objets équipés avec statistiques, effets, enchantements, gemmes et durabilité ; améliorations et familier invoqué. Le mode étendu ajoute les compétences, sorts connus, quêtes et réputations consultables. Une demande d’analyse est déjà incluse.

## État et limites

Version préliminaire publique pour l’interface **16001**. **132 tests Lua 5.1 simulés** réussis ; aucun test dans une session réelle de WoW Forever pour le moment.

Le nom du personnage est masqué par défaut. Aucune transmission ni clé API n’est requise. Les sacs ne sont exportés que sur activation ; banque, courrier et autres personnages sont exclus. Profils, sources et préférences sont enregistrés par personnage. Le mode sans spoilers filtre le rapport et donne une consigne à l’IA, sans contrôler sa réponse ni supprimer vos propres textes. Les données indisponibles restent inconnues. Cette version doit encore être vérifiée en jeu.

L’interface suit la langue du jeu et permet de la modifier dans les options d’export ou avec `/fcontext language`. Dix langues sont disponibles ; le rapport reste en anglais et les noms du jeu conservent la langue du client. Le choix s’applique immédiatement à tout le compte. [Guide des langues](LOCALIZATION.md). [README](../README.md) · [All Rights Reserved](../LICENSE).

Tous droits réservés pour les nouveaux éléments à partir de la v1.0.2. L’utilisation personnelle des versions officielles non modifiées et les changements préparés uniquement pour une PR au dépôt officiel sont autorisés ; leur acceptation dépend du mainteneur. La commercialisation et la publication de versions alternatives ne sont pas autorisées. Les éléments déjà publiés sous MIT conservent ces permissions ; ce changement ne les révoque pas. Conditions complètes en anglais dans [LICENSE](../LICENSE).
