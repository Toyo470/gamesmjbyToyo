local RoomlevelMap    =  import("zhajinhua.pintu.RoomlevelMap")
local UiCommon        =  import("zhajinhua.common.UiCommon")
local MenjiroomServer =  import("zhajinhua.ZhajinHuaServer")
local MenjiroomView   = class("MenjiroomView", function()
    return display.newNode("MenjiroomView")
end)

local headSize = 62
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

function MenjiroomView:ctor()
	self._view   = cc.CSLoader:createNode("zhajinhua/layout/room.csb"):addTo(self)
	bm.Room.iswith = false
	bm.Room.isover = false
	--local bar    = self._view:getChildByName("Image_2")
	--底部按键
	local base_foot=self._view:getChildByName("base_foot")
	--退出
	local quit  = self._view:getChildByName("btn_exit")
	if quit then
		quit:addTouchEventListener(
			function(sender,event)
				--触摸结束
				if event == TOUCH_EVENT_ENDED then

				    -- require("hall.gameSettings"):exitRoom()
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
				                    --开始组局
				                    require("hall.GameTips"):showTips("提示", "", 2, "游戏已经开始，不能返回大厅")

				                elseif data == 0 then
				                    --创建组局
				                    -- if bm.Room and bm.Room.isStart and bm.Room.isStart == 1 then -- 开始游戏
				                    dump(bm.Room, "exit", nesting)
				                    if bm.Room and bm.Room.start_group == 1 then
				                        require("hall.GameTips"):showTips("提示", "", 2, "游戏已经开始，不能返回大厅")
				                    else
				                    	local function okCallback()
				                        	bm.notCheckReload = 1
											MenjiroomServer.CLI_QUIT_ROOM()
				                    	end
				                        require("hall.GameTips"):showTips("提示", "tohall", 1, "你正在房间中，是否返回大厅？", nil, nil, okCallback)
				                    end
				                    
				                elseif data == 2 then
				                    --结束组局
				                    require("hall.GameTips"):showTips("提示", "tohall", 1, "当前组局已结束，是否返回大厅？")
				                    bm.notCheckReload = 0
				                end
				            else
				                require("hall.GameTips"):showTips("提示", "", 2, "游戏数据异常，不能退出房间")
				            end

				        end
				    })
				end
			end
		)
	end

	--可按状态
	--一跟到底


	--比牌
	local btn = base_foot:getChildByName("bi_green")
    if btn then
		btn:setOpacity(80)
		btn:setTouchEnabled(false)
	    btn:addTouchEventListener(
	        function(sender,event)

	            --触摸结束
	            if event == TOUCH_EVENT_ENDED then
	            	print("TOUCH_EVENT_ENDED bipai")
	            	MenjiroomView:clearBipai()
					MenjiroomView:biPai()
					MenjiroomView:moveChipList()
	            end
	        end
	    )
    end

	--弃牌
	btn = base_foot:getChildByName("qi_green")
    if btn then
		btn:setOpacity(80)
		btn:setTouchEnabled(false)
	    btn:addTouchEventListener(
	        function(sender,event)
	            --触摸结束
	            if event == TOUCH_EVENT_ENDED then
					MenjiroomServer.CLI_DIU_CARD()
					MenjiroomView:clearBipai()
					MenjiroomView:moveChipList()
    				-- require("zhajinhua.view.CompareView"):showCampare(525,521,1)

	            end
	        end
	    )
    end

	--加注
	btn = base_foot:getChildByName("jia_green")
    if btn then
		btn:setOpacity(80)
		btn:setTouchEnabled(false)
	    btn:addTouchEventListener(
	        function(sender,event)

	            --触摸结束
	            if event == TOUCH_EVENT_ENDED then
			        SCENENOW["scene"].view.showJiaZhuView()
			        MenjiroomView:clearBipai()
	            end
	        end
	    )
    end
	


	--跟住
	btn = base_foot:getChildByName("gen_green")
    if btn then
		btn:setOpacity(80)
		btn:setTouchEnabled(false)
	    btn:addTouchEventListener(
	        function(sender,event)

	        	print("跟注按钮")
	            --触摸结束
	            if event == TOUCH_EVENT_ENDED then
					MenjiroomServer.CLI_GEN_CARD()
					MenjiroomView:clearBipai()
					MenjiroomView:moveChipList()
	            end
	        end
	    )
    end

	--全押
	btn = base_foot:getChildByName("quan_green")
    if btn then
		btn:setOpacity(80)
		btn:setTouchEnabled(false)
	    btn:addTouchEventListener(
	        function(sender,event)

	            --触摸结束
	            if event == TOUCH_EVENT_ENDED then
	            	print("allin")
					MenjiroomServer.CLI_BET_ALLIN()
					MenjiroomView:clearBipai()
					MenjiroomView:moveChipList()
	            end
	        end
	    )
    end

	
    --视频录制
    local btn_record = self._view:getChildByName("btn_record")
    if btn_record then
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

	                require("hall.recordUtils.RecordUtils"):showRecordFrame(cc.p(480, 270), cc.size(264, 218), USER_INFO["activity_id"])

	            end
	        end
	    )
    end

    --文字聊天界面
    local faceUI = require("hall.FaceUI.faceUI")
    local faceUI_node = faceUI.new();
    faceUI_node:setHandle(bm.server:getHandle())
    self._view:addChild(faceUI_node, 9999)
    faceUI_node:setName("faceUI")

    local btn_chat = self._view:getChildByName("btn_chat")
    if btn_chat then
    	btn_chat:setPositionY(160)
	    btn_chat:addTouchEventListener(
	        function(sender,event)

	            --触摸结束
	            if event == TOUCH_EVENT_ENDED then
            		faceUI_node:showTxtPanle(cc.p(btn_chat:getPositionX() - 400, btn_chat:getPositionY() + btn_chat:getContentSize().height/2))
	            end
	        end
	    )
    end
    --邀请好友
    --邀请微信好友
    local invite_ly = self._view:getChildByName("invite_ly")
    if invite_ly then
		invite_ly:setVisible(true)
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
	                
	                require("hall.common.ShareLayer"):showShareLayer("炸金花，房号：" .. USER_INFO["invote_code"], "https://a.mlinks.cc/AK3b", "url", share_content)
	            
	            end
	        end
	    )
    end
    local btnSetting   = self._view:getChildByName("btn_settings")
    if btnSetting then
        btnSetting:setTouchEnabled(true)
    end

    local function touchButtonEvent(sender, event)
        --缩小ui
        if event == TOUCH_EVENT_BEGAN then
            require("hall.GameCommon"):playEffectSound("zhajinhua/res/audio/Audio_Button_Click.mp3")
            local stSmall = cc.ScaleTo:create(0.1, 0.8)
            local stNormal = cc.ScaleTo:create(0.1, 1)
            local sq = cc.Sequence:create(stSmall, stNormal)
            sender:runAction(sq)
        end

        if event == TOUCH_EVENT_ENDED then
            local stBig = cc.ScaleTo:create(0.1,1.3)
            local stNormal = cc.ScaleTo:create(0.1,1)
            local sq = cc.Sequence:create(stBig,stNormal)
            sender:runAction(sq)

            if sender == btnEixt then--返回赛场选择
                sender:setScale(1.0)
                -- require("hall.gameSettings"):exitRoom()

            end    
            --设置
            if sender == btnSetting then

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

                        self:disbandGroup()

                    end
                end

                require("hall.GameCommon"):showSettings(true,false,true,true,disband_action)

            end
        end
    end
    if btnEixt then
        btnEixt:addTouchEventListener(touchButtonEvent)
    end
    if btnSetting then
        btnSetting:addTouchEventListener(touchButtonEvent)
    end

    self:showGroupInfo()

	for k=0,4 do
		self:drawUser(false,k)
	end
	--[[local node = display.newNode()
	node:addTo(self)
	node:setName("drawnode")]]
	self._view:addNodeEventListener(cc.NODE_TOUCH_EVENT,function ( event )
		if event.name == "began" then
			--[[local base_foot=self._view:getChildByName("base_foot")
			local move2 = cc.MoveTo:create(0.2,cc.p(5.07,548.51))
			base_foot:runAction(move2)]]
		end
	end)

