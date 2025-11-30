--[[
	============================================================
	脚本名称: 祈求者耶戈什Boss战斗脚本 (Boss Jergosh the Invoker Combat Script)
	脚本功能: 
		这是怒焰裂谷副本Boss祈求者耶戈什的AI战斗脚本，
		控制Boss的技能释放和战斗行为。

	主要功能:
		1. 进入战斗时注册技能定时器
		2. 释放献祭和虚弱诅咒技能
		3. 离开战斗或死亡时清除事件

	技能说明:
		- 献祭 (Immolate): 12秒间隔，85%几率
		- 虚弱诅咒 (Curse of Weakness): 30秒间隔，75%几率，随机目标
	============================================================

	EmuDevs <http://emudevs.com/forum.php>
	Eluna Lua Engine <https://github.com/ElunaLuaEngine/Eluna>
	Eluna Scripts <https://github.com/ElunaLuaEngine/Scripts>
	Eluna Wiki <http://wiki.emudevs.com/doku.php?id=eluna>

	-= 脚本信息 (Script Information) =-
	* 脚本类型 (Script Type): Boss战斗 (Boss Fight)
	* NPC: 祈求者耶戈什 Jergosh the Invoker <11518>
--]]

local Jergosh = {};

-- 进入战斗事件 (Enter combat event)
function Jergosh.OnEnterCombat(event, creature, target)
	creature:RegisterEvent(Jergosh.Immolate, 12000, 0) -- 献祭，12秒间隔 (Immolate, 12s interval)
	creature:RegisterEvent(Jergosh.Curse_of_Weakness, 30000, 0) -- 虚弱诅咒，30秒间隔 (Curse of Weakness, 30s interval)
end

-- 献祭技能 (Immolate skill)
function Jergosh.Immolate(event, delay, pCall, creature)
	if (math.random(1, 100) <= 85) then -- 85%几率释放 (85% chance to cast)
		creature:CastSpell(creature:GetVictim(), 20800)
	end
end

-- 虚弱诅咒技能 (Curse of Weakness skill)
function Jergosh.Curse_of_Weakness(event, delay, pCall, creature)
	if (math.random(1, 100) <= 75) then -- 75%几率释放 (75% chance to cast)
		local players = creature:GetPlayersInRange() -- 获取范围内玩家 (Get players in range)
		creature:CastSpell(players[math.random(1, #players)], 11980) -- 随机目标 (Random target)
	end
end

-- 重置事件（离开战斗/死亡时调用）(Reset event - called on leave combat/death)
function Jergosh.Reset(event, creature)
	creature:RemoveEvents() -- 移除所有定时事件 (Remove all timed events)
end

-- 注册生物事件 (Register creature events)
RegisterCreatureEvent(11518, 1, Jergosh.OnEnterCombat) -- 1 = 进入战斗 (Enter combat)
RegisterCreatureEvent(11518, 2, Jergosh.Reset) -- 2 = 离开战斗 (OnLeaveCombat)
RegisterCreatureEvent(11518, 4, Jergosh.Reset) -- 4 = 死亡 (OnDied)