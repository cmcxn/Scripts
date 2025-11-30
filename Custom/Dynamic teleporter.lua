--[[
    ============================================================
    脚本名称: 动态传送器 (Dynamic Teleporter)
    脚本功能: 
        这是一个动态传送NPC脚本，允许玩家通过对话菜单
        传送到预设的各种地点。
        
    主要功能:
        1. 根据玩家阵营显示不同的传送选项
        2. 支持主菜单和子菜单的层级结构
        3. 支持部落/联盟/双阵营传送点配置
        4. 传送玩家到指定坐标位置
        
    配置说明:
        - 第一行是主菜单ID和标题，以及阵营限制
        - 0 = 联盟 (Alliance), 1 = 部落 (Horde), 2 = 双阵营 (Both)
        - 子菜单包含地点名称和传送坐标 (Map, X, Y, Z, O)
    ============================================================
    
    = 如何添加新地点 (How to add new locations) =

    示例 (Example):

    第一行是主菜单ID (这里是[1], 每个主菜单选项递增!),
    主菜单对话标题 (这里是"Horde Cities"),
    以及哪个阵营可以使用该菜单 (这里是1表示部落)。
    0 = 联盟 (Alliance), 1 = 部落 (Horde), 2 = 双阵营 (Both)

    第二行是主菜单的子菜单名称,
    按名称 (这里是"Orgrimmar") 和传送坐标分隔
    使用 Map, X, Y, Z, O (这里是 1, 1503, -4415.5, 22, 0)

    [1] = { "Horde Cities", 1,	--  这将是主菜单标题，以及哪个阵营可以使用该菜单
        {"Orgrimmar", 1, 1503, -4415.5, 22, 0},
    },

    你可以复制粘贴上面的内容到脚本中并按说明修改值。
]==]

local UnitEntry = 1 -- 传送NPC的Entry ID (Teleporter NPC entry ID)

-- 传送地点配置表 (Teleport locations configuration table)
local T = {
	[1] = { "部落主城 (Horde Cities)", 1, -- 部落阵营专用 (Horde faction only)
		{"奥格瑞玛 (Orgrimmar)", 1, 1503, -4415.5, 22, 0},
		{"幽暗城 (Undercity)", 0, 1831, 238.5, 61.6, 0},
		{"雷霆崖 (Thunderbluff)", 1, -1278, 122, 132, 0},
		{"银月城 (Silvermoon)", 530, 9484, -7294, 15, 0},
	},
	[2] = { "联盟主城 (Alliance Cities)", 0, -- 联盟阵营专用 (Alliance faction only)
		{"暴风城 (Stormwind)", 0, -8905, 560, 94, 0.62},
		{"铁炉堡 (Ironforge)", 0, -4795, -1117, 499, 0},
		{"达纳苏斯 (Darnassus)", 1, 9952, 2280.5, 1342, 1.6},
		{"埃索达 (The Exodar)", 530, -3863, -11736, -106, 2},
	},
	[3] = { "外域地点 (Outlands Locations)", 2, -- 双阵营可用 (Both factions)
		{"刀锋山 (Blade's Edge Mountains)", 530, 1481, 6829, 107, 6},
		{"地狱火半岛 (Hellfire Peninsula)", 530, -249, 947, 85, 2},
		{"纳格兰 (Nagrand)", 530, -1769, 7150, -9, 2},
		{"虚空风暴 (Netherstorm)", 530, 3043, 3645, 143, 2},
		{"影月谷 (Shadowmoon Valley)", 530, -3034, 2937, 87, 5},
		{"泰罗卡森林 (Terokkar Forest)", 530, -1942, 4689, -2, 5},
		{"赞加沼泽 (Zangarmarsh)", 530, -217, 5488, 23, 2},
		{"沙塔斯城 (Shattrath)", 530, -1822, 5417, 1, 3},
	},
	[4] = { "诺森德地点 (Northrend Locations)", 2, -- 双阵营可用 (Both factions)
		{"北风苔原 (Borean Tundra)", 571, 3230, 5279, 47, 3},
		{"晶歌森林 (Crystalsong Forest)", 571, 5732, 1016, 175, 3.6},
		{"龙骨荒野 (Dragonblight)", 571, 3547, 274, 46, 1.6},
		{"灰熊丘陵 (Grizzly Hills)", 571, 3759, -2672, 177, 3},
		{"嚎风峡湾 (Howling Fjord)", 571, 772, -2905, 7, 5},
		{"冰冠冰川 (Icecrown Glaicer)", 571, 8517, 676, 559, 4.7},
		{"索拉查盆地 (Sholazar Basin)", 571, 5571, 5739, -75, 2},
		{"风暴峭壁 (Storm Peaks)", 571, 6121, -1025, 409, 4.7},
		{"冬拥湖 (Wintergrasp)", 571, 5135, 2840, 408, 3},
		{"祖达克 (Zul'Drak)", 571, 5761, -3547, 387, 5},
		{"达拉然 (Dalaran)", 571, 5826, 470, 659, 1.4},
	},
	[5] = { "PvP地点 (PvP Locations)", 2, -- 双阵营可用 (Both factions)
		{"古拉巴什竞技场 (Gurubashi Arena)", 0, -13229, 226, 33, 1},
		{"厄运之槌竞技场 (Dire Maul Arena)", 1, -3669, 1094, 160, 3},
		{"纳格兰竞技场 (Nagrand Arena)", 530, -1983, 6562, 12, 2},
		{"刀锋山竞技场 (Blade's Edge Arena)", 530, 2910, 5976, 2, 4},
	},
}

-- ============================================================
-- 代码部分！请勿编辑以下内容！除非你知道自己在做什么！
-- CODE STUFFS! DO NOT EDIT BELOW UNLESS YOU KNOW WHAT YOU'RE DOING!
-- ============================================================

-- 当玩家与NPC对话时触发 (Triggered when player talks to NPC)
local function OnGossipHello(event, player, unit)
    -- 显示主菜单 (Show main menu)
    for i, v in ipairs(T) do
        -- 检查阵营限制：2表示双阵营可用，否则需要匹配玩家阵营
        -- Check faction restriction: 2 means both factions, otherwise match player faction
        if (v[2] == 2 or v[2] == player:GetTeam()) then
            player:GossipMenuAddItem(0, v[1], i, 0)
        end
    end
    player:GossipSendMenu(1, unit)
end	

-- 当玩家选择菜单项时触发 (Triggered when player selects a menu option)
local function OnGossipSelect(event, player, unit, sender, intid, code)
    if (sender == 0) then
        -- 返回主菜单 (return to main menu)
        OnGossipHello(event, player, unit)
        return
    end

    if (intid == 0) then
        -- 显示传送菜单 (Show teleport menu)
        for i, v in ipairs(T[sender]) do
            if (i > 2) then -- 跳过前两个元素（标题和阵营） (Skip first two elements - title and faction)
                player:GossipMenuAddItem(0, v[1], sender, i)
            end
        end
        player:GossipMenuAddItem(0, "返回 (Back)", 0, 0)
        player:GossipSendMenu(1, unit)
        return
    else
        -- 执行传送 (teleport)
        local name, map, x, y, z, o = table.unpack(T[sender][intid])
        player:Teleport(map, x, y, z, o)
    end
    
    player:GossipComplete()
end

-- 注册NPC对话事件 (Register NPC gossip events)
RegisterCreatureGossipEvent(UnitEntry, 1, OnGossipHello)  -- 注册对话开始事件 (Register gossip hello event)
RegisterCreatureGossipEvent(UnitEntry, 2, OnGossipSelect) -- 注册对话选择事件 (Register gossip select event)
