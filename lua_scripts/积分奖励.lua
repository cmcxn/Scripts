print(" PlayerBoost init")

local function getPlayerMoney(player) -- 获得玩家积分
    local uid = player:GetAccountId() 
    -- 查询玩家的积分
    local Q = AuthDBQuery(string.format("SELECT moneys FROM account_money WHERE id = %d", uid))
    local moneys = 0  -- 默认积分为0
	
	if Q then
		repeat
			moneys  = Q:GetUInt32(0) 
		until not Q:NextRow()	 
	else	 
		AuthDBExecute(string.format("INSERT IGNORE INTO account_money (id, moneys) VALUES (%d, %d)", uid, 0))
	end 
    return moneys
end 

local function addPlayerMoney(player, money) -- 增加玩家积分
    local uid = player:GetAccountId()
    -- 使用 SQL 直接增加积分
    AuthDBExecute(string.format("UPDATE account_money SET moneys = moneys + %d WHERE id = %d", money, uid))
end

local function removePlayerMoney(player, money) -- 减去玩家积分
    local uid = player:GetAccountId()
    -- 使用 SQL 直接减少积分
    AuthDBExecute(string.format("UPDATE account_money SET moneys = moneys - %d WHERE id = %d", money, uid))
end

local function PlayerBoost(event, player) -- 玩家激励
    local boost_money = 2  -- 每次加2分
    addPlayerMoney(player, boost_money)  -- 增加积分
    local moneys = getPlayerMoney(player)  -- 获取当前积分
    player:SendBroadcastMessage(string.format("在线30分钟获得%d积分, 当前余额：%d", boost_money, moneys))
end

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
-- 玩家瞬飞时间增加
local function addPlayerFightDay(player, days)
    local uid = player:GetAccountId()
	local endDate =  getPlayerFight(player)
	local currentDate = os.time() -- 当前时间戳
	local newEndDate = currentDate + (days * 24 * 60 * 60) -- 根据瞬飞天数计算的新到期时间
	if(endDate == 0) then
		-- 没开通
		AuthDBQuery("INSERT INTO account_fight (id, endDate) VALUES (" .. uid .. ", '" .. os.date("%Y-%m-%d %H:%M:%S", newEndDate) .. "')") -- 插入新记录到数据库
	else
		-- 只有没过期时候追加时间
		if(endDate>currentDate) then
			newEndDate =  endDate + (days * 24 * 60 * 60) 
		end		
		AuthDBQuery("UPDATE account_fight SET endDate = '" .. os.date("%Y-%m-%d %H:%M:%S", newEndDate) .. "' WHERE id = " .. uid) -- 更新数据库
	end
    return newEndDate -- 返回新的到期时间戳
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
-- 玩家机器人陪玩时间增加
local function addPlayerPartyBotDay(player, days)
    local uid = player:GetAccountId()
	local endDate =  getPlayerPartyBotString(player)
	local currentDate = os.time() -- 当前时间戳
	local newEndDate = currentDate + (days * 24 * 60 * 60) -- 根据瞬飞天数计算的新到期时间
	if(endDate == 0) then
		-- 没开通
		AuthDBQuery("INSERT INTO account_partybot (id, endDate) VALUES (" .. uid .. ", '" .. os.date("%Y-%m-%d %H:%M:%S", newEndDate) .. "')") -- 插入新记录到数据库
	else
		-- 只有没过期时候追加时间
		if(endDate>currentDate) then
			newEndDate =  endDate + (days * 24 * 60 * 60) 
		end		
		AuthDBQuery("UPDATE account_partybot SET endDate = '" .. os.date("%Y-%m-%d %H:%M:%S", newEndDate) .. "' WHERE id = " .. uid) -- 更新数据库
	end
    return newEndDate -- 返回新的到期时间戳
end



 
 local NPC_Entry = 22000
 
local menu_id = math.random(1000)

local function mainMenu(event, player, creature) 
    player:GossipClearMenu()
    player:GossipMenuAddItem(4, "秒升60级", 1,0 )	    
    player:GossipMenuAddItem(4, "秒升专业", 2,0 )	  
	player:GossipMenuAddItem(4, "辅助增益", 3,0 )	 
	player:GossipMenuAddItem(4, "稀有坐骑", 4,0 )	 
	player:GossipMenuAddItem(4, "传说武器", 5,0 )	 	
	player:GossipMenuAddItem(4, "兑换金币", 6,0 )	
	player:GossipMenuAddItem(4, "兑换积分", 66,0 )	
	player:GossipMenuAddItem(4, "瞬飞服务", 7,0 )	
    player:GossipMenuAddItem(4, "陪玩服务", 8,0 )	  	
	player:GossipMenuAddItem(0, "当前账号积分：|cFF000080"..getPlayerMoney(player).."|r", 0,0 )	 	
	local endDate = getPlayerFightString(player)
	if(endDate == 0) then		 
		player:GossipMenuAddItem(0, "当前账号：|cFF000080瞬飞服务未开通|r", 0,0 )	 	
	else		 
		player:GossipMenuAddItem(0, "瞬飞服务过期时间：|cFF000080"..endDate.."|r", 0,0 )	 	
	end
	
	endDate = getPlayerPartyBotString(player)
	if(endDate == 0) then		 
		player:GossipMenuAddItem(0, "当前账号：|cFF000080机器人陪玩未开通|r", 0,0 )	 	
	else		 
		player:GossipMenuAddItem(0, "机器人陪玩过期时间：|cFF000080"..endDate .."|r", 0,0 )	 	
	end	
    player:GossipSendMenu(100, creature, menu_id)
end

local function OnGossipHello(event, player, creature)
	mainMenu(event, player, creature)
end

