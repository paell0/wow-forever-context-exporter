# ForeverContext

[English](../README.md) | [Español](README.es.md) | [Português (Brasil)](README.pt-BR.md) | [Français](README.fr.md) | [Deutsch](README.de.md) | [简体中文](README.zh-CN.md) | [繁體中文](README.zh-TW.md) | [日本語](README.ja.md) | [हिन्दी](README.hi.md) | [ไทย](README.th.md) | [한국어](README.ko.md) | [Русский](README.ru.md) | [Italiano](README.it.md)

WoW Forever のキャラクターのタレント、専門技能、装備、ステータスをプレーンテキストで出力し、AI に相談できます。

## インストールと使い方

1. [Releases](https://github.com/paell0/wow-forever-context-exporter/releases) から `ForeverContext-1.0.1.zip` をダウンロードします。
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

操作画面とレポートのラベルは英語です。ゲーム内の名称と説明はクライアントの言語を保持します。これは文書の翻訳であり、日本語クライアントへの対応を追加するものではありません。詳細と開発手順は[英語 README](../README.md) を参照してください。ライセンス：[MIT](../LICENSE)。
