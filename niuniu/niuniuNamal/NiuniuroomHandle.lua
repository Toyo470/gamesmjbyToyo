
import("..cardkind")

require("niuniu.setting_help")

local hallHandle = require("hall.HallHandle")

local hallPa = require("hall.HALL_PROTOCOL")

local PROTOCOL = import("..Niuniu_Protocol")

-- setmetatable(PROTOCOL, {
-- 	__index=hallPa
-- })

local NiuniuroomServer  = import(".NiuniuroomServer")
local NiuniuroomHandle  = class("NiuniuroomHandle", hallHandle)

local NiuniuroomScenes_name = "NiuniuroomScenes" 

function NiuniuroomHandle:ctor()

	NiuniuroomHandle.super.ctor(self);

	local func_ = {

		[PROTOCOL.SVR_GAME_START] 			= {handler(self, NiuniuroomHandle.SVR_GAME_START)},
		[PROTOCOL.SVR_LOGIN_ROOM] 			= {handler(self, NiuniuroomHandle.SVR_LOGIN_ROOM)},
        [PROTOCOL.SVR_LOGIN_ROOM_BROADCAST] = {handler(self, NiuniuroomHandle.SVR_LOGIN_ROOM_BROADCAST)},
        [PROTOCOL.SVR_READY_TIME]           = {handler(self, NiuniuroomHandle.SVR_READY_TIME)}, 
        [PROTOCOL.SVR_QUIT_ROOM]            = {handler(self, NiuniuroomHandle.SVR_QUIT_ROOM)}, 
        [PROTOCOL.SVR_QUICK_SUC]            = {handler(self, NiuniuroomHandle.SVR_QUICK_SUC)}, 
        [PROTOCOL.SVR_READY_BROADCAST]      = {handler(self, NiuniuroomHandle.SVR_READY_BROADCAST)}, 
        [PROTOCOL.SVR_SEND_USER_CARD]       = {handler(self, NiuniuroomHandle.SVR_SEND_USER_CARD)}, 
        [PROTOCOL.SVR_BEGIN_QIANFGZHUANG_BROADCAST]       = {handler(self, NiuniuroomHandle.SVR_BEGIN_QIANFGZHUANG_BROADCAST)}, 
        [PROTOCOL.SVR_USER_QIANFGZHUANG_RESULT_BROADCAST]       = {handler(self, NiuniuroomHandle.SVR_USER_QIANFGZHUANG_RESULT_BROADCAST)}, 
    	[PROTOCOL.SVR_SEND_BASES_TO_USER_BROADCAST]      = {handler(self, NiuniuroomHandle.SVR_SEND_BASES_TO_USER_BROADCAST)}, 
    	[PROTOCOL.SVR_USER_BASES_RESULT_BROADCAST]            = {handler(self, NiuniuroomHandle.SVR_USER_BASES_RESULT_BROADCAST)}, 
    	[PROTOCOL.SVR_BRANK_BROADCAST]            = {handler(self, NiuniuroomHandle.SVR_BRANK_BROADCAST)},  	
    	[PROTOCOL.SVR_PLAY_CARD_BROADCAST]            = {handler(self, NiuniuroomHandle.SVR_PLAY_CARD_BROADCAST)}, 
    	[PROTOCOL.SVR_USER_PLAYED_CARDS_BROADCAST]            = {handler(self, NiuniuroomHandle.SVR_USER_PLAYED_CARDS_BROADCAST)}, 	
    	[PROTOCOL.SVR_SETTLEMENT_BROADCAST]       = {handler(self, NiuniuroomHandle.SVR_SETTLEMENT_BROADCAST)}, 
    	[PROTOCOL.SVR_GROUP_TIME] = {handler(self, NiuniuroomHandle.SVR_GROUP_TIME)},
    	[PROTOCOL.SVR_GET_HISTORY] = {handler(self,NiuniuroomHandle.SVR_GET_HISTORY)},
    	[PROTOCOL.SVR_GROUP_BILLBOARD] = {handler(self, NiuniuroomHandle.SVR_GROUP_BILLBOARD)},
    	[PROTOCOL.SVR_GET_CHIP] = {handler(self, NiuniuroomHandle.SVR_GET_CHIP)},
    	[PROTOCOL.SVR_CHANGE_CHIP] = {handler(self, NiuniuroomHandle.SVR_CHANGE_CHIP)},
    	[PROTOCOL.SVR_BRANKRUPT] = {handler(self, NiuniuroomHandle.SVR_BRANKRUPT)},--破产
    	[PROTOCOL.SERVER_COMMAND_KICK_OUT_ROOM] = {handler(self, NiuniuroomHandle.SERVER_COMMAND_KICK_OUT_ROOM)},

    	--文字聊天相关
     	[PROTOCOL.SVR_MSG_FACE]     = {handler(self, NiuniuroomHandle.SVR_MSG_FACE)},

    	--解散相关
    	--没有此房间，解散房间失败
     	[PROTOCOL.G2H_CMD_DISSOLVE_FAILED]     = {handler(self, NiuniuroomHandle.G2H_CMD_DISSOLVE_FAILED)},
     	--广播桌子用户请求解散组局
     	[PROTOCOL.SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP]     = {handler(self, NiuniuroomHandle.SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP)},
     	--广播当前组局解散情况
     	[PROTOCOL.G2H_CMD_REFRESH_DISSOLVE_LIST]     = {handler(self, NiuniuroomHandle.G2H_CMD_REFRESH_DISSOLVE_LIST)},
     	--广播桌子用户成功解散组局
     	[PROTOCOL.SERVER_BROADCAST_DISSOLVE_GROUP]     = {handler(self, NiuniuroomHandle.SERVER_BROADCAST_DISSOLVE_GROUP)},
     	--广播桌子用户解散组局 ，解散组局失败
     	[PROTOCOL.SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP]     = {handler(self, NiuniuroomHandle.SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP)},

     	--接收服务器返回的缓存信息
        [PROTOCOL.SERVER_CMD_FORWARD_MESSAGE] = {handler(self, NiuniuroomHandle.SERVER_CMD_FORWARD_MESSAGE)},

        [PROTOCOL.SERVER_CMD_MESSAGE] = {handler(self, NiuniuroomHandle.SERVER_CMD_MESSAGE)},
        
        [PROTOCOL.BROADCAST_USER_IP] = {handler(self, NiuniuroomHandle.BROADCAST_USER_IP)},

    }

    table.merge(self.func_, func_)
    
end

--协议返回数据接收
function NiuniuroomHandle:callFunc(pack)
	
	if self.func_[pack.cmd] and self.func_[pack.cmd][1] then
	 	print(pack.cmd,"test1")
        self.func_[pack.cmd][1](pack)
    end

end

-- 游戏开始
function NiuniuroomHandle:SVR_GAME_START( pack )
	-- body
	require("hall.gameSettings"):setGroupState(1)
	bm.Room.isOver = 0
	require("hall.gameSettings"):setGroupState(1)
    if bm.Room == nil then
        bm.Room = {}
    end
    bm.Room.start_group = 1
end
--接收服务器返回的缓存信息
function NiuniuroomHandle:SERVER_CMD_FORWARD_MESSAGE(pack)

    dump(pack, "-----NiuniuroomHandle 接收服务器返回的缓存信息-----")
    
    local msgList = pack.msgList
    for k,v in pairs(msgList) do
    	if v ~= nil and v ~= "" then
    		local msg = json.decode(v)
    		if msg ~= nil and msg ~= "" then
    			if msg.uid ~= nil and msg.uid ~= "" then
    				require("hall.view.userInfoView.userInfoView"):upDateUserInfo(msg.uid, msg)
    			end
    		end
    	end
    end
    
end

