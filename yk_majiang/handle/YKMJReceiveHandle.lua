--加载框架初始化类
require("framework.init")

local gamePlaneOperator = require("yk_majiang.operator.GamePlaneOperator")
-- local manyouPlaneOperator = require("yk_majiang.operator.ManyouPlaneOperator")

local cardUtils = require("yk_majiang.utils.cardUtils")
local voiceUtils = require("yk_majiang.utils.VoiceUtils")
local aniUtils = require("yk_majiang.utils.AniUtils")

--大厅套接字请求类
local hallPa = require("hall.HALL_PROTOCOL")
--麻将套接字请求类
local PROTOCOL = import("yk_majiang.handle.YKMJProtocol")
setmetatable(PROTOCOL, {
		__index=hallPa
	})

--加载大厅请求处理
local hallHandle = require("hall.HallHandle")
--定义麻将游戏处理类
local YKMJReceiveHandle = class("YKMJReceiveHandle",hallHandle)
local sendHandle = require("yk_majiang.handle.YKMJSendHandle")

--定义登录超时时间
local LOGIN_OUT_TIMER = 20
--定义麻将游戏界面名称
local run_scene_name = "yk_majiang.gameScene"
--扣除台费百分数
local percent_base = 0.20
local item_ly_list = {}

function YKMJReceiveHandle:ctor()

	YKMJReceiveHandle.super.ctor(self);

	--定义麻将游戏请求	
	local  func_ = {

		--用户自己退出成功
        [PROTOCOL.SVR_QUICK_SUC] = {handler(self, YKMJReceiveHandle.SVR_QUICK_SUC)},
        --广播用户准备
        [PROTOCOL.SVR_USER_READY_BROADCAST] = {handler(self, YKMJReceiveHandle.SVR_USER_READY_BROADCAST)},
        --登陆房间广播
        [PROTOCOL.SVR_LOGIN_ROOM_BROADCAST] = {handler(self, YKMJReceiveHandle.SVR_LOGIN_ROOM_BROADCAST)},
        --广播玩家退出返回
        [PROTOCOL.SVR_QUIT_ROOM] = {handler(self, YKMJReceiveHandle.SVR_QUIT_ROOM)},
        --发牌
        [PROTOCOL.SVR_SEND_USER_CARD] = {handler(self, YKMJReceiveHandle.SVR_SEND_USER_CARD)},
        --开始选择缺一门
        [PROTOCOL.SVR_START_QUE_CHOICE] = {handler(self, YKMJReceiveHandle.SVR_START_QUE_CHOICE)},
        --广播缺一门选择
        [PROTOCOL.SVR_BROADCAST_QUE] = {handler(self, YKMJReceiveHandle.SVR_BROADCAST_QUE)},
        --当前抓牌用户广播
        [PROTOCOL.SVR_PLAYING_UID_BROADCAST] = {handler(self, YKMJReceiveHandle.SVR_PLAYING_UID_BROADCAST)},
        --广播用户出牌
        [PROTOCOL.SVR_SEND_MAJIANG_BROADCAST] = {handler(self, YKMJReceiveHandle.SVR_SEND_MAJIANG_BROADCAST)},
        --svr通知我抓的牌
        [PROTOCOL.SVR_OWN_CATCH_BROADCAST] = {handler(self, YKMJReceiveHandle.SVR_OWN_CATCH_BROADCAST)},
        --广播用户进行了什么操作
        [PROTOCOL.SVR_PLAYER_USER_BROADCAST] = {handler(self, YKMJReceiveHandle.SVR_PLAYER_USER_BROADCAST)},
        --广播胡
    	[PROTOCOL.SVR_HUPAI_BROADCAST]       = {handler(self, YKMJReceiveHandle.SVR_HUPAI_BROADCAST)}, 
    	--结算
    	[PROTOCOL.SVR_ENDDING_BROADCAST] = {handler(self, YKMJReceiveHandle.SVR_ENDDING_BROADCAST)}, 
    	--请求托管
    	[PROTOCOL.SVR_ROBOT] = {handler(self, YKMJReceiveHandle.SVR_ROBOT)}, 
    	--出牌错误返回
    	[PROTOCOL.SVR_CHUPAI_ERROR] = {handler(self, YKMJReceiveHandle.SVR_CHUPAI_ERROR)}, 
    	--海底牌 SVR_HAIDI_CARD
    	[PROTOCOL.SVR_HAIDI_CARD] = {handler(self, YKMJReceiveHandle.SVR_HAIDI_CARD)}, 
    	--亮倒提示
    	[PROTOCOL.SVR_LIANGDAO_REMAID] = {handler(self, YKMJReceiveHandle.SVR_LIANGDAO_REMAID)}, 
    	[PROTOCOL.SVR_MSG_FACE]={handler(self, YKMJReceiveHandle.SVR_MSG_FACE)},
    	
    	[PROTOCOL.BROADCAST_USER_IP]={handler(self, YKMJReceiveHandle.BROADCAST_USER_IP)},

    	[PROTOCOL.SVR_HUIPAI]={handler(self, YKMJReceiveHandle.SVR_HUIPAI)},

    	[PROTOCOL.SVR_JIAPIAO]={handler(self, YKMJReceiveHandle.SVR_JIAPIAO)},
    	[PROTOCOL.SVR_JIAPIAO_BROADCAST]={handler(self, YKMJReceiveHandle.SVR_JIAPIAO_BROADCAST)},

    	--获取房间id结果
    	[PROTOCOL.SVR_GET_ROOM_OK]     = {handler(self, YKMJReceiveHandle.SVR_GET_ROOM_OK)},
    	--登陆房间返回
        [PROTOCOL.SVR_LOGIN_ROOM]      = {handler(self, YKMJReceiveHandle.SVR_LOGIN_ROOM)},
        --登陆错误
     	[PROTOCOL.SVR_ERROR]      = {handler(self, YKMJReceiveHandle.SVR_ERROR)},
     	--用户重新登录普通房间的消息返回（4105(10进制s)）
     	[PROTOCOL.SVR_REGET_ROOM]      = {handler(self, YKMJReceiveHandle.SVR_REGET_ROOM)},--重登
     	--服务器告知客户端可以进行的操作
     	[PROTOCOL.SVR_NORMAL_OPERATE]      = {handler(self, YKMJReceiveHandle.SVR_NORMAL_OPERATE)},--广播可以进行的操作
     	--服务器告知客户端游戏结束
     	[PROTOCOL.SVR_GAME_OVER]      = {handler(self, YKMJReceiveHandle.SVR_GAME_OVER)},
     	--广播刮风下雨（返回）杠
     	[PROTOCOL.SVR_GUFENG_XIAYU]      = {handler(self, YKMJReceiveHandle.SVR_GUFENG_XIAYU)},


     	--用户聊天消息
     	[PROTOCOL.CHAT_MSG]      = {handler(self, YKMJReceiveHandle.CHAT_MSG)},

     	--组局
     	--请求获取筹码返回
     	[PROTOCOL.SVR_GET_CHIP]     = {handler(self, YKMJReceiveHandle.SVR_GET_CHIP)},
     	--请求兑换筹码返回
     	[PROTOCOL.SVR_CHANGE_CHIP]     = {handler(self, YKMJReceiveHandle.SVR_CHANGE_CHIP)},
     	--组局时长
     	[PROTOCOL.SVR_GROUP_TIME]     = {handler(self, YKMJReceiveHandle.SVR_GROUP_TIME)},
     	--组局排行榜
     	[PROTOCOL.SVR_GROUP_BILLBOARD]     = {handler(self, YKMJReceiveHandle.SVR_GROUP_BILLBOARD)},
     	--组局历史记录
     	[PROTOCOL.SVR_GET_HISTORY]     = {handler(self, YKMJReceiveHandle.SVR_GET_HISTORY)},
     	--漫游
     	[PROTOCOL.SVR_MANYOU] = {handler(self, YKMJReceiveHandle.SVR_MANYOU)},

     	--没有此房间，解散房间失败
     	[PROTOCOL.G2H_CMD_DISSOLVE_FAILED]     = {handler(self, YKMJReceiveHandle.G2H_CMD_DISSOLVE_FAILED)},
     	--广播桌子用户请求解散组局
     	[PROTOCOL.SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP]     = {handler(self, YKMJReceiveHandle.SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP)},
     	--广播当前组局解散情况
     	[PROTOCOL.G2H_CMD_REFRESH_DISSOLVE_LIST]     = {handler(self, YKMJReceiveHandle.G2H_CMD_REFRESH_DISSOLVE_LIST)},
     	--广播桌子用户成功解散组局
     	[PROTOCOL.SERVER_BROADCAST_DISSOLVE_GROUP]     = {handler(self, YKMJReceiveHandle.SERVER_BROADCAST_DISSOLVE_GROUP)},
     	--广播桌子用户解散组局 ，解散组局失败
     	[PROTOCOL.SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP]     = {handler(self, YKMJReceiveHandle.SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP)},

     	--换牌
     	--服务器告诉客户端，可以换牌
     	[PROTOCOL.SERVER_COMMAND_NEED_CHANGE_CARD]     = {handler(self, YKMJReceiveHandle.SERVER_COMMAND_NEED_CHANGE_CARD)},
     	--//服务器广播换牌的结果 zsw
     	[PROTOCOL.SERVER_COMMAND_CHANGE_CARD_RESULT]     = {handler(self, YKMJReceiveHandle.SERVER_COMMAND_CHANGE_CARD_RESULT)},
         --接收服务器发来的距离
        [PROTOCOL.SERVER_CMD_FORWARD_MESSAGE] = {handler(self, YKMJReceiveHandle.SERVER_CMD_FORWARD_MESSAGE)},
          --录音
        [PROTOCOL.SERVER_CMD_MESSAGE] = {handler(self, YKMJReceiveHandle.SERVER_CMD_MESSAGE)},             
     	--比赛场相关
     	--用户请求进入比赛场的返回值
     	[PROTOCOL.s2c_JOIN_MATCH_RETURN]     = {handler(self, YKMJReceiveHandle.s2c_JOIN_MATCH_RETURN)},
     	--进入比赛失败
     	[PROTOCOL.s2c_JOIN_MATCH_FAIL]     = {handler(self, YKMJReceiveHandle.s2c_JOIN_MATCH_FAIL)},
     	-- 进入比赛成功
		[PROTOCOL.s2c_JOIN_MATCH_SUCCESS]     = {handler(self, YKMJReceiveHandle.s2c_JOIN_MATCH_SUCCESS)},
		--同时，已经报名的玩家会收到其他玩家进入的消息
     	[PROTOCOL.s2c_OTHER_PEOPLE_JOINT_IN]     = {handler(self, YKMJReceiveHandle.s2c_OTHER_PEOPLE_JOINT_IN)},
     	--返回退出比赛结果
     	[PROTOCOL.s2c_QUIT_MATCH_RETURN]     = {handler(self, YKMJReceiveHandle.s2c_QUIT_MATCH_RETURN)},
     	--比赛开始逻辑0x7104//牌局，开始发送其他玩家信息
     	[PROTOCOL.s2c_GAME_BEGIN_LOGIC]     = {handler(self, YKMJReceiveHandle.s2c_GAME_BEGIN_LOGIC)},
     	--每轮打完之后 会给玩家发送比赛状态信息0x7106
     	[PROTOCOL.s2c_GAME_STATE_MSG]     = {handler(self, YKMJReceiveHandle.s2c_GAME_STATE_MSG)},
     	-- 比赛的过程中会收到比赛的排名信息  0x7114
     	[PROTOCOL.s2c_PAI_MING_MSG]     = {handler(self, YKMJReceiveHandle.s2c_PAI_MING_MSG)},
     	--发送用户重连回比赛开赛后的等待界面
     	[PROTOCOL.s2c_SVR_MATCH_WAIT]     = {handler(self, YKMJReceiveHandle.s2c_SVR_MATCH_WAIT)},
     	--用户重新登录比赛场房间的消息返回
     	[PROTOCOL.s2c_SVR_REGET_MATCH_ROOM] = {handler(self, YKMJReceiveHandle.s2c_SVR_REGET_MATCH_ROOM)},
        
    }
    table.merge(self.func_, func_)

