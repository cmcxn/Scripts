--[[
    ============================================================
    脚本名称: 扩展对话菜单示例 (Extended Gossip Example Script)
    脚本功能: 
        这是一个扩展对话菜单的示例脚本，演示如何创建
        带有悬赏功能的对话菜单，包括代码输入和金币扣除。

    主要功能:
        1. 使用代码输入框获取玩家输入
        2. 通过玩家名称查找目标玩家
        3. 扣除金币作为悬赏费用
        4. 带有弹出确认和金币需求的菜单项

    示例学习:
        - GossipMenuAddItem 的完整参数使用
        - GetPlayerByName: 通过名称获取玩家
        - ModifyMoney: 修改玩家金币
    ============================================================
--]]

local npcId = 123 -- NPC的Entry ID (NPC entry ID)

-- 对话菜单打开时触发 (Triggered when gossip menu opens)
local function GossipHello(event, plr, unit)
    -- 添加菜单项: 图标, 文本, sender, intid, 使用代码框(true/false), 提示文本, 金币数量
    -- Add menu item: icon, text, sender, intid, use code (true/false), prompt text, how much gold (amount)
    plr:GossipMenuAddItem(0, "我想要发布悬赏 (I would like to place a bounty)", 0, 1, true, "你想悬赏谁？(Who would you like to place a bounty on?)", 10000) -- 1金 (1 gold)
    plr:GossipMenuAddItem(0, "没事了.. (Nevermind..)", 0, 2)
    plr:GossipSendMenu(1, unit)
end

-- 对话菜单选择时触发 (Triggered when gossip menu option is selected)
local function GossipSelect(event, player, creature, sender, intid, code)
    if (intid == 1) then -- 处理代码/悬赏逻辑 (Deal with code / bounty stuff)
        -- 通过输入的名称查找玩家 (Find player by input name)
        local victim = GetPlayerByName(code)
        if (victim ~= nil) then
            player:SendBroadcastMessage("目标名称 (NAME):" ..victim:GetName().."!")
            player:ModifyMoney(-10000) -- 扣除金币 (Remove the gold amount)
        end
    end
end

-- 注册NPC对话事件 (Register NPC gossip events)
RegisterCreatureGossipEvent(npcId, 1, GossipHello)  -- 1 = 对话开始事件 (Gossip hello event)
RegisterCreatureGossipEvent(npcId, 2, GossipSelect) -- 2 = 对话选择事件 (Gossip select event)