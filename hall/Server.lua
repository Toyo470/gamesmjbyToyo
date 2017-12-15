--
-- Author: LeoLuo
-- Date: 2015-05-09 09:59:20
--

local ServerBase = import("socket.ServerBase")
local Server = class("Server", ServerBase)
local PROTOCOL = import("hall.HALL_SERVER_PROTOCOL")

function Server:ctor()
    Server.super.ctor(self, "Server", PROTOCOL)
    self.isLogin_ = false
    --此处就是各种协议处理的方法映射
        self.func_ = {
            [PROTOCOL.SVR_LOGIN_OK] = {handler(self, Server.SVR_LOGIN_OK), ""},
            [PROTOCOL.SVR_KICK_OFF] = {handler(self, Server.SVR_KICK_OFF), ""},
            [PROTOCOL.SVR_KICK_OFF] = {handler(self, Server.SVR_KICK_OFF), ""},
            [PROTOCOL.SVR_LOGIN_GAME] = {handler(self, Server.SVR_LOGIN_GAME), ""},
            [PROTOCOL.SVR_LOGIN_ROOM_OK] = {handler(self, Server.SVR_LOGIN_ROOM_OK), ""},
            [PROTOCOL.SVR_LOGIN_ROOM_FAIL] = {handler(self, Server.SVR_LOGIN_ROOM_FAIL), ""},
            [PROTOCOL.SVR_READY_GAME] = {handler(self, Server.SVR_READY_GAME), ""},
            [PROTOCOL.SVR_DEAL] = {handler(self, Server.SVR_DEAL), ""},
            [PROTOCOL.SVR_LOGIN_ROOM] = {handler(self, Server.SVR_LOGIN_ROOM), ""},
            [PROTOCOL.SVR_LOGOUT_ROOM_OK] = {handler(self, Server.SVR_LOGOUT_ROOM_OK), ""},
            [PROTOCOL.SVR_LOGOUT_ROOM] = {handler(self, Server.SVR_LOGOUT_ROOM), ""},
            [PROTOCOL.SVR_RELOAD_ROOM] = {handler(self, Server.SVR_RELOAD_ROOM), ""},
            [PROTOCOL.SVR_GAME_START] = {handler(self, Server.SVR_GAME_START), ""},
            [PROTOCOL.SVR_BET] = {handler(self, Server.SVR_BET), ""},
            [PROTOCOL.SVR_PLAY_GAME] = {handler(self, Server.SVR_PLAY_GAME), ""},
            [PROTOCOL.SVR_PLAY_CARD] = {handler(self, Server.SVR_PLAY_CARD), ""},
            [PROTOCOL.SVR_PLAY_CARD_ERROR] = {handler(self, Server.SVR_PLAY_CARD_ERROR), ""},
            [PROTOCOL.SVR_PASS] = {handler(self, Server.SVR_PASS), ""},
            [PROTOCOL.SVR_GAME_OVER] = {handler(self, Server.SVR_GAME_OVER), ""},
            [PROTOCOL.SVR_DDZ_AUTO] = {handler(self, Server.SVR_DDZ_AUTO), ""},
            [PROTOCOL.SVR_MATCH_LOGIN] = {handler(self, Server.SVR_MATCH_LOGIN), ""},
            [PROTOCOL.SVR_MATCH_LOGIN_FAILED] = {handler(self, Server.SVR_MATCH_LOGIN_FAILED), ""},
            [PROTOCOL.SVR_MATCH_LOGIN_OK] = {handler(self, Server.SVR_MATCH_LOGIN_OK), ""},
            [PROTOCOL.SVR_MATCH_OTHER_LOGIN] = {handler(self, Server.SVR_MATCH_OTHER_LOGIN), ""},
            [PROTOCOL.SVR_MATCH_LOGOUT] = {handler(self, Server.SVR_MATCH_LOGOUT), ""},
            [PROTOCOL.SVR_MATCH_START] = {handler(self, Server.SVR_MATCH_START), ""},
            [PROTOCOL.SVR_MATCH_GAME_OVER] = {handler(self, Server.SVR_MATCH_GAME_OVER), ""},
            [PROTOCOL.SVR_MATCH_RANK] = {handler(self, Server.SVR_MATCH_RANK), ""},
            [PROTOCOL.SVR_HEART] = {handler(self, Server.SVR_HEART), ""},
            [PROTOCOL.SVR_CLOSE_NET] = {handler(self, Server.SVR_CLOSE_NET), ""},
            [PROTOCOL.SVR_CREATE_PRIVATEROOM] = {handler(self, Server.SVR_CREATE_PRIVATEROOM), ""},
            [PROTOCOL.SVR_CHANGE_CHIP] = {handler(self, Server.SVR_CHANGE_CHIP), ""},
            [PROTOCOL.SVR_GET_CHIP] = {handler(self, Server.SVR_GET_CHIP), ""},
            [PROTOCOL.SVR_GET_HISTORY] = {handler(self, Server.SVR_GET_HISTORY), ""},
            [PROTOCOL.SVR_GROUP_TIME] = {handler(self, Server.SVR_GROUP_TIME), ""},
            [PROTOCOL.SVR_GROUP_BILLBOARD] = {handler(self, Server.SVR_GROUP_BILLBOARD), ""}
        }
