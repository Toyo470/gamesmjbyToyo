require("framework.init")


local ServerBase = import("socket.ServerBase")
local majiangServer = class("majiangServer",ServerBase)
local PROTOCOL = import("xl_majiang.scenes.Majiang_Protocol")
function majiangServer:ctor()
    
end

function majiangServer:ctor()
    majiangServer.super.ctor(self, "majiangServer", PROTOCOL)
end

function majiangServer:LoginGame(level)

    if bm.server == nil then
        return
    end

    local mode = require("hall.gameSettings"):getGameMode()
    print("majiangServer:LoginGame",mode)

    --请求进入自由场游戏
    if mode == "free" or mode == "fast" then

        local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_GET_ROOM)
                    :setParameter("level", level)
                    :setParameter("Chip", 100)
                    :setParameter("Sid", 1)
                    :setParameter("activity_id", "")
                    :build()
        bm.server:send(pack)

        dump("请求进入自由场游戏", "请求进入自由场游戏")

    end

    --进入组局
    if mode == "group" then

        local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_GET_ROOM)
                    :setParameter("level", level)
                    :setParameter("Chip", 100)
                    :setParameter("Sid", 1)
                    :setParameter("activity_id", USER_INFO["activity_id"])
                    :build()
        bm.server:send(pack)

        dump("进入组局", "-----血流成河初始化-----")
        
    end

end

function majiangServer:LoginRoom(tid)
    if bm.server == nil then
        return
    end
end

--请求退出房间
function majiangServer:CLI_LOGOUT_ROOM()
    if bm.server == nil then
        return
    end
    -- body
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_LOGOUT_ROOM)
        :build()
    bm.server:send(pack)

    local btnEixt   = SCENENOW["scene"]:getChildByName("btn_exit")
    if btnEixt then
        btnEixt:setTouchEnabled(false)
    end
end
--请求退出比赛
function majiangServer:CLI_SEND_LOGOUT_MATCH(match_id)
    -- body
    if bm.server == nil then
        return
    end
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_SEND_LOGOUT_MATCH)
        :setParameter("MatchID", match_id)
        :setParameter("nUserId", USER_INFO["uid"])
        :build()
    bm.server:send(pack)
end

--游戏准备
function majiangServer:CLI_READY_GAME()
    -- body
    if bm.server == nil then
        return
    end
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_READY_GAME)
        :build()
    bm.server:send(pack)
end

--过牌
function majiangServer:CLI_PASS()
    -- body
    if bm.server == nil then
        return
    end
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_PASS)
                :build()
    bm.server:send(pack)
end

--比赛报名
function majiangServer:CLI_SEND_JOIN_MATCH(level)

    if bm.server == nil then
        return
    end
    print("jion_match:"..tostring(level))
    print("taotaotaotao")
    require("hall.gameSettings"):setGameMode("match")
    -- body
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_SEND_JOIN_MATCH)
        :setParameter("Level", level)
        :setParameter("flag", 1)
        :build(1)
    bm.server:send(pack)
end

--自动托管
function majiangServer:CLI_AUTO(action)
    -- body
    if bm.server == nil then
        return
    end
    local flag = action
    if flag < 0 then
        flag = 0
    elseif flag > 1 then
        flag = 1
    end
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_AUTO)
                :setParameter("action", action)
                :build()
    bm.server:send(pack)
end

--围观进入房间
function majiangServer:CLI_LOGIN_ROOM_ONLOOK(tid,onLookId)
    local sendpack = bm.server:createPacketBuilder(PROTOCOL.CLI_LOGIN_ROOM_ONLOOK)
                    :setParameter("tableid", tid)
                    :setParameter("nUserId", USER_INFO["uid"])
                    :setParameter("on_look_uid", onLookId)
                    :setParameter("strkey", json.encode("kadlelala"))
                    :setParameter("strinfo", USER_INFO["user_info"])
                    :setParameter("iflag", 1)
                    :setParameter("version", 1)
                    :build()
    bm.server:send(sendpack)

    --准备围观
    require("ddz.ddzSettings"):setLookState(1)
end

--退出围观
function majiangServer:CLI_REQUEST_LOOK_OUT(tid,onLookId)
    local sendpack = bm.server:createPacketBuilder(PROTOCOL.CLI_REQUEST_LOOK_OUT)
                    :setParameter("tid", tid)
                    :setParameter("uid", USER_INFO["uid"])
                    :setParameter("onlook_uid", onLookId)
                    :build()
    bm.server:send(sendpack)
end

--请求记牌器历史
function majiangServer:CLI_REQUEST_CALC_HISTORY()
    local sendpack = bm.server:createPacketBuilder(PROTOCOL.CLI_REQUEST_CALC_HISTORY)
                    :build()
    bm.server:send(sendpack)
end


--
function majiangServer:CLI_MSG_FACE(id)
    local sendpack = bm.server:createPacketBuilder(PROTOCOL.CLI_MSG_FACE)
                    :setParameter("type", id)
                    :build()
    bm.server:send(sendpack)
end

--开直播
function majiangServer:CLI_SEND_LIVE_ADDRESS(addr,flag)

    print("send LIVE_ADDRESS ",USER_INFO["uid"],addr,flag);
    local sendpack = bm.server:createPacketBuilder(PROTOCOL.CLI_SEND_LIVE_ADDRESS)
                    :setParameter("live_addr", addr)
                    :setParameter("flag", flag)
                    :build()
    bm.server:send(sendpack)
end

return majiangServer