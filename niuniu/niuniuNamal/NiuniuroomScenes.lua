-- 获取操作类
local NiuniuroomHandle  = require(TpackageName..".niuniuNamal.NiuniuroomHandle")
-- 获取服务类
local NiuniuroomServer  = require(TpackageName..".niuniuNamal.NiuniuroomServer")
-- 获取协议类
local PROTOCOL = import("niuniu.Niuniu_Protocol")

-- 过金币
local bShowAddCoin = false
local fTimeDrawCoins = 0
local sum_tick_time = 30
local sum_tick_10 = 10

local NiuniuroomScenes = class("NiuniuroomScenes", function()
    return display.newScene("NiuniuroomScenes")
end)

-- 界面初始化
function NiuniuroomScenes:ctor()

	local view
    if device.platform == "ios" then
        view = cc.CSLoader:createNode(cc.FileUtils:getInstance():getWritablePath() .. TpackageName.."/room_new.csb"):addTo(self)
    else
        view = cc.CSLoader:createNode(TpackageName.."/room_new.csb"):addTo(self)
    end

    if device.platform=="android"  then
        if _G.notifiLayer.rootNode then
            _G.notifiLayer.rootNode:setPositionY(_G.notifiLayer.rootNode:getPositionY() + 5)  --电量显示
        end
    end
	self._scene           = view
	self._room_x          = 0
	self._room_y          = 0

	self._is_click_normal = 0

	bm.User = {}  --用户信息
	bm.Room = {}  --房间信息

	self.tbWin = {}
	self.koufeng = {}

	self.isspectator = false

	-- 设置协议对应的处理类
	bm.server:setHandle(NiuniuroomHandle.new())

	-- 记录为当前正在运行的界面
	bm.runScene = self;

	-- 初始化准备标记
	self.send_ready_flag = false

	-- 初始化所有图标
	self:ini_all_icon()

	-- 显示自己
    self:show_player(0,true)

    self.leave_style = 0

    local time_str = view:getChildByName("Text_1")
    time_str:setVisible(false)

	-- 退出房间
    local btn_quit = view:getChildByName("quit")
    btn_quit:addTouchEventListener(
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
                                if bm.Room and tonumber(bm.Room.start_group) == 1 then
                                    require("hall.GameTips"):showTips("提示", "", 2, "游戏已经开始，不能返回大厅")
                                else
                                    local function okCallback()
                                        if bm.notCheckReload and bm.notCheckReload ~= 1 then
                                            bm.notCheckReload = 1
                                            NiuniuroomServer:quickRoom()
                                        else
                                        end
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

    --隐藏菜单按钮
    local btn_menu = view:getChildByName("menu")
    btn_menu:setVisible(false)

    --菜单
    local menu = view:getChildByName("menu")
    menu:setVisible(false)

    --房间号
    local room_id = view:getChildByName("room_id")
    room_id:setString("房间号：" .. USER_INFO["invote_code"])

    --房间信息
    local gameConfig_tt = view:getChildByName("gameConfig_tt")
    gameConfig_tt:setString(USER_INFO["gameConfig"])

    -- 设置
    local setting = view:getChildByName("setting")
    -- setting:setVisible(false)
	setting:addTouchEventListener(
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

                dump("", desciption, nesting)

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
    )

    --邀请微信好友
    local invite_ly = view:getChildByName("invite_ly")
    if bm.round > 0 then
        invite_ly:setVisible(false)
    end
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
                
                require("hall.common.ShareLayer"):showShareLayer("斗牛，房号：" .. USER_INFO["invote_code"], "https://a.mlinks.cc/AK3b", "url", share_content)
            
            end
        end
    )

    --解散房间按钮
    local disband_ly = view:getChildByName("disband_ly")
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

    --录像按钮
    local btn_record = view:getChildByName("btn_record")
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

                require("hall.recordUtils.RecordUtils"):showRecordFrame(cc.p(480, 270), cc.size(264, 218), USER_INFO["activity_id"])

            end
        end
    )

    --文字聊天界面
    local faceUI = require("hall.FaceUI.faceUI")
    local sendHandle = require("niuniu.niuniuNamal.NiuniuroomServer")
    local faceUI_node = faceUI.new();
    faceUI_node:setHandle(sendHandle)
    self:addChild(faceUI_node, 9999)
    faceUI_node:setName("faceUI")

    --聊天按钮
    local btn_msg = view:getChildByName("btn_msg")
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
                faceUI_node:showTxtPanle(cc.p(sender:getPositionX()-50,sender:getPositionY()+50),8)
                print("聊天按钮")
                local userData = {}
                userData["uid"] = tonumber(UID)
                userData["nickName"] = USER_INFO["nick"]
                userData["invote_code"] = USER_INFO["invote_code"]
                userData["msgType"] = "voice"
                userData["voiceTime"] = "3"
                userData["url"] = ""

                if userData ~= nil then
                    local PROTOCOL = import("hall.HALL_PROTOCOL")
                    if PROTOCOL ~= nil then
                        local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_CMD_SEND_MSG_TO_SERVER)
                                    :setParameter("level", USER_INFO["GroupLevel"])
                                    :setParameter("msg", json.encode(userData))
                                    :build()
                        if pack ~= nil then
                            bm.server:send(pack)
                            print("发消息")
                        end
                    end
                end


            end

        end
    )

    -- --底分
    -- local panel = self._scene:getChildByName("difeng_base")
    -- local ddd_1 = panel:getChildByName("ddd_1")
    -- local Sprite_9 = panel:getChildByName("Sprite_9")
    -- local Sprite_9_0 = panel:getChildByName("Sprite_9_0")
    -- local text_difeng = panel:getChildByName("text_difeng")

    -- ddd_1:setVisible(false)
    -- Sprite_9:setVisible(false)
    -- Sprite_9_0:setVisible(false)
    -- text_difeng:setVisible(false)

    -- if bm.round > 0 then
    --     ddd_1:setVisible(true)
    --     Sprite_9:setVisible(true)
    --     Sprite_9_0:setVisible(true)
    --     text_difeng:setVisible(true)
    -- else
    --     ddd_1:setVisible(false)
    --     Sprite_9:setVisible(false)
    --     Sprite_9_0:setVisible(false)
    --     text_difeng:setVisible(false)
    -- end
    
    --更新线程
    local function update(dt)
    	if self then
    		self:update_10(dt)
			self:update_30(dt)
        	self:updateDrawCoin(dt)
    	end
    end

    self:scheduleUpdateWithPriorityLua(update,0)

--chenhaiquan code 用来创建带阴影效果的ttf字体
 --    local str = "80000000"
 --    local params =
 --    {
 --    	text = str,
	--     font = "res/fonts/wryh.ttf",
	--     size = 20,
	--     color = cc.c3b(255,255,0), 
	--     align = cc.TEXT_ALIGNMENT_LEFT,
	--     valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
	-- }
 --    local niu_txt = display.newTTFLabel(params)
 --    niu_txt:enableShadow(cc.c4b(255,255,0,255), cc.size(1,0))

 --    self._scene:addChild(niu_txt)
 --    niu_txt:setPositionX(480)
 --    niu_txt:setPositionY(270)
 	--test code

 	local playerlist = {
    	{add_chips = 100,chips = 200 ,nick_name = "chen1"},
    	{add_chips = 100,chips = 200 ,nick_name = "chen2"},
    	{add_chips = 100,chips = 200 ,nick_name = "chen3"},
	}

	--local group_game_amount = 12
 	--self:showRanking(playerlist,group_game_amount)
 	
 
 	--0是表示从大厅进入，非0表示用组局模式进入s	 
  	local layout_group = view:getChildByName("Panel_2"):getChildByName("layout_group")
 	view:getChildByName("Panel_2"):setVisible(false)
 	
    --记录是否显示组局时间
 	self.bShowGroupTime = false

    --记录是否需要发送准备信息
 	self.need_send_ready_msg = false

 	--显示组局相关信息
 	self:show_groud_mode()

    --获取用户筹码
    self:getChips()

	--播放背景音乐
	audio.playMusic(NIUNIU_BG_SOUND,true)

 --    --预先加载部分声音特效
	-- audio.preloadSound(NIUNIU_FAPAI_SOUND)


	-- --牛牛发牌特效
	-- audio.playSound(NIUNIU_FAPAI_SOUND,false)

	-- USER_INFO["start_time"] = os.time()
 --    USER_INFO["group_lift_time"] = 3670
 --    self:set_update_group_time_flag(true)

    --发送我的组局信息（地理位置）
    local userData = {}
    userData["uid"] = tonumber(UID)
    userData["nickName"] = USER_INFO["nick"]
    userData["invote_code"] = USER_INFO["invote_code"]
    if device.platform == "ios" then

        userData["latitude"] = cct.getDataForApp("getLatitude", {}, "string")
        userData["longitude"] = cct.getDataForApp("getLongitude", {}, "string")

    elseif device.platform == "android" then

        local args = {}
        local sigs = "()Ljava/lang/String;"
        local luaj = require "cocos.cocos2d.luaj"
        local className = luaJniClass

        ok,ret  = luaj.callStaticMethod(className,"getLatitude",args,sigs)
        if not ok then
            print("luaj error:", ret)
        else
            userData["latitude"] = ret
        end

        ok,ret  = luaj.callStaticMethod(className,"getLongitude",args,sigs)
        if not ok then
            print("luaj error:", ret)
        else
            userData["longitude"] = ret
        end

    else

        userData["latitude"] = "10.00"
        userData["longitude"] = "10.00"

    end
    require("niuniu.niuniuNamal.NiuniuroomServer"):SendGameMsg(USER_INFO["GroupLevel"], json.encode(userData))

    for i = 0, 4 do
        local palyer_panel_ = self._scene:getChildByName("palyer_panel_"..tostring(i))
        if palyer_panel_ then
            local zuan_icon = palyer_panel_:getChildByName("gold")
            if zuan_icon then
                local lable = ccui.TextBMFont:create("", "hall/proxy/image/num.fnt")
                lable:setName("gold")
                -- if i == 0 then
                    lable:setScale(0.5)
                -- else
                --     lable:setScale(0.5)
                -- end
                lable:addTo(zuan_icon:getParent())
                lable:setPosition(zuan_icon:getPosition())
                zuan_icon:removeSelf()
            end
        end
    end
end

------------------------------------------------------------------------------------------------------------------------------------------
--界面相关
function NiuniuroomScenes:onEnter()

    dump("", "-----进入牛牛界面-----")

    bm.IReady = 0
    
end

function NiuniuroomScenes:onExit()

    dump("", "-----退出牛牛界面-----")

    bm.IReady = 0

    audio.stopMusic(true)

end

--发牌界面处理
function NiuniuroomScenes:showAndHide()

    dump("showAndHide", "-----showAndHide1-----")

    -- --隐藏邀请微信好友
    -- local invite_ly = self._scene:getChildByName("invite_ly")
    -- invite_ly:setVisible(false)

    -- --显示录制按钮
    -- local btn_record = self._scene:getChildByName("btn_record")
    -- btn_record:setVisible(true)

    -- --添加视频引导
    -- require("hall.leader.LeaderLayer"):showLeaderLayer(cc.p(897.00, 166.00))

