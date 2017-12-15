
-- --加载麻将设置类（麻将公共方法类）
-- require("majiang.setting_help")

--加载框架初始化类
require("framework.init")

local gamePlaneOperator = require("zz_majiang.operator.GamePlaneOperator")
-- local manyouPlaneOperator = require("zz_majiang.operator.ManyouPlaneOperator")

local cardUtils = require("zz_majiang.utils.cardUtils")

--加载大厅请求处理
local hallHandle = require("hall.HallHandle")

local voiceUtils = require("zz_majiang.utils.VoiceUtils")

--大厅套接字请求类
local hallPa = require("hall.HALL_PROTOCOL")

--麻将套接字请求类
local PROTOCOL = import("zz_majiang.handle.ZZMJProtocol")
setmetatable(PROTOCOL, {
		__index=hallPa
	})

local sendHandle = require("zz_majiang.handle.ZZMJSendHandle")

--定义麻将游戏处理类
local ZZMJReceiveHandle = class("ZZMJReceiveHandle",hallHandle)

local aniUtils = require("zz_majiang.utils.AniUtils")

--定义登录超时时间
local LOGIN_OUT_TIMER = 20

--定义麻将游戏界面名称
local run_scene_name = "zz_majiang.gameScene"

--扣除台费百分数
local percent_base = 0.20

local item_ly_list = {}

local liujuFlag = true

function ZZMJReceiveHandle:ctor()

	ZZMJReceiveHandle.super.ctor(self);

	--定义麻将游戏请求	
	local  func_ = {

		--用户自己退出成功
        [PROTOCOL.SVR_QUICK_SUC] = {handler(self, ZZMJReceiveHandle.SVR_QUICK_SUC)},
        --广播用户准备
        [PROTOCOL.SVR_USER_READY_BROADCAST] = {handler(self, ZZMJReceiveHandle.SVR_USER_READY_BROADCAST)},
        --登陆房间广播
        [PROTOCOL.SVR_LOGIN_ROOM_BROADCAST] = {handler(self, ZZMJReceiveHandle.SVR_LOGIN_ROOM_BROADCAST)},
        --广播玩家退出返回
        [PROTOCOL.SVR_QUIT_ROOM] = {handler(self, ZZMJReceiveHandle.SVR_QUIT_ROOM)},
        --发牌
        [PROTOCOL.SVR_SEND_USER_CARD] = {handler(self, ZZMJReceiveHandle.SVR_SEND_USER_CARD)},
        --开始选择缺一门
        [PROTOCOL.SVR_START_QUE_CHOICE] = {handler(self, ZZMJReceiveHandle.SVR_START_QUE_CHOICE)},
        --广播缺一门选择
        [PROTOCOL.SVR_BROADCAST_QUE] = {handler(self, ZZMJReceiveHandle.SVR_BROADCAST_QUE)},
        --当前抓牌用户广播
        [PROTOCOL.SVR_PLAYING_UID_BROADCAST] = {handler(self, ZZMJReceiveHandle.SVR_PLAYING_UID_BROADCAST)},
        --广播用户出牌
        [PROTOCOL.SVR_SEND_MAJIANG_BROADCAST] = {handler(self, ZZMJReceiveHandle.SVR_SEND_MAJIANG_BROADCAST)},
        --svr通知我抓的牌
        [PROTOCOL.SVR_OWN_CATCH_BROADCAST] = {handler(self, ZZMJReceiveHandle.SVR_OWN_CATCH_BROADCAST)},
        --广播用户进行了什么操作
        [PROTOCOL.SVR_PLAYER_USER_BROADCAST] = {handler(self, ZZMJReceiveHandle.SVR_PLAYER_USER_BROADCAST)},
        --广播胡
    	[PROTOCOL.SVR_HUPAI_BROADCAST]       = {handler(self, ZZMJReceiveHandle.SVR_HUPAI_BROADCAST)}, 
    	--结算
    	[PROTOCOL.SVR_ENDDING_BROADCAST] = {handler(self, ZZMJReceiveHandle.SVR_ENDDING_BROADCAST)}, 
    	--请求托管
    	[PROTOCOL.SVR_ROBOT] = {handler(self, ZZMJReceiveHandle.SVR_ROBOT)}, 
    	--出牌错误返回
    	-- [PROTOCOL.SVR_CHUPAI_ERROR] = {handler(self, ZZMJReceiveHandle.SVR_CHUPAI_ERROR)}, 
    	--海底牌 SVR_HAIDI_CARD
    	-- [PROTOCOL.SVR_HAIDI_CARD] = {handler(self, ZZMJReceiveHandle.SVR_HAIDI_CARD)}, 
    	--亮倒提示
    	-- [PROTOCOL.SVR_LIANGDAO_REMAID] = {handler(self, ZZMJReceiveHandle.SVR_LIANGDAO_REMAID)}, 
    	[PROTOCOL.SVR_MSG_FACE]={handler(self, ZZMJReceiveHandle.SVR_MSG_FACE)},
    	
    	[PROTOCOL.BROADCAST_USER_IP]={handler(self, ZZMJReceiveHandle.BROADCAST_USER_IP)},

    	-- [PROTOCOL.SVR_HUIPAI]={handler(self, ZZMJReceiveHandle.SVR_HUIPAI)},

    	-- [PROTOCOL.SVR_JIAPIAO]={handler(self, ZZMJReceiveHandle.SVR_JIAPIAO)},
    	-- [PROTOCOL.SVR_JIAPIAO_BROADCAST]={handler(self, ZZMJReceiveHandle.SVR_JIAPIAO_BROADCAST)},

    	--获取房间id结果
    	[PROTOCOL.SVR_GET_ROOM_OK]     = {handler(self, ZZMJReceiveHandle.SVR_GET_ROOM_OK)},
    	--登陆房间返回
        [PROTOCOL.SVR_LOGIN_ROOM]      = {handler(self, ZZMJReceiveHandle.SVR_LOGIN_ROOM)},
        --登陆错误
     	[PROTOCOL.SVR_ERROR]      = {handler(self, ZZMJReceiveHandle.SVR_ERROR)},
     	--用户重新登录普通房间的消息返回（4105(10进制s)）
     	[PROTOCOL.SVR_REGET_ROOM]      = {handler(self, ZZMJReceiveHandle.SVR_REGET_ROOM)},--重登
     	--服务器告知客户端可以进行的操作
     	[PROTOCOL.SVR_NORMAL_OPERATE]      = {handler(self, ZZMJReceiveHandle.SVR_NORMAL_OPERATE)},--广播可以进行的操作
     	--服务器告知客户端游戏结束
     	[PROTOCOL.SVR_GAME_OVER]      = {handler(self, ZZMJReceiveHandle.SVR_GAME_OVER)},
     	--广播刮风下雨（返回）杠
     	[PROTOCOL.SVR_GUFENG_XIAYU]      = {handler(self, ZZMJReceiveHandle.SVR_GUFENG_XIAYU)},


     	--用户聊天消息
     	[PROTOCOL.CHAT_MSG]      = {handler(self, ZZMJReceiveHandle.CHAT_MSG)},

     	--组局
     	--请求获取筹码返回
     	[PROTOCOL.SVR_GET_CHIP]     = {handler(self, ZZMJReceiveHandle.SVR_GET_CHIP)},
     	--请求兑换筹码返回
     	[PROTOCOL.SVR_CHANGE_CHIP]     = {handler(self, ZZMJReceiveHandle.SVR_CHANGE_CHIP)},
     	--组局时长
     	[PROTOCOL.SVR_GROUP_TIME]     = {handler(self, ZZMJReceiveHandle.SVR_GROUP_TIME)},
     	--组局排行榜
     	[PROTOCOL.SVR_GROUP_BILLBOARD]     = {handler(self, ZZMJReceiveHandle.SVR_GROUP_BILLBOARD)},
     	--组局历史记录
     	[PROTOCOL.SVR_GET_HISTORY]     = {handler(self, ZZMJReceiveHandle.SVR_GET_HISTORY)},
     	--漫游
     	-- [PROTOCOL.SVR_MANYOU] = {handler(self, ZZMJReceiveHandle.SVR_MANYOU)},

     	--没有此房间，解散房间失败
     	[PROTOCOL.G2H_CMD_DISSOLVE_FAILED]     = {handler(self, ZZMJReceiveHandle.G2H_CMD_DISSOLVE_FAILED)},
     	--广播桌子用户请求解散组局
     	[PROTOCOL.SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP]     = {handler(self, ZZMJReceiveHandle.SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP)},
     	--广播当前组局解散情况
     	[PROTOCOL.G2H_CMD_REFRESH_DISSOLVE_LIST]     = {handler(self, ZZMJReceiveHandle.G2H_CMD_REFRESH_DISSOLVE_LIST)},
     	--广播桌子用户成功解散组局
     	[PROTOCOL.SERVER_BROADCAST_DISSOLVE_GROUP]     = {handler(self, ZZMJReceiveHandle.SERVER_BROADCAST_DISSOLVE_GROUP)},
     	--广播桌子用户解散组局 ，解散组局失败
     	[PROTOCOL.SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP]     = {handler(self, ZZMJReceiveHandle.SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP)},

     	--换牌
     	--服务器告诉客户端，可以换牌
     	[PROTOCOL.SERVER_COMMAND_NEED_CHANGE_CARD]     = {handler(self, ZZMJReceiveHandle.SERVER_COMMAND_NEED_CHANGE_CARD)},
     	--//服务器广播换牌的结果 zsw
     	[PROTOCOL.SERVER_COMMAND_CHANGE_CARD_RESULT]     = {handler(self, ZZMJReceiveHandle.SERVER_COMMAND_CHANGE_CARD_RESULT)},

     	--比赛场相关
     	--用户请求进入比赛场的返回值
     	[PROTOCOL.s2c_JOIN_MATCH_RETURN]     = {handler(self, ZZMJReceiveHandle.s2c_JOIN_MATCH_RETURN)},
     	--进入比赛失败
     	[PROTOCOL.s2c_JOIN_MATCH_FAIL]     = {handler(self, ZZMJReceiveHandle.s2c_JOIN_MATCH_FAIL)},
     	-- 进入比赛成功
		[PROTOCOL.s2c_JOIN_MATCH_SUCCESS]     = {handler(self, ZZMJReceiveHandle.s2c_JOIN_MATCH_SUCCESS)},
		--同时，已经报名的玩家会收到其他玩家进入的消息
     	[PROTOCOL.s2c_OTHER_PEOPLE_JOINT_IN]     = {handler(self, ZZMJReceiveHandle.s2c_OTHER_PEOPLE_JOINT_IN)},
     	--返回退出比赛结果
     	[PROTOCOL.s2c_QUIT_MATCH_RETURN]     = {handler(self, ZZMJReceiveHandle.s2c_QUIT_MATCH_RETURN)},
     	--比赛开始逻辑0x7104//牌局，开始发送其他玩家信息
     	[PROTOCOL.s2c_GAME_BEGIN_LOGIC]     = {handler(self, ZZMJReceiveHandle.s2c_GAME_BEGIN_LOGIC)},
     	--每轮打完之后 会给玩家发送比赛状态信息0x7106
     	[PROTOCOL.s2c_GAME_STATE_MSG]     = {handler(self, ZZMJReceiveHandle.s2c_GAME_STATE_MSG)},
     	-- 比赛的过程中会收到比赛的排名信息  0x7114
     	[PROTOCOL.s2c_PAI_MING_MSG]     = {handler(self, ZZMJReceiveHandle.s2c_PAI_MING_MSG)},
     	--发送用户重连回比赛开赛后的等待界面
     	-- [PROTOCOL.s2c_SVR_MATCH_WAIT]     = {handler(self, ZZMJReceiveHandle.s2c_SVR_MATCH_WAIT)},
     	--用户重新登录比赛场房间的消息返回
     	-- [PROTOCOL.s2c_SVR_REGET_MATCH_ROOM] = {handler(self, ZZMJReceiveHandle.s2c_SVR_REGET_MATCH_ROOM)},

    }
    table.merge(self.func_, func_)

