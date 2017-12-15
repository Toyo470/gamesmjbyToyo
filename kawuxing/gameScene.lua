require("kawuxing.globle.KWXData")
require("kawuxing.globle.KWXDefine")

local gamePlaneOperator = require("kawuxing.operator.GamePlaneOperator")
local manyouPlaneOperator = require("kawuxing.operator.ManyouPlaneOperator")

local PROTOCOL = import("kawuxing.handle.KWXProtocol")
local sendHandle = require("kawuxing.handle.KWXSendHandle")
local receiveHandle = require("kawuxing.handle.KWXReceiveHandle")

local kwx_face=require("hall.FaceUI.faceUI")

local CHILD_NAME_MANYOU_PLANE = "manyou_plane"

local CHILD_NAME_SETTING_BT = "setting_bt"
local CHILD_NAME_CLOSE_ROOM_BT = "close_room_bt"
local CHILD_NAME_EXIT_BT = "exit_bt"
local CHILD_NAME_SHARE_BT = "share_bt"
local CHILD_NAME_RECORD_BT = "record_bt"
local CHILD_NAME_CHAT_BT = "chat_bt"
local CHILD_NAME_VOICE_TEMP_BT = "voice_temp_bt"

local KWXScene = class("KWXScene", function()
		return display:newScene()
	end)

local CHILD_NAME_ROOM_LB = "room_lb"

