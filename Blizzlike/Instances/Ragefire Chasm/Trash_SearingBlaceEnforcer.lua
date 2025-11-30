--[[
	============================================================
	脚本名称: 灼热之刃执行者小怪脚本 (Trash Searing Blade Enforcer Script)
	脚本功能: 
		这是怒焰裂谷副本灼热之刃执行者的AI战斗脚本，
		控制小怪的技能释放和战斗行为。

	主要功能:
		1. 进入战斗时注册技能定时器
		2. 释放盾牌猛击技能
		3. 离开战斗或死亡时清除事件

	技能说明:
		- 盾牌猛击 (Shield Slam): 8秒间隔，75%几率
	============================================================

	EmuDevs <http://emudevs.com/forum.php>
	Eluna Lua Engine <https://github.com/ElunaLuaEngine/Eluna>
	Eluna Scripts <https://github.com/ElunaLuaEngine/Scripts>
	Eluna Wiki <http://wiki.emudevs.com/doku.php?id=eluna>

	-= 脚本信息 (Script Information) =-
	* 脚本类型 (Script Type): 小怪 (Trash Mob)
	* NPC: 灼热之刃执行者 Searing Blade Enforcer <11323>
--]]

local Searing_Blade_Enforcer = {};

-- 进入战斗事件 (Enter combat event)
function Searing_Blade_Enforcer.OnEnterCombat(event, creature, target)
	creature:RegisterEvent(Searing_Blade_Enforcer.Shield_Slam, 8000, 0) -- 盾牌猛击，8秒间隔 (Shield Slam, 8s interval)
end

-- 盾牌猛击技能 (Shield Slam skill)
function Searing_Blade_Enforcer.Shield_Slam(event, delay, pCall, creature)
	if (math.random(1, 100) <= 75) then -- 75%几率释放 (75% chance to cast)
		creature:CastSpell(creature:GetVictim(), 8242)
	end
end

-- 重置事件（离开战斗/死亡时调用）(Reset event - called on leave combat/death)
function Searing_Blade_Enforcer.Reset(event, creature)
	creature:RemoveEvents() -- 移除所有定时事件 (Remove all timed events)
end

-- 注册生物事件 (Register creature events)
RegisterCreatureEvent(11323, 1, Searing_Blade_Enforcer.OnEnterCombat) -- 1 = 进入战斗 (Enter combat)
RegisterCreatureEvent(11323, 2, Searing_Blade_Enforcer.Reset) -- 2 = 离开战斗 (OnLeaveCombat)
RegisterCreatureEvent(11323, 4, Searing_Blade_Enforcer.Reset) -- 4 = 死亡 (OnDied)