end


--会牌协议
function ZZMJReceiveHandle:SVR_HUIPAI(pack) 

	HUIPAI=pack.PrivateHuipai or {}
    local PublicHuipai=pack.Huipai
    table.insert(HUIPAI,PublicHuipai)
    
    gamePlaneOperator:HuiPai(CARD_PLAYERTYPE_MY,pack.Huipai)
end

--加注协议
function ZZMJReceiveHandle:SVR_JIAPIAO(pack)

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

--加注协议
function ZZMJReceiveHandle:SVR_JIAPIAO_BROADCAST(pack)
	local playerType = cardUtils:getPlayerType(pack.seatId)
	gamePlaneOperator:showPiaoImg(playerType, pack.jiapiao, true)
	gamePlaneOperator:showPiaoPlane(playerType, pack.jiapiao, true)
end

--广播用户IP
function ZZMJReceiveHandle:BROADCAST_USER_IP(pack)
	 local playeripdata = pack.playeripdata or {}
    for _,ip_data in pairs(playeripdata) do
      local ip_ = ip_data.ip or ""
      local uid_ = ip_data.uid or 0
      if uid_ ~= 0 then
        local seatId = ZZMJ_SEAT_TABLE[uid_ .. ""]

	    if seatId then
	        --todo

	        if ZZMJ_USERINFO_TABLE[seatId .. ""] then
	            --todo
	            ZZMJ_USERINFO_TABLE[seatId .. ""].ip = ip_

	            
	        end
	    end
      end
    end

    			local myIp = ""

	            if ZZMJ_MY_USERINFO.seat_id and ZZMJ_USERINFO_TABLE[ZZMJ_MY_USERINFO.seat_id .. ""] then
	            	--todo
	            	myIp = ZZMJ_USERINFO_TABLE[ZZMJ_MY_USERINFO.seat_id .. ""].ip
	            end
	    

	            local ipTable = {}
	            for k,v in pairs(ZZMJ_USERINFO_TABLE) do
	            	if v.ip and v.ip ~= myIp then
	            		--todo
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

--表情协议
function ZZMJReceiveHandle:SVR_MSG_FACE(pack)
	if SCENENOW["name"] == run_scene_name then
		local seatId = ZZMJ_SEAT_TABLE[pack.uid .. ""]
		local sex = ZZMJ_USERINFO_TABLE[seatId .. ""].sex
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
function ZZMJReceiveHandle:SVR_HAIDI_CARD(pack)
	ZZMJ_REMAIN_CARDS_COUNT = 0
	gamePlaneOperator:showRemainCardsCount()
	manyouPlaneOperator:show(pack.card, pack.uid)
end

function ZZMJReceiveHandle:SVR_LIANGDAO_REMAID(pack)
	ZZMJ_ROOM.dianpao_card = pack.card

	local desc = "不能点炮，请重新出牌\n\n"

	desc = desc .. "接炮的玩家："

	for k,v in pairs(pack.winSeats) do
		desc = desc .. ZZMJ_USERINFO_TABLE[v .. ""].nick .. "  "
	end

	require("hall.GameCommon"):showAlert(true, desc, 300)

	ZZMJ_CHUPAI = 1
end

--出牌错误返回
function ZZMJReceiveHandle:SVR_CHUPAI_ERROR(pack)
	local errorCode = pack.errorCode

	if errorCode == 1 then
		--todo
		ZZMJ_CHUPAI = 1
	elseif errorCode == 2 then
		ZZMJ_CHUPAI = 1
		require("hall.GameCommon"):showAlert(true, "正在等待自己或者其他玩家操作", 200)
	elseif errorCode == 3 then
		ZZMJ_CHUPAI = 0
	elseif errorCode == 4 then
		ZZMJ_CHUPAI = 1
	end
end

--获取玩家显示的位置号 0自己，1左边玩家，2对家，3右边玩家
function ZZMJReceiveHandle:getIndex(uid)

	if tonumber(uid) == tonumber(UID) then
		return 0
	end
	local other_seat  = ZZMJ_ROOM.User[uid]
	dump( ZZMJ_ROOM.User, " ZZMJ_ROOM.User")

	--print(other_seat,bm.User.Seat,"2")
	local other_index = other_seat - bm.User.Seat
	if other_index < 0 then
		other_index = other_index + 4
	end
	--print(other_index,"3")
	   
	if other_index == 1 then
    	other_index = 3
    elseif other_index == 3 then
    	other_index = 1 
    end

	return other_index
