require("framework.init")

local PROTOCOL = import("ddz.ddz_PROTOCOL")


local ddzHandle = class("ddzHandle")

function ddzHandle:ctor()
    print("ddzHandle")
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
            [PROTOCOL.S2C_DISSOLVE_FAILED]={handler(self, ddzHandle.S2C_DISSOLVE_FAILED), ""},

            --没有此房间，解散房间失败
            [PROTOCOL.G2H_CMD_DISSOLVE_FAILED]     = {handler(self, ddzHandle.G2H_CMD_DISSOLVE_FAILED)},
            --广播桌子用户请求解散组局
            [PROTOCOL.SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP]     = {handler(self, ddzHandle.SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP)},
            --广播当前组局解散情况
            [PROTOCOL.G2H_CMD_REFRESH_DISSOLVE_LIST]     = {handler(self, ddzHandle.G2H_CMD_REFRESH_DISSOLVE_LIST)},
            --广播桌子用户成功解散组局
            [PROTOCOL.SERVER_BROADCAST_DISSOLVE_GROUP]     = {handler(self, ddzHandle.SERVER_BROADCAST_DISSOLVE_GROUP)},
            --广播桌子用户解散组局 ，解散组局失败
            [PROTOCOL.SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP]     = {handler(self, ddzHandle.SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP)},
            --广播桌子用户ip
            [PROTOCOL.BROADCAST_USER_IP]     = {handler(self, ddzHandle.BROADCAST_USER_IP)},
            
            [PROTOCOL.SERVER_CMD_MESSAGE]={handler(self, ddzHandle.SERVER_CMD_MESSAGE), ""},

            [PROTOCOL.SERVER_CMD_FORWARD_MESSAGE]={handler(self, ddzHandle.SERVER_CMD_FORWARD_MESSAGE), ""},
            
    }
end


--
function ddzHandle:callFunc(pack)
	 if self.func_[pack.cmd] and self.func_[pack.cmd][1] then
        self.func_[pack.cmd][1](pack)
    end
end

function ddzHandle:CLI_MSG_FACE(id)
    local sendpack = bm.server:createPacketBuilder(PROTOCOL.CLI_MSG_FACE)
                    :setParameter("type", id)
                    :build()
    bm.server:send(sendpack)
end

--登录游戏
function ddzHandle:SVR_LOGIN_GAME(pack)
    print("DDZPacket:SVR_LOGIN_GAME")
    print(SCENENOW["name"])
    if SCENENOW["name"] == "ddz.gameScene" then
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
    if SCENENOW["name"] == "ddz.roomScene" then
        SCENENOW["scene"]:onNetChangeChip(pack)
    end
end
--获取筹码返回
function ddzHandle:SVR_GET_CHIP(pack)
    print("DDZPacket:SVR_GET_CHIP")
    if SCENENOW["name"] == "ddz.roomScene" then
        SCENENOW["scene"]:onNetGetChip(pack)
    end
end

function ddzHandle:SVR_LOGIN_ROOM_OK(pack)
    print("success to enter room")
    if pack then
        if SCENENOW["name"] == "ddz.roomScene" then
            SCENENOW["scene"]:onNetLoginGameSucc(pack)
        end

    end
end
--围观登录成功
function ddzHandle:SVR_LOOKLOGIN_ROOM_OK(pack)
    if pack then
        if SCENENOW["name"] == "ddz.roomScene" then
            SCENENOW["scene"]:onNetLookLogin(pack)
        end
    end
end

