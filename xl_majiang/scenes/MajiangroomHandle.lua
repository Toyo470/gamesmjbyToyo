
--加载麻将设置类（麻将公共方法类）
require("xl_majiang.setting_help")

--加载框架初始化类
require("framework.init")

--加载麻将资源路径管理类
require("xl_majiang.card_path")
local CARD_PATH_MANAGER = require("xl_majiang.card_path")
CARD_PATH_MANAGER:init()

--加载大厅请求处理
local hallHandle = require("hall.HallHandle")

--加载声音路径
local SOUND_PATH = require("xl_majiang.sound_type")
--定义声音管理参数
local sound_path_manager = SOUND_PATH.new()

--麻将游戏数据处理类
local data_manager = require("xl_majiang.datamanager")

--大厅套接字请求类
local hallPa = require("hall.HALL_PROTOCOL")

--麻将套接字请求类
local PROTOCOL = import("xl_majiang.scenes.Majiang_Protocol")
-- setmetatable(PROTOCOL, {
-- 		__index=hallPa
-- 	})
--table.merge(PROTOCOL, hallPa)
--table.con

--定义麻将游戏处理类
local MajiangroomHandle = class("MajiangroomHandle",hallHandle)

--加载麻将牌类
local Majiangcard       = require("xl_majiang.card.Majiangcard")
--加载麻将牌操作类
local MajiangcardHandle = require("xl_majiang.card.MajiangcardHandle")

--加载麻将游戏动画类
local MajiangroomAnim   = require("xl_majiang.scenes.MajiangroomAnim")

--加载麻将游戏用户操作类
local MajiangroomServer = require("xl_majiang.scenes.MajiangroomServer")

--定义登录超时时间
local LOGIN_OUT_TIMER = 20

--定义麻将游戏界面名称
local run_scene_name = "xl_majiang.scenes.MajiangroomScenes"

--扣除台费百分数
local percent_base = 0.20

local item_ly_list = {}

function MajiangroomHandle:ctor()

	MajiangroomHandle.super.ctor(self);

	--定义麻将游戏请求	
	local  func_ = {

		--用户自己退出成功
        [PROTOCOL.SVR_QUICK_SUC] = {handler(self, MajiangroomHandle.SVR_QUICK_SUC)},
        --广播用户准备
        [PROTOCOL.SVR_USER_READY_BROADCAST] = {handler(self, MajiangroomHandle.SVR_USER_READY_BROADCAST)},
        --登陆房间广播
        [PROTOCOL.SVR_LOGIN_ROOM_BROADCAST] = {handler(self, MajiangroomHandle.SVR_LOGIN_ROOM_BROADCAST)},
        --广播玩家退出返回
        [PROTOCOL.SVR_QUIT_ROOM] = {handler(self, MajiangroomHandle.SVR_QUIT_ROOM)},
        --发牌
        [PROTOCOL.SVR_SEND_USER_CARD] = {handler(self, MajiangroomHandle.SVR_SEND_USER_CARD)},
        --开始选择缺一门
        [PROTOCOL.SVR_START_QUE_CHOICE] = {handler(self, MajiangroomHandle.SVR_START_QUE_CHOICE)},
        --广播缺一门选择
        [PROTOCOL.SVR_BROADCAST_QUE] = {handler(self, MajiangroomHandle.SVR_BROADCAST_QUE)},
        --当前抓牌用户广播
        [PROTOCOL.SVR_PLAYING_UID_BROADCAST] = {handler(self, MajiangroomHandle.SVR_PLAYING_UID_BROADCAST)},
        --广播用户出牌
        [PROTOCOL.SVR_SEND_MAJIANG_BROADCAST] = {handler(self, MajiangroomHandle.SVR_SEND_MAJIANG_BROADCAST)},
        --svr通知我抓的牌
        [PROTOCOL.SVR_OWN_CATCH_BROADCAST] = {handler(self, MajiangroomHandle.SVR_OWN_CATCH_BROADCAST)},
        --广播用户进行了什么操作
        [PROTOCOL.SVR_PLAYER_USER_BROADCAST] = {handler(self, MajiangroomHandle.SVR_PLAYER_USER_BROADCAST)},
        --广播胡
    	[PROTOCOL.SVR_HUPAI_BROADCAST]       = {handler(self, MajiangroomHandle.SVR_HUPAI_BROADCAST)}, 
    	--结算
    	[PROTOCOL.SVR_ENDDING_BROADCAST] = {handler(self, MajiangroomHandle.SVR_ENDDING_BROADCAST)}, 
    	--请求托管
    	[PROTOCOL.SVR_ROBOT] = {handler(self, MajiangroomHandle.SVR_ROBOT)}, 


    	--获取房间id结果
    	[PROTOCOL.SVR_GET_ROOM_OK]     = {handler(self, MajiangroomHandle.SVR_GET_ROOM_OK)},
    	--登陆房间返回
        [PROTOCOL.SVR_LOGIN_ROOM]      = {handler(self, MajiangroomHandle.SVR_LOGIN_ROOM)},
        --登陆错误
     	[PROTOCOL.SVR_ERROR]      = {handler(self, MajiangroomHandle.SVR_ERROR)},
     	--用户重新登录普通房间的消息返回（4105(10进制s)）
     	[PROTOCOL.SVR_REGET_ROOM]      = {handler(self, MajiangroomHandle.SVR_REGET_ROOM)},--重登
     	--服务器告知客户端可以进行的操作
     	[PROTOCOL.SVR_NORMAL_OPERATE]      = {handler(self, MajiangroomHandle.SVR_NORMAL_OPERATE)},--广播可以进行的操作
     	--服务器告知客户端游戏结束
     	[PROTOCOL.SVR_GAME_OVER]      = {handler(self, MajiangroomHandle.SVR_GAME_OVER)},
     	--广播刮风下雨（返回）杠
     	[PROTOCOL.SVR_GUFENG_XIAYU]      = {handler(self, MajiangroomHandle.SVR_GUFENG_XIAYU)},


     	--用户聊天消息
     	[PROTOCOL.CHAT_MSG]      = {handler(self, MajiangroomHandle.CHAT_MSG)},

     	--组局
     	--请求获取筹码返回
     	[PROTOCOL.SVR_GET_CHIP]     = {handler(self, MajiangroomHandle.SVR_GET_CHIP)},
     	--请求兑换筹码返回
     	[PROTOCOL.SVR_CHANGE_CHIP]     = {handler(self, MajiangroomHandle.SVR_CHANGE_CHIP)},
     	--组局时长
     	[PROTOCOL.SVR_GROUP_TIME]     = {handler(self, MajiangroomHandle.SVR_GROUP_TIME)},
     	--组局排行榜
     	[PROTOCOL.SVR_GROUP_BILLBOARD]     = {handler(self, MajiangroomHandle.SVR_GROUP_BILLBOARD)},
     	--组局历史记录
     	[PROTOCOL.SVR_GET_HISTORY]     = {handler(self, MajiangroomHandle.SVR_GET_HISTORY)},

     	--没有此房间，解散房间失败
     	[PROTOCOL.G2H_CMD_DISSOLVE_FAILED]     = {handler(self, MajiangroomHandle.G2H_CMD_DISSOLVE_FAILED)},
     	--广播桌子用户请求解散组局
     	[PROTOCOL.SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP]     = {handler(self, MajiangroomHandle.SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP)},
     	--广播当前组局解散情况
     	[PROTOCOL.G2H_CMD_REFRESH_DISSOLVE_LIST]     = {handler(self, MajiangroomHandle.G2H_CMD_REFRESH_DISSOLVE_LIST)},
     	--广播桌子用户成功解散组局
     	[PROTOCOL.SERVER_BROADCAST_DISSOLVE_GROUP]     = {handler(self, MajiangroomHandle.SERVER_BROADCAST_DISSOLVE_GROUP)},
     	--广播桌子用户解散组局 ，解散组局失败
     	[PROTOCOL.SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP]     = {handler(self, MajiangroomHandle.SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP)},

     	--换牌
     	--服务器告诉客户端，可以换牌
     	[PROTOCOL.SERVER_COMMAND_NEED_CHANGE_CARD]     = {handler(self, MajiangroomHandle.SERVER_COMMAND_NEED_CHANGE_CARD)},
     	--//服务器广播换牌的结果 zsw
     	[PROTOCOL.SERVER_COMMAND_CHANGE_CARD_RESULT]     = {handler(self, MajiangroomHandle.SERVER_COMMAND_CHANGE_CARD_RESULT)},

     	--文字聊天相关
     	[PROTOCOL.SVR_MSG_FACE]     = {handler(self, MajiangroomHandle.SVR_MSG_FACE)},

     	--比赛场相关
     	--用户请求进入比赛场的返回值
     	[PROTOCOL.s2c_JOIN_MATCH_RETURN]     = {handler(self, MajiangroomHandle.s2c_JOIN_MATCH_RETURN)},
     	--进入比赛失败
     	[PROTOCOL.s2c_JOIN_MATCH_FAIL]     = {handler(self, MajiangroomHandle.s2c_JOIN_MATCH_FAIL)},
     	-- 进入比赛成功
		[PROTOCOL.s2c_JOIN_MATCH_SUCCESS]     = {handler(self, MajiangroomHandle.s2c_JOIN_MATCH_SUCCESS)},
		--同时，已经报名的玩家会收到其他玩家进入的消息
     	[PROTOCOL.s2c_OTHER_PEOPLE_JOINT_IN]     = {handler(self, MajiangroomHandle.s2c_OTHER_PEOPLE_JOINT_IN)},
     	--返回退出比赛结果
     	[PROTOCOL.s2c_QUIT_MATCH_RETURN]     = {handler(self, MajiangroomHandle.s2c_QUIT_MATCH_RETURN)},
     	--比赛开始逻辑0x7104//牌局，开始发送其他玩家信息
     	[PROTOCOL.s2c_GAME_BEGIN_LOGIC]     = {handler(self, MajiangroomHandle.s2c_GAME_BEGIN_LOGIC)},
     	--每轮打完之后 会给玩家发送比赛状态信息0x7106
     	[PROTOCOL.s2c_GAME_STATE_MSG]     = {handler(self, MajiangroomHandle.s2c_GAME_STATE_MSG)},
     	-- 比赛的过程中会收到比赛的排名信息  0x7114
     	[PROTOCOL.s2c_PAI_MING_MSG]     = {handler(self, MajiangroomHandle.s2c_PAI_MING_MSG)},
     	--发送用户重连回比赛开赛后的等待界面
     	[PROTOCOL.s2c_SVR_MATCH_WAIT]     = {handler(self, MajiangroomHandle.s2c_SVR_MATCH_WAIT)},
     	--用户重新登录比赛场房间的消息返回
     	[PROTOCOL.s2c_SVR_REGET_MATCH_ROOM] = {handler(self, MajiangroomHandle.s2c_SVR_REGET_MATCH_ROOM)},

    }
    table.merge(self.func_, func_)

end

--获取玩家显示的位置号 0自己，1左边玩家，2对家，3右边玩家
function MajiangroomHandle:getIndex(uid)

	dump(uid, "-----获取玩家显示的位置号，uid-----")

	if tonumber(uid) == tonumber(UID) then
		return 0
	end

	-- if uid == nil then
	-- 	return 0
	-- end

	dump(bm.Room.User, "-----当前房间的其他用户信息-----")
	local other_seat = bm.Room.User[uid]
	dump(other_seat, "-----获取玩家显示的位置号，other_seat-----")

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

--显示倒计时器
function MajiangroomHandle:showTimer(uid,time)

	local scenes = SCENENOW['scene']

	if SCENENOW['name'] ~= run_scene_name then
		return
	end

	--设置显示计时器
	scenes:show_timer_visible(true)

	--初始化计时器
	scenes:init_clock()

	--判断当前是否有正在运行的计时器
	if bm.Room.timerid then
		bm.SchedulerPool:clear(bm.Room.timerid)
		bm.Room.timerid = nil
	end

	--获取庄家的位置
	local index = self:getIndex(uid)

	--庄家指示器指向调整
	scenes:show_timer_index(index)

	bm.Room.timer   = time
	self.timecount_ = 0

	bm.Room.timerid = bm.SchedulerPool:loopCall(function()

		self.timecount_ = self.timecount_ + 1

		if bm.Room.timer and self.timecount_ % 5 == 0 then
			bm.Room.timer  = bm.Room.timer - 1
		end

		if bm.Room.timer and bm.Room.timer >= 0 and bm.Room.timer <= 9 then
			local scenes  = SCENENOW['scene']
			if SCENENOW['name'] == run_scene_name and scenes.show_timer_num then
				--中间计时器显示时间
				scenes:show_timer_num(bm.Room.timer)
				--显示用户位置上的
				scenes:showClock(index,bm.Room.timer,true)
			end
		end
		
		return true

	end,0.2)
	
end

--清理界面
function MajiangroomHandle:clearUserView(index)

	dump(index, "-----清理界面-----")

	-- local index   = self:getIndex(uid)
	local scenes  = SCENENOW['scene']

	--移除重登loading
	local reloadloading = SCENENOW["scene"]:getChildByName("loading")
	if reloadloading then
		reloadloading:removeSelf()
	end

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

	if bm.Room.timerid then
		bm.SchedulerPool:clear(bm.Room.timerid)
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
function MajiangroomHandle:callFunc(pack)

	if self.func_[pack.cmd] and self.func_[pack.cmd][1] then
        self.func_[pack.cmd][1](pack)
    end

end
-------------------------------------------------------------------------------------------------------------------

--进出房间相关
--当前用户获取房间id结果
function MajiangroomHandle:SVR_GET_ROOM_OK(pack)

	dump(pack,"-----获取房间id结果-----")

 --    if require("hall.gameSettings"):getGameMode() ~= "group" then

	-- 	local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_LOGIN_ROOM_GROUP)
 --        :setParameter("tableid", pack['tid'])
 --        :setParameter("nUserId", UID)
 --        :setParameter("strkey", "")
 --        :setParameter("strinfo", USER_INFO["user_info"])
 --        :setParameter("iflag", 2)
 --        :setParameter("version", 1)
 --        :setParameter("activity_id","")
 --        :build()
 --    	bm.server:send(pack)
 --    	print("发送-----1001---不是组局-----")

	-- else

	-- 	local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_LOGIN_ROOM_GROUP)
 --        :setParameter("tableid", pack['tid'])
 --        :setParameter("nUserId", USER_INFO["uid"])
 --        :setParameter("strkey", json.encode("kadlelala"))
 --        :setParameter("strinfo", USER_INFO["user_info"])
 --      	:setParameter("iflag", 2)
 --        :setParameter("version", 1)
 --        :setParameter("activity_id", USER_INFO["activity_id"])
 --        :build()
 --    	bm.server:send(pack)
 --    	print("发送-----1001---是组局-----")

	-- end

	local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_LOGIN_ROOM_GROUP)
        :setParameter("tableid", pack['tid'])
        :setParameter("nUserId", USER_INFO["uid"])
        :setParameter("strkey", json.encode("kadlelala"))
        :setParameter("strinfo", USER_INFO["user_info"])
      	:setParameter("iflag", 2)
        :setParameter("version", 1)
        :setParameter("activity_id", USER_INFO["activity_id"])
        :build()
	bm.server:send(pack)
	print("发送-----1001---是组局-----")
	
end

--登陆房间返回（登录房间成功）
function MajiangroomHandle:SVR_LOGIN_ROOM(pack)

	dump(pack, "-----登录房间成功-----")

	for i=0,3 do
		self:clearUserView(i)
	end

	--清除所有胡标志
    self:clearAllHuSign()

	--设置自己没有胡
	bm.isMyHu = 0

	bm.isDisbandSuccess = false

	bm.User = {}
	bm.User.Seat      = pack.seat_id
	bm.User.Golf      = pack.gold
	bm.User.Pque      = nil

	bm.Room = {}
	bm.Room.User      = {}
    bm.Room.UserInfo  = {}
    bm.Room.seat_uid  = {}
	bm.Room.Card      = {}
	bm.Room.Gang      = {}
	bm.Room.base      = pack.base
	bm.Room.ShowVoicePosion = {}

	bm.Room.tuoguan_ing = 0
	--bm.display_scenes("xl_majiang.scenes.MajiangroomScenes")

	SCENENOW["scene"]:removeSelf()
	SCENENOW["scene"] = nil;

	local sc = require("xl_majiang.scenes.MajiangroomScenes").new()
	SCENENOW["scene"] = sc
    --SCENENOW["scene"]:retain();
    SCENENOW["name"]  = "xl_majiang.scenes.MajiangroomScenes";
	display.replaceScene(sc)

	local scenes = sc

	--绘制自己的信息
	scenes:set_ower_info(USER_INFO["icon_url"],USER_INFO["nick"],pack["gold"],USER_INFO["sex"])

	--绘制其他玩家
	if pack.user_mount > 0  then
		for i,v in pairs(pack.users_info) do
			MajiangroomHandle:showPlayer(v)
		end
	end

	--绘制其他元素
	scenes:set_basescole_txt(bm.Room.base)

	-- if bm.isGroup  then --
    if require("hall.gameSettings"):getGameMode() == "group" then
		USER_INFO["base_chip"] = bm.Room.base;
	else
		SCENENOW["scene"]:gameReady();
	end

	--播放游戏音乐
	audio.playMusic("xl_majiang/music/BG_283.mp3", true)

	--添加视频引导
	require("hall.leader.LeaderLayer"):showLeaderLayer(cc.p(901.00, 265.00))

	--添加录音按钮
	require("hall.VoiceRecord.VoiceRecordView"):showView(901.00, 135.00)

	--发送准备
	scenes:gameReady()

end

--登陆错误
function MajiangroomHandle:SVR_ERROR(pack)
	
	dump(pack, "-----登陆错误-----")

	local errcode = "error"
	local showBtn = 2
	if pack["type"] == 9 then
		errcode = "change_money"
		showBtn = 1
	end
	require("hall.GameTips"):showTips("提示", errcode, showBtn, tbErrorCode[pack["type"]])

end

