
-- --加载麻将设置类（麻将公共方法类）
-- require("majiang.setting_help")

--加载框架初始化类
require("framework.init")

local gamePlaneOperator = require("xykawuxing.operator.GamePlaneOperator")
local manyouPlaneOperator = require("xykawuxing.operator.ManyouPlaneOperator")
local controlPlaneOperator =require("xykawuxing.operator.ControlPlaneOperator")
local cardUtils = require("xykawuxing.utils.cardUtils")

--加载大厅请求处理
local hallHandle = require("hall.HallHandle")

local voiceUtils = require("xykawuxing.utils.VoiceUtils")

--大厅套接字请求类
local hallPa = require("hall.HALL_PROTOCOL")

--麻将套接字请求类
local PROTOCOL = import("xykawuxing.handle.XYKWXProtocol")

local sendHandle = require("xykawuxing.handle.XYKWXSendHandle")

--定义麻将游戏处理类
local XYKWXReceiveHandle = class("XYKWXReceiveHandle",hallHandle)

local aniUtils = require("xykawuxing.utils.AniUtils")

--定义登录超时时间
local LOGIN_OUT_TIMER = 20

--定义麻将游戏界面名称
local run_scene_name = "xykawuxing.gameScene"

--扣除台费百分数
local percent_base = 0.20

local item_ly_list = {}

function XYKWXReceiveHandle:ctor()

	XYKWXReceiveHandle.super.ctor(self);

	--定义麻将游戏请求	
	local  func_ = {

		--游戏开始
      	[PROTOCOL.SVR_GAME_START] = {handler(self, XYKWXReceiveHandle.SVR_GAME_START)},
		--房间不存在
      	[PROTOCOL.SVR_ENTER_PRIVATE_ROOM] = {handler(self, XYKWXReceiveHandle.SVR_ENTER_PRIVATE_ROOM)},
		--用户自己退出成功
        [PROTOCOL.SVR_QUICK_SUC] = {handler(self, XYKWXReceiveHandle.SVR_QUICK_SUC)},
        --广播用户准备
        [PROTOCOL.SVR_USER_READY_BROADCAST] = {handler(self, XYKWXReceiveHandle.SVR_USER_READY_BROADCAST)},
        --登陆房间广播
        [PROTOCOL.SVR_LOGIN_ROOM_BROADCAST] = {handler(self, XYKWXReceiveHandle.SVR_LOGIN_ROOM_BROADCAST)},
        --广播玩家退出返回
        [PROTOCOL.SVR_QUIT_ROOM] = {handler(self, XYKWXReceiveHandle.SVR_QUIT_ROOM)},
        --发牌
        [PROTOCOL.SVR_SEND_USER_CARD] = {handler(self, XYKWXReceiveHandle.SVR_SEND_USER_CARD)},
        --开始选择缺一门
        [PROTOCOL.SVR_START_QUE_CHOICE] = {handler(self, XYKWXReceiveHandle.SVR_START_QUE_CHOICE)},
        --广播缺一门选择
        [PROTOCOL.SVR_BROADCAST_QUE] = {handler(self, XYKWXReceiveHandle.SVR_BROADCAST_QUE)},
        --当前抓牌用户广播
        [PROTOCOL.SVR_PLAYING_UID_BROADCAST] = {handler(self, XYKWXReceiveHandle.SVR_PLAYING_UID_BROADCAST)},
        --广播用户出牌
        [PROTOCOL.SVR_SEND_MAJIANG_BROADCAST] = {handler(self, XYKWXReceiveHandle.SVR_SEND_MAJIANG_BROADCAST)},
        --svr通知我抓的牌
        [PROTOCOL.SVR_OWN_CATCH_BROADCAST] = {handler(self, XYKWXReceiveHandle.SVR_OWN_CATCH_BROADCAST)},
        --广播用户进行了什么操作
        [PROTOCOL.SVR_PLAYER_USER_BROADCAST] = {handler(self, XYKWXReceiveHandle.SVR_PLAYER_USER_BROADCAST)},
        --广播胡
    	[PROTOCOL.SVR_HUPAI_BROADCAST]       = {handler(self, XYKWXReceiveHandle.SVR_HUPAI_BROADCAST)}, 
    	--结算
    	[PROTOCOL.SVR_ENDDING_BROADCAST] = {handler(self, XYKWXReceiveHandle.SVR_ENDDING_BROADCAST)}, 
    	--请求托管
    	[PROTOCOL.SVR_ROBOT] = {handler(self, XYKWXReceiveHandle.SVR_ROBOT)}, 
    	--出牌错误返回
    	[PROTOCOL.SVR_CHUPAI_ERROR] = {handler(self, XYKWXReceiveHandle.SVR_CHUPAI_ERROR)}, 
    	--海底牌 SVR_HAIDI_CARD
    	[PROTOCOL.SVR_HAIDI_CARD] = {handler(self, XYKWXReceiveHandle.SVR_HAIDI_CARD)}, 
    	--亮倒提示
    	[PROTOCOL.SVR_LIANGDAO_REMAID] = {handler(self, XYKWXReceiveHandle.SVR_LIANGDAO_REMAID)}, 
    	[PROTOCOL.SVR_MSG_FACE]={handler(self, XYKWXReceiveHandle.SVR_MSG_FACE)},
    	
    	[PROTOCOL.BROADCAST_USER_IP]={handler(self, XYKWXReceiveHandle.BROADCAST_USER_IP)},

    	[PROTOCOL.SVR_JIAPIAO]={handler(self, XYKWXReceiveHandle.SVR_JIAPIAO)},
    	[PROTOCOL.SVR_JIAPIAO_BROADCAST]={handler(self, XYKWXReceiveHandle.SVR_JIAPIAO_BROADCAST)},

    	--获取房间id结果
    	[PROTOCOL.SVR_GET_ROOM_OK]     = {handler(self, XYKWXReceiveHandle.SVR_GET_ROOM_OK)},
    	--登陆房间返回
        [PROTOCOL.SVR_LOGIN_ROOM]      = {handler(self, XYKWXReceiveHandle.SVR_LOGIN_ROOM)},
        --登陆错误
     	[PROTOCOL.SVR_ERROR]      = {handler(self, XYKWXReceiveHandle.SVR_ERROR)},
     	--用户重新登录普通房间的消息返回（4105(10进制s)）
     	[PROTOCOL.SVR_REGET_ROOM]      = {handler(self, XYKWXReceiveHandle.SVR_REGET_ROOM)},--重登
     	--服务器告知客户端可以进行的操作
     	[PROTOCOL.SVR_NORMAL_OPERATE]      = {handler(self, XYKWXReceiveHandle.SVR_NORMAL_OPERATE)},--广播可以进行的操作
     	--服务器告知客户端游戏结束
     	[PROTOCOL.SVR_GAME_OVER]      = {handler(self, XYKWXReceiveHandle.SVR_GAME_OVER)},
     	--广播刮风下雨（返回）杠
     	[PROTOCOL.SVR_GUFENG_XIAYU]      = {handler(self, XYKWXReceiveHandle.SVR_GUFENG_XIAYU)},


     	--用户聊天消息
     	[PROTOCOL.CHAT_MSG]      = {handler(self, XYKWXReceiveHandle.CHAT_MSG)},
        --录音
        [PROTOCOL.SERVER_CMD_MESSAGE] = {handler(self, XYKWXReceiveHandle.SERVER_CMD_MESSAGE)},   
         --接收服务器发来的距离
        [PROTOCOL.SERVER_CMD_FORWARD_MESSAGE] = {handler(self, XYKWXReceiveHandle.SERVER_CMD_FORWARD_MESSAGE)},

     	--组局
     	--请求获取筹码返回
     	[PROTOCOL.SVR_GET_CHIP]     = {handler(self, XYKWXReceiveHandle.SVR_GET_CHIP)},
     	--请求兑换筹码返回
     	[PROTOCOL.SVR_CHANGE_CHIP]     = {handler(self, XYKWXReceiveHandle.SVR_CHANGE_CHIP)},
     	--组局时长
     	[PROTOCOL.SVR_GROUP_TIME]     = {handler(self, XYKWXReceiveHandle.SVR_GROUP_TIME)},
     	--组局排行榜
     	[PROTOCOL.SVR_GROUP_BILLBOARD]     = {handler(self, XYKWXReceiveHandle.SVR_GROUP_BILLBOARD)},
     	--组局历史记录
     	[PROTOCOL.SVR_GET_HISTORY]     = {handler(self, XYKWXReceiveHandle.SVR_GET_HISTORY)},
     	--漫游
     	[PROTOCOL.SVR_MANYOU] = {handler(self, XYKWXReceiveHandle.SVR_MANYOU)},

     	--没有此房间，解散房间失败
     	[PROTOCOL.G2H_CMD_DISSOLVE_FAILED]     = {handler(self, XYKWXReceiveHandle.G2H_CMD_DISSOLVE_FAILED)},
     	--广播桌子用户请求解散组局
     	[PROTOCOL.SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP]     = {handler(self, XYKWXReceiveHandle.SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP)},
     	--广播当前组局解散情况
     	[PROTOCOL.G2H_CMD_REFRESH_DISSOLVE_LIST]     = {handler(self, XYKWXReceiveHandle.G2H_CMD_REFRESH_DISSOLVE_LIST)},
     	--广播桌子用户成功解散组局
     	[PROTOCOL.SERVER_BROADCAST_DISSOLVE_GROUP]     = {handler(self, XYKWXReceiveHandle.SERVER_BROADCAST_DISSOLVE_GROUP)},
     	--广播桌子用户解散组局 ，解散组局失败
     	[PROTOCOL.SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP]     = {handler(self, XYKWXReceiveHandle.SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP)},

     	--换牌
     	--服务器告诉客户端，可以换牌
     	[PROTOCOL.SERVER_COMMAND_NEED_CHANGE_CARD]     = {handler(self, XYKWXReceiveHandle.SERVER_COMMAND_NEED_CHANGE_CARD)},
     	--//服务器广播换牌的结果 zsw
     	[PROTOCOL.SERVER_COMMAND_CHANGE_CARD_RESULT]     = {handler(self, XYKWXReceiveHandle.SERVER_COMMAND_CHANGE_CARD_RESULT)},
   
     	--比赛场相关
     	--用户请求进入比赛场的返回值
     	[PROTOCOL.s2c_JOIN_MATCH_RETURN]     = {handler(self, XYKWXReceiveHandle.s2c_JOIN_MATCH_RETURN)},
     	--进入比赛失败
     	[PROTOCOL.s2c_JOIN_MATCH_FAIL]     = {handler(self, XYKWXReceiveHandle.s2c_JOIN_MATCH_FAIL)},
     	-- 进入比赛成功
		[PROTOCOL.s2c_JOIN_MATCH_SUCCESS]     = {handler(self, XYKWXReceiveHandle.s2c_JOIN_MATCH_SUCCESS)},
		--同时，已经报名的玩家会收到其他玩家进入的消息
     	[PROTOCOL.s2c_OTHER_PEOPLE_JOINT_IN]     = {handler(self, XYKWXReceiveHandle.s2c_OTHER_PEOPLE_JOINT_IN)},
     	--返回退出比赛结果
     	[PROTOCOL.s2c_QUIT_MATCH_RETURN]     = {handler(self, XYKWXReceiveHandle.s2c_QUIT_MATCH_RETURN)},
     	--比赛开始逻辑0x7104//牌局，开始发送其他玩家信息
     	[PROTOCOL.s2c_GAME_BEGIN_LOGIC]     = {handler(self, XYKWXReceiveHandle.s2c_GAME_BEGIN_LOGIC)},
     	--每轮打完之后 会给玩家发送比赛状态信息0x7106
     	[PROTOCOL.s2c_GAME_STATE_MSG]     = {handler(self, XYKWXReceiveHandle.s2c_GAME_STATE_MSG)},
     	-- 比赛的过程中会收到比赛的排名信息  0x7114
     	[PROTOCOL.s2c_PAI_MING_MSG]     = {handler(self, XYKWXReceiveHandle.s2c_PAI_MING_MSG)},
     	--发送用户重连回比赛开赛后的等待界面
     	[PROTOCOL.s2c_SVR_MATCH_WAIT]     = {handler(self, XYKWXReceiveHandle.s2c_SVR_MATCH_WAIT)},
     	--用户重新登录比赛场房间的消息返回
     	[PROTOCOL.s2c_SVR_REGET_MATCH_ROOM] = {handler(self, XYKWXReceiveHandle.s2c_SVR_REGET_MATCH_ROOM)},

    }
    table.merge(self.func_, func_)

end

-- 游戏开始
function XYKWXReceiveHandle:SVR_GAME_START( pack )
	-- body
	require("hall.gameSettings"):setGroupState(1)
    if bm.Room == nil then
        bm.Room = {}
    end
    bm.Room.start_group = 1

    local is_alert = true
	print("IP广播",bm.round,bm.Room.isStart)
	dump(bm.ips, "ips")
	dump(XYKWX_USERINFO_TABLE, "user_info")
	bm.Room.UserInfo = bm.Room.UserInfo or {}
	for k,v in pairs(XYKWX_USERINFO_TABLE) do
		bm.Room.UserInfo[v.uid] = {}
		bm.Room.UserInfo[v.uid]["sex"] = v.sex
		bm.Room.UserInfo[v.uid]["photoUrl"] = v.photoUrl
		bm.Room.UserInfo[v.uid]["nick"] = v.nick
	end

	if XYKWX_ROUND and XYKWX_ROUND > 1 then
		is_alert = false
	end

	if is_alert then
		require("hall.GameTips"):showIPAlert(bm.ips["playeripdata"])
	end

	if SCENENOW['name'] ~= run_scene_name then
		return
	end	
	SCENENOW['scene'].reay_my:setVisible(false)
	SCENENOW['scene'].reay_right:setVisible(false)
	SCENENOW['scene'].reay_left:setVisible(false)
end
--接收服务器返回的组局信息
function XYKWXReceiveHandle:SERVER_CMD_MESSAGE(pack)
	require("hall.view.voicePlayView.voicePlayView"):dealVoiceOrVideo(pack)
	-- if bm.isInGame == false then
	-- 	return
	-- end
    
 --    local msg = json.decode(pack.msg)
 --    dump(msg, "-----NiuniuroomHandle 接收服务器返回的组局信息-----")
 --    if msg ~= nil then
 --    	local msgType = msg.msgType
	-- 	if msgType ~= nil and msgType ~= "" then

	-- 		if device.platform == "ios" then

	-- 			if msgType == "voice" then
	-- 				dump("voice", "-----接收服务器返回的组局信息-----")

	-- 				require("hall.view.voicePlayView.voicePlayView"):showView(msg.uid, msg.voiceTime)

	-- 				--通知本地播放录音
	-- 				local arr = {}
 --                    arr["url"] = msg.url
	-- 				cct.getDateForApp("playVoice", arr, "V")

	-- 			elseif msgType == "video" then
	-- 				dump("video", "-----接收服务器返回的组局信息-----")

	-- 				local arr = {}
 --                    arr["url"] = msg.url
	-- 				cct.getDateForApp("playVideo", arr, "V")

	-- 			end

	-- 		else

	-- 			if msgType == "voice" then
 --                    dump("voice", "-----接收服务器返回的组局信息-----")

 --                    require("hall.view.voicePlayView.voicePlayView"):showView(msg.uid, msg.voiceTime)

 --                    --通知本地播放录音

 --                    local data = {}
 --                    data["url"] = msg.url
                    
 --                    local arr = {}
 --                    table.insert(arr, json.encode(data))
 --                    cct.getDateForApp("playVoice", arr, "V")

 --                elseif msgType == "video" then
 --                    dump("video", "-----接收服务器返回的组局信息-----")
                    
 --                    local data = {}
 --                    data["url"] = msg.url
                    
 --                    local arr = {}
 --                    table.insert(arr, json.encode(data))
 --                    cct.getDateForApp("playVideo", arr, "V")

 --                end
			
	-- 		end

	-- 	end
 --    end
    
end

--接收服务器发来的距离数据    0x 0213
function XYKWXReceiveHandle:SERVER_CMD_FORWARD_MESSAGE(pack)

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


function XYKWXReceiveHandle:SVR_JIAPIAO(pack)

	local scenes  = SCENENOW['scene']

	if SCENENOW["name"] ~= run_scene_name then
		return
	end

	scenes:hideCloseRoomButton()
	scenes:ShowSettingButton()
	scenes:hideShareButton()

	gamePlaneOperator:showCenterPlane()

	gamePlaneOperator:showJiapiaoPlane(true)
end

function XYKWXReceiveHandle:SVR_JIAPIAO_BROADCAST(pack)
	local playerType = cardUtils:getPlayerType(pack.seatId)
	gamePlaneOperator:showPiaoImg(playerType, pack.jiapiao, true)
	gamePlaneOperator:showPiaoPlane(playerType, pack.jiapiao, true)
end

function XYKWXReceiveHandle:BROADCAST_USER_IP(pack)
	for k,v in pairs(pack.playeripdata) do
		if v.uid == tonumber(UID) then
			require("hall.view.userInfoView.userInfoView"):sendUserPosition(v.ip)
		end
	end

	bm.ips = pack
	
	local playeripdata = pack.playeripdata or {}
    for _,ip_data in pairs(playeripdata) do
      local ip_ = ip_data.ip or ""
      local uid_ = ip_data.uid or 0
      if uid_ ~= 0 then
        require("hall.GameData"):setUserIP(uid_, ip_)
      end
    end

  --   			local myIp = ""

	 --            if XYKWX_MY_USERINFO.seat_id and XYKWX_USERINFO_TABLE[XYKWX_MY_USERINFO.seat_id .. ""] then
	 --            	--todo
	 --            	myIp = XYKWX_USERINFO_TABLE[XYKWX_MY_USERINFO.seat_id .. ""].ip
	 --            end
	    

	 --            local ipTable = {}
	 --            for k,v in pairs(XYKWX_USERINFO_TABLE) do
	 --            	if v.ip and v.ip ~= myIp then
	 --            		--todo
	 --            		if not ipTable[v.ip] then
	 --            			--todo
	 --            			ipTable[v.ip] = {}
	 --            		end
	 --            		table.insert(ipTable[v.ip], v.nick)
	 --            	end
	 --            end

	 --            local msg = ""
	 --            for k,v in pairs(ipTable) do
	 --            	if table.getn(v) > 1 then
	 --            		--todo
	 --            		for i=1,table.getn(v) do
	 --            			msg = msg .. v[i] .. " "
	 --            		end
	 --            	end
	 --            end

	 --            if msg ~= "" then
	 --            	--todo
	 --            	require("hall.GameCommon"):showAlert(false, "提示：" .. msg .. "ip地址相同，谨防作弊", 300)
	 --            	require("hall.GameCommon"):showAlert(true, "提示：" .. msg .. "ip地址相同，谨防作弊", 300)
	 --            end
