--[[
    ============================================================
    脚本名称: 克鲁尔Boss战斗脚本 (Boss Kruul Combat Script)
    脚本功能: 
        这是魔兽世界Boss克鲁尔(Kruul)的AI战斗脚本，
        控制Boss的技能释放、召唤小怪和战斗行为。

    主要功能:
        1. 进入战斗时注册各种技能定时器
        2. 定时释放暗影齐射、顺劈、雷霆一击等技能
        3. 召唤地狱猎犬小怪协助战斗
        4. 击杀玩家时获得治疗效果

    技能说明:
        - 暗影齐射 (Shadow Volley): 10秒间隔
        - 顺劈 (Cleave): 14秒间隔
        - 雷霆一击 (Thunder Clap): 20秒间隔
        - 扭曲反射 (Twisted Reflection): 25秒间隔
        - 虚空箭 (Void Bolt): 30秒间隔
        - 狂暴 (Rage): 60秒间隔
        - 召唤猎犬 (Spawn Hounds): 8秒后首次，之后每45秒
    ============================================================
    
    EmuDevs <http://emudevs.com/forum.php>
    Eluna Lua Engine <https://github.com/ElunaLuaEngine/Eluna>
    Eluna Scripts <https://github.com/ElunaLuaEngine/Scripts>
    Eluna Wiki <http://wiki.emudevs.com/doku.php?id=eluna>

    -= 脚本信息 (Script Information) =-
    * 脚本类型 (Script Type): Boss战斗 (Boss Fight)
    * NPC: 克鲁尔 Kruul <18338>
--]]

local Kruul = {}

-- 进入战斗事件 (Enter combat event)
function Kruul.EnterCombat(event, creature, target)
    -- 注册各种技能定时器 (Register various skill timers)
    creature:RegisterEvent(Kruul.ShadowVolley, 10000, 0)       -- 暗影齐射，10秒间隔 (Shadow Volley, 10s interval)
    creature:RegisterEvent(Kruul.Cleave, 14000, 0)             -- 顺劈，14秒间隔 (Cleave, 14s interval)
    creature:RegisterEvent(Kruul.ThunderClap, 20000, 0)        -- 雷霆一击，20秒间隔 (Thunder Clap, 20s interval)
    creature:RegisterEvent(Kruul.TwistedReflection, 25000, 0)  -- 扭曲反射，25秒间隔 (Twisted Reflection, 25s interval)
    creature:RegisterEvent(Kruul.VoidBolt, 30000, 0)           -- 虚空箭，30秒间隔 (Void Bolt, 30s interval)
    creature:RegisterEvent(Kruul.Rage, 60000, 0)               -- 狂暴，60秒间隔 (Rage, 60s interval)
    creature:RegisterEvent(Kruul.SpawnHounds, 8000, 1)         -- 8秒后召唤猎犬，仅1次 (Spawn hounds after 8s, once)
end

-- 击杀目标事件 (Kill target event)
function Kruul.KilledTarget(event, creature, victim)
    creature:CastSpell(creature, 21054) -- 对自己施放治疗法术 (Cast heal spell on self)
end

-- 离开战斗事件 (Leave combat event)
function Kruul.LeaveCombat(event, creature)
    creature:RemoveEvents() -- 移除所有定时事件 (Remove all timed events)
end

-- 死亡事件 (Death event)
function Kruul.Died(event, creature, killer)
    creature:RemoveEvents() -- 移除所有定时事件 (Remove all timed events)
end

-- 暗影齐射技能 (Shadow Volley skill)
function Kruul.ShadowVolley(event, delay, pCall, creature)
    creature:CastSpell(creature:GetVictim(), 21341) -- 法术ID 21341
end

-- 顺劈技能 (Cleave skill)
function Kruul.Cleave(event, delay, pCall, creature)
    creature:CastSpell(creature:GetVictim(), 20677) -- 法术ID 20677
end

-- 雷霆一击技能 (Thunder Clap skill)
function Kruul.ThunderClap(event, delay, pCall, creature)
    creature:CastSpell(creature:GetVictim(), 23931) -- 法术ID 23931
end

-- 扭曲反射技能 (Twisted Reflection skill)
function Kruul.TwistedReflection(event, delay, pCall, creature)
    creature:CastSpell(creature:GetVictim(), 21063) -- 法术ID 21063
end

-- 虚空箭技能 (Void Bolt skill)
function Kruul.VoidBolt(event, delay, pCall, creature)
    creature:CastSpell(creature:GetVictim(), 21066) -- 法术ID 21066
end

-- 狂暴技能 (Rage skill)
function Kruul.Rage(event, delay, pCall, creature)
    creature:CastSpell(creature, 21340) -- 对自己施放狂暴 (Cast rage on self)
end

-- 召唤单个猎犬 (Summon a single hound)
function Kruul.SummonHounds(creature, target)
    -- 在随机位置生成猎犬 (Spawn hound at random position)
    local x, y, z = creature:GetRelativePoint(math.random()*9, math.random()*math.pi*2)
    local hound = creature:SpawnCreature(19207, x, y, z, 0, 2, 300000) -- 生成5分钟后消失 (Despawn after 5 minutes)
    if (hound) then
        hound:AttackStart(target) -- 让猎犬攻击目标 (Make hound attack target)
    end
end

-- 召唤一组猎犬 (Spawn a group of hounds)
function Kruul.SpawnHounds(event, delay, pCall, creature)
    -- 召唤3只猎犬攻击当前目标 (Summon 3 hounds to attack current target)
    Kruul.SummonHounds(creature, creature:GetVictim())
    Kruul.SummonHounds(creature, creature:GetVictim())
    Kruul.SummonHounds(creature, creature:GetVictim())
    -- 45秒后再次召唤 (Summon again after 45 seconds)
    creature:RegisterEvent(Kruul.SpawnHounds, 45000, 1)
end

-- 注册生物事件 (Register creature events)
RegisterCreatureEvent(18338, 1, Kruul.EnterCombat)  -- 1 = 进入战斗 (Enter combat)
RegisterCreatureEvent(18338, 2, Kruul.LeaveCombat)  -- 2 = 离开战斗 (Leave combat)
RegisterCreatureEvent(18338, 3, Kruul.KilledTarget) -- 3 = 击杀目标 (Kill target)
RegisterCreatureEvent(18338, 4, Kruul.Died)         -- 4 = 死亡 (Death)
