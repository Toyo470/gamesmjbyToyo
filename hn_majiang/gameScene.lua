require("hn_majiang.globle.HNMJData")
require("hn_majiang.globle.HNMJDefine")

local gamePlaneOperator = require("hn_majiang.operator.GamePlaneOperator")
-- local manyouPlaneOperator = require("hn_majiang.operator.ManyouPlaneOperator")

local PROTOCOL = import("hn_majiang.handle.HNMJProtocol")
local sendHandle = require("hn_majiang.handle.HNMJSendHandle")
local receiveHandle = require("hn_majiang.handle.HNMJReceiveHandle")

local HNMJ_face=require("hall.FaceUI.faceUI")

-- local CHILD_NAME_MANYOU_PLANE = "manyou_plane"

local CHILD_NAME_SETTING_BT = "setting_bt"
local CHILD_NAME_CLOSE_ROOM_BT = "close_room_bt"
local CHILD_NAME_EXIT_BT = "exit_bt"
local CHILD_NAME_SHARE_BT = "share_bt"
local CHILD_NAME_RECORD_BT = "record_bt"
local CHILD_NAME_CHAT_BT = "chat_bt"
local CHILD_NAME_VOICE_TEMP_BT = "voice_temp_bt"

local HNMJScene = class("HNMJScene", function()
		return display:newScene()
	end)

local CHILD_NAME_ROOM_LB = "room_lb"

function HNMJScene:ctor()
	bm.server:setProtocol(PROTOCOL)
    bm.server:setHandle(receiveHandle.new())

	self._scene = cc.CSLoader:createNode("hn_majiang/GameScene.csb"):addTo(self)
	HNMJ_GAME_PLANE = self._scene:getChildByName("game_plane")

    local HNMJ_face_node = HNMJ_face.new();
    HNMJ_face_node:setHandle(sendHandle)
    self:addChild(HNMJ_face_node, 9999)
    HNMJ_face_node:setName("faceUI")

    dump(HNMJ_GAME_PLANE, "hn_majiang test")

	HNMJ_CONTROLLER = require("hn_majiang.GameController")

	gamePlaneOperator:init()

	-- HNMJ_MANYOU_PLANE = self._scene:getChildByName(CHILD_NAME_MANYOU_PLANE)
	-- manyouPlaneOperator:init()

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
	-- if group_owner ~= USER_INFO["uid"] then
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
            	sender:setScale(0.5)
            end

            --触摸取消
            if event == TOUCH_EVENT_CANCELED then
            	sender:setScale(0.7)
            end

            --触摸结束（检查当前组局状态）
            if event == TOUCH_EVENT_ENDED then
            	sender:setScale(0.7)

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
		                		--创建组局
		                		require("hall.GameTips"):showTips("提示", "tohall", 1, "你正在房间中，是否返回大厅？")

		                	elseif data == 2 then
		                		--开始组局
		                		require("hall.GameTips"):showTips("提示", "", 2, "游戏已经开始，不能返回大厅")
		                		
		                	elseif data == 0 then
		                		--结束组局
		                		require("hall.GameTips"):showTips("提示", "tohall", 1, "当前组局已结束，是否返回大厅？")

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

            	require("hall.common.ShareLayer"):showShareLayer("海南麻将，房号：" .. USER_INFO["invote_code"], "https://a.mlinks.cc/AK3b", "url", USER_INFO["gameConfig"])
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
            HNMJ_face_node:showTxtPanle(pos, 8)
        -- end

        --print("click faceui")
        
    end
    chat_bt:onClick(onface_click)

end

function HNMJScene:onEnter()

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

    -- require("hn_majiang.RoundEndingLayer"):show(self:testEnding())
    -- require("hn_majiang.operator.GamePlaneOperator"):beginPlayCard(CARD_PLAYERTYPE_MY)
    -- self:showLeaderLayer()
end

function HNMJScene:get_player_ip( uid )
    -- body
    local ip_ = ""
    
    local seatId = HNMJ_SEAT_TABLE[uid .. ""]

    if seatId then
        --todo

        if HNMJ_USERINFO_TABLE[seatId .. ""] and HNMJ_USERINFO_TABLE[seatId .. ""].ip then
            --todo
            ip_ = HNMJ_USERINFO_TABLE[seatId .. ""].ip
        end
    end

    return ip_
end

function HNMJScene:showLeaderLayer()
    local record_bt = self._scene:getChildByName(CHILD_NAME_RECORD_BT)
    require("hall.leader.LeaderLayer"):showLeaderLayer(record_bt:getPosition())