--用户重登房间
function MajiangroomHandle:SVR_REGET_ROOM(pack)

	dump(pack, "-----用户重登房间-----")

	--清屏
	for i=0,3 do
		self:clearUserView(i)
	end

	--设置自己没有胡
	bm.isMyHu = 0

	--判断是否解散成功，用这个来控制一局结算的界面出不出现
	bm.isDisbandSuccess = false

	--设置当前正在游戏
	bm.palying = true

	--初始化用户Table
	bm.User={}
	bm.User.Seat      = pack.seat_id
	bm.User.Golf      = pack.user_gold
	bm.User.Pque      = pack.quew

	--初始化房间Table
	bm.Room={}
	bm.Room.User      = {}	
    bm.Room.UserInfo  = {}
    bm.Room.seat_uid  = {}
	bm.Room.Card      = {}
	bm.Room.Gang      = {}
	bm.Room.base      = pack.nBaseChips
	bm.Room.ShowVoicePosion = {}

	--设置当前不在托管
	bm.Room.tuoguan_ing = 0

	--设置当前已经换牌
	bm.Room.change_card_over = true

	if pack.m_nLevel ~= nil then
		bm.nomallevel = pack.m_nLevel
	end

	--获取游戏界面
	local sc = require("xl_majiang.scenes.MajiangroomScenes").new()
	SCENENOW["scene"] = sc
    SCENENOW["name"]  = "xl_majiang.scenes.MajiangroomScenes";
	display.replaceScene(sc)
	local scenes = sc
	
	--显示自己
	dump("", "-----用户重登房间，绘制自己信息-----")
	scenes:set_ower_info(USER_INFO["icon_url"],USER_INFO["nick"],pack["user_gold"],USER_INFO["sex"])
	scenes:set_basescole_txt(bm.Room.base)--底分
	scenes:show_ready_bar(0,false) -- 隐藏准备
	-- scenes:set_left_card_num_visible(false)
	-- scenes:set_left_card_num("")

	--显示游戏配置
	local left_card_num = scenes._scene:getChildByName("left_card_num")
	left_card_num:setString(USER_INFO["gameConfig"])

    --显示其他玩家
    dump(pack.users_info, "-----用户重登房间，绘制其他用户信息-----")
	for player_index,user_data in pairs(pack.users_info) do
		local data = {}
		data.seat_id = user_data.SeatId
		data.user_info = user_data.m_strUserInfo
		data.uid = user_data.UserId
		data.user_gold = user_data.m_nMoney
		self:showPlayer(data)
	end

	--界面移动
	scenes:hide_self_info()
	scenes:hide_otherplayer_info(1)--false表示隐藏
	scenes:hide_otherplayer_info(2)--false表示隐藏
	scenes:hide_otherplayer_info(3)--false表示隐藏

	--隐藏邀请微信好友按钮
	scenes:hidendinvite()

	--隐藏解散房间按钮
	scenes:hidendisband()

	--隐藏用户准备标志
	scenes:hideAllSelect()

	--显示设置按钮
	scenes:ShowSettingButton()

	--添加视频引导
	require("hall.leader.LeaderLayer"):showLeaderLayer(cc.p(901.00, 265.00))

	--添加录音按钮
	require("hall.VoiceRecord.VoiceRecordView"):showView(901.00, 135.00)

	dump(bm.Room.ShowVoicePosion, "-----录音播放效果显示位置-----")

	--牌库初始化
	self:initCardForUser(pack.holds_info)

	--0号玩家的手牌
	bm.Room.Card[0]['hand'] = pack.holds_info

	--计时器初始化
	bm.Room.timer = 0
	
	--记录自己的杠牌
	for _,gangdata in pairs(pack.gangCount_infoming) do
		table.insert(bm.Room.Card[0]['porg'],gangdata.gang)
		table.insert(bm.Room.Card[0]['porg'],gangdata.gang)
		table.insert(bm.Room.Card[0]['porg'],gangdata.gang)
		table.insert(bm.Room.Card[0]['porg'],gangdata.gang)
		bm.Room.Gang[0][gangdata.gang] = gangdata.gangtype
	end

	--记录自己的碰牌
	for _,card in pairs(pack.peng_info) do
		table.insert(bm.Room.Card[0]['porg'],card)  
		table.insert(bm.Room.Card[0]['porg'],card)
		table.insert(bm.Room.Card[0]['porg'],card)
	end

	--记录自己的出牌
	for _,card_data in pairs(pack.outcardSize_info) do
		if card_data.outcardtype == 0 then
			table.insert(bm.Room.Card[0]['out'], card_data.outcard)
		end
	end

	--重登记录我的缺
	if pack.quew == 1 and pack.isDQw ~= -1 then
		bm.User.Que = pack.isDQw
		
		local str = CARD_PATH_MANAGER:get_que_tip(bm.User.Que)
		scenes:show_widget_tip(0,true,"que_tip",str,cc.rect(0,0,36,36),1.0)
	end
    
    --是否胡牌
	if pack.pHuSeatId == 1 then

		--胡牌

		--正常显示自己的牌
		self:showPlayerCards(0)

		--显示自己胡牌标志
		self:show_zimo_tip(0,pack.pHudate_p)

		--从返回的手牌中去掉胡的牌再重新显示自己的牌
		bm.Room.Card[0]['hand'] = {}

		--记录去掉胡的那张牌的数组
    	local userleftcard = {}
    	--记录是否已经去掉胡的牌
    	local isQu = 0;
    	--去掉胡的那张牌
    	local hucard = pack.pHudate_c
    	-- bm.Room.Card[0]["hu"] = hucard
    	if hucard ~= nil then
    		for k,v in pairs(pack.holds_info) do
    			if v == hucard then
    				if isQu == 0 then
    					isQu = 1
    				else
    					table.insert(bm.Room.Card[0]['hand'], v)
    				end
    			else
    				table.insert(bm.Room.Card[0]['hand'], v)
    			end
    		end
    		dump(backuserleftcard,"-----" .. tostring(index) .. "用户去掉胡牌后的手牌-----")
    	end

		--显示自己胡后整理好的牌
		self:drawPlayerHupaiCard(USER_INFO["uid"], pack.pHudate_c, pack.pHudate_p)

	else

		--没有胡牌

		--正常显示自己的牌
		self:showPlayerCards(0)

		--获取手牌数量
		local _card_num = table.nums(pack.holds_info)

		--判断是否自己出牌
		if  _card_num == 2 or  
			_card_num == 5 or 
			_card_num == 8 or 
			_card_num == 11 or 
			_card_num == 14 then

			bm.Room.my_out_card_time = 1

			--当前用户出牌，把自己最后一张牌移到外面去
			self:drawHandCardAfterBack(0)
		end

	end

	--记录其他玩家牌情况
	for i,user_data in pairs(pack.users_info) do

		local index = self:getIndex(user_data.UserId)

		--其他玩家的杠牌
		for _,card_data in pairs(user_data.minggang) do
			table.insert(bm.Room.Card[index]['porg'],card_data.data1)
			table.insert(bm.Room.Card[index]['porg'],card_data.data1)
			table.insert(bm.Room.Card[index]['porg'],card_data.data1)
			table.insert(bm.Room.Card[index]['porg'],card_data.data1)
			bm.Room.Gang[index][card_data.data1] = card_data.data2
		end

		--其他用户的碰牌
		for _,card in pairs(user_data.pengdata) do
			table.insert(bm.Room.Card[index]['porg'],card)
			table.insert(bm.Room.Card[index]['porg'],card)
			table.insert(bm.Room.Card[index]['porg'],card)
		end

		--其他玩家出的牌
		for  _,card_data  in pairs(user_data.outCarddata) do
			if card_data.outCardState == 0 then
				table.insert(bm.Room.Card[index]['out'],card_data.outCards)
			end
		end

		--其他玩家的缺
		if user_data.que == 1 and user_data.isDQ~=-1 then
			local str = CARD_PATH_MANAGER:get_que_tip(user_data.isDQ)
			scenes:show_widget_tip(index, true, "que_tip",str,cc.rect(0,0,36,36),1.0)
		end

		--其他用户的手牌
		bm.Room.Card[index]['hand'] = {}
		for index_k = 1, user_data.countHandCards do
			table.insert(bm.Room.Card[index]['hand'],0)
		end	

		--正常显示其他用户手牌
		self:showPlayerCards(index)

		--其他玩家是否胡
		if user_data.HuSeatId == 1 then

			--显示玩家胡标志
			self:show_zimo_tip(index,user_data.HuType)

			--从返回的手牌中去掉胡的牌再重新显示自己的牌
			--记录去掉胡的那张牌的数组
	    	local userleftcard = {}
	    	--记录是否已经去掉胡的牌
	    	local isQu = 0;
	    	--去掉胡的那张牌
	    	local hucard = user_data.HuCard
	    	-- bm.Room.Card[index]["hu"] = hucard
	    	if hucard ~= nil then
	    		for k,v in pairs(bm.Room.Card[index]['hand']) do
	    			if isQu == 0 then
    					isQu = 1
    				else
    					table.insert(userleftcard, v)
    				end
	    		end
	    	end
	    	bm.Room.Card[index]['hand'] = userleftcard

			--显示自己胡后整理好的牌
			self:drawPlayerHupaiCard(user_data.UserId, user_data.HuCard, user_data.HuType)

		end
	
	end

	--显示指示器
	-- MajiangroomHandle:showTimer(pack.uid, 8)

	--显示庄家
	scenes:show_timer_visible(true)
	self:showZhuang(pack.m_nBankSeatId)

	--发送取消托管
	--MajiangroomServer:cancelTuo()
	bm.Room.tuoguan_ing = 0
	scenes:show_tuoguan_layout(false)

	--骰子动画
	--MajiangroomAnim:shuaiZi(pack.shai)

	--背景音乐
	audio.playMusic("xl_majiang/music/BG_283.mp3",true)

	-- if bm.isGroup  then --
 --    if require("hall.gameSettings"):getGameMode() == "group" then
	-- 	USER_INFO["base_chip"]=bm.Room.base;
	-- 	require("xl_majiang.gameScene"):showTimer(bm.GroupTimer)
	-- 	require("xl_majiang.gameScene"):checkChip(scenes)
	-- end

	-- data_manager:set_game_mode(1)
	-- majiangGameMode = 1
	-- require("hall.gameSettings"):setGameMode("free")

	local uid_arr = {}
	if bm.Room ~= nil then
		if bm.Room.User ~= nil then
			for k,v in pairs(bm.Room.User) do
				table.insert(uid_arr, k)
			end
		end
	end

	dump(uid_arr, "-----用户Id-----")
	require("hall.GameSetting"):setPlayerUid(uid_arr)

	--显示最后出的牌的标志
	--去掉上一只牌标志
	local nowCardSign = scenes:getChildByName("nowCardSign")
	if nowCardSign then
		nowCardSign:removeSelf()
	end

	-- self:showPlayerCards(pack.chupai_seatid)

	--显示用户当前可以的操作(重连回来后用户可进行的操作)
	if pack.myNowHandle ~= nil then
		self:showHandlesView(pack.myNowHandle,pack.lastCard)
	end

	--记录用户当前为重连状态
	bm.isReload = 1

end

--用户进入房间
function MajiangroomHandle:SVR_LOGIN_ROOM_BROADCAST(pack)

	dump(pack ,"-----用户进入房间-----")
	if pack ~= nil then
		self:showPlayer(pack)
	end

end

--显示其他玩家
function MajiangroomHandle:showPlayer(pack)

	dump(pack, "-----显示其他玩家-----")

	local scenes = SCENENOW['scene'] 
	if SCENENOW['name'] ~= run_scene_name then
		return
	end

	--新加入用户的用户信息
	local v = pack
	--保存用户座位与id映射
	bm.Room.User[v.uid] = pack.seat_id
	bm.Room.UserInfo[v.uid] = pack
	bm.Room.seat_uid[v.seat_id] = pack.uid
	
	local other_seat  = pack.seat_id
    local other_index = other_seat - bm.User.Seat

    if other_index < 0 then
      other_index = other_index + 4
    end

    if other_index == 1 then
    	other_index = 3

    elseif other_index == 3 then
    	other_index = 1 

    end

    local position = {}
    if other_index == 0 then
    	position.x = 223.00
    	position.y = 180.00
    elseif other_index == 1 then
    	position.x = 113.00
    	position.y = 396.00
    elseif other_index == 2 then
    	position.x = 391.00
    	position.y = 425.00
    elseif other_index == 3 then
    	position.x = 934.35
    	position.y = 396.81
    end
    bm.Room.ShowVoicePosion[v.uid] = position

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

    --显示其他用户到界面
   	scenes:show_otherplayer_info(other_index,icon_url,nick_name,user_gold,sex_num,v.uid)

    if pack.if_ready == 1 then

    	MajiangroomHandle:showOtherReady(other_index)

    	--设置用户已经准备
    	scenes:show_hasselect(other_index, true)

    end

    if table.nums(bm.Room.User) == 3 then
    	bm.palying = true
    end

    dump(bm.Room.User, "-----房间用户信息-----")
	local uid_arr = {}
	if bm.Room ~= nil then
		if bm.Room.User ~= nil then
			for k,v in pairs(bm.Room.User) do
				table.insert(uid_arr, k)
			end
		end
	end

	dump(uid_arr, "-----用户Id-----")
	require("hall.GameSetting"):setPlayerUid(uid_arr)

end

--用户退出房间
function MajiangroomHandle:SVR_QUIT_ROOM(pack)

	dump(pack,"-----用户退出房间-----")

	local scenes = SCENENOW['scene'] 
	if SCENENOW['name'] ~= run_scene_name then
		return
	end

	local index = self:getIndex(pack.uid)

	--设置对应位置为未准备
	scenes:show_hasselect(index, false)

	majiangGameMode = 1
	-- require("hall.gameSettings"):setGameMode("free")

	scenes:set_player_visible(index,false)
	
	-- local v = bm.Room.UserInfo[pack.uid]
	-- bm.Room.seat_uid[v.seat_id] = nil
	-- bm.Room.UserInfo[pack.uid] = nil
	-- bm.Room.User[pack.uid]  = nil --清空保存用户座位与id映射

	bm.palying = false

	dump(bm.Room.User, "-----房间用户信息-----")
	local uid_arr = {}
	if bm.Room ~= nil then
		if bm.Room.User ~= nil then
			for k,v in pairs(bm.Room.User) do
				if k ~= pack.uid then
					table.insert(uid_arr, k)
				end
			end
		end
	end

	dump(uid_arr, "-----用户Id-----")
	require("hall.GameSetting"):setPlayerUid(uid_arr)

end

--用户退出游戏成功
function MajiangroomHandle:SVR_QUICK_SUC(pack)

	dump(pack,"-----玩家退出游戏成功-----")
	audio.stopMusic(true)

	-- local mode = require("hall.gameSettings"):getGameMode()
	-- print("SVR_QUICK_SUC mode",tostring(mode))
	-- -- if bm.isGroup then
 --    if mode == "group" then
	-- 	--todo
	-- 	print("gExitGroupGame getGroupState",require("xl_majiang.ddzSettings"):getGroupState())
	-- 	if require("xl_majiang.ddzSettings"):getGroupState() == 2 then
	-- 		require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])
	-- 	else
 --        	require("xl_majiang.ddzSettings"):setEndGroup(2)
	-- 		require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])
	-- 	end

	-- else
	-- 	--bm.display_scenes("xl_majiang.gameScenes")
	-- 	if mode == "free" then
	-- 		display_scene("xl_majiang.MJselectChip",1)
	-- 	elseif mode == "fast" then
	-- 		require("app.HallUpdate"):enterHall()
	-- 	end
	-- end
	
end

----------------------------------------------------------------------------------------------------------------

--用户准备相关
--广播用户准备
function MajiangroomHandle:SVR_USER_READY_BROADCAST(pack)

	dump(pack, "-----广播用户准备4001-----")

	local scenes = SCENENOW['scene'] 

	if SCENENOW['name'] ~= run_scene_name then
		return
	end

	if pack.uid == UID then
		--print(".....................SVR_USER_READY_BROADCAST..........................")
		scenes:show_ready_bar(0,false)
		scenes:show_hasselect(0,true)
		
	else
		local index = self:getIndex(pack.uid)
		self:showOtherReady(index)
		scenes:show_hasselect(index, true)

	end

end

--显示其他玩家准备
function MajiangroomHandle:showOtherReady(index)

	local scenes         = SCENENOW['scene']
	scenes:show_ready_bar(index,false)

end
----------------------------------------------------------------------------------------------------------------

--用户操作相关
--服务器告知客户端可以进行的操作
function MajiangroomHandle:SVR_NORMAL_OPERATE(pack)

	dump(pack, "-----服务器告知客户端可以进行的操作-----");

	self:showHandlesView(pack.operatype,pack.operacard)

end