end


function YKMJReceiveHandle:SVR_HUIPAI(pack)
	HUIPAI=pack.PrivateHuipai or {}
	table.insert(HUIPAI,pack.Huipai)
	gamePlaneOperator:showCards(CARD_PLAYERTYPE_MY)
end

--接收服务器返回的组局信息
function YKMJReceiveHandle:SERVER_CMD_MESSAGE(pack)

	if bm.isInGame == false then
		return
	end
    
    local msg = json.decode(pack.msg)
    dump(msg, "-----NiuniuroomHandle 接收服务器返回的组局信息-----")
    if msg ~= nil then
    	local msgType = msg.msgType
		if msgType ~= nil and msgType ~= "" then

			if device.platform == "ios" then

				if msgType == "voice" then
					dump("voice", "-----接收服务器返回的组局信息-----")

					require("hall.view.voicePlayView.voicePlayView"):showView(msg.uid, msg.voiceTime)

					--通知本地播放录音
					local arr = {}
                    arr["url"] = msg.url
					cct.getDateForApp("playVoice", arr, "V")

				elseif msgType == "video" then
					dump("video", "-----接收服务器返回的组局信息-----")

					local arr = {}
                    arr["url"] = msg.url
					cct.getDateForApp("playVideo", arr, "V")

				end

			else

				if msgType == "voice" then
                    dump("voice", "-----接收服务器返回的组局信息-----")

                    require("hall.view.voicePlayView.voicePlayView"):showView(msg.uid, msg.voiceTime)

                    --通知本地播放录音

                    local data = {}
                    data["url"] = msg.url
                    
                    local arr = {}
                    table.insert(arr, json.encode(data))
                    cct.getDateForApp("playVoice", arr, "V")

                elseif msgType == "video" then
                    dump("video", "-----接收服务器返回的组局信息-----")
                    
                    local data = {}
                    data["url"] = msg.url
                    
                    local arr = {}
                    table.insert(arr, json.encode(data))
                    cct.getDateForApp("playVideo", arr, "V")

                end
			
			end

		end
    end
    
end

function YKMJReceiveHandle:SVR_JIAPIAO(pack)

	local scenes  = SCENENOW['scene']

	if SCENENOW["name"] ~= run_scene_name then
		return
	end

	scenes:hideCloseRoomButton()
	scenes:ShowSettingButton()
	scenes:hideShareButton()

	gamePlaneOperator:showCenterPlane()
    gamePlaneOperator:clearAllReadyStatus()
	gamePlaneOperator:showJiapiaoPlane(true)
end

function YKMJReceiveHandle:SVR_JIAPIAO_BROADCAST(pack)
	local playerType = cardUtils:getPlayerType(pack.seatId)
	gamePlaneOperator:showPiaoImg(playerType, pack.jiapiao, true)
	gamePlaneOperator:showPiaoPlane(playerType, pack.jiapiao, true)
end

--接收服务器发来的距离数据    0x 0213
function YKMJReceiveHandle:SERVER_CMD_FORWARD_MESSAGE(pack)
	
	-- show--dumpData=true
    --dump(pack,"-------距离数据---------")   

    local msgList = pack.msgList
    for k,v in pairs(msgList) do
    	if v ~= nil and v ~= "" then
    		local msg = json.decode(v)
    		if msg~= nil and  msg~=""  then 
    			require("hall.view.userInfoView.userInfoView"):upDateUserInfo(msg.uid,msg)
    		end
    	end
    end

 --    for k,v in pairs(pack.msgList) do
 --    	if v ~= nil and v ~= "" then
 --    		local msg = json.decode(v)
	-- 	    if msg then


	-- 	    	--dump(YKMJ_SEAT_TABLE, "-----YKMJ_USERINFO_TABLE-----")
	-- 			--dump(YKMJ_USERINFO_TABLE, "-----YKMJ_USERINFO_TABLE-----")

	-- 			local uid = msg.uid

	-- 			local seat_id = YKMJ_SEAT_TABLE[uid.. ""]



	-- 			-- YKMJ_USERINFO_TABLE[seat_id .. ""].longitude = msg.longitude

	-- 			-- YKMJ_USERINFO_TABLE[seat_id .. ""].latitude = msg.latitude

	-- 			-- local playerType =cardUtils:getPlayerType(seat_id)


	-- 			-- gamePlaneOperator:showPlayerInfo(playerType, YKMJ_USERINFO_TABLE[seat_id .. ""])


	-- 	    end
 --    	end
	-- end

end

function YKMJReceiveHandle:refreshcards()
	gamePlaneOperator:showCards(CARD_PLAYERTYPE_MY,{})
end


function YKMJReceiveHandle:BROADCAST_USER_IP(pack)

	 local playeripdata = pack.playeripdata or {}
    for _,ip_data in pairs(playeripdata) do
      local ip_ = ip_data.ip or ""
      local uid_ = ip_data.uid or 0
      if uid_ ~= 0 then
        local seatId = YKMJ_SEAT_TABLE[uid_ .. ""]

	    if seatId then
	        --todo

	        if YKMJ_USERINFO_TABLE[seatId .. ""] then
	            --todo
	            YKMJ_USERINFO_TABLE[seatId .. ""].ip = ip_
     
	        end
	    end
      end
    end

    			local myIp = ""

	            if YKMJ_MY_USERINFO.seat_id and YKMJ_USERINFO_TABLE[YKMJ_MY_USERINFO.seat_id .. ""] then
	            	--todo
	            	myIp = YKMJ_USERINFO_TABLE[YKMJ_MY_USERINFO.seat_id .. ""].ip
	            end
	    
	            local ipTable = {}
	            for k,v in pairs(YKMJ_USERINFO_TABLE) do
	            	if v.ip and v.ip ~= myIp then
	            		if not ipTable[v.ip] then
	            			--todo
	            			ipTable[v.ip] = {}
	            		end
	            		table.insert(ipTable[v.ip], v.nick)
	            	end
	            end                                                                                      
	            local msg = ""
	            for k,v in pairs(ipTable) do
	            	if table.getn(v) > 1 then
	            		--todo
	            		for i=1,table.getn(v) do
	            			msg = msg .. v[i] .. " "
	            		end
	            	end
	            end
                
	            if msg ~= "" then
	            	--todo
	            	require("hall.GameCommon"):showAlert(false, "提示：" .. msg .. "ip地址相同，谨防作弊", 300)
	            	require("hall.GameCommon"):showAlert(true, "提示：" .. msg .. "ip地址相同，谨防作弊", 300)
	            end


end

function YKMJReceiveHandle:SVR_MSG_FACE(pack)
	if SCENENOW["name"] == run_scene_name then
		local seatId = YKMJ_SEAT_TABLE[pack.uid .. ""]
		local sex = YKMJ_USERINFO_TABLE[seatId .. ""].sex
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
function YKMJReceiveHandle:SVR_HAIDI_CARD(pack)
	YKMJ_REMAIN_CARDS_COUNT = 0
	gamePlaneOperator:showRemainCardsCount()
	manyouPlaneOperator:show(pack.card, pack.uid)
