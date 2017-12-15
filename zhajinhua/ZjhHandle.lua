require("framework.init")


local PROTOCOL          = import("zhajinhua.Zhajinhua_Protocol")
local MenjiroomView     = import("zhajinhua.view.MenjiroomView")
local chat              = import("zhajinhua.common.chat")
local CompareView     = import("zhajinhua.view.CompareView")
local ZjhHandle   = class("ZjhHandle")

function ZjhHandle:ctor()
self.func_ = {
        [PROTOCOL.SVR_ENTER_PRIVATE_ROOM]          = {handler(self, ZjhHandle.SVR_ENTER_PRIVATE_ROOM)},
        [PROTOCOL.SVR_GET_ROOM_OK]          = {handler(self, ZjhHandle.SVR_GET_ROOM_OK)},
        [PROTOCOL.SVR_LOGIN_ROOM]           = {handler(self, ZjhHandle.SVR_LOGIN_ROOM)},
        [PROTOCOL.SVR_READY]                = {handler(self, ZjhHandle.SVR_READY)},
        [PROTOCOL.SVR_LOGIN_ROOM_BROADCAST] = {handler(self, ZjhHandle.SVR_LOGIN_ROOM_BROADCAST)},
        [PROTOCOL.SVR_QUIT_ROOM]            = {handler(self, ZjhHandle.SVR_QUIT_ROOM)},
        [PROTOCOL.SVR_BASE_BROADCAST]       = {handler(self, ZjhHandle.SVR_BASE_BROADCAST)},
        [PROTOCOL.SVR_SEND_CARD]            = {handler(self, ZjhHandle.SVR_SEND_CARD)},
        [PROTOCOL.SVR_START_BROADCAST]      = {handler(self, ZjhHandle.SVR_START_BROADCAST)},
        [PROTOCOL.SVR_QUIT]                 = {handler(self, ZjhHandle.SVR_QUIT)},
        [PROTOCOL.SVR_DIU_BROADCAST]        = {handler(self, ZjhHandle.SVR_DIU_BROADCAST)},
        [PROTOCOL.SVR_KAN_CARD]             = {handler(self, ZjhHandle.SVR_KAN_CARD)},
        [PROTOCOL.SVR_GEN_BROADCAST]        = {handler(self, ZjhHandle.SVR_GEN_BROADCAST)},
        [PROTOCOL.SVR_JIA_BROADCAST]        = {handler(self, ZjhHandle.SVR_JIA_BROADCAST)},
        [PROTOCOL.SVR_BI_BROADCAST]         = {handler(self, ZjhHandle.SVR_BI_BROADCAST)},
        [PROTOCOL.SVR_END]                  = {handler(self, ZjhHandle.SVR_END)},
        [PROTOCOL.SVR_ALL_COMPARE]          = {handler(self, ZjhHandle.SVR_ALL_COMPARE)},
        [PROTOCOL.SVR_ALLIN_BROADCAST]      = {handler(self, ZjhHandle.SVR_ALLIN_BROADCAST)},

        [PROTOCOL.SVR_MSG_FACE]={handler(self, ZjhHandle.SVR_MSG_FACE), ""},
        [PROTOCOL.SVR_GROUP_BILLBOARD] = {handler(self, ZjhHandle.SVR_GROUP_BILLBOARD), ""},
        [PROTOCOL.SVR_GROUP_TIME] = {handler(self, ZjhHandle.SVR_GROUP_TIME), ""},
        --没有此房间，解散房间失败
        [PROTOCOL.G2H_CMD_DISSOLVE_FAILED]     = {handler(self, ZjhHandle.G2H_CMD_DISSOLVE_FAILED)},
        --广播桌子用户请求解散组局
        [PROTOCOL.SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP]     = {handler(self, ZjhHandle.SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP)},
        --广播当前组局解散情况
        [PROTOCOL.G2H_CMD_REFRESH_DISSOLVE_LIST]     = {handler(self, ZjhHandle.G2H_CMD_REFRESH_DISSOLVE_LIST)},
        --广播桌子用户成功解散组局
        [PROTOCOL.SERVER_BROADCAST_DISSOLVE_GROUP]     = {handler(self, ZjhHandle.SERVER_BROADCAST_DISSOLVE_GROUP)},
        --广播桌子用户解散组局 ，解散组局失败
        [PROTOCOL.SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP]     = {handler(self, ZjhHandle.SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP)},
        --广播桌子用户ip
        [PROTOCOL.BROADCAST_USER_IP]     = {handler(self, ZjhHandle.BROADCAST_USER_IP)},
        --服务器返回组局收到的信息
        [PROTOCOL.SERVER_CMD_FORWARD_MESSAGE]     = {handler(self, ZjhHandle.SERVER_CMD_FORWARD_MESSAGE)},

        [PROTOCOL.SERVER_CMD_MESSAGE]     = {handler(self, ZjhHandle.SERVER_CMD_MESSAGE)},
    }