local function OnGossipSelect(event, player, creature, MenuGroup, MenuID)
	if MenuGroup==0 then
		mainMenu(event, player, creature)
	end
	-----等级秒升-----
	if MenuGroup==1 then
		player:GossipMenuAddItem(4, "秒升需要 |cFFFF0000500积分|r,点击确定", 11,0 )
		
		player:GossipMenuAddItem(7, "返回主菜单", 0,0 )
		player:GossipSendMenu(100, creature, menu_id)
	end
	-----等级秒升实现-----
	if MenuGroup==11 then
		if player:GetLevel() >=60 then
			player:SendBroadcastMessage("你已经满级了，无法使用秒升！")
			player:GossipComplete()
		else
			if getPlayerMoney(player)<500 then
				player:SendBroadcastMessage("秒升需要|cFFFF0000500积分|r，你的积分不足！")				
				player:GossipComplete()
			else
				player:SetLevel(60)
				removePlayerMoney(player,500 )
				player:SendBroadcastMessage("恭喜你秒升60级，可喜可贺！")
				player:GossipComplete()
			end
		end
	end
	
	-----------秒升专业-----------
	if MenuGroup==2 then
		player:GossipMenuAddItem(5, "秒升采矿 |cFFFF0000500积分|r", 21,0 )
		player:GossipMenuAddItem(5, "秒升锻造 |cFFFF0000500积分|r", 22,0 )
		player:GossipMenuAddItem(5, "秒升工程 |cFFFF0000500积分|r", 23,0 )
		player:GossipMenuAddItem(5, "秒升草药 |cFFFF0000500积分|r", 24,0 )
		player:GossipMenuAddItem(5, "秒升炼金 |cFFFF0000500积分|r", 25,0 )
		player:GossipMenuAddItem(5, "秒升裁缝 |cFFFF0000500积分|r", 26,0 )
		player:GossipMenuAddItem(5, "秒升附魔 |cFFFF0000500积分|r", 27,0 )
		player:GossipMenuAddItem(5, "秒升制皮 |cFFFF0000500积分|r", 28,0 )
		player:GossipMenuAddItem(5, "秒升剥皮 |cFFFF0000500积分|r", 29,0 )
		player:GossipMenuAddItem(5, "秒升急救 |cFFFF0000300积分|r", 210,0 )
		player:GossipMenuAddItem(5, "秒升烹饪 |cFFFF0000300积分|r", 211,0 )
		player:GossipMenuAddItem(5, "秒升钓鱼 |cFFFF0000300积分|r", 212,0 )
		player:GossipMenuAddItem(7, "返回主菜单", 0,0 )
		player:GossipSendMenu(100, creature, menu_id) 
	end
	
	-----秒升采矿--------
	if MenuGroup==21 then
		if not player:HasSpell( 2575 ) then
			player:SendBroadcastMessage("你没有学习采矿，无法秒升。") 
			player:GossipComplete()
		else
			if getPlayerMoney(player)<500 then
				player:SendBroadcastMessage("需要|cFFFF0000500积分|r，你的积分不足！")
				player:GossipComplete()
			else
				if player:GetSkillValue( 186 )>=300 then
					player:SendBroadcastMessage("你的采矿技能已经满了，无法秒升！")
					player:GossipComplete()
				else
					player:LearnSpell(10248)
					player:AdvanceSkill(186, 300)
					removePlayerMoney(player,500 )
					player:SendBroadcastMessage("你的采矿技能已经满！")
					player:GossipComplete()
				end
			end
		end	
	end
	
	-----秒升锻造--------
	if MenuGroup==22 then
		if not player:HasSpell( 2018 ) then
			player:SendBroadcastMessage("你没有学习锻造，无法秒升。") 
			player:GossipComplete()
		else
			if getPlayerMoney(player)<500 then
				player:SendBroadcastMessage("需要|cFFFF0000500积分|r，你的积分不足！")
				player:GossipComplete()
			else
				if player:GetSkillValue( 164 )>=300 then
					player:SendBroadcastMessage("你的锻造技能已经满了，无法秒升！")
					player:GossipComplete()
				else
					player:LearnSpell(9785)
					player:AdvanceSkill(164, 300)
					removePlayerMoney(player,500 )
					player:SendBroadcastMessage("你的锻造技能已经满！")
					player:GossipComplete()
				end
			end
		end	
	end
	
	-----秒升工程--------
	if MenuGroup==23 then
		if not player:HasSpell( 4036 ) then
			player:SendBroadcastMessage("你没有学习工程，无法秒升。") 
			player:GossipComplete()
		else
			if getPlayerMoney(player)<500 then
				player:SendBroadcastMessage("需要|cFFFF0000500积分|r，你的积分不足！")
				player:GossipComplete()
			else
				if player:GetSkillValue( 202 )>=300 then
					player:SendBroadcastMessage("你的工程技能已经满了，无法秒升！")
					player:GossipComplete()
				else
					player:LearnSpell(12656)
					player:AdvanceSkill(202, 300)
					removePlayerMoney(player,500 )
					player:SendBroadcastMessage("你的工程技能已经满！")
					player:GossipComplete()
				end
			end
		end	
	end
	
	-----秒升草药--------
	if MenuGroup==24 then
		if not player:HasSpell( 2366 ) then
			player:SendBroadcastMessage("你没有学习草药，无法秒升。") 
			player:GossipComplete()
		else
			if getPlayerMoney(player)<500 then
				player:SendBroadcastMessage("需要|cFFFF0000500积分|r，你的积分不足！")
				player:GossipComplete()
			else
				if player:GetSkillValue( 182 )>=300 then
					player:SendBroadcastMessage("你的草药技能已经满了，无法秒升！")
					player:GossipComplete()
				else
					player:LearnSpell(11993)
					player:AdvanceSkill(182, 300)
					removePlayerMoney(player,500 )
					player:SendBroadcastMessage("你的草药技能已经满！")
					player:GossipComplete()
				end
			end
		end	
	end
	
	-----秒升炼金--------
	if MenuGroup==25 then
		if not player:HasSpell( 2259 ) then
			player:SendBroadcastMessage("你没有学习炼金，无法秒升。") 
			player:GossipComplete()
		else
			if getPlayerMoney(player)<500 then
				player:SendBroadcastMessage("需要|cFFFF0000500积分|r，你的积分不足！")
				player:GossipComplete()
			else
				if player:GetSkillValue( 171 )>=300 then
					player:SendBroadcastMessage("你的炼金技能已经满了，无法秒升！")
					player:GossipComplete()
				else
					player:LearnSpell(11611)
					player:AdvanceSkill(171, 300)
					removePlayerMoney(player,500 )
					player:SendBroadcastMessage("你的炼金技能已经满！")
					player:GossipComplete()
				end
			end
		end	
	end
	
	-----秒升裁缝--------
	if MenuGroup==26 then
		if not player:HasSpell( 3908 ) then
			player:SendBroadcastMessage("你没有学习裁缝，无法秒升。") 
			player:GossipComplete()
		else
			if getPlayerMoney(player)<500 then
				player:SendBroadcastMessage("需要|cFFFF0000500积分|r，你的积分不足！")
				player:GossipComplete()
			else
				if player:GetSkillValue( 197 )>=300 then
					player:SendBroadcastMessage("你的裁缝技能已经满了，无法秒升！")
					player:GossipComplete()
				else
					player:LearnSpell(12180)
					player:AdvanceSkill(197, 300)
					removePlayerMoney(player,500 )
					player:SendBroadcastMessage("你的裁缝技能已经满！")
					player:GossipComplete()
				end
			end
		end	
	end
	
	-----秒升附魔--------
	if MenuGroup==27 then
		if not player:HasSpell( 7411 ) then
			player:SendBroadcastMessage("你没有学习附魔，无法秒升。") 
			player:GossipComplete()
		else
			if getPlayerMoney(player)<500 then
				player:SendBroadcastMessage("需要|cFFFF0000500积分|r，你的积分不足！")
				player:GossipComplete()
			else
				if player:GetSkillValue( 333 )>=300 then
					player:SendBroadcastMessage("你的附魔技能已经满了，无法秒升！")
					player:GossipComplete()
				else
					player:LearnSpell(13920)
					player:AdvanceSkill(333, 300)
					removePlayerMoney(player,500 )
					player:SendBroadcastMessage("你的附魔技能已经满！")
					player:AddItem(16207,1)
					player:AddItem(11145,1)
					player:AddItem(11130,1)
					player:GossipComplete()
				end
			end
		end	
	end
	
	-----秒升制皮--------
	if MenuGroup==28 then
		if not player:HasSpell( 2108 ) then
			player:SendBroadcastMessage("你没有学习制皮，无法秒升。") 
			player:GossipComplete()
		else
			if getPlayerMoney(player)<500 then
				player:SendBroadcastMessage("需要|cFFFF0000500积分|r，你的积分不足！")
				player:GossipComplete()
			else
				if player:GetSkillValue( 165 )>=300 then
					player:SendBroadcastMessage("你的制皮技能已经满了，无法秒升！")
					player:GossipComplete()
				else
					player:LearnSpell(10662)
					player:AdvanceSkill(165, 300)
					removePlayerMoney(player,500 )
					player:SendBroadcastMessage("你的制皮技能已经满！")
					player:GossipComplete()
				end
			end
		end	
	end
	
	-----秒升剥皮--------
	if MenuGroup==29 then
		if not player:HasSpell( 8613 ) then
			player:SendBroadcastMessage("你没有学习剥皮，无法秒升。") 
			player:GossipComplete()
		else
			if getPlayerMoney(player)<500 then
				player:SendBroadcastMessage("需要|cFFFF0000500积分|r，你的积分不足！")
				player:GossipComplete()
			else
				if player:GetSkillValue( 393 )>=300 then
					player:SendBroadcastMessage("你的剥皮技能已经满了，无法秒升！")
					player:GossipComplete()
				else
					player:LearnSpell(10768)
					player:AdvanceSkill(393, 300)
					removePlayerMoney(player,500 )
					player:SendBroadcastMessage("你的剥皮技能已经满！")
					player:GossipComplete()
				end
			end
		end	
	end
	
	-----秒升急救--------
	if MenuGroup==210 then
		if not player:HasSpell( 3273 ) then
			player:SendBroadcastMessage("你没有学习急救，无法秒升。") 
			player:GossipComplete()
		else
			if getPlayerMoney(player)<300 then
				player:SendBroadcastMessage("需要|cFFFF0000300积分|r，你的积分不足！")
				player:GossipComplete()
			else
				if player:GetSkillValue( 129 )>=300 then
					player:SendBroadcastMessage("你的急救技能已经满了，无法秒升！")
					player:GossipComplete()
				else
					player:LearnSpell(10846)
					player:AdvanceSkill(129, 300)
					removePlayerMoney(player,300 )
					player:SendBroadcastMessage("你的急救技能已经满！")
					player:GossipComplete()
				end
			end
		end	
	end
	
	-----秒升烹饪--------
	if MenuGroup==211 then
		if not player:HasSpell( 2550 ) then
			player:SendBroadcastMessage("你没有学习烹饪，无法秒升。") 
			player:GossipComplete()
		else
			if getPlayerMoney(player)<300 then
				player:SendBroadcastMessage("需要|cFFFF0000300积分|r，你的积分不足！")
				player:GossipComplete()
			else
				if player:GetSkillValue( 185 )>=300 then
					player:SendBroadcastMessage("你的烹饪技能已经满了，无法秒升！")
					player:GossipComplete()
				else
					player:LearnSpell(18260)
					player:AdvanceSkill(185, 300)
					removePlayerMoney(player,300 )
					player:SendBroadcastMessage("你的烹饪技能已经满！")
					player:GossipComplete()
				end
			end
		end	
	end
	
	-----秒升钓鱼--------
	if MenuGroup==212 then
		if not player:HasSpell( 7620 ) then
			player:SendBroadcastMessage("你没有学习钓鱼，无法秒升。") 
			player:GossipComplete()
		else
			if getPlayerMoney(player)<300 then
				player:SendBroadcastMessage("需要|cFFFF0000300积分|r，你的积分不足！")
				player:GossipComplete()
			else
				if player:GetSkillValue( 356 )>=300 then
					player:SendBroadcastMessage("你的钓鱼技能已经满了，无法秒升！")
					player:GossipComplete()
				else
					player:LearnSpell(18248)
					player:AdvanceSkill(356, 300)
					removePlayerMoney(player,300 )
					player:SendBroadcastMessage("你的钓鱼技能已经满！")
					player:GossipComplete()
				end
			end
		end	
	end
	
	-----瞬飞服务一级菜单------
	if MenuGroup==7 then
		player:GossipMenuAddItem(4, "【限时特惠】开通1周瞬飞 |cFFFF000010积分|r", 70,0 )	
		player:GossipMenuAddItem(4, "开通1天瞬飞 |cFFFF000020积分|r", 71,0 )	
		player:GossipMenuAddItem(4, "开通7天瞬飞 |cFFFF0000100积分", 72,0 )	
		player:GossipMenuAddItem(4, "开通30天瞬飞|cFFFF0000300积分", 73,0 )
		player:GossipSendMenu(100, creature, menu_id) 
	end
	
	-----开通1周瞬飞-----
	if MenuGroup==70 then
		if getPlayerMoney(player)<10 then
			player:SendBroadcastMessage("需要|cFFFF000010积分|r，你的积分不足！")
			player:GossipComplete()
		else 
			removePlayerMoney(player,10 )
			addPlayerFightDay(player, 7) 
			player:SendBroadcastMessage(" 瞬飞服务过期时间：" .. getPlayerFightString(player) )
			player:GossipComplete()
		end		
	end
	
	-----开通1天瞬飞-----
	if MenuGroup==71 then
		if getPlayerMoney(player)<20 then
			player:SendBroadcastMessage("需要|cFFFF000020积分|r，你的积分不足！")
			player:GossipComplete()
		else 
			removePlayerMoney(player,20 )
			addPlayerFightDay(player, 1) 
			player:SendBroadcastMessage(" 瞬飞服务过期时间：" .. getPlayerFightString(player) )
			player:GossipComplete()
		end		
	end
	
	-----开通7天瞬飞-----
	if MenuGroup==72 then
		if getPlayerMoney(player)<100 then
			player:SendBroadcastMessage("需要|cFFFF0000100积分|r，你的积分不足！")
			player:GossipComplete()
		else 
			removePlayerMoney(player,100)
			addPlayerFightDay(player, 7) 
			player:SendBroadcastMessage(" 瞬飞服务过期时间：" .. getPlayerFightString(player) )
			player:GossipComplete()
		end		
	end
	
	-----开通30天瞬飞-----
	if MenuGroup==73 then
		if getPlayerMoney(player)<300 then
			player:SendBroadcastMessage("需要|cFFFF0000300积分|r，你的积分不足！")
			player:GossipComplete()
		else 
			removePlayerMoney(player,300 )
			addPlayerFightDay(player, 30) 
			player:SendBroadcastMessage(" 瞬飞服务过期时间：" .. getPlayerFightString(player) )
			player:GossipComplete()
		end		
	end
	
	
	
	
	-----陪玩服务一级菜单------
	if MenuGroup==8 then
		player:GossipMenuAddItem(4, "【限时特惠】开通1周陪玩服务 |cFFFF000010积分|r", 80,0 )	
		player:GossipMenuAddItem(4, "开通1天陪玩服务 |cFFFF000020积分|r", 81,0 )	
		player:GossipMenuAddItem(4, "开通7天陪玩服务 |cFFFF0000100积分", 82,0 )	
		player:GossipMenuAddItem(4, "开通30天陪玩服务|cFFFF0000300积分", 83,0 )
		player:GossipSendMenu(100, creature, menu_id) 
	end
	
	-----开通1周陪玩服务-----
	if MenuGroup==80 then
		if getPlayerMoney(player)<10 then
			player:SendBroadcastMessage("需要|cFFFF000010积分|r，你的积分不足！")
			player:GossipComplete()
		else 
			removePlayerMoney(player,10 )
			addPlayerPartyBotDay(player, 7) 
			player:SendBroadcastMessage(" 陪玩服务过期时间：" .. getPlayerPartyBotString(player) )
			player:GossipComplete()
		end		
	end
	
	-----开通1天陪玩服务-----
	if MenuGroup==81 then
		if getPlayerMoney(player)<20 then
			player:SendBroadcastMessage("需要|cFFFF000020积分|r，你的积分不足！")
			player:GossipComplete()
		else 
			removePlayerMoney(player,20 )
			addPlayerPartyBotDay(player, 1) 
			player:SendBroadcastMessage(" 陪玩服务过期时间：" .. getPlayerPartyBotString(player) )
			player:GossipComplete()
		end		
	end
	
	-----开通7天陪玩服务-----
	if MenuGroup==82 then
		if getPlayerMoney(player)<100 then
			player:SendBroadcastMessage("需要|cFFFF0000100积分|r，你的积分不足！")
			player:GossipComplete()
		else 
			removePlayerMoney(player,100)
			addPlayerPartyBotDay(player, 7) 
			player:SendBroadcastMessage(" 陪玩服务过期时间：" .. getPlayerPartyBotString(player) )
			player:GossipComplete()
		end		
	end
	
	-----开通30天陪玩服务-----
	if MenuGroup==83 then
		if getPlayerMoney(player)<300 then
			player:SendBroadcastMessage("需要|cFFFF0000300积分|r，你的积分不足！")
			player:GossipComplete()
		else 
			removePlayerMoney(player,300 )
			addPlayerPartyBotDay(player, 30) 
			player:SendBroadcastMessage(" 陪玩服务过期时间：" .. getPlayerPartyBotString(player) )
			player:GossipComplete()
		end		
	end
	
	
	
	-----辅助增益一级菜单------
	if MenuGroup==3 then
		player:GossipMenuAddItem(4, "世界祝福", 31,0 )	
		player:GossipMenuAddItem(4, "四大合剂", 32,0 )	
		--player:GossipMenuAddItem(4, "伊利丹之怒", 331,0 )	
		--player:GossipMenuAddItem(4, "天神下凡", 341,0 )	
		--player:GossipMenuAddItem(4, "狂乱", 361,0 )	
		--player:GossipMenuAddItem(4, "格拉库的肉松蛋糕", 351,0 )	
		
		--player:GossipMenuAddItem(4, "强力药剂", 33,0 )	
		--player:GossipMenuAddItem(4, "食物增益", 54,0 )	
		player:GossipMenuAddItem(7, "返回主菜单", 0,0 )
		player:GossipSendMenu(100, creature, menu_id) 
	end
	
	
	
	-----伊利丹之怒 >>>功能实现-----
	if MenuGroup == 331 then
		player:GossipMenuAddItem(4, "伊利丹之怒 |cFFFF00004000积分|r", 3311,0 )	
	 --被伊利丹的愤怒吞噬：对恶魔的攻击强度提高1400点。爆击几率提高20%。近战攻击速度提高30%。
	    --player:GossipMenuAddItem(4, "对恶魔的攻击强度提高1400点。爆击几率提高20%。近战攻击速度提高30%|r", 3311,0 )	
		player:GossipSendMenu(100, creature, menu_id) 
	end
	-----伊利丹之怒-----
	if MenuGroup==3311 then
		if  player:HasSpell( 22988 ) then
			player:SendBroadcastMessage("你已经拥有伊利丹之怒。") 
			player:GossipComplete()
		else
			if getPlayerMoney(player)<4000 then
				player:SendBroadcastMessage("需要|cFFFF00004000积分|r，你的积分不足！")
				player:GossipComplete()
			else 
				player:LearnSpell(22988) 
				removePlayerMoney(player,4000 )
				player:SendBroadcastMessage("你的伊利丹之怒技能已经学习！")
				player:GossipComplete()
			end
		end	
	end
	
		-----狂乱 >>>功能实现-----
	if MenuGroup == 361 then
		player:GossipMenuAddItem(4, "狂乱 |cFFFF00005000积分|r", 3611,0 )	
	 --使施法者的攻击速度提高40%并且造成的物理伤害提高25%
	--player:GossipMenuAddItem(4, "使施法者的攻击速度提高40%并且造成的物理伤害提高25%|r", 3611,0 )	
	 player:GossipSendMenu(100, creature, menu_id) 
		player:GossipSendMenu(100, creature, menu_id) 
	end
	-----狂乱-----
	if MenuGroup==3611 then
		if  player:HasSpell( 28131 ) then
			player:SendBroadcastMessage("你已经拥有狂乱。") 
			player:GossipComplete()
		else
			if getPlayerMoney(player)<5000 then
				player:SendBroadcastMessage("需要|cFFFF00005000积分|r，你的积分不足！")
				player:GossipComplete()
			else 
				player:LearnSpell(28131) 
				removePlayerMoney(player,5000 )
				player:SendBroadcastMessage("你的狂乱技能已经学习！")
				player:GossipComplete()
			end
		end	
	end
	--狂乱
	 
	
	-----天神下凡 >>>功能实现-----
	-----天神下凡
