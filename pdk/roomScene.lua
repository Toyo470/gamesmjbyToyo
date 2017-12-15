local Card          = require("pdk.Card")
local scheduler     = require(cc.PACKAGE_NAME .. ".scheduler")
local CardAnalysis  = require("pdk.CardAnalysis")

local PROTOCOL = require("pdk.pdk_PROTOCOL")

local pdkServer = import("pdk.pdkServer")
local pdkHandle  = require("pdk.pdkHandle")

local pdk_face = require("hall.FaceUI.faceUI")

local PlayCardScene = class("PlayCardScene", function()
    return display.newScene("PlayCardScene")
end)

-----------------
local G_NEED_TO_SEND_READY_MSG = true
G_FINISH_FIRST_PLAY = false -- 首次出牌的标记
-----------------


local USERID2SEAT = {}
local SEAT2USERID = {}
local REMAINCARDS = {}
local bFirst = true
--local bUnmatchCard = false
local bFakeLogout = false
local tbTipsCards = {}
local dtUpdate = 0
local tbWin = {}
local bGameOver = false
local iLiftTime = 20
local iLastLiftTime = 18
local iActionCounts = 0
local bPlayCard = 0
tbSeatCoin = {}
local rtSelectCard
local bOnDeal = false
local isDealAllCards = false
local isReload = false
local iGameState = 0 --0:wait,1:deal,2:bet,3:play cards,4:reslut,5:match wait,6:match win,7:match result
local iGameCount = 0
--针对历史记录，本地最新
local nGameNo = 0
local tbHistory = {}
local ptTouchBegin = cc.p(0,0)
--自动出牌
local bAuto = false

--时间片update
local bUpdateClock = false
local iClockSeat = 0
local posClock = {{257,268},{780,400},{180,400}}
--发牌
local bUpdateSendCard = false
local fTimeSendCard = 0
local iSendIndex = 0
--过金币
local bShowAddCoin = false
local fTimeDrawCoins = 0
--特效音效
local bBombMusic = false
--是否准备过
local seat0sex = 0
local seat1sex = 1
local seat2sex = 1
--玩家退出组局
local bPlayerExitGroup = false
local bShowGroupTime = false

--玩家状态
--0，进入游戏
--1，登录游戏成功
--2，准备
--10,围观
local state_player = 0

local reLoadMatchLevel = 0
local isMatchWait = 0

--出完牌玩家id
local finishGameUid = 0
--退出
local bLogout = false

--组局
local groupRanking = {}
local group_game_amount = 0

local cardY = 122
local jumpCardY = 25
local headSize = 62

local tbPlayCardInfo = {} -- 保存牌桌上最后的牌及牌型 last_cards, card_type


local user_max_cards = 16
local USER_HAND_CARDS_FOR_DEAL = 16


tbResult = {}

--记录房间用户信息
bm.Room = {}
bm.Room.UserInfo  = {}
bm.Room.out_card_list = {} -- 出牌操作缓存

function PlayCardScene:resetState()
    if device.platform=="android"  then
        if _G.notifiLayer.rootNode then
            _G.notifiLayer.rootNode:setPositionY(_G.notifiLayer.rootNode:getPositionY() - 20)  --电量显示
        end
    end
    -- body
    state_player = 0
    reLoadMatchLevel = 0
    isMatchWait = 0
    finishGameUid = 0
    bLogout = false
    groupRanking = {}
    group_game_amount = 0

    require("pdk.pdkSettings"):setGroupState(0)
    tbResult = {}
    bPlayerExitGroup = false
    bShowGroupTime = false
    seat1sex = 1
    seat2sex = 1

    USERID2SEAT = {}
    SEAT2USERID = {}
    REMAINCARDS = {}
    bFirst = true
--local bUnmatchCard = false
    bFakeLogout = false
    tbTipsCards = {}
    dtUpdate = 0
    tbWin = {}
    bGameOver = false
    iLiftTime = 20
    iLastLiftTime = 18
    iActionCounts = 0
    bPlayCard = 0
    tbSeatCoin = {}
    bOnDeal = false
    isDealAllCards = false
    isReload = false
    iGameState = 0
    iGameCount = 0
    nGameNo = 0
    tbHistory = {}
    ptTouchBegin = cc.p(0,0)
--自动出牌
    bAuto = false

--时间片update
    bUpdateClock = false
    iClockSeat = 0
--发牌
    bUpdateSendCard = false
    fTimeSendCard = 0
    iSendIndex = 0
--过金币
    bShowAddCoin = false
    fTimeDrawCoins = 0
--特效音效
    bBombMusic = false
end

function PlayCardScene:ctor()
    dump("初始化", "----- 跑得快 -----")


	isShowNetLog = false

    bm.server:setProtocol(PROTOCOL)
    bm.server:setHandle(pdkHandle.new())

    local pdk_face_node = pdk_face.new()
    pdk_face_node:setHandle(bm.server:getHandle())
    self:addChild(pdk_face_node, 9999)
    pdk_face_node:setName("faceUI")

    display.addSpriteFrames("pdk/Game/cards/cards.plist", "pdk/Game/cards/cards.png")

    -- print("kkkkkkkkkkkkkkkkkkkkkkkkkkkkkk enter_mode",USER_INFO["enter_mode"])
    -- audio.preloadMusic("pdk/audio/bgm1.mp3")
    bGameOver = false
    
    local cardScene = cc.CSLoader:createNode("pdk/csb/roomScene.csb"):addTo(self)
    self._scene = cardScene

    -- modify beg     by:Jhao     date:2016-11-2 17:22:10 --
    local widgetsName = {"touxiangbufen_0", "touxiangbufen_1", "touxiangbufen_2"}
    for k, widgetName in pairs(widgetsName) do
        head = self._scene:getChildByName(widgetName):getChildByName("head")
        if head then
            local head_info = {}
            head_info["url"] = "pdk/Game/hall_ui/room_default_none.png"
            head_info["sp"] = head
            head_info["size"] = headSize
            head_info["touchable"] = 0
            head_info["use_sharp"] = 1
            require("hall.GameCommon"):setUserHead(head_info)

            local txt_gold = self._scene:getChildByName(widgetName):getChildByName("gold_mine")
            if txt_gold then
                local lable = ccui.TextBMFont:create("", "hall/proxy/image/num.fnt")
                lable:setName("gold_mine")
                lable:setAnchorPoint(cc.p(0,0.5))
                lable:setScale(0.5)
                lable:addTo(txt_gold:getParent())
                lable:setPosition(txt_gold:getPosition())
                txt_gold:removeSelf()
            end
        end
    end
    -- modify end --
    self.layer_bottom = self._scene:getChildByName("layer_bottom")
    local txt_gold = self.layer_bottom:getChildByName("gold_mine")
    if txt_gold then
        local lable = ccui.TextBMFont:create("", "hall/proxy/image/num.fnt")
        lable:setName("gold_mine")
        lable:addTo(txt_gold:getParent())
        lable:setPosition(txt_gold:getPosition())
        txt_gold:removeSelf()
    end


    self.layout_ui = cardScene:getChildByName("layout_ui")
    local laytop = self._scene:getChildByName("play_top")

	-- @modify by:Jhao.
    -- self.layout_ui:addTouchEventListener(function(sender,event)
    --     if event==2 then
    --         sender:setTouchEnabled(false)
    --         require("pdk.pdkServer"):CLI_PASS()
    --     end
    -- end)    

    self.layout_ui:getChildByName("buttons"):setVisible(false)
    self.btn_pass = self.layout_ui:getChildByName("buttons"):getChildByName("btn_pass")
    self.btn_tip = self.layout_ui:getChildByName("buttons"):getChildByName("btn_tip")
    self.btn_discard = self.layout_ui:getChildByName("buttons"):getChildByName("btn_discard")
    self.btn_pass:addTouchEventListener(function(sender,event)
        if event == 0 then
            sender:setScale(1.1)
        end

        if event == 2 then
            sender:setScale(1)

            if G_FINISH_FIRST_PLAY then
                return
            end

			-- if not self:eventPassBtn() then
			-- 	print("not self:eventPassBtn() )))))))))))  @@@@@@@@@@@@")
   --          	self:showErrorTips("kind_error")
			-- 	return 
			-- end

            --PASS
            require("pdk.pdkServer"):CLI_PASS()
            -- iActionCounts = 0
            --选的牌收回
            self:cleanCards()
            --消息发送隐藏按钮
            self:cleanupPlayCardBtn()
        end
    end)

    self.btn_tip:addTouchEventListener(function(sender,event)
        if event == 0 then
            sender:setScale(1.1)
        end

        if event == 2 then
            sender:setScale(1)
            require("hall.GameCommon"):playEffectSound("hall/Audio_Button_Click.mp3")

            local tt,main_card
            if self._getSuit == 0 then
                self._hasselect = {}
            end
            tt,main_card = CardAnalysis:getSuitCard(tbPlayCardInfo["card_type"],tbPlayCardInfo["last_cards"],self._hasselect)
            if tt then
                self._getSuit = 1
                self:popCard(tt)
                self._hasselect[main_card] = 1
                self:chuIfLight()
            else
                --重置循环提示
                if self._getSuit == 1 then
                    print("reset suit card neoooooooo")
                    self._hasselect = {}
                    tt,main_card = CardAnalysis:getSuitCard(tbPlayCardInfo["card_type"],tbPlayCardInfo["last_cards"],self._hasselect) 
                    if tt then
                        self:popCard(tt)
                        self._hasselect[main_card] = 1
                        --end
                        self:chuIfLight()
                        return
                    end
                end

                if not tbPlayCardInfo["card_type"] then
                    local card   = CardAnalysis:getLitleCard(self._notice)
                    self._notice[card[1][1]] =  1  
                    if card[1][1] ==  USER_INFO["cards"][1][1] then
                        self._notice = {}
                    end
                    self:popCard(card)
                    self:chuIfLight()
                else
                    require("pdk.pdkServer"):CLI_PASS()
                    -- iActionCounts = 0
                    --选的牌收回
                    self:cleanCards()
                    --消息发送隐藏按钮
                    self:cleanupPlayCardBtn()
                end
            end
        end
    end)
    self.btn_discard:addTouchEventListener(function(sender,event)
        if event == 0 then
            sender:setScale(1.1)
        end      

        if event == 2 then
            sender:setScale(1)

			print("@@@@@@@@@@@@@@@@ btn_discard")

            require("hall.GameCommon"):playEffectSound("hall/Audio_Button_Click.mp3")
            ---------------- check cards type ----------------
    --         if self:checkPlayCard(true) == false then
				-- print("@@@@@@@@@@@@@@@@ :checkPlayCard(true) == false ")
    --             return true
    --         end
            ---------------- check cards type ----------------
            local cardAmount = 0
            local cards = {}
            for key,value in pairs(USER_INFO["cards"]) do
                if  USER_INFO.cards[key][5] == 1 then
                    local cardvalue = value[1] + value[2]*16
                    print("out card:%d   value:%d    type:%x",cardvalue,value[1],value[2]*16)
                    cardvalue = Card:Encode(cardvalue)
                    local card = {}
                    card["card"] = cardvalue
                    table.insert(cards,card)
                    cardAmount = cardAmount + 1
                end
            end
            print("out cards----------->%s",json.encode(cards))
            --出牌
            require("pdk.pdkServer"):CLI_PLAYER_CARD(cardAmount,cards)
            -- iActionCounts = 0
            --消息发送隐藏按钮
            self:cleanupPlayCardBtn()
        end
    end)

    for i = 1, 3 do
        local im_ready = self._scene:getChildByName("touxiangbufen_"..tostring(i-1)):getChildByName("im_ready")
        im_ready:setVisible(false)
    end

    --注册按钮事件
    self.layer_top = self._scene:getChildByName("play_top")
    local btnEixt   = self.layer_top:getChildByName("btn_exit")
    if btnEixt then
        btnEixt:setTouchEnabled(true)
    end
    local btnSetting   = self.layer_top:getChildByName("btn_setting")
    if btnSetting then
        btnSetting:setTouchEnabled(true)
    end
    local btn_recharge = self.layer_bottom:getChildByName("btn_recharge")

    local function touchButtonEvent(sender, event)
        --缩小ui
        if event == TOUCH_EVENT_BEGAN then
            require("hall.GameCommon"):playEffectSound("hall/Audio_Button_Click.mp3")
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
                                if bm.Room and bm.Room.start_group == 1 then
                                    require("hall.GameTips"):showTips("提示", "", 2, "游戏已经开始，不能返回大厅")
                                else
                                    local function okCallback()
                                        if bm.notCheckReload and bm.notCheckReload ~= 1 then
                                            bm.notCheckReload = 1
                                            require("pdk.pdkServer"):CLI_LOGOUT_ROOM()
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
            --充值
            if sender == btn_recharge then
            end
            --记牌器
            if sender == btn_calc then
            end
        end
    end
    btnEixt:addTouchEventListener(touchButtonEvent)
    btnSetting:addTouchEventListener(touchButtonEvent)
    btn_recharge:addTouchEventListener(touchButtonEvent)

    -- self:displayMine()
    self:displayMyselfInfo(1)

    self.layout_effect = cardScene:getChildByName("layout_effect")

    local btn_history = self.layer_top:getChildByName("btn_history")
    local layer_group_time = self._scene:getChildByName("layer_group_time")

    -- --解散房间按钮
    -- local function release_group_callbaack(event)
    --     -- body
    --     if event.name == "ended" then
    --         -- require("pdk.pdkServer"):C2S_DISSOLVE_ROOM()
    --     end
    -- end
    local btn_release_group = self._scene:getChildByName("btn_release_group")
    btn_release_group:setVisible(true)
	btn_release_group:setPositionY(btn_release_group:getPositionY() - 50)
    btn_release_group:addTouchEventListener(function(sender,event)
        if event == 0 then
            sender:setScale(1.1)
        end

        if event == 2 then
            sender:setScale(1)

            dump("解散房间按钮点击", "-----斗地主-----")
            self:disbandGroup()
        end
    end)

    if USER_INFO["enter_mode"]==0 then
        if btn_history then
            btn_history:setVisible(false)
        end
        if layer_group_time then
            layer_group_time:setVisible(false)
        end
        self.layer_top:getChildByName("btn_menu"):setVisible(false)
    elseif USER_INFO["enter_mode"]==1 then
        if btn_history then
            btn_history:setVisible(true)
            btn_history:addTouchEventListener(function(sender,event)
                if event==2 then
                    -- sender:setTouchEnabled(false)
                    if state_player ~= 0 then
                        require("hall.GameCommon"):getHistory()
                    end
                end
            end)
        end


        if layer_group_time then
            layer_group_time:setVisible(true)
        end

        print("-----------------------if USER_INFO[] == UID then------------------",UID,USER_INFO["group_owner"])

    end

    if btn_history then
        btn_history:setVisible(false)
    end

    local txt_nick1 = self._scene:getChildByName("touxiangbufen_1"):getChildByName("Text_13")
    local txt_nick2 = self._scene:getChildByName("touxiangbufen_2"):getChildByName("Text_13")
    txt_nick1:enableShadow(cc.c4b(255,255,255,255),cc.size(1,0),0)
    txt_nick2:enableShadow(cc.c4b(255,255,255,255),cc.size(1,0),0)

    local pos = {{810,450},{150,450}}
    for i=1,2 do

        local player = self._scene:getChildByName("touxiangbufen_"..tostring(i))

        local alarm = require("pdk.Animation"):Alarm()
        if alarm then
            local s = 0.3
            self.layout_ui:addChild(alarm)
            alarm:setVisible(false)
            alarm:setName("baojing"..tostring(i))
            -- alarm:setScale(s)
            -- alarm:setPosition(cc.p(player:getPositionX(), player:getPositionY()+alarm:getContentSize().height/4*s-20))

			local offsetX = -60
			local offsetY = -50
			local posX = player:getPositionX() + offsetX
			local posY = player:getPositionY() + alarm:getContentSize().height/4*s + offsetY
			if i == 2 then 
				posX = player:getPositionX() - offsetX
			end
            alarm:setPosition(cc.p(posX, posY))
        end
    end
    
    ---------------------------------------------@by tao----------------
    self.btnFaceui_txt=self.layer_bottom:getChildByName("btn_chat");
    self.btnFaceui_faceui=self.layer_bottom:getChildByName("btn_emoji");
    -- self.btnFaceui_txt:hide();
    -- self.btnFaceui_faceui:hide();
    self.btnFaceui_txt.id=0;
    self.btnFaceui_faceui.id=1;
    local function onface_click(sender)
        sender:setScale9Enabled(true)
        sender:setContentSize(cc.size(70,70))
        local pos=sender:getPosition()
        if sender.id ==1 then
            pdk_face_node:showFacePanle(pos)
        else
            pdk_face_node:showTxtPanle(cc.p(self.btnFaceui_txt:getPositionX() - 400, self.btnFaceui_txt:getPositionY() + self.btnFaceui_txt:getContentSize().height/2))
        end

        print("click faceui")
        
    end
    self.btnFaceui_txt:onClick(onface_click)
    self.btnFaceui_faceui:onClick(onface_click)

    -- cct.showradioMessage(self,false);
    ---------------------------------------------------------------------

    --视频录制
    local btn_record = self.layer_top:getChildByName("btn_live_video")
    btn_record:setVisible(false)
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

    --邀请好友
    --邀请微信好友
    local invite_ly = self._scene:getChildByName("invite_ly")
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
                
                require("hall.common.ShareLayer"):showShareLayer("跑得快，房号：" .. USER_INFO["invote_code"], "https://a.mlinks.cc/AK3b", "url", share_content)
            
            end
        end
    )

    self:onEnters()
