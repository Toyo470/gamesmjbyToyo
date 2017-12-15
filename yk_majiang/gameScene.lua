require("yk_majiang.globle.YKMJData")
require("yk_majiang.globle.YKMJDefine")

-- local PING_TOOL = require("hall.GetPingValue")

local gamePlaneOperator = require("yk_majiang.operator.GamePlaneOperator")
-- local manyouPlaneOperator = require("yk_majiang.operator.ManyouPlaneOperator")


showdumpData=false

local PROTOCOL = import("yk_majiang.handle.YKMJProtocol")
local sendHandle = require("yk_majiang.handle.YKMJSendHandle")
local receiveHandle = require("yk_majiang.handle.YKMJReceiveHandle")

local YKMJ_face=require("hall.FaceUI.faceUI")

-- local CHILD_NAME_MANYOU_PLANE = "manyou_plane"
local CHILD_NAME_SETTING_BT = "setting_bt"
local CHILD_NAME_CLOSE_ROOM_BT = "close_room_bt"
local CHILD_NAME_EXIT_BT = "exit_bt"
local CHILD_NAME_SHARE_BT = "share_bt"
local CHILD_NAME_RECORD_BT = "record_bt"
local CHILD_NAME_CHAT_BT = "chat_bt"
local CHILD_NAME_VOICE_TEMP_BT = "voice_temp_bt"

local YKMJScene = class("YKMJScene", function()
		return display:newScene()
	end)

local CHILD_NAME_ROOM_LB = "room_lb"

