require("framework.init")

local PROTOCOL = import("ddz_laizi.ddz_PROTOCOL")


local ddzHandle = class("ddzHandle")

function ddzHandle:ctor()
    print("ddzHandle laizi")
	self.func_ = {
            [PROTOCOL.SVR_LOGIN_GAME] = {handler(self, ddzHandle.SVR_LOGIN_GAME), ""},
            [PROTOCOL.SVR_LOGIN_ROOM_OK] = {handler(self, ddzHandle.SVR_LOGIN_ROOM_OK), ""},
            [PROTOCOL.SVR_LOOKLOGIN_ROOM_OK] = {handler(self, ddzHandle.SVR_LOOKLOGIN_ROOM_OK), ""},
            [PROTOCOL.SVR_LOGIN_ROOM_FAIL] = {handler(self, ddzHandle.SVR_LOGIN_ROOM_FAIL), ""},
            [PROTOCOL.SVR_KICK_OFF]      = {handler(self, ddzHandle.SVR_KICK_OFF)},
            [PROTOCOL.SVR_READY_GAME] = {handler(self, ddzHandle.SVR_READY_GAME), ""},
            [PROTOCOL.SVR_DEAL] = {handler(self, ddzHandle.SVR_DEAL), ""},
            [PROTOCOL.SVR_LOGIN_ROOM] = {handler(self, ddzHandle.SVR_LOGIN_ROOM), ""},
            [PROTOCOL.SVR_LOGOUT_ROOM_OK] = {handler(self, ddzHandle.SVR_LOGOUT_ROOM_OK), ""},
            [PROTOCOL.SVR_LOGOUT_ROOM] = {handler(self, ddzHandle.SVR_LOGOUT_ROOM), ""},
            [PROTOCOL.SVR_RELOAD_ROOM] = {handler(self, ddzHandle.SVR_RELOAD_ROOM), ""},
            [PROTOCOL.SVR_GAME_START] = {handler(self, ddzHandle.SVR_GAME_START), ""},
            [PROTOCOL.SVR_BET] = {handler(self, ddzHandle.SVR_BET), ""},
            [PROTOCOL.SVR_PLAY_GAME] = {handler(self, ddzHandle.SVR_PLAY_GAME), ""},
            [PROTOCOL.SVR_PLAY_CARD] = {handler(self, ddzHandle.SVR_PLAY_CARD), ""},
            [PROTOCOL.SVR_PLAY_CARD_ERROR] = {handler(self, ddzHandle.SVR_PLAY_CARD_ERROR), ""},
            [PROTOCOL.SVR_PASS] = {handler(self, ddzHandle.SVR_PASS), ""},
            [PROTOCOL.SVR_GAME_OVER] = {handler(self, ddzHandle.SVR_GAME_OVER), ""},
            [PROTOCOL.SVR_DDZ_AUTO] = {handler(self, ddzHandle.SVR_DDZ_AUTO), ""},
            [PROTOCOL.SVR_MATCH_LOGIN] = {handler(self, ddzHandle.SVR_MATCH_LOGIN), ""},
            [PROTOCOL.SVR_MATCH_LOGIN_FAILED] = {handler(self, ddzHandle.SVR_MATCH_LOGIN_FAILED), ""},
            [PROTOCOL.SVR_MATCH_LOGIN_OK] = {handler(self, ddzHandle.SVR_MATCH_LOGIN_OK), ""},
            [PROTOCOL.SVR_MATCH_OTHER_LOGIN] = {handler(self, ddzHandle.SVR_MATCH_OTHER_LOGIN), ""},
            [PROTOCOL.SVR_MATCH_LOGOUT] = {handler(self, ddzHandle.SVR_MATCH_LOGOUT), ""},
            [PROTOCOL.SVR_MATCH_START] = {handler(self, ddzHandle.SVR_MATCH_START), ""},
            [PROTOCOL.SVR_MATCH_GAME_OVER] = {handler(self, ddzHandle.SVR_MATCH_GAME_OVER), ""},
            [PROTOCOL.SVR_MATCH_RANK] = {handler(self, ddzHandle.SVR_MATCH_RANK), ""},
            [PROTOCOL.SVR_MATCH_RELOAD] = {handler(self, ddzHandle.SVR_MATCH_RELOAD), ""},
            [PROTOCOL.SVR_MATCH_WAIT] = {handler(self, ddzHandle.SVR_MATCH_WAIT), ""},
            [PROTOCOL.SVR_MATCH_CLOSE] = {handler(self, ddzHandle.SVR_MATCH_CLOSE), ""},
            [PROTOCOL.SVR_ROOM_INFO] = {handler(self, ddzHandle.SVR_ROOM_INFO), ""},
            [PROTOCOL.SVR_CHANGE_CHIP] = {handler(self, ddzHandle.SVR_CHANGE_CHIP), ""},
            [PROTOCOL.SVR_GET_CHIP] = {handler(self, ddzHandle.SVR_GET_CHIP), ""},
            [PROTOCOL.SVR_GET_HISTORY] = {handler(self, ddzHandle.SVR_GET_HISTORY), ""},
            [PROTOCOL.SVR_GROUP_TIME] = {handler(self, ddzHandle.SVR_GROUP_TIME), ""},
            [PROTOCOL.SVR_ENTER_PRIVATE_ROOM] = {handler(self, ddzHandle.SVR_ENTER_PRIVATE_ROOM), ""},
            [PROTOCOL.SVR_CALC_HISTORY] = {handler(self, ddzHandle.SVR_CALC_HISTORY), ""},
            [PROTOCOL.SVR_GROUP_BILLBOARD] = {handler(self, ddzHandle.SVR_GROUP_BILLBOARD), ""},
            [PROTOCOL.SVR_MSG_FACE]={handler(self, ddzHandle.SVR_MSG_FACE), ""},
            [PROTOCOL.SER_BROADCAST_LIVE_ADDRESS]={handler(self, ddzHandle.SER_BROADCAST_LIVE_ADDRESS), ""},
            [PROTOCOL.SVR_GET_LAIZI]={handler(self, ddzHandle.SVR_GET_LAIZI), ""},
            
    }