end

--解散房间
function PlayCardScene:disbandGroup()
    --查询用户当前的游戏状态来判断当前通过怎样的方式来解散组局
    require("hall.gameSettings"):disbandGroup("pdk")

end

--更新自己位置上的信息
function PlayCardScene:displayMyselfInfo(flag)
    flag = flag or 1

    print("displayMyselfInfo flag:",flag,USER_INFO["icon_url"])
    local head = self._scene:getChildByName("touxiangbufen_0"):getChildByName("head")
    if head then
        if flag > 0 then
            local head_info = {}
            head_info["icon_url"] = USER_INFO["icon_url"]
            head_info["uid"] = tonumber(UID)
            head_info["sex"] = USER_INFO["sex"]
            head_info["sp"] = head
            head_info["size"] = headSize
            head_info["touchable"] = 0
            head_info["use_sharp"] = 1
            head_info["vip"] = USER_INFO["isVip"]
            -- require("hall.GameCommon"):getUserHead(head_info)
            require("hall.GameCommon"):setPlayerHead(head_info,head,headSize)
        else
            local head_info = {}
            head_info["url"] = "pdk/Game/hall_ui/room_default_none.png"
            head_info["sp"] = head
            head_info["size"] = headSize
            head_info["touchable"] = 0
            head_info["use_sharp"] = 1
            require("hall.GameCommon"):setUserHead(head_info)
        -- require("hall.GameCommon"):setPlayerHead(head_info,head,headSize)
        end
    end
    local sex = self._scene:getChildByName("touxiangbufen_0"):getChildByName("sex")
    local  str = 1
    if flag > 0 then
        str = "pdk/common/sex_"..tostring(USER_INFO["sex"])..".png"
    else
        str = "pdk/common/sex_1.png"
    end
    print("sex pictrue:",str)
    sex:setTexture(str)
    if flag > 0 then
        -- self:displayMine()
    else
        local touxiangbufen_0 = self._scene:getChildByName("touxiangbufen_0")
        if touxiangbufen_0 then
            local txt_nick = touxiangbufen_0:getChildByName("Text_13"):setString("")
            txt_nick:enableShadow(cc.c4b(255,255,255,255),cc.size(1,0),0)
        end

        local lbScore = self.layer_bottom:getChildByName("gold_mine")
        if lbScore then
            lbScore:setString("0")
        end
    end

    --新录音位置显示
    local user_node = self._scene:getChildByName("touxiangbufen_0")
    if user_node then
        local head = user_node:getChildByName("head")
        if head then
            local x = 0
            local y = 0
            x = user_node:getPositionX()
            y = user_node:getPositionY() - user_node:getContentSize().height/2
            x = x + head:getPositionX() + head:getContentSize().width/2
            y = y + head:getPositionY()
            require("hall.view.voicePlayView.voicePlayView"):updateUserPosition(tonumber(UID), cc.p(x, y))
        end
    end
end

--更新组局倒数时间
function PlayCardScene:updateGroupTime()
    -- body
    if require("hall.gameSettings"):getGameMode() ~= "group" then
        return
    end
    if bShowGroupTime == false then
        return
    end

    local turnSeconds = os.time()-USER_INFO["start_time"]
    local leftSeconds = USER_INFO["group_lift_time"] - turnSeconds
    local seconds = leftSeconds%60
    local minutes = math.modf(leftSeconds/60)
    local hours = math.modf(minutes/60)
    minutes = minutes%60
    local time = string.format("%02d:%02d:%02d",hours,minutes,seconds)
    local layer_group_time = self._scene:getChildByName("layer_group_time")
    if layer_group_time then
        local txtTime = layer_group_time:getChildByName("txt_time")
        if txtTime then
            if turnSeconds >= USER_INFO["group_lift_time"] then
                txtTime:setString("00:00:00")
                txtTime:setColor(cc.c3b(255,0,0))
                return
            end
            if txtTime then
                txtTime:setString(time)
                if hours == 0 and minutes < 10 then
                    txtTime:setColor(cc.c3b(255,0,0))
                else
                    txtTime:setColor(cc.c3b(134,212,248))
                end
            end
        end
    end
end


--发牌动画
local dtUpdateSendCard = 0
local bUpdateSendCard = false
local indexSendCard = 1

function PlayCardScene:sendCardAnimate()
    require("hall.GameCommon"):playEffectSound("pdk/audio/Audio_Deal_Card.mp3")
    isDealAllCards = false
    local index = 1
    local dis = 44
    indexSendCard = 1
    bUpdateSendCard = true
    dtUpdateSendCard = 0
end

--发牌动画
function PlayCardScene:updateSendCard(dt)

    if bUpdateSendCard == false then
        return
    end

    local dis = 52
 
    local startx = 30
    local xCenter = (960-startx*2)/2

    dtUpdateSendCard = dtUpdateSendCard + dt
    if dtUpdateSendCard >= 0.1 then
        dtUpdateSendCard = dtUpdateSendCard - 0.1
        self:clearCards()
        local dis    = (960-startx*2)/indexSendCard
        if dis > 52 then
            dis = 52
        end
        startx = startx + xCenter-(indexSendCard-1)*dis/2
        for i = 1, indexSendCard do
            local card_area,x,y =  self:addCard(USER_INFO.cards[i][1],USER_INFO.cards[i][2],startx,flag,i,dis)
            if card_area == nil then
                is_debug = false
                bUpdateSendCard = false
                self:clearCards()
                self:resetDeal()
                self:sendCardAnimate()
                return
            end

            USER_INFO.cards[i][3] = x
            USER_INFO.cards[i][4] = y
            USER_INFO.cards[i][5] = 0
        end 

        indexSendCard = indexSendCard + 1
        if indexSendCard > USER_HAND_CARDS_FOR_DEAL then
            bUpdateSendCard = false
            bOnDeal = false
            isDealAllCards = true

			if USERID2SEAT[G_PLAYER_CARD_ID] == USER_INFO["seat"] then
    		    self:cardClear()
    		    self:setCard(1)
    		    self:showFourButton(0,1,1,0)
    		    -- iLiftTime = 20
    		    bPlayCard = 1 --  出牌标记 
    		else
    		    bPlayCard = 0
    		end

            -- 发完牌后，是否有出牌操作
            self:dealOutCard()

    		-- self:clearAllUserDesk()
    		-- local tmp2,index = require("pdk.pdkSettings"):getDOS(USERID2SEAT[G_PLAYER_CARD_ID])

    		-- if USERID2SEAT[G_PLAYER_CARD_ID] == USER_INFO["seat"] then
    		--     self:clockAnimation(index,iLiftTime)
    		-- else
    		--     self:clockAnimation(index)
			-- end

            -- --发完牌，显示叫地主
            -- if iGameState == 21 then
            --     self:clockAnimation(0)
            --     self:setJiaoPanel()
            -- end
        end
    end
end

--停止玩家闹钟
function PlayCardScene:stopPlayerClock(uid)
    print("stopPlayerClock:"..uid)
    local seat = USERID2SEAT[uid]
    self.layout_ui:removeChildByName("clock"..tostring(seat))
    bUpdateClock = false
end

--闹钟动画
function PlayCardScene:clockAnimation(seat,leftTime)
    print("start clock:"..seat)
    iClockSeat = seat
    if self.layout_ui:getChildByName("clock"..tostring(iClockSeat)) then
        self.layout_ui:removeChildByName("clock"..tostring(iClockSeat))
    end
    if self.layout_ui:getChildByName("tt"..tostring(seat)) then
        self.layout_ui:removeChildByName("tt"..tostring(seat))
    end

    --cc.SpriteFrameCache:getInstance():addSpriteFrames("pdk/Plist.plist","pdk/Plist.png")
    local node = display.newNode()
    local a    =  display.newSprite("pdk/images/naozhong_03.png")
    local num  =  self._scene:getChildByName("clock_num") --Tag(70)
    local numt = num:clone()
    numt:setName("txtClockNum")

    local xp   = posClock[iClockSeat+1][1]
    local yp   = posClock[iClockSeat+1][2]
    self.clocktt    = 0
    node:addChild(a)
    node:addChild(numt)
    node:setName("clock"..tostring(iClockSeat))

    numt:setVisible(true)
    --a:setScale(0.5)
    a:setPosition(cc.p(xp,yp))
    a:setName("sp_clock")

    self._clcoktime = socket.gettime()

    iLiftTime = 18
    if leftTime then
        iLiftTime = leftTime
    end
    if iLiftTime > 50 or iLiftTime < 0 then
        iLiftTime = 18
    end
    if bPlayCard == 1 then
        print("play card set time iActionCounts:"..tostring(iActionCounts))
        if iActionCounts == 1 then
            iLiftTime = 13
        elseif iActionCounts == 2 then
            iLiftTime = 8
        elseif iActionCounts >= 3 then
            iLiftTime = 1
        end
    end

    if iLiftTime < 0 then
        iLiftTime = 0
    end
    numt:setPosition(cc.p(xp,yp))
    numt:setString(tostring(iLiftTime))
    node:addTo(self.layout_ui)
    print("clockAnimation  layout_ui",type(self.layout_ui),tostring(self.layout_ui:isVisible()))

    if seat == 0 then
        print("clockAnimation iLiftTime:"..iLiftTime.."        iActionCounts:"..iActionCounts)
    end

    bUpdateClock = true
end

--时钟更新
function PlayCardScene:updateClock()
    if bUpdateClock == false then
        return
    end

    local spClock = self.layout_ui:getChildByName("clock"..tostring(iClockSeat))
    if spClock then
        local txtTime = spClock:getChildByName("txtClockNum")
        if txtTime then
            local now    = socket.gettime()
            local cut    = now - self._clcoktime
            local rest   = iLiftTime -  cut
            if iClockSeat ~= 0 then
                rest = 18 - cut
            end

            rest         = math.floor(rest)
            local strnow
            strnow       = rest
            if(rest < 10) then
                strnow = "0"..rest
            end
            if rest > 0 then
                txtTime:setString(strnow)
            end

            if(cut >= iLiftTime) then
                print("unaction times:"..iActionCounts)
                if state_player == 1 then--没准备,准备倒计时
                    bLogout = true
                    require("pdk.pdkSettings"):requestExit()
                    -- self:stopClockAnimation()
                end
                bUpdateClock = false
            end
        end
    end
end
--自动出牌或PASS
function PlayCardScene:autoAction()
    if tbPlayCardInfo["last_cards"] ~= nil then
        --PASS
        require("pdk.pdkServer"):CLI_PASS()
    else
        --自动出牌
        local card   = CardAnalysis:getLitleCard(self._notice)
        self._notice[card[1][1]] =  1
        if card[1][1] ==  USER_INFO["cards"][1][1] then
            self._notice = {}
        end
        self:popCard(card)
        ---------------- check cards type ----------------
        if self:checkPlayCard(true) == false then
            return true
        end
        ---------------- check cards type ----------------
        local cardAmount = 0
        local cards = {}
        for key,value in pairs(USER_INFO["cards"]) do
            if  USER_INFO.cards[key][5] == 1 then
                local cardvalue = value[1] + value[2]*16
                print("out card:%d   value:%d    type:%x",cardvalue,value[1],value[2]*16)
                cardvalue = Card:Encode(cardvalue)
                local card = {}
                card["card"] = cardvalue
                table.insert(cards,card)
                cardAmount = cardAmount + 1
            end
        end
        print("out cards----------->%s",json.encode(cards))
            --出牌
            require("pdk.pdkServer"):CLI_PLAYER_CARD(cardAmount,cards)
        --消息发送隐藏按钮
        self:cleanupPlayCardBtn()
    end
end



--停止闹钟动画
function PlayCardScene:stopClockAnimation()
    print("stop clock")
    if self._chandle then
        print("stop unscheduleGlobal")
        scheduler.unscheduleGlobal(self._chandle)
    end
    for i = 0,2 do
        if self.layout_ui:getChildByName("clock"..i) then
            self.layout_ui:removeChildByName("clock"..i)
        end
    end

    self.clocktt = 0
    self._chandle = nil
end

-- 清空手上的牌
function PlayCardScene:clearCards()
    if USER_INFO.cards == nil then--牌容器空
        return
    end

    for key, value in pairs(USER_INFO.cards) do
        local tag_tmp   = value[1]+(value[2]+100)*20
        local card_area = self.layout_ui:getChildByTag(tag_tmp)
        self.layout_ui:removeChild(card_area)
    end
end
-- 重新显示牌 状态全部清洗 默认视为玩家手中牌 减少了
function  PlayCardScene:setCard(flag)
    local len = 0
    for key, value in pairs(USER_INFO.cards) do
        len = len + 1
    end

    local startx = 30
    local xCenter = (960-startx*2)/2
    local dis    = (960-startx*2)/len
    if dis > 52 then
        dis = 52
    end
    --dis          = dis > 60 and 60 or dis
    startx = startx + xCenter-(len-1)*dis/2--(100+dis*(len - 1))/2--480-(len-1)*25
    local num = 1
    local show_logo = 0
    -- dump(USER_INFO["cards"], "setCard")
    for key, value in pairs(USER_INFO.cards) do
        if num == #USER_INFO.cards and tbResult["type"] == 1 then
            show_logo = 1
        end
        -- dump(value, "setCard addCard:"..tostring(key))
        local card_area,x,y =  self:addCard(value[1],value[2],startx,flag,num,dis,show_logo)
        USER_INFO.cards[key][3] = x
        USER_INFO.cards[key][4] = y
        USER_INFO.cards[key][5] = 0
        num = num + 1
    end 
end

-- 重新显示牌 重新插入 保持选中状态
function  PlayCardScene:setCardOther()

    for key, value in pairs(USER_INFO.cards) do
        local tag_tmp              = value[1]+(value[2]+100)*20
        local card_area            = self.layout_ui:getChildByTag(tag_tmp)
        if card_area then
            local px  = card_area:getPositionX()
            local py  = card_area:getPositionY()
            if value[5] == 1 then
                if py <= cardY then
                    card_area:setPosition(px,py+jumpCardY)
                    value[4] = card_area:getPositionY()
                end
            else
                if py > cardY then
                    card_area:setPosition(px,py-jumpCardY)
                    value[4] = card_area:getPositionY()
                end
            end

            self:toWhite(tag_tmp)
        end

    end
end

-- 重新显示牌 位置状态未改变
function  PlayCardScene:setCardWhite()
    for key, value in pairs(USER_INFO.cards) do
       local tag              = value[1]+(value[2]+100)*20
       self:toWhite(tag)
       local card_area = self.layout_ui:getChildByTag(tag)
       card_area:setScale(0.5)
       if value[5] == 1 then
            card_area:setPosition(value[3],value[4]+30)
       else
            card_area:setPosition(value[3],value[4])
       end
    end
end