--接收服务器返回的组局信息
function NiuniuroomHandle:SERVER_CMD_MESSAGE(pack)
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
	-- 				dump("voice", "-----接收服务器返回的组局信息-----")

	-- 				require("hall.view.voicePlayView.voicePlayView"):showView(msg.uid, msg.voiceTime)

	-- 				--通知本地播放录音

	-- 				local data = {}
	-- 				data["url"] = msg.url
					
	-- 				local arr = {}
	-- 				table.insert(arr, json.encode(data))
	-- 				cct.getDateForApp("playVoice", arr, "V")

	-- 			elseif msgType == "video" then
	-- 				dump("video", "-----接收服务器返回的组局信息-----")
					
	-- 				local data = {}
	-- 				data["url"] = msg.url
					
	-- 				local arr = {}
	-- 				table.insert(arr, json.encode(data))
	-- 				cct.getDateForApp("playVideo", arr, "V")

	-- 			end
			
	-- 		end

	-- 	end
 --    end
    
end

---------------------------------------------------------------------------------------------------------------------------------------------
--用户相关

--用户登录房间
function NiuniuroomHandle:SVR_LOGIN_ROOM(pack)

	dump(pack, "------NiuniuroomHandle 用户登录房间 1007------")
	require("niuniu.hallScene.NiuniuhallHandle"):SVR_LOGIN_ROOM(pack)

end

--广播用户登录桌子
function  NiuniuroomHandle:SVR_LOGIN_ROOM_BROADCAST(pack)

	dump(pack, "------广播用户登录桌子100D------")
	local uid = tonumber(pack["uid"])
	
	bm.Room.User[uid]     = tonumber(pack["seat_id"]) --保存用户座位与id映射
	bm.Room.UserInfo[uid] = {gold = pack.user_gold}
	self:showPlayer(pack)

	--记录用户信息
	bm.Room.UserInfo[uid].user_info = pack.user_info

end

--获取玩家显示的序号
function NiuniuroomHandle:getIndex(uid)

	dump("", "------获取玩家显示的序号------")

	if tonumber(uid) == tonumber(UID) then
		return 0
	end

	local other_seat  = bm.Room.User[tonumber(uid)]
	local other_index = other_seat - bm.User.Seat
	if other_index < 0 then
		other_index = other_index + 5
	end

	return other_index

end

--显示玩家
function NiuniuroomHandle:showPlayer(pack)

	local uid = tonumber(pack["uid"])

	local other_index = self:getIndex(uid)

	local recscene = SCENENOW['scene']
 --   	if NiuniuroomScenes_name ~= recscene.name then
	-- 	return
	-- end
	
    local info_y = json.decode(pack["user_info"])

	recscene:show_player(other_index,true)

	local position = {}
    if other_index == 0 then
        position.x = 289.00
        position.y = 75.00
    elseif other_index == 1 then
        position.x = 30.00
        position.y = 390.00
    elseif other_index == 2 then
        position.x = 200.00
        position.y = 420.00
    elseif other_index == 3 then
        position.x = 690.00
        position.y = 420.00
    elseif other_index == 4 then
        position.x = 885.00
        position.y = 390.00
    end
    bm.Room.ShowVoicePosion[tonumber(uid)] = position

    --新录音位置显示
    require("hall.view.voicePlayView.voicePlayView"):updateUserPosition(tonumber(uid), position)

	recscene:set_player_gold(other_index,pack["user_gold"])
	local name = info_y["nick"] or info_y["nickName"] 
	recscene:set_player_name(other_index,name)
	local icon_url = info_y["photoUrl"] or info_y["icon_url"] 
	
	recscene:set_player_icon(other_index, icon_url, info_y["sex"],uid,name)

	-- local player_move_pos = { {-20.03,6.60}, {-19.32,201.34}, {59.83,346.56},{658.10,346.84}, {772.95,202.05} }
	      
	-- if bm.Room.Status ~= 0 then  --桌子的状态
	-- 	local panel = recscene._scene:getChildByName("palyer_panel_"..tostring(other_index))
 --        local move_pos = player_move_pos[other_index+1]
	-- 	local move = cc.MoveTo:create(0.2,cc.p(move_pos[1],move_pos[2]))
	-- 	panel:runAction(move)
	-- end

	--添加用户
    local uid_arr = {}
    if bm.Room ~= nil then
        if bm.Room.User ~= nil then
            for k,v in pairs(bm.Room.User) do
                if k ~= tonumber(UID) then
                    table.insert(uid_arr, k)
                end
            end
        end
    end

    dump(uid_arr, "-----用户Id-----")
    require("hall.GameSetting"):setPlayerUid(uid_arr)

end

--玩家请求退出房间成功
function NiuniuroomHandle:SVR_QUICK_SUC()

	dump(pack, "------玩家请求退出房间成功1008------")
	audio.stopMusic(true)

    if bm.notCheckReload and bm.notCheckReload == 1 then
        require("hall.GameTips"):enterHall()
    end
	-- local recscene = SCENENOW['scene']
	-- if NiuniuroomScenes_name ~= recscene.name then
	-- 	return
	-- end

	-- --离开
	-- if  USER_INFO["enter_mode"] == 0 then
	-- 	if bm.runScene.leave_style == 2 then
	-- 		display_scene("niuniu.niuniuScene")
	-- 	end

	-- 	if bm.runScene.leave_style == 1 then
	-- 	--去到大厅
	-- 		display_scene("hall.hallScene")  
	-- 	end

	-- 	if bm.runScene.leave_style == 0 then
	-- 		display_scene("niuniu.niuniuScene")
	-- 	end
	-- else
	-- 	require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])
	-- end

end

--广播玩家退出返回
function NiuniuroomHandle:SVR_QUIT_ROOM(pack)

	dump(pack, "------广播玩家退出返回100E------")
	local uid = tonumber(pack["uid"])

	if bm.Room.User[uid] == nil then
		return
	end

	if bm.round == bm.round_total then
		return
	end

	-- --组局的方式退出
	-- if  USER_INFO["enter_mode"] ~= 0 then
 --        require("hall.GameCommon"):gExitGroupGame(5)
 --        return
 --    end

	local other_index = self:getIndex(uid)
	local recscene = SCENENOW['scene']
	-- if NiuniuroomScenes_name ~= recscene.name then
	-- 	return
	-- end
	-- recscene:show_other_panel_ready(other_index,false)
	-- recscene:show_player(other_index,false)
	recscene:remove_bei_txt(other_index)
	-- end
	bm.Room.User[uid] = nil
	bm.Room.UserInfo[uid] = nil

	--添加用户
    local uid_arr = {}
    if bm.Room ~= nil then
        if bm.Room.User ~= nil then
            for k,v in pairs(bm.Room.User) do
                if k ~= tonumber(UID) then
                    table.insert(uid_arr, k)
                end
            end
        end
    end

    dump(uid_arr, "-----用户Id-----")
    require("hall.GameSetting"):setPlayerUid(uid_arr)

end

---------------------------------------------------------------------------------------------------------------------------------------------
--筹码相关
--获取筹码返回
function NiuniuroomHandle:SVR_GET_CHIP(pack)

	dump(pack, "-----获取筹码返回906-----")

    local scenes   = SCENENOW['scene']
	-- if NiuniuroomScenes_name ~= scenes.name then
	-- 	return
	-- end
    
    scenes:onNetGetChip(pack)

end

--兑换筹码返回
function NiuniuroomHandle:SVR_CHANGE_CHIP(pack)

	dump(pack, "-----兑换筹码返回905-----")

    local scenes   = SCENENOW['scene']
	-- if NiuniuroomScenes_name ~= scenes.name then
	-- 	return
	-- end

    scenes:onNetChangeChip(pack)

end

