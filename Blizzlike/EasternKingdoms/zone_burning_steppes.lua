--[[
    ============================================================
    脚本名称: 燃烧平原区域脚本 (Burning Steppes Zone Script)
    脚本功能: 
        这是燃烧平原区域的任务对话脚本，处理
        破衣约翰(Ragged John)的多阶段对话任务。

    主要功能:
        1. 多阶段对话推进任务剧情
        2. 检测玩家光环状态触发特殊事件
        3. 支持任务完成确认

    任务信息:
        - 区域 (Zone): 燃烧平原 (Burning Steppes)
        - 任务ID (QuestId): 4224 / 4866
        - NPC: 破衣约翰 Ragged John <9563>
    ============================================================
    
    EmuDevs <http://emudevs.com/forum.php>
    Eluna Lua Engine <https://github.com/ElunaLuaEngine/Eluna>
    Eluna Scripts <https://github.com/ElunaLuaEngine/Scripts>
    Eluna Wiki <http://wiki.emudevs.com/doku.php?id=eluna>

    -= 脚本信息 (Script Information) =-
    * 区域 (Zone): 燃烧平原 (Burning Steppes)
    * 任务ID (QuestId): 4224 / 4866
    * 脚本类型 (Script Type): 任务对话 (Quest Gossip)
    * NPC: 破衣约翰 Ragged John <9563>
--]]

-- 对话选项表 (Gossip options table)
-- 格式: { 当前ID, 下一ID, 对话文本, 显示文本ID }
local Gossip =
{
    { 1, 2, "那你做了什么？(So what did you do?)", 2714 },
    { 2, 3,  "说点有意义的，矮人。我不想和你的饼干、你爹或者任何'诋毁'扯上关系。(Start making sense, dwarf. I don't want to have anything to do with your cracker, your pappy, or any sort of 'discreditin'.)", 2715 },
    { 3, 4,  "铁怒？(Ironfoe?)", 2716 },
    { 4, 5,  "有意思... 继续，约翰。(Interesting... continue John.)", 2717 },
    { 5, 6,  "所以温德索尔就是这么死的...(So that's how Windsor died...)", 2718 },
    { 6, 7,  "那他是怎么死的？(So how did he die?)", 2719 },
    { 7, 8,  "好吧，那他到底在哪儿？等等！你喝醉了吗？(Ok so where the hell is he? Wait a minute! Are you drunk?)", 2720 },
    { 8, 9,  "他为什么会在黑石深渊？(WHY is he in Blackrock Depths?)", 2721 },
    { 9, 10,  "300？所以黑铁矮人杀了他然后把他拖进了深渊？(300? So the Dark Irons killed him and dragged him into the Depths?)", 2722 },
    { 10, 11,  "啊... 铁怒(Ahh... Ironfoe)", 2723 },
    { 11, 12,  "谢谢你，破衣约翰。你的故事非常振奋人心且富有信息。(Thanks, Ragged John. Your story was very uplifting and informative)", 2725 }
}

-- 对话菜单打开事件 (Gossip hello event)
function RaggedJohn_OnGossipHello(event, player, creature)
    -- 如果NPC是任务给予者，添加任务 (If NPC is quest giver, add quests)
    if (creature:IsQuestGiver()) then
        player:GossipAddQuests(creature)
    end

    -- 检查任务4224是否正在进行中 (Check if quest 4224 is in progress)
    if (player:GetQuestStatus(4224) == 3) then
        player:GossipMenuAddItem(0, "公务，约翰。我需要一些关于玛莎·温德索尔的信息。告诉我你最后一次见到他的情况。(Official buisness, John. I need some information about Marsha Windsor. Tell me about the last time you saw him.)", 0, 1)
    end
    player:GossipSendMenu(2713, creature)
end

-- 对话选择事件 (Gossip select event)
function RaggedJohn_OnGossipSelect(event, player, creature, sender, intid, code)
    player:GossipClearMenu()
    
    -- 最后一个对话选项 - 完成任务 (Last gossip option - complete quest)
    if (intid == 12) then
        player:GossipComplete()
        player:AreaExploredOrEventHappens(4224)
        return
    end

    -- 显示下一个对话选项 (Show next gossip option)
    if (intid == Gossip[intid][1]) then
        player:GossipMenuAddItem(0, Gossip[intid][3], 0, Gossip[intid][2])
        player:GossipSendMenu(Gossip[intid][4], creature)
    end
end

-- 视野范围内移动事件 - 用于任务4866 (Move in line of sight event - for quest 4866)
function RaggedJohn_MoveInLOS(event, creature, unit)
    -- 检查单位是否有光环16468 (Check if unit has aura 16468)
    if (unit:HasAura(16468)) then
        if (unit:GetUnitType() == "Player" and creature:IsWithinDistInMap(unit, 15) and unit:IsInAccessiblePlaceFor(creature)) then
            creature:CastSpell(unit, 16472) -- 施放法术 (Cast spell)
            unit:AreaExploredOrEventHappens(4866) -- 完成任务事件 (Complete quest event)
        end
    end
end

-- 注册NPC对话事件 (Register NPC gossip events)
RegisterCreatureGossipEvent(9563, 1, RaggedJohn_OnGossipHello)  -- 对话开始 (Gossip hello)
RegisterCreatureGossipEvent(9563, 2, RaggedJohn_OnGossipSelect) -- 对话选择 (Gossip select)
RegisterCreatureEvent(9563, 27, RaggedJohn_MoveInLOS)           -- 视野范围内移动 (Move in LOS)