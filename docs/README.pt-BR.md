# ForeverContext

[English](../README.md) | [Español](README.es.md) | [Português (Brasil)](README.pt-BR.md) | [Français](README.fr.md) | [Deutsch](README.de.md) | [简体中文](README.zh-CN.md) | [繁體中文](README.zh-TW.md) | [日本語](README.ja.md) | [हिन्दी](README.hi.md) | [ไทย](README.th.md) | [한국어](README.ko.md) | [Русский](README.ru.md) | [Italiano](README.it.md)

Exporte talentos, profissões, equipamentos e atributos do seu personagem de WoW Forever como texto para pedir orientações a uma IA.

## Instalação e uso

1. Baixe `ForeverContext-1.0.1.zip` em [Releases](https://github.com/paell0/wow-forever-context-exporter/releases).
2. Feche o jogo e extraia a pasta `ForeverContext` em `World of Warcraft/_forever_/Interface/AddOns/`.
3. Confira o caminho `AddOns/ForeverContext/ForeverContext.toc` e ative o addon. Remova a pasta do antigo ContextoPJ, caso esteja instalado.
4. Fora de combate, digite **`/fcontext`**.
5. Informe seu objetivo, se desejar, e clique em **Generate / refresh**. Clique em **Select all**, pressione **Ctrl+C** e cole na IA com **Ctrl+V**.

Aliases: `/forevercontext` e `/pjia`. Ajuda: `/fcontext help`.

## Informações exportadas

Classe, raça, nível, experiência, talentos ativos, pontos disponíveis, profissões e níveis; equipamentos com atributos, efeitos, encantamentos, gemas e durabilidade; buffs e mascote invocado. A opção estendida inclui perícias, feitiços, missões e reputações consultáveis. O relatório já contém um pedido de análise para a IA.

## Status e limitações

Prévia pública para a interface **16001**. **15 testes simulados de Lua 5.1** passaram; ainda não houve teste em uma sessão real de WoW Forever.

O nome do personagem é omitido por padrão. O addon não transmite dados nem exige chave de API. Não inclui bolsas ou banco. Alterações de talentos não aplicadas não são apresentadas como ativas. Dados pendentes são sinalizados: abra Talentos/Profissões e gere novamente.

Controles e rótulos do relatório estão em inglês. Nomes e descrições do jogo mantêm o idioma do cliente. Esta é uma tradução da documentação. Consulte o [README principal](../README.md) para desenvolvimento e detalhes completos. Licença [MIT](../LICENSE).