end

function XYKWXReceiveHandle:SVR_MSG_FACE(pack)
	if SCENENOW["name"] == run_scene_name then
		local seatId = XYKWX_SEAT_TABLE[pack.uid .. ""]
		local sex = XYKWX_USERINFO_TABLE[seatId .. ""].sex
		local playerType = cardUtils:getPlayerType(seatId)

		local isLeft = false
		if playerType == CARD_PLAYERTYPE_RIGHT then
			--todo
			isLeft = true
		end

		local node_head = gamePlaneOperator:getHeadNode(playerType)


        SCENENOW["scene"]:SVR_MSG_FACE(pack.uid, pack.type, sex, node_head, isLeft)
    end
end

--海底牌
function XYKWXReceiveHandle:SVR_HAIDI_CARD(pack)
	XYKWX_REMAIN_CARDS_COUNT = 0
	gamePlaneOperator:showRemainCardsCount()
	manyouPlaneOperator:show(pack.card, pack.uid)
end

function XYKWXReceiveHandle:SVR_LIANGDAO_REMAID(pack)
	XYKWX_ROOM.dianpao_card = pack.card

	local desc = "不能点炮，请重新出牌\n\n"

	desc = desc .. "接炮的玩家："

	for k,v in pairs(pack.winSeats) do
		desc = desc .. XYKWX_USERINFO_TABLE[v .. ""].nick .. "  "
	end

	require("hall.GameCommon"):showAlert(true, desc, 300)

	gamePlaneOperator:revertOutCardPosition()

	XYKWX_CHUPAI = 1
end

--出牌错误返回
function XYKWXReceiveHandle:SVR_CHUPAI_ERROR(pack)
	local errorCode = pack.errorCode

	if errorCode == 1 then
		--todo
		XYKWX_CHUPAI = 1
	elseif errorCode == 2 then
		XYKWX_CHUPAI = 1
		require("hall.GameCommon"):showAlert(true, "正在等待自己或者其他玩家操作", 200)
	elseif errorCode == 3 then
		XYKWX_CHUPAI = 0
	elseif errorCode == 4 then
		XYKWX_CHUPAI = 1
	end
end

--获取玩家显示的位置号 0自己，1左边玩家，2对家，3右边玩家
function XYKWXReceiveHandle:getIndex(uid)

	if tonumber(uid) == tonumber(UID) then
		return 0
	end
	local other_seat  = XYKWX_ROOM.User[uid]
	dump( XYKWX_ROOM.User, " XYKWX_ROOM.User")

	print(other_seat,bm.User.Seat,"2")
	local other_index = other_seat - bm.User.Seat
	if other_index < 0 then
		other_index = other_index + 4
	end
	print(other_index,"3")
	   
	if other_index == 1 then
    	other_index = 3
    elseif other_index == 3 then
    	other_index = 1 
    end

	return other_index

end

--漫游
function XYKWXReceiveHandle:SVR_MANYOU(pack)
	manyouPlaneOperator:show()
end

--显示倒计时器
function XYKWXReceiveHandle:showTimer(uid,time)

	local scenes = SCENENOW['scene']

	if SCENENOW['name'] ~= run_scene_name then
		return
	end

	--设置显示计时器
	scenes:show_timer_visible(true)

	--初始化计时器
	scenes:init_clock()

	if XYKWX_ROOM.timerid then
		bm.SchedulerPool:clear(XYKWX_ROOM.timerid)
	end

	local index = self:getIndex(uid)
	scenes:show_timer_index(index)
	XYKWX_ROOM.timer   = time
	self.timecount_ = 0 
	XYKWX_ROOM.timerid = nil

	XYKWX_ROOM.timerid = bm.SchedulerPool:loopCall(function()

		self.timecount_ = self.timecount_ + 1

		if XYKWX_ROOM.timer and self.timecount_ % 5 == 0 then
			XYKWX_ROOM.timer  = XYKWX_ROOM.timer - 1
		end

		if XYKWX_ROOM.timer and XYKWX_ROOM.timer >= 0 and XYKWX_ROOM.timer <= 9 then
			local scenes  = SCENENOW['scene']
			if SCENENOW['name'] == run_scene_name and scenes.show_timer_num then
				--显示时间数字
				scenes:show_timer_num(XYKWX_ROOM.timer)
				--
				scenes:showClock(index,XYKWX_ROOM.timer,true)
			end
		end
		
		return true

	end,0.2)
	
end

--清理界面
function XYKWXReceiveHandle:clearUserView(index)

	dump(index, "-----清理界面-----")

	-- local index   = self:getIndex(uid)
	local scenes  = SCENENOW['scene']

	if SCENENOW["name"] ~= run_scene_name then
		return
	end

	if index == 0 then
		local node = scenes._scene:getChildByName("layer_card"):getChildByName("owncard")
		if node then
			node:removeSelf()
		end

		local node = scenes:getChildByName("play_info")
		if node then
			node:removeSelf()
		end

		
	else
		local node = scenes._scene:getChildByName("layer_card"):getChildByName("othercard"..index)
		if node then
			node:removeSelf()
		end

		local node = scenes:getChildByName("play_info"..index)
		if node then
			node:removeSelf()
		end
	end

	local node = scenes:getChildByName("cardout"..index)
	if node then
		node:removeSelf()
	end

	if XYKWX_ROOM.timerid then
		bm.SchedulerPool:clear(XYKWX_ROOM.timerid)
	end  

	local node = scenes:getChildByName("timer") 
	if node then
		node:removeSelf()
	end

	local node = scenes:getChildByName("zhuang") 
	if node then
		node:removeSelf()
	end

	local node = scenes:getChildByName("has_xuan_que") 
	if node then
		node:removeSelf()
	end

	local node    = scenes:getChildByName("user"..index)
	if node ~= nil then
		node:removeSelf()
	end

	scenes:show_tuoguan_layout(false)
	scenes:set_left_card_num_visible(false)

	bm.palying = false
	
end
-------------------------------------------------------------------------------------------------------------------

--协议相关

--麻将游戏加载请求方法
function XYKWXReceiveHandle:callFunc(pack)

	if self.func_[pack.cmd] and self.func_[pack.cmd][1] then
        self.func_[pack.cmd][1](pack)
    end

end
-------------------------------------------------------------------------------------------------------------------

--进出房间相关
--用户进入房间
function XYKWXReceiveHandle:SVR_LOGIN_ROOM_BROADCAST(pack)

	dump(pack ,"-----用户进入房间-----")
	if pack ~= nil then
		self:showPlayer(pack)

		local uid_arr = {}

		for k,v in pairs(XYKWX_USERINFO_TABLE) do
			table.insert(uid_arr, v.uid)
		end

		require("hall.GameSetting"):setPlayerUid(uid_arr)

		bm.Room.XYKWX_uid_seatid[pack.uid] = pack.seat_id
	end

end

--处理进入房间
function XYKWXReceiveHandle:SVR_GET_ROOM_OK(pack_data)
	print("---------------------------SVR_GET_ROOM_OK----------------------------------")
	dump(pack_data)
	print("denglusuccess table id is ",pack_data['tid'],bm.isGroup,USER_INFO["activity_id"])

	print("group test")
	-- if not bm.isGroup  then
    if require("hall.gameSettings"):getGameMode() ~= "group" then
		--todo
		local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_LOGIN_ROOM_GROUP)
        :setParameter("tableid", pack_data['tid'])
        :setParameter("nUserId", UID)
        :setParameter("strkey", "")
        :setParameter("strinfo", USER_INFO["user_info"])
        :setParameter("iflag", 2)
        :setParameter("version", 1)
        :setParameter("activity_id","")
        :build()
    	bm.server:send(pack)
    	print("sending----------------1001............")
	else
		print("group test ok")

		local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_LOGIN_ROOM_GROUP)
        :setParameter("tableid", pack_data['tid'])
        :setParameter("nUserId", tonumber(UID))
        :setParameter("strkey", json.encode("kadlelala"))
        :setParameter("strinfo", USER_INFO["user_info"])
      	:setParameter("iflag", 2)
        :setParameter("version", 1)
        :setParameter("activity_id", USER_INFO["activity_id"])
        :build()
    	bm.server:send(pack)
    	print("sending----------------1001............")
	end
	
end

function XYKWXReceiveHandle:getSeatIndex(uid)
	local x = bm.Room.XYKWX_uid_seatid[uid] - bm.Room.XYKWX_uid_seatid[UID]
	if x < 0 then
		x = x + 3
	end
	return x
end

--登录房间成功
function XYKWXReceiveHandle:SVR_LOGIN_ROOM(pack)

	SCENENOW['scene']:removeChildByName("loading")
	if SCENENOW['name'] ~= run_scene_name then
		return
	end	

	bm.Room.XYKWX_uid_seatid = {}
	bm.Room.XYKWX_uid_seatid[UID] = pack.seat_id
	if pack.user_mount > 0  then
		for i,v in pairs(pack.users_info) do
			bm.Room.XYKWX_uid_seatid[v.uid] = v.seat_id
			if v.if_ready == 1 then
				local x = self:getSeatIndex(v.uid)
				if x == 1 then
					SCENENOW['scene'].reay_right:setVisible(true)
				else
					SCENENOW['scene'].reay_left:setVisible(true)
				end
			end
		end
	end

	--记录当前局数
		XYKWX_ROUND = 0

		--记录总局数
		XYKWX_TOTAL_ROUNDS = pack.totalRounds

		gamePlaneOperator:showRemainCardsCount()

	XYKWX_GAME_STATUS = 0

	XYKWX_USERINFO_TABLE = {}
	
	dump(pack, "-----登录房间成功-----")

	XYKWX_GROUP_ENDING_DATA = nil

	bm.User = {}
	XYKWX_MY_USERINFO.seat_id = pack.seat_id
	XYKWX_MY_USERINFO.coins      = pack.gold - USER_INFO["group_chip"]

	-- XYKWX_ROOM = {}
	-- XYKWX_ROOM.User      = {}	
 --    XYKWX_ROOM.UserInfo  = {}
 --    XYKWX_ROOM.seat_uid  = {}
	-- XYKWX_ROOM.Card      = {}
	-- XYKWX_ROOM.Gang      = {}
	XYKWX_ROOM.base      = pack.base

	-- XYKWX_ROOM.tuoguan_ing = 0
	--bm.display_scenes("majiang.scenes.MajiangroomScenes")

	-- SCENENOW["scene"]:removeSelf()
	-- SCENENOW["scene"] = nil;

	-- local sc = require("xykawuxing.gameScene"):new()
	-- SCENENOW["scene"] = sc
 --    --SCENENOW["scene"]:retain();
 --    SCENENOW["name"]  = "majiang.scenes.MajiangroomScenes";
	-- display.replaceScene(sc)

	-- local scenes = sc

	--绘制自己的信息
	XYKWX_MY_USERINFO.photoUrl = USER_INFO["icon_url"]
	XYKWX_MY_USERINFO.nick = USER_INFO["nick"]
	XYKWX_MY_USERINFO.coins = pack["gold"] - USER_INFO["group_chip"]
	XYKWX_MY_USERINFO.uid = tonumber(UID)
	XYKWX_MY_USERINFO.sex = USER_INFO["sex"]
	XYKWX_SEAT_TABLE_BY_TYPE[CARD_PLAYERTYPE_MY .. ""] = pack.seat_id
	XYKWX_SEAT_TABLE[tonumber(UID) .. ""] = pack.seat_id
	XYKWX_USERINFO_TABLE[pack.seat_id .. ""] = {}

	XYKWX_USERINFO_TABLE[pack.seat_id .. ""].photoUrl = USER_INFO["icon_url"]
	XYKWX_USERINFO_TABLE[pack.seat_id .. ""].uid = tonumber(UID)
	XYKWX_USERINFO_TABLE[pack.seat_id .. ""].nick = USER_INFO["nick"]
	XYKWX_USERINFO_TABLE[pack.seat_id .. ""].coins = pack["gold"] - USER_INFO["group_chip"]
	XYKWX_USERINFO_TABLE[pack.seat_id .. ""].sex = USER_INFO["sex"]


	dump(XYKWX_GAME_PLANE, "xykawuxing test")
	local infoPlane = gamePlaneOperator:showPlayerInfo(CARD_PLAYERTYPE_MY, XYKWX_MY_USERINFO)
	local point = cc.p(infoPlane:getAnchorPoint().x * infoPlane:getSize().width, infoPlane:getAnchorPoint().y * infoPlane:getSize().height)

	XYKWX_ROOM.positionTable[tonumber(UID) .. ""] = infoPlane:convertToWorldSpace(point)
	local position = XYKWX_ROOM.positionTable[tonumber(UID) .. ""]
	require("hall.view.voicePlayView.voicePlayView"):updateUserPosition(tonumber(tonumber(UID)),position)

	--绘制其他玩家
	if pack.user_mount > 0  then
		for i,v in pairs(pack.users_info) do
			dump(pack, "player test")
			XYKWXReceiveHandle:showPlayer(v)
		end
	end

	SCENENOW["scene"]:ShowRecordButton()

	local uid_arr = {}

	for k,v in pairs(XYKWX_USERINFO_TABLE) do
		table.insert(uid_arr, v.uid)
	end

	require("hall.GameSetting"):setPlayerUid(uid_arr)

	--绘制其他元素
	-- scenes:set_basescole_txt(XYKWX_ROOM.base)

	-- if bm.isGroup  then --
 --    if require("hall.gameSettings"):getGameMode() == "group" then
	-- 	USER_INFO["base_chip"] = XYKWX_ROOM.base;

	-- else
	-- 	SCENENOW["scene"]:gameReady();
	-- end

	voiceUtils:playBackgroundMusic()

	sendHandle:readyNow()

	SCENENOW["scene"]:ShowChatButton()

		--发送当前用户地理位置
	-- sendHandle:CLIENT_CMD_FORWARD_MESSAGE("")
end

--登陆错误
function XYKWXReceiveHandle:SVR_ERROR(pack)
	
	dump(pack, "-----登陆错误-----")

	local errcode = "error"
	local showBtn = 2
	if pack["type"] == 9 then
		errcode = "change_money"
		showBtn = 1
	end
	require("hall.GameTips"):showTips(tbErrorCode[pack["type"]],errcode,showBtn)

end