end
--显示和隐藏用户信息
function MenjiroomView:drawUser(flag, index, strIco, uid, sex)
	print("drawUser", index)
	local scenes  = self._view
	if scenes==nil then
		scenes=SCENENOW["scene"].view._view
	end
	--local scenes  = self._view
	print("type(scenes)",type(scenes))
	local info=scenes:getChildByName("user_"..index)
	print("flag2222",flag)
	if flag then
		info:setVisible(true)
	    local head = info:getChildByName("head")
	    if head then
        	local head_info = {}
	        head_info["icon_url"] = strIco
	        head_info["uid"] = uid
	        head_info["sex"] = sex
	        head_info["sp"] = head
	        head_info["size"] = headSize
	        head_info["touchable"] = 1
	        head_info["use_sharp"] = 1
	        require("zhajinhua.zjhSettings"):setPlayerHead(head_info,head,headSize)
	    end

		local x = 0
		local y = 0
        x = info:getPositionX()
        y = info:getPositionY() - info:getContentSize().height/2
        x = x + head:getPositionX() + head:getContentSize().width/2
        y = y + head:getPositionY()
        require("hall.view.voicePlayView.voicePlayView"):updateUserPosition(tonumber(uid), cc.p(x, y))
	else
		info:setVisible(false)
	end
end
-- 组局信息
function MenjiroomView:showGroupInfo()
    --组局显示邀请码
	local base_chip=self._view:getChildByName("base_chip")
    local lb = base_chip:getChildByName("txt_invitecode")
	local txt_config = base_chip:getChildByName("txt_config")
	if txt_config then
		txt_config:setString(USER_INFO["gameConfig"])
		txt_config:setVisible(true)
	end
    if lb then
		print("set invote_code:",tostring(USER_INFO["invote_code"]))
		lb:setString("房间号:"..USER_INFO["invote_code"])
		lb:setVisible(true)
    end
    --self:setGameConfig()
    dump(bm.Room.GroupInfo, "showGroupInfo")
    if bm.Room.GroupInfo then
    	self:updateRounds(bm.Room.GroupInfo["round"], bm.Room.GroupInfo["total_round"])
    end
end

-- 更新组局局数
function MenjiroomView:updateRounds(curr_round, total_round)
	local base_chip=self._view:getChildByName("base_chip")
	local txt_game_no = base_chip:getChildByName("txt_game_no")
	txt_game_no:setString(tostring(curr_round+1).."/"..tostring(total_round))
    --[[local txt_game_no = self._view:getChildByName("p_game_no"):getChildByName("txt_game_no")

	if txt_game_no then
        txt_game_no:setVisible(true)
        txt_game_no:setString(tostring(curr_round+1).."/"..tostring(total_round))
    end]]
end

-- 设置底注
function MenjiroomView:setBaseChip(value)
	local p_base_chip = self._view:getChildByName("base_chip")
	if p_base_chip then
		local txt_base_chip = p_base_chip:getChildByName("txt_chip")
        txt_base_chip:setVisible(true)
        txt_base_chip:setString("底注："..tostring(value))
	end
end

--房间配置
function MenjiroomView:setGameConfig()
    local panel = self._view:getChildByName("p_game_config")
    local txt_config = panel:getChildByName("txt_config")
    if txt_config then
        txt_config:setVisible(true)
        txt_config:setString(USER_INFO["gameConfig"])
        local backWith = txt_config:getContentSize().width+20
        local img_back = panel:getChildByName("Image_21")
        if img_back then
            print("setGameConfig")
            img_back:setContentSize(cc.size(backWith,37))
        end
        --调整局数位置
        local panelGameno = self._view:getChildByName("p_game_no")
        if panelGameno then
            panelGameno:setPositionX(480-backWith/2)
        end
        --调整底注位置
        local p_base_chip = self._view:getChildByName("p_base_chip")
        if p_base_chip then
            p_base_chip:setPositionX(480+backWith/2)
        end
    end
end
--解散房间
function MenjiroomView:disbandGroup()

    --查询用户当前的游戏状态来判断当前通过怎样的方式来解散组局
    require("hall.gameSettings"):disbandGroup("zjh")

end

function MenjiroomView:showMyinfo()
	self:drawUser(true,0, USER_INFO["icon_url"], tonumber(UID), USER_INFO["sex"])
	local scenes  = SCENENOW["scene"].view._view
	local node=scenes:getChildByName("user_0");
	local num = UiCommon:numFormat(bm.User.Gold)
	node:getChildByName("gold"):setString(num)--设置金币数
	node:getChildByName("nick"):setString(USER_INFO["nick"])--设置昵称
end

--显示用户准备
function MenjiroomView:showReady(uid)
	local scenes  = SCENENOW["scene"].view._view
	local index = self:getIndex(uid)
	if index==nil then
		return
	end
	local user_node = scenes:getChildByName("user_"..index)
	if user_node == nil then
		return nil
	end
	print("UID uid",UID.."uid"..uid)
	if tonumber(uid) == tonumber(UID) then
		local ready   = scenes:getChildByName("myready")
		print("showReady",ready)
        if ready ~= nil  then
            ready:removeSelf()
        end

        local change   = scenes:getChildByName("mychange")
        if change ~= nil  then
            change:removeSelf()
        end

		local ok = display.newSprite("zhajinhua/res/room/ready_img.png")
		
		ok:setScale(0.7)
		ok:addTo(user_node)
		ok:setName("ready")
		ok:pos(485.56,243.84)

		return
	end

	

	local position = {
		[1] = {
			['x'] = 210.40,
			['y'] = 97.23,
		},
		[2] = {
			['x'] = 190.11,
			['y'] = 92.01,
		},
		[3] = {
			['x'] = -65.77,
			['y'] = 91.36,
		},
		[4] = {
			['x'] = -99.43,
			['y'] = 97.53,
		},
	}

	

	local ok = display.newSprite("zhajinhua/res/room/ready_img.png")
	ok:setScale(0.7)
	ok:addTo(user_node)
	ok:setName("ready")
	ok:pos(position[index]['x'],position[index]['y'])

end



--显示用户信息
function MenjiroomView:showUserInfo(data)
	-- body
	local index   = self:getIndex(data.uid)
	local scenes  = SCENENOW["scene"].view._view

	local user_node = scenes:getChildByName("user_"..index)
	if user_node == nil then
		return
	end
	local info = json.decode(data["info"])
	dump(info, "showUserInfo", nesting)
	--金币数量
	local num = UiCommon:numFormat(data['gold'])
	user_node:getChildByName("gold"):setString(num)
	--昵称
	user_node:getChildByName("nick"):setString(info["nickName"])

	-- local url_icon = json.decode(info["user_info"])
	self:drawUser(true,index, info["photoUrl"], data.uid, info["sex"])
end


--获取用户序号
function MenjiroomView:getIndex(uid)
	if tonumber(uid) == tonumber(UID) then
		return 0
	end
	
	if uid == nil then
		print("getIndexerror")
	end
	local other_seat  = bm.Room.uid_seat[uid]
	if other_seat == nil then
		dump(bm.Room.uid_seat, "getIndexerror")
		return
	end
	local other_index = bm.User.Seat  -  other_seat
	if other_index < 0 then
		other_index = other_index + 5
	end

	return other_index

end


--删除用户信息
function MenjiroomView:removeUserInfo(uid)
	local scenes  = SCENENOW["scene"].view._view
	--[[local node = scenes:getChildByName("drawnode")
	if node == nil then
		return nil
	end]]

	local index     = self:getIndex(uid)
	local user_node = scenes:getChildByName("user_"..index)

	if user_node ~= nil  then
		user_node:setVisible(false)
	end

	
end


--改变玩家金币
function MenjiroomView:changeGold(pack)
	-- body
	local index   = self:getIndex(pack.uid)
	local scenes  = SCENENOW["scene"].view._view
	--[[local node    = scenes:getChildByName("drawnode")
	if node == nil  then
		return
	end]]

	local user_node =  scenes:getChildByName("user_"..index)
	if user_node == nil then
		return
	end

	local gold_num = user_node:getChildByName("gold")
	if gold_num == nil then
		return
	end

	local num      = UiCommon:numFormat(pack['gold'])
	gold_num:setString(num)
end

 
--显示牌局内信息
function MenjiroomView:showRoomInfo(pack, reset)
	-- body
	local scenes    = SCENENOW["scene"].view._view

	local info_node = scenes:getChildByName("base_chip")
	local newflag   = 0
	if info_node == nil then
		return
	end

	local info_num_node = info_node:getChildByName("sum_gold")
	if pack then
		info_num_node:setString(UiCommon:numFormat(pack.all_zhu))
		local game_no = info_node:getChildByName("txt_game_round")
		if pack["all_turns"] and pack["all_turns"] > 0 then
			if game_no then
				game_no:setVisible(true)
				game_no:setString("轮数:"..pack["now_turns"].."/"..pack["all_turns"])
				bm.Room.totalRound = pack["all_turns"]
			end
		else
			if game_no then
				game_no:setVisible(false)
			end
		end
	end
	if reset and reset == 1 then
		info_num_node:setString(UiCommon:numFormat(0))
	end