---------------------------------------------------------------------------------------------------------------------------------------------
--组局时长相关
--牛牛组局时长
function NiuniuroomHandle:SVR_GROUP_TIME(pack)

	dump(pack, "-----牛牛组局时长5101-----")

	-- if pack.round == 0 then
	-- 	return
	-- end

	if pack.round > pack.round_total then
		return
	end

	--记录当前局数
	if bm.round ~= pack.round_total then
		-- bm.round = pack.round + 1
		bm.round = pack.round
	end
	dump(bm.round, "-----当前局数-----")

	--记录总局数
	bm.round_total = pack.round_total
	dump(bm.round_total, "-----总局数-----")

	local scenes   = SCENENOW['scene']
	-- if NiuniuroomScenes_name ~= scenes.name then
	-- 	return
	-- end
	scenes:set_time_str()

	local invite_ly = scenes._scene:getChildByName("invite_ly")
	if invite_ly then
		if bm.round > 0 then
		    invite_ly:setVisible(false)
		end
	end

 --    local time = pack["time"]

 --    local scenes   = SCENENOW['scene']
	-- if NiuniuroomScenes_name ~= scenes.name then
	-- 	return
	-- end

	-- USER_INFO["start_time"] = os.time()
 --    USER_INFO["group_lift_time"] = time

    -- scenes:set_update_group_time_flag(true)
    
end

---------------------------------------------------------------------------------------------------------------------------------------------
--准备相关
--广播用户可以准备了
function NiuniuroomHandle:SVR_READY_TIME(pack)
	
	dump(pack, "------广播用户可以准备了6009------")
	
	local recscene = SCENENOW['scene']
	-- if NiuniuroomScenes_name ~= recscene.name then
	-- 	return
	-- end

	-- if recscene:get_send_ready_flag() == true then
	-- 	return
	-- end

	local invite_ly = recscene._scene:getChildByName("invite_ly")
	if invite_ly then
		invite_ly:setVisible(false)
	end

	recscene:show_panel_ready(true)
	recscene:set_recent_txt_visible(true)
	--recscene:set_recent_txt_("请准备")
	recscene:set_recent_txt_(4)

	recscene:set_timer_text(tostring(pack['time']))
	-- bm.ReadyTime = pack['time']
	bm.ReadyTime = 10
	bm.ReadyStop = false

	bm.SchedulerPool:loopCall(function()

		if bm.ReadyTime == 0 or bm.ReadyTime == nil  or bm.ReadyStop == true then
			
			-- if bm.runScene.show_panel_ready then
			-- 	bm.runScene:show_panel_ready(false)
			-- end

			-- if bm.runScene.set_recent_txt_ then
			-- 	bm.runScene:set_recent_txt_("")
			-- end

			return false

		end

		bm.ReadyTime = bm.ReadyTime -1
		if bm.ReadyTime < 0 then
			bm.ReadyTime = 0
		end
		if bm.runScene.set_timer_text then
			bm.runScene:set_timer_text(tostring(bm.ReadyTime))
		end
		
		return true

	end,1)

end

--广播玩家准备 用户准备了返回
function NiuniuroomHandle:SVR_READY_BROADCAST(pack)
	
	dump(pack, "------广播玩家准备6001------")

	local recscene = SCENENOW['scene']
	-- if NiuniuroomScenes_name ~= recscene.name then
	-- 	return
	-- end

	if pack.uid == tonumber(UID) then
		--print("recscene:show_panel_ready(false)-s-------------------------")
		bm.ReadyStop     = true
		recscene:show_panel_ready(false)
		recscene:set_spectator(false)
		recscene:move_player_panel(0)
		recscene:show_other_panel_ready(0, true)

		bm.IReady = 1

	else
		local index = self:getIndex(pack.uid)
		recscene:move_player_panel(index)
		recscene:show_other_panel_ready(index, true)
	end

end

---------------------------------------------------------------------------------------------------------------------------------------------
--倍数相关
--广播加倍倍数
function NiuniuroomHandle:SVR_USER_BASES_RESULT_BROADCAST(pack)
	
	dump(pack, "-----广播加倍倍数6014-----")

	bm.Room.Sendlasrcard = true
	local scenes   = SCENENOW['scene']
	-- if NiuniuroomScenes_name ~= scenes.name then
	-- 	return
	-- end

	if pack.uid == tonumber(UID) then	
		self:clearAddBase()
		scenes:show_bei(0,pack.base)
	else
		local p_index = self:getIndex(pack.uid)
		scenes:show_bei(p_index,pack.base)
	end

end

--清理加倍的四个倍数按钮
function NiuniuroomHandle:clearAddBase()

	dump("", "-----清理加倍的四个倍数按钮-----")

	local scenes = SCENENOW['scene']
	scenes:show_qiangfeng(false)

end

--处理加倍
function NiuniuroomHandle:SVR_SEND_BASES_TO_USER_BROADCAST(pack)
	
	dump(pack, "-----向特定用户发送可翻倍的数值列表7001-----")

	--显示阶段信息
	local recscene   = SCENENOW['scene']
	-- if NiuniuroomScenes_name ~= recscene.name then
	-- 	return
	-- end

	bm.qiangStop = true
	recscene:set_recent_txt_visible(true)

	recscene:set_recent_txt_(2)
	recscene:set_timer_text(tostring(pack.time))

	bm.addTime = pack['time']    ----------------------8
	bm.addStop = false
	-- bm.SchedulerPool:loopCall(function()
	-- 	--local recscene   = SCENENOW['scene']

	-- 	if bm.addTime == 1 or bm.addTime == nil or bm.addStop == true then
			
	-- 		bm.runScene:set_recent_txt_visible(false)
	-- 		return false
	-- 	end
		
	-- 	bm.addTime = bm.addTime -1

	-- 	-- bm.runScene:set_recent_txt_visible(false)
	-- 	bm.runScene:set_recent_txt_(2)
	-- 	bm.runScene:set_timer_text(tostring(bm.addTime))
	-- 	return true

	-- end,1)

	bm.SchedulerPool:loopCall(function()
		--local recscene   = SCENENOW['scene']

		if recscene == nil then
			return false
		end

		if bm.addTime == 1 or bm.addTime == nil or bm.addStop == true then
			
			recscene:set_recent_txt_visible(false)
			return false
		end
		
		bm.addTime = bm.addTime -1
		if bm.addTime < 0 then
			bm.addTime = 0
		end
		-- bm.runScene:set_recent_txt_visible(false)
		recscene:set_recent_txt_(2)
		recscene:set_timer_text(tostring(bm.addTime))
		return true

	end,1)

	--显示玩家自己可以选择的倍数
	if bm.Room.Zid ~= tonumber(UID) and bm.User.Status ~= 9 then       -------------------------这个其实是别人是庄家的时候，我才可以加分
		self:showBases(pack.bases)
	end

end

--显示倍数
function NiuniuroomHandle:showBases(bases)

	dump("", "-----显示倍数-----")

	local scenes = SCENENOW['scene']
	-- if NiuniuroomScenes_name ~= scenes.name then
	-- 	return
	-- end

	local index           = 1
	for key,value in pairs(bases) do
		scenes:set_qiang_feng_btn_visible(index,true,value)
		scenes:set_bei_score_txt(index,tonumber(value))

		index = index + 1
	end
	scenes:set_not_qiang()

end

