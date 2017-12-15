
--麻将用到的发送socket请求方法
local MajiangroomServer  = require("xl_majiang.scenes.MajiangroomServer")
--local MajiangroomHandle  = require("majiang.scenes.MajiangroomHandle")

--麻将牌类
local Majiangcard        = require("xl_majiang.card.Majiangcard")

--麻将动画类
local MajiangroomAnim  = require("xl_majiang.scenes.MajiangroomAnim")

--麻将协议
local PROTOCOL = import("xl_majiang.scenes.Majiang_Protocol")

--麻将公用界面方法
local mjSetting = require("xl_majiang.setting_help")

--定义麻将界面
local MajiangroomScenes  = class("MajiangroomScenes", function()
    return display.newScene("MajiangroomScenes")
end)

local sum_tick_time = 30

local sum_check_network = 10

local game_state = 0  --0等待，1准备，2换牌，3选缺，4打牌，5胡牌，6游戏结束

local invite_ly

local disband_ly

function MajiangroomScenes:ctor()
	print("initScne")

	_G.runScene = self;
--    _G.runScene:retain()

	--获取麻将游戏界面
	local view = cc.CSLoader:createNode("xl_majiang/scens/room.csb"):addTo(self)
	self._scene = view

	--房间信息
	local gameConfig_tt = self._scene:getChildByName("gameConfig_tt")
	gameConfig_tt:setVisible(true)
	gameConfig_tt:setString(USER_INFO["gameConfig"])

	--房间信息
	local left_card_num = self._scene:getChildByName("left_card_num")
	left_card_num:setVisible(false)

	--麻将牌显示区域
	self.layer_new = view:getChildByName("layer_card")

	--返回按钮
	local game_back_bt = self._scene:getChildByName("game_back_bt")
	game_back_bt:addTouchEventListener(
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
		                		require("hall.GameTips"):showTips("提示", "tohall", 1, "你正在房间中，是否返回大厅？")
		                		
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

	--用户资料区域
	--我
	local Panel_me = self._scene:getChildByName("Panel_me")
	--右
	local Panel_right = self._scene:getChildByName("Panel_right") 
	--左
	local Panel_left = self._scene:getChildByName("Panel_left")
	--上
	local Panel_top = self._scene:getChildByName("Panel_top") 
	Panel_me:setVisible(true)
	Panel_right:setVisible(false)
	Panel_left:setVisible(false)
	Panel_top:setVisible(false)

	--当前游戏名
	local score_base_tip = self._scene:getChildByName("score_base_tip")
    score_base_tip:setVisible(false)
    local score_base_txt = self._scene:getChildByName("score_base_txt")
    score_base_txt:setVisible(false)

    --邀请微信好友
    invite_ly = self._scene:getChildByName("invite_ly")
    invite_ly:addTouchEventListener(
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

            	local config_arr = LuaSplit(USER_INFO["gameConfig"], " ")
            	dump(config_arr, "-----share_content-----")
            	local share_content = ""
            	for k,v in pairs(config_arr) do
            		if v ~= "" then
            			share_content = share_content .. v .. ","
            		end
            	end
            	share_content = string.sub(share_content, 1, string.len(share_content) - 1)
            	
            	require("hall.common.ShareLayer"):showShareLayer("血流成河，房号：" .. USER_INFO["invote_code"], "https://a.mlinks.cc/AK3b", "url", share_content)
            
            end
        end
    )

    --解散房间按钮
	disband_ly = self._scene:getChildByName("disband_ly")
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

            	self:disbandGroup()

            end
        end
    )

	--准备按钮（现在不需要，全部自动准备）
	local ready_btn_right = self._scene:getChildByName("ready_btn_right")
	local ready_btn_top = self._scene:getChildByName("ready_btn_top")
	local ready_btn_left = self._scene:getChildByName("ready_btn_left")
	local ready_btn_me = self._scene:getChildByName("ready_btn_me")
	ready_btn_right:setVisible(false)
	ready_btn_top:setVisible(false)
	ready_btn_left:setVisible(false)
	ready_btn_me:setVisible(false)

	--设置按钮
	local btn_setting = self._scene:getChildByName("btn_setting")
	-- btn_setting:setVisible(false)
	btn_setting:addTouchEventListener(
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

            	local disband_action = function(sender,event)
            	
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

	                    require("hall.GameCommon"):showSettings(false)

	                    require("xl_majiang.scenes.MajiangroomScenes"):disbandGroup()

	                end
	            end

            	require("hall.GameCommon"):showSettings(true,false,true,true,disband_action)

            end
        end
    )

    --录像按钮
	local btn_record = self._scene:getChildByName("btn_record")
	btn_record:setVisible(true)
	btn_record:addTouchEventListener(
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

            	-- local a = {}
            	-- a.x = self.layer_new:getContentSize().width / 2
            	-- a.y = self.layer_new:getContentSize().height / 2

            	-- local b = {}
            	-- b.width = 264.44
            	-- b.height = 218.52

            	-- require("hall.recordUtils.RecordUtils"):showRecordFrame(a, b, 0)

            	require("hall.recordUtils.RecordUtils"):showRecordFrame(cc.p(480, 270), cc.size(264, 218), USER_INFO["activity_id"])

            end
        end
    )

    --文字聊天界面
    local faceUI = require("hall.FaceUI.faceUI")
    local sendHandle = require("xl_majiang.scenes.MajiangroomServer")
    local faceUI_node = faceUI.new();
    faceUI_node:setHandle(sendHandle)
    self:addChild(faceUI_node, 9999)
    faceUI_node:setName("faceUI")

    --聊天按钮
    local btn_msg = self._scene:getChildByName("btn_msg")
	btn_msg:setVisible(true)
	btn_msg:addTouchEventListener(
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

            	local pos = sender:getPosition()
    			faceUI_node:showTxtPanle(pos,8)

            end

        end
    )

	self:init_layout_widget()

	local function update(dt)
		self:update_30(dt)
        --self:updateDrawCoin(dt)
    end

    self:scheduleUpdateWithPriorityLua(update,0)

    self:set_show_chat_layout(false)
    self:set_show_chat_btn(true)
    self:set_show_chat_btn(false)

    self:set_over_layout(false)
 
    --换牌确认按钮
    local btn_huan_ok = self._scene:getChildByName("Button_11")
	local btn_huan_Canle = self._scene:getChildByName("Button_11_0")
	btn_huan_ok:hide()
	btn_huan_Canle:hide();
	btn_huan_ok:onClick(function()
			local tb = {} 
			for k,v in pairs(bm.Room.cardHuan) do
				table.insert(tb,v.value_)
			end
			require("xl_majiang.scenes.MajiangroomServer"):send_Huan_card(tb)
			btn_huan_ok:hide()
			btn_huan_Canle:hide();
			self:show_Text_18(false)
		end)
	btn_huan_Canle:onClick(function()
			for k,v in pairs(bm.Room.cardHuan) do
				v:setPositionY(50.00);

				--table.removebyvalue(bm.Room.cardHuan,v)
			end
			bm.Room.cardHuan={};
			btn_huan_ok:hide()
			btn_huan_Canle:hide();
			self:show_Text_18(false)
		end)

	self:show_Text_18(false)

	self:enableAuto(false)

	self:show_invote()

	--发送用户准备
	-- self:gameReady()

