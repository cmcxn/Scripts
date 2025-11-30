--[[
    ============================================================
    脚本名称: 阿拉希高地区域脚本 (Arathi Highlands Zone Script)
    脚本功能: 
        这是阿拉希高地区域的护送任务脚本，处理
        菲兹尔索普教授(Professor Phizzlethorpe)的护送任务。

    主要功能:
        1. 接受任务后开始护送NPC
        2. NPC沿路点移动并发表对话
        3. 在特定位置召唤敌对生物
        4. 完成护送后完成任务

    任务信息:
        - 区域 (Zone): 阿拉希高地 (Arathi Highlands)
        - 任务ID (QuestId): 665
        - NPC: 菲兹尔索普教授 Professor Phizzlethorpe <2768>
    ============================================================
    
    EmuDevs <http://emudevs.com/forum.php>
    Eluna Lua Engine <https://github.com/ElunaLuaEngine/Eluna>
    Eluna Scripts <https://github.com/ElunaLuaEngine/Scripts>
    Eluna Wiki <http://wiki.emudevs.com/doku.php?id=eluna>

    -= 脚本信息 (Script Information) =-
    * 区域 (Zone): 阿拉希高地 (Arathi Highlands)
    * 任务ID (QuestId): 665
    * 脚本类型 (Script Type): 护送任务 (Quest Escort)
    * NPC: 菲兹尔索普教授 Professor Phizzlethorpe <2768>
--]]

-- 路点坐标表 (Waypoint coordinates table)
local Waypoints =
{
    { 1, 1, -2073.519, -2123.502, 18.433033 },
    { 4, 5, -2073.519, -2123.502, 18.433033 },
    { 5, 6, -2074.780, -2089.530, 8.972266 },
    { 6, 7, -2074.940, -2089.247, 8.911692 },
    { 8, 8, -2066.248, -2086.332, 9.009366 }
}

local escortPlayer = nil  -- 护送的玩家 (Player being escorted)
local currentWP = 0       -- 当前路点 (Current waypoint)

-- 接受任务事件 (Quest accept event)
function Phizzlethorpe_OnQuestAccept(event, player, creature, quest)
    if (quest:GetId() == 665) then
        escortPlayer = player
        currentWP = 0
        creature:SendCreatureTalk(0, player:GetGUIDLow()) -- 发送对话 (Send talk)
        creature:SetWalk(true) -- 设置为步行模式 (Set to walk mode)
        creature:MoveTo(0, -2077.985, -2093.242, 10.001955) -- 移动到第一个位置 (Move to first position)
        creature:SetFaction(35) -- 设置为友好阵营 (Set to friendly faction)
    end
end

-- 进入战斗事件 (Enter combat event)
function Phizzlethorpe_OnEnterCombat(event, creature, target)
    creature:SendCreatureTalk(4, 0) -- 发送战斗对话 (Send combat talk)
end

-- 到达路点事件 (Reach waypoint event)
function Phizzlethorpe_OnReachWP(event, creature, pointType, waypointId)
    currentWP = waypointId + 1
    local delay = 0

    if (currentWP == 1) then
        delay = 1000 -- 延迟1秒 (Delay 1 second)
    elseif (currentWP == 2) then
        creature:SendCreatureTalk(1, escortPlayer:GetGUIDLow())
        creature:RegisterEvent(Phizzlethorpe_OnMoveForward, 3500, 1) -- 3.5秒后继续前进 (Continue forward after 3.5s)
    elseif (currentWP == 3) then
        creature:SendCreatureTalk(3, 0)
        creature:RegisterEvent(Phizzlethorpe_OnSummon, 8000, 1)      -- 8秒后召唤敌人 (Summon enemies after 8s)
        creature:RegisterEvent(Phizzlethorpe_OnAlmostDone, 15000, 1) -- 15秒后 (After 15s)
        creature:RegisterEvent(Phizzlethorpe_OnFinish, 22000, 1)     -- 22秒后完成 (Finish after 22s)
    elseif (currentWP == 4) then
        delay = 1000
        creature:SendCreatureTalk(7, escortPlayer:GetGUIDLow())
    elseif (currentWP == 6) then
        delay = 2000
    elseif (currentWP == 8) then
        delay = 1000
    elseif (currentWP == 9) then
        -- 护送完成 (Escort complete)
        creature:RemoveEvents()
        creature:SendCreatureTalk(8, 0)
        creature:SendCreatureTalk(9, escortPlayer:GetGUIDLow())
        escortPlayer:GroupEventHappens(665, creature) -- 完成任务事件 (Complete quest event)
        creature:Despawn(3000) -- 3秒后消失 (Despawn after 3s)
        escortPlayer = nil
        currentWP = 0
    end
    if (delay > 0) then
        creature:RegisterEvent(Phizzlethorpe_OnMove, delay, 1)
    end
end

-- 召唤生物事件 (Summoned creature event)
function Phizzlethorpe_OnJustSummoned(event, creature, summoned)
    summoned:AttackStart(escortPlayer) -- 召唤的生物攻击玩家 (Summoned creature attacks player)
end

-- 移动到下一个路点 (Move to next waypoint)
function Phizzlethorpe_OnMove(event, delay, pCall, creature)
    for k,_ in ipairs(Waypoints) do
        if (Waypoints[k][1] == currentWP) then
            creature:MoveTo(Waypoints[k][2], Waypoints[k][3], Waypoints[k][4], Waypoints[k][5])
        end
    end
end

-- 继续前进 (Move forward)
function Phizzlethorpe_OnMoveForward(event, delay, pCall, creature)
    creature:SendCreatureTalk(2, escortPlayer:GetGUIDLow())
    creature:MoveTo(currentWP, -2043.243, -2154.018, 20.232119)
end

-- 召唤敌人 (Summon enemies)
function Phizzlethorpe_OnSummon(event, delay, pCall, creature)
    creature:SpawnCreature(2776, -2052.96, -2142.49, 20.15, 1.0, 5, 0) -- 召唤纳迦 (Spawn Naga)
    creature:SpawnCreature(2776, -2052.96, -2142.49, 20.15, 1.0, 5, 0)
end

-- 即将完成 (Almost done)
function Phizzlethorpe_OnAlmostDone(event, delay, pCall, creature)
    creature:SendCreatureTalk(5, escortPlayer:GetGUIDLow())
end

-- 完成护送 (Finish escort)
function Phizzlethorpe_OnFinish(event, delay, pCall, creature)
    creature:SendCreatureTalk(6, escortPlayer:GetGUIDLow())
    creature:SetWalk(false) -- 切换到跑步模式 (Switch to run mode)
    creature:MoveTo(currentWP, -2070.117, -2126.960, 19.514397)
end

-- 注册生物事件 (Register creature events)
RegisterCreatureEvent(2768, 1, Phizzlethorpe_OnEnterCombat)   -- 进入战斗 (Enter combat)
RegisterCreatureEvent(2768, 6, Phizzlethorpe_OnReachWP)       -- 到达路点 (Reach waypoint)
RegisterCreatureEvent(2768, 19, Phizzlethorpe_OnJustSummoned) -- 召唤生物 (Summoned creature)
RegisterCreatureEvent(2768, 31, Phizzlethorpe_OnQuestAccept)  -- 接受任务 (Quest accept)