end

--显示组局相关信息
function NiuniuroomScenes:show_groud_mode()

    --显示组局界面
    local view = self._scene 
    local layout_group = view:getChildByName("Panel_2"):getChildByName("layout_group")
    view:getChildByName("Panel_2"):setVisible(false)
    view:getChildByName("Panel_2"):setTouchEnabled(true)
    view:getChildByName("Panel_2"):onClick(function(event)
        view:getChildByName("Panel_2"):setVisible(false)
    end)
    --layout_group:setVisible(false)
    layout_group:setLocalZOrder(2000)
    self.layout_group = layout_group

    --local toolbarBg_spr = view:getChildByName("toolbarBg_spr")sssss

    --隐藏菜单按钮
    local btn_menu = view:getChildByName("menu")
    btn_menu:setVisible(false)
    btn_menu:onClick(function ( )
        -- body
        --btn_menu:setTouchEnabled(false)
        view:getChildByName("Panel_2"):setVisible(true)
        layout_group:setScale(0.15)
        self.layout_group:setVisible(true)

        local action_scall1 = cc.ScaleTo:create(0.2,1)
        self.layout_group:runAction(action_scall1)

        if layout_group then
            local btnLook = layout_group:getChildByName("btn_sideSee")
            local btnAddChip = layout_group:getChildByName("btn_addBet")
            local btnHistory = layout_group:getChildByName("btn_records")
            local btnExitGroup = layout_group:getChildByName("btn_exitGroup")

            local function groupTouchEvent(sender, event)
                --缩小ui
                if event == TOUCH_EVENT_BEGAN then
                    --require("hall.GameCommon"):playEffectSound("ddz/audio/Audio_Button_Click.mp3")
                    sender:setScale(0.9)
                end

                if event == TOUCH_EVENT_ENDED then
                    sender:setScale(1)

                    local make_effect = false
                    if sender == btnLook then
                    end

                    if sender == btnAddChip then--添加筹码
                       -- USER_INFO["score"] = 1000 
                        require("hall.GameCommon"):showChange(true)
                        make_effect = true
                    end

                    if sender == btnHistory then--历史记录
                        require("hall.GameCommon"):getHistory()--不知道这消息能不能共用
                        --require("hall.GameCommon"):showHistory(true)

                        make_effect = true
                    end

                    --退出组局
                    if sender == btnExitGroup then--退出牌局
                        if bm.Room.Status == 3 then
                            require("hall.GameTips"):showTips("游戏已开始，不能退出")
                        -- elseif state_player == 4 then
                        --     require("hall.GameCommon"):gExitGroupGame(5) --退出组局
                        else
                           -- NiuniuroomServer:quickRoom()
                        end
                        make_effect = true
                    end

                    if make_effect == true then
                    --  btn_menu:setTouchEnabled(true)
                        local action_scaleto = cc.ScaleTo:create(0.2,0.01)
                        local action_hide = cc.Hide:create()
                        local action_sequence = cc.Sequence:create(action_scaleto,action_hide)
                        self.layout_group:runAction(action_sequence)
                        view:getChildByName("Panel_2"):setVisible(false)
                    end

                end
            end

            btnLook:addTouchEventListener(groupTouchEvent)--进入自由场
            btnAddChip:addTouchEventListener(groupTouchEvent)--进入自由场
            btnHistory:addTouchEventListener(groupTouchEvent)--进入自由场
            btnExitGroup:addTouchEventListener(groupTouchEvent)--进入自由场
        end

    end)

end

--获取用户播放录音位置
function NiuniuroomScenes:getPosforSeat(uid)
    return bm.Room.ShowVoicePosion[uid]
end

function NiuniuroomScenes:ini_all_icon( )

    for index = 0,4 do

      self:set_player_info_visible(index,"head",false)
      self:set_player_info_visible(index,"head_kuang",false)
      self:set_player_info_visible(index,"gold",false)
      self:set_player_info_visible(index,"sex",false)
      self:set_player_info_visible(index,"name",false)

      self:set_player_info_visible(index,"zang",false)
      self:set_player_info_visible(index,"beitxt",false)
      self:set_player_info_visible(index,"chouma_me_14",false)

      self:set_player_info_visible(index,"Sprite_18",false)
      self:set_player_info_visible(index,"Sprite_19",false)
      self:set_player_info_visible(index,"ready_sp",false)

      self:show_qiangfeng_txt(index,false)

    end

    for index = 1,4 do
        self:show_other_panel_ready_ex(index,false)
        --self:show_bei_score_txt(index,false)
    end

    local panel = self._scene:getChildByName("niu_tip")
    local btn_youniu =  panel:getChildByName("btn_youniu")
    local btn_meiniu =  panel:getChildByName("btn_meiniu")
    btn_youniu:setVisible(false)
    btn_meiniu:setVisible(false)
    -- neo 修改坐标
    if btn_youniu then
        btn_youniu:setPositionY(btn_youniu:getPositionY() - 80)
    end

    self:show_over_layout(false)
    self:show_niu_tip(false)
    self:show_qiangfeng(false)
    self:show_difeng_base(false)
    self:show_qiangzang(false)
    self:show_panel_ready(false)
    --self:set_recent_txt_visible(false)
    local  recent_txt = self._scene:getChildByName("recent_txt")
    recent_txt:setVisible(false)


    -- self:set_niu_feng(1,0)
    -- self:set_niu_feng(2,0)
    -- self:set_niu_feng(3,0)
    -- self:set_sum_feng(0)
    self:hide_qiangzuang()


    self:set_win_txt_visible(0,false)
    self:set_win_txt_visible(1,false)
    self:set_win_txt_visible(2,false)
    self:set_win_txt_visible(3,false)
    self:set_win_txt_visible(4,false)


    self:hide_bei_relatice(1,false)
    self:hide_bei_relatice(2,false)
    self:hide_bei_relatice(3,false)
    self:hide_bei_relatice(4,false)

    local panel = self._scene:getChildByName("difeng_base")
    local timer_2 = panel:getChildByName("timer_2")
    timer_2:setVisible(false)
    local text_center = panel:getChildByName("text_center")
    text_center:setVisible(false)

end

------------------------------------------------------------------------------------------------------------------------------------------
--界面更新相关

--检查网络（现屏蔽）
function NiuniuroomScenes:update_10(dt)

    sum_tick_10 = sum_tick_10 + dt
    if sum_tick_10 > 10 then
        --self:check_network()
        sum_tick_10 = 0
    end

end

--检查网络
function NiuniuroomScenes:check_network()

    --print("..........cc.kCCNetworkStatusNotReachable......net_state....",cc.kCCNetworkStatusNotReachable,"----",net_state)

    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if  cc.PLATFORM_OS_WINDOWS  ~= targetPlatform then

        local net_state = network.getInternetConnectionStatus()
        if cc.kCCNetworkStatusNotReachable == net_state  then
            -- 创建一个居中对齐的文字显示对象

            if self:getChildByName("net_state") == nil then
                local label = cc.Label:createWithTTF("无法访问互联网", "fonts/wryh.ttf", 32)
                self:addChild(label, 2000)
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

--设置是否更新组局时间
function NiuniuroomScenes:set_update_group_time_flag(falg)

    self.bShowGroupTime = falg

end

--更新组局显示时间
function NiuniuroomScenes:update_30(dt)

    -- self:updateGroupTime()

    -- sum_tick_time = sum_tick_time+dt
    -- if sum_tick_time > 30 then
    --     if bm.runScene.set_time_str ~= nil then
    --         bm.runScene:set_time_str()
    --     end 
    --     sum_tick_time = 0
    -- end

end

--更新组局时间
function NiuniuroomScenes:updateGroupTime()

    -- body
    if USER_INFO["enter_mode"] == 0 then 
        return
    end

    if self.bShowGroupTime == true then

        local turnSeconds = os.time()-USER_INFO["start_time"]
        local leftSeconds = USER_INFO["group_lift_time"] - turnSeconds
        local seconds = leftSeconds % 60
        local minutes = math.modf(leftSeconds/60)
        local hours = math.modf(minutes/60)
        minutes = minutes % 60
        local time = string.format("%02d:%02d:%02d",hours,minutes,seconds)

        local txtTime = self._scene:getChildByName("lb_time")

        if txtTime == nil then
            txtTime = cc.Label:createWithTTF("00:00:00", "fonts/wryh.ttf", 24)
            self._scene:addChild(txtTime,30)
            txtTime:setAnchorPoint(cc.p(1,0))
            txtTime:setPosition(cc.p(900,10))
            txtTime:setColor(cc.c3b(0,255,124))
            txtTime:enableShadow(cc.c4b(47,47,47,255),cc.size(1,0))
            txtTime:setName("lb_time")
        end

        if turnSeconds >= USER_INFO["group_lift_time"] then
            txtTime:setString("00:00:00")
            txtTime:setColor(cc.c3b(255,0,0))
            txtTime:enableShadow(cc.c4b(255,0,0,255),cc.size(1,0))
            return
        end

        if txtTime then
            txtTime:setString(time)
            if hours == 0 and minutes < 10 then
                txtTime:setColor(cc.c3b(255,0,0))
                txtTime:enableShadow(cc.c4b(255,0,0,255),cc.size(1,0))
            else
                txtTime:setColor(cc.c3b(0,255,124))
                txtTime:enableShadow(cc.c4b(0,255,124,255),cc.size(1,0))
            end
        end
    end

end

