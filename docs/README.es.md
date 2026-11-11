# ForeverContext

[![Version 1.4.0](https://img.shields.io/static/v1?label=version&message=1.4.0&color=D4A64A&labelColor=162033&style=for-the-badge)](https://github.com/paell0/wow-forever-context-exporter/releases/tag/v1.4.0) [![Public preview](https://img.shields.io/static/v1?label=status&message=public+preview&color=E8A838&labelColor=162033&style=for-the-badge)](https://github.com/paell0/wow-forever-context-exporter#privacy-and-limitations) [![Lua 5.1](https://img.shields.io/static/v1?label=Lua&message=5.1&color=2C2D72&labelColor=162033&style=for-the-badge&logo=lua&logoColor=white)](https://github.com/paell0/wow-forever-context-exporter/tree/main/ForeverContext) [![All Rights Reserved; prior MIT material retains its permissions](https://img.shields.io/static/v1?label=license&message=All+Rights+Reserved&color=B45309&labelColor=162033&style=for-the-badge)](../LICENSE) [![144 simulated tests; not verified in game](https://img.shields.io/static/v1?label=tests&message=144+simulated&color=3B82B6&labelColor=162033&style=for-the-badge)](https://github.com/paell0/wow-forever-context-exporter/blob/main/tests/test_addon.py)

<!-- language-selector:start -->

[![English](https://img.shields.io/static/v1?label=EN&message=English&color=334155&labelColor=162033&style=flat-square)](../README.md) [![Español (selected)](https://img.shields.io/static/v1?label=ES&message=Espa%C3%B1ol&color=D4A64A&labelColor=162033&style=flat-square)](README.es.md) [![Français](https://img.shields.io/static/v1?label=FR&message=Fran%C3%A7ais&color=334155&labelColor=162033&style=flat-square)](README.fr.md) [![Deutsch](https://img.shields.io/static/v1?label=DE&message=Deutsch&color=334155&labelColor=162033&style=flat-square)](README.de.md) [![Italiano](https://img.shields.io/static/v1?label=IT&message=Italiano&color=334155&labelColor=162033&style=flat-square)](README.it.md) [![Русский](https://img.shields.io/static/v1?label=RU&message=%D0%A0%D1%83%D1%81%D1%81%D0%BA%D0%B8%D0%B9&color=334155&labelColor=162033&style=flat-square)](README.ru.md)

[![Português (Brasil)](https://img.shields.io/static/v1?label=PT-BR&message=Portugu%C3%AAs+%28Brasil%29&color=334155&labelColor=162033&style=flat-square)](README.pt-BR.md)

[![简体中文](https://img.shields.io/static/v1?label=ZH-CN&message=%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87&color=334155&labelColor=162033&style=flat-square)](README.zh-CN.md) [![繁體中文](https://img.shields.io/static/v1?label=ZH-TW&message=%E7%B9%81%E9%AB%94%E4%B8%AD%E6%96%87&color=334155&labelColor=162033&style=flat-square)](README.zh-TW.md) [![日本語](https://img.shields.io/static/v1?label=JA&message=%E6%97%A5%E6%9C%AC%E8%AA%9E&color=334155&labelColor=162033&style=flat-square)](README.ja.md) [![한국어](https://img.shields.io/static/v1?label=KO&message=%ED%95%9C%EA%B5%AD%EC%96%B4&color=334155&labelColor=162033&style=flat-square)](README.ko.md) [![हिन्दी](https://img.shields.io/static/v1?label=HI&message=%E0%A4%B9%E0%A4%BF%E0%A4%A8%E0%A5%8D%E0%A4%A6%E0%A5%80&color=334155&labelColor=162033&style=flat-square)](README.hi.md) [![ไทย](https://img.shields.io/static/v1?label=TH&message=%E0%B9%84%E0%B8%97%E0%B8%A2&color=334155&labelColor=162033&style=flat-square)](README.th.md)

<!-- language-selector:end -->

Exporta los talentos, profesiones, equipo y estadísticas de tu personaje de WoW Forever como texto para pedir consejo a una IA.

También puedes abrir o cerrar el informe haciendo clic en el botón del minimapa. Arrástralo para cambiar su posición; esta se guarda entre sesiones. Usa `/fcontext minimap` para ocultarlo o volver a mostrarlo.

El informe consulta las descripciones de talentos para su rango actual y señala las descripciones genéricas no verificadas. Distingue bonos de conjunto activos, inactivos o desconocidos y omite el daño de mano izquierda si no hay un arma en ese hueco. También elimina alias de resistencia duplicados cuando sus valores coinciden.

La versión 1.1.0 añade un plan de progreso por personaje, comparación de dos objetos, informes según la pregunta y revisión de consejos anteriores. Pulsa **Progress plan** para pegar el bloque de plan que devuelve la IA, revisarlo con **Preview plan** y aceptarlo con **Accept plan**. Los objetivos verificables se actualizan con los datos del personaje; los manuales tienen casillas. **Compare items** permite arrastrar dos objetos y generar su comparación para la IA. Usa **Talent points**, **Gear advice**, **Next session** o **Review plan** para elegir el contexto. Los informes incluyen los objetivos aceptados y los cambios observados desde su referencia. [Guía completa y formato de planes, en inglés](PROGRESS-PLAN.md).


La versión 1.2.0 añade siete mejoras: fuentes de objetos con referencias y estado de confirmación; perfiles de talentos por actividad; avisos por cambio de versión; exportación opcional de bolsas; lista de objetos que conservar; modo sin spoilers; y categorías configurables. Abre **Item sources**, **Talent profiles**, **Browse bags**, **Keep items** y **Export options**. Las fuentes observadas, confirmadas por el jugador y sin confirmar se distinguen; no se incluye una base completa de botín. [Guía de las siete herramientas, en inglés](COMMUNITY-TOOLS.md).


La versión 1.4 simplifica el uso: **1. Preparar texto → 2. Seleccionar texto → Ctrl+C**; después abre tu IA y pega con **Ctrl+V**. **Herramientas** explica las funciones opcionales. **Ajustes** muestra primero las opciones básicas. La comparación y los planes tienen pasos numerados. [Guía para empezar, en inglés](QUICKSTART.md).

## Instalación y uso

1. Descarga `ForeverContext-1.4.0.zip` desde [Releases](https://github.com/paell0/wow-forever-context-exporter/releases).
2. Con el juego cerrado, descomprime la carpeta `ForeverContext` en `World of Warcraft/_forever_/Interface/AddOns/`.
3. Comprueba que exista `AddOns/ForeverContext/ForeverContext.toc` y activa el addon.
4. Fuera de combate, escribe **`/fcontext`**. Si instalaste ContextoPJ anteriormente, elimina su carpeta para evitar duplicados.
5. Escribe tu objetivo si quieres, pulsa **1. Preparar texto**, después **2. Seleccionar texto** y **Ctrl+C**. Pega el texto en la IA con **Ctrl+V**.

También puedes usar `/forevercontext` o `/pjia`. La ayuda se muestra con `/fcontext help`.

## Qué incluye

Clase, raza, nivel, experiencia, talentos activos y puntos disponibles; profesiones y niveles; objetos equipados con estadísticas, efectos, encantamientos, gemas y durabilidad; buffs y mascota invocada. Opcionalmente incluye habilidades, hechizos, misiones y reputaciones consultables. El informe ya contiene una petición de análisis para la IA.

## Estado y límites

Vista previa pública para la interfaz **16001**. Han pasado **144 pruebas simuladas con Lua 5.1**; esta versión todavía necesita verificación dentro del juego. Versiones anteriores ya han generado informes reales y han permitido detectar fallos de interfaz.

El nombre del personaje se omite por defecto. El addon no transmite información ni requiere clave de API. Las bolsas se exportan solo si lo activas; banco, correo y otros personajes quedan fuera. Perfiles, fuentes y preferencias se guardan por personaje. El modo sin spoilers filtra el informe y solicita ese estilo a la IA, pero no controla su respuesta ni borra tus propios textos. Los datos pendientes o restringidos se indican como desconocidos. Esta versión necesita verificación dentro del juego.

La interfaz detecta el idioma del juego y permite cambiarlo desde **Ajustes → Idioma** o `/fcontext language`. Hay 10 idiomas disponibles; el informe sigue en inglés y los nombres del juego mantienen el idioma del cliente. La elección se guarda para toda la cuenta y se aplica sin recargar. [Guía de idiomas](LOCALIZATION.md). [README](../README.md) · [All Rights Reserved](../LICENSE).

Todos los derechos reservados para el material nuevo desde v1.0.2. Se permite el uso personal de versiones oficiales sin modificar y preparar cambios únicamente para una PR al repositorio oficial; su aceptación depende del mantenedor. No se autoriza la comercialización ni la publicación de versiones alternativas. El material previamente publicado bajo MIT conserva esos permisos: este cambio no los revoca. Consulta los términos completos en inglés en [LICENSE](../LICENSE).