end

--
function ZjhHandle:callFunc(pack)
	 if self.func_[pack.cmd] and self.func_[pack.cmd][1] then
        self.func_[pack.cmd][1](pack)
    end
end

--处理进入房间
function ZjhHandle:SVR_GET_ROOM_OK(pack)

	local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_LOGIN_ROOM)
        :setParameter("tid", pack['tid'])
        :setParameter("uid", tonumber(UID))
        :setParameter("mtkey", "")
        :setParameter("strinfo", USER_INFO["user_info"])
        :build()
    bm.server:send(pack)
    dump(USER_INFO["user_info"], "SVR_GET_ROOM_OK", nesting)
end


--登录房间成功
function ZjhHandle:SVR_LOGIN_ROOM( pack )
	-- body

    bm.Room.uid_seat  = {}
    bm.Room.seat_uid  = {}
    local uid         = tostring(UID)
    local seat        = tostring(pack.seat)
    bm.Room.uid_seat[tonumber(UID)]  = pack.seat
    bm.Room.seat_uid[pack.seat] = tonumber(UID)
    bm.Room.zhus      = {}
    bm.Room.now_zhu   = pack.base
    bm.Room.now_turns = 0
    bm.User.UserInfo  = {}
    bm.User.online  = {}
    bm.User.chips  = {}
    bm.User.Seat      = pack.seat
    bm.User.Gold      = pack.gold
    bm.User.Cards     = {}
    bm.User.isKan     = {} --玩家是否看牌
    bm.User.isDiu     = {} --玩家是否弃牌
    bm.Room.anim      = 0
    bm.Room.chips     = {}
    bm.Room.over      = true
    bm.Room.all_compare = 0
    bm.Room.result = nil
    bm.Room.init_chips = 0
    bm.Room.banker = nil

    bm.Room.show_card = 0
    bm.Room.show_cards = {}


    display_scene("zhajinhua.scenes.MenjiroomScenes", 1)

    print("SVR_LOGIN_ROOM", SCENENOW["name"])

    bm.User.UserInfo[tonumber(UID)] = USER_INFO["user_info"]
    bm.User.online[tonumber(UID)] = 1
    bm.User.chips[tonumber(UID)] = pack["gold"]
    bm.Room.init_chips = pack["table_chips"]

    MenjiroomView:showMyinfo()
    --牌局未开始
    if pack.status == 0 then
        for k,v in pairs(pack.nostart[1].userInfo) do
            self:SVR_LOGIN_ROOM_BROADCAST(v)
            if v.if_ready == 1 then
                MenjiroomView:showReady(v.uid)
            end
        end
        --显示房间信息
        local tmp_pack = {}
        tmp_pack.all_zhu   = 0
        tmp_pack.all_turns = 0
        tmp_pack.now_turns = 0
        MenjiroomView:showRoomInfo(tmp_pack)
    end


    --牌局开始
    if pack.status == 2 then
        for k,v in pairs(pack.start[1].userinfos) do
            dump(v, "SVR_LOGIN_ROOM "..tostring(v["uid"]), nesting)
            self:SVR_LOGIN_ROOM_BROADCAST(v)
        end
        require("hall.gameSettings"):setGroupState(1)

        -- 邀请好友
        local invite_ly = SCENENOW["scene"].view._view:getChildByName("invite_ly")
        if invite_ly then
            invite_ly:setVisible(false)
        end
        --显示房间信息
        local tmp_pack = {}
        tmp_pack.all_zhu   = pack.start[1].all_xia
        tmp_pack.all_turns = pack.start[1].all_cycle
        tmp_pack.now_turns = pack.start[1].now_cycle
        MenjiroomView:showRoomInfo(tmp_pack)

        dump(pack.start[1], "SVR_LOGIN_ROOM 2", nesting)
        bm.Room.now_turns = pack.start[1].now_cycle
        bm.Room.totalRound = pack.start[1].all_cycle
        bm.Room.now_zhu = pack.start[1]["now_xia"]
        bm.Room.min_pk = pack.start[1]["min_pk"]
        bm.Room.min_allin = pack.start[1]["min_allin"]


        MenjiroomView:showBanker(pack.start[1]["zhuang_seat"])
        if bm.Room == nil then
            bm.Room = {}
        end
        bm.Room.start_group = 1

        MenjiroomView:sendCard()
        for k,v in pairs(pack.start[1].userinfos) do
            if v.if_ready == 1 then
                MenjiroomView:showReady(v["uid"])
            end
            if v["if_check"] == 1 then --是否已看牌
                bm.User.isKan[v["uid"]] = 1
                MenjiroomView:showKanpai(v["uid"])
            end
            if v["cancel"] == 1 then -- 是否弃牌
                MenjiroomView:showQipai(v["uid"])
                bm.User.isDiu[v["uid"]] = 1
            end
            if v["xia"] > 0 then -- 已下注
                -- MenjiroomView:diuChips(v["uid"],v["xia"])
                MenjiroomView:showNowZhu(v["uid"],v["xia"])
                bm.User.chips[tonumber(v["uid"])] = v["xia"]
            end
            if v["bet_values"] then
                for kk, vv in pairs(v["bet_values"]) do
                    MenjiroomView:diuChips(v["uid"],vv)
                end
            end
        end
        -- 玩家自己信息
        if pack.start[1]["play_content"] then
            local data = pack.start[1]["play_content"][1]
            dump(data, "SVR_LOGIN_ROOM ", nesting)
            if data["if_check"] == 1 then --是否已看牌
                bm.User.Cards = data["cards"]
                bm.User.card_type=data["card_type"]
                MenjiroomView:setCards()
                bm.User.isKan[tonumber(UID)] = 1
                MenjiroomView:showKanpai(tonumber(UID))
            end
            if data["cancel"] == 1 then -- 是否弃牌
                MenjiroomView:showQipai(tonumber(UID))
                bm.User.isDiu[tonumber(UID)] = 1
            end
            if data["user_all_xia"] > 0 then -- 已下注
                -- MenjiroomView:diuChips(UID,data["user_all_xia"])
                MenjiroomView:showNowZhu(tonumber(UID),data["user_all_xia"])
                bm.User.chips[tonumber(UID)] = data["user_all_xia"]
            end
            if data["bet_values"] then
                for kk, vv in pairs(data["bet_values"]) do
                    MenjiroomView:diuChips(tonumber(UID),vv)
                end
            end
            bm.Room.zhus = data["add_value"]
        end
        
        local next_uid = bm.Room.seat_uid[pack.start[1]["now_seat"]]
        MenjiroomView:showRoomButton(next_uid, pack.start[1]["can_compare"], pack.start[1]["is_allin"])
        MenjiroomView:showProgressTimer(next_uid, 15)
    end

    SCENENOW["scene"].view:setBaseChip(pack["base"])

    
    require("zhajinhua.zjhSettings"):updateUserList()
    --添加录音按钮
    require("hall.VoiceRecord.VoiceRecordView"):showView(898.38, 68.60)

    -- 自动准备
    require("zhajinhua.ZhajinHuaServer"):CLI_READYNOW_ROOM()
