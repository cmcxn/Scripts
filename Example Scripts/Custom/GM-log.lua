--[[
    ============================================================
    脚本名称: GM登录/登出日志 (GM Login/Logout Logger)
    脚本功能: 
        这是一个GM登录和登出通知脚本，当GM权限的玩家
        登录或登出时，向所有在线玩家发送世界消息通知。

    主要功能:
        1. 检测GM玩家登录并广播通知
        2. 检测GM玩家登出并广播通知
        3. 向控制台输出日志

    示例学习:
        - GetGMRank: 获取玩家GM等级
        - GetName: 获取玩家名称
        - SendWorldMessage: 发送世界消息
    ============================================================
--]]

print "---------- GM登录/登出日志 (GM Login/Logout) ---"

-- GM登录事件处理 (GM login event handler)
local function GMLogin (event, player)
    print "GM登入 (GM log in)"
    -- 检查玩家GM等级是否大于1 (Check if player GM rank is greater than 1)
    if player:GetGMRank() > 1 then
        -- 向所有玩家发送GM上线通知 (Send GM online notification to all players)
        SendWorldMessage("管理员 |CFFFF0303"..player:GetName().."|r 已上线。(Lord |CFFFF0303"..player:GetName().."|r is among us.)")
	end
end

-- GM登出事件处理 (GM logout event handler)
local function GMLogout (event, player)
    print "GM登出 (GM log out)"
    -- 检查玩家GM等级是否大于1 (Check if player GM rank is greater than 1)
    if player:GetGMRank() > 1 then
        -- 向所有玩家发送GM下线通知 (Send GM offline notification to all players)
        SendWorldMessage("管理员 |CFFFF0303"..player:GetName().."|r 已离开。(Lord |CFFFF0303"..player:GetName().."|r gone.)")
    end
end

-- 注册玩家事件 (Register player events)
RegisterPlayerEvent(3, GMLogin)  -- 3 = 玩家登录事件 (Player login event)
RegisterPlayerEvent(4, GMLogout) -- 4 = 玩家登出事件 (Player logout event)
