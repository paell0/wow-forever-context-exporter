# ForeverContext

[English](../README.md) | [Español](README.es.md) | [Português (Brasil)](README.pt-BR.md) | [Français](README.fr.md) | [Deutsch](README.de.md) | [简体中文](README.zh-CN.md) | [繁體中文](README.zh-TW.md) | [日本語](README.ja.md) | [हिन्दी](README.hi.md) | [ไทย](README.th.md) | [한국어](README.ko.md) | [Русский](README.ru.md) | [Italiano](README.it.md)

将 WoW Forever 角色的天赋、专业、装备和属性导出为纯文本，方便向 AI 寻求建议。

## 安装与使用

1. 从 [Releases](https://github.com/paell0/wow-forever-context-exporter/releases) 下载 `ForeverContext-1.0.1.zip`。
2. 关闭游戏，将 `ForeverContext` 文件夹解压到 `World of Warcraft/_forever_/Interface/AddOns/`。
3. 确认路径为 `AddOns/ForeverContext/ForeverContext.toc`，然后启用插件。如果安装过旧版 ContextoPJ，请先移除其文件夹。
4. 在非战斗状态下输入 **`/fcontext`**。
5. 可填写你的目标，点击 **Generate / refresh**，再点击 **Select all**，按 **Ctrl+C** 复制，用 **Ctrl+V** 粘贴到 AI。

别名：`/forevercontext`、`/pjia`。帮助：`/fcontext help`。

## 导出内容

职业、种族、等级、经验、当前天赋与可用点数；专业及技能等级；已装备物品的属性、效果、附魔、宝石和耐久度；可读取的增益与当前召唤的宠物。扩展选项还包括技能、已学法术、任务和可查询的声望。报告自带分析请求。

## 状态与限制

面向接口版本 **16001** 的公开预览版。已通过 **15 项模拟 Lua 5.1 测试**，尚未在真实 WoW Forever 游戏会话中验证。

默认不导出角色姓名。插件不会传输数据，也不需要 API 密钥。不包含背包和银行。未应用的天赋改动不会作为当前天赋导出；待加载或不可用的数据会明确标注。如有缺失，请打开天赋或专业界面后重新生成。

插件界面与报告标签为英文，游戏返回的名称和说明保留客户端语言。此处仅翻译文档，并不代表新增客户端语言支持。开发说明和完整限制请参阅[英文 README](../README.md)。许可证：[MIT](../LICENSE)。
