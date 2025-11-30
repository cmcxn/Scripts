--[[
	============================================================
	脚本名称: 钻地虫小怪脚本 (Trash Earthborer Script)
	脚本功能: 
		这是怒焰裂谷副本钻地虫的AI战斗脚本，
		控制小怪的技能释放和战斗行为。

	主要功能:
		1. 进入战斗时注册技能定时器
		2. 释放酸液技能
		3. 离开战斗或死亡时清除事件

	技能说明:
		- 钻地虫酸液 (Earthborer Acid): 6秒间隔，70%几率
	============================================================

	EmuDevs <http://emudevs.com/forum.php>
	Eluna Lua Engine <https://github.com/ElunaLuaEngine/Eluna>
	Eluna Scripts <https://github.com/ElunaLuaEngine/Scripts>
	Eluna Wiki <http://wiki.emudevs.com/doku.php?id=eluna>

	-= 脚本信息 (Script Information) =-
	* 脚本类型 (Script Type): 小怪 (Trash Mob)
	* NPC: 钻地虫 Earthborer <11320>
--]]

local Earthborer = {};

-- 进入战斗事件 (Enter combat event)
function Earthborer.OnEnterCombat(event, creature, target)
	creature:RegisterEvent(Earthborer.Earthborer_Acid, 6000, 0) -- 酸液，6秒间隔 (Acid, 6s interval)
end

-- 钻地虫酸液技能 (Earthborer Acid skill)
function Earthborer.Earthborer_Acid(event, delay, pCall, creature)
	if (math.random(1, 100) <= 70) then -- 70%几率释放 (70% chance to cast)
		creature:CastSpell(creature:GetVictim(), 18070)
	end
end

-- 重置事件（离开战斗/死亡时调用）(Reset event - called on leave combat/death)
function Earthborer.Reset(event, creature)
	creature:RemoveEvents() -- 移除所有定时事件 (Remove all timed events)
end

-- 注册生物事件 (Register creature events)
RegisterCreatureEvent(11320, 1, Earthborer.OnEnterCombat) -- 1 = 进入战斗 (Enter combat)
RegisterCreatureEvent(11320, 2, Earthborer.Reset) -- 2 = 离开战斗 (OnLeaveCombat)
RegisterCreatureEvent(11320, 4, Earthborer.Reset) -- 4 = 死亡 (OnDied)