--用户重登房间
function XYKWXReceiveHandle:SVR_REGET_ROOM(pack)
	bm.Room.XYKWX_uid_seatid = {}
	bm.Room.XYKWX_uid_seatid[UID] = pack.seat_id
	if pack.nPlayerCount > 0 then
		for k,v in pairs(pack.users_info) do
			bm.Room.XYKWX_uid_seatid[v.uid] = v.seat_id
		end
	end

	dump(pack, "-----重连房间成功-----")
	require("hall.gameSettings"):setGroupState(1)

	XYKWX_GROUP_ENDING_DATA = nil
	
    if bm.Room == nil then
        bm.Room = {}
    end
    bm.Room.start_group = 1

	SCENENOW['scene']:removeChildByName("loading")

	local scenes  = SCENENOW['scene']
	if SCENENOW['name'] ~= run_scene_name then
		return
	end	

	XYKWX_ROOM.isBufenLiang = pack.isBufenLiang

	XYKWX_GAME_STATUS = 1

	scenes:hideCloseRoomButton()
	scenes:ShowSettingButton()
	scenes:hideShareButton()
	scenes:ShowRecordButton()
	scenes:ShowChatButton()

	gamePlaneOperator:clearGameDatas()

	gamePlaneOperator:showCenterPlane()

	XYKWX_REMAIN_CARDS_COUNT = pack.card_less
	XYKWX_ROUND = pack.round + 1
	XYKWX_TOTAL_ROUNDS = pack.totalRounds

	gamePlaneOperator:showRemainCardsCount()

	XYKWX_MY_USERINFO.seat_id = pack.seat_id
	XYKWX_MY_USERINFO.coins      = pack.gold - USER_INFO["group_chip"]

	--绘制自己的信息
	XYKWX_MY_USERINFO.photoUrl = USER_INFO["icon_url"]
	XYKWX_MY_USERINFO.nick = USER_INFO["nick"]
	XYKWX_MY_USERINFO.coins = pack["gold"] - USER_INFO["group_chip"]
	XYKWX_MY_USERINFO.uid = tonumber(UID)
	XYKWX_MY_USERINFO.sex = USER_INFO["sex"]
	XYKWX_SEAT_TABLE_BY_TYPE[CARD_PLAYERTYPE_MY .. ""] = pack.seat_id
	XYKWX_SEAT_TABLE[tonumber(UID) .. ""] = pack.seat_id
	XYKWX_USERINFO_TABLE[pack.seat_id .. ""] = {}

	XYKWX_USERINFO_TABLE[pack.seat_id .. ""].photoUrl = USER_INFO["icon_url"]
	XYKWX_USERINFO_TABLE[pack.seat_id .. ""].uid = tonumber(UID)
	XYKWX_USERINFO_TABLE[pack.seat_id .. ""].nick = USER_INFO["nick"]
	XYKWX_USERINFO_TABLE[pack.seat_id .. ""].coins = pack["gold"] - USER_INFO["group_chip"]
	XYKWX_USERINFO_TABLE[pack.seat_id .. ""].sex = USER_INFO["sex"]

	local infoPlane = gamePlaneOperator:showPlayerInfo(CARD_PLAYERTYPE_MY, XYKWX_MY_USERINFO)
	local point = cc.p(infoPlane:getAnchorPoint().x * infoPlane:getSize().width, infoPlane:getAnchorPoint().y * infoPlane:getSize().height)

	XYKWX_ROOM.positionTable[tonumber(UID) .. ""] = infoPlane:convertToWorldSpace(point)
	local position = XYKWX_ROOM.positionTable[tonumber(UID) .. ""]
	require("hall.view.voicePlayView.voicePlayView"):updateUserPosition(tonumber(tonumber(UID)),position)

	--绘制其他玩家
	if pack.nPlayerCount > 0  then
		for i,v in pairs(pack.users_info) do
			dump(pack, "player test")
			XYKWXReceiveHandle:showPlayer(v)
		end
	end

	local uid_arr = {}

	for k,v in pairs(XYKWX_USERINFO_TABLE) do
		table.insert(uid_arr, v.uid)
	end

	require("hall.GameSetting"):setPlayerUid(uid_arr)

	voiceUtils:playBackgroundMusic()

	if pack.jiapiaoStatus ~= 2 then
		--todo
		if pack.piao >= 0 then
			--todo
			gamePlaneOperator:showPiaoPlane(CARD_PLAYERTYPE_MY, pack.piao, true)
		end

		for k,v in pairs(pack.users_info) do
			if v.piao >= 0 then
				--todo
				local pt = cardUtils:getPlayerType(v.seat_id)
				gamePlaneOperator:showPiaoPlane(pt, v.piao, true)
			end
		end

		if pack.jiapiaoStatus == 1 then
			--todo
			if pack.piao >= 0 then
				--todo
				gamePlaneOperator:showPiaoImg(CARD_PLAYERTYPE_MY, pack.piao, true)
			else
				gamePlaneOperator:showJiapiaoPlane(true)
			end

			for k,v in pairs(pack.users_info) do
				if v.piao >= 0 then
					--todo
					local pt = cardUtils:getPlayerType(v.seat_id)
					gamePlaneOperator:showPiaoImg(pt, v.piao, true)
				end
			end

			return
		end
	end


	XYKWX_ZHUANG_UID = XYKWX_USERINFO_TABLE[pack.m_nBankSeatId .. ""].uid

	local zhuangPlayerType = cardUtils:getPlayerType(pack.m_nBankSeatId)
	gamePlaneOperator:showZhuang(zhuangPlayerType)

    if require("hall.gameSettings"):getGameMode() == "group" then
		USER_INFO["base_chip"] = XYKWX_ROOM.base;

	else
		SCENENOW["scene"]:gameReady();
	end

	local myCards = pack.handCards

	table.sort(myCards)

	if pack.nPlayerCount > 0  then
		for i,v in pairs(pack.users_info) do
			local gameInfo = {}
			gameInfo.porg = {}
			gameInfo.hand = {}

			gameInfo.out = {}

			XYKWX_GAMEINFO_TABLE[pack.users_info[i].seat_id .. ""] = gameInfo

			if v.countForTing > 0 then
				--todo
				XYKWX_GAMEINFO_TABLE[v.seat_id .. ""].ting = 1
				XYKWX_GAMEINFO_TABLE[v.seat_id .. ""].hand = {}

				for i=1,v.countHandCards do
					table.insert(gameInfo.hand, -1)
				end

				for i=v.countHandCards - v.countForTing + 1,v.countHandCards do
					gameInfo.hand[i] = v.liangCards[i - (v.countHandCards - v.countForTing + 1) + 1]
				end
				XYKWX_GAMEINFO_TABLE[v.seat_id .. ""].anke = v.ankeCards
			else
				XYKWX_GAMEINFO_TABLE[v.seat_id .. ""].ting = 0
				for i=1,pack.users_info[i].countHandCards do
					table.insert(gameInfo.hand, 0)
				end
			end

			local playerType = cardUtils:getPlayerType(pack.users_info[i].seat_id)
			gamePlaneOperator:redrawGameInfo(playerType, pack.users_info[i])
		end
	end

	if pack.gameStatus == 2 then
		if pack.currentPlayerId == tonumber(UID) then
			--todo
			XYKWX_CHUPAI = 1

			local newCard = pack.newCard
			
			for k,v in pairs(myCards) do
				if v == newCard then
					--todo
					table.remove(myCards, k)
					break
				end

				if k == table.getn(myCards) then
					--todo
					newCard = v
					table.remove(myCards, k)
				end
			end
			local myGameInfo = {}
			myGameInfo.porg = {}
			myGameInfo.hand = myCards
			myGameInfo.out = {}

			XYKWX_GAMEINFO_TABLE[XYKWX_MY_USERINFO.seat_id .. ""] = myGameInfo

			if pack.liangStatus > 0 then
				--todo
				XYKWX_GAMEINFO_TABLE[XYKWX_MY_USERINFO.seat_id .. ""].anke = pack.ankeCards
			end

			if pack.nTingFlag == 1 then
			--todo
				XYKWX_GAMEINFO_TABLE[XYKWX_MY_USERINFO.seat_id .. ""].ting = 1
			end

			if pack.liangStatus == 3 then
				XYKWX_GAMEINFO_TABLE[XYKWX_MY_USERINFO.seat_id .. ""].tingHuCards = pack.tingHuCards
				table.sort(pack.liangCards)
				XYKWX_GAMEINFO_TABLE[XYKWX_MY_USERINFO.seat_id .. ""].liangCards = pack.liangCards
			end

			-- 重绘桌面信息
			gamePlaneOperator:redrawGameInfo(CARD_PLAYERTYPE_MY, pack)

			local controlTable = {} 
			controlTable.type = CONTROL_TYPE_NONE
			if pack.liangStatus == 0 and pack.tingCount > 0 then
				--todo
				controlTable.type = CONTROL_TYPE_TING
				-- controlTable.tingSeq = pack.tingCards
				controlTable.gangSeq = pack.lgCards
			
			end

			if pack.liangStatus == 3 then
				--todo
				local hasGrepCard = false
				for k,v in pairs(pack.tingCards) do
					if v.card == newCard then
						--todo
						hasGrepCard = true
					end
				end

				local tCount = pack.tingCount
				if hasGrepCard then
					--todo
					tCount = tCount - 1
				end

				if tCount > 0 then
					--todo
					controlTable.type = CONTROL_TYPE_TING
					controlTable.gangSeq = {}
				end
			end

			if controlTable.type == CONTROL_TYPE_NONE or controlTable.type == CONTROL_TYPE_TING then
				--todo
				XYKWX_CHUPAI = 1
			else
				XYKWX_CHUPAI = 2
			end

			cardUtils:getNewCard(XYKWX_MY_USERINFO.seat_id, newCard)

			gamePlaneOperator:getNewCard(CARD_PLAYERTYPE_MY, newCard)

			gamePlaneOperator:showControlPlane(controlTable)

			if pack.liangStatus == 1 or pack.liangStatus == 2 then
				gamePlaneOperator:showTingCards(pack.tingCards)
			end

		else
			XYKWX_CHUPAI = 0

			local myGameInfo = {}
			myGameInfo.porg = {}
			myGameInfo.hand = myCards
			myGameInfo.out = {}

			XYKWX_GAMEINFO_TABLE[XYKWX_MY_USERINFO.seat_id .. ""] = myGameInfo

			if pack.nTingFlag == 1 then
			--todo
				XYKWX_GAMEINFO_TABLE[XYKWX_MY_USERINFO.seat_id .. ""].ting = 1
				XYKWX_GAMEINFO_TABLE[XYKWX_MY_USERINFO.seat_id .. ""].anke = pack.ankeCards
				XYKWX_GAMEINFO_TABLE[XYKWX_MY_USERINFO.seat_id .. ""].tingHuCards = pack.tingHuCards
				table.sort(pack.liangCards)
				XYKWX_GAMEINFO_TABLE[XYKWX_MY_USERINFO.seat_id .. ""].liangCards = pack.liangCards
			end
			-- 重绘桌面信息
			gamePlaneOperator:redrawGameInfo(CARD_PLAYERTYPE_MY, pack)
		end

		local t_seatId = XYKWX_SEAT_TABLE[pack.currentPlayerId .. ""]
		gamePlaneOperator:beginPlayCard(cardUtils:getPlayerType(t_seatId))
	elseif pack.gameStatus == 3 then
		-- local controlTable = cardUtils:getControlTable(pack.handle, pack.handleCard, 3, pack.ableGangCards)

		local controlTable = {}

		if pack.liangStatus ~= 1 and pack.liangStatus ~= 2 then
			--todo
			controlTable = cardUtils:getControlTable(pack.handle, pack.handleCard, 3, pack.ableGangCards)
		end

		if pack.tingCount > 0 and pack.liangStatus == 0 then
			--todo
			controlTable.type = bit.bor(controlTable.type, CONTROL_TYPE_TING)
			-- controlTable.tingSeq = pack.tingCards
			controlTable.gangSeq = pack.lgCards
		end

			if pack.liangStatus == 3 then
				--todo
				local hasGrepCard = false
				for k,v in pairs(pack.tingCards) do
					if v.card == pack.newCard then
						--todo
						hasGrepCard = true
					end
				end

				local tCount = pack.tingCount
				if hasGrepCard then
					--todo
					tCount = tCount - 1
				end

				if tCount > 0 then
					--todo
					controlTable.type = CONTROL_TYPE_TING
					controlTable.gangSeq = {}
				end
			end

		if controlTable.type == CONTROL_TYPE_NONE or controlTable.type == CONTROL_TYPE_TING then
			--todo
			XYKWX_CHUPAI = 1
		else
			XYKWX_CHUPAI = 2
		end
		
		gamePlaneOperator:showControlPlane(controlTable)

		local newCard = pack.newCard
		local isGrep = false
			
		for k,v in pairs(myCards) do
			if v == newCard then
				--todo
				table.remove(myCards, k)
				isGrep = true
				break
			end
		end

		local myGameInfo = {}
		myGameInfo.porg = {}
		myGameInfo.hand = myCards
		myGameInfo.out = {}

		XYKWX_GAMEINFO_TABLE[XYKWX_MY_USERINFO.seat_id .. ""] = myGameInfo

			if pack.liangStatus > 0 then
				--todo
				XYKWX_GAMEINFO_TABLE[XYKWX_MY_USERINFO.seat_id .. ""].anke = pack.ankeCards
			end

			if pack.nTingFlag == 1 then
			--todo
				XYKWX_GAMEINFO_TABLE[XYKWX_MY_USERINFO.seat_id .. ""].ting = 1
			end

			if pack.liangStatus == 3 then
				XYKWX_GAMEINFO_TABLE[XYKWX_MY_USERINFO.seat_id .. ""].tingHuCards = pack.tingHuCards
				table.sort(pack.liangCards)
				XYKWX_GAMEINFO_TABLE[XYKWX_MY_USERINFO.seat_id .. ""].liangCards = pack.liangCards
			end

		-- if pack.nTingFlag == 1 then
		-- 	--todo
		-- 		XYKWX_GAMEINFO_TABLE[XYKWX_MY_USERINFO.seat_id .. ""].ting = 1
		-- 		XYKWX_GAMEINFO_TABLE[XYKWX_MY_USERINFO.seat_id .. ""].anke = pack.ankeCards
		-- 		XYKWX_GAMEINFO_TABLE[XYKWX_MY_USERINFO.seat_id .. ""].tingHuCards = pack.tingHuCards
		-- 	end
		-- 重绘桌面信息
		gamePlaneOperator:redrawGameInfo(CARD_PLAYERTYPE_MY, pack)

		if isGrep then
			--todo
			cardUtils:getNewCard(XYKWX_MY_USERINFO.seat_id, newCard)

			gamePlaneOperator:getNewCard(CARD_PLAYERTYPE_MY, newCard)
		end

		if pack.currentPlayerId ~= tonumber(UID) then
			--todo
			local playerTypeT = cardUtils:getPlayerType(XYKWX_SEAT_TABLE[pack.currentPlayerId .. ""])

			local removeResult = gamePlaneOperator:removeLatestOutCard(playerTypeT, pack.handleCard)

			if removeResult then
				--todo
				gamePlaneOperator:playCard(playerTypeT, 0, pack.handleCard)
			end
		end

		if pack.liangStatus == 1 or pack.liangStatus == 2 then
			gamePlaneOperator:showTingCards(pack.tingCards)
		end
	else
		local myGameInfo = {}
		myGameInfo.porg = {}
		myGameInfo.hand = myCards
		myGameInfo.out = {}

		XYKWX_GAMEINFO_TABLE[XYKWX_MY_USERINFO.seat_id .. ""] = myGameInfo

		if pack.nTingFlag == 1 then
			--todo
			XYKWX_GAMEINFO_TABLE[XYKWX_MY_USERINFO.seat_id .. ""].ting = 1
			XYKWX_GAMEINFO_TABLE[XYKWX_MY_USERINFO.seat_id .. ""].anke = pack.ankeCards
			XYKWX_GAMEINFO_TABLE[XYKWX_MY_USERINFO.seat_id .. ""].tingHuCards = pack.tingHuCards
		end
		-- 重绘桌面信息
		gamePlaneOperator:redrawGameInfo(CARD_PLAYERTYPE_MY, pack)

		if pack.liangStatus == 1 or pack.liangStatus == 2 then
			gamePlaneOperator:showTingCards(pack.tingCards)
		end
	end

		--发送当前用户地理位置
	-- sendHandle:CLIENT_CMD_FORWARD_MESSAGE("")
end

--显示其他玩家
function XYKWXReceiveHandle:showPlayer(pack)

	local scenes = SCENENOW['scene'] 
	if SCENENOW['name'] ~= run_scene_name then
		return
	end

	--新加入用户的用户信息
	local v = pack
	--保存用户座位与id映射
	XYKWX_SEAT_TABLE[v.uid .. ""] = pack.seat_id
	-- XYKWX_USERINFO_TABLE[pack.seat_id] = pack 

	if not XYKWX_USERINFO_TABLE[pack.seat_id .. ""] then
		--todo
		XYKWX_USERINFO_TABLE[pack.seat_id .. ""] = {}
	end

	XYKWX_USERINFO_TABLE[pack.seat_id .. ""].uid = pack.uid
	
    local playerType = cardUtils:getPlayerType(pack.seat_id)
    XYKWX_SEAT_TABLE_BY_TYPE[playerType .. ""] = pack.seat_id

    dump(XYKWX_SEAT_TABLE_BY_TYPE, "XYKWX_SEAT_TABLE_BY_TYPE test")

    --设置用户已经准备
    -- scenes:show_hasselect(other_index, true)
    dump(pack, "获取用户信息")
    --获取用户信息
    local info = json.decode(pack.user_info)

    local nick_name 
    local user_gold
    local icon_url
    local sex_num
    if not info then
    	nick_name = pack.nick
    	user_gold = pack.user_gold - USER_INFO["group_chip"]
    	icon_url = pack.icon_url
    	sex_num = pack.sex

    else
    	nick_name = pack.nick or info.nickName 
    	user_gold = pack.user_gold or info.money
    	user_gold = user_gold - USER_INFO["group_chip"]
    	icon_url = pack.icon_url or pack.smallHeadPhoto or info.photoUrl 
    	sex_num = pack.sex or info.sex

    end

    dump(info, "info test")
    dump(sex_num, "sex_num test")

    XYKWX_USERINFO_TABLE[pack.seat_id .. ""].nick = nick_name
    XYKWX_USERINFO_TABLE[pack.seat_id .. ""].coins = user_gold 
    XYKWX_USERINFO_TABLE[pack.seat_id .. ""].photoUrl = icon_url
    XYKWX_USERINFO_TABLE[pack.seat_id .. ""].sex = sex_num

    local userInfo = {}
    userInfo["photoUrl"] = icon_url
    userInfo["nick"] = nick_name
    userInfo["coins"] = user_gold
    userInfo["uid"] = pack.uid
    userInfo["sex"] = sex_num

   	-- scenes:show_otherplayer_info(other_index,icon_url,nick_name,user_gold,sex_num,v.uid)

   	dump(playerType, "playerType test 11")
   	local infoPlane = gamePlaneOperator:showPlayerInfo(playerType, userInfo)
   	local point = cc.p(infoPlane:getAnchorPoint().x * infoPlane:getSize().width, infoPlane:getAnchorPoint().y * infoPlane:getSize().height)

   	XYKWX_ROOM.positionTable[pack.uid .. ""] = infoPlane:convertToWorldSpace(point)
   	local position = XYKWX_ROOM.positionTable[pack.uid .. ""]
	require("hall.view.voicePlayView.voicePlayView"):updateUserPosition(tonumber(pack.uid),position)
end

--用户退出房间
function XYKWXReceiveHandle:SVR_QUIT_ROOM(pack)

	dump(pack,"-----用户退出房间-----")

	if SCENENOW['name'] ~= run_scene_name then
		return
	end

	local uid = pack.uid
	local seatId = XYKWX_SEAT_TABLE[uid .. ""]

	if not seatId then
		--todo
		return
	end

	table.remove(XYKWX_SEAT_TABLE, uid .. "")
	table.remove(XYKWX_USERINFO_TABLE, seatId .. "")
	table.remove(XYKWX_GAMEINFO_TABLE, seatId .. "")

	local playerType = cardUtils:getPlayerType(seatId)
	table.remove(XYKWX_SEAT_TABLE_BY_TYPE, playerType .. "")

	if XYKWX_GAME_STATUS == 0 then
		--todo
		gamePlaneOperator:removePlayer(playerType)
	else
		gamePlaneOperator:showNetworkImg(playerType, true)
	end
	

	local uid_arr = {}

	for k,v in pairs(XYKWX_USERINFO_TABLE) do
		table.insert(uid_arr, v.uid)
	end

	require("hall.GameSetting"):setPlayerUid(uid_arr)
end

--用户退出游戏成功
function XYKWXReceiveHandle:SVR_QUICK_SUC(pack)

	dump(pack,"-----玩家退出游戏成功-----")
	audio.stopMusic(true)

    if bm.notCheckReload and bm.notCheckReload == 1 then
        require("hall.GameTips"):enterHall()
    end
	-- local mode = require("hall.gameSettings"):getGameMode()
	-- print("SVR_QUICK_SUC mode",tostring(mode))
	-- -- if bm.isGroup then
 --    if mode == "group" then
	-- 	--todo
	-- 	print("gExitGroupGame getGroupState",require("majiang.ddzSettings"):getGroupState())
	-- 	if require("majiang.ddzSettings"):getGroupState() == 2 then
	-- 		require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])
	-- 	else
 --        	require("majiang.ddzSettings"):setEndGroup(2)
	-- 		require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])
	-- 	end

	-- else
	-- 	--bm.display_scenes("majiang.gameScenes")
	-- 	if mode == "free" then
	-- 		display_scene("majiang.MJselectChip",1)
	-- 	elseif mode == "fast" then
	-- 		require("app.HallUpdate"):enterHall()
	-- 	end
	-- end
	
end

----------------------------------------------------------------------------------------------------------------

--用户准备相关
--广播用户准备
function XYKWXReceiveHandle:SVR_USER_READY_BROADCAST(pack)
	--print("json:"..json.encode(pack))

	print("用户准备测试:" .. pack.uid)

	local scenes = SCENENOW['scene'] 

	if SCENENOW['name'] ~= run_scene_name then
		return
	end

	if pack.uid == UID then
		scenes.reay_my:setVisible(true)
	else
		local index = self:getSeatIndex(pack.uid)
		if index == 1 then
			scenes.reay_right:setVisible(true)
		else
			scenes.reay_left:setVisible(true)
		end
	end

end

--显示其他玩家准备
function XYKWXReceiveHandle:showOtherReady(index)

	local scenes         = SCENENOW['scene']
	scenes:show_ready_bar(index,false)

end
----------------------------------------------------------------------------------------------------------------

