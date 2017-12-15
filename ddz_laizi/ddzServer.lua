require("framework.init")


local ServerBase = import("socket.ServerBase")
local ddzServer = class("ddzServer",ServerBase)
local PROTOCOL         = import("ddz_laizi.ddz_PROTOCOL")
function ddzServer:ctor()
    
end

function ddzServer:ctor()
    ddzServer.super.ctor(self, "ddzServer", PROTOCOL)
end

function ddzServer:LoginGame()
    if bm.server == nil then
        return
    end
    local mode = require("hall.gameSettings"):getGameMode()
    print("ddzServer:LoginGame",mode)
    -- body
        if mode == "free" or mode == "fast" then--请求进入自由场游戏
            local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_LOGIN_GAME)
            :setParameter("Level", USER_INFO["gameLevel"])
            -- :setParameter("Level", 130)
            :setParameter("Chip", 1)
            :setParameter("Sid", 1)
            :setParameter("activity_id", "")
            :build()
            bm.server:send(pack)
        end
        --进入组局
        if mode == "group" then
            local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_LOGIN_GAME)
            :setParameter("Level", USER_INFO["GroupLevel"] or 35)
            :setParameter("Chip", 1)
            :setParameter("Sid", 1)
            :setParameter("activity_id", USER_INFO["activity_id"])
            :build()
            bm.server:send(pack)
        end
end

function ddzServer:LoginRoom(tid)
    if bm.server == nil then
        return
    end
    -- body
    local mode = require("hall.gameSettings"):getGameMode()
    print("LoginRoom mode:"..mode)
    print("LoginRoom tid:"..tid)
        if mode == "group" then
            local sendpack = bm.server:createPacketBuilder(PROTOCOL.CLI_LOGIN_ROOM_GROUP)
            :setParameter("tableid", tid)
            :setParameter("nUserId", USER_INFO["uid"])
            :setParameter("strkey", json.encode("kadlelala"))
            :setParameter("strinfo", USER_INFO["user_info"])
            :setParameter("iflag", 2)
            :setParameter("version", 1)
            :setParameter("activity_id", USER_INFO["activity_id"])
            :build()
            bm.server:send(sendpack)
        else
            local sendpack = bm.server:createPacketBuilder(PROTOCOL.CLI_LOGIN_ROOM)
            :setParameter("tableid", tid)
            :setParameter("nUserId", USER_INFO["uid"])
            :setParameter("strkey", json.encode("kadlelala"))
            :setParameter("strinfo", USER_INFO["user_info"])
            :setParameter("iflag", 1)
            :setParameter("version", 1)
            :build()
            bm.server:send(sendpack)
        end
end

--请求退出房间
function ddzServer:CLI_LOGOUT_ROOM()
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
function ddzServer:CLI_SEND_LOGOUT_MATCH(match_id)
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
function ddzServer:CLI_READY_GAME()
    -- body
    if bm.server == nil then
        return
    end
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_READY_GAME)
        :build()
    bm.server:send(pack)
end

--过牌
function ddzServer:CLI_PASS()
    -- body
    if bm.server == nil then
        return
    end
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_PASS)
                :build()
    bm.server:send(pack)
end

--比赛报名
function ddzServer:CLI_SEND_JOIN_MATCH(level)

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
function ddzServer:CLI_AUTO(action)
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
function ddzServer:CLI_LOGIN_ROOM_ONLOOK(tid,onLookId)
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
    require("ddz_laizi.ddzSettings"):setLookState(1)
end

--退出围观
function ddzServer:CLI_REQUEST_LOOK_OUT(tid,onLookId)
    local sendpack = bm.server:createPacketBuilder(PROTOCOL.CLI_REQUEST_LOOK_OUT)
                    :setParameter("tid", tid)
                    :setParameter("uid", USER_INFO["uid"])
                    :setParameter("onlook_uid", onLookId)
                    :build()
    bm.server:send(sendpack)
end

--请求记牌器历史
function ddzServer:CLI_REQUEST_CALC_HISTORY()
    local sendpack = bm.server:createPacketBuilder(PROTOCOL.CLI_REQUEST_CALC_HISTORY)
                    :build()
    bm.server:send(sendpack)
end


--
function ddzServer:CLI_MSG_FACE(id)
    local sendpack = bm.server:createPacketBuilder(PROTOCOL.CLI_MSG_FACE)
                    :setParameter("type", id)
                    :build()
    bm.server:send(sendpack)
end

--开直播
function ddzServer:CLI_SEND_LIVE_ADDRESS(addr,flag)

    print("send LIVE_ADDRESS ",USER_INFO["uid"],addr,flag);
    local sendpack = bm.server:createPacketBuilder(PROTOCOL.CLI_SEND_LIVE_ADDRESS)
                    :setParameter("live_addr", addr)
                    :setParameter("flag", flag)
                    :build()
    bm.server:send(sendpack)
end

return ddzServer