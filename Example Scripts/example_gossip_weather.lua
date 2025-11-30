--[[
    ============================================================
    脚本名称: 天气对话示例 (Weather Gossip Example Script)
    脚本功能: 
        这是一个天气控制对话菜单的示例脚本，演示如何
        通过对话菜单让玩家控制区域天气。

    主要功能:
        1. 创建天气控制对话菜单
        2. 随机设置玩家所在区域的天气
        3. 演示GetMap和SetWeather的使用

    示例学习:
        - GetMap: 获取玩家所在地图
        - GetZoneId: 获取玩家所在区域ID
        - SetWeather: 设置区域天气
    ============================================================
--]]

local NpcId = 123 -- NPC的Entry ID (NPC entry ID)

-- 对话菜单打开时触发 (Triggered when gossip menu opens)
local function OnGossipHello(event, player, unit)
    player:GossipMenuAddItem(0, "测试天气 (Test Weather)", 1, 1)
    player:GossipMenuAddItem(0, "没事了.. (Nevermind..)", 1, 2)
    player:GossipSendMenu(1, unit)
end

-- 对话菜单选择时触发 (Triggered when gossip menu option is selected)
local function OnGossipSelect(event, plr, unit, sender, action, code)
    if (action == 1) then
        -- 设置随机天气 (Set random weather)
        -- 参数: 区域ID, 天气类型(0-3), 强度 (Parameters: zone ID, weather type (0-3), intensity)
        plr:GetMap():SetWeather(plr:GetZoneId(), math.random(0, 3), 1)
        plr:GossipComplete()
    elseif (action == 2) then
        plr:GossipComplete() -- 关闭对话 (Close gossip)
    end
end

-- 注册NPC对话事件 (Register NPC gossip events)
-- 注意: 这里使用了OnHello和OnSelect作为函数名引用，但实际定义的是OnGossipHello和OnGossipSelect
-- Note: Using OnHello and OnSelect as references, but actual definitions are OnGossipHello and OnGossipSelect
RegisterCreatureGossipEvent(NpcId, 1, OnGossipHello)  -- 1 = 对话开始事件 (Gossip hello event)
RegisterCreatureGossipEvent(NpcId, 2, OnGossipSelect) -- 2 = 对话选择事件 (Gossip select event)
