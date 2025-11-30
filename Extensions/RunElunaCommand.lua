--[[
    ============================================================
    脚本名称: Eluna命令执行器 (Run Eluna Command)
    脚本功能: 
        这是一个开发工具脚本，允许从游戏内聊天或服务器
        控制台执行Eluna Lua代码。

    主要功能:
        1. 从游戏内聊天执行Lua代码
        2. 从服务器控制台执行Lua代码
        3. 预定义的环境变量（plr, sel, pp）
        4. GM权限检查

    使用说明:
        .eluna pp(GetLuaEngine(), "代码执行者:", plr and plr:GetName() or "console")
        
    预定义变量:
        - plr: 使用命令的玩家，控制台为nil
        - sel: 玩家的选择目标，无选择为nil
        - pp: 向所有人和控制台打印消息的函数

    注意:
        - 代码中的错误只报告给命令调用者（控制台或玩家）
        - 定时事件等延迟操作的错误按正常方式报告到日志
    ============================================================
--]]

-- 允许从游戏内聊天和服务器控制台执行Eluna Lua代码
-- Allows running Eluna lua from ingame chat and from server console

-- 此命令用于开发目的 (This command is intended for development purposes)

-- 使用示例 (Example usage):
-- .eluna pp(GetLuaEngine(), "Code ran by:", plr and plr:GetName() or "console")

-- pp 定义为向服务器所有人和控制台发送消息的函数，便于打印
-- pp is defined to be a function to send a message to everyone on server and to console for easy printing

-- plr 是使用命令的玩家，如果是控制台则为nil
-- plr is the player using the command or nil if command from console

-- sel 是plr的选择目标，如果没有选择则为nil
-- sel is the selection of plr or nil if nothing selected

-- 代码中的错误只报告给命令调用者（控制台或玩家），不会记录到日志
-- errors in the lua code executed are printed to command invoker only (console or player), they are not logged

-- 定时事件等延迟操作的错误按正常方式报告到Eluna设置定义的错误日志和控制台
-- errors in timed events made with the code and such delayed actions are reported by normal means to the error logs and console if so defined in Eluna settings.

local runcmd = "eluna"  -- 命令名称 (Command name)
local mingmrank = 3     -- 最低GM等级要求 (Minimum GM rank required)

-- 命令处理函数 (Command handler function)
local function RunCommand(event, player, cmd)
    -- 检查权限和命令格式 (Check permission and command format)
    if ((not player or player:GetGMRank() >= mingmrank) and cmd:lower():find("^"..runcmd.." .+")) then
        -- 这里可以为代码定义一些环境变量 (Here you can define some environment variables for the code)
        -- 我定义了plr为玩家或nil (I defined plr to be the player or nil)
        -- sel为玩家的当前选择目标或nil (sel to be the current selection of the player or nil)
        -- pp用于向所有人和控制台打印传递的参数 (pp to print the passed arguments to everyone and to console)
        local env = [[
            local plr = ...
            local sel = sel
            local pp = function(...)
                local t = {...}
                for i = 1, select("#", ...) do t[i] = tostring(t[i]) end
                local msg = table.concat(t, " ")
                SendWorldMessage(msg)
                print(msg)
            end
            if (plr) then
                sel = plr:GetSelection()
            end
        ]]
        local code = env..cmd:sub(#runcmd+2) -- 提取命令后的代码部分 (Extract code part after command)
        local func, err = load(code, "."..runcmd) -- 加载代码 (Load code)
        if (func) then
            local res
            res, err = pcall(func, player) -- 执行代码 (Execute code)
            if (res) then
                return false -- 执行成功 (Execution successful)
            end
        end
        -- 报告错误 (Report error)
        if (not player) then
            print(err) -- 输出到控制台 (Output to console)
        else
            player:SendBroadcastMessage(err) -- 发送给玩家 (Send to player)
        end
        return false
    end
end

-- 注册玩家命令事件 (Register player command event)
RegisterPlayerEvent(42, RunCommand) -- 42 = 玩家命令事件 (Player command event)