end

--隐藏邀请微信好友按钮
function MajiangroomScenes:hidendinvite()

	invite_ly:setVisible(false)

end

--隐藏解散房间按钮
function MajiangroomScenes:hidendisband()

	disband_ly:setVisible(false)

end

--解散房间
function MajiangroomScenes:disbandGroup()

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
					require("hall.GameTips"):showDisbandTips("解散房间", "disbandGroup", 1, "当前解散房间不需扣除房卡，是否解散？")

            	elseif data == 2 then
            		--开始组局
            		require("hall.GameTips"):showDisbandTips("解散房间", "disbandGroup", 1, "当前已经扣除房卡，是否申请解散房间？")
            		
            	elseif data == 0 then
            		--结束组局
            		require("hall.GameTips"):showTips("提示", "tohall", 1, "当前组局已结束，是否返回大厅？")

            	end
            else
            		
            end

 		end
	})

end

--显示组局邀请码（房间号）
function MajiangroomScenes:show_invote()

	dump(USER_INFO["invote_code"], "-----显示组局邀请码-----")
	local room_id = self._scene:getChildByName("room_id")
	room_id:setString(USER_INFO["invote_code"])

end

--显示设置按钮
function MajiangroomScenes:ShowSettingButton()
	local btn_setting = self._scene:getChildByName("btn_setting")
	btn_setting:setVisible(true)

	local btn_record = self._scene:getChildByName("btn_record")
	btn_record:setVisible(true)

end

function MajiangroomScenes:gameReady()

	local ready_btn = self._scene:getChildByName("ready_me_btn")
	ready_btn:setVisible(false)
	MajiangroomServer:readyNow()
	
end

function MajiangroomScenes:update_30(dt)

	sum_tick_time = sum_tick_time+dt
	sum_check_network = sum_check_network + dt

	-- if sum_check_network > 10 then
	-- 	self:check_network()--每隔10秒检查下网络
	-- 	sum_check_network = 0
	-- end

    if sum_tick_time > 30 then
    	
		local time_str = self._scene:getChildByName("Text_time")
		if time_str ~= nil then
	        local time = os.date("%H:%M", os.time())
	        time_str:setString(time)
	        time_str:setColor(cc.c3b(159,127,86))
	        time_str:enableOutline(cc.c4b(159,127,86,255),2)
		end
		sum_tick_time = 0
	end

end


function MajiangroomScenes:onEnter()
	self:show_version_tip()
	-- self:check_network()
end

--显示“等待其他玩家选择定缺花色...。。。。。”
function MajiangroomScenes:showwaitingotherchoose( flag )
	local waiting_queing_45 = self._scene:getChildByName("waiting_queing_45")
	waiting_queing_45:setVisible(flag)
end

--显示剩余牌数 
function MajiangroomScenes:show_less_base_card(flag)

	if self._scene == nil then
		return
	end

	if flag == false then
		self._scene:removeChildByName("less_card_num")

	elseif  flag == true then
		local wait_bar = display.newNode()
		wait_bar:setName("less_card_num")

		local base = display.newSprite()
		base:addTo(wait_bar)

		local label = display.newTTFLabel({text = "剩余：30 张",font = "Arial",size = 20,color = cc.c3b(127,219,150),align = cc.TEXT_ALIGNMENT_CENTER})
		label:setName("str_lab")
		label:addTo(wait_bar)

		wait_bar:pos(480,245.42)
		wait_bar:addTo(self._scene)
	end