--发送登录房间错误
function ddzHandle:SVR_LOGIN_ROOM_FAIL(pack)
    print("failed to enter room",pack["nErrno"])
    if pack then
        -- if SCENENOW["name"] == "ddz.roomScene" then
        --     SCENENOW["scene"]:onNetLoginGameFailed(pack)
        -- end
        -- if pack["nErrno"] == 7 then
        --     local tid = require("ddz.ddzSettings"):getLookingTable()
        --     if tid then
        --         require("ddz.ddzServer"):CLI_LOGIN_ROOM_ONLOOK(tid,-1)
        --         return
        --     end
        -- end
        local errcode = "error"
        local showBtn = 2
        if pack["nErrno"] == 9 or pack["nErrno"] == 21 then
            errcode = "change_money"
            showBtn = 1
        end
        local msg = require("ddz.ddzSettings"):getErrorCode(pack["nErrno"])
        if msg == nil then
            msg = "未知错误"
        end
        print(msg,showBtn)
        if pack["nErrno"]==16 then
            --先判断是否领取了首冲

            --if USER_INFO["isFirstCharged"] and USER_INFO["isFirstCharged"] == 1 then --you
            --余额不足的操纵
                local userBrkui=require("ddz/userBroke")
                local u_node=userBrkui.new();
                SCENENOW["scene"]:addChild(u_node,99999)

            -- else
            --     require("hall.fRecharge"):showOut(true);

            -- end
        else
            require("ddz.MatchSetting"):showMatchSignup(false)
            require("hall.GameTips"):showTips(msg,errcode,showBtn)
        end
        
        
        
    end

end
--游戏准备返回
function ddzHandle:SVR_READY_GAME(pack)
    print("ready on game")
    if SCENENOW["name"] == "ddz.roomScene" then
        SCENENOW["scene"]:onNetReadyGame(pack)
    end
end
function ddzHandle:SVR_DEAL(pack)--发牌
    print("deal cards")
    require("hall.gameSettings"):setGroupState(1)
    if SCENENOW["name"] == "ddz.roomScene" then
        SCENENOW["scene"]:onNetDeal(pack)
    end
end
function ddzHandle:SVR_LOGIN_ROOM(pack)
    print("other player login room")
    if SCENENOW["name"] == "ddz.roomScene" then
        SCENENOW["scene"]:onNetPlayerInRoom(pack)
    end

end
function ddzHandle:SVR_LOGOUT_ROOM_OK(pack)
    print("logout room success")
    if SCENENOW["name"] == "ddz.roomScene" or SCENENOW["name"] == "ddz.Win" or SCENENOW["name"] == "ddz.Lose" then
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
    if SCENENOW["name"] == "ddz.roomScene" then
        SCENENOW["scene"]:onNetLogoutRoom(pack)
    end
end
function ddzHandle:SVR_RELOAD_ROOM(pack)
    print("re-enter room")
    require("hall.gameSettings"):setGroupState(1)
    if pack then
        if SCENENOW["name"] ~= "ddz.roomScene" then
            display_scene("ddz.roomScene",1)
        end
        SCENENOW["scene"]:onNetReload(pack)
    end
end
function ddzHandle:SVR_GAME_START(pack)
    print("game start")
    if pack then
        if SCENENOW["name"] == "ddz.roomScene" then
            SCENENOW["scene"]:onNetGameStart(pack)
        end
    end
end
function ddzHandle:SVR_BET(pack)
    print("broadcast player bet")
    if pack then
        if SCENENOW["name"] == "ddz.roomScene" then
            SCENENOW["scene"]:onNetBet(pack)
        end
    end
end
function ddzHandle:SVR_PLAY_GAME(pack)
    print("broadcast,start to play card")
    if pack then
        if SCENENOW["name"] == "ddz.roomScene" then
            SCENENOW["scene"]:onNetPlayGame(pack)
        end
    end
end
function ddzHandle:SVR_PLAY_CARD(pack)
    print("broadcast,player play card")
    if pack then
        if SCENENOW["name"] == "ddz.roomScene" then
            SCENENOW["scene"]:onNetPlayCard(pack)
        end
    end
end
--出牌错误
function ddzHandle:SVR_PLAY_CARD_ERROR(pack)
    print("play card error")
    if pack then
        if SCENENOW["name"] == "ddz.roomScene" then
            SCENENOW["scene"]:onNetPlayCardError(pack)
        end
    end
end
function ddzHandle:SVR_PASS(pack)
    print("broadcast,player pass")
    if pack then
        if SCENENOW["name"] == "ddz.roomScene" then
            SCENENOW["scene"]:onNetPass(pack)
        end
    end