---------------------------------------------------------------------------------------------------------------------------------------------
--庄家相关
--广播开始抢庄
function NiuniuroomHandle:SVR_BEGIN_QIANFGZHUANG_BROADCAST(pack)
	
	dump(pack,"-----广播开始抢庄6015-----")

	local recscene = SCENENOW['scene']
 --   	if NiuniuroomScenes_name ~= recscene.name then
 --   		dump("当前不是牛牛界面","-----广播开始抢庄6015-----")
	-- 	return
	-- end

	--棋牌进行中
	bm.Room.Status = 3

	--获取当前正在抢庄的用户
	bm.Room.QiangUid = {}
	bm.Room.QiangUid = pack.ids

	--记录当前自己是否已经抢庄
	local exsits = false
	for key,value in pairs(bm.Room.QiangUid) do
		if tonumber(UID) == value then
			--当前自己已经抢庄
			exsits = true

			recscene:show_other_qiangzang(0,0)
			break
		end
	end

	for key,value in pairs(bm.Room.User) do 
		local if_can_qiang = false
		for key_t,value_t in pairs(bm.Room.QiangUid) do
			--printInfo(".........key..........1234......can_qiang")
			printInfo(key)
			printInfo(value_t)
			if key == value_t then
				if_can_qiang = true
				break
			end
		end
		if if_can_qiang == true then
			self:showQiangStatus(key,0)
		end
	end
	
	local notice = ""
	if exsits ==false then
		--notice = "您不能抢庄,呵呵"
	end
	
	recscene:show_panel_ready(false) ---------隐藏“准备”相关
	recscene:set_recent_txt_visible(true)

	if notice ~= "" then
		recscene:set_recent_txt_(notice)
		bm.qiang_notice = notice
	else
		--recscene:set_recent_txt_("抢庄阶段")
		recscene:set_recent_txt_(1)
		bm.qiang_notice = ""
	end

	recscene:set_timer_text(tostring(pack.time))


	bm.qiangTime = pack['time']
	bm.qiangStop = false
	bm.SchedulerPool:loopCall(function()

		if bm.qiangTime == 1 or bm.qiangTime == nil  or bm.qiangStop == true then
			
			bm.runScene:set_recent_txt_visible(false)
			return false
		end
		bm.runScene:set_recent_txt_visible(true)
		bm.qiangTime = bm.qiangTime -1
		if bm.qiangTime < 0 then
			bm.qiangTime = 0
		end
		
		-- ready_text:setString("抢庄阶段"..bm.qiangTime.."秒"..notice)
		if bm.qiang_notice ~= "" then
			bm.runScene:set_recent_txt_(bm.qiang_notice)
		else
			--bm.runScene:set_recent_txt_("抢庄阶段")
			bm.runScene:set_recent_txt_(1)
		end

		bm.runScene:set_timer_text(tostring(bm.qiangTime))

		return true
	end,1)

	if exsits == true then
		local scenes = SCENENOW['scene']
  		scenes:show_qiangzang(true)-------------------------显示抢庄面板
	end

end

--处理抢庄结果
function NiuniuroomHandle:SVR_USER_QIANFGZHUANG_RESULT_BROADCAST(pack)
	
	dump(pack, "------广播玩家抢庄结果6013-----")

	local scenes          = SCENENOW['scene']
	-- if NiuniuroomScenes_name ~= scenes.name then
	-- 	return
	-- end

	scenes:show_qiangzang(false)   --隐藏抢庄面板

	if pack.uid == tonumber(UID) then
		scenes:show_other_qiangzang(0,1)
	else	
		local p_index = self:getIndex(pack.uid)
		scenes:show_other_qiangzang(p_index,1)
	end

end

--广播庄家id
function NiuniuroomHandle:SVR_BRANK_BROADCAST(pack)

	dump(pack, "------广播庄家id 6003-----")
	local uid = tonumber(pack["uid"])

	if uid == -1 then
		return
	end

	bm.Room.Zid = uid

	local scenes   = SCENENOW['scene']
	-- if NiuniuroomScenes_name ~= scenes.name then
	-- 	return
	-- end
	scenes:hide_qiangzuang()

	local p_index = self:getIndex(uid)
	scenes:show_zuang(p_index,true)

end

--显示其他抢庄的状态
function NiuniuroomHandle:showQiangStatus(uid,if_qiang)
	if if_qiang ~= 1 then 
		if_qiang = 0 
	end
	local p_index    = self:getIndex(uid)
	local scenes     = SCENENOW['scene']
	scenes:show_other_qiangzang(p_index,if_qiang)
end

---------------------------------------------------------------------------------------------------------------------------------------------
--发牌相关
--处理发牌协议
function NiuniuroomHandle:SVR_SEND_USER_CARD(pack,isme)
	
	dump(pack, "------发送用户的牌信息4001------ is_send_card:"..tostring(bm.Room.is_send_card))
	bm.Room.Status = 3 --棋牌进行中

	if not bm.Room.Sendlasrcard then 

		bm.User.Cards = {}
		bm.ReadyStop  = true

		if isme == nil then
			self:sendCardAnimation()
		end
		self:showMycardThree(pack)
	else

		local y = 1
		for key,value in pairs(bm.User.Cards) do
			local x = 1
			for key_t,value_t in pairs(pack.cards) do
				if y == x then
					if value ~= nil and value.setCard ~= nil and value_t ~= 0 then
						local recent_card = value:setCard(value_t)
						recent_card:showFront()

						-- local contentsize =  recent_card.font_pai_:getContentSize()
						-- recent_card.font_pai_:setScale(73/contentsize.width,102/contentsize.height)

					end
				end
				x =x +1
			end
			y=y+1
		end
		self:choiceCardsSet()

	end

end

--显示自己发的牌
function NiuniuroomHandle:showMycardThree(pack)

	dump(pack, "------显示自己发的牌------")

	local recscene = SCENENOW['scene']
 --   	if NiuniuroomScenes_name ~= recscene.name then
	-- 	return
	-- end

	--隐藏邀请微信好友
    local invite_ly = recscene._scene:getChildByName("invite_ly")
    invite_ly:setVisible(false)

    --隐藏解散房间按钮
    local disband_ly = recscene._scene:getChildByName("disband_ly")
    disband_ly:setVisible(false)

    --显示录制按钮
    local btn_record = recscene._scene:getChildByName("btn_record")
    btn_record:setVisible(true)

    --隐藏其他用户的准备标志
    for i=0,4 do
    	recscene:show_other_panel_ready(i, false)
    end

    bm.IReady = 0

    --添加用户
    local uid_arr = {}
    if bm.Room ~= nil then
        if bm.Room.User ~= nil then
            for k,v in pairs(bm.Room.User) do
                if k ~= tonumber(UID) then
                    table.insert(uid_arr, k)
                end
            end
        end
    end

    dump(uid_arr, "-----用户Id-----")
    require("hall.GameSetting"):setPlayerUid(uid_arr)

    -- require("hall.leader.LeaderLayer"):showLeaderLayer(cc.p(897.00, 166.00))

 --    --添加录音按钮
	-- require("hall.VoiceRecord.VoiceRecordView"):showView(905.61, 136.38)

	-- dump(bm.Room.ShowVoicePosion, "-----录音播放效果显示位置-----")

	local i = 0
	for key,value in pairs(pack['cards']) do
		local card = nil
		if value == 0 then
			card = require("niuniu.PokerCard").new()
			card:addTo(recscene._scene)
			card:showBack()
			
			-- local contentsize =  card.backBg_:getContentSize()
			-- card.backBg_:setScale(73/contentsize.width,102/contentsize.height)

		else
			card = require("niuniu.PokerCard").new()
			card:setCard(value)
			card:addTo(recscene._scene)
			card:showFront()

			-- local contentsize =  card.font_pai_:getContentSize()
			-- card.font_pai_:setScale(73/contentsize.width,102/contentsize.height)
		end 
		
		table.insert(bm.User.Cards, card)

		card:setPositionY(0)
		card:setPositionX(210 + i * 110)
		
		i = i + 1

	end

	require("niuniu.niuniuNamal.NiuniuroomScenes"):showAndHide()

end

--其他玩家发牌动画  在其他玩家前面发5张牌。有动画效果
function  NiuniuroomHandle:sendCardAnimation(show_move_eff)

	-- if bm.Room and bm.Room.is_send_card and bm.Room.is_send_card == 1 then
	-- 	return
	-- end

	-- bm.Room.is_send_card = 1

	local min = nil
	local max = nil
	local map = {}

	self:resetUserCards()

	for key,value in pairs(bm.Room.User) do
		local other_index = self:getIndex(key)
		map[other_index]  = key
		if min == nil or other_index < min then
			min = other_index
		end
		if max == nil or other_index > max then
			max = other_index
		end
	end

	local pai_draw_pos = {{385.86,118.06},{171.91,302.93},{280.14,422.00},{559.98,422.00},{684.04,301.17}}

	local recscene = SCENENOW['scene']
	dump(bm.callfunc, "================map============UserCards===========")
	dump(map)
	for j=min,max do 
		local tem_user_id = map[j]
		if tem_user_id ~= nil then
			bm.Room.UserCards[tem_user_id] = {}
			print("tem_user_id...............card",tem_user_id)
			for i=5,1,-1 do
				local card = require("niuniu.PokerCard").new():addTo(recscene._scene)
				card:showBack()

				local contentsize =  card.backBg_:getContentSize()
				card.backBg_:setScale(48 / contentsize.width, 68 / contentsize.height)

				if show_move_eff == nil then
					card:setPositionY(270)
					card:setPositionX(480)
					local move = cc.MoveTo:create(0.2,cc.p((5-i)*15 + pai_draw_pos[j+1][1], pai_draw_pos[j+1][2] ))
					--cc.ScaleTo:create(time, scale)

					local delay= cc.DelayTime:create((5-i)*0.1)
					local se   = cc.Sequence:create(delay,move)
					dump(bm.callfunc, "sendCardAnimation", nesting)
					if bm.callfunc and i == 1 then
						se = cc.Sequence:create(delay, move, cc.CallFunc:create(bm.callfunc))
					end
					card:runAction(se)
				else
					card:setPositionY(pai_draw_pos[j+1][2] )
					card:setPositionX((5-i)*15 + pai_draw_pos[j+1][1])
				end

				table.insert(bm.Room.UserCards[map[j]],card)
			end
		end
	end