end

function YKMJReceiveHandle:SVR_LIANGDAO_REMAID(pack)
	YKMJ_ROOM.dianpao_card = pack.card

	local desc = "不能点炮，请重新出牌\n\n"

	desc = desc .. "接炮的玩家："

	for k,v in pairs(pack.winSeats) do
		desc = desc .. YKMJ_USERINFO_TABLE[v .. ""].nick .. "  "
	end

	require("hall.GameCommon"):showAlert(true, desc, 300)

	YKMJ_CHUPAI = 1
end

--出牌错误返回
function YKMJReceiveHandle:SVR_CHUPAI_ERROR(pack)
	local errorCode = pack.errorCode

	if errorCode == 1 then
		--todo
		YKMJ_CHUPAI = 1
	elseif errorCode == 2 then
		YKMJ_CHUPAI = 1
		require("hall.GameCommon"):showAlert(true, "正在等待自己或者其他玩家操作", 200)
	elseif errorCode == 3 then
		YKMJ_CHUPAI = 0
	elseif errorCode == 4 then
		YKMJ_CHUPAI = 1
	end
end

--获取玩家显示的位置号 0自己，1左边玩家，2对家，3右边玩家
function YKMJReceiveHandle:getIndex(uid)

	if tonumber(uid) == tonumber(UID) then
		return 0
	end
	local other_seat  = YKMJ_ROOM.User[uid]
	--dump( YKMJ_ROOM.User, " YKMJ_ROOM.User")

	-- --print(other_seat,bm.User.Seat,"2")
	local other_index = other_seat - bm.User.Seat
	if other_index < 0 then
		other_index = other_index + 4
	end
	-- --print(other_index,"3")
	   
	if other_index == 1 then
    	other_index = 3
    elseif other_index == 3 then
    	other_index = 1 
    end

	return other_index

end

--漫游
function YKMJReceiveHandle:SVR_MANYOU(pack)
	-- manyouPlaneOperator:show()
end

--显示倒计时器
function YKMJReceiveHandle:showTimer(uid,time)

	local scenes = SCENENOW['scene']

	if SCENENOW['name'] ~= run_scene_name then
		return
	end

	--设置显示计时器
	scenes:show_timer_visible(true)

	--初始化计时器
	scenes:init_clock()

	if YKMJ_ROOM.timerid then
		bm.SchedulerPool:clear(YKMJ_ROOM.timerid)
	end

	local index = self:getIndex(uid)
	scenes:show_timer_index(index)
	YKMJ_ROOM.timer   = time
	self.timecount_ = 0 
	YKMJ_ROOM.timerid = nil

	YKMJ_ROOM.timerid = bm.SchedulerPool:loopCall(function()

		self.timecount_ = self.timecount_ + 1

		if YKMJ_ROOM.timer and self.timecount_ % 5 == 0 then
			YKMJ_ROOM.timer  = YKMJ_ROOM.timer - 1
		end

		if YKMJ_ROOM.timer and YKMJ_ROOM.timer >= 0 and YKMJ_ROOM.timer <= 9 then
			local scenes  = SCENENOW['scene']
			if SCENENOW['name'] == run_scene_name and scenes.show_timer_num then
				--显示时间数字
				scenes:show_timer_num(YKMJ_ROOM.timer)
				--
				scenes:showClock(index,YKMJ_ROOM.timer,true)
			end
		end
		
		return true

	end,0.2)
	
end
-------------------------------------------------------------------------------------------------------------------

--协议相关

--麻将游戏加载请求方法
function YKMJReceiveHandle:callFunc(pack)

	if self.func_[pack.cmd] and self.func_[pack.cmd][1] then
        self.func_[pack.cmd][1](pack)
    end

end
-------------------------------------------------------------------------------------------------------------------

--进出房间相关
--用户进入房间
function YKMJReceiveHandle:SVR_LOGIN_ROOM_BROADCAST(pack)

	--dump(pack ,"-----用户进入房间-----")
	if pack ~= nil then
		self:showPlayer(pack)

		local uid_arr = {}

		for k,v in pairs(YKMJ_USERINFO_TABLE) do
			table.insert(uid_arr, v.uid)
		end

		require("hall.GameSetting"):setPlayerUid(uid_arr)
	end

end

--处理进入房间
function YKMJReceiveHandle:SVR_GET_ROOM_OK(pack_data)
	-- --print("---------------------------SVR_GET_ROOM_OK----------------------------------")
	--dump(pack_data)
	-- --print("denglusuccess table id is ",pack_data['tid'],bm.isGroup,USER_INFO["activity_id"])

	-- --print("group test")
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
    	-- --print("sending----------------1001............")
	else
		-- --print("group test ok")

		local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_LOGIN_ROOM_GROUP)
        :setParameter("tableid", pack_data['tid'])
        :setParameter("nUserId", USER_INFO["uid"])
        :setParameter("strkey", json.encode("kadlelala"))
        :setParameter("strinfo", USER_INFO["user_info"])
      	:setParameter("iflag", 2)
        :setParameter("version", 1)
        :setParameter("activity_id", USER_INFO["activity_id"])
        :build()
    	bm.server:send(pack)
    	-- --print("sending----------------1001............")
	end
	
end

--登录房间成功
function YKMJReceiveHandle:SVR_LOGIN_ROOM(pack)
   
	SCENENOW['scene']:removeChildByName("loading")
	if SCENENOW['name'] ~= run_scene_name then
		return
	end	

    PLAYERNUM = pack.playercount

	YKMJ_GAME_STATUS = 0

	YKMJ_USERINFO_TABLE = {}
	
	
	--dump(pack, "-----登录房间成功-----")

	YKMJ_GROUP_ENDING_DATA = nil

	bm.User = {}
	YKMJ_MY_USERINFO.seat_id = pack.seat_id
	YKMJ_MY_USERINFO.coins      = pack.gold 

	YKMJ_ROOM.base      = pack.base

	--绘制自己的信息
	YKMJ_MY_USERINFO.photoUrl = USER_INFO["icon_url"]
	YKMJ_MY_USERINFO.nick = USER_INFO["nick"]
	YKMJ_MY_USERINFO.coins = pack["gold"] 
	YKMJ_MY_USERINFO.uid = USER_INFO["uid"]
	YKMJ_MY_USERINFO.sex = USER_INFO["sex"]
	YKMJ_SEAT_TABLE_BY_TYPE[CARD_PLAYERTYPE_MY .. ""] = pack.seat_id
	YKMJ_SEAT_TABLE[USER_INFO["uid"] .. ""] = pack.seat_id
	YKMJ_USERINFO_TABLE[pack.seat_id .. ""] = {}

	YKMJ_USERINFO_TABLE[pack.seat_id .. ""].photoUrl = USER_INFO["icon_url"]
	YKMJ_USERINFO_TABLE[pack.seat_id .. ""].uid = USER_INFO["uid"]
	YKMJ_USERINFO_TABLE[pack.seat_id .. ""].nick = USER_INFO["nick"]
	YKMJ_USERINFO_TABLE[pack.seat_id .. ""].coins = pack["gold"] 
	YKMJ_USERINFO_TABLE[pack.seat_id .. ""].sex = USER_INFO["sex"]
	local infoPlane = gamePlaneOperator:showPlayerInfo(CARD_PLAYERTYPE_MY, YKMJ_MY_USERINFO)
	local point = cc.p(infoPlane:getAnchorPoint().x * infoPlane:getSize().width-14, infoPlane:getAnchorPoint().y * infoPlane:getSize().height+13)

	YKMJ_ROOM.positionTable[USER_INFO["uid"] .. ""] = infoPlane:convertToWorldSpace(point)

	local position = YKMJ_ROOM.positionTable[USER_INFO["uid"] .. ""]
	if position then
		require("hall.view.voicePlayView.voicePlayView"):updateUserPosition(tonumber(USER_INFO["uid"]),position)
	end
    
    --设置自己已准备
    gamePlaneOperator:setReadyStatus(CARD_PLAYERTYPE_MY)

	--绘制其他玩家
	if pack.user_mount > 0  then
		for i,v in pairs(pack.users_info) do
			YKMJReceiveHandle:showPlayer(v)
		end
	end

	SCENENOW["scene"]:ShowRecordButton()

	local uid_arr = {}

	for k,v in pairs(YKMJ_USERINFO_TABLE) do
		table.insert(uid_arr, v.uid)
	end

	require("hall.GameSetting"):setPlayerUid(uid_arr)

	--绘制其他元素
	-- scenes:set_basescole_txt(YKMJ_ROOM.base)

	-- if bm.isGroup  then --
 --    if require("hall.gameSettings"):getGameMode() == "group" then
	-- 	USER_INFO["base_chip"] = YKMJ_ROOM.base;

	-- else
	-- 	SCENENOW["scene"]:gameReady();
	-- end

	voiceUtils:playBackgroundMusic()

	sendHandle:readyNow()

	SCENENOW["scene"]:ShowChatButton()

	--发送当前用户地理位置
	sendHandle:CLIENT_CMD_FORWARD_MESSAGE("")

end

--登陆错误
function YKMJReceiveHandle:SVR_ERROR(pack)
	
	--dump(pack, "-----登陆错误-----")

	local errcode = "error"
	local showBtn = 2
	if pack["type"] == 9 then
		errcode = "change_money"
		showBtn = 1
	end
	require("hall.GameTips"):showTips(tbErrorCode[pack["type"]],errcode,showBtn)

end