end
function ddzHandle:SVR_GAME_OVER(pack)
    print("broadcast, game over")
    require("hall.gameSettings"):setGroupState(0)
    if pack then
        if SCENENOW["name"] == "ddz.roomScene" then
            SCENENOW["scene"]:onGameOver(pack)
        end
    end

end
--斗地主托管
function ddzHandle:SVR_DDZ_AUTO(pack)
    print("ddz auto")
    if pack then
        if SCENENOW["name"] == "ddz.roomScene" then
            SCENENOW["scene"]:onNetAuto(pack)
        end
    end
    
end
--用户请求进入比赛场返回
function ddzHandle:SVR_MATCH_LOGIN(pack)
    if pack then
        if SCENENOW["name"] == "ddz.SelectChip" then
            SCENENOW["scene"]:onNetMatchJoin(pack)
        end
    end

end
--用户请求进入比赛场返回失败
function ddzHandle:SVR_MATCH_LOGIN_FAILED(pack)
    if pack then
        if SCENENOW["name"] == "ddz.SelectChip" then
            SCENENOW["scene"]:onNetMatchLoginFailed(pack)
        end
    end

end
--用户请求进入比赛场返回成功
function ddzHandle:SVR_MATCH_LOGIN_OK(pack)
    if pack then
        if SCENENOW["name"] == "ddz.SelectChip" then
            SCENENOW["scene"]:onNetMatchLoginOk(pack)
        end
    end

end
--已经报名的玩家会收到其他玩家进入的消息
function ddzHandle:SVR_MATCH_OTHER_LOGIN(pack)
    if pack then
        if SCENENOW["name"] == "ddz.SelectChip" then
            SCENENOW["scene"]:onNetMatchOtherLogin(pack)
        end
    end

end
--返回退出比赛结果
function ddzHandle:SVR_MATCH_LOGOUT(pack)
    if pack then
        if SCENENOW["name"] == "ddz.SelectChip" then
            SCENENOW["scene"]:onNetMatchLogout(pack)
        end
    end

end
--牌局，开始发送其他玩家信息
function ddzHandle:SVR_MATCH_START(pack)
    if pack then
        if SCENENOW["name"] ~= "ddz.roomScene" then
            -- 成功调分成接口
            -- require("ddz.DDZHttpNet"):gameMatchExtract(1,require("ddz.ddzSettings"):getMatchId(),USER_INFO["match_fee"])
            display_scene("ddz.roomScene",1)
            print("enter ddz match")
        end

        if SCENENOW["name"] == "ddz.roomScene" then
            SCENENOW["scene"]:onNetMatchStart(pack)
        end
    end

end
--每轮打完之后 会给玩家发送比赛状态信息
function ddzHandle:SVR_MATCH_GAME_OVER(pack)
    if pack then
        if SCENENOW["name"] == "ddz.roomScene" then
            SCENENOW["scene"]:onNetMatchGameOver(pack)
        end
    end

end
--比赛的过程中会收到比赛的排名信息
function ddzHandle:SVR_MATCH_RANK(pack)
    if pack then
        if SCENENOW["name"] == "ddz.roomScene" then
            SCENENOW["scene"]:onNetMatchRank(pack)
        end
    end

end
--比赛重连
function ddzHandle:SVR_MATCH_RELOAD(pack)
    -- body
    if pack then
        if SCENENOW["name"] == "ddz.roomScene" then
            SCENENOW["scene"]:SVR_MATCH_RELOAD(pack)
        end
    end
end
--发送用户重连回比赛开赛后的等待界面
function ddzHandle:SVR_MATCH_WAIT(pack)
    -- body
    if pack then
        if SCENENOW["name"] == "ddz.roomScene" then
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
        if SCENENOW["name"] == "ddz.roomScene" then
            SCENENOW["scene"]:SVR_ROOM_INFO(pack)
        end
    end