--显示可以操作的界面
function MajiangroomHandle:showHandlesView(handle,card)	

	dump(handle,"-----显示可以操作的界面-----")
	dump(card,"-----显示可以操作的界面-----")

	--获取界面
	local scenes = SCENENOW['scene']
	if SCENENOW['name'] ~= run_scene_name then
		return
	end

	--获取可以进行的操作
	local result = MajiangcardHandle:getHandles(handle)
	local start = 420
	local has   = 1
	local width = 200

	local node = scenes:getChildByName("myhandles")
	if node then
		node:removeSelf()
	end

	--添加操作层
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
		bm.nodeClickHandler(hu, MajiangroomServer.requestHandle, result['h'], card)
	end

	--碰和杠
	local ifpg = 0
	if result['pg'] then
		ifpg = 1
		has = 0

		--添加杠按钮
		local path_other_gang = CARD_PATH_MANAGER:get_card_path("path_other_gang")
		local g = display.newSprite(path_other_gang)
		g:addTo(node)
		g:pos(start,200)
		bm.nodeClickHandler(g,MajiangroomServer.requestHandle, result['pg'], card)

		--添加碰按钮
		start         = start + 133
		local path_other_peng = CARD_PATH_MANAGER:get_card_path("path_other_peng")
		local p       = display.newSprite(path_other_peng)
		p:addTo(node)
		p:pos(start,200)

		bm.nodeClickHandler(p,MajiangroomServer.requestHandle, 0x008, card)
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

		has = 0

		--显示杠标志
		local path_other_gang = CARD_PATH_MANAGER:get_card_path("path_other_gang")
		local p = display.newSprite(path_other_gang)
		p:pos(start, 200)
		p:addTo(node)
		start = start + 133

		--判断是否可以补杠
		--摸牌补杠
		--记录当前摸到的牌是我已经碰过的牌，是的话则可以杠
		local find_flag =  false

		--检查我的碰杠牌记录
		local gang = {}
		dump(bm.Room.Card[0]['porg'],"-----我的碰杠牌-----")
		for i,v in pairs(bm.Room.Card[0]['porg']) do

			--缓存我已经碰杠过的牌，用作检查手牌中是否有可以杠的牌
			if gang[v] == nil then 
				gang[v] =  1
			else
				--gang[v]的值为3则碰牌，4则为杠牌
				gang[v] = gang[v] + 1
			end

			--当前摸到的牌是我已经碰过的牌（因为杠过的牌不可能再摸到）
			if v == card then
				find_flag = true
			end

		end

		--手牌补杠
		--记录可以手牌补杠
		local hand_gang_one = false
		--当前摸到的牌不是我已经碰过的牌
		if find_flag == false then

			--输出我的手牌
			dump(bm.Room.Card[0]['hand'],"hand")

			--检查手牌中是否有可杠的牌
			for i,v in pairs(bm.Room.Card[0]['hand']) do
				--v是当前的手牌，如果当前的手牌之前已经碰过
				if gang[v] ~= nil and gang[v] == 3 then
					--把可杠的牌设置为当前的这张手牌
					card = v;
					hand_gang_one = true
					break
				end
			end

		end

		--不是补杠

		--记录我手牌中能碰或杠的牌
		local hand_gang = {}
		for i,v in pairs(bm.Room.Card[0]['hand']) do
			if hand_gang[v] == nil then 
				hand_gang[v] =  1
			else
				--hand_gang[v]的值为3就是可碰的牌，可与摸到的牌匹配，判断是否能杠，为4则直接可杠
				hand_gang[v] = hand_gang[v] + 1
			end
		end

		--暗杠
		if hand_gang_one == false and find_flag == false then

			for i,v in pairs(bm.Room.Card[0]['hand']) do
				if hand_gang[v] ~= nil and hand_gang[v] == 4 then
					--判断是否为手牌暗杠
					card = v;
					break
				elseif hand_gang[v] ~= nil and hand_gang[v] == 3 and v == card then
					--判断是否为摸牌暗杠
					card = v;
					break
				end
			end


		end

		--以上都不是，就是明杠
 
 		--把要杠的牌返回到服务器
 		dump(card, "-----杠的牌-----")
		bm.nodeClickHandler(p, MajiangroomServer.requestHandle, result['g'], card)

	end

	if has == 0 then
		local guo = display.newSprite("xl_majiang/image/quan_guo.png")
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
function MajiangroomHandle:SVR_PLAYER_USER_BROADCAST(pack)
	
	dump(pack,"-----广播用户进行了什么操作-----")

	local scenes = SCENENOW['scene']
	if SCENENOW["name"] ~= run_scene_name then
		return
	end

	--获取用户进行的操作
	local result,mingoran = MajiangcardHandle:getHandles(pack.handle)
	local index = self:getIndex(pack.uid)
	dump(result,"result")

	--显示操作计时
	MajiangroomHandle:showTimer(pack.uid, 8)

	--假如当前为重连状态，需要移除掉被碰或杠的用户的最新出牌
	if bm.isReload == 1 then

		dump(pack.uid, "-----重连发生碰杠胡牌，操作的pack.uid-----")
		dump(pack.lid, "-----重连发生碰杠胡牌，出牌的pack.lid-----")

		local other_index = 0

		if pack.lid ~= UID then
			other_index = self:getIndex(pack.lid)
		end

		dump(bm.Room.Card[other_index]['out'], "-----出牌人的出牌数组-----")

		local count = #bm.Room.Card[other_index]['out']

		if count > 0 then

			table.remove(bm.Room.Card[other_index]['out'], count)

			dump(bm.Room.Card[other_index]['out'], "-----移除元素后出牌人的出牌数组-----")

			bm.isNowShowOutSign = 1

			self:drawOut(other_index)

		end
		
	end

	print("UID = ===================",UID)
	if pack.uid == UID then

		--移除已经添加的操作区域
		local node = scenes:getChildByName("myhandles")
		if node then 
			node:removeSelf() 
		end

		local zhua = scenes._scene:getChildByName("layer_card"):getChildByName("zhua")
		if zhua then 
			zhua:removeSelf() 
		end

		--如果原先我已经碰了，或者杆了，那么现在我重新
		if result['g'] or result['pg'] then

			local item_index = 1
			while item_index <= #bm.Room.Card[0]['porg'] do
				local temp_card = tonumber(bm.Room.Card[0]['porg'][item_index])
				if tonumber(pack.card) == temp_card then
					table.remove(bm.Room.Card[0]['porg'], item_index)
				else
					item_index = item_index + 1
				end
			end

			MajiangcardHandle:insertCardTo(bm.Room.Card[0]['porg'],{pack.card,pack.card,pack.card,pack.card})
			
			local item_index = 1
			while item_index <= #bm.Room.Card[0]['hand'] do
				local temp_card = tonumber(bm.Room.Card[0]['hand'][item_index])
				if tonumber(pack.card) == temp_card then
					table.remove(bm.Room.Card[0]['hand'], item_index)
				else
					item_index = item_index + 1
				end
			end

			bm.Room.Gang[0][pack.card] = mingoran
			bm.Room.my_out_card_time = 1--这行代码必须在self:drawHandCard(0)前
			self:drawHandCard(0)

			--显示杆特效（会与刮风下雨特效重复，屏蔽）
			-- local pos_x,pos_y = scenes:gettimerpos()
			-- show_guan_effect(scenes, pos_x, pos_y)
			
			print("gang=============------------------")
			self:anyCanOut()

			--播放杆声音
			local sound_path = sound_path_manager:GET_GANG_PENG_SOUND(USER_INFO["sex"], 3)
			-- cc.SimpleAudioEngine:getInstance():playEffect(sound_path,false)
			require("hall.VoiceUtil"):playEffect(sound_path,false)

		end

		--自己碰
		if result['p'] then

			MajiangcardHandle:insertCardTo(bm.Room.Card[0]['porg'],{pack.card,pack.card,pack.card})
			MajiangcardHandle:removeCardValue(bm.Room.Card[0]['hand'],pack.card,2,0)
			
			--这行代码必须在self:drawHandCard(0)前
			bm.Room.my_out_card_time = 1
			self:drawHandCard(0)
			--self:canoutFromHand()

			-- local pos_x,pos_y = scenes:gettimerpos()
			-- show_peng_effect(scenes,pos_x,pos_y)

			self:MypengHuGangAnim("p")

			print("peng=============------------------")
			self:anyCanOut()

			--播放碰声音
			local sound_path = sound_path_manager:GET_GANG_PENG_SOUND(USER_INFO["sex"],2)
			-- cc.SimpleAudioEngine:getInstance():playEffect(sound_path,false)
			require("hall.VoiceUtil"):playEffect(sound_path,false)

		end

	else

		--显示别人碰、杠、胡动画
		self:pengHuGangAnim(pack.uid, result)

		--杠，碰杠
		if result['g'] or result['pg'] then

			local item_index = 1
			while item_index <= #bm.Room.Card[index]['porg'] do
				local temp_card = tonumber(bm.Room.Card[index]['porg'][item_index])
				if tonumber(pack.card) == temp_card then
					table.remove(bm.Room.Card[index]['porg'], item_index)
				else
					item_index = item_index + 1
				end
			end

			MajiangcardHandle:insertCardTo(bm.Room.Card[index]['porg'],{pack.card,pack.card,pack.card,pack.card})
			if result['g'] == 0x400 then
				--补杠
				MajiangcardHandle:removeCardValue(bm.Room.Card[index]['hand'],0,1,index)
			elseif result['g'] == 0x200 then
				--暗杠
				MajiangcardHandle:removeCardValue(bm.Room.Card[index]['hand'],0,4,index)
			else
				MajiangcardHandle:removeCardValue(bm.Room.Card[index]['hand'],0,3,index)
			end
			
			self:drawHandCard(index)

			print("---------------------bm.Room.Gang[index][pack.card] = mingoran--------------------------------",index)
			bm.Room.Gang[index][pack.card] = mingoran

			local othInfo = bm.Room.UserInfo[pack.uid]

			if othInfo ~= nil then
				local sound_path = sound_path_manager:GET_GANG_PENG_SOUND(othInfo.sex,3)
				-- cc.SimpleAudioEngine:getInstance():playEffect(sound_path,false)
				require("hall.VoiceUtil"):playEffect(sound_path,false)
			end

		end 

		--碰
		if result['p'] then
			
			MajiangcardHandle:insertCardTo(bm.Room.Card[index]['porg'],{pack.card,pack.card,pack.card})

			MajiangcardHandle:removeCardValue(bm.Room.Card[index]['hand'],0,2,index)
			
			self:drawHandCard(index)
			
			MajiangroomHandle:showTimer(pack.uid,8)
			

			local othInfo = bm.Room.UserInfo[pack.uid]
			if othInfo ~= nil then
				local sound_path = sound_path_manager:GET_GANG_PENG_SOUND(othInfo.sex,2)
				-- cc.SimpleAudioEngine:getInstance():playEffect(sound_path,false)
				require("hall.VoiceUtil"):playEffect(sound_path,false)
			end

		end

	end

	--更改最后一张牌标记
	bm.Room.last = "otherhand"
	--显示或移除最后一张牌
	self:showLastEvent()

	--设置自己不是重连状态
	bm.isReload = 0

end

--显示自己碰
function MajiangroomHandle:MypengHuGangAnim(result)

	local x = 467.28
	local y = 168.11

	local scenes = SCENENOW['scene']

	local node = scenes:getChildByName("pghuamin")

	if node then
		node:removeSelf()
	end

	node = display.newNode()
	node:addTo(scenes)
	node:setName("pghuamin")
	node:setLocalZOrder(2000)

	if result == "p" then

		--添加底图
		local path_other_peng = "xl_majiang/image/effect_peng03.png"
		local object = display.newSprite(path_other_peng)
		object:setScale(0.9)
		object:pos(x, y)
		object:addTo(node)

		--添加顶层
		local path_other_peng_t = "xl_majiang/image/effect_peng01.png"
		local object_t = display.newSprite(path_other_peng_t)
		object_t:setOpacity(0)
		object_t:setScale(1.0)
		object_t:pos(x, y)
		object_t:addTo(node)

		--设置动画
		--渐出渐入
		local fadeIn = cc.FadeIn:create(0.4)
		object_t:runAction(cc.Sequence:create(fadeIn, fadeIn:reverse()))

		--放大缩小
		local scaleBy = cc.ScaleBy:create(0.4, 1.4, 1.4)
		object_t:runAction(cc.Sequence:create(scaleBy, scaleBy:reverse()))

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
		
	end,1.2)

end

--这里专门用来显示你看到的其他玩家（1，2，3）的碰，杠，胡动画显示
function MajiangroomHandle:pengHuGangAnim(uid,result)

	dump(uid,"-----显示你看到的其他玩家（1，2，3）的碰，杠，胡动画显示-----")
	dump(result,"-----显示你看到的其他玩家（1，2，3）的碰，杠，胡动画显示-----")

	local scenes = SCENENOW['scene']
	local index  = self:getIndex(uid)

	local config = {[1] = {['x'] = 268.76,['y'] = 295.40},
					[2] = {['x'] = 467.28,['y'] = 416.19},
					[3] = {['x'] = 664.62,['y'] = 295.40}
	}

	local node = scenes:getChildByName("pghuamin")

	if node then
		node:removeSelf()
	end

	node = display.newNode()
	node:addTo(scenes)
	node:setName("pghuamin")
	node:setLocalZOrder(2000)

	--杠、碰杠
	if result['g'] or result['pg'] then

		local path_other_gang = "xl_majiang/image/effect_gang03.png"
		local object = display.newSprite(path_other_gang)
		object:pos(config[index]['x'],config[index]['y'])
		object:addTo(node)

		local path_other_gang_t = "xl_majiang/image/effect_gang01.png"
		local object_t = display.newSprite(path_other_gang_t)
		object_t:pos(config[index]['x'],config[index]['y'])
		object_t:addTo(node)

		--设置动画
		--渐出渐入
		local fadeIn = cc.FadeIn:create(0.4)
		object_t:runAction(cc.Sequence:create(fadeIn, fadeIn:reverse()))

		--放大缩小
		local scaleBy = cc.ScaleBy:create(0.4, 1.4, 1.4)
		object_t:runAction(cc.Sequence:create(scaleBy, scaleBy:reverse()))

	end

	if result['p'] then

		--添加底图
		local path_other_peng = "xl_majiang/image/effect_peng03.png"
		local object = display.newSprite(path_other_peng)
		object:setScale(0.9)
		object:pos(config[index]['x'],config[index]['y'])
		object:addTo(node)

		--添加顶层
		local path_other_peng_t = "xl_majiang/image/effect_peng01.png"
		local object_t = display.newSprite(path_other_peng_t)
		object_t:setOpacity(0)
		object_t:setScale(1.0)
		object_t:pos(config[index]['x'],config[index]['y'])
		object_t:addTo(node)

		--设置动画
		--渐出渐入
		local fadeIn = cc.FadeIn:create(0.4)
		object_t:runAction(cc.Sequence:create(fadeIn, fadeIn:reverse()))

		--放大缩小
		local scaleBy = cc.ScaleBy:create(0.4, 1.4, 1.4)
		object_t:runAction(cc.Sequence:create(scaleBy, scaleBy:reverse()))

	end

	if result['h']then

		local path_other_hu = "xl_majiang/image/effect_hu03.png"
		local object = display.newSprite(path_other_hu)
		object:pos(config[index]['x'],config[index]['y'])
		object:addTo(node)

		local path_other_hu_t = "xl_majiang/image/effect_hu01.png"
		local object_t = display.newSprite(path_other_hu_t)
		object_t:pos(config[index]['x'],config[index]['y'])
		object_t:addTo(node)

		--设置动画
		--渐出渐入
		local fadeIn = cc.FadeIn:create(0.4)
		object_t:runAction(cc.Sequence:create(fadeIn, fadeIn:reverse()))

		--放大缩小
		local scaleBy = cc.ScaleBy:create(0.4, 1.4, 1.4)
		object_t:runAction(cc.Sequence:create(scaleBy, scaleBy:reverse()))

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
		
	end,1.2)

end
---------------------------------------------------------------------------------------------------------------

--托管相关
--广播用户托管
function MajiangroomHandle:SVR_ROBOT(pack)

	dump(pack,"-----广播用户托管-----")

	local scenes = SCENENOW['scene']
	if SCENENOW["name"] ~= run_scene_name then
		return
	end

	if pack.uid == UID then
		local scenes  = SCENENOW['scene']
		if  pack.kind  == 1 then
			bm.Room.tuoguan_ing = 1
			scenes:show_tuoguan_layout(true)
		else
			bm.Room.tuoguan_ing = 0
			scenes:show_tuoguan_layout(false)
		end
	end

end
-------------------------------------------------------------------------------------------------------------------

--发牌相关
--发牌协议
function MajiangroomHandle:SVR_SEND_USER_CARD(pack)

	dump(pack, "-----发牌协议-----")

	--清除所有胡标志
    self:clearAllHuSign()

	dump(bm.Room.User, "-----房间用户信息-----")
	local uid_arr = {}
	if bm.Room ~= nil then
		if bm.Room.User ~= nil then
			for k,v in pairs(bm.Room.User) do
				table.insert(uid_arr, k)
			end
		end
	end

	dump(uid_arr, "-----用户Id-----")
	require("hall.GameSetting"):setPlayerUid(uid_arr)

	local scenes  = SCENENOW['scene']
	if SCENENOW['name'] ~= run_scene_name then
		return
	end	

	bm.palying = true
	bm.isRun = true

	--记录庄家的座位
	bm.zuan_seat = pack.seat
	
	-- if bm.isGroup then
    if require("hall.gameSettings"):getGameMode() == "group" then
        --todo
        require("xl_majiang.gameScene"):setGameState(2)
    end
	--scenes:set_basescole_txt_visible(false)

	--隐藏邀请微信好友按钮
	scenes:hidendinvite()

	--隐藏解散房间按钮
	scenes:hidendisband()

	--隐藏用户准备标志
	scenes:hideAllSelect()

	--显示设置按钮
	scenes:ShowSettingButton()

	-- --添加视频引导
	-- require("hall.leader.LeaderLayer"):showLeaderLayer(cc.p(901.00, 265.00))

	-- --添加录音按钮
	-- require("hall.VoiceRecord.VoiceRecordView"):showView(901.00, 135.00)

	-- dump(bm.Room.ShowVoicePosion, "-----录音播放效果显示位置-----")

	--开始游戏时需要移动其他玩家的信息显示位置

	--移动自己
	scenes:hide_self_info()

	--移动其他用户
	scenes:hide_otherplayer_info(1)--false表示隐藏
	scenes:hide_otherplayer_info(2)--false表示隐藏
	scenes:hide_otherplayer_info(3)--false表示隐藏

	--骰子动画
	-- MajiangroomAnim:shuaiZi(pack.shai)

	-- bm.SchedulerPool:delayCall(MajiangroomHandle.SchedulerSendCard,2,pack)

	self:SchedulerSendCard(pack)

end

--发牌
function MajiangroomHandle:SchedulerSendCard(pack)

	dump(pack, "-----发牌-----")

	MajiangroomHandle:initCardForUser(pack)

	for i=0,3 do
		MajiangroomHandle:showPlayerCards(i)
	end

	--显示庄家
	MajiangroomHandle:showZhuang(pack.seat)

end

--发牌
-- function MajiangroomHandle:sendCard(pack)

-- 	MajiangcardHandle:setMyCards(pack.cards)
-- 	MajiangcardHandle:sortCards()
-- 	self:showMyHandMajiang()

-- end

--牌库初始化
function MajiangroomHandle:initCardForUser(pack)
	for i=0,3 do
		bm.Room.Card[i] = {}
		bm.Room.Card[i]['porg'] = {}
		bm.Room.Card[i]['hand'] = {0,0,0,0,0,0,0,0,0,0,0,0,0}
		bm.Room.Card[i]['out']  = {}

		bm.Room.Gang[i]         = {}
	end
	bm.Room.Card[0]['hand'] = pack.cards	--0号玩家的手牌

end

--显示玩家的牌
function MajiangroomHandle:showPlayerCards( index )

	MajiangroomHandle:drawHandCard(index)
	MajiangroomHandle:drawOut(index)

end

--显示庄家
function MajiangroomHandle:showZhuang(seat)

	local uid = UID

	if seat ~= bm.User.Seat then
		uid = bm.Room.seat_uid[seat]
	end

	local index = self:getIndex(uid)
	local scenes = SCENENOW['scene']
	if SCENENOW['name'] ~= run_scene_name then
		return
	end

	--显示庄家到用户信息上	
	scenes:show_widget_tip(index,true,"zuan_tip")

	--旋转庄家指示器
	scenes:RotationTimmer(index)