end

--设置剩余牌数 
function MajiangroomScenes:set_less_card_num( num )

	if self._scene == nil then
		return
	end
	num = num or 0

	local  wait_bar = self._scene:getChildByName("less_card_num")
	local strbase = wait_bar:getChildByName("str_lab")

	strbase:setString("剩余：".. tostring(num) .." 张")

end

--可以托管
function MajiangroomScenes:enableAuto(flag)
	-- body
	-- local panle = self._scene:getChildByName("Panel_tuoguan")
	-- local ren = panle:getChildByName("ren")
	-- local quxiaotuoguan = panle:getChildByName("quxiaotuoguan")
	-- local tuo = panle:getChildByName("tuo")
	-- panle:setVisible(flag)

	-- ren:setVisible(not flag)
	-- quxiaotuoguan:setVisible(not flag)
	-- tuo:setVisible(flag)

	local panle = self._scene:getChildByName("Panel_tuoguan")
	panle:setVisible(false)
	
end

--显示托管
function MajiangroomScenes:show_tuoguan_layout( flag )
	-- if flag then
	-- 	local panle = self._scene:getChildByName("Panel_tuoguan")
	-- 	local ren = panle:getChildByName("ren")
	-- 	local quxiaotuoguan = panle:getChildByName("quxiaotuoguan")
	-- 	local tuo = panle:getChildByName("tuo")
	-- 	panle:setVisible(true)

	-- 	ren:setVisible(true)
	-- 	quxiaotuoguan:setVisible(true)
	-- 	tuo:setVisible(false)

	-- 	quxiaotuoguan:onClick(function()
	-- 		MajiangroomServer:cancelTuo(0)
	-- 		end)
	-- else
	-- 	local panle = self._scene:getChildByName("Panel_tuoguan")
	-- 	local ren = panle:getChildByName("ren")
	-- 	local quxiaotuoguan = panle:getChildByName("quxiaotuoguan")
	-- 	local tuo = panle:getChildByName("tuo")

	-- 	panle:setVisible(true)

	-- 	ren:setVisible(false)
	-- 	quxiaotuoguan:setVisible(false)
	-- 	tuo:setVisible(true)

	-- 	tuo:onClick(function()
	-- 			MajiangroomServer:cancelTuo(1)
	-- 		end)
	-- end

	local panle = self._scene:getChildByName("Panel_tuoguan")
	panle:setVisible(false)

end

--显示“已准备”标签
function MajiangroomScenes:show_already_bar(player_index,show_flag)
	-- body
	if self._scene == nil or show_flag == nil then
		return
	end
	local already_image = nil 

	if player_index == 1 then
		already_image = self._scene:getChildByName("ready_image_left")
	elseif player_index == 2 then
		already_image = self._scene:getChildByName("ready_image_top")
	elseif player_index == 3 then
	 	already_image = self._scene:getChildByName("ready_image_right")
	elseif player_index == 0 then
		already_image = self._scene:getChildByName("ready_image_me")
	end

	if already_image ~= nil then 
		already_image:setVisible(show_flag)
	end
end

--显示“准备”标签
function MajiangroomScenes:show_ready_bar(player_index,show_flag)
	-- body
	if self._scene == nil or show_flag == nil then
		return
	end
	local already_image = nil 

	if player_index == 1 then
		already_image = self._scene:getChildByName("ready_btn_left")
	elseif player_index == 2 then
		already_image = self._scene:getChildByName("ready_btn_top")
	elseif player_index == 3 then
	 	already_image = self._scene:getChildByName("ready_btn_right")
	elseif player_index == 0 then
	 	already_image = self._scene:getChildByName("ready_me_btn")
	end

	if already_image ~= nil then 
		already_image:setVisible(show_flag)
	end
end

--开始游戏时需要隐藏自身的一些东西，在这里处理
function  MajiangroomScenes:hide_self_info()

	local panel = self._scene:getChildByName("Panel_me")

	if panel == nil then
		return
	end

	-- local spMoney = panel:getChildByName("btn_recharge")
	-- local Text_1 = panel:getChildByName("Text_1")
	-- local sex = panel:getChildByName("sex")

	-- spMoney:setVisible(false) --moeny
	--Text_1:setVisible(false) --nick
	-- sex:setVisible(false) --sex

	--开始移动
	local p = cc.p(19.00,167.00)
	local action_move = cc.MoveTo:create(1,p)
	local action_scale = cc.ScaleTo:create(0.77, 0.75)
	local sum_action = cc.Spawn:create(action_move,action_scale)
	panel:runAction(sum_action)

	-- --金币移动
	-- local mt = cc.MoveTo:create(1,cc.p(160,-70))
	-- if spMoney then
	-- 	spMoney:runAction(mt)
	-- end

end