function KWXScene:ctor()
	bm.server:setProtocol(PROTOCOL)
    bm.server:setHandle(receiveHandle.new())

	self._scene = cc.CSLoader:createNode("kawuxing/GameScene.csb"):addTo(self)

    self.reay_my = cc.Sprite:create("kawuxing/image/mahjong_ready.png")
    self._scene:addChild(self.reay_my)
    self.reay_my:setPosition(cc.p(480, 180))
    self.reay_my:setVisible(false)

    self.reay_right = cc.Sprite:create("kawuxing/image/mahjong_ready.png")
    self._scene:addChild(self.reay_right)
    self.reay_right:setPosition(cc.p(620, 270))
    self.reay_right:setVisible(false)

    self.reay_left = cc.Sprite:create("kawuxing/image/mahjong_ready.png")
    self._scene:addChild(self.reay_left)
    self.reay_left:setPosition(cc.p(340, 270))
    self.reay_left:setVisible(false)

    if not bm.Room then
        bm.Room = {}
    end
    if not bm.Room.KWX_uid_seatid then
        bm.Room.KWX_uid_seatid = {}
    end


	KWX_GAME_PLANE = self._scene:getChildByName("game_plane")

    local kwx_face_node = kwx_face.new();
    kwx_face_node:setHandle(sendHandle)
    self:addChild(kwx_face_node, 9999)
    kwx_face_node:setName("faceUI")

    dump(KWX_GAME_PLANE, "kawuxing test")

	KWX_CONTROLLER = require("kawuxing.GameController")

	gamePlaneOperator:init()

	KWX_MANYOU_PLANE = self._scene:getChildByName(CHILD_NAME_MANYOU_PLANE)
	manyouPlaneOperator:init()

	local setting_bt = self._scene:getChildByName(CHILD_NAME_SETTING_BT)
	local close_room_bt = self._scene:getChildByName(CHILD_NAME_CLOSE_ROOM_BT)

	setting_bt:setVisible(false)
	setting_bt:addTouchEventListener(
        function(sender,event)
            --触摸开始
            if event == TOUCH_EVENT_BEGAN then
            	sender:setScale(0.9)
            end

            --触摸取消
            if event == TOUCH_EVENT_CANCELED then
            	sender:setScale(1.0)
            end

            --触摸结束
            if event == TOUCH_EVENT_ENDED then
            	sender:setScale(1.0)

            	require("hall.GameCommon"):showSettings(true,false,true,true,function(sender, event)
            			--     --触摸开始
		                if event == TOUCH_EVENT_BEGAN then
		                    sender:setScale(0.9)
		                end

		                --触摸取消
		                if event == TOUCH_EVENT_CANCELED then
		                    sender:setScale(1.0)
		                end

		                --触摸结束
		                if event == TOUCH_EVENT_ENDED then
		                    sender:setScale(1.0)

		                    require("hall.GameCommon"):showSettings(false)

		                    self:disbandGroup()

		                end
            		end)

            end
        end
    )

	local group_owner = tonumber(USER_INFO["group_owner"])
	--只有房主才出现解散按钮
	-- if group_owner ~= tonumber(UID) then
	-- 	close_room_bt:setVisible(false)
	-- end
	close_room_bt:addTouchEventListener(
        function(sender,event)
            --触摸开始
            if event == TOUCH_EVENT_BEGAN then
            	sender:setScale(0.9)
            end

            --触摸取消
            if event == TOUCH_EVENT_CANCELED then
            	sender:setScale(1.0)
            end

            --触摸结束
            if event == TOUCH_EVENT_ENDED then
            	sender:setScale(1.0)

            	self:disbandGroup()

            end
        end
    )

    --返回按钮
	local exit_bt = self._scene:getChildByName(CHILD_NAME_EXIT_BT)
	exit_bt:addTouchEventListener(
        function(sender,event)
            --触摸开始
            if event == TOUCH_EVENT_BEGAN then
            	sender:setScale(0.9)
            end

            --触摸取消
            if event == TOUCH_EVENT_CANCELED then
            	sender:setScale(1.0)
            end

            --触摸结束（检查当前组局状态）
            if event == TOUCH_EVENT_ENDED then
            	sender:setScale(1.0)

            	-- require("hall.gameSettings"):exitRoom()
                dump(USER_INFO["activity_id"], "-----退出房间按钮，当前activityid-----")

                cct.createHttRq({
                    url = HttpAddr .. "/freeGame/queryGroupGameStatus",
                    date = {
                        activityId = USER_INFO["activity_id"],
                        interfaceType = "j"
                    },
                    type_= "POST",
                    callBack = function(data)
                        dump(data, "检查当前组局状态")
                        local responseData = data.netData
                        responseData = json.decode(responseData)
                        local returnCode = responseData.returnCode
                        if returnCode == "0" then
                            local data = tonumber(responseData.data)
                            -- dump(data, "检查当前组局状态")
                            if data == 1 then
                                --开始组局
                                require("hall.GameTips"):showTips("提示", "", 2, "游戏已经开始，不能返回大厅")

                            elseif data == 0 then
                                --创建组局
                                -- if bm.Room and bm.Room.isStart and bm.Room.isStart == 1 then -- 开始游戏
                                dump(bm.Room, "exit", nesting)
                                if bm.Room and bm.Room.start_group == 1 then
                                    require("hall.GameTips"):showTips("提示", "", 2, "游戏已经开始，不能返回大厅")
                                else
                                    local function okCallback()
                                        if bm.notCheckReload and bm.notCheckReload ~= 1 then
                                            bm.notCheckReload = 1
                                            sendHandle:CLI_QUIT_ROOM()
                                        else
                                        end
                                    end
                                    require("hall.GameTips"):showTips("提示", "tohall", 1, "你正在房间中，是否返回大厅？", nil, nil, okCallback)
                                end
                                
                            elseif data == 2 then
                                --结束组局
                                require("hall.GameTips"):showTips("提示", "tohall", 1, "当前组局已结束，是否返回大厅？")
                                bm.notCheckReload = 0
                            end
                        else
                            require("hall.GameTips"):showTips("提示", "", 2, "游戏数据异常，不能退出房间")
                        end

                    end
                })

            end
        end
    )

    --邀请微信好友
    local share_bt = self._scene:getChildByName(CHILD_NAME_SHARE_BT)
    share_bt:setVisible(true)
    share_bt:addTouchEventListener(
        function(sender,event)
            --触摸开始
            if event == TOUCH_EVENT_BEGAN then
            	sender:setScale(0.9)
            end

            --触摸取消
            if event == TOUCH_EVENT_CANCELED then
            	sender:setScale(1.0)
            end

            --触摸结束
            if event == TOUCH_EVENT_ENDED then
            	sender:setScale(1.0)

            	require("hall.common.ShareLayer"):showShareLayer("卡五星，房号：" .. USER_INFO["invote_code"], "https://a.mlinks.cc/AK3b", "url", USER_INFO["gameConfig"])
            end
        end
    )

    local record_bt = self._scene:getChildByName(CHILD_NAME_RECORD_BT)
    record_bt:setVisible(false)
    record_bt:addTouchEventListener(
    	function(sender,event)
            --触摸开始
            if event == TOUCH_EVENT_BEGAN then
            	sender:setScale(0.9)
            end

            --触摸取消
            if event == TOUCH_EVENT_CANCELED then
            	sender:setScale(1.0)
            end

            --触摸结束
            if event == TOUCH_EVENT_ENDED then
            	sender:setScale(1.0)

            	if device.platform ~= "windows" then
            		--todo
            		require("hall.recordUtils.RecordUtils"):showRecordFrame(cc.p(480, 270), cc.size(264, 218), USER_INFO["activity_id"])
            	end
            end
        end
    	)

    local chat_bt = self._scene:getChildByName(CHILD_NAME_CHAT_BT)
    chat_bt:setVisible(false)
    local function onface_click(sender)
        local pos=sender:getPosition()
        -- if sender.id ==1 then
        --     ddz_face_node:showFacePanle(pos)
        -- else
            kwx_face_node:showTxtPanle(pos, 8)
        -- end

        print("click faceui")
        
    end
    chat_bt:onClick(onface_click)

