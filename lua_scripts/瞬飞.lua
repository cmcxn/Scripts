print(" Playerfight init123")

-- local function formatTimestamp(timestamp)
    -- return os.date("%Y-%m-%d %H:%M:%S", timestamp)
-- end
-- 玩家瞬飞时间戳
local function getPlayerFight(player)
    local uid = player:GetAccountId()
    local Q = AuthDBQuery("SELECT endDate FROM account_fight WHERE id = " .. uid)
    local endDate = 0
    if Q then 
		repeat
            local dateString = Q:GetString(0) -- 获取字符串形式的日期时间
            local year, month, day, hour, min, sec = string.match(dateString, "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)") -- 解析日期时间字符串
            endDate = os.time({year = year, month = month, day = day, hour = hour, min = min, sec = sec}) -- 将解析后的日期时间转换为时间戳
		until not Q:NextRow()		 
	else
		--print(" Playerfight is null")	
    end
    return endDate
end
-- 玩家瞬飞时间字符
local function getPlayerFightString(player)
    local uid = player:GetAccountId()
    local Q = AuthDBQuery("SELECT endDate FROM account_fight WHERE id = " .. uid)
    local endDate = 0
    if Q then 
		repeat
            endDate = Q:GetString(0) -- 获取字符串形式的日期时间
		until not Q:NextRow()		 
	else
		--print(" Playerfight is null")	
    end
    return endDate
end

 
local function isFightExpired(player)
	local currentTimestamp = os.time() -- 当前时间戳 
	local endDate = getPlayerFight(player) -- 获取瞬飞到期时间戳
    return endDate < currentTimestamp -- 判断到期时间是否小于当前时间
end

-- 玩家机器人陪玩时间戳
local function getPlayerPartyBot(player)
    local uid = player:GetAccountId()
    local Q = AuthDBQuery("SELECT endDate FROM account_partybot WHERE id = " .. uid)
    local endDate = 0
    if Q then 
		repeat
            local dateString = Q:GetString(0) -- 获取字符串形式的日期时间
            local year, month, day, hour, min, sec = string.match(dateString, "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)") -- 解析日期时间字符串
            endDate = os.time({year = year, month = month, day = day, hour = hour, min = min, sec = sec}) -- 将解析后的日期时间转换为时间戳
		until not Q:NextRow()		 
	else
		--print(" Playerfight is null")	
    end
    return endDate
end

-- 玩家机器人陪玩时间字符
local function getPlayerPartyBotString(player)
    local uid = player:GetAccountId()
    local Q = AuthDBQuery("SELECT endDate FROM account_partybot WHERE id = " .. uid)
    local endDate = 0
    if Q then 
		repeat
            endDate = Q:GetString(0) -- 获取字符串形式的日期时间
		until not Q:NextRow()		 
	else
		--print(" Playerfight is null")	
    end
    return endDate
end

local function isPartyBotExpired(player)
	local currentTimestamp = os.time() -- 当前时间戳 
	local endDate = getPlayerPartyBot(player) -- 获取瞬飞到期时间戳
    return endDate < currentTimestamp -- 判断到期时间是否小于当前时间
end

local function Playerfight(event, player)--瞬飞判断 
	local endDate = getPlayerFightString(player)
	if(endDate == 0) then
		player:SendBroadcastMessage(" 瞬飞服务未开通"   )
	else
		player:SendBroadcastMessage(" 瞬飞服务过期时间：" .. endDate )
	end
	if(isFightExpired(player)) then
		player:SendBroadcastMessage("瞬飞服务已过期！")
		return false
	else
		--player:SendBroadcastMessage("正在使用瞬飞服务！ "   )
		return true
	end 
	--return true
end 

RegisterPlayerEvent(101, Playerfight)--瞬飞钩子
print(" Playerfight init ok  "   )

local function OnParty(event, player,cmd)--机器人判断 
	-- print(" OnParty   " .. cmd  )
	local endDate = getPlayerPartyBotString(player)
	if(endDate == 0) then
		player:SendBroadcastMessage(" 陪玩服务未开通"   )
	else
		player:SendBroadcastMessage(" 陪玩服务过期时间：" .. endDate )
	end
	-- print(isPartyBotExpired(player) )
	if(isPartyBotExpired(player)) then
		player:SendBroadcastMessage("陪玩服务已过期！")
		return false
	else 
		return true
	end 	 
	-- return true
end 

-- RegisterPlayerEvent(102, OnParty)--机器人钩子
print(" OnParty init ok  1234567"   )

