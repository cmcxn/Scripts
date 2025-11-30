--[[
    ============================================================
    脚本名称: 东瘟疫之地区域脚本 (Eastern Plaguelands Zone Script)
    脚本功能: 
        这是东瘟疫之地区域的多NPC脚本，处理多个NPC的
        对话和任务相关功能。

    主要功能:
        1. 食尸鬼剥皮者死亡时召唤达罗郡之魂
        2. 奥古斯都商人功能（需完成任务后解锁）
        3. 达罗郡之魂的任务对话
        4. 提里奥·弗丁的多阶段任务对话

    涉及NPC:
        - 食尸鬼剥皮者 (Ghoul Flayer) <8530, 8531, 8532>
        - 被触动的奥古斯都 (Augustus the Touched) <12384>
        - 达罗郡之魂 (Darrowshire Spirit) <11064>
        - 提里奥·弗丁 (Tirion Fordring) <1855>

    任务ID: 5742 / 6164
    ============================================================
    
    EmuDevs <http://emudevs.com/forum.php>
    Eluna Lua Engine <https://github.com/ElunaLuaEngine/Eluna>
    Eluna Scripts <https://github.com/ElunaLuaEngine/Scripts>
    Eluna Wiki <http://wiki.emudevs.com/doku.php?id=eluna>

    -= 脚本信息 (Script Information) =-
    * 区域 (Zone): 东瘟疫之地 (Eastern Plaugelands)
    * 任务ID (QuestId): 5742 / 6164
    * 脚本类型 (Script Type): 对话、生物AI和任务 (Gossip, CreatureAI and Quest)
    * NPC: 食尸鬼剥皮者 Ghoul Flayer <8530, 8531, 8532>, 被触动的奥古斯都 Augustus the Touched <12384>, 
           达罗郡之魂 Darrowshire Spirit <11064>, 提里奥·弗丁 Tirion Fordring <1855>
--]]

-- ============================================================
-- 食尸鬼剥皮者 (Ghoul Flayer)
-- ============================================================
-- 死亡事件 - 召唤达罗郡之魂 (Death event - Spawn Darrowshire Spirit)
function Flayer_Died(event, creature, killer)
    if (killer:GetUnitType() == "Player") then
        -- 在死亡位置召唤达罗郡之魂，60秒后消失 (Spawn Darrowshire Spirit at death location, despawn after 60s)
        creature:SpawnCreature(11064, 0, 0, 0, 0, 3, 60000)
    end
end

-- 注册食尸鬼剥皮者死亡事件 (Register Ghoul Flayer death events)
RegisterCreatureEvent(8530, 4, Flayer_Died)
RegisterCreatureEvent(8531, 4, Flayer_Died)
RegisterCreatureEvent(8532, 4, Flayer_Died)

-- ============================================================
-- 被触动的奥古斯都 (Augustus the Touched)
-- ============================================================
-- 对话菜单打开事件 (Gossip hello event)
function Augustus_GossipHello(event, player, creature)
    -- 如果NPC是任务给予者，添加任务 (If NPC is quest giver, add quests)
    if (creature:IsQuestGiver()) then
        player:GossipAddQuests(creature)
    end

    -- 如果NPC是商人且玩家已完成任务6164，显示商人选项 (If NPC is vendor and player completed quest 6164, show vendor option)
    if (creature:IsVendor() and player:GetQuestRewardStatus(6164)) then
        player:GossipMenuAddItem(0, "我想看看你的商品。(I'd like to browse your goods.)", 0, 1)
    end
    player:GossipSendMenu(player:GetGossipTextId(creature), creature)
end

-- 对话选择事件 (Gossip select event)
function Augustus_GossipSelect(event, player, creature, sender, intid, code)
    player:GossipClearMenu()
    if (intid == 1) then
        player:SendListInventory(creature) -- 发送商人物品列表 (Send vendor inventory)
    end
end

RegisterCreatureGossipEvent(12384, 1, Augustus_GossipHello)
RegisterCreatureGossipEvent(12384, 2, Augustus_GossipSelect)

-- ============================================================
-- 达罗郡之魂 (Darrowshire Spirit)
-- ============================================================
-- 对话菜单打开事件 (Gossip hello event)
function Darrowshire_GossipHello(event, player, creature)
    player:GossipSendMenu(3873, creature)
    player:TalkedToCreature(creature:GetEntry(), creature) -- 记录与生物对话（用于任务）(Record talked to creature - for quest)
    creature:SetFlag(59, 33554432) -- 设置标志 (Set flag)
end

-- 重置事件 (Reset event)
function Darrowshire_Reset(event, creature)
    creature:CastSpell(creature, 17321) -- 施放视觉效果法术 (Cast visual effect spell)
    creature:RemoveFlag(59, 33554432)   -- 移除标志 (Remove flag)
end

RegisterCreatureGossipEvent(11064, 1, Darrowshire_GossipHello)
RegisterCreatureEvent(11064, 23, Darrowshire_Reset)

-- ============================================================
-- 提里奥·弗丁 (Tirion Fordring)
-- ============================================================
-- 对话菜单打开事件 (Gossip hello event)
function Tirion_GossipHello(event, player, creature)
    -- 如果NPC是任务给予者，添加任务 (If NPC is quest giver, add quests)
    if (creature:IsQuestGiver()) then
        player:GossipAddQuests(creature)
    end

    -- 检查任务5742是否正在进行中且玩家正在坐下 (Check if quest 5742 in progress and player is sitting)
    if (player:GetQuestStatus(5742) == 3 and player:GetStandState() == 1) then
        player:GossipMenuAddItem(0, "我准备好听你的故事了，提里奥。(I am ready to hear your tale, Tirion.)", 0, 1)
    end
    player:GossipSendMenu(player:GetGossipTextId(creature), creature)
end

-- 对话选择事件 (Gossip select event)
function Tirion_GossipSelect(event, player, creature, sender, intid, code)
    player:GossipClearMenu()
    if (intid == 1) then
        player:GossipMenuAddItem(0, "谢谢你，提里奥。你的身份呢？(Thank you, Tirion.  What of your identity?)", 0, 2)
        player:GossipSendMenu(4493, creature)
    elseif (intid == 2) then
        player:GossipMenuAddItem(0, "太可怕了。(That is terrible.)", 0, 3)
        player:GossipSendMenu(4494, creature)
    elseif (intid == 3) then
        player:GossipMenuAddItem(0, "我会的，提里奥。(I will, Tirion.)", 0, 4)
        player:GossipSendMenu(4495, creature)
    elseif (intid == 4) then
        player:GossipComplete()
        player:AreaExploredOrEventHappens(5742) -- 完成任务事件 (Complete quest event)
    end
end

RegisterCreatureGossipEvent(1855, 1, Tirion_GossipHello)
RegisterCreatureGossipEvent(1855, 2, Tirion_GossipSelect)
