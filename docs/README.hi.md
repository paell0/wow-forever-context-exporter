# ForeverContext

[![Version 1.4.0](https://img.shields.io/static/v1?label=version&message=1.4.0&color=D4A64A&labelColor=162033&style=for-the-badge)](https://github.com/paell0/wow-forever-context-exporter/releases/tag/v1.4.0) [![Public preview](https://img.shields.io/static/v1?label=status&message=public+preview&color=E8A838&labelColor=162033&style=for-the-badge)](https://github.com/paell0/wow-forever-context-exporter#privacy-and-limitations) [![Lua 5.1](https://img.shields.io/static/v1?label=Lua&message=5.1&color=2C2D72&labelColor=162033&style=for-the-badge&logo=lua&logoColor=white)](https://github.com/paell0/wow-forever-context-exporter/tree/main/ForeverContext) [![All Rights Reserved; prior MIT material retains its permissions](https://img.shields.io/static/v1?label=license&message=All+Rights+Reserved&color=B45309&labelColor=162033&style=for-the-badge)](../LICENSE) [![144 simulated tests; not verified in game](https://img.shields.io/static/v1?label=tests&message=144+simulated&color=3B82B6&labelColor=162033&style=for-the-badge)](https://github.com/paell0/wow-forever-context-exporter/blob/main/tests/test_addon.py)

<!-- language-selector:start -->

[![English](https://img.shields.io/static/v1?label=EN&message=English&color=334155&labelColor=162033&style=flat-square)](../README.md) [![Español](https://img.shields.io/static/v1?label=ES&message=Espa%C3%B1ol&color=334155&labelColor=162033&style=flat-square)](README.es.md) [![Français](https://img.shields.io/static/v1?label=FR&message=Fran%C3%A7ais&color=334155&labelColor=162033&style=flat-square)](README.fr.md) [![Deutsch](https://img.shields.io/static/v1?label=DE&message=Deutsch&color=334155&labelColor=162033&style=flat-square)](README.de.md) [![Italiano](https://img.shields.io/static/v1?label=IT&message=Italiano&color=334155&labelColor=162033&style=flat-square)](README.it.md) [![Русский](https://img.shields.io/static/v1?label=RU&message=%D0%A0%D1%83%D1%81%D1%81%D0%BA%D0%B8%D0%B9&color=334155&labelColor=162033&style=flat-square)](README.ru.md)

[![Português (Brasil)](https://img.shields.io/static/v1?label=PT-BR&message=Portugu%C3%AAs+%28Brasil%29&color=334155&labelColor=162033&style=flat-square)](README.pt-BR.md)

[![简体中文](https://img.shields.io/static/v1?label=ZH-CN&message=%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87&color=334155&labelColor=162033&style=flat-square)](README.zh-CN.md) [![繁體中文](https://img.shields.io/static/v1?label=ZH-TW&message=%E7%B9%81%E9%AB%94%E4%B8%AD%E6%96%87&color=334155&labelColor=162033&style=flat-square)](README.zh-TW.md) [![日本語](https://img.shields.io/static/v1?label=JA&message=%E6%97%A5%E6%9C%AC%E8%AA%9E&color=334155&labelColor=162033&style=flat-square)](README.ja.md) [![한국어](https://img.shields.io/static/v1?label=KO&message=%ED%95%9C%EA%B5%AD%EC%96%B4&color=334155&labelColor=162033&style=flat-square)](README.ko.md) [![हिन्दी (selected)](https://img.shields.io/static/v1?label=HI&message=%E0%A4%B9%E0%A4%BF%E0%A4%A8%E0%A5%8D%E0%A4%A6%E0%A5%80&color=D4A64A&labelColor=162033&style=flat-square)](README.hi.md) [![ไทย](https://img.shields.io/static/v1?label=TH&message=%E0%B9%84%E0%B8%97%E0%B8%A2&color=334155&labelColor=162033&style=flat-square)](README.th.md)

<!-- language-selector:end -->

अपने WoW Forever पात्र की प्रतिभाएँ, पेशे, उपकरण और आँकड़े सादे पाठ में निर्यात करें, ताकि आप AI से सलाह माँग सकें।

मिनीमैप बटन पर क्लिक करके भी रिपोर्ट खोल या बंद कर सकते हैं। बटन को खींचकर उसकी स्थिति बदलें; स्थिति अगले सत्र के लिए सहेजी जाती है। बटन छिपाने या फिर दिखाने के लिए `/fcontext minimap` लिखें।

रिपोर्ट प्रतिभाओं के वर्तमान रैंक की व्याख्या प्राप्त करती है और अपुष्ट सामान्य विवरणों को स्पष्ट करती है। सेट बोनस सक्रिय, निष्क्रिय या अज्ञात के रूप में चिह्नित होते हैं। दूसरे हाथ में हथियार न हो तो उसका नुकसान नहीं दिखता। समान मान वाले दोहराए गए प्रतिरोध नाम एक बार दिखते हैं।

1.1.0 में हर पात्र के लिए प्रगति योजना, दो वस्तुओं की तुलना, प्रश्न के अनुसार रिपोर्ट और पिछले सुझावों की समीक्षा जोड़ी गई है। **Progress plan** में AI का योजना ब्लॉक चिपकाएँ, **Preview plan** से जाँचें और **Accept plan** से स्वीकार करें। सत्यापित किए जा सकने वाले लक्ष्य पात्र के डेटा से अपडेट होते हैं; अन्य कार्य मैन्युअल चेकबॉक्स से पूरे होते हैं। **Compare items** में दो वस्तुएँ खींचें। **Talent points**, **Gear advice**, **Next session** या **Review plan** चुनें। रिपोर्ट में स्वीकार किए गए लक्ष्य और संदर्भ से बदलाव शामिल होते हैं। [पूरी अंग्रेज़ी मार्गदर्शिका और योजना प्रारूप](PROGRESS-PLAN.md)।


1.2.0 में सात सुधार हैं: संदर्भ और पुष्टि के साथ वस्तुओं के स्रोत, गतिविधि के अनुसार टैलेंट प्रोफ़ाइल, संस्करण बदलने की चेतावनी, वैकल्पिक बैग निर्यात, सुरक्षित रखने वाली वस्तुओं की सूची, स्पॉइलर-रहित मोड और निर्यात श्रेणियों का चयन। **Item sources**, **Talent profiles**, **Browse bags**, **Keep items** और **Export options** खोलें। खेल में देखी गई जानकारी, खिलाड़ी की पुष्टि और अपुष्ट नोट अलग दिखते हैं; पूरा लूट डेटाबेस शामिल नहीं है। [सात टूल की अंग्रेज़ी गाइड](COMMUNITY-TOOLS.md)।


1.4 में उपयोग सरल है: **1. Prepare text → 2. Select text → Ctrl+C**, फिर AI में **Ctrl+V** से चिपकाएँ। **More tools** वैकल्पिक सुविधाएँ समझाता है। सेटिंग्स में पहले सरल विकल्प दिखते हैं; तुलना और योजनाओं में क्रमांकित चरण हैं। हिन्दी UI शामिल नहीं है। [अंग्रेज़ी शुरुआती गाइड](QUICKSTART.md)।

## इंस्टॉल करना और उपयोग

1. [Releases](https://github.com/paell0/wow-forever-context-exporter/releases) से `ForeverContext-1.4.0.zip` डाउनलोड करें।
2. गेम बंद करें और `ForeverContext` फ़ोल्डर को `World of Warcraft/_forever_/Interface/AddOns/` में निकालें।
3. सुनिश्चित करें कि पथ `AddOns/ForeverContext/ForeverContext.toc` है और ऐडऑन चालू करें। पुराना ContextoPJ इंस्टॉल हो तो उसका फ़ोल्डर पहले हटा दें।
4. युद्ध के बाहर **`/fcontext`** लिखें।
5. चाहें तो अपना लक्ष्य लिखें। **1. Prepare text**, फिर **2. Select text** पर क्लिक करें। **Ctrl+C** से कॉपी करके **Ctrl+V** से AI में चिपकाएँ।

वैकल्पिक कमांड: `/forevercontext` और `/pjia`। सहायता: `/fcontext help`।

## रिपोर्ट में क्या मिलता है

वर्ग, जाति, स्तर, अनुभव, सक्रिय प्रतिभाएँ और उपलब्ध अंक; पेशे और कौशल स्तर; पहने हुए उपकरणों के आँकड़े, प्रभाव, एन्चैंटमेंट, रत्न और टिकाऊपन; पढ़े जा सकने वाले बफ़ और बुलाया हुआ पालतू। विस्तृत विकल्प में कौशल, सीखे हुए मंत्र, क्वेस्ट और उपलब्ध प्रतिष्ठा भी शामिल हैं। रिपोर्ट में AI के लिए विश्लेषण का अनुरोध पहले से है।

## स्थिति और सीमाएँ

इंटरफ़ेस **16001** के लिए सार्वजनिक पूर्वावलोकन। **Lua 5.1 के 144 सिम्युलेटेड परीक्षण** सफल हैं; वास्तविक WoW Forever सत्र में अभी परीक्षण नहीं हुआ है।

पात्र का नाम डिफ़ॉल्ट रूप से छिपा रहता है। डेटा भेजा नहीं जाता और API कुंजी नहीं चाहिए। बैग केवल विकल्प चालू करने पर निर्यात होते हैं; बैंक, डाक और दूसरे पात्र शामिल नहीं हैं। प्रोफ़ाइल, स्रोत और पसंद हर पात्र के लिए अलग सहेजे जाते हैं। स्पॉइलर-रहित मोड रिपोर्ट फ़िल्टर करता है और AI को निर्देश देता है, लेकिन उसके जवाब या आपके लिखे पाठ को नियंत्रित नहीं करता। अनुपलब्ध डेटा अज्ञात दिखता है। इस संस्करण की खेल में जाँच अभी बाकी है।

इंटरफ़ेस खेल की भाषा पहचानता है। निर्यात विकल्पों या `/fcontext language` से 10 भाषाओं में से चुनें; हिन्दी इंटरफ़ेस अभी शामिल नहीं है। रिपोर्ट अंग्रेज़ी में रहती है और खेल के नाम क्लाइंट की भाषा में रहते हैं। चयन बिना रीलोड पूरे खाते पर लागू होता है। [भाषा गाइड](LOCALIZATION.md)। [README](../README.md) · [All Rights Reserved](../LICENSE).

v1.0.2 से नई मौलिक सामग्री के सभी अधिकार सुरक्षित हैं। आधिकारिक अपरिवर्तित संस्करणों का व्यक्तिगत उपयोग और केवल आधिकारिक रिपॉज़िटरी में PR भेजने के लिए बदलाव व परीक्षण की अनुमति है; स्वीकृति रखरखावकर्ता तय करता है। व्यावसायीकरण या अलग संशोधित संस्करण प्रकाशित करने की अनुमति नहीं है। पहले MIT के तहत प्रकाशित सामग्री के अधिकार बने रहते हैं; यह बदलाव उन्हें रद्द नहीं करता। पूर्ण अंग्रेज़ी शर्तें [LICENSE](../LICENSE) में हैं।
