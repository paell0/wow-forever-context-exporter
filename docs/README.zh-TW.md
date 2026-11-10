# ForeverContext

[![Version 1.0.1](https://img.shields.io/static/v1?label=version&message=1.0.1&color=D4A64A&labelColor=162033&style=for-the-badge)](https://github.com/paell0/wow-forever-context-exporter/releases/tag/v1.0.1) [![Public preview](https://img.shields.io/static/v1?label=status&message=public+preview&color=E8A838&labelColor=162033&style=for-the-badge)](https://github.com/paell0/wow-forever-context-exporter#privacy-and-limitations) [![Lua 5.1](https://img.shields.io/static/v1?label=Lua&message=5.1&color=2C2D72&labelColor=162033&style=for-the-badge&logo=lua&logoColor=white)](https://github.com/paell0/wow-forever-context-exporter/tree/main/ForeverContext) [![MIT license](https://img.shields.io/static/v1?label=license&message=MIT&color=2EA66F&labelColor=162033&style=for-the-badge)](../LICENSE) [![15 simulated tests; not verified in game](https://img.shields.io/static/v1?label=tests&message=15+simulated&color=3B82B6&labelColor=162033&style=for-the-badge)](https://github.com/paell0/wow-forever-context-exporter/blob/main/tests/test_addon.py)

<!-- language-selector:start -->

[![English](https://img.shields.io/static/v1?label=EN&message=English&color=334155&labelColor=162033&style=flat-square)](../README.md) [![Español](https://img.shields.io/static/v1?label=ES&message=Espa%C3%B1ol&color=334155&labelColor=162033&style=flat-square)](README.es.md) [![Português (Brasil)](https://img.shields.io/static/v1?label=PT-BR&message=Portugu%C3%AAs+%28Brasil%29&color=334155&labelColor=162033&style=flat-square)](README.pt-BR.md) [![Français](https://img.shields.io/static/v1?label=FR&message=Fran%C3%A7ais&color=334155&labelColor=162033&style=flat-square)](README.fr.md) [![Deutsch](https://img.shields.io/static/v1?label=DE&message=Deutsch&color=334155&labelColor=162033&style=flat-square)](README.de.md)

[![简体中文](https://img.shields.io/static/v1?label=ZH-CN&message=%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87&color=334155&labelColor=162033&style=flat-square)](README.zh-CN.md) [![繁體中文 (selected)](https://img.shields.io/static/v1?label=ZH-TW&message=%E7%B9%81%E9%AB%94%E4%B8%AD%E6%96%87&color=D4A64A&labelColor=162033&style=flat-square)](README.zh-TW.md) [![日本語](https://img.shields.io/static/v1?label=JA&message=%E6%97%A5%E6%9C%AC%E8%AA%9E&color=334155&labelColor=162033&style=flat-square)](README.ja.md) [![हिन्दी](https://img.shields.io/static/v1?label=HI&message=%E0%A4%B9%E0%A4%BF%E0%A4%A8%E0%A5%8D%E0%A4%A6%E0%A5%80&color=334155&labelColor=162033&style=flat-square)](README.hi.md)

[![ไทย](https://img.shields.io/static/v1?label=TH&message=%E0%B9%84%E0%B8%97%E0%B8%A2&color=334155&labelColor=162033&style=flat-square)](README.th.md) [![한국어](https://img.shields.io/static/v1?label=KO&message=%ED%95%9C%EA%B5%AD%EC%96%B4&color=334155&labelColor=162033&style=flat-square)](README.ko.md) [![Русский](https://img.shields.io/static/v1?label=RU&message=%D0%A0%D1%83%D1%81%D1%81%D0%BA%D0%B8%D0%B9&color=334155&labelColor=162033&style=flat-square)](README.ru.md) [![Italiano](https://img.shields.io/static/v1?label=IT&message=Italiano&color=334155&labelColor=162033&style=flat-square)](README.it.md)

<!-- language-selector:end -->

將 WoW Forever 角色的天賦、專業、裝備與屬性匯出為純文字，方便向 AI 尋求建議。

## 安裝與使用

1. 從 [Releases](https://github.com/paell0/wow-forever-context-exporter/releases) 下載 `ForeverContext-1.0.1.zip`。
2. 關閉遊戲，將 `ForeverContext` 資料夾解壓至 `World of Warcraft/_forever_/Interface/AddOns/`。
3. 確認路徑為 `AddOns/ForeverContext/ForeverContext.toc`，然後啟用插件。若曾安裝舊版 ContextoPJ，請先移除其資料夾。
4. 在非戰鬥狀態下輸入 **`/fcontext`**。
5. 可填寫你的目標，按 **Generate / refresh**，再按 **Select all**，使用 **Ctrl+C** 複製，並以 **Ctrl+V** 貼到 AI。

別名：`/forevercontext`、`/pjia`。說明：`/fcontext help`。

## 匯出內容

職業、種族、等級、經驗值、目前天賦與可用點數；專業及技能等級；已裝備物品的屬性、效果、附魔、寶石與耐久度；可讀取的增益與目前召喚的寵物。擴充選項包含技能、已學法術、任務及可查詢的聲望。報告已附分析請求。

## 狀態與限制

適用於介面版本 **16001** 的公開預覽版。已通過 **15 項模擬 Lua 5.1 測試**，尚未於真實 WoW Forever 遊戲工作階段驗證。

預設不匯出角色姓名。插件不會傳送資料，也不需要 API 金鑰。不包含背包或銀行。未套用的天賦變更不會列為目前天賦；待載入與無法取得的資料會明確標示。如有缺漏，請開啟天賦或專業視窗後重新產生。

插件介面與報告標籤為英文，遊戲提供的名稱及說明保留用戶端語言。這裡僅翻譯文件，不代表新增用戶端語言支援。開發說明與完整限制請見[英文 README](../README.md)。授權條款：[MIT](../LICENSE)。
