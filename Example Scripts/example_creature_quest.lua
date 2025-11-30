--[[
    ============================================================
    脚本名称: 生物任务事件示例 (Example Creature Quest Script)
    脚本功能: 
        这是一个生物任务事件处理的示例脚本，演示如何处理
        玩家接受任务和完成任务时的事件。

    主要功能:
        1. 接受任务时NPC说话
        2. 完成任务时NPC说话

    示例学习:
        - GetId: 获取任务ID
        - SendUnitSay: 单位说话
    ============================================================
--]]

local NpcId = 123   -- NPC的Entry ID (NPC entry ID)
local QuestId = 123 -- 任务ID (Quest ID)

-- 玩家接受任务时触发 (Triggered when player accepts quest)
local function OnQuestAccept(event, player, creature, quest)
    if (quest:GetId() == QuestId) then
        creature:SendUnitSay("你接受了一个任务！(You have accepted a quest!)", 0)
    end
end

-- 玩家完成任务时触发 (Triggered when player completes quest)
-- 注意: 与OnQuestComplete效果相同 (Note: Same effect as OnQuestComplete)
local function OnQuestReward(event, player, creature, quest)
    if (quest:GetId() == QuestId) then
        creature:SendUnitSay("你完成了一个任务！(You have completed a quest!)", 0)
    end
end

-- 注册生物任务事件 (Register creature quest events)
RegisterCreatureEvent(NpcId, 31, OnQuestAccept) -- 31 = 接受任务事件 (Quest accept event)
RegisterCreatureEvent(NpcId, 34, OnQuestReward) -- 34 = 任务奖励事件 (Quest reward event)