--牌容器增加牌
function PlayCardScene:addCard(value,kind,startx,flag,cout,dis,show_landlord)

    	local isLandlord = show_landlord or 0
        local tag              = value+(kind+100)*20
        local img              = Card:getCard(value,kind,isLandlord)
             color             = img:getColor() --全局牌的白色的颜色

        img:addTo(self.layout_ui)
        img:setTag(tag)
        if require("pdk.pdkSettings"):getLookState() == 2 then
            img:setTouchEnabled(false)
        else
            img:setTouchEnabled(true)
        end
        img:setTouchSwallowEnabled(true)
        if flag ~= 0 then
            self._card_start_x = 0 
            self._card_start_y = 0 
            self._card_move_type = 0
            img:addNodeEventListener(cc.NODE_TOUCH_EVENT,function ( event )
                if event.name == "began"  then
                        self._card_start_x   = img:getPositionX()
                        self._card_start_y   = img:getPositionY()
                        ptTouchBegin.x = event.x
                        ptTouchBegin.y = event.y
                        self._card_move_type = 0 
                        self._card_move_type_2_back = 0
                        self:toBlack(tag)
                        event.type = 0
                        self._card_draw = 0
                        return true
                end

                if event.name == "ended"  then
                    print("NODE_TOUCH_EVENT ended")
                    if self._card_move_type == 0 then
                        require("hall.GameCommon"):playEffectSound("hall/Audio_Button_Click.mp3")
                        local y = img:getPositionY()
                        if y > cardY then
                            img:setPositionY(y-jumpCardY)
                            local index = Card:getCardIndex(tag)
                            USER_INFO.cards[index][5] = 0
                        else
                            img:setPositionY(y+jumpCardY)
                            local index = Card:getCardIndex(tag)
                            USER_INFO.cards[index][5] = 1
                        end

                        self:toWhite(tag)
                    else
                        if self._card_move_type == 1 then
                            local tbCards = self:touchSelectCard(rtSelectCard)
                            print("tbCards"..json.encode(tbCards))


                            for key, value in pairs(USER_INFO.cards) do
                                local tag              = value[1]+(value[2]+100)*20 
                                if type(tbCards)=="table" then
                                                                   
                                    for i, valueSelect in pairs(tbCards) do
                                        if valueSelect == tag then
                                            value[5] = 1 - value[5]
                                        end
                                    end
                                end
                            end

                            -- print("touchRect:x[%d]--width[%d]",rtSelectCard.x,rtSelectCard.width)
                            print("hand cards--------------->")
                            print_lua_table(USER_INFO.cards)

                            self:setCardOther()
                            self._card_move_type = 0
                        end

                         if self._card_move_type == 2 then
                            self:setCardWhite()
                            self._card_move_type_2_back = 0
                        end
                    end
                   
                    self._card_start_x   = 0 
                    self._card_start_y   = 0 
                    self._card_move_type = 0
                    self._card_draw      = 0

                    self:chuIfLight()
                end

                if event.name == "moved" then
                     --左右拉选
                    -- if self._card_move_type  == 1 then
                    if  (self._card_move_type  ==  1 or (math.abs(event.x - self._card_start_x) > 5  and (math.abs(event.y - self._card_start_y)  / math.abs(event.x - self._card_start_x) ) < 0.5 )) and self._card_move_type_2_back == 0  then
                         self._card_move_type  = 1
                         local startx_t  =    event.x<= self._card_start_x and event.x - 20  or self._card_start_x
                         local width     =    event.x - self._card_start_x > 0 and event.x - self._card_start_x + 20 or self._card_start_x -  event.x
                         if startx_t == event.x - 20 then
                            width = width + 30
                         end
                         rtSelectCard      =    cc.rect(startx_t,0,width,320)

                         self:touchAreaCard(rtSelectCard,tag)

                         return
                    end
                    -- end

                    if math.abs(event.x - ptTouchBegin.x) > 5  then
                        print("touch rect move")
                        self._card_move_type = 1 --左右选择
                        return
                    end
                end
            end)
        end      

        img:setPosition(cc.p(startx + (cout-1) *dis ,cardY))

        local x = img:getPositionX()
        local y = cardY

        return img,x,y
end

--设置牌可以触摸
function PlayCardScene:setCardTouched(flag)
    for key, value in pairs(USER_INFO.cards) do 
        local now_tag = Card:getKey(value[1],value[2])
        local tmp = self.layout_ui:getChildByTag(now_tag)
        if tmp then
            tmp:setTouchEnabled(flag)
        end
    end
end

function PlayCardScene:onEnters()
    
    self:resetState()

    require("hall.GameSetting"):showGameAwardPool()

    --记牌器
    require("pdk.calcCards"):init()
    require("pdk.PlayVideo"):init()
    self:setGameMode()
    require("hall.GameCommon"):playEffectMusic("pdk/audio/bgm1.mp3",true)
    
    local function update(dt)
        local lbTime = self._scene:getChildByName("Text_1")
        if lbTime then
            local time = os.date("%H:%M", os.time())
            lbTime:setString(time)
        end
        self:updateClock()
        self:updateDrawCoin(dt) 
        self:updateGroupTime()
        self:updateSendCard(dt)
        --直播
        require("pdk.PlayVideo"):update(dt)

        if bBombMusic then
            local flag = cc.SimpleAudioEngine:getInstance():isMusicPlaying()
            if not flag then
                bBombMusic = false
				print("--- playEffectMusic(pdk/audio/bgm.mp3, true")
                require("hall.GameCommon"):playEffectMusic("pdk/audio/bgm1.mp3",true)
            end
        end

    end
    self:scheduleUpdateWithPriorityLua(update,0)

    --登录房间
    pdkServer:LoginRoom(require("hall.GameList"):getReloadTable())

    self:setGameConfig()

end

--房间配置
function PlayCardScene:setGameConfig()
    local panel = self._scene:getChildByName("p_game_config")
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
        local panelGameno = self._scene:getChildByName("p_game_no")
        local txt_panelGameno = self._scene:getChildByName("p_game_no"):getChildByName("txt_game_no")
        txt_panelGameno:setVisible(false)
        if panelGameno then
            panelGameno:setPositionX(480-backWith/2)
        end
        --调整底注位置
        local p_base_chip = self._scene:getChildByName("p_base_chip")
        if p_base_chip then
            p_base_chip:setPositionX(480+backWith/2)
        end
    end
end

--设置游戏模式
function PlayCardScene:setGameMode()
    local mode = require("hall.gameSettings"):getGameMode()

    print("PlayCardScene:setGameMode",tostring(mode))
    --组局显示邀请码
    local lb = self._scene:getChildByName("txt_invitecode")
    if lb then
        if mode == "group" then
            -- require("hall.common.GroupGame"):showInvoteCode()
            print("set invote_code:",tostring(USER_INFO["invote_code"]))
            lb:setString("房间号:"..USER_INFO["invote_code"])
            lb:setVisible(true)
        else
            lb:setVisible(false)
        end
    end
    if mode == "match" then
        spGold = self._scene:getChildByName("touxiangbufen_2"):getChildByName("gold")
        if spGold then
            spGold:setTexture("hall/common/score_bt.png")
            spGold:setScale(0.5)
        end
        spGold = self._scene:getChildByName("touxiangbufen_1"):getChildByName("gold")
        if spGold then
            spGold:setTexture("hall/common/score_bt.png")
            spGold:setScale(0.5)
        end
    end
end

function PlayCardScene:onExit()
    self:unscheduleUpdate()
    coutt = 0
    iLiftTime = 18
    iLastLiftTime = 18
	print(" onExit --- stop   AudioEngine.stopAllEffects")
    AudioEngine.stopAllEffects()
    audio.stopMusic(false)
end

--准备完毕
function PlayCardScene:ready(flag)
    flag = flag or 1
    print("PlayCardScene:ready()")
    local ready_btn = self._scene:getChildByName("readybtn")

    if ready_btn then
        ready_btn:setVisible(false)
        ready_btn:setEnabled(false)
    end

    local btn_select_chip = self._scene:getChildByName("btn_select_chip")
    if btn_select_chip then
        btn_select_chip:setVisible(false)
        btn_select_chip:setEnabled(false)
    end

    if state_player < 10 then
        state_player = 2
    end

    local im_ready = self._scene:getChildByName("touxiangbufen_0"):getChildByName("im_ready")
    if im_ready then
        if flag > 0 then
            im_ready:setVisible(true)
        else
            im_ready:setVisible(false)
        end
    end

    require("hall.VoiceRecord.VoiceRecordView"):showView(890, 290)
end