--用户重登房间  1009
function YKMJReceiveHandle:SVR_REGET_ROOM(pack)

	--dump(pack, "-----重连房间成功-----")


	YKMJ_GROUP_ENDING_DATA = nil

	SCENENOW['scene']:removeChildByName("loading")

	local scenes  = SCENENOW['scene']
	if SCENENOW['name'] ~= run_scene_name then
		return
	end	
    
	YKMJ_ROOM.isBufenLiang = pack.isBufenLiang

	YKMJ_GAME_STATUS = 1

	PLAYERNUM = pack.nPlayerCount+1

	scenes:hideCloseRoomButton()
	scenes:ShowSettingButton()
	scenes:hideShareButton()
	scenes:ShowRecordButton()
	scenes:ShowChatButton()

	gamePlaneOperator:clearGameDatas()

	gamePlaneOperator:showCenterPlane()

	YKMJ_REMAIN_CARDS_COUNT = pack.card_less

	YKMJ_MY_USERINFO.seat_id = pack.seat_id
	YKMJ_MY_USERINFO.coins      = pack.gold 

	--绘制自己的信息
	YKMJ_MY_USERINFO.photoUrl = USER_INFO["icon_url"]
	YKMJ_MY_USERINFO.nick = USER_INFO["nick"]
	YKMJ_MY_USERINFO.coins = pack["gold"] 
	YKMJ_MY_USERINFO.uid = USER_INFO["uid"]
	YKMJ_MY_USERINFO.sex = USER_INFO["sex"]
	YKMJ_SEAT_TABLE_BY_TYPE[CARD_PLAYERTYPE_MY .. ""] = pack.seat_id
	YKMJ_SEAT_TABLE[USER_INFO["uid"] .. ""] = pack.seat_id
	YKMJ_USERINFO_TABLE[pack.seat_id .. ""] = {}

	YKMJ_USERINFO_TABLE[pack.seat_id .. ""].photoUrl = USER_INFO["icon_url"]
	YKMJ_USERINFO_TABLE[pack.seat_id .. ""].uid = USER_INFO["uid"]
	YKMJ_USERINFO_TABLE[pack.seat_id .. ""].nick = USER_INFO["nick"]
	YKMJ_USERINFO_TABLE[pack.seat_id .. ""].coins = pack["gold"] 
	YKMJ_USERINFO_TABLE[pack.seat_id .. ""].sex = USER_INFO["sex"]

	local infoPlane = gamePlaneOperator:showPlayerInfo(CARD_PLAYERTYPE_MY, YKMJ_MY_USERINFO)
	local point = cc.p(infoPlane:getAnchorPoint().x * infoPlane:getSize().width-10, infoPlane:getAnchorPoint().y * infoPlane:getSize().height+10)

	YKMJ_ROOM.positionTable[USER_INFO["uid"] .. ""] = infoPlane:convertToWorldSpace(point)
	
	local position = YKMJ_ROOM.positionTable[USER_INFO["uid"] .. ""]
	if position then
		require("hall.view.voicePlayView.voicePlayView"):updateUserPosition(tonumber(USER_INFO["uid"]),position)
	end

	--绘制其他玩家
	if pack.nPlayerCount > 0  then
		for i,v in pairs(pack.users_info) do
			YKMJReceiveHandle:showPlayer(v)
		end
	end

	local uid_arr = {}

	for k,v in pairs(YKMJ_USERINFO_TABLE) do
		table.insert(uid_arr, v.uid)
	end

	require("hall.GameSetting"):setPlayerUid(uid_arr)

	voiceUtils:playBackgroundMusic()

	-- if pack.jiapiaoStatus ~= 2 then
	-- 	--todo
	-- 	-- if pack.piao >= 0 then
	-- 	-- 	--todo
	-- 	-- 	gamePlaneOperator:showPiaoPlane(CARD_PLAYERTYPE_MY, pack.piao, true)
	-- 	-- end

	-- 	-- for k,v in pairs(pack.users_info) do
	-- 	-- 	if v.piao >= 0 then
	-- 	-- 		--todo
	-- 	-- 		local pt = cardUtils:getPlayerType(v.seat_id)
	-- 	-- 		gamePlaneOperator:showPiaoPlane(pt, v.piao, true)
	-- 	-- 	end
	-- 	-- end

	-- 	-- if pack.jiapiaoStatus == 1 then
	-- 	-- 	--todo
	-- 	-- 	if pack.piao >= 0 then
	-- 	-- 		--todo
	-- 	-- 		gamePlaneOperator:showPiaoImg(CARD_PLAYERTYPE_MY, pack.piao, true)
	-- 	-- 	else
	-- 	-- 		gamePlaneOperator:showJiapiaoPlane(true)
	-- 	-- 	end

	-- 	-- 	for k,v in pairs(pack.users_info) do
	-- 	-- 		if v.piao >= 0 then
	-- 	-- 			--todo
	-- 	-- 			local pt = cardUtils:getPlayerType(v.seat_id)
	-- 	-- 			gamePlaneOperator:showPiaoImg(pt, v.piao, true)
	-- 	-- 		end
	-- 	-- 	end

	-- 	-- 	return
	-- 	-- end
	-- end


	YKMJ_ZHUANG_UID = YKMJ_USERINFO_TABLE[pack.m_nBankSeatId .. ""].uid

	local zhuangPlayerType = cardUtils:getPlayerType(pack.m_nBankSeatId)
	gamePlaneOperator:showZhuang(zhuangPlayerType)

    if require("hall.gameSettings"):getGameMode() == "group" then
		USER_INFO["base_chip"] = YKMJ_ROOM.base;

	else
		SCENENOW["scene"]:gameReady();
	end

	local myCards = pack.handCards

	table.sort(myCards)
----------------------------------------------------重绘他人的牌-------------------------------------------  
    --重绘其他玩家的牌
	if pack.nPlayerCount > 0  then
		for i,v in pairs(pack.users_info) do
			local gameInfo = {}
			gameInfo.porg = {}
			gameInfo.hand = {}

			gameInfo.out = {}
          
			YKMJ_GAMEINFO_TABLE[pack.users_info[i].seat_id .. ""] = gameInfo
            
			-- if v.countForTing > 0 then
			-- 	--todo
			-- 	YKMJ_GAMEINFO_TABLE[v.seat_id .. ""].ting = 1
			-- 	YKMJ_GAMEINFO_TABLE[v.seat_id .. ""].hand = v.handCards
			-- 	YKMJ_GAMEINFO_TABLE[v.seat_id .. ""].anke = v.ankeCards
			-- else
			-- 	YKMJ_GAMEINFO_TABLE[v.seat_id .. ""].ting = 0
				for i=1,pack.users_info[i].countHandCards do
					table.insert(gameInfo.hand, 0)
				end
			-- end

			local playerType = cardUtils:getPlayerType(pack.users_info[i].seat_id)
			gamePlaneOperator:redrawGameInfo(playerType, pack.users_info[i])
		end
	end

		--------------会牌-------------

	HUIPAI={}
    local PublicHuipai=pack.Huipai
    table.insert(HUIPAI,PublicHuipai)
    --显示墙头牌
    gamePlaneOperator:HuiPai(CARD_PLAYERTYPE_MY,pack.Qiangtoupai)
	-------------------------------

