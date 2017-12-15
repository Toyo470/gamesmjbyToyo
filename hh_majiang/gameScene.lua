require("zz_majiang.globle.ZZMJData")
require("zz_majiang.globle.ZZMJDefine")

local gamePlaneOperator = require("zz_majiang.operator.GamePlaneOperator")
-- local manyouPlaneOperator = require("zz_majiang.operator.ManyouPlaneOperator")

local PROTOCOL = import("zz_majiang.handle.ZZMJProtocol")
local sendHandle = require("zz_majiang.handle.ZZMJSendHandle")
local receiveHandle = require("zz_majiang.handle.ZZMJReceiveHandle")

local ZZMJ_face=require("hall.FaceUI.faceUI")

-- local CHILD_NAME_MANYOU_PLANE = "manyou_plane"

local CHILD_NAME_MENU_PLANE = "menu_plane"
local CHILD_NAME_MENU_BT = "menu_bt"
local CHILD_NAME_BT = ""
local CHILD_NAME_DISBAND_BT = "disband_bt"
local CHILD_NAME_SETTING_BT = "setting_bt"
local CHILD_NAME_CLOSE_ROOM_BT = "close_room_bt"
local CHILD_NAME_EXIT_BT = "exit_bt"
local CHILD_NAME_SHARE_BT = "share_bt"
local CHILD_NAME_RECORD_BT = "record_bt"
local CHILD_NAME_CHAT_BT = "chat_bt"
local CHILD_NAME_VOICE_BT = "voice_temp_bt"

local ZZMJScene = class("ZZMJScene", function()
		return display:newScene()
	end)

local CHILD_NAME_ROOM_LB = "room_lb"