end

---------------------------------------------------------------------------------------------------------------------------------------------
--选牌相关
--设置选牌
function NiuniuroomHandle:choiceCardsSet()

	dump(pack, "------设置选牌------")

	bm.Room.Mychoice = {}
	for key,value in pairs(bm.User.Cards) do
		value:setTouchEnabled(true)
		value:addNodeEventListener(cc.NODE_TOUCH_EVENT,function ( event )
			
			if event.name == "began" then

				--cc.SimpleAudioEngine:getInstance():playEffect("niuniun/music/Audio_Button_Click.mp3",false)
			
				local y = value:getPositionY()
				if y <= 10 then

					if #bm.Room.Mychoice >= 3 then
						return true
					end

					value:setPositionY(y + 20)
					table.insert(bm.Room.Mychoice,value)
					self:showMyChoicePoint()

				else
					value:setPositionY(y - 20)
					for i,v in pairs(bm.Room.Mychoice) do
						if v.cardUint_ == value.cardUint_ then
							table.remove(bm.Room.Mychoice,i)
						end
					end
					self:showMyChoicePoint()

				end

				return true
			end
		end)

	end

end

--显示我选择的牌的分数
function NiuniuroomHandle:showMyChoicePoint()

	dump(pack, "------显示我选择的牌的分数------")

	local scenes     = SCENENOW['scene']
	-- if NiuniuroomScenes_name ~= scenes.name then
	-- 	return
	-- end

	local value = 0
	local index = 1

    --每次都刷新
	scenes:set_niu_feng(1,tostring(0))
	scenes:set_niu_feng(2,tostring(0))
	scenes:set_niu_feng(3,tostring(0))
	scenes:set_sum_feng(tostring(0))

	for i,v in pairs(bm.Room.Mychoice) do
		local tmp = v.cardValue_
		if tmp > 10 and tmp <14 then
			tmp = 10
		elseif tmp > 13 then
			tmp = 1
		end
		scenes:set_niu_feng(index,tostring(tmp))
		index = index + 1
		value = value + tmp
	end
	
	scenes:set_sum_feng(tostring(value))


	--上面是玩家选了3张牌后，我们计算了有没有牛，也就是这个value值
	--如果有牛的话，那么我们添加有牛的按钮事件。
	--
	--local submit = scenes:getChildByName("submit")
	-- local niu_panel = scenes._scene:getChildByName("niu_tip")
	-- local youniu_btn = niu_panel:getChildByName("btn_youniu")
	-- local meiniu_btn = niu_panel:getChildByName("btn_meiniu")

	-- if #bm.Room.Mychoice >=3 then
	-- 	if value % 10 == 0 then
	-- 		bm.buttontHandler(youniu_btn,function ()
	-- 		NiuniuroomServer:sendMycards()
	-- 		bm.runScene:show_niu_tip(false)
	-- 		bm.runScene:show_niu_tip_btn(false)
	-- 		end)
	-- 		youniu_btn:setVisible(true)
	-- 	else	
			
	-- 		bm.buttontHandler(meiniu_btn,function ()
	-- 			NiuniuroomServer:sendMycards()
	-- 			bm.runScene:show_niu_tip(false)
	-- 			bm.runScene:show_niu_tip_btn(false)
	-- 		end)
	-- 		meiniu_btn:setVisible(true)
	-- 	end
	-- else
	-- 	youniu_btn:setVisible(false)
	-- 	meiniu_btn:setVisible(false)
	-- end

end

---------------------------------------------------------------------------------------------------------------------------------------------
function NiuniuroomHandle:showGameTips( flag )
	-- body
	local is_show = flag or false

	local recscene = SCENENOW['scene']
	local niu_panel = recscene._scene:getChildByName("niu_tip")
	if niu_panel then
		local youniu_btn = niu_panel:getChildByName("btn_youniu")
		if youniu_btn then
			youniu_btn:setVisible(false)
		end
	end
end
--出牌相关
--广播玩家开始出牌
function NiuniuroomHandle:SVR_PLAY_CARD_BROADCAST(pack)
	
	dump(pack, "-----广播玩家开始出牌6004-----")

	--显示阶段信息
	bm.Room.Status = 3 --棋牌进行中
	local recscene = SCENENOW['scene']
	-- if NiuniuroomScenes_name ~= recscene.name then
	-- 	return
	-- end

	if recscene.isspectator == false then
		recscene:show_niu_tip(true)
	end

	bm.addStop = true
	recscene:set_recent_txt_visible(true)
	recscene:set_recent_txt_(3)
	recscene:set_timer_text(tostring(pack.time))

	-- 显示摊牌
	local niu_panel = recscene._scene:getChildByName("niu_tip")
	local youniu_btn = niu_panel:getChildByName("btn_youniu")

	bm.buttontHandler(youniu_btn,function ()
		NiuniuroomServer:sendMycards()
		bm.runScene:show_niu_tip(false)
		bm.runScene:show_niu_tip_btn(false)
	end)
	youniu_btn:setVisible(true)


	bm.playTime = pack.time
	bm.playStop = false
	bm.SchedulerPool:loopCall(function()
		if bm.playTime == 1 or bm.playTime == nil  or bm.playStop == true then
			
			bm.runScene:set_recent_txt_visible(false)
			bm.runScene:show_niu_tip(false)
			return false
		end
		
		bm.runScene:set_recent_txt_visible(true)
		bm.playTime = bm.playTime -1
		if bm.playTime < 0 then
			bm.playTime = 0
		end
		bm.runScene:set_recent_txt_(3)
		bm.runScene:set_timer_text(tostring(bm.playTime))
		return true
	end,1)

end