end

function HNMJScene:ShowChatButton()
    local chat_bt = self._scene:getChildByName(CHILD_NAME_CHAT_BT)
    chat_bt:setVisible(true)
end

function HNMJScene:ShowRecordButton()
	local record_bt = self._scene:getChildByName(CHILD_NAME_RECORD_BT)
    record_bt:setVisible(true)

    local voice_temp_bt = self._scene:getChildByName(CHILD_NAME_VOICE_TEMP_BT)
    require("hall.VoiceRecord.VoiceRecordView"):showView(voice_temp_bt:getPosition().x, voice_temp_bt:getPosition().y, -1)

    self:showLeaderLayer()
end

--获取用户播放录音位置
function HNMJScene:getPosforSeat(uid)
    return HNMJ_ROOM.positionTable[uid .. ""]
end

--显示设置按钮
function HNMJScene:ShowSettingButton()
	local setting_bt = self._scene:getChildByName(CHILD_NAME_SETTING_BT)

	setting_bt:setVisible(true)
end

function HNMJScene:hideCloseRoomButton()
	local close_room_bt = self._scene:getChildByName(CHILD_NAME_CLOSE_ROOM_BT)

	close_room_bt:setVisible(false)
end

function HNMJScene:hideShareButton()
	local share_bt = self._scene:getChildByName(CHILD_NAME_SHARE_BT)
	share_bt:setVisible(false)
end

--解散房间
function HNMJScene:disbandGroup()

	--查询用户当前的游戏状态来判断当前通过怎样的方式来解散组局
	cct.createHttRq({
        url = HttpAddr .. "/freeGame/queryGroupGameStatus",
        date = {
        	activityId = USER_INFO["activity_id"],
        	interfaceType = "j"
        },
        type_= "POST",
        callBack = function(data)
            local responseData = data.netData
            responseData = json.decode(responseData)
            local returnCode = responseData.returnCode
            if returnCode == "0" then
            	local data = tonumber(responseData.data)
            	dump(data, "检查当前组局状态")
            	if data == 1 then
            		--创建组局
					require("hall.GameTips"):showDisbandTips("解散房间", "HNMJ_disbandGroup", 1, "当前解散房间不需扣除房卡，是否解散？")

            	elseif data == 2 then
            		--开始组局
            		require("hall.GameTips"):showDisbandTips("解散房间", "HNMJ_disbandGroup", 1, "当前已经扣除房卡，是否申请解散房间？")
            		
            	elseif data == 0 then
            		--结束组局
            		require("hall.GameTips"):showTips("提示", "tohall", 1, "当前组局已结束，是否返回大厅？")

            	end
            else
            		
            end

 		end
	})

end

function HNMJScene:test()
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

function HNMJScene:testEnding()

	HNMJ_USERINFO_TABLE[0] = {}
	HNMJ_USERINFO_TABLE[0].uid = 723
	HNMJ_USERINFO_TABLE[0].nick = "zh"

	HNMJ_USERINFO_TABLE[1] = HNMJ_USERINFO_TABLE[0]
	HNMJ_USERINFO_TABLE[2] = HNMJ_USERINFO_TABLE[0]
	HNMJ_USERINFO_TABLE[3] = HNMJ_USERINFO_TABLE[0]


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
function HNMJScene:SVR_MSG_FACE(uid, type, sex, node_head, isLeft)
    local s = self:getChildByName("faceUI")
    -- local sexT = sex
    -- if pack["uid"] == USER_INFO["uid"] then
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

function HNMJScene:show_ready_bar(player_index, show_flag)
    --print("show_ready_bar", tostring(player_index), tostring(show_flag))
    if show_flag then
        local spReady = cc.Sprite:create("hn_majiang/image/mahjong_ready.png")
        if spReady then
            spReady:addTo(self, 2)
            local pos = nil
            if player_index == 0 then
                pos = cc.p(480, 150)
            elseif player_index == 1 then
                pos = cc.p(280, 270)
            elseif player_index == 2 then
                pos = cc.p(480, 390)
            elseif player_index == 3 then
                pos = cc.p(680, 270)
            end
            spReady:setPosition(pos)
            spReady:setName("user_ready_"..tostring(player_index))
        end
    else
        local spReady = self:getChildByName("user_ready_"..tostring(player_index))
        if spReady then
            spReady:removeSelf()
        end
    end
end

return HNMJScene