end
--组局排行榜
function ddzHandle:SVR_GROUP_BILLBOARD(pack)
    if pack then

        if bm.Room == nil then
            bm.Room = {}
        end
        bm.Room.start_group = 0
        if SCENENOW["name"] == "ddz.roomScene" then
            SCENENOW["scene"]:onNetBillboard(pack)
        end
    end

end
--组局历史记录
function ddzHandle:SVR_GET_HISTORY(pack)
    if pack then
        if SCENENOW["name"] == "ddz.roomScene" then
            SCENENOW["scene"]:onNetHistory(pack)
        end
    end

end
--组局时长
function ddzHandle:SVR_GROUP_TIME(pack)
    if pack then
        if SCENENOW["name"] == "ddz.roomScene" then
            SCENENOW["scene"]:onNetGroupTime(pack)
        end
    end

end



--玩家进入私人房
function ddzHandle:SVR_ENTER_PRIVATE_ROOM(pack)
    require("hall.GameTips"):showTips("系统错误", "tohall", 3, "房间不存在")
end
--历史出牌
function ddzHandle:SVR_CALC_HISTORY(pack)
    if pack then
        if SCENENOW["name"] == "ddz.roomScene" then
            SCENENOW["scene"]:SVR_CALC_HISTORY(pack)
        end
    end
end


function ddzHandle:SVR_MSG_FACE(pack)
    if SCENENOW["name"] == "ddz.roomScene" then
        SCENENOW["scene"]:SVR_MSG_FACE(pack)
    end
end


--直播开始了
function ddzHandle:SER_BROADCAST_LIVE_ADDRESS(pack)

    require("ddz.PlayVideo"):setVideoAddr(pack["live_addr"],pack["flag"])
end


function ddzHandle:S2C_DISSOLVE_FAILED( pack )
    -- body
    dump(pack,"S2C_DISSOLVE_FAILED-0x908")
end

-----------------------------------------------------------------------------------------------------------------------------

--组局解散相关
--没有此房间，解散房间失败
function ddzHandle:G2H_CMD_DISSOLVE_FAILED(pack)

    dump("-----没有此房间，解散房间失败-----", "-----没有此房间，解散房间失败-----")

    require("hall.GameTips"):showTips("提示", "disbandGroup_fail", 2, "解散房间失败")

end

