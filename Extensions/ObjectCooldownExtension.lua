--[[
    ============================================================
    脚本名称: 对象冷却扩展 (Object Cooldown Extension)
    脚本功能: 
        这是一个对象冷却扩展脚本，为Player对象添加
        自定义的Lua冷却时间管理功能。

    主要功能:
        1. 为玩家设置自定义冷却时间
        2. 获取玩家剩余冷却时间
        3. 支持多个独立的冷却ID
        4. 按脚本文件自动隔离冷却数据

    使用方法:
        player:SetLuaCooldown(30)      -- 设置30秒冷却
        player:GetLuaCooldown()        -- 获取剩余冷却秒数
        player:SetLuaCooldown(30, 2)   -- 设置冷却ID为2的30秒冷却
        player:GetLuaCooldown(2)       -- 获取冷却ID为2的剩余秒数
    ============================================================
--]]

local cooldowns = {}; -- 冷却数据存储表 (Cooldown data storage table)

-- 为玩家设置Lua冷却时间 (Set Lua cooldown for player)
-- seconds: 冷却时间(秒) (cooldown duration in seconds)
-- opt_id: 可选的冷却ID，默认为1 (optional cooldown ID, defaults to 1)
function Player:SetLuaCooldown(seconds, opt_id)
	assert(type(self) == "userdata"); -- 确保self是有效的用户数据 (Ensure self is valid userdata)
	seconds = assert(tonumber(seconds)); -- 确保seconds是有效数字 (Ensure seconds is a valid number)
	opt_id = opt_id or 1; -- 默认冷却ID为1 (Default cooldown ID is 1)
	local guid, source = self:GetGUIDLow(), debug.getinfo(2, 'S').short_src; -- 获取玩家GUID和调用脚本路径 (Get player GUID and calling script path)

	-- 初始化玩家的冷却表 (Initialize player's cooldown table)
	if (not cooldowns[guid]) then
		cooldowns[guid] = { [source] = {}; };
	end

	-- 设置冷却结束时间 (Set cooldown end time)
	cooldowns[guid][source][opt_id] = os.clock() + seconds;
end

-- 获取玩家的Lua冷却剩余时间 (Get player's remaining Lua cooldown time)
-- opt_id: 可选的冷却ID，默认为1 (optional cooldown ID, defaults to 1)
-- 返回: 剩余冷却秒数，0表示没有冷却或冷却已结束 (Returns: remaining cooldown seconds, 0 means no cooldown or cooldown ended)
function Player:GetLuaCooldown(opt_id)
	assert(type(self) == "userdata"); -- 确保self是有效的用户数据 (Ensure self is valid userdata)
	local guid, source = self:GetGUIDLow(), debug.getinfo(2, 'S').short_src; -- 获取玩家GUID和调用脚本路径 (Get player GUID and calling script path)
	opt_id = opt_id or 1; -- 默认冷却ID为1 (Default cooldown ID is 1)

	-- 初始化玩家的冷却表 (Initialize player's cooldown table)
	if (not cooldowns[guid]) then
		cooldowns[guid] = { [source] = {}; };
	end

	local cd = cooldowns[guid][source][opt_id];
	if (not cd or cd < os.clock()) then
		-- 没有冷却或冷却已结束 (No cooldown or cooldown ended)
		cooldowns[guid][source][opt_id] = 0
		return 0;
	else
		-- 返回剩余冷却秒数 (Return remaining cooldown seconds)
		return cooldowns[guid][source][opt_id] - os.clock();
	end
end

--[[ 使用示例 (Example usage):
	if(player:GetLuaCooldown() == 0) then -- 检查是否有冷却 (Check if cooldown is present)
		player:SetLuaCooldown(30)
		print("冷却已设置为30秒 (Cooldown is set to 30 seconds)")
	else
		print("您的冷却还剩 "..player:GetLuaCooldown().." 秒！(There are still "..player:GetLuaCooldown().." seconds remaining of your cooldown!)")
	end
]]