# ForeverContext

[![Version 1.3.0](https://img.shields.io/static/v1?label=version&message=1.3.0&color=D4A64A&labelColor=162033&style=for-the-badge)](https://github.com/paell0/wow-forever-context-exporter/releases/tag/v1.3.0) [![Public preview](https://img.shields.io/static/v1?label=status&message=public+preview&color=E8A838&labelColor=162033&style=for-the-badge)](https://github.com/paell0/wow-forever-context-exporter#privacy-and-limitations) [![Lua 5.1](https://img.shields.io/static/v1?label=Lua&message=5.1&color=2C2D72&labelColor=162033&style=for-the-badge&logo=lua&logoColor=white)](https://github.com/paell0/wow-forever-context-exporter/tree/main/ForeverContext) [![All Rights Reserved; prior MIT material retains its permissions](https://img.shields.io/static/v1?label=license&message=All+Rights+Reserved&color=B45309&labelColor=162033&style=for-the-badge)](../LICENSE) [![132 simulated tests; not verified in game](https://img.shields.io/static/v1?label=tests&message=132+simulated&color=3B82B6&labelColor=162033&style=for-the-badge)](https://github.com/paell0/wow-forever-context-exporter/blob/main/tests/test_addon.py)

<!-- language-selector:start -->

[![English](https://img.shields.io/static/v1?label=EN&message=English&color=334155&labelColor=162033&style=flat-square)](../README.md) [![Español](https://img.shields.io/static/v1?label=ES&message=Espa%C3%B1ol&color=334155&labelColor=162033&style=flat-square)](README.es.md) [![Français](https://img.shields.io/static/v1?label=FR&message=Fran%C3%A7ais&color=334155&labelColor=162033&style=flat-square)](README.fr.md) [![Deutsch](https://img.shields.io/static/v1?label=DE&message=Deutsch&color=334155&labelColor=162033&style=flat-square)](README.de.md) [![Italiano](https://img.shields.io/static/v1?label=IT&message=Italiano&color=334155&labelColor=162033&style=flat-square)](README.it.md) [![Русский](https://img.shields.io/static/v1?label=RU&message=%D0%A0%D1%83%D1%81%D1%81%D0%BA%D0%B8%D0%B9&color=334155&labelColor=162033&style=flat-square)](README.ru.md)

[![Português (Brasil) (selected)](https://img.shields.io/static/v1?label=PT-BR&message=Portugu%C3%AAs+%28Brasil%29&color=D4A64A&labelColor=162033&style=flat-square)](README.pt-BR.md)

[![简体中文](https://img.shields.io/static/v1?label=ZH-CN&message=%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87&color=334155&labelColor=162033&style=flat-square)](README.zh-CN.md) [![繁體中文](https://img.shields.io/static/v1?label=ZH-TW&message=%E7%B9%81%E9%AB%94%E4%B8%AD%E6%96%87&color=334155&labelColor=162033&style=flat-square)](README.zh-TW.md) [![日本語](https://img.shields.io/static/v1?label=JA&message=%E6%97%A5%E6%9C%AC%E8%AA%9E&color=334155&labelColor=162033&style=flat-square)](README.ja.md) [![한국어](https://img.shields.io/static/v1?label=KO&message=%ED%95%9C%EA%B5%AD%EC%96%B4&color=334155&labelColor=162033&style=flat-square)](README.ko.md) [![हिन्दी](https://img.shields.io/static/v1?label=HI&message=%E0%A4%B9%E0%A4%BF%E0%A4%A8%E0%A5%8D%E0%A4%A6%E0%A5%80&color=334155&labelColor=162033&style=flat-square)](README.hi.md) [![ไทย](https://img.shields.io/static/v1?label=TH&message=%E0%B9%84%E0%B8%97%E0%B8%A2&color=334155&labelColor=162033&style=flat-square)](README.th.md)

<!-- language-selector:end -->

Exporte talentos, profissões, equipamentos e atributos do seu personagem de WoW Forever como texto para pedir orientações a uma IA.

Você também pode abrir ou fechar o relatório pelo botão do minimapa. Arraste-o para mudar a posição, que é salva entre sessões. Use `/fcontext minimap` para ocultar ou mostrar o botão.

O relatório consulta as descrições dos talentos no nível atual e identifica referências genéricas não verificadas. Distingue bônus de conjunto ativos, inativos ou desconhecidos e omite o dano da mão secundária quando não há uma arma nesse espaço. Também remove aliases duplicados de resistência quando os valores coincidem.

A versão 1.1.0 adiciona planos por personagem, comparação de dois itens, relatórios por pergunta e revisão de conselhos anteriores. Use **Progress plan** para colar o bloco devolvido pela IA, **Preview plan** para revisar e **Accept plan** para aceitar. Metas verificáveis usam dados do personagem; tarefas manuais têm caixas de seleção. Em **Compare items**, arraste dois itens e gere o contexto para a IA. Escolha **Talent points**, **Gear advice**, **Next session** ou **Review plan**. Os relatórios incluem as metas aceitas e as mudanças observadas. [Guia completo e formato dos planos, em inglês](PROGRESS-PLAN.md).


A versão 1.2.0 adiciona sete melhorias: fontes de itens com referências e confirmação; perfis de talentos por atividade; avisos de versão; exportação opcional das bolsas; lista de itens para guardar; modo sem spoilers; e categorias configuráveis. Use **Item sources**, **Talent profiles**, **Browse bags**, **Keep items** e **Export options**. Fontes observadas, confirmadas pelo jogador e não confirmadas são diferenciadas; não há um banco completo de saques. [Guia das sete ferramentas em inglês](COMMUNITY-TOOLS.md).

## Instalação e uso

1. Baixe `ForeverContext-1.3.0.zip` em [Releases](https://github.com/paell0/wow-forever-context-exporter/releases).
2. Feche o jogo e extraia a pasta `ForeverContext` em `World of Warcraft/_forever_/Interface/AddOns/`.
3. Confira o caminho `AddOns/ForeverContext/ForeverContext.toc` e ative o addon. Remova a pasta do antigo ContextoPJ, caso esteja instalado.
4. Fora de combate, digite **`/fcontext`**.
5. Informe seu objetivo, se desejar, e clique em **Generate / refresh**. Clique em **Select all**, pressione **Ctrl+C** e cole na IA com **Ctrl+V**.

Aliases: `/forevercontext` e `/pjia`. Ajuda: `/fcontext help`.

## Informações exportadas

Classe, raça, nível, experiência, talentos ativos, pontos disponíveis, profissões e níveis; equipamentos com atributos, efeitos, encantamentos, gemas e durabilidade; buffs e mascote invocado. A opção estendida inclui perícias, feitiços, missões e reputações consultáveis. O relatório já contém um pedido de análise para a IA.

## Status e limitações

Prévia pública para a interface **16001**. **132 testes simulados de Lua 5.1** passaram; ainda não houve teste em uma sessão real de WoW Forever.

O nome do personagem é omitido por padrão. O addon não transmite dados nem exige chave de API. As bolsas só são exportadas se você ativar a opção; banco, correio e outros personagens ficam de fora. Perfis, fontes e preferências são salvos por personagem. O modo sem spoilers filtra o relatório e orienta a IA, mas não controla suas respostas nem remove seus próprios textos. Dados indisponíveis são marcados como desconhecidos. Esta versão ainda precisa de verificação no jogo.

A interface detecta o idioma do jogo e permite alterá-lo nas opções de exportação ou com `/fcontext language`. Há 10 idiomas disponíveis; o relatório continua em inglês e os nomes do jogo mantêm o idioma do cliente. A escolha vale para toda a conta e é aplicada sem recarregar. [Guia de idiomas](LOCALIZATION.md). [README](../README.md) · [All Rights Reserved](../LICENSE).

Todos os direitos reservados para material novo a partir da v1.0.2. É permitido usar versões oficiais sem alterações para uso pessoal e preparar mudanças apenas para uma PR ao repositório oficial, sujeita à aprovação do mantenedor. A comercialização e a publicação de versões alternativas não são autorizadas. O material anteriormente publicado sob MIT mantém essas permissões; esta mudança não as revoga. Consulte os termos completos em inglês em [LICENSE](../LICENSE).