end


function Server:onProcessPacket(pack)
    print("Server:onProcessPacket")
    self:callFunc(pack)
end

function Server:callFunc(pack)
    if self.func_[pack.cmd] and self.func_[pack.cmd][1] then
        self.func_[pack.cmd][1](pack)
        -- if self.func_[pack.cmd][2] then
        --     bm.EventCenter:dispatchEvent({name=self.func_[pack.cmd][2], data=pack})
        -- end
    end
end
--接收心跳包
function Server:onHeartBeatReceived(delaySeconds)
    print("handle onHeartBeatReceived delay seconds:"..delaySeconds)
    self.heartBeatSchedulerPool_:clear(self.heartBeatTimeoutId_)
    self.heartBeatTimeoutId_ = nil
    self.heartBeatTimeoutCount_ = 0
end
--心跳3次没返回，返回游戏检查更新
function Server:onHeartBeatTimeout_()
    self.heartBeatTimeoutId_ = nil
    self.heartBeatTimeoutCount_ = (self.heartBeatTimeoutCount_ or 0) + 1
    self:onHeartBeatTimeout(self.heartBeatTimeoutCount_)
    print("heart beat timeout;%d", self.heartBeatTimeoutCount_)
    if self.heartBeatTimeoutCount_ >= 3 then
        local next = require("src.app.scenes.MainScene").new()
        display.replaceScene(next)
    end

end
function Server:SVR_HEART(pack)
    print("handle heart beat")
    local delaySeconds = bm.getTime() - self.heartBeatPackSendTime_
    if self.heartBeatTimeoutId_ then
        self.heartBeatSchedulerPool_:clear(self.heartBeatTimeoutId_)
        self.heartBeatTimeoutId_ = nil
        self.heartBeatTimeoutCount_ = 0
        self:onHeartBeatReceived(delaySeconds)
        --self.logger_:debug("heart beat received", delaySeconds)
        print("heart beat received:%d", delaySeconds)
    else
        --self.logger_:debug("timeout heart beat received", delaySeconds)
        print("timeout heart beat received:%d", delaySeconds)
    end
end

function Server:SVR_LOGIN_OK(pack)
    if  SCENENOW["name"] == "hall.hallScene" then
        SCENENOW["scene"]:onNetLoginOK(pack)
    end
end
function Server:SVR_KICK_OFF(pack)
    print("be kicked off")
    SCENENOW["scene"]:onNetKickOff(pack)
end
function Server:SVR_LOGIN_GAME(pack)
    print("DDZPacket:SVR_LOGIN_GAME")
    print(SCENENOW["name"])
    if SCENENOW["name"] == "ddz.gameScene" then
        SCENENOW["scene"]:onNetLoginGame(pack)
    end

end

function Server:SVR_CREATE_PRIVATEROOM(pack)
    print("DDZPacket:SVR_CREATE_PRIVATEROOM")
    if SCENENOW["name"] == "hall.hallScene" then
        SCENENOW["scene"]:onNetCreatePrivateRoom(pack)
    end

