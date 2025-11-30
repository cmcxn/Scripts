--[[
	============================================================
	脚本名称: 怒焰穴居人小怪脚本 (Trash Ragefire Trogg Script)
	脚本功能: 
		这是怒焰裂谷副本怒焰穴居人的AI战斗脚本，
		控制小怪的技能释放和战斗行为。

	主要功能:
		1. 进入战斗时注册技能定时器
		2. 释放打击技能
		3. 离开战斗或死亡时清除事件

	技能说明:
		- 打击 (Strike): 5秒间隔，100%几率
	============================================================

	EmuDevs <http://emudevs.com/forum.php>
	Eluna Lua Engine <https://github.com/ElunaLuaEngine/Eluna>
	Eluna Scripts <https://github.com/ElunaLuaEngine/Scripts>
	Eluna Wiki <http://wiki.emudevs.com/doku.php?id=eluna>

	-= 脚本信息 (Script Information) =-
	* 脚本类型 (Script Type): 小怪 (Trash Mob)
	* NPC: 怒焰穴居人 Ragefire Trogg <11318>
--]]

local Ragefire_Trogg = {};

-- 进入战斗事件 (Enter combat event)
function Ragefire_Trogg.OnEnterCombat(event, creature, target)
	creature:RegisterEvent(Ragefire_Trogg.Strike, 5000, 0) -- 打击，5秒间隔 (Strike, 5s interval)
end

-- 打击技能 (Strike skill)
function Ragefire_Trogg.Strike(event, delay, pCall, creature)
	creature:CastSpell(creature:GetVictim(), 11976)
end

-- 重置事件（离开战斗/死亡时调用）(Reset event - called on leave combat/death)
function Ragefire_Trogg.Reset(event, creature)
	creature:RemoveEvents() -- 移除所有定时事件 (Remove all timed events)
end

-- 注册生物事件 (Register creature events)
RegisterCreatureEvent(11318, 1, Ragefire_Trogg.OnEnterCombat) -- 1 = 进入战斗 (Enter combat)
RegisterCreatureEvent(11318, 2, Ragefire_Trogg.Reset) -- 2 = 离开战斗 (OnLeaveCombat)
RegisterCreatureEvent(11318, 4, Ragefire_Trogg.Reset) -- 4 = 死亡 (OnDied)