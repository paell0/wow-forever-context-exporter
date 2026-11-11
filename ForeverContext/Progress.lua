local _, NS = ...
local call, number, object, clean = NS.SafeCall, NS.ReadNumber, NS.ReadTable, NS.Clean

local function api(namespace, method)
    return _G[namespace] and _G[namespace][method]
end

local function copy(value, depth)
    depth = depth or 0
    if depth > 16 then return nil end
    if type(value) == "table" then
        local result = {}
        for key, child in pairs(value) do
            if type(key) == "string" or type(key) == "number" then result[key] = copy(child, depth + 1) end
        end
        return result
    elseif type(value) == "string" or type(value) == "number" or type(value) == "boolean" then
        return value
    end
end

function NS.CharacterState()
    if type(ForeverContextCharacterDB) ~= "table" then ForeverContextCharacterDB = {} end
    local state = ForeverContextCharacterDB
    if type(state.options) ~= "table" then
        local old = type(ForeverContextDB) == "table" and ForeverContextDB or {}
        state.options = {goal = type(old.goal) == "string" and old.goal or "", includeName = old.includeName == true, extended = old.extended ~= false}
    end
    if type(state.history) ~= "table" then state.history = {} end
    if type(state.candidates) ~= "table" then state.candidates = {} end
    state.schema = 1
    return state
end

function NS.CharacterSettings() return NS.CharacterState().options end
function NS.ProgressVersion() return number(NS.CharacterState().progressVersion) or 0 end

function NS.CaptureSnapshot(extraTasks)
    local snapshot = {at = clean(call(date, "%Y-%m-%d %H:%M:%S")), level = number(call(UnitLevel, "player")),
        money = number(call(GetMoney)), slots = {}, skills = {}, talents = {}}
    local version, build = call(GetBuildInfo)
    snapshot.client, snapshot.build = clean(version), clean(build)
    snapshot.equipmentReadable = true
    for slot = 1, 19 do
        local id, status = NS.ReadInventorySlot(slot)
        if status == "known" or status == "empty" then
            snapshot.slots[slot] = id
        else
            snapshot.equipmentReadable = false
        end
    end
    local function readSkill(id)
        if not number(id) then return end
        local info = object(call(api("C_SkillInfo", "GetSkillLineInfoByID"), id))
        if info and number(info.rank) then snapshot.skills[id] = {rank = info.rank, name = clean(info.name)} end
    end
    local count = number(call(api("C_SkillInfo", "GetNumSkillLines"))) or 0
    for index = 1, count do
        local info = object(call(api("C_SkillInfo", "GetSkillLineInfo"), index))
        if info and not info.isHeader and number(info.skillID) and number(info.rank) then
            snapshot.skills[info.skillID] = {rank = info.rank, name = clean(info.name)}
        end
    end
    local professions = {call(GetProfessions)}
    -- GetProfessions can contain nil holes; fixed positions must be read individually.
    for index = 1, 6 do
        local profession = professions[index]
        if number(profession) then
            local name, _, rank, _, _, _, id = call(GetProfessionInfo, profession)
            if number(id) and number(rank) then snapshot.skills[id] = {rank = rank, name = clean(name)} end
            local info = number(id) and object(call(api("C_TradeSkillUI", "GetProfessionInfoBySkillLineID"), id))
            if info and number(info.maxSkillLevel) and info.maxSkillLevel > 0 and number(info.skillLevel) then
                snapshot.skills[id] = snapshot.skills[id] or {name = clean(name)}
                snapshot.skills[id].rank = info.skillLevel
            end
        end
    end
    local state = NS.CharacterState()
    for _, task in ipairs(state.plan and state.plan.tasks or {}) do if task.kind == "SKILL" then readSkill(task.id) end end
    for _, task in ipairs(state.history[1] and state.history[1].tasks or {}) do if task.kind == "SKILL" then readSkill(task.id) end end
    for _, task in ipairs(extraTasks or {}) do if task.kind == "SKILL" then readSkill(task.id) end end
    local group = number(call(api("C_SpecializationInfo", "GetActiveSpecGroup") or GetActiveSpecGroup)) or 1
    local configID = number(call(api("C_SpecializationInfo", "GetCombatConfigIDForSpecGroup"), group)) or number(call(api("C_ClassTalents", "GetActiveConfigID")))
    local config = configID and object(call(api("C_Traits", "GetConfigInfo"), configID))
    local staged, checked = NS.HasStagedChanges(configID)
    snapshot.talentsReadable = checked and not staged and config and object(config.treeIDs) and true or false
    if snapshot.talentsReadable then
        for _, tree in ipairs(config.treeIDs) do
            local nodes = object(call(api("C_Traits", "GetTreeNodes"), tree))
            if not nodes then snapshot.talentsReadable = false end
            for _, id in ipairs(nodes or {}) do
                local info = object(call(api("C_Traits", "GetNodeInfo"), configID, id))
                if info then
                    local active = object(info.activeEntry)
                    local rank = active and number(active.rank) or number(info.ranksPurchased)
                    if rank ~= nil then snapshot.talents[id] = rank else snapshot.talentsReadable = false end
                else
                    snapshot.talentsReadable = false
                end
            end
        end
    end
    return snapshot
