--[[
============================================================
脚本名称: 武器附魔视觉效果 (Weapon Enchant Visuals)
脚本功能: 
    这个脚本为所有拾取的武器添加随机附魔视觉效果。
    这纯粹是视觉效果，实际附魔时视觉效果会被替换。

主要功能:
    1. 拾取武器时有25%几率获得随机附魔视觉效果
    2. 视觉效果保存到数据库，重新登录后仍然有效
    3. 实际附魔武器时会自动替换视觉效果
    4. 完全自动化，只需放入脚本文件夹即可工作

配置说明:
    - chance: 获得视觉效果的几率 (0.0 - 1.0)

作者: Rochet2 - https://rochet2.github.io/
来源: http://emudevs.com/showthread.php/53-Lua-Enchant-visual-system-and-gossip

关于 (About):
所有拾取的武器有25%几率获得随机附魔视觉效果
这纯粹是视觉乐趣，实际附魔时视觉效果会被替换。

此脚本100%自动化。您只需将其放入脚本文件夹即可工作。
============================================================
--]]

--[[
Author: Rochet2 - https://rochet2.github.io/
Source: http://emudevs.com/showthread.php/53-Lua-Enchant-visual-system-and-gossip

About:
All weapons looted have a 25% chance to have a random enchant visual
This is purely visual fun and the visual will be replaced when the weapon is enchanted.

This script is 100% automatic. You can only put it to your script folder and it will work.
]]

local chance = 0.25 -- 获得视觉效果的几率 (25%) (Chance to get visual effect - 25%)

-- ============================================================
-- 以下内容请勿编辑 (Do not edit anything below)
-- ============================================================

-- 创建数据库表用于存储附魔视觉效果数据 (Create database table for storing enchant visual data)
local charactersSQL = [[
CREATE TABLE IF NOT EXISTS `custom_item_enchant_visuals` (
    `iguid` INT(10) UNSIGNED NOT NULL COMMENT 'item DB guid (物品数据库GUID)',
    `display` INT(10) UNSIGNED NOT NULL COMMENT 'enchantID (附魔ID)',
    PRIMARY KEY (`iguid`)
)
COMMENT='stores the enchant IDs for the visuals (存储视觉效果的附魔ID)'
COLLATE='latin1_swedish_ci'
ENGINE=InnoDB;
]]
CharDBQuery(charactersSQL)

-- 脚本变量 (script variables):
local EQUIPMENT_SLOT_MAINHAND = 15 -- 主手装备槽 (Main hand equipment slot)
local EQUIPMENT_SLOT_OFFHAND = 16  -- 副手装备槽 (Off hand equipment slot)
local PLAYER_VISIBLE_ITEM_1_ENCHANTMENT = 284 -- 可见物品附魔字段 (Visible item enchant field)
local PERM_ENCHANTMENT_SLOT = 0 -- 永久附魔槽位 (Permanent enchant slot)
local DD -- 数据缓存表 (Data cache table)

-- 函数声明 (functions)
local LoadDB, setVisual, applyVisuals, LOGIN

-- 从数据库加载附魔视觉数据 (Load enchant visual data from database)
function LoadDB()
    DD = {}
    -- 删除不存在的物品记录 (Delete records for non-existing items)
    CharDBQuery("DELETE FROM custom_item_enchant_visuals WHERE NOT EXISTS(SELECT 1 FROM item_instance WHERE custom_item_enchant_visuals.iguid = item_instance.guid)")
    local Q = CharDBQuery("SELECT iguid, display FROM custom_item_enchant_visuals")
    if (Q) then
        repeat
            local iguid, display = Q:GetUInt32(0), Q:GetUInt32(1)
            DD[iguid] = display
        until not Q:NextRow()
    end
end
LoadDB()