--开始游戏时需要移动其他玩家的信息显示位置
function  MajiangroomScenes:hide_otherplayer_info( index )

	local action_move
	local action_scale
	local sum_action
	local p = cc.p(0,0)
	local panel = nil
	if index == 1 then
		--左
		panel = self._scene:getChildByName("Panel_left")
		p = cc.p(27.10, 384.55)
		action_move = cc.MoveTo:create(1,p)
		action_scale = cc.ScaleTo:create(0.76,0.76)

	elseif index == 2 then
		--对家
		panel = self._scene:getChildByName("Panel_top")
		p = cc.p(185.60, 515.81)
		action_move = cc.MoveTo:create(1,p)
		action_scale = cc.ScaleTo:create(0.76,0.76)

	elseif index  == 3 then
		--右
		panel = self._scene:getChildByName("Panel_right")
		p = cc.p(848.35, 386.23)
		action_move = cc.MoveTo:create(1,p)
		action_scale = cc.ScaleTo:create(0.77,0.77)
	end

	--开始移动
	sum_action = cc.Spawn:create(action_move,action_scale)
	panel:runAction(sum_action)

	-- if panel ~= nil then
	-- 	-- local Text_2 = panel:getChildByName("Text_2")
	-- 	-- local Text_1 = panel:getChildByName("Text_1")
	--  --    local Sprite_37 = panel:getChildByName("Sprite_37")
	-- 	-- local sex = panel:getChildByName("sex")

	-- 	-- Text_2:setVisible(false)
	-- 	-- --Text_1:setVisible(false)
	-- 	-- Sprite_37:setVisible(false)
	-- 	-- sex:setVisible(false)
	-- end

end

--获取用户播放录音位置
function MajiangroomScenes:getPosforSeat(uid)
	return bm.Room.ShowVoicePosion[uid]
end

--显示时间
function MajiangroomScenes:show_time_bar(flag)
	if self._scene == nil then
		return
	end

	local Text_time = self._scene:getChildByName("Text_time")
	local time_base = self._scene:getChildByName("time_base")
	Text_time:setVisible(false)
	time_base:setVisible(false)
end

--设置时间
function MajiangroomScenes:show_time_number(time_num)
	if self._scene == nil then
		return
	end

	local time_base = self._scene:getChildByName("Text_time")
	time_base:setString(tostring(time_num))

end

--显示自身的信息
function MajiangroomScenes:set_ower_info(icon_url,nick_str,gold_num_str,sex_num)

	if self._scene == nil then
		return
	end

	--获取显示自己信息的布局
	local panel_me = self._scene:getChildByName("Panel_me")
	if panel_me == nil then
		return
	end

	--用户昵称
	local nick = panel_me:getChildByName("Text_1") 
	nick:setString(require("hall.GameCommon"):formatNick(nick_str))

	--用户积分
	local gold_num = panel_me:getChildByName("txt_score")
	gold_num:setString(gold_num_str)

	--用户头像
	local head_im = panel_me:getChildByName("Image_3")
	require("hall.GameCommon"):getUserHead(icon_url, UID, sex_num, head_im, 69, false)

    --用户性别
	local sex_spr = panel_me:getChildByName("sex")
	sex_spr:setVisible(false)
	if sex_num == 1 then
		sex_spr:setTexture("xl_majiang/image/nan.png")
	else
		sex_spr:setTexture("xl_majiang/image/nv.png")
	end

end

--显示其他玩家来后信息
function MajiangroomScenes:show_otherplayer_info(other_index,icon_url,nick_name,user_gold,sex_num,uid)

	if self._scene == nil then
		return
	end

	--获取对应座位显示用户信息的布局
	local panel = nil
    if other_index == 1 then
    	panel = self._scene:getChildByName("Panel_left")
    elseif other_index == 2 then
    	panel = self._scene:getChildByName("Panel_top")
    elseif other_index == 3 then
    	panel = self._scene:getChildByName("Panel_right")
    end

    if panel ~= nil then

    	--显示布局
    	panel:setVisible(true)

    	--用户昵称
    	local nick = panel:getChildByName("Text_1") 
		nick:setString(require("hall.GameCommon"):formatNick(nick_name))

		--用户积分
		local coin_num = panel:getChildByName("Text_2") 
		coin_num:setString(user_gold)

		--用户头像
		local head_im = panel:getChildByName("Image_3") 
		require("hall.GameCommon"):getUserHead(icon_url, UID, sex_num, head_im, 69, false)

		--用户性别
		local sex_spr = panel:getChildByName("sex") 
		sex_spr:setVisible(false)
		if sex_num == 1 then
			sex_spr:setTexture("xl_majiang/image/nan.png")
		else
			sex_spr:setTexture("xl_majiang/image/nv.png")
		end

    end
end


function MajiangroomScenes:show_widget_tip(palyer_index,flag,widget_name,file_name,file_rect,scale)

	local panel = nil
	if palyer_index == 0 then
		panel = self._scene:getChildByName("Panel_me")
		--如果我不按下选缺，那么这个选缺的界面会一直存在，这里做隐藏
		self:show_choosing_que(false)
	elseif palyer_index == 1 then
		panel = self._scene:getChildByName("Panel_left")
	elseif palyer_index == 2 then
		panel = self._scene:getChildByName("Panel_top")
	elseif palyer_index == 3 then
		panel = self._scene:getChildByName("Panel_right")
	end

	if panel ~= nil then
		local zuan_tip = panel:getChildByName(widget_name)
		zuan_tip:setVisible(flag)

		if flag == true and file_name then
			zuan_tip:setTexture(file_name)
			-- zuan_tip:setTextureRect(file_rect)
		end

		-- if scale ~= nil then
		-- 	zuan_tip:setScale(scale)
		-- end

	end

end