--用户操作相关
--服务器告知客户端可以进行的操作
function XYKWXReceiveHandle:SVR_NORMAL_OPERATE(pack)

	dump(pack, "-----服务器告知客户端可以进行的操作-----");

	if pack.isLiang > 0 then
		--todo
		if pack.tingCount > 0 then
			--todo
			XYKWX_CONTROLLER:showTingCards(pack.tingCards)
		else
			require("hall.GameCommon"):showAlert(true, "提示：该亮杠操作导致无牌可听，请重新亮杠", 300)

			XYKWX_CONTROLLER:showLgSelectBox(pack.lgCards)
		end
		
		return
	end

	local controlTable = cardUtils:getControlTable(pack.handle, pack.card, 1)

	gamePlaneOperator:showControlPlane(controlTable)
end

--显示可以操作的界面
function XYKWXReceiveHandle:showHandlesView(handle,card)	

	dump(handle,"-----显示可以操作的界面-----")
	dump(card,"-----显示可以操作的界面-----")

	--获取界面
	local scenes = SCENENOW['scene']
	if SCENENOW['name'] ~= run_scene_name then
		return
	end

	local result = MajiangcardHandle:getHandles(handle)
	local start = 420
	local has   = 1
	local width = 200

	local node = scenes:getChildByName("myhandles")
	if node then
		node:removeSelf()
	end

	node = display.newNode()
	node:addTo(scenes,9000)
	node:setName("myhandles")
	node:setLocalZOrder(9000)

	--胡
	if result['h'] then
		has   = 0
		local path_other_hu = CARD_PATH_MANAGER:get_card_path("path_other_hu")
		local hu = display.newSprite(path_other_hu)
		hu:addTo(node)
		hu:pos(start,200)
		start = start + 133
		bm.nodeClickHandler(hu,MajiangroomServer.requestHandle,result['h'],card)
	end

	--碰和杠
	local ifpg = 0
	if result['pg'] then
		ifpg = 1
		has = 0
		local path_other_gang = CARD_PATH_MANAGER:get_card_path("path_other_gang")
		local g       = display.newSprite(path_other_gang)
		g:addTo(node)
		g:pos(start,200)
		bm.nodeClickHandler(g,MajiangroomServer.requestHandle,result['pg'],card)

		start         = start + 133
		local path_other_peng = CARD_PATH_MANAGER:get_card_path("path_other_peng")
		local p       = display.newSprite(path_other_peng)
		p:addTo(node)
		p:pos(start,200)

		bm.nodeClickHandler(p,MajiangroomServer.requestHandle,0x008,card)
		start = start + 133
	end

	--碰
	if result['p'] and ifpg == 0 then
		has = 0
		local path_other_peng = CARD_PATH_MANAGER:get_card_path("path_other_peng")
		local p       = display.newSprite(path_other_peng)
		p:addTo(node)
		p:pos(start,200)
		start         = start + 133
		bm.nodeClickHandler(p,MajiangroomServer.requestHandle,result['p'],card)
	end

	--杠
	if result['g'] and ifpg == 0 then
		has   = 0
		local path_other_gang = CARD_PATH_MANAGER:get_card_path("path_other_gang")
		local p       = display.newSprite(path_other_gang)
		p:pos(start,200)
		p:addTo(node)
		start         = start + 133

		--下面这几行是添加碰了的时候，我手上还有这个一个牌可以杆下的话，那么
		local find_flag =  false
		dump(XYKWX_ROOM.Card[0]['porg'],"porg")

		local gang = {}
		for i,v in pairs(XYKWX_ROOM.Card[0]['porg']) do
			if gang[v] == nil then 
				gang[v]=  1
			else
				gang[v]= gang[v] + 1
			end

			if v == card then
				find_flag = true-----摸到的牌是要杆的牌
			end
		end

		local hand_gang = {}
		for i,v in pairs(XYKWX_ROOM.Card[0]['hand']) do
			if hand_gang[v] == nil then 
				hand_gang[v]=  1
			else
				hand_gang[v]= hand_gang[v] + 1
			end
		end

		local hand_gang_one = false 
		if find_flag == false then -----手牌就是要杆的牌
			dump(XYKWX_ROOM.Card[0]['hand'],"hand")
			for i,v in pairs(XYKWX_ROOM.Card[0]['hand']) do
				if gang[v] ~= nil and gang[v] == 3  then
					card = v;
					hand_gang_one = true
					break
				end
			end
		end

		if hand_gang_one  == false and find_flag == false then
			for i,v in pairs(XYKWX_ROOM.Card[0]['hand']) do-----手牌就有四张要杆的牌
				if hand_gang[v] ~= nil and hand_gang[v] == 4  then
					card = v;
					break
				end
			end
		end
 
		bm.nodeClickHandler(p,MajiangroomServer.requestHandle,result['g'],card)
	end

	if has == 0 then
		local guo       = display.newSprite("majiang/image/quan_guo.png")
		guo:pos(start,200)
		guo:addTo(node)

		guo:setTouchEnabled(true)
        guo:addNodeEventListener(cc.NODE_TOUCH_EVENT,function ( event )
                if event.name == "began" then
                	bm.guo_card =card 
                    require("hall.GameCommon"):playEffectSound(audio_path,false)
                    MajiangroomServer:requestHandle(0,card)
					local scenes = SCENENOW['scene']
                	local  node  = scenes:getChildByName("myhandles")
					if node then
						node:removeSelf()
					end	

					return true
                end
        end)
	end

end

--广播用户进行了什么操作
function XYKWXReceiveHandle:SVR_PLAYER_USER_BROADCAST(pack)
	
	dump(pack,"-----广播用户进行了什么操作-----")

	local scenes          = SCENENOW['scene']
	if SCENENOW["name"] ~= run_scene_name then
		return
	end

	local handle = pack.handle
	local value = bit.band(pack.card, 0xFF)

	local seatId = XYKWX_SEAT_TABLE[pack.uid .. ""]

	local playerType = cardUtils:getPlayerType(seatId)

	if bit.band(handle, TING_TYPE_T) > 0 then
		table.sort(pack.liangCards)

		XYKWX_GAMEINFO_TABLE[seatId .. ""].ting = 1
		
		if playerType ~= CARD_PLAYERTYPE_MY then
			--todo
			XYKWX_GAMEINFO_TABLE[seatId .. ""].hand = {}
			for i=1,pack.totalCount do
				table.insert(XYKWX_GAMEINFO_TABLE[seatId .. ""].hand, 0)
			end

			for i=pack.totalCount - pack.liangCount + 1,pack.totalCount do
				XYKWX_GAMEINFO_TABLE[seatId .. ""].hand[i] = pack.liangCards[i - (pack.totalCount - pack.liangCount + 1) + 1]
			end
		end
		
		XYKWX_GAMEINFO_TABLE[seatId .. ""].liangCards = pack.liangCards
		XYKWX_GAMEINFO_TABLE[seatId .. ""].anke = pack.lgCards

		gamePlaneOperator:showTingHuPlane(playerType, pack.tingHuCards)		
	end

	local progCards = cardUtils:processControl(seatId, handle, value)

	gamePlaneOperator:control(playerType, progCards, handle)

	voiceUtils:playControlSound(seatId, handle)

	if playerType == CARD_PLAYERTYPE_MY then
		--todo
		if pack.tingCount > 0 then
			--todo
			local controlTable = {}
			controlTable.type = CONTROL_TYPE_TING
			controlTable.value = 0
			controlTable.tingSeq = pack.tingCards
			controlTable.gangSeq = pack.lgCards

			gamePlaneOperator:showControlPlane(controlTable)

			-- XYKWX_CHUPAI = 2
			XYKWX_CHUPAI = 1
		else
			XYKWX_CHUPAI = 1
		end
	end
end

--这里专门用来显示你看到的其他玩家（1，2，3）的碰杠动画显示
function XYKWXReceiveHandle:pengHuGangAnim(uid,result)

	dump(uid,"-----显示你看到的其他玩家（1，2，3）的碰杠动画显示-----")
	dump(result,"-----显示你看到的其他玩家（1，2，3）的碰杠动画显示-----")

	local scenes = SCENENOW['scene']
	local index  = self:getIndex(uid)

	local config = {[1] = {['x'] = 300,['y'] = 300},
					[2] = {['x'] = 500,['y'] = 450},
					[3] = {['x'] = 750,['y'] = 300}
	}

	local  node  = scenes:getChildByName("pghuamin")

	if node then
		node:removeSelf()
	end

	node = display.newNode()
	node:addTo(scenes)
	node:setName("pghuamin")
	node:setLocalZOrder(2000)

	local object = nil

	if result['g'] or result['pg'] then
		local path_other_gang = CARD_PATH_MANAGER:get_card_path("path_other_gang")
		local object       = display.newSprite(path_other_gang)
		object:pos(config[index]['x'],config[index]['y'])
		object:addTo(node)
	end

	if result['p']then
		local path_other_peng = CARD_PATH_MANAGER:get_card_path("path_other_peng")
		local object       = display.newSprite(path_other_peng)
		object:pos(config[index]['x'],config[index]['y'])
		object:addTo(node)
	end

	if result['h']then
		local path_other_hu = CARD_PATH_MANAGER:get_card_path("path_other_hu")
		local object      = display.newSprite(path_other_hu)
		object:pos(config[index]['x'],config[index]['y'])
		object:addTo(node)
	end

	bm.SchedulerPool:delayCall(function ()
		if tolua.isnull(SCENENOW['scene'])==true then
			--todo
			return;
		end
		local n=SCENENOW['scene']:getChildByName("pghuamin")
		if n then
			--todo
			n:removeSelf()
		end
		
	end,1)

end

--显示上次动作
function XYKWXReceiveHandle:showLastEvent()

	dump("","-----显示上次动作-----")

	local scenes    = SCENENOW['scene']
	if XYKWX_ROOM.last == "chupai" then
		local chu       = scenes:getChildByName("chu")
		if chu then
			local fade = cc.FadeOut:create(0.5)
			chu:runAction(fade)
		end
		
		MajiangcardHandle:insertCardTo(XYKWX_ROOM.Card[XYKWX_ROOM.index]['out'],{XYKWX_ROOM.card_value})
		bm.SchedulerPool:delayCall(XYKWXReceiveHandle.drawOut,0.5,XYKWX_ROOM.index)
		-- self:sendOtherPlayerCard(XYKWX_ROOM.index)
		bm.SchedulerPool:delayCall(function()
			if tolua.isnull(scenes) == false then
				local chu       = scenes:getChildByName("chu")
				if chu then
					chu:removeSelf()
				end
			end
		end,0.5)
		
	end

	if  XYKWX_ROOM.last == "otherhand"  then

		local chu       = scenes:getChildByName("chu")
		if chu then
			chu:removeSelf()
		end

	end

end
---------------------------------------------------------------------------------------------------------------

--托管相关
--广播用户托管
function XYKWXReceiveHandle:SVR_ROBOT(pack)

	dump(pack,"-----广播用户托管-----")

	local scenes = SCENENOW['scene']
	if SCENENOW["name"] ~= run_scene_name then
		return
	end

	if pack.uid == UID then
		local scenes  = SCENENOW['scene']
		if  pack.kind  == 1 then
			XYKWX_ROOM.tuoguan_ing = 1
			-- scenes:show_tuoguan_layout(true)
		else
			XYKWX_ROOM.tuoguan_ing = 0
			-- scenes:show_tuoguan_layout(false)
		end
	end

end
-------------------------------------------------------------------------------------------------------------------

--发牌相关
--发牌协议
function XYKWXReceiveHandle:SVR_SEND_USER_CARD(pack)

	dump(pack, "-----发牌协议-----")

	local scenes  = SCENENOW['scene']
	if SCENENOW['name'] ~= run_scene_name then
		return
	end	

	gamePlaneOperator:clearGameDatas()
	
	XYKWX_ROOM.isBufenLiang = pack.isBufenLiang

	gamePlaneOperator:clearPiaoImg()

	XYKWX_GAME_STATUS = 1

	scenes:hideCloseRoomButton()
	scenes:ShowSettingButton()
	scenes:hideShareButton()

	gamePlaneOperator:showCenterPlane()

	-- if table.getn(XYKWX_SEAT_TABLE_BY_TYPE) < 4 then
	-- 	--todo
	-- 	return
	-- end

	bm.palying = true
	bm.isRun=true

	XYKWX_ENDING_DATA = nil

	--记录庄家的座位
	bm.zuan_seat = pack.seat
	
	-- if bm.isGroup then
    if require("hall.gameSettings"):getGameMode() == "group" then
        --todo
        XYKWX_STATE = 2
    end
	--scenes:set_basescole_txt_visible(false)

	--隐藏解散房间按钮
	-- scenes:hidendisband()

	--隐藏用户准备标志
	-- scenes:hideAllSelect()

	--显示设置按钮
	-- scenes:ShowSettingButton()

	--开始游戏时需要移动其他玩家的信息显示位置

	--移动自己
	-- scenes:hide_self_info()

	--移动其他用户
	-- scenes:hide_otherplayer_info(1)--false表示隐藏
	-- scenes:hide_otherplayer_info(2)--false表示隐藏
	-- scenes:hide_otherplayer_info(3)--false表示隐藏

	--骰子动画
	-- aniUtils:shuaiZi(pack.shai)

	self:SchedulerSendCard(pack)
	-- bm.SchedulerPool:delayCall(XYKWXReceiveHandle.SchedulerSendCard,2,pack)

end

--发牌
function XYKWXReceiveHandle:SchedulerSendCard(pack)

	XYKWXReceiveHandle:initCardForUser(pack)

	for i=0,2 do
		XYKWXReceiveHandle:showPlayerCards(i)
	end

	--显示庄家
	-- XYKWXReceiveHandle:showZhuang(pack.seat)
	local playerType = cardUtils:getPlayerType(pack.seat)

	XYKWX_ZHUANG_UID = XYKWX_USERINFO_TABLE[pack.seat .. ""].uid

	gamePlaneOperator:showZhuang(playerType)

end

--发牌
-- function XYKWXReceiveHandle:sendCard(pack)

-- 	MajiangcardHandle:setMyCards(pack.cards)
-- 	MajiangcardHandle:sortCards()
-- 	self:showMyHandMajiang()

-- end

--牌库初始化
function XYKWXReceiveHandle:initCardForUser(pack)
	for i=0,2 do
		local gameInfo = {}
		gameInfo.porg = {}
		gameInfo.hand = {0,0,0,0,0,0,0,0,0,0,0,0,0}
		gameInfo.out = {}
		gameInfo.ting = 0
		-- XYKWX_ROOM.Gang[i]         = {}

		XYKWX_GAMEINFO_TABLE[i .. ""] = gameInfo
	end

	local myCards = pack.cards

	table.sort(myCards)

	XYKWX_GAMEINFO_TABLE[XYKWX_MY_USERINFO.seat_id .. ""].hand = myCards	--0号玩家的手牌

	dump(XYKWX_GAMEINFO_TABLE, "cards test ")
end

--显示玩家的牌
function XYKWXReceiveHandle:showPlayerCards( seatId )

	-- XYKWXReceiveHandle:drawHandCard(index)
	-- XYKWXReceiveHandle:drawOut(index)

	local playerType = cardUtils:getPlayerType(seatId)

	dump(XYKWX_GAMEINFO_TABLE, "cards test 11")

	gamePlaneOperator:showCards(playerType)

end

--显示庄家
function XYKWXReceiveHandle:showZhuang(seat)

	local uid = UID

	if seat ~= bm.User.Seat then
		uid = XYKWX_ROOM.seat_uid[seat]
	end

	local index = self:getIndex(uid)
	local scenes = SCENENOW['scene']
	if SCENENOW['name'] ~= run_scene_name then
		return
	end
	
	scenes:show_widget_tip(index,true,"zuan_tip")

end

