
local PROTOCOL = require("pdk.pdk_PROTOCOL")

local pdkServer = import("pdk.pdkServer")
local pdkHandle  = require("pdk.pdkHandle")

local gameScene = class("gameScene", function()
    return display.newScene("gameScene")
end)


function gameScene:ctor()
    bm.server:setProtocol(PROTOCOL)
    bm.server:setHandle(pdkHandle.new())
    
    --记录房间用户信息
    bm.Room = {}
    bm.Room.UserInfo  = {}
end

function gameScene:onEnter()
    require("hall.GameCommon"):landLoading(true)

        local mode = require("hall.gameSettings"):getGameMode()
        if mode == "free" then
            local adapLevel = require("hall.hall_data"):getAdapterLevel("pdk")
            if adapLevel < 0 then
                require("hall.GameTips"):showTips("余额不足，请充值","change_money",1)
                return
            end
            USER_INFO["gameLevel"] = adapLevel
        end
        pdkServer:LoginGame()
    print("---jianghao")
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

    require("pdk.pdkSettings"):setOnlookTable(tableid)
    --判断当前是否为进入游戏状态，否则继续围观
    local look_state = require("pdk.pdkSettings"):getLookState()
    print("onNetLoginGame lookstate:",look_state)

    -- pdkServer:LoginRoom(tableid)
    require("hall.GameList"):setReloadTable(tableid)
    display_scene("pdk.roomScene", 1)
end


--获取视频录音播放位置
function gameScene:getPosforSeat(uid)
    local pos = cc.p(1000 , 1000)
    return pos
end


return gameScene
