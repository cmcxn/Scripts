--[[
	============================================================
	脚本名称: 巴札兰Boss战斗脚本 (Boss Bazzalan Combat Script)
	脚本功能: 
		这是怒焰裂谷副本Boss巴札兰的AI战斗脚本，
		控制Boss的技能释放和战斗行为。

	主要功能:
		1. 进入战斗时注册技能定时器
		2. 释放毒药和险恶打击技能
		3. 离开战斗或死亡时清除事件

	技能说明:
		- 毒药 (Poison): 3-5秒随机间隔，75%几率
		- 险恶打击 (Sinister Strike): 8秒间隔，85%几率
	============================================================

	EmuDevs <http://emudevs.com/forum.php>
	Eluna Lua Engine <https://github.com/ElunaLuaEngine/Eluna>
	Eluna Scripts <https://github.com/ElunaLuaEngine/Scripts>
	Eluna Wiki <http://wiki.emudevs.com/doku.php?id=eluna>

	-= 脚本信息 (Script Information) =-
	* 脚本类型 (Script Type): Boss战斗 (Boss Fight)
	* NPC: 巴札兰 Bazzalan <11519>
--]]

local Bazzalan = {};

-- 进入战斗事件 (Enter combat event)
function Bazzalan.OnEnterCombat(event, creature, target)
	creature:RegisterEvent(Bazzalan.Poison, math.random(3000, 5000), 0) -- 毒药，3-5秒随机间隔 (Poison, 3-5s random interval)
	creature:RegisterEvent(Bazzalan.Sinister_Strike, 8000, 0) -- 险恶打击，8秒间隔 (Sinister Strike, 8s interval)
end

-- 毒药技能 (Poison skill)
function Bazzalan.Poison(event, delay, pCall, creature)
	if (math.random(1, 100) <= 75) then -- 75%几率释放 (75% chance to cast)
		creature:CastSpell(creature:GetVictim(), 744)
	end
end

-- 险恶打击技能 (Sinister Strike skill)
function Bazzalan.Sinister_Strike(event, delay, pCall, creature)
	if (math.random(1, 100) <= 85) then -- 85%几率释放 (85% chance to cast)
		creature:CastSpell(creature:GetVictim(), 14873)
	end
end

-- 重置事件（离开战斗/死亡时调用）(Reset event - called on leave combat/death)
function Bazzalan.Reset(event, creature)
	creature:RemoveEvents() -- 移除所有定时事件 (Remove all timed events)
end

-- 注册生物事件 (Register creature events)
RegisterCreatureEvent(11519, 1, Bazzalan.OnEnterCombat) -- 1 = 进入战斗 (Enter combat)
RegisterCreatureEvent(11519, 2, Bazzalan.Reset) -- 2 = 离开战斗 (OnLeaveCombat)
RegisterCreatureEvent(11519, 4, Bazzalan.Reset) -- 4 = 死亡 (OnDied)