--显示手牌
function XYKWXReceiveHandle:drawHandCard(index)
	
	--获取界面
	local scenes = SCENENOW['scene']
	if SCENENOW['name'] ~= run_scene_name then
		return
	end

	if index == 0 then

		--自己

		-- XYKWX_ROOM.Card[0]['porg'] = {0x01,0x01,0x01,0x01}
  		-- XYKWX_ROOM.Card[0]['hand'] = {0x11,0x12,0x13,0x14,0x15,0x16,0x02,0x02,0x02}
		-- XYKWX_ROOM.Gang[0][0x01] = 1

		--获取碰的牌
		XYKWX_ROOM.Card[index]['porg'] = MajiangcardHandle:sortCards(XYKWX_ROOM.Card[index]['porg'])

		--获取手牌
		XYKWX_ROOM.Card[index]['hand'] = MajiangcardHandle:sortCards(XYKWX_ROOM.Card[index]['hand'])

		--获取牌的显示区域
		local layer_card = scenes._scene:getChildByName("layer_card")

		--移除用户所有手牌
		local card_node = layer_card:getChildByName("owncard")
		if card_node then
			card_node:removeSelf()
		end

		local card_node = display.newNode()
		card_node:addTo(layer_card)
		card_node:setName("owncard")
		card_node:setLocalZOrder(1150)

		local huase = {	[0] = 0, [1] = 0, [2] = 0,}
		local s_point  = 119.00
		local y_ponit  = 50.00
		local y        = 0
		local pi       = 1
		local count    = 0
		local gang_num = 0
		local width    = 0 
		local my_point = 0
		local an_gang  = 0

		--绘制碰和杠的牌
		for i,v in pairs(XYKWX_ROOM.Card[index]['porg']) do

			local tmp = Majiangcard.new()
			tmp:setCard(v)
			tmp:setMyOutCard()
			tmp:setScale(1.862, 1.521)
			y = y_ponit

			-- my_point = s_point + (pi - 1) * (54 * 0.8 - 6)
			my_point = s_point + (pi - 1) * 54
			if XYKWX_ROOM.Gang[index][v] then

				if XYKWX_ROOM.Gang[index][v] == 1 then
					tmp:setMyBlack()
					-- tmp:setScale(0.8,0.8383)
					-- my_point = s_point+(pi-1)*(54*0.8 - 6)
					my_point = s_point + (pi-1) * 54
				end

				count = count + 1

				if count == 4 then
					tmp:setMyOutCard()
					-- tmp:setScale(0.8,0.8383)
					gang_num = gang_num +1
					-- my_point = s_point+(pi-3)*(54*0.8 - 6)
					my_point = s_point + (pi-3) * 54
					y  = y_ponit + 15
					count = 0
					pi =pi -1
				end

			else
				count = 0
			end

			tmp:pos(my_point, y-10)
			tmp:addTo(card_node)
			
			pi = pi + 1

		end

		--绘制手牌
		--local s_point  = 148.83
		-- local start = (#XYKWX_ROOM.Card[index]['porg'] - gang_num * 4 ) * (54 * 0.8 - 6) + gang_num * 3 * (54 * 0.8 - 6) + s_point
		local start = (#XYKWX_ROOM.Card[index]['porg'] - gang_num * 4 ) * 54 + gang_num * 3 * 54 + s_point
		local pi = 1
		local last_card_pos_x = 0
		for i,v in pairs(XYKWX_ROOM.Card[index]['hand']) do 
			--print("inex:"..i)
			local tmp = Majiangcard.new()
			tmp:setCard(v)
			tmp:setMyHandCard()
			-- tmp:setScale(0.8,0.8383)
			-- tem:setScaleY()
			--tmp:dark()
			-- last_card_pos_x = start+(pi-1)*(54*0.8 - 6)
			last_card_pos_x = start+(pi-1) * 54
			tmp:pos(last_card_pos_x,y_ponit)
			tmp:setName(i)
			tmp:addTo(card_node)
			huase[tmp.cardVariety_] = huase[tmp.cardVariety_] + 1
			pi = pi + 1

		end

		if XYKWX_ROOM.Card[index]['hu'] then
			local tmp = Majiangcard.new()
			tmp:setCard(XYKWX_ROOM.Card[index]['hu'])
			tmp:setMyOutCard()
			tmp:pos(877.03,44.00)--877.03,104.61
			tmp:addTo(card_node)
		end

		local min = nil 
		local se  = nil
		for i,v in pairs(huase) do
			if min == nil then
				min = v
				se  = i
			else
				if min > v then
					min = v
					se  = i
				end
			end
		end
		bm.User.Pque = se

	end
	
	if index == 1 then

		--左边玩家

		local card_node = scenes._scene:getChildByName("layer_card"):getChildByName("othercard"..index)
		if card_node then
			card_node:removeSelf()
		end

		card_node = display.newNode()
		card_node:addTo(scenes._scene:getChildByName("layer_card"))
		card_node:setName("othercard"..index)


		local cout_s_point = 485.00
		local x_ponit = 143.00

		local pi      = 1
		local count    = 0
		local gang_num = 0
		dump(XYKWX_ROOM.Card[index]['porg'])
		dump(XYKWX_ROOM.Gang[index])

		-- XYKWX_ROOM.Card[1]['porg'] = {0x01,0x01,0x01,0x01,0x02,0x02,0x02,0x02,0x03,0x03,0x03,0x03,0x04,0x04,0x04}
  		-- XYKWX_ROOM.Card[1]['hand'] = {1}--{0x01,0x01,0x01}
		-- XYKWX_ROOM.Gang[1][0x01] = 0
		-- XYKWX_ROOM.Gang[1][0x02] = 0
		-- XYKWX_ROOM.Gang[1][0x03] = 0

		--绘制碰和杠的牌
		local last_y_pos = 0
		for i,v in pairs(XYKWX_ROOM.Card[index]['porg']) do
			local tmp = Majiangcard.new()
			tmp:setCard(v)
			tmp:setLeftOutCard()
			-- tmp:setScale(0.54,0.45)
			local my_point = cout_s_point-(pi-1)*(17.72)
			last_y_pos = cout_s_point-(pi-1)*(17.72)
			if XYKWX_ROOM.Gang[index][v] then
				if XYKWX_ROOM.Gang[index][v] == 1 then
					tmp:setLeftBlack()
					tmp:setScale(1)
				end
				count = count + 1
				if count == 4 then
					tmp:setLeftOutCard()
					-- tmp:setScale(0.54,0.45)
					gang_num = gang_num + 1
					my_point =  cout_s_point-(pi-3)*(17.72)
					count = 0
					pi = pi -1
				end
			else
				count = 0
			end  
			tmp:pos(x_ponit,my_point)
			tmp:addTo(card_node)
			pi = pi + 1
		end

		--绘制手牌
		start = cout_s_point
		if last_y_pos ~= 0 then
			start = last_y_pos - 30
		end

		local pi    = 1
		for i,v in pairs(XYKWX_ROOM.Card[index]['hand']) do 
			local tmp = Majiangcard.new()
			if v == 0 then --0标示，这个牌是在打的状态，显示的是背面
				tmp:setLeftHand()
				tmp:pos(x_ponit,start - (pi-1) * 22)
				last_y_pos = start - (pi-1) * 22
			else
				tmp:setCard(v)
				tmp:setLeftOutCard()
				-- tmp:setScale(0.54,0.45)
				tmp:pos(x_ponit,start - (pi-1)*17.72)--手牌自摸
				last_y_pos =start - (pi-1)*17.72
			end
			tmp:addTo(card_node)
			tmp:setName(i)
			pi = pi + 1
		end
		
		if XYKWX_ROOM.Card[index]['hu'] then
			local tmp = Majiangcard.new()
			tmp:setCard(XYKWX_ROOM.Card[index]['hu'])
			tmp:setLeftOutCard()
			-- tmp:setScale(0.54,0.45)
			tmp:pos(x_ponit,last_y_pos - 30)
			tmp:addTo(card_node)
		end

	end

	if index == 2 then

		--对家

		local card_node = scenes._scene:getChildByName("layer_card"):getChildByName("othercard"..index)
		if card_node then
			card_node:removeSelf()
		end

		card_node = display.newNode()
		card_node:addTo(scenes._scene:getChildByName("layer_card"))
		card_node:setName("othercard"..index)

		local s_point = 766.00
		local y_ponit = 497.00
	
		local pi      = 1

		--绘制碰和杠的牌
		local count    = 0
		local gang_num = 0
		local item_width = 30
		local item_heigth = 42

		-- XYKWX_ROOM.Card[2]['porg'] = {0x01,0x01,0x01,0x01,0x02,0x02,0x02,0x02,0x03,0x03,0x03,0x03,0x04,0x04,0x04}
  --  		XYKWX_ROOM.Card[2]['hand'] = {0x01,0x01,0x01}
		-- XYKWX_ROOM.Gang[2][0x01] = 1
		-- XYKWX_ROOM.Gang[2][0x02] = 1
		-- XYKWX_ROOM.Gang[2][0x03] = 1

		dump(XYKWX_ROOM.Card[index]['porg'],"porg_card_index_2")

		local last_posss = 0
		for i,v in pairs(XYKWX_ROOM.Card[index]['porg']) do

			local tmp = Majiangcard.new()
			tmp:setCard(v)
			tmp:setMyOutCard()
			-- tmp:setScale(0.4,0.48)
			-- local my_point = s_point-(pi-1)*(74*0.4 -2)
			local my_point = s_point - (pi-1) * 27
			last_posss = my_point
			local less = 0
			if XYKWX_ROOM.Gang[index][v] then

				if XYKWX_ROOM.Gang[index][v] == 1 then
					tmp:setTopBlack()
				end

				count = count + 1

				if count == 4 then
					tmp:setMyOutCard()
					gang_num = gang_num + 1
					-- my_point =  s_point-(pi-3)*(74*0.4 -2)
					my_point =  s_point - (pi-3) * 27
					count    =  0 
					pi       = pi -1
					less 	 = 10
				end

			else
				count = 0
			end 
			tmp:pos(my_point, y_ponit + less)
			tmp:addTo(card_node)
			pi = pi + 1

		end

		--绘制手牌
		local start = s_point
		if last_posss ~= 0 then
			start = last_posss - 30
		end
		
		local pi = 1
		for i,v in pairs(XYKWX_ROOM.Card[index]['hand']) do 

			local tmp = Majiangcard.new()

			if v == 0 then
				tmp:setTopHandCard()
				tmp:pos(start - (pi-1) * 30, y_ponit)
				last_posss = start - (pi-1) * 30
			else
				tmp:setCard(v)
				tmp:setMyOutCard()
				-- tmp:setScale(0.4,0.48)
				-- tmp:pos(start-(pi-1)*(74*0.4-2),y_ponit)
				tmp:pos(start - (pi-1) * 54, y_ponit)
				-- last_posss = start-(pi-1)*(74*0.4-2)
				last_posss = start - (pi-1) * 54
			end
			
			tmp:addTo(card_node)
			tmp:setName(i)
			pi = pi + 1

		end

		--XYKWX_ROOM.Card[2]['hu'] = 0x02
		if XYKWX_ROOM.Card[index]['hu'] then
			local tmp = Majiangcard.new()
			tmp:setCard(XYKWX_ROOM.Card[index]['hu'])
			tmp:setMyOutCard()
			-- tmp:setScale(0.4,0.48)
			tmp:pos(last_posss - 40, y_ponit)
			tmp:addTo(card_node)
		end

	end

	if index == 3 then

		--右边玩家

		local card_node = scenes._scene:getChildByName("layer_card"):getChildByName("othercard"..index)
		if card_node then
			card_node:removeSelf()
		end

		card_node = display.newNode()
		card_node:addTo(scenes._scene:getChildByName("layer_card"))
		card_node:setName("othercard"..index)


		local hand_width = 23
		local hand_heigth = 56
		local cout_width = 36
		local cout_heigth = 30

		local s_point  = 158.00
		local x_ponit  = 820.00
		local pi       = 1
		local count    = 0
		local gang_num = 0
		local c        = 2000

		-- XYKWX_ROOM.Card[3]['porg'] = {0x01,0x01,0x01,0x01,0x02,0x02,0x02,0x02,0x03,0x03,0x03}
  		-- XYKWX_ROOM.Card[3]['hand'] = {0x01,0x01,0x01,0x01}
		-- XYKWX_ROOM.Gang[3][0x01] = 1
		-- XYKWX_ROOM.Gang[3][0x02] = 1
		-- XYKWX_ROOM.Gang[3][0x03] = 0

		local last_ppos = 0
			--绘制碰和杠的牌
		for i,v in pairs(XYKWX_ROOM.Card[index]['porg']) do
			local tmp = Majiangcard.new()
			tmp:setCard(v)
			tmp:setRightOutCard()
			-- tmp:setScale(0.54,0.45)
			tmp:zorder(c-pi)
			local my_point = s_point+(pi-1) * 17.72
			if XYKWX_ROOM.Gang[index][v] then
				if XYKWX_ROOM.Gang[index][v] == 1 then
					tmp:setLeftBlack()
					tmp:setScale(1)
				end
				count = count + 1
				if count == 4 then
					tmp:setRightOutCard()
					-- tmp:setScale(0.54,0.45)
					gang_num = gang_num +1
					my_point = s_point+(pi-3) * 17.72
					tmp:zorder(c+pi)
					count = 0
					pi = pi - 1
				end
			else
				count = 0
			end  
			tmp:pos(x_ponit,my_point)
			last_ppos = my_point
			tmp:addTo(card_node)
			pi = pi + 1
		end

		--绘制手牌
		if last_ppos ~= 0 then
			s_point     =  last_ppos + 30
		end
		
		local   c   =  1000
		
		local pi    = 1
		local last_y_pos = 0
		for i,v in pairs(XYKWX_ROOM.Card[index]['hand']) do 
			local tmp = Majiangcard.new()
			if v ==  0 then
				tmp:setRightHand()
				last_y_pos = s_point+(pi-1) * 22
				tmp:pos(x_ponit,s_point+(pi-1) * 22)  --手牌
			else
				tmp:setCard(v)
				tmp:setRightOutCard()
				-- tmp:setScale(0.54,0.45)
				tmp:pos(x_ponit,s_point+(pi-1)*17.72)--手牌自摸
				last_y_pos = s_point+(pi-1)*17.72
			end

			tmp:addTo(card_node) 
			tmp:zorder(c-pi)
			tmp:setName(i)
			pi = pi + 1

		end

		--XYKWX_ROOM.Card[index]['hu'] = 0x01
		if XYKWX_ROOM.Card[index]['hu'] then
			local tmp = Majiangcard.new()
			tmp:setCard(XYKWX_ROOM.Card[index]['hu'])
			tmp:setRightOutCard()
			-- tmp:setScale(0.54,0.45)        
			tmp:pos(x_ponit,last_y_pos + 30)
			tmp:addTo(card_node)
		end
	end

end

--绘出玩家已经出的牌
function XYKWXReceiveHandle:drawOut(index)

	if SCENENOW['name'] ~= run_scene_name then
		return
	end

	if tolua.isnull(SCENENOW['scene']) then
		return
	end

	local scenes    = SCENENOW['scene']
	local card_node = scenes:getChildByName("cardout"..index)
	if card_node  then
		card_node:removeSelf()
	end

	card_node = display.newNode():addTo(scenes)
	card_node:setName("cardout"..index)

	--自己
	if index == 0 then
		--XYKWX_ROOM.Card[index]['out'] = {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}
		--绘制已经出的牌
		local item_width = 27.00
		local item_heigth = 31.00

		local x_start = 302.00
		local y_start = 122.00

		local pi      = 1
		local count   = 1
		local all     = 100
		for i,v in pairs(XYKWX_ROOM.Card[index]['out']) do 

			local tmp = Majiangcard.new()
			tmp:setCard(v)
			tmp:setMyOutCard()
			-- tmp:setScale(0.4,0.5)
			tmp:pos( x_start + (pi-1) * item_width, y_start + (count-1) * item_heigth)
			tmp:addTo(card_node,all)
			all = all -1

			pi = pi + 1
			if pi > 11 then
				pi = 1
				count =count +1
			end
		end
	end

	--左边
	if index == 1 then
		local item_width = 36.00
		local item_heigth = 23.00
		local x_start = 191.00
		local y_start = 442.00
		local pi      = 1
		local count   = 1
        --XYKWX_ROOM.Card[index]['out'] = {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}
		for i,v in pairs(XYKWX_ROOM.Card[index]['out']) do 
			local tmp = Majiangcard.new()
			tmp:setCard(v)
			tmp:setLeftOutCard()
			-- tmp:setScale(0.5)
			tmp:pos(x_start + (count-1) * item_width, y_start - (pi-1) * (item_heigth))
			tmp:addTo(card_node)

			pi = pi + 1
			if pi > 12 then
				pi = 1
				count = count + 1
			end
		end
	end

	--对家
	if index == 2 then
		--XYKWX_ROOM.Card[index]['out'] = {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}
		local item_width = 27.00
		local item_heigth = 31.00

		local x_start = 647.00
		local y_start = 448.00
		local pi      = 1
		local count   = 1

		for i,v in pairs(XYKWX_ROOM.Card[index]['out']) do 
			local tmp = Majiangcard.new()
			tmp:setCard(v)
			tmp:setMyOutCard()
			-- tmp:setScale(0.4,0.5)
			tmp:pos(x_start-(pi-1)*item_width,y_start-(count-1)*item_heigth)
			tmp:addTo(card_node)
			pi = pi + 1
			if pi > 11 then
				pi = 1
				count = count +1
			end
		end
	end

	--右边
	if index == 3 then
		--XYKWX_ROOM.Card[index]['out'] = {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}
		local x_start = 774.00
		local y_start = 170.00
		local item_width = 36.00
		local item_heigth = 23.00
		local pi      = 1
		local count   = 1
		local zorder_z = 1000
		for i,v in pairs(XYKWX_ROOM.Card[index]['out']) do 
			local tmp = Majiangcard.new()
			tmp:setCard(v)
			tmp:setRightOutCard()
			-- tmp:setScale(0.5)
			tmp:pos(x_start-(count-1)*item_width,y_start+(pi-1)*(item_heigth))
			tmp:addTo(card_node)
			tmp:zorder(zorder_z-pi)
			pi = pi + 1
			if pi > 12 then
				pi = 1
				count =count +1
			end
		end
	end

end

--重新显示牌
function  XYKWXReceiveHandle:showMyHandMajiang()
	local scenes    = SCENENOW['scene']

	if SCENENOW['name'] ~= run_scene_name then
		return
	end

	local card_node = scenes._scene:getChildByName("layer_card"):getChildByName("owncard")
	if card_node == nil then
		card_node = display.newNode()
		card_node:addTo(scenes._scene:getChildByName("layer_card"))
		card_node:setName("owncard")
	end
	local count = #bm.User.Mycards
	local start = (CONFIG_SCREEN_WIDTH -  count * 82*0.7)/2
	local pi    = 1
	local huase = {
		[0] = 0,
		[1] = 0,
		[2] = 0,
	}

	for i,v in pairs(bm.User.Mycards) do
		local tmp = Majiangcard.new()
		tmp:setCard(v)
		tmp:setScale(0.7)
		tmp:setMyHandCard()
		tmp:dark()
		tmp:addTo(card_node)
		tmp:pos(start+(pi-1) * 82 * 0.7, 60)
		huase[tmp.cardVariety_] = huase[tmp.cardVariety_] + 1
		pi = pi +1
	end

	local min = nil 
	local se  = nil
	for i,v in pairs(huase) do
		if min == nil then
			min = v
			se  = i
		else
			if min > v then
				min = v
				se  = i
			end
		end
	end
	bm.User.Pque = se

end
----------------------------------------------------------------------------------------------------------------

--换牌相关
--服务器告诉客户端，可以换牌
function XYKWXReceiveHandle:SERVER_COMMAND_NEED_CHANGE_CARD(pack)

	dump(pack, "-----可以换牌-----")

	local scenes = SCENENOW['scene'] 

	if SCENENOW['name'] ~= run_scene_name then
		return
	end

	XYKWX_ROOM.change_card_over = false
	dump(pack, "SERVER_COMMAND_NEED_CHANGE_CARD")
	XYKWX_ROOM.cardHuan={};
	bm.huanCardsStart = true

	scenes:show_Text_18(true)

	local txtTimer = display.newBMFontLabel({
	    text = 10,
	    font = "majiang/image/num2.fnt",
	})
	scenes._scene:getChildByName("layer_card"):addChild(txtTimer, 100000)
	txtTimer:setPositionX(487)
	txtTimer:setPositionY(185)

	--换牌倒计时
	local timer = 10 
	local ac = cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function()
			timer=timer-1
			txtTimer:setString(timer)
			if timer==0 then

				txtTimer:stopAllActions();
				txtTimer:removeFromParent();

				scenes:show_Text_18(false)

			end
		end)))
	txtTimer:runAction(ac)

end