end
--兑换筹码返回
function Server:SVR_CHANGE_CHIP(pack)
    print("DDZPacket:SVR_CHANGE_CHIP")
    if SCENENOW["name"] == "ddz.gameScene" then
        SCENENOW["scene"]:onNetChangeChip(pack)
    end
end
--获取筹码返回
function Server:SVR_GET_CHIP(pack)
    print("DDZPacket:SVR_GET_CHIP")
    if SCENENOW["name"] == "ddz.gameScene" then
        SCENENOW["scene"]:onNetGetChip(pack)
    end
end

function Server:SVR_CLOSE_NET(pack)
    print("server close socket")
    bm.server:disconnect(nil)
    gExitGame()
end
function Server:SVR_GET_ROOM_OK(pack)
    print("get room id")
end
function Server:SVR_LOGIN_ROOM_OK(pack)
    print("success to enter room")
    if pack then
        if SCENENOW["name"] == "ddz.gameScene" then
            SCENENOW["scene"]:onNetLoginGameSucc(pack)
        end

    end
end
function Server:SVR_LOGIN_ROOM_FAIL(pack)
    print("failed to enter room")
    if pack then
        if SCENENOW["name"] == "ddz.gameScene" then
            SCENENOW["scene"]:onNetLoginGameFailed(pack)
        end
    end

end
--游戏准备返回
function Server:SVR_READY_GAME(pack)
    print("ready on game")
    if SCENENOW["name"] == "ddz.gameScene" then
        SCENENOW["scene"]:onNetReadyGame(pack)
    end
end
function Server:SVR_DEAL(pack)--发牌
    print("deal cards")
    if SCENENOW["name"] == "ddz.gameScene" then
        SCENENOW["scene"]:onNetDeal(pack)
    end
end
function Server:SVR_LOGIN_ROOM(pack)
    print("other player login room")
    if SCENENOW["name"] == "ddz.gameScene" then
        SCENENOW["scene"]:onNetPlayerInRoom(pack)
    end

end
function Server:SVR_LOGOUT_ROOM_OK(pack)
    print("logout room success")
    if SCENENOW["name"] == "ddz.gameScene" or SCENENOW["name"] == "ddz.Win" or SCENENOW["name"] == "ddz.Lose" then
        SCENENOW["scene"]:onNetLogoutRoomOk(pack)
    end
end
function Server:SVR_LOGOUT_ROOM(pack)
    print("other player logout room")
    if SCENENOW["name"] == "ddz.gameScene" then
        SCENENOW["scene"]:onNetLogoutRoom(pack)
    end
end
function Server:SVR_RELOAD_ROOM(pack)
    print("re-enter room")
    if pack then
        if SCENENOW["name"] ~= "ddz.gameScene" then
            display_scene("ddz.gameScene",1)
        end
        SCENENOW["scene"]:onNetReload(pack)
    end
end
function Server:SVR_GAME_START(pack)
    print("game start")
    if pack then
        if SCENENOW["name"] == "ddz.gameScene" then
            SCENENOW["scene"]:onNetGameStart(pack)
        end
    end
end
function Server:SVR_BET(pack)
    print("broadcast player bet")
    if pack then
        if SCENENOW["name"] == "ddz.gameScene" then
            SCENENOW["scene"]:onNetBet(pack)
        end
    end
end
function Server:SVR_PLAY_GAME(pack)
    print("broadcast,start to play card")
    if pack then
        if SCENENOW["name"] == "ddz.gameScene" then
            SCENENOW["scene"]:onNetPlayGame(pack)
        end
    end
end
function Server:SVR_PLAY_CARD(pack)
    print("broadcast,player play card")
    if pack then
        if SCENENOW["name"] == "ddz.gameScene" then
            SCENENOW["scene"]:onNetPlayCard(pack)
        end
    end
end
--出牌错误
function Server:SVR_PLAY_CARD_ERROR(pack)
    print("play card error")
    if pack then
        if SCENENOW["name"] == "ddz.gameScene" then
            SCENENOW["scene"]:onNetPlayCardError(pack)
        end
    end
end
function Server:SVR_PASS(pack)
    print("broadcast,player pass")
    if pack then
        if SCENENOW["name"] == "ddz.gameScene" then
            SCENENOW["scene"]:onNetPass(pack)
        end
    end