function MajiangroomScenes:init_layout_widget()

	--庄标志
	self:show_widget_tip(0,false,"zuan_tip")
	self:show_widget_tip(1,false,"zuan_tip")
	self:show_widget_tip(2,false,"zuan_tip")
	self:show_widget_tip(3,false,"zuan_tip")

	--选的缺牌标志
	self:show_widget_tip(0,false,"que_tip")
	self:show_widget_tip(1,false,"que_tip")
	self:show_widget_tip(2,false,"que_tip")
	self:show_widget_tip(3,false,"que_tip")

	--记录已经选缺
	self.has_select = {}
	self.has_select[0] = false
	self.has_select[1] = false
	self.has_select[2] = false
	self.has_select[3] = false 

	--已经准备标志显示位置
	self:show_hasselect(0,false)
	self:show_hasselect(1,false)
	self:show_hasselect(2,false)
	self:show_hasselect(3,false)

	--其他用户选缺
	self:show_other_xuanqueing(false)

	--
	self:show_Text_18(false)

	--选缺
	self:show_choosing_que(false)

	--等待选择
	self:showwaitingotherchoose(false)

	--托管区域
	self:show_tuoguan_layout(false)

	--计时器
	self:show_timer_visible(false)

end

--设置用户的准备标志显示
function MajiangroomScenes:show_hasselect(palyer_index,flag)

	dump(palyer_index, "-----设置用户的准备标志显示-----")

	--定义准备标志
	local widget_icon = nil
	--获取准备标志
	if palyer_index == 0 then
		widget_icon = self._scene:getChildByName("has_select_0")
	elseif palyer_index == 1 then
		widget_icon = self._scene:getChildByName("has_select_1")
	elseif palyer_index == 2 then
		widget_icon = self._scene:getChildByName("has_select_2")
	elseif palyer_index == 3 then
		widget_icon = self._scene:getChildByName("has_select_3")
	end
	--缓存准备标志
	self.has_select[palyer_index] = flag

	if widget_icon ~= nil then
		widget_icon:setVisible(flag)
	end

end

--隐藏所有用户的准备标志
function MajiangroomScenes:hideAllSelect()

	local has_select_0 = self._scene:getChildByName("has_select_0")
	has_select_0:setVisible(false)

	local has_select_1 = self._scene:getChildByName("has_select_1")
	has_select_1:setVisible(false)

	local has_select_2 = self._scene:getChildByName("has_select_2")
	has_select_2:setVisible(false)

	local has_select_3 = self._scene:getChildByName("has_select_3")
	has_select_3:setVisible(false)

end


function MajiangroomScenes:check_all_select()
	if self.has_select[0] == true
	and self.has_select[1] == true
	and self.has_select[2] == true
	and self.has_select[3] == true then
	return true
	end

	return false 
end

function MajiangroomScenes:set_basescole_txt(base)

    local score_base_txt = self._scene:getChildByName("score_base_txt")
    score_base_txt:setString(base)
    score_base_txt:setVisible(false)

end

function MajiangroomScenes:set_basescole_txt_visible(flag)
	local score_base_txt = self._scene:getChildByName("base_txt_ex")
    score_base_txt:setVisible(flag)

	local score_base_tip = self._scene:getChildByName("score_base_tip")
    -- score_base_tip:setVisible(flag)
    score_base_tip:setVisible(false)

end

function MajiangroomScenes:set_player_visible(index,flag)
	if index == 0 then
		local Panel_me = self._scene:getChildByName("Panel_me")
		Panel_me:setVisible(flag)
	elseif index == 1 then
		local Panel_me = self._scene:getChildByName("Panel_left") 
		Panel_me:setVisible(flag)
	elseif index == 2 then
		local Panel_me = self._scene:getChildByName("Panel_top") 
		Panel_me:setVisible(flag)
	elseif index == 3 then
		local Panel_me = self._scene:getChildByName("Panel_right") 
		Panel_me:setVisible(flag)
	end
end

function MajiangroomScenes:set_left_card_num_visible(falg,num_str)

	local left_card_num = self._scene:getChildByName("left_card_num")
	if falg == true then
		left_card_num:setString(num_str  .. "  第 " .. tostring(bm.round) .. "/" .. tostring(bm.round_total) .. " 局")
	end
	left_card_num:setVisible(falg)

end

function MajiangroomScenes:set_left_card_num(num)
	local left_num = self._scene:getChildByName("left_num_card")
	if left_num == nil then
		self:set_left_card_num_visible(true,"剩余牌数: "..tostring(num))
	else
		left_num:setString("剩余牌数: "..tostring(num))
	end
end

--获取自己碰杠胡标志显示位置
function MajiangroomScenes:gettimerpos()
	--local center_tab = self._scene:getChildByName("center_tab")
	local x = 467.28
	local y = 168.11

	return x,y
end

function MajiangroomScenes:onExit()
	--audio.stopMusic()
end

function MajiangroomScenes:set_show_chat_layout(visible_falg)
	local chat_layout = self._scene:getChildByName("chat_layout")
	chat_layout:setVisible(visible_falg)
end

