--[[
    ============================================================
    脚本名称: 永歌森林区域脚本 (Eversong Woods Zone Script)
    脚本功能: 
        这是永歌森林区域的任务脚本，处理学徒米尔韦达
        和灌能水晶的任务事件。

    主要功能:
        1. 接受任务后召唤敌对生物
        2. 击杀足够敌人后自动完成任务
        3. 灌能水晶的波次防守事件
        4. NPC死亡时任务失败

    涉及NPC:
        - 学徒米尔韦达 (Apprentice Mirveda) <15402>
        - 灌能水晶 (Infused Crystal) <16364>

    任务ID: 8488 / 8490
    ============================================================
    
    EmuDevs <http://emudevs.com/forum.php>
    Eluna Lua Engine <https://github.com/ElunaLuaEngine/Eluna>
    Eluna Scripts <https://github.com/ElunaLuaEngine/Scripts>
    Eluna Wiki <http://wiki.emudevs.com/doku.php?id=eluna>

    -= 脚本信息 (Script Information) =-
    * 区域 (Zone): 永歌森林 (Eversong Woods)
    * 任务ID (QuestId): 8488 / 8490
    * 脚本类型 (Script Type): 对话、生物AI和任务 (Gossip, CreatureAI and Quest)
    * NPC: 学徒米尔韦达 Apprentice Mirveda <15402>, 灌能水晶 Infused Crystal <16364>
--]]

local killCount = 0   -- 击杀计数 (Kill count)
local playerGUID = 0  -- 玩家GUID (Player GUID)

-- ============================================================
-- 学徒米尔韦达 (Apprentice Mirveda)
-- ============================================================

-- 接受任务事件 (Quest accept event)
function Mirveda_QuestAccept(event, player, creature, quest)
    if (quest:GetId() == 8488) then
        playerGUID = player:GetGUIDLow()
        creature:RegisterEvent(Mirveda_SpawnCreature, 1200, 1) -- 1.2秒后召唤敌人 (Spawn enemies after 1.2s)
        creature:RegisterEvent(Mirveda_QuestComplete, 1000, 0) -- 每秒检查任务完成 (Check quest complete every second)
    end
end

-- 召唤敌人 (Spawn enemies)
function Mirveda_SpawnCreature(event, delay, pCall, creature)
    creature:SpawnCreature(15958, 8725, -7153.93, 35.23, 0, 2, 4000) -- 召唤精灵 (Spawn Wretched)
    creature:SpawnCreature(15656, 8725, -7153.93, 35.23, 0, 2, 4000)
    creature:SpawnCreature(15656, 8725, -7153.93, 35.23, 0, 2, 4000)
end

-- 检查任务完成 (Check quest complete)
function Mirveda_QuestComplete(event, delay, pCall, creature)
    if (killCount >= 3 and playerGUID > 0) then
        creature:RemoveEventById(event)
        local player = GetPlayerByGUID(playerGUID)
        if (player ~= nil) then
            player:CompleteQuest(8488) -- 完成任务 (Complete quest)
        end
    end
end

-- 重置状态 (Reset state)
function Mirveda_Reset()
    killCount = 0
    playerGUID = 0
end

-- NPC死亡事件 - 任务失败 (NPC death event - Quest fail)
function Mirveda_Died(event, creature, killer)
    creature:RemoveEvents()
    if (playerGUID > 0) then
        local player = GetPlayerByGUID(playerGUID)
        if (player ~= nil) then
            player:FailQuest(8488) -- 任务失败 (Fail quest)
        end
    end
end

-- 召唤生物事件 (Summoned creature event)
function Mirveda_JustSummoned(event, creature, summoned)
    summoned:AttackStart(creature) -- 召唤的生物攻击NPC (Summoned creature attacks NPC)
    summoned:MoveChase(creature)   -- 追逐NPC (Chase NPC)
end

-- 召唤生物消失事件 - 增加击杀计数 (Summoned creature despawn event - Increase kill count)
function Mirveda_SummonedDespawn(event, creature, summoned)
    killCount = killCount + 1
end

-- 注册学徒米尔韦达事件 (Register Apprentice Mirveda events)
RegisterCreatureEvent(15402, 4, Mirveda_Died)
RegisterCreatureEvent(15402, 19, Mirveda_JustSummoned)
RegisterCreatureEvent(15402, 20, Mirveda_SummonedDespawn)
RegisterCreatureEvent(15402, 23, Mirveda_Reset)
RegisterCreatureEvent(15402, 31, Mirveda_QuestAccept)

