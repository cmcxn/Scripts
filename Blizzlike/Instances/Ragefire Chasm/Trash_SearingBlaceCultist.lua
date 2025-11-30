--[[
	============================================================
	脚本名称: 灼热之刃狂热者小怪脚本 (Trash Searing Blade Cultist Script)
	脚本功能: 
		这是怒焰裂谷副本灼热之刃狂热者的AI战斗脚本，
		控制小怪的技能释放和战斗行为。

	主要功能:
		1. 进入战斗时注册技能定时器
		2. 释放痛苦诅咒技能
		3. 离开战斗或死亡时清除事件

	技能说明:
		- 痛苦诅咒 (Curse of Agony): 12秒间隔，85%几率，随机目标
	============================================================

	EmuDevs <http://emudevs.com/forum.php>
	Eluna Lua Engine <https://github.com/ElunaLuaEngine/Eluna>
	Eluna Scripts <https://github.com/ElunaLuaEngine/Scripts>
	Eluna Wiki <http://wiki.emudevs.com/doku.php?id=eluna>

	-= 脚本信息 (Script Information) =-
	* 脚本类型 (Script Type): 小怪 (Trash Mob)
	* NPC: 灼热之刃狂热者 Searing Blade Cultist <11322>
--]]

local Searing_Blade_Cultist = {};

-- 进入战斗事件 (Enter combat event)
function Searing_Blade_Cultist.OnEnterCombat(event, creature, target)
	creature:RegisterEvent(Searing_Blade_Cultist.Curse_of_Agony, 12000, 0) -- 痛苦诅咒，12秒间隔 (Curse of Agony, 12s interval)
end

-- 痛苦诅咒技能 (Curse of Agony skill)
function Searing_Blade_Cultist.Curse_of_Agony(event, delay, pCall, creature)
	if (math.random(1, 100) <= 85) then -- 85%几率释放 (85% chance to cast)
		local players = creature:GetPlayersInRange() -- 获取范围内玩家 (Get players in range)
		creature:CastSpell(players[math.random(1, #players)], 18266) -- 随机目标 (Random target)
	end
end

-- 重置事件（离开战斗/死亡时调用）(Reset event - called on leave combat/death)
function Searing_Blade_Cultist.Reset(event, creature)
	creature:RemoveEvents() -- 移除所有定时事件 (Remove all timed events)
end

-- 注册生物事件 (Register creature events)
RegisterCreatureEvent(11322, 1, Searing_Blade_Cultist.OnEnterCombat) -- 1 = 进入战斗 (Enter combat)
RegisterCreatureEvent(11322, 2, Searing_Blade_Cultist.Reset) -- 2 = 离开战斗 (OnLeaveCombat)
RegisterCreatureEvent(11322, 4, Searing_Blade_Cultist.Reset) -- 4 = 死亡 (OnDied)