--服务器广播换牌的结果
function XYKWXReceiveHandle:SERVER_COMMAND_CHANGE_CARD_RESULT(pack)

	dump(pack, "-----服务器广播换牌的结果-----")

	local scenes  = SCENENOW['scene']

	if SCENENOW['name'] ~= run_scene_name then
		return
	end
	
	scenes:show_Text_18(false)

	XYKWX_ROOM.change_card_over = true
	--XYKWX_ROOM.cardHuan = XYKWX_ROOM.cardHuan or {} -- 可能存在没有换的状况

	local old_hand_card = XYKWX_ROOM.Card[0]['hand']
	dump(old_hand_card,"old_hand_card") 
	if pack.mount > 0 then
		--0号玩家的手牌
		XYKWX_ROOM.Card[0]['hand'] = pack.cards	
		self:drawHandCard(0)
	end

	dump(XYKWX_ROOM.Card[0]['hand'],"-----当前用户换牌后的新手牌-----") 

	XYKWX_ROOM.Card[0]['hand'] = MajiangcardHandle:sortCards(XYKWX_ROOM.Card[0]['hand'])

	local gang_num  = 0
	local scenes = SCENENOW['scene']
	local card_node = scenes._scene:getChildByName("layer_card"):getChildByName("owncard")
	if card_node  then card_node:removeSelf() end
	card_node = display.newNode()
	card_node:addTo(scenes._scene:getChildByName("layer_card"))
	card_node:setName("owncard")
	card_node:setLocalZOrder(50)

	local s_point  = 119.00
	local y_ponit  = 44.00

	local start = 119.00
	local pi    = 1

	local time_index  = 1
	for i,v in pairs(XYKWX_ROOM.Card[0]['hand']) do 

		local tmp = Majiangcard.new()
		tmp:setCard(v)
		tmp:setMyHandCard()
		-- tmp:setScale(0.8,0.8383)
		-- tmp:dark()
		local find_index = table.indexof(old_hand_card,v)
		if find_index == false then
			-- tmp:pos(start+(pi-1)*(74*0.8 - 6),y_ponit + 40)
			tmp:pos(start + (pi-1) * 54, y_ponit + 40)
			tmp:moveBy(1, 0, -40)
		else
			table.remove(old_hand_card,find_index)
			-- tmp:pos(start+(pi-1)*(74*0.8 - 6),y_ponit)
			tmp:pos(start+(pi-1) * 54, y_ponit)
		end

		tmp:setName(i)
		tmp:addTo(card_node)
		--huase[tmp.cardVariety_] = huase[tmp.cardVariety_] + 1
		pi = pi + 1

	end

	SCENENOW['scene']._scene:getChildByName("Button_11"):hide()
	SCENENOW['scene']._scene:getChildByName("Button_11_0"):hide()

	bm.huanCardsStart = false;

end
----------------------------------------------------------------------------------------------------------------------------------

--选缺相关
--开始选择缺门
function  XYKWXReceiveHandle:SVR_START_QUE_CHOICE(pack)

	dump(pack,"-----开始选择缺门-----")

	local scenes  = SCENENOW['scene']


	if SCENENOW['name'] ~= run_scene_name then
		return
	end

	scenes:show_other_xuanqueing(true)
	scenes:show_choosing_que(true)
	
end

--广播缺一门  通知用户选缺选了哪一门,这时游戏还没有开始，
function XYKWXReceiveHandle:SVR_BROADCAST_QUE(pack)

	dump(pack,"-----广播缺一门-----")


	bm.User.Que = nil
	XYKWX_ROOM.Que = true

	for i,v in pairs(pack.content) do
		self:hasChoiceQue(v.uid,v.que)
	end

end

--设置已经选缺
function XYKWXReceiveHandle:hasChoiceQue(uid,que)

	dump(uid,"-----设置已经选缺-----")

	local scenes  = SCENENOW['scene']
	if SCENENOW['name'] ~= run_scene_name then
		return
	end

	if uid == UID then
		print("uid------------------que",que)
		bm.User.Que = que
	end

	local index  = self:getIndex(uid)
	local str = CARD_PATH_MANAGER:get_que_tip(que)
	scenes:show_widget_tip(index,true,"que_tip",str,cc.rect(0,0,36,36),1.0)
	
	scenes:show_other_xuanqueing_index(index,false)

	--que是0，1,2万筒条

	scenes:show_hasselect(index,true)
	if scenes:check_all_select() == true then
		scenes:showwaitingotherchoose(false)

		scenes:show_hasselect(0,false)  --隐藏所有的已选“筒”，“条”
		scenes:show_hasselect(1,false)
		scenes:show_hasselect(2,false)
		scenes:show_hasselect(3,false)
	end

	scenes:hideAllSelect()

end
----------------------------------------------------------------------------------------------------------------

--抓牌相关
--广播抓牌用户
function XYKWXReceiveHandle:SVR_PLAYING_UID_BROADCAST(pack)
	
	dump(pack,"-----广播抓牌用户-----")

	local scenes  = SCENENOW['scene']
	if SCENENOW['name'] ~= run_scene_name then
		return
	end

	-- self:showLastEvent()
	-- XYKWXReceiveHandle:showTimer(pack.uid,8)
	-- local index = self:getIndex(pack.uid)
	-- self:zhuaMajiang(index)
	-- if XYKWX_ROOM.Card and XYKWX_ROOM.Card[index] then
	-- 	--todo
	-- 	MajiangcardHandle:insertCardTo(XYKWX_ROOM.Card[index]['hand'],{0})	
	-- end

	-- --设置剩余的牌数
	-- --scenes:set_left_card_num_visible(true)
	-- scenes:set_left_card_num(tostring(pack.simplNum))

	local playerType = cardUtils:getPlayerType(XYKWX_SEAT_TABLE[pack.uid .. ""])
	local seatId = XYKWX_SEAT_TABLE[pack.uid .. ""]

	if playerType ~= CARD_PLAYERTYPE_MY then
		--todo
		-- cardUtils:getNewCard(seatId, pack.card)
		cardUtils:getNewCard(seatId, 0)

		gamePlaneOperator:getNewCard(playerType, pack.card)
	end

	XYKWX_REMAIN_CARDS_COUNT = pack.simplNum
	gamePlaneOperator:showRemainCardsCount()
end

--通知我抓的牌
function XYKWXReceiveHandle:SVR_OWN_CATCH_BROADCAST(pack)

	dump(pack,"-----通知我抓的牌-----")

	local scenes = SCENENOW['scene']

	if SCENENOW['name'] ~= run_scene_name then
		return
	end

	XYKWX_REMAIN_CARDS_COUNT = XYKWX_REMAIN_CARDS_COUNT - 1
	gamePlaneOperator:showRemainCardsCount()

	local value = bit.band(pack.card, 0xFF)

	cardUtils:getNewCard(XYKWX_MY_USERINFO.seat_id, value)

	gamePlaneOperator:getNewCard(CARD_PLAYERTYPE_MY, value)

	local controlTable = cardUtils:getControlTable(pack.handle, pack.card, 2, pack.cards)

	if pack.tingCount > 0 then
		--todo
		controlTable.type = bit.bor(controlTable.type, CONTROL_TYPE_TING)
		controlTable.tingSeq = pack.tingCards
		controlTable.gangSeq = pack.lgCards
	end

	if controlTable.type == CONTROL_TYPE_NONE or controlTable.type == CONTROL_TYPE_TING then
		--todo
		XYKWX_CHUPAI = 1
	else
		XYKWX_CHUPAI = 2
	end

	gamePlaneOperator:showControlPlane(controlTable)

end

--显示其他人抓牌
function XYKWXReceiveHandle:zhuaMajiang(index)

	dump(index,"-----显示其他人抓牌-----")

	local scenes  = SCENENOW['scene']
	--local  index =  self:getIndex(uid)

	if SCENENOW['name'] ~= run_scene_name then
		return
	end

	if index == 1 then
		local card_node = scenes._scene:getChildByName("layer_card"):getChildByName("othercard"..index)
		if card_node == nil then
			card_node = display.newNode()
			card_node:addTo(scenes._scene:getChildByName("layer_card"))
			card_node:setName("othercard"..index)
		end

		local tmp = Majiangcard.new()
		tmp:setLeftHand()
		tmp:pos(124.00, 195.00)
		tmp:addTo(card_node)
		tmp:setName("zhua")

	end

	if index == 2 then
		local card_node = scenes._scene:getChildByName("layer_card"):getChildByName("othercard"..index)
		if card_node == nil then
			card_node = display.newNode()
			card_node:addTo(scenes._scene:getChildByName("layer_card"))
			card_node:setName("othercard"..index)
		end

		local tmp     =  Majiangcard.new()
		tmp:setTopHandCard()
		tmp:pos(373.00, 505.00)
		tmp:setName("zhua")
		tmp:addTo(card_node)	
	end

	if index == 3 then
		local card_node = scenes._scene:getChildByName("layer_card"):getChildByName("othercard"..index)
		if card_node == nil then
			card_node = display.newNode()
			card_node:addTo(scenes._scene:getChildByName("layer_card"))
			card_node:setName("othercard"..index)
		end
		
		local tmp = Majiangcard.new()
		tmp:setRightHand()
		tmp:pos(839.00, 485.00)
		tmp:setName("zhua")
		tmp:addTo(card_node)
	
	end

end
---------------------------------------------------------------------------------------------------------------

--出牌相关
--显示我的牌哪些可以出，去掉暗化
function XYKWXReceiveHandle:anyCanOut(node)

	dump(node,"-----显示我的牌哪些可以出，去掉暗化-----")

	local scenes    = SCENENOW['scene']
	if SCENENOW['name'] ~= run_scene_name then
		return
	end

	local que_num = 0 
	for i,v in pairs(XYKWX_ROOM.Card[0]['hand']) do
		local huase     = Majiangcard:getVariety(v)
		if huase == bm.User.Que then
			que_num = que_num + 1
		end
	end

	print("que_num==================",que_num)
	dump(XYKWX_ROOM.Card[0]['hand'])
	if que_num ~= 0 then
		for i,v in pairs(XYKWX_ROOM.Card[0]['hand']) do
			local huase     = Majiangcard:getVariety(v)
			local card_node = scenes._scene:getChildByName("layer_card"):getChildByName("owncard")
			local card_tmp = card_node:getChildByName(i) 
			if huase == bm.User.Que then
				if card_tmp then 
					card_tmp:setMyHandCard()
				end
			else
				if card_tmp then card_tmp:dark() end
			end
		end

		if node  then
			--todo
			if node.cardVariety_ ~= bm.User.Que then
				node:dark()
			end
		end
		
	end

end

--从手中出牌
function XYKWXReceiveHandle:canoutFromHand()

	dump("","-----从手中出牌-----")

	local scenes    = SCENENOW['scene']
	if SCENENOW['name']~= run_scene_name then
		return
	end

	local count = 0
	for i,v in pairs(XYKWX_ROOM.Card[0]['hand']) do
			local huase     = Majiangcard:getVariety(v)
			local card_node = scenes._scene:getChildByName("layer_card"):getChildByName("owncard")
			if huase == bm.User.Que then
				local card_tmp = card_node:getChildByName(i) 
				card_tmp:setMyHandCard()
				count = count +1
			end
	end

	if count == 0 then
		for i,v in pairs(XYKWX_ROOM.Card[0]['hand']) do
				
				local card_node = scenes._scene:getChildByName("layer_card"):getChildByName("owncard")
				local card_tmp = card_node:getChildByName(i) 
				card_tmp:setMyHandCard()
				
		end
	end

end 

--广播用户出牌
function XYKWXReceiveHandle:SVR_SEND_MAJIANG_BROADCAST(pack)
	
	dump(pack,"-----广播用户出牌-----")
	
	local scenes    = SCENENOW['scene']
	if SCENENOW['name'] ~= run_scene_name then
		return
	end

	local value = bit.band(pack.card, 0xFF)

	local handleResult = cardUtils:getControlTable(pack.handle, value, 1)

	if pack.uid ~= tonumber(UID) then
		--todo
		gamePlaneOperator:showControlPlane(handleResult)
	else
		XYKWX_CHUPAI = 0
		controlPlaneOperator:Lgsetvisible()  --出牌时 隐藏亮杠 屏蔽亮杠功能
	end

	local seatId = XYKWX_SEAT_TABLE[pack.uid .. ""]
	local playerType = cardUtils:getPlayerType(seatId)

	local tag = cardUtils:playCard(seatId, value)
	gamePlaneOperator:playCard(playerType, tag, value)

	
	-- self:showHandlesView(pack.handle,pack.card)

	-- local index     = self:getIndex(pack.uid)
	-- local card_node = scenes._scene:getChildByName("layer_card"):getChildByName("othercard"..index)
	-- local result    = MajiangcardHandle:getHandles(pack.handle)

	-- local zhua      = scenes._scene:getChildByName("layer_card"):getChildByName("zhua")
	-- if zhua then  zhua:removeSelf() end
		
	-- if index == 0 then
	-- 	MajiangcardHandle:removeCardValue(XYKWX_ROOM.Card[index]['hand'],pack.card,1,index)		
	-- else
	-- 	MajiangcardHandle:removeCardValue(XYKWX_ROOM.Card[index]['hand'],0,1,index)
	-- end

 --     --这里表示的是牌从哪个位置开始打出来
	-- local config = {[0]={['x'] = 430,['y'] = 200,},
	-- 				[1]={['x'] = 200,['y'] = 350,},
	-- 				[2]={['x'] = 430,['y'] = 500,},
	-- 				[3]={['x'] = 750,['y'] = 350,},}

	-- local tmp = Majiangcard.new()
	-- tmp:setCard(pack.card)
	-- tmp:setMyOutCard()
	-- tmp:setScale(1)
	-- tmp:addTo(scenes)
	-- tmp:setName("chu")
	-- tmp:zorder(1500)
	-- tmp:pos(config[index]['x'],config[index]['y'])


	-- XYKWX_ROOM.last       = "chupai" --上次的动作
	-- XYKWX_ROOM.index      = index --上次的序号
	-- XYKWX_ROOM.card_value = pack.card --上次的牌

	-- self:drawHandCard(index)

	voiceUtils:playCardSound(seatId,pack.card)

end
---------------------------------------------------------------------------------------------------------------

--游戏广播相关
--广播结束游戏 没用
function XYKWXReceiveHandle:SVR_GAME_OVER(pack)

	dump(pack, "-----广播结束游戏 没用-----");
	require("hall.recordUtils.RecordUtils"):closeRecordFrame()
	XYKWX_GAME_STATUS = 0

	if XYKWX_ENDING_DATA then
		--todo
		if XYKWX_ROUND == XYKWX_TOTAL_ROUNDS then
			--todo
			require("xykawuxing.RoundEndingLayer"):showZhuaniao(XYKWX_ENDING_DATA, true)
		else
			require("xykawuxing.RoundEndingLayer"):showZhuaniao(XYKWX_ENDING_DATA, false)
		end
	end	

	-- local callAc = cc.CallFunc:create(function()
	-- 		--todo
	-- 		if XYKWX_ENDING_DATA then
	-- 			--todo
	-- 			if XYKWX_ROUND == XYKWX_TOTAL_ROUNDS then
	-- 				--todo
	-- 				require("xykawuxing.RoundEndingLayer"):show(XYKWX_ENDING_DATA, true)
	-- 			else
	-- 				require("xykawuxing.RoundEndingLayer"):show(XYKWX_ENDING_DATA, false)
	-- 			end
	-- 		end	

	-- 		gamePlaneOperator:clearGameDatas()
	-- 	end)
	-- local seqAc = cc.Sequence:create(cc.DelayTime:create(3), callAc)
	
	-- SCENENOW["scene"]:runAction(seqAc)
end

--广播刮风下雨（返回）杠
function XYKWXReceiveHandle:SVR_GUFENG_XIAYU(pack)

	dump(pack, "-----广播刮风下雨-----");

	local scenes         = SCENENOW['scene'] 

	if SCENENOW['name'] ~= run_scene_name then
		return
	end

	local config = {[0]={['x'] = 480,['y'] = 200,},
					[1]={['x'] = 300,['y'] = 250,},--左
					[2]={['x'] = 480,['y'] = 450,},--上
					[3]={['x'] = 750,['y'] = 300,},--右
	}

	local node = display.newNode()
	local userid_index = self:getIndex(pack.userid)

	local action_deley = cc.DelayTime:create(1.5)
	local action_removeself = cc.RemoveSelf:create()
	local action_sequence = cc.Sequence:create(action_deley,action_removeself)

	if pack.gangType == 1 then
		local guafeng = CARD_PATH_MANAGER:get_card_path("guafeng")
		local object  = display.newSprite(guafeng)
		
		object:pos(config[userid_index].x,config[userid_index].y)
		object:addTo(scenes)
		object:runAction(action_sequence)

	elseif pack.gangType ==2 then
		local xiayu = CARD_PATH_MANAGER:get_card_path("xiayu")
		local object  = display.newSprite(xiayu)
		object:pos(config[userid_index].x,config[userid_index].y)
		object:addTo(scenes)
		object:runAction(action_sequence)
	else
		print("....error..............pack.gangType............",pack.gangType)
	end


	local path_font_res = CARD_PATH_MANAGER:get_card_path("path_font_res")
	local wingold = tostring(pack.wingold)
	local label = display.newBMFontLabel({
	    text = wingold,
	    font = path_font_res,
	})
	label:pos(config[userid_index].x,config[userid_index].y)
	label:addTo(node)


	if pack.czgangType == 1 then
		local index = self:getIndex(pack.fuqianUserId)
		local wingold = tostring(pack.fuqiannum)
		local path_font_res = CARD_PATH_MANAGER:get_card_path("path_font_res")
		local label = display.newBMFontLabel({
		    text = wingold,
		    font = path_font_res,
		})
		label:pos(config[index].x,config[index].y)
		label:addTo(node)


	elseif pack.czgangType == 0 then
		for _,sheMoenydate in pairs(pack.sheMoenydate) do
			local index = self:getIndex(sheMoenydate.userid)
			local wingold = tostring(sheMoenydate.userPaymoney)
			local path_font_res = CARD_PATH_MANAGER:get_card_path("path_font_res")
			local label = display.newBMFontLabel({
			    text = wingold,
			    font = path_font_res,
			})
			label:pos(config[index].x,config[index].y)
			label:addTo(node)
		end		
	end


	local action_move = cc.MoveBy:create(1,cc.p(0,100))
	local action_fadeout = cc.Sequence:create(action_move,cc.FadeOut:create(0.3),cc.RemoveSelf:create())
	--local action_swpan =cc.Spawn:create(action_move,action_fadeout)
	node:runAction(action_fadeout)
	node:addTo(scenes)

end
---------------------------------------------------------------------------------------------------------------