function ZZMJScene:ctor()
    showDumpData=false
	bm.server:setProtocol(PROTOCOL)
    bm.server:setHandle(receiveHandle.new())

	self._scene = cc.CSLoader:createNode("zz_majiang/GameScene.csb"):addTo(self)
	ZZMJ_GAME_PLANE = self._scene:getChildByName("game_plane")

    local ZZMJ_face_node = ZZMJ_face.new();
    ZZMJ_face_node:setHandle(sendHandle)
    self:addChild(ZZMJ_face_node, 9999)
    ZZMJ_face_node:setName("faceUI")

    dump(ZZMJ_GAME_PLANE, "zz_majiang test")

	ZZMJ_CONTROLLER = require("zz_majiang.GameController")

	gamePlaneOperator:init()

	-- ZZMJ_MANYOU_PLANE = self._scene:getChildByName(CHILD_NAME_MANYOU_PLANE)
	-- manyouPlaneOperator:init()   
    local close_room_bt = self._scene:getChildByName(CHILD_NAME_CLOSE_ROOM_BT)
    local menu_plane = self._scene:getChildByName(CHILD_NAME_MENU_PLANE) 
    local menu_bt = self._scene:getChildByName(CHILD_NAME_MENU_BT) 
	local setting_bt = menu_plane:getChildByName(CHILD_NAME_SETTING_BT)
    
    menu_plane:setVisible(false)
    menu_bt:addTouchEventListener(
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
                
                if menu_plane:isVisible() then
                 menu_plane:setVisible(false)
                else 
                menu_plane:setVisible(true)
                end
            end
        end
    )

    disband_bt = menu_plane:getChildByName(CHILD_NAME_DISBAND_BT)
    disband_bt:addTouchEventListener(
        function(sender,event)
            --触摸开始
            if event == TOUCH_EVENT_BEGAN then
                sender:setScale(0.8)
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

	-- setting_bt:setVisible(false)
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

	-- local group_owner = tonumber(USER_INFO["group_owner"])
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
	local exit_bt = menu_plane:getChildByName(CHILD_NAME_EXIT_BT)
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

            	require("hall.common.ShareLayer"):showShareLayer("哈哈麻将，房号：" .. USER_INFO["invote_code"], "https://a.mlinks.cc/AK3b", "url", USER_INFO["gameConfig"])
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

    local chat_bt = menu_plane:getChildByName(CHILD_NAME_CHAT_BT)
    chat_bt:setVisible(false)
    local function onface_click(sender)
        local pos=sender:getPosition()
        -- if sender.id ==1 then
        --     ddz_face_node:showFacePanle(pos)
        -- else
            ZZMJ_face_node:showTxtPanle(pos, 8)
        -- end

        --print("click faceui")
        
    end
    chat_bt:onClick(onface_click)

end

function ZZMJScene:onEnter()

	local room_lb = self._scene:getChildByName(CHILD_NAME_ROOM_LB)
	room_lb:setString(USER_INFO["invote_code"])

	-- dump(tableIdReload, "tableIdReload test")
    
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

    -- require("zz_majiang.RoundEndingLayer"):show(self:testEnding())
    -- require("zz_majiang.operator.GamePlaneOperator"):beginPlayCard(CARD_PLAYERTYPE_MY)
    -- self:showLeaderLayer()
end

function ZZMJScene:get_player_ip( uid )
    -- body
    local ip_ = ""
    
    local seatId = ZZMJ_SEAT_TABLE[uid .. ""]

    if seatId then
        --todo

        if ZZMJ_USERINFO_TABLE[seatId .. ""] and ZZMJ_USERINFO_TABLE[seatId .. ""].ip then
            --todo
            ip_ = ZZMJ_USERINFO_TABLE[seatId .. ""].ip
        end
    end

    return ip_
end

function ZZMJScene:showLeaderLayer()
    local record_bt = self._scene:getChildByName(CHILD_NAME_RECORD_BT)
    require("hall.leader.LeaderLayer"):showLeaderLayer(record_bt:getPosition())
end

function ZZMJScene:ShowChatButton()
    local menu_plane = self._scene:getChildByName(CHILD_NAME_MENU_PLANE)
    local chat_bt = menu_plane:getChildByName(CHILD_NAME_CHAT_BT)
    chat_bt:setVisible(true)
end

function ZZMJScene:ShowRecordButton()
	local record_bt = self._scene:getChildByName(CHILD_NAME_RECORD_BT)
    record_bt:setVisible(true)

    local voice_temp_bt = self._scene:getChildByName(CHILD_NAME_VOICE_BT)
    require("hall.VoiceRecord.VoiceRecordView"):showView(voice_temp_bt:getPosition().x, voice_temp_bt:getPosition().y, -1)

    self:showLeaderLayer()
end

--获取用户播放录音位置
function ZZMJScene:getPosforSeat(uid)
    return ZZMJ_ROOM.positionTable[uid .. ""]
end

--显示设置按钮（弃用）
function ZZMJScene:ShowSettingButton()
	-- local setting_bt = self._scene:getChildByName(CHILD_NAME_SETTING_BT)

	-- setting_bt:setVisible(true)
end


-------------------------游戏未开始前的解散房间和分享按钮------------------------
function ZZMJScene:hideCloseRoomButton()
	local close_room_bt = self._scene:getChildByName(CHILD_NAME_CLOSE_ROOM_BT)
	close_room_bt:setVisible(false)
end

function ZZMJScene:hideShareButton()
	local share_bt = self._scene:getChildByName(CHILD_NAME_SHARE_BT)
	share_bt:setVisible(false)
end
----------------------------------------------------------------------------------
--解散房间
function ZZMJScene:disbandGroup()

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
					require("hall.GameTips"):showDisbandTips("解散房间", "ZZMJ_disbandGroup", 1, "当前解散房间不需扣除房卡，是否解散？")

            	elseif data == 2 then
            		--开始组局
            		require("hall.GameTips"):showDisbandTips("解散房间", "ZZMJ_disbandGroup", 1, "当前已经扣除房卡，是否申请解散房间？")
            		
            	elseif data == 0 then
            		--结束组局
            		require("hall.GameTips"):showTips("提示", "tohall", 1, "当前组局已结束，是否返回大厅？")

            	end
            else
            		
            end

 		end
	})

