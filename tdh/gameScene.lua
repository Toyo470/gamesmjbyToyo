require("tdh.globle.TDHMJData")
require("tdh.globle.TDHMJDefine")

local gamePlaneOperator = require("tdh.operator.GamePlaneOperator")
local PROTOCOL = import("tdh.handle.TDHMJProtocol")
local sendHandle = require("tdh.handle.TDHMJSendHandle")
local receiveHandle = require("tdh.handle.TDHMJReceiveHandle")
local tdhmj_face=require("hall.FaceUI.faceUI")


showDumpData=false

local CHILD_NAME_SETTING_BT = "setting_bt"
local CHILD_NAME_CLOSE_ROOM_BT = "close_room_bt"
local CHILD_NAME_EXIT_BT = "exit_bt"
local CHILD_NAME_SHARE_BT = "share_bt"
local CHILD_NAME_RECORD_BT = "record_bt"
local CHILD_NAME_CHAT_BT = "chat_bt"
local CHILD_NAME_VOICE_TEMP_BT = "voice_temp_bt"
local CHILD_NAME_ROOM_LB = "room_lb"

local TDHMJScene = class("TDHMJScene", function()
		return display:newScene()
	end)

function TDHMJScene:ctor()
	bm.server:setProtocol(PROTOCOL)
    bm.server:setHandle(receiveHandle.new())

	self._scene = cc.CSLoader:createNode("tdh/tdhmjScene.csb"):addTo(self)
	TDHMJ_GAME_PLANE = self._scene:getChildByName("game_plane")

    local tdhmj_face_node = tdhmj_face.new()
    tdhmj_face_node:setHandle(sendHandle)
    self:addChild(tdhmj_face_node, 9999)
    tdhmj_face_node:setName("faceUI")

	TDHMJ_CONTROLLER = require("tdh.GameController")
    TDHMJ_ting = nil 
    TDHMJ_tingCards = nil

	gamePlaneOperator:init()

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

            	require("hall.common.ShareLayer"):showShareLayer("四人推倒胡，房号：" .. USER_INFO["invote_code"], "https://a.mlinks.cc/AK3b", "url", USER_INFO["gameConfig"])
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
            tdhmj_face_node:showTxtPanle(pos, 8)
        -- end

        --print("click faceui")
        
    end
    chat_bt:onClick(onface_click)

end

function TDHMJScene:onEnter()

	local room_lb = self._scene:getChildByName(CHILD_NAME_ROOM_LB)
	room_lb:setString("房间号\n" .. USER_INFO["invote_code"])

	dump(tableIdReload, "tableIdReload test")
    
    sendHandle:LoginGame(USER_INFO["GroupLevel"])

	if tableIdReload == 0 then --非重登
        if require("hall.gameSettings"):getGameMode() == "group" then
                    --todo
                    dump(tableIdReload, "tableIdReload test group")
            
        else
            display_scene("majiang/gameScenes")
        end

    else
        -- local pack_data = {}
        -- pack_data.tid = tableIdReload

        -- receiveHandle:SVR_GET_ROOM_OK(pack_data)
        tableIdReload = 0
    end

    -- require("tdh.RoundEndingLayer"):show(self:testEnding())
    -- require("tdh.operator.GamePlaneOperator"):beginPlayCard(CARD_PLAYERTYPE_MY)
    -- self:showLeaderLayer()


end


function TDHMJScene:showLeaderLayer()
    local record_bt = self._scene:getChildByName(CHILD_NAME_RECORD_BT)
    require("hall.leader.LeaderLayer"):showLeaderLayer(record_bt:getPosition())
end

--显示聊天按钮
function TDHMJScene:ShowChatButton()
    local chat_bt = self._scene:getChildByName(CHILD_NAME_CHAT_BT)
    chat_bt:setVisible(true)
end

--显示录音按钮
function TDHMJScene:ShowRecordButton()
	local record_bt = self._scene:getChildByName(CHILD_NAME_RECORD_BT)
    record_bt:setVisible(true)

    local voice_temp_bt = self._scene:getChildByName(CHILD_NAME_VOICE_TEMP_BT)
    require("hall.VoiceRecord.VoiceRecordView"):showView(voice_temp_bt:getPosition().x, voice_temp_bt:getPosition().y, -1)

    self:showLeaderLayer()