--触摸区选牌
function PlayCardScene:touchSelectCard(rect)
    if rect == nil then
        return
    end

    local tbSelectCards = {}
    local tmp_table     = {} 
    local tmp_value     = {}
    for key, value in pairs(USER_INFO.cards) do
        local tag = value[1]+(value[2]+100)*20

        flag = cc.rectContainsPoint(rect, cc.p(value[3], value[4]))
        if flag then
            table.insert(tbSelectCards,tag)
            tmp_table[value[1]] = value[2]
            table.insert(tmp_value,value[1])
        end
    end

    local res = {}
    table.sort(tmp_value)
    print("tmp_value "..json.encode(tmp_value))

    local res2 = {}
    for k,v in pairs(tmp_value) do
        if v>2  and v<15 then
            if k<#tmp_value and tmp_value[k+1] then
                if v==tmp_value[k+1] then
                    if k==1 then
                        table.insert(res2,v)
                        table.insert(res2,tmp_value[k+1])
                    elseif #res2==0 then
                        table.insert(res2,v)
                        table.insert(res2,tmp_value[k+1])
                    elseif v-res2[#res2]==1 then --v-tmp_value[k-1]==1 then
                        table.insert(res2,v)
                        table.insert(res2,tmp_value[k+1])
                    elseif v-tmp_value[k-1]>1 and #res2<6 then
                        res2 = {}
                        table.insert(res2,v)
                        table.insert(res2,tmp_value[k+1])
                    end                     
                end
            end
        end
    end  
    print("res2 "..json.encode(res2))
   
    local t_value = 0  
    for key,value in pairs(tmp_value) do  
        if value >2  and value<15 then
            if value ~= t_value then
                if t_value == 0 then
                    table.insert(res,value)
                    print(json.encode(res))
                else
                    if value  - t_value  == 1 then
                        table.insert(res,value)
                        print(json.encode(res))
                    else
                        if #res<5 then
                            res     = {}
                            table.insert(res,value)
                        else
                            break
                        end
                    end
                end
            end
        end
        t_value = value
    end 

    if #tbSelectCards <5 then
        return tbSelectCards
    else
        local last_res = {}
        if #res >=5 then             
             for key,value in pairs(res) do  
                   local s_value =  tmp_table[value]
                   local tag     =  value+(s_value+100)*20
                   table.insert(last_res,tag)

             end
             return last_res      
        elseif #res2 >=6 and res2[3]-res2[1]==1 and res2[5]-res2[3]==1 then 
             for i=1,#res2-1,2 do  
                for key, value in pairs(USER_INFO.cards) do
                    if key>1 and key<#USER_INFO.cards then
                        local value1 = USER_INFO.cards[key-1]
                        local value2 = USER_INFO.cards[key+1]
                        if value1 and value2 and res2[i] == value[1] and res2[i] == value1[1] and res2[i] ~= value2[1] then
                            local tag              = value[1]+(value[2]+100)*20
                            table.insert(last_res,tag)
                            local tag2              = value1[1]+(value1[2]+100)*20
                            table.insert(last_res,tag2)                        
                        end
                    elseif key==#USER_INFO.cards then
                        local value1 = USER_INFO.cards[key-1]                       
                        if value1 and res2[i] == value[1] and res2[i] == value1[1] then
                            local tag              = value[1]+(value[2]+100)*20
                            table.insert(last_res,tag)
                            local tag2              = value1[1]+(value1[2]+100)*20
                            table.insert(last_res,tag2)                        
                        end
                    end
                end
             end
             return last_res
        end
    end

    return tbSelectCards
end
--触摸区域显示牌
function PlayCardScene:touchAreaCard(rect,tag_t)

    for key, value in pairs(USER_INFO.cards) do  
        local tag              = value[1]+(value[2]+100)*20  
        local img              = self.layout_ui:getChildByTag(tag)

        flag = cc.rectContainsPoint(rect, cc.p(value[3], value[4]))
        if flag then
            self:toBlack(tag)
        else
            self:toWhite(tag)
        end
    end
end
--游戏结束后，显示加分动画
function PlayCardScene:drawCoin()

    dump(tbWin, "tbWin")
    local layer_win = self._scene:getChildByName("layer_win")
    for i = 0,2 do
        local dos,index = require("pdk.pdkSettings"):getDOS(i)
        local txtWin = layer_win:getChildByName(dos)
        txtWin:setVisible(true)
        local bAdd = true
        local value = tbWin[dos]
        if value > 0 then
            txtWin:setColor(cc.c3b(255,255,255))
        else
            txtWin:setColor(cc.c3b(255,0,0))
            bAdd = false
        end

        local str = ""
        if bAdd then
            str = "+0"
        else
            str = "-0"
        end
        txtWin:stopAllActions()
        txtWin:setString(str)
        local fi = cc.FadeIn:create(0.5)
        txtWin:runAction(fi)
    end
    fTimeDrawCoins = 0
    bShowAddCoin = true
    print("bShowAddCoin")

    if layer_win then
        layer_win:setVisible(true)
    end

    --移除录音按钮
    -- require("hall.VoiceRecord.VoiceRecordView"):removeView()
end

local jumpTime = 0
function PlayCardScene:updateDrawCoin(dt)
    if bShowAddCoin == false then
        return
    end

    fTimeDrawCoins = fTimeDrawCoins + dt
    if fTimeDrawCoins < jumpTime then
        return
    end
    local layer_win = self._scene:getChildByName("layer_win")
    if fTimeDrawCoins < 1+jumpTime then
        local str = ""
        for i = 0,2 do
            local dos,index = require("pdk.pdkSettings"):getDOS(i)
            local txtWin = layer_win:getChildByName(dos)
            local bAdd = true
            local value = tbWin[dos]
            if value < 0 then
                bAdd = false
            end
            if bAdd then
                str = "+0"
            else
                str = "-0"
            end
            txtWin:setString(str)
            local iAddCoin = math.modf(value*(fTimeDrawCoins-jumpTime))
            if bAdd then
                str = "+"..tostring(iAddCoin)
            else
                str = tostring(iAddCoin)
            end
            txtWin:setString(str)
            --玩家分数变动
            if require("pdk.pdkSettings"):getLookState() == 2 then
                self:drawOtherCoin(i,tbSeatCoin[i] + iAddCoin)
            else
                if i == USERID2SEAT[tonumber(UID)] then
                    local gold = 0
                    local mode = require("hall.gameSettings"):getGameMode()
                    if mode == "free" or mode == "fast" then
                        gold = USER_INFO["gold"]
                    elseif mode == "match" then
                        gold = USER_INFO["match_gold"]
                    elseif mode == "group" then
                        gold = USER_INFO["chips"]
                    end

                    self:displayMine(gold+iAddCoin)
                else
                    self:drawOtherCoin(i,tbSeatCoin[i] + iAddCoin)
                end
            end
        end
    else
        local function showFreeEnd()
            for i = 0,2 do
                local dos,index = require("pdk.pdkSettings"):getDOS(i)
                local txtWin = layer_win:getChildByName(dos)
                if txtWin then
                    txtWin:setVisible(false)
                end
            end

            self:clearAllUserDesk()
            self:clearCards()

            -- bGameOver = false
            bFakeLogout = true
            if state_player < 10 then
                state_player = 0
            end

            --登录游戏
            print("showFreeEnd  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx")
            self:stopRound()
        end
        local str = ""
        for i = 0,2 do
            local dos,index = require("pdk.pdkSettings"):getDOS(i)
            local txtWin = layer_win:getChildByName(dos)
            local bAdd = true
            local value = tbWin[dos]
            if value < 0 then
                bAdd = false
            end
            if bAdd then
                str = "+"..tostring(value)
            else
                str = tostring(value)
            end
            txtWin:setString(str)
            local mb = cc.MoveBy:create(1,cc.p(0,60))
            local mb2 = cc.MoveBy:create(0.1,cc.p(0,-60))
            local hide = cc.Hide:create()
            local delay = cc.DelayTime:create(2)
            local fo = cc.FadeOut:create(2)
            local seq = nil
            if i == 0 then
                seq = cc.Sequence:create(mb,fo, hide,mb2,cc.CallFunc:create(showFreeEnd))
            else
                seq = cc.Sequence:create(mb,fo, hide,mb2)
            end

            txtWin:runAction(seq)
            --玩家分数变动
            if require("pdk.pdkSettings"):getLookState() == 2 then
                self:drawOtherCoin(i,tbSeatCoin[i] + tbWin[dos])
                tbSeatCoin[i] = tbSeatCoin[i] + tbWin[dos]
            else
                if i == USERID2SEAT[tonumber(UID)] then
                    USER_INFO["chips"] = USER_INFO["chips"] + tbWin[dos]
                    self:displayMine(USER_INFO["chips"])
                else
                    self:drawOtherCoin(i,tbSeatCoin[i] + tbWin[dos])
                    tbSeatCoin[i] = tbSeatCoin[i] + tbWin[dos]
                end
            end
        end
        bShowAddCoin = false
    end
end
--显示其他玩家信息
function PlayCardScene:drawOther(table)
    print( "PlayCardScene:drawOther"..json.encode(table))
    if not table  or #table <= 0 then
        return -1
    end

    dump(table,"drawOther")
    local mode = require("hall.gameSettings"):getGameMode()

    for key, var in ipairs(table) do
        if var then
            dump(var, "drawOther player")
            local temp = {}
            temp["gold"] = var["gold"]
            temp["nick"] = var["nick"]
            temp["sex"] = var["sex"]
            temp["head_url"] = var["icon"]
            if mpcInGameList == nil then
                mpcInGameList = {}
            end
            mpcInGameList[var["uid"]] = temp

            SEAT2USERID[var["seat"]] = var["uid"]
            local dos,index  = require("pdk.pdkSettings"):getDOS(var["seat"])
            print("drawOther: seat["..var["seat"].."]  dos["..dos.."]  index["..index.."]")
            local head = self._scene:getChildByName(dos):getChildByName("head")
            if not tolua.isnull(head:getChildByName("duanxian"))  then   --删除断线标志
                head:removeChildByName("duanxian")
            end

            local sex  = self._scene:getChildByName(dos):getChildByName("sex")
            if sex then
                sex:setVisible(true)
                if index == 0 then
                    seat0sex = var["sex"]
                    if var["uid"] > 0 then
                        seat0sex = seat0sex - 1
                    end
                    if head then
                        local head_info = {}
                        head_info["icon_url"] = var["icon"]
                        head_info["uid"] = var["uid"]
                        head_info["sex"] = USER_INFO["sex"]
                        head_info["sp"] = head
                        head_info["size"] = headSize
                        head_info["touchable"] = 1
                        head_info["use_sharp"] = 1
                        head_info["vip"] = var["isVip"]
                        -- require("hall.GameCommon"):getUserHead(head_info)
                        require("hall.GameCommon"):setPlayerHead(head_info,head,headSize)
                    end
                    if sex then
                        local strHead = "pdk/common/sex_"..tostring(USER_INFO["sex"])..".png"
                        sex:setTexture(strHead)
                    end
                elseif index == 1 then
                    seat1sex = tonumber(var["sex"])
                    if var["uid"] > 0 then
                        seat1sex = seat1sex - 1
                    end
                    if head then
                        local head_info = {}
                        head_info["icon_url"] = var["icon"]
                        head_info["uid"] = var["uid"]
                        head_info["sex"] = seat1sex+1
                        head_info["sp"] = head
                        head_info["size"] = headSize
                        head_info["touchable"] = 1
                        head_info["use_sharp"] = 1
                        head_info["vip"] = var["isVip"]
                        -- require("hall.GameCommon"):getUserHead(head_info)
                        require("hall.GameCommon"):setPlayerHead(head_info,head,headSize)
                    end
                    if sex then
                        local strHead = "pdk/common/sex_"..tostring(seat1sex+1)..".png"
                        sex:setTexture(strHead)
                    end
                elseif index==2 then
                    seat2sex = tonumber(var["sex"])
                    if var["uid"] > 0 then
                        seat2sex = seat2sex - 1
                    end
                    if head then
                        local head_info = {}
                        head_info["icon_url"] = var["icon"]
                        head_info["uid"] = var["uid"]
                        head_info["sex"] = seat2sex+1
                        head_info["sp"] = head
                        head_info["size"] = headSize
                        head_info["touchable"] = 1
                        head_info["use_sharp"] = 1
                        head_info["vip"] = var["isVip"]
                        -- require("hall.GameCommon"):getUserHead(head_info)
                        require("hall.GameCommon"):setPlayerHead(head_info,head,headSize)
                    end
                    if sex then
                        local strHead = "pdk/common/sex_"..tostring(seat2sex+1)..".png"
                        sex:setTexture(strHead)
                    end
                end
            end

            if sex then
                sex:setVisible(false)
            end

            --新录音位置显示
            if head then
                local x = 90
                local y = 480
                if index == 1 then
                    x = 960 - x - 30
                end

                require("hall.view.voicePlayView.voicePlayView"):updateUserPosition(tonumber(var["uid"]), cc.p(x, y))
            end
            
            local im_ready = self._scene:getChildByName(dos):getChildByName("im_ready")
            local nick     = self._scene:getChildByName(dos):getChildByName("Text_13")
            local txt_gold = nil
            if index == 0 then
                txt_gold = self. layer_bottom:getChildByName("gold_mine")
            else
                txt_gold = self._scene:getChildByName(dos):getChildByName("gold_mine")
            end

            local str = ""
            local mode = require("hall.gameSettings"):getGameMode()
            if mode == "match" then
                str = "points"
            elseif mode == "group" then
                str = "chip"
            elseif mode == "free" or mode == "fast" then
                str = "gold"
            end
            local imgGold = self._scene:getChildByName(dos):getChildByName(str)
            if imgGold then
                imgGold:setVisible( true)
            end

            if var["ready"] == 1 then
                im_ready:setVisible(true)
            end
            if index == 0 then
                self:drawOtherCoin(0, var["gold"])
            else
                self:drawOtherCoin(var["seat"], var["gold"])

                local strNick = require("hall.GameCommon"):formatNick(var["nick"])
                nick:setString(strNick)
                nick:setVisible(true)
            end
        end
    end
end
--显示seat id的金币
function PlayCardScene:drawOtherCoin(seat,gold)
    local dos,index =require("pdk.pdkSettings"):getDOS(seat)
    local txt_gold = nil

    local mode = require("hall.gameSettings"):getGameMode()
    if index == 0 then
        txt_gold = self. layer_bottom:getChildByName("gold_mine")
        if txt_gold then
            txt_gold:setString(tostring(USER_INFO["gold"] - USER_INFO["group_chip"]))
        end
    else
        txt_gold = self._scene:getChildByName(dos):getChildByName("gold_mine")
        if mode == "match" then
            if txt_gold then
                txt_gold:setString(tostring(gold- USER_INFO["group_chip"]))
            end
        else
            if txt_gold then
                txt_gold:setString(tostring(gold - USER_INFO["group_chip"]))
            end
        end
    end
end

--显示自己信息
function PlayCardScene:displayMine(value)
    local mode = require("hall.gameSettings"):getGameMode()
    local coin
    if value then
        coin = value
        if mode == "group" then
            coin = coin - USER_INFO["group_chip"]
        end
    else
        if mode == "group" then
            coin = USER_INFO["chips"] or 0
            coin = coin - USER_INFO["group_chip"]
        else
            coin = USER_INFO["gold"] or 0
            coin = coin - USER_INFO["group_chip"]
        end
    end
    local touxiangbufen_0 = self._scene:getChildByName("touxiangbufen_0")
    if touxiangbufen_0 then
        local strNick = require("hall.GameCommon"):formatNick(USER_INFO["nick"])
        local txt_nick = touxiangbufen_0:getChildByName("Text_13"):setString(strNick)
        txt_nick:enableShadow(cc.c4b(255,255,255,255),cc.size(1,0),0)
    end
    local lbScore = self.layer_bottom:getChildByName("gold_mine")
    if lbScore then
        lbScore:setString(tostring(coin))
    end

end


--更新金币
function PlayCardScene:goldUpdate()
    -- body
    if USER_INFO["enter_mode"] > 0 then
        self:getChips()
    else
        local lbScore = self.layer_bottom:getChildByName("gold_mine")
        if lbScore then
            -- lbScore:setString(require("hall.GameCommon"):formatGold(tonumber(USER_INFO["gold"])))
            lbScore:setString(tostring(USER_INFO["gold"] - USER_INFO["group_chip"]))
        end
    end
end
--玩家退场
function PlayCardScene:delUser(seat)

    print("delUser seat:"..seat,tostring(SEAT2USERID[seat]))

    mpcInGameList[SEAT2USERID[seat]] = nil
    SEAT2USERID[seat] = nil

    local dos,index  = require("pdk.pdkSettings"):getDOS(seat)
    local head = self._scene:getChildByName(dos):getChildByName("head")
    local sex  = self._scene:getChildByName(dos):getChildByName("sex")
    
    local duanxian = ccui.ImageView:create("pdk/images/duanxianchonglian_bt.png")  --断线标志
    head:addChild(duanxian)
    duanxian:setName("duanxian")
    duanxian:setVisible(true)
    duanxian:setPosition(0,-110)
    print("delUser dos:"..dos)

    local im_ready = self._scene:getChildByName(dos):getChildByName("im_ready")
    local nick     = self._scene:getChildByName(dos):getChildByName("Text_13")
    local gold = nil
    if dos == "touxiangbufen_0" then
        gold = self.layer_bottom:getChildByName("gold_mine")
    else
        gold = self._scene:getChildByName(dos):getChildByName("gold_mine")
    end
    
    -- local cardNum = self.layout_ui:getChildByName("cardNum"..tostring(seat))
    -- if cardNum then
    --     cardNum:setVisible(false)
    -- end
    -- local cardNumBack = self.layout_ui:getChildByName("cardNumBack"..tostring(seat))
    -- if cardNumBack then
    --     cardNumBack:setVisible(false)
    -- end
    -- --重置头像
    -- -- head:setVisible(false)
    -- if head then
    --     local head_info = {}
    --     head_info["url"] = "pdk/Game/hall_ui/room_default_none.png"
    --     head_info["sp"] = head
    --     head_info["size"] = headSize
    --     head_info["touchable"] = 0
    --     head_info["use_sharp"] = 1
    --     require("hall.GameCommon"):setUserHead(head_info)
    --     -- require("hall.GameCommon"):setPlayerHead(head_info,head,headSize)
    -- end

    -- if sex then
    --     sex:setVisible(false)
    -- end
    -- if im_ready then
    --     im_ready:setVisible(false)
    -- end
    -- -- nick:setVisible(false)
    -- if nick then
    --     nick:setString("???")
    -- end
    -- if gold then
    --     gold:setVisible(false)
    -- end
end


-- 设置同桌玩家准备
function PlayCardScene:setOtherReady(seat)
    print("------------------------other player %d ready",seat)
    local dos,index = require("pdk.pdkSettings"):getDOS(seat)
    local im_ready = self._scene:getChildByName(dos):getChildByName("im_ready")
    im_ready:setVisible(true)
end

--牌变为选中状态
function PlayCardScene:toBlack(tag)
    local img = self.layout_ui:getChildByTag(tag)
    if img then
        -- print("toBlack",tag)
        img:setColor(cc.c3b(125, 125, 125))
    end
end

--牌变为未选中
function PlayCardScene:toWhite(tag)
    local img = self.layout_ui:getChildByTag(tag)
    if img then
        img:setColor(cc.c3b(255, 255, 255))
    end
end


--开始游戏
function PlayCardScene:start()
    local mode = require("hall.gameSettings"):getGameMode()
    print("startGame mode:"..mode)
    if mode ~= "group" then
        -- require("hall.GameData"):setPlayerRoute("pdk",mode,USER_INFO["base_chip"],1)
    end
    for i=0,2 do
        local dos,index = require("pdk.pdkSettings"):getDOS(i)
        local player = self._scene:getChildByName(dos)
        player:getChildByName("im_ready"):setVisible(false)
    end

    --添加录音按钮
    -- require("hall.VoiceRecord.VoiceRecordView"):showView(890, 290)

    if isReload==true then
        self:setCard(1)
        bOnDeal = false

        -- --发完牌，显示叫地主
        -- if iGameState == 21 then
        --     self:clockAnimation(0)
        -- end
        isReload = false
    else
		-- local sp = display.newSprite():addTo(self)
        -- sp:runAction(cc.Sequence:create(cc.DelayTime:create(10),cc.CallFunc:create(function() self:sendCardAnimate() sp:removeSelf() end)))
        -- self:sendCardAnimate()

        self:sendCardAnimate()

    end
    state_player = 2
end

local v_pos_effect = {{480,250},{760,400},{200,400}}

--进入房间设置准备按钮
function PlayCardScene:loginTableSetReafyPanel()
    --是否换桌
    state_player = 0
    local ret = require("hall.hall_data"):checkEnter("pdk",USER_INFO["gameLevel"])
    if ret > 0 then
        local adapLevel = require("hall.hall_data"):getAdapterLevel("pdk")
        if adapLevel < 0 then
            require("hall.GameTips"):showTips("余额不足，请充值","change_money",1)
            return
        end
        USER_INFO["gameLevel"] = adapLevel
    end
    local ready_btn = self._scene:getChildByName("btn_again") 
    if ready_btn == nil then
        ready_btn = self._scene:getChildByName("readybtn")
    end
    if ready_btn then
        ready_btn:setName("readybtn")
        ready_btn:setVisible(true)
        ready_btn:setEnabled(true)
        ready_btn:loadTextureNormal("hall/Settings/setting_yellow_bt.png")

        local spTxt = ready_btn:getChildByName("txt_again_29")
        if spTxt then
            if ret == 0 then
                spTxt:setTexture("pdk/images/subsidy_text_zailaiyiju.png")
            else
                spTxt:setTexture("pdk/images/text_huanzhuo.png")
            end
        end
    end
    --离开
    local btn_Select = self._scene:getChildByName("btn_select_chip")
    if btn_Select then
        btn_Select:setVisible(true)
        btn_Select:setEnabled(true)
        btn_Select:loadTextureNormal("hall/common/subsidy_blue_bt.png")
    end
    --倒计时
    self:clockAnimation(0,11)

    local mode = require("hall.gameSettings"):getGameMode()

    local function touchButtonEvent(sender, event)
        if event == TOUCH_EVENT_BEGAN then
            -- ready_btn:setScale(1.2)
        end
        if event == TOUCH_EVENT_ENDED then
            if sender == ready_btn then
                require("hall.GameCommon"):playEffectSound("hall/Audio_Button_Click.mp3")
                -- ready_btn:setScale(1)
                --组局检查筹码时候够
                if mode == "group" then
                    if USER_INFO["chips"] < USER_INFO["base_chip"]*3 then
                        --提示筹码余额不足
                        require("hall.GameTips"):showTips("筹码不足，请兑换","change_chip",1)
                        return
                    end
                end
                if mode ~= "match" then
                    -- pdkServer:LoginGame()
                    self:getChips()
                end

                self:stopClockAnimation()
                ready_btn:setEnabled(false)
                btn_Select:setEnabled(false)
                ready_btn:loadTextureNormal("hall/common/small_disable_bt_n.png")
                btn_Select:loadTextureNormal("hall/common/small_disable_bt_n.png")
            end
            if btn_Select == sender then
                --退出游戏
                state_player = 0
                self:resetState()
                if mode == "free" then
                    display_scene("pdk.SelectChip",1)
                    self:stopClockAnimation()
                end
                if mode == "fast" then
                    require("app.HallUpdate"):enterHall()
                end
                if mode == "group" then
                    require("hall.GameCommon"):gExitGroupGame(1)
                    return
                end

                --避免重复点击
                --btnEixt:setVisible(false)
                btn_Select:setTouchEnabled(false)
                bFakeLogout = false
                ready_btn:setEnabled(false)
                btn_Select:setEnabled(false)
                ready_btn:loadTextureNormal("hall/common/small_disable_bt_n.png")
                btn_Select:loadTextureNormal("hall/common/small_disable_bt_n.png")
            end
        end
    end

    if ready_btn then
        ready_btn:addTouchEventListener(touchButtonEvent)
    end
    if btn_Select then
        btn_Select:addTouchEventListener(touchButtonEvent)
    end
end

--清除排队
function PlayCardScene:cardClear()
    for key,value in pairs(USER_INFO.cards) do
         local tag_tmp              = value[1]+(value[2]+100)*20
         if self.layout_ui:getChildByTag(tag_tmp) then
            self.layout_ui:removeChildByTag(tag_tmp)
        end
    end
end

--打牌的四个按钮
function  PlayCardScene:showFourButton(a,b,c,d)
    self._notice = {}
    self._hasselect = {}
    self._getSuit   = 0
    tbTipsCards["card_type"] = nil
    tbTipsCards["last_cards"] = nil
    local bshow = true
    if require("pdk.pdkSettings"):getLookState() == 2 then
        bshow = false
    end
    self.layout_ui:getChildByName("buttons"):setVisible(bshow)

    if a==1 then
        self.btn_pass:setTouchEnabled(bshow)
        self.btn_pass:loadTextureNormal("hall/Settings/setting_yellow_bt.png")
        self.btn_pass:setContentSize(cc.size(150,78))
        if spTxt then
            spTxt:setPosition(75, 39)
        end
    else
        self.btn_pass:setTouchEnabled(false)
        self.btn_pass:loadTextureNormal("hall/common/small_disable_bt_n.png")
        self.btn_pass:setContentSize(cc.size(142,75))
    end
    self.btn_tip:setContentSize(cc.size(150,78))
    local spTxt = self.btn_pass:getChildByName("txt_pass")
    if spTxt then
        spTxt:setPosition(71, 42)
    end
    self.btn_pass:setScale9Enabled(true)
    self.btn_pass:setCapInsets(cc.rect(0,0,self.btn_pass:getContentSize().width,self.btn_pass:getContentSize().height))

    if c==1 then
        self.btn_tip:setTouchEnabled(bshow)
        self.btn_tip:loadTextureNormal("hall/Settings/setting_yellow_bt.png")
    else
        self.btn_tip:setTouchEnabled(false)
        self.btn_tip:loadTextureNormal("hall/common/small_disable_bt_n.png")
    end
    spTxt = self.btn_pass:getChildByName("txt_tip")
    if spTxt then
        spTxt:setPosition(75, 42)
    end
    self.btn_tip:setScale9Enabled(true)
    self.btn_tip:setCapInsets(cc.rect(0,0,150,78))
    self.btn_tip:setContentSize(cc.size(150,78))

    if d==1 then
        self.btn_discard:setTouchEnabled(bshow)
        self.btn_discard:loadTextureNormal("hall/Settings/small_green_bt_n.png")
    else
        self.btn_discard:setTouchEnabled(false)
        self.btn_discard:loadTextureNormal("hall/common/small_disable_bt_n.png")
    end
    spTxt = self.btn_discard:getChildByName("txt_discard")
    if spTxt then
        spTxt:setPosition(71, 42)
    end
    self.btn_discard:setScale9Enabled(true)
    self.btn_discard:setCapInsets(cc.rect(0,0,self.btn_discard:getContentSize().width,self.btn_discard:getContentSize().height))
    self.btn_discard:setContentSize(cc.size(142,78))
end

--检查出牌
function PlayCardScene:checkPlayCard(flag)
    local cards =  self:needChuCards()
    local str   =  Card:dealCardToString(cards)
    dump(cards, "needChuCards")
    local typeCard,a,b  =  CardAnalysis:getType(cards)
	print("typeCard:", typeCard)

    if typeCard == nil then
        if flag then
            self:showErrorTips("kind_error")
        end
        return false
    end

    --检查出的牌是否比上家牌大
    if tbPlayCardInfo["last_cards"] ~= nil then
        local realMaxCardValue = a
        if a < 3 then--把大小王牌值转到最大
            realMaxCardValue = realMaxCardValue + 15
        end        
        
        --相同类型 --先检查类型
        if typeCard == tbPlayCardInfo["card_type"] then
            local lType,max_card,amount  =  CardAnalysis:getType(tbPlayCardInfo["last_cards"])
            --比较最大牌值
            if realMaxCardValue <= max_card then
                if flag then
                    self:showErrorTips("kind_error")
                end

                return false
            end
        else--不同牌型
            if typeCard == 11 then--炸弹
                print("boom")
            else
                print("typeCard",typeCard)
                dump(cards, "checkPlayCard")
                if flag then
                    self:showErrorTips("kind_error")
                end
                return false
            end
        end
    end

    return true
end

--显示托管状态
function PlayCardScene:showAuto(flag)
    local btnAuto = self.layer_top:getChildByName("btn_auto")
    bAuto = flag
    if flag == false then
        if btnAuto then
            btnAuto:setVisible(false)
            btnAuto:setEnabled(false)
        end
    else
        if btnAuto then
            btnAuto:setVisible(true)
            btnAuto:setEnabled(true)
            local function touchButtonEvent(sender, event)
                --缩小ui
                if event == TOUCH_EVENT_BEGAN then
                    require("hall.GameCommon"):playEffectSound("hall/Audio_Button_Click.mp3")
                    btnAuto:setScale(0.6)
                end

                if event == TOUCH_EVENT_ENDED then
                    btnAuto:setScale(1)

                    --取消托管
                    self:showAuto(false)
                    iActionCounts = 1
                    iLastLiftTime = 13
                    require("pdk.pdkServer"):CLI_AUTO(0)
                end

            end
            btnAuto:addTouchEventListener(touchButtonEvent)
        end
    end
end
--显示不出的按钮
function PlayCardScene:showNot2Play()
    self.layout_ui:setTouchEnabled(true)
    self:showErrorTips("no_match")
end

--提示然后把牌弹出
function PlayCardScene:popCard(cards)
    local tmp = {}
    for k,v in pairs(cards) do         
        for key,value in pairs(USER_INFO["cards"]) do 
            if (v[1] == value[1] and v[2] == value[2] ) then
                local tag_tmp              = value[1]+(value[2]+100)*20 
                local card_area            = self.layout_ui:getChildByTag(tag_tmp)
                local x                    = card_area:getPositionX()
                local y                    = card_area:getPositionY()
                if y <= cardY then
                    card_area:setPosition(cc.p(x,y+jumpCardY))
                end

                tmp[key]                  = 1
                USER_INFO.cards[key][5] = 1
            else
                local tag_tmp              = value[1]+(value[2]+100)*20 
                local card_area            = self.layout_ui:getChildByTag(tag_tmp)
				if card_area == nil then
					return
				end
                local x                    = card_area:getPositionX()
                local y                    = card_area:getPositionY()
                if y > cardY and tmp[key] ~= 1 then
                    card_area:setPosition(cc.p(x,y-jumpCardY))
                    USER_INFO.cards[key][5] = 0
                end                    
            end
        end
    end
    require("hall.GameCommon"):playEffectSound("hall/Audio_Button_Click.mp3")
end



--获得需要出的牌
function PlayCardScene:needChuCards()
    local tmp = {}
    for key,value in pairs(USER_INFO["cards"]) do 
        if  USER_INFO.cards[key][5] == 1 then
            table.insert(tmp,{value[1],value[2]})
        end
    end
    return tmp
end



--出牌错误内容
function PlayCardScene:showErrorTips(errCode)

    print("showErrorTips type:",tostring(errCode))
    if require("pdk.pdkSettings"):getLookState() == 2 then
        return
    end
    if self.layout_ui:getChildByName("card_error_msg") then
        self.layout_ui:removeChildByName("card_error_msg")
    end

    display.addSpriteFrames("pdk/common/msg.plist", "pdk/common/msg.png")
    local str = ""
    if errCode == "no_match" then
        str = "#ddz/common/txt_no_match.png"
    elseif errCode == "kind_error" then
        str = "#ddz/common/txt_illegal.png"
    else
        return
    end
    local sp = display.newSprite(str)
    sp:setName("card_error_msg")
    -- sp:addTo(self.layout_ui)
    -- sp:setPosition(cc.p(480,100))

    local fullRect = cc.rect(0,0,sp:getContentSize().width+200,sp:getContentSize().height+30)
    local imageView = ccui.ImageView:create()
    imageView:setScale9Enabled(true)
    imageView:loadTexture("pdk/images/gold_box.png")
    imageView:setContentSize(cc.size(fullRect.width,fullRect.height))
    imageView:setPosition(480,120)
    self.layout_ui:addChild(imageView)
    sp:addTo(imageView)
    sp:setPosition(fullRect.width/2, fullRect.height/2)

    imageView:runAction(cc.Sequence:create(cc.DelayTime:create(2),cc.Hide:create()))
    if errCode == "kind_error" then
        self:cleanCards()
    end
end

--重置所有牌的状态
function  PlayCardScene:cleanCards()
    for key, value in pairs(USER_INFO.cards) do 
        local tag_tmp              = value[1]+(value[2]+100)*20 
        local card_area            = self.layout_ui:getChildByTag(tag_tmp)
        if card_area then
            local px  = card_area:getPositionX()
            USER_INFO.cards[key][5] = 0
            USER_INFO.cards[key][3] = px
            USER_INFO.cards[key][4] = cardY
            card_area:setPosition(cc.p(px,cardY))
            self:toWhite(tag_tmp)
        end
    end
end

--把打牌的四个按钮清掉
function PlayCardScene:cleanupPlayCardBtn() 
    self.layout_ui:getChildByName("buttons"):setVisible(false)
end

--打牌减少牌
function PlayCardScene:reduceCard(cards)

    for i=#USER_INFO.cards,1,-1 do
        local value     = USER_INFO.cards[i]
        local tag_tmp   = value[1]+(value[2]+100)*20
        local flag      = 0
        for k,v in pairs(cards) do
            if v[1] == value[1] and v[2] == value[2] then
                table.remove(USER_INFO.cards,i)
            end
        end

        self.layout_ui:removeChildByTag(tag_tmp)
    end
    self:setCard(1)
end

--把出的牌的出出去
function  PlayCardScene:sendCardToDeskAnimate(cards)
    local count  = #cards
    local start  = 480 - ((count-1)*30+50)/2
    local n      = 0
    local tttmp  = {}
    local cardst =self:showOtherCardRank(cards)

    for i=1,#cardst do
        local v        = cardst[i]
        local tag_tmp  = v[1]+(v[2]+100)*20 
        local card_tmp = self.layout_ui:getChildByTag(tag_tmp)
        card_tmp:setScale(0.3)
        card_tmp:setTouchEnabled(false)
        local tmp = card_tmp:clone()
        
        local x  = card_tmp:getPositionX()
        local y  = card_tmp:getPositionY()

        local nowx = start + n*30
        local nowy = 230
        tmp:setPosition(cc.p(nowx,nowy))
        tmp:addTo(self.layout_ui)

        n   = n +1
    end    
end

--显示别人出的牌排序 
function  PlayCardScene:showOtherCardRank(cards)
    table.sort(cards,function(a,b)
            return a[1]>b[1]
    end)

    local type_t,main_card,len = CardAnalysis:getType(cards)
    print("showOtherCardRank type_t",tostring(type_t),tostring(main_card),tostring(len))
    local tmp    = {}
    if type_t >=7 and type_t <= 12 then

        for k,v in pairs(cards) do
            if not tmp[v[1]] then
                tmp[v[1]] = {}
            end

            table.insert(tmp[v[1]],{v[1],v[2]})
        end

        dump(tmp, "showOtherCardRank tmp")
        local all = {}
        for k,v in pairs(tmp) do
            table.insert(all,v)
        end
        dump(all, "showOtherCardRank")

        table.sort(all,function(a,b)
            if #a == #b then
                return a[1][1] > b[1][1]
            else
                return #a>#b
            end
        end)

        dump(all, "showOtherCardRank sort")

        if type_t == 9 then
            local plane = {}
            local wing = {}
            local plane_count = 0
            for k, v in pairs(all) do
                if v[1][1] + plane_count == main_card then
                    table.insert(plane,v)
                    plane_count = plane_count + 1
                else
                    table.insert(wing,v)
                end
            end
            all = {}
            for k, v in pairs(plane) do
                table.insert(all,v)
            end
            for k, v in pairs(wing) do
                table.insert(all, v)
            end
        end
        local result ={}
        for k,v in pairs(all) do
            for kk,vv in pairs(v) do
                 table.insert(result,{vv[1],vv[2]})
            end

        end

        dump(result, "showOtherCardRank result")
        return result
    end   
    return cards   
end



--显示别的出的牌
function PlayCardScene:showOtherCard(cards,seat,server_seat,offerx)

    dump(cards, "showOtherCard "..tostring(seat).."  "..tostring(server_seat))
    offerx = offerx or 35
    local node = display.newNode()

    -- if seat == 2 then
    --     node:addTo(self.layout_ui,100000)
    -- else
    node:addTo(self.layout_ui)
    -- end
    node:setName("node"..seat)
    local start = 0
    local  yh   = 0
    if seat==0 then
        local count = #cards 
        start       = 480 - ((count-1)*offerx)  /2
        yh          = 270
    elseif seat==1 then        
        local count = #cards 
        start       = 800 - ((count-1)*offerx+50)
        yh          = 390
    elseif seat==2 then
        yh    = 390
        start = 200
    end
    local i = 0

    for k,v in pairs(cards) do
        local img = Card:getOutCard(v[1],v[2],0)
        img:addTo(node)
        img:setPosition(cc.p(start+i*offerx,yh))
        i = i + 1
    end
end

--清楚玩家的桌前的状态内容
function PlayCardScene:clearUserDesk(seat)
    if self.layout_ui:getChildByName("tt"..tostring(seat)) then
        self.layout_ui:removeChildByName("tt"..tostring(seat))
    end
    if self.layout_ui:getChildByName("clock"..tostring(seat)) then
        bUpdateClock = false
        self.layout_ui:removeChildByName("clock"..tostring(seat))
    end
    if self.layout_ui:getChildByName("node"..tostring(seat)) then
        self.layout_ui:removeChildByName("node"..tostring(seat))
    end
end

--清楚所有玩家桌前的状态内容
function PlayCardScene:clearAllUserDesk()
    for i=0,2 do
        if self.layout_ui:getChildByName("tt"..tostring(i)) then
            self.layout_ui:removeChildByName("tt"..tostring(i))
        end
        if self.layout_ui:getChildByName("clock"..tostring(i)) then
            bUpdateClock = false
            self.layout_ui:removeChildByName("clock"..tostring(i))
        end
        if self.layout_ui:getChildByName("node"..tostring(i)) then
            self.layout_ui:removeChildByName("node"..tostring(i))
        end
        if self.layout_ui:getChildByName("rest"..tostring(i)) then
            self.layout_ui:removeChildByName("rest"..tostring(i))
        end
    end    
end

--计算出牌是否点亮
function PlayCardScene:chuIfLight()
    local btouch = true
    if require("pdk.pdkSettings"):getLookState() == 2 then
        btouch = false
    end
    for i=#USER_INFO.cards,1,-1 do
        if USER_INFO.cards[i][5] == 1   then
            self.btn_discard:setTouchEnabled(btouch)
            -- self.btn_discard:setBright(btouch)
            self.btn_discard:loadTextureNormal("hall/Settings/small_green_bt_n.png")
            self.btn_discard:setScale9Enabled(true)
            self.btn_discard:setCapInsets(cc.rect(0,0,self.btn_discard:getContentSize().width,self.btn_discard:getContentSize().height))
            self.btn_discard:setContentSize(cc.size(142,75))
            local spTxt = self.btn_pass:getChildByName("txt_pass")
            if spTxt then
                spTxt:setPosition(71, 42)
            end
            return
        end
    end
    self.btn_discard:setTouchEnabled(false)
    -- self.btn_discard:setBright(false)
    self.btn_discard:loadTextureNormal("hall/common/small_disable_bt_n.png")
    self.btn_discard:setScale9Enabled(true)
    self.btn_discard:setCapInsets(cc.rect(0,0,self.btn_discard:getContentSize().width,self.btn_discard:getContentSize().height))
    self.btn_discard:setContentSize(cc.size(142,75))
    local spTxt = self.btn_pass:getChildByName("txt_pass")
    if spTxt then
        spTxt:setPosition(71, 42)
    end
end

--设置剩余的排数
function PlayCardScene:setRestCardNum(seat,num,flag)
    print("player seat:"..tostring(seat),"card amount:"..tostring(num))
    local is_show = flag or 1
    if seat==1 or seat==2 then
        if is_show == 1 then
            if num<=1 and num>0 then -- 单张才报警
                self.layout_ui:getChildByName("baojing"..tostring(seat)):setVisible(true)
            else
                self.layout_ui:getChildByName("baojing"..tostring(seat)):setVisible(false)
            end

        end

        if num == 1 then
            local sex
            if seat==0 then
                sex = USER_INFO["sex"]
            elseif seat==1 then
                sex = seat1sex+1
            elseif seat==2 then
                sex = seat2sex+1
            end
            if sex == 1 then--男
                require("hall.GameCommon"):playEffectSound("pdk/audio/new/Man_baojing1.mp3")
            else--2是女，0保密
                require("hall.GameCommon"):playEffectSound("pdk/audio/new/Woman_baojing1.mp3")
            end
        end
        local cardNum = self.layout_ui:getChildByName("cardNum"..tostring(seat))
        if cardNum then
            cardNum:setVisible(true)
            cardNum:setString(tostring(num))
            if is_show == 1 then
                cardNum:setVisible(false) -- @add Jhao.
            end
        end
        local cardNumBack = self.layout_ui:getChildByName("cardNumBack"..tostring(seat))
        if cardNumBack then
            cardNumBack:setVisible(true)
            if is_show == 1 then
                cardNumBack:setVisible(false) -- @add Jhao.
            end
        end
    end
    REMAINCARDS[seat] = num
end

--播放出片的声音&效果
function PlayCardScene:playCardsMusic(card_table,type,seat)    
    local file = nil
    local sex
    if seat==0 then
        sex = USER_INFO["sex"]
    elseif seat==1 then
        sex = seat1sex+1
    elseif seat==2 then
        sex = seat2sex+1
    end
    print("playCardsMusic sex",tostring(sex),tostring(USER_INFO["sex"]))
    if type == 1 then--单牌类型
        local main_value = card_table[1][1]
        if sex == 2 then
            --file = "Audio_Card_Single_"..main_value.."_W.mp3"
            file = "Woman_"..main_value..".mp3"
        else
            -- file = "Audio_Card_Single_"..main_value.."_M.mp3"
            file = "Man_"..main_value..".mp3"
        end
    end

    if type == 4 then--单连类型
        if sex == 2 then
            file = "Audio_Card_Straight_W.mp3"
        else
            file = "Audio_Card_Straight_M.mp3"
        end
        require("pdk.Animation"):animShun(self.layout_effect,seat)
    end

    if type == 2 then--对牌类型
        local main_value = CardAnalysis:isDouble(card_table)
        if main_value then
            if sex == 2 then
                -- file = "Audio_Card_Double_"..main_value.."_W.mp3"
                file = "Woman_dui"..main_value..".mp3"
            else
                -- file = "Audio_Card_Double_"..main_value.."_M.mp3"
                file = "Man_dui"..main_value..".mp3"
            end
        end
    end

    if type == 5 then--对连类型
        if sex == 2 then
            file = "Audio_Card_DoubleLine_W.mp3"
        else
            file = "Audio_Card_DoubleLine_M.mp3"
        end
        
        require("pdk.Animation"):animDoubleLine(self.layout_effect)
    end

    if type == 3 then--三条类型
        local main_value = card_table[1][1]
        if sex == 2 then
            -- file = "Audio_Card_Three_W.mp3"
            file = "Woman_tuple"..main_value..".mp3"
        else
            -- file = "Audio_Card_Three_M.mp3"
            file = "Man_tuple"..main_value..".mp3"
        end
    end

    if type == 9 then--三连类型
        if sex == 2 then
            file = "Audio_Card_Plane_W.mp3"
        else
            file = "Audio_Card_Plane_M.mp3"
        end
        
        require("pdk.Animation"):animPlane(self.layout_effect)
    end

    if type == 7  then--三带一单
        if sex == 2 then
            file = "Audio_Card_Three_Take_One_W.mp3"
        else
            file = "Audio_Card_Three_Take_One_M.mp3"
        end
        
    end

    if type == 8  then--三带一对
        if sex == 2 then
            file = "Audio_Card_Three_Take_Double_W.mp3"
        else
            file = "Audio_Card_Three_Take_Double_M.mp3"
        end
        
    end

    --炸弹类型
    if type == 11 then
        if sex == 2 then
            file = "Audio_Card_Bomb_W.mp3"
        else
            file = "Audio_Card_Bomb_M.mp3"
        end
        require("pdk.Animation"):animBoom(self.layout_effect)
        require("hall.GameCommon"):playEffectMusic("pdk/audio/new/Audio_after_bomb.mp3")
        bBombMusic = true
    end
    print("playCardsMusic",tostring(file))

    if file then
        require("hall.GameCommon"):playEffectSound("pdk/audio/new/"..file)
    end

end


--检查是否最后一张牌，是--自动出牌
function PlayCardScene:checkLastCard()
    if #USER_INFO["cards"] > 1 then
        return false
    end

    local card   = CardAnalysis:getLitleCard(self._notice)
    self:popCard(card)

    if self:checkPlayCard(false) == false then
        self:cleanCards()
    else
        local cardAmount = 0
        local cards = {}
        for key,value in pairs(USER_INFO["cards"]) do
            if  USER_INFO.cards[key][5] == 1 then
                local cardvalue = value[1] + value[2]*16
                print("out card:%d   value:%d    type:%x",cardvalue,value[1],value[2]*16)
                cardvalue = Card:Encode(cardvalue)
                local card = {}
                card["card"] = cardvalue
                table.insert(cards,card)
                cardAmount = cardAmount + 1
            end
        end
        print("out cards----------->%s",json.encode(cards))
            --出牌
            require("pdk.pdkServer"):CLI_PLAYER_CARD(cardAmount,cards)
        --消息发送隐藏按钮
        self:cleanupPlayCardBtn()
    end
end

----------------------------------------------------------------
------------------------- 比赛结束页面 -------------------------
----------------------------------------------------------------

--游戏结束
function PlayCardScene:stopRound()
    local mode = require("hall.gameSettings"):getGameMode()
    if mode ~= "match" then
        self:endGame()
        if mode == "free" or mode == "fast" then
            self:loginTableSetReafyPanel()
        end
    end
    require("pdk.pdkSingleSettle"):setShow()
    -- if self.childNewLayer then
    --     self.childNewLayer:setShow()
    -- end
	-- if SCENENOW["name"] == "pdk.pdkSingleSettle" then
	-- 	SCENENOW["scene"]:setShow()
	-- end

end



--重新发牌
function PlayCardScene:endGame()

    self:cleanupPlayCardBtn()
    self:clearAllUserDesk()
    self:resetGame()

    --隐藏邀请好友按钮
    local invite_ly = self._scene:getChildByName("invite_ly")
    invite_ly:setVisible(false)

end



--重置
function PlayCardScene:resetGame()
    local txtWin = self._scene:getChildByName("layer_win")
    if txtWin then
        txtWin:setVisible(false)
    end

    local cardNum = self.layout_ui:getChildByName("cardNum1")
    cardNum:setVisible(false)
    cardNum = self.layout_ui:getChildByName("cardNum2")
    cardNum:setVisible(false)
    local cardNumBack = self.layout_ui:getChildByName("cardNumBack1")
    if cardNumBack then
        -- cardNumBack:setTexture("pdk/Game/cards/lord_card_backface_big.png")
        cardNumBack:setVisible(false)
    end
    cardNumBack = self.layout_ui:getChildByName("cardNumBack2")
    if cardNumBack then
        -- cardNumBack:setTexture("pdk/Game/cards/lord_card_backface_big.png")
        cardNumBack:setVisible(false)
    end

    iGameState = 0
    local sp = self.layout_effect:getChildByName("shunanim")
    if sp then
        sp:stopAllActions()
        self.layout_effect:removeChildByName("shunanim")
    end
    mpcInGameList = {}

    if require("pdk.pdkSettings"):getGroupState() ~= 1 then
		print("resetGame --- stop   AudioEngine.stopAllEffects")
        cc.SimpleAudioEngine:getInstance():stopAllEffects()
        cc.SimpleAudioEngine:getInstance():stopMusic()
        require("hall.GameCommon"):playEffectMusic("pdk/audio/bgm1.mp3",true)
    end
end



--设置底分
function PlayCardScene:setBaseChip(value)

    USER_INFO["base_chip"] = value
    local layout = self._scene:getChildByName("p_base_chip")
    if layout then
        local txt = layout:getChildByName("txt_chip")
        if txt then
            txt:setVisible(true)
            txt:setString(tostring(USER_INFO["base_chip"]))
        end
    end
end
----------------------------------------------------------------
------------------------- 返回网络消息 -------------------------
----------------------------------------------------------------
--游戏开始
function PlayCardScene:onNetGameStart(pack)
    print("PlayCardScene game start")
end


--进入房间
function PlayCardScene:onNetLoginGameSucc(pack)

    --记录房间用户信息
    bm.Room = {}
    bm.Room.UserInfo  = {}

    local mode = require("hall.gameSettings"):getGameMode()
    print("login game success game mode["..mode.."]")
    state_player = 1
    require("pdk.pdkSettings"):setLookState(0)
    --重置记牌器
    -- require("pdk.calcCards"):reset()

    print("onNetLoginGameSucc gold:",pack["Userscore"])

    USER_INFO["gold"] = pack["Userscore"]
    USER_INFO["score"] = pack["Userscore"]
    USER_INFO["seat"] = pack["Seatid"]
    tbSeatCoin[USER_INFO["seat"]] = USER_INFO["gold"]
    USERID2SEAT[tonumber(UID)] = tonumber(pack["Seatid"])
    SEAT2USERID[tonumber(pack["Seatid"])] = tonumber(UID)
    print("player seatid:%d",USERID2SEAT[tonumber(UID)])
    seat0sex = USER_INFO["sex"]-1

    self:displayMyselfInfo()
    --设置底分
    self:setBaseChip(pack["Basechip"])
    for i, v in ipairs(pack["playerlist"]) do
        local uid = tonumber(v["Userid"])
        local table = {}
        table["seat"] = v["Seatid"]
        table["ready"] = v["ReadyStart"]
        table["gold"] = v["Playerscore"]
        table["uid"]  = uid

        tbSeatCoin[table["seat"]] = table["gold"]
        local userinfo = json.decode(v["Userinfo"])
        print_lua_table(userinfo)
        if userinfo then

            table["nick"] = userinfo["nickName"]
            table["sex"]  = userinfo["sex"]
            table["icon"] = userinfo["photoUrl"]
            table["isVip"] = userinfo["isVip"]
        else
            table["nick"] = tostring(uid)
        end
        self:drawOther({table});
        USERID2SEAT[uid] = table["seat"]
        print("other player %d seatid:%d",i,USERID2SEAT[uid])

        bm.Room.UserInfo[uid] = table

    end

    print("onNetLoginGameSucc",mode)
    if mode == "group" then--组局
        self:getChips()
    else
        require("pdk.pdkServer"):CLI_READY_GAME()
        --发送准备消息后，隐藏准备按钮
        self:ready()
    end
    -- 移除netloader
    if self:getChildByName("loading") then
        self:getChildByName("loading"):removeSelf()
    end
end



--进入房间失败
function PlayCardScene:onNetLoginGameFailed(pack)
    print("login game failed,ecode:",pack["nErrno"])
    --返回选分
    -- require("hall.GameTips"):showTips("进入游戏失败","loginGameFailed",2)
    local errcode = "error"
    local showBtn = 2
    if pack["type"] == 9 then
        errcode = "change_money"
        showBtn = 1
    end
    require("hall.GameTips"):showTips(require("pdk.pdkSettings"):getErrorCode(pack["nErrno"]),errcode,showBtn)
end

--有玩家进入房间
function PlayCardScene:onNetPlayerInRoom(pack)
    dump(pack, "onNetPlayerInRoom "..tostring(bGameOver), nesting)
    if bGameOver then
        return
    end

    if pack then
        local table = {}
        table["seat"] = pack["seatid"] 
        table["ready"] = pack["ready"]
        if pack["score"] >= 0 then
            table["gold"] = pack["score"]
        elseif pack["score"] == -1 then
            table["gold"] = pack["chip"]
        end
        table["uid"] = pack["userid"]

        local userinfo = json.decode(pack["userinfo"])
        if userinfo then
            table["nick"] = userinfo["nickName"]
            table["sex"] = userinfo["sex"]
            table["icon"] = userinfo["photoUrl"]
            table["isVip"] = userinfo["isVip"]
        else
            table["nick"] = tostring(pack["userid"])
        end

        tbSeatCoin[table["seat"]] = table["gold"]
        USERID2SEAT[pack["userid"]] = table["seat"]
        dump(USERID2SEAT, "USERID2SEAT onNetPlayerInRoom", nesting)
        if tonumber(pack["userid"]) == tonumber(UID) then
            USER_INFO["gold"] = table["gold"]
            USER_INFO["score"] = pack["gold"]
            USER_INFO["seat"] = pack["seatid"]
            self:displayMyselfInfo()
        else
            self:drawOther({table})
        end

        bm.Room.UserInfo[pack["userid"]] = table

    end
end

--玩家退出房间返回
function PlayCardScene:onNetLogoutRoomOk(pack)
    print("onNetLogoutRoomOk:"..tostring(bLogout))
    print("bPlayerExitGroup:"..tostring(bPlayerExitGroup))
    print("bFakeLogout:"..tostring(bFakeLogout))
    print("state_player:"..tostring(state_player))
    local mode = require("hall.gameSettings"):getGameMode()

    if require("pdk.pdkSettings"):getGroupState() == 1 then
        print("组局结束退出")
        return
    end

    if bm.notCheckReload and bm.notCheckReload == 1 then
        require("hall.GameTips"):enterHall()
    end
end

--广播有玩家退出房间
function PlayCardScene:onNetLogoutRoom(pack)
    if bGameOver then
        return
    end
    if pack then
        print("player [%d] logout room",pack["Uid"])
        local seat = USERID2SEAT[pack["Uid"]]
        if seat then
            self:delUser(seat)
        end

    end
end

--准备返回
function PlayCardScene:onNetReadyGame(pack)
    -- if bGameOver then
    --     return
    -- end

    bGameOver = false
--    print("准备状态 pack:"..pack)
    if pack then
        local readyId = pack["Uid"]
        print("pack id:%d",readyId)
        print("USER_INFO uid:",tostring(UID))

        if tonumber(readyId) ~= tonumber(UID) then
            print("onNetReadyGame")
            print_lua_table(USERID2SEAT)
            self:setOtherReady(USERID2SEAT[readyId])
        else
            --清空之前的牌
            self:clearCards()
            self:ready()
            local mode = require("hall.gameSettings"):getGameMode()
        end
    end
end

--发牌
function PlayCardScene:onNetDeal(pack)
    print("send cards ----- 发牌")
    if state_player < 10 then
        state_player = 3
    end

    if bm.Room == nil then
        bm.Room = {}
    end
    bm.Room.start_group = 1

    self:clearAllUserDesk()
    -- self:endGame()
    self:clearCards()
    USER_INFO["cards"] = nil
    local c  = Card.new()

    require("pdk.pdkSettings"):addGame()

    for i,v in ipairs(pack["Cardbuf"]) do
        local card = Card:Decode(v)
        Card:Encode(card)
        c:init(card)
        local key =  Card:addCard(c)
    end
    Card:sortCard()

    self:start()
    USER_HAND_CARDS_FOR_DEAL = pack["Cardcount"]
	print("@#@#@#@#@ &&&&&&&&&&&&&&&&:pack[Cardcount]:", pack["Cardcount"])
    self:setRestCardNum(0,USER_HAND_CARDS_FOR_DEAL)
    self:setRestCardNum(1,USER_HAND_CARDS_FOR_DEAL)
    self:setRestCardNum(2,USER_HAND_CARDS_FOR_DEAL)    
    iGameState = 1

    --隐藏邀请好友按钮
    local invite_ly = self._scene:getChildByName("invite_ly")
    invite_ly:setVisible(false)

    --显示视频录制按钮
    local btn_record = self.layer_top:getChildByName("btn_live_video")
    btn_record:setVisible(true)

    --添加视频引导
    require("hall.leader.LeaderLayer"):showLeaderLayer(cc.p(335.61, 505.51))

    local uid_arr = {}
    if bm.Room ~= nil then
        if bm.Room.UserInfo ~= nil then
            for k,v in pairs(bm.Room.UserInfo) do
                table.insert(uid_arr, k)
            end
        end
    end

    dump(uid_arr, "-----用户Id-----")
    require("hall.GameSetting"):setPlayerUid(uid_arr)
end

G_PLAYER_CARD_ID = nil

--开始打牌
function PlayCardScene:onNetPlayGame(pack)
    local btn_release_group = self._scene:getChildByName("btn_release_group")
    btn_release_group:setVisible(false)
    btn_release_group:addTouchEventListener(function(sender,event)
        if event == 0 then
            sender:setScale(1.1)
        end

        if event == 2 then
            sender:setScale(1)

            dump("解散房间按钮点击", "-----斗地主-----")
            self:disbandGroup()
        end
    end)

    print("start play cards ------ 开始打牌")
    local c  = Card.new()
    local inset_table = {}
    local table_value = {}
    G_FINISH_FIRST_PLAY = true -- 首次出牌的标记

	G_PLAYER_CARD_ID = pack["nOutCardUserId"]

	--[[ 移动到发牌动画之后
    if USERID2SEAT[G_PLAYER_CARD_ID] == USER_INFO["seat"] then
        self:cardClear()
        self:setCard(1)
        self:showFourButton(0,1,1,0)
        -- iLiftTime = 20
        bPlayCard = 1 --  出牌标记 
    else
        bPlayCard = 0
    end

    self:clearAllUserDesk()
    local tmp2,index = require("pdk.pdkSettings"):getDOS(USERID2SEAT[pack["nOutCardUserId"] ])
    if USERID2SEAT[G_PLAYER_CARD_ID] == USER_INFO["seat"] then
        self:clockAnimation(index,iLiftTime)
    else
        self:clockAnimation(index)
    end
	]]

end

--玩家出牌
function PlayCardScene:SVR_PLAY_CARD( pack )
    -- body
    if bm.Room == nil then
        bm.Room = {}
    end
    if bm.Room.out_card_list == nil then
        bm.Room.out_card_list = {}
    end
    table.insert(bm.Room.out_card_list, pack)
    self:dealOutCard()
end

-- 处理出牌队列
function PlayCardScene:dealOutCard()
    -- body
    if bUpdateSendCard == true then -- 在发牌时，暂停出牌操作
        return
    end
    if bm.Room == nil then
        bm.Room = {}
    end
    if bm.Room.out_card_list == nil then
        bm.Room.out_card_list = {}
    end
    dump(bm.Room.out_card_list, "dealOutCard", nesting)
    if #bm.Room.out_card_list > 0 then
        local data = bm.Room.out_card_list[1]
        table.remove(bm.Room.out_card_list, 1)
        dump(data, "dealOutCard", nesting)
        self:onNetPlayCard(data)
    end
end

function PlayCardScene:onNetPlayCard(pack)
    print("玩家出牌")

    G_FINISH_FIRST_PLAY = false -- 首次出牌的标记
    
    self.layout_ui:setTouchEnabled(false)
    local seat        = USERID2SEAT[pack["nPreOutUserId"]]--当前出牌的座位
    local rest        = 16--当前出牌玩家剩余牌数
    local sex
    if seat==0 then
        sex = seat0sex+1
    elseif seat==1 then
        sex = seat1sex+1
    elseif seat==2 then
        sex = seat2sex+1
    end
    local card_type   = pack["Cardtype"]--出牌类型

    if seat == nil then
        dump(USERID2SEAT, "onNetPlayCard USERID2SEAT", nesting)
    end

    local tmp,index_out_card = require("pdk.pdkSettings"):getDOS(seat)
    dump(REMAINCARDS, "onNetPlayCard REMAINCARDS  "..tostring(index_out_card).."   seat "..tostring(seat))
	user_max_cards = pack["Cardcount"]

    rest = REMAINCARDS[index_out_card] - pack["Cardcount"]

    local c_table = {}
    local c  = Card.new()
    for i,v in ipairs(pack["Cardbuf"])  do
        local card = Card:Decode(v)
        c:init(card)
        table.insert(c_table,{c._value,c._kind})
    end

	print("@@@@@@@@@@@@@@ seatid", USER_INFO["seat"])

    if seat == USER_INFO["seat"] then -- 自己出牌之后的处理
        self.layout_ui:setTouchEnabled(false)
        self:cleanupPlayCardBtn()
        self:clearUserDesk(index_out_card)
        local tm_table = self:showOtherCardRank(c_table)
        self:showOtherCard(tm_table,0,seat)
        self:reduceCard(c_table)
    else
        self:clearUserDesk(index_out_card)
        local tm_table = self:showOtherCardRank(c_table)
        self:showOtherCard(tm_table,index_out_card,seat)
        self:setRestCardNum(index_out_card,rest)
    end
    self:playCardsMusic(c_table,card_type,index_out_card)

    --玩家出完牌
    if pack["nNextOutUserId"] == 0 then
        finishGameUid = pack["nPreOutUserId"]
        print("玩家[%d]出完牌",pack["nPreOutUserId"])
        return
    end

    --给玩家出牌表赋值
    tbPlayCardInfo["last_cards"] = c_table
    tbPlayCardInfo["card_type"]  = card_type
    print("play cards")
    dump(tbPlayCardInfo["last_cards"],"onNetPlayCard")

    local nseat = USERID2SEAT[pack["nNextOutUserId"]]--下家出牌的位置
    if nseat == nil then
        print("@@@@@@@@@@@@@@@ USERID2SEAT ddddddddddddddddddddddddddddddddd")
        print_lua_table(USERID2SEAT)
    end

    local tmp2,index2 = require("pdk.pdkSettings"):getDOS(nseat)
    if nseat == USER_INFO["seat"] then
        if bAuto then
            self:autoAction()
            return
        end

        self:cleanupPlayCardBtn()       
        --到自己出牌时，检查手上是否有牌出
        self._hasselect = {}
        local tt,main_card = CardAnalysis:getSuitCard(tbPlayCardInfo["card_type"],tbPlayCardInfo["last_cards"],self._hasselect)
        self:showFourButton(1,0,1,0)
		print("&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&")
		print("------- tt ------", tt, main_card, tbPlayCardInfo["card_type"])
		print("&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&")
        --有牌出
        if tt then
            self:chuIfLight()
            self:checkLastCard()
            print("onNetPlayCard getSuitCard cards--------------->")
            print_lua_table(tt)
        else
			self:cleanupPlayCardBtn()

            self:showNot2Play()
            print("hand cards--------------->")
            print_lua_table(USER_INFO.cards)

			-- @add Jhao. beg -- 自动pass
    		local spAction = display.newSprite():addTo(self)
    		spAction:runAction(cc.Sequence:create(cc.DelayTime:create(1), 
						cc.CallFunc:create(function() require("pdk.pdkServer"):CLI_PASS() end),
                        cc.CallFunc:create(function() spAction:removeSelf() end)))
			-- @add Jhao. end --
			

        end
        self._hasselect = {}
        self._getSuit = 0
        bPlayCard = 1
    else
        bPlayCard = 0
    end

    self:clearUserDesk(index2)
    self:clockAnimation(index2)

    -- 再检查一下出牌队列，是否还有出牌操作
    self:dealOutCard()
end

--玩家出牌错误
function PlayCardScene:onNetPlayCardError(pack)
    self:showErrorTips("kind_error")
    self:showFourButton(1,0,1,0)
end

--玩家PASS
function PlayCardScene:onNetPass(pack)
    print("玩家PASS")
    print(pack["nIsNewTurn"])
    local seat = USERID2SEAT[pack["nPassUserId"]]
    local nseat = USERID2SEAT[pack["nNextOutUserId"]]
    local a,index = require("pdk.pdkSettings"):getDOS(USERID2SEAT[pack["nPassUserId"]])--应该是seatid吧？
    local b,index2 = require("pdk.pdkSettings"):getDOS(USERID2SEAT[pack["nNextOutUserId"]])--同上

    if pack["nIsNewTurn"] > 0 then
        bFirst = true
    else
        bFirst = false
    end

	print("@@@@@@@@@@@@@@@ onNetPass:", USERID2SEAT[pack["nNextOutUserId"]])

    if USERID2SEAT[pack["nNextOutUserId"]] == USER_INFO["seat"] then
        if bAuto then
            self:autoAction()
        else
            self:cleanupPlayCardBtn()
            self:clearUserDesk(index2)

			print("@@@@@@@@@@@@@@@@ bFirst:", bFirst)

            if bFirst then
                self:showFourButton(0,0,1,0)
                tbPlayCardInfo["last_cards"] = nil
                tbPlayCardInfo["card_type"]  = nil
            else
                --到自己出牌时，检查手上是否有牌出
                self._hasselect = {}
                local tt,main_card = CardAnalysis:getSuitCard(tbPlayCardInfo["card_type"],tbPlayCardInfo["last_cards"],self._hasselect)


				print("@@@@@@@@@@@@@@@ tt:", tt, main_card)

                self:showFourButton(1,0,1,0)
                --有牌出
                if not tt then
					self:cleanupPlayCardBtn()
					print("@@@@@@@@@@@@@@@ tt = nil nil nil nil nil nil nil nil :", tt, main_card)
                    self:showNot2Play()                
					-- @add Jhao. beg -- 自动pass
    				local spAction = display.newSprite():addTo(self)
    				spAction:runAction(cc.Sequence:create(cc.DelayTime:create(1), 
						cc.CallFunc:create(function() require("pdk.pdkServer"):CLI_PASS() end),
                        cc.CallFunc:create(function() spAction:removeSelf() end)))
					-- @add Jhao. end --
                end
            end
            bPlayCard = 1
        end
    else
        bPlayCard = 0
    end

    self:clearUserDesk(index)
    self:clearUserDesk(index2)
    self:clockAnimation(index2)

    if USERID2SEAT[pack["nPassUserId"]] == USER_INFO["seat"] then
        self.layout_ui:setTouchEnabled(false)
        self:cleanupPlayCardBtn()
        self:cleanCards()
    end
    if USERID2SEAT[pack["nNextOutUserId"]] == USER_INFO["seat"] then
        --设置可以选牌
        self:chuIfLight()
        --是否自动出牌
        self:checkLastCard()
    end
end

-- 获取玩家名字
function PlayCardScene:getUserName(uid)
	local loop = 0
	local name = uid
	if tonumber(uid) == tonumber(UID) then
		return USER_INFO["nick"]
	end

	if bm.Room ~= nil then
        if bm.Room.UserInfo ~= nil then
            for k,v in pairs(bm.Room.UserInfo) do
				loop = loop + 1
				if tonumber(uid) == tonumber(k) then
					name = v.nick
				end
			end
		end
	end
	print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! loop:", loop)
	return name
end

--牌局结束
function PlayCardScene:onGameOver(pack)
    print("牌局结束 uid:", tostring(UID))
    print("金币:", USER_INFO["chips"])

	-- @add Jhao. beg
	-- 最后一局判断
	local isLastRound = (G_GAME_GROUP_ITME_TB["round"] + 1 == G_GAME_GROUP_ITME_TB["round_total"])

	-- if not isLastRound then -- 非最后一局
	-------------------------------------
    local newLayer = cc.CSLoader:createNode("pdk/csb/singleSettlement.csb")
    newLayer:setName("singleSettlement")
    SCENENOW["scene"]:addChild(newLayer)
    newLayer:setVisible(false)
    require("pdk.pdkSingleSettle"):initBtnEvent()
    require("pdk.pdkSingleSettle"):setWin(false)
    require("pdk.pdkSingleSettle"):setRoundInfo(tostring(G_GAME_GROUP_ITME_TB["round"]) .. "/" .. tostring(G_GAME_GROUP_ITME_TB["round_total"]))
	-------------------------------------
    -- local layer = require("pdk.pdkSingleSettle")
    -- local newLayer = layer:new()
    -- self._scene:addChild(newLayer)
    -- newLayer:setName("newLayer")
    -- newLayer:setWin(false)

    local function resultReady()
        local mode = require("hall.gameSettings"):getGameMode()
        if mode == "group" then
            if require("pdk.pdkSettings"):getGroupState() == 1 then
                --停止直播
                require("pdk.PlayVideo"):stopVideo()
                print(" PlayCardScene:stopRound()++++++++++++++++++++++++")
				dump(nil, "onGameOver --- stop   AudioEngine.stopAllEffects")
                require("pdk.pdkSettings"):setGroupState(0)
                require("pdk.pdkSettings"):showGroupResult(groupRanking)
                cc.SimpleAudioEngine:getInstance():stopAllEffects()
                cc.SimpleAudioEngine:getInstance():stopMusic()
                audio.stopMusic(false)
            else
                --自动准备
                self:getChips()
                -- pdkServer:LoginGame()
            end
        end
    end

    require("pdk.pdkSingleSettle"):setBtnCallBack(resultReady)
    -- newLayer:setBtnCallBack(resultReady)
    -- self.childNewLayer = newLayer

	-- else	-- 最后一局
	-- 	self.childNewLayer = nil
	-- 	G_NEED_TO_SEND_READY_MSG = true
	-- end

	G_NEED_TO_SEND_READY_MSG = false
	local winerId = tonumber(pack["winerId"])

	print("onGameOver*pack_playerList***", #pack["playerList"])

	for idx, userData in pairs(pack["playerList"]) do
		local uid = tonumber(userData["Uid"]) -- 玩家id
		local overCardNum = userData["Cardcount"] -- 剩余牌的数量
		local boomNum = userData["bomb_times"] -- 炸弹数量
		local moneyValue = userData["Turningscore"] -- 变化的钱

		if winerId == uid then
			overCardNum = 0
		end
        if winerId == tonumber(UID) then
		 	-- SCENENOW["scene"]:setWin(true)
            require("pdk.pdkSingleSettle"):setWin(true)
        end

        print("uid", uid)
        dump(bm.Room.UserInfo[uid], "addRecord(bm.Room.UserInfo uid -----------------------")
        -- print("9999999999999999999999999999999", bm.Room.UserInfo[uid]["icon"])
        if uid == tonumber(UID) then
            require("pdk.pdkSingleSettle"):addRecord(USER_INFO["icon_url"], self:getUserName(uid), overCardNum, boomNum, moneyValue,USER_INFO["uid"],tonumber(USER_INFO["sex"]))
        else
            require("pdk.pdkSingleSettle"):addRecord(bm.Room.UserInfo[uid]["icon"], self:getUserName(uid), overCardNum, boomNum, moneyValue,uid,tonumber(bm.Room.UserInfo[uid]["sex"]))
        end
            
        --显示剩余牌数
        if uid ~= tonumber(UID) then
            local tmp,index = require("pdk.pdkSettings"):getDOS(USERID2SEAT[uid])
            self:setRestCardNum(index,overCardNum,0)
        end

	end
	-- @add Jhao. end --

    self.layout_ui:getChildByName("baojing1"):setVisible(false)
    self.layout_ui:getChildByName("baojing2"):setVisible(false)

    bGameOver = true
    iGameState = 4
    bPlayCard = 0
    local table_r = {}
    table_r["base"] = pack["Basechip"]
    table_r["lord_nick"] = 1

    --结算托管状态
    self:showAuto(false)
    iActionCounts = 0
    --计算台费
    local winCounts = 0
    for i, v in ipairs(pack["playerList"]) do
        local uid = tonumber(v["Uid"])
        if uid == tonumber(UID) then
            tbResult["basechip"] = pack["Basechip"]
            tbResult["win"] = v["Turningscore"] -- 变化的钱
            local mode = require("hall.gameSettings"):getGameMode()
            if mode == "free" or mode == "fast" then
                require("hall.GoldRecord.GoldRecord"):writeData(USER_INFO["gold"]+tbResult["win"], tbResult["win"])
            end
   
            USER_INFO["kick_off"] = v["Kickoff"]
        end
        local dos,index = require("pdk.pdkSettings"):getDOS(USERID2SEAT[uid])
        --显示玩家剩余牌
        if uid ~= finishGameUid and uid ~= tonumber(UID) then
            self:clearUserDesk(index)
            local c_table = {}
            local c  = Card.new()
            for i,k in ipairs(v["Cardbuf"])  do
                local card = Card:Decode(k)
                c:init(card)
                table.insert(c_table,{c._value,c._kind})
            end
            dump(USERID2SEAT, "USERID2SEAT onGameOver")
            self:showOtherCard(c_table,index,USERID2SEAT[uid],15)
        end
    end

    local mode = require("hall.gameSettings"):getGameMode()
    --把台费加回去
    for i, v in ipairs(pack["playerList"]) do
        local uid = tonumber(v["Uid"])
        local dos,index = require("pdk.pdkSettings"):getDOS(USERID2SEAT[uid])
        tbWin[dos] = v["Turningscore"]
        if v["Turningscore"] > 0 then
            tbWin[dos] = v["Turningscore"]

            if uid == tonumber(UID) then
                --先扣台费
                local gold = 0
                if mode == "free" or mode == "fast" then
                    gold = USER_INFO["gold"]
                    USER_INFO["gold"] = gold
                elseif mode == "match" then
                    gold = USER_INFO["match_gold"]
                    USER_INFO["match_gold"] = gold
                elseif mode == "group" then
                    gold = USER_INFO["chips"]
                    USER_INFO["chips"] = gold
                end

                self:displayMine(gold)
            end
        end
    end


    --显示分数变动
    for i=0,2 do
        if self.layout_ui:getChildByName("tt"..tostring(i)) then
            self.layout_ui:removeChildByName("tt"..tostring(i))
        end
        if self.layout_ui:getChildByName("clock"..tostring(i)) then
            bUpdateClock = false
            self.layout_ui:removeChildByName("clock"..tostring(i))
        end
    end

    bFakeLogout = true

    local spAction = display.newSprite():addTo(self)
    spAction:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),
        cc.CallFunc:create(function() self:drawCoin() end),
        cc.CallFunc:create(function() spAction:removeSelf() end)))
    -- self:drawCoin()

    iGameCount = iGameCount + 1
    tbPlayCardInfo["last_cards"] = nil
    tbPlayCardInfo["card_type"]  = nil

