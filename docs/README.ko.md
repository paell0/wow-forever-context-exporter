# ForeverContext

[![Version 1.0.5](https://img.shields.io/static/v1?label=version&message=1.0.5&color=D4A64A&labelColor=162033&style=for-the-badge)](https://github.com/paell0/wow-forever-context-exporter/releases/tag/v1.0.5) [![Public preview](https://img.shields.io/static/v1?label=status&message=public+preview&color=E8A838&labelColor=162033&style=for-the-badge)](https://github.com/paell0/wow-forever-context-exporter#privacy-and-limitations) [![Lua 5.1](https://img.shields.io/static/v1?label=Lua&message=5.1&color=2C2D72&labelColor=162033&style=for-the-badge&logo=lua&logoColor=white)](https://github.com/paell0/wow-forever-context-exporter/tree/main/ForeverContext) [![All Rights Reserved; prior MIT material retains its permissions](https://img.shields.io/static/v1?label=license&message=All+Rights+Reserved&color=B45309&labelColor=162033&style=for-the-badge)](../LICENSE) [![37 simulated tests; not verified in game](https://img.shields.io/static/v1?label=tests&message=37+simulated&color=3B82B6&labelColor=162033&style=for-the-badge)](https://github.com/paell0/wow-forever-context-exporter/blob/main/tests/test_addon.py)

<!-- language-selector:start -->

[![English](https://img.shields.io/static/v1?label=EN&message=English&color=334155&labelColor=162033&style=flat-square)](../README.md) [![Español](https://img.shields.io/static/v1?label=ES&message=Espa%C3%B1ol&color=334155&labelColor=162033&style=flat-square)](README.es.md) [![Français](https://img.shields.io/static/v1?label=FR&message=Fran%C3%A7ais&color=334155&labelColor=162033&style=flat-square)](README.fr.md) [![Deutsch](https://img.shields.io/static/v1?label=DE&message=Deutsch&color=334155&labelColor=162033&style=flat-square)](README.de.md) [![Italiano](https://img.shields.io/static/v1?label=IT&message=Italiano&color=334155&labelColor=162033&style=flat-square)](README.it.md) [![Русский](https://img.shields.io/static/v1?label=RU&message=%D0%A0%D1%83%D1%81%D1%81%D0%BA%D0%B8%D0%B9&color=334155&labelColor=162033&style=flat-square)](README.ru.md)

[![Português (Brasil)](https://img.shields.io/static/v1?label=PT-BR&message=Portugu%C3%AAs+%28Brasil%29&color=334155&labelColor=162033&style=flat-square)](README.pt-BR.md)

[![简体中文](https://img.shields.io/static/v1?label=ZH-CN&message=%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87&color=334155&labelColor=162033&style=flat-square)](README.zh-CN.md) [![繁體中文](https://img.shields.io/static/v1?label=ZH-TW&message=%E7%B9%81%E9%AB%94%E4%B8%AD%E6%96%87&color=334155&labelColor=162033&style=flat-square)](README.zh-TW.md) [![日本語](https://img.shields.io/static/v1?label=JA&message=%E6%97%A5%E6%9C%AC%E8%AA%9E&color=334155&labelColor=162033&style=flat-square)](README.ja.md) [![한국어 (selected)](https://img.shields.io/static/v1?label=KO&message=%ED%95%9C%EA%B5%AD%EC%96%B4&color=D4A64A&labelColor=162033&style=flat-square)](README.ko.md) [![हिन्दी](https://img.shields.io/static/v1?label=HI&message=%E0%A4%B9%E0%A4%BF%E0%A4%A8%E0%A5%8D%E0%A4%A6%E0%A5%80&color=334155&labelColor=162033&style=flat-square)](README.hi.md) [![ไทย](https://img.shields.io/static/v1?label=TH&message=%E0%B9%84%E0%B8%97%E0%B8%A2&color=334155&labelColor=162033&style=flat-square)](README.th.md)

<!-- language-selector:end -->

WoW Forever 캐릭터의 특성, 전문 기술, 장비, 능력치를 일반 텍스트로 내보내 AI에게 조언을 구할 수 있습니다.

미니맵 버튼을 클릭하여 보고서를 열거나 닫을 수도 있습니다. 드래그하여 위치를 바꾸면 다음 접속 시에도 유지됩니다. `/fcontext minimap`으로 버튼을 숨기거나 다시 표시할 수 있습니다.

보고서는 특성의 현재 등급 설명을 조회하고 검증되지 않은 일반 참고 설명을 명확히 표시합니다. 세트 효과는 활성·비활성·상태 불명으로 구분하며 보조 장비 칸에 무기가 없으면 보조 무기 피해를 표시하지 않습니다. 값이 같은 중복 저항 별칭도 정리합니다.

## 설치 및 사용

1. [Releases](https://github.com/paell0/wow-forever-context-exporter/releases)에서 `ForeverContext-1.0.5.zip`을 다운로드합니다.
2. 게임을 종료하고 `ForeverContext` 폴더를 `World of Warcraft/_forever_/Interface/AddOns/`에 압축 해제합니다.
3. 경로가 `AddOns/ForeverContext/ForeverContext.toc`인지 확인하고 애드온을 활성화합니다. 이전 ContextoPJ가 있다면 해당 폴더를 먼저 제거하세요.
4. 전투 중이 아닐 때 **`/fcontext`**를 입력합니다.
5. 필요하면 목표를 입력한 뒤 **Generate / refresh**, **Select all**을 클릭합니다. **Ctrl+C**로 복사하고 **Ctrl+V**로 AI에 붙여 넣습니다.

별칭 명령어: `/forevercontext`, `/pjia`. 도움말: `/fcontext help`.

## 내보내는 정보

직업, 종족, 레벨, 경험치, 활성 특성과 남은 포인트, 전문 기술 및 숙련도, 착용 장비의 능력치·효과·마법부여·보석·내구도, 읽을 수 있는 강화 효과와 소환된 소환수 정보가 포함됩니다. 확장 옵션에는 숙련 기술, 배운 주문, 퀘스트와 조회 가능한 평판이 추가됩니다. AI 분석 요청문도 포함되어 있습니다.

## 상태 및 제한

인터페이스 **16001**용 공개 미리 보기 버전입니다. **Lua 5.1 모의 테스트 37개**를 통과했지만 실제 WoW Forever 게임 세션에서는 아직 검증하지 않았습니다.

캐릭터 이름은 기본적으로 제외됩니다. 데이터를 전송하지 않으며 API 키도 필요하지 않습니다. 가방과 은행은 포함되지 않습니다. 적용하지 않은 특성 변경은 현재 특성으로 내보내지 않습니다. 누락된 데이터는 경고로 표시합니다. 특성 또는 전문 기술 창을 연 뒤 다시 생성해 보세요.

애드온 버튼과 보고서 레이블은 영어이며 게임의 이름과 설명은 클라이언트 언어를 유지합니다. 이 문서는 번역된 안내서이며 게임 클라이언트 언어 지원을 추가하지 않습니다. 개발 및 전체 제한 사항은 [영문 README](../README.md)를 참고하세요. 라이선스: [All Rights Reserved](../LICENSE).

v1.0.2부터 새롭게 작성된 자료의 권리는 명시된 허용 범위를 제외하고 보유합니다. 수정하지 않은 공식 버전의 개인적 사용과 공식 저장소에 PR을 제출하기 위한 수정·테스트만 허용하며, 수락 여부는 관리자가 결정합니다. 상업화 또는 별도 수정판 배포는 허용하지 않습니다. 기존 MIT 자료에 부여된 권한은 유지되며 이 변경으로 철회되지 않습니다. 전체 영문 조건은 [LICENSE](../LICENSE)를 참고하세요.
