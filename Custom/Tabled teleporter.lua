--[[
    ============================================================
    脚本名称: 表格式多层传送器 (Tabled Multi-Menu Teleporter)
    脚本功能: 
        这是一个基于表格的多层级传送脚本，允许玩家通过
        对话菜单传送到预设的各种地点，支持无限层级的子菜单。
        
    主要功能:
        1. 支持多层级嵌套的子菜单结构
        2. 支持密码保护的传送点
        3. 支持自定义图标
        4. 支持返回上级菜单
        5. 自动分析和导出传送点配置
        
    配置说明:
        - name: 地点名称或子菜单名称
        - mapid: 地图ID (如果是传送点)
        - x, y, z, o: 坐标 (如果是传送点)
        - pass: 密码 (可选)
        - icon: 图标ID (可选)
        
    原作者: Kenuvis
    日期: 23.07.2012
    转换为Eluna: Rochet2 于 9.6.2015
    ============================================================
--]]

-- 项目: 基于表格的多菜单传送脚本 (Projekt: Tablebased multimenu Teleportscript)
-- 代码: Kenuvis (Code: Kenuvis)
-- 日期: 23.07.2012 (Date: 23.07.2012)
-- 转换为Eluna: Rochet2 于 9.6.2015 (Convert to Eluna by Rochet2 on 9.6.2015)

print("########")
print("多层传送器加载中... (Multiteleporter loaded...)")

local NPCID = 40478 -- 传送NPC的Entry ID (Teleporter NPC entry ID)
local teleport = {}

-- 默认设置 (Default settings)
teleport.StandardTeleportIcon = 2 -- 默认传送点图标 (Default teleport icon)
teleport.StandardMenuIcon = 3    -- 默认菜单图标 (Default menu icon)
teleport.WrongPassText = "密码错误！(Wrong Password!)" -- 密码错误提示 (Wrong password message)

-- 传送点配置表 (Teleport locations configuration table)
-- 支持多层嵌套子菜单结构 (Supports multi-level nested submenu structure)
teleport.ports = {
    {name = "地点1 (Location 1)", mapid = 1, x = 2, y = 3, z = 4, o = 5},
    {name = "地点2-需密码 (Location 2)", mapid = 1, x = 2, y = 3, z = 4, o = 5, pass = "password"}, -- 需要密码 (Requires password)
    {name = "地点3-自定义图标 (Location 3)", mapid = 1, x = 2, y = 3, z = 4, o = 5, icon = 4}, -- 自定义图标 (Custom icon)
    {name = "子菜单1 (SubMenu1)", -- 子菜单示例 (Submenu example)
        {name = "地点4 (Location 4)", mapid = 1, x = 2, y = 3, z = 4, o = 5},
        {name = "地点5 (Location 5)", mapid = 1, x = 2, y = 3, z = 4, o = 5},
        {name = "地点6 (Location 6)", mapid = 1, x = 2, y = 3, z = 4, o = 5},
        {name = "子子菜单1 (SubSubMenu1)", -- 嵌套子菜单 (Nested submenu)
            {name = "地点7 (Location 7)", mapid = 1, x = 2, y = 3, z = 4, o = 5},
            {name = "地点8 (Location 8)", mapid = 1, x = 2, y = 3, z = 4, o = 5},
            {name = "地点9 (Location 9)", mapid = 1, x = 2, y = 3, z = 4, o = 5},
            {name = "测试 (test)", -- 更深层嵌套 (Deeper nesting)
                {name = "地点7 (Location 7)", mapid = 1, x = 2, y = 3, z = 4, o = 5},
                {name = "地点8 (Location 8)", mapid = 1, x = 2, y = 3, z = 4, o = 5},
                {name = "地点9 (Location 9)", mapid = 1, x = 2, y = 3, z = 4, o = 5},
            },
        },
    },
}

-- ============================================================
-- 以下内容请勿修改！ (Nothing change after this!)
-- ============================================================

local IDcount = 1     -- ID计数器 (ID counter)
teleport.Menu = {}    -- 菜单缓存表 (Menu cache table)