end

--玩家托管
function PlayCardScene:onNetAuto(pack)
    if pack == nil then
        return
    end

    if tonumber(pack["Userid"]) == tonumber(UID) then
        --取消托管
        if pack["action"] == 0 then
            self:showAuto(false)
            --显示托管状态
        elseif pack["action"] == 1 then
            self:showAuto(true)
        end
    end
end

--玩家重登，进入游戏
function PlayCardScene:onNetReload(pack)

    self:resetState()
    self:resetGame()
    isReload = true

    local btn_release_group = self._scene:getChildByName("btn_release_group")
    btn_release_group:setVisible(false)

    if require("pdk.pdkSettings"):getLookState() > 0 then
        require("pdk.pdkSettings"):setLookState(2)
        require("hall.GameTips"):showTips("您已进入围观模式")
    end

    print("onNetReload")

    self:setGameMode()

    if bm.Room == nil then
        bm.Room = {}
    end
    bm.Room.start_group = 1

    -- require("pdk.pdkSettings"):addGame()

    USER_INFO["gameLevel"] = pack["Gamelevel"]

    --设置玩家座位
    local my_seat = tonumber(pack["Seated"])
    USER_INFO["seat"] = my_seat
    USERID2SEAT[tonumber(UID)] = my_seat
    SEAT2USERID[my_seat] = tonumber(UID)
    tbSeatCoin[my_seat] = USER_INFO["gold"]
    self:displayMyselfInfo(1)
    print("player seatid:%d",USERID2SEAT[USER_INFO["uid"]])

    --设置玩家状态
    if pack["Readystart"] > 0 then
        self:ready()
    end

    --设置底分
    self:setBaseChip(pack["Basechip"])

    local xFlag = 1

    bm.Room = {}
    bm.Room.UserInfo = {}

    --设置其他玩家状态
    for i, v in ipairs(pack["playerlist"]) do
        local uid = tonumber(v["Uid"])
        local table = {}
        table["uid"] = uid
        table["seat"] = v["Seatid"]
        USERID2SEAT[uid] = v["Seatid"]         
        table["ready"] = v["ReadyStart"]
        local userinfo = json.decode(v["UserInfo"])
        if userinfo then
            dump(userinfo,"reload play"..tostring(uid))
            table["gold"] = userinfo["money"]
            table["nick"] = userinfo["nickName"]
            table["sex"] = userinfo["sex"]
            table["icon"] = userinfo["photoUrl"]
            table["isVip"] = userinfo["isVip"]
        else
            table["gold"] = 0
            table["nick"] = tostring(uid)
        end
        table["gold"] = v["gold"]

        tbSeatCoin[table["seat"]] = table["gold"]
        self:drawOther({table});
        print("other player %d seatid:%d",i,USERID2SEAT[uid])
        local tmp,index = require("pdk.pdkSettings"):getDOS(table["seat"])
        self:setRestCardNum(index,v["HandCardCount"])

        bm.Room.UserInfo[uid] = table
    end

    dump(bm.Room.UserInfo, "-----斗地主房间其他用户-----")
    
    dump(tbSeatCoin, "tbSeatCoin")
    print_lua_table(tbSeatCoin)
    
    REMAINCARDS[0] = pack["Handcardcount"]

    -- 设置出牌的玩家
    local tmp2, index_out = require("pdk.pdkSettings"):getDOS(USERID2SEAT[pack["OutCardUserId"]])
    print("OutCardUserIdOutCardUserId:", tmp2, index_out)

    for i,v in pairs(pack["LastCarddata"]) do
        print("LastCarddata <<:", i)
        if v["CardCount"]~= 0 then
            local c_table = {}
            local c  = Card.new()
            for i,v in ipairs(v["cards"])  do
                local card = Card:Decode(v)
                c:init(card)
                table.insert(c_table,{c._value,c._kind})
                print("---------------:", c._value,c._kind)
            end
            local seat = i - 1
            local dos,index = require("pdk.pdkSettings"):getDOS(seat)
            print("LastCarddata   i", i, "index:", index)

            if index ~= index_out then
                self:clearUserDesk(seat)
                local tm_table = self:showOtherCardRank(c_table)

                local spdelay = display.newSprite():addTo(self)
                print("cc.CallFunc:create", tostring(i))
                spdelay:runAction(cc.Sequence:create(cc.DelayTime:create(0.1*i),
                        cc.CallFunc:create(function()
                                self:showOtherCard(tm_table,index,seat)
                            end),
                        cc.CallFunc:create(function()
                                spdelay:removeSelf()
                            end)))

                -- self:showOtherCard(tm_table, index, seat)

                -- 给玩家出牌表赋值
                if #c_table > 0 then
                    tbPlayCardInfo["last_cards"] = c_table
                    tbPlayCardInfo["card_type"]  = CardAnalysis:getType(c_table)

                    --自己
                    if seat == USER_INFO["seat"] then

                        print("nil seat == USER_INFO[seat]")
                        tbPlayCardInfo["last_cards"] = nil
                        tbPlayCardInfo["card_type"] = nil
                    end
                end
            end

        end
    end

    print("onNetReload clock pos:",tostring(index),"uid:",tostring(pack["OutCardUserId"]),USERID2SEAT[pack["OutCardUserId"]])

    local spdelay = display.newSprite():addTo(self)
    spdelay:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),
                cc.CallFunc:create(function() 
                    self:clockAnimation(index_out,pack["LeftTime"]) 
                    end),
                cc.CallFunc:create(function() 
                    spdelay:removeSelf() 
                    end)))

    local nseat = USERID2SEAT[pack["OutCardUserId"]]--下家出牌的位置
    local tmp2, index2 = require("pdk.pdkSettings"):getDOS(nseat)
    if nseat == USER_INFO["seat"] then
        self:cleanupPlayCardBtn()
        self:clearUserDesk(index2)
        --到自己出牌时，检查手上是否有牌出
        self:showFourButton(1,0,1,0)
        self.layout_ui:setTouchEnabled(false)
        self.layout_effect:setTouchEnabled(false)                  
    end

    --玩家剩余牌数
    self:clearCards()
    USER_INFO["cards"] = nil
    local c  = Card.new()

    -- @ori beg
    for i,v in ipairs(pack["Carddata"])  do
        local card = Card:Decode(v)
        Card:Encode(card)
        c:init(card)
        local key =  Card:addCard(c)
        -- print("point:"..c._value)
        -- print(" kind:"..c._kind)
    end
    -- @ori end

    Card:sortCard()
    self:start()

    if require("hall.gameSettings"):getGameMode() == "group" then
        self:getChips()
    end

    print("user seat:", USER_INFO["seat"])
    print("index_out:", index_out)
    print("pack[OutCardUserId]", pack["OutCardUserId"])
    print("USER_INFO[uid]", tostring(UID))

    local useless, mySeatId = require("pdk.pdkSettings"):getDOS(USER_INFO["seat"])
    local useless, playCardSeatId = require("pdk.pdkSettings"):getDOS(index_out)
    print("mySeatId:", mySeatId)
    print("playCardSeatId :", playCardSeatId )
    if nseat == USER_INFO["seat"] and
        tbPlayCardInfo ~= nil and 
        tonumber(UID) ~= tonumber(pack["OutCardUserId"]) then -- 到自己出牌且桌面有牌,且牌桌上的牌不是自己打出的牌

        self._hasselect = {}
        print("self._hasselect type:", tbPlayCardInfo["card_type"])
        local tt,main_card = CardAnalysis:getSuitCard(tbPlayCardInfo["card_type"],tbPlayCardInfo["last_cards"],self._hasselect)
        self:showFourButton(1,0,1,0)
        --有牌出
        if tt then
            self:chuIfLight()
            self:checkLastCard()
            print("onNetPlayCard getSuitCard cards--------------->")
            print_lua_table(tt)
        else
            self:cleanupPlayCardBtn()

            self:showNot2Play()
            print("hand cards--------------->")
            print_lua_table(USER_INFO.cards)

            -- @add Jhao. beg -- 自动pass
            local spAction = display.newSprite():addTo(self)
            spAction:runAction(cc.Sequence:create(cc.DelayTime:create(1 + 0.5), -- add 0.5s
                        cc.CallFunc:create(function() require("pdk.pdkServer"):CLI_PASS() end),
                        cc.CallFunc:create(function() spAction:removeSelf() end)))
            -- @add Jhao. end --
        end

    end

    --记录房间用户信息
    bm.USERID2SEAT = USERID2SEAT

    --隐藏邀请好友按钮
    local invite_ly = self._scene:getChildByName("invite_ly")
    invite_ly:setVisible(false)

    --显示视频录制按钮
    local btn_record = self.layer_top:getChildByName("btn_live_video")
    btn_record:setVisible(true)

    --添加视频引导
    require("hall.leader.LeaderLayer"):showLeaderLayer(cc.p(335.61, 505.51))

    local uid_arr = {}
    if bm.Room ~= nil then
        if bm.Room.UserInfo ~= nil then
            for k,v in pairs(bm.Room.UserInfo) do
                table.insert(uid_arr, k)
            end
        end
    end

    dump(uid_arr, "-----用户Id-----")
    require("hall.GameSetting"):setPlayerUid(uid_arr)

    -- 移除netloader
    if self:getChildByName("loading") then
        self:getChildByName("loading"):removeSelf()
    end
