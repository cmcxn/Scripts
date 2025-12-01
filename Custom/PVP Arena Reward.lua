--[[
    ============================================================
    脚本名称: PVP竞技场奖励脚本 (PVP Arena Reward Script)
    脚本功能: 
        这是一个PVP竞技场奖励脚本，当玩家在荆棘谷大竞技场
        区域内击杀拥有特定BUFF的玩家时，会获得金币奖励。

    主要功能:
        1. 监听玩家击杀玩家事件
        2. 检测击杀是否发生在大竞技场区域
        3. 检测被击杀玩家是否拥有特定BUFF
        4. 移除被击杀玩家的BUFF
        5. 给予击杀者1000金币奖励
        6. 发送世界公告通知所有玩家

    区域信息:
        - 地图 (Map): 0 (Eastern Kingdoms / 东部王国)
        - 区域 (Zone): 33 (Stranglethorn Vale / 荆棘谷)
        - 子区域 (Area): 2177 (Gurubashi Arena / 大竞技场)

    配置说明:
        - ARENA_BUFF_ID: 需要检测的BUFF法术ID
        - GOLD_REWARD: 金币奖励数量(单位:铜币,10000=1金)

    示例学习:
        - RegisterPlayerEvent: 注册玩家事件
        - GetAreaId: 获取玩家所在区域ID
        - HasAura: 检测玩家是否拥有某个光环/BUFF
        - RemoveAura: 移除玩家的光环/BUFF
        - ModifyMoney: 修改玩家金钱
        - SendWorldMessage: 发送世界消息
    ============================================================
    
    EmuDevs <http://emudevs.com/forum.php>
    Eluna Lua Engine <https://github.com/ElunaLuaEngine/Eluna>
    Eluna Scripts <https://github.com/ElunaLuaEngine/Scripts>
    Eluna Wiki <http://wiki.emudevs.com/doku.php?id=eluna>

    -= 脚本信息 (Script Information) =-
    * 区域 (Zone): 荆棘谷 (Stranglethorn Vale)
    * 地图ID (MapId): 0
    * 区域ID (AreaId): 2177 (大竞技场 / Gurubashi Arena)
    * 脚本类型 (Script Type): PVP奖励 (PVP Reward)
--]]

--------------------------------------------------------
--[[
     配置区域 (Configuration Section)
--]]
--------------------------------------------------------

local PVPArenaReward = {
    -- 大竞技场区域ID (Gurubashi Arena Area ID)
    ARENA_AREA_ID = 2177,
    
    -- 需要检测的BUFF法术ID - 请根据服务器实际配置修改此ID
    -- (Target buff spell ID - please modify this ID according to your server's configuration)
    -- 示例: 22888 = 沙漠狂沙 (Sandstorm), 您需要替换为您服务器上实际使用的竞技场BUFF ID
    -- Example: 22888 = Sandstorm spell, replace with your server's actual arena buff spell ID
    ARENA_BUFF_ID = 22888,
    
    -- 金币奖励数量 (铜币单位，10000铜币 = 1金)
    -- (Gold reward amount in copper, 10000 copper = 1 gold)
    GOLD_REWARD = 10000000,  -- 1000金 = 1000 * 10000 铜币
}

--------------------------------------------------------
--[[
     核心逻辑 (Core Logic)
--]]
--------------------------------------------------------

-- 玩家击杀玩家事件处理 (Player kill player event handler)
-- event: 事件ID (event ID)
-- killer: 击杀者玩家 (killer player)
-- killed: 被击杀的玩家 (killed player)
local function OnPlayerKillPlayer(event, killer, killed)
    -- 检查被击杀者是否为有效玩家 (Check if killed is a valid player)
    if not killed or not killer then
        return
    end
    
    -- 获取击杀者和被击杀者的区域ID (Get area ID of both players)
    local killerAreaId = killer:GetAreaId()
    local killedAreaId = killed:GetAreaId()
    
    -- 检查击杀是否发生在大竞技场区域 (Check if kill happened in Gurubashi Arena)
    -- 至少有一个玩家在竞技场区域内即可触发奖励
    -- (Trigger reward if at least one player is in the arena area)
    if killerAreaId ~= PVPArenaReward.ARENA_AREA_ID and killedAreaId ~= PVPArenaReward.ARENA_AREA_ID then
        return
    end
    
    -- 检查被击杀玩家是否拥有指定的BUFF (Check if killed player has the specified buff)
    if not killed:HasAura(PVPArenaReward.ARENA_BUFF_ID) then
        return
    end
    
    -- 获取玩家名称 (Get player names)
    local killerName = killer:GetName()
    local killedName = killed:GetName()
    
    -- 移除被击杀玩家的BUFF (Remove the buff from killed player)
    killed:RemoveAura(PVPArenaReward.ARENA_BUFF_ID)
    
    -- 给予击杀者金币奖励 (Give gold reward to killer)
    killer:ModifyMoney(PVPArenaReward.GOLD_REWARD)
    
    -- 发送世界公告 (Send world announcement)
    -- 消息格式: 玩家A击杀了拥有BUFF的玩家B，获得了X个金币
    local goldAmount = math.floor(PVPArenaReward.GOLD_REWARD / 10000)
    local message = string.format(
        "|cFFFF0000[竞技场公告]|r |cFF00FF00%s|r 在大竞技场击杀了拥有BUFF的 |cFFFF0000%s|r，获得了 |cFFFFD700%d|r 金币奖励！",
        killerName,
        killedName,
        goldAmount
    )
    SendWorldMessage(message)
    
    -- 打印日志到控制台 (Print log to console)
    print(string.format("[PVP Arena] %s killed %s with buff in Gurubashi Arena, rewarded %d gold", killerName, killedName, goldAmount))
end

--------------------------------------------------------
--[[
     事件注册 (Event Registration)
--]]
--------------------------------------------------------

-- 注册玩家击杀玩家事件 (Register player kill player event)
-- 事件类型6: PLAYER_EVENT_ON_KILL_PLAYER (Event type 6: Player kills another player)
RegisterPlayerEvent(6, OnPlayerKillPlayer)

-- 脚本加载提示 (Script load notification)
print("---------- PVP竞技场奖励脚本已加载 (PVP Arena Reward Script Loaded) ----------")