--胡牌
--胡牌协议
function XYKWXReceiveHandle:SVR_HUPAI_BROADCAST(pack)

	dump(pack,"-----胡牌协议-----")

	local scenes  = SCENENOW['scene']
	local paoid = nil 
	for i ,v in pairs(pack.content) do
		local  index  = self:getIndex(v.uid)
		
		local hu_type = v.htype
		if v.htype == 1 then --平胡
		  print("--------------v.pao_content---------------")
		  paoid   = v.pao_content[1].paoid
		end

		self:show_zimo_tip(index,hu_type)
		self:drawPlayerHupaiCard(v.uid,v.card,v.htype)


		--播放自摸声音
		if index == 0 then
			local sound_path = sound_path_manager:GET_GANG_PENG_SOUND(USER_INFO["sex"],1)
			--require("hall.GameCommon"):playEffectSound(sound_path,false)
			cc.SimpleAudioEngine:getInstance():playEffect(sound_path,false)

			scenes:setGameState(5)
			-- if require("hall.gameSettings"):getGameMode() == "match" then
			-- 	require("majiang.MatchSetting"):showMatchWait(true,"majiang")
			-- end
		else
			local otherinfo = XYKWX_ROOM.UserInfo[v.uid]
			if otherinfo ~= nil then
				local sound_path = sound_path_manager:GET_GANG_PENG_SOUND(otherinfo.sex,1)
				--require("hall.GameCommon"):playEffectSound(sound_path,false)
				cc.SimpleAudioEngine:getInstance():playEffect(sound_path,false)
			end
		end
	end

	--print(paodi,"paoid")

	--显示放炮玩家
	if paoid ~= nil then
		local config = {
			[0] = {['x'] = 480,['y'] = 200},
			[1] = {['x'] = 220,['y'] = 306},
			[2] = {['x'] = 480,['y'] = 410},
			[3] = {['x'] = 710,['y'] = 306}	
			-- [0] = {['x'] = 480,['y'] = 300},
			-- [1] = {['x'] = 480,['y'] = 300},
			-- [2] = {['x'] = 480,['y'] = 300},
			-- [3] = {['x'] = 480,['y'] = 300}	
		}

		local index   = self:getIndex(paoid)
		local fangpao = CARD_PATH_MANAGER:get_card_path("fangpao")
		local object  = display.newSprite(fangpao)
		object:addTo(scenes)
		object:setLocalZOrder(2001)
		object:pos(config[index]['x'],config[index]['y'])
		bm.SchedulerPool:delayCall(function ()
			if tolua.isnull(object) == false then
				object:removeSelf()
			end
		end,3)
	end

	XYKWX_ROOM.last = "otherhand"
	self:showLastEvent()

end

--显示自摸
function XYKWXReceiveHandle:show_zimo_tip(index,hu_type)

	dump(index,"-----显示自摸-----")
	dump(hu_type,"-----显示自摸-----")

	local config = {
		[0] = {['x'] = 480,['y'] = 185},
		[1] = {['x'] = 320,['y'] = 306},
		[2] = {['x'] = 480,['y'] = 380},
		[3] = {['x'] = 610,['y'] = 306}	
		}

	local scenes  = SCENENOW['scene']

	if SCENENOW["name"]~= run_scene_name then
		return
	end
	
	local object    = scenes:getChildByName("hashu"..index)
	if object then
		object:removeSelf()
	end

	local pos_x,pos_y = scenes:gettimerpos()
	if hu_type == 1 then
		local path_hu = CARD_PATH_MANAGER:get_card_path("path_hu")
	 	local object  = display.newSprite(path_hu)
		object:addTo(scenes)
		object:pos(config[index]['x'],config[index]['y'])

		 if index == 0 then
		 	show_zimo_effect(scenes,pos_x,pos_y,hu_type)
		 end
	end

	if hu_type == 2 then
		 local path_zimo = CARD_PATH_MANAGER:get_card_path("path_zimo")
		 local object  = display.newSprite(path_zimo)
		 object:addTo(scenes)
		 object:pos(config[index]['x'],config[index]['y'])

		 if index == 0 then
		 	show_zimo_effect(scenes,pos_x,pos_y,hu_type)
		 end
	end

end

--调整胡牌带未打完手牌
function XYKWXReceiveHandle:drawPlayerHupaiCard(uid,card,hkind)

	dump(uid,"-----调整胡牌带未打完手牌-----")
	dump(card,"-----调整胡牌带未打完手牌-----")
	dump(hkind,"-----调整胡牌带未打完手牌-----")

	local scenes  = SCENENOW['scene']
	if SCENENOW["name"] ~= run_scene_name then
		return
	end

	local index   = self:getIndex(uid)

	local node_name = "othercard"..index
	if index == 0 then
		node_name = "owncard"
	end

	--这里做区分手牌是自摸胡，还是平胡别人，显示有区别
	if hkind == 2 then
		MajiangcardHandle:removeCardValue(XYKWX_ROOM.Card[index]["hand"],card,1,index)
		XYKWX_ROOM.Card[index]["hu"] = card
	else
		XYKWX_ROOM.Card[index]["hu"] = card
	end

	self:drawHandCard(index)

	print(tostring(node_name))
	local node = scenes._scene:getChildByName("layer_card"):getChildByName(node_name)


	print(tostring(node))
	local pos_x  = 0
	for i,v in pairs(XYKWX_ROOM.Card[index]["hand"]) do
		local tmp = node:getChildByName(i)
		if tmp then
			if index == 1 or index == 3 then
				tmp:setLeftBlack()
				local item_width = 36
				local item_heigth = 30
				local contentsize =  tmp.pannel_:getContentSize()
				tmp.pannel_:setScale(item_width/contentsize.width,item_heigth/contentsize.height)

			end

			if index == 2 then
				tmp:setTopBlack()
				local contentsize =  tmp.pannel_:getContentSize()
				tmp.pannel_:setScale(30/contentsize.width,42/contentsize.height)

				if pos_x ~= 0 then
					tmp:setPositionX( pos_x - 30 )
					pos_x = pos_x - 30
				else
					pos_x = tmp:getPositionX()
				end
			end
		end
	end

end
------------------------------------------------------------------------------------------------------------------

--结算相关
--结算协议
function XYKWXReceiveHandle:SVR_ENDDING_BROADCAST(pack)

	dump(pack,"-----一盘结束，进行结算-----")
	require("hall.gameSettings"):setGroupState(0)

	for i=1,table.getn(pack.players) do
		local userInfo = XYKWX_USERINFO_TABLE[(i - 1) .. ""]
		userInfo.coins = pack.players[i].coins - USER_INFO["group_chip"]

		local playerType = cardUtils:getPlayerType(i - 1)

		gamePlaneOperator:showPlayerInfo(playerType, userInfo)
	end

	XYKWX_ENDING_DATA = pack

	for k,v in pairs(pack.players) do
		if v.huTypeCount > 0 then
			--todo
			local playerType = cardUtils:getPlayerType(k - 1)
			gamePlaneOperator:showCardsForHu(playerType, v.remainCards)
		end
	end

	require("xykawuxing.RoundEndingLayer"):setIsShow(true)
end

--显示当轮结算界面
function XYKWXReceiveHandle:showRoundResult(pack)

	--假如是最后一轮，则不需要弹出一轮结算
	if bm.round == bm.round_total then
		return
	end

	dump(pack, "-----一轮结算信息-----")
	dump(USER_INFO["user_info"], "-----当前用户信息-----")
	dump(XYKWX_ROOM, "-----显示房间信息-----")

	--登录用户信息（自己）
	local now_user_info = json.decode(USER_INFO["user_info"])

	--获取单轮结算界面
    local s = cc.CSLoader:createNode("majiang/common/GameRoundResult.csb")
    SCENENOW["scene"]:addChild(s)

    --结果标签
    local result_ly = s:getChildByName("result_ly")
    local result_bg_iv = result_ly:getChildByName("result_bg_iv")
    local result_iv = result_ly:getChildByName("result_iv")

    --结果显示区域
    local content_ly = s:getChildByName("content_ly")

    --记录自己是否胜出,默认是输
    local isWin = 0
    --记录是否有人胡了
    local ishu = 0
    for k,v in pairs(pack.content) do
    	--遍历四位用户的结算信息

    	--0 自己 1左边 2对家 3右边
    	local index = self:getIndex(v.uid)
    	if index == 0 then

    		--判断输赢
			if v.userpergold > 0 then

				--赢
				isWin = 1

				--结果标签改成赢的样式
				result_bg_iv:loadTexture("hall/group/create/red_button_p.png")
				result_iv:loadTexture("majiang/common/mahjong_win.png")

			end
    	end

    	--显示用户当局情况
    	--添加显示区域
    	local result_Item = cc.CSLoader:createNode("majiang/common/GameRoundResult_Item.csb")
    	content_ly:addChild(result_Item)
    	local item_ly = result_Item:getChildByName("item_ly")
    	item_ly:setPosition(21, (content_ly:getContentSize().height - 23) - (88 * (k - 1) ) )
    	item_ly_list[k] = item_ly

    	--庄家
    	local zuan_iv = item_ly:getChildByName("zuan_iv")

    	--显示用户名称
    	local name_tt = item_ly:getChildByName("name_tt")
    	if index == 0 then
    		--当前用户信息
    		name_tt:setString(now_user_info.nickName)

    		dump(bm.zuan_seat, "----庄家座位-----")
    		dump(bm.User.Seat, "----玩家座位-----")

    		--判断是否为庄家
    		if bm.User.Seat == bm.zuan_seat then
    			zuan_iv:setVisible(true)
    		else
    			zuan_iv:setVisible(false)
    		end

    	else
    		--其他用户信息
    		local user_info = XYKWX_ROOM.UserInfo[v.uid]
    		local other_user_info = json.decode(user_info.user_info)
    		name_tt:setString(other_user_info.nickName)

    		dump(bm.zuan_seat, "----庄家座位-----")
    		dump(user_info.seat_id, "----玩家座位-----")

    		--判断是否为庄家
    		if user_info.seat_id == bm.zuan_seat then
    			zuan_iv:setVisible(true)
    		else
    			zuan_iv:setVisible(false)
    		end

    	end

    	--显示用户手牌
    	-- dump(XYKWX_ROOM.Card[k], "-----"... tostring(index) ..."用户手牌-----")
    	local showCard_ly = item_ly:getChildByName("showCard_ly")
    	local userleftcard = v.userleftcard
    	dump(userleftcard,"-----" .. tostring(index) .. "用户手牌-----")
    	for k,v in pairs(userleftcard) do

    		--定义牌
    		local card = cc.CSLoader:createNode("hall/majiangCard/csb/roundResult_card.csb")
    		showCard_ly:addChild(card)
    		local card_ly = card:getChildByName("card_ly")
    		card_ly:setPosition(38 * (k - 1), showCard_ly:getContentSize().height)

    		--显示牌内容
    		local card_iv = card_ly:getChildByName("card_iv")
    		local value = tonumber(v)
    		if value > 0 and value < 10 then
    			--万
    			card_iv:loadTexture("hall/majiangCard/wan/".. tostring(value) ..".png")
    		elseif value > 16 and value < 26 then
    			--筒
    			card_iv:loadTexture("hall/majiangCard/tong/".. tostring(value - 16) ..".png")
    		elseif value > 32 and value < 42 then
    			--条
    			card_iv:loadTexture("hall/majiangCard/tiao/".. tostring(value - 32) ..".png")
    		end

    	end

    	--显示胡、胡内容、番数、分数、是否流局
    	--结果
    	local result_tt = item_ly:getChildByName("result_tt")
    	local result_str = ""

    	--番
    	local fan_tt = item_ly:getChildByName("fan_tt")
    	local fan_total = 0

    	--胡标志
    	local hu_iv = item_ly:getChildByName("hu_iv")

    	--是否胡了
    	local ifhu = v.ifhu
    	if ifhu == 1 then

    		if #v.hucontent > 0 then
    			
	    		--获取胡的内容
	    		local hucontent = v.hucontent[1]
	    		dump(hucontent,"-----" .. tostring(index) .. "胡的内容----")

	    		--获取胡的牌型
				local cardkind = hucontent.cardkind
				local card_kind_name = CARD_TYPE[cardkind]
				result_str = result_str .. card_kind_name .. " "

				--记录胡的牌
				local kucard

				--记录点炮的用户id
				local paoid

				--胡的类型
				local hutype = hucontent.hutype
				if hutype == 1 then

					--接炮
					result_str = result_str .. "接炮 "

					local pinghu = hucontent.pinghu[1]

					--是否杠上炮
					if pinghu.ifgangpao == 1 then 
						result_str = result_str .. "杠上炮 "
					end

					--是否抢杠胡
					if pinghu.ifqiangganghu == 1 then
						result_str = result_str .. "抢杠胡 "
					end

					--记录胡的牌
					kucard = pinghu.hucard

					--记录谁点炮
					paoid = pinghu.paoid 

				else 

					--自摸
					result_str = result_str .. "自摸 "

					local zimo = hucontent.zimo[1]

					--记录胡的牌
					kucard = zimo.hucard

					--是否杠上花
					if zimo.ifgangshanghua then
						result_str = result_str .. "杠上花 "
					end

				end

	    		--添加番数
	    		fan_total = fan_total + hucontent.fanshu

				-- local money = hucontent.money--钱
				-- local gen = hucontent.gen--根根的数量
				-- local gangnum = hucontent.gangnum--杠的数量

	    	end

	    	--显示胡标志图片
    		hu_iv:setVisible(true)

    		--记录有人胡了
    		ishu = 1

    	else

    		--隐藏胡标志图片
    		hu_iv:setVisible(false)

    	end

    	--是否点炮
		if v.ifpao==1 then
			result_str = result_str .. "点炮 "
		end

		--刮风下雨
		local ifgua = v.ifgua
		if ifgua > 0 then
			-- result_str = result_str .. "刮风下雨所得：" .. ifgua .. " "
			result_str = result_str .. "刮风下雨"
			-- fan_total = fan_total + ifgua
		elseif ifgua < 0 then
			-- fan_total = fan_total + ifgua
		end

		--是否花猪
		if v.ifhua == 1 then

			-- local huazhu = v.huazhu[1]
			-- --local getMonetPlaynum = huazhu.huamount --收钱玩家数量
			-- --收钱玩家id
			-- local moneyhuazhu = huazhu.huazhuuids
			-- for k,v in pairs(moneyhuazhu) do
			-- 	print("收钱玩家id",k,v)
			-- end
			result_str = result_str .. "花猪 "

		end

		--是否大叫
		if v.ifdajiao==1 then

			local dajiaocontent = v.dajiaocontent[1]
			--local dajiaomout=dajiaocontent.dajiaomout--大叫人数
			local dajiagetMoeny = dajiaocontent.dajiaouserinfo[1]

			--大叫番数
			local f = 0
			--大叫收钱
			local m = 0
			for kd,vd in pairs(dajiagetMoeny) do

				-- --收钱玩家id
				-- if kd == "dajiaouid" then

				-- end

				--番数
				if kd == "dajiaofan" then 
					f = f + vd
				end

				-- --大叫赢的钱
				-- if kd=="dajiaowin" then
				-- 	m = m+vd
				-- end

			end

			--添加番数
			fan_total = fan_total + f

			-- if f ~= 0 then
			-- 	str = str.."番数："..f.."  ".."输赢："..(m*-1).."   "
			-- end

			result_str = result_str.."大叫"
		end

		--显示牌局结果
		result_tt:setString(result_str)

		--显示番数
		if fan_total > 0 then
    		fan_tt:setString(tostring(fan_total) .. "番")
    		fan_tt:setTextColor(cc.c3b(0, 255, 0))

    	else
    		fan_tt:setString("0番")
    		fan_tt:setTextColor(cc.c3b(255, 0, 0))

		end

		--显示分数
    	local fen_tt = item_ly:getChildByName("fen_tt")
    	if v.userpergold > 0 then
    		fen_tt:setTextColor(cc.c3b(0, 255, 0))
    		fen_tt:setString("+" .. tostring(v.userpergold))
    	else
    		if v.userpergold < 0 then
    			fen_tt:setTextColor(cc.c3b(255, 0, 0))
    		end
    		fen_tt:setString(tostring(v.userpergold))
    	end
    	
    end

    --设置流局显示
    if ishu == 0 then
    	--结果标签改成赢的样式
		result_bg_iv:loadTexture("hall/group/create/grey_button.png")
		result_iv:loadTexture("majiang/common/text_liuju.png")
    end

    --显示抓鸟显示
    local pickBird_ly = s:getChildByName("pickBird_ly")
    pickBird_ly:setVisible(false)

    --显示房间号
    local roodId_tt = s:getChildByName("roodId_tt")
    roodId_tt:setString("房间号：" .. USER_INFO["invote_code"])

    --显示房间名
    local roodName_tt = s:getChildByName("roodName_tt")
    roodName_tt:setString("血战到底")

    --显示当前轮数
    local time_tt = s:getChildByName("time_tt")
    time_tt:setString("当前局数" .. tostring(bm.round))

    --开始游戏按钮（再来一局）
    local again_ly = s:getChildByName("again_ly")
    again_ly:addTouchEventListener(
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

                if require("hall.gameSettings"):getGameMode() == "group" then
					require("majiang.majiangServer"):LoginGame(USER_INFO["GroupLevel"] or 37)
				else
					require("majiang.majiangServer"):LoginGame(bm.nomallevel)
			    end

			    s:removeSelf()

            end
        end
    )

end


-------------------------------------------------------------------------------------------------------------------

--组局相关
--请求获取筹码返回
function XYKWXReceiveHandle:SVR_GET_CHIP(pack)
	-- if bm.isGroup then
    if require("hall.gameSettings"):getGameMode() == "group" then
		--todo
		require("majiang.gameScene"):onNetGetChip(pack)
	end
	
end

--请求兑换筹码返回
function XYKWXReceiveHandle:SVR_CHANGE_CHIP(pack)
	
	dump(pack, "-----请求兑换筹码返回------")
	-- if bm.isGroup  then
    if require("hall.gameSettings"):getGameMode() == "group" then
			
		require("majiang.gameScene"):onChipSuccess(pack)
	end

end

--组局时长
function XYKWXReceiveHandle:SVR_GROUP_TIME(pack)


	dump(pack, "-----组局时长-----")

	--  加入当前游戏模式是组局 if bm.isGroup then
    if require("hall.gameSettings"):getGameMode() == "group" then

    	--记录当前局数
		XYKWX_ROUND = pack.round + 1

		--记录总局数
		XYKWX_TOTAL_ROUNDS = pack.round_total

    end
	
end

--组局排行榜（一局结算之后返回的数据）
function XYKWXReceiveHandle:SVR_GROUP_BILLBOARD(pack)
    if pack then
    	XYKWX_GROUP_ENDING_DATA = pack
        -- if bm.isGroup then
    	if require("hall.gameSettings"):getGameMode() == "group" then

    		local isShow = require("xykawuxing.RoundEndingLayer"):isShow()
    		if not isShow then
    			--todo
    			require("xykawuxing.GroupEndingLayer"):showGroupResult(XYKWX_GROUP_ENDING_DATA)
    		end

			require("hall.gameSettings"):setGroupState(0)
		    if bm.Room == nil then
		        bm.Room = {}
		    end
		    bm.Room.start_group = 0
            -- require("majiang.gameScene"):onNetBillboard(pack)
        end
    end

end

--组局历史记录
function XYKWXReceiveHandle:SVR_GET_HISTORY(pack)

	dump(pack, "-----组局历史记录-----")

    if pack then
        -- if bm.isGroup then
    	if require("hall.gameSettings"):getGameMode() == "group" then
            require("majiang.gameScene"):onNetHistory(pack)
        end
    end