end

--漫游
function ZZMJReceiveHandle:SVR_MANYOU(pack)
	manyouPlaneOperator:show()
end

--显示倒计时器
function ZZMJReceiveHandle:showTimer(uid,time)

	local scenes = SCENENOW['scene']

	if SCENENOW['name'] ~= run_scene_name then
		return
	end

	--设置显示计时器
	scenes:show_timer_visible(true)

	--初始化计时器
	scenes:init_clock()

	if ZZMJ_ROOM.timerid then
		bm.SchedulerPool:clear(ZZMJ_ROOM.timerid)
	end

	local index = self:getIndex(uid)
	scenes:show_timer_index(index)
	ZZMJ_ROOM.timer   = time
	self.timecount_ = 0 
	ZZMJ_ROOM.timerid = nil

	ZZMJ_ROOM.timerid = bm.SchedulerPool:loopCall(function()

		self.timecount_ = self.timecount_ + 1

		if ZZMJ_ROOM.timer and self.timecount_ % 5 == 0 then
			ZZMJ_ROOM.timer  = ZZMJ_ROOM.timer - 1
		end

		if ZZMJ_ROOM.timer and ZZMJ_ROOM.timer >= 0 and ZZMJ_ROOM.timer <= 9 then
			local scenes  = SCENENOW['scene']
			if SCENENOW['name'] == run_scene_name and scenes.show_timer_num then
				--显示时间数字
				scenes:show_timer_num(ZZMJ_ROOM.timer)
				--
				scenes:showClock(index,ZZMJ_ROOM.timer,true)
			end
		end
		
		return true

	end,0.2)
end

--清理界面
function ZZMJReceiveHandle:clearUserView(index)

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

	if ZZMJ_ROOM.timerid then
		bm.SchedulerPool:clear(ZZMJ_ROOM.timerid)
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
function ZZMJReceiveHandle:callFunc(pack)

	if self.func_[pack.cmd] and self.func_[pack.cmd][1] then
        self.func_[pack.cmd][1](pack)
    end

end
-------------------------------------------------------------------------------------------------------------------

--进出房间相关
--用户进入房间
function ZZMJReceiveHandle:SVR_LOGIN_ROOM_BROADCAST(pack)
     
	dump(pack ,"-----用户进入房间-----")
	if pack ~= nil then
		self:showPlayer(pack)

		local uid_arr = {}

		for k,v in pairs(ZZMJ_USERINFO_TABLE) do
			table.insert(uid_arr, v.uid)
		end

		require("hall.GameSetting"):setPlayerUid(uid_arr)
	end
end

--处理进入房间
function ZZMJReceiveHandle:SVR_GET_ROOM_OK(pack_data)
	--print("---------------------------SVR_GET_ROOM_OK----------------------------------")
	dump(pack_data)
	--print("denglusuccess table id is ",pack_data['tid'],bm.isGroup,USER_INFO["activity_id"])

	--print("group test")
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
    	--print("sending----------------1001............")
	else
		--print("group test ok")

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
    	--print("sending----------------1001............")
	end
end

--登录房间成功
function ZZMJReceiveHandle:SVR_LOGIN_ROOM(pack)

	SCENENOW['scene']:removeChildByName("loading")
	if SCENENOW['name'] ~= run_scene_name then
		return
	end	
    
    --清除准备的手
    gamePlaneOperator:clearAllReadyStatus()

	ZZMJ_GAME_STATUS = 0

	ZZMJ_USERINFO_TABLE = {}
	
	dump(pack, "-----登录房间成功-----")

	ZZMJ_GROUP_ENDING_DATA = nil

	bm.User = {}
	ZZMJ_MY_USERINFO.seat_id = pack.seat_id
	ZZMJ_MY_USERINFO.coins      = pack.gold

	-- ZZMJ_ROOM = {}
	-- ZZMJ_ROOM.User      = {}	
 --    ZZMJ_ROOM.UserInfo  = {}
 --    ZZMJ_ROOM.seat_uid  = {}
	-- ZZMJ_ROOM.Card      = {}
	-- ZZMJ_ROOM.Gang      = {}
	ZZMJ_ROOM.base      = pack.base

	-- ZZMJ_ROOM.tuoguan_ing = 0
	--bm.display_scenes("majiang.scenes.MajiangroomScenes")

	-- SCENENOW["scene"]:removeSelf()
	-- SCENENOW["scene"] = nil;

	-- local sc = require("zz_majiang.gameScene"):new()
	-- SCENENOW["scene"] = sc
 --    --SCENENOW["scene"]:retain();
 --    SCENENOW["name"]  = "majiang.scenes.MajiangroomScenes";
	-- display.replaceScene(sc)

	-- local scenes = sc

	--绘制自己的信息
	ZZMJ_MY_USERINFO.photoUrl = USER_INFO["icon_url"]
	ZZMJ_MY_USERINFO.nick = USER_INFO["nick"]
	ZZMJ_MY_USERINFO.coins = pack["gold"]
	ZZMJ_MY_USERINFO.uid = USER_INFO["uid"]
	ZZMJ_MY_USERINFO.sex = USER_INFO["sex"]
	ZZMJ_SEAT_TABLE_BY_TYPE[CARD_PLAYERTYPE_MY .. ""] = pack.seat_id
	ZZMJ_SEAT_TABLE[USER_INFO["uid"] .. ""] = pack.seat_id
	ZZMJ_USERINFO_TABLE[pack.seat_id .. ""] = {}

	ZZMJ_USERINFO_TABLE[pack.seat_id .. ""].photoUrl = USER_INFO["icon_url"]
	ZZMJ_USERINFO_TABLE[pack.seat_id .. ""].uid = USER_INFO["uid"]
	ZZMJ_USERINFO_TABLE[pack.seat_id .. ""].nick = USER_INFO["nick"]
	ZZMJ_USERINFO_TABLE[pack.seat_id .. ""].coins = pack["gold"]
	ZZMJ_USERINFO_TABLE[pack.seat_id .. ""].sex = USER_INFO["sex"]


	dump(ZZMJ_GAME_PLANE, "zz_majiang test")
	local infoPlane = gamePlaneOperator:showPlayerInfo(CARD_PLAYERTYPE_MY, ZZMJ_MY_USERINFO)
	local point = cc.p(infoPlane:getAnchorPoint().x * infoPlane:getSize().width, infoPlane:getAnchorPoint().y * infoPlane:getSize().height)

	ZZMJ_ROOM.positionTable[USER_INFO["uid"] .. ""] = infoPlane:convertToWorldSpace(point)
    

    --设置自己已准备
    gamePlaneOperator:setReadyStatus(CARD_PLAYERTYPE_MY)

	--绘制其他玩家
	if pack.user_mount > 0  then
		for i,v in pairs(pack.users_info) do
			dump(pack, "player test")
			ZZMJReceiveHandle:showPlayer(v)
		end
	end

	SCENENOW["scene"]:ShowRecordButton()

	local uid_arr = {}

	for k,v in pairs(ZZMJ_USERINFO_TABLE) do
		table.insert(uid_arr, v.uid)
	end

	require("hall.GameSetting"):setPlayerUid(uid_arr)

	--绘制其他元素
	-- scenes:set_basescole_txt(ZZMJ_ROOM.base)

	-- if bm.isGroup  then --
 --    if require("hall.gameSettings"):getGameMode() == "group" then
	-- 	USER_INFO["base_chip"] = ZZMJ_ROOM.base;

	-- else
	-- 	SCENENOW["scene"]:gameReady();
	-- end

	voiceUtils:playBackgroundMusic()

	sendHandle:readyNow()

	SCENENOW["scene"]:ShowChatButton()
end

--登陆错误
function ZZMJReceiveHandle:SVR_ERROR(pack)
	
	dump(pack, "-----登陆错误-----")

	local errcode = "error"
	local showBtn = 2
	if pack["type"] == 9 then
		errcode = "change_money"
		showBtn = 1
	end
	require("hall.GameTips"):showTips(tbErrorCode[pack["type"]],errcode,showBtn)