-- ============================================================
-- 灌能水晶 (Infused Crystal)
-- ============================================================

-- 敌人生成位置 (Enemy spawn positions)
local Spawns =
{
    { 8270.68, -7188.53, 139.619 },
    { 8284.27, -7187.78, 139.603 },
    { 8297.43, -7193.53, 139.603 },
    { 8303.5, -7201.96, 139.577 },
    { 8273.22, -7241.82, 139.382 },
    { 8254.89, -7222.12, 139.603 },
    { 8278.51, -7242.13, 139.162 },
    { 8267.97, -7239.17, 139.517 }
}

local completed = false      -- 是否完成 (Is completed)
local started = false        -- 是否开始 (Is started)
local crystalPlayerGUID = 0  -- 玩家GUID (Player GUID)

-- 水晶死亡事件 - 任务失败 (Crystal death event - Quest fail)
function Crystal_Died(event, creature, killer)
    creature:RemoveEvents()
    if (crystalPlayerGUID > 0 and not completed) then
        local player = GetPlayerByGUID(crystalPlayerGUID)
        if (player ~= nil) then
            player:FailQuest(8490) -- 任务失败 (Fail quest)
        end
    end
end

-- 水晶重置事件 (Crystal reset event)
function Crystal_Reset(event, creature)
    crystalPlayerGUID = 0
    started = false
    completed = false
end

-- 视野范围内移动事件 - 开始事件 (Move in LOS event - Start event)
function Crystal_MoveLOS(event, creature, unit)
    if (unit:GetUnitType() == "Player" and creature:IsWithinDistInMap(unit, 10) and not started) then
        -- 检查玩家是否正在进行任务8490 (Check if player has quest 8490 in progress)
        if (unit:GetQuestStatus(8490) == 3) then
            crystalPlayerGUID = unit:GetGUIDLow()
            creature:RegisterEvent(Crystal_WaveStart, 1000, 1)  -- 1秒后开始波次 (Start wave after 1s)
            creature:RegisterEvent(Crystal_Completed, 60000, 1) -- 60秒后完成 (Complete after 60s)
            started = true
        end
    end
end

-- 波次开始 (Wave start)
function Crystal_WaveStart(event, delay, pCall, creature)
    if (started and not completed) then
        -- 从随机位置召唤3个敌人 (Spawn 3 enemies from random positions)
        local rand1 = math.random(8)
        local rand2 = math.random(8)
        local rand3 = math.random(8)
        creature:SpawnCreature(17086, Spawns[rand1][1], Spawns[rand1][2], Spawns[rand1][3], 0, 2, 10000)
        creature:SpawnCreature(17086, Spawns[rand2][1], Spawns[rand2][2], Spawns[rand2][3], 0, 2, 10000)
        creature:SpawnCreature(17086, Spawns[rand3][1], Spawns[rand3][2], Spawns[rand3][3], 0, 2, 10000)
        creature:RegisterEvent(Crystal_WaveStart, 30000, 0) -- 30秒后下一波 (Next wave after 30s)
    end
end

-- 事件完成 (Event completed)
function Crystal_Completed(event, delay, pCall, creature)
    if (started) then
        creature:RemoveEvents()
        creature:SendCreatureTalk(0, crystalPlayerGUID) -- 发送完成对话 (Send complete talk)
        completed = true
        if (crystalPlayerGUID > 0) then
            local player = GetPlayerByGUID(crystalPlayerGUID)
            if (player ~= nil) then
                player:CompleteQuest(8490) -- 完成任务 (Complete quest)
            end
        end
        creature:DealDamage(creature, creature:GetHealth()) -- 自毁 (Self destruct)
        creature:RemoveCorpse() -- 移除尸体 (Remove corpse)
    end
end

-- 召唤生物事件 (Summoned creature event)
function Crystal_Summoned(event, creature, summoned)
    local player = GetPlayerByGUID(crystalPlayerGUID)
    if (player ~= nil) then
        summoned:AttackStart(player) -- 召唤的生物攻击玩家 (Summoned creature attacks player)
    end
end

-- 注册灌能水晶事件 (Register Infused Crystal events)
RegisterCreatureEvent(16364, 4, Crystal_Died)
RegisterCreatureEvent(16364, 19, Crystal_Summoned)
RegisterCreatureEvent(16364, 23, Crystal_Reset)
RegisterCreatureEvent(16364, 27, Crystal_MoveLOS)