


local ServerBase = require("hall.ScoketGame")
local HallServer = class("HallServer",ServerBase)
local PROTOCOL         = import("hall.HALL_PROTOCOL")


local HallHandle  = require("hall.HallHandle")

function HallServer:ctor()
    HallServer.super.ctor(self, "HallServer", PROTOCOL)
end

function HallServer:onAfterConnected()
    -- print("HallServer:onAfterConnected",bm.netWorkblock)

    -- if not  bm.netdisConnect then
    --     --todo
    -- else

    local tbl = self:getProtocol() or {}
    local protocol_name = tbl.HALL_PROTOCOL_EX or ""
    print("protocol_name--------------", protocol_name, "----PROTOCOL.HALL_PROTOCOL_EX--------", PROTOCOL.HALL_PROTOCOL_EX)
    if protocol_name ~= PROTOCOL.HALL_PROTOCOL_EX then

        dump("protocol_name不是HALL_PROTOCOL_EX", "-----重连完成-----")

        bm.server.oldProtoacal = self:getProtocol()
        bm.server.oldHandle = self:getHandle()

    else

        dump("protocol_name是HALL_PROTOCOL_EX", "-----重连完成-----")

        bm.server.oldProtoacal = self:getProtocol()
        bm.server.oldHandle = self:getHandle()

    end
    -- end
   
    bm.server:setProtocol(PROTOCOL)
    bm.server:setHandle(HallHandle.new())
        
    -- bm.server:setProtocol(bm.server.oldProtoacal)
    -- bm.server:setHandle(bm.server.oldHandle)


   -- self:scheduleHeartBeat(PROTOCOL.SVR_HEART,1,2)--开始心跳
    self:LoginHall();

    if bm.netdisConnect then
        --todo

        --require("hall.GameTips"):showTips("提示","",4,"重新连接成功")
        require("hall.GameUpdate"):setUpdateStatus(0)
        return;
    end

    require("hall.GameCommon"):setLoadingProgress(60)
    require("hall.GameCommon"):showLoadingTips("登录大厅")
    
    -- if  SCENENOW["name"] == "hall.hallScene" then
    --     --SCENENOW["scene"]:onConnected()
    -- else
    --     require("app.HallUpdate"):landLoading(true)
    --     require("app.HallUpdate"):queryVersion(2)
    -- end

end

function HallServer:netClose(msg)
    print("socket close")

    bm.netdisConnect = true
    -- if  SCENENOW["name"]=="hall.hallScene" or SCENENOW["name"]=="hall.gameScene" then
    --     --todo
    --     return;
    -- end
    if not tolua.isnull(SCENENOW["scene"]) and  bm.isInGame then
        if not SCENENOW["scene"]:getChildByName("loading") then
            --todo
            --self:connect()
            -- if self.socket_.isConnected then
            --      self.socket_:_onDisconnect()
            -- else
            --      self.socket_:_connectFailure()
            -- end
            
            cct.showLoadingTip(msg)           
        end
    end
end

--登录游戏大厅
function HallServer:LoginHall()
    print("-----Socket登录游戏大厅   HallServer:LoginGame--116---")
    dump(USER_INFO,"-----用户信息-----")
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_LOGIN)
        :setParameter("uid", UID)
        :setParameter("storeId", 1)
        :setParameter("kind", 1)
        :setParameter("userInfo", USER_INFO["user_info"])       
        :build()

    bm.server:send(pack)
end

--登录游戏
function HallServer:loginGame(level)
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_LOGIN_GAME)
                    :setParameter("Level",  level)
                    :setParameter("Chip", 10)
                    :setParameter("Sid", 1)
                    :setParameter("activity_id", "")
                    :build()
    bm.server:send(pack)
end


--发送组局信息
function HallServer:SendGameMsg(level,msg)

    dump(level, "-----当前组局level-----")
    dump(msg, "-----发送组局信息-----")

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_CMD_FORWARD_MESSAGE)
                    :setParameter("level", level)
                    :setParameter("msg", msg)
                    :build()
    bm.server:send(pack)

end

return HallServer