end


---------------------------------------------------重连--------------------------------------------------------
--用户重登房间
function ZZMJReceiveHandle:SVR_REGET_ROOM(pack)

	dump(pack, "-----重连房间成功-----")

	ZZMJ_GROUP_ENDING_DATA = nil

	SCENENOW['scene']:removeChildByName("loading")

	local scenes  = SCENENOW['scene']
	if SCENENOW['name'] ~= run_scene_name then
		return
	end	

	ZZMJ_GAME_STATUS = 1

	scenes:hideCloseRoomButton()
	scenes:ShowSettingButton()
	scenes:hideShareButton()
	scenes:ShowRecordButton()
	scenes:ShowChatButton()

	gamePlaneOperator:clearGameDatas()

	gamePlaneOperator:showCenterPlane()

	ZZMJ_REMAIN_CARDS_COUNT = pack.card_less

	ZZMJ_MY_USERINFO.seat_id = pack.seat_id
	ZZMJ_MY_USERINFO.coins      = pack.gold

------------------------------------------------绘制杂项信息-----------------------------------------
	--绘制自己的信息
	ZZMJ_MY_USERINFO.photoUrl = USER_INFO["icon_url"]
	ZZMJ_MY_USERINFO.nick = USER_INFO["nick"]
	ZZMJ_MY_USERINFO.coins = pack["gold"]
	ZZMJ_MY_USERINFO.uid = USER_INFO["uid"]
	ZZMJ_MY_USERINFO.sex = USER_INFO["sex"]
	ZZMJ_SEAT_TABLE_BY_TYPE[CARD_PLAYERTYPE_MY .. ""] = pack.seat_id
	ZZMJ_SEAT_TABLE[USER_INFO["uid"] .. ""] = pack.seat_id
	ZZMJ_USERINFO_TABLE[pack.seat_id .. ""] = {}

	ZZMJ_USERINFO_TABLE[pack.seat_id .. ""].photoUrl = USER_INFO["icon_url"]
	ZZMJ_USERINFO_TABLE[pack.seat_id .. ""].uid = USER_INFO["uid"]
	ZZMJ_USERINFO_TABLE[pack.seat_id .. ""].nick = USER_INFO["nick"]
	ZZMJ_USERINFO_TABLE[pack.seat_id .. ""].coins = pack["gold"]
	ZZMJ_USERINFO_TABLE[pack.seat_id .. ""].sex = USER_INFO["sex"]

	local infoPlane = gamePlaneOperator:showPlayerInfo(CARD_PLAYERTYPE_MY, ZZMJ_MY_USERINFO)
	local point = cc.p(infoPlane:getAnchorPoint().x * infoPlane:getSize().width, infoPlane:getAnchorPoint().y * infoPlane:getSize().height)

	ZZMJ_ROOM.positionTable[USER_INFO["uid"] .. ""] = infoPlane:convertToWorldSpace(point)

	--绘制其他玩家
	if pack.nPlayerCount > 0  then
		for i,v in pairs(pack.users_info) do
			ZZMJReceiveHandle:showPlayer(v)
		end
	end

	local uid_arr = {}

	for k,v in pairs(ZZMJ_USERINFO_TABLE) do
		table.insert(uid_arr, v.uid)
	end
	require("hall.GameSetting"):setPlayerUid(uid_arr)

	voiceUtils:playBackgroundMusic()

	ZZMJ_ZHUANG_UID = ZZMJ_USERINFO_TABLE[pack.m_nBankSeatId .. ""].uid

	local zhuangPlayerType = cardUtils:getPlayerType(pack.m_nBankSeatId)
	gamePlaneOperator:showZhuang(zhuangPlayerType)

    if require("hall.gameSettings"):getGameMode() == "group" then
		USER_INFO["base_chip"] = ZZMJ_ROOM.base
	else
		SCENENOW["scene"]:gameReady()
	end
-----------------------------------------绘制其他玩家手牌-----------------------------------------------
	if pack.nPlayerCount > 0  then
		for i,v in pairs(pack.users_info) do
			local gameInfo = {}
			gameInfo.porg = {}
			gameInfo.hand = {}

			for i=1,pack.users_info[i].countHandCards do
				table.insert(gameInfo.hand, 0)
			end

			gameInfo.out = {}
            dump(pack.users_info[i].seat_id,"pack.users_info[i].seat_id")
			ZZMJ_GAMEINFO_TABLE[pack.users_info[i].seat_id .. ""] = gameInfo

			local playerType = cardUtils:getPlayerType(pack.users_info[i].seat_id)
			gamePlaneOperator:redrawGameInfo(playerType, pack.users_info[i])
		end
	end

------------------------------------------绘制自己的手牌和操作-----------------------------------------------
	local myCards = pack.handCards

	table.sort(myCards)

--打牌状态
	-- if pack.gameStatus == 2 then
 
		if pack.currentPlayerId == USER_INFO["seat_id"] then
			--todo
			ZZMJ_CHUPAI = 1

			-- local newCard = pack.newCard
			
			-- for k,v in pairs(myCards) do
			-- 	if v == newCard then
			-- 		--todo
			-- 		table.remove(myCards, k)
			-- 		break
			-- 	end

			-- 	if k == table.getn(myCards) then
			-- 		--todo
			-- 		newCard = v
			-- 		table.remove(myCards, k)
			-- 	end
			-- end

			local myGameInfo = {}
			myGameInfo.porg = {}
			myGameInfo.hand = myCards
			myGameInfo.out = {}

			ZZMJ_GAMEINFO_TABLE[ZZMJ_MY_USERINFO.seat_id .. ""] = myGameInfo


			-- 重绘桌面信息
			gamePlaneOperator:redrawGameInfo(CARD_PLAYERTYPE_MY, pack)

			local controlTable = {} 
			controlTable.type = CONTROL_TYPE_NONE

			if controlTable.type == CONTROL_TYPE_NONE or controlTable.type == CONTROL_TYPE_TING then
				--todo
				ZZMJ_CHUPAI = 1
			else
				ZZMJ_CHUPAI = 2
			end

			-- cardUtils:getNewCard(ZZMJ_MY_USERINFO.seat_id, newCard)

			-- gamePlaneOperator:getNewCard(CARD_PLAYERTYPE_MY, newCard)

			gamePlaneOperator:showControlPlane(controlTable)

		else
			ZZMJ_CHUPAI = 0

			local myGameInfo = {}
			myGameInfo.porg = {}
			myGameInfo.hand = myCards
			myGameInfo.out = {}

			ZZMJ_GAMEINFO_TABLE[ZZMJ_MY_USERINFO.seat_id .. ""] = myGameInfo
        --在听状态的话创建听牌数组 
		if pack.tingHuCount>0 then
			--todo
			ZZMJ_GAMEINFO_TABLE[ZZMJ_MY_USERINFO.seat_id .. ""].ting = 1
			ZZMJ_GAMEINFO_TABLE[ZZMJ_MY_USERINFO.seat_id .. ""].tingHuCards = pack.tingHuCards
		end
			-- 重绘桌面信息
			gamePlaneOperator:redrawGameInfo(CARD_PLAYERTYPE_MY, pack)
		end
     
        dump(pack.currentPlayerId,"当前玩家ID")
		local t_seatId = pack.currentPlayerId
		-- ZZMJ_SEAT_TABLE[pack.currentPlayerId .. ""]
	    dump(t_seatId,"当前玩家ID")
		gamePlaneOperator:beginPlayCard(cardUtils:getPlayerType(t_seatId))

--操作状态
	-- elseif pack.gameStatus == 3 then

		local controlTable = {}
        
         dump(pack.handleCard,"pack.handleCard")
		controlTable = cardUtils:getControlTable(pack.handle, pack.handleCard, 1)

		if controlTable.type == CONTROL_TYPE_NONE or controlTable.type == CONTROL_TYPE_TING then
			--todo
			ZZMJ_CHUPAI = 1
		else
			ZZMJ_CHUPAI = 2
		end
		
		gamePlaneOperator:showControlPlane(controlTable)