end

-- 刷新轮次
function MenjiroomView:showRounds()
	local scenes    = SCENENOW["scene"].view._view

	local info_node = scenes:getChildByName("base_chip")
	local newflag   = 0
	if info_node == nil then
		return
	end

	local game_no = info_node:getChildByName("txt_game_round")
	if game_no then
		if bm.Room.totalRound and bm.Room.totalRound > 0 then
			game_no:setVisible(true)
			game_no:setString("轮数："..tostring(bm.Room.now_turns).."/"..tostring(bm.Room.totalRound))
		else
			game_no:setVisible(false)
		end
	end
end


--显示倒计时
function MenjiroomView:showProgressTimer(uid,time)

	local scenes  = SCENENOW["scene"].view._view
	--[[local node = scenes:getChildByName("drawnode")
	if node == nil then
		return nil
	end]]
	
	-- local tmp = nil

	if not tolua.isnull(bm.Room.seatProgressTimer) then
		if not tolua.isnull(bm.Room.seatProgressTimer:getParent()) then
			bm.Room.seatProgressTimer:removeSelf()
		end
		bm.Room.seatProgressTimer = nil
	end

	print("showProgressTimer", uid, tostring(time))
	bm.Room.time_progress = time

	local user_node = nil
	user_node = scenes:getChildByName("user_"..tostring(MenjiroomView:getIndex(uid)))
	if user_node == nil then
		return
	end
    local tmp = cc.ProgressTimer:create(cc.Sprite:create("zhajinhua/res/NewImg/head_time01.png"))
    tmp:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
    tmp:setMidpoint(cc.p(0.5, 0.5))
    tmp:setPosition(user_node:getContentSize().width/2, user_node:getContentSize().height/2)
    tmp:addTo(user_node, 99)
    tmp:setName("head_time")
    if tonumber(uid) == tonumber(UID) then
    	tmp:setScale(1.1)
    end

    local pt = cc.ProgressTo:create(time,100)
    local sq2 = cc.Sequence:create(pt, cc.CallFunc:create(function()
    	if bm.Room.seatProgressTimer then
    		bm.Room.seatProgressTimer:stopAllActions()

			local action_time = 0.3
			local action_in = 0.1
			local st_big = cc.ScaleTo:create(action_time, 1.3)
			local fo = cc.FadeOut:create(action_time)
			local st_small = cc.ScaleTo:create(action_in, 1.1)
			local fi = cc.FadeIn:create(action_in)
			local sqout = cc.Spawn:create(st_big,fo)
			local sqin = cc.Spawn:create(st_small,fi)
			local sq = cc.Sequence:create(sqout,sqin)
    		bm.Room.seatProgressTimer:runAction(cc.RepeatForever:create(sq))
    	end
    	end))
    tmp:runAction(sq2)
	bm.Room.seatProgressTimer = tmp
end
function MenjiroomView:sav_kanPai()
	MenjiroomServer:CLI_SEE_CARD()
end
--发牌
function  MenjiroomView:sendCard()
	-- body
	local scenes  = SCENENOW["scene"].view._view

	local position = {
		[0] = {
			['x'] = 448.96,
			['y'] = 242.07,
			['width'] = 30,
		},
		[1] = {
			['x'] = 186.22,
			['y'] = 95.12,
			['width'] = 20,
		},
		[2] = {
			['x'] = 167.82,
			['y'] = 92.85,
			['width'] = 20,
		},
		[3] = {
			['x'] = -83.64,
			['y'] = 88.85,
			['width'] = 20,
		},
		[4] = {
			['x'] = -123.49,
			['y'] = 92.44,
			['width'] = 20,
		},
	}

	
	local count = 0
	for j=0,2 do
		for i=0,4 do 

			for k,v in pairs(bm.Room.uid_seat) do
				local index = self:getIndex(k)
				if i == index then
					local card = require("zhajinhua.common.PokerCard").new()

					
					local user_node = MenjiroomView:getUserNode(k)
					print("s_uid_k",k)
					if user_node ~= nil then
						
						local card_node = user_node:getChildByName("card_node")

						if card_node == nil then
							-- card_node = ccui.Widget:create()
							card_node = cc.Layer:create()
							card_node:setName("card_node")
							card_node:addTo(user_node)
						end
						card:addTo(card_node)
						card:showBack()
						card:pos(480,270)
						card:setScale(0.72)
						card:setName("card"..j)
						if tonumber(k) == tonumber(UID)  then
							-- card:setCard(bm.User.Cards[j+1])
							card:setScale(1)
							MenjiroomView:createKanPai(user_node)
						end

						require("hall.GameCommon"):playEffectSound("zhajinhua/res/audio/send_card.mp3")

						local move = cc.MoveTo:create(0.1,cc.p(position[index]['x']+j*position[index]['width'],position[index]['y']))
						

						local delay= cc.DelayTime:create(count*0.1)
						local se   = cc.Sequence:create(delay,move)
						card:runAction(se)

						count = count +1
					end
					
				end
			end
		end
	end
end
function MenjiroomView:createKanPai(user_node)
	if user_node == nil then
		return
	end
	local card_kan=user_node:getChildByName("card_kan")
	if card_kan ~= nil then
		card_kan:removeSelf()
	end
	--创建点击遮罩
	--local card_kan    = cc.Layer:create()
	local card_kan = display.newLayer()
	card_kan:setContentSize(cc.size(133,86))
	card_kan:setName("card_kan")
	card_kan:addTo(user_node)
	card_kan:setPosition(cc.p(413.18,196.46))
	--看牌
	local cards_look = display.newSprite("zhajinhua/res/NewImg/cards_look_box01.png")
	cards_look:setName("cards_look")
	cards_look:setPosition(cc.p(card_kan:getContentSize().width/2,card_kan:getContentSize().height/2))
	cards_look:addTo(card_kan)
	local ttfConfig = {}
	ttfConfig.fontFilePath = "res/fonts/fzcy.ttf"
	ttfConfig.fontSize = 24
	local label = cc.Label:createWithTTF(ttfConfig, "点击看牌")
	label:setPosition(cc.p(cards_look:getContentSize().width/2, cards_look:getContentSize().height/2-3))
	label:setColor(cc.c3b(170,240,255))
	label:addTo(cards_look)
	card_kan:setTouchEnabled(true)
	card_kan:setTouchMode(cc.TOUCHES_ALL_AT_ONCE)
	card_kan:addNodeEventListener(cc.NODE_TOUCH_EVENT,function(event)
		if event.name == "began" then
			MenjiroomServer:CLI_SEE_CARD()
		end
	end)

end
-- 设置牌值
function MenjiroomView:setCards(uid, cards)
	local uid_card = uid or tonumber(UID)
	local v_cards = cards or bm.User.Cards
	local user_node = MenjiroomView:getUserNode(uid_card)
	if user_node then
		local card_node = user_node:getChildByName("card_node")
		if card_node then
			for k, v in pairs(v_cards) do
				local card = card_node:getChildByName("card"..tostring(k-1))
				if card then
					card:setCard(v)
				end
			end
		end
	end
end

--获得用户的节点
function MenjiroomView:getUserNode(uid)

	local index = self:getIndex(uid)
	print("getUserNode", tostring(index), tostring(uid))

	if index == nil then
		return nil
	end

	local scenes    = SCENENOW["scene"].view._view
	--[[local node = scenes:getChildByName("drawnode")
	if node == nil then
		return nil
	end]]


	local user_node = scenes:getChildByName("user_"..index)
	if user_node == nil then
		return nil
	end

	return user_node
end