function NiuniuroomScenes:set_time_str()

    --移除重登loading
    local reloadloading = SCENENOW["scene"]:getChildByName("loading")
    if reloadloading then
       reloadloading:removeSelf()
    end

    -- body
    local time_str = self._scene:getChildByName("Text_1")
    if time_str ~= nil then

        -- local str = os.date()
        -- local now_str_a;
        -- local newArr=string.split(str," ")
        -- if device.platform~="windows" then
        --     now_str_a=newArr[#newArr-1]
        -- else
        --     now_str_a=newArr[#newArr]
        -- end

        --         -- local str = os.date()
        --         -- local now_str_a;
        --         -- if device.platform~="windows" then
        --         --  now_str_a=(string.split(str," "))[4]
        --         -- else
        --         --  now_str_a=(string.split(str," "))[2]
        --         -- end


        --         -- print(str,"this.timer")
        --         now_str_a=string.split(now_str_a,":")
        --         local now_str=now_str_a[1]..":"..now_str_a[2]
        --         --local now_str = string.sub(str,10,14)
        --         time_str:setString(now_str)
                
                
        -- local str = os.date()
  --    local now_str = string.sub(str,10,14)
        -- time_str:setString(now_str)

        time_str:setVisible(true)
        time_str:setString("第" .. tostring(bm.round+1) .. "/" .. tostring(bm.round_total) .. "局")


    end

end

------------------------------------------------------------------------------------------------------------------------------------------
--用户相关
--显示玩家（弃用）
function  NiuniuroomScenes:showPlayer(index_t,info)

    -- if index_t == 1 then
    --  local nick      = self._scene:getChildByTag(50)
    --  local img_back  = self._scene:getChildByTag(65)
    --  local head      = self._scene:getChildByTag(66)
    --  local gold_back = self._scene:getChildByTag(69)
    --  local gold_num  = self._scene:getChildByTag(71)

    -- else
    --  local nick      = self._scene:getChildByTag(50):clone():addTo(self)
    --  local img_back  = self._scene:getChildByTag(65):clone():addTo(self)
    --  local head      = self._scene:getChildByTag(66):clone():addTo(self) 
    --  local gold_back = self._scene:getChildByTag(69):clone():addTo(self) 
    --  local gold_num  = self._scene:getChildByTag(71):clone():addTo(self)

    --  if index_t ~= nil then
    --      local p_index =  index_t -1
    --      nick:setPositionX(nick:getPositionX() + 150*p_index)
    --      img_back:setPositionX(img_back:getPositionX() + 150*p_index)
    --      head:setPositionX(head:getPositionX() + 150*p_index)
    --      gold_back:setPositionX(gold_back:getPositionX() + 150*p_index)
    --      gold_num:setPositionX(gold_num:getPositionX() + 150*p_index)
    --  end

    -- end

    -- nick:setString(info.o_user_detail.nick)
    -- gold_num:setString(info.o_user_gold)
    
end

--设置玩家信息
function NiuniuroomScenes:set_player_info(player_index,iocn_str,content_txt)

    local panel = self._scene:getChildByName("palyer_panel_"..tostring(player_index-1))
    if panel == nil then
        print("-----设置玩家信息异常-----",player_index,iocn_str,content_txt)
        return
    end

    local name = panel:getChildByName(iocn_str)
    name:setString(tostring(content_txt))

end



--显示玩家信息
function NiuniuroomScenes:set_player_info_visible(player_index,name_str,visible_flag)

    local panel = self._scene:getChildByName("palyer_panel_" .. tostring(player_index))
    if panel == nil then

        -- local str  = "palyer_panel_"..tostring(player_index-1)
        -- printError(str)

        print("-----显示玩家信息异常-----",player_index,iocn_str,content_txt)
        return
    end

    local name = panel:getChildByName(name_str)
    if name == nil then
        -- printInfo("icon is nil ===========set_player_info_visible================name")
        -- printInfo(name_str)

        dump("", "-----显示玩家名称异常-----")
        return
    end

    name:setVisible(visible_flag)

end

--显示隐藏用户
function NiuniuroomScenes:show_player(palyer_index,flag)

    self:set_player_info_visible(palyer_index,"head",flag)
    self:set_player_info_visible(palyer_index,"head_kuang",flag)
    self:set_player_info_visible(palyer_index,"gold",flag)
    self:set_player_info_visible(palyer_index,"sex",false)
    self:set_player_info_visible(palyer_index,"name",flag)
    self:set_player_info_visible(palyer_index,"chouma_me_14",flag)
    self:set_player_info_visible(palyer_index,"Sprite_18",false)
    self:set_player_info_visible(palyer_index,"Sprite_19",false)
    self:set_player_info_visible(palyer_index,"ready_sp",false)

end

--设置玩家名字
function NiuniuroomScenes:set_player_name(player_index,name_str)

    local  palyer_panel_ = self._scene:getChildByName("palyer_panel_"..tostring(player_index))
    local  zuan_icon = palyer_panel_:getChildByName("name")
    zuan_icon:setString(name_str)

end

--设置玩家头像
function NiuniuroomScenes:set_player_icon(player_index,icon_url,sex,uid,nick)

    local url = icon_url or ""

    local palyer_panel_ = self._scene:getChildByName("palyer_panel_"..tostring(player_index))
    if palyer_panel_ ~= nil then
        local head = palyer_panel_:getChildByName("head")
        if head ~= nil then
            if url ~= nil and url ~= "" then
                require("hall.GameCommon"):getUserHead(url,uid,sex,head,81,true,nick)
            end
        end
    end

    self:set_player_sex(player_index,sex)

end

--设置玩家性别
function NiuniuroomScenes:set_player_sex(player_index,sex )

    local  palyer_panel_ = self._scene:getChildByName("palyer_panel_"..tostring(player_index))
    local sex_icon = palyer_panel_:getChildByName("sex")

    print("showPlaySex",type(sex),sex)
    if tonumber(sex) == 1 then
        print("bukexuea")
        sex_icon:loadTexture("niuniu/newimage/sex_nan.png")
    else
        sex_icon:loadTexture("niuniu/newimage/sex_nv.png")
    end

end

--退出房间
function NiuniuroomScenes:quickRoom()

    dump("", "-----退出房间-----")

    -- NiuniuroomServer:quickRoom()

end

------------------------------------------------------------------------------------------------------------------------------------------
--筹码相关
--请求获取服务器筹码
function NiuniuroomScenes:getChips()

    dump("", "-----发送获取服务器筹码806-----")

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_GET_CHIP)
    :setParameter("uid", tonumber(UID))
    :build()
    bm.server:send(pack)

end

--获取筹码返回
function NiuniuroomScenes:onNetGetChip(pack)
    dump(pack,"获取筹码返回")
    USER_INFO["chips"] = pack["chip"]
    --self:displayMine()

    --显示用户筹码
    self:set_player_gold(0, tostring(USER_INFO["chips"]))

    -- if bm.Room.Status ~= 3 then
    --     --检查筹码是否足够
    --     if require("hall.common.GroupGame"):checkChips() then
    --         --发送准备消息
    --         --if isReload == false then
    --             --require("ddz.ddzServer"):CLI_READY_GAME()
    --             -- NiuniuroomServer:readyNow()
    --             --发送准备消息后，隐藏准备按钮
    --             --self:ready()
    --         --end
    --     else
    --         require("hall.GameCommon"):showChange(true)
    --     end
    -- end

    -- self:ready()

    -- --发送准备消息
    -- NiuniuroomServer:readyNow(1)
    
    -- self.need_send_ready_msg = false

    -- self:show_panel_ready(true);

end

--更新自己筹码
function NiuniuroomScenes:goldUpdate()

    dump(USER_INFO["gold"], "-----更新自己筹码-----")

    self:set_player_gold(0,USER_INFO["gold"])
    
end

--设置其他玩家筹码
function NiuniuroomScenes:set_player_gold(player_index,gold_num)

    dump(player_index, "-----设置其他玩家筹码-----")
    dump(gold_num, "-----设置其他玩家筹码-----")
    local chips = tonumber(gold_num) - USER_INFO["group_chip"]
    print("set_player_gold", tostring(chips))

    local palyer_panel_ = self._scene:getChildByName("palyer_panel_"..tostring(player_index))
    local zuan_icon = palyer_panel_:getChildByName("gold")
    if not tolua.isnull(palyer_panel_:getChildByName("duanxian")) then  --移除断线标志
        palyer_panel_:removeChildByName("duanxian")
    end
    zuan_icon:setString(chips)

    -- if player_index == 0 then

    --     local  palyer_panel_ = self._scene:getChildByName("palyer_panel_"..tostring(player_index))
    --     local  zuan_icon = palyer_panel_:getChildByName("gold")
    --     zuan_icon:setVisible(false)

    --     local layer_num = palyer_panel_:getChildByName("layer_num")
    --     if layer_num ~= nil then
    --         layer_num:removeSelf()
    --     end

    -- --  gold_num = 24000
    --     local x = zuan_icon:getPositionX()
    --     local y = zuan_icon:getPositionY()
    --     local layer_num = require("hall.GameCommon"):showNums(gold_num,cc.c3b(125,125,125),true)
    --     palyer_panel_:addChild(layer_num)
        
    --     layer_num:setAnchorPoint(cc.p(0.0,0.5))
    --     layer_num:setPositionX(460.47)
    --     layer_num:setPositionY(26.86)
    --     layer_num:setName("layer_num")


    --     USER_INFO["gold"] = gold_num

    -- else
    --     local  palyer_panel_ = self._scene:getChildByName("palyer_panel_"..tostring(player_index))
    --     local  zuan_icon = palyer_panel_:getChildByName("gold")
    --     zuan_icon:setString(gold_num)
    -- end

end

--开始更新金币
function NiuniuroomScenes:update_begin_flag()

    -- fTimeDrawCoins = 0
    -- bShowAddCoin = true
    self:show_table_ticket()

end

--更新用户筹码
function NiuniuroomScenes:show_table_ticket()

    local node_base = display.newNode()

    --local pos_player = {{379.79,44.23},{64.03,181.00},{187.72,347.11},{547.57,346.21},{702.06,181.39}}

    -- for palyer_index = 0 ,4 do

    --     local fengshu = self.koufeng[palyer_index]

    --     if self.tbWin[palyer_index] ~= nil and fengshu ~= nil and fengshu ~= 0 then

    --         --local str = "-500"
    --         local txtWin = self._scene:getChildByName("txtwin"..tostring(palyer_index))
    --         txtWin_x = txtWin:getPositionX()
    --         txtWin_y = txtWin:getPositionY()

    --      --    local params =
    --      --    {
    --      --     text = "-" .. tostring(fengshu),
    --         --     font = "res/fonts/wryh.ttf",
    --         --     size = 30,
    --         --     color = cc.c3b(255,255,0), 
    --         --     align = cc.TEXT_ALIGNMENT_LEFT,
    --         --     valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
    --         -- }
    --      --    local niu_txt = display.newTTFLabel(params)
    --      --    niu_txt:enableShadow(cc.c4b(255,255,0,255), cc.size(1,0))
    --      --    if USER_INFO["enter_mode"] == 0 then
    --      --     node_base:addChild(niu_txt)
    --         -- end

    --      --    niu_txt:setPositionX(txtWin_x)
    --      --    niu_txt:setPositionY(txtWin_y)   
           
    --      --    --local action_move = cc.MoveBy:create(1,cc.size(0,20))
    --         -- local action_fadeout = cc.FadeOut:create(1)
    --         -- --local spawn = cc.Sequence:create(action_move,action_fadeout)
    --         -- niu_txt:runAction(action_fadeout)

    --     end
    -- end

    self.koufeng = {}
    self._scene:addChild(node_base)
    node_base:setLocalZOrder(10010)

    local action_deley = cc.DelayTime:create(1.0)
    local action_call = cc.CallFunc:create(function ()

        -- body
        self:create_gold_num_new_txt()
        fTimeDrawCoins = 0
        bShowAddCoin = true
        --printInfo("----------------CallFunc------------------------------------------")

    end)

    local action_removeself = cc.RemoveSelf:create()
    local spawn = cc.Sequence:create(action_deley,action_call,action_removeself)
    node_base:runAction(spawn)

end

function NiuniuroomScenes:create_gold_num_new_txt()

    --获取庄位置
    local zhuan_index = NiuniuroomHandle:getIndex(bm.Room.Zid)
    if zhuan_index == nil then
        zhuan_index = 0
    end

    dump(zhuan_index, "-----庄家座位-----")

    --庄家输赢情况
    local isZhuanWin = 0
    for player_index,value in pairs(self.tbWin) do
        if player_index ~= zhuan_index then
            if value < 0 then
                isZhuanWin = 1
            end
        end
    end
    if isZhuanWin == 0 then
        dump("庄输", "-----庄家输赢情况-----")
    else
        dump("庄有赢", "-----庄家输赢情况-----")
    end

    --玩家数
    local playerCount = #self.tbWin - 1
    dump(playerCount, "-----玩家数-----")

    --显示更新内容（文字和筹码）
    for player_index,value in pairs(self.tbWin) do

        dump(player_index, "-----对应座位-----")
        dump(value, "-----更新筹码数-----")

        --显示更新文字
        local txtWin = self._scene:getChildByName("txtwin"..tostring(player_index))
        txtWin:setVisible(true)
        txtWin:setLocalZOrder(10000)

        local str = ""
        if value > 0 then
            txtWin:setColor(cc.c3b(255,255,255))
            str = "+0"
        else
            txtWin:setColor(cc.c3b(255,0,0))
            str = "-0"
        end
        txtWin:stopAllActions()

        txtWin:setString(str)

        local fi = cc.FadeIn:create(0.5)


        txtWin:runAction(fi)

        --记录每个玩家筹码出现或飞入的位置
        local x = 0
        local y = 0
        if player_index == 0 then
            x = 50.68 
            y = 50.44

        elseif player_index == 1 then
            x = 20.59
            y = 299.34

        elseif player_index == 2 then
            x = 170.39
            y = 445.27

        elseif player_index == 3 then
            x = 707.40
            y = 454.81

        elseif player_index == 4 then
            x = 880.24
            y = 299.65

        end

        --记录庄家筹码出现或飞入的位置
        local zhuang_x = 0
        local zhuang_y = 0
        if zhuan_index == 0 then
            zhuang_x = 50.68
            zhuang_y = 50.44

        elseif zhuan_index == 1 then
            zhuang_x = 20.59
            zhuang_y = 299.34

        elseif zhuan_index == 2 then
            zhuang_x = 170.39
            zhuang_y = 445.27

        elseif zhuan_index == 3 then
            zhuang_x = 707.40
            zhuang_y = 454.81

        elseif zhuan_index == 4 then
            zhuang_x = 880.24
            zhuang_y = 299.65

        end

        --判断当前位置是否为庄
        if player_index == zhuan_index then
            --当前用户是庄家
        
        else
            --当前用户不是庄家

            --添加显示减少的筹码
            if value < 0 then

                --玩家输，筹码从玩家生成，飞向庄家
                dump(zhuang_x, "-----筹码飞动，玩家输，飞向庄家x-----")
                dump(zhuang_y, "-----筹码飞动，玩家输，飞向庄家y-----")

                --计算生成筹码数
                local coin_count = (value * -1) / 5
                if coin_count > 0 and coin_count < 5 then
                    coin_count = 1
                end

                -- coin_count = 10
                if coin_count > 15 then
                   coin_count = 15
                end

                --金币流数
                local coinLiu_count = 5

                for a=0, coinLiu_count do
                    
                    --添加筹码
                    for i=1,coin_count do
                        
                        local coin_sp = cc.Sprite:create("niuniu/newimage/effect_gold.png")
                        coin_sp:setAnchorPoint(0.5, 0.5)
                        coin_sp:setScale(0.5)
                        coin_sp:setPosition(x + 10 * a, y)
                        self._scene:addChild(coin_sp, 100)

                        --筹码飞动
                        -- local mb = cc.JumpTo:create(0.1 + 0.2 * i, cc.p(zhuang_x + 10 * a, zhuang_y), 50, 1)

                        local random = i + 2
                        local delaytime = 0.1 + 0.2 * math.random(random)
                        local mb = cc.JumpTo:create(delaytime, cc.p(zhuang_x + 10 * a, zhuang_y), 50, 1)
                        local fo = cc.FadeOut:create(0.5)

                        local seq = cc.Sequence:create(mb, fo)

                        coin_sp:runAction(seq)

                        local remove_action = cc.Sequence:create(cc.DelayTime:create(delaytime + 0.6),cc.CallFunc:create(function()
                            coin_sp:removeSelf()
                        end))
                        coin_sp:runAction(remove_action)

                    end

                end

                local sound_path = "niuniu/sound/coins_fly_in_short.mp3"
                -- cc.SimpleAudioEngine:getInstance():playEffect(sound_path,false)
                require("hall.VoiceUtil"):playEffect(sound_path,false)

            elseif value > 0 then

                --玩家赢，筹码从庄家生成，飞向玩家

                dump(x, "-----筹码飞动，玩家赢，飞向玩家x-----")
                dump(y, "-----筹码飞动，玩家赢，飞向玩家y-----")
                
                --计算生成筹码数
                local coin_count = value / 5
                if coin_count > 0 and coin_count < 5 then
                    coin_count = 1
                end

                -- coin_count = 10
                if coin_count > 15 then
                   coin_count = 15
                end

                --金币流数
                local coinLiu_count = 5

                --添加筹码
                for a=0, coinLiu_count do
                    
                    for i=1, coin_count do

                        if isZhuanWin == 1 and playerCount > 2 then
                            --庄有赢而且当前玩家数大于2
                            --玩家动画延迟一秒播放
                            local action = cc.Sequence:create(cc.DelayTime:create(2),cc.CallFunc:create(function()

                                local coin_sp = cc.Sprite:create("niuniu/newimage/effect_gold.png")
                                coin_sp:setAnchorPoint(0.5, 0.5)
                                coin_sp:setScale(0.5)
                                coin_sp:setPosition(zhuang_x + 10 * a, zhuang_y)
                                self._scene:addChild(coin_sp, 100)

                                --筹码飞动
                                -- local mb = cc.MoveTo:create(5.0, cc.p(x, y))
                                -- local mb = cc.JumpTo:create(0.1 + 0.2 * i, cc.p(x + 10 * a, y), 50, 1)

                                -- local random = i + 2
                                -- local mb = cc.JumpTo:create(0.1 + 0.2 * math.random(random), cc.p(x + 10 * a, y), 50, 1)
                                -- local fo = cc.FadeOut:create(0.5)

                                -- local seq = cc.Sequence:create(mb, fo)
                
                                local random = i + 2
                                local delaytime = 0.1 + 0.2 * math.random(random)
                                local mb = cc.JumpTo:create(delaytime, cc.p(x + 10 * a, y), 50, 1)
                                local fo = cc.FadeOut:create(0.5)

                                local seq = cc.Sequence:create(mb, fo)
                                coin_sp:runAction(seq)

                                local remove_action = cc.Sequence:create(cc.DelayTime:create(delaytime + 0.6),cc.CallFunc:create(function()
                                    coin_sp:removeSelf()
                                end))
                                coin_sp:runAction(remove_action)

                            end))
                            self._scene:runAction(action)

                        else

                            local coin_sp = cc.Sprite:create("niuniu/newimage/effect_gold.png")
                            coin_sp:setAnchorPoint(0.5, 0.5)
                            coin_sp:setScale(0.5)
                            coin_sp:setPosition(zhuang_x + 10 * a, zhuang_y)
                            self._scene:addChild(coin_sp, 100)

                            --筹码飞动
                            -- local mb = cc.MoveTo:create(5.0, cc.p(x, y))
                            -- local mb = cc.JumpTo:create(0.1 + 0.2 * i, cc.p(x + 10 * a, y), 50, 1)

                            -- local random = i + 2
                            -- local mb = cc.JumpTo:create(0.1 + 0.2 * math.random(random), cc.p(x + 10 * a, y), 50, 1)
                            -- local fo = cc.FadeOut:create(0.5)

                            -- local seq = cc.Sequence:create(mb, fo)
            
                            local random = i + 2
                            local delaytime = 0.1 + 0.2 * math.random(random)
                            local mb = cc.JumpTo:create(delaytime, cc.p(x + 10 * a, y), 50, 1)
                            local fo = cc.FadeOut:create(0.5)

                            local seq = cc.Sequence:create(mb, fo)
                            coin_sp:runAction(seq)

                            local remove_action = cc.Sequence:create(cc.DelayTime:create(delaytime + 0.6),cc.CallFunc:create(function()
                                coin_sp:removeSelf()
                            end))
                            coin_sp:runAction(remove_action)

                        end

                    end

                end

                if isZhuanWin == 1 and playerCount > 2 then

                    local action = cc.Sequence:create(cc.DelayTime:create(2),cc.CallFunc:create(function()

                        local sound_path = "niuniu/sound/coins_fly_in_long.mp3"
                        -- cc.SimpleAudioEngine:getInstance():playEffect(sound_path,false)
                        require("hall.VoiceUtil"):playEffect(sound_path,false)

                    end))
                    self._scene:runAction(action)

                else

                    local sound_path = "niuniu/sound/coins_fly_in_long.mp3"
                    -- cc.SimpleAudioEngine:getInstance():playEffect(sound_path,false)
                    require("hall.VoiceUtil"):playEffect(sound_path,false)

                end

            end

        end

    end

end

--更新筹码
function NiuniuroomScenes:updateDrawCoin(dt)

    -- dump(dt, "-----更新筹码-----")
    
    if bShowAddCoin == false then
        return
    end

    fTimeDrawCoins = fTimeDrawCoins + dt

    if fTimeDrawCoins < 1 then

        local str = ""
        for i = 0,4 do

            local txtWin = self._scene:getChildByName("txtwin"..tostring(i))
            
            --local visible = txtWin:getvisible()
            local value = self.tbWin[i]
            if value ~= nil then

                -- local bAdd = true
                
                -- if value < 0 then
                --     bAdd = false
                -- end

                -- if bAdd then
                --     str = "+0"
                -- else
                --     str = "-0"
                -- end

                -- txtWin:setString(str)

                -- local iAddCoin,_ = math.modf(value*fTimeDrawCoins)

                -- if bAdd then
                --     str = "+"..tostring(iAddCoin)
                -- else
                --     str = tostring(iAddCoin)
                -- end

                -- txtWin:setString(str)

                local bAdd = true
                
                if value < 0 then
                    bAdd = false
                end

                local iAddCoin,_ = math.modf(value)

                if bAdd then
                    str = "+"..tostring(iAddCoin)
                else
                    str = tostring(iAddCoin)
                end

                txtWin:setString(str)

            end
        end

    else

        local function showFreeEnd()

            for i = 0,4 do
                local txtWin = bm.runScene._scene:getChildByName("txtwin"..tostring(i))
                if txtWin then
                    txtWin:setVisible(false)
                end
            end

        end

        local str = ""

        for i = 0,4 do

            local txtWin = self._scene:getChildByName("txtwin"..tostring(i))
            -- local visible = txtWin:getvisible()

            local value = self.tbWin[i]

            if value ~= nil then

                local bAdd = true
               
                if value < 0 then
                    bAdd = false
                end

                if bAdd then
                    str = "+"..tostring(value)
                else
                    str = tostring(value)
                end

                txtWin:setString(str)

                local mb = cc.MoveBy:create(1.5,cc.p(0,60))
                local mb2 = cc.MoveBy:create(0.1,cc.p(0,-60))
                local hide = cc.Hide:create()
                local fo = cc.FadeOut:create(0.5)

                local seq = nil
                if i == 0 then
                    seq = cc.Sequence:create(mb, fo, hide, mb2, cc.CallFunc:create(showFreeEnd))
                else
                    seq = cc.Sequence:create(mb, fo, hide, mb2)
                end

                txtWin:runAction(seq)

            end

        end

        bShowAddCoin = false
        self.tbWin = {}
    end
    
end

--请求兑换筹码返回（弃用）
function NiuniuroomScenes:onNetChangeChip(pack)

    if pack["uid"] == tonumber(UID) then
        USER_INFO["chips"] = pack["chip"]
        USER_INFO["score"] = pack["money"]
        USER_INFO["gold"] = pack["money"]
        self:set_player_gold(0,tostring(USER_INFO["chips"]))
        if require("hall.common.GroupGame"):checkMoney2Chips() then
            if require("hall.common.GroupGame"):checkChips() then

                if self.need_send_ready_msg == true then

                    --发送准备消息
                    NiuniuroomServer:readyNow(1)
                    
                    self.need_send_ready_msg = false

                end
                --发送准备消息后，隐藏准备按钮
               -- self:ready()
            else
                require("hall.GameCommon"):showChange(true)
            end
        end
    else
       -- self:drawOtherCoin(USERID2SEAT[pack["uid"]],pack["chip"])
       --显示其他玩家的筹码
       local other_index = NiuniuroomHandle:getIndex(pack["uid"])
       self:set_player_gold(other_index,pack["chip"])
    end

end

-----------------------------------------------------------------------------------------------------------------------------------------------------------
--阶段显示相关
--阶段显示与隐藏
function NiuniuroomScenes:set_recent_txt_visible(flag)

    --local  recent_txt = self._scene:getChildByName("recent_txt_top")

    if flag == false then
        self._scene:removeChildByName("tip_icon")
    end

    -- if flag == false then
    --  if recent_txt ~= nil then 
    --      recent_txt:setVisible(false)
    --  end
    -- else
    --  if recent_txt ~= nil then
    --      recent_txt:setVisible(true)
    --  else
    --      local params =
    --      {
    --          text = "..............",
    --          font = "res/fonts/wryh.ttf",
    --          size = 30,
    --          color = cc.c3b(255,255,0), 
    --          align = cc.TEXT_ALIGNMENT_LEFT,
    --          valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
    --      }
    --      local niu_txt = display.newTTFLabel(params)
    --      niu_txt:enableShadow(cc.c4b(255,255,0,255), cc.size(1,0))
    --      self._scene:addChild(niu_txt, 20000, "recent_txt_top")

    --      local recent_txt = self._scene:getChildByName("recent_txt")
    --      niu_txt:setPositionX(recent_txt:getPositionX())
 --         niu_txt:setPositionY(recent_txt:getPositionY())
    --  end
    -- end

end

--显示当前阶段操作提示
function NiuniuroomScenes:set_recent_txt_(txt_)

    -- local  recent_txt = self._scene:getChildByName("recent_txt_top")
    -- if recent_txt == nil then
    --  return
    -- end

    -- recent_txt:setString("")

    if txt_ == "" then
        self._scene:removeChildByName("tip_icon")
        return
    end

    print("--------------------set_recent_txt_----------------------",txt_)

    local qiangzuan = ""
    if txt_ == 1 then
        qiangzuan = "qiangzuanjieduan.png"--抢庄阶段
    elseif txt_ == 2 then
         qiangzuan = "jiabeijieduan.png"--加倍阶段
    elseif txt_ == 3 then
         qiangzuan = "chupaijieduan.png"--出牌阶段
    elseif txt_ == 4 then
         qiangzuan = "qingzhunbei.png"--请准备
    end

    local tip = self._scene:getChildByName("tip_icon")
    if tip == nil then
        local tip = display.newSprite("niuniu/newimage/"..qiangzuan):addTo(self._scene)
        tip:setPositionX(485.00)
        tip:setPositionY(389.19)
        tip:setName("tip_icon")
    else
        tip:setTexture("niuniu/newimage/"..qiangzuan)
    end

end

------------------------------------------------------------------------------------------------------------------------------------------
--准备相关
--设置是否需要发送准备
function NiuniuroomScenes:set_need_send_ready_msg(flag)

    dump(flag, "-----设置是否需要发送准备-----")

    self.need_send_ready_msg = flag

end

function NiuniuroomScenes:set_send_ready_flag(flag)

    self.send_ready_flag = flag

end

function NiuniuroomScenes:get_send_ready_flag()

    return self.send_ready_flag
    
end

--准备按钮显示与隐藏
function NiuniuroomScenes:show_panel_ready(flag)


    dump(flag, "-----show_panel_ready-----")

    if bm.IReady == 1 then
        return
    end

    local panel = self._scene:getChildByName("panel_ready")

    local btn_ready =  panel:getChildByName("btn_ready")
    local Image_7 =  panel:getChildByName("Image_7")
    local Text_9 =  panel:getChildByName("Text_9")

    btn_ready:setVisible(flag)
    Image_7:setVisible(false)
    Text_9:setVisible(false)

    -- if flag == true then

    btn_ready:addTouchEventListener(
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

                NiuniuroomServer:readyNow()

            end
        end
    )

end

--其他玩家的准备
function NiuniuroomScenes:show_other_panel_ready(palyerindex,flag)

    self:set_player_info_visible(palyerindex,"ready_sp",flag)
    
end

function NiuniuroomScenes:show_other_panel_ready_ex(palyerindex,flag)

    -- body
    local panel = self._scene:getChildByName("panel_ready")

    local btn_ready =  panel:getChildByName("btn_ready"..tostring(palyerindex))
    if btn_ready ~= nil then
        btn_ready:setVisible(flag)
    else
        dump("", "-----show_other_panel_ready-----")
    end

end

-----------------------------------------------------------------------------------------------------------------------------------------
--庄家相关
--显示庄家标示
function NiuniuroomScenes:show_zuang(player_index,flag)

    local  palyer_panel_ = self._scene:getChildByName("palyer_panel_"..tostring(player_index))
    local  zuan_icon = palyer_panel_:getChildByName("zang")
    zuan_icon:setVisible(flag)

end

--显示抢庄
function NiuniuroomScenes:show_qiangzang(flag)

    local panel = self._scene:getChildByName("qiangzang")

    local btn_qiang =  panel:getChildByName("btn_qiang")
    local btn_buqiang =  panel:getChildByName("btn_buqiang")

    btn_qiang:setVisible(flag)
    btn_buqiang:setVisible(flag)

    if flag == true then
         bm.buttontHandler(btn_buqiang,function()
      --        NiuniuroomServer:noQiang()
                bm.runScene:show_qiangzang(false)
            end)

        bm.buttontHandler(btn_qiang,function()
                NiuniuroomServer:qiang()
            end)
    end
    
end

--抢庄标示
function NiuniuroomScenes:show_other_qiangzang(player_index,index)

    local panel = self._scene:getChildByName("qiangzang")

    local btn_qiang_zuang = panel:getChildByName("spr_zuan"..tostring(player_index)..tostring(1))
    local btn_qiang = panel:getChildByName("spr_zuan"..tostring(player_index)..tostring(0)) 
    if index == 1 then
        btn_qiang_zuang:setVisible(true)
        btn_qiang:setVisible(false)

    elseif index == 0 then
        btn_qiang_zuang:setVisible(false)
        btn_qiang:setVisible(true)
    end
    
end

--抢分
function NiuniuroomScenes:show_qiangfeng(flag)

    dump(flag, "-----显示抢分-----")

    local panel = self._scene:getChildByName("qiangfeng")
    local btn_not = panel:getChildByName("btn_not")
    local btn_1 = panel:getChildByName("btn_1")
    local btn_2 = panel:getChildByName("btn_2")
    local btn_3 = panel:getChildByName("btn_3")
    local btn_4 = panel:getChildByName("btn_4")
    local txt_feng1 = panel:getChildByName("txt1")
    local txt_feng2 = panel:getChildByName("txt2")
    local txt_feng3 = panel:getChildByName("txt3")
    local txt_feng4 = panel:getChildByName("txt4")

    btn_not:setVisible(false)
    btn_1:setVisible(flag)
    btn_2:setVisible(flag)
    btn_3:setVisible(flag)
    btn_4:setVisible(flag)

    txt_feng1:setVisible(flag)
    txt_feng2:setVisible(flag)
    txt_feng3:setVisible(flag)
    txt_feng4:setVisible(flag)

    local txt_feng1 = panel:getChildByName("bei1")
    local txt_feng2 = panel:getChildByName("bei2")
    local txt_feng3 = panel:getChildByName("bei3")
    local txt_feng4 = panel:getChildByName("bei4")
    txt_feng1:setVisible(flag)
    txt_feng2:setVisible(flag)
    txt_feng3:setVisible(flag)
    txt_feng4:setVisible(flag)
    
end

--分家（不是庄家）
function NiuniuroomScenes:set_qiang_feng_btn_visible(index,flag,btn_value)

    dump(flag, "-----分家（不是庄家）-----")

    local panel = self._scene:getChildByName("qiangfeng")
    local btn_1 =  panel:getChildByName("btn_"..tostring(index))
    btn_1:setVisible(flag)

    if flag == true then

        -- bm.buttontHandler(btn_1,function ()
        --     NiuniuroomServer:addBase(btn_value)
        -- end)

        btn_1:addTouchEventListener(
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

                    dump(btn_value, "-----分家点击-----")

                    NiuniuroomServer:addBase(btn_value)

                end
            end
        )

    end

end

--不抢
function NiuniuroomScenes:set_not_qiang()

    dump("", "-----不抢-----")

    local panel = self._scene:getChildByName("qiangfeng")
    local btn_1 =  panel:getChildByName("btn_not")
    btn_1:setVisible(false)

    -- bm.buttontHandler(btn_1,function ()
    --     bm.runScene:show_qiangfeng(false)
    -- end)

    btn_1:addTouchEventListener(
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

                dump(btn_value, "-----不抢点击-----")

                bm.runScene:show_qiangfeng(false)

            end
        end
    )

end

--设置抢分文本
function NiuniuroomScenes:set_bei_score_txt(index,score)

    local panel = self._scene:getChildByName("qiangfeng")
    --local txt_str_icon =  panel:getChildByName("txt_feng"..tostring(index))
    --txt_str_icon:setString(score)
    
    local path = "niuniu/room"
    --local txt_str_icon =  panel:getChildByName("txt_feng"..tostring(index))
    --txt_str_icon:setString(score)
    local txt_str_icon =  panel:getChildByName("txt"..tostring(index))--获取10位名字

    --txt_str_icon:setTexture(path..tostring(tennum)..".png")
    txt_str_icon:setString(score)

    self:hide_bei_relatice(index,true)

end

function NiuniuroomScenes:hide_bei_relatice(index,flag)

    local panel = self._scene:getChildByName("qiangfeng")

    local tem = panel:getChildByName("txt"..tostring(index))
    local bei = panel:getChildByName("bei"..tostring(index))

    tem:setVisible(flag)
    bei:setVisible(flag)

end

--显示抢分文本
function NiuniuroomScenes:show_bei_score_txt(index,flag)

    local panel = self._scene:getChildByName("qiangfeng")
    local txt_str_icon =  panel:getChildByName("txt"..tostring(index))
    -- txt_str_icon:setVisible(flag)
    txt_str_icon:setVisible(false)

end

--玩家抢倍率
function NiuniuroomScenes:show_qiangfeng_txt(player_index,flag)

    local panel = self._scene:getChildByName("qiangbei")
    local txt_str_icon =  panel:getChildByName("txt_"..tostring(player_index))
    txt_str_icon:setVisible(flag)

end

function NiuniuroomScenes:set_qiangfeng_txt(player_index,str_txt)

    local panel = self._scene:getChildByName("qiangbei")
    local txt_str_icon =  panel:getChildByName("txt_"..tostring(player_index))
    str_txt = str_txt or ""
    txt_str_icon:setString(str_txt)

end

--底分与倒计时面板
function NiuniuroomScenes:show_difeng_base(flag,difeng)

    local panel = self._scene:getChildByName("difeng_base")

    --底分
    local ddd_1 = panel:getChildByName("ddd_1")
    local Sprite_9_0 = panel:getChildByName("Sprite_9_0")
    local text_difeng = panel:getChildByName("text_difeng")

    ddd_1:setVisible(flag)
    Sprite_9_0:setVisible(flag)
    text_difeng:setVisible(flag)
    text_difeng:setString(difeng)

end

--设置倒计时时间显示
function NiuniuroomScenes:set_timer_text(timer_txt)

    local panel = self._scene:getChildByName("difeng_base")
    local text_center = panel:getChildByName("text_center")
    text_center:setVisible(true)
    text_center:setString(timer_txt)

    local timer_2 = panel:getChildByName("timer_2")
    timer_2:setVisible(true)

end

--隐藏抢庄
function NiuniuroomScenes:hide_qiangzuang()

    local panel = self._scene:getChildByName("qiangzang")
    panel:getChildByName("spr_zuan"..tostring(0)..tostring(1)):setVisible(false)
    panel:getChildByName("spr_zuan"..tostring(1)..tostring(1)):setVisible(false)
    panel:getChildByName("spr_zuan"..tostring(2)..tostring(1)):setVisible(false)
    panel:getChildByName("spr_zuan"..tostring(3)..tostring(1)):setVisible(false)
    panel:getChildByName("spr_zuan"..tostring(4)..tostring(1)):setVisible(false)

    panel:getChildByName("spr_zuan"..tostring(0)..tostring(0)):setVisible(false)
    panel:getChildByName("spr_zuan"..tostring(1)..tostring(0)):setVisible(false)
    panel:getChildByName("spr_zuan"..tostring(2)..tostring(0)):setVisible(false)
    panel:getChildByName("spr_zuan"..tostring(3)..tostring(0)):setVisible(false)
    panel:getChildByName("spr_zuan"..tostring(4)..tostring(0)):setVisible(false)

end

------------------------------------------------------------------------------------------------------------------------------------------
--游戏相关
function NiuniuroomScenes:sendCard()

    dump("", "-----sendCard-----")

    local obj  = {} 
    for i=5,1,-1 do
        local card            = require(TpackageName..".foundation.PokerCard").new():setCard(18):addTo(self)
        local y               = card:getPositionY()
        local x               = card:getPositionX()
        card:setPositionY(display.cy)
        card:setPositionX(display.cx)
        card:showBack()
        card:setScale(0.5)
        local move = cc.MoveTo:create(0.1,cc.p(200+(5-i)*15, 430))
        local delay= cc.DelayTime:create((5-i)*0.1)
        local se   = cc.Sequence:create(delay,move)
        card:runAction(se)
        obj[5-i] =  card
        -- card:flip()
    end

end

function NiuniuroomScenes:set_spectator(flag)

    self.isspectator = flag

end

function NiuniuroomScenes:send_extract(total_num,num)
    -- total_num,_ = math.modf(total_num)
    -- num,_ = math.modf(num)
    -- cct.createHttRq({
    --  url=HttpAddr .. "/game/quickGameExtract",
    --  date={
    --      quickGameId = 5,
    --      totalIncome = total_num,
    --      extractIncome = num
    --  },
    --  type_="POST",
    --  callBack=handler(self, self.HttpResponseCallBack)
    -- })

    --调用豪哥方法
    print("5,total_num,num-----------------------------",total_num,num)
    require("hall.HttpSettings"):quickGameExtract(5,total_num,num)

end

function NiuniuroomScenes:HttpResponseCallBack(date)

    local da=date.netData
    local strResponse = string.trim(da)
    local gameList  = json.decode(strResponse)
    printInfo("======================HttpResponseCallBack=======================")
    dump(gameList)
    if gameList.returnCode~="0" then
        --todo
        print("net error==================================")
        return
    end

end

------------------------------------------------------------------------------------------------------------------------------------------
--结算相关
--有牛，没牛
function NiuniuroomScenes:show_niu_tip(flag)

    dump(flag, "-----有牛，没牛-----")

    local panel = self._scene:getChildByName("niu_tip")
    panel:setVisible(flag)
    local text_center =  panel:getChildByName("text_center")
    local text_left =  panel:getChildByName("text_left")
    local text_right =  panel:getChildByName("text_right")
    local text_sum =  panel:getChildByName("text_sum")

    text_center:setVisible(flag)
    text_left:setVisible(flag)
    text_right:setVisible(flag)
    text_sum:setVisible(flag)

    local text = 0
    if flag == false then
        text_center:setString(text)
        text_left:setString(text)
        text_right:setString(text)
        text_sum:setString(text)
    end

end

function NiuniuroomScenes:show_niu_tip_btn(flag)

    dump(flag, "-----show_niu_tip_btn-----")

    local niu_panel = self._scene:getChildByName("niu_tip")
    local youniu_btn = niu_panel:getChildByName("btn_youniu")
    local meiniu_btn = niu_panel:getChildByName("btn_meiniu")
    youniu_btn:setVisible(flag)
    meiniu_btn:setVisible(flag)
    
end

--显示牛
function NiuniuroomScenes:show_niu_text(index,str)

    local position = {{456.07,196.38},{342.24,304.79},{343.12,388.47},{609.15,391.99},{613.55,303.90}}
    print("index---------------------------",index)

    -- local niu_tip = self._scene:getChildByName("niuniu_txt"..tostring(index))
    -- if niu_tip == nil then
    --  return
    -- end

    local x = position[index+1][1]
    local y = position[index+1][2]
    local filename = str
    local spr = display.newSprite(filename, x, y)
    self._scene:addChild(spr,100)

    local delayaction = cc.DelayTime:create(0.5)
    local scale_2 = cc.ScaleTo:create(0.5,2)
    local scale_1 = cc.ScaleTo:create(0.5,1)
    local seq = cc.Sequence:create(delayaction,scale_2,scale_1)
    spr:runAction(seq)
    spr:setName("niuniu_txt"..tostring(index))

    -- local params =
 --    {
 --     text = str,
    --     font = "res/fonts/wryh.ttf",
    --     size = 30,
    --     color = cc.c3b(249,235,158), -- 使用纯红色
    --     align = cc.TEXT_ALIGNMENT_LEFT,
    --     valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
    --     OutlineColor = cc.c4b(144,72,43,255)

    -- } 
 --    local niu_txt = display.newTTFLabel(params)
 --    niu_txt:enableOutline(params.OutlineColor,2)
 --    niu_txt:setRotation(-20)

 --    niu_txt:setPositionX(200)
 --    niu_txt:setPositionY(200)
 --    niu_txt:setName("niuniu_txt"..tostring(index))
 --    self._scene:addChild(niu_txt)

    -- niu_txt:setPositionX(position[index+1][1])
    -- niu_txt:setPositionY(position[index+1][2])
    -- niu_txt:setVisible(true)

    -- local delayaction = cc.DelayTime:create(0.5)
    -- --local removeselfaction = cc.Hide:create()
    -- local scale_2 = cc.ScaleTo:create(0.5,2)
    -- local scale_1 = cc.ScaleTo:create(0.5,1)
    -- local seq = cc.Sequence:create(delayaction,scale_2,scale_1)

    -- niu_txt:runAction(seq)

end

--显示我的分数
function NiuniuroomScenes:set_sum_feng(sum_txt)

    dump(sum_txt, "-----set_sum_feng-----")

    local panel = self._scene:getChildByName("niu_tip")
    local text_sum =  panel:getChildByName("text_sum")
    text_sum:setString(sum_txt)
    
end

--123
function NiuniuroomScenes:set_niu_feng(index,sum_txt)

    dump(index, "-----set_niu_feng-----")
    dump(sum_txt, "-----set_niu_feng-----")

    local panel = self._scene:getChildByName("niu_tip")
    local index_str = ""
    if index == 1 then
        index_str = "text_left"

    elseif index == 2 then
        index_str = "text_center"

    elseif index == 3 then
        index_str = "text_right"
    end

    local index_str_icon =  panel:getChildByName(index_str)
    index_str_icon:setString(sum_txt)

end

--显示玩家倍数
function NiuniuroomScenes:show_bei(player_index,num_bei)

    dump(player_index, "-----显示玩家倍数-----")
    dump(num_bei, "-----显示玩家倍数-----")

    local  palyer_panel_ = self._scene:getChildByName("palyer_panel_"..tostring(player_index))
    local  zuan_icon = palyer_panel_:getChildByName("beitxt")
    zuan_icon:setVisible(true)

    print(".....tolua.type(zuan_icon).................................",tolua.type(zuan_icon))
    local Sprite_18 = palyer_panel_:getChildByName("Sprite_18")
    Sprite_18:setVisible(true)

    local Sprite_19 = palyer_panel_:getChildByName("Sprite_19")
    Sprite_19:setVisible(true)

    zuan_icon:setString(num_bei)


    --local width = zuan_icon:getStringLength()*22
    --print("width-----------------------",width)
    
    -- if player_index > 2 then
    --  local bei_txt_x = zuan_icon:getPositionX() - width
    --  Sprite_19:setPositionX(bei_txt_x)
    -- else
    --  local bei_txt_x = zuan_icon:getPositionX() + width
    --  Sprite_18:setPositionX(bei_txt_x)
    -- end
    
    if tonumber(num_bei) > 99 then
        zuan_icon:setScale(0.55)
    else
        zuan_icon:setScale(0.8)
    end

    -- local bei_txt_y = zuan_icon:getPositionY()

  --  local function show_bei_bar(num)
  --    -- body
  --        num = checkint(num)
  --        local node_base = display.newNode()
  --        local new_sprite = display.newSprite("niuniu/room/bei.png"):addTo(node_base)
  --        local tem = num
  --        for i = 1,4 do  
  --            local ge,_  = math.modf(tem / 10)
  --            local ge_less,_ = math.modf(tem%10)
  --            if ge ~= 0 then 
  --                local pre_x = new_sprite:getPositionX()
  --                new_sprite = display.newSprite("niuniu/room/"..tostring(ge_less)..".png"):addTo(node_base)
  --                if i == 1 then
  --                    new_sprite:setPositionX(-20 + pre_x)
  --                else
  --                    new_sprite:setPositionX(-15 + pre_x)
  --                end
  --            end

  --            if ge == 0 and ge_less ~= 0 then
  --                local pre_x = new_sprite:getPositionX()
  --                new_sprite = display.newSprite("niuniu/room/"..tostring(ge_less)..".png"):addTo(node_base)
  --                new_sprite:setPositionX(-15 + pre_x)
  --            end

  --            tem = ge
  --        end
  --        local pre_x = new_sprite:getPositionX()
        -- new_sprite = display.newSprite("niuniu/room/qiang.png"):addTo(node_base)
        -- new_sprite:setPositionX(-20 + pre_x)

  --        return node_base
  --  end

  --  local base_node = show_bei_bar(num_bei)
  --  palyer_panel_:addChild(base_node)
  --  base_node:pos(bei_txt_x+30,bei_txt_y)
  --  base_node:setName("txt_bei"..tostring("player_index"))

end

--移除倍数显示
function NiuniuroomScenes:remove_bei_txt(player_index)

    -- local  palyer_panel_ = self._scene:getChildByName("palyer_panel_"..tostring(player_index))
    -- palyer_panel_:removeChildByName("txt_bei"..tostring("player_index"))
    local  palyer_panel_ = self._scene:getChildByName("palyer_panel_"..tostring(player_index))
    local  zuan_icon = palyer_panel_:getChildByName("beitxt")
    zuan_icon:setVisible(false)
    local duanxian = ccui.ImageView:create("niuniu/newimage/duanxianchonglian_bt.png")   ---断线标志
    palyer_panel_:addChild(duanxian)
    duanxian:setName("duanxian")
    duanxian:setPosition(100,-50)
    duanxian:setVisible(true)
    print(".....tolua.type(zuan_icon).................................",tolua.type(zuan_icon))
    local Sprite_18 = palyer_panel_:getChildByName("Sprite_18")
    Sprite_18:setVisible(false)

    local Sprite_19 = palyer_panel_:getChildByName("Sprite_19")
    Sprite_19:setVisible(false)

end

--设置赢标志显示隐藏
function NiuniuroomScenes:set_win_txt_visible(player_index,flag)

    local icon = self._scene:getChildByName("txtwin"..tostring(player_index))
    icon:setVisible(flag)

end

--游戏结束后，显示加分动画
function NiuniuroomScenes:drawCoin(player_index,value,fengshu)

    self.tbWin[player_index] = value
    self.koufeng[player_index] = fengshu

end

--组局结束会回调到这里,组局结算（旧的组局排行榜）
function NiuniuroomScenes:onNetBillboard(pack)

    dump(dt, "-----旧的组局排行榜-----")

    local info = pack["playerlist"]

    local groupRanking = {}
    for i,v in pairs(info) do
        groupRanking[v["uid"]] = json.decode(v["user_info"])
    end
    local  group_game_amount = pack["game_amount"]

    if bm.Room.Status ~= 3 then
   		self:showRanking(groupRanking,group_game_amount)
    end

end

--组局排行榜
function NiuniuroomScenes:showRanking(playerlist,game_amount)
    -- body

    require("hall.common.GroupGame"):showRanking(playerlist,game_amount);
    -- local group_result = self:getChildByName("group_result")
    -- if group_result == nil then
    --     group_result = cc.CSLoader:createNode("niuniu/GroupResult.csb"):addTo(self)
    --     group_result:setName("group_result")
    --     group_result:setLocalZOrder(100000)
    --  print("================showRanking======================")
    -- end

    --退出
    -- local btn_exit = group_result:getChildByName("btn_exit")
    -- if btn_exit then
    --     btn_exit:addTouchEventListener(function(sender,event)
    --         if event == 0 then
    --             sender:setScale(1.1)
    --         end

    --         if event == 2 then
    --             sender:setScale(1)
    --             require("hall.GameCommon"):gExitGroupGame(5)
    --         end
    --     end)
    -- end

    -- local rich = -99999999999
    -- local richId = {}--充值最多
    -- local loser = 99999999999
    -- local loserId = {}--输最多
    -- local mvp = 0
    -- local mvpId = {}--赢最多
    -- local total_chips = 0
    -- print("playerlist :"..tostring(#playerlist))
    -- for i,k in pairs(playerlist) do
    --     print("playerlist :"..tostring(i))
    --     print_lua_table(k)
    --     local add = k["add_chips"]
    --     local chips = k["chips"]
    --     if (chips - add) > mvp then
    --         mvpId = k
    --         mvp = chips - add
    --     end
    --     if (chips-add) < loser then
    --         loserId = k
    --         loser = chips - add
    --     end
    --     if add > rich then
    --         richId = k
    --         rich = add
    --     end
    --     total_chips = total_chips + add
    -- end
    -- print("onNetBillboard total_chips:"..tostring(total_chips))
    -- --土豪
    -- local layer = group_result:getChildByName("layer_richman")
    -- if layer then
    --     local spHead = layer:getChildByName("sp_head")
    --     if spHead then
    --         getUserHead(richId["photo_url"],richId["sex"],spHead,60,true)
    --     end
    --     local lbNick = layer:getChildByName("txt_nick")
    --     if lbNick then
    --         lbNick:setString(richId["nick_name"])
    --     end
    -- end
    -- --大鱼
    -- local layer = group_result:getChildByName("layer_loser")
    -- if layer then
    --     local spHead = layer:getChildByName("sp_head")
    --     if spHead then
    --         getUserHead(loserId["photo_url"],loserId["sex"],spHead,60,true)
    --     end
    --     local lbNick = layer:getChildByName("txt_nick")
    --     if lbNick then
    --         lbNick:setString(loserId["nick_name"])
    --     end
    -- end
    -- --MVP
    -- -- userinfo = pack["mvp_info"]
    -- local layer = group_result:getChildByName("layer_mvp")
    -- if layer then
    --     local spHead = layer:getChildByName("sp_head")
    --     if spHead then
    --         getUserHead(mvpId["photo_url"],mvpId["sex"],spHead,60,true)
    --     end
    --     local lbNick = layer:getChildByName("txt_nick")
    --     if lbNick then
    --         lbNick:setString(mvpId["nick_name"])
    --     end
    -- end
    -- --个人信息
    -- local spMyHead = group_result:getChildByName("sp_my_head")
    -- if spMyHead then
    --     getUserHead(USER_INFO["icon_url"],USER_INFO["sex"],spMyHead,60,true)
    -- end
    -- local lbChips = group_result:getChildByName("txt_my_chip")
    -- if lbChips then
    --     -- lbChips:setString(tostring(pack["chips"]))
    --    ----------------- lbChips:setString(playerlist[USER_INFO["uid"]]["chips"])
    --     lbChips:enableShadow(cc.c4b(0xff,0xff,0xff,255),cc.size(1,0))
    -- end
    -- local lbCountGame = group_result:getChildByName("txt_game_count")
    -- if lbCountGame then
    --     lbCountGame:setString(game_amount)
    --     lbCountGame:enableShadow(cc.c4b(0xff,0xff,0xff,255),cc.size(1,0))
    -- end
    -- local lbTotalChips = group_result:getChildByName("txt_total_chips")
    -- if lbTotalChips then
    --     -- lbTotalChips:setString(pack["total_chips"])
    --     lbTotalChips:setString(tostring(total_chips))
    --     lbTotalChips:enableShadow(cc.c4b(0xff,0xff,0xff,255),cc.size(1,0))
    -- end
    -- --记录
    -- -- for i,v in pairs(pack["playerList"]) do
    -- for i,l in pairs(playerlist) do
    --     -- userinfo = json.decode(v["user_info"])
    --     -- self:addGroupRecord(v["nick"],v["add_chips"],v["chips"])
    --     self:addGroupRecord(l["nick_name"],l["add_chips"],l["chips"])
    -- end

end

------------------------------------------------------------------------------------------------------------------------------------------
--解散组局相关
--解散组局
function NiuniuroomScenes:disbandGroup()

    --查询用户当前的游戏状态来判断当前通过怎样的方式来解散组局
    require("hall.gameSettings"):disbandGroup("niuniu")
    
end

--获取历史记录
function NiuniuroomScenes:onNetHistory(pack)

    local playerlist = {}
    for i, v in ipairs(pack["playerlist"]) do
        playerlist[v["uid"]] = json.decode(v["user_info"])
    end

    local history = json.decode(pack["history"])
    if history ~= null then
       for i,v in ipairs(history) do
            local tbPlayers = {}

            for j, k in ipairs(v) do
                local uid = k["user_id"]
                local name = json.decode(playerlist[uid]["user_name"]) or playerlist[uid]["nick_name"]
                print(name,"===================name=========================")
                table.insert(tbPlayers,{uid,name,k["user_chip_variation"],playerlist[uid]["photo_url"],playerlist[uid]["sex"]})
            end
            require("hall.GameCommon"):addHistoryItem(i,tbPlayers)
        end
    end
    
    -- local gameno = 1
    -- local tbPlayers = {}
    -- table.insert(tbPlayers,{121,"zh",300,"",1})
    -- table.insert(tbPlayers,{4,"zh",300,"",0})
    -- -- table.insert(tbPlayers,{5,"zh",-600,"",1})
    -- -- table.insert(tbPlayers,{6,"zch",-500,"",0})
    -- -- table.insert(tbPlayers,{7,"zch",-100,"",1})

    -- self:addHistoryItem(gameno,tbPlayers)
    -- self:addHistoryItem(gameno,tbPlayers)
    -- self:addHistoryItem(gameno,tbPlayers)
    -- self:addHistoryItem(gameno,tbPlayers)
    -- self:addHistoryItem(gameno,tbPlayers)

    require("hall.GameCommon"):showHistory(true)

end

--大厅，离开，继续（弃用）
function NiuniuroomScenes:show_over_layout(flag)

	local panel = self._scene:getChildByName("over_layout")
	local dating =  panel:getChildByName("dating")
	local likai =  panel:getChildByName("likai")
	local jixu =  panel:getChildByName("jixu")

	dating:setVisible(flag) --返回大厅
	likai:setVisible(flag) --离开
	jixu:setVisible(flag) --继续


	if flag == true then
		bm.buttontHandler(dating,function()
		-- body
			bm.runScene.leave_style = 1
			-- NiuniuroomServer:quickRoom()
		end
		)

		bm.buttontHandler(likai,function( )
		-- body
			bm.runScene.leave_style = 2
			-- NiuniuroomServer:quickRoom()
		end)

		bm.buttontHandler(jixu,function(  )
		-- body
			if bm.runScene.show_over_layout ~= nil then 
				bm.runScene:show_over_layout(false)
				bm.runScene:set_send_ready_flag(true)
			end

			NiuniuroomServer:readyNow()
		end)
	end

	--如果不是从大厅模式进来的，那么就是组局模式，这里刻意
	if  USER_INFO["enter_mode"] ~= 0 then
		dating:setVisible(false) --返回大厅s

		panel:setPositionX(-66.88)
	end

end

-- function NiuniuroomScenes:addGroupRecord(nick,buyChip,chip)
--     -- body
--     local layerGroupRecord = self:getChildByName("group_result")
--     if layerGroupRecord == nil then
--         layerGroupRecord = cc.CSLoader:createNode("niuniu/GroupResult.csb"):addTo(self)
--         layerGroupRecord:setName("group_result")
--     end
--     local lsPlayer = layerGroupRecord:getChildByName("lv_players")
--     if lsPlayer then
--         local layout = ccui.Layout:create()
--         layout:setContentSize(cc.size(363,40))

--         local lbNick = cc.Label:createWithTTF(nick, "fonts/wryh.ttf", 20)
--         layout:addChild(lbNick)
--         lbNick:setPosition(cc.p(60,25))
--         lbNick:enableShadow(cc.c4b(0xff,0xff,0xff,255),cc.size(1,0))
--         local lbBuy = cc.Label:createWithTTF(tostring(buyChip), "fonts/wryh.ttf", 20)
--         layout:addChild(lbBuy)
--         lbBuy:setPosition(cc.p(181,25))
--         lbBuy:enableShadow(cc.c4b(0xff,0xff,0xff,255),cc.size(1,0))
--         local lbChip = cc.Label:createWithTTF(tostring(chip), "fonts/wryh.ttf", 20)
--         layout:addChild(lbChip)
--         lbChip:setPosition(cc.p(300,25))
--         lbChip:enableShadow(cc.c4b(0xff,0xff,0xff,255),cc.size(1,0))

--         lsPlayer:insertCustomItem(layout, 0)
--     end
-- end

function NiuniuroomScenes:move_player_panel(index)

	--现在已经不存在移动了
	-- local player_move_pos = {{-20.03,6.60},{-19.32,201.34},{59.83,346.56},{658.10,346.84},{772.95,202.05}	}
	-- if index == 0 then
	-- 	local panel = self._scene:getChildByName("palyer_panel_0") --把玩家移动到左下角
	-- 	local move_pos = player_move_pos[1]
	-- 	local move = cc.MoveTo:create(0.2,cc.p(move_pos[1],move_pos[2]))

	-- 	panel:runAction(move)
	-- else
	-- 	local panel = self._scene:getChildByName("palyer_panel_"..tostring(index)) --把玩家移动到左下角
	-- 	local move_pos = player_move_pos[index+1]
	-- 	local move = cc.MoveTo:create(0.2,cc.p(move_pos[1],move_pos[2]))
	-- 	panel:runAction(move)	
	-- end

end

--显示历史记录
-- function NiuniuroomScenes:showHistory(flag)
--     -- body
--     print("GameCommon:showHistory:"..tostring(flag))
--     local layHistory = SCENENOW["scene"]:getChildByName("layerHistory")
--     if layHistory == nil then
--         layHistory = ccui.Layout:create()
--         local spBack = display.newSprite("niuniu/group/histroy_back.png")
--         layHistory:addChild(spBack)
--         spBack:setPosition(cc.p(480,270))
--         layHistory:setAnchorPoint(cc.p(0.5,0.5))
--         layHistory:setContentSize(cc.size(960,540))
--         layHistory:setName("layerHistory")
--         SCENENOW["scene"]:addChild(layHistory)
--         layHistory:setPosition(cc.p(480,270))
--         layHistory:setTouchEnabled(true)
--         layHistory:addTouchEventListener(function(sender,event)
--             if event==2 then
--                 self:showHistory(false)
--             end
--         end)
--     end
--     if flag == false then
--         if layHistory then
--             -- layHistory:setVisible(false)
--             SCENENOW["scene"]:removeChildByName("layerHistory")
--         end
--         return
--     end
--     local lsHistory = layHistory:getChildByName("ls_history")
--     if lsHistory == nil then
--         lsHistory = ccui.ListView:create()
--         lsHistory:setAnchorPoint( cc.p(0.5,0.5))
--         lsHistory:setDirection(ccui.ScrollViewDir.vertical)
--         lsHistory:setContentSize(cc.size(420,280))
--         lsHistory:setPosition(cc.p(480,270))
--         layHistory:addChild(lsHistory)
--         lsHistory:setName("ls_history")
--     end
--     lsHistory:setVisible(true)

--     local function touchEvent(sender,eventType)
--         if eventType == ccui.TouchEventType.began then
--         elseif eventType == ccui.TouchEventType.moved then
--         elseif eventType == ccui.TouchEventType.ended then
--             self:showHistory(false)
--             print("end showHistory")
--         elseif eventType == ccui.TouchEventType.canceled then
--         end
--     end
-- end

--历史项目
-- function NiuniuroomScenes:addHistoryItem(gameNo,playerlist)
-- 	table.sort( playerlist, function(a,b)
--         local at = a[1]
--         local bt = b[1]

--         return at<bt
--     end )

--     -- body k["Userid"],k["nick"],k["win"],k["icon"],k["sex"]
--     local layHistory = SCENENOW["scene"]:getChildByName("layerHistory")
--     if layHistory == nil then
--         layHistory = ccui.Layout:create()
--         local spBack = display.newSprite("niuniu/newimage/group/histroy_back.png")
--         layHistory:addChild(spBack)
--         spBack:setPosition(cc.p(480,270))
--         layHistory:setAnchorPoint(cc.p(0.5,0.5))
--         layHistory:setContentSize(cc.size(960,540))
--         layHistory:setName("layerHistory")
--         SCENENOW["scene"]:addChild(layHistory)
--         layHistory:setPosition(cc.p(480,270))
--         layHistory:setTouchEnabled(true)
--         layHistory:addTouchEventListener(function(sender,event)
--             if event==2 then
--                 self:showHistory(false)
--             end
--         end)
--     end
--     local lsHistory = layHistory:getChildByName("ls_history")
--     if lsHistory == nil then
--         lsHistory = ccui.ListView:create()
--         lsHistory:setAnchorPoint( cc.p(0.5,0.5))
--         lsHistory:setDirection(ccui.ScrollViewDir.vertical)
--         lsHistory:setContentSize(cc.size(420,270))
--         lsHistory:setPosition(cc.p(480,230))
--         layHistory:addChild(lsHistory)
--         lsHistory:setName("ls_history")
--     end
--     --分割线
--     local layerLine = ccui.Layout:create()
--     local spLine = display.newSprite("niuniu/newimage/group/history_line.png")
--     layerLine:addChild(spLine)
--     spLine:setPosition(cc.p(spLine:getContentSize().width/2,spLine:getContentSize().height/2))
--     lsHistory:insertCustomItem(layerLine, 0)

--     local  layer = ccui.Layout:create()
--     layer:setContentSize(cc.size(420,140))

--     --数字编号
--     local lbTitle = cc.Label:createWithTTF(tostring(gameNo), "res/fonts/wryh.ttf", 30)
--     layer:addChild(lbTitle)
--     lbTitle:setColor(cc.c3b(0xff,0xf2,0x70)) 
--     lbTitle:setPosition(cc.p(20,60))
--     lbTitle:enableShadow(cc.c4b(0xff,0xf2,0x70,255),cc.size(1,0))

--     --这里是做一下，当记录人数大于3时做下缩放，和位置调整
--     local layout_pos_scale = 1
--     local layout_scale =1
--     if (#playerlist) == 4 then
--     	layout_pos_scale = 0.7
--     	layout_scale = 0.85
--     elseif (#playerlist) == 5 then
--     	layout_pos_scale = 0.5
--     	layout_scale = 0.7
--     end

--     for i,v in pairs(playerlist) do
--     	--多加一个layout，用作缩放用
--     	local layout_item = ccui.Layout:create()
--     	 layout_item:setContentSize(cc.size(140,140))

-- 		--先画头像
--         local spHead = display.newSprite()
--         layout_item:addChild(spHead)
--         -- url sex,
--         getUserHead(v[4],v[5],spHead,50,true)
--         layout_item:setPosition(cc.p((i-1)*130*layout_pos_scale+90,100))

--         local result_gold = v[3] -- 输赢的金币数
--         local name = v[2] --玩家的名字
--         local str = ""
--         if result_gold > 0 then
--             str = "+"..tostring(result_gold)
--         else
--             str = tostring(result_gold)
--         end

--         local lbWin = cc.Label:createWithTTF(str, "res/fonts/wryh.ttf", 20)
--         local spChip = display.newSprite("niuniu/newimage/group/chip.png")
     
--         if result_gold> 0 then
--             lbWin:enableShadow(cc.c4b(255,255,255,255),cc.size(1,0),0)
--             lbWin:setColor(cc.c3b(255,255,255))
--         else
--             lbWin:setColor(cc.c3b(255,0xf5,0x4f))
--             lbWin:enableShadow(cc.c4b(255,0xf5,0x4f,255),cc.size(1,0),0)
--             spChip:setColor(cc.c3b(255,0xf5,0x4f))
--         end

      
--         layout_item:addChild(spChip)
--         spChip:setPosition(cc.p(-spChip:getContentSize().width,-spChip:getContentSize().height*2))
--         layout_item:addChild(lbWin)
--         lbWin:setPosition(cc.p(spChip:getContentSize().width/2-2,-spChip:getContentSize().height*2))

--         local lbNick = cc.Label:createWithTTF(name, "res/fonts/wryh.ttf", 18)
--         layout_item:addChild(lbNick)
--         lbNick:setPosition(cc.p(0,-spChip:getContentSize().height*3))
--         if result_gold > 0 then
--             lbNick:setColor(cc.c3b(255,255,255))
--             lbNick:enableShadow(cc.c4b(255,255,255,255),cc.size(1,0),0)
--         else
--             lbNick:setColor(cc.c3b(255,0xf5,0x4f))
--             lbNick:enableShadow(cc.c4b(255,0xf5,0x4f,255),cc.size(1,0),0)
--         end

--        layout_item:setScale(layout_scale)
--         layer:addChild(layout_item)

--     end
--     lsHistory:insertCustomItem(layer, 0)
-- end

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

return NiuniuroomScenes