-------------------------------------------新抓的牌移到右侧及绘制手牌----------------------------------
		-- local newCard = pack.newCard
		-- local isGrep = false
			
		-- for k,v in pairs(myCards) do
		-- 	if v == newCard then
		-- 		--todo
		-- 		table.remove(myCards, k)
		-- 		isGrep = true
		-- 		break
		-- 	end
		-- end

		local myGameInfo = {}
		myGameInfo.porg = {}
		myGameInfo.hand = myCards
		myGameInfo.out = {}

		ZZMJ_GAMEINFO_TABLE[ZZMJ_MY_USERINFO.seat_id .. ""] = myGameInfo





		-- -- 重绘桌面信息
		-- gamePlaneOperator:redrawGameInfo(CARD_PLAYERTYPE_MY, pack)

  --       --手里有新抓到的牌
		-- if isGrep then
		-- 	--todo
		-- 	cardUtils:getNewCard(ZZMJ_MY_USERINFO.seat_id, newCard)

		-- 	gamePlaneOperator:getNewCard(CARD_PLAYERTYPE_MY, newCard)
		-- end
-----------------------------------------------------------------------------------------------

		if pack.currentPlayerId ~= USER_INFO["seat_id"] then
			--todo
			local playerTypeT = cardUtils:getPlayerType(pack.currentPlayerId)
				-- ZZMJ_SEAT_TABLE[pack.currentPlayerId .. ""]

			local removeResult = gamePlaneOperator:removeLatestOutCard(playerTypeT, pack.handleCard)

			if removeResult then
				--todo
				gamePlaneOperator:playCard(playerTypeT, 0, pack.handleCard)
			end
		end
     

     gamePlaneOperator:rotateTimer(zhuangPlayerType)
     gamePlaneOperator:clearAllReadyStatus()

	-- end --end gamestatus judge
end
----------------------------------------------------------------------------------------------------------------


--显示其他玩家
function ZZMJReceiveHandle:showPlayer(pack)

	local scenes = SCENENOW['scene'] 
	if SCENENOW['name'] ~= run_scene_name then
		return
	end

	--新加入用户的用户信息
	local v = pack

	if ZZMJ_GAME_STATUS == 0 then
	    local playerType = cardUtils:getPlayerType(v.seat_id)
		gamePlaneOperator:setReadyStatus(playerType)
	end
	--保存用户座位与id映射
	ZZMJ_SEAT_TABLE[v.uid .. ""] = pack.seat_id
	-- ZZMJ_USERINFO_TABLE[pack.seat_id] = pack 

	if not ZZMJ_USERINFO_TABLE[pack.seat_id .. ""] then
		--todo
		ZZMJ_USERINFO_TABLE[pack.seat_id .. ""] = {}
	end

	ZZMJ_USERINFO_TABLE[pack.seat_id .. ""].uid = pack.uid
	
    local playerType = cardUtils:getPlayerType(pack.seat_id)
    ZZMJ_SEAT_TABLE_BY_TYPE[playerType .. ""] = pack.seat_id

    dump(ZZMJ_SEAT_TABLE_BY_TYPE, "ZZMJ_SEAT_TABLE_BY_TYPE test")

    --设置用户已经准备
    -- scenes:show_hasselect(other_index, true)

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
    	user_gold = pack.user_gold or info.money 
    	icon_url = pack.icon_url or pack.smallHeadPhoto or info.photoUrl 
    	sex_num = pack.sex or info.sex

    end

    dump(info, "info test")
    dump(sex_num, "sex_num test")

    ZZMJ_USERINFO_TABLE[pack.seat_id .. ""].nick = nick_name
    ZZMJ_USERINFO_TABLE[pack.seat_id .. ""].coins = user_gold
    ZZMJ_USERINFO_TABLE[pack.seat_id .. ""].photoUrl = icon_url
    ZZMJ_USERINFO_TABLE[pack.seat_id .. ""].sex = sex_num

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

   	ZZMJ_ROOM.positionTable[pack.uid .. ""] = infoPlane:convertToWorldSpace(point)
end

--用户退出房间
function ZZMJReceiveHandle:SVR_QUIT_ROOM(pack)

	dump(pack,"-----用户退出房间-----")

	if SCENENOW['name'] ~= run_scene_name then
		return
	end

	local uid = pack.uid
	local seatId = ZZMJ_SEAT_TABLE[uid .. ""]

	if not seatId then
		--todo
		return
	end

	table.remove(ZZMJ_SEAT_TABLE, uid .. "")
	table.remove(ZZMJ_USERINFO_TABLE, seatId .. "")
	table.remove(ZZMJ_GAMEINFO_TABLE, seatId .. "")

	local playerType = cardUtils:getPlayerType(seatId)
	table.remove(ZZMJ_SEAT_TABLE_BY_TYPE, playerType .. "")

	if ZZMJ_GAME_STATUS == 0 then
		--todo
		gamePlaneOperator:removePlayer(playerType)
	else
		gamePlaneOperator:showNetworkImg(playerType, true)
	end
	

	local uid_arr = {}

	for k,v in pairs(ZZMJ_USERINFO_TABLE) do
		table.insert(uid_arr, v.uid)
	end

	require("hall.GameSetting"):setPlayerUid(uid_arr)
end

--用户退出游戏成功
function ZZMJReceiveHandle:SVR_QUICK_SUC(pack)

	dump(pack,"-----玩家退出游戏成功-----")
	audio.stopMusic(true)
end

--用户准备相关
--广播用户准备
function ZZMJReceiveHandle:SVR_USER_READY_BROADCAST(pack)
    --print("用户准备测试:" .. pack.uid)
    local seatId = ZZMJ_SEAT_TABLE[pack.uid .. ""]
	local playerType = cardUtils:getPlayerType(seatId)
   
    gamePlaneOperator:setReadyStatus(playerType)
end
------------------------------------------------------------------------------------------------------

--用户操作相关
--服务器告知客户端可以进行的操作
function ZZMJReceiveHandle:SVR_NORMAL_OPERATE(pack)

	dump(pack, "-----服务器告知客户端可以进行的操作-----");

	local controlTable = cardUtils:getControlTable(pack.handle, pack.card, 1)

	gamePlaneOperator:showControlPlane(controlTable)
end

--广播用户进行了什么操作
function ZZMJReceiveHandle:SVR_PLAYER_USER_BROADCAST(pack)
	
	dump(pack,"-----广播用户进行了什么操作-----")

	local scenes          = SCENENOW['scene']
	if SCENENOW["name"] ~= run_scene_name then
		return
	end

	local handle = pack.handle
	local value = bit.band(pack.card, 0xFF)

	local seatId = ZZMJ_SEAT_TABLE[pack.uid .. ""]

	local playerType = cardUtils:getPlayerType(seatId)

	local tingSeq = pack.tingCards 

	-- if bit.band(handle, TING_TYPE_T) > 0 then
	-- 	ZZMJ_GAMEINFO_TABLE[seatId .. ""].ting = 1
	-- 	gamePlaneOperator:showTingHuPlane(playerType, pack.tingHuCards)		
	-- end

	local progCards = cardUtils:processControl(seatId, handle, value)

	gamePlaneOperator:control(playerType, progCards, handle, tingSeq)

	voiceUtils:playControlSound(seatId, handle)

	if playerType == CARD_PLAYERTYPE_MY then

			ZZMJ_CHUPAI = 1
		-- else
		-- 	ZZMJ_CHUPAI = 1
		-- end
	end
end
---------------------------------------------------------------------------------------------------------------
--托管相关
--广播用户托管
function ZZMJReceiveHandle:SVR_ROBOT(pack)

	dump(pack,"-----广播用户托管-----")

	local scenes = SCENENOW['scene']
	if SCENENOW["name"] ~= run_scene_name then
		return
	end

	if pack.uid == UID then
		local scenes  = SCENENOW['scene']
		if  pack.kind  == 1 then
			ZZMJ_ROOM.tuoguan_ing = 1
			-- scenes:show_tuoguan_layout(true)
		else
			ZZMJ_ROOM.tuoguan_ing = 0
			-- scenes:show_tuoguan_layout(false)
		end
	end