--显示弃牌图片
function MenjiroomView:showQipai(uid)
	-- body
	local scenes  = SCENENOW["scene"].view._view
	local position = {
		[0] = {
			['x'] = 485.56,
			['y'] = 243.84,
		},
		[1] = {
			['x'] = 205.79,
			['y'] = 91.81,
		},
		[2] = {
			['x'] = 188,
			['y'] = 91.36,
		},
		[3] = {
			['x'] = -62.88,
			['y'] = 91.36,
		},
		[4] = {
			['x'] = -103.12,
			['y'] = 91.81,
		}
	}

	print("showQipai", tostring(uid))

	local index = self:getIndex(uid)
	local user_node = MenjiroomView:getUserNode(uid)
	if user_node == nil then
		return
	end

	--弃牌
	if tonumber(uid) == tonumber(UID) then
		local base_foot = scenes:getChildByName("base_foot")
	    local qi_green = base_foot:getChildByName("qi_green")
		if qi_green then
			qi_green:setOpacity(80)
			qi_green:setTouchEnabled(false)
		end
	end
	--弃牌
	local kan = user_node:getChildByName("kanpai")
	if kan~=nil then
		kan:removeSelf()
	end
	local qi_img = display.newSprite("zhajinhua/res/NewImg/cards_fling_box01.png")
	qi_img:setScale(0.9)
	qi_img:pos(position[index]['x'],position[index]['y'])
	if tonumber(uid) == tonumber(UID) then
		local card_kan=user_node:getChildByName("card_kan")
		if card_kan~=nil then
			card_kan:removeSelf()
		end
		qi_img:setScale(1.2)
		qi_img:pos(position[index]['x']-4.5,position[index]['y'])
	end

	qi_img:addTo(user_node,9)
	local ttfConfig = {}
	ttfConfig.fontFilePath = "res/fonts/fzcy.ttf"
	ttfConfig.fontSize = 20
	local label = cc.Label:createWithTTF(ttfConfig, "弃牌")
	label:setPosition(cc.p(qi_img:getContentSize().width/2, qi_img:getContentSize().height/2-1))
	label:setColor(cc.c3b(255,255,255))
	label:addTo(qi_img)
	qi_img:setName("qipai")
	
end


--显示看牌
function MenjiroomView:showKanpai(uid)
	local scenes  = SCENENOW["scene"].view._view
	local user_node = MenjiroomView:getUserNode(uid)
	if user_node == nil then
		return
	end
	local position = {
		[0] = {
			['x'] = 430,
			['y'] = 120,
		},
		[1] = {
			['x'] = 205.79,
			['y'] = 91.81,
		},
		[2] = {
			['x'] = 188,
			['y'] = 91.36,
		},
		[3] = {
			['x'] = -62.88,
			['y'] = 91.36,
		},
		[4] = {
			['x'] = -103.12,
			['y'] = 91.81,
		}
	}

	if tonumber(uid) == tonumber(UID) then
		print("showKanpai", type(user_node), tostring(uid))
		local card_node = user_node:getChildByName("card_node")
		dump(card_node, "showKanpai", nesting)
		for j=0,2 do
			local card = card_node:getChildByName("card"..j)
			card:flip()
		end
		local card_kan=user_node:getChildByName("card_kan")
		if card_kan~=nil then
			card_kan:removeSelf()
		end
		MenjiroomView:moveChipList()
	else
		local index   = self:getIndex(uid)
		--看牌
		local kan_img = display.newSprite("zhajinhua/res/NewImg/cards_looked_box01.png")
		kan_img:setName("kanpai")
		kan_img:pos(position[index]['x'],position[index]['y'])
		kan_img:setScale(0.9)
		kan_img:addTo(user_node,9)
		local ttfConfig = {}
		ttfConfig.fontFilePath = "res/fonts/fzcy.ttf"
		ttfConfig.fontSize = 20
		local label = cc.Label:createWithTTF(ttfConfig, "已看牌")
		label:setPosition(cc.p(kan_img:getContentSize().width/2, kan_img:getContentSize().height/2-3))
		label:setColor(cc.c3b(255,255,255))
		label:addTo(kan_img)

	end
end

-- 显示牌
function MenjiroomView:showCard(uid, cards)

	local scenes  = SCENENOW["scene"].view._view
	local user_node = MenjiroomView:getUserNode(uid)
	if user_node == nil then
		return
	end

	local card_node = user_node:getChildByName("card_node")
	dump(card_node, "showKanpai", nesting)
	for j=0,2 do
		local card = card_node:getChildByName("card"..j)
		card:flip()
	end
	local card_kan=user_node:getChildByName("card_kan")
	if card_kan~=nil then
		card_kan:removeSelf()
	end
end


--玩家扔出筹码
function MenjiroomView:diuChips(uid,gold)
	local index     = self:getIndex(uid)
	local user_node = MenjiroomView:getUserNode(uid)
	if user_node == nil then
		return
	end
	print("bm.Room.chip_v",bm.Room.chip_v)
	print("bm.Room.chip_gold",bm.Room.chip_k)
	local action_time = 0.1
	local chip=nil
	for k,v in pairs(bm.Room.zhus) do
		if gold==v then
			chip= UiCommon:getChipBtnNew(gold,k)
			if chip then
				local random = math.random(1,90)
				local rotate=cc.RotateBy:create(action_time,random)
				chip:setScale(0.65)

				local rand_x = math.random(312.52,645.13)
				local rand_y = math.random(300,420)
				chip:setPosition(user_node:getPosition())
				local move = cc.MoveTo:create(action_time,cc.p(rand_x,rand_y))

				local sw = cc.Spawn:create(rotate, move)

				chip:runAction(sw)
			end
		end
	end

	if chip == nil then
		chip= UiCommon:getChipBtnNew(gold,1)
		chip:setScale(0.65)
		local random = math.random(1,90)
		local rotate=cc.RotateBy:create(action_time,random)

		local rand_x = math.random(312.52,645.13)
		local rand_y = math.random(300,420)
		chip:setPosition(user_node:getPosition())
		local move = cc.MoveTo:create(action_time,cc.p(rand_x,rand_y))

		local sw = cc.Spawn:create(rotate, move)

		chip:runAction(sw)
	end

	local scenes    = SCENENOW["scene"].view._view
	chip:addTo(scenes)

	table.insert(bm.Room.chips,chip)

	require("hall.GameCommon"):playEffectSound("zhajinhua/res/audio/sound_jinbi.mp3")
end



--显示玩家当前下注数量
function  MenjiroomView:showNowZhu(uid, gold, add_flag)
	-- body
	local user_node = MenjiroomView:getUserNode(uid)
	if user_node == nil then
		return
	end

	local gold_back = user_node:getChildByName("chip_bg")

	print("showNowZhu", tostring(uid), tostring(gold), tostring(add_flag))

	local chips = gold
	local txt = gold_back:getChildByName("chip")
	if txt then
		if add_flag and add_flag == 1 then
			chips = tonumber(txt:getString()) + gold
		end
		txt:setString(UiCommon:numFormat(chips))
	end

end

--显示操作按钮
function MenjiroomView:showRoomButton(uid, can_compare, allin_flag)
	-- body
	print("dddddddddddddddddddddddddddddddddddddddddddddddddddddddd:"..bm.Room.now_turns)
	local scenes  = SCENENOW["scene"].view._view
	local isQi   = false
	local isKan  = false
	local isBi   = true
	local isGen  = false
	local isJia  = false
	local isShowAllin = true  -- 是否显示火拼
	local isAllin = allin_flag or 0

	if bm.User.isKan[uid] == nil then
		isKan = true
	end

	if bm.User.isDiu[tonumber(UID)] == nil then
		isQi  = true
	end
	-- 全押不能弃牌
	if bm.User.chips[tonumber(UID)] and bm.User.chips[tonumber(UID)] >= bm.Room.init_chips then
		isQi = false
	end

	local min_pk = bm.Room.min_pk or 3
	local min_allin = bm.Room.min_allin or 3


	if bm.Room.now_turns < min_pk or tonumber(uid) ~= tonumber(UID) then
		isBi = false
	end
	if can_compare and can_compare == 1 and tonumber(uid) == tonumber(UID) then
		isBi = true
	end

	if bm.Room.now_turns < min_allin or tonumber(uid) ~= tonumber(UID) then
		isShowAllin = false
	end

	-- 当玩家分数不够时，只能弃牌或全押
	if tonumber(uid) == tonumber(UID) then
	    local zhu  = bm.Room.now_zhu
	    
	    if bm.User.isKan[tonumber(UID)]  ~= nil then
	        zhu = zhu * 2
	    end
		if (bm.Room.init_chips - bm.User.chips[tonumber(UID)]) < zhu then
			isAllin = 1
		end
	end

	-- allin不能比牌
	if isAllin == 1 then
		isBi = false
		-- local effect_all=scenes:getChildByName("effect_all");   --当玩家下注超极限时。会刷出全押图片
		-- if effect_all then
		-- 	effect_all:setLocalZOrder(10)
		-- 	effect_all:setVisible(true)
		-- end
		if tonumber(uid) ~= tonumber(UID) then
			isShowAllin = false
		else
			isShowAllin = true
		end
	end

	if tonumber(uid) == tonumber(UID) and isAllin == 0 then
		isGen = true
		isJia = true
	end


	local base_foot=scenes:getChildByName("base_foot")

	--弃牌
    local qi_green = base_foot:getChildByName("qi_green")
	if isQi then
		qi_green:setOpacity(255)
    	qi_green:setTouchEnabled(true)
    else
		qi_green:setOpacity(80)
		qi_green:setTouchEnabled(false)
	end

	--比牌
    local bi_green = base_foot:getChildByName("bi_green")
	if isBi then
		bi_green:setOpacity(255)
		bi_green:setTouchEnabled(true)
	else
		bi_green:setTouchEnabled(false)
		bi_green:setOpacity(80)
	end

    --跟注
	local gen_green = base_foot:getChildByName("gen_green")
	if isGen then
		gen_green:setOpacity(255)
		gen_green:setTouchEnabled(true)
	else
		gen_green:setTouchEnabled(false)
		gen_green:setOpacity(80)
	end

    --加注
	local jia_green = base_foot:getChildByName("jia_green")
	if isJia then
		jia_green:setOpacity(255)
		jia_green:setTouchEnabled(true)
	else
		jia_green:setTouchEnabled(false)
		jia_green:setOpacity(80)
	end

    --全押
	local btn_allin = base_foot:getChildByName("quan_green")
	if btn_allin then
		if isShowAllin then
			btn_allin:setOpacity(255)
			btn_allin:setTouchEnabled(true)

		else
			btn_allin:setTouchEnabled(false)
			btn_allin:setOpacity(80)
		end
	end