end


--结算协议
function ZjhHandle:SVR_END(pack)
    bm.Room.over = false
    bm.Room.isover = true
    require("hall.gameSettings"):setGroupState(0)
    if bm.Room.all_compare and bm.Room.all_compare == 1 then
        bm.Room.result = pack
    else
        if bm.Room.show_card and bm.Room.show_card > 0 then

            for k, v in pairs(bm.Room.show_cards) do
                MenjiroomView:setCards(k, v)
                MenjiroomView:showCard(k)
            end
            local user_node_f = MenjiroomView:getUserNode(pack["userinfos"][1]["uid"])
            if user_node_f then
                user_node_f:runAction(cc.Sequence:create(cc.DelayTime:create(2), cc.CallFunc:create(function()
                    MenjiroomView:gameEnd(pack)
                end)))
            end
        else
            MenjiroomView:gameEnd(pack)
        end
    end
end

--广播全桌比牌
function ZjhHandle:SVR_ALL_COMPARE( pack )
    -- body
    MenjiroomView:AllCompare()
end

--广播比牌结果
function ZjhHandle:SVR_BI_BROADCAST( pack )
    -- body

    bm.Room.all_compare = 1
    bm.Room.result = nil

    bm.Room.anim = 7

    local delay_compare = 0
    bm.Room.show_card = 0
    bm.Room.show_cards = {}

    local user_node = MenjiroomView:getUserNode(tonumber(UID))

    local uid = tonumber(pack["uid"])

    if pack["f_cards"] and pack["f_cards"] > 0 then
        bm.Room.show_cards[uid] = {}
        bm.Room.show_cards[uid] = pack["f_card"]
        bm.Room.show_card = 1
    end
    if pack["s_cards"] and pack["s_cards"] > 0 then
        bm.Room.show_cards[pack["buid"]] = {}
        bm.Room.show_cards[pack["buid"]] = pack["s_card"]
        bm.Room.show_card = 1
    end
 
    if pack.next_seat == -1 then
        if bm.Room.seatProgressTimer ~= nil then
            if bm.Room.seatProgressTimer:getParent() then
                bm.Room.seatProgressTimer:removeSelf()
            end
            bm.Room.seatProgressTimer = nil
        end

        MenjiroomView:resetOperate()
    else
        local next_uid = bm.Room.seat_uid[pack["next_seat"]]
        if next_uid then
            MenjiroomView:showProgressTimer(next_uid,pack.time)
            MenjiroomView:showRoomButton(next_uid, pack["can_compare"])
        end

        if tonumber(next_uid) == tonumber(UID) then
            bm.Room.zhus = pack.zhus
        end
    end

    -- 设置比牌结果
    if pack["result"] then
        if pack["result"] == 0 then
            bm.User.isDiu[uid] = 1
        else
            bm.User.isDiu[pack["buid"]] = 1
        end
    end

    MenjiroomView:diuChips(uid,pack.kou_gold)
    MenjiroomView:showNowZhu(uid,pack.user_zhu)
    MenjiroomView:showRoomInfo(pack)
    bm.User.chips[uid] = bm.User.chips[uid] + pack["kou_gold"]

    -- 游戏音效
    local data_info = json.decode(bm.User.UserInfo[uid])
    if data_info then
        dump(data_info, "SVR_BI_BROADCAST", nesting)
        if data_info["sex"] == 1 or data_info["sex"] == "1" then --男
            require("hall.GameCommon"):playEffectSound("zhajinhua/res/audio/f_cmp.mp3")
        elseif data_info["sex"] == 2 or data_info["sex"] == "2" then
            require("hall.GameCommon"):playEffectSound("zhajinhua/res/audio/m_cmp.mp3")
        end
    end
    -- CompareView:showCampare(pack.uid,pack.buid,pack.result)

    require("zhajinhua.view.CompareView"):showCampare(uid,pack["buid"],pack["result"])
    for k,v in pairs(bm.Room.uid_seat) do
        local uid_seat = tonumber(k)
        if tonumber(uid_seat) ~= tonumber(UID) then
            local user_node = MenjiroomView:getUserNode(uid_seat)
            if user_node~= nil then
                 local tmp = user_node:getChildByName("kuang_node")
                 if tmp ~= nil then
                    tmp:removeSelf()
                 end
            end
                  
        end
    end

