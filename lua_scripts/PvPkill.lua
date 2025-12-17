--[[
PVP击杀和奖励公告lua (改为奖励和减少金币)
]]--
print(">>Script: PvPkill.lua loading...OK")

local GOLD_AMOUNT = 10 -- 击杀后奖励的金币数量
local copperAmount = GOLD_AMOUNT * 10000 -- 将金币转换为铜币单位

local function PvPkill(event, killer, killed)
    -- 发送世界消息，公告击杀信息, 需要的可以删除下面一行的注释
    -- SendWorldMessage("|cFFFF99CC[PVP提示]|r： |h|cFF00FA9A资深玩家|r|Hplayer:"..killer:GetName().."|h|cffff0000["..killer:GetName().."]|r|h 杀死了 |cFF00FA9A菜鸟玩家|r|Hplayer:"..killed:GetName().."|h|cffff0000["..killed:GetName().."]|r|h")

    -- 公告奖励和惩罚
    killer:SendBroadcastMessage("击杀玩家["..killed:GetName().."]获得奖励金币 "..GOLD_AMOUNT.." 金币")
    killed:SendBroadcastMessage("你被["..killer:GetName().."]杀死了, 减少金币 "..GOLD_AMOUNT.." 金币")

    -- 给击杀者奖励金币（铜币单位）
    killer:ModifyMoney(copperAmount)

    -- 检查被击杀者是否有足够的金币，如果金币足够则扣除，否则设为0
    local killedMoney = killed:GetCoinage() -- 获取被击杀者的当前金币(铜币单位)
    if killedMoney >= copperAmount then
        killed:ModifyMoney(-copperAmount) -- 扣除金币（铜币单位）
    else
        killed:ModifyMoney(-killedMoney) -- 如果金币不足，扣除所有剩余金币
    end
end

RegisterPlayerEvent(6, PvPkill)
