--[[
    ============================================================
    脚本名称: 生物事件示例 (Example Creature Script)
    脚本功能: 
        这是一个生物事件处理的示例脚本，演示如何处理
        生物进入战斗、离开战斗和死亡等事件。

    主要功能:
        1. 进入战斗时注册定时施放法术事件
        2. 离开战斗时发送喊话并清除所有事件
        3. 死亡时向击杀者发送消息并清除事件

    示例学习:
        - RegisterEvent: 注册定时事件
        - RemoveEvents: 移除所有定时事件
        - CastSpell: 施放法术
        - SendUnitYell: 单位喊话
        - SendBroadcastMessage: 发送广播消息
    ============================================================
--]]

local npcId = 123 -- NPC的Entry ID (NPC entry ID)

-- 定时施放冰箭术 (Cast Frostbolt on timer)
local function CastFrostbolt(eventId, dely, calls, creature)
    creature:CastSpell(creature:GetVictim(), 11, true) -- 向当前目标施放法术ID 11 (Cast spell ID 11 on current victim)
end

-- 进入战斗事件处理 (Enter combat event handler)
local function OnEnterCombat(event, creature, target)
    -- 注册每5秒施放一次冰箭术的定时事件，无限次 (Register timer to cast frostbolt every 5 seconds, infinite times)
    creature:RegisterEvent(CastFrostbolt, 5000, 0)
end

-- 离开战斗事件处理 (Leave combat event handler)
local function OnLeaveCombat(event, creature)
    creature:SendUnitYell("哈哈，我脱战了！(Haha, I'm out of combat!)", 0) -- 喊话 (Yell)
    creature:RemoveEvents() -- 移除所有定时事件 (Remove all timed events)
end

-- 死亡事件处理 (Death event handler)
local function OnDied(event, creature, killer)
    -- 检查击杀者是否为玩家 (Check if killer is a player)
    if(killer:GetObjectType() == "Player") then
        killer:SendBroadcastMessage("你击杀了 "..creature:GetName().."! (You killed " ..creature:GetName().."!)")
    end
    creature:RemoveEvents() -- 移除所有定时事件 (Remove all timed events)
end

-- 注册生物事件 (Register creature events)
RegisterCreatureEvent(npcId, 1, OnEnterCombat) -- 1 = 进入战斗事件 (Enter combat event)
RegisterCreatureEvent(npcId, 2, OnLeaveCombat) -- 2 = 离开战斗事件 (Leave combat event)
RegisterCreatureEvent(npcId, 4, OnDied)        -- 4 = 死亡事件 (Death event)