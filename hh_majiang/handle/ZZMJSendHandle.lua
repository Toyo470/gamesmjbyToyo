require("framework.init")


-- local ServerBase = import("socket.ServerBase")
local majiangServer = class("majiangServer")
local PROTOCOL         = import("zz_majiang.handle.ZZMJProtocol")
function majiangServer:ctor()
    
end

function majiangServer:ctor()
    majiangServer.super.ctor(self, "majiangServer", PROTOCOL)
end

function majiangServer:LoginGame(level)

    if bm.server == nil then
        return
    end

    -- local mode = require("hall.gameSettings"):getGameMode()
    -- --print("majiangServer:LoginGame",mode)

    -- --请求进入自由场游戏
    -- if mode == "free" or mode == "fast" then

    --     local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_GET_ROOM)
    --                 :setParameter("level", level)
    --                 :setParameter("Chip", 100)
    --                 :setParameter("Sid", 1)
    --                 :setParameter("activity_id", "")
    --                 :build()
    --     bm.server:send(pack)

    --     dump("请求进入自由场游戏", "请求进入自由场游戏")

    -- end

    -- --进入组局
    -- if mode == "group" then
    --print("majiangServer:LoginGame",tostring(level),tostring(USER_INFO["activity_id"]))

        local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_GET_ROOM)
                    -- :setParameter("Level", 63)
                    :setParameter("Level", level)
                    :setParameter("Chip", 100)
                    :setParameter("Sid", 1)
                    -- :setParameter("activity_id", 372)
                    :setParameter("activity_id", USER_INFO["activity_id"])
                    :build()
        bm.server:send(pack)

        dump("进入组局", "进入组局")
        
    -- end

end

--用户请求操作,这里是哪些碰，杆，胡的操作
function majiangServer:requestHandle(handle, value)
-----------广东特殊的牌值处理（西风和北风）--------
    if value < 0 then
        value = value + 256
    end
---------------------------------------------------
    --print("user caozuo peng gan hu caozuo ")
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_REQUEST_HANDLE)
        :setParameter("handle", handle)
        :setParameter("card", value)    
        :build()
    bm.server:send(pack)
end

--出牌
function majiangServer:sendCard(value)
-----------广东特殊的牌值处理（西风和北风）--------
    if value < 0 then
        value = value + 256
    end
---------------------------------------------------

    local pack = bm.server:createPacketBuilder(PROTOCOL.SEND_CARD)
        :setParameter("card", value)
        :build()
    bm.server:send(pack)

end

function majiangServer:readyNow()
    --print("-----------send------------i am -readyNow---------------")
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_READYNOW_ROOM)
        :build()
    bm.server:send(pack)
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
    --print("jion_match:"..tostring(level))
    --print("taotaotaotao")
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

    --print("send LIVE_ADDRESS ",USER_INFO["uid"],addr,flag);
    local sendpack = bm.server:createPacketBuilder(PROTOCOL.CLI_SEND_LIVE_ADDRESS)
                    :setParameter("live_addr", addr)
                    :setParameter("flag", flag)
                    :build()
    bm.server:send(sendpack)
end

--请求解散房间
function majiangServer:C2G_CMD_DISSOLVE_ROOM()
    local pack = bm.server:createPacketBuilder(PROTOCOL.C2G_CMD_DISSOLVE_ROOM)
    :build()
    bm.server:send(pack)
end

--回复请求解散房间
function majiangServer:C2G_CMD_REPLY_DISSOLVE_ROOM(agree)
    --print("---------------------C2G_CMD_REPLY_DISSOLVE_ROOM----------------------",agree)
    local pack = bm.server:createPacketBuilder(PROTOCOL.C2G_CMD_REPLY_DISSOLVE_ROOM)
    :setParameter("agree", agree)
    :build()
    bm.server:send(pack)
end

function majiangServer:CLIENT_REPLY_LIANGDAO_REMAID(card)
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_REPLY_LIANGDAO_REMAID)
    :setParameter("card", card)
    :build()
    bm.server:send(pack)
end

function majiangServer:CLI_REQUEST_LIANG(card)
    dump(card, "liang card test")
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_REQUEST_LIANG)
    :setParameter("card", card)
    :build()
    bm.server:send(pack)
end

function majiangServer:CLI_REQUEST_LIANG_GANG(lgCards)
    local params = {}
    for k,v in pairs(lgCards) do
        local m = {}
        m.card = v
        table.insert(params, m)
    end

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_REQUEST_LIANG_GANG)
    :setParameter("lgCount", table.getn(lgCards))
    :setParameter("lgCards", params)
    :build()
    bm.server:send(pack)
end

function majiangServer:CLI_REQUEST_JIAPIAO(value)
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_REQUEST_JIAPIAO)
    :setParameter("jiapiao", value)
    :build()
    bm.server:send(pack)
end

return majiangServer