--广播当前组局解散情况
function ddzHandle:G2H_CMD_REFRESH_DISSOLVE_LIST(pack)

    dump(pack, "-----广播当前组局解散情况-----")
    dump(bm.Room.UserInfo, "-----广播当前房间情况-----")

    local applyId = tonumber(pack["applyId"])
    local agreeNum = pack.agreeNum
    local agreeMember_arr = pack.agreeMember_arr

    local showMsg = ""

    --申请解散者信息
    local applyer_info = {}
    if applyId == tonumber(UID) then
        showMsg =  "\n" .. "您申请解散房间，请等待其他玩家同意（超过5分钟未做选择，则默认同意）" .. "\n"
    else
        if bm.Room ~= nil then
            if bm.Room.UserInfo ~= nil then
                applyer_info = bm.Room.UserInfo[applyId]
                dump(applyer_info, "-----广播当前房间情况applyer_info-----")
                if applyer_info ~= nil then
                    local nickName = applyer_info.nick
                    if nickName ~= nil then
                        showMsg = "\n" .. "玩家【" .. nickName .. "】申请解散房间，请等待其他玩家同意（超过5分钟未做选择，则默认同意）" .. "\n"
                    end
                else
                    showMsg = "\n" .. "玩家申请解散房间，请等待其他玩家同意（超过5分钟未做选择，则默认同意）" .. "\n"
                end
            end
        end
    end
    
    local isMyAgree = 0
    if applyId ~= tonumber(UID) then
        --假如申请者不是自己，添加自己的选择情况
        if agreeNum > 0 then
            for k,v in pairs(agreeMember_arr) do
                if tonumber(v) == tonumber(UID) then
                    isMyAgree = 1
                    break
                end
            end
        end
        if isMyAgree == 1 then
            showMsg = showMsg .. "  【我】已同意" .. "\n"
        else
            showMsg = showMsg .. "  【我】等待选择" .. "\n"
        end
    end

    --显示其他人情况
    if bm.Room ~= nil then
        if bm.Room.UserInfo ~= nil then
            for k,v in pairs(bm.Room.UserInfo) do
                dump(v, "-----显示其他人情况-----")
                local uid = tonumber(v["uid"])
                --排除掉申请者，申请者不需要显示到这里
                if uid ~= applyId then

                    --记录当前用户是否已经同意
                    local isAgree = 0
                    if agreeNum > 0 then
                        for k,v in pairs(agreeMember_arr) do
                            if uid == tonumber(v) then
                                --当前用户已经同意
                                isAgree = 1
                                break
                            end
                        end
                    end

                    --显示当前用户情况
                    local nickName = v.nick
                    if nickName ~=nil then
                        if isAgree == 1 then
                            showMsg = showMsg .. "  【" .. nickName .. "】已同意" .. "\n"
                        else
                            showMsg = showMsg .. "  【" .. nickName .. "】等待选择" .. "\n"
                        end
                    end

                end
            end
        end
    end

    if applyId == tonumber(UID) then
        print("G2H_CMD_REFRESH_DISSOLVE_LIST 1", showMsg)
        --假如申请者是自己，则直接显示其他用户的选择情况
        require("hall.GameTips"):showDisbandTips("提示", "agree_disbandGroup", 4, showMsg)
    else
        --申请者不是自己，根据自己的同意情况进行界面显示
        if isMyAgree == 1 then
        print("G2H_CMD_REFRESH_DISSOLVE_LIST 2")
            require("hall.GameTips"):showDisbandTips("提示", "agree_disbandGroup", 4, showMsg)
        else
        print("G2H_CMD_REFRESH_DISSOLVE_LIST 3")
            require("hall.GameTips"):showDisbandTips("提示", "ddz_request_disbandGroup", 1, showMsg)
        end
    end
    

    print("G2H_CMD_REFRESH_DISSOLVE_LIST")
end

--广播桌子用户请求解散组局
function ddzHandle:SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP(pack)

    dump(pack, "-----广播桌子用户请求解散组局-----")

    -- require("hall.GameTips"):showDisbandTips("提示", "ddz_request_disbandGroup", 1, "确认解散房间")

end

--广播桌子用户成功解散组局
function ddzHandle:SERVER_BROADCAST_DISSOLVE_GROUP(pack)

    dump(pack, "-----广播桌子用户成功解散组局-----")

    bm.isDisbandSuccess = true

    -- require("hall.GameTips"):showDisbandTips("解散房间成功","ddz_disbandGroup_success",3)

end

--广播桌子用户解散组局 ，解散组局失败
function ddzHandle:SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP(pack)

    dump(pack, "-----广播桌子用户解散组局 ，解散组局失败-----")

    local rejectId = tonumber(pack["rejectId"])
    if rejectId == tonumber(UID) then
        require("hall.GameTips"):showDisbandTips("解散房间失败", "disbandGroup_fail", 2, "您拒绝解散房间")
    else
        if bm.Room ~= nil then
            if bm.Room.UserInfo ~= nil then
                if bm.Room.UserInfo[rejectId] ~= nil then
                    dump(bm.Room.UserInfo, "rejecter_info")
                    local rejecter_info = bm.Room.UserInfo[rejectId]
                    dump(rejecter_info, "rejecter_info")
                    require("hall.GameTips"):showDisbandTips("解散房间失败", "disbandGroup_fail", 2, rejecter_info.nick .. "拒绝解散房间")
                end
            end
        end
    end

end