--玩家出牌
function NiuniuroomHandle:SVR_USER_PLAYED_CARDS_BROADCAST(pack)

	dump(pack, "-----玩家出牌6005-----")

	bm.Room.Status = 3 --棋牌进行中
	local scenes = SCENENOW['scene']
	-- if NiuniuroomScenes_name ~= scenes.name then
	-- 	return
	-- end

	if pack.uid == tonumber(UID) then

	else

		local y = 1
		local have_sort_flag = is_nuw_num(pack.kind)
		for key,value in pairs(pack.cards) do
			local x = 1
			dump(bm.Room.UserCards, "SVR_USER_PLAYED_CARDS_BROADCAST", nesting)
			for key_t,value_t in pairs(bm.Room.UserCards[pack.uid]) do
				if x == y then
					local rec_card = value_t:setCard(value)
					rec_card:showFront()

					local contentsize =  rec_card.font_pai_:getContentSize()
					rec_card.font_pai_:setScale(48/contentsize.width,68/contentsize.height)

					if have_sort_flag == true and x > 3 then
						local card_x = rec_card.font_pai_:getPositionX()
						rec_card.font_pai_:setPositionX(card_x + 30)
					end

				end
				x = x +1
			end
			y = y+1
		end

	end

	local point_str = CARDTYPE_IMAGE[pack.kind] ---牛的类型,比如：牛一，牛二......
	local scenes = SCENENOW['scene']

	--播放牛牛结果牌的声音
	local sound_path = GET_CARD_RESULT_SOUND(pack.kind)
	-- cc.SimpleAudioEngine:getInstance():playEffect(sound_path,false)
	require("hall.VoiceUtil"):playEffect(sound_path,false)

	if pack.uid == tonumber(UID) then	

		self:clearAddBase()

		local niuniu_tip = scenes._scene:getChildByName("niuniu_txt".. 0)
		if niuniu_tip ~= nil then
			niuniu_tip:removeSelf()
		end

		scenes:show_niu_text(0, point_str)

		local have_sort_flag = is_nuw_num(pack.kind)
		
		local j=0
		local dis = 288
		if bm.Room.Mychoice then
			for i,card in pairs(bm.Room.Mychoice) do
				card:setLocalZOrder(j)
				j=j+1
				card:setPositionY(110)
				card:setPositionX(288 + (i-1) * 73)
				dis = 288 + (i-1) * 73 + 150 -- 最后一张牌的位置加30
			end
		end

		local i = 0
		for i_index,card in pairs(bm.User.Cards) do

			

			local find_flag = false
			for _,choose_card in pairs(bm.Room.Mychoice) do
				if choose_card == card then
					find_flag = true
				end
			end
			if find_flag == false then
				card:setPositionY(110)
				card:setPositionX(dis + i * 73)
				card:setLocalZOrder(j)
				i = i + 1 
				j=j+1
			end

		end
		for key,value in pairs(bm.User.Cards) do
			value:setTouchEnabled(false)
		end
	else

		local p_index = self:getIndex(pack.uid )
		local niuniu_tip = scenes._scene:getChildByName("niuniu_txt"..p_index)
		if niuniu_tip ~= nil then
			niuniu_tip:removeSelf()
		end
		scenes:show_niu_text(p_index,point_str)

	end
	
end

---------------------------------------------------------------------------------------------------------------------------------------------
--结算相关
--结算
function NiuniuroomHandle:SVR_SETTLEMENT_BROADCAST(pack)

	dump(pack, "-----牛牛结算6008-----")
	dump(bm.Room, "-----牛牛结算 当前房间信息-----")

	bm.Room.Status = 0 --棋牌结束
	bm.User.Status = 0 --牌局结束
	bm.playStop = true

    if bm.Room == nil then
        bm.Room = {}
    end
    bm.Room.isOver = 1
	require("hall.gameSettings"):setGroupState(0)
    bm.Room.start_group = 0

	local scenes   = SCENENOW['scene']
	-- if NiuniuroomScenes_name ~= scenes.name then
	-- 	return
	-- end

	for key,value in pairs(pack.o_userinfo) do

		--自己
		if value.uid == tonumber(UID) then	

			--隐藏有牛没牛界面
			scenes:show_niu_tip(false)

			--设置当前的金币
			scenes:set_player_gold(0,tostring(value.gold))
			self:clearAddBase()

			local fengcheng  = value.cardgold
			local Totalwin= value.cardgold
			if value.cardgold > 0 then

				--计算分成
				fengcheng = bm.User.Gold + value.cardgold - value.gold
				if fengcheng > 0 then
					scenes:send_extract(value.cardgold,fengcheng)
					
				end

				if USER_INFO["enter_mode"] == 0 then
					--todo

					Totalwin=math.floor(value.cardgold/0.8)
				end

			end
			scenes:drawCoin(0,Totalwin,fengcheng)
			bm.User.Gold = value.gold

			self:send_something(value.cardgold)

		else

			--这里其实是出理其他分家的输赢情况，没能测试(有有3个玩家才行)===========
			local p_index  = self:getIndex(value.uid)
			scenes:set_player_gold(p_index,tostring(value.gold))

			local fengcheng  = 0
			local userinfo = bm.Room.UserInfo[value.uid]
			local userinfo_gold = userinfo.o_user_gold or userinfo.gold
			local Totalwin=value.cardgold
			if value.cardgold > 0 then
				if USER_INFO["enter_mode"] == 0 then
					Totalwin=math.floor(value.cardgold/0.8)
					--fengcheng = userinfo_gold + value.cardgold - value.gold
				end
			end
			scenes:drawCoin(p_index,Totalwin,fengcheng)
			userinfo.gold = value.gold
			bm.Room.UserInfo[value.uid] = userinfo 

		end

	end

	---显示庄家输赢金币数文本
	--local point_str = tostring(pack.brank_cardgold) --输赢的金币数

	if pack.brank_id == tonumber(UID) then	--如果我是庄家

		scenes:show_niu_tip(false) --隐藏有牛没牛界面
		scenes:set_player_gold(0,tostring(pack.brank_gold)) --设置当前的金币

		self:clearAddBase()

		local fengcheng =  0
		local Totalwin=pack.brank_cardgold
		if pack.brank_cardgold > 0 then

			--计算分成
			fengcheng = bm.User.Gold + pack.brank_cardgold - pack.brank_gold 
			if fengcheng > 0 then
				scenes:send_extract(pack.brank_cardgold,fengcheng)	
			end

			if USER_INFO["enter_mode"] == 0 then
				--todo
				Totalwin=math.floor(pack.brank_cardgold/0.8)
			end

		end

		scenes:drawCoin(0,Totalwin,fengcheng)
		bm.User.Gold = pack.brank_gold

		self:send_something(pack.brank_cardgold)

	else

		local p_index = self:getIndex(pack.brank_id )
		scenes:set_player_gold(p_index,tostring(pack.brank_gold)) --设置当前的金币

		local fengcheng =  0
		
		local userinfo = bm.Room.UserInfo[pack.brank_id]
		local userinfo_gold = userinfo.o_user_gold or userinfo.gold

		local Totalwin=pack.brank_cardgold

		if pack.brank_cardgold > 0 then

			if USER_INFO["enter_mode"] == 0 then --非组局
				--todo
				Totalwin=math.floor(pack.brank_cardgold/0.8)
			end
			--fengcheng = userinfo_gold + pack.brank_cardgold - pack.brank_gold
		end

		scenes:drawCoin(p_index,Totalwin,fengcheng)

		userinfo.gold = pack.brank_gold
		bm.Room.UserInfo[pack.brank_id] = userinfo

	end

	--开始update
	scenes:update_begin_flag()

	bm.SchedulerPool:delayCall(function ( )
		NiuniuroomHandle:cardInit()

    	bm.Room.isOver = 0 --结束单局结果显示
		if bm.Room.group_data then
			dump(bm.Room.group_data, "显示排行榜", nesting)
			self:showResult(bm.Room.group_data)
			bm.Room.group_data = nil
		else
			if bm.runScene.show_over_layout ~= nil then
				bm.runScene:show_over_layout(false)
			end
		end
	end,4)

	bm.SchedulerPool:delayCall(function ( )
		if bm.runScene.show_over_layout ~= nil then
			bm.runScene:show_over_layout(false)
		end
	end,pack.time)

	--更新当前局数
	-- bm.round = pack.round + 1
	-- dump(bm.round, "-----当前局数-----")
	-- scenes:set_time_str()
	
end

--牛牛组局排行榜
function NiuniuroomHandle:SVR_GROUP_BILLBOARD(pack)

	dump(pack, "-----牛牛组局排行榜5100-----")

	-- dump(bm.round, "-----牛牛组局排行榜bm.round-----")
	-- dump(bm.round_total, "-----牛牛组局排行榜bm.round-----")
	dump(bm.Room, "SVR_GROUP_BILLBOARD", nesting)

	-- if bm.round == bm.round_total and bm.round ~= 0 then
	if bm.Room and bm.Room.isOver and tonumber(bm.Room.isOver) == 1 then
		bm.Room.group_data = pack
	else
		print("SVR_GROUP_BILLBOARD 显示排行榜")
		self:showResult(pack)
	end

	-- if bm.round ~= 0 then

	-- 	local scenes   = SCENENOW['scene']
	-- 	-- if NiuniuroomScenes_name ~= scenes.name then
	-- 	-- 	return
	-- 	-- end
		
	-- 	--延迟两秒出现结果界面
	-- 	local a = display.newSprite():addTo(scenes)
	-- 	a:runAction(
	-- 		cc.Sequence:create(cc.DelayTime:create(4), cc.CallFunc:create(
	-- 			function ()
				
	-- 				self:showResult(pack)

	-- 				a:removeSelf()

	-- 			end)  
	-- 		)
	-- 	)

	-- else

	-- 	self:showResult(pack)

	-- end

