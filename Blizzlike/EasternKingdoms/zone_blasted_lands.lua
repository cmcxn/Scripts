--[[
    ============================================================
    脚本名称: 诅咒之地区域脚本 (Blasted Lands Zone Script)
    脚本功能: 
        这是诅咒之地区域的任务对话脚本，处理
        死亡引路人(Deathly Usher)的任务相关对话。

    主要功能:
        1. 检查玩家任务状态和物品
        2. 提供前往亵渎者高地的传送选项
        3. 完成任务条件后施放传送法术

    任务信息:
        - 区域 (Zone): 诅咒之地 (Blasted Lands)
        - 任务ID (QuestId): 3628 (使用GetQuestStatus检查)
        - 所需物品 (Required Item): 10757
        - NPC: 死亡引路人 Deathly Usher <8816>
    ============================================================
    
    EmuDevs <http://emudevs.com/forum.php>
    Eluna Lua Engine <https://github.com/ElunaLuaEngine/Eluna>
    Eluna Scripts <https://github.com/ElunaLuaEngine/Scripts>
    Eluna Wiki <http://wiki.emudevs.com/doku.php?id=eluna>

    -= 脚本信息 (Script Information) =-
    * 区域 (Zone): 诅咒之地 (Blasted Lands)
    * 任务ID (QuestId): 3628 <GetQuestStatus>
    * 脚本类型 (Script Type): 任务对话 (Quest Gossip)
    * NPC: 死亡引路人 Deathly Usher <8816>
--]]

-- 对话菜单打开事件 (Gossip hello event)
function DeathlyUsher_OnGossipHello(event, player, creature)
    -- 检查玩家是否正在进行任务3628且拥有物品10757 (Check if player has quest 3628 in progress and has item 10757)
    if (player:GetQuestStatus(3628) == 3 and player:HasItem(10757)) then
        player:GossipMenuAddItem(0, "我希望前往亵渎者高地。(I wish to visit the Rise of the Defiler.)", 0, 1)
    end
    player:GossipSendMenu(player:GetGossipTextId(creature), creature)
end

-- 对话选择事件 (Gossip select event)
function DeathlyUsher_OnGossipSelect(event, player, creature, sender, intid, code)
    player:GossipClearMenu()
    if (intid == 1) then
        player:GossipComplete()
        creature:CastSpell(player, 12885, true) -- 施放传送法术 (Cast teleport spell)
    end
end

-- 注册NPC对话事件 (Register NPC gossip events)
RegisterCreatureGossipEvent(8816, 1, DeathlyUsher_OnGossipHello)  -- 对话开始 (Gossip hello)
RegisterCreatureGossipEvent(8816, 2, DeathlyUsher_OnGossipSelect) -- 对话选择 (Gossip select)