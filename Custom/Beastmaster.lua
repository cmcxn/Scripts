--[[
    ============================================================
    脚本名称: 宠物大师 (Beastmaster)
    脚本功能: 
        这是一个猎人专用的NPC脚本，允许猎人玩家通过对话菜单
        浏览并驯服各种可驯服的野兽宠物。
        
    主要功能:
        1. 检测玩家是否为猎人职业
        2. 检测玩家是否已学会驯服野兽技能
        3. 根据玩家等级显示可驯服的野兽列表
        4. 生成临时友好的野兽并强制驯服
        5. 支持分页显示野兽列表
        
    配置说明:
        - entry: NPC的Entry ID
        - maxObj: 每页显示的菜单项数量
    ============================================================
--]]

local Beastmaster = {
    entry = 823, -- 宠物大师NPC的Entry ID (Beastmaster entry)
    maxObj = 13, -- 每页最大菜单项数量 (13 = Max amt. of menu objects)
}

-- 当玩家与NPC对话时触发 (Triggered when player talks to NPC)
function Beastmaster.OnHello(event, player, unit)
    -- 检查玩家是否为猎人职业 (Check whether the player is actually a hunter or not)
    if(player:GetClass() == 3) then
        -- 检查玩家是否已学会驯服野兽技能 (Check if player is able to tame pets)
        if(player:HasSpell(1515)) then
            Beastmaster.GenerateMenu(1, player, unit);
        else
            player:SendBroadcastMessage("[Eluna Beastmaster]: 你还没有学会驯服野兽技能。(You are not able to tame pets.)")
        end
    else
        player:SendBroadcastMessage("[Eluna Beastmaster]: 只有猎人才能使用此服务！(Only Hunters can use this service!)")
    end
end

-- 当玩家选择菜单项时触发 (Triggered when player selects a menu option)
function Beastmaster.OnSelect(event, player, unit, sender, intid, code)
    -- intid为0表示菜单翻页，为1表示选择宠物 (Intid 0 is used solely for menu pages and 1 for pet selection)
    if(intid == 0) then
        Beastmaster.GenerateMenu(sender, player, unit);
    elseif(intid == 1) then
        -- 生成一个临时的友好版本生物并强制驯服 (Spawn a temporary, friendly version of the selected creature and force tame it)
        local pet = PerformIngameSpawn(1, sender, unit:GetMapId(), unit:GetInstanceId(), unit:GetX(), unit:GetY(), unit:GetZ(), unit:GetO(), false, 5000)
        pet:SetFaction(35) -- 设置为友好阵营 (Set to friendly faction)
        player:CastSpell(pet, 2650, true) -- 施放驯服野兽法术 (Cast tame beast spell)
        player:GossipComplete()
    end
end

-- 生成对话菜单 (Generate gossip menu)
-- id: 当前页码 (current page number)
-- player: 玩家对象 (player object)
-- unit: NPC对象 (NPC object)
function Beastmaster.GenerateMenu(id, player, unit)
    local low = ((Beastmaster.maxObj*id)-Beastmaster.maxObj+1) -- 计算当前页起始索引 (Calculate starting index for current page)
    local high = Beastmaster.maxObj*id -- 计算当前页结束索引 (Calculate ending index for current page)
    
    -- 获取当前页的对话选项信息 (Retrieve the current page sets' gossip option information)
    for i = low, high do
        local t = Beastmaster["Cache"][i]
        
        if t then -- 仅显示存在于表中的项目 (show "i" if only exists in the table)
            -- 不显示等级高于玩家的生物 (Do not list gossip options with creatures above the players level)
            if(player:GetLevel() >= t["level"]) then
                player:GossipMenuAddItem(2, "等级: "..t["level"].." - "..t["name"], t["entry"], 1)
            end
        end
    end
    
    -- 如果不是第一页，显示"上一页"按钮 (If the menu is not the first menu, show Previous button)
    if(id ~= 1) then
        player:GossipMenuAddItem(4, "<-- 上一页 (Previous)", id-1, 0)
    end
    
    -- 如果下一页有可用项目且在玩家等级范围内，显示"下一页"按钮 (If the next menu has available objects and object is within player level, show Next button)
    if(Beastmaster["Cache"][high+1]) and (player:GetLevel() >= Beastmaster["Cache"][high+1]["level"]) then
        player:GossipMenuAddItem(4, "下一页 (Next) -->", id+1, 0)
    end
    
    player:GossipSendMenu(1, unit)
end

-- 从数据库加载可驯服野兽的缓存 (Load cache of tameable beasts from database)
function Beastmaster.LoadCache()
    Beastmaster["Cache"] = {} -- 初始化缓存表 (Initialize cache table)
    local i = 1;
    local Query;
    
    -- 根据核心类型执行不同的SQL查询 (Execute different SQL queries based on core type)
    if(GetCoreName() == "MaNGOS") then
        Query = WorldDBQuery("SELECT Entry, Name, MaxLevel FROM creature_template WHERE CreatureType=1 AND CreatureTypeFlags&1 <> 0 AND Family!=0 ORDER BY MaxLevel ASC;")
    elseif(GetCoreName() == "TrinityCore") then
        Query = WorldDBQuery("SELECT Entry, Name, MaxLevel FROM creature_template WHERE Type=1 AND Type_Flags&1 <> 0 AND Family!=0 ORDER BY MaxLevel ASC;")
    end
    
    -- 处理查询结果并填充缓存 (Process query results and populate cache)
    if(Query) then
        repeat
            Beastmaster["Cache"][i] = {
                entry = Query:GetUInt32(0), -- 生物Entry ID
                name = Query:GetString(1),  -- 生物名称
                level = Query:GetUInt32(2)  -- 生物最高等级
            };
            i = i+1
        until not Query:NextRow()
        print("[Eluna Beastmaster]: 缓存初始化完成，已加载 "..Query:GetRowCount().." 个可驯服野兽。(Cache initialized. Loaded "..Query:GetRowCount().." tameable beasts.)")
    else
        print("[Eluna Beastmaster]: 缓存初始化完成，未找到结果。(Cache initialized. No results found.)")
    end
end

-- 初始化缓存 (Initialize cache)
Beastmaster.LoadCache()

-- 注册NPC对话事件 (Register NPC gossip events)
RegisterCreatureGossipEvent(Beastmaster.entry, 1, Beastmaster.OnHello)  -- 注册对话开始事件 (Register gossip hello event)
RegisterCreatureGossipEvent(Beastmaster.entry, 2, Beastmaster.OnSelect) -- 注册对话选择事件 (Register gossip select event)