end

--广播玩家加注
function ZjhHandle:SVR_JIA_BROADCAST(pack)
    local next_seat = pack.next_seat
    local next_uid  = bm.Room.seat_uid[next_seat]
    if next_uid == nil then
        return
    end

    local uid = tonumber(pack["uid"])


    MenjiroomView:chatContent(uid,chat[5]['font'])
    bm.Room.now_zhu    = pack["round_chips"]
    bm.Room.now_turns  = pack.now_turns
    MenjiroomView:showProgressTimer(next_uid,pack.time)
    MenjiroomView:diuChips(uid,pack.gold)
    MenjiroomView:showRoomInfo(pack)
    MenjiroomView:showNowZhu(uid,pack.user_zhu)
    MenjiroomView:showRoomButton(next_uid, pack["can_compare"])

    bm.User.chips[uid] = bm.User.chips[uid] + pack["gold"]
    if tonumber(next_uid) == tonumber(UID) then
        bm.Room.zhus      = pack.zhus
    end

    -- 游戏音效
    local data_info = json.decode(bm.User.UserInfo[uid])
    if data_info then
        dump(data_info, "SVR_BI_BROADCAST", nesting)
        if data_info["sex"] == 1 or data_info["sex"] == "1" then --男
            require("hall.GameCommon"):playEffectSound("zhajinhua/res/audio/f_add.mp3")
        elseif data_info["sex"] == 2 or data_info["sex"] == "2" then
            require("hall.GameCommon"):playEffectSound("zhajinhua/res/audio/m_add.mp3")
        end
    end
end

--广播玩家allin
function ZjhHandle:SVR_ALLIN_BROADCAST(pack)
    local next_seat = pack.next_seat
    local uid = tonumber(pack["uid"])

    MenjiroomView:showAllin()
    MenjiroomView:chatContent(uid,chat[5]['font'])
    bm.Room.now_zhu    = pack.gold
    bm.Room.now_turns  = pack.now_turns
    MenjiroomView:diuChips(uid,pack["gold"])
    MenjiroomView:showNowZhu(uid,pack["gold"], 1)
    MenjiroomView:showRoomInfo(pack)

    bm.User.chips[uid] = bm.User.chips[uid] + pack["gold"]

    local next_uid  = bm.Room.seat_uid[next_seat]
    if next_uid then
        MenjiroomView:showProgressTimer(next_uid,pack.time)
        MenjiroomView:showRoomButton(next_uid, 0,1)
    end
    -- 游戏音效
    local data_info = json.decode(bm.User.UserInfo[uid])
    if data_info then
        if data_info["sex"] == 1 or data_info["sex"] == "1" then --男
            require("hall.GameCommon"):playEffectSound("zhajinhua/res/audio/f_allin.mp3")
        elseif data_info["sex"] == 2 or data_info["sex"] == "2" then
            require("hall.GameCommon"):playEffectSound("zhajinhua/res/audio/m_allin.mp3")
        end
    end
end