end

function KWXScene:onEnter()

	local room_lb = self._scene:getChildByName(CHILD_NAME_ROOM_LB)
	room_lb:setString("房间号\n" .. USER_INFO["invote_code"])

	dump(tableIdReload, "tableIdReload test")
    
    sendHandle:LoginGame(USER_INFO["GroupLevel"])

	if tableIdReload == 0 then --非重登
        -- if require("hall.gameSettings"):getGameMode() == "group" then
        --             --todo
        --             dump(tableIdReload, "tableIdReload test group")
            
        -- else
        --     display_scene("majiang/gameScenes")
        -- end

    else
        -- local pack_data = {}
        -- pack_data.tid = tableIdReload

        -- receiveHandle:SVR_GET_ROOM_OK(pack_data)
        tableIdReload = 0
    end

    -- require("kawuxing.RoundEndingLayer"):show(self:testEnding())
    -- require("kawuxing.operator.GamePlaneOperator"):beginPlayCard(CARD_PLAYERTYPE_MY)
    -- self:showLeaderLayer()
end

function KWXScene:get_player_ip( uid )
    -- body
    local ip_ = ""
    
    local seatId = KWX_SEAT_TABLE[uid .. ""]

    if seatId then
        --todo

        if KWX_USERINFO_TABLE[seatId .. ""] and KWX_USERINFO_TABLE[seatId .. ""].ip then
            --todo
            ip_ = KWX_USERINFO_TABLE[seatId .. ""].ip
        end
    end

    return ip_
end

function KWXScene:showLeaderLayer()
    local record_bt = self._scene:getChildByName(CHILD_NAME_RECORD_BT)
    require("hall.leader.LeaderLayer"):showLeaderLayer(record_bt:getPosition())
end

function KWXScene:ShowChatButton()
    local chat_bt = self._scene:getChildByName(CHILD_NAME_CHAT_BT)
    chat_bt:setVisible(true)
end

function KWXScene:ShowRecordButton()
	local record_bt = self._scene:getChildByName(CHILD_NAME_RECORD_BT)
    record_bt:setVisible(true)

    local voice_temp_bt = self._scene:getChildByName(CHILD_NAME_VOICE_TEMP_BT)
    require("hall.VoiceRecord.VoiceRecordView"):showView(voice_temp_bt:getPosition().x, voice_temp_bt:getPosition().y, -1)

    self:showLeaderLayer()
end

