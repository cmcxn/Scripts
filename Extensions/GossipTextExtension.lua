--[[
    ============================================================
    脚本名称: 对话文本扩展 (Gossip Text Extension)
    脚本功能: 
        这是一个对话文本扩展脚本，为Player对象添加
        GossipSetText方法，允许在对话菜单中显示自定义文本。

    主要功能:
        1. 扩展Player对象，添加GossipSetText方法
        2. 可在对话菜单顶部显示自定义文本
        3. 无需使用数据库中的gossip_menu_option

    使用方法:
        player:GossipMenuAddItem(0, "选项", 0, 0)
        player:GossipSetText("自定义顶部文本")
        player:GossipSendMenu(0x7FFFFFFF, creature)
        -- 使用0x7FFFFFFF作为MenuId而不是数据库中的MenuId
    ============================================================
--]]

local SMSG_NPC_TEXT_UPDATE = 384    -- NPC文本更新的服务器消息操作码 (Server message opcode for NPC text update)
local MAX_GOSSIP_TEXT_OPTIONS = 8   -- 最大对话文本选项数 (Maximum gossip text options)

-- 为Player对象添加GossipSetText方法 (Add GossipSetText method to Player object)
-- text: 要显示的文本 (text to display)
-- textID: 文本ID，默认为0x7FFFFFFF (text ID, defaults to 0x7FFFFFFF)
function Player:GossipSetText(text, textID)
    -- 创建数据包 (Create packet)
    local data = CreatePacket(SMSG_NPC_TEXT_UPDATE, 100);
    data:WriteULong(textID or 0x7FFFFFFF) -- 写入文本ID (Write text ID)
    
    -- 写入8个文本选项（gossip_menu_option表有8个选项槽位）
    -- Write 8 text options (gossip_menu_option table has 8 option slots)
    for i = 1, MAX_GOSSIP_TEXT_OPTIONS do
        data:WriteFloat(0)          -- 概率 (Probability)
        data:WriteString(text)      -- 男性文本 (Text - male)
        data:WriteString(text)      -- 女性文本 (Text - female)
        data:WriteULong(0)          -- 语言 (language)
        data:WriteULong(0)          -- 表情1 (emote)
        data:WriteULong(0)          -- 表情2 (emote)
        data:WriteULong(0)          -- 表情3 (emote)
        data:WriteULong(0)          -- 表情4 (emote)
        data:WriteULong(0)          -- 表情5 (emote)
        data:WriteULong(0)          -- 表情6 (emote)
    end
    self:SendPacket(data) -- 发送数据包给玩家 (Send packet to player)
end

--[[ 使用示例 (Example usage):
	player:GossipMenuAddItem(0, "asd", 0, 0)
	player:GossipMenuAddItem(0, "asd", 0, 0)
	player:GossipSetText("测试文本 "..math.random()) -- 将在对话菜单顶部显示为文本 (Will show as top text within the gossip menu)
	player:GossipSendMenu(0x7FFFFFFF, creature) -- 使用0x7FFFFFFF作为MenuId而不是数据库中的MenuId (Use 0x7FFFFFFF as the MenuId instead of the normal database based MenuId's)
]]
