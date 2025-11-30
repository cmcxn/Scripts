--[[
    ============================================================
    脚本名称: 玩家聊天命令示例 (Player Chat Command Example Script)
    脚本功能: 
        这是一个玩家聊天命令处理的示例脚本，演示如何
        创建自定义聊天命令前缀并处理命令。

    主要功能:
        1. 设置自定义命令前缀
        2. 检测以特定前缀开头的消息
        3. 执行相应的命令操作

    示例学习:
        - string:find: 查找字符串
        - SendNotification: 发送屏幕通知
        - 自定义聊天命令系统
    ============================================================
--]]

local ChatPrefix = "#example" -- 聊天命令前缀 (Chat command prefix)

-- 聊天命令系统处理函数 (Chat command system handler)
-- event: 事件ID (event ID)
-- player: 发送消息的玩家 (player who sent the message)
-- msg: 消息内容 (message content)
-- _: 消息类型(未使用) (message type - unused)
-- lang: 语言 (language)
local function ChatSystem(event, player, msg, _, lang)
    -- 检查消息是否以命令前缀开头 (Check if message starts with command prefix)
    if (msg:find(ChatPrefix) == 1) then
        player:SendNotification("示例聊天命令已生效 (Example Chat Command Works)")
    end
end

-- 注册玩家聊天事件 (Register player chat event)
RegisterPlayerEvent(18, ChatSystem) -- 18 = 玩家聊天消息事件 (Player chat message event)