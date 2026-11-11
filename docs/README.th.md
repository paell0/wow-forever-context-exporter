# ForeverContext

[![Version 1.3.0](https://img.shields.io/static/v1?label=version&message=1.3.0&color=D4A64A&labelColor=162033&style=for-the-badge)](https://github.com/paell0/wow-forever-context-exporter/releases/tag/v1.3.0) [![Public preview](https://img.shields.io/static/v1?label=status&message=public+preview&color=E8A838&labelColor=162033&style=for-the-badge)](https://github.com/paell0/wow-forever-context-exporter#privacy-and-limitations) [![Lua 5.1](https://img.shields.io/static/v1?label=Lua&message=5.1&color=2C2D72&labelColor=162033&style=for-the-badge&logo=lua&logoColor=white)](https://github.com/paell0/wow-forever-context-exporter/tree/main/ForeverContext) [![All Rights Reserved; prior MIT material retains its permissions](https://img.shields.io/static/v1?label=license&message=All+Rights+Reserved&color=B45309&labelColor=162033&style=for-the-badge)](../LICENSE) [![132 simulated tests; not verified in game](https://img.shields.io/static/v1?label=tests&message=132+simulated&color=3B82B6&labelColor=162033&style=for-the-badge)](https://github.com/paell0/wow-forever-context-exporter/blob/main/tests/test_addon.py)

<!-- language-selector:start -->

[![English](https://img.shields.io/static/v1?label=EN&message=English&color=334155&labelColor=162033&style=flat-square)](../README.md) [![Español](https://img.shields.io/static/v1?label=ES&message=Espa%C3%B1ol&color=334155&labelColor=162033&style=flat-square)](README.es.md) [![Français](https://img.shields.io/static/v1?label=FR&message=Fran%C3%A7ais&color=334155&labelColor=162033&style=flat-square)](README.fr.md) [![Deutsch](https://img.shields.io/static/v1?label=DE&message=Deutsch&color=334155&labelColor=162033&style=flat-square)](README.de.md) [![Italiano](https://img.shields.io/static/v1?label=IT&message=Italiano&color=334155&labelColor=162033&style=flat-square)](README.it.md) [![Русский](https://img.shields.io/static/v1?label=RU&message=%D0%A0%D1%83%D1%81%D1%81%D0%BA%D0%B8%D0%B9&color=334155&labelColor=162033&style=flat-square)](README.ru.md)

[![Português (Brasil)](https://img.shields.io/static/v1?label=PT-BR&message=Portugu%C3%AAs+%28Brasil%29&color=334155&labelColor=162033&style=flat-square)](README.pt-BR.md)

[![简体中文](https://img.shields.io/static/v1?label=ZH-CN&message=%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87&color=334155&labelColor=162033&style=flat-square)](README.zh-CN.md) [![繁體中文](https://img.shields.io/static/v1?label=ZH-TW&message=%E7%B9%81%E9%AB%94%E4%B8%AD%E6%96%87&color=334155&labelColor=162033&style=flat-square)](README.zh-TW.md) [![日本語](https://img.shields.io/static/v1?label=JA&message=%E6%97%A5%E6%9C%AC%E8%AA%9E&color=334155&labelColor=162033&style=flat-square)](README.ja.md) [![한국어](https://img.shields.io/static/v1?label=KO&message=%ED%95%9C%EA%B5%AD%EC%96%B4&color=334155&labelColor=162033&style=flat-square)](README.ko.md) [![हिन्दी](https://img.shields.io/static/v1?label=HI&message=%E0%A4%B9%E0%A4%BF%E0%A4%A8%E0%A5%8D%E0%A4%A6%E0%A5%80&color=334155&labelColor=162033&style=flat-square)](README.hi.md) [![ไทย (selected)](https://img.shields.io/static/v1?label=TH&message=%E0%B9%84%E0%B8%97%E0%B8%A2&color=D4A64A&labelColor=162033&style=flat-square)](README.th.md)

<!-- language-selector:end -->

ส่งออกพรสวรรค์ อาชีพ อุปกรณ์ และค่าสถานะของตัวละคร WoW Forever เป็นข้อความธรรมดา เพื่อนำไปขอคำแนะนำจาก AI

คลิกปุ่มบนมินิแมปเพื่อเปิดหรือปิดรายงานได้เช่นกัน ลากปุ่มเพื่อเปลี่ยนตำแหน่ง โดยตำแหน่งจะถูกบันทึกไว้สำหรับครั้งถัดไป ใช้ `/fcontext minimap` เพื่อซ่อนหรือแสดงปุ่มอีกครั้ง

รายงานจะเรียกคำอธิบายพรสวรรค์ตามอันดับปัจจุบันและระบุข้อความอ้างอิงทั่วไปที่ยังไม่ยืนยัน แยกโบนัสเซตเป็นทำงาน ไม่ทำงาน หรือไม่ทราบสถานะ และไม่แสดงความเสียหายมือรองหากไม่มีอาวุธในช่องนั้น ชื่อเรียกค่าต้านทานที่ซ้ำกันและมีค่าเท่ากันจะแสดงเพียงครั้งเดียว

เวอร์ชัน 1.1.0 เพิ่มแผนความก้าวหน้าแยกตามตัวละคร การเปรียบเทียบสองไอเทม รายงานตามคำถาม และการทบทวนคำแนะนำเดิม วางบล็อกแผนจาก AI ใน **Progress plan** ตรวจด้วย **Preview plan** แล้วกด **Accept plan** เป้าหมายที่ตรวจสอบได้จะใช้ข้อมูลตัวละคร ส่วนงานอื่นมีช่องให้ทำเครื่องหมายเอง ลากสองไอเทมลงใน **Compare items** และเลือก **Talent points**, **Gear advice**, **Next session** หรือ **Review plan** รายงานจะแนบเป้าหมายที่ยอมรับและความเปลี่ยนแปลงจากข้อมูลอ้างอิง [คู่มือและรูปแบบแผนฉบับภาษาอังกฤษ](PROGRESS-PLAN.md)


รุ่น 1.2.0 เพิ่มเจ็ดอย่าง: แหล่งไอเทมพร้อมข้อมูลอ้างอิงและสถานะยืนยัน โปรไฟล์ทาเลนต์ตามกิจกรรม คำเตือนเมื่อเวอร์ชันเปลี่ยน การส่งออกกระเป๋าแบบเลือกได้ รายการไอเทมที่ต้องการเก็บ โหมดไม่สปอยล์ และการเลือกหมวดส่งออก เปิด **Item sources**, **Talent profiles**, **Browse bags**, **Keep items** และ **Export options** ข้อมูลที่พบในเกม การยืนยันของผู้เล่น และบันทึกที่ยังไม่ยืนยันจะแยกกัน ไม่มีฐานข้อมูลของดรอปครบทั้งหมด [คู่มือเจ็ดเครื่องมือภาษาอังกฤษ](COMMUNITY-TOOLS.md)

## การติดตั้งและใช้งาน

1. ดาวน์โหลด `ForeverContext-1.3.0.zip` จาก [Releases](https://github.com/paell0/wow-forever-context-exporter/releases)
2. ปิดเกมแล้วแตกโฟลเดอร์ `ForeverContext` ลงใน `World of Warcraft/_forever_/Interface/AddOns/`
3. ตรวจสอบว่ามีไฟล์ `AddOns/ForeverContext/ForeverContext.toc` และเปิดใช้งานแอดออน หากเคยติดตั้ง ContextoPJ ให้ลบโฟลเดอร์เก่าก่อน
4. ขณะไม่ได้ต่อสู้ ให้พิมพ์ **`/fcontext`**
5. ระบุเป้าหมายได้ตามต้องการ คลิก **Generate / refresh** แล้วคลิก **Select all** กด **Ctrl+C** เพื่อคัดลอก และกด **Ctrl+V** เพื่อวางใน AI

คำสั่งอื่นที่ใช้ได้: `/forevercontext` และ `/pjia` ดูความช่วยเหลือด้วย `/fcontext help`

## ข้อมูลที่ส่งออก

คลาส เผ่า เลเวล ประสบการณ์ พรสวรรค์ที่ใช้งานและแต้มที่เหลือ อาชีพและระดับทักษะ อุปกรณ์ที่สวมใส่พร้อมค่าสถานะ เอฟเฟกต์ เอนแชนต์ อัญมณี และความทนทาน รวมถึงบัฟที่อ่านได้และสัตว์เลี้ยงที่เรียกอยู่ ตัวเลือกเพิ่มเติมรวมทักษะ คาถาที่เรียนแล้ว เควสต์ และชื่อเสียงที่เรียกดูได้ รายงานมีข้อความขอให้ AI วิเคราะห์อยู่แล้ว

## สถานะและข้อจำกัด

รุ่นทดลองสาธารณะสำหรับอินเทอร์เฟซ **16001** ผ่านการทดสอบจำลอง **Lua 5.1 จำนวน 132 รายการ** แต่ยังไม่ได้ทดสอบในเซสชัน WoW Forever จริง

ค่าเริ่มต้นไม่แสดงชื่อตัวละคร ไม่มีการส่งข้อมูลและไม่ต้องใช้คีย์ API ส่งออกกระเป๋าเฉพาะเมื่อเปิดตัวเลือก ไม่รวมธนาคาร จดหมาย หรือตัวละครอื่น โปรไฟล์ แหล่งไอเทม และค่าตั้งบันทึกแยกตามตัวละคร โหมดไม่สปอยล์กรองรายงานและกำชับ AI แต่ควบคุมคำตอบหรือข้อความที่คุณเขียนเองไม่ได้ ข้อมูลที่อ่านไม่ได้จะแสดงว่าไม่ทราบ รุ่นนี้ยังต้องตรวจสอบในเกม

หน้าต่างจะใช้ภาษาของเกมโดยอัตโนมัติ เปลี่ยนได้ในตัวเลือกส่งออกหรือด้วย `/fcontext language` มี 10 ภาษาให้เลือก แต่ยังไม่มีภาษาไทย รายงานยังเป็นภาษาอังกฤษ และชื่อในเกมคงภาษาของไคลเอนต์ การเลือกมีผลทั้งบัญชีทันทีโดยไม่ต้องโหลดใหม่ [คู่มือภาษา](LOCALIZATION.md) [README](../README.md) · [All Rights Reserved](../LICENSE).

สงวนสิทธิ์ในเนื้อหาต้นฉบับใหม่ตั้งแต่ v1.0.2 อนุญาตให้ใช้รุ่นทางการที่ไม่แก้ไขเป็นการส่วนตัว และแก้ไขหรือทดสอบเพื่อส่ง PR ไปยังคลังทางการเท่านั้น โดยผู้ดูแลเป็นผู้ตัดสินใจรับการเปลี่ยนแปลง ไม่อนุญาตให้นำไปจำหน่ายหรือเผยแพร่รุ่นดัดแปลงแยกต่างหาก เนื้อหาที่เคยเผยแพร่ภายใต้ MIT ยังคงมีสิทธิ์เดิม การเปลี่ยนแปลงนี้ไม่เพิกถอนสิทธิ์นั้น ดูข้อกำหนดภาษาอังกฤษฉบับเต็มใน [LICENSE](../LICENSE)