----------------------------------------------------重绘自己的牌-------------------------------------
    
    --打牌状态
	if pack.gameStatus == 2 then
		--打牌玩家为自己
		if tonumber(pack.currentPlayerId) == tonumber(USER_INFO["uid"]) then
			--todo
			YKMJ_CHUPAI = 1

			local newCard = pack.newCard
			
			for k,v in pairs(myCards) do
			--摸到的牌从卡组里删除
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

			YKMJ_GAMEINFO_TABLE[YKMJ_MY_USERINFO.seat_id .. ""] = myGameInfo

			-- if pack.liangStatus > 0 then
			-- 	--todo
			-- 	YKMJ_GAMEINFO_TABLE[YKMJ_MY_USERINFO.seat_id .. ""].anke = pack.ankeCards
			-- end

			if pack.tingHuCount >0 then
				YKMJ_GAMEINFO_TABLE[YKMJ_MY_USERINFO.seat_id .. ""].ting = 1
				YKMJ_GAMEINFO_TABLE[YKMJ_MY_USERINFO.seat_id .. ""].tingHuCards = pack.tingHuCards
			end

			-- 重绘桌面信息
			gamePlaneOperator:redrawGameInfo(CARD_PLAYERTYPE_MY, pack)

			local controlTable = {} 
			controlTable.type = CONTROL_TYPE_NONE

			-- if pack.liangStatus == 3 then
			-- 	--todo
			-- 	local hasGrepCard = false
			-- 	for k,v in pairs(pack.tingCards) do
			-- 		if v.card == newCard then
			-- 			--todo
			-- 			hasGrepCard = true
			-- 		end
			-- 	end

			-- 	local tCount = pack.tingCount
			-- 	if hasGrepCard then
			-- 		--todo
			-- 		tCount = tCount - 1
			-- 	end

			-- 	if tCount > 0 then
			-- 		--todo
			-- 		controlTable.type = CONTROL_TYPE_TING
			-- 		controlTable.gangSeq = {}
			-- 	end
			-- end

			if controlTable.type == CONTROL_TYPE_NONE or controlTable.type == CONTROL_TYPE_TING then
				--todo
				YKMJ_CHUPAI = 1
			else
				YKMJ_CHUPAI = 2
			end
            
      --       --可以听但是还没听的时候
   			-- if pack.tingCount>0 then
      --       	gamePlaneOperator:showTingCards(pack.tingCards)
      --       end


			cardUtils:getNewCard(YKMJ_MY_USERINFO.seat_id, newCard)

			gamePlaneOperator:getNewCard(CARD_PLAYERTYPE_MY, newCard,pack.tingCards)

			gamePlaneOperator:showControlPlane(controlTable)



			-- if pack.liangStatus == 1 or pack.liangStatus == 2 then
			-- 	gamePlaneOperator:showTingCards(pack.tingCards)
			-- end

        --打牌玩家为他人
		else
			YKMJ_CHUPAI = 0

			local myGameInfo = {}
			myGameInfo.porg = {}
			myGameInfo.hand = myCards
			myGameInfo.out = {}

			YKMJ_GAMEINFO_TABLE[YKMJ_MY_USERINFO.seat_id .. ""] = myGameInfo
            
            -- --dump(pack.tingHuCount,"pack.tingHuCount")
			-- if pack.tingHuCount > 0 then
			-- --todo
			-- 	YKMJ_GAMEINFO_TABLE[YKMJ_MY_USERINFO.seat_id .. ""].ting = 1
			-- 	-- YKMJ_GAMEINFO_TABLE[YKMJ_MY_USERINFO.seat_id .. ""].anke = pack.ankeCards
			-- 	YKMJ_GAMEINFO_TABLE[YKMJ_MY_USERINFO.seat_id .. ""].tingHuCards = pack.tingHuCards
			-- end
			-- 重绘桌面信息
			gamePlaneOperator:redrawGameInfo(CARD_PLAYERTYPE_MY, pack)
		end
        
        local t_seatId = YKMJ_SEAT_TABLE[pack.currentPlayerId .. ""]
		gamePlaneOperator:beginPlayCard(cardUtils:getPlayerType(t_seatId))

    --等待操作状态
	elseif pack.gameStatus == 3 then

		local controlTable = {}

		if pack.liangStatus ~= 1 and pack.liangStatus ~= 2 then
			--todo
			controlTable = cardUtils:getControlTable(pack.handle, pack.handleCard, 3, pack.ableGangCards)
		end

		-- if controlTable.type == CONTROL_TYPE_NONE or controlTable.type == CONTROL_TYPE_TING then
		-- 	--todo
		-- 	YKMJ_CHUPAI = 1
		-- else
			YKMJ_CHUPAI = 2
		-- end
		
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

		YKMJ_GAMEINFO_TABLE[YKMJ_MY_USERINFO.seat_id .. ""] = myGameInfo

			-- if pack.liangStatus > 0 then
			-- 	--todo
			-- 	YKMJ_GAMEINFO_TABLE[YKMJ_MY_USERINFO.seat_id .. ""].anke = pack.ankeCards
			-- end
			if pack.tingHuCount >0  then
			--todo
				YKMJ_GAMEINFO_TABLE[YKMJ_MY_USERINFO.seat_id .. ""].ting = 1
				YKMJ_GAMEINFO_TABLE[YKMJ_MY_USERINFO.seat_id .. ""].tingHuCards = pack.tingHuCards
			end

			-- if pack.liangStatus == 3 then
				
			-- end

		-- if pack.nTingFlag == 1 then
		-- 	--todo
		-- 		YKMJ_GAMEINFO_TABLE[YKMJ_MY_USERINFO.seat_id .. ""].ting = 1
		-- 		YKMJ_GAMEINFO_TABLE[YKMJ_MY_USERINFO.seat_id .. ""].anke = pack.ankeCards
		-- 		YKMJ_GAMEINFO_TABLE[YKMJ_MY_USERINFO.seat_id .. ""].tingHuCards = pack.tingHuCards
		-- 	end
		-- 重绘桌面信息
		gamePlaneOperator:redrawGameInfo(CARD_PLAYERTYPE_MY, pack)

		if isGrep then
			--todo
			cardUtils:getNewCard(YKMJ_MY_USERINFO.seat_id, newCard)

			gamePlaneOperator:getNewCard(CARD_PLAYERTYPE_MY, newCard,pack.tingCards)
		end

	   -- if YKMJ_SEAT_TABLE[pack.currentPlayerId .. ""]-1 ~=  then     --当前出牌玩家不是我的情况下
        local t_seatId = YKMJ_SEAT_TABLE[pack.currentPlayerId .. ""]
        gamePlaneOperator:beginPlayCard(cardUtils:getPlayerType(t_seatId-1))
	 --   elseif  YKMJ_SEAT_TABLE[pack.currentPlayerId .. ""] == YKMJ_SEAT_TABLE[USER_INFO["uid"] .. ""] then

		-- local removeResult = gamePlaneOperator:removeLatestOutCard(playerTypeT, pack.handleCard)
		-- if removeResult then  --如果这张牌存在,就打出去?
		-- 	gamePlaneOperator:playCard(playerTypeT, 0, pack.handleCard)
		-- end

		-- end   

	 --    --可以听但是还没听的时候
		-- if pack.tingCount>0 then
		-- 	gamePlaneOperator:showTingCards(pack.tingCards)
		-- end

		-- if pack.liangStatus == 1 or pack.liangStatus == 2 then
		-- 	gamePlaneOperator:showTingCards(pack.tingCards)
		-- end

	--其他状态
	else
		local myGameInfo = {}
		myGameInfo.porg = {}
		myGameInfo.hand = myCards
		myGameInfo.out = {}

		YKMJ_GAMEINFO_TABLE[YKMJ_MY_USERINFO.seat_id .. ""] = myGameInfo

		if pack.tingHuCount > 0 then
			--todo
			YKMJ_GAMEINFO_TABLE[YKMJ_MY_USERINFO.seat_id .. ""].ting = 1
			YKMJ_GAMEINFO_TABLE[YKMJ_MY_USERINFO.seat_id .. ""].tingHuCards = pack.tingHuCards
		end
		-- 重绘桌面信息
		gamePlaneOperator:redrawGameInfo(CARD_PLAYERTYPE_MY, pack)

	end
    
    gamePlaneOperator:rotateTimer(zhuangPlayerType)
	gamePlaneOperator:clearAllReadyStatus()

	--发送当前用户地理位置
	sendHandle:CLIENT_CMD_FORWARD_MESSAGE("")

end

--显示其他玩家
function YKMJReceiveHandle:showPlayer(pack)

	local scenes = SCENENOW['scene'] 
	if SCENENOW['name'] ~= run_scene_name then
		return
	end

	--新加入用户的用户信息
	local v = pack
	if YKMJ_GAME_STATUS == 0 then
	    local playerType = cardUtils:getPlayerType(v.seat_id)
		gamePlaneOperator:setReadyStatus(playerType)
	end
	
	--保存用户座位与id映射
	YKMJ_SEAT_TABLE[v.uid .. ""] = pack.seat_id

	if not YKMJ_USERINFO_TABLE[pack.seat_id .. ""] then
		--todo
		YKMJ_USERINFO_TABLE[pack.seat_id .. ""] = {}
	end

	YKMJ_USERINFO_TABLE[pack.seat_id .. ""].uid = pack.uid
	
    local playerType = cardUtils:getPlayerType(pack.seat_id)
    YKMJ_SEAT_TABLE_BY_TYPE[playerType .. ""] = pack.seat_id

    --获取用户信息
    local info = json.decode(pack.user_info)

    local nick_name 
    local user_gold
    local icon_url
    local sex_num
    if not info then
    	nick_name = pack.nick
    	user_gold = pack.user_gold 
    	icon_url = pack.icon_url
    	sex_num = pack.sex

    else
    	nick_name = pack.nick or info.nickName 
    	user_gold = pack.user_gold  or info.money 
    	icon_url = pack.icon_url or pack.smallHeadPhoto or info.photoUrl 
    	sex_num = pack.sex or info.sex

    end

    YKMJ_USERINFO_TABLE[pack.seat_id .. ""].nick = nick_name
    YKMJ_USERINFO_TABLE[pack.seat_id .. ""].coins = user_gold
    YKMJ_USERINFO_TABLE[pack.seat_id .. ""].photoUrl = icon_url
    YKMJ_USERINFO_TABLE[pack.seat_id .. ""].sex = sex_num

    local userInfo = {}
    userInfo["photoUrl"] = icon_url
    userInfo["nick"] = nick_name
    userInfo["coins"] = user_gold
    userInfo["uid"] = pack.uid
    userInfo["sex"] = sex_num

   	local infoPlane = gamePlaneOperator:showPlayerInfo(playerType, userInfo)
   	local point = cc.p(infoPlane:getAnchorPoint().x * infoPlane:getSize().width-10, infoPlane:getAnchorPoint().y * infoPlane:getSize().height+10)

   	YKMJ_ROOM.positionTable[pack.uid .. ""] = infoPlane:convertToWorldSpace(point)
   	local position = YKMJ_ROOM.positionTable[pack.uid .. ""]
	if position then
		require("hall.view.voicePlayView.voicePlayView"):updateUserPosition(tonumber(pack.uid),position)
	end
end

--用户退出房间
function YKMJReceiveHandle:SVR_QUIT_ROOM(pack)

	--dump(pack,"-----用户退出房间-----")

	if SCENENOW['name'] ~= run_scene_name then
		return
	end

	local uid = pack.uid
	local seatId = YKMJ_SEAT_TABLE[uid .. ""]

	if not seatId then
		--todo
		return
	end

	table.remove(YKMJ_SEAT_TABLE, uid .. "")
	table.remove(YKMJ_USERINFO_TABLE, seatId .. "")
	table.remove(YKMJ_GAMEINFO_TABLE, seatId .. "")

	local playerType = cardUtils:getPlayerType(seatId)
	table.remove(YKMJ_SEAT_TABLE_BY_TYPE, playerType .. "")

	if YKMJ_GAME_STATUS == 0 then
		--todo
		gamePlaneOperator:removePlayer(playerType)
	else
		gamePlaneOperator:showNetworkImg(playerType, true)
	end
	

	local uid_arr = {}

	for k,v in pairs(YKMJ_USERINFO_TABLE) do
		table.insert(uid_arr, v.uid)
	end

	require("hall.GameSetting"):setPlayerUid(uid_arr)
