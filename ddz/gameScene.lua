
local PROTOCOL = require("ddz.ddz_PROTOCOL")

local ddzServer = import("ddz.ddzServer")
local ddzHandle  = require("ddz.ddzHandle")

local gameScene = class("gameScene", function()
    return display.newScene("gameScene")
end)


function gameScene:ctor()

    bm.server:setProtocol(PROTOCOL)
    bm.server:setHandle(ddzHandle.new())

end

function gameScene:onEnter()

    require("hall.GameCommon"):landLoading(true)

    -- --是否重连机制
    -- local tid = require("hall.GameList"):getReloadTable()
    -- print("ddz.gameScene",tid,require("hall.gameSettings"):getGameMode())
    -- if tid > 0 then
    --     print("table id:",tid)
    --     print("ddzGameMode:",require("hall.gameSettings"):getGameMode())
    --     --重连模式
    --     local mode = require("hall.GameList"):getReloginMode()
    --     print("reloadLoginMode:",mode)
    --     -- ddzServer:LoginRoom(tid)
    --     display_scene("ddz.roomScene", 1)
    --     -- require("hall.GameList"):setReloadTable(0)
    -- else
        local mode = require("hall.gameSettings"):getGameMode()
        if mode == "free" then
            local adapLevel = require("hall.hall_data"):getAdapterLevel("ddz")
            if adapLevel < 0 then
                require("hall.GameTips"):showTips("余额不足，请充值","change_money",1)
                return
            end
            USER_INFO["gameLevel"] = adapLevel
        end
        ddzServer:LoginGame()
    -- end
end

--网络消息返回
function gameScene:onNetLoginGame(pack)
    print("recv LoginGame")
    if pack == nil then
        return
    end

    local tableid = pack["Tid"]
    print("table id:",tableid)
    dump(USER_INFO["user_info"], "user_info")

    require("ddz.ddzSettings"):setOnlookTable(tableid)
    --判断当前是否为进入游戏状态，否则继续围观
    local look_state = require("ddz.ddzSettings"):getLookState()
    print("onNetLoginGame lookstate:",look_state)

    -- ddzServer:LoginRoom(tableid)
    require("hall.GameList"):setReloadTable(tableid)
    display_scene("ddz.roomScene", 1)

end

function gameScene:getPosforSeat(uid)
    return cc.p(1000,1000)
end

return gameScene