end


--
function ddzHandle:callFunc(pack)
	 if self.func_[pack.cmd] and self.func_[pack.cmd][1] then
        self.func_[pack.cmd][1](pack)
    end
end

--登录游戏
function ddzHandle:SVR_LOGIN_GAME(pack)
    print("DDZPacket:SVR_LOGIN_GAME")
    print(SCENENOW["name"])
    if SCENENOW["name"] == "ddz_laizi.gameScene" then
        SCENENOW["scene"]:onNetLoginGame(pack)
    end

end

--客户端被踢
function ddzHandle:SVR_KICK_OFF(pack)

    require("hall.GameTips"):showTips("您被请出游戏","kick_off")
end
--兑换筹码返回
function ddzHandle:SVR_CHANGE_CHIP(pack)
    print("DDZPacket:SVR_CHANGE_CHIP")
    if SCENENOW["name"] == "ddz_laizi.gameScene" then
        SCENENOW["scene"]:onNetChangeChip(pack)
    end
end
--获取筹码返回
function ddzHandle:SVR_GET_CHIP(pack)
    print("DDZPacket:SVR_GET_CHIP")
    if SCENENOW["name"] == "ddz_laizi.gameScene" then
        SCENENOW["scene"]:onNetGetChip(pack)
    end
end

function ddzHandle:SVR_LOGIN_ROOM_OK(pack)
    print("success to enter room")
    if pack then
        if SCENENOW["name"] == "ddz_laizi.gameScene" then
            SCENENOW["scene"]:onNetLoginGameSucc(pack)
        end

    end