end

function PlayCardScene:HttpMatchLoadBattles()
    -- body
    require("pdk.MatchSetting"):setRankInfo(require("pdk.pdkSettings"):getMatchLevelRankInfo(USER_INFO["gameLevel"]))
    if isMatchWait == 1 then
        require("pdk.MatchSetting"):showMatchWait(true,"pdk")
    end
end
--获取房间讯息
function PlayCardScene:SVR_ROOM_INFO(pack)
    -- body
    if isMatchWait == 1 then
        USER_INFO["gameLevel"] = pack["level"]
    end
end

--组局结束
function PlayCardScene:onNetBillboard( pack )
    -- body
    local info = pack["playerlist"]

    groupRanking = pack
    -- for i,v in pairs(info) do
    --     groupRanking[v["uid"]] = json.decode(v["user_info"])
    -- end
    -- group_game_amount = pack["game_amount"]

    require("pdk.pdkSettings"):setGroupState(1)
    require("pdk.pdkSingleSettle"):resetButton()
    tbPlayCardInfo["last_cards"] = nil
    tbPlayCardInfo["card_type"]  = nil
    print("state_player---------------------",state_player)
    if bGameOver == false then
        --停止直播
        require("pdk.PlayVideo"):stopVideo()
        print(" PlayCardScene:onNetBillboard()++++++++++++++++++++++++")
		print(" onNetBillboard  --- stop   AudioEngine.stopAllEffects")
        require("pdk.pdkSettings"):setGroupState(0)
        require("pdk.pdkSettings"):showGroupResult(groupRanking)
        cc.SimpleAudioEngine:getInstance():stopAllEffects()
        cc.SimpleAudioEngine:getInstance():stopMusic()
        audio.stopMusic(false)

        -- require("pdk.pdkServer"):CLI_LOGOUT_ROOM()
    end