function MajiangroomScenes:show_chat_layout()
	local chat_layout = self._scene:getChildByName("chat_layout")
	chat_layout:setVisible(true)

	local ListView= chat_layout:getChildByName("ListView_txt")
	local item_base = chat_layout:getChildByName("item_base")
	

	local str_list = {
	"hello,chat",
	"hello,world",
	"hello,tao",
	}
    local function listViewEvent(sender, eventType)
    	--print(".................index_rec...................",sender, eventType)

    	if eventType == 0 then

    	elseif eventType == 1 then
    		local index_rec = sender:getCurSelectedIndex()
    		print("index_rec------------------",index_rec,"---------------",str_list[index_rec+1])

    		local input_txt = chat_layout:getChildByName("input_txt")
        	input_txt:setString(str_list[index_rec+1]) 
    	end

    	--print((sender))
      --   if eventType == ccui.ListViewEventType.ons_selected_item then
      --   	local index_rec = sender:getCurSelectedIndex()
    		-- print(".................index_rec...................",index_rec)
      --       -- local rec_txt = str_list[index_rec] or ""


      --   end
    end
	ListView:addEventListener(listViewEvent)


	for index,str in pairs(str_list)do
		local base = item_base:clone()
		base:setTouchEnabled(true)

		local list_item = base:getChildByName("list_item")
		list_item:setString(str)
		ListView:addChild(base)
	end


	--点击发送消息
	local function send_fun( )
		-- body
		local input_txt = chat_layout:getChildByName("input_txt")
		local txt = input_txt:getString()

		if txt ~= nil or txt ~= "" then
			MajiangroomServer:send_chat_msg(txt)
		end

	end  

	local send_btn = chat_layout:getChildByName("send_btn")
	send_btn:onClick(send_fun)

	self:set_show_chat_btn(false)
end

function MajiangroomScenes:set_show_chat_btn(visible_falg)
	local chat_btn = self._scene:getChildByName("chat_btn")
    chat_btn:setVisible(visible_falg)

    if visible_falg == true then
    	chat_btn:onClick(function ( ... )
    		-- body
    		self:show_chat_layout()
    	end)
    end
end

function MajiangroomScenes:set_over_layout(flag)
	-- body
	if flag == false then
		local over_layout = self:getChildByName("layer_over")
		if over_layout ~= nil then
			over_layout:removeSelf()
		end

	end

	if flag == true then
		local view            = cc.CSLoader:createNode("xl_majiang/scens/layer_over.csb"):addTo(self)
		view:setName("layer_over")
		view:setLocalZOrder(60)

		local over_layout = view:getChildByName("over_layout")
		local continue_btn = over_layout:getChildByName("jixu")
		local leave_btn =  over_layout:getChildByName("likai")
		continue_btn:onClick(function ( ... )
			-- body
			--登陆房间
		    -- if bm.isGroup then
    		if require("hall.gameSettings"):getGameMode() == "group" then
				require("xl_majiang.majiangServer"):LoginGame(USER_INFO["GroupLevel"] or 37)
			else
				require("xl_majiang.majiangServer"):LoginGame(bm.nomallevel)
		    end
		end)
		leave_btn:onClick(function ( ... )
				-- body
				--bm.display_scenes("xl_majiang.gameScenes")
				MajiangroomServer:quickRoom()
			end)
	end
end

--设置玩家金币数量
function MajiangroomScenes:set_player_gold(index,gold_num)

	local panel = nil
	if index == 0 then
	 	panel= self._scene:getChildByName("Panel_me")
	elseif index == 1 then
    	panel = self._scene:getChildByName("Panel_left")
    elseif index == 2 then
    	panel = self._scene:getChildByName("Panel_top")
    elseif index == 3 then
    	panel = self._scene:getChildByName("Panel_right")
    end

    if index == 0 then
    	local gold = panel:getChildByName("btn_recharge"):getChildByName("txt_score")
		gold:setString(gold_num)
		local mode = require("hall.gameSettings"):getGameMode()
		if mode == "free" then
			USER_INFO["gold"]=gold_num
		elseif mode == "group" then
			USER_INFO["chip"]=gold_num
		end
    else
        local gold = panel:getChildByName("Text_2")
		gold:setString(gold_num)
    end


end

function MajiangroomScenes:goldUpdate()
	-- if bm.isGroup  then --
    if require("hall.gameSettings"):getGameMode() == "group" then
		USER_INFO["base_chip"]=bm.Room.base;
		require("xl_majiang.gameScene"):showTimer(bm.GroupTimer)

		require("xl_majiang.gameScene"):checkChip(scenes)
	else
		self:set_player_gold(0,USER_INFO["gold"])
	end
end


function MajiangroomScenes:show_version_tip()
	-- local version_str = require("hall.GameData"):getGameVersion("majiang")
	-- local lbVersion = cc.Label:createWithTTF("version:"..version_str, "fonts/fzcy.ttf", 18)
	-- self:addChild(lbVersion,888)
	-- lbVersion:setColor(cc.c3b(255,127,39))
	-- lbVersion:setPosition(cc.p(lbVersion:getContentSize().width/2,lbVersion:getContentSize().height/2))
end