end

-- 重置按钮
function MenjiroomView:resetOperate()
	local scenes  = SCENENOW["scene"].view._view:getChildByName("base_foot")

	--弃牌
    local qi_green = scenes:getChildByName("qi_green")
	if qi_green then
		qi_green:setOpacity(80)
    	qi_green:setTouchEnabled(false)
	end

	--比牌
    local bi_green = scenes:getChildByName("bi_green")
	if bi_green then
		bi_green:setOpacity(80)
		bi_green:setTouchEnabled(false)
	end

    --跟注
	local gen_green = scenes:getChildByName("gen_green")
	if gen_green then
		gen_green:setOpacity(80)
		gen_green:setTouchEnabled(false)
	end

    --加注
	local jia_green = scenes:getChildByName("jia_green")
	if jia_green then
		jia_green:setOpacity(80)
		jia_green:setTouchEnabled(false)
	end

    --全押
	local btn_allin = scenes:getChildByName("quan_green")
	if btn_allin then
		btn_allin:setTouchEnabled(false)
		btn_allin:setOpacity(80)
	end
end

-- 重置房间
function MenjiroomView:resetGame()
	for k , v in pairs(bm.User.UserInfo) do
		if bm.User.online[k] and bm.User.online[k] == 1 then
			MenjiroomView:showNowZhu(k,0)
		else
    		MenjiroomView:removeUserInfo(k)
		end
	end
	local scenes    = SCENENOW["scene"].view._view

	local info_node = scenes:getChildByName("base_chip")
	if info_node then
		local info_num_node = info_node:getChildByName("sum_gold")
		if info_num_node then
			info_num_node:setString(0)
		end
	end

	-- 重置轮数
	bm.Room.now_turns = 0
	MenjiroomView:showRounds()
	-- 重置庄家
	if bm.Room.banker then
		bm.Room.banker:removeSelf()
		bm.Room.banker = nil
	end

	bm.Room.all_compare = 0
	bm.Room.result = nil
	bm.Room.isover = false
	bm.Room.show_card = 0
end

--显示加注
function MenjiroomView:showJiaZhuView()
	-- body  

	local scenes  = SCENENOW["scene"].view._view
	scenes:removeNodeEventListener(cc.NODE_TOUCH_EVENT)
	local node_t = scenes:getChildByName("chip_node")
	if node_t == nil then
		return
	end
	node_t:setVisible(true)
	node_t:setLocalZOrder(100)
	local cBet = bm.Room.now_zhu
	if bm.User.isKan[tonumber(UID)] ~= nil then
		cBet = cBet * 2
	end
	print("showJiaZhuView", tostring(cBet), tostring(bm.User.isKan[tonumber(UID)]))
	local i      = 0

	bm.Room.chip_v=0
	for k,v in pairs(bm.Room.zhus) do
		local chip_btn=node_t:getChildByName("chip_btn"..k)
		local chipNum      = UiCommon:getChipsNum(v)
	    if chip_btn then
	    	if cBet > 0 then
	    		if v < cBet then
					chip_btn:setTouchEnabled(false)
					chip_btn:setOpacity(80)
				else
					chip_btn:setTouchEnabled(true)
					chip_btn:setOpacity(255)
	    		end
	    	end
			chipNum:addTo(chip_btn)
			-- chipNum:setAnchorPoint(cc.p(0.5,0.5))
			chipNum:setPosition(chip_btn:getContentSize().width/2 - chipNum:getContentSize().width/2,56.38)

			chip_btn:setScale(1)
			chip_btn:addTouchEventListener(
		        function(sender,event)
		            --触摸结束
		            if event == TOUCH_EVENT_ENDED then
						print("加注", tostring(v))
						bm.Room.chip_v=v;
						MenjiroomServer:CLI_JIA_CARD(v)
						--[[local move = cc.MoveTo:create(0.2,cc.p(1200,100))
			            node_t:runAction(move)]]
						MenjiroomView:moveChipList()
		            end
		        end
		    )
	    end
	end
	node_t:setPosition(397.01,139.95)
	scenes:setTouchSwallowEnabled(false)
	scenes:setTouchEnabled(true)
    scenes:addNodeEventListener(cc.NODE_TOUCH_EVENT,function ( event )
            if event.name == "began" then
            	MenjiroomView:moveChipList()
            end
    end)

end

-- 收起筹码表
function MenjiroomView:moveChipList()
	local scenes  = SCENENOW["scene"].view._view
	local user_node_ = MenjiroomView:getUserNode(tonumber(UID))
	if user_node_ then
		local node_n = scenes:getChildByName("chip_node")
		if node_n then
			node_n:setVisible(false)
		end
	end
end

--比牌
function MenjiroomView:biPai()

	print("MenjiroomView:biPai")

	for k,v in pairs(bm.Room.uid_seat) do
		local uid = tonumber(k)
		if tonumber(uid) ~= tonumber(UID)  and  bm.User.isDiu[uid] ~= 1 then
			local user_node  = MenjiroomView:getUserNode(uid)
			if user_node then
				user_node:setTouchEnabled(true)
				local kuang_node = cc.Layer:create()
				local kuang_node = ccui.Button:create()
				local kuang_node = ccui.Button:create("zhajinhua/res/room/head_choose.png", nil, nil)


				local action_time = 0.3
				local action_in = 0.1
			    -- local kuang = display.newSprite("zhajinhua/res/room/head_choose.png")
			    local st_big = cc.ScaleTo:create(action_time, 1.3)
			    local fo = cc.FadeOut:create(action_time)
			    local st_small = cc.ScaleTo:create(action_in, 1.1)
			    local fi = cc.FadeIn:create(action_in)
			    local sqout = cc.Spawn:create(st_big,fo)
			    local sqin = cc.Spawn:create(st_small,fi)
			    local sq = cc.Sequence:create(sqout,sqin)
			    kuang_node:runAction(cc.RepeatForever:create(sq))

				-- kuang:addTo(kuang_node)
				-- kuang:setName("kuang_select")
				-- kuang:setPosition(kuang_node:getContentSize().width/2, kuang_node:getContentSize().height/2)
				kuang_node:addTo(user_node,10)
				kuang_node:setLocalZOrder(10)
				-- kuang_node:setContentSize(kuang:getContentSize())
				kuang_node:setName("kuang_node")
				local i     = 0
				local index = self:getIndex(uid)
				kuang_node:setPosition(user_node:getContentSize().width/2, user_node:getContentSize().height/2)

				local jiantou = nil
				if index == 1 or index == 2 then
					jiantou = display.newSprite("zhajinhua/res/room/headBox/arrow2.png")
					jiantou:setPosition(kuang_node:getContentSize().width/2 + 60 + jiantou:getContentSize().width/2, kuang_node:getContentSize().height/2)
				else
					jiantou = display.newSprite("zhajinhua/res/room/headBox/arrow1.png")
					jiantou:setPosition(-(kuang_node:getContentSize().width/2 + 60 - jiantou:getContentSize().width), kuang_node:getContentSize().height/2)
				end
				
				jiantou:addTo(kuang_node,6)
				jiantou:setScale(0.6)

				print("bipai", tostring(uid))
				dump(kuang_node:getContentSize(), "kuang_node size")
				dump(kuang_node:getPosition(), "kuang_node pos")

				local seat = bm.Room.uid_seat[uid]
				kuang_node:addTouchEventListener(function (sender,event)
					-- body
					--触摸结束
					if event == TOUCH_EVENT_ENDED then
						print("CLI_BI_CARD", tostring(seat), tostring(uid))
						MenjiroomServer:CLI_BI_CARD(seat)
						-- kuang:removeSelf()
						MenjiroomView:clearBipai()
					end
				end)
			end
		end
	end
