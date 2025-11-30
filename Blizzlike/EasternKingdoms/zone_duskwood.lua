--[[
    ============================================================
    脚本名称: 暮色森林区域脚本 (Duskwood Zone Script)
    脚本功能: 
        这是暮色森林区域的Boss战斗脚本，处理
        暮光腐蚀者(Twilight Corrupter)的战斗和召唤。

    主要功能:
        1. 区域触发器检测玩家进入触发Boss生成
        2. Boss进入战斗时注册技能定时器
        3. 击杀玩家后获得增益效果
        4. Boss死亡后清理状态

    任务信息:
        - 区域 (Zone): 暮色森林 (Duskwood)
        - 物品ID (ItemId): 21149
        - 区域触发器 (AreaTrigger): 暮光树丛 (Twilight Grove)
        - NPC: 暮光腐蚀者 Twilight Corrupter <15625>

    技能说明:
        - 灵魂腐蚀 (Soul Corruption): 随机间隔
        - 梦魇造物 (Creature Of Nightmare): 45秒间隔
    ============================================================
    
    EmuDevs <http://emudevs.com/forum.php>
    Eluna Lua Engine <https://github.com/ElunaLuaEngine/Eluna>
    Eluna Scripts <https://github.com/ElunaLuaEngine/Scripts>
    Eluna Wiki <http://wiki.emudevs.com/doku.php?id=eluna>

    -= 脚本信息 (Script Information) =-
    * 区域 (Zone): 暮色森林 (Duskwood)
    * 物品ID (ItemId): 21149
    * 区域触发器 (AreaTrigger): 暮光树丛 (Twilight Grove)
    * 脚本类型 (Script Type): 区域触发器 & Boss战斗 (AreaTrigger & Boss Fight)
    * NPC: 暮光腐蚀者 Twilight Corrupter <15625>
--]]

local killCount = 0   -- 击杀玩家计数 (Kill count)
local corrupter = nil -- Boss引用 (Boss reference)

-- 区域触发器事件 (Area trigger event)
function TwilightCorrupter_OnTrigger(event, player, triggerId)
    -- 检查是触发器4017，玩家有任务物品，且Boss未生成 (Check if trigger 4017, player has quest item, and boss not spawned)
    if (triggerId == 4017 and player:HasQuestForItem(21149) and corrupter == nil) then
        -- 生成Boss (Spawn boss)
        corrupter = player:SpawnCreature(15625, -10328.16, -489.57, 49.95, 0, 1, 60000)
        if (corrupter ~= nil) then
            corrupter:SetFaction(14)       -- 设置为敌对阵营 (Set to hostile faction)
            corrupter:SetMaxHealth(832750) -- 设置最大生命值 (Set max health)
            corrupter:SendCreatureTalk(0, player:GetGUID()) -- 发送对话 (Send talk)
        end
    end
end

-- Boss重置事件 (Boss reset event)
function TwilightCorrupter_OnReset(event, creature)
    creature:RemoveEvents() -- 移除所有定时事件 (Remove all timed events)
    killCount = 0           -- 重置击杀计数 (Reset kill count)
end

-- Boss进入战斗事件 (Boss enter combat event)
function TwilightCorrupter_OnEnterCombat(event, creature, target)
    -- 注册技能定时器 (Register skill timers)
    creature:RegisterEvent(TwilightCorrupter_SoulCorruption, math.random(4000) + 15000, 0) -- 灵魂腐蚀 (Soul Corruption)
    creature:RegisterEvent(TwilightCorrupter_CreatureOfNightmare, 45000, 0) -- 梦魇造物 (Creature Of Nightmare)
end

-- 击杀单位事件 (Kill unit event)
function TwilightCorrupter_OnKilledUnit(event, creature, victim)
    if (victim:GetUnitType() == "Player") then
        killCount = killCount + 1
        creature:SendCreatureTalk(2, victim:GetGUID()) -- 发送击杀对话 (Send kill talk)
        -- 每击杀3个玩家获得增益 (Get buff every 3 player kills)
        if (killCount == 3) then
            creature:CastSpell(creature, 24312, true)
            killCount = 0
        end
    end
end

-- Boss死亡事件 (Boss death event)
function TwilightCorrupter_OnDied(event, creature, killer)
    creature:RemoveEvents() -- 移除所有定时事件 (Remove all timed events)
    corrupter = nil         -- 清除Boss引用 (Clear boss reference)
end

-- 灵魂腐蚀技能 (Soul Corruption skill)
function TwilightCorrupter_SoulCorruption(event, delay, pCall, creature)
    creature:CastSpell(creature:GetVictim(), 25805)
end

-- 梦魇造物技能 (Creature Of Nightmare skill)
function TwilightCorrupter_CreatureOfNightmare(event, delay, pCall, creature)
    creature:CastSpell(creature:GetVictim(), 25806)
end

-- 注册事件 (Register events)
RegisterServerEvent(24, TwilightCorrupter_OnTrigger)        -- 24 = 区域触发器事件 (Area trigger event)
RegisterCreatureEvent(15625, 1, TwilightCorrupter_OnEnterCombat)  -- 进入战斗 (Enter combat)
RegisterCreatureEvent(15625, 3, TwilightCorrupter_OnKilledUnit)   -- 击杀单位 (Kill unit)
RegisterCreatureEvent(15625, 4, TwilightCorrupter_OnDied)         -- 死亡 (Death)
RegisterCreatureEvent(15625, 23, TwilightCorrupter_OnReset)       -- 重置 (Reset)
