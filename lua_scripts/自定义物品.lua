
local TEAM_ALLIANCE=0
local TEAM_HORDE=1
--CLASS                                        职业        
local CLASS_WARRIOR                 = 1                --战士
local CLASS_PALADIN                        = 2                --圣骑士
local CLASS_HUNTER                        = 3                --猎人
local CLASS_ROGUE                        = 4                --盗贼
local CLASS_PRIEST                        = 5                --牧师
local CLASS_DEATH_KNIGHT        = 6                --死亡骑士
local CLASS_SHAMAN                        = 7                --萨满
local CLASS_MAGE                        = 8                --法师
local CLASS_WARLOCK                        = 9                --术士
local CLASS_DRUID                        = 11        --德鲁伊

local ClassName={--职业表
        [CLASS_WARRIOR]        ="战士",
        [CLASS_PALADIN]        ="圣骑士",
        [CLASS_HUNTER]        ="猎人",
        [CLASS_ROGUE]        ="盗贼",
        [CLASS_PRIEST]        ="牧师",
        [CLASS_DEATH_KNIGHT]="死亡骑士",
        [CLASS_SHAMAN]        ="萨满",
        [CLASS_MAGE]        ="法师",
        [CLASS_WARLOCK]        ="术士",
        [CLASS_DRUID]        ="德鲁伊",
}

local function GetPlayerInfo(player)--得到玩家信息
        local Pclass        = ClassName[player:GetClass()] or "? ? ?" --得到职业
        local Pname                = player:GetName()
        local Pteam                = ""
        local team=player:GetTeam()
        if(team==TEAM_ALLIANCE)then
                Pteam                ="|cFF0070d0联盟|r"
        elseif(team==TEAM_HORDE)then 
                Pteam                ="|cFFF000A0部落|r"
        end
        return string.format("%s%s玩家[|cFF00FF00|Hplayer:%s|h%s|h|r]",Pteam,Pclass,Pname,Pname)
end