--玩家看牌
function ZjhHandle:SVR_KAN_CARD(pack)
    local uid = tonumber(pack["uid"])

    bm.User.isKan[uid] = 1
    MenjiroomView:chatContent(uid,chat[6]['font'])
    MenjiroomView:showKanpai(uid)

    -- 游戏音效
    local data_info = json.decode(bm.User.UserInfo[uid])
    if data_info then
        if tonumber(data_info["sex"]) == 1 then --男
            require("hall.GameCommon"):playEffectSound("zhajinhua/res/audio/f_see.mp3")
        elseif tonumber(data_info["sex"]) == 2 then
            require("hall.GameCommon"):playEffectSound("zhajinhua/res/audio/m_see.mp3")
        end
    end
end


--玩家跟注
function ZjhHandle:SVR_GEN_BROADCAST(pack)

    local next_seat = pack.next_seat
    local next_uid  = bm.Room.seat_uid[next_seat]
    if next_uid == nil then
        MenjiroomView:resetOperate()
        return
    end

    local uid = tonumber(pack["uid"])

    local point = 0
    if bm.User.isKan[uid] == nil then
        point = 2
        if pack.now_turns >=3 then
            local num = math.random(1,10)
            if num >= 7 then
                point = 7
            else
                point = 2
            end
        end
    else
        point = 1
        if pack.now_turns >=3 then
            local num = math.random(1,10)
            if num >= 7 then
                point = 10
            else
                point = 1
            end
        else
            local num = math.random(1,10)
            if num >= 7 then
                point = 8
            end
        end

    end
    
    MenjiroomView:chatContent(uid,chat[point]['font'])

    bm.Room.now_turns  = pack.now_turns
    MenjiroomView:showProgressTimer(next_uid,pack.time)
    MenjiroomView:diuChips(uid,pack.gold)
    MenjiroomView:showRoomInfo(pack)
    MenjiroomView:showNowZhu(uid,pack.user_zhu)
    MenjiroomView:showRoomButton(next_uid, pack["can_compare"])

    bm.User.chips[uid] = bm.User.chips[uid] + pack["gold"]

    if tonumber(next_uid) == tonumber(UID) then
        bm.Room.zhus      = pack.zhus
    end

    -- 游戏音效
    local data_info = json.decode(bm.User.UserInfo[uid])
        dump(data_info, "SVR_GEN_BROADCAST", nesting)
    if data_info == nil then
        dump(bm.User.UserInfo, "SVR_GEN_BROADCAST", nesting)
    end
    if data_info then
        if data_info["sex"] == 1 or data_info["sex"] == "1" then --男
            require("hall.GameCommon"):playEffectSound("zhajinhua/res/audio/f_follow1.mp3")
        elseif data_info["sex"] == 2 or data_info["sex"] == "2" then
            require("hall.GameCommon"):playEffectSound("zhajinhua/res/audio/m_follow1.mp3")
        end
    end
end


--玩家弃牌
function ZjhHandle:SVR_DIU_BROADCAST( pack )
    local uid = tonumber(pack["uid"])

    bm.User.isDiu[uid] = 1

    if pack.next_id  ~= -1 then
        local next_id = bm.Room.seat_uid[pack.next_id]
        MenjiroomView:showProgressTimer(next_id,pack.time)
        local is_allin = 0
        if pack["game_status"] == 4 then
            is_allin = 1
        end
        MenjiroomView:showRoomButton(next_id, pack["can_compare"], is_allin)

        if tonumber(next_id) == tonumber(UID) then
            bm.Room.zhus = pack["zhus"]
        end
    end

    bm.Room.now_turns  = pack["now_turn"]
    bm.Room.totalRound = pack["all_turns"]
    MenjiroomView:showRounds()
    MenjiroomView:showQipai(uid)
    local point = 4
    local num   =  math.random(1,10)
    if num % 2 ==0 then
        point = 3
    end
    MenjiroomView:chatContent(uid,chat[point]['font'])
    -- 游戏音效
    local data_info = json.decode(bm.User.UserInfo[uid])
    if data_info then
        if data_info["sex"] == 1 or data_info["sex"] == "1" then --男
            require("hall.GameCommon"):playEffectSound("zhajinhua/res/audio/f_giveup.mp3")
        elseif data_info["sex"] == 2 or data_info["sex"] == "2" then
            require("hall.GameCommon"):playEffectSound("zhajinhua/res/audio/m_giveup.mp3")
        end
    end
end

--用户准备
function ZjhHandle:SVR_READY(pack)
    local scenes  = SCENENOW["scene"].view._view
    if bm.Room.over == true then
        local zhezhao = scenes:getChildByName("zhezhao")
        if zhezhao ~= nil then
            zhezhao:removeSelf()
        end
    end
    local uid  = tonumber(pack["uid"])

    MenjiroomView:showReady(uid)
    if uid == tonumber(UID) then
        MenjiroomView:resetGame()
    end
end