end


--请求兑换筹码返回
function PlayCardScene:onNetChangeChip(pack)
    local uid = tonumber(pack["uid"])
    if uid == tonumber(UID) then
        USER_INFO["chips"] = pack["chip"]
        USER_INFO["score"] = pack["money"]
        USER_INFO["gold"] = pack["money"]
        self:displayMine()
        --发送准备消息
        require("pdk.pdkServer"):CLI_READY_GAME()
        
        --发送准备消息后，隐藏准备按钮
        self:ready()

    else
        tbSeatCoin[USERID2SEAT[uid]] = pack["chip"]
        self:drawOtherCoin(USERID2SEAT[uid],pack["chip"])
    end
end

--请求筹码
function PlayCardScene:getChips()
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_GET_CHIP)
    :setParameter("uid", tonumber(UID))
    :build()
    bm.server:send(pack)
end

--获取筹码
function PlayCardScene:onNetGetChip(pack)
    USER_INFO["chips"] = pack["chip"]
    self:displayMine()
    if state_player < 2 then

    	require("pdk.pdkServer"):CLI_READY_GAME()
    	--发送准备消息后，隐藏准备按钮
    	self:ready()
        

    end
end


--获取历史记录
function PlayCardScene:onNetHistory(pack)
    -- body
    -- local info = json.decode(pack["playerlist"])
    local playerlist = {}
    for i, v in ipairs(pack["playerlist"]) do
        playerlist[v["uid"]] = json.decode(v["user_info"])
    end
    print_lua_table(playerlist)
    local his = json.decode(pack["history"])
    if his ~= null then
        for i,v in ipairs(his) do
            local tbPlayers = {}
            print_lua_table(v)
            for j, k in ipairs(v) do
                local uid = k["user_id"]
                table.insert(tbPlayers,{uid,playerlist[uid]["nick_name"],k["user_chip_variation"],playerlist[uid]["photo_url"],playerlist[uid]["sex"]})
            end
            require("hall.GameCommon"):addHistoryItem(i,tbPlayers)
        end
    end
    require("hall.GameCommon"):showHistory(true)
