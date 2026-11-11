local _, NS = ...
NS.LocaleCatalog = {}
NS.LocaleOptions = {
    {"auto", "Automatic (game language)"}, {"enUS", "English"}, {"esES", "Español"},
    {"ptBR", "Português (Brasil)"}, {"frFR", "Français"}, {"deDE", "Deutsch"},
    {"itIT", "Italiano"}, {"ruRU", "Русский"}, {"zhCN", "简体中文"},
    {"zhTW", "繁體中文"}, {"koKR", "한국어"},
}
local aliases = {enus="enUS", engb="enUS", eses="esES", esmx="esES", ptbr="ptBR", ptpt="ptBR",
    frfr="frFR", dede="deDE", itit="itIT", ruru="ruRU", zhcn="zhCN", zhtw="zhTW", kokr="koKR", auto="auto"}
local bindings = setmetatable({}, {__mode="k"})
local patterns = {}
local fonts=setmetatable({}, {__mode="k"})
local fontLocales=setmetatable({}, {__mode="k"})
local glyphFonts={zhCN="Fonts\\ARKai_T.ttf", zhTW="Fonts\\blei00d.TTF", koKR="Fonts\\2002.TTF", ruRU="Fonts\\FRIZQT___CYR.TTF"}

local function applyFont(widget, locale)
    local font=widget
    if type(widget.GetFontString)=="function" then
        local ok, child=pcall(widget.GetFontString,widget)
        if ok and child then font=child end
    end
    if type(font.GetFont)~="function" or type(font.SetFont)~="function" then return end
    local original=fonts[font]
    if not original then
        local ok,path,size,flags=pcall(font.GetFont,font)
        if not ok or not path or not size then return end
        original={path,size,flags}; fonts[font]=original
    end
    -- Only addon-owned text is touched; preserve the original size and style.
    pcall(font.SetFont,font,glyphFonts[locale] or original[1],original[2],original[3])
end

function NS.GetLanguageSetting()
    local selected = type(ForeverContextDB)=="table" and ForeverContextDB.language
    return type(selected)=="string" and aliases[selected:lower()] or "auto"
end

function NS.GetLanguage()
    local selected=NS.GetLanguageSetting()
    if selected and selected~="auto" then return selected end
    local locale = type(GetLocale)=="function" and GetLocale() or "enUS"
    return type(locale)=="string" and aliases[locale:lower()] or "enUS"
end

local function format(text, args)
    return (text:gsub("{(%d+)}", function(index)
        local value=args[tonumber(index)]
        return value==nil and "{" .. index .. "}" or tostring(value)
    end))
end

function NS.AddLocalePattern(key)
    local count=0
    local pattern=key:gsub("([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1")
    pattern=pattern:gsub("{%d+}",function() count=count+1; return "(.-)" end)
    if count>0 then patterns[#patterns+1]={key=key,pattern="^" .. pattern .. "$"} end
end

function NS.L(key, ...)
    if type(key)~="string" then return key end
    local catalog=NS.LocaleCatalog[NS.GetLanguage()] or {}
    local translated=catalog[key]
    local args={...}
    if translated then return format(translated,args) end
    if select("#",...)>0 then return format(key,args) end
    local prefix, inner = key:match("^(|c%x%x%x%x%x%x%x%x)(.-)|r$")
    if prefix then return prefix .. NS.L(inner) .. "|r" end
    for _, entry in ipairs(patterns) do
        local captures={key:match(entry.pattern)}
        if captures[1] then return format(catalog[entry.key] or entry.key,captures) end
    end
    return key
end

function NS.BindText(widget, resolver)
    bindings[widget]=resolver
    applyFont(widget,fontLocales[widget] or NS.GetLanguage())
    if widget.foreverPlainText then NS.SetPlainText(widget,resolver()) else widget:SetText(resolver()) end
end

function NS.SetWidgetLanguageFont(widget,locale)
    fontLocales[widget]=aliases[locale:lower()]
    applyFont(widget,fontLocales[widget] or NS.GetLanguage())
end

function NS.SetText(widget, key, ...)
    local args={...}
    NS.BindText(widget,function() return NS.L(key,unpack(args)) end)
end

function NS.LanguageLabel()
    local selected=NS.GetLanguageSetting()
    if not selected or selected=="auto" then
        local name=NS.GetLanguage()
        for _, row in ipairs(NS.LocaleOptions) do if row[1]==name then name=row[2]; break end end
        return NS.L("Automatic — {1}",name)
    end
    for _, row in ipairs(NS.LocaleOptions) do if row[1]==NS.GetLanguage() then return row[2] end end
    return "English"
end

function NS.SetLanguage(locale)
    local normalized=type(locale)=="string" and aliases[locale:lower()]
    if not normalized then return nil,NS.L("Unsupported language.") end
    if type(ForeverContextDB)~="table" then ForeverContextDB={} end
    ForeverContextDB.language=normalized
    for widget,resolver in pairs(bindings) do
        applyFont(widget,fontLocales[widget] or NS.GetLanguage())
        if widget.foreverPlainText then NS.SetPlainText(widget,resolver()) else widget:SetText(resolver()) end
    end
    return true
end