function MajiangroomScenes:check_network()
	
	
	--print("..........cc.kCCNetworkStatusNotReachable......net_state....",cc.kCCNetworkStatusNotReachable,"----",net_state)

	local targetPlatform = cc.Application:getInstance():getTargetPlatform()
	if  cc.PLATFORM_OS_WINDOWS  ~= targetPlatform then

		local net_state = network.getInternetConnectionStatus()
		if cc.kCCNetworkStatusNotReachable == net_state  then
			-- 创建一个居中对齐的文字显示对象

			if self:getChildByName("net_state") == nil then
				local label = cc.Label:createWithTTF("无法访问互联网", "fonts/fzcy.ttf", 32)
				self.layer_new:addChild(label, 2000)
				label:setColor(cc.c3b(255,0,0))
				label:setPosition(cc.p(480,300))
				label:setName("net_state")
			end
		else
			if self:getChildByName("net_state") ~= nil then
				display_scene("hall.hallScene")
			end
		end
	end
end

function MajiangroomScenes:HttpResponseCallBack(parent)

end


function MajiangroomScenes:send_extract(total_num,num)
	--调用豪哥方法
	require("hall.HttpSettings"):quickGameExtract(4,total_num,num)
end

--选缺
function MajiangroomScenes:show_choosing_que(flag)

	local Panel_quetbl = self._scene:getChildByName("Panel_quetbl")
	Panel_quetbl:setVisible(flag)

	if flag == false then
		return
	end

	local wang = Panel_quetbl:getChildByName("Button_1")
	local tiao = Panel_quetbl:getChildByName("Button_2")
	local tong = Panel_quetbl:getChildByName("Button_3")

    --提示门bm.User.Pque
	print("bm.User.Pque------------------------------", bm.User.Pque)
	local bShowLight = 0
	bm.SchedulerPool:loopCall(function()

		if tolua.isnull(wang) then
			return false
		end

		if tolua.isnull(tong) then
			return false
		end

		if tolua.isnull(tiao) then
			return false
		end

		if bShowLight == 1 then

			if bm.User.Pque == 0 then
				wang:getChildByName("Image_6"):loadTexture("xl_majiang/image/mahjong_wan_bt_s.png")
			elseif bm.User.Pque == 1 then
				tong:getChildByName("Image_6"):loadTexture("xl_majiang/image/mahjong_tong_bt_s.png")
			elseif bm.User.Pque == 2 then
				tiao:getChildByName("Image_6"):loadTexture("xl_majiang/image/mahjong_suo_bt_s.png")
			end
			
		else
			
			if bm.User.Pque == 0 then
				wang:getChildByName("Image_6"):loadTexture("xl_majiang/image/mahjong_wan_bt.png")
			elseif bm.User.Pque == 1 then
				tong:getChildByName("Image_6"):loadTexture("xl_majiang/image/mahjong_tong_bt.png")
			elseif bm.User.Pque == 2 then
				tiao:getChildByName("Image_6"):loadTexture("xl_majiang/image/mahjong_suo_bt.png")
			end

		end
		bShowLight = 1 - bShowLight

		return true

	end, 0.2)

	--万
	wang:addTouchEventListener(
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

                require("hall.GameCommon"):playEffectSound(audio_path,false)
				MajiangroomServer:choiceQue(0)

				if self:check_all_select() == false then
					self:showwaitingotherchoose(true)
				end

				self:show_choosing_que(false)

            end
        end
    )

	--筒
	tong:addTouchEventListener(
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

                require("hall.GameCommon"):playEffectSound(audio_path,false)
				MajiangroomServer:choiceQue(1)

				if self:check_all_select() == false then
					self:showwaitingotherchoose(true)
				end
				
				self:show_choosing_que(false)

            end
        end
    )

	--条
	tiao:addTouchEventListener(
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

                require("hall.GameCommon"):playEffectSound(audio_path,false)
				MajiangroomServer:choiceQue(2)

				if self:check_all_select() == false then
					self:showwaitingotherchoose(true)
				end

				self:show_choosing_que(false)

            end
        end
    )

end


function MajiangroomScenes:show_other_xuanqueing(flag)
	local Panel_queing = self._scene:getChildByName("Panel_queing")
	Panel_queing:setVisible(flag)

end

function MajiangroomScenes:show_other_xuanqueing_index(index,flag)
	if index == 0 then
		return
	end

	local Panel_queing = self._scene:getChildByName("Panel_queing")
	local child_icon = Panel_queing:getChildByName("queing"..tostring(index))
	child_icon:setVisible(flag)

	self:enableAuto(true)

end

--显示换牌提示及倒计时
function MajiangroomScenes:show_Text_18(flag)

	local Text_18 = self._scene:getChildByName("Text_18")
	Text_18:setVisible(flag)

	local Panel_huaning = self._scene:getChildByName("Panel_huaning")
	Panel_huaning:setVisible(flag)

	local hpTimer_tt = self._scene:getChildByName("hpTimer_tt")
	hpTimer_tt:setString("10")
	hpTimer_tt:setVisible(flag)

end

--显示换牌倒计时
function MajiangroomScenes:showChangeCardTimer(time)
	local timmer = self._scene:getChildByName("Text_18_0")
	if tolua.isnull(timmer) == false then
		timmer:setString(time)
	end

end

function MajiangroomScenes:init_clock()
	local str = ""
	local spClock = nil
	for i = 0,3 do
		if i == 0 then
			str = "Panel_me"
		elseif i == 1 then
			str = "Panel_left"
		elseif i == 2 then
			str = "Panel_top"
		elseif i == 3 then
			str = "Panel_right" 
		end
		spClock = self._scene:getChildByName(str):getChildByName("sp_clock")
		if spClock then
			spClock:setVisible(false)
		end
	end
