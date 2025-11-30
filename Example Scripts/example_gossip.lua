--[[
    ============================================================
    脚本名称: 对话菜单示例 (Example Gossip Script)
    脚本功能: 
        这是一个对话菜单的示例脚本，演示如何创建和处理
        NPC、游戏物体、物品和玩家的对话菜单。

    主要功能:
        1. 创建多层级对话菜单
        2. 显示弹出确认框
        3. 使用代码输入框
        4. 设置金币需求
        5. 支持NPC、游戏物体、物品对话

    示例学习:
        - GossipClearMenu: 清除对话菜单
        - GossipMenuAddItem: 添加对话菜单项
        - GossipSendMenu: 发送对话菜单
        - GossipComplete: 关闭对话菜单
    ============================================================
--]]

local GobId = 123  -- 游戏物体Entry ID (GameObject entry ID)
local NpcId = 123  -- NPC Entry ID (NPC entry ID)
local ItemId = 123 -- 物品Entry ID (物品需要有使用法术) (Item entry ID - Item needs to have spell on use)
local MenuId = 123 -- 唯一菜单ID，用于识别玩家对话菜单 (Unique ID to recognice player gossip menu among others)

-- 对话菜单打开时触发 (Triggered when gossip menu opens)
local function OnGossipHello(event, player, object)
    player:GossipClearMenu() -- 玩家对话需要清除菜单 (required for player gossip)
    -- 添加菜单项: 图标, 文本, sender, intid, 是否使用代码框, 弹出文本, 金币需求
    -- Add menu item: icon, text, sender, intid, use codebox, popup text, gold requirement
    player:GossipMenuAddItem(0, "打开子菜单 (Open submenu)", 1, 1)
    player:GossipMenuAddItem(0, "测试弹出框 (Test popup box)", 1, 2, false, "测试弹出框 (Test popup)")
    player:GossipMenuAddItem(0, "测试代码框 (Test codebox)", 1, 3, true, nil)
    player:GossipMenuAddItem(0, "测试金币需求 (Test money requirement)", 1, 4, nil, nil, 50000) -- 5金 (5 gold)
    player:GossipSendMenu(1, object, MenuId) -- 玩家对话需要MenuId (MenuId required for player gossip)
end

-- 对话菜单选择时触发 (Triggered when gossip menu option is selected)
local function OnGossipSelect(event, player, object, sender, intid, code, menuid)
    if (intid == 1) then
        -- 显示子菜单 (Show submenu)
        player:GossipMenuAddItem(0, "关闭对话 (Close gossip)", 1, 5)
        player:GossipMenuAddItem(0, "返回.. (Back ..)", 1, 6)
        player:GossipSendMenu(1, object, MenuId) -- 玩家对话需要MenuId (MenuId required for player gossip)
    elseif (intid == 2) then
        -- 返回主菜单 (Return to main menu)
        OnGossipHello(event, player, object)
    elseif (intid == 3) then
        -- 显示玩家输入的代码 (Display player's input code)
        player:SendBroadcastMessage(code)
        OnGossipHello(event, player, object)
    elseif (intid == 4) then
        -- 检查并扣除金币 (Check and deduct gold)
        if (player:GetCoinage() >= 50000) then
            player:ModifyMoney(-50000)
        end
        OnGossipHello(event, player, object)
    elseif (intid == 5) then
        -- 关闭对话菜单 (Close gossip menu)
        player:GossipComplete()
    elseif (intid == 6) then
        -- 返回主菜单 (Return to main menu)
        OnGossipHello(event, player, object)
    end
end

-- 玩家命令事件处理，用于通过命令打开玩家对话 (Player command handler to open player gossip via command)
local function OnPlayerCommand(event, player, command)
    if (command == "test gossip") then
        OnGossipHello(event, player, player)
        return false -- 返回false阻止命令继续处理 (Return false to prevent further command processing)
    end
end

-- 注册NPC对话事件 (Register NPC gossip events)
RegisterCreatureGossipEvent(NpcId, 1, OnGossipHello)  -- 对话开始 (Gossip hello)
RegisterCreatureGossipEvent(NpcId, 2, OnGossipSelect) -- 对话选择 (Gossip select)

-- 注册游戏物体对话事件 (Register GameObject gossip events)
RegisterGameObjectGossipEvent(GobId, 1, OnGossipHello)
RegisterGameObjectGossipEvent(GobId, 2, OnGossipSelect)

-- 注册物品对话事件 (Register Item gossip events)
RegisterItemGossipEvent(ItemId, 1, OnGossipHello)
RegisterItemGossipEvent(ItemId, 2, OnGossipSelect)

-- 注册玩家命令事件和玩家对话事件 (Register player command and player gossip events)
RegisterPlayerEvent(42, OnPlayerCommand)        -- 42 = 玩家命令事件 (Player command event)
RegisterPlayerGossipEvent(MenuId, 2, OnGossipSelect) -- 玩家对话选择事件 (Player gossip select event)