end
-------------------------------------------------------------------------------------------------------------------

--发牌相关
--发牌协议
function ZZMJReceiveHandle:SVR_SEND_USER_CARD(pack)

	dump(pack, "-----发牌协议-----")

	local scenes  = SCENENOW['scene']
	if SCENENOW['name'] ~= run_scene_name then
		return
	end	
    
    gamePlaneOperator:clearAllReadyStatus()
	gamePlaneOperator:clearPiaoImg()

	ZZMJ_GAME_STATUS = 1

	scenes:hideCloseRoomButton()
	scenes:ShowSettingButton()
	scenes:hideShareButton()

	gamePlaneOperator:showCenterPlane()

	-- if table.getn(ZZMJ_SEAT_TABLE_BY_TYPE) < 4 then
	-- 	--todo
	-- 	return
	-- end

	bm.palying = true
	bm.isRun=true

	ZZMJ_ENDING_DATA = nil

	--记录庄家的座位
	bm.zuan_seat = pack.seat

	zhuangPlayerType = cardUtils:getPlayerType(bm.zuan_seat)
	gamePlaneOperator:rotateTimer(zhuangPlayerType)
	
	-- if bm.isGroup then
    if require("hall.gameSettings"):getGameMode() == "group" then
        --todo
        ZZMJ_STATE = 2
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
	-- bm.SchedulerPool:delayCall(ZZMJReceiveHandle.SchedulerSendCard,2,pack)
end

--发牌
function ZZMJReceiveHandle:SchedulerSendCard(pack)

	ZZMJReceiveHandle:initCardForUser(pack)

	for i=0,3 do
		ZZMJReceiveHandle:showPlayerCards(i)
	end

	--显示庄家
	-- ZZMJReceiveHandle:showZhuang(pack.seat)
	local playerType = cardUtils:getPlayerType(pack.seat)

	ZZMJ_ZHUANG_UID = ZZMJ_USERINFO_TABLE[pack.seat .. ""].uid

	gamePlaneOperator:showZhuang(playerType)
end

--牌库初始化
function ZZMJReceiveHandle:initCardForUser(pack)
	for i=0,3 do
		local gameInfo = {}
		gameInfo.porg = {}
		gameInfo.hand = {0,0,0,0,0,0,0,0,0,0,0,0,0}
		gameInfo.out = {}
		gameInfo.ting = 0
		-- ZZMJ_ROOM.Gang[i]         = {}

		ZZMJ_GAMEINFO_TABLE[i .. ""] = gameInfo
	end

	local myCards = pack.cards

	table.sort(myCards)

	ZZMJ_GAMEINFO_TABLE[ZZMJ_MY_USERINFO.seat_id .. ""].hand = myCards	--0号玩家的手牌

	dump(ZZMJ_GAMEINFO_TABLE, "cards test ")
end

--显示玩家的牌
function ZZMJReceiveHandle:showPlayerCards( seatId )

	-- ZZMJReceiveHandle:drawHandCard(index)
	-- ZZMJReceiveHandle:drawOut(index)

	local playerType = cardUtils:getPlayerType(seatId)

	dump(ZZMJ_GAMEINFO_TABLE, "cards test 11")

	gamePlaneOperator:showCards(playerType)
end

--显示庄家
function ZZMJReceiveHandle:showZhuang(seat)

	local uid = UID

	if seat ~= bm.User.Seat then
		uid = ZZMJ_ROOM.seat_uid[seat]
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
function ZZMJReceiveHandle:SERVER_COMMAND_NEED_CHANGE_CARD(pack)

	dump(pack, "-----可以换牌-----")

	local scenes = SCENENOW['scene'] 

	if SCENENOW['name'] ~= run_scene_name then
		return
	end

	ZZMJ_ROOM.change_card_over = false
	dump(pack, "SERVER_COMMAND_NEED_CHANGE_CARD")
	ZZMJ_ROOM.cardHuan={};
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
function ZZMJReceiveHandle:SERVER_COMMAND_CHANGE_CARD_RESULT(pack)

	dump(pack, "-----服务器广播换牌的结果-----")

	local scenes  = SCENENOW['scene']

	if SCENENOW['name'] ~= run_scene_name then
		return
	end
	
	scenes:show_Text_18(false)

	ZZMJ_ROOM.change_card_over = true
	--ZZMJ_ROOM.cardHuan = ZZMJ_ROOM.cardHuan or {} -- 可能存在没有换的状况

	local old_hand_card = ZZMJ_ROOM.Card[0]['hand']
	dump(old_hand_card,"old_hand_card") 
	if pack.mount > 0 then
		--0号玩家的手牌
		ZZMJ_ROOM.Card[0]['hand'] = pack.cards	
		self:drawHandCard(0)
	end

	dump(ZZMJ_ROOM.Card[0]['hand'],"-----当前用户换牌后的新手牌-----") 

	ZZMJ_ROOM.Card[0]['hand'] = MajiangcardHandle:sortCards(ZZMJ_ROOM.Card[0]['hand'])

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
	for i,v in pairs(ZZMJ_ROOM.Card[0]['hand']) do 

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
function  ZZMJReceiveHandle:SVR_START_QUE_CHOICE(pack)

	dump(pack,"-----开始选择缺门-----")

	local scenes  = SCENENOW['scene']


	if SCENENOW['name'] ~= run_scene_name then
		return
	end

	scenes:show_other_xuanqueing(true)
	scenes:show_choosing_que(true)	
end

--广播缺一门  通知用户选缺选了哪一门,这时游戏还没有开始，
function ZZMJReceiveHandle:SVR_BROADCAST_QUE(pack)

	dump(pack,"-----广播缺一门-----")


	bm.User.Que = nil
	ZZMJ_ROOM.Que = true

	for i,v in pairs(pack.content) do
		self:hasChoiceQue(v.uid,v.que)
	end
end

--设置已经选缺
function ZZMJReceiveHandle:hasChoiceQue(uid,que)

	dump(uid,"-----设置已经选缺-----")

	local scenes  = SCENENOW['scene']
	if SCENENOW['name'] ~= run_scene_name then
		return
	end

	if uid == UID then
		--print("uid------------------que",que)
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
function ZZMJReceiveHandle:SVR_PLAYING_UID_BROADCAST(pack)
	
	dump(pack,"-----广播抓牌用户-----")

	local scenes  = SCENENOW['scene']
	if SCENENOW['name'] ~= run_scene_name then
		return
	end

	local playerType = cardUtils:getPlayerType(ZZMJ_SEAT_TABLE[pack.uid .. ""])
	local seatId = ZZMJ_SEAT_TABLE[pack.uid .. ""]

	if playerType ~= CARD_PLAYERTYPE_MY then
		cardUtils:getNewCard(seatId, 0)
		gamePlaneOperator:getNewCard(playerType, 0)
	end

	ZZMJ_REMAIN_CARDS_COUNT = pack.simplNum
	gamePlaneOperator:showRemainCardsCount()
end

--通知我抓的牌
function ZZMJReceiveHandle:SVR_OWN_CATCH_BROADCAST(pack)

	dump(pack,"-----通知我抓的牌-----")

	local scenes = SCENENOW['scene']

	if SCENENOW['name'] ~= run_scene_name then
		return
	end

    --显示剩余牌数
	ZZMJ_REMAIN_CARDS_COUNT = ZZMJ_REMAIN_CARDS_COUNT - 1
	gamePlaneOperator:showRemainCardsCount()

    --刷新手牌以显示听牌队列
	local tingSeq = pack.tingCards
	gamePlaneOperator:showCards(CARD_PLAYERTYPE_MY,tingSeq)

	local value = bit.band(pack.card, 0xFF)

	cardUtils:getNewCard(ZZMJ_MY_USERINFO.seat_id, value)

	gamePlaneOperator:getNewCard(CARD_PLAYERTYPE_MY,value,tingSeq)

	local controlTable = cardUtils:getControlTable(pack.handle, pack.card, 2, pack.cards)

	-- if pack.tingCount > 0 then
	-- 	-- --todo
	-- 	-- controlTable.type = bit.bor(controlTable.type, CONTROL_TYPE_TING)
	-- 	-- controlTable.tingSeq = pack.tingCards
	-- 	-- controlTable.gangSeq = pack.lgCards
	-- end

	if controlTable.type == CONTROL_TYPE_NONE or controlTable.type == CONTROL_TYPE_TING then
		--todo
		ZZMJ_CHUPAI = 1
	else
		ZZMJ_CHUPAI = 2
	end

	gamePlaneOperator:showControlPlane(controlTable)