end

--显示手牌
function MajiangroomHandle:drawHandCard(index)
	
	--获取界面
	local scenes = SCENENOW['scene']
	if SCENENOW['name'] ~= run_scene_name then
		return
	end

	if index == 0 then

		--自己

		-- bm.Room.Card[0]['porg'] = {0x01,0x01,0x01,0x01}
  		-- bm.Room.Card[0]['hand'] = {0x11,0x12,0x13,0x14,0x15,0x16,0x02,0x02,0x02}
		-- bm.Room.Gang[0][0x01] = 1

		--获取碰的牌
		bm.Room.Card[index]['porg'] = MajiangcardHandle:sortCards(bm.Room.Card[index]['porg'])

		--获取手牌,并排序
		bm.Room.Card[index]['hand'] = MajiangcardHandle:sortCards(bm.Room.Card[index]['hand'])

		dump(bm.Room.Card[index]['hand'], "-----用户手牌-----")

		--把用户的缺牌放到右边
		local cache_arr = {}
		local newCard_arr = {}
		if bm.User.Que ~= nil then
			if bm.Room.Card[index]['hand'] ~= nil then

				for k,v in pairs(bm.Room.Card[index]['hand']) do

					local nowCardVariety = require("xl_majiang.card.Majiangcard"):getVariety(v)
					--判断当前牌的花色是否为缺色
					if bm.User.Que == nowCardVariety then
						table.insert(cache_arr, v)
					else
						table.insert(newCard_arr, v)
					end

				end

				--把缺色牌添加到新数组中
				if #cache_arr > 0 then
					for k,v in pairs(cache_arr) do
						table.insert(newCard_arr, v)
					end
				end

				bm.Room.Card[index]['hand'] = newCard_arr

			end
		end

		--获取牌的显示区域
		local layer_card = scenes._scene:getChildByName("layer_card")

		--移除界面上用户所有手牌
		local card_node = layer_card:getChildByName("owncard")
		if card_node then
			card_node:removeSelf()
		end

		local card_node = display.newNode()
		card_node:addTo(layer_card)
		card_node:setName("owncard")
		card_node:setLocalZOrder(1150)

		local huase = {	[0] = 0, [1] = 0, [2] = 0,}
		-- local s_point  = 119.00

		local s_point  = 90
		local y_ponit  = 50.00
		local y        = 0
		local pi       = 1
		local count    = 0
		local gang_num = 0
		local width    = 0 
		local my_point = 0
		local an_gang  = 0

		--绘制碰和杠的牌
		for i,v in pairs(bm.Room.Card[index]['porg']) do

			--碰牌
			local tmp = Majiangcard.new()
			tmp:setCard(v)
			tmp:setMyOutCard()
			tmp:setScale(0.9473, 0.762)
			y = y_ponit

			my_point = s_point + (pi - 1) * 52
			if bm.Room.Gang[index][v] then

				if bm.Room.Gang[index][v] == 1 then
					tmp:setMyBlack()
					tmp:setScale(1.3846,1.1355)
					my_point = s_point + (pi-1) * 52
				end

				count = count + 1

				if count == 4 then
					tmp:setMyOutCard()
					tmp:setScale(0.9473, 0.762)
					gang_num = gang_num + 1
					my_point = s_point + (pi - 3) * 52
					y  = y_ponit + 15
					count = 0
					pi =pi -1
				end

			else
				count = 0
			end

			tmp:pos(my_point, y - 10)
			tmp:addTo(card_node)
			
			pi = pi + 1

		end

		--绘制手牌
		--local s_point  = 148.83
		-- local start = (#bm.Room.Card[index]['porg'] - gang_num * 4 ) * (54 * 0.8 - 6) + gang_num * 3 * (54 * 0.8 - 6) + s_point
		local start = (#bm.Room.Card[index]['porg'] - gang_num * 4 ) * 54 + gang_num * 3 * 54 + s_point + 10
		local pi = 1
		local last_card_pos_x = 0
		for i,v in pairs(bm.Room.Card[index]['hand']) do 
			--print("inex:"..i)
			local tmp = Majiangcard.new()
			tmp:setCard(v)
			tmp:setMyHandCard()
			-- tmp:setScale(0.8,0.8383)
			tmp:setScale(1.1)
			-- tem:setScaleY()
			--tmp:dark()
			-- last_card_pos_x = start+(pi-1)*(54*0.8 - 6)
			last_card_pos_x = start+(pi-1) * 59.4
			tmp:pos(last_card_pos_x,y_ponit)
			tmp:setName(i)
			tmp:addTo(card_node)
			huase[tmp.cardVariety_] = huase[tmp.cardVariety_] + 1
			pi = pi + 1

		end

		--我胡的牌
		if bm.Room.Card[index]['hu'] then
			local tmp = Majiangcard.new()
			tmp:setCard(bm.Room.Card[index]['hu'])
			tmp:setMyOutCard()
			tmp:setScale(0.9473, 0.762)
			-- tmp:pos(870.00, y_ponit + 15)
			tmp:pos(770.00, y_ponit + 55)
			tmp:addTo(card_node)
		end

		--记录推荐的缺
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
		dump(bm.Room.Card[index]['porg'])
		dump(bm.Room.Gang[index])

		-- bm.Room.Card[1]['porg'] = {0x01,0x01,0x01,0x01,0x02,0x02,0x02,0x02,0x03,0x03,0x03,0x03,0x04,0x04,0x04}
  		-- bm.Room.Card[1]['hand'] = {1}--{0x01,0x01,0x01}
		-- bm.Room.Gang[1][0x01] = 0
		-- bm.Room.Gang[1][0x02] = 0
		-- bm.Room.Gang[1][0x03] = 0

		--绘制碰和杠的牌
		local last_y_pos = 0
		for i,v in pairs(bm.Room.Card[index]['porg']) do
			local tmp = Majiangcard.new()
			tmp:setCard(v)
			tmp:setLeftOutCard()
			-- tmp:setScale(0.54,0.45)
			local my_point = cout_s_point-(pi-1) * 22
			last_y_pos = cout_s_point-(pi-1) * 22
			if bm.Room.Gang[index][v] then
				if bm.Room.Gang[index][v] == 1 then
					tmp:setLeftBlack()
					tmp:setScale(1)
				end
				count = count + 1
				if count == 4 then
					tmp:setLeftOutCard()
					-- tmp:setScale(0.54,0.45)
					gang_num = gang_num + 1
					my_point =  cout_s_point-(pi-3) * 22
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
		for i,v in pairs(bm.Room.Card[index]['hand']) do 
			local tmp = Majiangcard.new()
			if v == 0 then --0标示，这个牌是在打的状态，显示的是背面
				tmp:setLeftHand()
				tmp:pos(x_ponit,start - (pi-1) * 22)
				last_y_pos = start - (pi-1) * 22
			else
				tmp:setCard(v)
				tmp:setLeftOutCard()
				-- tmp:setScale(0.54,0.45)
				tmp:pos(x_ponit,start - (pi-1) * 22)--手牌自摸
				last_y_pos =start - (pi-1) * 22
			end
			tmp:addTo(card_node)
			tmp:setName(i)
			pi = pi + 1
		end
		
		if bm.Room.Card[index]['hu'] then
			local tmp = Majiangcard.new()
			tmp:setCard(bm.Room.Card[index]['hu'])
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
		local y_ponit = 492.00
	
		local pi      = 1

		--绘制碰和杠的牌
		local count    = 0
		local gang_num = 0
		local item_width = 30
		local item_heigth = 42

		-- bm.Room.Card[2]['porg'] = {0x01,0x01,0x01,0x01,0x02,0x02,0x02,0x02,0x03,0x03,0x03,0x03,0x04,0x04,0x04}
  --  		bm.Room.Card[2]['hand'] = {0x01,0x01,0x01}
		-- bm.Room.Gang[2][0x01] = 1
		-- bm.Room.Gang[2][0x02] = 1
		-- bm.Room.Gang[2][0x03] = 1

		dump(bm.Room.Card[index]['porg'],"porg_card_index_2")

		local last_posss = 0
		for i,v in pairs(bm.Room.Card[index]['porg']) do

			local tmp = Majiangcard.new()
			tmp:setCard(v)
			tmp:setMyOutCard()
			tmp:setScale(0.5,0.5)
			-- local my_point = s_point-(pi-1)*(74*0.4 -2)
			local my_point = s_point - (pi-1) * 27
			last_posss = my_point
			local less = 0
			if bm.Room.Gang[index][v] then

				if bm.Room.Gang[index][v] == 1 then
					tmp:setTopBlack()
					tmp:setScale(0.7307,0.7457)
				end

				count = count + 1

				if count == 4 then
					tmp:setMyOutCard()
					tmp:setScale(0.5,0.5)
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
		for i,v in pairs(bm.Room.Card[index]['hand']) do 

			local tmp = Majiangcard.new()

			if v == 0 then
				tmp:setTopHandCard()
				tmp:pos(start - (pi-1) * 30, y_ponit)
				last_posss = start - (pi-1) * 30
			else
				tmp:setCard(v)
				tmp:setMyOutCard()
				tmp:setScale(0.5,0.5)
				-- tmp:pos(start-(pi-1)*(74*0.4-2),y_ponit)
				tmp:pos(start - (pi-1) * 54, y_ponit)
				-- last_posss = start-(pi-1)*(74*0.4-2)
				last_posss = start - (pi-1) * 54
			end
			
			tmp:addTo(card_node)
			tmp:setName(i)
			pi = pi + 1

		end

		--bm.Room.Card[2]['hu'] = 0x02
		if bm.Room.Card[index]['hu'] then
			local tmp = Majiangcard.new()
			tmp:setCard(bm.Room.Card[index]['hu'])
			tmp:setMyOutCard()
			tmp:setScale(0.5,0.5)
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

		-- bm.Room.Card[3]['porg'] = {0x01,0x01,0x01,0x01,0x02,0x02,0x02,0x02,0x03,0x03,0x03}
  		-- bm.Room.Card[3]['hand'] = {0x01,0x01,0x01,0x01}
		-- bm.Room.Gang[3][0x01] = 1
		-- bm.Room.Gang[3][0x02] = 1
		-- bm.Room.Gang[3][0x03] = 0

		local last_ppos = 0
			--绘制碰和杠的牌
		for i,v in pairs(bm.Room.Card[index]['porg']) do
			local tmp = Majiangcard.new()
			tmp:setCard(v)
			tmp:setRightOutCard()
			-- tmp:setScale(0.54,0.45)
			tmp:zorder(c-pi)
			local my_point = s_point+(pi-1) * 22
			if bm.Room.Gang[index][v] then
				if bm.Room.Gang[index][v] == 1 then
					tmp:setLeftBlack()
					tmp:setScale(1)
				end
				count = count + 1
				if count == 4 then
					tmp:setRightOutCard()
					-- tmp:setScale(0.54,0.45)
					gang_num = gang_num +1
					my_point = s_point+(pi-3) * 22
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
			s_point =  last_ppos + 50
		end
		
		local   c   =  1000
		
		local pi    = 1
		local last_y_pos = 0
		for i,v in pairs(bm.Room.Card[index]['hand']) do 
			local tmp = Majiangcard.new()
			if v ==  0 then
				tmp:setRightHand()
				last_y_pos = s_point+(pi-1) * 22
				tmp:pos(x_ponit,s_point+(pi-1) * 22)  --手牌
			else
				tmp:setCard(v)
				tmp:setRightOutCard()
				-- tmp:setScale(0.54,0.45)
				tmp:pos(x_ponit,s_point+(pi-1) * 22)--手牌自摸
				last_y_pos = s_point+(pi-1) * 22
			end

			tmp:addTo(card_node) 
			tmp:zorder(c-pi)
			tmp:setName(i)
			pi = pi + 1

		end

		--bm.Room.Card[index]['hu'] = 0x01
		if bm.Room.Card[index]['hu'] then
			local tmp = Majiangcard.new()
			tmp:setCard(bm.Room.Card[index]['hu'])
			tmp:setRightOutCard()
			-- tmp:setScale(0.54,0.45)        
			tmp:pos(x_ponit,last_y_pos + 30)
			tmp:addTo(card_node)
		end

	end

end

--显示手牌（重连后当前为自己出牌）
function MajiangroomHandle:drawHandCardAfterBack(index)

	local scenes = SCENENOW['scene']
	if SCENENOW['name'] ~= run_scene_name then
		return
	end

	--获取碰的牌
	bm.Room.Card[index]['porg'] = MajiangcardHandle:sortCards(bm.Room.Card[index]['porg'])

	--获取手牌,并排序
	bm.Room.Card[index]['hand'] = MajiangcardHandle:sortCards(bm.Room.Card[index]['hand'])

	dump(bm.Room.Card[index]['hand'], "-----用户手牌-----")

	--把用户的缺牌放到右边
	local cache_arr = {}
	local newCard_arr = {}
	if bm.User.Que ~= nil then
		if bm.Room.Card[index]['hand'] ~= nil then

			for k,v in pairs(bm.Room.Card[index]['hand']) do

				local nowCardVariety = require("xl_majiang.card.Majiangcard"):getVariety(v)

				--判断当前牌的花色是否为缺色
				if bm.User.Que == nowCardVariety then
					table.insert(cache_arr, v)
				else
					table.insert(newCard_arr, v)
				end

			end

			--把缺色牌添加到新数组中
			if #cache_arr > 0 then
				for k,v in pairs(cache_arr) do
					table.insert(newCard_arr, v)
				end
			end

			bm.Room.Card[index]['hand'] = newCard_arr

		end
	end

	--获取牌的显示区域
	local layer_card = scenes._scene:getChildByName("layer_card")

	--移除界面上用户所有手牌
	local card_node = layer_card:getChildByName("owncard")
	if card_node then
		card_node:removeSelf()
	end

	local card_node = display.newNode()
	card_node:addTo(layer_card)
	card_node:setName("owncard")
	card_node:setLocalZOrder(1150)

	local huase = {	[0] = 0, [1] = 0, [2] = 0,}
	-- local s_point  = 119.00
	local s_point  = 90.00
	local y_ponit  = 50.00
	local y        = 0
	local pi       = 1
	local count    = 0
	local gang_num = 0
	local width    = 0 
	local my_point = 0
	local an_gang  = 0

	--绘制碰和杠的牌
	for i,v in pairs(bm.Room.Card[index]['porg']) do

		--碰牌
		local tmp = Majiangcard.new()
		tmp:setCard(v)
		tmp:setMyOutCard()
		tmp:setScale(0.9473, 0.762)
		y = y_ponit

		my_point = s_point + (pi - 1) * 52
		if bm.Room.Gang[index][v] then

			if bm.Room.Gang[index][v] == 1 then
				tmp:setMyBlack()
				tmp:setScale(1.3846,1.1355)
				my_point = s_point + (pi-1) * 52
			end

			count = count + 1

			if count == 4 then
				tmp:setMyOutCard()
				tmp:setScale(0.9473, 0.762)
				gang_num = gang_num + 1
				my_point = s_point + (pi - 3) * 52
				y  = y_ponit + 15
				count = 0
				pi =pi -1
			end

		else
			count = 0
		end

		tmp:pos(my_point, y - 10)
		tmp:addTo(card_node)
		
		pi = pi + 1

	end

	--绘制手牌
	--local s_point  = 148.83
	-- local start = (#bm.Room.Card[index]['porg'] - gang_num * 4 ) * (54 * 0.8 - 6) + gang_num * 3 * (54 * 0.8 - 6) + s_point
	local start = (#bm.Room.Card[index]['porg'] - gang_num * 4 ) * 54 + gang_num * 3 * 54 + s_point + 10
	local pi = 1
	local last_card_pos_x = 0
	for i,v in pairs(bm.Room.Card[index]['hand']) do 
		--print("inex:"..i)
		local tmp = Majiangcard.new()
		tmp:setCard(v)
		tmp:setMyHandCard()
		tmp:setScale(1.1)
		-- tem:setScaleY()
		--tmp:dark()
		-- last_card_pos_x = start+(pi-1)*(54*0.8 - 6)
		last_card_pos_x = start+(pi-1) * 59.4

		if i == #bm.Room.Card[index]['hand'] then
			--当前是最后一张牌
			last_card_pos_x = last_card_pos_x + 20
		end

		tmp:pos(last_card_pos_x,y_ponit)
		tmp:setName(i)
		tmp:addTo(card_node)
		huase[tmp.cardVariety_] = huase[tmp.cardVariety_] + 1
		pi = pi + 1

	end

	--我胡的牌
	if bm.Room.Card[index]['hu'] then
		local tmp = Majiangcard.new()
		tmp:setCard(bm.Room.Card[index]['hu'])
		tmp:setMyOutCard()
		tmp:setScale(0.9473, 0.762)
		tmp:pos(870.00, y_ponit + 15)
		tmp:addTo(card_node)
	end

	--记录推荐的缺
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

	--设置我可以出的牌
	self:anyCanOut()

end

--绘出玩家已经出的牌
function MajiangroomHandle:drawOut(index)

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

	--出的牌标志
	--去掉上一只牌标志
	local nowCardSign = scenes:getChildByName("nowCardSign")
	if nowCardSign then
		nowCardSign:removeSelf()
	end

	--添加新标志
	nowCardSign = display.newNode()
	nowCardSign:setName("nowCardSign")
	nowCardSign:setLocalZOrder(1501)
	nowCardSign:addTo(scenes)
	local path_nowCardSign = "xl_majiang/image/nowCardSign.png"
	local nowCardSign_object = display.newSprite(path_nowCardSign)
	nowCardSign_object:addTo(nowCardSign)

	if bm.isNowShowOutSign == 1 then
		nowCardSign:setVisible(false)
		bm.isNowShowOutSign = 0
	end

	--自己
	if index == 0 then
		--bm.Room.Card[index]['out'] = {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}
		--绘制已经出的牌
		local item_width = 27.00
		local item_heigth = 31.00

		local x_start = 0
		local y_start = 0

		local x_start1 = 418.00
		local y_start1 = 178.00

		local x_start2 = 391.00
		local y_start2 = 146.00

		local x_start3 = 364.00
		local y_start3 = 115.00

		local x_start4 = 337.00
		local y_start4 = 82.00

		local pi      = 1
		local count   = 1
		local all     = 100
		for i,v in pairs(bm.Room.Card[index]['out']) do 

			local tmp = Majiangcard.new()
			tmp:setCard(v)
			tmp:setMyOutCard()
			tmp:setScale(0.5,0.5)
			if i >= 0 and i < 6 then
				x_start = x_start1
				y_start = y_start1
			elseif i >= 6 and i < 13 then
				x_start = x_start2
				y_start = y_start2
				all = 101
			elseif i >= 13 and i < 22 then
				x_start = x_start3
				y_start = y_start3
				all = 102
			elseif i >= 22 and i < 32 then
				x_start = x_start3
				y_start = y_start3
				all = 103
			end

			if i == 6 or i == 13 or i == 22 then
				pi = 1
			end

			tmp:pos(x_start + (pi-1) * item_width, y_start + (count-1) * item_heigth)


			tmp:addTo(card_node,all)
			all = all - 1

			if i == #bm.Room.Card[index]['out'] then
				nowCardSign_object:pos(x_start + (pi-1) * item_width, y_start + (count-1) * item_heigth + 31)
			end

			pi = pi + 1
			-- if pi > 11 then
			-- 	pi = 1
			-- 	count =count +1
			-- end

		end
	end

	--左边
	if index == 1 then
		local item_width = 36.00
		local item_heigth = 23.00


		local x_start = 0
		local y_start = 0

		local x_start1 = 337.00
		local y_start1 = 339.00

		local x_start2 = 301.00
		local y_start2 = 362.00

		local x_start3 = 265.00
		local y_start3 = 385.00

		local x_start4 = 229.00
		local y_start4 = 408.00


		local pi      = 1
		local count   = 1
        --bm.Room.Card[index]['out'] = {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}
		for i,v in pairs(bm.Room.Card[index]['out']) do 
			local tmp = Majiangcard.new()
			tmp:setCard(v)
			tmp:setLeftOutCard()
			-- tmp:setScale(0.5)

			if i >= 0 and i < 6 then
				x_start = x_start1
				y_start = y_start1
			elseif i >= 6 and i < 13 then
				x_start = x_start2
				y_start = y_start2
			elseif i >= 13 and i < 22 then
				x_start = x_start3
				y_start = y_start3
			elseif i >= 22 and i < 32 then
				x_start = x_start3
				y_start = y_start3
			end

			if i == 6 or i == 13 or i == 22 then
				pi = 1
			end

			tmp:pos(x_start + (count-1) * item_width, y_start - (pi-1) * (item_heigth))
			tmp:addTo(card_node)

			if i == #bm.Room.Card[index]['out'] then
				nowCardSign_object:pos(x_start + (count-1) * item_width + 15, y_start - (pi-1) * (item_heigth) + 23)
			end

			pi = pi + 1
			-- if pi > 12 then
			-- 	pi = 1
			-- 	count = count + 1
			-- end

		end
	end

	--对家
	if index == 2 then
		--bm.Room.Card[index]['out'] = {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}
		local item_width = 27.00
		local item_heigth = 31.00

		local x_start = 0
		local y_start = 0

		local x_start1 = 524.00
		local y_start1 = 367.00

		local x_start2 = 551.00
		local y_start2 = 399.00

		local x_start3 = 578.00
		local y_start3 = 433.00

		local x_start4 = 605.00
		local y_start4 = 467.00

		local pi      = 1
		local count   = 1
		local order   = 4

		for i,v in pairs(bm.Room.Card[index]['out']) do 
			local tmp = Majiangcard.new()
			tmp:setCard(v)
			tmp:setMyOutCard()
			tmp:setScale(0.5,0.5)

			if i >= 0 and i < 6 then
				x_start = x_start1
				y_start = y_start1
			elseif i >= 6 and i < 13 then
				x_start = x_start2
				y_start = y_start2
				order   = 3
			elseif i >= 13 and i < 22 then
				x_start = x_start3
				y_start = y_start3
				order   = 2
			elseif i >= 22 and i < 32 then
				x_start = x_start3
				y_start = y_start3
				order   = 1
			end

			if i == 6 or i == 13 or i == 22 then
				pi = 1
			end

			tmp:pos(x_start-(pi-1)*item_width,y_start-(count-1)*item_heigth)
			tmp:addTo(card_node,order)

			if i == #bm.Room.Card[index]['out'] then
				nowCardSign_object:pos(x_start-(pi-1) * item_width, y_start-(count-1) * item_heigth + 31)
			end

			pi = pi + 1
			if pi > 11 then
				pi = 1
				count = count +1
			end

		end
	end

	--右边
	if index == 3 then
		--bm.Room.Card[index]['out'] = {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}

		local x_start = 0
		local y_start = 0

		local x_start1 = 595.00
		local y_start1 = 251.00

		local x_start2 = 631.00
		local y_start2 = 228.00

		local x_start3 = 667.00
		local y_start3 = 207.00

		local x_start4 = 703.00
		local y_start4 = 186.00

		local item_width = 36.00
		local item_heigth = 23.00
		local pi      = 1
		local count   = 1
		local zorder_z = 1000
		for i,v in pairs(bm.Room.Card[index]['out']) do 
			local tmp = Majiangcard.new()
			tmp:setCard(v)
			tmp:setRightOutCard()
			-- tmp:setScale(0.5)

			if i >= 0 and i < 6 then
				x_start = x_start1
				y_start = y_start1
			elseif i >= 6 and i < 13 then
				x_start = x_start2
				y_start = y_start2
				order   = 3
			elseif i >= 13 and i < 22 then
				x_start = x_start3
				y_start = y_start3
				order   = 2
			elseif i >= 22 and i < 32 then
				x_start = x_start3
				y_start = y_start3
				order   = 1
			end

			if i == 6 or i == 13 or i == 22 then
				pi = 1
			end

			tmp:pos(x_start-(count-1)*item_width,y_start+(pi-1)*(item_heigth))
			tmp:addTo(card_node)
			tmp:zorder(zorder_z-pi)

			if i == #bm.Room.Card[index]['out'] then
				nowCardSign_object:pos(x_start-(count-1) * item_width - 15, y_start+(pi-1) * (item_heigth) + 23)
			end

			pi = pi + 1
			-- if pi > 12 then
			-- 	pi = 1
			-- 	count =count +1
			-- end

		end
	end

end

--重新显示牌
function  MajiangroomHandle:showMyHandMajiang()
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
function MajiangroomHandle:SERVER_COMMAND_NEED_CHANGE_CARD(pack)

	dump(pack, "-----可以换牌-----")

	local scenes = SCENENOW['scene'] 

	if SCENENOW['name'] ~= run_scene_name then
		return
	end

	--设置当前开始换牌
	bm.huanCardsStart = true
	--设置当前换牌未结束
	bm.Room.change_card_over = false
	--初始化换牌记录数组
	bm.Room.cardHuan = {};
	--初始化换牌选择花色
	bm.Room.selectCardVariety = 0

	--显示换牌提示
	scenes:show_Text_18(true)

	--显示换牌倒计时
	local hpTimer_tt = scenes._scene:getChildByName("hpTimer_tt")
	--换牌倒计时操作
	local timer = 10 
	local ac = cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function()
			timer=timer-1
			hpTimer_tt:setString(timer)
			if timer==0 then

				hpTimer_tt:stopAllActions();

				scenes:show_Text_18(false)

			end
		end)))
	hpTimer_tt:runAction(ac)

end

--服务器广播换牌的结果
function MajiangroomHandle:SERVER_COMMAND_CHANGE_CARD_RESULT(pack)

	dump(pack, "-----服务器广播换牌的结果-----")

	local scenes  = SCENENOW['scene']

	if SCENENOW['name'] ~= run_scene_name then
		return
	end
	
	scenes:show_Text_18(false)

	bm.Room.change_card_over = true
	--bm.Room.cardHuan = bm.Room.cardHuan or {} -- 可能存在没有换的状况

	-- if bm.Room ~= nil then
	-- 	if bm.Room.Card ~= nil then
			
	-- 		local old_hand_card = bm.Room.Card[0]['hand']
	-- 		dump(old_hand_card,"old_hand_card") 
	-- 		if pack.mount > 0 then
	-- 			--0号玩家的手牌
	-- 			bm.Room.Card[0]['hand'] = pack.cards	
	-- 			self:drawHandCard(0)
	-- 		end

	-- 		dump(bm.Room.Card[0]['hand'],"-----当前用户换牌后的新手牌-----") 

	-- 		bm.Room.Card[0]['hand'] = MajiangcardHandle:sortCards(bm.Room.Card[0]['hand'])

	-- 	end
	-- end

	if bm.Room ~= nil then
		if bm.Room.Card ~= nil then
			if bm.Room.Card[0] ~= nil then
				if bm.Room.Card[0]['hand'] ~= nil then

					local old_hand_card = bm.Room.Card[0]['hand']
					dump(old_hand_card,"old_hand_card") 
					if pack.mount > 0 then
						--0号玩家的手牌
						bm.Room.Card[0]['hand'] = pack.cards	
						self:drawHandCard(0)
					end

					dump(bm.Room.Card[0]['hand'],"-----当前用户换牌后的新手牌-----") 

					bm.Room.Card[0]['hand'] = MajiangcardHandle:sortCards(bm.Room.Card[0]['hand'])

					local gang_num  = 0
					local scenes = SCENENOW['scene']
					local card_node = scenes._scene:getChildByName("layer_card"):getChildByName("owncard")
					if card_node  then card_node:removeSelf() end
					card_node = display.newNode()
					card_node:addTo(scenes._scene:getChildByName("layer_card"))
					card_node:setName("owncard")
					card_node:setLocalZOrder(50)

					local s_point  = 119.00
					local y_ponit  = 50.00

					local start = 90.00
					local pi    = 1

					local time_index  = 1
					for i,v in pairs(bm.Room.Card[0]['hand']) do 

						local tmp = Majiangcard.new()
						tmp:setCard(v)
						tmp:setMyHandCard()
						tmp:setScale(1.1)
						-- tmp:dark()
						local find_index = table.indexof(old_hand_card,v)
						if find_index == false then
							-- tmp:pos(start+(pi-1)*(74*0.8 - 6),y_ponit + 40)
							tmp:pos(start + (pi-1) * 59.4, y_ponit + 40)
							tmp:moveBy(1, 0, -40)
						else
							table.remove(old_hand_card,find_index)
							-- tmp:pos(start+(pi-1)*(74*0.8 - 6),y_ponit)
							tmp:pos(start+(pi-1) * 59.4, y_ponit)
						end

						tmp:setName(i)
						tmp:addTo(card_node)
						--huase[tmp.cardVariety_] = huase[tmp.cardVariety_] + 1
						pi = pi + 1

					end

				end
			end
		end
	end

	SCENENOW['scene']._scene:getChildByName("Button_11"):hide()
	SCENENOW['scene']._scene:getChildByName("Button_11_0"):hide()

	bm.huanCardsStart = false;

end
----------------------------------------------------------------------------------------------------------------------------------

--选缺相关
--开始选择缺门
function  MajiangroomHandle:SVR_START_QUE_CHOICE(pack)

	dump(pack,"-----开始选缺-----")

	local scenes = SCENENOW['scene']
	if SCENENOW['name'] ~= run_scene_name then
		return
	end

	scenes:show_other_xuanqueing(true)
	scenes:show_choosing_que(true)
	
end

--广播缺一门  通知用户选缺选了哪一门,这时游戏还没有开始，
function MajiangroomHandle:SVR_BROADCAST_QUE(pack)

	dump(pack,"-----广播缺一门-----")

	--设置换牌阶段已经结束
	bm.Room.change_card_over = true

	bm.User.Que = nil
	bm.Room.Que = true

	for i,v in pairs(pack.content) do
		self:hasChoiceQue(v.uid,v.que)
	end

end

--设置已经选缺
function MajiangroomHandle:hasChoiceQue(uid,que)

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

	--重新排列我的牌
	self:drawHandCard(0)

end
----------------------------------------------------------------------------------------------------------------

--抓牌相关
--广播抓牌用户
function MajiangroomHandle:SVR_PLAYING_UID_BROADCAST(pack)
	
	dump(pack,"-----广播抓牌用户-----")

	bm.isReload = 0

	local scenes  = SCENENOW['scene']
	if SCENENOW['name'] ~= run_scene_name then
		return
	end

	--选缺有时候没有被删掉，这里多加个判断算了
	local node = scenes:getChildByName("xuan_que_ing")
	if node ~= nil then
		node:removeSelf()
	end

	--显示最后出的牌
	self:showLastEvent()

	MajiangroomHandle:showTimer(pack.uid,8)

	local index = self:getIndex(pack.uid)
	self:zhuaMajiang(index)
	if bm.Room.Card and bm.Room.Card[index] then

		MajiangcardHandle:insertCardTo(bm.Room.Card[index]['hand'],{0})	
		
	end

	--设置剩余的牌数
	--scenes:set_left_card_num_visible(true)
	scenes:set_left_card_num(tostring(pack.simplNum))

end

--通知我抓的牌
function MajiangroomHandle:SVR_OWN_CATCH_BROADCAST(pack)

	dump(pack,"-----通知我抓的牌-----")

	local scenes = SCENENOW['scene']

	if SCENENOW['name'] ~= run_scene_name then
		return
	end

	bm.Room.my_out_card_time = 1
	scenes:show_Text_18(false)
	bm.Room.change_card_over = true

	--显示最后出的牌
	self:showLastEvent()

	--检查和显示我可以做的操作
	self:showHandlesView(pack.handle,pack.card)

	--显示操作倒计时
	MajiangroomHandle:showTimer(UID,8)


	-- local card_node = scenes:getChildByName("owncard")
	-- if card_node == nil then
	-- 	card_node = display.newNode()
	-- 	card_node:addTo(scenes)
	-- 	card_node:setName("owncard")
	-- end
	
	--记录我当前的手牌到缓存
	MajiangcardHandle:insertCardTo(bm.Room.Card[0]['hand'],{pack.card})

	--local s_point  = 148.83
	--local gang_num = table.nums(bm.Room.Gang[0])
	-- local start = (#bm.Room.Card[index]['porg'] - gang_num*4 )*(74*0.8 - 6) + gang_num*3*(74*0.8 - 6) + s_point

	--绘制我的手牌到界面
	local tmp = Majiangcard.new()
	tmp:setCard(pack.card)
	tmp:setScale(1.1)
	tmp:setMyHandCard()
	tmp:setName("zhua")
	tmp:setIsZhua()
	tmp:addTo(scenes._scene:getChildByName("layer_card"))

	--计算碰杠牌占的位置
	local count    = 0
	local gang_num = 0
	for i,v in pairs(bm.Room.Card[0]['porg']) do

		if bm.Room.Gang[0][v] then

			count = count + 1

			if count == 4 then
				gang_num = gang_num + 1
				count = 0
			end

		else
			count = 0
		end

	end

	--计算手牌占的位置
	local start = (#bm.Room.Card[0]['porg'] - gang_num * 4 ) * 54 + gang_num * 3 * 54 + 90 + 10
	local pi = 1
	local last_card_pos_x = 0
	for i,v in pairs(bm.Room.Card[0]['hand']) do 
		last_card_pos_x = start + (pi-1) * 59.4
		pi = pi + 1
	end

	tmp:pos(last_card_pos_x + 20, 50.00)

	self:anyCanOut(tmp)

	--设置剩余的牌数
	scenes:set_left_card_num(tostring(pack.simplNum))

end

--显示其他人抓牌
function MajiangroomHandle:zhuaMajiang(index)

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
		tmp:pos(373.00, 497.00)
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
		tmp:pos(839.00, 455.00)
		tmp:setName("zhua")
		tmp:addTo(card_node)
	
	end

end
---------------------------------------------------------------------------------------------------------------

--出牌相关
--显示我的牌哪些可以出，去掉暗化
function MajiangroomHandle:anyCanOut(node)

	dump(node,"-----显示我的牌哪些可以出，去掉暗化-----")

	local scenes = SCENENOW['scene']
	if SCENENOW['name'] ~= run_scene_name then
		return
	end

	local que_num = 0 
	for i,v in pairs(bm.Room.Card[0]['hand']) do
		local huase = Majiangcard:getVariety(v)
		if huase == bm.User.Que then
			que_num = que_num + 1
		end
	end

	print("que_num==================",que_num)
	dump(bm.Room.Card[0]['hand'])
	if que_num ~= 0 then
		for i,v in pairs(bm.Room.Card[0]['hand']) do
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

		if node then
			--todo
			if node.cardVariety_ ~= bm.User.Que then
				node:dark()
			end
		end
		
	end

end

--从手中出牌
function MajiangroomHandle:canoutFromHand()

	dump("","-----从手中出牌-----")

	local scenes    = SCENENOW['scene']
	if SCENENOW['name']~= run_scene_name then
		return
	end

	local count = 0
	for i,v in pairs(bm.Room.Card[0]['hand']) do
			local huase     = Majiangcard:getVariety(v)
			local card_node = scenes._scene:getChildByName("layer_card"):getChildByName("owncard")
			if huase == bm.User.Que then
				local card_tmp = card_node:getChildByName(i) 
				card_tmp:setMyHandCard()
				count = count +1
			end
	end

	if count == 0 then
		for i,v in pairs(bm.Room.Card[0]['hand']) do
				
			local card_node = scenes._scene:getChildByName("layer_card"):getChildByName("owncard")
			local card_tmp = card_node:getChildByName(i) 
			card_tmp:setMyHandCard()
				
		end
	end

end 

--广播用户出牌
function MajiangroomHandle:SVR_SEND_MAJIANG_BROADCAST(pack)
	
	dump(pack,"-----广播用户出牌-----")

	--设置自己不是重连状态
	bm.isReload = 0
	
	local scenes = SCENENOW['scene']
	if SCENENOW['name'] ~= run_scene_name then
		return
	end

	--显示这张牌会触发我可以进行的操作
	self:showHandlesView(pack.handle,pack.card)

	--获取牌是从哪个用户对应的位置出来的
	local index     = self:getIndex(pack.uid)
	local card_node = scenes._scene:getChildByName("layer_card"):getChildByName("othercard"..index)
	--匹配我可以进行的操作
	local result    = MajiangcardHandle:getHandles(pack.handle)

	local zhua      = scenes._scene:getChildByName("layer_card"):getChildByName("zhua")
	if zhua then  zhua:removeSelf() end
	
	--移除出牌用户一张手牌
	if index == 0 then
		MajiangcardHandle:removeCardValue(bm.Room.Card[index]['hand'],pack.card,1,index)		
	else
		MajiangcardHandle:removeCardValue(bm.Room.Card[index]['hand'],0,1,index)
	end

    --这里表示的是牌从哪个位置开始打出来，放大显示牌
	local config = {[0]={['x'] = 300.00,['y'] = 192.00,},
					[1]={['x'] = 276.00,['y'] = 347.00,},
					[2]={['x'] = 620.00,['y'] = 375.00,},
					[3]={['x'] = 680.00,['y'] = 295.00,},}

	--重绘出牌用户手牌（为其去掉一张手牌）
	self:drawHandCard(index)

	--最后出的牌放大显示
	local tmp = Majiangcard.new()
	tmp:setCard(pack.card)
	tmp:setBigOutCard()
	tmp:setScale(1)
	tmp:addTo(scenes)
	tmp:setName("chu")
	tmp:zorder(1500)
	tmp:pos(config[index]['x'],config[index]['y'])

	--记录出的牌
	bm.Room.last       = "chupai" --上次的动作
	bm.Room.index      = index --上次的序号
	bm.Room.card_value = pack.card --上次的牌

	--播放出牌声音
	self:play_card_sound(pack.uid,pack.card,index)

end

--出牌播放声音
function MajiangroomHandle:play_card_sound(uid,card_value,index)

	dump(uid,"-----出牌播放声音用户-----")
	dump(card_value,"-----出牌播放声音牌值-----")
	dump(index,"-----出牌播放声音-----")

	local sound_path =""
	if index == 0 then
		sound_path = sound_path_manager:GET_CARD_SOUND(USER_INFO["sex"],card_value)
		-- cc.SimpleAudioEngine:getInstance():playEffect(sound_path,false)
		require("hall.VoiceUtil"):playEffect(sound_path,false)
	else
		local pack = bm.Room.UserInfo[uid]
		if pack == nil then
			return
		end
		sound_path = sound_path_manager:GET_CARD_SOUND(pack.sex,card_value)
		-- cc.SimpleAudioEngine:getInstance():playEffect(sound_path,false)
		require("hall.VoiceUtil"):playEffect(sound_path,false)
	end
	
end

--显示或移除最后出的牌
function MajiangroomHandle:showLastEvent()

	dump("","-----显示或移除最后出的牌-----")

	local scenes = SCENENOW['scene']

	if bm.Room.last == "chupai" then

		local chu = scenes:getChildByName("chu")
		if chu then
			local fade = cc.FadeOut:create(0.5)
			chu:runAction(fade)
		end
		
		MajiangcardHandle:insertCardTo(bm.Room.Card[bm.Room.index]['out'],{bm.Room.card_value})
		bm.SchedulerPool:delayCall(MajiangroomHandle.drawOut,0.5,bm.Room.index)
		-- self:sendOtherPlayerCard(bm.Room.index)
		bm.SchedulerPool:delayCall(function()
			if tolua.isnull(scenes) == false then
				local chu = scenes:getChildByName("chu")
				if chu then
					chu:removeSelf()
				end
			end
		end,0.5)
		
	end

	if bm.Room.last == "otherhand"  then

		local chu = scenes:getChildByName("chu")
		if chu then
			chu:removeSelf()
		end

	end

end
---------------------------------------------------------------------------------------------------------------

--游戏广播相关
--广播结束游戏 没用
function MajiangroomHandle:SVR_GAME_OVER(pack)

	dump(pack, "-----广播结束游戏 没用-----");

end

--广播刮风下雨（返回）杠
function MajiangroomHandle:SVR_GUFENG_XIAYU(pack)

	dump(pack, "-----广播刮风下雨-----");

	local scenes = SCENENOW['scene'] 

	if SCENENOW['name'] ~= run_scene_name then
		return
	end

	local config = {[0] = {['x'] = 467.28,['y'] = 168.11},
					[1] = {['x'] = 268.76,['y'] = 295.40},
					[2] = {['x'] = 467.28,['y'] = 416.19},
					[3] = {['x'] = 664.62,['y'] = 295.40}
	}

	local node = display.newNode()
	local userid_index = self:getIndex(pack.userid)

	if userid_index ~= 0 then
		return
	end

	local action_deley = cc.DelayTime:create(1.5)
	local action_removeself = cc.RemoveSelf:create()
	local action_sequence = cc.Sequence:create(action_deley,action_removeself)

	if pack.gangType == 1 then
		--刮风
		local guafeng = CARD_PATH_MANAGER:get_card_path("guafeng")
		local object  = display.newSprite(guafeng)
		
		object:pos(config[userid_index].x,config[userid_index].y)
		object:addTo(scenes)
		object:runAction(action_sequence)

	elseif pack.gangType ==2 then
		--下雨
		local xiayu = CARD_PATH_MANAGER:get_card_path("xiayu")
		local object  = display.newSprite(xiayu)
		object:pos(config[userid_index].x,config[userid_index].y)
		object:addTo(scenes)
		object:runAction(action_sequence)

	else
		dump(pack.gangType, "-----广播刮风下雨数据错误-----")
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
function MajiangroomHandle:SVR_HUPAI_BROADCAST(pack)

	dump(pack,"-----胡牌协议-----")

	local scenes  = SCENENOW['scene']
	local paoid = nil 
	for i ,v in pairs(pack.content) do

		local index = self:getIndex(v.uid)
		
		local hu_type = v.htype
		if v.htype == 1 then --接炮
		  	aoid = v.pao_content[1].paoid
		end

		--显示胡牌特效
		self:show_zimo_tip(index,hu_type)

		--绘制胡的牌
		self:drawPlayerHupaiCard(v.uid,v.card,v.htype)

		--播放自摸声音
		if index == 0 then
			local sound_path = sound_path_manager:GET_GANG_PENG_SOUND(USER_INFO["sex"],1)
			-- cc.SimpleAudioEngine:getInstance():playEffect(sound_path,false)
			require("hall.VoiceUtil"):playEffect(sound_path,false)

			scenes:setGameState(5)
			-- if require("hall.gameSettings"):getGameMode() == "match" then
			-- 	require("xl_majiang.MatchSetting"):showMatchWait(true,"majiang")
			-- end
		else
			local otherinfo = bm.Room.UserInfo[v.uid]
			if otherinfo ~= nil then
				local sound_path = sound_path_manager:GET_GANG_PENG_SOUND(otherinfo.sex,1)
				-- cc.SimpleAudioEngine:getInstance():playEffect(sound_path,false)
				require("hall.VoiceUtil"):playEffect(sound_path,false)
			end
		end
	end

	--显示放炮玩家
	if paoid ~= nil then
		local config = {
			[0] = {['x'] = 480,['y'] = 200},
			[1] = {['x'] = 220,['y'] = 306},
			[2] = {['x'] = 480,['y'] = 410},
			[3] = {['x'] = 710,['y'] = 306}
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

	bm.Room.last = "otherhand"
	self:showLastEvent()

end

--显示胡牌标志
function MajiangroomHandle:show_zimo_tip(index,hu_type)

	dump(index,"-----显示胡牌标志-----")
	dump(hu_type,"-----显示胡牌标志-----")

	--设置自己胡
	if index == 0 then
		bm.isMyHu = 1
	end

	local config = {
		[0] = {['x'] = 464,['y'] = 65},
		[1] = {['x'] = 187,['y'] = 290},
		[2] = {['x'] = 464,['y'] = 482},
		[3] = {['x'] = 770,['y'] = 290}	
	}

	local scenes = SCENENOW['scene']

	if SCENENOW["name"] ~= run_scene_name then
		return
	end
	
	local object = scenes:getChildByName("hashu"..index)
	if object then
		object:removeSelf()
	end

	local pos_x,pos_y = scenes:gettimerpos()
	if hu_type == 1 then
		local path_hu = CARD_PATH_MANAGER:get_card_path("path_hu")
	 	local object  = display.newSprite(path_hu)
	 	object:setName("hashu"..index)
		object:addTo(scenes)
		object:pos(config[index]['x'],config[index]['y'])
		object:setScale(0.95)

		 -- if index == 0 then
		 -- 	show_zimo_effect(scenes,pos_x,pos_y,hu_type)
		 -- end
	end

	if hu_type == 2 then
		 local path_zimo = CARD_PATH_MANAGER:get_card_path("path_zimo")
		 local object  = display.newSprite(path_zimo)
		 object:setName("hashu"..index)
		 object:addTo(scenes)
		 object:pos(config[index]['x'],config[index]['y'])
		 object:setScale(0.7)

		 -- if index == 0 then
		 -- 	show_zimo_effect(scenes,pos_x,pos_y,hu_type)
		 -- end
	end

end

--清除所有胡标志
function MajiangroomHandle:clearAllHuSign()

	local scenes = SCENENOW['scene']

	if SCENENOW["name"] ~= run_scene_name then
		return
	end

	for i=0,3 do

		local object = scenes:getChildByName("hashu" .. i)
		if object then
			dump("hashu"..i, "-----清除所有胡标志-----")
			object:removeSelf()
		end

	end

end

--调整胡牌带未打完手牌
function MajiangroomHandle:drawPlayerHupaiCard(uid,card,hkind)

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

	--这里做区分手牌是自摸胡，还是胡别人，显示有区别
	if hkind == 2 then
		MajiangcardHandle:removeCardValue(bm.Room.Card[index]["hand"],card,1,index)
		bm.Room.Card[index]["hu"] = card
	else
		bm.Room.Card[index]["hu"] = card
	end

	self:drawHandCard(index)

	local node = scenes._scene:getChildByName("layer_card"):getChildByName(node_name)

	local pos_x  = 0
	for i,v in pairs(bm.Room.Card[index]["hand"]) do
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
function MajiangroomHandle:SVR_ENDDING_BROADCAST(pack)

	dump(pack,"-----一盘结束，进行结算-----")

	--设置游戏没有开始
	bm.isRun=false
	bm.palying = false

	if bm.Room.timerid then
		bm.SchedulerPool:clear(bm.Room.timerid)
	end

	local scenes = SCENENOW['scene']
	if SCENENOW["name"] ~= run_scene_name then
		return
	end

	--记录麻将游戏结束
	scenes:setGameState(6)

    --延迟两秒出现结果界面
	local a = display.newSprite():addTo(scenes)
	a:runAction(
		cc.Sequence:create(cc.DelayTime:create(2.5), cc.CallFunc:create(
			function ()
				self:showRoundResult(pack)
				a:removeSelf()
			end)  
		)
	)

end

--显示当轮结算界面
function MajiangroomHandle:showRoundResult(pack)

	if SCENENOW["name"] ~= run_scene_name then
		return
	end

	--隐藏放大显示的出牌
	local chu = SCENENOW["scene"]:getChildByName("chu")
	if chu then
		chu:removeSelf()
	end

	--清除所有胡标志
    self:clearAllHuSign()

	dump(pack, "-----一轮结算信息-----")
	dump(USER_INFO["user_info"], "-----当前登录用户信息-----")
	dump(bm.Room, "-----显示房间信息-----")

	--登录用户信息（自己）
	local now_user_info = json.decode(USER_INFO["user_info"])
    
	--获取单轮结算界面
    local s = cc.CSLoader:createNode("xl_majiang/common/GameRoundResult.csb")
    SCENENOW["scene"]:addChild(s,9997)

    --结果标签
    local result_ly = s:getChildByName("result_ly")
    local result_bg_iv = result_ly:getChildByName("result_bg_iv")
    local result_iv = result_ly:getChildByName("result_iv")

    --解散房间按钮
	local disband_ly = s:getChildByName("disband_ly")
	--只有房主才出现解散按钮
	local group_owner = tonumber(USER_INFO["group_owner"])
	-- if group_owner ~= USER_INFO["uid"] then
	-- 	disband_ly:setVisible(false)
	-- end
	disband_ly:addTouchEventListener(
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

            	require("xl_majiang.scenes.MajiangroomScenes"):disbandGroup()

            end
        end
    )

    --结果显示区域
    local content_ly = s:getChildByName("content_ly")

    --显示抓鸟
    local pickBird_ly = s:getChildByName("pickBird_ly")
    pickBird_ly:setVisible(false)

    --显示房间号
    local roodId_tt = s:getChildByName("roodId_tt")
    roodId_tt:setString("房间号：" .. USER_INFO["invote_code"])

    --显示房间名
    local roodName_tt = s:getChildByName("roodName_tt")
    roodName_tt:setString("血流成河")

    --显示当前轮数
    local time_tt = s:getChildByName("time_tt")
    time_tt:setString("当前局数" .. tostring(bm.round))

    --开始游戏按钮（再来一轮）
    local again_ly = s:getChildByName("again_ly")

    --假如是最后一轮，则开始游戏按钮改为游戏结束按钮
	if bm.round == bm.round_total then
		again_ly:getChildByName("Image_5"):loadTexture("xl_majiang/common/text_youxijieshu.png")
	end

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

                if bm.round == bm.round_total then

					local GameResult = SCENENOW["scene"]:getChildByName("GameResult")
					if GameResult then
						GameResult:setVisible(true)
					end

				else
					--再来一局，开始新游戏
					require("xl_majiang.majiangServer"):LoginGame(USER_INFO["GroupLevel"])

				end

			    s:removeSelf()

            end
        end
    )

    if pack == nil then
    	return
    end

    if pack.content == nil then
    	return
    end

    --获取点炮情况
    local pao_arr = {}
    for k,v in pairs(pack.content) do
    	local ifhu = v.ifhu
    	if ifhu == 1 then
    		if #v.hucontent > 0 then

    			--获取胡的内容
	    		local hucontent = v.hucontent[1]

	    		--记录点炮的用户id
				local paoid

				--胡的类型
				local hutype = hucontent.hutype
				if hutype == 1 then

					--获取接炮的胡内容
					local pinghu = hucontent.pinghu[1]

					--记录谁点炮
					paoid = pinghu.paoid

					--获取是第几个胡
		    		local huOrder = hucontent.huOrder

		    		--记录所有数据
		    		if paoid ~= nil then
		    			if pao_arr[paoid] == nil then
			    			pao_arr[paoid] = {}
			    		end
		    		end
		    		
		    		table.insert(pao_arr[paoid], huOrder)

				end

    		end
    	end
    end


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
				--记录自己赢
				isWin = 1
			elseif v.userpergold == 0 then
				--记录没有输赢
				isWin = 0
			elseif v.userpergold < 0 then
				--记录自己输
				isWin = 2
			end

    	end

    	--显示用户当局情况
    	--添加显示区域
    	local result_Item = cc.CSLoader:createNode("xl_majiang/common/GameRoundResult_Item.csb")
    	content_ly:addChild(result_Item)
    	local item_ly = result_Item:getChildByName("item_ly")
    	item_ly:setPosition(21, (content_ly:getContentSize().height - 23) - (88 * (k - 1) ) )
    	item_ly_list[k] = item_ly

    	--设置分隔线显示
    	local zuan_iv = item_ly:getChildByName("Image_8")
    	if k == #pack.content then
    		zuan_iv:setVisible(false)
    	end

    	--庄家
    	local zuan_iv = item_ly:getChildByName("zuan_iv")

    	--显示用户名称
    	local name_tt = item_ly:getChildByName("name_tt")
    	if index == 0 then

    		--当前用户信息
    		-- name_tt:setString(now_user_info.nickName)
    		name_tt:setString("我")

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
    		local user_info = bm.Room.UserInfo[v.uid]
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

    	--显示胡、胡内容、番数、分数、是否流局
    	--结果
    	local result_tt = item_ly:getChildByName("result_tt")
    	local result_str = ""

    	--番
    	local fan_tt = item_ly:getChildByName("fen_tt")
    	local fan_total = 0

    	--胡标志
    	local hu_iv = item_ly:getChildByName("hu_iv")

    	--胡的牌
		local hucard = nil

		--第几个胡的显示
		local huOrder_ly = item_ly:getChildByName("huOrder_ly")
		local huOrder_tt = huOrder_ly:getChildByName("huOrder_tt")

    	--是否胡了
    	local ifhu = v.ifhu
    	if ifhu == 1 then

    		if #v.hucontent > 0 then
    			
	    		--获取胡的内容
	    		local hucontent = v.hucontent[1]
	    		dump(hucontent,"-----" .. tostring(index) .. "胡的内容----")

	    		--获取胡的牌型
				local cardkind = hucontent.cardkind
				local cardkind_arr = LuaSplit(cardkind, ",")
				if #cardkind_arr > 0 then
					for k,v in pairs(cardkind_arr) do
						local card_kind_name = CARD_TYPE[tonumber(v)]
						dump(card_kind_name, "-----card_kind_name-----")
						if card_kind_name then
							result_str = result_str .. card_kind_name .. " "
						end
					end
				end

				--记录总番数
				fan_total = hucontent.allFan

				--记录点炮的用户id
				local paoid

				--胡的类型
				local hutype = hucontent.hutype
				if hutype == 1 then

					local pinghu = hucontent.pinghu[1]

					--是否杠上炮
					if pinghu.ifgangpao == 1 then 
						result_str = result_str .. "杠上炮 "
					end

					--是否抢杠胡
					if pinghu.ifqiangganghu == 1 then
						result_str = result_str .. "抢杠胡 "
					end

					--是否海底炮
					if pinghu.ifHaiDiPao == 1 then
						result_str = result_str .. "海底炮 "
					end

					--记录胡的牌
					hucard = pinghu.hucard

					--显示接炮
					--记录谁点炮
					paoid = pinghu.paoid
					local pao_user_info
					if paoid ~= nil then
						if paoid == USER_INFO["uid"] then
							pao_user_info = json.decode(USER_INFO["user_info"])
							if pao_user_info ~= nil then
								local nickName = pao_user_info.nickName
								if nickName ~= nil then
									result_str = result_str .. "接我的炮 "
								end
							end
						else
							pao_user_info = json.decode(bm.Room.UserInfo[paoid].user_info)
							if pao_user_info ~= nil then
								local nickName = pao_user_info.nickName
								if nickName ~= nil then
									result_str = result_str .. "接" .. nickName .. "的炮 "
								end
							end
						end
					end

				else 

					--自摸
					result_str = result_str .. "自摸 "

					local zimo = hucontent.zimo[1]

					--记录胡的牌
					hucard = zimo.hucard

					--是否杠上花
					if zimo.ifgangshanghua == 1 then
						result_str = result_str .. "杠上花 "
					end

				end

				--是否天胡
				if hucontent.ifTianHu == 1 then
					result_str = result_str .. "天胡 "
				end

				--是否地胡
				if hucontent.ifDiHu == 1 then
					result_str = result_str .. "地胡 "
				end

				--是否扫底胡
				if hucontent.ifSaoDi == 1 then
					result_str = result_str .. "扫底胡 "
				end

				--是否金钩胡
				if hucontent.ifJinGou == 1 then
					result_str = result_str .. "金钩胡 "
				end

				--根
				if hucontent.gen ~= nil then
					if tonumber(hucontent.gen) > 0 then
						result_str = result_str .. "根X" .. tostring(hucontent.gen) .. " "
					end
				end

				--显示是第几个胡
	    		local huOrder = hucontent.huOrder
	    		if huOrder ~= nil then
	    			huOrder_ly:setVisible(true)
	    			huOrder_tt:setString(tostring(huOrder))
	    		else
	    			huOrder_ly:setVisible(false)
	    		end

	    	end

	    	--显示胡标志图片
    		hu_iv:setVisible(true)

    		--记录有人胡了
    		ishu = 1

    	else

    		--隐藏胡标志图片
    		hu_iv:setVisible(false)

    		--隐藏第几个胡的显示区域
    		huOrder_ly:setVisible(false)

    	end

    	--是否点炮
		if v.ifpao==1 then

			local paoOrder = ""
			if pao_arr[v.uid] ~= nil then
				--对我点炮情况进行排序
				table.sort(pao_arr[v.uid])

				--拼接
				for k,v in pairs(pao_arr[v.uid]) do
					paoOrder = paoOrder .. tostring(v) .. ","
				end

				--去掉最后的逗号
				paoOrder = string.sub(paoOrder, 1, string.len(paoOrder) - 1)

			end

			result_str = result_str .. "点" .. paoOrder .."胡 "
		end

		--显示明杠数（刮风）
    	local mingGangNum = v.mingGangNum
    	if mingGangNum > 0 then
    		result_str = result_str .. "刮风X" .. tostring(mingGangNum) .. " "
    	end

    	--显示暗杠数（下雨）
    	local anGangNum = v.anGangNum
    	if anGangNum > 0 then
    		result_str = result_str .. "下雨X" .. tostring(anGangNum) .. " "
    	end

    	-- --显示点杠情况
    	-- local diangangMemberNum = v.diangangMemberNum
    	-- if diangangMemberNum > 0 then
    	-- 	local diangangMemberArray = v.diangangMemberArray
    	-- 	for k,v in pairs(diangangMemberArray) do
    			
    	-- 		if USER_INFO["uid"] == v then
    	-- 			result_str = result_str .. "点我杠X" .. tostring(v.gangNum) .. " "

    	-- 		else
    	-- 			if bm.Room then
	    -- 				if bm.Room.UserInfo then
	    -- 					if bm.Room.UserInfo[v.uid] then
	    -- 						local user_info = bm.Room.UserInfo[v.uid]
	    -- 						local other_user_info = json.decode(user_info.user_info)

	    -- 						result_str = result_str .. "点" .. other_user_info.nickName .. "杠X" .. tostring(v.gangNum) .. " "
	    -- 					end
	    -- 				end
	    -- 			end

    	-- 		end

    	-- 	end
    	-- end

		--是否花猪
		if v.ifhua == 1 then
			result_str = result_str .. "花猪 "
		end

		--是否大叫
		if v.ifdajiao == 1 then
			result_str = result_str .. "大叫"
		end

		--显示牌局结果
		result_tt:setString(result_str)

		-------------------------------------------------------------------------------------------------------------------------------------

		--显示用户的牌
    	--获取牌显示区域
    	local showCard_ly = item_ly:getChildByName("showCard_ly")
    	--定义牌显示位置的x坐标
    	local position_x = 0 - 37
    
    	--显示用户杠牌
    	--明杠
    	local mingGangArray = v.mingGangArray
    	dump(mingGangArray,"-----" .. tostring(index) .. "用户明杠-----")
    	local mingGangNum = v.mingGangNum
    	if mingGangNum > 0 then

	    	for k,v in pairs(mingGangArray) do

	    		--获取杠的牌值
	    		local value = tonumber(v)

	    		--循环四次显示牌
	    		for i = 1, 4 do

	    			--定义牌
		    		local card = cc.CSLoader:createNode("hall/majiangCard/csb/roundResult_card.csb")
		    		showCard_ly:addChild(card)
		    		local card_ly = card:getChildByName("card_ly")
		    		position_x = position_x + 37
		    		card_ly:setPosition(position_x, showCard_ly:getContentSize().height)

		    		--显示牌内容
		    		local card_iv = card_ly:getChildByName("card_iv")
		    		if value > 0 and value < 10 then
		    			--万
		    			card_iv:loadTexture("hall/majiangCard/wan/".. tostring(value) .. ".png")
		    		elseif value > 16 and value < 26 then
		    			--筒
		    			card_iv:loadTexture("hall/majiangCard/tong/".. tostring(value) .. ".png")
		    		elseif value > 32 and value < 42 then
		    			--条
		    			card_iv:loadTexture("hall/majiangCard/tiao/".. tostring(value) .. ".png")
		    		end

		    	end

		    	--输出完一组后，添加间距距离
		    	position_x = position_x + 5

	    	end

    	end

    	--暗杠
    	local anGangArray = v.anGangArray
    	dump(anGangArray,"-----" .. tostring(index) .. "用户暗杠-----")
    	local anGangNum = v.anGangNum
    	if anGangNum > 0 then

	    	for k,v in pairs(anGangArray) do

	    		--获取杠的牌值
	    		local value = tonumber(v)

	    		--循环四次显示牌
	    		for i = 1, 4 do

	    			--定义牌
		    		local card = cc.CSLoader:createNode("hall/majiangCard/csb/roundResult_card.csb")
		    		showCard_ly:addChild(card)
		    		local card_ly = card:getChildByName("card_ly")
		    		position_x = position_x + 37
		    		card_ly:setPosition(position_x, showCard_ly:getContentSize().height)

		    		--显示牌内容
		    		local card_iv = card_ly:getChildByName("card_iv")
		    		if value > 0 and value < 10 then
		    			--万
		    			card_iv:loadTexture("hall/majiangCard/wan/".. tostring(value) .. ".png")
		    		elseif value > 16 and value < 26 then
		    			--筒
		    			card_iv:loadTexture("hall/majiangCard/tong/".. tostring(value) .. ".png")
		    		elseif value > 32 and value < 42 then
		    			--条
		    			card_iv:loadTexture("hall/majiangCard/tiao/".. tostring(value) .. ".png")
		    		end

		    	end

		    	--输出完一组后，添加间距距离
		    	position_x = position_x + 5

	    	end

    	end

    	--显示用户碰牌
    	local pengArray = v.pengArray
    	dump(pengArray,"-----" .. tostring(index) .. "用户碰牌-----")
    	local pengNum = v.pengNum
    	if pengNum > 0 then

	    	for k,v in pairs(pengArray) do

	    		--获取杠的牌值
	    		local value = tonumber(v)

	    		--循环三次显示牌
	    		for i = 1, 3 do

	    			--定义牌
		    		local card = cc.CSLoader:createNode("hall/majiangCard/csb/roundResult_card.csb")
		    		showCard_ly:addChild(card)
		    		local card_ly = card:getChildByName("card_ly")
		    		position_x = position_x + 37
		    		card_ly:setPosition(position_x, showCard_ly:getContentSize().height)

		    		--显示牌内容
		    		local card_iv = card_ly:getChildByName("card_iv")
		    		if value > 0 and value < 10 then
		    			--万
		    			card_iv:loadTexture("hall/majiangCard/wan/".. tostring(value) .. ".png")
		    		elseif value > 16 and value < 26 then
		    			--筒
		    			card_iv:loadTexture("hall/majiangCard/tong/".. tostring(value) .. ".png")
		    		elseif value > 32 and value < 42 then
		    			--条
		    			card_iv:loadTexture("hall/majiangCard/tiao/".. tostring(value) .. ".png")
		    		end

		    	end

		    	--输出完一组后，添加间距距离
		    	position_x = position_x + 5

	    	end

    	end
    	
    	--显示用户手牌
    	local backuserleftcard = v.userleftcard
    	dump(backuserleftcard,"-----" .. tostring(index) .. "用户手牌-----")

    	--记录去掉胡的那张牌的数组
    	local userleftcard = {}
    	--记录是否已经去掉胡的牌
    	local isQu = 0;
    	--去掉胡的那张牌
    	if hucard ~= nil then
    		for k,v in pairs(backuserleftcard) do
    			if v == hucard then
    				if isQu == 0 then
    					isQu = 1
    				else
    					table.insert(userleftcard, v)
    				end
    			else
    				table.insert(userleftcard, v)
    			end
    		end
    		dump(backuserleftcard,"-----" .. tostring(index) .. "用户去掉胡牌后的手牌-----")

    	else
    		userleftcard = backuserleftcard

    	end

    	if #userleftcard > 0 then
	    	for k,v in pairs(userleftcard) do

	    		--定义牌
	    		local card = cc.CSLoader:createNode("hall/majiangCard/csb/roundResult_card.csb")
	    		showCard_ly:addChild(card)
	    		local card_ly = card:getChildByName("card_ly")
	    		position_x = position_x + 37
	    		card_ly:setPosition(position_x, showCard_ly:getContentSize().height)

	    		--显示牌内容
	    		local card_iv = card_ly:getChildByName("card_iv")
	    		local value = tonumber(v)
	    		if value > 0 and value < 10 then
	    			--万
	    			card_iv:loadTexture("hall/majiangCard/wan/".. tostring(value) .. ".png")
	    		elseif value > 16 and value < 26 then
	    			--筒
	    			card_iv:loadTexture("hall/majiangCard/tong/".. tostring(value) .. ".png")
	    		elseif value > 32 and value < 42 then
	    			--条
	    			card_iv:loadTexture("hall/majiangCard/tiao/".. tostring(value) .. ".png")
	    		end

	    	end

    	end

    	--显示胡的牌
    	--判断当前用户是否胡了
    	if hucard ~= nil then

    		local card = cc.CSLoader:createNode("hall/majiangCard/csb/roundResult_card.csb")
			showCard_ly:addChild(card)

			local card_ly = card:getChildByName("card_ly")
			position_x = position_x + 34 * 2
			card_ly:setPosition(position_x, showCard_ly:getContentSize().height)

			--显示牌内容
			local card_iv = card_ly:getChildByName("card_iv")
			if hucard > 0 and hucard < 10 then
				--万
				card_iv:loadTexture("hall/majiangCard/wan/".. tostring(hucard) .. ".png")
			elseif hucard > 16 and hucard < 26 then
				--筒
				card_iv:loadTexture("hall/majiangCard/tong/".. tostring(hucard) .. ".png")
			elseif hucard > 32 and hucard < 42 then
				--条
				card_iv:loadTexture("hall/majiangCard/tiao/".. tostring(hucard) .. ".png")
			end

    	end

    	-----------------------------------------------------------------------------------------------------------------------------------

		--显示番数
		if fan_total > 0 then
    		fan_tt:setString(tostring(fan_total) .. "番")
    	else
    		fan_tt:setString("0番")
		end

		--显示分数
    	local fen_tt = item_ly:getChildByName("fan_tt")
    	if v.userpergold > 0 then
    		-- fan_tt:setTextColor(cc.c3b(0, 255, 0))
    		-- fen_tt:setTextColor(cc.c3b(0, 255, 0))
    		fen_tt:setString("+" .. tostring(v.userpergold))
    	else
    		if v.userpergold < 0 then
    			-- fen_tt:setTextColor(cc.c3b(255, 0, 0))
    			-- fan_tt:setTextColor(cc.c3b(255, 0, 0))
    		end
    		fen_tt:setString(tostring(v.userpergold))
    	end
    	
    end

    --设置流局显示
    if isWin == 1 then
    	--结果标签改成赢的样式
		result_bg_iv:loadTexture("hall/group/create/red_button_p.png")
		result_iv:loadTexture("xl_majiang/common/mahjong_win.png")
	elseif isWin == 2 then
		--结果标签显示输的样式
	elseif isWin == 0 then
		--没有赢输，则结果标签改成流局的样式
		result_bg_iv:loadTexture("hall/group/create/grey_button.png")
		result_iv:loadTexture("xl_majiang/common/text_liuju.png")
		-- --判断当前是否有人胡
	 --    if ishu == 0 then
	 --    	--没有人胡，则结果标签改成流局的样式
		-- 	result_bg_iv:loadTexture("hall/group/create/grey_button.png")
		-- 	result_iv:loadTexture("xl_majiang/common/text_liuju.png")
	 --    end
    end

end

--显示一局结算的结算界面
function MajiangroomHandle:showGroupResult(pack)

	dump(pack, "-----一局结算信息-----")
	dump(bm.Room, "显示房间信息")

	if SCENENOW["name"] ~= run_scene_name then
		return
	end

	--去掉放大显示出的牌
	local chu = SCENENOW["scene"]:getChildByName("chu")
	if chu then
		chu:removeSelf()
	end

	--清除所有胡标志
    self:clearAllHuSign()

	--去掉提示弹框
	local layer_tips = SCENENOW["scene"]:getChildByName("layer_tips")
    if layer_tips then
        layer_tips:removeSelf()
    end

	--获取总结算界面
    local s = cc.CSLoader:createNode("xl_majiang/common/GameResult.csb")
    s:setName("GameResult")
    SCENENOW["scene"]:addChild(s,9998)

    local jzdb_sp = cc.Sprite:create("xl_majiang/image/text_jinzhidubo.png")
    jzdb_sp:setAnchorPoint(0.5, 0.5)
    jzdb_sp:setPosition(480, 520)
    s:addChild(jzdb_sp)

    --假如当前是最后一轮，结果界面先隐藏
    if bm.round == bm.round_total then
    	if bm.isDisbandSuccess then
    		s:setVisible(true)
    	else
    		s:setVisible(false)
    	end
    end

    --退出按钮（当前组局结算，返回到大厅）
    local back_bt = s:getChildByName("back_bt")
    back_bt:addTouchEventListener(
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

                --退出房间，返回大厅
                require("xl_majiang.ddzSettings"):setEndGroup(2)
                require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])

                --移除录音按钮
                require("hall.VoiceRecord.VoiceRecordView"):removeView()

            end
        end
    )

    --结果显示区域
    local content_ly = s:getChildByName("content_ly")
    local content_sv = content_ly:getChildByName("content_sv")

    --显示用户结算结果
    local playerlist = pack.playerlist
    if #playerlist > 0 then

    	--记录最佳炮手和大富豪
    	local paoshou_uid = nil
    	local lastPaoNum = 0

    	local fuhao_uid = nil
    	local lastChip = 0

    	for k,v in pairs(playerlist) do
    		
    		--获取用户id
    		local uid = v.uid

    		--获取用户信息以及结算情况
	    	local user_info = json.decode(v.user_info)

	    	--获取用户点炮数
	    	local dianpao = user_info.dianpao
	    	if dianpao ~= nil then
	    		--比较点炮数
	    		if dianpao > lastPaoNum then
	    			--记录最新点炮数和点炮id
	    			lastPaoNum = dianpao
	    			paoshou_uid = uid
	    		end
	    	end

	    	--获取用户分数
	    	local chips = user_info.chips
	    	if chips ~= nil then
	    		--比较分数
	    		local cha = chips - USER_INFO["group_chip"]
	    		if cha > lastChip then
	    			--记录最新点炮数和点炮id
	    			lastChip = cha
	    			fuhao_uid = uid
	    		end
	    	end

    	end

    	local zOrder = 10

    	--生成界面
    	for k,v in pairs(playerlist) do

    		--获取用户id
    		local uid = v.uid

    		--获取用户信息以及结算情况
	    	local user_info = json.decode(v.user_info)

	    	--定义结果分项
	    	local result_Item = cc.CSLoader:createNode("xl_majiang/common/GameResult_Item.csb")
	    	result_Item:setLocalZOrder(zOrder)
	    	zOrder = zOrder - 1
	    	content_sv:addChild(result_Item)

	    	local item_ly = result_Item:getChildByName("item_ly")
	    	item_ly:setPosition(219 * (k - 1), content_sv:getContentSize().height)

	    	--显示最佳炮手
	    	local paoshou_im = item_ly:getChildByName("paoshou_im")
    		if paoshou_uid ~= nil then
    			if paoshou_uid == uid then
    				paoshou_im:setVisible(true)
    			end
    		end

    		--显示大富豪
    		local winner_im = item_ly:getChildByName("winner_im")
    		if fuhao_uid ~= nil then
    			if fuhao_uid == uid then
    				winner_im:setVisible(true)
    			end
    		end

	    	local top_ly = item_ly:getChildByName("top_ly")

	    	--用户头像
	    	local head_im = top_ly:getChildByName("head_im")
	    	require("hall.GameCommon"):getUserHead(user_info.photo_url, v.uid, user_info.sex, head_im, 61, false)

	    	--是否为房主
	    	local roomowner_im = top_ly:getChildByName("roomowner_im")
	    	--只有房主才出现房主标志
    		local group_owner = tonumber(USER_INFO["group_owner"])
			if group_owner == v.uid then
				roomowner_im:setVisible(true)
			else
				roomowner_im:setVisible(false)
			end

	    	--用户昵称
	    	local name_tt = top_ly:getChildByName("name_tt")
	    	name_tt:setString(user_info.nick_name)

	    	--用户id
	    	local id_tt = top_ly:getChildByName("id_tt")
	    	id_tt:setString("ID:" .. tostring(v.uid))

	    	--中间区域
	    	local content_sv = item_ly:getChildByName("content_sv")

	    	--自摸
	    	local zimo_ly = content_sv:getChildByName("zimo_ly")
	    	local zimo_itemNum_tt = zimo_ly:getChildByName("itemNum_tt")
	    	if user_info.zimo ~= nil then
	    		zimo_itemNum_tt:setString(tostring(user_info.zimo))
	    	end

	    	--点炮
	    	local dianpao_ly = content_sv:getChildByName("dianpao_ly")
	    	local dianpao_itemNum_tt = dianpao_ly:getChildByName("itemNum_tt")
	    	if user_info.dianpao ~= nil then
	    		dianpao_itemNum_tt:setString(tostring(user_info.dianpao))
	    	end

	    	--接炮
	    	local jiepao_ly = content_sv:getChildByName("jiepao_ly")
	    	local jiepao_itemNum_tt = jiepao_ly:getChildByName("itemNum_tt")
	    	if user_info.jiepao ~= nil then
	    		jiepao_itemNum_tt:setString(tostring(user_info.jiepao))
	    	end

	    	--暗杠
	    	local angang_ly = content_sv:getChildByName("angang_ly")
	    	local angang_itemNum_tt = angang_ly:getChildByName("itemNum_tt")
	    	if user_info.angang ~= nil then
	    		angang_itemNum_tt:setString(tostring(user_info.angang))
	    	end

	    	--明杠
	    	local minggang_ly = content_sv:getChildByName("minggang_ly")
	    	local minggang_itemNum_tt = minggang_ly:getChildByName("itemNum_tt")
	    	if user_info.minggang ~= nil then
	    		minggang_itemNum_tt:setString(tostring(user_info.minggang))
	    	end

	    	--大叫
	    	local dajiao_ly = content_sv:getChildByName("dajiao_ly")
	    	local dajiao_itemNum_tt = dajiao_ly:getChildByName("itemNum_tt")
	    	if user_info.chadajiao ~= nil then
	    		dajiao_itemNum_tt:setString(tostring(user_info.chadajiao))
	    	end

	    	--底部区域
	    	local bottom_ly = item_ly:getChildByName("bottom_ly")

	    	--总成绩
	    	--用户当前的积分
	    	local chips = user_info.chips
	    	if bm.round == 1 then
	    		chips = 0 
	    	else
	    		chips = chips - USER_INFO["group_chip"]
	    	end
	    	local socre_tt = bottom_ly:getChildByName("socre_tt")
	    	socre_tt:setString(tostring(chips))

    	end

    end

    local share_ly = s:getChildByName("share_ly")
    share_ly:addTouchEventListener(
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
                share_ly:setTouchEnabled(false)
                --通知APP分享结果
                -- require("hall.common.ShareLayer"):showShareLayer("分享结果","","screen","")
                if device.platform == "android" then
                	require("hall.common.ShareLayer"):showShareLayer("分享结果","","screen","",share_ly)
                elseif device.platform ~= "windows" then
                	require("hall.common.ShareLayer"):shareGroupResultForIOS(share_ly)
                end

            end
        end
    )

end
-------------------------------------------------------------------------------------------------------------------

--组局相关
--请求获取筹码返回
function MajiangroomHandle:SVR_GET_CHIP(pack)
	-- if bm.isGroup then
    if require("hall.gameSettings"):getGameMode() == "group" then
		--todo
		require("xl_majiang.gameScene"):onNetGetChip(pack)
	end
	
end

--请求兑换筹码返回
function MajiangroomHandle:SVR_CHANGE_CHIP(pack)
	
	dump(pack, "-----请求兑换筹码返回------")
	-- if bm.isGroup  then
    if require("hall.gameSettings"):getGameMode() == "group" then
			
		require("xl_majiang.gameScene"):onChipSuccess(pack)
	end

end

--组局时长
function MajiangroomHandle:SVR_GROUP_TIME(pack)


	dump(pack, "-----组局时长-----")

	--记录当前局数
	bm.round = pack.round + 1
	dump(bm.round, "-----当前局数-----")

	--记录总局数
	bm.round_total = pack.round_total
	dump(bm.round_total, "-----总局数-----")
	

	-- --  加入当前游戏模式是组局 if bm.isGroup then
 --    if require("hall.gameSettings"):getGameMode() == "group" then

 --    	--记录服务器返回的组局时间
	-- 	bm.GroupTimer = pack.time or 0
	-- 	if bm.GroupTimer <=0 then
	-- 		--todo
	-- 		bm.GroupTimer=0
	-- 	end
	-- 	--bm.GroupTimer = 3000

	-- 	--记录当前是第几局
	-- 	bm.round = pack.round

	-- 	--记录总局数
	-- 	bm.round_total = pack.round_total

	-- end

	-- local m = true
	-- while m do
	-- 	if bm.isGroup and SCENENOW["name"]  == "xl_majiang.scenes.MajiangroomScenes" and SCENENOW["scene"]._scene then
	-- 		m = false
	-- 		require("xl_majiang.gameScene"):showTimer(pack)
	-- 	end
	-- end
	
	
end

--组局排行榜（一局结算之后返回的数据）
function MajiangroomHandle:SVR_GROUP_BILLBOARD(pack)

    if pack then
     --    -- if bm.isGroup then
    	-- if require("hall.gameSettings"):getGameMode() == "group" then

    	-- 	self:showGroupResult(pack)
    		
     --    end

     self:showGroupResult(pack)

    end

end

--组局历史记录
function MajiangroomHandle:SVR_GET_HISTORY(pack)

	dump(pack, "-----组局历史记录-----")

    if pack then

        -- if bm.isGroup then
    	-- if require("hall.gameSettings"):getGameMode() == "group" then
     --        require("xl_majiang.gameScene"):onNetHistory(pack)
     --    end

     	require("xl_majiang.gameScene"):onNetHistory(pack)

    end

end
-----------------------------------------------------------------------------------------------------------------------------

--组局解散相关
--没有此房间，解散房间失败
function MajiangroomHandle:G2H_CMD_DISSOLVE_FAILED(pack)

	dump("-----没有此房间，解散房间失败-----", "-----没有此房间，解散房间失败-----")

	require("hall.GameTips"):showTips("提示", "disbandGroup_fail", 2, "解散房间失败")

end

--广播当前组局解散情况
function MajiangroomHandle:G2H_CMD_REFRESH_DISSOLVE_LIST(pack)

	dump(pack, "-----广播当前组局解散情况-----")
	dump(bm.Room, "-----广播当前房间情况-----")

	local applyId = pack.applyId
	local agreeNum = pack.agreeNum
	local agreeMember_arr = pack.agreeMember_arr

	local showMsg = ""

	--申请解散者信息
	local applyer_info = {}
	if tonumber(pplyId) == tonumber(USER_INFO["uid"]) then
		showMsg = "\n" .. "您申请解散房间，请等待其他玩家同意（超过5分钟未做选择，则默认同意）" .. "\n"
	else
		if bm.Room ~= nil then
			if bm.Room.UserInfo ~= nil then
				applyer_info = json.decode(bm.Room.UserInfo[applyId].user_info)
				local nickName = applyer_info.nickName
				if nickName ~= nil then
					showMsg = "\n" .. "玩家【" .. nickName .. "】申请解散房间，请等待其他玩家同意（超过5分钟未做选择，则默认同意）" .. "\n"
				end
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
	if bm.Room ~= nil then
		if bm.Room.UserInfo ~= nil then
			for k,v in pairs(bm.Room.UserInfo) do
				local uid = v.uid
				--排除掉申请者，申请者不需要显示到这里
				if uid ~= applyId then

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

					--显示当前用户情况
					local user_info = json.decode(v.user_info)
					if user_info ~= nil then
						local nickName = user_info.nickName
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
	end

	if tonumber(applyId) == tonumber(USER_INFO["uid"]) then
		--假如申请者是自己，则直接显示其他用户的选择情况
		require("hall.GameTips"):showTips("提示", "agree_disbandGroup", 4, showMsg)
	else
		--申请者不是自己，根据自己的同意情况进行界面显示
		if isMyAgree == 1 then
			require("hall.GameTips"):showTips("提示", "agree_disbandGroup", 4, showMsg)
		else
			require("hall.GameTips"):showTips("提示", "request_disbandGroup", 1, showMsg)
		end
	end
	

end

--广播桌子用户请求解散组局
function MajiangroomHandle:SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP(pack)

	dump(pack, "-----广播桌子用户请求解散组局-----")

	-- require("hall.GameTips"):showTips("提示", "request_disbandGroup", 1, "确认解散房间")

end

--广播桌子用户成功解散组局
function MajiangroomHandle:SERVER_BROADCAST_DISSOLVE_GROUP(pack)

	dump(pack, "-----广播桌子用户成功解散组局-----")

	bm.isDisbandSuccess = true

	-- require("hall.GameTips"):showTips("解散房间成功","disbandGroup_success",3)

end

--广播桌子用户解散组局 ，解散组局失败
function MajiangroomHandle:SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP(pack)

	dump(pack, "-----广播桌子用户解散组局 ，解散组局失败-----")

	local rejectId = pack.rejectId
	if tonumber(rejectId) == tonumber(USER_INFO["uid"]) then
		require("hall.GameTips"):showTips("解散房间失败", "disbandGroup_fail", 2, "您拒绝解散房间")
	else
		if bm.Room ~= nil then
			if bm.Room.UserInfo ~= nil then
				if bm.Room.UserInfo[rejectId] ~= nil then
					local rejecter_info = json.decode(bm.Room.UserInfo[rejectId].user_info)
					require("hall.GameTips"):showTips("解散房间失败", "disbandGroup_fail", 2, rejecter_info.nickName .. "拒绝解散房间")
				end
			end
		end
	end

end
---------------------------------------------------------------------------------------------------------------

--聊天相关
function MajiangroomHandle:SVR_MSG_FACE(pack)

	dump(pack, "-----文字聊天信息返回 1004-----")

	if SCENENOW["name"] ~= run_scene_name then
		return
	end

	--去掉提示弹框
	local layer_tips = SCENENOW["scene"]:getChildByName("layer_tips")
    if layer_tips then
        layer_tips:removeSelf()
    end

    local faceUI = SCENENOW["scene"]:getChildByName("faceUI")
    local index  = self:getIndex(pack.uid)
    local sexT = 2
    local isLeft = false
    local node_head = nil

    --性别,头像位置
    if index == 0 then
        sexT = USER_INFO["sex"]
        node_head = SCENENOW["scene"]._scene:getChildByName("Panel_me"):getChildByName("Image_3")

    else

        local othInfo = json.decode(bm.Room.UserInfo[pack.uid]["user_info"])
        dump(othInfo, "-----othInfo-----")
		if othInfo ~= nil then
			sexT = othInfo.sex
		end

		if index == 1 then
			node_head = SCENENOW["scene"]._scene:getChildByName("Panel_left"):getChildByName("Image_3")
		elseif index == 2 then
			node_head = SCENENOW["scene"]._scene:getChildByName("Panel_top"):getChildByName("Image_3")
		elseif index == 3 then
			node_head = SCENENOW["scene"]._scene:getChildByName("Panel_right"):getChildByName("Image_3")
		end

    end

    if index == 3 then
       isLeft = true
    end

    dump(faceUI, "-----faceUI-----")
    dump(node_head, "-----node_head-----")
    dump(sexT, "-----sexT-----")

    if faceUI ~= nil and node_head ~= nil then
    	faceUI:showGetFace(pack.uid, pack.type, tonumber(sexT), node_head, isLeft)
    end

end

--收到聊天消息（弃用）
function MajiangroomHandle:CHAT_MSG( pack )
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
function MajiangroomHandle:s2c_JOIN_MATCH_RETURN(pack)
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

function MajiangroomHandle:s2c_JOIN_MATCH_FAIL(pack)
	print("0x7109==========return==========")
	dump(pack)
	USER_INFO["match_fee"] = 0
    require("xl_majiang.MatchSetting"):setJoinMatch(false)
end

function MajiangroomHandle:s2c_JOIN_MATCH_SUCCESS(pack)
	print("0x7101==========return==========")
	dump(pack)

	--重设玩家的金币数，这个是扣除了报名费
	USER_INFO["gold"] = pack.Score
	local scenes         = SCENENOW['scene'] 

	if SCENENOW['name'] =="xl_majiang.MJselectChip"  then
		scenes:goldUpdate()
	end
	 require("xl_majiang.MatchSetting"):setJoinMatch(true)


    if USER_INFO["match_fee"] then
        if USER_INFO["match_fee"] > 0 then
            bMatchJoin = true
            require("xl_majiang.MatchSetting"):showMatchSignup(true,pack["MatchUserCount"],pack["totalCount"],pack["Costformatch"],"majiang",USER_INFO["curr_match_level"])
        end
    end

    USER_INFO["match_fee"] = pack["Costformatch"]

    --进入比赛模式
    --进入比赛模式
    require("hall.GameData"):enterMatch(4)
end

function MajiangroomHandle:s2c_OTHER_PEOPLE_JOINT_IN(pack)
	print("0x7103==========return==========")
	dump(pack)
	require("xl_majiang.MatchSetting"):setJoinMatch(true)
	require("xl_majiang.MatchSetting"):joinMatch(pack.Usercount,pack.Totalcount)
end

function MajiangroomHandle:s2c_QUIT_MATCH_RETURN(pack)
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
			if SCENENOW['name'] =="xl_majiang.MJselectChip"  then
				scenes:goldUpdate()
			end
            
            require("xl_majiang.MatchSetting"):setJoinMatch(false)
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
            require("xl_majiang.MatchSetting"):setJoinMatch(true)
        end

    end
end

function MajiangroomHandle:s2c_GAME_BEGIN_LOGIC(pack)
	print("0x7104==========return==========")
	dump(pack)
	
	bm.User={}
	bm.User.Seat      = pack.seat_id
	bm.User.Golf      = pack.gold or pack.Matchpoint
	bm.User.Pque      = nil

	bm.Room={}
	bm.Room.User      = {}	
    bm.Room.UserInfo  = {}
    bm.Room.seat_uid  = {}
	bm.Room.Card      = {}
	bm.Room.Gang      = {}
	bm.Room.base      = pack.base 

	bm.Room.tuoguan_ing = 0

	--bm.display_scenes("xl_majiang.scenes.MajiangroomScenes")

	SCENENOW["scene"]:removeSelf()
	SCENENOW["scene"]=nil;

	local sc=require("xl_majiang.scenes.MajiangroomScenes").new()
	SCENENOW["scene"] = sc
    --SCENENOW["scene"]:retain();
    SCENENOW["name"]  = "xl_majiang.scenes.MajiangroomScenes";
	display.replaceScene(sc)
	local scenes   = sc

	--绘制自己的信息
	scenes:set_ower_info(USER_INFO["icon_url"],USER_INFO["nick"],pack["Matchpoint"],USER_INFO["sex"])

	--绘制其他玩家
	if pack.Usercount > 0  then
		for i,v in pairs(pack.other_players) do
			MajiangroomHandle:showPlayer(v)
		end
	end

	--绘制其他内容
	scenes:set_basescole_txt(bm.Room.base) 

	-- if bm.isGroup  then --
    if require("hall.gameSettings"):getGameMode() == "group" then
		USER_INFO["base_chip"]=bm.Room.base;
		require("xl_majiang.gameScene"):showTimer(bm.GroupTimer)

		require("xl_majiang.gameScene"):checkChip(scenes)

	else
		SCENENOW["scene"]:gameReady();
		
	end
	majiangGameMode = 2
	require("hall.gameSettings"):setGameMode("match")
	require("xl_majiang.MatchSetting"):setCurrentRound(pack["Round"],pack["Sheaves"])
	audio.playMusic("xl_majiang/music/BG_283.mp3",true)

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

function MajiangroomHandle:s2c_PAI_MING_MSG(pack)
	print("0x7114==========return==========")
	dump(pack)
end

function MajiangroomHandle:s2c_SVR_MATCH_WAIT(pack)
	print("0x7113==========return==========")
	dump(pack)
	SCENENOW["scene"]:removeSelf()
	SCENENOW["scene"]=nil;

	local sc=require("xl_majiang.scenes.MajiangroomScenes").new()
	SCENENOW["scene"] = sc
    --SCENENOW["scene"]:retain();
    SCENENOW["name"]  = "xl_majiang.scenes.MajiangroomScenes";
	display.replaceScene(sc)
	local scenes   = sc
	if tolua.isnull(scenes) == false then
	    USER_INFO["match_gold"] = pack["Matchpoint"]
		scenes:set_ower_info(USER_INFO["icon_url"],USER_INFO["nick"],pack["Matchpoint"],USER_INFO["sex"])
	    require("xl_majiang.HallHttpNet"):MatchloadBattles(4)
	    require("xl_majiang.MatchSetting"):setMatchState(1)
	end

	if pack["table_count"]>0 then
        require("xl_majiang.MatchSetting"):showMatchWait(true,"majiang")
        return
    end
end

function MajiangroomHandle:s2c_GAME_STATE_MSG(pack)
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
        require("xl_majiang.MatchSetting"):showMatchWait(true,"majiang")
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
            require("xl_majiang.MatchSetting"):showMatchWin(pack["Rank"],USER_INFO["match_rank"],require("xl_majiang.MatchSetting"):getCurrentRank(),"majiang")
        end
    elseif status==1 then --淘汰后显示结果
        require("xl_majiang.MatchSetting"):setMatchResult(pack["Rank"],pack["Maxnumber"],pack["Strtime"],"majiang",require("xl_majiang.MatchSetting"):getIncentive(pack["Level"],pack["Rank"]))
        require("xl_majiang.MatchSetting"):showMatchLose(pack["Rank"],pack["Maxnumber"],require("xl_majiang.MatchSetting"):getCurrentRank(),"majiang")
        bMatchStatus = 2
        local sp = display.newSprite():addTo(scenes)
        sp:performWithDelay(function()
            require("xl_majiang.MatchSetting"):showMatchResult()
        end,5)
        audio.stopMusic(true)
    elseif status==2 then --赢了显示结果
    	audio.stopMusic(true)

        bMatchStatus = 2
        
        require("xl_majiang.MatchSetting"):setMatchResult(pack["Rank"],pack["Maxnumber"],pack["Strtime"],"majiang",require("xl_majiang.MatchSetting"):getIncentive(pack["Level"],pack["Rank"]))
		require("xl_majiang.MatchSetting"):showMatchResult()	
	end
       
end

function MajiangroomHandle:s2c_SVR_REGET_MATCH_ROOM(pack)
	
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
    require("xl_majiang.HallHttpNet"):requestIncentive(pack.m_nLevel)

 --    if pack.pHuSeatId == 1 then
	-- 	require("majiang.MatchSetting"):showMatchWait(true,"majiang")
	-- end

end
---------------------------------------------------------------------------------------------------------------

--按照传入的分隔符，切割字符串
function LuaSplit(str, split_char)  
    if str == "" or str == nil then   
        return {};  
    end  
    local split_len = string.len(split_char)  
    local sub_str_tab = {};  
    local i = 0;  
    local j = 0;  
    while true do  
        j = string.find(str, split_char,i+split_len);--从目标串str第i+split_len个字符开始搜索指定串  
        if string.len(str) == i then   
            break;  
        end  
  
  
        if j == nil then  
            table.insert(sub_str_tab,string.sub(str,i));  
            break;  
        end;  
  
  
        table.insert(sub_str_tab,string.sub(str,i,j-1));  
        i = j+split_len;  
    end  
    return sub_str_tab;  
end  

return MajiangroomHandle