end

--用户区域上的计时器
function MajiangroomScenes:showClock(index,num,flag)
	-- body
	if flag == nil then
		flag = true 
	end

	--flag = flag or true

	local str = ""
	local spClock = nil
	if index == 0 then
		str = "Panel_me"
	elseif index == 1 then
		str = "Panel_left"
	elseif index == 2 then
		str = "Panel_top"
	elseif index == 3 then
		str = "Panel_right" 
	end
	spClock = self._scene:getChildByName(str):getChildByName("sp_clock")

	if spClock then
		--print("showClock    kkkk",num)
		spClock:setVisible(flag)
		local txt = spClock:getChildByName("txt_clock")
		if txt then
			txt:setString(num)
		end

		--暂时隐藏所有的用户区域的计时器
		spClock:setVisible(false)
	end

end

--旋转座位标志
function MajiangroomScenes:RotationTimmer(index)

	--index为庄位置

	--旋转标志器
	local Panel_timer = self._scene:getChildByName("Panel_timer")

	-- local BitmapFontLabel = Panel_timer:getChildByName("BitmapFontLabel_1")


	local direction_ly = Panel_timer:getChildByName("direction_ly")

	--重置标志器指向
	direction_ly:setRotation(0)

	--进行旋转（把东指向庄）
	if index == 0 then
		direction_ly:setRotation(0)
		bm.zuowei_zhuan = 0
	elseif index == 1 then
		direction_ly:setRotation(90)
		bm.zuowei_zhuan = 1
	elseif index == 2 then
		direction_ly:setRotation(180)
		bm.zuowei_zhuan = 2
	elseif index == 3 then
		direction_ly:setRotation(270)
		bm.zuowei_zhuan = 3
	end

end

--游戏座位指示
function MajiangroomScenes:show_timer_index(index)

	--index为当前出牌的位置
	dump(index, "-----当前出牌位置-----")

	--计时器显示区域
	local Panel_timer = self._scene:getChildByName("Panel_timer")
	local direction_ly = Panel_timer:getChildByName("direction_ly")

	--东
	local Sprite_0 = direction_ly:getChildByName("Sprite_0")
	--南
	local Sprite_1 = direction_ly:getChildByName("Sprite_1")
	--西
	local Sprite_2 = direction_ly:getChildByName("Sprite_2")
	--北
	local Sprite_3 = direction_ly:getChildByName("Sprite_3")

	--重置所有方向
	Sprite_0:setVisible(false)
	Sprite_1:setVisible(false)
	Sprite_2:setVisible(false)
	Sprite_3:setVisible(false)

	--显示当前出牌方向
	local Sprite
	local zuowei_zhuan = bm.zuowei_zhuan
	local new_index
	if zuowei_zhuan == 0 then
		--不进行旋转
		if index == 0 then
			new_index = 0

		elseif index == 1 then
			new_index = 3

		elseif index == 2 then
			new_index = 2

		elseif index == 3 then
			new_index = 1

		end
	elseif zuowei_zhuan == 1 then
		--顺时针转了90度
		if index == 0 then
			new_index = 1

		elseif index == 1 then
			new_index = 0

		elseif index == 2 then
			new_index = 3

		elseif index == 3 then
			new_index = 2

		end
	elseif zuowei_zhuan == 2 then
		--顺时针转了180度
		if index == 0 then
			new_index = 2

		elseif index == 1 then
			new_index = 1

		elseif index == 2 then
			new_index = 0

		elseif index == 3 then
			new_index = 3

		end
	elseif zuowei_zhuan == 3 then
		--顺时针转了270度
		if index == 0 then
			new_index = 3

		elseif index == 1 then
			new_index = 2

		elseif index == 2 then
			new_index = 1

		elseif index == 3 then
			new_index = 0

		end
	end
	Sprite = direction_ly:getChildByName("Sprite_"..tostring(new_index))
	Sprite:setVisible(true)

end

--中间计时器显示时间
function MajiangroomScenes:show_timer_num(num)

	local Panel_timer = self._scene:getChildByName("Panel_timer")
	local BitmapFontLabel_1 = Panel_timer:getChildByName("BitmapFontLabel_1")
	local cache = tonumber(num)
	if cache < 10 then
		BitmapFontLabel_1:setString("0" .. num)
		return
	end
	BitmapFontLabel_1:setString(num)

end

--设置游戏计时器显示
function MajiangroomScenes:show_timer_visible(flag)

	local Panel_timer = self._scene:getChildByName("Panel_timer")
	Panel_timer:setVisible(flag)
	
end

--0等待，1准备，2换牌，3选缺，4打牌，5胡牌，6游戏结束
function MajiangroomScenes:setGameState( state )
	-- body
	game_state = state
	if game_state == 5 then
		self:enableAuto(false)
	elseif game_state == 6 then
		self:enableAuto(false)

	end
end

function MajiangroomScenes:HttpMatchLoadBattles()
    -- body
    require("xl_majiang.MatchSetting"):setRankInfo(require("xl_majiang.ddzSettings"):getMatchLevelRankInfo(USER_INFO["gameLevel"]))
    if require("xl_majiang.MatchSetting"):getMatchState() == 1 then
        require("xl_majiang.MatchSetting"):showMatchWait(true,"xl_majiang")
    end
end

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

return MajiangroomScenes
