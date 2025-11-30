--[[
    ============================================================
    脚本名称: 世界消息广播器 (World Message Broadcaster)
    脚本功能: 
        这是一个定时世界消息广播脚本，可以在指定时间
        或指定间隔向所有在线玩家发送广播消息。

    主要功能:
        1. 支持按固定时间间隔广播消息
        2. 支持在每周特定日期和时间广播消息
        3. 支持多条消息同时配置
        4. 自动计算下次广播时间

    配置说明:
        在 Broadcast.Register 表中添加消息配置:
        {"消息内容", 日期, 时间}
        - 日期: 1-7 表示周一到周日 (Monday=1, Sunday=7)
                0 表示使用固定间隔
        - 时间: 如果日期为0，则为间隔秒数
                如果日期>0，则为小时.分钟格式 (如 14.30 = 14:30)
    ============================================================
--]]

local Broadcast = {
	Register = {
		-- 消息配置格式 (Message configuration format):
		-- {"消息内容 (String)", 日期 (day), 时间 (time)}
		-- 日期是1到7，周一是1，周日是7 (Day is from 1 to 7, where Monday is 1 and Sunday is 7)
		-- 如果日期是0，时间是间隔秒数；如果指定了日期，时间是小时.分钟格式
		-- (Time is either seconds if day is 0 or format hour.minutes if day is specified)
		{"这是广播消息示例 (Announce message here)", 0, 1800}, -- 每1800秒(30分钟)广播一次
	}
}

-- 分离时间为小时和分钟 (Separate time into hours and minutes)
local function SeparateTime(t)
	local h = math.floor(t)         -- 小时 (hours)
	local m = ((t*1000)-(h*1000))/10 -- 分钟 (minutes)
	return h, m;
end

-- 计算到指定日期时间的秒数差 (Calculate seconds difference to specified date/time)
-- weekday: 目标星期几 (target day of week)
-- h: 小时 (hour)
-- m: 分钟 (minute)
-- s: 秒 (second)
local function GetTimeDiff(weekday, h, m, s)
	local d = os.date("*t") -- 获取当前日期时间 (Get current date/time)

	d.sec = s or 0
	d.min = m
	d.hour = h

	local ddiff = weekday-d.wday+1 -- 计算日期差 (Calculate day difference)
	d.day = d.day+ddiff
	local now = os.date("*t")
	
	if (ddiff < 0) then
		-- 考虑到目标日期在当前日期之前的情况（如当前是周二想要周一）
		-- Take into consideration that it is tuesday and we want monday
		d.day = d.day+7
	elseif (ddiff == 0 and d.hour*60*60+d.min*60+d.sec < now.hour*60*60+now.min*60+now.sec) then
		-- 考虑到是同一天但已经过了目标时间的情况
		-- Take into consideration that it is the same date, but its already past the wanted time
		d.day = d.day+7
	end

	-- 获取最终时间 (get final times)
	local e = os.time(d)
	local diff = e-os.time() -- 这是到目标日期的秒数 (this is the time in seconds until the wanted date is achieved)

	return diff;
end

-- 发送消息并重新设置定时器 (Send message and reset timer)
function Broadcast.SendAndReset(msg, d, t)
	SendWorldMessage(msg) -- 向所有玩家发送世界消息 (Send world message to all players)
	if(d > 0) then
		-- 如果指定了日期，计算下次广播时间 (If day specified, calculate next broadcast time)
		local regtime = GetTimeDiff(d, SeparateTime(t))
		CreateLuaEvent(function() Broadcast.SendAndReset(msg, d, t) end, regtime*1000, 1)
	end
end

-- 脚本加载时初始化所有广播任务 (Initialize all broadcast tasks when script loads)
function Broadcast.OnLoad()
	for i, v in ipairs(Broadcast.Register) do
		local msg, d, t = table.unpack(Broadcast.Register[i])
		if d == 0 then
			-- 日期为0时，使用固定间隔循环广播 (When day is 0, use fixed interval loop)
			CreateLuaEvent(function() Broadcast.SendAndReset(msg, d, t) end, t*1000, 0)
		else
			-- 指定日期时，计算首次广播时间 (When day specified, calculate first broadcast time)
			local regtime = GetTimeDiff(d, SeparateTime(t))
			CreateLuaEvent(function() Broadcast.SendAndReset(msg, d, t) end, regtime*1000, 1)
		end
	end
end

-- 启动广播系统 (Start broadcast system)
Broadcast.OnLoad()