end
---------------------------------------------------------------------------------------------------------------
--广播用户出牌
function ZZMJReceiveHandle:SVR_SEND_MAJIANG_BROADCAST(pack)
	
	dump(pack,"-----广播用户出牌-----")
	
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
		ZZMJ_CHUPAI = 0
	end

	local seatId = ZZMJ_SEAT_TABLE[pack.uid .. ""]
	local playerType = cardUtils:getPlayerType(seatId)
    
    dump(ZZMJ_GAMEINFO_TABLE[seatId .. ""].hand,"OK")
	local tag = cardUtils:playCard(seatId, value)
	gamePlaneOperator:playCard(playerType, tag, value)

	voiceUtils:playCardSound(seatId,pack.card)

end
---------------------------------------------------------------------------------------------------------------
--游戏广播相关
--广播结束游戏 没用
function ZZMJReceiveHandle:SVR_GAME_OVER(pack)

	-- dump(pack, "-----广播结束游戏 没用-----");
	-- require("hall.recordUtils.RecordUtils"):closeRecordFrame()
	-- ZZMJ_GAME_STATUS = 0

	-- if ZZMJ_ENDING_DATA then
	-- 	--todo
	-- 	if ZZMJ_ROUND == ZZMJ_TOTAL_ROUNDS then
	-- 		--todo
	-- 		require("zz_majiang.RoundEndingLayer"):showZhuaniao(ZZMJ_ENDING_DATA, true)
	-- 	else
	-- 		require("zz_majiang.RoundEndingLayer"):showZhuaniao(ZZMJ_ENDING_DATA, false)
	-- 	end
	-- end	

	-- local callAc = cc.CallFunc:create(function()
	-- 		--todo
	-- 		if ZZMJ_ENDING_DATA then
	-- 			--todo
	-- 			if ZZMJ_ROUND == ZZMJ_TOTAL_ROUNDS then
	-- 				--todo
	-- 				require("zz_majiang.RoundEndingLayer"):show(ZZMJ_ENDING_DATA, true)
	-- 			else
	-- 				require("zz_majiang.RoundEndingLayer"):show(ZZMJ_ENDING_DATA, false)
	-- 			end
	-- 		end	

	-- 		gamePlaneOperator:clearGameDatas()
	-- 	end)
	-- local seqAc = cc.Sequence:create(cc.DelayTime:create(3), callAc)
	
	-- SCENENOW["scene"]:runAction(seqAc)
end

---------------------------------------------------------------------------------------------------------------

--胡牌
--胡牌协议 4013
function ZZMJReceiveHandle:SVR_HUPAI_BROADCAST(pack)

	dump(pack,"-----胡牌协议-----")

	require("hall.recordUtils.RecordUtils"):closeRecordFrame()
	ZZMJ_GAME_STATUS = 0

	       --  if playerType == 3 then playerType = 4;
        -- elseif  playerType == 4 then playerType=3;
        -- end  
    for i,v in pairs(pack.hucontent) do 

    local seatId = ZZMJ_SEAT_TABLE[pack.hucontent[i].uid .. ""]
    local playerType = cardUtils:getPlayerType(seatId)
		  gamePlaneOperator:showCardsForHu(playerType, pack.hucontent[i].remainCards)
	end
    liujuFlag = false


	-- if ZZMJ_ENDING_DATA then
	-- 	--todo
	-- 	if ZZMJ_ROUND == ZZMJ_TOTAL_ROUNDS then
	-- 		--todo
	-- 		require("zz_majiang.RoundEndingLayer"):showZhuaniao(ZZMJ_ENDING_DATA, true)
	-- 	else
	-- 		require("zz_majiang.RoundEndingLayer"):showZhuaniao(ZZMJ_ENDING_DATA, false)
	-- 	end
	-- end	

	-- local scenes  = SCENENOW['scene']
	-- local paoid = nil 
	-- for i ,v in pairs(pack.content) do
	-- 	local  index  = self:getIndex(v.uid)
		
	-- 	local hu_type = v.htype
	-- 	if v.htype == 1 then --平胡
	-- 	  --print("--------------v.pao_content---------------")
	-- 	  paoid   = v.pao_content[1].paoid
	-- 	end

	-- 	self:show_zimo_tip(index,hu_type)
	-- 	self:drawPlayerHupaiCard(v.uid,v.card,v.htype)


	-- 	--播放自摸声音
	-- 	if index == 0 then
	-- 		local sound_path = sound_path_manager:GET_GANG_PENG_SOUND(USER_INFO["sex"],1)
	-- 		--require("hall.GameCommon"):playEffectSound(sound_path,false)
	-- 		cc.SimpleAudioEngine:getInstance():playEffect(sound_path,false)

	-- 		scenes:setGameState(5)
	-- 		-- if require("hall.gameSettings"):getGameMode() == "match" then
	-- 		-- 	require("majiang.MatchSetting"):showMatchWait(true,"majiang")
	-- 		-- end
	-- 	else
	-- 		local otherinfo = ZZMJ_ROOM.UserInfo[v.uid]
	-- 		if otherinfo ~= nil then
	-- 			local sound_path = sound_path_manager:GET_GANG_PENG_SOUND(otherinfo.sex,1)
	-- 			--require("hall.GameCommon"):playEffectSound(sound_path,false)
	-- 			cc.SimpleAudioEngine:getInstance():playEffect(sound_path,false)
	-- 		end
	-- 	end
	-- end

	-- ----print(paodi,"paoid")

	-- --显示放炮玩家
	-- if paoid ~= nil then
	-- 	local config = {
	-- 		[0] = {['x'] = 480,['y'] = 200},
	-- 		[1] = {['x'] = 220,['y'] = 306},
	-- 		[2] = {['x'] = 480,['y'] = 410},
	-- 		[3] = {['x'] = 710,['y'] = 306}	
	-- 		-- [0] = {['x'] = 480,['y'] = 300},
	-- 		-- [1] = {['x'] = 480,['y'] = 300},
	-- 		-- [2] = {['x'] = 480,['y'] = 300},
	-- 		-- [3] = {['x'] = 480,['y'] = 300}	
	-- 	}

	-- 	local index   = self:getIndex(paoid)
	-- 	local fangpao = CARD_PATH_MANAGER:get_card_path("fangpao")
	-- 	local object  = display.newSprite(fangpao)
	-- 	object:addTo(scenes)
	-- 	object:setLocalZOrder(2001)
	-- 	object:pos(config[index]['x'],config[index]['y'])
	-- 	bm.SchedulerPool:delayCall(function ()
	-- 		if tolua.isnull(object) == false then
	-- 			object:removeSelf()
	-- 		end
	-- 	end,3)
	-- end

	-- ZZMJ_ROOM.last = "otherhand"
	-- self:showLastEvent()

end


--显示自摸
function ZZMJReceiveHandle:show_zimo_tip(index,hu_type)

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
------------------------------------------------------------------------------------------------------------------
--红中游戏结束时协议顺序   胡了4013---4008    (最后一局)4008---5100     (解散组局) 5100
--结算相关
--结算协议  4008
function ZZMJReceiveHandle:SVR_ENDDING_BROADCAST(pack)

	dump(pack,"----一盘结束，进行结算-----")
    
	for i,v in ipairs(pack.players) do
		local seatid = ZZMJ_SEAT_TABLE[v.uid .. ""]
		local userInfo = ZZMJ_USERINFO_TABLE[seatid..""]
		userInfo.coins = pack.players[i].coins

		local playerType = cardUtils:getPlayerType(seatid)

		gamePlaneOperator:showPlayerInfo(playerType, userInfo)
	end

	ZZMJ_ENDING_DATA = pack
    
    --流局与否判断
	ZZMJ_ENDING_DATA['type'] = 0
	if liujuFlag == false then ZZMJ_ENDING_DATA['type'] = 1 end   --liujuFlag == true  为流局
    
    --延迟显示结算页
    SCENENOW["scene"]:performWithDelay(function()
    if ZZMJ_ENDING_DATA then
		--todo
		if ZZMJ_ROUND == ZZMJ_TOTAL_ROUNDS then
			
			require("zz_majiang.RoundEndingLayer"):showZhuaniao(ZZMJ_ENDING_DATA, true)
		else
			require("zz_majiang.RoundEndingLayer"):showZhuaniao(ZZMJ_ENDING_DATA, false)
		end
	end	

	require("zz_majiang.RoundEndingLayer"):setIsShow(true)
	end,2)