end

--用户退出游戏成功
function YKMJReceiveHandle:SVR_QUICK_SUC(pack)

	--dump(pack,"-----玩家退出游戏成功-----")
	audio.stopMusic(true)

	-- local mode = require("hall.gameSettings"):getGameMode()
	-- --print("SVR_QUICK_SUC mode",tostring(mode))
	-- -- if bm.isGroup then
 --    if mode == "group" then
	-- 	--todo
	-- 	--print("gExitGroupGame getGroupState",require("majiang.ddzSettings"):getGroupState())
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
function YKMJReceiveHandle:SVR_USER_READY_BROADCAST(pack)
	local seatId = YKMJ_SEAT_TABLE[pack.uid .. ""]
	local playerType = cardUtils:getPlayerType(seatId)
   
    gamePlaneOperator:setReadyStatus(playerType)

end
----------------------------------------------------------------------------------------------------------------

--用户操作相关
--服务器告知客户端可以进行的操作
function YKMJReceiveHandle:SVR_NORMAL_OPERATE(pack)

	--dump(pack, "-----服务器告知客户端可以进行的操作-----");

	local controlTable = cardUtils:getControlTable(pack.handle, pack.card, 1)

	gamePlaneOperator:showControlPlane(controlTable)
end


--广播用户进行了什么操作 4005
function YKMJReceiveHandle:SVR_PLAYER_USER_BROADCAST(pack)
	
	--dump(pack,"-----广播用户进行了什么操作-----")

	local scenes          = SCENENOW['scene']
	if SCENENOW["name"] ~= run_scene_name then
		return
	end

	local handle = pack.handle
	local value = bit.band(pack.card, 0xFF)
	local seatId = YKMJ_SEAT_TABLE[pack.uid .. ""]
	local playerType = cardUtils:getPlayerType(seatId)

	gamePlaneOperator:showNetworkImg(playerType,false)
    --听牌显示
	local tingSeq = pack.tingCards 
    --碰杠吃牌
	local progCards = cardUtils:processControl(seatId, handle, value)
	--牌的来源玩家
    local fromplayerType = cardUtils:getPlayerType(pack.lid)
    if fromplayerType==CARD_PLAYERTYPE_MY and playerType==CARD_PLAYERTYPE_MY then
    	 if bit.band(handle,GANG_TYPE_PG)>0 then   --暂时处理碰杠时候牌没移除的问题
       	 if not tolua.isnull(YKMJ_CURRENT_CARDNODE) then
			YKMJ_CURRENT_CARDNODE:removeFromParent()
		 end
		 end
    else   --在fromplayerType与playerType不同时为我的情况下
	   local removeResult = gamePlaneOperator:removeLatestOutCard(fromplayerType, value)   
	end

    --5个参数
	gamePlaneOperator:control(playerType, progCards,handle,tingSeq,fromplayerType)
	voiceUtils:playControlSound(seatId, handle)

	if playerType == CARD_PLAYERTYPE_MY then YKMJ_CHUPAI = 1
	else gamePlaneOperator:hideControlPlane(playerType)  --别人操作完之后隐藏自己的操作
	end
end
---------------------------------------------------------------------------------------------------------------

--托管相关
--广播用户托管
function YKMJReceiveHandle:SVR_ROBOT(pack)

	--dump(pack,"-----广播用户托管-----")

	local scenes = SCENENOW['scene']
	if SCENENOW["name"] ~= run_scene_name then
		return
	end

	if pack.uid == UID then
		local scenes  = SCENENOW['scene']
		if  pack.kind  == 1 then
			YKMJ_ROOM.tuoguan_ing = 1
			-- scenes:show_tuoguan_layout(true)
		else
			YKMJ_ROOM.tuoguan_ing = 0
			-- scenes:show_tuoguan_layout(false)
		end
	end

end
-------------------------------------------------------------------------------------------------------------------

--发牌相关
--发牌协议
function YKMJReceiveHandle:SVR_SEND_USER_CARD(pack)

	--dump(pack, "-----发牌协议-----")
    
    gamePlaneOperator:clearAllReadyStatus()
    gamePlaneOperator:clearGameDatas()
    --显示公共会牌
	local PublicHuipai=pack.Huipai  or 0 --公共会牌
	-- 
	local Qiangtoupai=pack.Qiangtoupai  or 0
	HUIPAI={}
    --创建会牌数组
	table.insert(HUIPAI,PublicHuipai)
	--显示墙头牌
    gamePlaneOperator:HuiPai(CARD_PLAYERTYPE_MY,Qiangtoupai)

	local scenes  = SCENENOW['scene']
	if SCENENOW['name'] ~= run_scene_name then
		return
	end	

	YKMJ_ROOM.isBufenLiang = pack.isBufenLiang

	gamePlaneOperator:clearPiaoImg()

	YKMJ_GAME_STATUS = 1

	scenes:hideCloseRoomButton()
	scenes:ShowSettingButton()
	scenes:hideShareButton()

	gamePlaneOperator:showCenterPlane()

	bm.palying = true
	bm.isRun=true

	YKMJ_ENDING_DATA = nil

	--记录庄家的座位
	bm.zuan_seat = pack.seat

	zhuangPlayerType = cardUtils:getPlayerType(bm.zuan_seat)
	gamePlaneOperator:rotateTimer(zhuangPlayerType)
	
	-- if bm.isGroup then
    if require("hall.gameSettings"):getGameMode() == "group" then
        --todo
        YKMJ_STATE = 2
    end

	--骰子动画
	-- aniUtils:shuaiZi(pack.shai)

	self:SchedulerSendCard(pack)
	-- bm.SchedulerPool:delayCall(YKMJReceiveHandle.SchedulerSendCard,2,pack)

end

--发牌
function YKMJReceiveHandle:SchedulerSendCard(pack)

	YKMJReceiveHandle:initCardForUser(pack)

	for i=0,PLAYERNUM-1 do
		YKMJReceiveHandle:showPlayerCards(i)
	end

	local playerType = cardUtils:getPlayerType(pack.seat)

	YKMJ_ZHUANG_UID = YKMJ_USERINFO_TABLE[pack.seat .. ""].uid

	gamePlaneOperator:showZhuang(playerType)

end

--牌库初始化
function YKMJReceiveHandle:initCardForUser(pack)

	for i=0,PLAYERNUM-1 do
		local gameInfo = {}
		gameInfo.porg = {}
		gameInfo.hand = {0,0,0,0,0,0,0,0,0,0,0,0,0}
		gameInfo.out = {}
		gameInfo.ting = 0
		-- YKMJ_ROOM.Gang[i]         = {}

		YKMJ_GAMEINFO_TABLE[i .. ""] = gameInfo
	end

	local myCards = pack.cards

	table.sort(myCards)

	YKMJ_GAMEINFO_TABLE[YKMJ_MY_USERINFO.seat_id .. ""].hand = myCards	--0号玩家的手牌

end

--显示玩家的牌
function YKMJReceiveHandle:showPlayerCards( seatId )

	local playerType = cardUtils:getPlayerType(seatId)

	gamePlaneOperator:showCards(playerType,{})

end

--显示庄家
function YKMJReceiveHandle:showZhuang(seat)

	local uid = UID

	if seat ~= bm.User.Seat then
		uid = YKMJ_ROOM.seat_uid[seat]
	end

	local index = self:getIndex(uid)
	local scenes = SCENENOW['scene']
	if SCENENOW['name'] ~= run_scene_name then
		return
	end
	
	scenes:show_widget_tip(index,true,"zuan_tip")

end
----------------------------------------------------------------------------------------------------------------

--换牌相关
--服务器告诉客户端，可以换牌
function YKMJReceiveHandle:SERVER_COMMAND_NEED_CHANGE_CARD(pack)

	--dump(pack, "-----可以换牌-----")

	local scenes = SCENENOW['scene'] 

	if SCENENOW['name'] ~= run_scene_name then
		return
	end

	YKMJ_ROOM.change_card_over = false
	--dump(pack, "SERVER_COMMAND_NEED_CHANGE_CARD")
	YKMJ_ROOM.cardHuan={};
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
function YKMJReceiveHandle:SERVER_COMMAND_CHANGE_CARD_RESULT(pack)

	--dump(pack, "-----服务器广播换牌的结果-----")

	local scenes  = SCENENOW['scene']

	if SCENENOW['name'] ~= run_scene_name then
		return
	end
	
	scenes:show_Text_18(false)

	YKMJ_ROOM.change_card_over = true
	--YKMJ_ROOM.cardHuan = YKMJ_ROOM.cardHuan or {} -- 可能存在没有换的状况

	local old_hand_card = YKMJ_ROOM.Card[0]['hand']
	--dump(old_hand_card,"old_hand_card") 
	if pack.mount > 0 then
		--0号玩家的手牌
		YKMJ_ROOM.Card[0]['hand'] = pack.cards	
		self:drawHandCard(0)
	end

	--dump(YKMJ_ROOM.Card[0]['hand'],"-----当前用户换牌后的新手牌-----") 

	YKMJ_ROOM.Card[0]['hand'] = MajiangcardHandle:sortCards(YKMJ_ROOM.Card[0]['hand'])

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
	for i,v in pairs(YKMJ_ROOM.Card[0]['hand']) do 

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

	bm.huanCardsStart = false

end
----------------------------------------------------------------------------------------------------------------------------------

