# ForeverContext

[![Version 1.0.1](https://img.shields.io/static/v1?label=version&message=1.0.1&color=D4A64A&labelColor=162033&style=for-the-badge)](https://github.com/paell0/wow-forever-context-exporter/releases/tag/v1.0.1) [![Public preview](https://img.shields.io/static/v1?label=status&message=public+preview&color=E8A838&labelColor=162033&style=for-the-badge)](https://github.com/paell0/wow-forever-context-exporter#privacy-and-limitations) [![Lua 5.1](https://img.shields.io/static/v1?label=Lua&message=5.1&color=2C2D72&labelColor=162033&style=for-the-badge&logo=lua&logoColor=white)](https://github.com/paell0/wow-forever-context-exporter/tree/main/ForeverContext) [![MIT license](https://img.shields.io/static/v1?label=license&message=MIT&color=2EA66F&labelColor=162033&style=for-the-badge)](../LICENSE) [![15 simulated tests; not verified in game](https://img.shields.io/static/v1?label=tests&message=15+simulated&color=3B82B6&labelColor=162033&style=for-the-badge)](https://github.com/paell0/wow-forever-context-exporter/blob/main/tests/test_addon.py)

<!-- language-selector:start -->

[![English](https://img.shields.io/static/v1?label=EN&message=English&color=334155&labelColor=162033&style=flat-square)](../README.md) [![Español](https://img.shields.io/static/v1?label=ES&message=Espa%C3%B1ol&color=334155&labelColor=162033&style=flat-square)](README.es.md) [![Français](https://img.shields.io/static/v1?label=FR&message=Fran%C3%A7ais&color=334155&labelColor=162033&style=flat-square)](README.fr.md) [![Deutsch](https://img.shields.io/static/v1?label=DE&message=Deutsch&color=334155&labelColor=162033&style=flat-square)](README.de.md) [![Italiano](https://img.shields.io/static/v1?label=IT&message=Italiano&color=334155&labelColor=162033&style=flat-square)](README.it.md) [![Русский (selected)](https://img.shields.io/static/v1?label=RU&message=%D0%A0%D1%83%D1%81%D1%81%D0%BA%D0%B8%D0%B9&color=D4A64A&labelColor=162033&style=flat-square)](README.ru.md)

[![Português (Brasil)](https://img.shields.io/static/v1?label=PT-BR&message=Portugu%C3%AAs+%28Brasil%29&color=334155&labelColor=162033&style=flat-square)](README.pt-BR.md)

[![简体中文](https://img.shields.io/static/v1?label=ZH-CN&message=%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87&color=334155&labelColor=162033&style=flat-square)](README.zh-CN.md) [![繁體中文](https://img.shields.io/static/v1?label=ZH-TW&message=%E7%B9%81%E9%AB%94%E4%B8%AD%E6%96%87&color=334155&labelColor=162033&style=flat-square)](README.zh-TW.md) [![日本語](https://img.shields.io/static/v1?label=JA&message=%E6%97%A5%E6%9C%AC%E8%AA%9E&color=334155&labelColor=162033&style=flat-square)](README.ja.md) [![한국어](https://img.shields.io/static/v1?label=KO&message=%ED%95%9C%EA%B5%AD%EC%96%B4&color=334155&labelColor=162033&style=flat-square)](README.ko.md) [![हिन्दी](https://img.shields.io/static/v1?label=HI&message=%E0%A4%B9%E0%A4%BF%E0%A4%A8%E0%A5%8D%E0%A4%A6%E0%A5%80&color=334155&labelColor=162033&style=flat-square)](README.hi.md) [![ไทย](https://img.shields.io/static/v1?label=TH&message=%E0%B9%84%E0%B8%97%E0%B8%A2&color=334155&labelColor=162033&style=flat-square)](README.th.md)

<!-- language-selector:end -->

Экспортируйте таланты, профессии, экипировку и характеристики персонажа WoW Forever в обычный текст, чтобы попросить совета у ИИ.

## Установка и использование

1. Скачайте `ForeverContext-1.0.1.zip` из раздела [Releases](https://github.com/paell0/wow-forever-context-exporter/releases).
2. Закройте игру и распакуйте папку `ForeverContext` в `World of Warcraft/_forever_/Interface/AddOns/`.
3. Проверьте путь `AddOns/ForeverContext/ForeverContext.toc` и включите аддон. Если установлен старый ContextoPJ, сначала удалите его папку.
4. Вне боя введите **`/fcontext`**.
5. При желании укажите цель. Нажмите **Generate / refresh**, затем **Select all** и **Ctrl+C**. Вставьте отчёт в ИИ с помощью **Ctrl+V**.

Другие команды: `/forevercontext` и `/pjia`. Справка: `/fcontext help`.

## Содержимое отчёта

Класс, раса, уровень, опыт, активные таланты и доступные очки; профессии и навыки; надетые предметы с характеристиками, эффектами, чарами, камнями и прочностью; доступные для чтения усиления и призванный питомец. Расширенный режим добавляет умения, изученные заклинания, задания и доступную репутацию. Запрос на анализ для ИИ уже включён.

## Статус и ограничения

Общедоступная предварительная версия для интерфейса **16001**. Пройдены **15 тестов в симуляции Lua 5.1**; в реальной игровой сессии WoW Forever аддон пока не проверялся.

Имя персонажа по умолчанию скрыто. Аддон не передаёт данные и не требует ключа API. Сумки и банк не экспортируются. Неприменённые изменения талантов не выдаются за активные. Недоступные данные отмечаются предупреждениями: откройте таланты или профессии и создайте отчёт заново.

Кнопки и подписи отчёта — на английском; названия и описания из игры сохраняют язык клиента. Это перевод документации, а не добавление языковой поддержки клиента. Разработка и полные ограничения описаны в [основном README](../README.md). Лицензия: [MIT](../LICENSE).