end

--聊天
function ZZMJScene:SVR_MSG_FACE(uid, type, sex, node_head, isLeft)
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




-- function ZZMJScene:test()
-- 	local cards = {}
-- 	for i=1,13 do

-- 		local card = {}
-- 		card["value"] = i
-- 		table.insert(cards, card)
-- 	end
-- 	playerPlaneOperator:showCards(CARD_PLAYERTYPE_MY, self.myPlane, cards)
-- 	playerPlaneOperator:showCards(CARD_PLAYERTYPE_LEFT, self.leftPlane, cards)
-- 	playerPlaneOperator:showCards(CARD_PLAYERTYPE_RIGHT, self.rightPlane, cards)
-- 	playerPlaneOperator:showCards(CARD_PLAYERTYPE_TOP, self.topPlane, cards)

-- 	local controlType = bit.bor(CONTROL_TYPE_HU, CONTROL_TYPE_GANG)
-- 	dump(CONTROL_TYPE_HU, "controlType test")
-- 	dump(controlType, "controlType test")
-- 	controlType = bit.bor(controlType, CONTROL_TYPE_PENG)
-- 	dump(controlType, "controlType test")
-- 	controlType = bit.bor(controlType, CONTROL_TYPE_CHI)
-- 	dump(controlType, "controlType test")
-- 	playerPlaneOperator:showControlPlane(self.myPlane, controlType)
-- end

-- function ZZMJScene:testEnding()

-- 	ZZMJ_USERINFO_TABLE[0] = {}
-- 	ZZMJ_USERINFO_TABLE[0].uid = 723
-- 	ZZMJ_USERINFO_TABLE[0].nick = "zh"

-- 	ZZMJ_USERINFO_TABLE[1] = ZZMJ_USERINFO_TABLE[0]
-- 	ZZMJ_USERINFO_TABLE[2] = ZZMJ_USERINFO_TABLE[0]
-- 	ZZMJ_USERINFO_TABLE[3] = ZZMJ_USERINFO_TABLE[0]


-- 	local testData = {}
-- 	testData.type = 2
-- 	testData.spendTime = 50
-- 	testData.time = 123214214
-- 	testData.uid = 723

-- 	testData.players = {}

-- 	local player = {}
-- 	player.uid = 723
-- 	player.isOnline = 1
-- 	player.coins = 3000
-- 	player.changeCoins = 3
-- 	player.remainCardsCount = 2
-- 	player.remainCards = {2,2}
-- 	player.agCount = 0
-- 	player.gCount = 0
-- 	player.pCount = 0
-- 	player.cCount = 0
-- 	player.huTypeCount = 0

-- 	table.insert(testData.players, player)
-- 	table.insert(testData.players, player)
-- 	table.insert(testData.players, player)
-- 	table.insert(testData.players, player)

-- 	testData.birdCount = 0
-- 	testData.huCard = 1
-- 	testData.isOver = 1

-- 	return testData
-- end



-- function ZZMJScene:show_ready_bar(player_index, show_flag)
--     --print("show_ready_bar", tostring(player_index), tostring(show_flag))
--     if show_flag then
--         local spReady = cc.Sprite:create("zz_majiang/image/mahjong_ready.png")
--         if spReady then
--             spReady:addTo(self, 2)
--             local pos = nil
--             if player_index == 0 then
--                 pos = cc.p(480, 150)
--             elseif player_index == 1 then
--                 pos = cc.p(280, 270)
--             elseif player_index == 2 then
--                 pos = cc.p(480, 390)
--             elseif player_index == 3 then
--                 pos = cc.p(680, 270)
--             end
--             spReady:setPosition(pos)
--             spReady:setName("user_ready_"..tostring(player_index))
--         end
--     else
--         local spReady = self:getChildByName("user_ready_"..tostring(player_index))
--         if spReady then
--             spReady:removeSelf()
--         end
--     end


-- end

return ZZMJScene