--用户入场
function ZjhHandle:SVR_LOGIN_ROOM_BROADCAST(pack)

    local uid  = tonumber(pack["uid"])
    local seat = tostring(pack.seat)
    bm.Room.uid_seat[uid]  = pack.seat
    bm.Room.seat_uid[pack.seat] = uid

    -- local user_info = json.decode(pack["info"])
    bm.User.UserInfo[uid]  = pack["info"]
    bm.User.online[uid] = 1
    bm.User.chips[uid] = pack["gold"]
 
    MenjiroomView:showUserInfo(pack)

    require("zhajinhua.zjhSettings"):updateUserList()
end

--用户离场
function ZjhHandle:SVR_QUIT_ROOM(pack)
    local uid  = tonumber(pack["uid"])
    local seat = bm.Room.uid_seat[uid]

    -- bm.Room.seat_uid[seat]      = nil
    -- bm.Room.uid_seat[uid]       = nil
    bm.User.isKan[uid]     = nil
    bm.User.isDiu[uid]     = nil
    
    if bm.User.UserInfo[uid] then
        bm.User.online[uid] = 0
    end

    require("zhajinhua.zjhSettings"):updateUserList()
end

--自己离场
function ZjhHandle:SVR_QUIT(pack)
    if bm.Room.seatProgressTimer ~= nil then
        if bm.Room.seatProgressTimer:getParent() then
            bm.Room.seatProgressTimer:removeSelf()
        end
        bm.Room.seatProgressTimer = nil
    end

    bm.User.online[tonumber(UID)] = 0
    require("zhajinhua.zjhSettings"):updateUserList()
    if bm.notCheckReload and bm.notCheckReload == 1 then
        require("hall.GameTips"):enterHall()
    end
end
    


--广播台费
function ZjhHandle:SVR_BASE_BROADCAST(pack)
    --改变玩家金币
    MenjiroomView:changeGold(pack)
end

--发牌
function ZjhHandle:SVR_SEND_CARD(pack)
    print(pack,"SVR_SEND_CARD")
    bm.User.Cards = pack.cards
    bm.User.card_type=pack.card_type
    MenjiroomView:setCards()
end


--广播开始
function ZjhHandle:SVR_START_BROADCAST(pack)

     local is_alert = true
    print("IP广播",bm.round,bm.Room.isStart)
    dump(bm.ips, "ips")

    bm.Room.UserInfo = {}
    for k,v in pairs(bm.User.UserInfo) do
        local user_data = json.decode(v)
        bm.Room.UserInfo[k] = {}
        bm.Room.UserInfo[k]["nick"] = user_data["nickName"]
    end
    dump(bm.Room.UserInfo, "user_info")


    if bm.round and tonumber(bm.round) > 1 then
        is_alert = false
    end

    if is_alert then
        require("hall.GameTips"):showIPAlert(bm.ips["playeripdata"])
    end

  
    SCENENOW["scene"].view:setBaseChip(pack["base"])
    require("hall.gameSettings"):setGroupState(1)

    require("zhajinhua.zjhSettings"):addGame()
    -- 初始化玩家下注
    for k, v in pairs(bm.User.chips) do
        bm.User.chips[k] = 0
    end
    dump(bm.User.chips, "SVR_START_BROADCAST")

    local uid  = ""
    local seat = pack.handle_seat
    bm.Room.now_zhu   = pack.base

    if bm.User.Seat == seat then
        uid  = tonumber(UID)
    else
        uid  = bm.Room.seat_uid[seat]
    end

    bm.Room.now_turns  = pack.now_turns
    bm.Room.min_pk = pack["min_pk_round"]
    bm.Room.min_allin = pack["min_allin_round"]
    bm.Room.zhus      = pack.zhu_values
    bm.Room.init_chips = pack["table_chips"]

    MenjiroomView:showBanker(pack["zhuang_seat"])
    MenjiroomView:showRoomInfo(pack)
    --显示倒计时
    MenjiroomView:showProgressTimer(uid,pack.time)

    MenjiroomView:showRoomButton(uid, pack["can_compare"])
    --该我操作了
    if tonumber(uid) == tonumber(UID) then


    else
        --弃牌
        --弃牌
        local qi_green = SCENENOW["scene"].view._view:getChildByName("base_foot")
        if qi_green then
            qi_green:setOpacity(255)
            qi_green:setEnabled(true)
        end

        --跟注
        --[[local gen_grey  = scenes:getChildByName("gen_grey")
        local gen_green = scenes:getChildByName("gen_green")
        gen_grey:setVisible(true)
        gen_green:setVisible(false)]]

        --加注
        --[[local jia_grey  = scenes:getChildByName("jia_grey")
        local jia_green = scenes:getChildByName("jia_green")
        jia_grey:setVisible(true)
        jia_green:setVisible(false)]]
    end
   
    for k,v in pairs(bm.Room.uid_seat) do
        MenjiroomView:diuChips(k,bm.Room.now_zhu)
        MenjiroomView:showNowZhu(k,bm.Room.now_zhu)
        bm.User.chips[k] = bm.Room.now_zhu
    end

    --删除准备的按钮
    for k,v in pairs(bm.Room.uid_seat) do
        local node = MenjiroomView:getUserNode(k)
        
        if node ~= nil then
            local ready = node:getChildByName("ready")
            if ready then
                ready:removeSelf()
            end
        end
       
    end


    -- 邀请好友
    local invite_ly = SCENENOW["scene"].view._view:getChildByName("invite_ly")
    if invite_ly then
        invite_ly:setVisible(false)
    end


    if bm.Room == nil then
        bm.Room = {}
    end
    bm.Room.start_group = 1

    
    MenjiroomView:sendCard()