-- 通用函数：克隆物品 template
-- @param orig_entry  number  — 要复制的原 item_template entry
-- @param new_entry   number  — 新的 item entry id
-- @param overrides   table   — 可选: 覆盖字段, 如 { name = "...", description = "...", display_id = ... }
local function CloneItemTemplate(orig_entry, new_entry, overrides)
    overrides = overrides or {}

    -- 不再删除旧的 new_entry，存在就跳过插入
    -- WorldDBExecute(string.format("DELETE FROM item_template WHERE entry = %d;", new_entry))

    local name      = overrides.name        or "(unknown)"
    local desc      = overrides.description or ""
    local displayId = overrides.display_id  or 0

    local sql = [[
    INSERT INTO item_template (
      entry, patch, class, subclass, name, description, display_id, quality, flags,
      buy_count, buy_price, sell_price, inventory_type, allowable_class, allowable_race,
      item_level, required_level, required_skill, required_skill_rank,
      required_spell, required_honor_rank, required_city_rank,
      required_reputation_faction, required_reputation_rank,
      max_count, stackable, container_slots,
      stat_type1, stat_value1, stat_type2, stat_value2,
      stat_type3, stat_value3, stat_type4, stat_value4,
      stat_type5, stat_value5, stat_type6, stat_value6,
      stat_type7, stat_value7, stat_type8, stat_value8,
      stat_type9, stat_value9, stat_type10, stat_value10,
      delay, range_mod, ammo_type,
      dmg_min1, dmg_max1, dmg_type1,
      dmg_min2, dmg_max2, dmg_type2,
      dmg_min3, dmg_max3, dmg_type3,
      dmg_min4, dmg_max4, dmg_type4,
      dmg_min5, dmg_max5, dmg_type5,
      block, armor, holy_res, fire_res, nature_res, frost_res, shadow_res, arcane_res,
      spellid_1, spelltrigger_1, spellcharges_1, spellppmrate_1, spellcooldown_1, spellcategory_1, spellcategorycooldown_1,
      spellid_2, spelltrigger_2, spellcharges_2, spellppmrate_2, spellcooldown_2, spellcategory_2, spellcategorycooldown_2,
      spellid_3, spelltrigger_3, spellcharges_3, spellppmrate_3, spellcooldown_3, spellcategory_3, spellcategorycooldown_3,
      spellid_4, spelltrigger_4, spellcharges_4, spellppmrate_4, spellcooldown_4, spellcategory_4, spellcategorycooldown_4,
      spellid_5, spelltrigger_5, spellcharges_5, spellppmrate_5, spellcooldown_5, spellcategory_5, spellcategorycooldown_5,
      bonding, page_text, page_language, page_material, start_quest, lock_id, material, sheath,
      random_property, set_id, max_durability, area_bound, map_bound, duration, bag_family,
      disenchant_id, food_type, min_money_loot, max_money_loot,
      wrapped_gift, extra_flags, other_team_entry
    )
    SELECT
      %d AS entry,
      patch,
      class,
      subclass,
      '%s' AS name,
      '%s' AS description,
      %d AS display_id,
      quality,
      flags,
      buy_count, buy_price, sell_price,
      inventory_type, allowable_class, allowable_race,
      item_level, required_level, required_skill, required_skill_rank,
      required_spell, required_honor_rank, required_city_rank,
      required_reputation_faction, required_reputation_rank,
      max_count, stackable, container_slots,
      stat_type1, stat_value1, stat_type2, stat_value2,
      stat_type3, stat_value3, stat_type4, stat_value4,
      stat_type5, stat_value5, stat_type6, stat_value6,
      stat_type7, stat_value7, stat_type8, stat_value8,
      stat_type9, stat_value9, stat_type10, stat_value10,
      delay, range_mod, ammo_type,
      dmg_min1, dmg_max1, dmg_type1,
      dmg_min2, dmg_max2, dmg_type2,
      dmg_min3, dmg_max3, dmg_type3,
      dmg_min4, dmg_max4, dmg_type4,
      dmg_min5, dmg_max5, dmg_type5,
      block, armor, holy_res, fire_res, nature_res, frost_res, shadow_res, arcane_res,
      spellid_1, spelltrigger_1, spellcharges_1, spellppmrate_1, spellcooldown_1, spellcategory_1, spellcategorycooldown_1,
      spellid_2, spelltrigger_2, spellcharges_2, spellppmrate_2, spellcooldown_2, spellcategory_2, spellcategorycooldown_2,
      spellid_3, spelltrigger_3, spellcharges_3, spellppmrate_3, spellcooldown_3, spellcategory_3, spellcategorycooldown_3,
      spellid_4, spelltrigger_4, spellcharges_4, spellppmrate_4, spellcooldown_4, spellcategory_4, spellcategorycooldown_4,
      spellid_5, spelltrigger_5, spellcharges_5, spellppmrate_5, spellcooldown_5, spellcategory_5, spellcategorycooldown_5,
      bonding, page_text, page_language, page_material, start_quest, lock_id, material, sheath,
      random_property, set_id, max_durability, area_bound, map_bound, duration, bag_family,
      disenchant_id, food_type, min_money_loot, max_money_loot,
      wrapped_gift, extra_flags, other_team_entry
    FROM item_template
    WHERE entry = %d
      AND NOT EXISTS (SELECT 1 FROM item_template WHERE entry = %d);
    ]]

    WorldDBExecute(string.format(sql,
        new_entry,
        name,
        desc,
        displayId,
        orig_entry,
        new_entry
    ))

    print(string.format("Clone attempt: orig_entry=%d -> new_entry=%d (name: %s)", orig_entry, new_entry, name))
end

-- 配置表：所有需要克隆的“积分物品”
local CreditItemConfig = {
    -- 每日红包本体（参考 21746，自定义显示）
    { src = 21746, entry = 62000, name = "每日宣传红包", desc = "使用后获得随机积分", display = 34361 },

    -- 各种积分卡（参考 117） -- 各种积分卡（参考 117）
    -- 下面示范：1积分卡从红包里掉 30%，其他先不设（你可以自己填）
    -- { src = 117, entry = 62001, name = "1积分",   desc = "使用后获得1个积分",   display = 24730, amount = 1,   lootChance = 30 },
    { src = 117, entry = 62002, name = "10积分",  desc = "使用后获得10个积分",  display = 24730, amount = 10,  lootChance = 50 },
    { src = 117, entry = 62003, name = "20积分",  desc = "使用后获得20个积分",  display = 24730, amount = 20,  lootChance = 30 },
    { src = 117, entry = 62004, name = "50积分",  desc = "使用后获得50个积分",  display = 24730, amount = 50,  lootChance = 15 },
    { src = 117, entry = 62005, name = "100积分", desc = "使用后获得100个积分", display = 24730, amount = 100, lootChance = 4 },
    { src = 117, entry = 62006, name = "500积分", desc = "使用后获得500个积分", display = 24730, amount = 500, lootChance = 0.9 },
    { src = 117, entry = 62007, name = "1000积分", desc = "使用后获得1000个积分", display = 24730, amount = 1000, lootChance = 0.1 },

}