end

--获取用户播放录音位置
function TDHMJScene:getPosforSeat(uid)
    return TDHMJ_ROOM.positionTable[uid .. ""]
end

--显示设置按钮
function TDHMJScene:ShowSettingButton()
	local setting_bt = self._scene:getChildByName(CHILD_NAME_SETTING_BT)

	setting_bt:setVisible(true)
end
--隐藏解散房间
function TDHMJScene:hideCloseRoomButton()
	local close_room_bt = self._scene:getChildByName(CHILD_NAME_CLOSE_ROOM_BT)

	close_room_bt:setVisible(false)
end
--隐藏邀请微信好友
function TDHMJScene:hideShareButton()
	local share_bt = self._scene:getChildByName(CHILD_NAME_SHARE_BT)
	share_bt:setVisible(false)
end

--隐藏录音按钮
function TDHMJScene:hideVoiceButton()
    local voice_temp_bt = self._scene:getChildByName(CHILD_NAME_VOICE_TEMP_BT)
    voice_temp_bt:setVisible(false)
end


--解散房间
function TDHMJScene:disbandGroup()
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
					require("hall.GameTips"):showDisbandTips("解散房间", "tdh_disbandGroup", 1, "当前解散房间不需扣除房卡，是否解散？")

            	elseif data == 2 then
            		--开始组局
            		require("hall.GameTips"):showDisbandTips("解散房间", "tdh_disbandGroup", 1, "当前已经扣除房卡，是否申请解散房间？")
            		
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
function TDHMJScene:SVR_MSG_FACE(uid, type, sex, node_head, isLeft)
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

--获取用户IP
function TDHMJScene:get_player_ip( uid )
    -- body
    local ip_ = ""
    
    local seatId = TDHMJ_SEAT_TABLE[uid .. ""]

    if seatId then
        --todo

        if TDHMJ_USERINFO_TABLE[seatId .. ""] and TDHMJ_USERINFO_TABLE[seatId .. ""].ip then
            --todo
            ip_ = TDHMJ_USERINFO_TABLE[seatId .. ""].ip
        end
    end

    return ip_
end


--测试出牌显示代码段

-- function TDHMJScene:test()
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
-- 	-- controlType = bit.bor(controlType, CONTROL_TYPE_CHI)
-- 	-- dump(controlType, "controlType test")
-- 	playerPlaneOperator:showControlPlane(self.myPlane, controlType)
-- end


--测试结算代码段
-- function TDHMJScene:testEnding()

-- 	TDHMJ_USERINFO_TABLE[0] = {}
-- 	TDHMJ_USERINFO_TABLE[0].uid = 723
-- 	TDHMJ_USERINFO_TABLE[0].nick = "zh"

-- 	TDHMJ_USERINFO_TABLE[1] = TDHMJ_USERINFO_TABLE[0]
-- 	TDHMJ_USERINFO_TABLE[2] = TDHMJ_USERINFO_TABLE[0]
-- 	TDHMJ_USERINFO_TABLE[3] = TDHMJ_USERINFO_TABLE[0]


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


--创建一个touch的半透明layer

--priority : touch 权限级别,默认为-1024

--touchRect: 在touchRect 区域会放行touch事件 若touchRect = nil 则全屏吃touch

--touchCallback: 屏蔽层touch 回调

-- function TDHMJScene:createMaskLayer(priority,touchRect,touchCallback,layerOpacity,highRect)

--     local layer = CCLayer:create()

--     layer:setPosition(ccp(0, 0))

--     layer:setAnchorPoint(ccp(0, 0))

--     layer:setTouchEnabled(true)

--     layer:setTouchPriority(priority or -1024)

--     layer:registerScriptTouchHandler(function ( eventType,x,y )

--         if(eventType == "began") then

--             if(touchRect == nil) then

--                 if(touchCallback ~= nil) then

--                     touchCallback()

--                 end

--                 return true

--             else

--                 if(touchRect:containsPoint(ccp(x,y))) then

--                     return false

--                 else

--                     if(touchCallback ~= nil) then

--                         touchCallback()

--                     end

--                     return true

--                 end

--             end

--         end

--         --print(eventType)

--     end,false, priority or -1024, true)

