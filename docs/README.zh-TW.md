# ForeverContext

[![Version 1.2.0](https://img.shields.io/static/v1?label=version&message=1.2.0&color=D4A64A&labelColor=162033&style=for-the-badge)](https://github.com/paell0/wow-forever-context-exporter/releases/tag/v1.2.0) [![Public preview](https://img.shields.io/static/v1?label=status&message=public+preview&color=E8A838&labelColor=162033&style=for-the-badge)](https://github.com/paell0/wow-forever-context-exporter#privacy-and-limitations) [![Lua 5.1](https://img.shields.io/static/v1?label=Lua&message=5.1&color=2C2D72&labelColor=162033&style=for-the-badge&logo=lua&logoColor=white)](https://github.com/paell0/wow-forever-context-exporter/tree/main/ForeverContext) [![All Rights Reserved; prior MIT material retains its permissions](https://img.shields.io/static/v1?label=license&message=All+Rights+Reserved&color=B45309&labelColor=162033&style=for-the-badge)](../LICENSE) [![114 simulated tests; not verified in game](https://img.shields.io/static/v1?label=tests&message=114+simulated&color=3B82B6&labelColor=162033&style=for-the-badge)](https://github.com/paell0/wow-forever-context-exporter/blob/main/tests/test_addon.py)

<!-- language-selector:start -->

[![English](https://img.shields.io/static/v1?label=EN&message=English&color=334155&labelColor=162033&style=flat-square)](../README.md) [![Español](https://img.shields.io/static/v1?label=ES&message=Espa%C3%B1ol&color=334155&labelColor=162033&style=flat-square)](README.es.md) [![Français](https://img.shields.io/static/v1?label=FR&message=Fran%C3%A7ais&color=334155&labelColor=162033&style=flat-square)](README.fr.md) [![Deutsch](https://img.shields.io/static/v1?label=DE&message=Deutsch&color=334155&labelColor=162033&style=flat-square)](README.de.md) [![Italiano](https://img.shields.io/static/v1?label=IT&message=Italiano&color=334155&labelColor=162033&style=flat-square)](README.it.md) [![Русский](https://img.shields.io/static/v1?label=RU&message=%D0%A0%D1%83%D1%81%D1%81%D0%BA%D0%B8%D0%B9&color=334155&labelColor=162033&style=flat-square)](README.ru.md)

[![Português (Brasil)](https://img.shields.io/static/v1?label=PT-BR&message=Portugu%C3%AAs+%28Brasil%29&color=334155&labelColor=162033&style=flat-square)](README.pt-BR.md)

[![简体中文](https://img.shields.io/static/v1?label=ZH-CN&message=%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87&color=334155&labelColor=162033&style=flat-square)](README.zh-CN.md) [![繁體中文 (selected)](https://img.shields.io/static/v1?label=ZH-TW&message=%E7%B9%81%E9%AB%94%E4%B8%AD%E6%96%87&color=D4A64A&labelColor=162033&style=flat-square)](README.zh-TW.md) [![日本語](https://img.shields.io/static/v1?label=JA&message=%E6%97%A5%E6%9C%AC%E8%AA%9E&color=334155&labelColor=162033&style=flat-square)](README.ja.md) [![한국어](https://img.shields.io/static/v1?label=KO&message=%ED%95%9C%EA%B5%AD%EC%96%B4&color=334155&labelColor=162033&style=flat-square)](README.ko.md) [![हिन्दी](https://img.shields.io/static/v1?label=HI&message=%E0%A4%B9%E0%A4%BF%E0%A4%A8%E0%A5%8D%E0%A4%A6%E0%A5%80&color=334155&labelColor=162033&style=flat-square)](README.hi.md) [![ไทย](https://img.shields.io/static/v1?label=TH&message=%E0%B9%84%E0%B8%97%E0%B8%A2&color=334155&labelColor=162033&style=flat-square)](README.th.md)

<!-- language-selector:end -->

將 WoW Forever 角色的天賦、專業、裝備與屬性匯出為純文字，方便向 AI 尋求建議。

也可以點擊小地圖按鈕開啟或關閉報告。拖曳按鈕可調整位置，位置會在下次登入時保留。使用 `/fcontext minimap` 隱藏或重新顯示按鈕。

報告依天賦目前等級查詢說明，並明確標示未驗證的通用參考文字。套裝效果會標為生效、未生效或狀態未知；副手沒有武器時不顯示副手傷害。數值相同的重複抗性別名會合併顯示。

1.1.0 新增依角色儲存的成長計畫、雙物品比較、依問題產生報告與舊建議回顧。在 **Progress plan** 貼上 AI 回傳的計畫區塊，以 **Preview plan** 檢查後再用 **Accept plan** 接受。可驗證目標依角色資料更新，手動任務使用核取方塊。在 **Compare items** 拖入兩個物品即可產生比較內容。使用 **Talent points**、**Gear advice**、**Next session** 或 **Review plan** 選擇報告目的。報告包含已接受目標及相對參考快照的變化。[完整英文指南與計畫格式](PROGRESS-PLAN.md)。


1.2.0 新增七項功能：附參考資料和確認狀態的物品來源、依活動儲存的天賦配置、版本變更提醒、可選背包匯出、物品保留清單、無劇透模式及可選匯出分類。請開啟 **Item sources**、**Talent profiles**、**Browse bags**、**Keep items** 和 **Export options**。遊戲觀察、玩家確認與未確認筆記會明確區分；不包含完整掉落資料庫。[七項工具英文指南](COMMUNITY-TOOLS.md)。

## 安裝與使用

1. 從 [Releases](https://github.com/paell0/wow-forever-context-exporter/releases) 下載 `ForeverContext-1.2.0.zip`。
2. 關閉遊戲，將 `ForeverContext` 資料夾解壓至 `World of Warcraft/_forever_/Interface/AddOns/`。
3. 確認路徑為 `AddOns/ForeverContext/ForeverContext.toc`，然後啟用插件。若曾安裝舊版 ContextoPJ，請先移除其資料夾。
4. 在非戰鬥狀態下輸入 **`/fcontext`**。
5. 可填寫你的目標，按 **Generate / refresh**，再按 **Select all**，使用 **Ctrl+C** 複製，並以 **Ctrl+V** 貼到 AI。

別名：`/forevercontext`、`/pjia`。說明：`/fcontext help`。

## 匯出內容

職業、種族、等級、經驗值、目前天賦與可用點數；專業及技能等級；已裝備物品的屬性、效果、附魔、寶石與耐久度；可讀取的增益與目前召喚的寵物。擴充選項包含技能、已學法術、任務及可查詢的聲望。報告已附分析請求。

## 狀態與限制

適用於介面版本 **16001** 的公開預覽版。已通過 **114 項模擬 Lua 5.1 測試**，尚未於真實 WoW Forever 遊戲工作階段驗證。

預設省略角色姓名。不傳送資料，也不需要 API 金鑰。只有啟用後才匯出背包；銀行、郵件和其他角色不在範圍內。配置、來源和偏好依角色儲存。無劇透模式會過濾報告並要求 AI 遵守，但無法控制其回覆，也不會刪除你自己寫的文字。無法讀取的資料標為未知。本版本仍需遊戲內驗證。

插件介面與報告標籤為英文，遊戲提供的名稱及說明保留用戶端語言。這裡僅翻譯文件，不代表新增用戶端語言支援。開發說明與完整限制請見[英文 README](../README.md)。授權條款：[All Rights Reserved](../LICENSE)。

自 v1.0.2 起，新原創內容保留所有權利。允許個人使用未修改的官方版本，也允許僅為向官方儲存庫提交 PR 而開發與測試修改；是否接受由維護者決定。不授權商業化或發布獨立修改版。先前以 MIT 發布的內容仍保留原有授權，本次變更不會撤銷這些權利。完整英文條款見 [LICENSE](../LICENSE)。