end

-- 清除比牌选择动画
function MenjiroomView:clearBipai()

    for k,v in pairs(bm.Room.uid_seat) do
        local uid = k
        if tonumber(uid) ~= tonumber(UID) then
            local user_node = MenjiroomView:getUserNode(uid)
            if user_node~= nil then
				local tmp = user_node:getChildByName("kuang_node")
				if tmp ~= nil then
					tmp:removeSelf()
				end
				tmp = user_node:getChildByName("kuang_select")
				if tmp ~= nil then
					tmp:removeSelf()
				end
            end
        end
    end

	if bm.Room.seatProgressTimer ~= nil then
		if bm.Room.seatProgressTimer:getParent() then
			bm.Room.seatProgressTimer:removeSelf()
		end
		bm.Room.seatProgressTimer = nil
	end
end


function MenjiroomView:exitGame(sender,event)

end

-- 比牌回调
function MenjiroomView:CallBackCompare(active_uid, compare_uid, compare_resutl)

	bm.Room.all_compare = 0

	if compare_resutl == 1 then
		print("bm.User.isKan[active_uid]",bm.User.isKan[active_uid])
		if bm.User.isKan[active_uid] ==nil then
			if tonumber(active_uid)==tonumber(UID) then
				local user_node = MenjiroomView:getUserNode(active_uid)
				MenjiroomView:createKanPai(user_node)
			end
		end
		MenjiroomView:showQipai(compare_uid)
	else
		print("bm.User.isKan[compare_uid]",bm.User.isKan[compare_uid])
		if bm.User.isKan[compare_uid] ==nil then
			if tonumber(compare_uid) == tonumber(UID) then
				local user_node = MenjiroomView:getUserNode(compare_uid)
				MenjiroomView:createKanPai(user_node)
			end
		end
		MenjiroomView:showQipai(active_uid)
	end

	dump(bm.Room.result, "CallBackCompare", nesting)

	if bm.Room.show_card and bm.Room.show_card > 0 then

		for k, v in pairs(bm.Room.show_cards) do
			if tonumber(k) == tonumber(UID) and bm.User.isKan[tonumber(UID)] ~= nil then
			else
				MenjiroomView:setCards(k, v)
				MenjiroomView:showCard(k)
			end
		end
		local user_node_f = MenjiroomView:getUserNode(active_uid)
		if user_node_f then
			user_node_f:runAction(cc.Sequence:create(cc.DelayTime:create(2), cc.CallFunc:create(function()
					if bm.Room.result then
						MenjiroomView:gameEnd(bm.Room.result)
					end
                end)))
		end
	else
		if bm.Room.result then
			MenjiroomView:gameEnd(bm.Room.result)
		end
	end

end

-- 全桌比牌
function MenjiroomView:AllCompare()
	local scenes  = SCENENOW["scene"].view._view
	if scenes == nil then
		return
	end

	bm.Room.all_compare = 1
	-- bm.Room.result = nil

	local effect = display.newSprite("#allCompare1.png")
	local frames = display.newFrames("allCompare%d.png", 1, 13)
	local animation = display.newAnimation(frames, 0.1)

	local function onComplete()
		if bm.Room.result then
			-- 先显示牌，然后出结果页
			local data = bm.Room.result
			for k, v in pairs(data["userinfos"]) do
				dump(v.compare_content[1]['cards'], "AllCompare", nesting)
                MenjiroomView:setCards(v["uid"], v.compare_content[1]['cards'])
                MenjiroomView:showCard(v["uid"])
			end

            local user_node_f = MenjiroomView:getUserNode(data["userinfos"][1]["uid"])
            if user_node_f then
                user_node_f:runAction(cc.Sequence:create(cc.DelayTime:create(3), cc.CallFunc:create(function()
                    MenjiroomView:gameEnd(bm.Room.result)
                end)))
            end

			-- MenjiroomView:gameEnd(bm.Room.result)
		end
	end

	effect:playAnimationOnce(animation, true, onComplete)
	effect:addTo(scenes)
	effect:setPosition(480, 270)

end

-- 显示结果
function MenjiroomView:gameEnd(pack)
    dump(pack,"单局结算SVR_END")
    bm.Room.result = pack

	local win_uid = nil
	for k,v in pairs(pack.userinfos) do
		if v.turngold > 0 then
			win_uid = v.uid
		end
	end
	MenjiroomView:addResult(pack)
    MenjiroomView:recycleChips(win_uid, pack)


    -- 移除桌面动画
    MenjiroomView:clearBipai()
    MenjiroomView:resetOperate()
    -- 重置房间
    require("zhajinhua.zjhSettings"):resetUserInfo()
	bm.Room.all_compare = 0
end


--绘制用户列表
function MenjiroomView:drawGameoverList(uid,num,index,cards,account,card_type)
	function str_type(card_type)
		if card_type==nil then
			return "";
		elseif card_type==1 then
			return "散牌"
		elseif card_type==2 then
			return "一对"
		elseif card_type==3 then
			return "顺子"
		elseif card_type==4 then
			return "同花"
		elseif card_type==5 then
			return "同花顺"
		elseif card_type==6 then
			return "豹子"
		elseif card_type==7 then
			return "235"
		end
	end
	-- body
	local scenes  = SCENENOW["scene"].view._view
	if account==nil then
		return;
	end
	local sing = account:getChildByName("single_panel"):setVisible(true);
	local panel=sing:getChildByName("panel"):clone()
	-- panel:getChildByName("card_class"):setString(str_type(card_type));

	local text  = nil
	if num > 0 then
		panel:getChildByName("victory_text"):setString("赢")
		panel:getChildByName("victory_text"):setTextColor(cc.c4b(36,171,29,255));
		panel:getChildByName("account_text"):setString("+"..num)
	else
		panel:getChildByName("victory_text"):setString("输")
		panel:getChildByName("victory_text"):setTextColor(cc.c4b(164,18,24,255));
		panel:getChildByName("account_text"):setString(num)
	end

	local  nick = ""
	if tonumber(UID) == tonumber(uid) then
		nick = USER_INFO['nick']
	else
		if bm.User.UserInfo[tonumber(uid)] then
			nick = bm.User.UserInfo[tonumber(uid)]
			nick = json.decode(nick)
			nick = nick["nickName"]
		end
	end

    local strNick = require("hall.GameCommon"):formatNick(nick)
	panel:getChildByName("nick"):setString(strNick)

	local head = panel:getChildByName("head")
	if head == nil then -- 手动添加头像
		head = display.newSprite("zhajinhua/res/login/female_head.png")
		head:addTo(panel)
		head:setPosition(48, 36)
	end
	if head then
		local url_icon = json.decode(bm.User.UserInfo[tonumber(uid)])
		dump(url_icon, "drawGameoverList head "..tostring(tonumber(uid)), nesting)
		if url_icon then
			local head_info = {}
			head_info["icon_url"] = url_icon["photoUrl"]
			head_info["uid"] = tonumber(uid)
			head_info["sex"] = url_icon["sex"]
			head_info["sp"] = head
			head_info["size"] = 45
			head_info["touchable"] = 0
			head_info["use_sharp"] = 1
			require("zhajinhua.zjhSettings"):setPlayerHead(head_info,head,45)
		else
			dump(bm.User.UserInfo, "bm.User.UserInfo", nesting)
		end
	end

	print("card_type",card_type)
	for i = 1,3 do
		local card = require("zhajinhua.common.PokerCard").new()

		card:addTo(panel,3)
		card:setScale(0.55)
		card:pos(464.85+i*21.18,36.04)
		card:showBack()
		print("setCard",type(cards))
		if cards ~= nil  then
			card:setCard(cards[i])
			card:showFront()
		end
		if tonumber(uid) == tonumber(UID) then
			if bm.User.Cards[i] then
				card:setCard(bm.User.Cards[i])
				card:showFront()
			end
		end
	end

	sing:getChildByName("ListView"):pushBackCustomItem(panel)