--选缺相关
--开始选择缺门
function  YKMJReceiveHandle:SVR_START_QUE_CHOICE(pack)

	--dump(pack,"-----开始选择缺门-----")

	local scenes  = SCENENOW['scene']


	if SCENENOW['name'] ~= run_scene_name then
		return
	end

	scenes:show_other_xuanqueing(true)
	scenes:show_choosing_que(true)
	
end

--广播缺一门  通知用户选缺选了哪一门,这时游戏还没有开始，
function YKMJReceiveHandle:SVR_BROADCAST_QUE(pack)

	--dump(pack,"-----广播缺一门-----")


	bm.User.Que = nil
	YKMJ_ROOM.Que = true

	for i,v in pairs(pack.content) do
		self:hasChoiceQue(v.uid,v.que)
	end

end

--设置已经选缺
function YKMJReceiveHandle:hasChoiceQue(uid,que)

	--dump(uid,"-----设置已经选缺-----")

	local scenes  = SCENENOW['scene']
	if SCENENOW['name'] ~= run_scene_name then
		return
	end

	if uid == UID then
		-- --print("uid------------------que",que)
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
function YKMJReceiveHandle:SVR_PLAYING_UID_BROADCAST(pack)
	
	--dump(pack,"-----广播抓牌用户-----")

	local scenes  = SCENENOW['scene']
	if SCENENOW['name'] ~= run_scene_name then
		return
	end
    
	local playerType = cardUtils:getPlayerType(YKMJ_SEAT_TABLE[pack.uid .. ""])

	local seatId = YKMJ_SEAT_TABLE[pack.uid .. ""]

	if playerType ~= CARD_PLAYERTYPE_MY then
		--todo
		cardUtils:getNewCard(seatId, 0)

		gamePlaneOperator:getNewCard(playerType, 0)
	end

	YKMJ_REMAIN_CARDS_COUNT = pack.simplNum
	gamePlaneOperator:showRemainCardsCount()
end

--通知我抓的牌
function YKMJReceiveHandle:SVR_OWN_CATCH_BROADCAST(pack)

	--dump(pack,"-----通知我抓的牌-----")

	local scenes = SCENENOW['scene']

	if SCENENOW['name'] ~= run_scene_name then
		return
	end

	YKMJ_REMAIN_CARDS_COUNT = YKMJ_REMAIN_CARDS_COUNT - 1
	gamePlaneOperator:showRemainCardsCount()
    
	local tingSeq = pack.tingCards
	gamePlaneOperator:showCards(CARD_PLAYERTYPE_MY,tingSeq)

	local value = bit.band(pack.card, 0xFF)

	cardUtils:getNewCard(YKMJ_MY_USERINFO.seat_id, value)

	gamePlaneOperator:getNewCard(CARD_PLAYERTYPE_MY, value,pack.tingCards)

	local controlTable = cardUtils:getControlTable(pack.handle, pack.card, 2, pack.cards)

	if controlTable.type == CONTROL_TYPE_NONE or controlTable.type == CONTROL_TYPE_TING then
		YKMJ_CHUPAI = 1
	else
		YKMJ_CHUPAI = 2
	end

	gamePlaneOperator:showControlPlane(controlTable)

end
---------------------------------------------------------------------------------------------------------------

--出牌相关
--广播用户出牌
function YKMJReceiveHandle:SVR_SEND_MAJIANG_BROADCAST(pack)
	
	--dump(pack,"-----广播用户出牌-----")
	
	local scenes    = SCENENOW['scene']
	if SCENENOW['name'] ~= run_scene_name then
		return
	end

	local value = bit.band(pack.card, 0xFF)

	local handleResult = cardUtils:getControlTable(pack.handle, value, 1)

	if tonumber(pack.uid) ~= tonumber(USER_INFO["uid"]) then
		--todo
		gamePlaneOperator:showControlPlane(handleResult)
	else
		YKMJ_CHUPAI = 0
	end

	local seatId = YKMJ_SEAT_TABLE[pack.uid .. ""]
	local playerType = cardUtils:getPlayerType(seatId)

	gamePlaneOperator:showNetworkImg(playerType,false)

	local tag = cardUtils:playCard(seatId, value)
	gamePlaneOperator:playCard(playerType, tag, value)

	voiceUtils:playCardSound(seatId,pack.card)

end
---------------------------------------------------------------------------------------------------------------

--游戏广播相关
--广播结束游戏 没用
function YKMJReceiveHandle:SVR_GAME_OVER(pack)

	--dump(pack, "-----广播结束游戏 没用-----");
	require("hall.recordUtils.RecordUtils"):closeRecordFrame()
	YKMJ_GAME_STATUS = 0

	if YKMJ_ENDING_DATA then
		--todo
		if YKMJ_ROUND == YKMJ_TOTAL_ROUNDS then
			--todo
			require("yk_majiang.RoundEndingLayer"):showZhuaniao(YKMJ_ENDING_DATA, true)
		else
			require("yk_majiang.RoundEndingLayer"):showZhuaniao(YKMJ_ENDING_DATA, false)
		end
	end	
end

--广播刮风下雨（返回）杠
function YKMJReceiveHandle:SVR_GUFENG_XIAYU(pack)

	--dump(pack, "-----广播刮风下雨-----");

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
		--print("....error..............pack.gangType............",pack.gangType)
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
function YKMJReceiveHandle:SVR_HUPAI_BROADCAST(pack)
end
------------------------------------------------------------------------------------------------------------------

--结算相关
--结算协议   4008
function YKMJReceiveHandle:SVR_ENDDING_BROADCAST(pack)

	--dump(pack,"-----一盘结束，进行结算-----")

	for i=1,table.getn(pack.players) do
		local userInfo = YKMJ_USERINFO_TABLE[(i - 1) .. ""]
		userInfo.coins = pack.players[i].coins 

		local playerType = cardUtils:getPlayerType(i - 1)

		gamePlaneOperator:showPlayerInfo(playerType, userInfo)
	end

	YKMJ_ENDING_DATA = pack

    gamePlaneOperator:HideHuiPaiPlane()

	for k,v in pairs(pack.players) do
		if v.huTypeCount > 0 then
			--todo
			local playerType = cardUtils:getPlayerType(k - 1)
			gamePlaneOperator:showCardsForHu(playerType, v.remainCards,pack.huCard)
		end
	end

	require("yk_majiang.RoundEndingLayer"):setIsShow(true)
end

--显示当轮结算界面
function YKMJReceiveHandle:showRoundResult(pack)

	--假如是最后一轮，则不需要弹出一轮结算
	if bm.round == bm.round_total then
		return
	end

	--dump(pack, "-----一轮结算信息-----")
	--dump(USER_INFO["user_info"], "-----当前用户信息-----")
	--dump(YKMJ_ROOM, "-----显示房间信息-----")

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

    		--dump(bm.zuan_seat, "----庄家座位-----")
    		--dump(bm.User.Seat, "----玩家座位-----")

    		--判断是否为庄家
    		if bm.User.Seat == bm.zuan_seat then
    			zuan_iv:setVisible(true)
    		else
    			zuan_iv:setVisible(false)
    		end

    	else
    		--其他用户信息
    		local user_info = YKMJ_ROOM.UserInfo[v.uid]
    		local other_user_info = json.decode(user_info.user_info)
    		name_tt:setString(other_user_info.nickName)

    		--dump(bm.zuan_seat, "----庄家座位-----")
    		--dump(user_info.seat_id, "----玩家座位-----")

    		--判断是否为庄家
    		if user_info.seat_id == bm.zuan_seat then
    			zuan_iv:setVisible(true)
    		else
    			zuan_iv:setVisible(false)
    		end

    	end

    	--显示用户手牌
    	-- --dump(YKMJ_ROOM.Card[k], "-----"... tostring(index) ..."用户手牌-----")
    	local showCard_ly = item_ly:getChildByName("showCard_ly")
    	local userleftcard = v.userleftcard
    	--dump(userleftcard,"-----" .. tostring(index) .. "用户手牌-----")
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
	    		--dump(hucontent,"-----" .. tostring(index) .. "胡的内容----")

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
			-- 	--print("收钱玩家id",k,v)
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
function YKMJReceiveHandle:SVR_GET_CHIP(pack)
	-- if bm.isGroup then
    if require("hall.gameSettings"):getGameMode() == "group" then
		--todo
		require("majiang.gameScene"):onNetGetChip(pack)
	end
	
end

--请求兑换筹码返回
function YKMJReceiveHandle:SVR_CHANGE_CHIP(pack)
	
	--dump(pack, "-----请求兑换筹码返回------")
	-- if bm.isGroup  then
    if require("hall.gameSettings"):getGameMode() == "group" then
			
		require("majiang.gameScene"):onChipSuccess(pack)
	end

end

--组局时长
function YKMJReceiveHandle:SVR_GROUP_TIME(pack)


	--dump(pack, "-----组局时长-----")

	--  加入当前游戏模式是组局 if bm.isGroup then
    if require("hall.gameSettings"):getGameMode() == "group" then

    	--记录当前局数
		YKMJ_ROUND = pack.round + 1

		--记录总局数
		YKMJ_TOTAL_ROUNDS = pack.round_total

    end
	
end

--组局排行榜（一局结算之后返回的数据）
function YKMJReceiveHandle:SVR_GROUP_BILLBOARD(pack)
    if pack then
    	YKMJ_GROUP_ENDING_DATA = pack
        -- if bm.isGroup then
    	if require("hall.gameSettings"):getGameMode() == "group" then

    		local isShow = require("yk_majiang.RoundEndingLayer"):isShow()
    		if not isShow then
    			--todo
    			require("yk_majiang.GroupEndingLayer"):showGroupResult(YKMJ_GROUP_ENDING_DATA)
    		end

            -- require("majiang.gameScene"):onNetBillboard(pack)
        end
    end

