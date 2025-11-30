--[[
	============================================================
	脚本名称: 饥饿者塔拉加曼Boss战斗脚本 (Boss Taragaman the Hungerer Combat Script)
	脚本功能: 
		这是怒焰裂谷副本Boss饥饿者塔拉加曼的AI战斗脚本，
		控制Boss的技能释放和战斗行为。

	主要功能:
		1. 进入战斗时注册技能定时器
		2. 释放上勾拳和火焰新星技能
		3. 离开战斗或死亡时清除事件

	技能说明:
		- 上勾拳 (Uppercut): 5秒间隔，85%几率
		- 火焰新星 (Fire Nova): 8秒间隔，75%几率
	============================================================

	EmuDevs <http://emudevs.com/forum.php>
	Eluna Lua Engine <https://github.com/ElunaLuaEngine/Eluna>
	Eluna Scripts <https://github.com/ElunaLuaEngine/Scripts>
	Eluna Wiki <http://wiki.emudevs.com/doku.php?id=eluna>

	-= 脚本信息 (Script Information) =-
	* 脚本类型 (Script Type): Boss战斗 (Boss Fight)
	* NPC: 饥饿者塔拉加曼 Taragaman the Hungerer <11520>
--]]

local Taragaman = {};

-- 进入战斗事件 (Enter combat event)
function Taragaman.OnEnterCombat(event, creature, target)
	creature:RegisterEvent(Taragaman.Uppercut, 5000, 0) -- 上勾拳，5秒间隔 (Uppercut, 5s interval)
	creature:RegisterEvent(Taragaman.Fire_Nova, 8000, 0) -- 火焰新星，8秒间隔 (Fire Nova, 8s interval)
end

-- 上勾拳技能 (Uppercut skill)
function Taragaman.Uppercut(event, delay, pCall, creature)
	if (math.random(1, 100) <= 85) then -- 85%几率释放 (85% chance to cast)
		creature:CastSpell(creature:GetVictim(), 18072)
	end
end

-- 火焰新星技能 (Fire Nova skill)
function Taragaman.Fire_Nova(event, delay, pCall, creature)
	if (math.random(1, 100) <= 75) then -- 75%几率释放 (75% chance to cast)
		creature:CastSpell(creature:GetVictim(), 11970)
	end
end

-- 重置事件（离开战斗/死亡时调用）(Reset event - called on leave combat/death)
function Taragaman.Reset(event, creature)
	creature:RemoveEvents() -- 移除所有定时事件 (Remove all timed events)
end

-- 注册生物事件 (Register creature events)
RegisterCreatureEvent(11520, 1, Taragaman.OnEnterCombat) -- 1 = 进入战斗 (Enter combat)
RegisterCreatureEvent(11520, 2, Taragaman.Reset) -- 2 = 离开战斗 (OnLeaveCombat)
RegisterCreatureEvent(11520, 4, Taragaman.Reset) -- 4 = 死亡 (OnDied)