end

local function positiveInteger(value, maximum)
    if type(value) ~= "string" or not value:match("^%d+$") then return nil end
    local n = tonumber(value)
    return n and n >= 1 and n <= maximum and n or nil
end

function NS.ParsePlan(text)
    if type(text) ~= "string" or #text > 24000 then return nil, "Plan text must be at most 24,000 bytes." end
    text = text:gsub("\r\n", "\n"):gsub("\r", "\n"):gsub("^\239\187\191", "")
    text = text:match("^%s*(.-)%s*$")
    text = text:gsub("^```[%w_-]*%s*\n", ""):gsub("\n```%s*$", "")
    local plan, started, lineNumber = {title = "My progress plan", tasks = {}}, false, 0
    for line in (text .. "\n"):gmatch("(.-)\n") do
        lineNumber = lineNumber + 1
        line = line:match("^%s*(.-)%s*$")
        if line ~= "" then
            if not started then
                if line ~= "FCPLAN/1" then return nil, "The first line must be FCPLAN/1." end
                started = true
            elseif line:sub(1, 1) ~= "#" then
                local fields = {}
                for field in (line .. "|"):gmatch("(.-)|") do fields[#fields + 1] = field:match("^%s*(.-)%s*$") end
                local kind, task = fields[1], nil
                local expected = {TITLE=2, MANUAL=2, LEVEL=3, GOLD=3, SLOT=3, ITEM=3, SKILL=4, TALENT=4}
                if not expected[kind] or #fields ~= expected[kind] then return nil, "Invalid fields on line " .. lineNumber .. "." end
                local label = clean(fields[#fields], "")
                if label == "" or #label > 240 then return nil, "A label is missing or too long on line " .. lineNumber .. "." end
                if kind == "TITLE" then
                    plan.title = label
                elseif kind == "MANUAL" then
                    task = {kind=kind, label=label, manualDone=false}
                elseif kind == "SKILL" or kind == "TALENT" then
                    local id, target = positiveInteger(fields[2], 10000000), positiveInteger(fields[3], 100000)
                    if not id or not target then return nil, "Invalid ID or target on line " .. lineNumber .. "." end
                    task = {kind=kind, id=id, target=target, label=label}
                else
                    local limits = {LEVEL=1000, GOLD=10000000, SLOT=19, ITEM=10000000}
                    local target = positiveInteger(fields[2], limits[kind])
                    if not target then return nil, "Invalid target on line " .. lineNumber .. "." end
                    task = {kind=kind, target=target, label=label}
                end
                if task then
                    if #plan.tasks >= 32 then return nil, "A plan can contain at most 32 tasks." end
                    plan.tasks[#plan.tasks + 1] = task
                end
            end
        end
    end
    if not started or #plan.tasks == 0 then return nil, "Add at least one task after FCPLAN/1." end
    return plan
end

-- Accept a full AI reply containing one fenced plan, then use the same strict
-- parser. Surrounding prose is never executed or silently treated as a task.
function NS.ParsePlanReply(text)
    if type(text)~="string" or #text>24000 then return NS.ParsePlan(text) end
    text=text:gsub("\r\n","\n"):gsub("\r","\n"):gsub("^\239\187\191","")
    local lines,inside,start,ending,planFence,count={},nil,nil,nil,nil,0
    for line in (text .. "\n"):gmatch("(.-)\n") do
        lines[#lines+1]=line
        local trimmed=line:match("^%s*(.-)%s*$")
        if inside then
            if trimmed==inside then
                if start and planFence==inside and not ending then ending=#lines-1 end
                inside=nil
            end
        else
            inside=trimmed:match("^(```+)[%w_-]*%s*$") or trimmed:match("^(~~~+)[%w_-]*%s*$")
        end
        if trimmed=="FCPLAN/1" then
            count=count+1
            start,planFence=#lines,inside
        end
    end
    if count==0 then return nil,"No plan found. Ask your AI for a ForeverContext plan (FCPLAN/1), then paste it here." end
    if count>1 then return nil,"More than one plan found. Paste only the one you want to use." end
    if planFence and not ending then return nil,"The plan block is incomplete. Copy the whole block and try again." end
    return NS.ParsePlan(table.concat(lines,"\n",start,ending or #lines))
end

function NS.EvaluateTask(task, snapshot)
    local observed, target = nil, task.target
    if task.kind == "MANUAL" then return task.manualDone and "DONE" or "PENDING", "manual check" end
    if task.kind == "LEVEL" then observed = snapshot.level
    elseif task.kind == "GOLD" then observed, target = snapshot.money, task.target * 10000
    elseif task.kind == "SKILL" then observed = snapshot.skills[task.id] and snapshot.skills[task.id].rank
    elseif task.kind == "TALENT" and snapshot.talentsReadable then observed = snapshot.talents[task.id]
    elseif task.kind == "SLOT" then
        local item = snapshot.slots[task.target]
        if item == nil then return "UNKNOWN", "equipment data unavailable" end
        return item > 0 and "DONE" or "PENDING", "slot " .. task.target .. (item > 0 and ": item " .. item or ": empty")
    elseif task.kind == "ITEM" then
        for slot = 1, 19 do if snapshot.slots[slot] == task.target then return "DONE", "item equipped in slot " .. slot end end
        return snapshot.equipmentReadable and "PENDING" or "UNKNOWN", "item " .. task.target .. " must be equipped"
    end
    if observed == nil then return "UNKNOWN", "required data unavailable or target not observed" end
    local detail = task.kind == "GOLD" and string.format("%.2f/%d gold balance", observed / 10000, task.target) or tostring(observed) .. "/" .. tostring(target)
    return observed >= target and "DONE" or "PENDING", detail
end

local function archivePlan(state)
    if not state.plan then return end
    table.insert(state.history, 1, copy(state.plan))
    while #state.history > 2 do table.remove(state.history) end
end

function NS.AcceptPlan(plan)
    if type(plan) ~= "table" or type(plan.tasks) ~= "table" or #plan.tasks == 0 then return nil, "Preview a valid plan first." end
    local state = NS.CharacterState()
    archivePlan(state)
    state.plan = copy(plan)
    state.plan.acceptedAt = clean(call(date, "%Y-%m-%d %H:%M:%S"))
    state.plan.baseline = copy(state.lastExport or NS.CaptureSnapshot())
    state.plan.revision = (state.revision or 0) + 1
    state.revision = state.plan.revision
    state.progressVersion = NS.ProgressVersion() + 1
    return true
end

function NS.ClearPlan()
    local state = NS.CharacterState()
    if not state.plan then return end
    archivePlan(state)
    state.plan = nil
    state.progressVersion = NS.ProgressVersion() + 1
end

function NS.MarkManualTask(index, done)
    local plan = NS.CharacterState().plan
    local task = plan and plan.tasks[index]
    if not task or task.kind ~= "MANUAL" then return false end
    if task.manualDone ~= (done == true) then
        task.manualDone = done == true
        NS.CharacterState().progressVersion = NS.ProgressVersion() + 1
    end
    return true
end

function NS.CommitExport(snapshot)
    if snapshot then NS.CharacterState().lastExport = copy(snapshot) end
end

local function changes(before, now, options)
    local lines = {}
    if not before then return {"No previous snapshot is available yet."} end
    lines[#lines + 1] = "Reference: " .. clean(before.at) .. "; client " .. clean(before.client) .. " build " .. clean(before.build)
    if before.build ~= now.build then lines[#lines + 1] = "Client build changed: recheck whether prior advice and talent IDs still apply to the new game rules." end
    if before.level and now.level and before.level ~= now.level then lines[#lines + 1] = "Level: " .. before.level .. " -> " .. now.level end
    if before.money and now.money and before.money ~= now.money then lines[#lines + 1] = string.format("Gold balance change: %+.2f gold", (now.money - before.money) / 10000) end
    for slot = 1, NS.ModuleEnabled(options, "equipment") and 19 or 0 do
        local old, current = before.slots[slot], now.slots[slot]
        if old ~= nil and current ~= nil and old ~= current then
            lines[#lines + 1] = "Equipment slot " .. slot .. ": " .. (old == 0 and "empty" or "item " .. old) .. " -> " .. (current == 0 and "empty" or "item " .. current)
        end
    end
    local professionIDs = NS.ProfessionSkillIDs()
    for id, skill in pairs((NS.ModuleEnabled(options, "professions") or NS.ModuleEnabled(options, "skills")) and now.skills or {}) do
        local old = before.skills[id]
        local module = professionIDs[id] and "professions" or "skills"
        if NS.ModuleEnabled(options, module) and old and old.rank ~= skill.rank then lines[#lines + 1] = clean(skill.name) .. " [skill " .. id .. "]: " .. old.rank .. " -> " .. skill.rank end
    end
    if NS.ModuleEnabled(options, "talents") and before.talentsReadable and now.talentsReadable then
        for id, rank in pairs(now.talents) do
            if before.talents[id] ~= nil and before.talents[id] ~= rank then lines[#lines + 1] = "Talent node " .. id .. ": " .. before.talents[id] .. " -> " .. rank end
        end
    end
    if #lines == 1 then lines[#lines + 1] = "No comparable level, gold, equipped-item, tracked skill, or committed talent changes observed." end
    return lines
end

function NS.ProgressText(snapshot, options)
    local state = NS.CharacterState()
    local lines = {"=== ACCEPTED PROGRESS PLAN ==="}
    local plan = state.plan
    local professionIDs = NS.ProfessionSkillIDs()
    local function taskModule(task)
        if task.kind == "SKILL" then return professionIDs[task.id] and "professions" or "skills" end
        return ({TALENT="talents", ITEM="equipment", SLOT="equipment"})[task.kind]
    end
    if plan then
        lines[#lines + 1] = clean(plan.title) .. "; revision " .. plan.revision .. "; accepted " .. clean(plan.acceptedAt)
        for index, task in ipairs(plan.tasks) do
            local module = taskModule(task)
            if not module or NS.ModuleEnabled(options, module) then
            local status, detail = NS.EvaluateTask(task, snapshot)
            lines[#lines + 1] = index .. ". [" .. status .. "] " .. clean(task.label) .. " — " .. detail
            else lines[#lines+1] = index .. ". Task details withheld by export options." end
        end
        lines[#lines + 1] = "Automatic checks reflect current state and can become pending again. UNKNOWN is not failure. Manual tasks are checked only by the player."
    else
        lines[#lines + 1] = "No plan accepted. Suggested or imported draft tasks are not accepted advice."
    end
    lines[#lines + 1] = "\n=== CHANGES SINCE PLAN REFERENCE / LAST GENERATED REPORT ==="
    for _, line in ipairs(changes(plan and plan.baseline or state.lastExport, snapshot, options)) do lines[#lines + 1] = line end
    if state.history[1] then
        lines[#lines + 1] = "\nPrevious archived plan: " .. clean(state.history[1].title) .. "; accepted " .. clean(state.history[1].acceptedAt)
        for _, task in ipairs(state.history[1].tasks) do
            local module = taskModule(task)
            if not module or NS.ModuleEnabled(options, module) then
            local status, detail = NS.EvaluateTask(task, snapshot)
            lines[#lines + 1] = "- [" .. status .. " now] " .. clean(task.label) .. " — " .. detail
            else lines[#lines+1] = "- Archived task details withheld by export options." end
        end
        lines[#lines + 1] = "Changes since that archived plan's reference:"
        for _, line in ipairs(changes(state.history[1].baseline, snapshot, options)) do lines[#lines + 1] = line end
    end
    return table.concat(lines, "\n")
end

NS.PlanInstructions = [[If useful, finish with an optional plain-text plan in this exact format (no executable code):
FCPLAN/1
TITLE|Short plan title
LEVEL|26|Reach level 26
SKILL|186|75|Reach Mining 75
SLOT|1|Equip a helmet
TALENT|104753|5|Reach committed rank 5 in this known talent node
ITEM|12345|Equip this exact known item ID
GOLD|10|Hold at least 10 gold
MANUAL|A task the player must check manually
Use at most 32 tasks, one per line, with no pipe characters in labels. Replace examples with appropriate targets. Use only IDs verified in the report or reliable Forever sources; TALENT expects a node ID, not a spell or entry ID. Unknown IDs or actions should be MANUAL tasks. GOLD checks current balance, ITEM checks equipped items only, and TALENT checks committed ranks without bonus ranks. The player must preview and accept a plan before it is saved as active advice.]]