end
--围观登录成功
function ddzHandle:SVR_LOOKLOGIN_ROOM_OK(pack)
    if pack then
        if SCENENOW["name"] == "ddz_laizi.gameScene" then
            SCENENOW["scene"]:onNetLookLogin(pack)
        end
    end
end

function ddzHandle:SVR_LOGIN_ROOM_FAIL(pack)
    print("failed to enter room",pack["nErrno"])
    if pack then
        -- if SCENENOW["name"] == "ddz_laizi.gameScene" then
        --     SCENENOW["scene"]:onNetLoginGameFailed(pack)
        -- end
        -- if pack["nErrno"] == 7 then
        --     local tid = require("ddz_laizi.ddzSettings"):getLookingTable()
        --     if tid then
        --         require("ddz_laizi.ddzServer"):CLI_LOGIN_ROOM_ONLOOK(tid,-1)
        --         return
        --     end
        -- end
        local errcode = "error"
        local showBtn = 2
        if pack["nErrno"] == 9 or pack["nErrno"] == 21 then
            errcode = "change_money"
            showBtn = 1
        end
        local msg = require("ddz_laizi.ddzSettings"):getErrorCode(pack["nErrno"])
        if msg == nil then
            msg = "未知错误"
        end
        print(msg,showBtn)
        if pack["nErrno"]==16 then
            --先判断是否领取了首冲

            --if USER_INFO["isFirstCharged"] and USER_INFO["isFirstCharged"] == 1 then --you
                local userBrkui=require("ddz_laizi/userBroke")
                local u_node=userBrkui.new();
                SCENENOW["scene"]:addChild(u_node,99999)

            -- else
            --     require("hall.fRecharge"):showOut(true);

            -- end
        else
            require("ddz_laizi.MatchSetting"):showMatchSignup(false)
            require("hall.GameTips"):showTips(msg,errcode,showBtn)
        end
    end

end
--游戏准备返回
function ddzHandle:SVR_READY_GAME(pack)
    print("ready on game")
    if SCENENOW["name"] == "ddz_laizi.gameScene" then
        SCENENOW["scene"]:onNetReadyGame(pack)
    end
end
function ddzHandle:SVR_DEAL(pack)--发牌
    print("deal cards")
    if SCENENOW["name"] == "ddz_laizi.gameScene" then
        SCENENOW["scene"]:onNetDeal(pack)
    end
end
function ddzHandle:SVR_LOGIN_ROOM(pack)
    print("other player login room")
    if SCENENOW["name"] == "ddz_laizi.gameScene" then
        SCENENOW["scene"]:onNetPlayerInRoom(pack)
    end

end
function ddzHandle:SVR_LOGOUT_ROOM_OK(pack)
    print("logout room success")
    if SCENENOW["name"] == "ddz_laizi.gameScene" or SCENENOW["name"] == "ddz_laizi.Win" or SCENENOW["name"] == "ddz_laizi.Lose" then
        if tolua.isnull(SCENENOW["scene"]) == false then
            SCENENOW["scene"]:onNetLogoutRoomOk(pack)
        else
            local next = require("src.app.scenes.MainScene").new()
            SCENENOW["scene"] = next
            SCENENOW["name"] = "app.scenes.MainScene"
            display.replaceScene(next)
        end
    end
end
function ddzHandle:SVR_LOGOUT_ROOM(pack)
    print("other player logout room")
    if SCENENOW["name"] == "ddz_laizi.gameScene" then
        SCENENOW["scene"]:onNetLogoutRoom(pack)
    end
end
function ddzHandle:SVR_RELOAD_ROOM(pack)
    print("re-enter room")
    if pack then
        if SCENENOW["name"] ~= "ddz_laizi.gameScene" then
            display_scene("ddz_laizi.gameScene",1)
        end
        SCENENOW["scene"]:onNetReload(pack)
    end
end
function ddzHandle:SVR_GAME_START(pack)
    print("game start")
    if pack then
        if SCENENOW["name"] == "ddz_laizi.gameScene" then
            SCENENOW["scene"]:onNetGameStart(pack)
        end
    end
