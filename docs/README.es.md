# ForeverContext

[English](../README.md) | [Español](README.es.md) | [Português (Brasil)](README.pt-BR.md) | [Français](README.fr.md) | [Deutsch](README.de.md) | [简体中文](README.zh-CN.md) | [繁體中文](README.zh-TW.md) | [日本語](README.ja.md) | [हिन्दी](README.hi.md) | [ไทย](README.th.md) | [한국어](README.ko.md) | [Русский](README.ru.md) | [Italiano](README.it.md)

Exporta los talentos, profesiones, equipo y estadísticas de tu personaje de WoW Forever como texto para pedir consejo a una IA.

## Instalación y uso

1. Descarga `ForeverContext-1.0.1.zip` desde [Releases](https://github.com/paell0/wow-forever-context-exporter/releases).
2. Con el juego cerrado, descomprime la carpeta `ForeverContext` en `World of Warcraft/_forever_/Interface/AddOns/`.
3. Comprueba que exista `AddOns/ForeverContext/ForeverContext.toc` y activa el addon.
4. Fuera de combate, escribe **`/fcontext`**. Si instalaste ContextoPJ anteriormente, elimina su carpeta para evitar duplicados.
5. Escribe tu objetivo si quieres, pulsa **Generate / refresh**, después **Select all** y **Ctrl+C**. Pega el texto en la IA con **Ctrl+V**.

También puedes usar `/forevercontext` o `/pjia`. La ayuda se muestra con `/fcontext help`.

## Qué incluye

Clase, raza, nivel, experiencia, talentos activos y puntos disponibles; profesiones y niveles; objetos equipados con estadísticas, efectos, encantamientos, gemas y durabilidad; buffs y mascota invocada. Opcionalmente incluye habilidades, hechizos, misiones y reputaciones consultables. El informe ya contiene una petición de análisis para la IA.

## Estado y límites

Vista previa pública para la interfaz **16001**. Han pasado **15 pruebas simuladas con Lua 5.1**; todavía no se ha probado en una sesión real de WoW Forever.

El nombre del personaje se omite por defecto. El addon no transmite información ni requiere una clave de API. Solo exporta el equipo puesto, no bolsas ni banco. No presenta cambios de talentos sin aplicar como si fueran activos y señala los datos pendientes. Abre Talentos/Profesiones y vuelve a generar si faltan datos.

Los controles y etiquetas del informe están en inglés; nombres y descripciones del juego conservan el idioma de tu cliente. Esta traducción es de la documentación. Consulta el [README principal](../README.md) para desarrollo y límites completos. Licencia [MIT](../LICENSE).