end


--结算排行榜
function MenjiroomView:onNetBillboard(pack)
	local scenes  = SCENENOW["scene"].view._view
	--去掉提示弹框
	local layer_tips = SCENENOW["scene"]:getChildByName("layer_tips")
	if layer_tips then
		layer_tips:removeSelf()
	end
	local account =scenes:getChildByName("accountScene")
	if account==nil then
		account= cc.CSLoader:createNode("zhajinhua/layout/account.csb")
		account:setName("accountScene")
		account:addTo(scenes,101)
	end
	local total_panel=account:getChildByName("total_panel")
	print("bm.Room.isover",bm.Room.isover)
	if bm.Room.isover == false then
		account:setVisible(true)
		total_panel:setVisible(true);
		local end_btn = total_panel:getChildByName("foot_panle"):getChildByName("end_btn")
		local share_btn = total_panel:getChildByName("foot_panle"):getChildByName("share_btn")
		end_btn:setEnabled(true)
		end_btn:addTouchEventListener(function(sender,event)

			--触摸结束
			if event == TOUCH_EVENT_ENDED then

				--退出房间，返回大厅
				require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])

			end
		end)
		share_btn:addTouchEventListener(function(sender,event)
			--触摸结束
			if event == TOUCH_EVENT_ENDED then
				share_btn:setTouchEnabled(false)
                if device.platform == "android" then
                    require("hall.common.ShareLayer"):showShareLayer("分享结果","","screen","",share_btn)
                elseif device.platform ~= "windows" then
                    require("hall.common.ShareLayer"):shareGroupResultForIOS(share_btn)
                end
            end

		end)
	else

		local accountScene=scenes:getChildByName("accountScene")
		print("accountScenezhezhao",type(accountScene))
		if accountScene then
			local single_panel=accountScene:getChildByName("single_panel")
			single_panel:setVisible(true)
			local Image_1=single_panel:getChildByName("change_btn"):getChildByName("Image_1")
			Image_1:loadTexture("zhajinhua/res/fin_text_paijujiesu.png")
			total_panel:setVisible(false);

    		if bm.Room.all_compare and bm.Room.all_compare == 1 then
    			single_panel:setVisible(false)
    		end
		end

	end
	local max=0;
	local cloneP = nil
	for k,v in pairs(pack.playerlist) do
		local data=json.decode(v.user_info)
		local panel=total_panel:getChildByName("panel"):clone()
		if data["chips"]>max then
			max=data["chips"]
			cloneP=panel
		end

		dump(data, "onNetBillboard "..tostring(v["uid"]), nesting)
		local txt_nick = panel:getChildByName("nick")
		if txt_nick then
			txt_nick:setString(data["nick_name"])
		end
		local txt_id = panel:getChildByName("user_id")
		if txt_id then
			txt_id:setString("ID:"..tostring(v["uid"]))
		end
		panel:getChildByName("victory_img"):setVisible(false)
		if(tonumber(data["chips"])>0) then
			panel:getChildByName("account_text"):setString("+"..data["chips"])
		else
			panel:getChildByName("account_text"):setString(data["chips"])
		end

		local head = panel:getChildByName("head")
		if head == nil then -- 手动添加头像
			head = display.newSprite("zhajinhua/res/login/female_head.png")
			head:addTo(panel)
			head:setPosition(116, 36)
		end
		if head then
			local head_info = {}
			head_info["icon_url"] = data["photo_url"]
			head_info["uid"] = k
			head_info["sex"] = data["sex"]
			head_info["sp"] = head
			head_info["size"] = 45
			head_info["touchable"] = 0
			head_info["use_sharp"] = 1
			require("zhajinhua.zjhSettings"):setPlayerHead(head_info,head,45)
		end

		total_panel:getChildByName("ListView"):pushBackCustomItem(panel)
	end
	if cloneP~=nil then
		cloneP:getChildByName("victory_img"):setVisible(true)
	end
end

-- 添加结算数据
function MenjiroomView:addResult(pack)
	local scenes  = SCENENOW["scene"].view._view
	local node    = display.newNode()
	node:setName("zhezhao")
	node:addTo(scenes,1)
	node:setVisible(false)

	local layer = cc.LayerColor:create(cc.c4b(0,0,0,110))
	layer:addTo(node,1)


	local account = scenes:getChildByName("accountScene")
	if account == nil then
		account= cc.CSLoader:createNode("zhajinhua/layout/account.csb")
		account:addTo(scenes,101)
	end
	account:setName("accountScene")
	account:setVisible(false)

	local index = 1
	for k,v in pairs(pack.userinfos) do 
		local cards = nil
		local card_type=nil
		if v.compare_content ~= nil then
			cards = v.compare_content[1]['cards']
			card_type =v.compare_content[1]['card_type']
		end
		MenjiroomView:drawGameoverList(v.uid,v.turngold,index,cards,account,card_type)
		index = index +1
	end

	local change_btn=account:getChildByName("single_panel"):getChildByName("change_btn")
	change_btn:addTouchEventListener(function (sender,event)
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
			local scenes  = SCENENOW["scene"].view._view
			if bm.Room.iswith == true then
				local zhezhao = scenes:getChildByName("zhezhao")
				if zhezhao ~= nil then
					zhezhao:removeSelf()
				end
				local accountScene= scenes:getChildByName("accountScene")
				if accountScene~=nil then
					accountScene:setVisible(true)
					local total_panel=accountScene:getChildByName("total_panel")
					total_panel:setVisible(true)
					local single_panel=accountScene:getChildByName("single_panel")
					single_panel:setVisible(false)
					local end_btn=total_panel:getChildByName("foot_panle"):getChildByName("end_btn")
					local share_btn=total_panel:getChildByName("foot_panle"):getChildByName("share_btn")
					end_btn:setEnabled(true)
					end_btn:addTouchEventListener(function(sender,event)
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
							require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])

						end
					end)
					share_btn:addTouchEventListener(function(sender,event)
						--触摸结束
						if event == TOUCH_EVENT_ENDED then
							share_btn:setTouchEnabled(false)
			                if device.platform == "android" then
			                    require("hall.common.ShareLayer"):showShareLayer("分享结果","","screen","",share_btn)
			                elseif device.platform ~= "windows" then
			                    require("hall.common.ShareLayer"):shareGroupResultForIOS(share_btn)
			                end
			            end

					end)
				end
			else
				bm.SchedulerPool:clearAll()
				MenjiroomView:clearDesk()
				MenjiroomServer:CLI_READYNOW_ROOM()
				bm.Room.over = true
			end

		end
	end)
end



--回收筹码
function MenjiroomView:recycleChips(uid,pack)

	print("MenjiroomView:recycleChips")

	local index = MenjiroomView:getIndex(uid)
	local user_node = MenjiroomView:getUserNode(uid)
	if user_node == nil then
		print("recycleChips can't get user_node", tostring(index), tostring(uid))
		return
	end
	local pos = 0
	for k,v in pairs(bm.Room.chips) do
		pos = pos + 1
		local move = cc.MoveTo:create(0.3, user_node:getPosition())
		local remove_chips = function ()
			-- body
			v:removeSelf()
		end
		local callfunc = function()
			print("recycleChips callfunc", tostring(uid))
			MenjiroomView:kuangLight(uid)
			MenjiroomView:gameEndMoneyAnim(pack)
		end
		if pos == 1 then
			local callback1           = cc.CallFunc:create(remove_chips)
			local callback2           = cc.CallFunc:create(callfunc)
			local sq                 = cc.Sequence:create(move, callback1, callback2)
			v:runAction(sq)
		else
			local callback           = cc.CallFunc:create(remove_chips)
			local sq                 = cc.Sequence:create(move,callback)
			v:runAction(sq)
		end
	end
end

