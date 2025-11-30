--[[
    ============================================================
    脚本名称: SQL数据库传送器 (SQL Teleporter)
    脚本功能: 
        这是一个基于SQL数据库的传送NPC脚本，所有传送点
        配置存储在数据库中，支持动态添加和修改传送点。

    主要功能:
        1. 从数据库加载传送点配置
        2. 支持多层级子菜单结构
        3. 支持按阵营限制传送点
        4. 支持自定义菜单图标
        5. 自动创建数据库表结构

    数据库表字段说明:
        - id: 唯一标识ID
        - parent: 父菜单ID (0表示主菜单)
        - type: 类型 (1=子菜单, 2=传送点)
        - faction: 阵营限制 (-1=双阵营, 0=联盟, 1=部落)
        - icon: 菜单图标ID
        - name: 菜单名称
        - map: 地图ID
        - x, y, z, o: 坐标

    配置说明:
        - entry: NPC的Entry ID
    ============================================================
--]]

local Teleporter = {
    entry = 823 -- 传送NPC的Entry ID (Unit entry)
}

-- ============================================================
-- 以下内容请勿编辑 (Do not edit anything below this line)
-- ============================================================

-- 当玩家与NPC对话时触发 (Triggered when player talks to NPC)
function Teleporter.OnHello(event, player, unit)
    -- 遍历所有传送选项 (Iterate through all teleport options)
    for k, v in pairs(Teleporter["Options"]) do
        -- 检查阵营限制和是否为主菜单项 (Check faction restriction and if it's a main menu item)
        if(player:GetTeam() == v["faction"] or v["faction"] == -1) and ( v["parent"] == 0) then
            player:GossipMenuAddItem(v["icon"], v["name"], 0, k)
        end
    end
    player:GossipSendMenu(1, unit)
end

-- 当玩家选择菜单项时触发 (Triggered when player selects a menu option)
function Teleporter.OnSelect(event, player, unit, sender, intid, code)
    local t = Teleporter["Options"]
    
    if(intid == 0) then -- 返回主菜单的特殊处理 (Special handling for "Back" option in case parent is 0)
        Teleporter.OnHello(event, player, unit)
    elseif(t[intid]["type"] == 1) then
        -- 类型1是子菜单，显示子菜单项 (Type 1 is submenu, show submenu items)
        -- 使用两次循环确保结果排序 (Hacky loops, but I want the results to be sorted damnit)
        for i = 1, 2 do
            for k, v in pairs(t) do
                -- 显示属于当前子菜单的项目 (Show items belonging to current submenu)
                if(v["parent"] == intid and v["type"] == i and (player:GetTeam() == v["faction"] or v["faction"] == -1)) then
                    player:GossipMenuAddItem(v["icon"], v["name"], 0, k)
                end
            end
        end
        player:GossipMenuAddItem(7, "[返回] ([Back])", 0, t[intid]["parent"])
        player:GossipSendMenu(1, unit)
    elseif(t[intid]["type"] == 2) then
        -- 类型2是传送点，执行传送 (Type 2 is teleport point, execute teleport)
        player:Teleport(t[intid]["map"], t[intid]["x"], t[intid]["y"], t[intid]["z"], t[intid]["o"])
    end
end

-- 从数据库加载传送点缓存 (Load teleport cache from database)
function Teleporter.LoadCache()
    Teleporter["Options"] = {} -- 初始化选项表 (Initialize options table)

    -- 检查数据库表是否存在 (Check if database table exists)
    if not(WorldDBQuery("SHOW TABLES LIKE 'eluna_teleporter';")) then
        print("[E-SQL Teleporter]: 世界数据库中缺少eluna_teleporter表。(eluna_teleporter table missing from world database.)")
        print("[E-SQL Teleporter]: 正在创建表结构，初始化缓存。(Inserting table structure, initializing cache.)")
        WorldDBQuery("CREATE TABLE `eluna_teleporter` (`id` int(5) NOT NULL AUTO_INCREMENT,`parent` int(5) NOT NULL DEFAULT '0',`type` int(1) NOT NULL DEFAULT '1',`faction` int(2) NOT NULL DEFAULT '-1',`icon` int(2) NOT NULL DEFAULT '0',`name` char(20) NOT NULL DEFAULT '',`map` int(5) DEFAULT NULL,`x` decimal(10,3) DEFAULT NULL,`y` decimal(10,3) DEFAULT NULL,`z` decimal(10,3) DEFAULT NULL,`o` decimal(10,3) DEFAULT NULL,PRIMARY KEY (`id`) ) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=latin1;")
        return Teleporter.LoadCache();
    end
    
    -- 从数据库加载所有传送点 (Load all teleport points from database)
    local Query = WorldDBQuery("SELECT * FROM eluna_teleporter;")
    if(Query) then
        repeat
            Teleporter["Options"][Query:GetUInt32(0)] = {
                parent = Query:GetUInt32(1),  -- 父菜单ID (parent menu ID)
                type = Query:GetUInt32(2),    -- 类型：1=子菜单, 2=传送点 (type: 1=submenu, 2=teleport)
                faction = Query:GetInt32(3),  -- 阵营限制 (faction restriction)
                icon = Query:GetInt32(4),     -- 图标ID (icon ID)
                name = Query:GetString(5),    -- 名称 (name)
                map = Query:GetUInt32(6),     -- 地图ID (map ID)
                x = Query:GetFloat(7),        -- X坐标 (X coordinate)
                y = Query:GetFloat(8),        -- Y坐标 (Y coordinate)
                z = Query:GetFloat(9),        -- Z坐标 (Z coordinate)
                o = Query:GetFloat(10),       -- 朝向 (orientation)
            };
        until not Query:NextRow()
        print("[E-SQL Teleporter]: 缓存初始化完成，已加载 "..Query:GetRowCount().." 个传送点。(Cache initialized. Loaded "..Query:GetRowCount().." results.)")
    else
        print("[E-SQL Teleporter]: 缓存初始化完成，未找到传送点。(Cache initialized. No results found.)")
    end
end

-- 初始化缓存 (Initialize cache)
Teleporter.LoadCache()

-- 注册NPC对话事件 (Register NPC gossip events)
RegisterCreatureGossipEvent(Teleporter.entry, 1, Teleporter.OnHello)  -- 注册对话开始事件 (Register gossip hello event)
RegisterCreatureGossipEvent(Teleporter.entry, 2, Teleporter.OnSelect) -- 注册对话选择事件 (Register gossip select event)