# ForeverContext

[![Version 1.4.0](https://img.shields.io/static/v1?label=version&message=1.4.0&color=D4A64A&labelColor=162033&style=for-the-badge)](https://github.com/paell0/wow-forever-context-exporter/releases/tag/v1.4.0) [![Public preview](https://img.shields.io/static/v1?label=status&message=public+preview&color=E8A838&labelColor=162033&style=for-the-badge)](https://github.com/paell0/wow-forever-context-exporter#privacy-and-limitations) [![Lua 5.1](https://img.shields.io/static/v1?label=Lua&message=5.1&color=2C2D72&labelColor=162033&style=for-the-badge&logo=lua&logoColor=white)](https://github.com/paell0/wow-forever-context-exporter/tree/main/ForeverContext) [![All Rights Reserved; prior MIT material retains its permissions](https://img.shields.io/static/v1?label=license&message=All+Rights+Reserved&color=B45309&labelColor=162033&style=for-the-badge)](../LICENSE) [![144 simulated tests; not verified in game](https://img.shields.io/static/v1?label=tests&message=144+simulated&color=3B82B6&labelColor=162033&style=for-the-badge)](https://github.com/paell0/wow-forever-context-exporter/blob/main/tests/test_addon.py)

<!-- language-selector:start -->

[![English](https://img.shields.io/static/v1?label=EN&message=English&color=334155&labelColor=162033&style=flat-square)](../README.md) [![Español](https://img.shields.io/static/v1?label=ES&message=Espa%C3%B1ol&color=334155&labelColor=162033&style=flat-square)](README.es.md) [![Français](https://img.shields.io/static/v1?label=FR&message=Fran%C3%A7ais&color=334155&labelColor=162033&style=flat-square)](README.fr.md) [![Deutsch](https://img.shields.io/static/v1?label=DE&message=Deutsch&color=334155&labelColor=162033&style=flat-square)](README.de.md) [![Italiano](https://img.shields.io/static/v1?label=IT&message=Italiano&color=334155&labelColor=162033&style=flat-square)](README.it.md) [![Русский](https://img.shields.io/static/v1?label=RU&message=%D0%A0%D1%83%D1%81%D1%81%D0%BA%D0%B8%D0%B9&color=334155&labelColor=162033&style=flat-square)](README.ru.md)

[![Português (Brasil)](https://img.shields.io/static/v1?label=PT-BR&message=Portugu%C3%AAs+%28Brasil%29&color=334155&labelColor=162033&style=flat-square)](README.pt-BR.md)

[![简体中文 (selected)](https://img.shields.io/static/v1?label=ZH-CN&message=%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87&color=D4A64A&labelColor=162033&style=flat-square)](README.zh-CN.md) [![繁體中文](https://img.shields.io/static/v1?label=ZH-TW&message=%E7%B9%81%E9%AB%94%E4%B8%AD%E6%96%87&color=334155&labelColor=162033&style=flat-square)](README.zh-TW.md) [![日本語](https://img.shields.io/static/v1?label=JA&message=%E6%97%A5%E6%9C%AC%E8%AA%9E&color=334155&labelColor=162033&style=flat-square)](README.ja.md) [![한국어](https://img.shields.io/static/v1?label=KO&message=%ED%95%9C%EA%B5%AD%EC%96%B4&color=334155&labelColor=162033&style=flat-square)](README.ko.md) [![हिन्दी](https://img.shields.io/static/v1?label=HI&message=%E0%A4%B9%E0%A4%BF%E0%A4%A8%E0%A5%8D%E0%A4%A6%E0%A5%80&color=334155&labelColor=162033&style=flat-square)](README.hi.md) [![ไทย](https://img.shields.io/static/v1?label=TH&message=%E0%B9%84%E0%B8%97%E0%B8%A2&color=334155&labelColor=162033&style=flat-square)](README.th.md)

<!-- language-selector:end -->

将 WoW Forever 角色的天赋、专业、装备和属性导出为纯文本，方便向 AI 寻求建议。

也可以点击小地图按钮打开或关闭报告。拖动按钮可调整位置，位置会在下次登录时保留。使用 `/fcontext minimap` 隐藏或重新显示按钮。

报告按天赋当前等级查询说明，并明确标注未验证的通用参考文本。套装效果会标为生效、未生效或状态未知；副手没有武器时不显示副手伤害。数值相同的重复抗性别名会合并显示。

1.1.0 新增按角色保存的成长计划、双物品比较、按问题生成报告和旧建议回顾。在 **Progress plan** 粘贴 AI 返回的计划块，点击 **Preview plan** 检查后再用 **Accept plan** 接受。可验证目标按角色数据更新，手动任务使用勾选框。在 **Compare items** 拖入两个物品即可生成比较上下文。使用 **Talent points**、**Gear advice**、**Next session** 或 **Review plan** 选择报告目的。报告会包含已接受目标及相对参考快照的变化。[完整英文指南与计划格式](PROGRESS-PLAN.md)。


1.2.0 新增七项功能：带参考资料和确认状态的物品来源、按活动保存的天赋配置、版本变化提醒、可选背包导出、物品保留清单、无剧透模式及可选导出分类。请打开 **Item sources**、**Talent profiles**、**Browse bags**、**Keep items** 和 **Export options**。游戏中观察到的来源、玩家确认的来源与未确认笔记会明确区分；不包含完整掉落数据库。[七项工具英文指南](COMMUNITY-TOOLS.md)。


1.4 简化了操作：**1. 准备文本 → 2. 选择文本 → Ctrl+C**，然后在你的 AI 中按 **Ctrl+V** 粘贴。**更多工具**会解释可选功能。设置首先显示基础选项，物品比较和计划都有编号步骤。[英文入门指南](QUICKSTART.md)。

## 安装与使用

1. 从 [Releases](https://github.com/paell0/wow-forever-context-exporter/releases) 下载 `ForeverContext-1.4.0.zip`。
2. 关闭游戏，将 `ForeverContext` 文件夹解压到 `World of Warcraft/_forever_/Interface/AddOns/`。
3. 确认路径为 `AddOns/ForeverContext/ForeverContext.toc`，然后启用插件。如果安装过旧版 ContextoPJ，请先移除其文件夹。
4. 在非战斗状态下输入 **`/fcontext`**。
5. 可填写你的目标，点击 **1. Prepare text**，再点击 **2. Select text**，按 **Ctrl+C** 复制，用 **Ctrl+V** 粘贴到 AI。

别名：`/forevercontext`、`/pjia`。帮助：`/fcontext help`。

## 导出内容

职业、种族、等级、经验、当前天赋与可用点数；专业及技能等级；已装备物品的属性、效果、附魔、宝石和耐久度；可读取的增益与当前召唤的宠物。扩展选项还包括技能、已学法术、任务和可查询的声望。报告自带分析请求。

## 状态与限制

面向接口版本 **16001** 的公开预览版。已通过 **144 项模拟 Lua 5.1 测试**，尚未在真实 WoW Forever 游戏会话中验证。

默认省略角色姓名。不发送数据，也不需要 API 密钥。仅在启用后导出背包；银行、邮件和其他角色不在范围内。配置、来源和偏好按角色保存。无剧透模式会过滤报告并要求 AI 遵守，但无法控制其回复，也不会删除你自己写的文字。无法读取的数据标为未知。本版本仍需游戏内验证。

界面默认跟随游戏语言，可在导出选项中或通过 `/fcontext language` 切换，共支持 10 种语言。报告仍为英文，游戏名称保留客户端语言。语言选择对整个账号生效，无需重新加载。[语言指南](LOCALIZATION.md)。 [README](../README.md) · [All Rights Reserved](../LICENSE).

自 v1.0.2 起，新原创内容保留所有权利。允许个人使用未修改的官方版本，也允许仅为向官方仓库提交 PR 而开发和测试修改；是否接受由维护者决定。不授权商业化或发布独立修改版。此前按 MIT 发布的内容仍保留原有授权，本次变更不会撤销这些权利。完整英文条款见 [LICENSE](../LICENSE)。