--玩家收钱的相框发亮
function MenjiroomView:kuangLight(uid)

	local user_node = MenjiroomView:getUserNode(uid)
	if user_node == nil then
		print("kuangLight can't get user_node", tostring(uid))
		return
	end
	local index     = MenjiroomView:getIndex(uid)

	local light_kuang = display.newSprite("#headWin1.png")
	local frames = display.newFrames("headWin%d.png", 1, 10)
	local animation = display.newAnimation(frames, 0.1)

	local function onComplete()
		local scenes = SCENENOW["scene"].view._view
		local account = scenes:getChildByName("accountScene")
		if account == nil then
			MenjiroomView:addResult(pack)
		end
		local mask = scenes:getChildByName("zhezhao")
		if mask then
			mask:setVisible(true)
		end
		account:setVisible(true)
	end
	light_kuang:playAnimationOnce(animation, true, onComplete)
	light_kuang:addTo(user_node, 2)
	light_kuang:setScale(1.2)
	light_kuang:pos(user_node:getContentSize().width/2, user_node:getContentSize().height/2)
end

--钱上浮飘啊飘
function MenjiroomView:gameEndMoneyAnim(pack)
	-- body
	local  position = {
		[0] = {
			['x'] = 220,
			['y'] = 150,
		},
		[1] = {
			['x'] = 60,
			['y'] = 240,
			
		},
		[2] = {
			['x'] = 60,
			['y'] = 400,
			
		},
		[3] = {
			['x'] = 800,
			['y'] = 400,
			
		},
		[4] = {
			['x'] = 800,
			['y'] = 240,
		},
	}

	require("hall.GameCommon"):playEffectSound("zhajinhua/res/audio/login_gold.mp3")

	for k,v in pairs(pack.userinfos) do
		local uid       = v.uid
		local index     = MenjiroomView:getIndex(uid)
		local user_node = MenjiroomView:getUserNode(uid)
		if user_node then
			local num       = nil
			if v.turngold > 0 then
				num  =  UiCommon:gameWinGold(v.turngold)
			else
				num  =  UiCommon:gameLostGold(-v.turngold)
			end

			num:addTo(user_node)
			num:setScale(0.5)
			num:pos(position[index]['x'],position[index]['y'])
			num:setCascadeOpacityEnabled(true)

			local move    = cc.MoveTo:create(0.7,cc.p(position[index]['x'],position[index]['y']+70))
			local fadeout = cc.FadeOut:create(0.7)
			local spawn   = cc.Spawn:create(move,fadeout)
			num:runAction(spawn)

			-- bm.User.chips[uid] = v["chips"]
			-- 更新玩家金币
			local num_chips = UiCommon:numFormat(v["chips"])
			user_node:getChildByName("gold"):setString(num_chips)--设置金币数
		end
	end
end

--聊天内容
function MenjiroomView:chatContent(uid,str)
	--body
	local user_node = MenjiroomView:getUserNode(uid)
	if user_node == nil then
		return
	end
	local  position = {
		[0] = {
			['x'] = 131.45,
			['y'] = 120.93,
		},
		[1] = {
			['x'] = 131.45,
			['y'] = 120.93,
			
		},
		[2] = {
			['x'] = 131.45,
			['y'] = 120.93,
			
		},
		[3] = {
			['x'] = -30.07,
			['y'] = 127.94,
			
		},
		[4] = {
			['x'] = -30.07,
			['y'] = 127.94,
		},
	}


	local index     = MenjiroomView:getIndex(uid)
	local file      = "chat_bubble_l1.png"

	if index == 3 or index == 4 then 
		file = "chat_bubble_r1.png"
	end


	local len       = #str
	local length    = 50*len/3
	local rlen      = 0 

	local start_x = 0

	if length < 100 then
		rlen = 100
	else
		rlen=length+20
		start_x = 22/3*(len/3)
	end

	
	start_x = start_x  + (rlen - length)/2


	local bi_back   = user_node:getChildByName("chat")
	if bi_back ~= nil then
		bi_back:removeSelf()
	end
	
	bi_back   = display.newScale9Sprite("zhajinhua/res/room/chatExpress/"..file,0,0,cc.size(rlen,90),cc.rect(20,10,220,50))
	bi_back:addTo(user_node)
	bi_back:setName("chat")
	bi_back:setCascadeOpacityEnabled(true)
  

	local text  = bi_back:getChildByName("font")
	if text ~= nil then
		text:removeSelf()
	end
	text  = cc.ui.UILabel.new({text = str, size = 30, color = cc.c3b(20, 30, 10)})
	text:addTo(bi_back)
	text:setName("font")
	text:pos(10+start_x,50)
	bi_back:pos(position[index]['x'],position[index]['y'])

	bi_back:setScale(0.5)

	local fadeout = cc.FadeOut:create(2)
	bi_back:runAction(fadeout)

end
--全压
function MenjiroomView:showAllin()
	local scenes  = SCENENOW["scene"].view._view
	local effect_all=scenes:getChildByName("effect_all")
	if effect_all then
		effect_all:setLocalZOrder(10)
		effect_all:setVisible(true)
		-- PK光
		local pk_light = display.newSprite("zhajinhua/res/room/compareCard/light01.png")
		pk_light:setBlendFunc(cc.blendFunc(gl.SRC_ALPHA, gl.ONE))
		pk_light:addTo(effect_all, 4)
		pk_light:setPosition(32.35, 38.82)
		local mt = cc.MoveTo:create(0.4, cc.p(128.14, 34.05))
		local callback           = cc.CallFunc:create(function()
			pk_light:removeSelf()
		end)
		local sq=cc.Sequence:create(mt, callback)
		pk_light:runAction(sq)
	end
end
--结算清理
function  MenjiroomView:clearDesk()
	bm.Room.now_turns = 1
	for k,v in pairs(bm.Room.uid_seat) do
		local user_node = MenjiroomView:getUserNode(k)
		if user_node then
			local gold_back = user_node:getChildByName("gold_back")
			if gold_back ~= nil then
				gold_back:removeSelf()
			end
			local card_kan=user_node:getChildByName("card_kan")
			if card_kan ~= nil then
				card_kan:removeSelf()
			end

			local kanpai = user_node:getChildByName("kanpai")
			if kanpai ~= nil then
				kanpai:removeSelf()
			end


			local qipai = user_node:getChildByName("qipai")
			if qipai ~= nil then
				qipai:removeSelf()
			end

			local card_node = user_node:getChildByName("card_node")
			if card_node ~= nil then
				card_node:removeSelf()
			end

			local failed = user_node:getChildByName("failed")
			if failed ~= nil then
				failed:removeSelf()
			end
		end

	end
	local scenes  = SCENENOW["scene"].view._view
	local info_node = scenes:getChildByName("info_node")
	if info_node~= nil then
		info_node:removeSelf()
	end
	local user_my_node = MenjiroomView:getUserNode(tonumber(UID))
	if user_my_node then
		local card_kan=user_my_node:getChildByName("card_kan")
		if card_kan~=nil then
			card_kan:removeSelf()
		end
	end

	local accountScene=scenes:getChildByName("accountScene")
	if accountScene~= nil then
		accountScene:removeSelf()
	end
	if bm.Room.seatProgressTimer ~= nil then
		if bm.Room.seatProgressTimer:getParent() then
			bm.Room.seatProgressTimer:removeSelf()
		end
		bm.Room.seatProgressTimer = nil
	end
	local cards_look=scenes:getChildByName("cards_look")
	if cards_look~=nil then
		cards_look:setVisible(false)
	end
	local effect_all=scenes:getChildByName("effect_all")
	if effect_all~=nil then
		effect_all:setVisible(false)
	end
	bm.User.Cards     = {}
    bm.User.isKan     = {} --玩家是否看牌
    bm.User.isDiu     = {} --玩家是否弃牌
    bm.Room.anim      = 0
    bm.Room.chips     = {}
    bm.Room.zhus      = {}

    bm.SchedulerPool:clearAll()

end

-- 显示庄的位置
function MenjiroomView:showBanker(sid)
	print("showBanker sid", tostring(sid))
	local uid = bm.Room.seat_uid[sid]
	local user_node = MenjiroomView:getUserNode(uid)
	if user_node == nil then
		print("showBanker can't get user_node")
		return
	end
	local index     = MenjiroomView:getIndex(uid)
	local offset_x = 0
	if index == 3 or index == 4 then
		offset_x = 30 - user_node:getContentSize().width
	end

	local banker = display.newSprite("zhajinhua/res/banker.png")
	banker:addTo(user_node, 100)
	dump(user_node:getContentSize(), "showBanker user_node", nesting)
	banker:setPosition(cc.p(user_node:getContentSize().width - banker:getContentSize().width/2 + offset_x, user_node:getContentSize().height - banker:getContentSize().height/2))

	bm.Room.banker = banker
end

return MenjiroomView