end

--显示组局总结果
function NiuniuroomHandle:showResult(pack)

	if pack == nil then
		return
	end

	local scenes   = SCENENOW['scene']
	-- if NiuniuroomScenes_name ~= scenes.name then
	-- 	return
	-- end

	--旧的组局排行榜（弃用）
    -- SCENENOW["scene"]:onNetBillboard(pack)

    --去掉提示弹框
	local layer_tips = SCENENOW["scene"]:getChildByName("layer_tips")
    if layer_tips then
        layer_tips:removeSelf()
    end

    --获取总结算界面
    local s = cc.CSLoader:createNode("niuniu/common/GameResult.csb")
    s:setName("GameResult")
    SCENENOW["scene"]:addChild(s,9998)

    local jzdb_sp = cc.Sprite:create("niuniu/newimage/text_jinzhidubo.png")
    jzdb_sp:setAnchorPoint(0.5, 0.5)
    jzdb_sp:setPosition(480, 520)
    s:addChild(jzdb_sp)

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

                --移除录音按钮
                require("hall.VoiceRecord.VoiceRecordView"):removeView()

                --退出房间，返回大厅
                require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])

            end
        end
    )

    --截屏分享
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
                if device.platform == "android" then
                	require("hall.common.ShareLayer"):showShareLayer("分享结果","","screen","",share_ly)
                elseif device.platform ~= "windows" then
                	require("hall.common.ShareLayer"):shareGroupResultForIOS(share_ly)
                end

            end
        end
    )

    --结果显示区域
    local content_ly = s:getChildByName("content_ly")
    local content_sv = content_ly:getChildByName("content_sv")

    --显示用户结算结果
    local playerlist = pack.playerlist

 --    local test_list = {}
	-- for i=1,5 do
	-- 	table.insert(test_list, playerlist[1])
	-- end

	-- playerlist = test_list

 --    dump(playerlist, "-----test_list-----")


    if #playerlist > 0 then

    	local zOrder = #playerlist

    	content_sv:setInnerContainerSize(cc.size(219 * #playerlist, content_sv:getContentSize().height))

    	if #playerlist > 4 then
    		content_sv:setInnerContainerSize(cc.size(219 * 4, content_sv:getContentSize().height))
    	end

    	--生成界面
    	for k,v in pairs(playerlist) do

    		--获取用户id
    		local uid = v.uid

    		--获取用户信息以及结算情况
	    	local user_info = json.decode(v.user_info)

	    	--定义结果分项
	    	local result_Item = cc.CSLoader:createNode("niuniu/common/GameResult_Item.csb")
	    	result_Item:setLocalZOrder(zOrder)
	    	zOrder = zOrder - 1
	    	content_sv:addChild(result_Item)

	    	local item_ly = result_Item:getChildByName("item_ly")
	    	item_ly:setPosition(219 * (k - 1), content_sv:getContentSize().height)

	    	if #playerlist > 4 then
	    		result_Item:setScale(0.8)
	    		item_ly:setPosition(219 * (k - 1), content_sv:getContentSize().height + 45)
	    	end

	    	local top_ly = item_ly:getChildByName("top_ly")

	    	--用户头像
	    	local head_im = top_ly:getChildByName("head_im")
	    	require("hall.GameCommon"):getUserHead(user_info.photo_url, v.uid, user_info.sex, head_im, 61, false, user_info.nick_name)

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
	    	local content_svv = item_ly:getChildByName("content_sv")

	    	--牛八
	    	local niuba_ly = content_svv:getChildByName("niuba_ly")
	    	local niuba_itemNum_tt = niuba_ly:getChildByName("itemNum_tt")
	    	if user_info.niu8 ~= nil then
	    		niuba_itemNum_tt:setString(tostring(user_info.niu8))
	    	end

	    	--牛九
	    	local niujiu_ly = content_svv:getChildByName("niujiu_ly")
	    	local niujiu_itemNum_tt = niujiu_ly:getChildByName("itemNum_tt")
	    	if user_info.niu9 ~= nil then
	    		niujiu_itemNum_tt:setString(tostring(user_info.niu9))
	    	end

	    	--牛牛
	    	local niuniu_ly = content_svv:getChildByName("niuniu_ly")
	    	local niuniu_itemNum_tt = niuniu_ly:getChildByName("itemNum_tt")
	    	if user_info.niuniu ~= nil then
	    		niuniu_itemNum_tt:setString(tostring(user_info.niuniu))
	    	end

	    	--四炸
	    	local sizha_ly = content_svv:getChildByName("sizha_ly")
	    	local sizha_itemNum_tt = sizha_ly:getChildByName("itemNum_tt")
	    	if user_info.sizha ~= nil then
	    		sizha_itemNum_tt:setString(tostring(user_info.sizha))
	    	end

	    	--五花牛
	    	local wuhua_ly = content_svv:getChildByName("wuhua_ly")
	    	local wuhua_itemNum_tt = wuhua_ly:getChildByName("itemNum_tt")
	    	if user_info.wuhuaniu ~= nil then
	    		wuhua_itemNum_tt:setString(tostring(user_info.wuhuaniu))
	    	end

	    	--五小牛
	    	local wuxiao_ly = content_svv:getChildByName("wuxiao_ly")
	    	local wuxiao_itemNum_tt = wuxiao_ly:getChildByName("itemNum_tt")
	    	if user_info.wuxiaoniu ~= nil then
	    		wuxiao_itemNum_tt:setString(tostring(user_info.wuxiaoniu))
	    	end

	    	--底部区域
	    	local bottom_ly = item_ly:getChildByName("bottom_ly")

	    	--总成绩
	    	--用户当前的积分
	    	local chips =user_info.chips - user_info.add_chips
	    	-- if bm.round == 0 then
	    	-- 	chips = user_info.chips
	    	-- else
	    	-- 	chips = user_info.chips - user_info.add_chips
	    	-- end
	    	-- dump(bm.round, "-----bm.round-----")
	    	-- if bm.round == 0 then
	    	-- 	chips = 0 
	    	-- else
	    	-- 	chips = chips - USER_INFO["group_chip"]
	    	-- end
	    	-- if bm.round == 1 then
	    	-- 	if chips == -20000 then
		    -- 		chips = 0
		    -- 	end
	    	-- end
	    	local socre_tt = bottom_ly:getChildByName("socre_tt")
	    	socre_tt:setString(tostring(chips))

    	end

    end

end

function NiuniuroomHandle:send_something(userpergold)

	dump(userpergold, "-----牛牛send_something-----")

	if USER_INFO["enter_mode"] == 0 then
		if userpergold > 0 then
			require("hall.HttpSettings"):UpdateDanPoint(5,1)
		elseif userpergold < 0 then
			require("hall.HttpSettings"):UpdateDanPoint(5,0)
		else
			require("hall.HttpSettings"):UpdateDanPoint(5,2)
		end
	end

end

---------------------------------------------------------------------------------------------------------------------------------------------
--组局解散相关
--没有此房间，解散房间失败
function NiuniuroomHandle:G2H_CMD_DISSOLVE_FAILED(pack)

	dump("-----没有此房间，解散房间失败-----", "-----没有此房间，解散房间失败-----")

	require("hall.GameTips"):showTips("提示", "disbandGroup_fail", 2, "解散房间失败")

end

--广播当前组局解散情况
function NiuniuroomHandle:G2H_CMD_REFRESH_DISSOLVE_LIST(pack)

	dump(pack, "-----广播当前组局解散情况-----")
	dump(bm.Room, "-----广播当前房间情况-----")

	local applyId = pack.applyId
	local agreeNum = pack.agreeNum
	local agreeMember_arr = pack.agreeMember_arr

	local showMsg = ""

	--申请解散者信息
	local applyer_info = {}
	if applyId == tonumber(UID) then
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
	if bm.Room ~= nil then
		if bm.Room.UserInfo ~= nil then

			dump(bm.Room.UserInfo, "-----广播当前组局解散情况bm.Room.UserInfo-----")

			for k,v in pairs(bm.Room.UserInfo) do
				local uid = v.uid

				dump(uid, "-----广播当前组局解散情况uid-----")

				--排除掉自己，自己不需要显示到这里
				if uid ~= tonumber(UID) then
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
	end

	if applyId == tonumber(UID) then
		--假如申请者是自己，则直接显示其他用户的选择情况
		require("hall.GameTips"):showDisbandTips("提示", "agree_disbandGroup", 4, showMsg)
	else
		--申请者不是自己，根据自己的同意情况进行界面显示
		if isMyAgree == 1 then
			require("hall.GameTips"):showDisbandTips("提示", "agree_disbandGroup", 4, showMsg)
		else
			require("hall.GameTips"):showDisbandTips("提示", "niuniu_request_disbandGroup", 1, showMsg)
		end
	end
	

end

--广播桌子用户请求解散组局
function NiuniuroomHandle:SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP(pack)

	dump(pack, "-----广播桌子用户请求解散组局-----")

	-- require("hall.GameTips"):showTips("提示", "niuniu_request_disbandGroup", 1, "确认解散房间")

end

--广播桌子用户成功解散组局
function NiuniuroomHandle:SERVER_BROADCAST_DISSOLVE_GROUP(pack)

	dump(pack, "-----广播桌子用户成功解散组局-----")

	bm.isDisbandSuccess = true

	-- require("hall.GameTips"):showTips("解散房间成功","disbandGroup_success",3)

end

--广播桌子用户解散组局 ，解散组局失败
function NiuniuroomHandle:SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP(pack)

	dump(pack, "-----广播桌子用户解散组局 ，解散组局失败-----")

	local rejectId = tonumber(pack.rejectId)
	if rejectId == tonumber(UID) then
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

---------------------------------------------------------------------------------------------------------------------------------------------
--聊天相关
function NiuniuroomHandle:SVR_MSG_FACE(pack)

	dump(pack, "-----文字聊天信息返回 1004-----")

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
        node_head = SCENENOW["scene"]._scene:getChildByName("palyer_panel_0"):getChildByName("head")

    else

        local othInfo = json.decode(bm.Room.UserInfo[pack.uid]["user_info"])
        dump(othInfo, "-----othInfo-----")
		if othInfo ~= nil then
			sexT = othInfo.sex
		end

		node_head = SCENENOW["scene"]._scene:getChildByName("palyer_panel_"..tostring(index)):getChildByName("head")

    end

    if index == 3 or index == 4 then
       isLeft = true
    end

    dump(faceUI, "-----faceUI-----")
    dump(node_head, "-----node_head-----")
    dump(sexT, "-----sexT-----")

    if faceUI ~= nil and node_head ~= nil then
    	faceUI:showGetFace(pack.uid, pack.type, tonumber(sexT), node_head, isLeft)
    end

end

---------------------------------------------------------------------------------------------------------------------------------------------
--破产相关
--破产
function NiuniuroomHandle:SVR_BRANKRUPT(pack)

	dump(pack, "-----牛牛破产7002-----")

	local scenes = SCENENOW['scene']
	-- if NiuniuroomScenes_name ~= scenes.name then
	-- 	return
	-- end

	if  USER_INFO["enter_mode"] ~= 0 then
		require("hall.GameCommon"):showChange(true)
		scenes:set_need_send_ready_msg(true)
	end

end

--新加协议
function NiuniuroomHandle:SERVER_COMMAND_KICK_OUT_ROOM(pack)
	
	dump(pack, "-----新加协议7007-----")

   -- KICK_USER_OUT_BANKRUPT = 1,--破产
   --   KICK_USER_OUT_NO_FEEDBACK = 2,
   --   KICK_USER_OUT_LACK_FEE = 3,--用户不足扣台费
   --   KICK_USER_OUT_JETTON_BANKRUPT = 4,
	local scenes   = SCENENOW['scene']
	-- if NiuniuroomScenes_name ~= scenes.name then
	-- 	return
	-- end
	if pack and pack.type == 1 then
		if  USER_INFO["enter_mode"] == 0 then
			display_scene("niuniu.niuniuScene")

			local NiuniuManager = require("niuniu.niuniumanager")
			NiuniuManager:set_need_tip_flag(true)
		end
	end

end

---------------------------------------------------------------------------------------------------------------------------------------------
--牛牛历史记录相关
--牛牛历史记录返回
function NiuniuroomHandle:SVR_GET_HISTORY(pack)

    dump(pack, "-----牛牛历史记录返回907-----")

    local scenes   = SCENENOW['scene']
	-- if NiuniuroomScenes_name ~= scenes.name then
	-- 	return
	-- end

	if pack ~= nil then
	    SCENENOW["scene"]:onNetHistory(pack)
	else
		print("=====NiuniuroomHandle:SVR_GET_HISTORY-----------------------is nil ")
	end

end


---------------------------------------------------------------------------------------------------------------------------------------------
--其他操作
-- 重置牌
function NiuniuroomHandle:resetUserCards()
	if bm.Room.UserCards then
		for _,card_tbl in pairs(bm.Room.UserCards)do
			if card_tbl ~= nil then
				for i,card in pairs(card_tbl) do
					if card ~= nil then
						card:removeSelf()
					end
				end
			end
		end
	end
	bm.Room.UserCards = {}
end
--重置
function NiuniuroomHandle:cardInit()

	dump("", "-----牛牛重置界面-----")

	local scenes   = SCENENOW['scene']
	-- if NiuniuroomScenes_name ~= scenes.name then
	-- 	return
	-- end

	scenes:set_send_ready_flag(false)

	if scenes.isspectator == false then
	-- 显示是否要继续的界面
    	scenes:show_over_layout(true)

    	local niu_panel = scenes._scene:getChildByName("niu_tip")
		local youniu_btn = niu_panel:getChildByName("btn_youniu")
		local meiniu_btn = niu_panel:getChildByName("btn_meiniu")
		youniu_btn:setVisible(false)
		meiniu_btn:setVisible(false)

	end

	for index = 0,4 do
		printInfo(index)
		local niuniu_tip = scenes._scene:getChildByName("niuniu_txt"..tostring(index))
		if niuniu_tip ~= nil then
			niuniu_tip:removeSelf()
		end

		scenes:show_zuang(index,false)

		scenes:remove_bei_txt(index)
	end

	scenes:show_niu_tip(false)


	-- for uid,seat in pairs(bm.Room.User) do
	-- 	if bm.Room.UserCards[uid] then
	self:resetUserCards()
	-- end

	if bm.User.Cards and table.getn(bm.User.Cards) then
		for i,card in pairs(bm.User.Cards) do
			card:removeSelf()
		end
	end

	bm.Room.Sendlasrcard = false
	bm.playTime = nil
	bm.playStop = nil
	bm.addTime  = nil
	bm.addStop  = nil
	bm.qiangTime = nil
	bm.qiangStop = nil
	bm.ReadyTime = nil
	bm.ReadyStop = nil

	bm.Room.is_send_card = 0
	
	bm.runScene.leave_style = 0

end


function NiuniuroomHandle:BROADCAST_USER_IP(pack)
	local data = pack.playeripdata
	dump(data, "BROADCAST_USER_IP NiuniuroomHandle", nesting)
	for k,v in pairs(data) do
		require("hall.GameData"):setUserIP(v["uid"], v["ip"])
		if v.uid == tonumber(UID) then
			require("hall.view.userInfoView.userInfoView"):sendUserPosition(v.ip)
		end
	end
end

return NiuniuroomHandle