end
function ddzHandle:SVR_BET(pack)
    print("broadcast player bet")
    if pack then
        if SCENENOW["name"] == "ddz_laizi.gameScene" then
            SCENENOW["scene"]:onNetBet(pack)
        end
    end
end
function ddzHandle:SVR_PLAY_GAME(pack)
    print("broadcast,开始打牌")
    if pack then
        if SCENENOW["name"] == "ddz_laizi.gameScene" then
            SCENENOW["scene"]:onNetPlayGame(pack)
        end
    end
end
function ddzHandle:SVR_PLAY_CARD(pack)
    print("broadcast,player play card")
    if pack then
        if SCENENOW["name"] == "ddz_laizi.gameScene" then
            SCENENOW["scene"]:onNetPlayCard(pack)
        end
    end
end
--出牌错误
function ddzHandle:SVR_PLAY_CARD_ERROR(pack)
    print("play card error")
    if pack then
        if SCENENOW["name"] == "ddz_laizi.gameScene" then
            SCENENOW["scene"]:onNetPlayCardError(pack)
        end
    end
end
function ddzHandle:SVR_PASS(pack)
    print("broadcast,player pass")
    if pack then
        if SCENENOW["name"] == "ddz_laizi.gameScene" then
            SCENENOW["scene"]:onNetPass(pack)
        end
    end
end
function ddzHandle:SVR_GAME_OVER(pack)
    print("broadcast, game over")
    if pack then
        if SCENENOW["name"] == "ddz_laizi.gameScene" then
            SCENENOW["scene"]:onGameOver(pack)
        end
    end

end
--斗地主托管
function ddzHandle:SVR_DDZ_AUTO(pack)
    print("ddz_laizi auto")
    if pack then
        if SCENENOW["name"] == "ddz_laizi.gameScene" then
            SCENENOW["scene"]:onNetAuto(pack)
        end
    end
    
end
--用户请求进入比赛场返回
function ddzHandle:SVR_MATCH_LOGIN(pack)
    if pack then
        if SCENENOW["name"] == "ddz_laizi.SelectChip" then
            SCENENOW["scene"]:onNetMatchJoin(pack)
        end
    end

end
--用户请求进入比赛场返回失败
function ddzHandle:SVR_MATCH_LOGIN_FAILED(pack)
    if pack then
        if SCENENOW["name"] == "ddz_laizi.SelectChip" then
            SCENENOW["scene"]:onNetMatchLoginFailed(pack)
        end
    end

end
--用户请求进入比赛场返回成功
function ddzHandle:SVR_MATCH_LOGIN_OK(pack)
    if pack then
        if SCENENOW["name"] == "ddz_laizi.SelectChip" then
            SCENENOW["scene"]:onNetMatchLoginOk(pack)
        end
    end

end
--已经报名的玩家会收到其他玩家进入的消息
function ddzHandle:SVR_MATCH_OTHER_LOGIN(pack)
    if pack then
        if SCENENOW["name"] == "ddz_laizi.SelectChip" then
            SCENENOW["scene"]:onNetMatchOtherLogin(pack)
        end
    end

end
--返回退出比赛结果
function ddzHandle:SVR_MATCH_LOGOUT(pack)
    if pack then
        if SCENENOW["name"] == "ddz_laizi.SelectChip" then
            SCENENOW["scene"]:onNetMatchLogout(pack)
        end
    end

end
--牌局，开始发送其他玩家信息
function ddzHandle:SVR_MATCH_START(pack)
    if pack then
        if SCENENOW["name"] ~= "ddz_laizi.gameScene" then
            -- 成功调分成接口
            -- require("ddz_laizi.DDZHttpNet"):gameMatchExtract(1,require("ddz_laizi.ddzSettings"):getMatchId(),USER_INFO["match_fee"])
            display_scene("ddz_laizi.gameScene",1)
            print("enter ddz_laizi match")
        end

        if SCENENOW["name"] == "ddz_laizi.gameScene" then
            SCENENOW["scene"]:onNetMatchStart(pack)
        end
    end