end

--聊天相关
function ZjhHandle:SVR_MSG_FACE(pack)

    dump(pack, "-----文字聊天信息返回 1004-----")

    local faceUI = SCENENOW["scene"].view._view:getChildByName("faceUI")
    if faceUI == nil then
        print("scene:"..SCENENOW["name"],"not match faceUI")
        return
    end
    --去掉提示弹框
    local layer_tips = SCENENOW["scene"]:getChildByName("layer_tips")
    if layer_tips then
        layer_tips:removeSelf()
    end

    local uid = tonumber(pack["uid"])

    local index  = MenjiroomView:getIndex(uid)
    local sexT = 2
    local isLeft = false
    local node_head = MenjiroomView:getUserNode(uid):getChildByName("head")

    --性别,头像位置
    if index == 0 then
        sexT = USER_INFO["sex"]

    else
        local othInfo = json.decode(bm.User.UserInfo[uid])
        dump(othInfo, "-----othInfo-----")
        if othInfo ~= nil then
            sexT = tonumber(othInfo.sex)
        end

    end

    if index > 2 then
       isLeft = true
    end

    dump(node_head, "-----node_head-----")
    dump(sexT, "-----sexT-----")
    dump(index, "-----index-----")

    if faceUI ~= nil and node_head ~= nil then
        faceUI:showGetFace(uid, pack.type, tonumber(sexT), node_head, isLeft)
    end
end

--组局排行榜
function ZjhHandle:SVR_GROUP_BILLBOARD(pack)
    dump(pack,"组局结束")
    bm.Room.iswith = true
    if pack then
        MenjiroomView:onNetBillboard(pack)
        if bm.Room == nil then
            bm.Room = {}
        end
        bm.Room.start_group = 0
    end

end
--组局时长
function ZjhHandle:SVR_GROUP_TIME(pack)
    if pack == nil then
        return
    end

    bm.round = pack.round + 1

    if bm.Room.GroupInfo == nil then
        bm.Room.GroupInfo = {}
    end
    bm.Room.GroupInfo["round"] = pack["round"]
    bm.Room.GroupInfo["round_total"] = pack["round_total"]

    dump(bm.Room.GroupInfo, "SVR_GROUP_TIME")
    -- if SCENENOW["scene"].view:updateRound then
        SCENENOW["scene"].view:updateRounds(bm.Room.GroupInfo["round"], bm.Room.GroupInfo["round_total"])
    -- end
end
--组局解散相关
--没有此房间，解散房间失败
function ZjhHandle:G2H_CMD_DISSOLVE_FAILED(pack)

    dump("-----没有此房间，解散房间失败-----", "-----没有此房间，解散房间失败-----")

    require("hall.GameTips"):showTips("提示", "disbandGroup_fail", 2, "解散房间失败")

end

--广播当前组局解散情况
function ZjhHandle:G2H_CMD_REFRESH_DISSOLVE_LIST(pack)

    dump(pack, "-----广播当前组局解散情况-----")
    dump(bm.User.UserInfo, "-----广播当前房间情况-----")

    local applyId = tonumber(pack.applyId)
    local agreeNum = pack.agreeNum
    local agreeMember_arr = pack.agreeMember_arr

    local showMsg = ""

    --申请解散者信息
    local applyer_info = {}
    if applyId == tonumber(UID) then
        showMsg =  "\n" .. "您申请解散房间，请等待其他玩家同意（超过5分钟未做选择，则默认同意）" .. "\n"
    else
        if bm.User ~= nil then
            if bm.User.UserInfo ~= nil then
                applyer_info = bm.User.UserInfo[applyId]
                applyer_info = json.decode(applyer_info)
                dump(applyer_info, "-----广播当前房间情况applyer_info-----")
                if applyer_info ~= nil then
                    local nickName = applyer_info["nickName"]
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
                if v == tonumber(UID) then
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
    if bm.User ~= nil then
        if bm.User.UserInfo ~= nil then
            for k,v in pairs(bm.User.UserInfo) do
                dump(v, "-----显示其他人情况-----")
                local uid = k
                --排除掉申请者，申请者不需要显示到这里
                if uid ~= applyId then

                    --记录当前用户是否已经同意
                    local isAgree = 0
                    if agreeNum > 0 then
                        for k,m in pairs(agreeMember_arr) do
                            if uid == m then
                                --当前用户已经同意
                                isAgree = 1
                                break
                            end
                        end
                    end

                    --显示当前用户情况
                    local user_data = json.decode(v)
                    local nickName = user_data["nickName"]
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
        --假如申请者是自己，则直接显示其他用户的选择情况
        require("hall.GameTips"):showDisbandTips("提示", "agree_disbandGroup", 4, showMsg)
    else
        --申请者不是自己，根据自己的同意情况进行界面显示
        if isMyAgree == 1 then
            require("hall.GameTips"):showDisbandTips("提示", "agree_disbandGroup", 4, showMsg)
        else
            require("hall.GameTips"):showDisbandTips("提示", "zjh_request_disbandGroup", 1, showMsg)
        end
    end
    