end
function Server:SVR_GAME_OVER(pack)
    print("broadcast, game over")
    if pack then
        if SCENENOW["name"] == "ddz.gameScene" then
            SCENENOW["scene"]:onGameOver(pack)
        end
    end

end
--斗地主托管
function Server:SVR_DDZ_AUTO(pack)
    print("ddz auto")
    if pack then
        if SCENENOW["name"] == "ddz.gameScene" then
            SCENENOW["scene"]:onNetAuto(pack)
        end
    end

end
--用户请求进入比赛场返回
function Server:SVR_MATCH_LOGIN(pack)
    if pack then
        if SCENENOW["name"] == "ddz.SelectChip" then
            SCENENOW["scene"]:onNetMatchJoin(pack)
        end
    end

end
--用户请求进入比赛场返回失败
function Server:SVR_MATCH_LOGIN_FAILED(pack)
    if pack then
        if SCENENOW["name"] == "ddz.SelectChip" then
            SCENENOW["scene"]:onNetMatchLoginFailed(pack)
        end
    end

end
--用户请求进入比赛场返回成功
function Server:SVR_MATCH_LOGIN_OK(pack)
    if pack then
        if SCENENOW["name"] == "ddz.SelectChip" then
            SCENENOW["scene"]:onNetMatchLoginOk(pack)
        end
    end

end
--已经报名的玩家会收到其他玩家进入的消息
function Server:SVR_MATCH_OTHER_LOGIN(pack)
    if pack then
        if SCENENOW["name"] == "ddz.SelectChip" then
            SCENENOW["scene"]:onNetMatchOtherLogin(pack)
        end
    end

end
--返回退出比赛结果
function Server:SVR_MATCH_LOGOUT(pack)
    if pack then
        if SCENENOW["name"] == "ddz.SelectChip" then
            SCENENOW["scene"]:onNetMatchLogout(pack)
        end
    end

end
--牌局，开始发送其他玩家信息
function Server:SVR_MATCH_START(pack)
    if pack then
        if SCENENOW["name"] ~= "ddz.gameScene" then
            display_scene("ddz.gameScene",1)
        end

        if SCENENOW["name"] == "ddz.gameScene" then
            SCENENOW["scene"]:onNetMatchStart(pack)
        end
    end

end
--每轮打完之后 会给玩家发送比赛状态信息
function Server:SVR_MATCH_GAME_OVER(pack)
    if pack then
        if SCENENOW["name"] == "ddz.gameScene" then
            SCENENOW["scene"]:onNetMatchGameOver(pack)
        end
    end

end
--比赛的过程中会收到比赛的排名信息
function Server:SVR_MATCH_RANK(pack)
    if pack then
        if SCENENOW["name"] == "ddz.gameScene" then
            SCENENOW["scene"]:onNetMatchRank(pack)
        end
    end

end
--组局排行榜
function Server:SVR_GROUP_BILLBOARD(pack)
    if pack then
        if SCENENOW["name"] == "ddz.gameScene" then
            SCENENOW["scene"]:onNetBillboard(pack)
        end
    end

end
--组局历史记录
function Server:SVR_GET_HISTORY(pack)
    if pack then
        if SCENENOW["name"] == "ddz.gameScene" then
            SCENENOW["scene"]:onNetHistory(pack)
        end
    end

end
--组局时长
function Server:SVR_GROUP_TIME(pack)
    if pack then
        if SCENENOW["name"] == "ddz.gameScene" then
            SCENENOW["scene"]:onNetGroupTime(pack)
        end
    end

end
function Server:onAfterConnected()
    print("Server:onAfterConnected")
    if  SCENENOW["name"] == "hall.hallScene" then
        SCENENOW["scene"]:onConnected()
    end
    --开始心跳
    self:scheduleHeartBeat(PROTOCOL.SVR_HEART,5,5)
end

--ServerBase
--{
--    function buildHeartBeatPack()
--         -- body
--        print("Server:buildHeartBeatPack()")
--        local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_HEART)
--        :build()
--        return pack
--     end
--}
-- function ServerBase:buildHeartBeatPack()
--     print("Server:buildHeartBeatPack()")
--     local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_HEART)
--     :build()
--     return pack
-- end
return Server