end

--组局历史记录
function YKMJReceiveHandle:SVR_GET_HISTORY(pack)

	--dump(pack, "-----组局历史记录-----")

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
function YKMJReceiveHandle:G2H_CMD_DISSOLVE_FAILED(pack)

	--dump("", "没有此房间，解散房间失败")

	require("hall.GameTips"):showTips("解散房间失败","disbandGroup_fail",2)

end

--广播桌子用户请求解散组局
function YKMJReceiveHandle:SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP(pack)

	--dump("", "广播桌子用户请求解散组局")

	-- require("hall.GameTips"):showTips("确认解散房间","cs_request_disbandGroup",1)

end

--广播桌子用户成功解散组局
function YKMJReceiveHandle:SERVER_BROADCAST_DISSOLVE_GROUP(pack)

	--dump("", "广播桌子用户成功解散组局")

	-- require("hall.GameTips"):showTips("解散房间成功","cs_disbandGroup_success",3)

	YKMJ_ROUND = YKMJ_TOTAL_ROUNDS

	if SCENENOW["scene"]:getChildByName("layer_tips") then
        SCENENOW["scene"]:removeChildByName("layer_tips")
    end

    if require("yk_majiang.RoundEndingLayer"):isShow() then
    	--todo
    	require("yk_majiang.RoundEndingLayer"):hide()
    	if YKMJ_ENDING_DATA then
    		--todo
    		require("yk_majiang.RoundEndingLayer"):show(YKMJ_ENDING_DATA, true)
    	end
    	
    end

end

--广播桌子用户解散组局 ，解散组局失败
function YKMJReceiveHandle:SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP(pack)

	--dump("", "广播桌子用户解散组局 ，解散组局失败")

	require("hall.GameTips"):showTips("解散房间失败","disbandGroup_fail",2)

end

--广播当前组局解散情况
function YKMJReceiveHandle:G2H_CMD_REFRESH_DISSOLVE_LIST(pack)

	--dump(pack, "-----广播当前组局解散情况-----")
	--dump(bm.Room, "-----广播当前房间情况-----")

	local applyId = pack.applyId
	local agreeNum = pack.agreeNum
	local agreeMember_arr = pack.agreeMember_arr

	local showMsg = ""

	--申请解散者信息
	local applyer_info = {}
	if tonumber(applyId) == tonumber(USER_INFO["uid"]) then
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
		local seatId = YKMJ_SEAT_TABLE[applyId .. ""]
		if seatId then
			--todo
			local userInfo = YKMJ_USERINFO_TABLE[seatId .. ""]

			if userInfo then
				--todo
				local nickName = userInfo.nick

				showMsg = "玩家【" .. nickName .. "】申请解散房间，请等待其他玩家同意（超过5分钟未做选择，则默认同意）" .. "\n"
			end
		end
		
	end
	
	local isMyAgree = 0
	if tonumber(applyId) ~= tonumber(USER_INFO["uid"]) then
		--假如申请者不是自己，添加自己的选择情况
		if agreeNum > 0 then
			for k,v in pairs(agreeMember_arr) do
				if tonumber(v) == tonumber(USER_INFO["uid"]) then
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
		if YKMJ_USERINFO_TABLE then
			for k,v in pairs(YKMJ_USERINFO_TABLE) do
				local uid = v.uid
				--排除掉申请者，申请者不需要显示到这里
				if tonumber(uid) ~= tonumber(applyId) and tonumber(uid) ~= tonumber(USER_INFO["uid"]) then

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

	if tonumber(applyId) == tonumber(USER_INFO["uid"]) then
		--假如申请者是自己，则直接显示其他用户的选择情况
		require("hall.GameTips"):showTips("提示", "agree_disbandGroup", 4, showMsg)
	else
		--申请者不是自己，根据自己的同意情况进行界面显示
		if isMyAgree == 1 then
			require("hall.GameTips"):showTips("提示", "agree_disbandGroup", 4, showMsg)
		else
			require("hall.GameTips"):showDisbandTips("提示", "YKMJ_request_disbandGroup", 1, showMsg)
		end
	end
	

end

---------------------------------------------------------------------------------------------------------------

--聊天相关
--收到聊天消息
function YKMJReceiveHandle:CHAT_MSG( pack )
	--dump(pack, "================CHAT_MSG========================")
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
function YKMJReceiveHandle:s2c_JOIN_MATCH_RETURN(pack)
	--print("===recieve====0x211====================")
	--dump(pack)
	--print("UID------------------",UID)
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
	--print("sending ------------------1001-------------")
end

function YKMJReceiveHandle:s2c_JOIN_MATCH_FAIL(pack)
	--print("0x7109==========return==========")
	--dump(pack)
	USER_INFO["match_fee"] = 0
    require("majiang.MatchSetting"):setJoinMatch(false)
end

function YKMJReceiveHandle:s2c_JOIN_MATCH_SUCCESS(pack)
	--print("0x7101==========return==========")
	--dump(pack)

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

function YKMJReceiveHandle:s2c_OTHER_PEOPLE_JOINT_IN(pack)
	--print("0x7103==========return==========")
	--dump(pack)
	require("majiang.MatchSetting"):setJoinMatch(true)
	require("majiang.MatchSetting"):joinMatch(pack.Usercount,pack.Totalcount)
end

function YKMJReceiveHandle:s2c_QUIT_MATCH_RETURN(pack)
	--print(" 0x7110==========return==========")
	--dump(pack)
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
            --print("match logout failed,error type:"..pack["Errortype"])
            require("majiang.MatchSetting"):setJoinMatch(true)
        end

    end
end

function YKMJReceiveHandle:s2c_GAME_BEGIN_LOGIC(pack)
	--print("0x7104==========return==========")
	--dump(pack)
	
	bm.User={}
	bm.User.Seat      = pack.seat_id
	bm.User.Golf      = pack.gold or pack.Matchpoint
	bm.User.Pque      = nil

	YKMJ_ROOM={}
	YKMJ_ROOM.User      = {}	
    YKMJ_ROOM.UserInfo  = {}
    YKMJ_ROOM.seat_uid  = {}
	YKMJ_ROOM.Card      = {}
	YKMJ_ROOM.Gang      = {}
	YKMJ_ROOM.base      = pack.base 

	YKMJ_ROOM.tuoguan_ing = 0

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
			YKMJReceiveHandle:showPlayer(v)
		end
	end

	--绘制其他内容
	scenes:set_basescole_txt(YKMJ_ROOM.base) 

	-- if bm.isGroup  then --
    if require("hall.gameSettings"):getGameMode() == "group" then
		USER_INFO["base_chip"]=YKMJ_ROOM.base;
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

function YKMJReceiveHandle:s2c_PAI_MING_MSG(pack)
	--print("0x7114==========return==========")
	--dump(pack)
end

function YKMJReceiveHandle:s2c_SVR_MATCH_WAIT(pack)
	--print("0x7113==========return==========")
	--dump(pack)
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

function YKMJReceiveHandle:s2c_GAME_STATE_MSG(pack)
	--print("0x7106==========return==========")
	--dump(pack)
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

function YKMJReceiveHandle:s2c_SVR_REGET_MATCH_ROOM(pack)
	
	----dump(pack)
	--重新调用1009部分的功能
	self:SVR_REGET_ROOM(pack)
	majiangGameMode = 2
	require("hall.gameSettings"):setGameMode("match")
	data_manager:set_game_mode(2)
	
	-- --print("recieve msg ----------7112--------------------------")
 --    --print("pack.m_nMatchRank--------------",pack.m_nMatchRank)--当前排名
 --    --print("pack.m_nPoint--------------",pack.m_nPoint)--当前积分
 --    --print("pack.m_strUserInfo--------------",pack.m_strUserInfo)--用户信息
    --pack.m_nplayecount

	--for index,user_data in pairs(pack.other_point) do
		-- --print("index.............",index)
		-- --print("user_data.m_userid--------------",user_data.m_userid)
		-- --print("user_data.m_nMatchRank--------------",user_data.m_nMatchRank)
		-- --print("user_data.m_nPoint--------------",user_data.m_nMatchRank)
	--end

	-- --print("index............over")
 --    --print("pack.m_nLevel--------------",pack.m_nLevel)
    USER_INFO["curr_match_level"] = pack.m_nLevel
    USER_INFO["match_fee"] = 100

    -- --print("pack.m_nSheaves--------------",pack.m_nSheaves)--第几局`
    -- --print("pack.m_nRound--------------",pack.m_nRound)--第几轮
    -- require("majiang.MatchSetting"):setCurrentRound(pack["m_nRound"],pack["m_nSheaves"])

    -- --print("pack.m_nLowPoint--------------",pack.m_nLowPoint)
    -- --print("pack.m_nNuber--------------",pack.m_nNuber)
    -- --print("pack.m_nCurrentCount--------------",pack.m_nCurrentCount)
    -- --print("pack.m_nstr--------------",pack.m_nstr)
    -- --print("pack.m_nFinalplayTimesInTable--------------",pack.m_nFinalplayTimesInTable)

    --require("majiang.HallHttpNet"):MatchloadBattles(4)

    data_manager:match_game_http(pack.m_nLevel)
    require("majiang.HallHttpNet"):requestIncentive(pack.m_nLevel)

 --    if pack.pHuSeatId == 1 then
	-- 	require("majiang.MatchSetting"):showMatchWait(true,"majiang")
	-- end

end
---------------------------------------------------------------------------------------------------------------

return YKMJReceiveHandle