end

--广播桌子用户请求解散组局
function ZjhHandle:SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP(pack)

    dump(pack, "-----广播桌子用户请求解散组局-----")

    -- require("hall.GameTips"):showDisbandTips("提示", "ddz_request_disbandGroup", 1, "确认解散房间")

end

--广播桌子用户成功解散组局
function ZjhHandle:SERVER_BROADCAST_DISSOLVE_GROUP(pack)

    dump(pack, "-----广播桌子用户成功解散组局-----")

    bm.isDisbandSuccess = true

    -- require("hall.GameTips"):showDisbandTips("解散房间成功","ddz_disbandGroup_success",3)

end

--广播桌子用户解散组局 ，解散组局失败
function ZjhHandle:SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP(pack)

    dump(pack, "-----广播桌子用户解散组局 ，解散组局失败-----")

    local rejectId = tonumber(pack.rejectId)
    if rejectId == tonumber(UID) then
        require("hall.GameTips"):showDisbandTips("解散房间失败", "disbandGroup_fail", 2, "您拒绝解散房间")
    else
        if bm.User ~= nil then
            if bm.User.UserInfo ~= nil then
                if bm.User.UserInfo[rejectId] ~= nil then
                    local rejecter_info = bm.User.UserInfo[rejectId]
                    rejecter_info = json.decode(rejecter_info)
                    require("hall.GameTips"):showDisbandTips("解散房间失败", "disbandGroup_fail", 2, rejecter_info["nickName"] .. "拒绝解散房间")
                end
            end
        end
    end

end

function ZjhHandle:BROADCAST_USER_IP(pack)
    print("*********广播玩家IP*********")
    for k,v in pairs(pack.playeripdata) do
        if v.uid == tonumber(UID) then
            require("hall.view.userInfoView.userInfoView"):sendUserPosition(v.ip)
        end
    end

    bm.ips = pack

    -- if pack == nil then
    --     return
    -- end
    local ip_list = {}
    for k, v in pairs(pack["playeripdata"]) do
        local uid = tonumber(v["uid"])
        require("hall.GameData"):setUserIP(uid, v["ip"])
    end

    -- local same_ip = {}
    -- for k, v in pairs(ip_list) do
    --     print("ip_list ",tostring(k), tostring(v))
    --     if v > 1 then
    --         same_ip[k] = 1
    --     end
    -- end


    -- local msg = "玩家："
    -- local show_alert = 0
    -- if bm.User ~= nil then
    --     for k, v in pairs(pack["playeripdata"]) do
    --         if same_ip[v["ip"]] ~= nil then
    --             local uid = tonumber(v["uid"])
    --             if bm.User.UserInfo[uid] and uid ~= tonumber(UID) then
    --                 dump(bm.User.UserInfo[uid], "BROADCAST_USER_IP 1", nesting)
    --                 local nick = bm.User.UserInfo[uid]
    --                 nick = json.decode(nick)
    --                 msg = msg .. "  "..nick["nickName"]
    --                 show_alert = 1
    --             end
    --         end
    --     end
    -- end


    -- if bm.Room.GroupInfo and bm.Room.GroupInfo["round"] and bm.Room.GroupInfo["round"] > 0 then
    --     show_alert = 0
    -- end

    -- if show_alert == 1 then
    --     require("hall.GameCommon"):showAlert(false)
    --     require("hall.GameCommon"):showAlert(true, "提示：" .. msg .. "  ip地址相同，谨防作弊", 300)
    -- end
end

function ZjhHandle:CLI_MSG_FACE(id)
    local sendpack = bm.server:createPacketBuilder(PROTOCOL.CLI_MSG_FACE)
                    :setParameter("type", id)
                    :build()
    bm.server:send(sendpack)
end

function ZjhHandle:SVR_ENTER_PRIVATE_ROOM( pack )

  require("hall.GameTips"):showTips("系统错误", "tohall", 3, "房间不存在")

end

function ZjhHandle:SERVER_CMD_FORWARD_MESSAGE( pack )
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

function ZjhHandle:SERVER_CMD_MESSAGE( pack )
    require("hall.view.voicePlayView.voicePlayView"):dealVoiceOrVideo(pack)
end

return ZjhHandle