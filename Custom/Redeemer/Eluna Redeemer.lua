--[[
    ============================================================
    脚本名称: 兑换码系统 (Redeemer Script)
    脚本功能: 
        这个脚本允许玩家通过对话菜单输入预设的兑换码
        来获得相应的奖励。

    主要功能:
        1. 玩家输入兑换码获取奖励
        2. 兑换码使用后自动失效
        3. 支持多种奖励类型：物品、称号、金币
        4. GM可以手动刷新兑换码缓存
        5. 支持定时自动刷新缓存

    可用的兑换类型 (Available types of code redemptions):
        1: 物品 (Item) -- entry = 物品ID, count = 物品数量
        2: 称号 (Title) -- entry = 称号ID, count = 0
        3: 金币 (Money) -- entry = 0, count = 铜币数量

    配置说明:
        - Entry: NPC的Entry ID
        - ReloadTimer: 缓存自动刷新间隔（秒），0表示不自动刷新
    ============================================================
    
    - Redeemer script:
    
    This script allows players to redeem predetermined 
    codes given out during events etc.
    
    Codes are stored in its own table in the character database,
    as well as the rewards that are tied to the said code.
    
    Once a code is redeemed, it will be marked as
    redeemed in the database, as well as what player
    redeemed it and the date/time it was redeemed.
    The code will then be unavailable for future use.
    
    - Available types of code redemptions:
    
    1: Item -- entry = item entry, count = item count
    2: Title -- entry = title id, count = 0
    3: Money -- entry = 0, count = copper amount
--]]

local Redeemer = {
    Entry = 823,       -- 兑换NPC的Entry ID (Creature Entry)
    ReloadTimer = 120  -- 缓存自动刷新间隔，单位秒 (Cache reload timer in seconds)
}

-- 当玩家与NPC对话时触发 (Triggered when player talks to NPC)
function Redeemer.OnGossipHello(event, player, unit)
    player:GossipMenuAddItem(0, "我想要兑换我的密码 (I would like to redeem my secret code)", 0, 1, true, "请在下方输入您的兑换码 (Please insert your code below)")
    -- 如果是GM，显示刷新缓存选项 (If GM, show refresh cache option)
    if(player:IsGM()) then
        player:GossipMenuAddItem(0, "[GM] 刷新兑换码缓存 (Refresh code cache)", 0, 2)
    end
    player:GossipSendMenu(1, unit)
end

-- 当玩家选择菜单项时触发 (Triggered when player selects a menu option)
function Redeemer.OnGossipSelect(event, player, object, sender, intid, code)
    if(intid == 1) then
        local sCode = tostring(code)
        local t = Redeemer["Cache"][sCode]
        
        if(t) then
            -- 根据奖励类型发放奖励 (Give reward based on reward type)
            if(t["rtype"] == 1) then
                -- 物品奖励 (Item reward)
                player:AddItem(t["entry"], t["count"])
            elseif(t["rtype"] == 2) then
                -- 称号奖励 (Title reward)
                player:SetKnownTitle(t["entry"])
            elseif(t["rtype"] == 3) then
                -- 金币奖励 (Money reward)
                player:ModifyMoney(t["count"])
            else
                player:SendAreaTriggerMessage("错误：兑换失败，奖励类型错误。请联系管理员。(ERROR: Redemption failed, wrong redemption type. Please report to developers.)")
                return;
            end
            
            player:SendAreaTriggerMessage("恭喜！您的兑换码已成功兑换！(Congratulations! Your code has been successfully redeemed!)")
            -- 更新数据库，标记兑换码已使用 (Update database, mark code as redeemed)
            CharDBExecute("UPDATE redemption SET redeemed=1, player_guid="..player:GetGUIDLow()..", date='"..os.date("%x, %X", os.time()).."' WHERE BINARY passphrase='"..sCode.."';");
            Redeemer["Cache"][sCode] = nil; -- 从缓存中移除 (Remove from cache)
        else
            player:SendAreaTriggerMessage("您输入的兑换码无效，或兑换码已被使用。(You have entered an invalid code, or your code has already been redeemed.)")
        end
    elseif(intid == 2) then
        -- GM刷新缓存 (GM refresh cache)
        Redeemer.LoadCache()
        player:SendAreaTriggerMessage("可用兑换码已刷新。(Available passphrases have been refreshed.)")
    end
    player:GossipComplete()
end

-- 从数据库加载兑换码缓存 (Load redemption codes cache from database)
function Redeemer.LoadCache(event)
    Redeemer["Cache"] = {} -- 初始化缓存表 (Initialize cache table)
    
    -- 检查数据库表是否存在 (Check if database table exists)
    if not(CharDBQuery("SHOW TABLES LIKE 'redemption';")) then
        print("[Eluna Redeemer]: 角色数据库中缺少redemption表。(redemption table missing from Character database.)")
        print("[Eluna Redeemer]: 正在创建表结构，初始化缓存。(Inserting table structure, initializing cache.)")
        CharDBQuery("CREATE TABLE `redemption` (`passphrase` varchar(32) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL, `type` int(32) NOT NULL DEFAULT '0', `entry` int(32) NOT NULL DEFAULT '0', `count` int(32) NOT NULL DEFAULT '0', `redeemed` int(32) NOT NULL DEFAULT '0', `player_guid` int(32) DEFAULT NULL, `date` varchar(32) DEFAULT NULL, PRIMARY KEY (`passphrase`)) ENGINE=InnoDB DEFAULT CHARSET=utf8;")
        return Redeemer.LoadCache();
    end
    
    -- 加载未使用的兑换码 (Load unused redemption codes)
    local Query = CharDBQuery("SELECT * FROM redemption WHERE redeemed=0;");
    if(Query)then
        repeat
            Redeemer["Cache"][Query:GetString(0)] = {
                -- passphrase (兑换码)
                rtype = Query:GetUInt32(1), -- 奖励类型 (reward type)
                entry = Query:GetUInt32(2), -- 物品/称号Entry ID
                count = Query:GetUInt32(3)  -- 数量/金币数
                -- redeemed (是否已兑换)
                -- player_guid (兑换玩家GUID)
                -- date (兑换日期)
            };
        until not Query:NextRow()
        print("[Eluna Redeemer]: 缓存初始化完成，已加载 "..Query:GetRowCount().." 个兑换码。(Cache initialized. Loaded "..Query:GetRowCount().." results.)")
    else
        print("[Eluna Redeemer]: 缓存初始化完成，未找到兑换码。(Cache initialized. No results found.)")
    end
end

-- 初始化脚本 (Initialize script)
if(Redeemer.ReloadTimer > 0) then
    -- 如果设置了自动刷新间隔，创建定时刷新事件 (If reload timer set, create periodic refresh event)
    Redeemer.LoadCache()
    CreateLuaEvent(Redeemer.LoadCache, Redeemer.ReloadTimer*1000, 0)
else
    Redeemer.LoadCache()
end

-- 注册NPC对话事件 (Register NPC gossip events)
RegisterCreatureGossipEvent(Redeemer.Entry, 1, Redeemer.OnGossipHello)  -- 注册对话开始事件 (Register gossip hello event)
RegisterCreatureGossipEvent(Redeemer.Entry, 2, Redeemer.OnGossipSelect) -- 注册对话选择事件 (Register gossip select event)