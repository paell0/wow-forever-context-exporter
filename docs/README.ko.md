# ForeverContext

[English](../README.md) | [Español](README.es.md) | [Português (Brasil)](README.pt-BR.md) | [Français](README.fr.md) | [Deutsch](README.de.md) | [简体中文](README.zh-CN.md) | [繁體中文](README.zh-TW.md) | [日本語](README.ja.md) | [हिन्दी](README.hi.md) | [ไทย](README.th.md) | [한국어](README.ko.md) | [Русский](README.ru.md) | [Italiano](README.it.md)

WoW Forever 캐릭터의 특성, 전문 기술, 장비, 능력치를 일반 텍스트로 내보내 AI에게 조언을 구할 수 있습니다.

## 설치 및 사용

1. [Releases](https://github.com/paell0/wow-forever-context-exporter/releases)에서 `ForeverContext-1.0.1.zip`을 다운로드합니다.
2. 게임을 종료하고 `ForeverContext` 폴더를 `World of Warcraft/_forever_/Interface/AddOns/`에 압축 해제합니다.
3. 경로가 `AddOns/ForeverContext/ForeverContext.toc`인지 확인하고 애드온을 활성화합니다. 이전 ContextoPJ가 있다면 해당 폴더를 먼저 제거하세요.
4. 전투 중이 아닐 때 **`/fcontext`**를 입력합니다.
5. 필요하면 목표를 입력한 뒤 **Generate / refresh**, **Select all**을 클릭합니다. **Ctrl+C**로 복사하고 **Ctrl+V**로 AI에 붙여 넣습니다.

별칭 명령어: `/forevercontext`, `/pjia`. 도움말: `/fcontext help`.

## 내보내는 정보

직업, 종족, 레벨, 경험치, 활성 특성과 남은 포인트, 전문 기술 및 숙련도, 착용 장비의 능력치·효과·마법부여·보석·내구도, 읽을 수 있는 강화 효과와 소환된 소환수 정보가 포함됩니다. 확장 옵션에는 숙련 기술, 배운 주문, 퀘스트와 조회 가능한 평판이 추가됩니다. AI 분석 요청문도 포함되어 있습니다.

## 상태 및 제한

인터페이스 **16001**용 공개 미리 보기 버전입니다. **Lua 5.1 모의 테스트 15개**를 통과했지만 실제 WoW Forever 게임 세션에서는 아직 검증하지 않았습니다.

캐릭터 이름은 기본적으로 제외됩니다. 데이터를 전송하지 않으며 API 키도 필요하지 않습니다. 가방과 은행은 포함되지 않습니다. 적용하지 않은 특성 변경은 현재 특성으로 내보내지 않습니다. 누락된 데이터는 경고로 표시합니다. 특성 또는 전문 기술 창을 연 뒤 다시 생성해 보세요.

애드온 버튼과 보고서 레이블은 영어이며 게임의 이름과 설명은 클라이언트 언어를 유지합니다. 이 문서는 번역된 안내서이며 게임 클라이언트 언어 지원을 추가하지 않습니다. 개발 및 전체 제한 사항은 [영문 README](../README.md)를 참고하세요. 라이선스: [MIT](../LICENSE).