--获取用户播放录音位置
function KWXScene:getPosforSeat(uid)
    return KWX_ROOM.positionTable[uid .. ""]
end

--显示设置按钮
function KWXScene:ShowSettingButton()
	local setting_bt = self._scene:getChildByName(CHILD_NAME_SETTING_BT)

	setting_bt:setVisible(true)
end

function KWXScene:hideCloseRoomButton()
	local close_room_bt = self._scene:getChildByName(CHILD_NAME_CLOSE_ROOM_BT)

	close_room_bt:setVisible(false)
end

function KWXScene:hideShareButton()
	local share_bt = self._scene:getChildByName(CHILD_NAME_SHARE_BT)
	share_bt:setVisible(false)
end

--解散房间
function KWXScene:disbandGroup()

	--查询用户当前的游戏状态来判断当前通过怎样的方式来解散组局
    require("hall.gameSettings"):disbandGroup("kwx")

end

function KWXScene:test()
	local cards = {}
	for i=1,13 do

		local card = {}
		card["value"] = i
		table.insert(cards, card)
	end
	playerPlaneOperator:showCards(CARD_PLAYERTYPE_MY, self.myPlane, cards)
	playerPlaneOperator:showCards(CARD_PLAYERTYPE_LEFT, self.leftPlane, cards)
	playerPlaneOperator:showCards(CARD_PLAYERTYPE_RIGHT, self.rightPlane, cards)
	playerPlaneOperator:showCards(CARD_PLAYERTYPE_TOP, self.topPlane, cards)

	local controlType = bit.bor(CONTROL_TYPE_HU, CONTROL_TYPE_GANG)
	dump(CONTROL_TYPE_HU, "controlType test")
	dump(controlType, "controlType test")
	controlType = bit.bor(controlType, CONTROL_TYPE_PENG)
	dump(controlType, "controlType test")
	controlType = bit.bor(controlType, CONTROL_TYPE_CHI)
	dump(controlType, "controlType test")
	playerPlaneOperator:showControlPlane(self.myPlane, controlType)
end

function KWXScene:testEnding()

	KWX_USERINFO_TABLE[0] = {}
	KWX_USERINFO_TABLE[0].uid = 723
	KWX_USERINFO_TABLE[0].nick = "zh"

	KWX_USERINFO_TABLE[1] = KWX_USERINFO_TABLE[0]
	KWX_USERINFO_TABLE[2] = KWX_USERINFO_TABLE[0]
	KWX_USERINFO_TABLE[3] = KWX_USERINFO_TABLE[0]


	local testData = {}
	testData.type = 2
	testData.spendTime = 50
	testData.time = 123214214
	testData.uid = 723

	testData.players = {}

	local player = {}
	player.uid = 723
	player.isOnline = 1
	player.coins = 3000
	player.changeCoins = 3
	player.remainCardsCount = 2
	player.remainCards = {2,2}
	player.agCount = 0
	player.gCount = 0
	player.pCount = 0
	player.cCount = 0
	player.huTypeCount = 0

	table.insert(testData.players, player)
	table.insert(testData.players, player)
	table.insert(testData.players, player)
	table.insert(testData.players, player)

	testData.birdCount = 0
	testData.huCard = 1
	testData.isOver = 1

	return testData
end

--聊天
function KWXScene:SVR_MSG_FACE(uid, type, sex, node_head, isLeft)
    local s = self:getChildByName("faceUI")
    -- local sexT = sex
    -- if pack["uid"] == tonumber(UID) then
        -- sex = USER_INFO["sex"]
        -- if sexT == 0 then--保密
        --     sexT = 0
        -- else
        --     sexT = sexT -1
        -- end
    -- else
    --     local temp,seat = require("ddz.ddzSettings"):getDOS(USERID2SEAT[pack["uid"]])

    --     if seat==1 then
    --         sex = seat1sex
    --     elseif seat==2 then
    --         sex = seat2sex
    --     end
    -- end
    
    if tonumber(sex) >= 0 then
        s:showGetFace(uid, type, tonumber(sex), node_head, isLeft)
    end
end

return KWXScene