-- 分析并导出传送点配置 (Analyse and export teleport configuration)
-- list: 传送点列表 (teleport list)
-- from: 父菜单ID (parent menu ID)
function teleport.Analyse(list, from)
    for k,v in ipairs(list) do
        v.ID = IDcount       -- 分配唯一ID (Assign unique ID)
        v.FROM = from        -- 记录父菜单ID (Record parent menu ID)
        v.ICON = v.icon or teleport.StandardTeleportIcon -- 设置图标 (Set icon)
        IDcount = IDcount + 1
        teleport.Menu[v.ID] = v

        -- 如果没有mapid，说明是子菜单，递归分析 (If no mapid, it's a submenu, analyse recursively)
        if not v.mapid then
            teleport.Menu[v.ID].ICON = v.icon or teleport.StandardMenuIcon
            teleport.Analyse(v, v.ID)
        end
    end
end

print("导出传送点... (Export Teleports...)")
teleport.Analyse(teleport.ports, 0)
print("导出完成 (Export complete)")

-- 在表中查找指定值 (Find value in table)
table.find = function(_table, _tofind, _index)
    for k,v in pairs(_table) do
        if _index then
            if v[_index] == _tofind then
                return k
            end
        else
            if v == _tofind then
                return k
            end
        end
    end
end

-- 在表中查找所有匹配的值 (Find all matching values in table)
table.findall = function(_table, _tofind, _index)
    local result = {}
    for k,v in pairs(_table) do
        if _index then
            if v[_index] == _tofind then
                table.insert(result, v)
            end
        else
            if v == _tofind then
                table.insert(result, v)
            end
        end
    end
    return result
end

-- 构建对话菜单 (Build gossip menu)
-- Unit: NPC对象 (NPC object)
-- Player: 玩家对象 (Player object)
-- from: 父菜单ID (Parent menu ID)
function teleport.BuildMenu(Unit, Player, from)
    local MenuTable = table.findall(teleport.Menu, from, "FROM")

    -- 添加当前菜单的所有选项 (Add all options for current menu)
    for _,entry in ipairs(MenuTable) do
        Player:GossipMenuAddItem(entry.ICON, entry.name, 0, entry.ID, entry.pass)
    end
    
    -- 如果不是主菜单，添加返回按钮 (If not main menu, add back button)
    if from > 0 then
        local GoBack = teleport.Menu[table.find(teleport.Menu, from, "ID")].FROM
        Player:GossipMenuAddItem(7, "返回.. (Back..)", 0, GoBack)
    end
    Player:GossipSendMenu(1, Unit)
end

-- 处理对话事件 (Handle gossip events)
function teleport.OnTalk(Event, Player, Unit, _, ID, Password)
    if Event == 1 or ID == 0 then
        -- 显示主菜单 (Show main menu)
        teleport.BuildMenu(Unit, Player, 0)
    else
        local M = teleport.Menu[table.find(teleport.Menu, ID, "ID")]
        if not M then error("这不应该发生 (This should not happen)") end

        -- 检查密码 (Check password)
        if M.pass then
            if Password ~= M.pass then
                Player:SendNotification(teleport.WrongPassText)
                Player:GossipComplete()
                return
            end
        end

        -- 如果有mapid，执行传送；否则显示子菜单 (If has mapid, teleport; otherwise show submenu)
        if M.mapid then
            Player:Teleport(M.mapid, M.x, M.y, M.z, M.o)
            Player:GossipComplete()
            return
        end

        teleport.BuildMenu(Unit, Player, ID)
    end
end

-- 注册NPC对话事件 (Register NPC gossip events)
print("注册NPC: (Register NPC:) "..NPCID)
RegisterCreatureGossipEvent(NPCID, 1, teleport.OnTalk) -- 注册对话开始事件 (Register gossip hello event)
RegisterCreatureGossipEvent(NPCID, 2, teleport.OnTalk) -- 注册对话选择事件 (Register gossip select event)

print("多层传送器加载完成 (Multiteleporter loading complete)")
print("########")
