# ForeverContext

[![Version 1.0.5](https://img.shields.io/static/v1?label=version&message=1.0.5&color=D4A64A&labelColor=162033&style=for-the-badge)](https://github.com/paell0/wow-forever-context-exporter/releases/tag/v1.0.5) [![Public preview](https://img.shields.io/static/v1?label=status&message=public+preview&color=E8A838&labelColor=162033&style=for-the-badge)](https://github.com/paell0/wow-forever-context-exporter#privacy-and-limitations) [![Lua 5.1](https://img.shields.io/static/v1?label=Lua&message=5.1&color=2C2D72&labelColor=162033&style=for-the-badge&logo=lua&logoColor=white)](https://github.com/paell0/wow-forever-context-exporter/tree/main/ForeverContext) [![All Rights Reserved; prior MIT material retains its permissions](https://img.shields.io/static/v1?label=license&message=All+Rights+Reserved&color=B45309&labelColor=162033&style=for-the-badge)](../LICENSE) [![37 simulated tests; not verified in game](https://img.shields.io/static/v1?label=tests&message=37+simulated&color=3B82B6&labelColor=162033&style=for-the-badge)](https://github.com/paell0/wow-forever-context-exporter/blob/main/tests/test_addon.py)

<!-- language-selector:start -->

[![English](https://img.shields.io/static/v1?label=EN&message=English&color=334155&labelColor=162033&style=flat-square)](../README.md) [![Español](https://img.shields.io/static/v1?label=ES&message=Espa%C3%B1ol&color=334155&labelColor=162033&style=flat-square)](README.es.md) [![Français](https://img.shields.io/static/v1?label=FR&message=Fran%C3%A7ais&color=334155&labelColor=162033&style=flat-square)](README.fr.md) [![Deutsch](https://img.shields.io/static/v1?label=DE&message=Deutsch&color=334155&labelColor=162033&style=flat-square)](README.de.md) [![Italiano](https://img.shields.io/static/v1?label=IT&message=Italiano&color=334155&labelColor=162033&style=flat-square)](README.it.md) [![Русский](https://img.shields.io/static/v1?label=RU&message=%D0%A0%D1%83%D1%81%D1%81%D0%BA%D0%B8%D0%B9&color=334155&labelColor=162033&style=flat-square)](README.ru.md)

[![Português (Brasil)](https://img.shields.io/static/v1?label=PT-BR&message=Portugu%C3%AAs+%28Brasil%29&color=334155&labelColor=162033&style=flat-square)](README.pt-BR.md)

[![简体中文 (selected)](https://img.shields.io/static/v1?label=ZH-CN&message=%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87&color=D4A64A&labelColor=162033&style=flat-square)](README.zh-CN.md) [![繁體中文](https://img.shields.io/static/v1?label=ZH-TW&message=%E7%B9%81%E9%AB%94%E4%B8%AD%E6%96%87&color=334155&labelColor=162033&style=flat-square)](README.zh-TW.md) [![日本語](https://img.shields.io/static/v1?label=JA&message=%E6%97%A5%E6%9C%AC%E8%AA%9E&color=334155&labelColor=162033&style=flat-square)](README.ja.md) [![한국어](https://img.shields.io/static/v1?label=KO&message=%ED%95%9C%EA%B5%AD%EC%96%B4&color=334155&labelColor=162033&style=flat-square)](README.ko.md) [![हिन्दी](https://img.shields.io/static/v1?label=HI&message=%E0%A4%B9%E0%A4%BF%E0%A4%A8%E0%A5%8D%E0%A4%A6%E0%A5%80&color=334155&labelColor=162033&style=flat-square)](README.hi.md) [![ไทย](https://img.shields.io/static/v1?label=TH&message=%E0%B9%84%E0%B8%97%E0%B8%A2&color=334155&labelColor=162033&style=flat-square)](README.th.md)

<!-- language-selector:end -->

将 WoW Forever 角色的天赋、专业、装备和属性导出为纯文本，方便向 AI 寻求建议。

也可以点击小地图按钮打开或关闭报告。拖动按钮可调整位置，位置会在下次登录时保留。使用 `/fcontext minimap` 隐藏或重新显示按钮。

报告按天赋当前等级查询说明，并明确标注未验证的通用参考文本。套装效果会标为生效、未生效或状态未知；副手没有武器时不显示副手伤害。数值相同的重复抗性别名会合并显示。

## 安装与使用

1. 从 [Releases](https://github.com/paell0/wow-forever-context-exporter/releases) 下载 `ForeverContext-1.0.5.zip`。
2. 关闭游戏，将 `ForeverContext` 文件夹解压到 `World of Warcraft/_forever_/Interface/AddOns/`。
3. 确认路径为 `AddOns/ForeverContext/ForeverContext.toc`，然后启用插件。如果安装过旧版 ContextoPJ，请先移除其文件夹。
4. 在非战斗状态下输入 **`/fcontext`**。
5. 可填写你的目标，点击 **Generate / refresh**，再点击 **Select all**，按 **Ctrl+C** 复制，用 **Ctrl+V** 粘贴到 AI。

别名：`/forevercontext`、`/pjia`。帮助：`/fcontext help`。

## 导出内容

职业、种族、等级、经验、当前天赋与可用点数；专业及技能等级；已装备物品的属性、效果、附魔、宝石和耐久度；可读取的增益与当前召唤的宠物。扩展选项还包括技能、已学法术、任务和可查询的声望。报告自带分析请求。

## 状态与限制

面向接口版本 **16001** 的公开预览版。已通过 **37 项模拟 Lua 5.1 测试**，尚未在真实 WoW Forever 游戏会话中验证。

默认不导出角色姓名。插件不会传输数据，也不需要 API 密钥。不包含背包和银行。未应用的天赋改动不会作为当前天赋导出；待加载或不可用的数据会明确标注。如有缺失，请打开天赋或专业界面后重新生成。

插件界面与报告标签为英文，游戏返回的名称和说明保留客户端语言。此处仅翻译文档，并不代表新增客户端语言支持。开发说明和完整限制请参阅[英文 README](../README.md)。许可证：[All Rights Reserved](../LICENSE)。

自 v1.0.2 起，新原创内容保留所有权利。允许个人使用未修改的官方版本，也允许仅为向官方仓库提交 PR 而开发和测试修改；是否接受由维护者决定。不授权商业化或发布独立修改版。此前按 MIT 发布的内容仍保留原有授权，本次变更不会撤销这些权利。完整英文条款见 [LICENSE](../LICENSE)。
