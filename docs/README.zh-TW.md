# ForeverContext

[English](../README.md) | [Español](README.es.md) | [Português (Brasil)](README.pt-BR.md) | [Français](README.fr.md) | [Deutsch](README.de.md) | [简体中文](README.zh-CN.md) | [繁體中文](README.zh-TW.md) | [日本語](README.ja.md) | [हिन्दी](README.hi.md) | [ไทย](README.th.md) | [한국어](README.ko.md) | [Русский](README.ru.md) | [Italiano](README.it.md)

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
