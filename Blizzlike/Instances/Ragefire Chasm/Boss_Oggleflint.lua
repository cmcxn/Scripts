--[[
	============================================================
	脚本名称: 奥格弗林特Boss战斗脚本 (Boss Oggleflint Combat Script)
	脚本功能: 
		这是怒焰裂谷副本Boss奥格弗林特的AI战斗脚本，
		控制Boss的技能释放和战斗行为。

	主要功能:
		1. 进入战斗时注册技能定时器
		2. 释放顺劈斩技能
		3. 离开战斗或死亡时清除事件

	技能说明:
		- 顺劈斩 (Cleave): 8秒间隔，70%几率
	============================================================

	EmuDevs <http://emudevs.com/forum.php>
	Eluna Lua Engine <https://github.com/ElunaLuaEngine/Eluna>
	Eluna Scripts <https://github.com/ElunaLuaEngine/Scripts>
	Eluna Wiki <http://wiki.emudevs.com/doku.php?id=eluna>

	-= 脚本信息 (Script Information) =-
	* 脚本类型 (Script Type): Boss战斗 (Boss Fight)
	* NPC: 奥格弗林特 Oggleflint <11517>
--]]

local Oggleflint = {};

-- 进入战斗事件 (Enter combat event)
function Oggleflint.OnEnterCombat(event, creature, target)
	creature:RegisterEvent(Oggleflint.Cleave, 8000, 0) -- 顺劈斩，8秒间隔 (Cleave, 8s interval)
end

-- 顺劈斩技能 (Cleave skill)
function Oggleflint.Cleave(event, delay, pCall, creature)
	if (math.random(1, 100) <= 70) then -- 70%几率释放 (70% chance to cast)
		creature:CastSpell(creature:GetVictim(), 40505)
	end
end

-- 重置事件（离开战斗/死亡时调用）(Reset event - called on leave combat/death)
function Oggleflint.Reset(event, creature)
	creature:RemoveEvents() -- 移除所有定时事件 (Remove all timed events)
end

-- 注册生物事件 (Register creature events)
RegisterCreatureEvent(11517, 1, Oggleflint.OnEnterCombat) -- 1 = 进入战斗 (Enter combat)
RegisterCreatureEvent(11517, 2, Oggleflint.Reset) -- 2 = 离开战斗 (OnLeaveCombat)
RegisterCreatureEvent(11517, 4, Oggleflint.Reset) -- 4 = 死亡 (OnDied)