-- 设置物品的视觉效果 (Set visual effect for item)
-- player: 玩家对象 (player object)
-- item: 物品对象 (item object)  
-- display: 附魔视觉效果ID (enchant visual effect ID)
function setVisual(player, item, display)
    if (not player or not item) then return
        false
    end
    local iguid = item:GetGUIDLow()
    local enID = item:GetEnchantmentId(PERM_ENCHANTMENT_SLOT) or 0
    
    -- 如果物品有实际附魔，则使用实际附魔的视觉效果 (If item has real enchant, use real enchant visual)
    if (enID ~= 0) then
        CharDBExecute("DELETE FROM custom_item_enchant_visuals WHERE iguid = "..iguid)
        DD[iguid] = nil
        display = enID
    elseif (not display) then
        -- 如果没有提供display且缓存中没有，返回false (If no display provided and not in cache, return false)
        if (not DD[iguid]) then
            return false
        end
        display = DD[iguid]
    else
        -- 保存新的视觉效果到数据库 (Save new visual effect to database)
        CharDBExecute("REPLACE INTO custom_item_enchant_visuals (iguid, display) VALUES ("..iguid..", "..display..")")
        DD[iguid] = display
    end
    
    -- 如果物品已装备，更新视觉效果 (If item is equipped, update visual)
    if (item:IsEquipped()) then
        player:SetUInt16Value(PLAYER_VISIBLE_ITEM_1_ENCHANTMENT + (item:GetSlot() * 2), 0, display)
    end
    return true
end

-- 应用武器视觉效果 (Apply weapon visuals)
function applyVisuals(player)
    if (not player) then
        return
    end
    -- 遍历主手和副手装备槽 (Iterate through main hand and off hand slots)
    for i = EQUIPMENT_SLOT_MAINHAND, EQUIPMENT_SLOT_OFFHAND do
        setVisual(player, player:GetItemByPos(255, i))
    end
end

-- 玩家登录时应用视觉效果 (Apply visuals when player logs in)
function LOGIN(event, player)
    applyVisuals(player)
end

-- 注册事件 (Register events)
RegisterPlayerEvent(3, LOGIN)  -- 玩家登录事件 (Player login event)
RegisterPlayerEvent(29, function(e,p,i,b,s) setVisual(p, i) end) -- 装备物品事件 (Equip item event)

-- 附魔视觉效果ID列表 (Enchant visual effect IDs)
local E = {3789, 3854, 3273, 3225, 3870, 1899, 2674, 2675, 2671, 2672, 3365, 2673, 2343, 425, 3855, 1894, 1103, 1898, 3345, 1743, 3093, 1900, 3846, 1606, 283, 1, 3265, 2, 3, 3266, 1903, 13, 26, 7, 803, 1896, 2666, 25}

-- 可以添加视觉效果的武器子类型 (Weapon subclasses that can have visual effects)
local SubClasses = {
    [0] = true,  -- 单手斧 (One-Handed Axe)
    [1] = true,  -- 双手斧 (Two-Handed Axe)
    [4] = true,  -- 单手锤 (One-Handed Mace)
    [5] = true,  -- 双手锤 (Two-Handed Mace)
    [6] = true,  -- 长柄武器 (Polearm)
    [7] = true,  -- 单手剑 (One-Handed Sword)
    [8] = true,  -- 双手剑 (Two-Handed Sword)
    [10] = true, -- 法杖 (Staff)
    [11] = true, -- 奇特武器 (Exotic)
    [12] = true, -- 奇特武器2 (Exotic 2)
    [14] = true, -- 杂项 (Miscellaneous)
    [15] = true, -- 匕首 (Dagger)
}

math.randomseed(os.time()) -- 初始化随机种子 (Initialize random seed)

-- 拾取物品时触发 (Triggered when item is looted)
local function ONITEMLOOT(event, player, item, count, guid)
    -- 检查是否为武器类型 (Check if it's a weapon type)
    if (item:GetClass() == 2 and SubClasses[item:GetSubClass()]) then
        if (math.random() < chance) then -- 25%几率获得视觉效果 (25% chance to get visuals)
            setVisual(player, item, E[math.random(#E)]) -- 随机选择一个附魔视觉效果 (Randomly select an enchant visual)
        end
    end
end

RegisterPlayerEvent(32, ONITEMLOOT) -- 注册拾取物品事件 (Register loot item event)