end
-----------------------------------------------------------------------------------------------------------------------------

--组局解散相关
--没有此房间，解散房间失败
function XYKWXReceiveHandle:G2H_CMD_DISSOLVE_FAILED(pack)

	dump("", "没有此房间，解散房间失败")

	require("hall.GameTips"):showTips("解散房间失败","disbandGroup_fail",2)

end

--广播桌子用户请求解散组局
function XYKWXReceiveHandle:SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP(pack)

	dump("", "广播桌子用户请求解散组局")

	-- require("hall.GameTips"):showTips("确认解散房间","cs_request_disbandGroup",1)

end

--广播桌子用户成功解散组局
function XYKWXReceiveHandle:SERVER_BROADCAST_DISSOLVE_GROUP(pack)

	dump("", "广播桌子用户成功解散组局")

	-- require("hall.GameTips"):showTips("解散房间成功","cs_disbandGroup_success",3)

	XYKWX_ROUND = XYKWX_TOTAL_ROUNDS

	if SCENENOW["scene"]:getChildByName("layer_tips") then
        SCENENOW["scene"]:removeChildByName("layer_tips")
    end

    if require("xykawuxing.RoundEndingLayer"):isShow() then
    	--todo
    	require("xykawuxing.RoundEndingLayer"):hide()
    	if XYKWX_ENDING_DATA then
    		--todo
    		require("xykawuxing.RoundEndingLayer"):show(XYKWX_ENDING_DATA, true)
    	end
    	
    end

end

--广播桌子用户解散组局 ，解散组局失败
function XYKWXReceiveHandle:SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP(pack)

	dump("", "广播桌子用户解散组局 ，解散组局失败")
	print("拒绝解散的玩家UID：", pack.rejectId)

	local seatId = XYKWX_SEAT_TABLE[pack.rejectId .. ""]
	local userInfo = XYKWX_USERINFO_TABLE[seatId .. ""]
	local msg = ""
	if userInfo and userInfo.nick then
		msg = "玩家【".. userInfo.nick .."】拒绝解散组局"
	end

	require("hall.GameTips"):showTips("解散房间失败","disbandGroup_fail",2, msg)

end

--广播当前组局解散情况
function XYKWXReceiveHandle:G2H_CMD_REFRESH_DISSOLVE_LIST(pack)

	dump(pack, "-----广播当前组局解散情况-----")
	dump(bm.Room, "-----广播当前房间情况-----")

	local applyId = pack.applyId
	local agreeNum = pack.agreeNum
	local agreeMember_arr = pack.agreeMember_arr

	local showMsg = ""

	--申请解散者信息
	local applyer_info = {}
	if applyId == tonumber(UID) then
		showMsg = "您申请解散房间，请等待其他玩家同意（超过5分钟未做选择，则默认同意）" .. "\n"
	else
		-- if bm.Room ~= nil then
		-- 	if bm.Room.UserInfo ~= nil then
		-- 		applyer_info = json.decode(bm.Room.UserInfo[applyId].user_info)
		-- 		local nickName = applyer_info.nickName
		-- 		if nickName ~= nil then
					
		-- 		end
		-- 	end
		-- end
		local seatId = XYKWX_SEAT_TABLE[applyId .. ""]
		if seatId then
			--todo
			local userInfo = XYKWX_USERINFO_TABLE[seatId .. ""]

			if userInfo then
				--todo
				local nickName = userInfo.nick

				showMsg = "玩家【" .. nickName .. "】申请解散房间，请等待其他玩家同意（超过5分钟未做选择，则默认同意）" .. "\n"
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
	-- if bm.Room ~= nil then
		if XYKWX_USERINFO_TABLE then
			for k,v in pairs(XYKWX_USERINFO_TABLE) do
				local uid = v.uid
				--排除掉申请者，申请者不需要显示到这里
				if uid ~= applyId and uid ~= tonumber(UID) then

					--记录当前用户是否已经同意
					local isAgree = 0
					if agreeNum > 0 then
						for k,v in pairs(agreeMember_arr) do
							if uid == v then
								--当前用户已经同意
								isAgree = 1
								break
							end
						end
					end

					-- --显示当前用户情况
					-- local user_info = json.decode(v.user_info)
					-- if user_info ~= nil then
						local nickName = v.nick
						if nickName ~=nil then
							if isAgree == 1 then
								showMsg = showMsg .. "  【" .. nickName .. "】已同意" .. "\n"
							else
								showMsg = showMsg .. "  【" .. nickName .. "】等待选择" .. "\n"
							end
						end
						
					-- end
				end
			end
		end
	-- end

	if applyId == tonumber(UID) then
		--假如申请者是自己，则直接显示其他用户的选择情况
		require("hall.GameTips"):showTips("提示", "agree_disbandGroup", 4, showMsg)
	else
		--申请者不是自己，根据自己的同意情况进行界面显示
		if isMyAgree == 1 then
			require("hall.GameTips"):showTips("提示", "agree_disbandGroup", 4, showMsg)
		else
			require("hall.GameTips"):showTips("提示", "xykwx_request_disbandGroup", 1, showMsg)
		end
	end
	

end

---------------------------------------------------------------------------------------------------------------

--聊天相关
--收到聊天消息
function XYKWXReceiveHandle:CHAT_MSG( pack )
	dump(pack, "================CHAT_MSG========================")
	local scenes         = SCENENOW['scene'] 

	if SCENENOW['name'] ~= run_scene_name then
		return
	end

	local config = {[0]={['x'] = 480,['y'] = 200,},
					[1]={['x'] = 300,['y'] = 250,},--左
					[2]={['x'] = 480,['y'] = 450,},--上
					[3]={['x'] = 750,['y'] = 300,},--右
	}

	local msg = pack.msg or "nothing to get"
	local index = self:getIndex(pack.uid or UID)

	local niu_txt = scenes:getChildByName("chat_msg"..tostring(index))
	if niu_txt ~= nil then niu_txt:removeSelf() end

	local params =
    {
        text = msg,
        font = "res/fonts/fzcy.ttf",
        size = 25,
        color = cc.c3b(255,0,0), 
        align = cc.TEXT_ALIGNMENT_CENTER,
        valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
    }
    niu_txt =  display.newTTFLabel(params)
    niu_txt:enableShadow(cc.c4b(255,0,0,255), cc.size(1,0))
    scenes:addChild(niu_txt, "3000", "chat_msg"..tostring(index))
    niu_txt:setPositionX(config[index].x)
    niu_txt:setPositionY(config[index].y)

    local action_deley = cc.DelayTime:create(0.5)
    local action_move = cc.MoveBy:create(0.5,cc.p(0,-80))
    local action_reself = cc.RemoveSelf:create()
    local action_seq = cc.Sequence:create(action_deley,action_move,action_reself)
    niu_txt:runAction(action_seq)

end
---------------------------------------------------------------------------------------------------------------

--比赛相关
function XYKWXReceiveHandle:s2c_JOIN_MATCH_RETURN(pack)
	print("===recieve====0x211====================")
	dump(pack)
	print("UID------------------",UID)
    USER_INFO["match_id"] = pack["Matched"]
	local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_LOGIN_ROOM_GROUP)
    :setParameter("tableid", pack.Matched)
    :setParameter("nUserId", UID)
    :setParameter("strkey", json.encode("kadlelala"))
    :setParameter("strinfo", USER_INFO["user_info"])
    :setParameter("iflag", 1)
    :setParameter("version", 1)
    :setParameter("activity_id","")
    :build()
	bm.server:send(pack)
	print("sending ------------------1001-------------")
end

function XYKWXReceiveHandle:s2c_JOIN_MATCH_FAIL(pack)
	print("0x7109==========return==========")
	dump(pack)
	USER_INFO["match_fee"] = 0
    require("majiang.MatchSetting"):setJoinMatch(false)
end

function XYKWXReceiveHandle:s2c_JOIN_MATCH_SUCCESS(pack)
	print("0x7101==========return==========")
	dump(pack)

	--重设玩家的金币数，这个是扣除了报名费
	USER_INFO["gold"] = pack.Score
	local scenes         = SCENENOW['scene'] 

	if SCENENOW['name'] =="majiang.MJselectChip"  then
		scenes:goldUpdate()
	end
	 require("majiang.MatchSetting"):setJoinMatch(true)


    if USER_INFO["match_fee"] then
        if USER_INFO["match_fee"] > 0 then
            bMatchJoin = true
            require("majiang.MatchSetting"):showMatchSignup(true,pack["MatchUserCount"],pack["totalCount"],pack["Costformatch"],"majiang",USER_INFO["curr_match_level"])
        end
    end

    USER_INFO["match_fee"] = pack["Costformatch"]

    --进入比赛模式
    --进入比赛模式
    require("hall.GameData"):enterMatch(4)
end

function XYKWXReceiveHandle:s2c_OTHER_PEOPLE_JOINT_IN(pack)
	print("0x7103==========return==========")
	dump(pack)
	require("majiang.MatchSetting"):setJoinMatch(true)
	require("majiang.MatchSetting"):joinMatch(pack.Usercount,pack.Totalcount)
end

function XYKWXReceiveHandle:s2c_QUIT_MATCH_RETURN(pack)
	print(" 0x7110==========return==========")
	dump(pack)
	-- require("majiang.MatchSetting"):setJoinMatch(false)

    if pack then
        local flag = pack["Flag"]
        -- 成功退赛
        if flag == 1 or flag == 2 then
            --退回报名费
			local scenes         = SCENENOW['scene'] 
            USER_INFO["gold"] = USER_INFO["gold"] + pack["nCostForMatch"]
			if SCENENOW['name'] =="majiang.MJselectChip"  then
				scenes:goldUpdate()
			end
            
            require("majiang.MatchSetting"):setJoinMatch(false)
            MajiangroomServer:quickRoom()

            local layer_sign = scenes:getChildByName("layer_sign")

            if layer_sign then
                local txt = layer_sign:getChildByName("layout_join"):getChildByName("txt_playercount")
                if txt then
                    local str = "退赛成功"
                    txt:setString(str)
                end
            end
            USER_INFO["match_fee"] = 0
            bMatchJoin = false


        else
            --失败原因
            print("match logout failed,error type:"..pack["Errortype"])
            require("majiang.MatchSetting"):setJoinMatch(true)
        end

    end
end

function XYKWXReceiveHandle:s2c_GAME_BEGIN_LOGIC(pack)
	print("0x7104==========return==========")
	dump(pack)
	
	bm.User={}
	bm.User.Seat      = pack.seat_id
	bm.User.Golf      = pack.gold or pack.Matchpoint
	bm.User.Pque      = nil

	XYKWX_ROOM={}
	XYKWX_ROOM.User      = {}	
    XYKWX_ROOM.UserInfo  = {}
    XYKWX_ROOM.seat_uid  = {}
	XYKWX_ROOM.Card      = {}
	XYKWX_ROOM.Gang      = {}
	XYKWX_ROOM.base      = pack.base 

	XYKWX_ROOM.tuoguan_ing = 0

	--bm.display_scenes("majiang.scenes.MajiangroomScenes")

	SCENENOW["scene"]:removeSelf()
	SCENENOW["scene"]=nil;

	local sc=require("majiang.scenes.MajiangroomScenes").new()
	SCENENOW["scene"] = sc
    --SCENENOW["scene"]:retain();
    SCENENOW["name"]  = "majiang.scenes.MajiangroomScenes";
	display.replaceScene(sc)
	local scenes   = sc

	--绘制自己的信息
	scenes:set_ower_info(USER_INFO["icon_url"],USER_INFO["nick"],pack["Matchpoint"],USER_INFO["sex"])

	--绘制其他玩家
	if pack.Usercount > 0  then
		for i,v in pairs(pack.other_players) do
			XYKWXReceiveHandle:showPlayer(v)
		end
	end

	--绘制其他内容
	scenes:set_basescole_txt(XYKWX_ROOM.base) 

	-- if bm.isGroup  then --
    if require("hall.gameSettings"):getGameMode() == "group" then
		USER_INFO["base_chip"]=XYKWX_ROOM.base;
		require("majiang.gameScene"):showTimer(bm.GroupTimer)

		require("majiang.gameScene"):checkChip(scenes)

	else
		SCENENOW["scene"]:gameReady();
		
	end
	majiangGameMode = 2
	require("hall.gameSettings"):setGameMode("match")
	require("majiang.MatchSetting"):setCurrentRound(pack["Round"],pack["Sheaves"])
	voiceUtils:playBackgroundMusic()

    if scenes:getChildByName("match_win") then
        scenes:removeChildByName("match_win")
    end
    if scenes:getChildByName("match_lose") then
        scenes:removeChildByName("match_lose")
    end
    if scenes:getChildByName("match_wait") then
        scenes:removeChildByName("match_wait")
    end
    if scenes:getChildByName("match_result") then
        scenes:removeChildByName("match_result")
    end

end

function XYKWXReceiveHandle:s2c_PAI_MING_MSG(pack)
	print("0x7114==========return==========")
	dump(pack)
end

function XYKWXReceiveHandle:s2c_SVR_MATCH_WAIT(pack)
	print("0x7113==========return==========")
	dump(pack)
	SCENENOW["scene"]:removeSelf()
	SCENENOW["scene"]=nil;

	local sc=require("majiang.scenes.MajiangroomScenes").new()
	SCENENOW["scene"] = sc
    --SCENENOW["scene"]:retain();
    SCENENOW["name"]  = "majiang.scenes.MajiangroomScenes";
	display.replaceScene(sc)
	local scenes   = sc
	if tolua.isnull(scenes) == false then
	    USER_INFO["match_gold"] = pack["Matchpoint"]
		scenes:set_ower_info(USER_INFO["icon_url"],USER_INFO["nick"],pack["Matchpoint"],USER_INFO["sex"])
	    require("majiang.HallHttpNet"):MatchloadBattles(4)
	    require("majiang.MatchSetting"):setMatchState(1)
	end

	if pack["table_count"]>0 then
        require("majiang.MatchSetting"):showMatchWait(true,"majiang")
        return
    end
end

function XYKWXReceiveHandle:s2c_GAME_STATE_MSG(pack)
	print("0x7106==========return==========")
	dump(pack)
	local scenes         = SCENENOW['scene'] 

	if SCENENOW['name'] ~= run_scene_name then
		return
	end
	if pack == nil then
		return
	end

    if pack["Tablecount"]>0 then
        require("majiang.MatchSetting"):showMatchWait(true,"majiang")
        return
    end

	local status = pack["Status"]
    if status==0 then --晋级
        if USER_INFO["match_rank"] == nil then
            USER_INFO["match_rank"] = 0
        end
        if USER_INFO["match_rank"] == 0 then
            USER_INFO["match_rank"] = pack["Maxnumber"]
        end
        -- self:showMatchWin(pack["Rank"],USER_INFO["match_rank"],currentRound)
        if pack["Tablecount"] == 0 then
            require("majiang.MatchSetting"):showMatchWin(pack["Rank"],USER_INFO["match_rank"],require("majiang.MatchSetting"):getCurrentRank(),"majiang")
        end
    elseif status==1 then --淘汰后显示结果
        require("majiang.MatchSetting"):setMatchResult(pack["Rank"],pack["Maxnumber"],pack["Strtime"],"majiang",require("majiang.MatchSetting"):getIncentive(pack["Level"],pack["Rank"]))
        require("majiang.MatchSetting"):showMatchLose(pack["Rank"],pack["Maxnumber"],require("majiang.MatchSetting"):getCurrentRank(),"majiang")
        bMatchStatus = 2
        local sp = display.newSprite():addTo(scenes)
        sp:performWithDelay(function()
            require("majiang.MatchSetting"):showMatchResult()
        end,5)
        audio.stopMusic(true)
    elseif status==2 then --赢了显示结果
    	audio.stopMusic(true)

        bMatchStatus = 2
        
        require("majiang.MatchSetting"):setMatchResult(pack["Rank"],pack["Maxnumber"],pack["Strtime"],"majiang",require("majiang.MatchSetting"):getIncentive(pack["Level"],pack["Rank"]))
		require("majiang.MatchSetting"):showMatchResult()	
	end
       
end

function XYKWXReceiveHandle:s2c_SVR_REGET_MATCH_ROOM(pack)
	
	--dump(pack)
	--重新调用1009部分的功能
	self:SVR_REGET_ROOM(pack)
	majiangGameMode = 2
	require("hall.gameSettings"):setGameMode("match")
	data_manager:set_game_mode(2)
	
	-- print("recieve msg ----------7112--------------------------")
 --    print("pack.m_nMatchRank--------------",pack.m_nMatchRank)--当前排名
 --    print("pack.m_nPoint--------------",pack.m_nPoint)--当前积分
 --    print("pack.m_strUserInfo--------------",pack.m_strUserInfo)--用户信息
    --pack.m_nplayecount

	--for index,user_data in pairs(pack.other_point) do
		-- print("index.............",index)
		-- print("user_data.m_userid--------------",user_data.m_userid)
		-- print("user_data.m_nMatchRank--------------",user_data.m_nMatchRank)
		-- print("user_data.m_nPoint--------------",user_data.m_nMatchRank)
	--end

	-- print("index............over")
 --    print("pack.m_nLevel--------------",pack.m_nLevel)
    USER_INFO["curr_match_level"] = pack.m_nLevel
    USER_INFO["match_fee"] = 100

    -- print("pack.m_nSheaves--------------",pack.m_nSheaves)--第几局`
    -- print("pack.m_nRound--------------",pack.m_nRound)--第几轮
    -- require("majiang.MatchSetting"):setCurrentRound(pack["m_nRound"],pack["m_nSheaves"])

    -- print("pack.m_nLowPoint--------------",pack.m_nLowPoint)
    -- print("pack.m_nNuber--------------",pack.m_nNuber)
    -- print("pack.m_nCurrentCount--------------",pack.m_nCurrentCount)
    -- print("pack.m_nstr--------------",pack.m_nstr)
    -- print("pack.m_nFinalplayTimesInTable--------------",pack.m_nFinalplayTimesInTable)

    --require("majiang.HallHttpNet"):MatchloadBattles(4)

    data_manager:match_game_http(pack.m_nLevel)
    require("majiang.HallHttpNet"):requestIncentive(pack.m_nLevel)

 --    if pack.pHuSeatId == 1 then
	-- 	require("majiang.MatchSetting"):showMatchWait(true,"majiang")
	-- end

end
---------------------------------------------------------------------------------------------------------------

--玩家进入私人房
function XYKWXReceiveHandle:SVR_ENTER_PRIVATE_ROOM(pack)

    require("hall.GameTips"):showTips("系统错误", "tohall", 3, "房间不存在")
end
return XYKWXReceiveHandle