-- 执行克隆（循环）
for _, cfg in ipairs(CreditItemConfig) do
    CloneItemTemplate(cfg.src, cfg.entry, {
        name        = cfg.name,
        description = cfg.desc,
        display_id  = cfg.display,
        -- 这里 quality / flags 如需要可在 cfg 里再加字段
        -- quality   = 1,
        -- flags     = 4,
    })
end

print("Clone done !!!!!!!!!!!!")

--------------------------------
-- 2. 红包 → 积分卡 掉落关系
--------------------------------

local RED_ENVELOPE_ENTRY = 62000   -- 打开的红包物品

-- 先清空这个红包的旧掉落配置
-- WorldDBExecute(string.format(
--     "DELETE FROM item_loot_template WHERE entry = %d;",
--     RED_ENVELOPE_ENTRY
-- ))

-- 再根据配置表写入新的掉落关系
for _, cfg in ipairs(CreditItemConfig) do
    if cfg.lootChance and cfg.lootChance > 0 then
        local sql = string.format([[
            INSERT INTO item_loot_template
                (`entry`, `item`, `ChanceOrQuestChance`, `groupid`, `mincountOrRef`, `maxcount`, `condition_id`, `patch_min`, `patch_max`)
            SELECT
                %d, %d, %f, 1, 1, 1, 0, 7, 10
            FROM DUAL
            WHERE NOT EXISTS (
                SELECT 1 FROM item_loot_template
                WHERE entry = %d AND item = %d
            );
        ]],
        RED_ENVELOPE_ENTRY,   -- 插入值：entry
        cfg.entry,            -- 插入值：item
        cfg.lootChance,       -- 插入值：概率
        RED_ENVELOPE_ENTRY,   -- NOT EXISTS 条件用
        cfg.entry             -- NOT EXISTS 条件用
        )

        WorldDBExecute(sql)
        print(string.format(
            "LootConfig: 红包 %d -> 物品 %d (chance=%.2f%%, 如果已存在则忽略)",
            RED_ENVELOPE_ENTRY, cfg.entry, cfg.lootChance
        ))
    end
end


print("item_loot_template done !!!!!!!!!!!!")

--------------------------------
-- 3. 使用积分卡时，加对应数量积分
--------------------------------

local ITEM_EVENT_ON_USE = 2

-- 建立 “entry → 积分数” 映射表
local CREDIT_ITEMS = {}
for _, cfg in ipairs(CreditItemConfig) do
    if cfg.amount and cfg.amount > 0 then  -- 红包本体 amount=0, 不加入
        CREDIT_ITEMS[cfg.entry] = cfg.amount
    end
end

local function OnUseCreditItem(event, player, item, target, bag, slot)
    local entry  = item:GetEntry()
    local amount = CREDIT_ITEMS[entry]

    if not amount then
        -- 不是积分卡，丢给其他脚本处理
        return true
    end

    print(string.format("OnUseCreditItem: player=%s entry=%d amount=%d",
        player:GetName(), entry, amount))

    local uid = player:GetAccountId()
    AuthDBExecute(string.format(
        "UPDATE account_money SET moneys = moneys + %d WHERE id = %d",
        amount, uid
    ))

    SendWorldMessage("|cFFFF0000[系统公告]|r恭喜"..GetPlayerInfo(player).." 使用宣传红包获得" ..  amount .. " 积分。")
    player:SendBroadcastMessage("你获得了 " .. amount .. " 积分。")
    player:RemoveItem(entry, 1)

    -- 阻止默认使用逻辑
    return false
end

-- 循环注册所有积分卡的 ITEM_EVENT_ON_USE
for entry, amount in pairs(CREDIT_ITEMS) do
    if amount then   -- 只有有积分的才注册
        RegisterItemEvent(entry, ITEM_EVENT_ON_USE, OnUseCreditItem)
    end
end

print("RegisterItemEvent done !!!!!!!!!!!!")
