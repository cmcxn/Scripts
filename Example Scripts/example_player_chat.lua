--[[
    ============================================================
    脚本名称: 玩家聊天事件示例 (Player Chat Event Example Script)
    脚本功能: 
        这是一个玩家聊天事件处理的示例脚本，演示如何
        监听并处理玩家发送的聊天消息。

    主要功能:
        1. 监听玩家发送的所有聊天消息
        2. 检测特定消息并执行操作
        3. 可用于创建聊天命令系统

    示例学习:
        - RegisterPlayerEvent 事件类型18 (聊天消息)
        - 消息内容比较和处理
    ============================================================
--]]

-- 玩家聊天事件处理 (Player chat event handler)
-- event: 事件ID (event ID)
-- player: 发送消息的玩家 (player who sent the message)
-- msg: 消息内容 (message content)
-- Type: 消息类型 (message type)
-- lang: 语言 (language)
local function OnEvents(event, player, msg, Type, lang)
    if (msg == "asd") then
        print "检测到asd消息 (asd detected)" -- 打印到控制台 (print to console)
    end
end

-- 注册玩家聊天事件 (Register player chat event)
RegisterPlayerEvent(18, OnEvents) -- 18 = 玩家聊天消息事件 (Player chat message event)