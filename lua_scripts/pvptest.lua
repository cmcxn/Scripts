
-- 常量：区域更新事件 ID
local PLAYER_EVENT_ON_UPDATE_AREA = 47

-- 需要启用 FFA 的区域或子区域 ID 列表（AreaTable.dbc / area_table.sql 中的 AreaId）
local FFA_AREAS = {
    [2177] = true,    -- 例：荆棘谷 Gurubashi Arena（更换成你的目标区域）
    [9] = true,  -- 例：自定义区域 ID
}

local function OnAreaChanged(event, player, oldArea, newArea)
    print(" OnAreaChanged init 123 "   )
    local inFFA = FFA_AREAS[newArea]
    player:SendBroadcastMessage("你进入了 " .. newArea .. "！")
    if inFFA then
        -- 进入指定区域：打开 FFA + PvP
        player:SetFFA(true)
        player:SetPvP(true)
        player:SendBroadcastMessage("你进入了自由混战区域！")
    elseif FFA_AREAS[oldArea] then
        -- 离开指定区域：关闭 FFA（若想保持 PvP 可移除下一行）
        player:SetFFA(false)
        player:SetPvP(false)
        player:SendBroadcastMessage("你已离开自由混战区域。")
    end
end

RegisterPlayerEvent(PLAYER_EVENT_ON_UPDATE_AREA, OnAreaChanged)
print(" OnAreaChanged init  ok"   )