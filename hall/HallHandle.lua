require("framework.init")

--导入套接字请求处理
local PROTOCOL = import("hall.HALL_PROTOCOL")

--定义大厅请求处理类
local HallHandle = class("HallHandle")

function HallHandle:ctor()
	self.func_ = {
        --当前玩家被服务器断网
        [PROTOCOL.SVR_CLOSE_NET] = {handler(self, HallHandle.SVR_CLOSE_NET)},
        --当前玩家被踢下线
        [PROTOCOL.SVR_KICK_OFF] = {handler(self, HallHandle.SVR_KICK_OFF)},
        --服务器返回进入游戏
        [PROTOCOL.SVR_LOGIN_GAME] = {handler(self, HallHandle.SVR_LOGIN_GAME)},  --210
        --登录成功
        [PROTOCOL.SVR_LOGIN_OK] = {handler(self, HallHandle.SVR_LOGIN_OK)}, 
        --围观重连
        [PROTOCOL.SVR_LOGINLOOK_OK] = {handler(self, HallHandle.SVR_LOGINLOOK_OK)}, 
        --接收服务器返回的组局信息
        -- [PROTOCOL.SERVER_CMD_FORWARD_MESSAGE] = {handler(self, HallHandle.SERVER_CMD_FORWARD_MESSAGE)},
    }
end

--接收服务器返回的组局信息
function HallHandle:SERVER_CMD_FORWARD_MESSAGE(pack)

    dump(pack, "-----HallHandle 接收服务器返回的组局信息-----")

    -- require("hall.util.GameMsgHandleUtil"):ReceiveMsg(pack)

end

--
function HallHandle:callFunc(pack)
	 if self.func_[pack.cmd] and self.func_[pack.cmd][1] then
        self.func_[pack.cmd][1](pack)
    end
end

--客户端socket被断
function HallHandle:SVR_CLOSE_NET(pack)
    require("hall.GameTips"):showTips("提示", "network_disconnect", 1, "网络异常，请检查网络")
end

--客户端被踢
function HallHandle:SVR_KICK_OFF(pack)
    print("===============HallHandle:SVR_KICK_OFF==================")
    if bm.isLoginScene == 0 then
        require("hall.GameTips"):showTips("提示", "", 3, "您被请出游戏")
        --返回到登录页
        require("hall.LoginScene"):show()

    end

    

end


--服务器返回进入游戏
--重连之后才会有的操作
--直接发送1001
function HallHandle:SVR_LOGIN_GAME(pack)

    dump(pack, "-----服务器返回进入游戏  重连113返回-----")

    -- local partotal=bm.server:getProtocol()
    print("reconnectSVR_LOGIN_GAME",pack.Tid)
    local sendpack = bm.server:createPacketBuilder(PROTOCOL.CLI_LOGIN_ROOM_GROUP)
                                :setParameter("tableid", pack.Tid)
                                :setParameter("nUserId", USER_INFO["uid"])
                                :setParameter("strkey", json.encode("kadlelala"))
                                :setParameter("strinfo", USER_INFO["user_info"])
                                :setParameter("iflag", 2)
                                :setParameter("version", 1)
                                :setParameter("activity_id", USER_INFO["activity_id"])
                                :build()
    
    bm.server:setProtocol(bm.server.oldProtoacal)
    bm.server:setHandle(bm.server.oldHandle)

    bm.server:send(sendpack)

    dump("", "-----重连发送1001-----")

end