function ddzHandle:BROADCAST_USER_IP(pack)
    for k,v in pairs(pack.playeripdata) do
        local uid = tonumber(v["uid"])
        if uid == tonumber(UID) then
            require("hall.view.userInfoView.userInfoView"):sendUserPosition(v.ip)
        end
    end

    if pack == nil then
        return
    end
    local ip_list = {}
    for k, v in pairs(pack["playeripdata"]) do
        local uid = tonumber(v["uid"])
        require("ddz.ddzSettings"):setUserIP(uid, v["ip"])
        require("hall.GameData"):setUserIP(uid, v["ip"])
        if uid ~= tonumber(UID) and uid ~= 0 then
            if ip_list[v["ip"]] == nil then
                ip_list[v["ip"]] = 1
            else
                ip_list[v["ip"]] = ip_list[v["ip"]] + 1
            end
        end
    end

    local same_ip = {}
    for k, v in pairs(ip_list) do
        print("ip_list ",tostring(k), tostring(v))
        if v > 1 then
            same_ip[k] = 1
        end
    end


    local msg = "玩家："
    local show_alert = 0
    if bm.Room ~= nil then
        for k, v in pairs(pack["playeripdata"]) do
            if same_ip[v["ip"]] ~= nil then
                local uid = tonumber(v["uid"])
                if bm.Room.UserInfo[uid] then
                    msg = msg .. "  "..bm.Room.UserInfo[uid]["nick"]
                    show_alert = 1
                end
            end
        end
    end

    if require("ddz.ddzSettings"):getGameCount() > 0 then
        show_alert = 0
    end

    if show_alert == 1 then
        require("hall.GameCommon"):showAlert(false)
        require("hall.GameCommon"):showAlert(true, "提示：" .. msg .. "  ip地址相同，谨防作弊", 300)
    end
end

--接收服务器返回的组局信息
function ddzHandle:SERVER_CMD_MESSAGE(pack)
    require("hall.view.voicePlayView.voicePlayView"):dealVoiceOrVideo(pack)
    -- if bm.isInGame == false then
    --     return
    -- end
    
    -- local msg = json.decode(pack.msg)
    -- dump(msg, "-----NiuniuroomHandle 接收服务器返回的组局信息-----")
    -- if msg ~= nil then
    --     local msgType = msg.msgType
    --     if msgType ~= nil and msgType ~= "" then

    --         if device.platform == "ios" then

    --             if msgType == "voice" then
    --                 dump("voice", "-----接收服务器返回的组局信息-----")

    --                 require("hall.view.voicePlayView.voicePlayView"):showView(msg.uid, msg.voiceTime)

    --                 --通知本地播放录音
    --                 local arr = {}
    --                 arr["url"] = msg.url
    --                 cct.getDateForApp("playVoice", arr, "V")

    --             elseif msgType == "video" then
    --                 dump("video", "-----接收服务器返回的组局信息-----")

    --                 local arr = {}
    --                 arr["url"] = msg.url
    --                 cct.getDateForApp("playVideo", arr, "V")

    --             end

    --         else

    --             if msgType == "voice" then
    --                 dump("voice", "-----接收服务器返回的组局信息-----")

    --                 require("hall.view.voicePlayView.voicePlayView"):showView(msg.uid, msg.voiceTime)

    --                 --通知本地播放录音

    --                 local data = {}
    --                 data["url"] = msg.url
                    
    --                 local arr = {}
    --                 table.insert(arr, json.encode(data))
    --                 cct.getDateForApp("playVoice", arr, "V")

    --             elseif msgType == "video" then
    --                 dump("video", "-----接收服务器返回的组局信息-----")
                    
    --                 local data = {}
    --                 data["url"] = msg.url
                    
    --                 local arr = {}
    --                 table.insert(arr, json.encode(data))
    --                 cct.getDateForApp("playVideo", arr, "V")

    --             end
            
    --         end

    --     end
    -- end
    
end

--服务器返回组局收到的信息
function ddzHandle:SERVER_CMD_FORWARD_MESSAGE( pack )
    dump(pack,"-------距离数据---------")   
    
    local msgList = pack.msgList
    for k,v in pairs(msgList) do
        if v ~= nil and v ~= "" then
            local msg = json.decode(v)
            if msg~= nil and  msg~=""  then 
                require("hall.view.userInfoView.userInfoView"):upDateUserInfo(msg.uid,msg)
            end
        end
    end
end


return ddzHandle