--     local gw,gh = g_winSize.width, g_winSize.height

--     if(touchRect == nil) then

--         local layerColor = CCLayerColor:create(ccc4(0,0,0,layerOpacity or 150),gw,gh)

--         layerColor:setPosition(ccp(0,0))

--         layerColor:setAnchorPoint(ccp(0,0))

--         layer:addChild(layerColor)

--         return layer

--     else

--         local ox,oy,ow,oh = touchRect.origin.x, touchRect.origin.y, touchRect.size.width, touchRect.size.height

--         local layerColor = CCLayerColor:create(ccc4(0, 0, 0, layerOpacity or 150 ), gw, gh)

--         local clipNode = CCClippingNode:create();

--         clipNode:setInverted(true)

--         clipNode:addChild(layerColor)

--         local stencilNode = CCNode:create()

--         -- stencilNode:retain()

--         local node = CCScale9Sprite:create("bg.png");

--         node:setContentSize(CCSizeMake(ow, oh))

--         node:setAnchorPoint(ccp(0, 0))

--         node:setPosition(ccp(ox, oy))

--         stencilNode:addChild(node)

--         if(highRect ~= nil) then

--             local highNode = CCScale9Sprite:create("bg.png");

--             highNode:setContentSize(CCSizeMake(highRect.size.width, highRect.size.height))

--             highNode:setAnchorPoint(ccp(0, 0))

--             highNode:setPosition(ccp(highRect.origin.x, highRect.origin.y))

--             stencilNode:addChild(highNode)

--         end

--         clipNode:setStencil(stencilNode)

--         clipNode:setAlphaThreshold(0.5)

--         layer:addChild(clipNode)

--      end

--     return layer

-- end

-- function darkNode ( node )

-- local vertDefaultSource = "\n" . .

-- "attribute vec4 a_position; \n" . .

-- "attribute vec2 a_texCoord; \n" . .

-- "attribute vec4 a_color; \n" . .                                                     

-- "#ifdef GL_ES  \n" . .

-- "varying lowp vec4 v_fragmentColor;\n" . .

-- "varying mediump vec2 v_texCoord;\n" . .

-- "#else                      \n" . .

-- "varying vec4 v_fragmentColor; \n" . .

-- "varying vec2 v_texCoord;  \n" . .

-- "#endif    \n" . .

-- "void main() \n" . .

-- "{\n" . .

-- "gl_Position = CC_PMatrix * a_position; \n" . .

-- "v_fragmentColor = a_color;\n" . .

-- "v_texCoord = a_texCoord;\n" . .

-- "}"


-- local pszFragSource = "#ifdef GL_ES \n" . .

-- "precision mediump float; \n" . .

-- "#endif \n" . .

-- "varying vec4 v_fragmentColor; \n" . .

-- "varying vec2 v_texCoord; \n" . .

-- "void main(void) \n" . .

-- "{ \n" . .

-- "vec4 c = texture2D(CC_Texture0, v_texCoord); \n" . .

-- "gl_FragColor.xyz = vec3(0.4*c.r + 0.4*c.g +0.4*c.b); \n" . .

-- "gl_FragColor.w = c.w; \n" . .

-- "}"

-- local pProgram = cc . GLProgram : createWithByteArrays ( vertDefaultSource , pszFragSource )


-- pProgram : bindAttribLocation ( cc . ATTRIBUTE_NAME_POSITION , cc . VERTEX_ATTRIB_POSITION )

-- pProgram : bindAttribLocation ( cc . ATTRIBUTE_NAME_COLOR , cc . VERTEX_ATTRIB_COLOR )

-- pProgram : bindAttribLocation ( cc . ATTRIBUTE_NAME_TEX_COORD , cc . VERTEX_ATTRIB_FLAG_TEX_COORDS )

-- pProgram : link ( )

-- pProgram : updateUniforms ( )

-- node : setGLProgram ( pProgram )


-- end

return TDHMJScene