--登录成功
function HallHandle:SVR_LOGIN_OK(pack)

    print("-----登录成功 mode[%d]-----",USER_INFO["enter_mode"])

    if pack then

        local reloadTable = pack["Tid"]
        tableIdReload = reloadTable
        require("hall.GameList"):setReloadTable(reloadTable)

        if pack["Ver"] == 1 then

           

            print("", "-----Socket返回登录成功，进入大厅-----",bm.netdisConnect)

            if not bm.netdisConnect then
                require("hall.GameCommon"):landLoading(false)
                require("hall.GameCommon"):setLoadingProgress(100)
                display_scene("hall.gameScene", 1)
            else
                bm.netdisConnect=false
                bm.isConnectBytao=true
                require("hall.groudgamemanager"):reConnectGroupStatus(handler(self, self.reConnetGame))
            end




            

            -- if USER_INFO["enter_mode"] > 0 then

            --     require("hall.gameSettings"):setGameMode("group")

            --     if reloadTable > 0 then

            --         -- self:reloadGame(reloadTable)
            --         require("hall.GameList"):setReloginMode(0)
            --         require("hall.HallHttpNet"):requestReloadGame()

            --     else

            --         if needUpdate then

            --             if USER_INFO["enter_mode"] == 100 then
            --                 USER_INFO["enter_code"] = "zbzd"
            --                 require("hall.GameData"):getZbzdInfo()
            --             end

            --             if USER_INFO["enter_mode"] == 7 then
            --                 USER_INFO["enter_code"] = "douniu"
            --             end
                        
            --             require("hall.GameUpdate"):queryVersion(USER_INFO["enter_mode"],USER_INFO["enter_code"],0)
            --         else

            --             if USER_INFO["enter_mode"] > 0 then

            --                 require("hall.GameUpdate"):enterScene(USER_INFO["enter_code"])
            --             else

            --                 require("hall.GameUpdate"):enterGame(USER_INFO["enter_code"])

            --             end
            --             --require("hall.GameUpdate"):enterGame(USER_INFO["enter_code"])
            --         end
            --     end

            -- else 
            --     --大厅
            --     if reloadTable > 0 then
            --         -- self:reloadGame(reloadTable)
            --         require("hall.HallHttpNet"):requestReloadGame()
            --     else
            --         -- self:landLoading(false)
            --         require("hall.GameCommon"):landLoading(false)
            --         require("hall.GameCommon"):setLoadingProgress(100)
            --         display_scene("hall.gameScene",1)
            --     end
            -- end

        end
    end
end

--重连到游戏
function HallHandle:reConnetGame(activityId,level)

    print("-----重连到游戏,发送113-----",activityId,level)
    
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_LOGIN_GAME)
        :setParameter("Level", level)
        :setParameter("Chip", 1)
        :setParameter("Sid", 1)
        :setParameter("activity_id", activityId)       
        :build()
    bm.server:send(pack)

    USER_INFO["activity_id"]=activityId
end


--围观重连
function HallHandle:SVR_LOGINLOOK_OK(pack)
    local reloadTable = pack["Tid"]
    tableIdReload = reloadTable
    if reloadTable > 0 then
        require("hall.GameList"):setReloadTable(reloadTable)
        require("hall.GameList"):setReloginMode(pack["on_look_user"])
        require("hall.HallHttpNet"):requestReloadGame()
    else
        require("hall.GameCommon"):landLoading(false)
        require("hall.GameCommon"):setLoadingProgress(100)
        display_scene("hall.gameScene",1)
    end
end

function HallHandle:reloadGame(tid)
    -- body
    local gameid = tid or 4
    print("check game reload:"..gameid)
    if gameid > 0 then
        local code = require("hall.GameList"):getGameCode(gameid)
        if code == "" then
            if gameid == 4 then
                code = "majiang"
            end
        end

        if code then
            ddzReload = 1
            print("-------------reload -----------------"..code)
            require("hall.GameUpdate"):queryVersion(gameid,code,0,require("hall.GameList"):getGameName(gameid))
            -- display_scene(code..".gameScene",1)
        end

    else
        
        --本地没有传gameid过来
        self:reLoadDDZ(tid)
        self:reLoadDouniu(tid)
        self:reLoadHundrenBull(tid)

    end
end

function HallHandle:reLoadDDZ(tid)
    -- body
    local svid = require("hall.GameCommon"):getSvid(tid)
    print("check ddz reload:"..svid)
    local tbSvid = {201,401,801,1601,1801,1001,1202,1404,1606}
    for i,v in ipairs(tbSvid) do
        if svid == v then
            ddzReload = 1
            print("reload ddz")
            tableIdReload = tid
            display_scene("ddz.gameScene",1)
        end
    end
end

function HallHandle:reLoadDouniu(tid)
    -- body
    local svid = require("hall.GameCommon"):getSvid(tid)
    print("check ddz reload:"..svid)
    local tbSvid = {5000}
    for i,v in ipairs(tbSvid) do
        if svid == v then
            ddzReload = 1
            print("reload douniu")
            tableIdReload = tid
            display_scene("douniu.gameScene",1)
        end
    end
end

function HallHandle:reLoadHundrenBull(tid)
    -- body
    local svid = require("hall.GameCommon"):getSvid(tid)
    print("check ddz reload:"..svid)
    local tbSvid = {19301}
    for i,v in ipairs(tbSvid) do
        if svid == v then
            require("hall.GameTips"):showTips("您有视频间游戏未完成","reloadBull",1)
        end
    end
end


return HallHandle