end
--每轮打完之后 会给玩家发送比赛状态信息
function ddzHandle:SVR_MATCH_GAME_OVER(pack)
    if pack then
        if SCENENOW["name"] == "ddz_laizi.gameScene" then
            SCENENOW["scene"]:onNetMatchGameOver(pack)
        end
    end

end
--比赛的过程中会收到比赛的排名信息
function ddzHandle:SVR_MATCH_RANK(pack)
    if pack then
        if SCENENOW["name"] == "ddz_laizi.gameScene" then
            SCENENOW["scene"]:onNetMatchRank(pack)
        end
    end

end
--比赛重连
function ddzHandle:SVR_MATCH_RELOAD(pack)
    -- body
    if pack then
        if SCENENOW["name"] == "ddz_laizi.gameScene" then
            SCENENOW["scene"]:SVR_MATCH_RELOAD(pack)
        end
    end
end
--发送用户重连回比赛开赛后的等待界面
function ddzHandle:SVR_MATCH_WAIT(pack)
    -- body
    if pack then
        if SCENENOW["name"] == "ddz_laizi.gameScene" then
            SCENENOW["scene"]:SVR_MATCH_WAIT(pack)
        end
    end
end
function ddzHandle:SVR_MATCH_CLOSE( pack )
    -- body
    require("hall.GameTips"):showTips("比赛中断，请重新载入","network_disconnect",1)
end
--获取房间讯息
function ddzHandle:SVR_ROOM_INFO(pack)
    -- body
    if pack then
        if SCENENOW["name"] == "ddz_laizi.gameScene" then
            SCENENOW["scene"]:SVR_ROOM_INFO(pack)
        end
    end
end
--组局排行榜
function ddzHandle:SVR_GROUP_BILLBOARD(pack)
    if pack then
        if SCENENOW["name"] == "ddz_laizi.gameScene" then
            SCENENOW["scene"]:onNetBillboard(pack)
        end
    end

end
--组局历史记录
function ddzHandle:SVR_GET_HISTORY(pack)
    if pack then
        if SCENENOW["name"] == "ddz_laizi.gameScene" then
            SCENENOW["scene"]:onNetHistory(pack)
        end
    end

end
--组局时长
function ddzHandle:SVR_GROUP_TIME(pack)
    if pack then
        if SCENENOW["name"] == "ddz_laizi.gameScene" then
            SCENENOW["scene"]:onNetGroupTime(pack)
        end
    end

end



--玩家进入私人房
function ddzHandle:SVR_ENTER_PRIVATE_ROOM(pack)
    if pack then
        if SCENENOW["name"] == "ddz_laizi.gameScene" then
            SCENENOW["scene"]:SVR_ENTER_PRIVATE_ROOM(pack)
        end
    end
end
--历史出牌
function ddzHandle:SVR_CALC_HISTORY(pack)
    if pack then
        if SCENENOW["name"] == "ddz_laizi.gameScene" then
            SCENENOW["scene"]:SVR_CALC_HISTORY(pack)
        end
    end
end


function ddzHandle:SVR_MSG_FACE(pack)
    if SCENENOW["name"] == "ddz_laizi.gameScene" then
        local s=SCENENOW["scene"]:getChildByName("faceUI")
        s:showGetFace(pack.uid,pack.type)
    end
end

function ddzHandle:SVR_GET_LAIZI(pack)
    if SCENENOW["name"] == "ddz_laizi.gameScene" then
        SCENENOW["scene"]:getLaiziFromNet(pack["value"])
    end
end

--直播开始了
function ddzHandle:SER_BROADCAST_LIVE_ADDRESS(pack)

    require("ddz_laizi.PlayVideo"):setVideoAddr(pack["live_addr"],pack["flag"])
end


return ddzHandle