# ForeverContext

[![Version 1.0.2](https://img.shields.io/static/v1?label=version&message=1.0.2&color=D4A64A&labelColor=162033&style=for-the-badge)](https://github.com/paell0/wow-forever-context-exporter/releases/tag/v1.0.2) [![Public preview](https://img.shields.io/static/v1?label=status&message=public+preview&color=E8A838&labelColor=162033&style=for-the-badge)](https://github.com/paell0/wow-forever-context-exporter#privacy-and-limitations) [![Lua 5.1](https://img.shields.io/static/v1?label=Lua&message=5.1&color=2C2D72&labelColor=162033&style=for-the-badge&logo=lua&logoColor=white)](https://github.com/paell0/wow-forever-context-exporter/tree/main/ForeverContext) [![All Rights Reserved; prior MIT material retains its permissions](https://img.shields.io/static/v1?label=license&message=All+Rights+Reserved&color=B45309&labelColor=162033&style=for-the-badge)](../LICENSE) [![15 simulated tests; not verified in game](https://img.shields.io/static/v1?label=tests&message=15+simulated&color=3B82B6&labelColor=162033&style=for-the-badge)](https://github.com/paell0/wow-forever-context-exporter/blob/main/tests/test_addon.py)

<!-- language-selector:start -->

[![English](https://img.shields.io/static/v1?label=EN&message=English&color=334155&labelColor=162033&style=flat-square)](../README.md) [![Español](https://img.shields.io/static/v1?label=ES&message=Espa%C3%B1ol&color=334155&labelColor=162033&style=flat-square)](README.es.md) [![Français](https://img.shields.io/static/v1?label=FR&message=Fran%C3%A7ais&color=334155&labelColor=162033&style=flat-square)](README.fr.md) [![Deutsch](https://img.shields.io/static/v1?label=DE&message=Deutsch&color=334155&labelColor=162033&style=flat-square)](README.de.md) [![Italiano](https://img.shields.io/static/v1?label=IT&message=Italiano&color=334155&labelColor=162033&style=flat-square)](README.it.md) [![Русский](https://img.shields.io/static/v1?label=RU&message=%D0%A0%D1%83%D1%81%D1%81%D0%BA%D0%B8%D0%B9&color=334155&labelColor=162033&style=flat-square)](README.ru.md)

[![Português (Brasil)](https://img.shields.io/static/v1?label=PT-BR&message=Portugu%C3%AAs+%28Brasil%29&color=334155&labelColor=162033&style=flat-square)](README.pt-BR.md)

[![简体中文](https://img.shields.io/static/v1?label=ZH-CN&message=%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87&color=334155&labelColor=162033&style=flat-square)](README.zh-CN.md) [![繁體中文](https://img.shields.io/static/v1?label=ZH-TW&message=%E7%B9%81%E9%AB%94%E4%B8%AD%E6%96%87&color=334155&labelColor=162033&style=flat-square)](README.zh-TW.md) [![日本語 (selected)](https://img.shields.io/static/v1?label=JA&message=%E6%97%A5%E6%9C%AC%E8%AA%9E&color=D4A64A&labelColor=162033&style=flat-square)](README.ja.md) [![한국어](https://img.shields.io/static/v1?label=KO&message=%ED%95%9C%EA%B5%AD%EC%96%B4&color=334155&labelColor=162033&style=flat-square)](README.ko.md) [![हिन्दी](https://img.shields.io/static/v1?label=HI&message=%E0%A4%B9%E0%A4%BF%E0%A4%A8%E0%A5%8D%E0%A4%A6%E0%A5%80&color=334155&labelColor=162033&style=flat-square)](README.hi.md) [![ไทย](https://img.shields.io/static/v1?label=TH&message=%E0%B9%84%E0%B8%97%E0%B8%A2&color=334155&labelColor=162033&style=flat-square)](README.th.md)

<!-- language-selector:end -->

WoW Forever のキャラクターのタレント、専門技能、装備、ステータスをプレーンテキストで出力し、AI に相談できます。

## インストールと使い方

1. [Releases](https://github.com/paell0/wow-forever-context-exporter/releases) から `ForeverContext-1.0.2.zip` をダウンロードします。
2. ゲームを終了し、`ForeverContext` フォルダーを `World of Warcraft/_forever_/Interface/AddOns/` に展開します。
3. `AddOns/ForeverContext/ForeverContext.toc` を確認してアドオンを有効にします。旧 ContextoPJ がある場合は、そのフォルダーを先に削除してください。
4. 非戦闘時に **`/fcontext`** を入力します。
5. 必要に応じて目標を記入し、**Generate / refresh**、**Select all** の順にクリックします。**Ctrl+C** でコピーし、**Ctrl+V** で AI に貼り付けます。

別名コマンド：`/forevercontext`、`/pjia`。ヘルプ：`/fcontext help`。

## 出力内容

クラス、種族、レベル、経験値、現在のタレントと利用可能ポイント、専門技能と熟練度、装備中のアイテムの属性・効果・エンチャント・宝石・耐久度、読み取り可能なバフと召喚中のペット。拡張オプションでは技能、習得済み呪文、クエスト、取得可能な評判も含みます。AI への分析依頼文も付属します。

## 状態と制限

インターフェース **16001** 向けの公開プレビューです。**Lua 5.1 の模擬テスト 15 件**に合格していますが、実際の WoW Forever セッションでは未検証です。

キャラクター名は既定で除外されます。データの送信や API キーは不要です。バッグと銀行は含みません。未適用のタレント変更を現在の構成として出力せず、不足データには警告を表示します。必要に応じてタレントや専門技能画面を開き、再生成してください。

操作画面とレポートのラベルは英語です。ゲーム内の名称と説明はクライアントの言語を保持します。これは文書の翻訳であり、日本語クライアントへの対応を追加するものではありません。詳細と開発手順は[英語 README](../README.md) を参照してください。ライセンス：[All Rights Reserved](../LICENSE)。

v1.0.2 以降の新規の独自コンテンツは、明示した許可以外の権利を留保します。未変更の公式版の個人利用と、公式リポジトリへの PR 提出のみを目的とする変更・テストを許可し、採用はメンテナーが判断します。商業利用や独自の変更版の配布は許可しません。以前 MIT で公開した内容への許可は維持され、この変更によって取り消されません。英語の全文は [LICENSE](../LICENSE) を参照してください。