end

--组局时长
G_GAME_GROUP_ITME_TB = {}
function PlayCardScene:onNetGroupTime(pack)
    -- body
    local time = pack["time"]
    USER_INFO["group_lift_time"] = time
    -- bShowGroupTime = true
    USER_INFO["start_time"] = os.time()

	G_GAME_GROUP_ITME_TB["round"] = pack["round"] -- 当前已进行多少局
	G_GAME_GROUP_ITME_TB["round_total"] = pack["round_total"] -- 当前组局总局数

    require("pdk.pdkSettings"):setGameCount(pack["round"])

    local layer_group_time = self._scene:getChildByName("layer_group_time")
    if layer_group_time then
        local txtTime = layer_group_time:getChildByName("txt_time")
        if txtTime then
            txtTime:setString(tostring(string.format("%02d",pack["round"]+1).."/"..tostring(string.format("%02d",pack["round_total"]))))
        end
    end

    local txt_game_no = self._scene:getChildByName("p_game_no"):getChildByName("txt_game_no")
    if txt_game_no then
        
        txt_game_no:setString(tostring(pack["round"]+1).."/"..tostring(pack["round_total"]))
        txt_game_no:setVisible(true)
        --调整局数字
        local game_text = self._scene:getChildByName("p_game_no"):getChildByName("game_text_zuju_3")
        if game_text then
            game_text:setPositionX(txt_game_no:getPositionX()-game_text:getContentSize().width/2-txt_game_no:getContentSize().width-5)
        end
    end
end

--乱闯私人房
function PlayCardScene:SVR_ENTER_PRIVATE_ROOM(pack)
    -- body
    if require("hall.gameSettings"):getGameMode() == "group" then
        self:resetState()
        require("hall.GameCommon"):gExitGroupGame(1)
    else
        self:resetState()
        display_scene("pdk.SelectChip",1)
        bLogout = false
    end
end

--历史出牌
function PlayCardScene:SVR_CALC_HISTORY(pack)
    if pack then
        -- require("pdk.calcCards"):init()
        -- for i,v in ipairs(pack["cardList"]) do
        --     require("pdk.calcCards"):setHistory(v["cards"])
        -- end
        -- require("pdk.calcCards"):setGameState(1)
        -- require("pdk.calcCards"):updateCards(true)
    end
end


function PlayCardScene:getUSERID2SEAT()
    return USERID2SEAT;
end


--弹充值框返回
function PlayCardScene:callBackTips(msg,flag)
    if msg == "change_money2chips" then
        if flag == 0 then--取消
            state_player = 100
        else
            USER_INFO["auto_recharge"] = 1
            state_player = 100
            pdkServer:CLI_LOGOUT_ROOM()
        end
    end
end

--聊天
function PlayCardScene:SVR_MSG_FACE(pack)
    local faceUI = self:getChildByName("faceUI")
    if faceUI == nil then
        print("scene:"..SCENENOW["name"],"not match faceUI")
        return
    end

    local sex = -1
    local uid = tonumber(pack["uid"])
    local dos,seat = require("pdk.pdkSettings"):getDOS(USERID2SEAT[uid])
    if uid == tonumber(UID) then
        sex = USER_INFO["sex"]
        if tonumber(sex) == 0 then--保密
            sex = 0
        end
    else

        if tonumber(seat)==1 then
            sex = seat1sex + 1
        elseif tonumber(seat)==2 then
            sex = seat2sex + 1
        end
    end
    

    --去掉提示弹框
    local layer_tips = SCENENOW["scene"]:getChildByName("layer_tips")
    if layer_tips then
        layer_tips:removeSelf()
    end

    local isLeft = false
    local node_head = self._scene:getChildByName(dos):getChildByName("head")

    if tonumber(seat) == 1 then
       isLeft = true
    end

    dump(node_head, "-----node_head-----")
    dump(sex, "-----sex-----")
    dump(seat, "-----seat-----")

    if faceUI ~= nil and node_head ~= nil then
        faceUI:showGetFace(pack.uid, pack.type, tonumber(sex), node_head, isLeft)
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



--[[*****************************************
-- *************** 跑得快逻辑 ***************
   ****************************************** ]]

-- @brief:获取牌桌上的牌及牌型
-- @date:2016-11-7
-- @authon:Jhao.
-- 		@return:cards, type
function PlayCardScene:getTableCardsNType()
	return tbPlayCardInfo["last_cards"], tbPlayCardInfo["card_type"]
end



-- @brief:获取玩家自己手上的所有牌
-- @date:2016-11-7
-- @authon:Jhao.
-- 		@return:cards
function PlayCardScene:getOwnCards()
	return USER_INFO["cards"]
end



-- @brief:"不要"按钮逻辑。(要的起的情况下，必须要出牌)
-- @date:2016-11-7
-- @authon:Jhao.
function PlayCardScene:eventPassBtn()

	if tbPlayCardInfo["last_cards"] == nil then
		return false
	end
    self._hasselect = {}
	return not CardAnalysis:getSuitCard(tbPlayCardInfo["card_type"],
				tbPlayCardInfo["last_cards"], self._hasselect)
end



-- @brief:"出牌"按钮逻辑。
-- @date:2016-11-7
-- @authon:Jhao.
function PlayCardScene:eventDiscardBtn()
end



-- @brief:"提示"按钮逻辑。
-- @date:2016-11-7
-- @authon:Jhao.
function PlayCardScene:eventTipsBtn()
end


--获取视频录音播放位置
function PlayCardScene:getPosforSeat(uid)
    local seat=USERID2SEAT[uid]
    local name,index=require("pdk.pdkSettings"):getDOS(seat)

    local node_head=SCENENOW["scene"]._scene:getChildByName(name)
    local pos=node_head:getPosition()
    if index == 1 then
        pos.x=pos.x-30
    else
        pos.x=pos.x+30
    end
    pos.y=pos.y-30
    return pos
end


function PlayCardScene:get_player_ip( uid )
    -- body
    local ip_ = require("pdk.pdkSettings"):getUserIP(uid)
    print("get_player_ip",tostring(uid),tostring(ip_))
    if ip_ == nil then
        return ""
    end
    return ip_
end


function PlayCardScene:BROADCAST_USER_IP(pack)
    if pack == nil then
        return
    end

    print("BROADCAST_USER_IP", tostring(require("pdk.pdkSettings"):getGameCount()))
    if require("pdk.pdkSettings"):getGameCount() > 0 then
        return
    end

    local ip_list = {}
    for k, v in pairs(pack["playeripdata"]) do
        local uid = tonumber(v["uid"])
        require("pdk.pdkSettings"):setUserIP(uid, v["ip"])
        if uid ~= tonumber(UID) and uid ~= 0 then
            if ip_list[v["ip"]] == nil then
                ip_list[v["ip"]] = 1
            else
                ip_list[v["ip"]] = ip_list[v["ip"]] + 1
            end
        end
    end

    dump(ip_list, "BROADCAST_USER_IP ip_list")

    local same_ip = {}
    for k, v in pairs(ip_list) do
        print("ip_list ",tostring(k), tostring(v))
        if v > 1 then
            same_ip[k] = 1
        end
    end

    dump(same_ip, "BROADCAST_USER_IP same_ip 1")

    local msg = "玩家："
    local show_alert = 0
    if bm.Room ~= nil then
        for k, v in pairs(pack["playeripdata"]) do
            if same_ip[v["ip"]] ~= nil then
                local uid = tonumber(v["uid"])
                if bm.Room.UserInfo[uid] then
                    msg = msg .. "  "..bm.Room.UserInfo[uid]["nick"]
                    show_alert = 1
                end
            end
        end
    end

    dump(same_ip, "BROADCAST_USER_IP same_ip 2")

    if show_alert == 1 then
        require("hall.GameCommon"):showAlert(false)
        require("hall.GameCommon"):showAlert(true, "提示：" .. msg .. "  ip地址相同，谨防作弊", 300)
    end
end


return PlayCardScene
