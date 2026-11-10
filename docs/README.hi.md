# ForeverContext

[![Version 1.0.2](https://img.shields.io/static/v1?label=version&message=1.0.2&color=D4A64A&labelColor=162033&style=for-the-badge)](https://github.com/paell0/wow-forever-context-exporter/releases/tag/v1.0.2) [![Public preview](https://img.shields.io/static/v1?label=status&message=public+preview&color=E8A838&labelColor=162033&style=for-the-badge)](https://github.com/paell0/wow-forever-context-exporter#privacy-and-limitations) [![Lua 5.1](https://img.shields.io/static/v1?label=Lua&message=5.1&color=2C2D72&labelColor=162033&style=for-the-badge&logo=lua&logoColor=white)](https://github.com/paell0/wow-forever-context-exporter/tree/main/ForeverContext) [![All Rights Reserved; prior MIT material retains its permissions](https://img.shields.io/static/v1?label=license&message=All+Rights+Reserved&color=B45309&labelColor=162033&style=for-the-badge)](../LICENSE) [![15 simulated tests; not verified in game](https://img.shields.io/static/v1?label=tests&message=15+simulated&color=3B82B6&labelColor=162033&style=for-the-badge)](https://github.com/paell0/wow-forever-context-exporter/blob/main/tests/test_addon.py)

<!-- language-selector:start -->

[![English](https://img.shields.io/static/v1?label=EN&message=English&color=334155&labelColor=162033&style=flat-square)](../README.md) [![Español](https://img.shields.io/static/v1?label=ES&message=Espa%C3%B1ol&color=334155&labelColor=162033&style=flat-square)](README.es.md) [![Français](https://img.shields.io/static/v1?label=FR&message=Fran%C3%A7ais&color=334155&labelColor=162033&style=flat-square)](README.fr.md) [![Deutsch](https://img.shields.io/static/v1?label=DE&message=Deutsch&color=334155&labelColor=162033&style=flat-square)](README.de.md) [![Italiano](https://img.shields.io/static/v1?label=IT&message=Italiano&color=334155&labelColor=162033&style=flat-square)](README.it.md) [![Русский](https://img.shields.io/static/v1?label=RU&message=%D0%A0%D1%83%D1%81%D1%81%D0%BA%D0%B8%D0%B9&color=334155&labelColor=162033&style=flat-square)](README.ru.md)

[![Português (Brasil)](https://img.shields.io/static/v1?label=PT-BR&message=Portugu%C3%AAs+%28Brasil%29&color=334155&labelColor=162033&style=flat-square)](README.pt-BR.md)

[![简体中文](https://img.shields.io/static/v1?label=ZH-CN&message=%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87&color=334155&labelColor=162033&style=flat-square)](README.zh-CN.md) [![繁體中文](https://img.shields.io/static/v1?label=ZH-TW&message=%E7%B9%81%E9%AB%94%E4%B8%AD%E6%96%87&color=334155&labelColor=162033&style=flat-square)](README.zh-TW.md) [![日本語](https://img.shields.io/static/v1?label=JA&message=%E6%97%A5%E6%9C%AC%E8%AA%9E&color=334155&labelColor=162033&style=flat-square)](README.ja.md) [![한국어](https://img.shields.io/static/v1?label=KO&message=%ED%95%9C%EA%B5%AD%EC%96%B4&color=334155&labelColor=162033&style=flat-square)](README.ko.md) [![हिन्दी (selected)](https://img.shields.io/static/v1?label=HI&message=%E0%A4%B9%E0%A4%BF%E0%A4%A8%E0%A5%8D%E0%A4%A6%E0%A5%80&color=D4A64A&labelColor=162033&style=flat-square)](README.hi.md) [![ไทย](https://img.shields.io/static/v1?label=TH&message=%E0%B9%84%E0%B8%97%E0%B8%A2&color=334155&labelColor=162033&style=flat-square)](README.th.md)

<!-- language-selector:end -->

अपने WoW Forever पात्र की प्रतिभाएँ, पेशे, उपकरण और आँकड़े सादे पाठ में निर्यात करें, ताकि आप AI से सलाह माँग सकें।

## इंस्टॉल करना और उपयोग

1. [Releases](https://github.com/paell0/wow-forever-context-exporter/releases) से `ForeverContext-1.0.2.zip` डाउनलोड करें।
2. गेम बंद करें और `ForeverContext` फ़ोल्डर को `World of Warcraft/_forever_/Interface/AddOns/` में निकालें।
3. सुनिश्चित करें कि पथ `AddOns/ForeverContext/ForeverContext.toc` है और ऐडऑन चालू करें। पुराना ContextoPJ इंस्टॉल हो तो उसका फ़ोल्डर पहले हटा दें।
4. युद्ध के बाहर **`/fcontext`** लिखें।
5. चाहें तो अपना लक्ष्य लिखें। **Generate / refresh**, फिर **Select all** पर क्लिक करें। **Ctrl+C** से कॉपी करके **Ctrl+V** से AI में चिपकाएँ।

वैकल्पिक कमांड: `/forevercontext` और `/pjia`। सहायता: `/fcontext help`।

## रिपोर्ट में क्या मिलता है

वर्ग, जाति, स्तर, अनुभव, सक्रिय प्रतिभाएँ और उपलब्ध अंक; पेशे और कौशल स्तर; पहने हुए उपकरणों के आँकड़े, प्रभाव, एन्चैंटमेंट, रत्न और टिकाऊपन; पढ़े जा सकने वाले बफ़ और बुलाया हुआ पालतू। विस्तृत विकल्प में कौशल, सीखे हुए मंत्र, क्वेस्ट और उपलब्ध प्रतिष्ठा भी शामिल हैं। रिपोर्ट में AI के लिए विश्लेषण का अनुरोध पहले से है।

## स्थिति और सीमाएँ

इंटरफ़ेस **16001** के लिए सार्वजनिक पूर्वावलोकन। **Lua 5.1 के 15 सिम्युलेटेड परीक्षण** सफल हैं; वास्तविक WoW Forever सत्र में अभी परीक्षण नहीं हुआ है।

पात्र का नाम डिफ़ॉल्ट रूप से शामिल नहीं होता। ऐडऑन डेटा नहीं भेजता और API कुंजी नहीं माँगता। बैग और बैंक शामिल नहीं हैं। लागू न किए गए प्रतिभा बदलाव सक्रिय नहीं माने जाते। अधूरे डेटा के लिए चेतावनी मिलती है; प्रतिभा या पेशे की विंडो खोलकर रिपोर्ट फिर बनाएँ।

ऐडऑन के नियंत्रण और रिपोर्ट लेबल अंग्रेज़ी में हैं। गेम के नाम और विवरण क्लाइंट की भाषा में रहते हैं। यह केवल दस्तावेज़ का अनुवाद है, हिन्दी गेम क्लाइंट समर्थन का दावा नहीं। विकास और पूरी सीमाओं के लिए [अंग्रेज़ी README](../README.md) देखें। लाइसेंस: [All Rights Reserved](../LICENSE)।

v1.0.2 से नई मौलिक सामग्री के सभी अधिकार सुरक्षित हैं। आधिकारिक अपरिवर्तित संस्करणों का व्यक्तिगत उपयोग और केवल आधिकारिक रिपॉज़िटरी में PR भेजने के लिए बदलाव व परीक्षण की अनुमति है; स्वीकृति रखरखावकर्ता तय करता है। व्यावसायीकरण या अलग संशोधित संस्करण प्रकाशित करने की अनुमति नहीं है। पहले MIT के तहत प्रकाशित सामग्री के अधिकार बने रहते हैं; यह बदलाव उन्हें रद्द नहीं करता। पूर्ण अंग्रेज़ी शर्तें [LICENSE](../LICENSE) में हैं।