end
-------------------------------------------------------------------------------------------------------------------

--组局相关
--请求获取筹码返回
function ZZMJReceiveHandle:SVR_GET_CHIP(pack)
	-- if bm.isGroup then
    if require("hall.gameSettings"):getGameMode() == "group" then
		--todo
		require("majiang.gameScene"):onNetGetChip(pack)
	end
end

--请求兑换筹码返回
function ZZMJReceiveHandle:SVR_CHANGE_CHIP(pack)
	
	dump(pack, "-----请求兑换筹码返回------")
	-- if bm.isGroup  then
    if require("hall.gameSettings"):getGameMode() == "group" then
			
		require("majiang.gameScene"):onChipSuccess(pack)
	end
end

--组局时长
function ZZMJReceiveHandle:SVR_GROUP_TIME(pack)


	dump(pack, "-----组局时长-----")

	--  加入当前游戏模式是组局 if bm.isGroup then
    if require("hall.gameSettings"):getGameMode() == "group" then

    	--记录当前局数
		ZZMJ_ROUND = pack.round + 1

		--记录总局数
		ZZMJ_TOTAL_ROUNDS = pack.round_total

    end
end

--组局排行榜（一局结算之后返回的数据）    正常情况下解散才走这边  0x5100
function ZZMJReceiveHandle:SVR_GROUP_BILLBOARD(pack)
    if pack then

    	ZZMJ_GROUP_ENDING_DATA = pack

        -- if bm.isGroup then
    	if require("hall.gameSettings"):getGameMode() == "group" then

    		local isShow = require("zz_majiang.RoundEndingLayer"):isShow()
    		if not isShow then
    			if ZZMJ_ROUND ~= ZZMJ_TOTAL_ROUNDS then  --最后一局的话只执行4008
    			require("zz_majiang.GroupEndingLayer"):showGroupResult(ZZMJ_GROUP_ENDING_DATA)
    			end
    		end

            -- require("majiang.gameScene"):onNetBillboard(pack)
        end
    end
end

--组局历史记录
function ZZMJReceiveHandle:SVR_GET_HISTORY(pack)

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
function ZZMJReceiveHandle:G2H_CMD_DISSOLVE_FAILED(pack)

	dump("", "没有此房间，解散房间失败")

	require("hall.GameTips"):showTips("解散房间失败","disbandGroup_fail",2)
end

--广播桌子用户请求解散组局
function ZZMJReceiveHandle:SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP(pack)

	dump("", "广播桌子用户请求解散组局")

	-- require("hall.GameTips"):showTips("确认解散房间","cs_request_disbandGroup",1)
end

--广播桌子用户成功解散组局
function ZZMJReceiveHandle:SERVER_BROADCAST_DISSOLVE_GROUP(pack)

	dump("", "广播桌子用户成功解散组局")

	-- require("hall.GameTips"):showTips("解散房间成功","cs_disbandGroup_success",3)

	-- ZZMJ_ROUND = ZZMJ_TOTAL_ROUNDS

	if SCENENOW["scene"]:getChildByName("layer_tips") then
        SCENENOW["scene"]:removeChildByName("layer_tips")
    end

    if require("zz_majiang.RoundEndingLayer"):isShow() then
    	--todo
    	require("zz_majiang.RoundEndingLayer"):hide()
    	if ZZMJ_ENDING_DATA then
    		--todo
    		require("zz_majiang.RoundEndingLayer"):show(ZZMJ_ENDING_DATA, true)
    	end
    	
    end
end

--广播桌子用户解散组局 ，解散组局失败
function ZZMJReceiveHandle:SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP(pack)

	dump("", "广播桌子用户解散组局 ，解散组局失败")

	require("hall.GameTips"):showTips("解散房间失败","disbandGroup_fail",2)
end

--广播当前组局解散情况
function ZZMJReceiveHandle:G2H_CMD_REFRESH_DISSOLVE_LIST(pack)

	dump(pack, "-----广播当前组局解散情况-----")
	dump(bm.Room, "-----广播当前房间情况-----")

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
		local seatId = ZZMJ_SEAT_TABLE[applyId .. ""]
		if seatId then
			--todo
			local userInfo = ZZMJ_USERINFO_TABLE[seatId .. ""]

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
		if ZZMJ_USERINFO_TABLE then
			for k,v in pairs(ZZMJ_USERINFO_TABLE) do
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
			require("hall.GameTips"):showDisbandTips("提示", "ZZMJ_request_disbandGroup", 1, showMsg)
		end
	end
end

---------------------------------------------------------------------------------------------------------------
--聊天相关
--收到聊天消息
function ZZMJReceiveHandle:CHAT_MSG( pack )
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
function ZZMJReceiveHandle:s2c_JOIN_MATCH_RETURN(pack)
	--print("===recieve====0x211====================")
	dump(pack)
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

function ZZMJReceiveHandle:s2c_JOIN_MATCH_FAIL(pack)
	--print("0x7109==========return==========")
	dump(pack)
	USER_INFO["match_fee"] = 0
    require("majiang.MatchSetting"):setJoinMatch(false)
end

function ZZMJReceiveHandle:s2c_JOIN_MATCH_SUCCESS(pack)
	--print("0x7101==========return==========")
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

function ZZMJReceiveHandle:s2c_OTHER_PEOPLE_JOINT_IN(pack)
	--print("0x7103==========return==========")
	dump(pack)
	require("majiang.MatchSetting"):setJoinMatch(true)
	require("majiang.MatchSetting"):joinMatch(pack.Usercount,pack.Totalcount)
end

function ZZMJReceiveHandle:s2c_QUIT_MATCH_RETURN(pack)
	--print(" 0x7110==========return==========")
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
            --print("match logout failed,error type:"..pack["Errortype"])
            require("majiang.MatchSetting"):setJoinMatch(true)
        end

    end
end

function ZZMJReceiveHandle:s2c_GAME_BEGIN_LOGIC(pack)
	--print("0x7104==========return==========")
	dump(pack)
	
	bm.User={}
	bm.User.Seat      = pack.seat_id
	bm.User.Golf      = pack.gold or pack.Matchpoint
	bm.User.Pque      = nil

	ZZMJ_ROOM={}
	ZZMJ_ROOM.User      = {}	
    ZZMJ_ROOM.UserInfo  = {}
    ZZMJ_ROOM.seat_uid  = {}
	ZZMJ_ROOM.Card      = {}
	ZZMJ_ROOM.Gang      = {}
	ZZMJ_ROOM.base      = pack.base 

	ZZMJ_ROOM.tuoguan_ing = 0

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
			ZZMJReceiveHandle:showPlayer(v)
		end
	end

	--绘制其他内容
	scenes:set_basescole_txt(ZZMJ_ROOM.base) 

	-- if bm.isGroup  then --
    if require("hall.gameSettings"):getGameMode() == "group" then
		USER_INFO["base_chip"]=ZZMJ_ROOM.base;
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

function ZZMJReceiveHandle:s2c_PAI_MING_MSG(pack)
	--print("0x7114==========return==========")
	dump(pack)
end

function ZZMJReceiveHandle:s2c_SVR_MATCH_WAIT(pack)
	--print("0x7113==========return==========")
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

function ZZMJReceiveHandle:s2c_GAME_STATE_MSG(pack)
	--print("0x7106==========return==========")
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

function ZZMJReceiveHandle:s2c_SVR_REGET_MATCH_ROOM(pack)
	
	--dump(pack)
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

return ZZMJReceiveHandle