function YKMJScene:ctor()
	bm.server:setProtocol(PROTOCOL)
    bm.server:setHandle(receiveHandle.new())
    
	self._scene = cc.CSLoader:createNode("yk_majiang/GameScene.csb"):addTo(self)
	YKMJ_GAME_PLANE = self._scene:getChildByName("game_plane")

    local version = YKMJ_GAME_PLANE:getChildByName("version")
    -- local versionStr=require("hall.GameData"):getGameVersion("yk_majiang")
    version:setString("1.1.4")

	--******************** ping value beg ******************** @Jhao
	local function updatePingValue(_string)
		local str = "1.1.4" .. "(".. _string ..")"
        if bm.isInGame == true then
        	version:setString(str)
        	version:setPositionX(YKMJ_GAME_PLANE:getWidth() - version:getWidth()/2)
		else
			-- PING_TOOL:setUpdateCallBackFunc(nil)
        end
	end

	-- if PING_TOOL ~= nil then
	-- 	PING_TOOL:setUpdateCallBackFunc(updatePingValue)
	-- end
	--******************** ping value end ********************

          version:addTouchEventListener(
        function(sender,event)

         --触摸结束
            if event == TOUCH_EVENT_ENDED then
                if  GOPERATESTYLE==1 then
                    -- cc.UserDefault:getInstance():setIntegerForKey("OperateStyle", 2)
                    GOPERATESTYLE = 2          
                else 
                    -- cc.UserDefault:getInstance():setIntegerForKey("OperateStyle", 1)
                    GOPERATESTYLE = 1
                end
                -- cc.UserDefault:getInstance():flush()
                require("hall.GameTips"):showTips("提示", "", 3, "成功切换出牌方式！" .. "\n".."出牌后生效")
                -- receiveHandle:refreshcards()
            end
        end
    )

    local YKMJ_face_node = YKMJ_face.new();
    YKMJ_face_node:setHandle(sendHandle)
    self:addChild(YKMJ_face_node, 9999)
    YKMJ_face_node:setName("faceUI")

    --dump(YKMJ_GAME_PLANE, "yk_majiang test")

	YKMJ_CONTROLLER = require("yk_majiang.GameController")

	gamePlaneOperator:init()

	-- YKMJ_MANYOU_PLANE = self._scene:getChildByName(CHILD_NAME_MANYOU_PLANE)
	-- manyouPlaneOperator:init()

	local setting_bt = self._scene:getChildByName(CHILD_NAME_SETTING_BT)
	local close_room_bt = self._scene:getChildByName(CHILD_NAME_CLOSE_ROOM_BT)

	setting_bt:setVisible(true)
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

            	--dump(USER_INFO["activity_id"], "-----退出房间按钮，当前activityid-----")

            	cct.createHttRq({
		            url = HttpAddr .. "/freeGame/queryGroupGameStatus",
		            date = {
		            	activityId = USER_INFO["activity_id"],
		            	interfaceType = "j"
		            },
		            type_= "POST",
		            callBack = function(data)
		            	--dump(data, "检查当前组局状态")
		                local responseData = data.netData
		                responseData = json.decode(responseData)
		                local returnCode = responseData.returnCode
		                if returnCode == "0" then
		                	local data = tonumber(responseData.data)
		                	-- --dump(data, "检查当前组局状态")
		                	if data == 1 then
		                		--创建组局
		                		require("hall.GameTips"):showTips("提示", "tohall", 1, "你正在房间中，是否返回大厅？")

		                	elseif data == 2 then    --2017/3/7日改动:开始游戏后返回大厅按钮变成解散按钮
		                		--开始组局
		                		-- require("hall.GameTips"):showTips("提示", "", 2, "游戏已经开始，不能返回大厅")
                                require("hall.GameTips"):showDisbandTips("解散房间", "YKMJ_disbandGroup", 1, "当前已经扣除房卡，是否申请解散房间？")
		                		
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
                
                if PLAYERNUM == 4 or not PLAYERNUM then
            	    require("hall.common.ShareLayer"):showShareLayer("四人营口麻将，房号：" .. USER_INFO["invote_code"], "https://a.mlinks.cc/AK3b", "url", USER_INFO["gameConfig"])
                elseif PLAYERNUM == 2 then
                    require("hall.common.ShareLayer"):showShareLayer("二人营口麻将，房号：" .. USER_INFO["invote_code"], "https://a.mlinks.cc/AK3b", "url", USER_INFO["gameConfig"])
                end
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
            YKMJ_face_node:showTxtPanle(pos, 8)
        -- end

        --print("click faceui")
        
    end
    chat_bt:onClick(onface_click)

    -- local eventDispatcher = SCENENOW["scene"]:getEventDispatcher()
    -- local function showNetworkImg () end
    -- cc.eventManager.addCustomListener(cc.game.EVENT_SHOW,showNetworkImg)
    -- cc.eventManager.addCustomListener(cc.game.EVENT_HIDE,showNetworkImg)


    -- local listenerCustom=cc.EventListenerCustom:create(cc.game.EVENT_HIDE,function ()
    --     print("切换到前台")
    -- end)  
    -- local customEventDispatch=cc.Director:getInstance():getEventDispatcher()
    -- customEventDispatch:addEventListenerWithFixedPriority(listenerCustom, 1)
    
     -- isShowErrorScene= true
     -- local eventDispatcher = SCENENOW["scene"]:getEventDispatcher()
     -- eventDispatcher:addEventListener("APP_ENTER_BACKGROUND_EVENT", function(event)
     --     print("========= 前台")
     -- end)

     -- local listener1 = cc.EventListenerCustom:create(APP_ENTER_BACKGROUND_EVENT, function() sendHandle:CLI_LOGOUT_ROOM() end)
     -- self:getEventDispatcher():addEventListenerWithFixedPriority(listener1, 1)

    -- local  pauseTime = 0
    -- cc.eventManager.addCustomListener(cc.game.EVENT_HIDE, 
    -- pauseTime = ServerTimeUtils.getServerTime()
    
    -- --dump("重新回到游戏!")
    -- if(ServerTimeUtils.getServerTime() - pauseTime > 60*1000)(
    --     if  not cc.sys.isNative then
    --         location.reload()  
    --     else
    --         ReLogin()
    --     end
    -- )

end

function YKMJScene:onEnter()

	local room_lb = self._scene:getChildByName(CHILD_NAME_ROOM_LB)
	room_lb:setString(USER_INFO["invote_code"].."")

	--dump(tableIdReload, "tableIdReload test")
    
    sendHandle:LoginGame(USER_INFO["GroupLevel"])

	if tableIdReload == 0 then --非重登
        -- if require("hall.gameSettings"):getGameMode() == "group" then
        --             --todo
        --             --dump(tableIdReload, "tableIdReload test group")
            
        -- else
        --     display_scene("majiang/gameScenes")
        -- end

    else
        -- local pack_data = {}
        -- pack_data.tid = tableIdReload

        -- receiveHandle:SVR_GET_ROOM_OK(pack_data)
        tableIdReload = 0
    end

    -- require("yk_majiang.RoundEndingLayer"):show(self:testEnding())
    -- require("yk_majiang.operator.GamePlaneOperator"):beginPlayCard(CARD_PLAYERTYPE_MY)
    -- self:showLeaderLayer()
end

function YKMJScene:get_player_ip( uid )
    -- body
    local ip_ = ""
    
    local seatId = YKMJ_SEAT_TABLE[uid .. ""]

    if seatId then
        --todo

        if YKMJ_USERINFO_TABLE[seatId .. ""] and YKMJ_USERINFO_TABLE[seatId .. ""].ip then
            --todo
            ip_ = YKMJ_USERINFO_TABLE[seatId .. ""].ip
        end
    end

    return ip_
end

function YKMJScene:showLeaderLayer()
    local record_bt = self._scene:getChildByName(CHILD_NAME_RECORD_BT)
    require("hall.leader.LeaderLayer"):showLeaderLayer(record_bt:getPosition())
end

function YKMJScene:ShowChatButton()
    local chat_bt = self._scene:getChildByName(CHILD_NAME_CHAT_BT)
    chat_bt:setVisible(true)
end

function YKMJScene:ShowRecordButton()
	local record_bt = self._scene:getChildByName(CHILD_NAME_RECORD_BT)
    record_bt:setVisible(true)

    local voice_temp_bt = self._scene:getChildByName(CHILD_NAME_VOICE_TEMP_BT)
    require("hall.VoiceRecord.VoiceRecordView"):showView(voice_temp_bt:getPosition().x, voice_temp_bt:getPosition().y, -1)

    self:showLeaderLayer()
end

--获取用户播放录音位置
function YKMJScene:getPosforSeat(uid)
    return YKMJ_ROOM.positionTable[uid .. ""]
end

--显示设置按钮
function YKMJScene:ShowSettingButton()
	local setting_bt = self._scene:getChildByName(CHILD_NAME_SETTING_BT)

	setting_bt:setVisible(true)
end

function YKMJScene:hideCloseRoomButton()
	local close_room_bt = self._scene:getChildByName(CHILD_NAME_CLOSE_ROOM_BT)

	close_room_bt:setVisible(false)
end

function YKMJScene:hideShareButton()
	local share_bt = self._scene:getChildByName(CHILD_NAME_SHARE_BT)
	share_bt:setVisible(false)
end

--解散房间
function YKMJScene:disbandGroup()

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
            	--dump(data, "检查当前组局状态")
            	if data == 1 then
            		--创建组局
					require("hall.GameTips"):showDisbandTips("解散房间", "YKMJ_disbandGroup", 1, "当前解散房间不需扣除房卡，是否解散？")

            	elseif data == 2 then
            		--开始组局
            		require("hall.GameTips"):showDisbandTips("解散房间", "YKMJ_disbandGroup", 1, "当前已经扣除房卡，是否申请解散房间？")
            		
            	elseif data == 0 then
            		--结束组局
            		require("hall.GameTips"):showTips("提示", "tohall", 1, "当前组局已结束，是否返回大厅？")

            	end
            else
            		
            end

 		end
	})

end

function YKMJScene:test()
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
	--dump(CONTROL_TYPE_HU, "controlType test")
	--dump(controlType, "controlType test")
	controlType = bit.bor(controlType, CONTROL_TYPE_PENG)
	--dump(controlType, "controlType test")
	controlType = bit.bor(controlType, CONTROL_TYPE_CHI)
	--dump(controlType, "controlType test")
	playerPlaneOperator:showControlPlane(self.myPlane, controlType)
end

function YKMJScene:testEnding()

	YKMJ_USERINFO_TABLE[0] = {}
	YKMJ_USERINFO_TABLE[0].uid = 723
	YKMJ_USERINFO_TABLE[0].nick = "zh"

	YKMJ_USERINFO_TABLE[1] = YKMJ_USERINFO_TABLE[0]
	YKMJ_USERINFO_TABLE[2] = YKMJ_USERINFO_TABLE[0]
	YKMJ_USERINFO_TABLE[3] = YKMJ_USERINFO_TABLE[0]


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
function YKMJScene:SVR_MSG_FACE(uid, type, sex, node_head, isLeft)
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

return YKMJScene