--UPDATE `mangos`.`spell_template` SET ` `durationIndex` = 21  WHERE `entry` = 19135 AND `build` = 4222;
--UPDATE `mangos`.`spell_template` SET  `durationIndex` = 21   WHERE `entry` = 19135 AND `build` = 5086;
	if MenuGroup == 341 then
		player:GossipMenuAddItem(4, "天神下凡 |cFFFF00005000积分|r", 3411,0 )	
		--player:GossipMenuAddItem(4, "使施法者对敌人造成的物理伤害提高50%，护甲值提高50% |r", 3411,0 )	
	 --使施法者对敌人造成的物理伤害提高50%，护甲值提高50%，持续15 sec。
		player:GossipSendMenu(100, creature, menu_id) 
	end
	-----天神下凡-----
	if MenuGroup==3411 then
		if  player:HasSpell( 19135 ) then
			player:SendBroadcastMessage("你已经拥有天神下凡。") 
			player:GossipComplete()
		else
			if getPlayerMoney(player)<5000 then
				player:SendBroadcastMessage("需要|cFFFF00005000积分|r，你的积分不足！")
				player:GossipComplete()
			else 
				player:LearnSpell(19135) 
				removePlayerMoney(player,5000 )
				player:SendBroadcastMessage("你天神下凡技能已学习！！")
				player:GossipComplete()
			end
		end	
	end
	
	-----格拉库的肉松蛋糕 >>>功能实现-----
	if MenuGroup == 351 then
		player:GossipMenuAddItem(4, "格拉库的肉松蛋糕 |cFFFF0000300积分|r", 3511,0 )	
	 
		player:GossipSendMenu(100, creature, menu_id) 
	end
	-----格拉库的肉松蛋糕-----
	if MenuGroup==3511 then
		if  player:HasSpell( 25990 ) then
			player:SendBroadcastMessage("你已经拥有格拉库的肉松蛋糕。") 
			player:GossipComplete()
		else
			if getPlayerMoney(player)<300 then
				player:SendBroadcastMessage("需要|cFFFF0000300积分|r，你的积分不足！")
				player:GossipComplete()
			else 
				player:LearnSpell(25990) 
				removePlayerMoney(player,300 )
				player:SendBroadcastMessage("你的格拉库的肉松蛋糕已学习！")
				player:GossipComplete()
			end
		end	
	end
		
	
	
	----------世界祝福子菜单----------
	if MenuGroup==31 then
		player:GossipMenuAddItem(4, "屠龙者的咆哮", 311,0 )	
		player:GossipMenuAddItem(4, "赞达拉之魂", 312,0 )	
		player:GossipMenuAddItem(4, "酋长的祝福", 313,0 )	
		player:GossipMenuAddItem(4, "凤歌夜曲　", 314,0 )	
		player:GossipMenuAddItem(4, "摩尔达的勇气", 315,0 )	
		player:GossipMenuAddItem(4, "芬古斯的狂暴", 316,0 )	
		player:GossipMenuAddItem(4, "斯里基克的机智", 317,0 )	
		player:GossipMenuAddItem(7, "返回主菜单", 0,0 )
		player:GossipSendMenu(100, creature, menu_id) 
	end
	
	-----屠龙者的咆哮>>>功能实现-----
	if MenuGroup == 311 then
		player:GossipMenuAddItem(4, "屠龙者咆哮2小时 |cFFFF00005积分|r", 3111,0 )	
		player:GossipMenuAddItem(4, "屠龙者咆哮1天　 |cFFFF000030积分|r", 3112,0 )	
		player:GossipMenuAddItem(4, "屠龙者咆哮7天　 |cFFFF0000200积分|r", 3113,0 )	
		
		player:GossipSendMenu(100, creature, menu_id) 
	end
	-----屠龙 2小时-----
	if MenuGroup == 3111 then
		--if player:GetAura( 22888 )==nil then
			if getPlayerMoney(player)<5 then
				player:SendBroadcastMessage("需要|cFFFF00005积分|r，你的积分不足！")
				player:GossipComplete()
			else
				player:AddAura( 22888,player )					
				yue = removePlayerMoney(player,5)
				player:SendBroadcastMessage("恭喜你获得了屠龙者的咆哮2小时！")
				player:GossipComplete()
			end
		--else
		--	player:SendBroadcastMessage("你已经拥有该祝福，无法再次购买！")
		--	player:GossipComplete()
		--end
	end	
	-----屠龙 1天-----
	if MenuGroup == 3112 then
		--if player:GetAura( 22888 )==nil then
			if getPlayerMoney(player)<30 then
				player:SendBroadcastMessage("需要|cFFFF000030积分|r，你的积分不足！")
				player:GossipComplete()
			else
				player:AddAura( 22888,player )	
				aura = player:GetAura( 22888 )
				aura:SetDuration( 86400000 )				
				removePlayerMoney(player,30)
				player:SendBroadcastMessage("恭喜你获得了屠龙者的咆哮1天！")
				player:GossipComplete()
			end
		--else
		--	player:SendBroadcastMessage("你已经拥有该祝福，无法再次购买！")
		--	player:GossipComplete()
		--end
	end	
	-----屠龙 7天-----	
	if MenuGroup == 3113 then
		--if player:GetAura( 22888 )==nil then
			if getPlayerMoney(player)<200 then
				player:SendBroadcastMessage("需要|cFFFF0000200积分|r，你的积分不足！")
				player:GossipComplete()
			else
				player:AddAura( 22888,player )	
				aura = player:GetAura( 22888 )
				aura:SetDuration( 604800000 )				
				removePlayerMoney(player,200)
				player:SendBroadcastMessage("恭喜你获得了屠龙者的咆哮7天！")
				player:GossipComplete()
			end
		--else
		--	player:SendBroadcastMessage("你已经拥有该祝福，无法再次购买！")
		--	player:GossipComplete()
		--end
	end		
	
	-----赞达拉之魂>>>功能实现-----
	if MenuGroup == 312 then
		player:GossipMenuAddItem(4, "赞达拉之魂2小时 |cFFFF00005积分|r", 3121,0 )	
		player:GossipMenuAddItem(4, "赞达拉之魂1天　 |cFFFF000030积分|r", 3122,0 )	
		player:GossipMenuAddItem(4, "赞达拉之魂7天　 |cFFFF0000200积分|r", 3123,0 )	
		
		player:GossipSendMenu(100, creature, menu_id) 
	end
	-----赞达拉 2小时-----
	if MenuGroup == 3121 then
		--if player:GetAura( 24425 )==nil then
			if getPlayerMoney(player)<5 then
				player:SendBroadcastMessage("需要|cFFFF00005积分|r，你的积分不足！")
				player:GossipComplete()
			else
				player:AddAura( 24425,player )
				removePlayerMoney(player,5 )
				player:SendBroadcastMessage("恭喜你获得了赞达拉之魂2小时！")
				player:GossipComplete()
			end
		--else
		--	player:SendBroadcastMessage("你已经拥有该祝福，无法再次购买！")
		--	player:GossipComplete()
		--end
	end	
	-----赞达拉 1天-----
	if MenuGroup == 3122 then
		--if player:GetAura( 24425 )==nil then
			if getPlayerMoney(player)<30 then
				player:SendBroadcastMessage("需要|cFFFF000030积分|r，你的积分不足！")
				player:GossipComplete()
			else
				player:AddAura( 24425,player )
				aura = player:GetAura( 24425 )
				aura:SetDuration( 86400000 )
				removePlayerMoney(player,30 )
				player:SendBroadcastMessage("恭喜你获得了赞达拉之魂1天！")
				player:GossipComplete()
			end
		--else
		--	player:SendBroadcastMessage("你已经拥有该祝福，无法再次购买！")
		--	player:GossipComplete()
		--end
	end	
	-----赞达拉 7天-----
	if MenuGroup == 3123 then
		--if player:GetAura( 24425 )==nil then
			if getPlayerMoney(player)<200 then
				player:SendBroadcastMessage("需要|cFFFF0000200积分|r，你的积分不足！")
				player:GossipComplete()
			else
				player:AddAura( 24425,player )
				aura = player:GetAura( 24425 )
				aura:SetDuration( 604800000 )	
				removePlayerMoney(player,200 )
				player:SendBroadcastMessage("恭喜你获得了赞达拉之魂7天！")
				player:GossipComplete()
			end
		--else
		--	player:SendBroadcastMessage("你已经拥有该祝福，无法再次购买！")
		--	player:GossipComplete()
		--end
	end	
	
	
	-----酋长的祝福>>>功能实现-----
	if MenuGroup == 313 then
		player:GossipMenuAddItem(4, "酋长的祝福2小时 |cFFFF00005积分|r", 3131,0 )	
		player:GossipMenuAddItem(4, "酋长的祝福1天　 |cFFFF000030积分|r", 3132,0 )	
		player:GossipMenuAddItem(4, "酋长的祝福7天　 |cFFFF0000200积分|r", 3133,0 )	
		
		player:GossipSendMenu(100, creature, menu_id) 
	end
	-----酋长的祝福 2小时-----
	if MenuGroup == 3131 then
		--if player:GetAura( 16609 )==nil then
			if getPlayerMoney(player)<5 then
				player:SendBroadcastMessage("需要|cFFFF00005积分|r，你的积分不足！")
				player:GossipComplete()
			else
				player:AddAura( 16609,player )
				removePlayerMoney(player,5 )
				player:SendBroadcastMessage("恭喜你获得了酋长的祝福2小时！")
				player:GossipComplete()
			end
		--else
		--	player:SendBroadcastMessage("你已经拥有该祝福，无法再次购买！")
		--	player:GossipComplete()
		--end
	end	
	-----酋长的祝福 1天-----
	if MenuGroup == 3132 then
		--if player:GetAura( 16609 )==nil then
			if getPlayerMoney(player)<30 then
				player:SendBroadcastMessage("需要|cFFFF000030积分|r，你的积分不足！")
				player:GossipComplete()
			else
				player:AddAura( 16609,player )
				aura = player:GetAura( 16609 )
				aura:SetDuration( 86400000 )
				removePlayerMoney(player,30 )
				player:SendBroadcastMessage("恭喜你获得了酋长的祝福1天！")
				player:GossipComplete()
			end
		--else
		--	player:SendBroadcastMessage("你已经拥有该祝福，无法再次购买！")
		--	player:GossipComplete()
		--end
	end	
	-----酋长的祝福 7天-----
	if MenuGroup == 3133 then
		--if player:GetAura( 16609 )==nil then
			if getPlayerMoney(player)<200 then
				player:SendBroadcastMessage("需要|cFFFF0000200积分|r，你的积分不足！")
				player:GossipComplete()
			else
				player:AddAura( 16609,player )
				aura = player:GetAura( 16609 )
				aura:SetDuration( 604800000 )	
				removePlayerMoney(player,200 )
				player:SendBroadcastMessage("恭喜你获得了酋长的祝福7天！")
				player:GossipComplete()
			end
		--else
		--	player:SendBroadcastMessage("你已经拥有该祝福，无法再次购买！")
		--	player:GossipComplete()
		--end
	end	
	
	-----风歌夜曲>>>功能实现-----
	if MenuGroup == 314 then
		player:GossipMenuAddItem(4, "风歌夜曲2小时 |cFFFF00005积分|r", 3141,0 )	
		player:GossipMenuAddItem(4, "风歌夜曲1天　 |cFFFF000030积分|r", 3142,0 )	
		player:GossipMenuAddItem(4, "风歌夜曲7天　 |cFFFF0000200积分|r", 3143,0 )	
		
		player:GossipSendMenu(100, creature, menu_id) 
	end
	-----风歌夜曲 2小时-----
	if MenuGroup == 3141 then
		--if player:GetAura( 15366 )==nil then
			if getPlayerMoney(player)<5 then
				player:SendBroadcastMessage("需要|cFFFF00005积分|r，你的积分不足！")
				player:GossipComplete()
			else
				player:AddAura( 15366,player )
				removePlayerMoney(player,5 )
				player:SendBroadcastMessage("恭喜你获得了风歌夜曲2小时！")
				player:GossipComplete()
			end
		--else
		--	player:SendBroadcastMessage("你已经拥有该祝福，无法再次购买！")
		--	player:GossipComplete()
		--end
	end	
	-----风歌夜曲 1天-----
	if MenuGroup == 3142 then
		--if player:GetAura( 15366 )==nil then
			if getPlayerMoney(player)<30 then
				player:SendBroadcastMessage("需要|cFFFF000030积分|r，你的积分不足！")
				player:GossipComplete()
			else
				player:AddAura( 15366,player )
				aura = player:GetAura( 15366 )
				aura:SetDuration( 86400000 )
				removePlayerMoney(player,30 )
				player:SendBroadcastMessage("恭喜你获得了风歌夜曲1天！")
				player:GossipComplete()
			end
		--else
		--	player:SendBroadcastMessage("你已经拥有该祝福，无法再次购买！")
		--	player:GossipComplete()
		--end
	end	
	-----风歌夜曲 7天-----
	if MenuGroup == 3143 then
		--if player:GetAura( 15366 )==nil then
			if getPlayerMoney(player)<200 then
				player:SendBroadcastMessage("需要|cFFFF0000200积分|r，你的积分不足！")
				player:GossipComplete()
			else
				player:AddAura( 15366,player )
				aura = player:GetAura( 15366 )
				aura:SetDuration( 604800000 )	
				removePlayerMoney(player,200 )
				player:SendBroadcastMessage("恭喜你获得了风歌夜曲7天！")
				player:GossipComplete()
			end
		--else
		--	player:SendBroadcastMessage("你已经拥有该祝福，无法再次购买！")
		--	player:GossipComplete()
		--end
	end	
	
	-----摩尔达的勇气>>>功能实现-----
	if MenuGroup == 315 then
		player:GossipMenuAddItem(4, "摩尔达的勇气2小时 |cFFFF00003积分|r", 3151,0 )	
		player:GossipMenuAddItem(4, "摩尔达的勇气1天　 |cFFFF000025积分|r", 3152,0 )	
		player:GossipMenuAddItem(4, "摩尔达的勇气7天　 |cFFFF0000150积分|r", 3153,0 )	
		
		player:GossipSendMenu(100, creature, menu_id) 
	end
	-----摩尔达的勇气 2小时-----
	if MenuGroup == 3151 then
		--if player:GetAura( 22818 )==nil then
			if getPlayerMoney(player)<3 then
				player:SendBroadcastMessage("需要|cFFFF00003积分|r，你的积分不足！")
				player:GossipComplete()
			else
				player:AddAura( 22818,player )
				removePlayerMoney(player,3 )
				player:SendBroadcastMessage("恭喜你获得了摩尔达的勇气2小时！")
				player:GossipComplete()
			end
		--else
		--	player:SendBroadcastMessage("你已经拥有该祝福，无法再次购买！")
		--	player:GossipComplete()
		--end
	end	
	-----摩尔达的勇气 1天-----
	if MenuGroup == 3152 then
		--if player:GetAura( 22818 )==nil then
			if getPlayerMoney(player)<25 then
				player:SendBroadcastMessage("需要|cFFFF000025积分|r，你的积分不足！")
				player:GossipComplete()
			else
				player:AddAura( 22818,player )
				aura = player:GetAura( 22818 )
				aura:SetDuration( 86400000 )
				removePlayerMoney(player,25 )
				player:SendBroadcastMessage("恭喜你获得了摩尔达的勇气1天！")
				player:GossipComplete()
			end
		--else
		--	player:SendBroadcastMessage("你已经拥有该祝福，无法再次购买！")
		--	player:GossipComplete()
		--end
	end	
	-----摩尔达的勇气 7天-----
	if MenuGroup == 3153 then
		--if player:GetAura( 22818 )==nil then
			if getPlayerMoney(player)<150 then
				player:SendBroadcastMessage("需要|cFFFF0000150积分|r，你的积分不足！")
				player:GossipComplete()
			else
				player:AddAura( 22818,player )
				aura = player:GetAura( 22818 )
				aura:SetDuration( 604800000 )	
				removePlayerMoney(player,150 )
				player:SendBroadcastMessage("恭喜你获得了摩尔达的勇气7天！")
				player:GossipComplete()
			end
		--else
		--	player:SendBroadcastMessage("你已经拥有该祝福，无法再次购买！")
			player:GossipComplete()
		--end
	end	
	
	-----芬古斯的狂暴>>>功能实现-----
	if MenuGroup == 316 then
		player:GossipMenuAddItem(4, "芬古斯的狂暴2小时 |cFFFF00003积分|r", 3161,0 )	
		player:GossipMenuAddItem(4, "芬古斯的狂暴1天　 |cFFFF000025积分|r", 3162,0 )	
		player:GossipMenuAddItem(4, "芬古斯的狂暴7天　 |cFFFF0000150积分|r", 3163,0 )	
		
		player:GossipSendMenu(100, creature, menu_id) 
	end
	-----芬古斯的狂暴 2小时-----
	if MenuGroup == 3161 then
		--if player:GetAura( 22817 )==nil then
			if getPlayerMoney(player)<3 then
				player:SendBroadcastMessage("需要|cFFFF00003积分|r，你的积分不足！")
				player:GossipComplete()
			else
				player:AddAura( 22817,player )
				removePlayerMoney(player,3 )
				player:SendBroadcastMessage("恭喜你获得了芬古斯的狂暴2小时！")
				player:GossipComplete()
			end
		--else
		--	player:SendBroadcastMessage("你已经拥有该祝福，无法再次购买！")
		--	player:GossipComplete()
		--end
	end	
	-----芬古斯的狂暴 1天-----
	if MenuGroup == 3162 then
		--if player:GetAura( 22817 )==nil then
			if getPlayerMoney(player)<25 then
				player:SendBroadcastMessage("需要|cFFFF000025积分|r，你的积分不足！")
				player:GossipComplete()
			else
				player:AddAura( 22817,player )
				aura = player:GetAura( 22817 )
				aura:SetDuration( 86400000 )
				removePlayerMoney(player,25 )
				player:SendBroadcastMessage("恭喜你获得了芬古斯的狂暴1天！")
				player:GossipComplete()
			end
		--else
		--	player:SendBroadcastMessage("你已经拥有该祝福，无法再次购买！")
		--	player:GossipComplete()
		--end
	end	
	-----芬古斯的狂暴 7天-----
	if MenuGroup == 3163 then
		--if player:GetAura( 22817 )==nil then
			if getPlayerMoney(player)<150 then
				player:SendBroadcastMessage("需要|cFFFF0000150积分|r，你的积分不足！")
				player:GossipComplete()
			else
				player:AddAura( 22817,player )
				aura = player:GetAura( 22817 )
				aura:SetDuration( 604800000 )	
				removePlayerMoney(player,150 )
				player:SendBroadcastMessage("恭喜你获得了芬古斯的狂暴7天！")
				player:GossipComplete()
			end
		--else
		--	player:SendBroadcastMessage("你已经拥有该祝福，无法再次购买！")
		--	player:GossipComplete()
		--end
	end	
	
	-----斯里基克的机智>>>功能实现-----
	if MenuGroup == 317 then
		player:GossipMenuAddItem(4, "斯里基克的机智2小时 |cFFFF00003积分|r", 3171,0 )	
		player:GossipMenuAddItem(4, "斯里基克的机智1天　 |cFFFF000025积分|r", 3172,0 )	
		player:GossipMenuAddItem(4, "斯里基克的机智7天　 |cFFFF0000150积分|r", 3173,0 )	
		
		player:GossipSendMenu(100, creature, menu_id) 
	end
	-----斯里基克的机智 2小时-----
	if MenuGroup == 3171 then
		--if player:GetAura( 22820 )==nil then
			if getPlayerMoney(player)<3 then
				player:SendBroadcastMessage("需要|cFFFF00003积分|r，你的积分不足！")
				player:GossipComplete()
			else
				player:AddAura( 22820,player )
				removePlayerMoney(player,3 )
				player:SendBroadcastMessage("恭喜你获得了斯里基克的机智2小时！")
				player:GossipComplete()
			end
		--else
		--	player:SendBroadcastMessage("你已经拥有该祝福，无法再次购买！")
		--	player:GossipComplete()
		--end
	end	
	-----斯里基克的机智 1天-----
	if MenuGroup == 3172 then
		--if player:GetAura( 22820 )==nil then
			if getPlayerMoney(player)<25 then
				player:SendBroadcastMessage("需要|cFFFF000025积分|r，你的积分不足！")
				player:GossipComplete()
			else
				player:AddAura( 22820,player )
				aura = player:GetAura( 22820 )
				aura:SetDuration( 86400000 )
				removePlayerMoney(player,25 )
				player:SendBroadcastMessage("恭喜你获得了斯里基克的机智1天！")
				player:GossipComplete()
			end
		--else
		--	player:SendBroadcastMessage("你已经拥有该祝福，无法再次购买！")
		--	player:GossipComplete()
		--end
	end	
	-----斯里基克的机智 7天-----
	if MenuGroup == 3173 then
		--if player:GetAura( 22820 )==nil then
			if getPlayerMoney(player)<150 then
				player:SendBroadcastMessage("需要|cFFFF0000150积分|r，你的积分不足！")
				player:GossipComplete()
			else
				player:AddAura( 22820,player )
				aura = player:GetAura( 22820 )
				aura:SetDuration( 604800000 )	
				removePlayerMoney(player,150 )
				player:SendBroadcastMessage("恭喜你获得了斯里基克的机智7天！")
				player:GossipComplete()
			end
		--else
		--	player:SendBroadcastMessage("你已经拥有该祝福，无法再次购买！")
		--	player:GossipComplete()
		--end
	end	
	
	-----四大合剂子菜单------
	if MenuGroup==32 then
		player:GossipMenuAddItem(1, "泰坦合剂", 321,0 )	
		player:GossipMenuAddItem(1, "超级能量合剂", 322,0 )	
		player:GossipMenuAddItem(1, "精炼智慧合剂", 323,0 )	
		player:GossipMenuAddItem(1, "多重抗性合剂", 324,0 )	
		
		player:GossipSendMenu(100, creature, menu_id) 
	end
	-----泰坦合剂>>>功能实现-----
	if MenuGroup==321 then
		player:GossipMenuAddItem(1, "泰坦合剂2小时 |cFFFF00003积分|r", 3211,0 )	
		player:GossipMenuAddItem(1, "泰坦合剂1天　 |cFFFF000025积分|r", 3212,0 )	
		player:GossipMenuAddItem(1, "泰坦合剂7天　 |cFFFF0000150积分|r", 3213,0 )	
		
		player:GossipSendMenu(100, creature, menu_id) 
	end
	
	-----泰坦合剂 2小时-----
	if MenuGroup==3211 then
		--if player:GetAura( 17626 )==nil then
			if getPlayerMoney(player)<3 then
				player:SendBroadcastMessage("该增益需要|cFFFF00003积分|r，你的积分不足！")
				player:GossipComplete()
			else
				player:AddAura( 17626,player )
				removePlayerMoney(player,3 )
				player:SendBroadcastMessage("恭喜你获得泰坦合剂增益2小时！")
				player:GossipComplete()
			end
		--else
		--	player:SendBroadcastMessage("你已经拥有该增益，无法再次购买！")
		--	player:GossipComplete()
		--end
	end
	
	-----泰坦合剂 1天-----
	if MenuGroup==3212 then
		--if player:GetAura( 17626 )==nil then
			if getPlayerMoney(player)<25 then
				player:SendBroadcastMessage("该物品需要|cFFFF000025积分|r，你的积分不足！")
				player:GossipComplete()
			else
				player:AddAura( 17626,player )
				aura = player:GetAura( 17626 )
				aura:SetDuration( 86400000 )
				removePlayerMoney(player,25 )
				player:SendBroadcastMessage("恭喜你获得泰坦合剂增益1天！")
				player:GossipComplete()
			end
		--else
		--	player:SendBroadcastMessage("你已经拥有该增益，无法再次购买！")
		--	player:GossipComplete()
		--end
	end
	
	-----泰坦合剂 7天-----
	if MenuGroup==3213 then
		--if player:GetAura( 17626 )==nil then
			if getPlayerMoney(player)<150 then
				player:SendBroadcastMessage("该物品需要|cFFFF0000150积分|r，你的积分不足！")
				player:GossipComplete()
			else
				player:AddAura( 17626,player )
				aura = player:GetAura( 17626 )
				aura:SetDuration( 604800000 )
				removePlayerMoney(player,150 )
				player:SendBroadcastMessage("恭喜你获得泰坦合剂增益7天！")
				player:GossipComplete()
			end
		--else
		--	player:SendBroadcastMessage("你已经拥有该增益，无法再次购买！")
		--	player:GossipComplete()
		--end
	end
	
	-----超级能量>>>功能实现-----
	if MenuGroup==322 then
		player:GossipMenuAddItem(1, "超级能量合剂2小时 |cFFFF00003积分|r", 3221,0 )	
		player:GossipMenuAddItem(1, "超级能量合剂1天　 |cFFFF000025积分|r", 3222,0 )	
		player:GossipMenuAddItem(1, "超级能量合剂7天　 |cFFFF0000150积分|r", 3223,0 )	
		
		player:GossipSendMenu(100, creature, menu_id) 
	end
	
	-----超级能量 2小时-----
	if MenuGroup==3221 then
		--if player:GetAura( 17628 )==nil then
			if getPlayerMoney(player)<3 then
				player:SendBroadcastMessage("该增益需要|cFFFF00003积分|r，你的积分不足！")
				player:GossipComplete()
			else
				player:AddAura( 17628,player )
				removePlayerMoney(player,3 )
				player:SendBroadcastMessage("恭喜你获得超级能量合剂增益2小时！")
				player:GossipComplete()
			end
		--else
		--	player:SendBroadcastMessage("你已经拥有该增益，无法再次购买！")
		--	player:GossipComplete()
	--	end
	end
	
	-----超级能量 1天-----
	if MenuGroup==3222 then
		--if player:GetAura( 17628 )==nil then
			if getPlayerMoney(player)<25 then
				player:SendBroadcastMessage("该物品需要|cFFFF000025积分|r，你的积分不足！")
				player:GossipComplete()
			else
				player:AddAura( 17628,player )
				aura = player:GetAura( 17628 )
				aura:SetDuration( 86400000 )
				removePlayerMoney(player,25 )
				player:SendBroadcastMessage("恭喜你获得超级能量合剂增益1天！")
				player:GossipComplete()
			end
		--else
			--player:SendBroadcastMessage("你已经拥有该增益，无法再次购买！")
		--	player:GossipComplete()
		--end
	end
	
	-----超级能量 7天-----
	if MenuGroup==3223 then
		--if player:GetAura( 17628 )==nil then
			if getPlayerMoney(player)<150 then
				player:SendBroadcastMessage("该物品需要|cFFFF0000150积分|r，你的积分不足！")
				player:GossipComplete()
			else
				player:AddAura( 17628,player )
				aura = player:GetAura( 17628 )
				aura:SetDuration( 604800000 )
				removePlayerMoney(player,150 )
				player:SendBroadcastMessage("恭喜你获得超级能量合剂增益7天！")
				player:GossipComplete()
			end
		--else
		--	player:SendBroadcastMessage("你已经拥有该增益，无法再次购买！")
		--	player:GossipComplete()
		--end
	end
	
	-----精炼智慧>>>功能实现-----
	if MenuGroup==323 then
		player:GossipMenuAddItem(1, "精炼智慧合剂2小时 |cFFFF00003积分|r", 3231,0 )	
		player:GossipMenuAddItem(1, "精炼智慧合剂1天　 |cFFFF000025积分|r", 3232,0 )	
		player:GossipMenuAddItem(1, "精炼智慧合剂7天　 |cFFFF0000150积分|r", 3233,0 )	
		
		player:GossipSendMenu(100, creature, menu_id) 
	end
	
	-----精炼智慧 2小时-----
	if MenuGroup==3231 then
		--if player:GetAura( 17627 )==nil then
			if getPlayerMoney(player)<3 then
				player:SendBroadcastMessage("该增益需要|cFFFF00003积分|r，你的积分不足！")
				player:GossipComplete()
			else
				player:AddAura( 17627,player )
				removePlayerMoney(player,3 )
				player:SendBroadcastMessage("恭喜你获得精炼智慧合剂增益2小时！")
				player:GossipComplete()
			end
		--else
		--	player:SendBroadcastMessage("你已经拥有该增益，无法再次购买！")
		--	player:GossipComplete()
		--end
	end
	
	-----精炼智慧 1天-----
	if MenuGroup==3232 then
		--if player:GetAura( 17627 )==nil then
			if getPlayerMoney(player)<25 then
				player:SendBroadcastMessage("该物品需要|cFFFF000025积分|r，你的积分不足！")
				player:GossipComplete()
			else
				player:AddAura( 17627,player )
				aura = player:GetAura( 17627 )
				aura:SetDuration( 86400000 )
				removePlayerMoney(player,25 )
				player:SendBroadcastMessage("恭喜你获得精炼智慧合剂增益1天！")
				player:GossipComplete()
			end
		--else
		--	player:SendBroadcastMessage("你已经拥有该增益，无法再次购买！")
		--	player:GossipComplete()
		--end
	end
	
	-----精炼智慧 7天-----
	if MenuGroup==3233 then
		--if player:GetAura( 17627 )==nil then
			if getPlayerMoney(player)<150 then
				player:SendBroadcastMessage("该物品需要|cFFFF0000150积分|r，你的积分不足！")
				player:GossipComplete()
			else
				player:AddAura( 17627,player )
				aura = player:GetAura( 17627 )
				aura:SetDuration( 604800000 )
				removePlayerMoney(player,150 )
				player:SendBroadcastMessage("恭喜你获得精炼智慧合剂增益7天！")
				player:GossipComplete()
			end
		--else
		--	player:SendBroadcastMessage("你已经拥有该增益，无法再次购买！")
		--	player:GossipComplete()
		--end
	end

	-----多重抗性>>>功能实现-----
	if MenuGroup==324 then
		player:GossipMenuAddItem(1, "多重抗性合剂2小时 |cFFFF00003积分|r", 3241,0 )	
		player:GossipMenuAddItem(1, "多重抗性合剂1天　 |cFFFF000025积分|r", 3242,0 )	
		player:GossipMenuAddItem(1, "多重抗性合剂7天　 |cFFFF0000150积分|r", 3243,0 )	
		
		player:GossipSendMenu(100, creature, menu_id) 
	end
	
	-----多重抗性 2小时-----
	if MenuGroup==3241 then
		--if player:GetAura( 17629 )==nil then
			if getPlayerMoney(player)<3 then
				player:SendBroadcastMessage("该增益需要|cFFFF00003积分|r，你的积分不足！")
				player:GossipComplete()
			else
				player:AddAura( 17629,player )
				removePlayerMoney(player,3 )
				player:SendBroadcastMessage("恭喜你获得多重抗性合剂增益2小时！")
				player:GossipComplete()
			end
		--else
		--	player:SendBroadcastMessage("你已经拥有该增益，无法再次购买！")
		--	player:GossipComplete()
		--end
	end
	
	-----多重抗性 1天-----
	if MenuGroup==3242 then
		--if player:GetAura( 17629 )==nil then
			if getPlayerMoney(player)<25 then
				player:SendBroadcastMessage("该物品需要|cFFFF000025积分|r，你的积分不足！")
				player:GossipComplete()
			else
				player:AddAura( 17629,player )
				aura = player:GetAura( 17629 )
				aura:SetDuration( 86400000 )
				removePlayerMoney(player,25 )
				player:SendBroadcastMessage("恭喜你获得多重抗性合剂增益1天！")
				player:GossipComplete()
			end
		--else
		--	player:SendBroadcastMessage("你已经拥有该增益，无法再次购买！")
		--	player:GossipComplete()
	--	end
	end
	
	-----多重抗性 7天-----
	if MenuGroup==3243 then
		--if player:GetAura( 17629 )==nil then
			if getPlayerMoney(player)<150 then
				player:SendBroadcastMessage("该物品需要|cFFFF0000150积分|r，你的积分不足！")
				player:GossipComplete()
			else
				player:AddAura( 17629,player )
				aura = player:GetAura( 17629 )
				aura:SetDuration( 604800000 )
				removePlayerMoney(player,150 )
				player:SendBroadcastMessage("恭喜你获得多重抗性合剂增益7天！")
				player:GossipComplete()
			end
	--	else
		--	player:SendBroadcastMessage("你已经拥有该增益，无法再次购买！")
		--	player:GossipComplete()
		--end
	end

	-----稀有坐骑------
	if MenuGroup==4 then
		player:GossipMenuAddItem(1, "死亡军马缰绳　 |cFFFF00001500积分|r", 41,0 )	
		player:GossipMenuAddItem(1, "迅捷祖利安猛虎 |cFFFF00001500积分|r", 42,0 )	
		player:GossipMenuAddItem(1, "拉扎什迅猛龙　 |cFFFF00001500积分|r", 43,0 )	
		player:GossipMenuAddItem(1, "黑色其拉作坦克 |cFFFF00002000积分|r", 44,0 )	
		
		player:GossipSendMenu(100, creature, menu_id) 
	end
	
	-----DK马-----
	if MenuGroup==41 then
		if getPlayerMoney(player)<1500 or player:GetItemCount( 13335 )>0 then
			player:SendBroadcastMessage("你的积分不足|cFFFF0000100|r或已经拥有了该坐骑！")
			player:GossipComplete()
		else
			if not player:HasSpell( 33392 ) then
				player:LearnSpell(33392) -----中级骑术
			end	
			player:AddItem( 13335 )
			removePlayerMoney(player,1500 )
			player:SendBroadcastMessage("恭喜你获得稀有坐骑！")
			player:GossipComplete()
		end
	end
	
	-----ZG老虎-----
	if MenuGroup==42 then
		if getPlayerMoney(player)<1500 or player:GetItemCount( 19902 )>0 then
			player:SendBroadcastMessage("你的积分不足|cFFFF0000100|r或已经拥有了该坐骑！")
			player:GossipComplete()
		else
			if not player:HasSpell( 33392 ) then
				player:LearnSpell(33392) -----中级骑术
			end	
			player:AddItem( 19902 )
			removePlayerMoney(player,1500 )
			player:SendBroadcastMessage("恭喜你获得稀有坐骑！")
			player:GossipComplete()
		end
	end
	
	-----ZG龙-----
	if MenuGroup==43 then
		if getPlayerMoney(player)<1500 or player:GetItemCount( 19872 )>0 then
			player:SendBroadcastMessage("你的积分不足|cFFFF0000100|r或已经拥有了该坐骑！")
			player:GossipComplete()
		else
			if not player:HasSpell( 33392 ) then
				player:LearnSpell(33392) -----中级骑术
			end	
			player:AddItem( 19872 )
			removePlayerMoney(player,1500 )
			player:SendBroadcastMessage("恭喜你获得稀有坐骑！")
			player:GossipComplete()
		end
	end
	
	-----黑虫子-----
	if MenuGroup==44 then
		if getPlayerMoney(player)<2000 or player:GetItemCount( 21176 )>0 then
			player:SendBroadcastMessage("你的积分不足|cFFFF0000150|r或已经拥有了该坐骑！")
			player:GossipComplete()
		else
			if not player:HasSpell( 33392 ) then
				player:LearnSpell(33392) -----中级骑术
			end	
			player:AddItem( 21176 )
			removePlayerMoney(player,2000 )
			player:SendBroadcastMessage("恭喜你获得稀有坐骑！")
			player:GossipComplete()
		end
	end
	
	-----传说武器------
	if MenuGroup==5 then
		player:GossipMenuAddItem(1, "雷霆之怒，逐风者的祝福之剑　 |cFFFF00003000积分|r", 51,0 )	
		player:GossipMenuAddItem(1, "萨弗拉斯，炎魔拉格纳罗斯之手 |cFFFF00003000积分|r", 52,0 )	
		player:GossipMenuAddItem(1, "埃提耶什，守护者的传说之杖　 |cFFFF00003000积分|r", 53,0 )	
		player:GossipMenuAddItem(1, "灰烬使者 					  |cFFFF00003000积分|r", 54,0 )	
		
		player:GossipSendMenu(100, creature, menu_id) 
	end
	
	-----风剑-----
	if MenuGroup==51 then
		if getPlayerMoney(player)<3000 or player:GetItemCount( 19019 )>0 then
			player:SendBroadcastMessage("你的积分不足|cFFFF0000100|r或已经拥有了该武器！")
			player:GossipComplete()
		else
			player:AddItem( 19019 )
			removePlayerMoney(player,3000 )
			player:SendBroadcastMessage("恭喜你获得传说武器！")
			player:GossipComplete()
		end
	end
	
	-----橙锤-----
	if MenuGroup==52 then
		if getPlayerMoney(player)<3000 or player:GetItemCount( 17182 )>0 then
			player:SendBroadcastMessage("你的积分不足|cFFFF0000100|r或已经拥有了该武器！")
			player:GossipComplete()
		else
			player:AddItem( 17182 )
			removePlayerMoney(player,3000 )
			player:SendBroadcastMessage("恭喜你获得传说武器！")
			player:GossipComplete()
		end
	end
	
	-----鸡腿-----
	if MenuGroup==53 then
		player:GossipMenuAddItem(1, "埃提耶什，守护者的传说之杖(命中)　 |cFFFF00003000积分|r", 531,0 )	
		player:GossipMenuAddItem(1, "埃提耶什，守护者的传说之杖(暴击)　 |cFFFF00003000积分|r", 532,0 )	
		player:GossipMenuAddItem(1, "埃提耶什，守护者的传说之杖(治疗)　 |cFFFF00003000积分|r", 533,0 )	
		player:GossipMenuAddItem(1, "埃提耶什，守护者的传说之杖(野性)　 |cFFFF00003000积分|r", 534,0 )	
		
		player:GossipSendMenu(100, creature, menu_id) 
	end
	-----鸡腿（命中）-----
	if MenuGroup==531 then
		if getPlayerMoney(player)<3000 or player:GetItemCount( 22589 )>0 then
			player:SendBroadcastMessage("你的积分不足|cFFFF0000100|r或已经拥有了该武器！")
			player:GossipComplete()
		else
			player:AddItem( 22589 )
			removePlayerMoney(player,3000 )
			player:SendBroadcastMessage("恭喜你获得传说武器！")
			player:GossipComplete()
		end
	end
	-----鸡腿（暴击）-----
	if MenuGroup==532 then
		if getPlayerMoney(player)<3000 or player:GetItemCount( 22630 )>0 then
			player:SendBroadcastMessage("你的积分不足|cFFFF0000100|r或已经拥有了该武器！")
			player:GossipComplete()
		else
			player:AddItem( 22630 )
			removePlayerMoney(player,3000 )
			player:SendBroadcastMessage("恭喜你获得传说武器！")
			player:GossipComplete()
		end
	end	
	-----鸡腿（治疗）-----
	if MenuGroup==533 then
		if getPlayerMoney(player)<3000 or player:GetItemCount( 22631 )>0 then
			player:SendBroadcastMessage("你的积分不足|cFFFF0000100|r或已经拥有了该武器！")
			player:GossipComplete()
		else
			player:AddItem( 22631 )
			removePlayerMoney(player,3000 )
			player:SendBroadcastMessage("恭喜你获得传说武器！")
			player:GossipComplete()
		end
	end	
	-----鸡腿（野性）-----
	if MenuGroup==534 then
		if getPlayerMoney(player)<3000 or player:GetItemCount( 22632 )>0 then
			player:SendBroadcastMessage("你的积分不足|cFFFF0000100|r或已经拥有了该武器！")
			player:GossipComplete()
		else
			player:AddItem( 22632 )
			removePlayerMoney(player,3000 )
			player:SendBroadcastMessage("恭喜你获得传说武器！")
			player:GossipComplete()
		end
	end	
	
	-----灰烬-----
	if MenuGroup==54 then
		if getPlayerMoney(player)<3000 or player:GetItemCount( 13262 )>0 then
			player:SendBroadcastMessage("你的积分不足|cFFFF0000100|r或已经拥有了该武器！")
			player:GossipComplete()
		else
			player:AddItem( 13262 )
			removePlayerMoney(player,3000 )
			player:SendBroadcastMessage("恭喜你获得传说武器！")
			player:GossipComplete()
		end
	end
	
	-----兑换金币------
	if MenuGroup==6 then
		player:GossipMenuAddItem(1, "兑换10个金币	|cFFFF00005积分|r", 61,0 )	
		player:GossipMenuAddItem(1, "兑换100个金币	|cFFFF000050积分|r", 62,0 )	
		player:GossipMenuAddItem(1, "兑换500个金币　|cFFFF0000250积分|r", 63,0 )	
		
		player:GossipSendMenu(100, creature, menu_id) 
	end	
	-----兑换10个金币-----
	if MenuGroup==61 then
		if getPlayerMoney(player)<5 then
			player:SendBroadcastMessage("你的积分不足，无法兑换！")
			player:GossipComplete()
		else
			player:ModifyMoney( 100000 )
			removePlayerMoney(player,5 )
			player:SendBroadcastMessage("恭喜你兑换了10个金币！")
			player:GossipComplete()
		end
	end	
	-----兑换100个金币-----
	if MenuGroup==62 then
		if getPlayerMoney(player)<50 then
			player:SendBroadcastMessage("你的积分不足，无法兑换！")
			player:GossipComplete()
		else
			player:ModifyMoney( 1000000 )
			removePlayerMoney(player,50 )
			player:SendBroadcastMessage("恭喜你兑换了100个金币！")
			player:GossipComplete()
		end
	end		
	-----兑换500个金币-----
	if MenuGroup==63 then
		if getPlayerMoney(player)<250 then
			player:SendBroadcastMessage("你的积分不足，无法兑换！")
			player:GossipComplete()
		else
			player:ModifyMoney( 5000000 )
			removePlayerMoney(player,250 )
			player:SendBroadcastMessage("恭喜你兑换了500个金币！")
			player:GossipComplete()
		end
	end		
	
-------------------- 兑换积分相关 --------------------

	-----兑换积分------
	if MenuGroup==66 then
		player:GossipMenuAddItem(1, "兑换1积分　　　|cFFFF000020金币|r", 661,0 )	
		player:GossipMenuAddItem(1, "兑换10积分　　|cFFFF0000200金币|r", 662,0 )	
		player:GossipMenuAddItem(1, "兑换100积分　|cFFFF00002000金币|r", 663,0 )	 
		player:GossipSendMenu(100, creature, menu_id) 
	end		
	
	-----兑换1积分-----
	if MenuGroup==661 then
		if player:GetCoinage()>=200000 then			 
			player:ModifyMoney( -200000 ) 
			addPlayerMoney(player,1) -- 增加1积分 
			player:SendBroadcastMessage("恭喜你兑换了1积分！")
			player:GossipComplete()
		else
			player:SendBroadcastMessage("你的金币不足，无法兑换！")								
			player:GossipComplete()
		end
	end	
	-----兑换10积分-----
	if MenuGroup==662 then
		if player:GetCoinage()>=2000000 then		 
			player:ModifyMoney( -2000000 )		
			addPlayerMoney(player,10) -- 增加10积分 		
			player:SendBroadcastMessage("恭喜你兑换了10积分！")
			player:GossipComplete()
		else
			player:SendBroadcastMessage("你的金币不足，无法兑换！")								
			player:GossipComplete()
		end
	end		
	-----兑换100积分-----
	if MenuGroup==663 then
		if player:GetCoinage()>=20000000 then
			player:ModifyMoney( -20000000 )	
			addPlayerMoney(player,100) -- 增加100积分 	
			player:SendBroadcastMessage("恭喜你兑换了100积分！")
			player:GossipComplete()
		else
			player:SendBroadcastMessage("你的金币不足，无法兑换！")								
			player:GossipComplete()
		end
	end	
	
	-----药剂食物------
	-- if MenuGroup==6 then
		-- player:GossipMenuAddItem(1, "蛮力药剂 |cFFFF0000100积分|r", 71,0 )	
		-- player:GossipMenuAddItem(1, "先知药剂 |cFFFF0000100积分|r", 72,0 )	
		-- player:GossipMenuAddItem(1, "猫鼬药剂 |cFFFF0000100积分|r", 73,0 )	
		-- player:GossipMenuAddItem(1, "强效奥法药剂 |cFFFF0000100积分|r", 74,0 )	
		-- player:GossipMenuAddItem(1, "滋补药剂 |cFFFF000050积分|r", 75,0 )	
		-- player:GossipMenuAddItem(1, "特效活力药水 |cFFFF000050积分|r", 76,0 )	
		-- player:GossipMenuAddItem(1, "格拉库的蛋糕 |cFFFF000050积分|r", 77,0 )	
		
		-- player:GossipSendMenu(100, creature, menu_id) 
	-- end
	-- -----蛮力药剂-----
	-- if MenuGroup==71 then
		-- if getPlayerMoney(player)<100 then
			-- player:SendBroadcastMessage("该物品需要|cFFFF0000100积分|r，你的积分不足！")
			-- player:GossipComplete()
		-- else
			-- player:AddItem( 25911 )
			-- removePlayerMoney(player,100 )
			-- player:SendBroadcastMessage("恭喜你获得强力合剂！")
			-- player:GossipComplete()
		-- end
	-- end
	-- -----先知药剂 -----
	-- if MenuGroup==72 then
		-- if getPlayerMoney(player)<100 then
			-- player:SendBroadcastMessage("该物品需要|cFFFF0000100积分|r，你的积分不足！")
			-- player:GossipComplete()
		-- else
			-- player:AddItem( 25912 )
			-- removePlayerMoney(player,100 )
			-- player:SendBroadcastMessage("恭喜你获得强力合剂！")
			-- player:GossipComplete()
		-- end
	-- end
	-- -----猫鼬药剂-----
	-- if MenuGroup==73 then
		-- if getPlayerMoney(player)<100 then
			-- player:SendBroadcastMessage("该物品需要|cFFFF0000100积分|r，你的积分不足！")
			-- player:GossipComplete()
		-- else
			-- player:AddItem( 25913 )
			-- removePlayerMoney(player,100 )
			-- player:SendBroadcastMessage("恭喜你获得强力合剂！")
			-- player:GossipComplete()
		-- end
	-- end
	-- -----强效奥法-----
	-- if MenuGroup==74 then
		-- if getPlayerMoney(player)<100 then
			-- player:SendBroadcastMessage("该物品需要|cFFFF0000100积分|r，你的积分不足！")
			-- player:GossipComplete()
		-- else
			-- player:AddItem( 25914 )
			-- removePlayerMoney(player,100 )
			-- player:SendBroadcastMessage("恭喜你获得强力合剂！")
			-- player:GossipComplete()
		-- end
	-- end
	-- -----滋补药剂-----
	-- if MenuGroup==75 then
		-- if getPlayerMoney(player)<50 then
			-- player:SendBroadcastMessage("该物品需要|cFFFF000050积分|r，你的积分不足！")
			-- player:GossipComplete()
		-- else
			-- player:AddItem( 25915 )
			-- removePlayerMoney(player,50 )
			-- player:SendBroadcastMessage("恭喜你获得强力合剂！")
			-- player:GossipComplete()
		-- end
	-- end
	-- -----特效活力-----
	-- if MenuGroup==76 then
		-- if getPlayerMoney(player)<50 then
			-- player:SendBroadcastMessage("该物品需要|cFFFF000050积分|r，你的积分不足！")
			-- player:GossipComplete()
		-- else
			-- player:AddItem( 25916 )
			-- removePlayerMoney(player,50 )
			-- player:SendBroadcastMessage("恭喜你获得强力合剂！")
			-- player:GossipComplete()
		-- end
	-- end
	-- -----格拉库蛋糕-----
	-- if MenuGroup==77 then
		-- if getPlayerMoney(player)<50 then
			-- player:SendBroadcastMessage("该物品需要|cFFFF000050积分|r，你的积分不足！")
			-- player:GossipComplete()
		-- else
			-- player:AddItem( 26043 )
			-- removePlayerMoney(player,50 )
			-- player:SendBroadcastMessage("恭喜你获得强力合剂！")
			-- player:GossipComplete()
		-- end
	-- end
	

	
	
-- end
  
	

end

RegisterCreatureGossipEvent(NPC_Entry, 1, OnGossipHello)
RegisterCreatureGossipEvent(NPC_Entry, 2, OnGossipSelect)
 

-- RegisterPlayerEvent(100, PlayerBoost)--奖励

print(" PlayerBoost init ok113")

