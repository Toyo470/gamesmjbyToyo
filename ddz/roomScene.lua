local Card          = require("ddz.Card")
local scheduler     = require(cc.PACKAGE_NAME .. ".scheduler")
local CardAnalysis  = require("ddz.CardAnalysis")

local PROTOCOL = require("ddz.ddz_PROTOCOL")

local ddzServer = import("ddz.ddzServer")
local ddzHandle  = require("ddz.ddzHandle")

local ddz_face = require("hall.FaceUI.faceUI")

local PlayCardScene = class("PlayCardScene", function()
    return display.newScene("PlayCardScene")
end)


local USERID2SEAT = {}
local SEAT2USERID = {}
local REMAINCARDS = {}
local bFirst = true
local loadSeat = 1
local bMacthWait = false
--local bUnmatchCard = false
local bFakeLogout = false
local tbTipsCards = {}
local dtUpdate = 0
local tbWin = {}
local bGameOver = false
local iTotalTimes = 0
local iLiftTime = 20
local iLastLiftTime = 18
local iActionCounts = 0
local bPlayCard = 0
local tbSeatCoin = {}
local rtSelectCard
local bOnDeal = false
local isDealAllCards = false
local isReload = false
local bShowMenu = true
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
--比赛等待
local bShowMatchWait = false
local fTimeMatchWait = 0
local idxRound = 1
local fRoundFrame = 0.3
local bMatchStatus = 0   --0:等待，1：start，2：match over,3晋级
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

local tbPlayCardInfo = {}

--是否叫地主
local call_bet_first = 0
--发牌时间间隔
local dt_send_card = 0.1
local temp_cards = {}
local is_debug = true


tbResult = {}

--记录房间用户信息
bm.Room = {}
bm.Room.UserInfo  = {}

function PlayCardScene:resetState()
    -- body
    if device.platform=="android"  then
        if _G.notifiLayer.rootNode then
            _G.notifiLayer.rootNode:setPositionY(_G.notifiLayer.rootNode:getPositionY() - 20)  --电量显示
        end
    end
    state_player = 0
    reLoadMatchLevel = 0
    isMatchWait = 0
    finishGameUid = 0
    bLogout = false
    groupRanking = {}
    group_game_amount = 0

    require("ddz.ddzSettings"):setGroupState(0)
    tbResult = {}
    bPlayerExitGroup = false
    bShowGroupTime = false
    seat1sex = 1
    seat2sex = 1

    USERID2SEAT = {}
    SEAT2USERID = {}
    REMAINCARDS = {}
    bFirst = true
    loadSeat = 1
    bMacthWait = false
--local bUnmatchCard = false
    bFakeLogout = false
    tbTipsCards = {}
    dtUpdate = 0
    tbWin = {}
    bGameOver = false
    iTotalTimes = 0
    iLiftTime = 20
    iLastLiftTime = 18
    iActionCounts = 0
    bPlayCard = 0
    tbSeatCoin = {}
    bOnDeal = false
    isDealAllCards = false
    isReload = false
    bShowMenu = true
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
--比赛等待
    bShowMatchWait = false
    fTimeMatchWait = 0
    idxRound = 1
    fRoundFrame = 0.3
    bMatchStatus = 0   --0:等待，1：start，2：match over
--过金币
    bShowAddCoin = false
    fTimeDrawCoins = 0
--特效音效
    bBombMusic = false
    call_bet_first = 0
end

function PlayCardScene:ctor()

    dump("初始化", "-----斗地主-----")

    bm.server:setProtocol(PROTOCOL)
    bm.server:setHandle(ddzHandle.new())

    local ddz_face_node=ddz_face.new()
    ddz_face_node:setHandle(bm.server:getHandle())
    self:addChild(ddz_face_node, 9999)
    ddz_face_node:setName("faceUI")

    display.addSpriteFrames("ddz/Game/cards/cards.plist", "ddz/Game/cards/cards.png")

    print("kkkkkkkkkkkkkkkkkkkkkkkkkkkkkk enter_mode",USER_INFO["enter_mode"])
    audio.preloadMusic("ddz/audio/Audio_Game_Back.mp3")
    bGameOver = false
    
    local cardScene
    if device.platform == "ios" then
        if isiOSVerify then
            cardScene = cc.CSLoader:createNode("ddz/csb/playcard.csb"):addTo(self)
        else
            cardScene = cc.CSLoader:createNode(cc.FileUtils:getInstance():getWritablePath() .. "ddz/csb/playcard.csb"):addTo(self)
        end
    else
        cardScene = cc.CSLoader:createNode("ddz/csb/playcard.csb"):addTo(self)
    end

    self._scene = cardScene

    self.layer_bottom = self._scene:getChildByName("layer_bottom")

    local head = self._scene:getChildByName("touxiangbufen_0"):getChildByName("head")
    if head then
        local head_info = {}
        head_info["icon_url"] = USER_INFO["icon_url"]
        head_info["uid"] = tonumber(UID)
        head_info["sex"] = USER_INFO["sex"]
        head_info["sp"] = head
        head_info["size"] = headSize
        head_info["touchable"] = 0
        head_info["use_sharp"] = 1
        head_info["vip"] = USER_INFO["isVip"]
        require("hall.GameCommon"):setPlayerHead(head_info,head,headSize)
    end
    local txt_gold = self.layer_bottom:getChildByName("gold_mine")
    if txt_gold then
        local lable = ccui.TextBMFont:create("", "hall/proxy/image/num.fnt")
        lable:setName("gold_mine")
        lable:addTo(txt_gold:getParent())
        lable:setPosition(txt_gold:getPosition())
        txt_gold:removeSelf()
    end
    -- local sex = self._scene:getChildByName("touxiangbufen_0"):getChildByName("sex")
    -- sex:setTexture("ddz/Game/tihuan/sex_"..tostring(seat0sex)..".png")
    --重置空头像
    head = self._scene:getChildByName("touxiangbufen_1"):getChildByName("head")
    if head then
        local head_info = {}
        head_info["url"] = "ddz/Game/hall_ui/room_default_none.png"
        head_info["sp"] = head
        head_info["size"] = headSize
        head_info["touchable"] = 0
        head_info["use_sharp"] = 1
        require("hall.GameCommon"):setUserHead(head_info)
        -- require("hall.GameCommon"):setPlayerHead(head_info,head,headSize)
    end
    txt_gold = self._scene:getChildByName("touxiangbufen_1"):getChildByName("gold_mine")
    if txt_gold then
        local lable = ccui.TextBMFont:create("", "hall/proxy/image/num.fnt")
        lable:setName("gold_mine")
        lable:setAnchorPoint(cc.p(0,0.5))
        lable:setScale(0.5)
        lable:addTo(txt_gold:getParent())
        lable:setPosition(txt_gold:getPosition())
        txt_gold:removeSelf()
    end
    head = self._scene:getChildByName("touxiangbufen_2"):getChildByName("head")
    if head then
        local head_info = {}
        head_info["url"] = "ddz/Game/hall_ui/room_default_none.png"
        head_info["sp"] = head
        head_info["size"] = headSize
        head_info["touchable"] = 0
        head_info["use_sharp"] = 1
        require("hall.GameCommon"):setUserHead(head_info)
        -- require("hall.GameCommon"):setPlayerHead(head_info,head,headSize)
    end
    txt_gold = self._scene:getChildByName("touxiangbufen_2"):getChildByName("gold_mine")
    if txt_gold then
        local lable = ccui.TextBMFont:create("", "hall/proxy/image/num.fnt")
        lable:setName("gold_mine")
        lable:setAnchorPoint(cc.p(0,0.5))
        lable:setScale(0.5)
        lable:addTo(txt_gold:getParent())
        lable:setPosition(txt_gold:getPosition())
        txt_gold:removeSelf()
    end


    self.layout_ui = cardScene:getChildByName("layout_ui")
    local laytop = self._scene:getChildByName("play_top")
    self.layout_basecard = laytop:getChildByName("layout_basecard")
    self.layout_ui:addTouchEventListener(function(sender,event)
        if event==2 then
            sender:setTouchEnabled(false)
            require("ddz.ddzServer"):CLI_PASS()
        end
    end)    

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

            --PASS
            require("ddz.ddzServer"):CLI_PASS()
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
            require("hall.GameCommon"):playEffectSound("ddz/audio/Audio_Button_Click.mp3")

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
                    require("ddz.ddzServer"):CLI_PASS()
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

            require("hall.GameCommon"):playEffectSound("ddz/audio/Audio_Button_Click.mp3")
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
            require("ddz.ddzServer"):CLI_PLAYER_CARD(cardAmount,cards)
            -- iActionCounts = 0
            --消息发送隐藏按钮
            self:cleanupPlayCardBtn()
        end
    end)

    self.buttons_jiaofen = self.layout_ui:getChildByName("buttons_jiaofen")
    self.buttons_jiaofen:setVisible(false)
    self.btn_buqiang = self.buttons_jiaofen:getChildByName("btn_buqiang")
    self.btn_jiao = self.buttons_jiaofen:getChildByName("btn_jiao")
    self.btn_qiang = self.buttons_jiaofen:getChildByName("btn_qiang")
    self.btn_bujiao = self.buttons_jiaofen:getChildByName("btn_bujiao")

    local base_score = self._scene:getChildByName("base_score")
    if base_score then
        base_score:setVisible(false)
    end
    --不抢
    local bu_func = function(sender,event)
        if event == 0 then
            sender:setScale(1.1)
        end      

        if event == 2 then
            sender:setScale(1)

            require("hall.GameCommon"):playEffectSound("ddz/audio/Audio_Button_Click.mp3")
            --不叫地主
            local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_SET_BET)
            :setParameter("Score", 0)
            :build()
            bm.server:send(pack)
            print("---CLI_SET_BET-----------------sending-----------------------------",0)
        end
    end
    self.btn_buqiang:addTouchEventListener(bu_func)
    self.btn_bujiao:addTouchEventListener(bu_func)

    local func = function(sender,event)
        if event == 0 then
            sender:setScale(1.1)
        end      

        if event == 2 then
            sender:setScale(1)

            require("hall.GameCommon"):playEffectSound("ddz/audio/Audio_Button_Click.mp3")
            local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_SET_BET)
            :setParameter("Score", 1)
            :build()
            bm.server:send(pack)

            print("---CLI_SET_BET-----------------sending-----------------------------",1)
        end
    end

    self.btn_jiao:addTouchEventListener(func)
    self.btn_qiang:addTouchEventListener(func)

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

    local match_info = self.layer_bottom:getChildByName("Panel_match")
    if require("hall.gameSettings"):getGameMode() ~= "match" then
        match_info:setEnabled(false)
    end

    local function touchButtonEvent(sender, event)
        --缩小ui
        if event == TOUCH_EVENT_BEGAN then
            require("hall.GameCommon"):playEffectSound("ddz/audio/Audio_Button_Click.mp3")
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
                                dump(bm.Room, "exit", nesting)
                                if bm.Room and bm.Room.start_group == 1 then
                                    require("hall.GameTips"):showTips("提示", "", 2, "游戏已经开始，不能返回大厅")
                                else
                                    local function okCallback()
                                        if bm.notCheckReload and bm.notCheckReload ~= 1 then
                                            bm.notCheckReload = 1
                                            ddzServer:CLI_LOGOUT_ROOM()
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
    local btn_release_group = self._scene:getChildByName("btn_release_group")
    if btn_release_group then
        btn_release_group:setPositionY(btn_release_group:getPositionY() - 100)
        btn_release_group:setVisible(false)
    end

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

        --解散房间按钮
        local function release_group_callbaack(event)
            -- body
            if event.name == "ended" then
                -- require("ddz.ddzServer"):C2S_DISSOLVE_ROOM()

                dump("解散房间按钮点击", "-----斗地主-----")
                self:disbandGroup()


            end
        end
        if tonumber(USER_INFO["group_owner"]) == UID then
            btn_release_group:setVisible(true)
            btn_release_group:onTouch(release_group_callbaack)
        end
        btn_release_group:setVisible(true)
        btn_release_group:onTouch(release_group_callbaack)
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

        local alarm = require("ddz.Animation"):Alarm()
        if alarm then
            local s = 0.3
            self.layout_ui:addChild(alarm)
            alarm:setVisible(false)
            alarm:setName("baojing"..tostring(i))
            alarm:setScale(s)
            alarm:setPosition(cc.p(player:getPositionX(),player:getPositionY()+alarm:getContentSize().height/4*s-20))
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
        local pos=sender:getPosition()
        if sender.id ==1 then
            ddz_face_node:showFacePanle(pos)
        else
            ddz_face_node:showTxtPanle(cc.p(self.btnFaceui_txt:getPositionX() - 400, self.btnFaceui_txt:getPositionY() + self.btnFaceui_txt:getContentSize().height/2))
        end

        print("click faceui")
        
    end
    self.btnFaceui_txt:onClick(onface_click)
    self.btnFaceui_faceui:onClick(onface_click)

    -- cct.showradioMessage(self,false);
    ---------------------------------------------------------------------

    --视频录制
    local btn_record = self._scene:getChildByName("btn_record")
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
                
                require("hall.common.ShareLayer"):showShareLayer("斗地主，房号：" .. USER_INFO["invote_code"], "https://a.mlinks.cc/AK3b", "url", share_content)
            
            end
        end
    )
    
    self:onEnters()

end

--解散房间
function PlayCardScene:disbandGroup()

    --查询用户当前的游戏状态来判断当前通过怎样的方式来解散组局
    require("hall.gameSettings"):disbandGroup("ddz")

end

--设置组局按钮状态
--flag 1为围观状态
function PlayCardScene:setLookMenuBtn(flag)

    flag = flag or 1

    local spSee = self._scene:getChildByName("layout_group"):getChildByName("btn_sideSee"):getChildByName("btn_see_1")
    if spSee then
        local strPic = 1
        if flag == 1 then
            strPic = "ddz/group/btn_see.png"
        else
            strPic = "ddz/group/btn_play.png"
        end
        spSee:setTexture(strPic)
    end
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
            head_info["url"] = "ddz/Game/hall_ui/room_default_none.png"
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
        str = "ddz/Game/tihuan/sex_"..tostring(seat0sex+1)..".png"
    else
        str = "ddz/Game/tihuan/sex_1.png"
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
--切换顶部按钮
function PlayCardScene:showMenu(flag)
    if bShowMenu == flag then
        return
    end

    bShowMenu = flag
    local layoutMenu = self._scene:getChildByName("lay_buttons")
    local laytop = self._scene:getChildByName("play_top")
    local btnEixt   = layoutMenu:getChildByName("back")
    local btnSetting   = layoutMenu:getChildByName("btn_setting")
    local btnRobbot   = layoutMenu:getChildByName("btn_robbot")
    --切换到按钮
    local time = 0.1
    if flag then
        --已在屏幕内
        if layoutMenu:getPositionY() > 540 then
            return
        end

        local function showFreeEnd()
            local mt = cc.MoveTo:create(time, cc.p(layoutMenu:getPositionX(), layoutMenu:getPositionY()-layoutMenu:getContentSize().height))
            layoutMenu:runAction(mt)
        end
        local mt = cc.MoveTo:create(time, cc.p(laytop:getPositionX(), laytop:getPositionY()+laytop:getContentSize().height))
        local seq = nil
        seq = cc.Sequence:create(mt,cc.CallFunc:create(showFreeEnd))
        laytop:runAction(seq)
    else
        --已在屏幕外
        if laytop:getPositionY() < 540 then
            return
        end
        local function showFreeEnd()
            local mt = cc.MoveTo:create(time, cc.p(laytop:getPositionX(), laytop:getPositionY()-laytop:getContentSize().height))
            laytop:runAction(mt)
        end
        local mt = cc.MoveTo:create(time, cc.p(layoutMenu:getPositionX(), layoutMenu:getPositionY()+layoutMenu:getContentSize().height))
        local seq = nil
        seq = cc.Sequence:create(mt,cc.CallFunc:create(showFreeEnd))

        layoutMenu:runAction(seq)
    end
end

--发牌动画
local dtUpdateSendCard = 0
local bUpdateSendCard = false
local indexSendCard = 1
function PlayCardScene:sendCardAnimate()
    require("hall.GameCommon"):playEffectSound("ddz/audio/Audio_Deal_Card.mp3")   
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

    local dis = 44
 
    local startx = 30
    local xCenter = (960-startx*2)/2

    dtUpdateSendCard = dtUpdateSendCard + dt
    if dtUpdateSendCard >= dt_send_card then
        dtUpdateSendCard = dtUpdateSendCard - dt_send_card
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
        if indexSendCard > #USER_INFO.cards then
            bUpdateSendCard = false
            bOnDeal = false
            isDealAllCards = true
            --发完牌，显示叫地主
            if iGameState == 21 then
                self:clockAnimation(0)
                self:setJiaoPanel()
            end
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

    --cc.SpriteFrameCache:getInstance():addSpriteFrames("ddz/Plist.plist","ddz/Plist.png")
    local node = display.newNode()
    local a    =  display.newSprite("ddz/images/naozhong_03.png")
    local num  =  self._scene:getChildByName("clock_num") --Tag(70)
    local numt = num:clone()
    numt:setName("txtClockNum")

    local xp   = posClock[iClockSeat+1][1]
    local yp   = posClock[iClockSeat+1][2]
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
--                print("clock strNow:"..strnow)
                txtTime:setString(strnow)
            end

            if(cut >= iLiftTime) then
                print("unaction times:"..iActionCounts)
                if state_player == 1 then--没准备,准备倒计时
                    bLogout = true
                    require("ddz.ddzSettings"):requestExit()
                    self:stopClockAnimation()
                end
                -- if bPlayCard == 1 then
                --     iActionCounts = iActionCounts + 1
                --     print("bPlayCard unaction times:"..iActionCounts)

                --     -- self:autoAction()
                --     -- if iActionCounts >= 2 then
                --     --     self:showAuto(true)
                --     --     require("ddz.ddzServer"):CLI_AUTO(1)
                --     --     --选的牌收回
                --     --     self:cleanCards()
                --     --     --消息发送隐藏按钮
                --     --     self:cleanupPlayCardBtn()
                --     -- end
                -- end
                -- self.layout_ui:removeChild(spClock)
                -- self.clocktt = 0
                bUpdateClock = false
            end
        end
    end
end
--自动出牌或PASS
function PlayCardScene:autoAction()
    if tbPlayCardInfo["last_cards"] ~= nil then
        --PASS
        require("ddz.ddzServer"):CLI_PASS()
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
        require("ddz.ddzServer"):CLI_PLAYER_CARD(cardAmount,cards)
        --消息发送隐藏按钮
        self:cleanupPlayCardBtn()
    end
end
--停止闹钟动画
function PlayCardScene:stopClockAnimation()
    print("stop clock")
    for i = 0,2 do
        if self.layout_ui:getChildByName("clock"..i) then
            self.layout_ui:removeChildByName("clock"..i)
        end
    end

end

-- 清空手上的牌
function PlayCardScene:clearCards()
    if USER_INFO.cards == nil then--牌容器空
        return
    end

    for key, value in pairs(USER_INFO.cards) do
        local tag_tmp   = value[1]+(value[2]+100)*20
        local card_area = self.layout_ui:getChildByTag(tag_tmp)
        if card_area then
            self.layout_ui:removeChild(card_area)
        end
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
    for key, value in pairs(USER_INFO.cards) do
        if num == #USER_INFO.cards and tbResult["type"] == 1 then
            show_logo = 1
        end
        local card_area,x,y =  self:addCard(value[1],value[2],startx,flag,num,dis,show_logo)
        if card_area == nil then
            self:clearCards()
            self:setCard()
            return
        end
        USER_INFO.cards[key][3] = x
        USER_INFO.cards[key][4] = y
        USER_INFO.cards[key][5] = 0
        num = num + 1
    end 
end

-- 地主的3张牌插入动画
function PlayCardScene:lordInsetBaseCard(table_info)
    self:setCardTouched(false)
    for key,value in pairs(table_info) do
        print("key,value",key,value)
        local now = self.layout_ui:getChildByTag(value)
        local x   = now:getPositionX()
        local y   = now:getPositionY()
        now:setPosition(cc.p(x, y+30))
        local move = cc.MoveTo:create(1,cc.p(x, y))
        local delay= cc.DelayTime:create(0.5)
        local se   
        if key == 3 then
            se = cc.Sequence:create(delay,move,cc.CallFunc:create(function() self:setCardTouched(true)  self:showFourButton(0,0,1,0) end))
        else
            se = cc.Sequence:create(delay,move)
        end
        now:runAction(se)
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
        local tag = value+(kind+100)*20
        local img = Card:getCard(value,kind,isLandlord)
        if img == nil then
            print("addCard img nil")
            return nil, nil, nil
        end
        color = img:getColor() --全局牌的白色的颜色
        self.layout_ui:addChild(img)
        img:setTag(tag)
        img:setTouchEnabled(true)
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
                        require("hall.GameCommon"):playEffectSound("ddz/audio/Audio_Button_Click.mp3")
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
                            -- print("tbCards"..json.encode(tbCards))


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
                            -- print("hand cards--------------->")
                            -- print_lua_table(USER_INFO.cards)

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

--                    if math.abs(event.y - self._card_start_y) > 5  then
--                        self._card_move_type = 2 --上下拖动
--                         return
--                    end 
                end
            end)
        end      

        --img:setPosition(cc.p(display.cx - startx + cout *dis ,110))
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
    require("ddz.calcCards"):init()
    require("ddz.PlayVideo"):init()
    self:setGameMode()
    require("hall.GameCommon"):playEffectMusic("ddz/audio/Audio_Game_Back.mp3",true)
    
    local function update(dt)
        local lbTime = self._scene:getChildByName("Text_1")
        if lbTime then
            local time = os.date("%H:%M", os.time())
            lbTime:setString(time)
        end
        self:updateClock()
        self:updateMatchWait(dt)
        self:updateDrawCoin(dt) 
        self:updateGroupTime()
        self:updateSendCard(dt)
        --直播
        require("ddz.PlayVideo"):update(dt)

        if bBombMusic then
            local flag = cc.SimpleAudioEngine:getInstance():isMusicPlaying()
            if not flag then
                bBombMusic = false
                require("hall.GameCommon"):playEffectMusic("ddz/audio/Audio_Game_Back.mp3",true)
            end
        end

    end
    self:scheduleUpdateWithPriorityLua(update,0)

    --登录房间
    ddzServer:LoginRoom(require("hall.GameList"):getReloadTable())

    self:setGameConfig()
    self:setBaseTime(0)


    --添加录音按钮
    require("hall.VoiceRecord.VoiceRecordView"):showView(490, 90)
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
            --组局显示筹码
            -- local spGold = self.layer_bottom:getChildByName("gold")
            -- if spGold then
            --     spGold:setTexture("hall/common/game_chip.png")
            --     spGold:setScale(0.7)
            -- end
            -- spGold = self._scene:getChildByName("touxiangbufen_2"):getChildByName("gold")
            -- if spGold then
            --     spGold:setTexture("hall/common/game_chip.png")
            --     spGold:setScale(0.5)
            -- end
            -- spGold = self._scene:getChildByName("touxiangbufen_1"):getChildByName("gold")
            -- if spGold then
            --     spGold:setTexture("hall/common/game_chip.png")
            --     spGold:setScale(0.5)
            -- end
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
    --添加录音按钮
    require("hall.VoiceRecord.VoiceRecordView"):showView(890, 270)
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
    -- print("touchAreaCard x,y,width,height",rect.x,rect.y,rect.width,rect.height)
    for key, value in pairs(USER_INFO.cards) do  
        local tag              = value[1]+(value[2]+100)*20  
        local img              = self.layout_ui:getChildByTag(tag)

        flag = cc.rectContainsPoint(rect, cc.p(value[3], value[4]))
        if flag then
            -- print("touchAreaCard select",value[1],tag)
            --区域范围内
--            flag = tag_t == tag and  true or flag

            -- if  flag then
                self:toBlack(tag)
            -- end
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
        local dos,index = require("ddz.ddzSettings"):getDOS(i)
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
            local dos,index = require("ddz.ddzSettings"):getDOS(i)
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

                    if mode == "match" then
                        self:setMatchPoint(gold+iAddCoin,0)
                    else
                        self:displayMine(gold+iAddCoin)
                    end
                else
                    self:drawOtherCoin(i,tbSeatCoin[i] + iAddCoin)
                end
        end
    else
        local function showFreeEnd()
            for i = 0,2 do
                local dos,index = require("ddz.ddzSettings"):getDOS(i)
                local txtWin = layer_win:getChildByName(dos)
                if txtWin then
                    txtWin:setVisible(false)
                end
            end

            if require("hall.gameSettings"):getGameMode() == "match" and bMatchStatus == 2 then
                require("ddz.MatchSetting"):showMatchResult()
                -- return
            end

            if bMatchStatus ~= 1 then
                --清除玩家
                -- for i=0,2 do
                --     if state_player == 10 then
                --         self:delUser(i)
                --     else
                --         if i ~= USERID2SEAT[tonumber(UID)] then
                --             self:delUser(i)
                --         end
                --     end
                -- end
                --清剩余牌
                self:clearAllUserDesk()
                self:clearCards()
                self.layout_basecard:setVisible(false)
            end

            bGameOver = false
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
            local dos,index = require("ddz.ddzSettings"):getDOS(i)
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
            local mb = cc.MoveBy:create(2,cc.p(0,60))
            local mb2 = cc.MoveBy:create(0.1,cc.p(0,-60))
            local hide = cc.Hide:create()
            local delay = cc.DelayTime:create(2)
            local fo = cc.FadeOut:create(3)
            local seq = nil
            if i == 0 then
                seq = cc.Sequence:create(mb,fo, hide,mb2,cc.CallFunc:create(showFreeEnd))
            else
                seq = cc.Sequence:create(mb,fo, hide,mb2)
            end

            txtWin:runAction(seq)
            --玩家分数变动
                if i == USERID2SEAT[tonumber(UID)] then
                    local gold = 0
                    local mode = require("hall.gameSettings"):getGameMode()
                    if mode == "free" or mode == "fast" then
                        USER_INFO["gold"] = USER_INFO["gold"]+tbWin[dos]
                        self:displayMine(USER_INFO["gold"])
                    elseif mode == "match" then
                        USER_INFO["match_gold"] = USER_INFO["match_gold"]+tbWin[dos]
                        self:setMatchPoint(USER_INFO["match_gold"])
                    elseif mode == "group" then
                        USER_INFO["chips"] = USER_INFO["chips"] + tbWin[dos]
                        self:displayMine(USER_INFO["chips"])
                    end
                else
                    self:drawOtherCoin(i,tbSeatCoin[i] + tbWin[dos])
                    tbSeatCoin[i] = tbSeatCoin[i] + tbWin[dos]
                end
        end
        bShowAddCoin = false
    end
end
--显示其他玩家信息
function PlayCardScene:drawOther(table_info)
    print( "PlayCardScene:drawOther"..json.encode(table_info))
    if not table_info  or #table_info <= 0 then
        return -1
    end

    dump(table_info,"drawOther")
    local mode = require("hall.gameSettings"):getGameMode()

    for key, var in ipairs(table_info) do
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
            local dos,index  = require("ddz.ddzSettings"):getDOS(var["seat"])
            print("drawOther: seat["..var["seat"].."]  dos["..dos.."]  index["..index.."]")
            local head = self._scene:getChildByName(dos):getChildByName("head")
            if not tolua.isnull(head:getChildByName("duanxian")) then --删除断线
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
                        head_info["sex"] = seat0sex+1
                        head_info["sp"] = head
                        head_info["size"] = headSize
                        head_info["touchable"] = 1
                        head_info["use_sharp"] = 1
                        head_info["vip"] = var["isVip"]
                        -- require("hall.GameCommon"):getUserHead(head_info)
                        require("hall.GameCommon"):setPlayerHead(head_info,head,headSize)
                    end
                    if sex then
                        local strHead = "ddz/Game/tihuan/sex_"..tostring(seat0sex+1)..".png"
                        sex:setTexture(strHead)
                    end
                elseif index == 1 then
                    seat1sex = var["sex"]
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
                        local strHead = "ddz/Game/tihuan/sex_"..tostring(seat1sex+1)..".png"
                        sex:setTexture(strHead)
                    end
                elseif index==2 then
                    seat2sex = var["sex"]
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
                        local strHead = "ddz/Game/tihuan/sex_"..tostring(seat2sex+1)..".png"
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
                -- local user_node = self._scene:getChildByName(dos)
                -- if user_node then
                --     x = user_node:getPositionX()
                --     y = user_node:getPositionY() - user_node:getContentSize().height/2
                -- end
                -- x = x + head:getPositionX() + headSize/2
                -- y = y + head:getPositionY()
                -- if index == 1 then
                --     x = x - headSize/2 - 30
                -- end
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
                -- if txt_gold then
                --     txt_gold:setVisible(true)
                --     print("set gold 1")
                --     -- if mode == "match" then
                --     --     txt_gold:setString(tostring(var["gold"]))
                --     -- else
                --     --     txt_gold:setString(require("hall.GameCommon"):formatGold(tonumber(var["gold"])))
                --     -- end
                --     txt_gold:setString(tostring(var["gold"]))
                --     print("set gold 2")
                -- end
                local strNick = require("hall.GameCommon"):formatNick(var["nick"])
                nick:setString(strNick)
                nick:setVisible(true)
            end
        end
    end
end
--显示seat id的金币
function PlayCardScene:drawOtherCoin(seat,gold)
    dump(USER_INFO["group_chip"], "drawOtherCoin", nesting)
    local dos,index =require("ddz.ddzSettings"):getDOS(seat)
    local txt_gold = nil

    -- if dos == "touxiangbufen_0" then
    --     return
    -- end
    local mode = require("hall.gameSettings"):getGameMode()
    if index == 0 then
        if mode == "match" then
            txt_gold = self. layer_bottom:getChildByName("Panel_match"):getChildByName("match_point")
        else
            txt_gold = self. layer_bottom:getChildByName("gold_mine")
        end
        if txt_gold then
            -- txt_gold:setString(require("hall.GameCommon"):formatGold(tonumber(USER_INFO["gold"])))
            txt_gold:setString(tostring(USER_INFO["gold"]))
        end
    else
        txt_gold = self._scene:getChildByName(dos):getChildByName("gold_mine")
        if mode == "match" then
            if txt_gold then
                txt_gold:setString(tostring(gold))
            end
        else
            if txt_gold then
                print("drawOtherCoin", tostring(gold - USER_INFO["group_chip"]))
                -- txt_gold:setString(require("hall.GameCommon"):formatGold(tonumber(gold)))
                txt_gold:setString(tostring(gold - USER_INFO["group_chip"]))
            end
        end
    end
end

--显示自己信息
function PlayCardScene:displayMine(value)
    local mode = require("hall.gameSettings"):getGameMode()
    local coin
    print("displayMine", tostring(value))
    if value then
        coin = value
        if mode == "group" then
            coin = coin - USER_INFO["group_chip"]
        end
    else
        -- if mode == "free" then
        --     coin = USER_INFO["gold"] or 0
        -- elseif mode == "match" then
        --     coin = USER_INFO["match_gold"] or 0
        -- elseif mode == "group" then
        --     coin = USER_INFO["chips"] or 0
        -- end
        if mode == "group" then
            coin = USER_INFO["chips"] or 0
            coin = coin - USER_INFO["group_chip"]
        else
            coin = USER_INFO["gold"] or 0
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
        -- lbScore:setString(require("hall.GameCommon"):formatGold(tonumber(coin)))
        print("displayMine", tostring(coin))
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
            lbScore:setString(tostring(USER_INFO["gold"]))
        end
    end
end
--玩家退场
function PlayCardScene:delUser(seat)

    print("delUser seat:"..seat,tostring(SEAT2USERID[seat]))

    mpcInGameList[SEAT2USERID[seat]] = nil
    SEAT2USERID[seat] = nil

    local dos,index  = require("ddz.ddzSettings"):getDOS(seat)
    local head = self._scene:getChildByName(dos):getChildByName("head")
    local sex  = self._scene:getChildByName(dos):getChildByName("sex")

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
    local duanxian = ccui.ImageView:create("ddz/images/duanxianchonglian_bt.png")   --断线标志
    head:addChild(duanxian)
    duanxian:setVisible(true)
    duanxian:setPosition(0,-110)
    duanxian:setName("duanxian")
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
    --     head_info["url"] = "ddz/Game/hall_ui/room_default_none.png"
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
    local dos,index = require("ddz.ddzSettings"):getDOS(seat)
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
        -- require("hall.GameData"):setPlayerRoute("ddz",mode,USER_INFO["base_chip"],1)
    end
    for i=0,2 do
        local dos,index = require("ddz.ddzSettings"):getDOS(i)
        local player = self._scene:getChildByName(dos)
        player:getChildByName("im_ready"):setVisible(false)
    end


    -- if isReload==true then
    --     self:setCard(1)
    --     bOnDeal = false

    --     --发完牌，显示叫地主
    --     if iGameState == 21 then
    --         self:clockAnimation(0)
    --         self:setJiaoPanel()
    --     end
    --     isReload = false
    -- else
        self:sendCardAnimate()
    -- end
    state_player = 2
end

local v_pos_effect = {{480,250},{760,400},{200,400}}
--抢地主
function PlayCardScene:qiang(seat,sex)
    self:clearUserDesk(seat)
    local spTT = self.layout_ui:getChildByName("tt"..tostring(seat))
    if spTT then
        spTT:removeSelf()
    end

    print("qiang seat",seat)

    local sp = display.newSprite("ddz/images/ddz_text_qiangdizhu.png")
    -- sp:setScale(0.8)
    sp:setName("tt"..tostring(seat))
    -- sp:addTo(self.layout_ui)
    self.layout_ui:addChild(sp)
    sp:setPosition(cc.p(v_pos_effect[seat+1][1],v_pos_effect[seat+1][2]))

    sex  = sex == 0 and 1 or sex +1
    local music = { "ddz/audio/CallLandlord_QDZ_M.mp3","ddz/audio/CallLandlord_QDZ_W.mp3"}
    require("hall.GameCommon"):playEffectSound(music[sex])
end
--不抢地主
function PlayCardScene:noqiang(seat,sex)
    self:clearUserDesk(seat)
    local spTT = self.layout_ui:getChildByName("tt"..tostring(seat))
    if spTT then
        spTT:removeSelf()
    end

    print("noqiang seat",seat)
    local sp = display.newSprite("ddz/images/ddz_text_buqiang.png")
    -- sp:setScale(0.8)
    sp:setName("tt"..tostring(seat))
    -- sp:addTo(self.layout_ui)
    self.layout_ui:addChild(sp)
    sp:setPosition(cc.p(v_pos_effect[seat+1][1],v_pos_effect[seat+1][2]))

    sex  = sex == 0 and 1 or sex +1
    local music = { "ddz/audio/CallLandlord_BQDZ_M.mp3","ddz/audio/CallLandlord_BQDZ_W.mp3"}
    require("hall.GameCommon"):playEffectSound(music[sex])
end

--不叫地主动画 sex 0 男 1 女
function PlayCardScene:nojiao(seat,sex)
    self:clearUserDesk(seat)
    local spTT = self.layout_ui:getChildByName("tt"..tostring(seat))
    if spTT then
        spTT:removeSelf()
    end

    print("nojiao seat",seat)
    local sp = display.newSprite("ddz/images/ddz_text_bujiao.png")
    -- sp:setScale(0.8)
    sp:setName("tt"..tostring(seat))
    -- sp:addTo(self.layout_ui)
    self.layout_ui:addChild(sp)
    sp:setPosition(cc.p(v_pos_effect[seat+1][1],v_pos_effect[seat+1][2]))

    sex  = sex == 0 and 1 or sex +1
    local music = { "ddz/audio/CallLandlord_BJDZ_M.mp3","ddz/audio/CallLandlord_BJDZ_W.mp3"}
    require("hall.GameCommon"):playEffectSound(music[sex])
end


--叫地主动画
function PlayCardScene:jiao(bet,seat)
    self:clearUserDesk(seat)
    local spTT = self.layout_ui:getChildByName("tt"..tostring(seat))
    if spTT then
        spTT:removeSelf()
    end
    print("jiao dz seat[%d]  bet[%d]",seat,bet)

    local sp = display.newSprite("ddz/images/ddz_text_jiaodizhu.png")
    -- sp:setScale(0.8)
    sp:setName("tt"..tostring(seat))
    -- sp:addTo(self.layout_ui)
    self.layout_ui._Tip=sp
    self.layout_ui:addChild(sp)
    -- sp:setPosition(cc.p(position[seat][1],position[seat][2]))
    sp:setPosition(cc.p(v_pos_effect[seat+1][1],v_pos_effect[seat+1][2]))

    local music = { "ddz/audio/CallLandlord_JDZ_M.mp3","ddz/audio/CallLandlord_JDZ_W.mp3"}
    if seat==0 then
        require("hall.GameCommon"):playEffectSound(music[seat0sex+1])
    elseif seat==1 then
        require("hall.GameCommon"):playEffectSound(music[seat1sex+1])
    elseif seat==2 then
        require("hall.GameCommon"):playEffectSound(music[seat2sex+1])
    end

end


--不要动画
function PlayCardScene:noyao(seat)
    self:clearUserDesk(seat)

    local sp = display.newSprite("ddz/images/ddz_text_buchu.png")
    -- sp:setScale(0.8)
    sp:setName("tt"..tostring(seat))
    local rnd = math.random(100,200)
    local music
    if rnd % 2 == 0 then
        math.randomseed(socket.gettime())
        local rnd1 = math.random(100,200)
        if rnd1%2 == 0 then
            music = { "ddz/audio/Audio_Pass1_M.mp3","ddz/audio/Audio_Pass1_W.mp3"}
        else
            music = { "ddz/audio/Audio_Pass3_M.mp3","ddz/audio/Audio_Pass3_W.mp3"}
        end
    else
        music = { "ddz/audio/Audio_Pass2_M.mp3","ddz/audio/Audio_Pass2_W.mp3"}
    end
    
    sp:addTo(self.layout_ui)
    sp:setPosition(cc.p(v_pos_effect[seat+1][1],v_pos_effect[seat+1][2]))

    if seat==0 then
        require("hall.GameCommon"):playEffectSound(music[seat0sex+1])
    elseif seat==1 then
        require("hall.GameCommon"):playEffectSound(music[seat1sex+1])
    elseif seat==2 then
        require("hall.GameCommon"):playEffectSound(music[seat2sex+1])
    end
end

-- 设置叫地主界面
function  PlayCardScene:setJiaoPanel(per_id)
    per_id = per_id or 0--为0表示第一次抢，即从我开始叫地主
        self.buttons_jiaofen:setVisible(true)
        if per_id == 0 then
            self.buttons_jiaofen:getChildByName("btn_jiao"):setVisible(true)
            self.buttons_jiaofen:getChildByName("btn_bujiao"):setVisible(true)

            self.buttons_jiaofen:getChildByName("btn_qiang"):setVisible(false)
            self.buttons_jiaofen:getChildByName("btn_buqiang"):setVisible(false)
        else
            self.buttons_jiaofen:getChildByName("btn_qiang"):setVisible(true)
            self.buttons_jiaofen:getChildByName("btn_buqiang"):setVisible(true)

            self.buttons_jiaofen:getChildByName("btn_jiao"):setVisible(false)
            self.buttons_jiaofen:getChildByName("btn_bujiao"):setVisible(false)
        end
end


--清楚叫地主按钮
function PlayCardScene:clearJiao()
    self.buttons_jiaofen:setVisible(false)    
end

--进入房间设置准备按钮
function PlayCardScene:loginTableSetReafyPanel()
    --是否换桌
    state_player = 0
    local ret = require("hall.hall_data"):checkEnter("ddz",USER_INFO["gameLevel"])
    if ret > 0 then
        local adapLevel = require("hall.hall_data"):getAdapterLevel("ddz")
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
                spTxt:setTexture("ddz/images/subsidy_text_zailaiyiju.png")
            else
                spTxt:setTexture("ddz/images/text_huanzhuo.png")
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
                require("hall.GameCommon"):playEffectSound("ddz/audio/Audio_Button_Click.mp3")
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
                    -- ddzServer:LoginGame()
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
                    display_scene("ddz.SelectChip",1)
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


--加倍动画
function PlayCardScene:doubleAnimate(base)
    local double_img  = cc.Sprite:create("ddz/Game/hall_ui/11.png")
    double_img:setScale(0.5)
    double_img:addTo(self.layout_ui)
    double_img:setName("double_img")

    self._doublecount = 0
    if self._doublehandle then
        scheduler.unscheduleGlobal(self._doublehandle)
    end

    local double_num  = cc.Sprite:create("ddz/Game/hall_ui/animMoneyMultiple_pin.png")
    if base == 3 then
        double_img:setPosition(cc.p(480-60,270+50))
        double_num:setTextureRect(cc.rect(0,280,100,100))
        double_num:addTo(double_img)
        local x = double_num:getPositionX()
        local y = double_num:getPositionY()
        double_num:setPosition(cc.p(x+130,y+45))
    end

    if base == 6 then
        double_img:setPosition(cc.p(480-60,270+50))
        double_num:setTextureRect(cc.rect(100,93,100,95))
        double_num:addTo(double_img)
        local x = double_num:getPositionX()
        local y = double_num:getPositionY()
        double_num:setPosition(cc.p(x+135,y+46))
    end

    if base == 12 then
         double_img:setPosition(cc.p(480-80,270+50))
        double_num:setTextureRect(cc.rect(100,380,100,95))
        double_num:addTo(double_img)
        local x = double_num:getPositionX()
        local y = double_num:getPositionY()
        double_num:setPosition(cc.p(x+130,y+45))

        local double_num1  = cc.Sprite:create("ddz/Game/hall_ui/animMoneyMultiple_pin.png")
        double_num1:setTextureRect(cc.rect(0,380,100,95))
        double_num1:addTo(double_img)
        local x = double_num1:getPositionX()
        local y = double_num1:getPositionY()
        double_num1:setPosition(cc.p(x+130+70,y+45))
    end


     if base == 24 then
        double_img:setPosition(cc.p(480-80,270+50))
        double_num:setTextureRect(cc.rect(0,380,100,95))
        double_num:addTo(double_img)
        local x = double_num:getPositionX()
        local y = double_num:getPositionY()
        double_num:setPosition(cc.p(x+130,y+45))

        local double_num1  = cc.Sprite:create("ddz/Game/hall_ui/animMoneyMultiple_pin.png")
        double_num1:setTextureRect(cc.rect(100,190,100,95))
        double_num1:addTo(double_img)
        local x = double_num1:getPositionX()
        local y = double_num1:getPositionY()
        double_num1:setPosition(cc.p(x+130+70,y+45))
    end
    self._doublex   = double_img:getPositionX()
    require("hall.GameCommon"):playEffectSound("ddz/audio/Audio_Lord_Multiple.mp3")
    self._doublehandle    = scheduler.scheduleGlobal(function() 
        self._doublecount  = self._doublecount + 1

        local index = math.floor(self._doublecount / 6) +1
        local nx = double_img:getPositionX()
        local ny = double_img:getPositionY()
        if self._doublecount <= 21 then
           
        
            if self._doublecount %3 ==  1 then
                double_img:setPositionX(nx +2)
            end
            if(self._doublecount %3 ==  2) then
                double_img:setPositionX(nx -2)
            end
        end

        if self._doublecount > 40 then
            self._doublecount = 0
            self.layout_ui:removeChildByName("double_img")
            scheduler.unscheduleGlobal(self._doublehandle)
        end
    end,0.01)    
end

-- 出现三张未翻开的底牌
function PlayCardScene:sendBaseCard()
    for i=1,3 do
        local str = "base"..tostring(i)
        local double_img  = self.layout_basecard:getChildByName(str)
        if double_img then
            double_img:loadTexture("ddz/Game/cards/lord_card_backface_big.png")
            double_img:setVisible(true)
        else
            print("sendBaseCard:"..str)
        end
        str = "card"..tostring(i)
        local card = self.layout_basecard:getChildByName(str)
        if card then
            self.layout_basecard:removeChild(card)
        end
    end
    self.layout_basecard:setVisible(true)   
end

-- 发牌后 底盘展现旋转动画
function  PlayCardScene:cardRotation(table_card)

    local layout = self._scene:getChildByName("play_top")
    local node = layout:getChildByName("layout_basecard")
    local double_img  = node:getChildByName("base1")
    local double_img1 = node:getChildByName("base2")
    local double_img2 = node:getChildByName("base3")
    
    local function  hide (sender,table)
        sender:setVisible(false)
    end
    local r           = cc.OrbitCamera:create(1,100,0,0,360,0,0)
    local call_hide   = cc.CallFunc:create(hide)
    local delay       = cc.DelayTime:create(0.25)
    local se          = cc.Sequence:create(delay,call_hide)
    local sp          = cc.Spawn:create(r,se)
    double_img:runAction(sp)
    local r1           =  cc.OrbitCamera:create(1,100,0,0,360,0,0)
    local call_hide1   = cc.CallFunc:create(hide)
    local delay1       = cc.DelayTime:create(0.25)
    local se1          = cc.Sequence:create(delay1,call_hide1)
    local sp1          = cc.Spawn:create(r1,se1)
    double_img1:runAction(sp1)
    local r2           =  cc.OrbitCamera:create(1,100,0,0,360,0,0)
    local call_hide2  = cc.CallFunc:create(hide)
    local delay2       = cc.DelayTime:create(0.25)
    local se2          = cc.Sequence:create(delay2,call_hide2)
    local sp2          = cc.Spawn:create(r2,se2)
    double_img2:runAction(sp2)

    local new = Card:getSmallCard(table_card[1][1],table_card[1][2])
    new:addTo(node)
    new:setName("card1")
    new:setPosition(double_img:getPosition())
    local new1 = Card:getSmallCard(table_card[2][1],table_card[2][2])
    new1:addTo(node)
    new1:setName("card2")
    new1:setPosition(double_img1:getPosition())
    local new2 = Card:getSmallCard(table_card[3][1],table_card[3][2])
    new2:addTo(node)
    new2:setName("card3")
    new2:setPosition(double_img2:getPosition())  
    new:setVisible(false)
    new1:setVisible(false)
    new2:setVisible(false)

    local function  show (sender,table)
        sender:setVisible(true)
    end
    local r4           =  cc.OrbitCamera:create(0.5,100,0,-90,90,0,0)
    local call_show4   = cc.CallFunc:create(show)
    local delay4       = cc.DelayTime:create(0.25)
    local se4          = cc.Sequence:create(delay4,call_show4)
    local sp4          = cc.Spawn:create(r4,se4)
    new:runAction(sp4)
    local r5           =  cc.OrbitCamera:create(0.5,100,0,-90,90,0,0)
    local call_show5   = cc.CallFunc:create(show)
    local delay5       = cc.DelayTime:create(0.25)
    local se5          = cc.Sequence:create(delay5,call_show5)
    local sp5          = cc.Spawn:create(r5,se5)
    new1:runAction(sp5)
    local r6           =  cc.OrbitCamera:create(0.5,100,0,-90,90,0,0)
    local call_show6   = cc.CallFunc:create(show)
    local delay6       = cc.DelayTime:create(0.25)
    local se6          = cc.Sequence:create(delay6,call_show6)
    local sp6          = cc.Spawn:create(r6,se6)
    new2:runAction(sp6)
end

-- 给农民和地主帽子
function PlayCardScene:setHat(seat,isLandlord)    
    local dos,index = require("ddz.ddzSettings"):getDOS(seat)
    local hat = self._scene:getChildByName(dos):getChildByName("sp_identity_back")
    if hat then
        hat:setVisible(true)
        local spIdentity = hat:getChildByName("sp_identity")
        if spIdentity then
            local str = ""
            if isLandlord == 1 then
                str = "ddz/images/ddz_text_dizhu.png"
            else
                str = "ddz/images/ddz_text_nongmin.png"
            end
            spIdentity:setTexture(str)
        end
    end
end

--清空帽子
function PlayCardScene:clearHat()
    for i=0,2 do
        local dos,index = require("ddz.ddzSettings"):getDOS(i)
        self._scene:getChildByName(dos):getChildByName("sp_identity_back"):setVisible(false)
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
    local tip_enabled= true
    if b==1 then 
        tip_enabled=false
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
        self.btn_tip:setTouchEnabled(tip_enabled)
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
    local typeCard,a,b  =  CardAnalysis:getType(cards)  -- 分析滑出的牌

    if not typeCard then
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
        
        --先检查类型
        --相同类型
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
            if typeCard == 11 or typeCard == 12 then--炸弹,火箭
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
                    require("hall.GameCommon"):playEffectSound("ddz/audio/Audio_Button_Click.mp3")
                    btnAuto:setScale(0.6)
                end

                if event == TOUCH_EVENT_ENDED then
                    btnAuto:setScale(1)

                    --取消托管
                    self:showAuto(false)
                    iActionCounts = 1
                    iLastLiftTime = 13
                    require("ddz.ddzServer"):CLI_AUTO(0)
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
                local x                    = card_area:getPositionX()
                local y                    = card_area:getPositionY()
                if y > cardY and tmp[key] ~= 1 then
                    card_area:setPosition(cc.p(x,y-jumpCardY))
                    USER_INFO.cards[key][5] = 0
                end                    
            end
        end
    end
    require("hall.GameCommon"):playEffectSound("ddz/audio/Audio_Button_Click.mp3")
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
    if self.layout_ui:getChildByName("card_error_msg") then
        self.layout_ui:removeChildByName("card_error_msg")
    end

    display.addSpriteFrames("ddz/common/msg.plist", "ddz/common/msg.png")
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
    imageView:loadTexture("ddz/images/gold_box.png")
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
        if( a[2]  == 4 and b[2] == 4) then
            return a[1]>b[1]
        end

        if(a[2] == 4 and b[2] ~= 4) then
            return true
        end

        if(a[2] ~= 4 and b[2] == 4) then
            return false
        end

        if(a[2] ~= 4 and b[2] ~= 4) then
            if a[1] == b[1] then
                return a[2] > b[2]
            else
                return a[1]>b[1]
            end

        end
    end)

    local type_t = CardAnalysis:getType(cards)
    local tmp    = {}
    if type_t >=7 and type_t <= 12 then

        for k,v in pairs(cards) do
            if not tmp[v[1]] then
                tmp[v[1]] = {}
            end

            table.insert(tmp[v[1]],{v[1],v[2]})
        end

        local all = {}
        for k,v in pairs(tmp) do
            table.insert(all,v)
        end

        table.sort(all,function(a,b)
            return #a>#b
        end)

        local result ={}
        for k,v in pairs(all) do
            for kk,vv in pairs(v) do
                 table.insert(result,{vv[1],vv[2]})
            end

        end

        return result
    end   
    return cards   
end

--显示别的出的牌
function PlayCardScene:showOtherCard(cards,seat,server_seat,offerx)

    offerx = offerx or 35
    local node = display.newNode()

    node:addTo(self.layout_ui)
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

    local b_show_msg = false
    local show_logo = 0
    for k,v in pairs(cards) do
        if k == #cards and loadSeat == server_seat and loadSeat ~= USER_INFO["seat"] then
            show_logo = 1
        end
        local img = Card:getOutCard(v[1],v[2],show_logo)
        if img then
            -- if v[1] <3 or v[1] >14 then
            --     b_show_msg = true
            -- end
            img:addTo(node)
            -- end
            img:setPosition(cc.p(start+i*offerx,yh))
            i = i + 1
        end
    end
    if b_show_msg then

        local strCard = ""
        for key,value in pairs(cards) do
            -- dump(value, "showOtherCard")
            local all = "0x"..tostring(value[2])..string.format("%x",value[1])
            print("showOtherCard byte:",tostring(all),tostring(key))
            
            if key > 1 then
                -- if key%6 == 0 then
                --     strCard = strCard.."\n"
                -- else
                    strCard = strCard .. ","
                -- end
            end
            strCard  = strCard..tostring(all)
        end
        print("showOtherCard:",strCard)
        require("hall.GameTips"):showTips(strCard)
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
function PlayCardScene:setRestCardNum(seat,num)
    print("player seat:"..tostring(seat),"card amount:"..tostring(num))
    if seat==1 or seat==2 then
        if num<=2 and num>0 then
            self.layout_ui:getChildByName("baojing"..tostring(seat)):setVisible(true)
        else
            self.layout_ui:getChildByName("baojing"..tostring(seat)):setVisible(false)
        end
        local sex
        if seat==0 then
            sex = seat0sex+1
        elseif seat==1 then
            sex = seat1sex+1
        elseif seat==2 then
            sex = seat2sex+1
        end
        if num == 1 then
            if sex == 1 then--男
                require("hall.GameCommon"):playEffectSound("ddz/audio/new/Man_baojing1.mp3")
            else--2是女，0保密
                require("hall.GameCommon"):playEffectSound("ddz/audio/new/Woman_baojing1.mp3")
            end
        end
        if num == 2 then
            if sex == 1 then--男
                require("hall.GameCommon"):playEffectSound("ddz/audio/new/Man_baojing2.mp3")
            else--2是女，0保密
                require("hall.GameCommon"):playEffectSound("ddz/audio/new/Woman_baojing2.mp3")
            end
        end
        local cardNum = self.layout_ui:getChildByName("cardNum"..tostring(seat))
        if cardNum then
            cardNum:setVisible(true)
            cardNum:setString(tostring(num))
        end
        local cardNumBack = self.layout_ui:getChildByName("cardNumBack"..tostring(seat))
        if cardNumBack then
            cardNumBack:setVisible(true)
        end
    end
    REMAINCARDS[seat] = num
end

--播放出片的声音&效果
function PlayCardScene:playCardsMusic(card_table,type,seat)    
    local file
    local sex
    if seat==0 then
        sex = seat0sex+1
    elseif seat==1 then
        sex = seat1sex+1
    elseif seat==2 then
        sex = seat2sex+1
    end
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
        require("ddz.Animation"):animShun(self.layout_effect,seat)
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
        
        require("ddz.Animation"):animDoubleLine(self.layout_effect)
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

    if type == 6 or type == 13 or type == 14 then--三连类型
        if sex == 2 then
            file = "Audio_Card_Plane_W.mp3"
        else
            file = "Audio_Card_Plane_M.mp3"
        end
        
        require("ddz.Animation"):animPlane(self.layout_effect)
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

    if type == 9  then--四带两单
        if sex == 2 then
            file = "Audio_Card_Four_Take_2_W.mp3"
        else
            file = "Audio_Card_Four_Take_2_M.mp3"
        end
        
    end

    if type == 10  then--四带两对
        if sex == 2 then
            file = "Audio_Card_Four_Take_2Double_W.mp3"
        else
            file = "Audio_Card_Four_Take_2Double_M.mp3"
        end
        
    end

    --炸弹类型
    if type == 11 then
        if sex == 2 then
            file = "Audio_Card_Bomb_W.mp3"
        else
            file = "Audio_Card_Bomb_M.mp3"
        end
        require("ddz.Animation"):animBoom(self.layout_effect)
        require("hall.GameCommon"):playEffectMusic("ddz/audio/new/Audio_after_bomb.mp3")
        bBombMusic = true
    end


    if type == 12  then--火箭类型
        if sex == 2 then
            file = "Audio_Card_Rocket_W.mp3"
        else
            file = "Audio_Card_Rocket_M.mp3"
        end
        -- self:animRocket()
        require("ddz.Animation"):animRocket(self.layout_effect)
    end
    require("hall.GameCommon"):playEffectSound("ddz/audio/new/"..file)
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
        require("ddz.ddzServer"):CLI_PLAYER_CARD(cardAmount,cards)
        --消息发送隐藏按钮
        self:cleanupPlayCardBtn()
    end
end

--设置倍数
function PlayCardScene:setBaseTime(time,xFlag)
    local isShowX = xFlag or 0
    if isShowX == 1 then
        local base_score = self._scene:getChildByName("base_score")
        if base_score and tonumber(time) > 0 then
            base_score:setVisible(true)
            base_score:setString("X"..tostring(time))
        end
    end
    local Panel_basebei = self. layer_bottom:getChildByName("Panel_basebei")
    local little_base = Panel_basebei:getChildByName("little_base")
    if little_base then
        little_base:setString(tostring(time))
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

    if mode == "group" then
        if require("ddz.ddzSettings"):getGroupState() == 1 then
            --停止直播
            require("ddz.PlayVideo"):stopVideo()
            print(" PlayCardScene:stopRound()++++++++++++++++++++++++")
            require("ddz.ddzSettings"):setGroupState(0)
            require("ddz.ddzSettings"):showGroupResult(groupRanking)
            cc.SimpleAudioEngine:getInstance():stopAllEffects()
            cc.SimpleAudioEngine:getInstance():stopMusic()
            audio.stopMusic(false)
        else
            --自动准备
            self:getChips()
            -- ddzServer:LoginGame()
        end
    end
end

--重新发牌
function PlayCardScene:endGame()

    print("endGame  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx")
    if self:getChildByName("match_win") then
        self:removeChildByName("match_win")
    end
    if self:getChildByName("match_lose") then
        self:removeChildByName("match_lose")
    end
    if self:getChildByName("match_wait") then
        self:removeChildByName("match_wait")
    end
    if self:getChildByName("match_result") then
        self:removeChildByName("match_result")
    end

    self:cleanupPlayCardBtn()
    self:clearJiao()
    self:clearAllUserDesk()
    self:clearHat()
    self:resetGame()
    -- USERID2SEAT = {}
    -- SEAT2USERID = {}
    -- mpcInGameList = {}

    --隐藏解散房间按钮
    local btn_release_group = self._scene:getChildByName("btn_release_group")
    btn_release_group:setVisible(false)

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
        -- cardNumBack:setTexture("ddz/Game/cards/lord_card_backface_big.png")
        cardNumBack:setVisible(false)
    end
    cardNumBack = self.layout_ui:getChildByName("cardNumBack2")
    if cardNumBack then
        -- cardNumBack:setTexture("ddz/Game/cards/lord_card_backface_big.png")
        cardNumBack:setVisible(false)
    end

    iGameState = 0
    iTotalTimes = 0
    call_bet_first = 0
    local sp = self.layout_effect:getChildByName("shunanim")
    if sp then
        sp:stopAllActions()
        self.layout_effect:removeChildByName("shunanim")
    end
    --设置倍数
    self:setBaseTime(1)
    mpcInGameList = {}

    if require("ddz.ddzSettings"):getGroupState() ~= 1 then
        cc.SimpleAudioEngine:getInstance():stopAllEffects()
        cc.SimpleAudioEngine:getInstance():stopMusic()
        require("hall.GameCommon"):playEffectMusic("ddz/audio/Audio_Game_Back.mp3",true)
    end
end

function PlayCardScene:updateMatchWait(dt)
    if bShowMatchWait == false then
        return
    end

    fTimeMatchWait = fTimeMatchWait + dt
    if fTimeMatchWait >= fRoundFrame then
        fTimeMatchWait = fTimeMatchWait - fRoundFrame
        local str = "sp_current_rank"..tostring(idxRound)
        str = "sp_current_rank"..tostring(idxRound)
        local match_wait = self:getChildByName("match_wait")
        if match_wait then
            local sp = match_wait:getChildByName(str)
            if sp then
                sp:setVisible(false)
            end
            idxRound = idxRound + 1
            if idxRound > 5 then
                idxRound = 1
            end
            str = "sp_current_rank"..tostring(idxRound)
            sp = match_wait:getChildByName(str)
            if sp then
                sp:setVisible(true)
            end
        end
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
--更新比赛分数
function PlayCardScene:setMatchPoint(value,update)
    print("setMatchPoint",value)
    local isUpdate = update or 1
    if isUpdate == 1 then
        USER_INFO["match_gold"] = value
    end
    local match_info = self.layer_bottom:getChildByName("Panel_match")
    if require("hall.gameSettings"):getGameMode() == "match" then
        if match_info then
            match_info:setVisible(true)
            local match_point = match_info:getChildByName("match_point")
            if match_point then
                -- match_point:setString(require("hall.GameCommon"):formatGold(tonumber(value)))
                match_point:setString(tostring(value))
            end
        end
    end
end

function PlayCardScene:getPosforSeat(uid)
    local seat=USERID2SEAT[tonumber(uid)]
    local name,index=require("ddz.ddzSettings"):getDOS(seat)

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

----------------------------------------------------------------
------------------------- 返回网络消息 -------------------------
----------------------------------------------------------------
--游戏开始
function PlayCardScene:onNetGameStart(pack)
    print("PlayCardScene game start")
    --如果围观登录，退出围观，再进入围观
    if state_player == 10 then
        state_player = 5
        require("ddz.ddzServer"):CLI_REQUEST_LOOK_OUT(require("ddz.ddzSettings"):getLookingTable(),-1)
    end

    --游戏开始
    -- local c  = Card.new()
    -- for i=0,17 do
    --     local card = Card:Decode(15)
    --     Card:Encode(card)
    --     c:init(card)
    --     print("add card value:",c._value,"kind:",c._kind)
    --     local key =  Card:addCard(c)
    -- end
    -- Card:sortCard()

    -- self:start()
    -- self:setRestCardNum(0,17)
    -- self:setRestCardNum(1,17)
    -- self:setRestCardNum(2,17)    
    -- iGameState = 1
end


--进入房间
function PlayCardScene:onNetLoginGameSucc(pack)

    --记录房间用户信息
    bm.Room = {}
    bm.Room.UserInfo  = {}

    local mode = require("hall.gameSettings"):getGameMode()
    print("login game success game mode["..mode.."]")
    state_player = 1
    --重置记牌器
    -- require("ddz.calcCards"):reset()

    print("onNetLoginGameSucc gold:",pack["Userscore"])

    USER_INFO["gold"] = pack["Userscore"]
    USER_INFO["score"] = pack["Userscore"]
    USER_INFO["seat"] = pack["Seatid"]
    tbSeatCoin[USER_INFO["seat"]] = USER_INFO["gold"]
    USERID2SEAT[tonumber(UID)] = pack["Seatid"]
    SEAT2USERID[pack["Seatid"]] = tonumber(UID)
    print("player seatid:%d",USERID2SEAT[tonumber(UID)])
    seat0sex = USER_INFO["sex"]-1

    self:displayMyselfInfo()
    --设置底分
    self:setBaseChip(pack["Basechip"])

    --加入语音广播列表
    local tb_user_data = {}
    tb_user_data["seat"] = USER_INFO["seat"]
    tb_user_data["gold"] = USER_INFO["gold"]
    tb_user_data["uid"]  = tonumber(UID)
    tb_user_data["nick"] = USER_INFO["nick"]
    tb_user_data["sex"]  = USER_INFO["sex"]
    tb_user_data["icon"] = USER_INFO["icon_url"]
    bm.Room.UserInfo[tonumber(UID)] = tb_user_data

    for i, v in ipairs(pack["playerlist"]) do
        local uid = tonumber(v["Userid"])
        local table_info = {}
        table_info["seat"] = v["Seatid"]
        table_info["ready"] = v["ReadyStart"]
        table_info["gold"] = v["Playerscore"]
        table_info["uid"]  = uid

        tbSeatCoin[table_info["seat"]] = table_info["gold"]
        local userinfo = json.decode(v["Userinfo"])
        print_lua_table(userinfo)
        if userinfo then

            table_info["nick"] = userinfo["nickName"]
            table_info["sex"]  = userinfo["sex"]
            table_info["icon"] = userinfo["photoUrl"]
            table_info["isVip"] = userinfo["isVip"]
        else
            table_info["nick"] = tostring(uid)
        end
        self:drawOther({table_info});
        USERID2SEAT[uid] = table_info["seat"]
        print("other player %d seatid:%d",i,USERID2SEAT[uid])

        bm.Room.UserInfo[uid] = table_info

    end
    
    local uid_arr = {}
    if bm.Room ~= nil then
        if bm.Room.UserInfo ~= nil then
            for k,v in pairs(bm.Room.UserInfo) do
                if v then
                    table.insert(uid_arr, k)
                end
            end
        end
    end

    dump(uid_arr, "-----用户Id-----")
    require("hall.GameSetting"):setPlayerUid(uid_arr)

    print("onNetLoginGameSucc",mode)
    if mode == "group" then--组局
        self:getChips()
    else
        require("ddz.ddzServer"):CLI_READY_GAME()
        --发送准备消息后，隐藏准备按钮
        self:ready()
        -- if require("ddz.ddzSettings"):getGameCount() == 0 then
        --     --发送准备消息
        -- else
        --     --登录房间成功，显示准备按钮
        -- end
        -- 自动准备
    end
    -- 移除netloader
    if self:getChildByName("loading") then
        self:getChildByName("loading"):removeSelf()
    end
end
--围观进入房间成功
function PlayCardScene:onNetLookLogin(pack)
    local mode = require("hall.gameSettings"):getGameMode()
    print("login game success game mode["..mode.."]")
    state_player = 10
    require("ddz.ddzSettings"):setLookState(2)

    USER_INFO["gold"] = pack["Userscore"]
    USER_INFO["score"] = pack["Userscore"]
    USER_INFO["seat"] = pack["Seatid"]

    --设置底分
    self:setBaseChip(pack["Basechip"])

    for i, v in ipairs(pack["playerlist"]) do
        local uid = tonumber(v["Userid"])
        local table_info = {}
        table_info["seat"] = v["Seatid"]
        table_info["ready"] = v["ReadyStart"]
        table_info["gold"] = v["Playerscore"]
        table_info["uid"]  = uid

        tbSeatCoin[table_info["seat"]] = table_info["gold"]
        local userinfo = json.decode(v["Userinfo"])
        print_lua_table(userinfo)
        if userinfo then

            table_info["nick"] = userinfo["nickName"]
            table_info["sex"]  = userinfo["sex"]
            table_info["icon"] = userinfo["photoUrl"]
            table_info["isVip"] = userinfo["isVip"]
        else
            table_info["nick"] = tostring(uid)
        end
        self:drawOther({table_info});
        USERID2SEAT[uid] = table_info["seat"]
        print("other player %d seatid:%d",i,USERID2SEAT[uid])
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
    require("hall.GameTips"):showTips(require("ddz.ddzSettings"):getErrorCode(pack["nErrno"]),errcode,showBtn)
end

--有玩家进入房间
function PlayCardScene:onNetPlayerInRoom(pack)
    if bGameOver then
        return
    end

    if pack then
        local uid = tonumber(pack["userid"])
        local table_info = {}
        table_info["seat"] = pack["seatid"] 
        table_info["ready"] = pack["ready"]
        if pack["score"] >= 0 then
            table_info["gold"] = pack["score"]
        elseif pack["score"] == -1 then
            table_info["gold"] = pack["chip"]
        end
        table_info["uid"] = uid

        local userinfo = json.decode(pack["userinfo"])
        if userinfo then
            table_info["nick"] = userinfo["nickName"]
            table_info["sex"] = userinfo["sex"]
            table_info["icon"] = userinfo["photoUrl"]
            table_info["isVip"] = userinfo["isVip"]
        else
            table_info["nick"] = tostring(uid)
        end

        tbSeatCoin[table_info["seat"]] = table_info["gold"]
        USERID2SEAT[uid] = table_info["seat"]
        if uid == tonumber(UID) then
            USER_INFO["gold"] = table_info["gold"]
            USER_INFO["score"] = pack["gold"]
            USER_INFO["seat"] = pack["seatid"]
            self:displayMyselfInfo()
        else
            self:drawOther({table_info})
        end

        bm.Room.UserInfo[uid] = table_info

        local uid_arr = {}
        if bm.Room ~= nil then
            if bm.Room.UserInfo ~= nil then
                for k,v in pairs(bm.Room.UserInfo) do
                    if v then
                        table.insert(uid_arr, k)
                    end
                end
            end
        end

        dump(uid_arr, "-----用户Id-----")
        require("hall.GameSetting"):setPlayerUid(uid_arr)
    end
end

--玩家退出房间返回
function PlayCardScene:onNetLogoutRoomOk(pack)
    print("onNetLogoutRoomOk:"..tostring(bLogout))
    print("bPlayerExitGroup:"..tostring(bPlayerExitGroup))
    print("bFakeLogout:"..tostring(bFakeLogout))
    print("state_player:"..tostring(state_player))
    local mode = require("hall.gameSettings"):getGameMode()
    if mode == "group" then
        if tonumber(USER_INFO["group_owner"]) == tonumber(UID) then
            local btn_release_group = self._scene:getChildByName("btn_release_group")
            if btn_release_group then
                btn_release_group:loadTextureNormal("hall/common/small_disable_bt_n.png")
                btn_release_group:setTouchEnabled(false)
            end
        end
        -- btn_release_group:setVisible(false)
    end

    if require("ddz.ddzSettings"):getGroupState() == 1 then
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
        local uid = tonumber(pack["Uid"])
        print("player [%d] logout room", tostring(uid))
        local seat = USERID2SEAT[uid]
        if seat then
            self:delUser(seat)
        end
        bm.Room.UserInfo[uid] = nil
        local uid_arr = {}
        if bm.Room ~= nil then
            if bm.Room.UserInfo ~= nil then
                for k,v in pairs(bm.Room.UserInfo) do
                    if v then
                        table.insert(uid_arr, k)
                    end
                end
            end
        end

        dump(uid_arr, "-----用户Id-----")
        require("hall.GameSetting"):setPlayerUid(uid_arr)
    end
end


--准备返回
function PlayCardScene:onNetReadyGame(pack)
    if bGameOver then
        return
    end

--    print("准备状态 pack:"..pack)
    if pack then
        local readyId = tonumber(pack["Uid"])
        print("pack id:",readyId)
        print("USER_INFO uid:", tostring(UID))

        if tonumber(readyId) ~= tonumber(UID) then
            print("onNetReadyGame")
            print_lua_table(USERID2SEAT)
            self:setOtherReady(USERID2SEAT[readyId])
        else
            --清空之前的牌
            self:clearCards()
            self:ready()
            local mode = require("hall.gameSettings"):getGameMode()
            if mode == "group" then
                if tonumber(USER_INFO["group_owner"]) == tonumber(UID) then
                    local btn_release_group = self._scene:getChildByName("btn_release_group")
                    if btn_release_group then
                        btn_release_group:loadTextureNormal("hall/Settings/setting_yellow_bt.png")
                        btn_release_group:setTouchEnabled(true)
                    end
                end
            end
        end
    end
end

--发牌
function PlayCardScene:onNetDeal(pack)
    print("send cards ----- 发牌")
    if state_player < 10 then
        state_player = 3
    end

    self:clearJiao()
    self:clearAllUserDesk()
    -- self:endGame()
    self:clearCards()
    USER_INFO["cards"] = nil
    temp_cards = {}
    local c  = Card.new()

    require("ddz.ddzSettings"):addGame()

    for i,v in ipairs(pack["Cardbuf"]) do
        table.insert(temp_cards,v)
        local card = Card:Decode(v)
        Card:Encode(card)
        c:init(card)
        local key =  Card:addCard(c)
    end
    Card:sortCard()
    dump(temp_cards, "onNetDeal temp_cards")

    dt_send_card = 0.1
    self:start()
    self:setRestCardNum(0,17)
    self:setRestCardNum(1,17)
    self:setRestCardNum(2,17)    
    iGameState = 1

    -- --隐藏解散房间按钮
    local btn_release_group = self._scene:getChildByName("btn_release_group")
    btn_release_group:setVisible(false)

    --隐藏邀请好友按钮
    local invite_ly = self._scene:getChildByName("invite_ly")
    invite_ly:setVisible(false)

    --显示视频录制按钮
    local btn_record = self._scene:getChildByName("btn_record")
    btn_record:setVisible(true)

    --添加视频引导
    require("hall.leader.LeaderLayer"):showLeaderLayer(cc.p(335.61, 505.51))

    local uid_arr = {}
    if bm.Room ~= nil then
        if bm.Room.UserInfo ~= nil then
            for k,v in pairs(bm.Room.UserInfo) do
                if v then
                    table.insert(uid_arr, k)
                end
            end
        end
    end

    dump(uid_arr, "-----用户Id-----")
    require("hall.GameSetting"):setPlayerUid(uid_arr)

    if bm.Room == nil then
        bm.Room = {}
    end
    bm.Room.start_group = 1

end

--重置发牌数据
function PlayCardScene:resetDeal()
    USER_INFO["cards"] = nil
    local c  = Card.new()

    require("ddz.ddzSettings"):addGame()

    dump(temp_cards, "resetDeal temp_cards", nesting)
    for i,v in ipairs(temp_cards) do
        local card = Card:Decode(v)
        Card:Encode(card)
        c:init(card)
        local key =  Card:addCard(c)
    end
    dump(USER_INFO["cards"], "resetDeal cards", nesting)
    Card:sortCard()
end

--玩家叫分
function PlayCardScene:onNetBet(pack)
    local delay = 0
    if isDealAllCards==false and tonumber(UID) == tonumber(pack["nCurAnte"]) then
        delay = 2
    else
        delay = 0
    end

    dump(pack,"pack+++++++++++++++++++++++++++")

    self:performWithDelay(function()
        local preUid = tonumber(pack["PreScoreUserId"])
        local preBet = pack["PreScore"]
        local curUid  = tonumber(pack["nCurAnte"])
        local seat = USERID2SEAT[curUid]
        print("seat uid:"..preUid)
        print("seat current uid:"..curUid)
        print("USER_INFO uid:", tostring(UID))
        self:sendBaseCard()
        
        --设置倍数
        -- iTotalTimes = pack["PreScore"] or 0
        -- if iTotalTimes == 0 then iTotalTimes = 1 end
        local betScore = pack["PreScore"]

        self:setBaseTime(betScore,1)

        iGameState = 2
        --叫地主返回
        if preUid ~= 0 then
            self:stopPlayerClock(preUid)
            if tonumber(preUid) == tonumber(UID) then
               self:clearJiao()
            end
            --叫地主效果
            seat = USERID2SEAT[preUid]
            local tmp,index = require("ddz.ddzSettings"):getDOS(seat)

            local sex2seat = 1
            if seat == 0 then
                sex2seat = seat0sex
            elseif seat == 1 then
                sex2seat = seat1sex
            else
                sex2seat = seat2sex
            end
            if betScore == 0 then
                self:nojiao(index,sex2seat)
            else
                if call_bet_first == 0 then
                    self:jiao(betScore,index)
                    call_bet_first = 1
                else
                    if betScore > iTotalTimes then
                        self:qiang(index,sex2seat)
                    else
                        self:noqiang(index,sex2seat)
                    end
                end
            end
            -- if betScore == 0 then
            --     self:nojiao(index,sex2seat)
            -- elseif betScore == 1 then--叫地主
            --     if betScore > iTotalTimes then
            --         self:jiao(betScore,index)
            --     else
            --         self:noqiang(index,sex2seat)
            --     end
            -- elseif betScore > 1 then
            --     if betScore > iTotalTimes then
            --         self:qiang(index,sex2seat)
            --     else
            --         self:noqiang(index,sex2seat)
            --     end
            -- end
            iTotalTimes = betScore
        end

        if curUid ~= 0 then
            if curUid == tonumber(UID) then
                if bOnDeal == false then
                    self:clockAnimation(0)
                    -- self:setJiaoPanel(preUid)
                    self:setJiaoPanel(betScore)
                else
                    iGameState = 21
                end
            else
                seat = USERID2SEAT[curUid]
                local tmp,index = require("ddz.ddzSettings"):getDOS(seat)
                self:clockAnimation(index)
            end
        else
            iGameState = 3
        end
    end, delay)
end

--开始打牌
function PlayCardScene:onNetPlayGame(pack)
    print("start play cards ------ 开始打牌")
    local c  = Card.new()
    local inset_table = {}
    local table_value = {}
    local out_uid = tonumber(pack["nOutCardUserId"])
    loadSeat = USERID2SEAT[out_uid]
    --设置玩家是地主还是农民
    if out_uid == tonumber(UID) then
        --地主
        tbResult["type"] = 1
    else
        --农民
        tbResult["type"] = 0
    end

    --重置记牌器
    -- require("ddz.calcCards"):setGameState(1)
   
    for i,v in ipairs(pack["Cardbuf"])  do
        local card = Card:Decode(v)
        c:init(card)
        if loadSeat == USER_INFO["seat"] then
            local key =  Card:addCard(c)
            print("point.."..c._value)
            print("kind.."..c._kind)
            table.insert(inset_table,key)
        end

        table.insert(table_value,{c._value,c._kind})
    end

    if loadSeat == USER_INFO["seat"] then
        Card:sortCard()
        self:cardClear()
        self:setCard(1)
        self:cardRotation(table_value)
        self:lordInsetBaseCard(inset_table)
        self:showFourButton(0,1,1,0)
        self:setRestCardNum(0,20)
        self:setRestCardNum(1,17)
        self:setRestCardNum(2,17)
        -- iLiftTime = 20
        bPlayCard = 1
    else
        local tmp,index = require("ddz.ddzSettings"):getDOS(loadSeat)
        self:setRestCardNum(index,20)
        self:setRestCardNum(0,17)
        if index==1 then
            self:setRestCardNum(2,17)
        else
            self:setRestCardNum(1,17)
        end
        Card:sortCard()
        self:cardRotation(table_value)
        bPlayCard = 0
    end

    self:clearAllUserDesk()
    self:setHat(loadSeat,1)
    for i = 0, 2 do
        if i ~= loadSeat then
            self:setHat(i,0)
        end
    end
    local tmp2,index = require("ddz.ddzSettings"):getDOS(loadSeat)
    if loadSeat == USER_INFO["seat"] then
        self:clockAnimation(index,iLiftTime)
    else
        self:clockAnimation(index)
    end

    local base_score = self._scene:getChildByName("base_score")
    if base_score then
        base_score:setVisible(false)
    end

end

--玩家出牌
function PlayCardScene:onNetPlayCard(pack)
    print("玩家出牌")
    local uid_pre_out = tonumber(pack["nPreOutUserId"])
    local next_uid = tonumber(pack["nNextOutUserId"])
    self.layout_ui:setTouchEnabled(false)
    local seat        = USERID2SEAT[uid_pre_out]--当前出牌的座位
    local rest        = 17--当前出牌玩家剩余牌数
    local sex
    if seat==0 then
        sex = seat0sex+1
    elseif seat==1 then
        sex = seat1sex+1
    elseif seat==2 then
        sex = seat2sex+1
    end
    local card_type   = pack["Cardtype"]--出牌类型
    --三带一类型，判断是否为飞机
    if card_type == 7 then
        if pack["Cardcount"] >= 8 then
            card_type = 13
        end
    end
    --三带对类型时，判断是否为飞机
    if card_type == 8 then
        if pack["Cardcount"] >= 10 then
            card_type = 14
        end
    end

    --设置倍数
    if card_type >= 11 and card_type < 13 then
        --设置倍数
        iTotalTimes = iTotalTimes*2
        self:setBaseTime(iTotalTimes)
    end
    self:setBaseTime(pack["bet_chips"])

    local tmp,index = require("ddz.ddzSettings"):getDOS(seat)
    rest = REMAINCARDS[index] - pack["Cardcount"]

    local c_table = {}
    local c  = Card.new()
    for i,v in ipairs(pack["Cardbuf"]) do
        local card = Card:Decode(v)
        c:init(card)
        table.insert(c_table,{c._value,c._kind})
        -- require("ddz.calcCards"):subCard(c._value)
    end
    -- require("ddz.calcCards"):updateCards(true)

    if seat == USER_INFO["seat"] then
        self.layout_ui:setTouchEnabled(false)
        self:cleanupPlayCardBtn()
        self:clearUserDesk(index)
        local tm_table = self:showOtherCardRank(c_table)
        self:showOtherCard(tm_table,0,seat)
        self:reduceCard(c_table)
    else
        self:clearUserDesk(index)
        local tm_table = self:showOtherCardRank(c_table)
        self:showOtherCard(tm_table,index,seat)
        self:setRestCardNum(index,rest)
    end
    self:playCardsMusic(c_table,card_type,index)

    --玩家出完牌
    if next_uid == 0 then
        finishGameUid = uid_pre_out
        print("玩家[%d]出完牌", tostring(uid_pre_out))
        return
    end

    --给玩家出牌表赋值
    tbPlayCardInfo["last_cards"] = c_table
    tbPlayCardInfo["card_type"]  = card_type
    print("play cards")
    print_lua_table(tbPlayCardInfo["last_cards"])

    local nseat = USERID2SEAT[next_uid]--下家出牌的位置
    if nseat == nil then
        print("ddddddddddddddddddddddddddddddddd")
        print_lua_table(USERID2SEAT)
    end
    local tmp2,index2 = require("ddz.ddzSettings"):getDOS(nseat)
    if nseat == USER_INFO["seat"] then
        if bAuto then
            self:autoAction()
            return
        end
        --如果上家出火箭，自动过牌
        if card_type == 12 then
            require("ddz.ddzServer"):CLI_PASS()
            return
        end

        self:cleanupPlayCardBtn()       
        --到自己出牌时，检查手上是否有牌出
        self._hasselect = {}
        local tt,main_card = CardAnalysis:getSuitCard(tbPlayCardInfo["card_type"],tbPlayCardInfo["last_cards"],self._hasselect)
        self:showFourButton(1,0,1,0)
        --有牌出
        if tt then
            self:chuIfLight()
            self:checkLastCard()
            print("onNetPlayCard getSuitCard cards--------------->")
            print_lua_table(tt)
        else
            self:showNot2Play()
            -- print("hand cards--------------->")
            -- print_lua_table(USER_INFO.cards)
            --自动过
            -- require("ddz.ddzServer"):CLI_PASS()

        end
        self._hasselect = {}
        self._getSuit = 0
        bPlayCard = 1
    else
        bPlayCard = 0
    end

    self:clearUserDesk(index2)
    self:clockAnimation(index2)

    -- local fuck_err = nil
    -- print(fuck_err/2)
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
    local pass_uid = tonumber(pack["nPassUserId"])
    local next_uid = tonumber(pack["nNextOutUserId"])
    local seat = USERID2SEAT[pass_uid]
    local nseat = USERID2SEAT[next_uid]
    local a,index = require("ddz.ddzSettings"):getDOS(USERID2SEAT[pass_uid])--应该是seatid吧？
    local b,index2 = require("ddz.ddzSettings"):getDOS(USERID2SEAT[next_uid])--同上

    if pack["nIsNewTurn"] > 0 then
        bFirst = true
    else
        bFirst = false
    end

    if USERID2SEAT[next_uid] == USER_INFO["seat"] then
        if bAuto then
            self:autoAction()
        else
            self:cleanupPlayCardBtn()
            self:clearUserDesk(index2)
            if bFirst then
                self:showFourButton(0,0,1,0)
                tbPlayCardInfo["last_cards"] = nil
                tbPlayCardInfo["card_type"]  = nil
            else
                --到自己出牌时，检查手上是否有牌出
                self._hasselect = {}
                local tt,main_card = CardAnalysis:getSuitCard(tbPlayCardInfo["card_type"],tbPlayCardInfo["last_cards"],self._hasselect)
                self:showFourButton(1,0,1,0)
                --有牌出
                if tt then

                else                   
                    self:showNot2Play()
                    --如果上家出火箭，自动过牌
                    if tbPlayCardInfo["card_type"] == 12 then
                        require("ddz.ddzServer"):CLI_PASS()
                        return
                    end
                    -- require("ddz.ddzServer"):CLI_PASS()
                end
            end
            bPlayCard = 1
        end
    else
        bPlayCard = 0
    end

    self:clearUserDesk(index)
    self:clearUserDesk(index2)
    self:noyao(index)
    self:clockAnimation(index2)

    if USERID2SEAT[pass_uid] == USER_INFO["seat"] then
        self.layout_ui:setTouchEnabled(false)
        self:cleanupPlayCardBtn()
        self:cleanCards()
    end
    if USERID2SEAT[next_uid] == USER_INFO["seat"] then
        --设置可以选牌
        self:chuIfLight()
        --是否自动出牌
        self:checkLastCard()
    end
end

--牌局结束
function PlayCardScene:onGameOver(pack)
    print("牌局结束 uid:", tostring(UID))
    print("金币:", USER_INFO["gold"])

    -- require("ddz.calcCards"):setCalcs(false)
    -- require("ddz.calcCards"):setGameState(0)

    self.layout_ui:getChildByName("baojing1"):setVisible(false)
    self.layout_ui:getChildByName("baojing2"):setVisible(false)

    bGameOver = true
    iGameState = 4
    bPlayCard = 0
    local table_r = {}
    table_r["base"] = pack["Basechip"]
    table_r["multiple"] = pack["Totoltimes"]
    table_r["win"] = pack["winnerType"]-1--0是地主赢，1是农民赢
    table_r["lord_seat"] = loadSeat
    table_r["nick_f_farm"] = 1
    table_r["seat_f_farm"] = 1
    table_r["nick_s_farm"] = 1
    table_r["seat_s_farm"] = 1
    table_r["lord_nick"] = 1

    --结算托管状态
    self:showAuto(false)
    iActionCounts = 0
    --计算台费
    local totalLost = 0  --台面总输
    local totalWin = 0  --台面总赢
    local winCounts = 0
    for i, v in ipairs(pack["playerList"]) do
        local uid = tonumber(v["Uid"])
        if v["Turningscore"] > 0 then
            table_r["win_cost"] = v["Turningscore"]
            totalWin = totalWin + v["Turningscore"]
        else
            table_r["lost_cost"] = v["Turningscore"]
            totalLost = totalLost + v["Turningscore"]
        end
        if uid == tonumber(UID) then
            tbResult["basechip"] = pack["Basechip"]
            if loadSeat == USER_INFO["seat"] then
                tbResult["times"] = pack["Totoltimes"]*2
            else
                tbResult["times"] = pack["Totoltimes"]
            end
            tbResult["win"] = v["Turningscore"]
            local mode = require("hall.gameSettings"):getGameMode()
            if mode == "free" or mode == "fast" then
                require("hall.GoldRecord.GoldRecord"):writeData(USER_INFO["gold"]+tbResult["win"], tbResult["win"])
            end
   
            USER_INFO["kick_off"] = v["Kickoff"]
        end
        local dos,index = require("ddz.ddzSettings"):getDOS(USERID2SEAT[uid])
        tbWin[dos] = v["Turningscore"]
        if v["Turningscore"] > 0 then
            winCounts = winCounts + 1
        end
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
            self:showOtherCard(c_table,index,USERID2SEAT[uid],15)
        end
    end

    local cost = 0

    local mode = require("hall.gameSettings"):getGameMode()
    --把台费加回去
    for i, v in ipairs(pack["playerList"]) do
        local uid = tonumber(v["Uid"])
        local dos,index = require("ddz.ddzSettings"):getDOS(USERID2SEAT[uid])
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
                if mode == "match" then
                    self:setMatchPoint(gold)
                else
                    self:displayMine(gold)
                end
            end
        end
    end

    --播放春天动画
    if pack["Sprint"] > 1 then
        --春天动画
        -- self:animSpring()
        require("ddz.Animation"):animSpring(self.layout_effect)
        --设置倍数
        -- iTotalTimes = iTotalTimes*pack["Sprint"]
        -- self:setBaseTime(iTotalTimes)
    end
    self:setBaseTime(pack["Totoltimes"]*pack["Basechip"])


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

    spAction:runAction(cc.Sequence:create(cc.DelayTime:create(2),cc.CallFunc:create(function() self:drawCoin() end),cc.CallFunc:create(function() spAction:removeSelf() end)))
    -- self:drawCoin()

    iGameCount = iGameCount + 1
    tbPlayCardInfo["last_cards"] = nil
    tbPlayCardInfo["card_type"]  = nil
    --增加游戏次数
    if mode ~= "group" then
        if USER_INFO["match_fee"] > 0 then
            --比赛次数
            -- require("hall.GameData"):addMatchGame()
            -- print("[------------------------------------match game time------------------------------------]%d",require("hall.GameData"):getMatchGameCount())
        else
            --自由场次数
            require("hall.GameData"):addFreeGame()
            print("[------------------------------------free game time------------------------------------]%d",require("hall.GameData"):getFreeGameCount())
        end
    end
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
    ddzServer:CLI_REQUEST_CALC_HISTORY()

    print("onNetReload")

    self:setGameMode()

    require("ddz.ddzSettings"):addGame()

    bm.Room = {}
    bm.Room.UserInfo = {}
    if bm.Room == nil then
        bm.Room = {}
    end
    bm.Room.start_group = 1

    USER_INFO["gameLevel"] = pack["Gamelevel"]

    --设置玩家座位
    local my_seat = tonumber(pack["Seated"])
    USER_INFO["seat"] = my_seat
    USERID2SEAT[tonumber(UID)] = my_seat
    SEAT2USERID[my_seat] = tonumber(UID)
    tbSeatCoin[my_seat] = USER_INFO["gold"]
    self:displayMyselfInfo(1)
    print("player seatid:", tostring(USERID2SEAT[tonumber(UID)]))

    --设置玩家状态
    if pack["Readystart"] > 0 then
        self:ready()
    end

    --设置底分
    self:setBaseChip(pack["Basechip"])

    local xFlag = 1
    if pack["Gamestatus"] == 1 then
        iTotalTimes = pack["Landscore"]
        xFlag = 1
    else
        iTotalTimes = pack["LandlordScore"]
        xFlag = 0
    end

    self:setBaseTime(iTotalTimes, xFlag)


    
    --加入语音广播列表
    local tb_user_data = {}
    tb_user_data["seat"] = USER_INFO["seat"]
    tb_user_data["gold"] = USER_INFO["gold"]
    tb_user_data["uid"]  = tonumber(UID)
    tb_user_data["nick"] = USER_INFO["nick"]
    tb_user_data["sex"]  = USER_INFO["sex"]
    tb_user_data["icon"] = USER_INFO["icon_url"]
    bm.Room.UserInfo[tonumber(UID)] = tb_user_data

    --设置其他玩家状态
    for i, v in ipairs(pack["playerlist"]) do
        local uid = tonumber(v["Uid"])
        local table_info = {}
        table_info["uid"] = uid
        table_info["seat"] = v["Seatid"]
        USERID2SEAT[uid] = v["Seatid"]         
        table_info["ready"] = v["ReadyStart"]
        local userinfo = json.decode(v["UserInfo"])
        if userinfo then
            dump(userinfo,"reload play"..tostring(uid))
            table_info["gold"] = userinfo["money"]
            table_info["nick"] = userinfo["nickName"]
            table_info["sex"] = userinfo["sex"]
            table_info["icon"] = userinfo["photoUrl"]
            table_info["isVip"] = userinfo["isVip"]
        else
            table_info["gold"] = 0
            table_info["nick"] = tostring(uid)
        end
        table_info["gold"] = v["gold"]

        tbSeatCoin[table_info["seat"]] = table_info["gold"]
        self:drawOther({table_info});
        print("other player %d seatid:%d",i,USERID2SEAT[uid])
        local tmp,index = require("ddz.ddzSettings"):getDOS(table_info["seat"])
        self:setRestCardNum(index,v["HandCardCount"])

        bm.Room.UserInfo[uid] = table_info
    end

    dump(bm.Room.UserInfo, "-----斗地主房间其他用户-----")
    
    dump(tbSeatCoin, "tbSeatCoin")
    print_lua_table(tbSeatCoin)
    
    REMAINCARDS[0] = pack["Handcardcount"]

    --牌局状态
    self:sendBaseCard()

    if pack["Gamestatus"] ==1 then
        --叫地主阶段
        local curUid  = tonumber(pack["Curlandlordscore"])
        local seat = USERID2SEAT[curUid]
        print("seat current uid:"..curUid)
        --叫地主返回
        if curUid > 0 then
            if(curUid == tonumber(UID)) then
                self:clockAnimation(0)
                self:setJiaoPanel(pack["Landscore"])
                if pack["Landscore"] > 0 then
                    call_bet_first = 1
                end
            else
                local tmp,index = require("ddz.ddzSettings"):getDOS(seat)
                self:clockAnimation(index,pack["Lefttime"])
            end
        end
    else
        --打牌阶段
        --三张地主牌
        -- require("ddz.calcCards"):setGameState(1)
        local c  = Card.new()
        local table_value = {}
        local land_uid = tonumber(pack["LandlordUserId"])
        local out_card_uid = tonumber(pack["OutCardUserId"])
        loadSeat = USERID2SEAT[land_uid]
        self:setHat(loadSeat,1)
        for i = 0, 2 do
            if i ~= loadSeat then
                self:setHat(i,0)
            end
        end
        if land_uid == tonumber(UID) then
            --地主
            tbResult["type"] = 1
        else
            --农民
            tbResult["type"] = 0
        end

        for i,v in ipairs(pack["LandCarddata"])  do
            local card = Card:Decode(v)
            Card:Encode(card)
            c:init(card)
            table.insert(table_value,{c._value,c._kind})
        end

        -- local base_score = self._scene:getChildByName("base_score")
        -- if base_score then
        --     base_score:setVisible(false)
        -- end
        self:cardRotation(table_value)
        --设置出牌的玩家
        local tmp2,index_out = require("ddz.ddzSettings"):getDOS(USERID2SEAT[out_card_uid])

        for i,v in pairs(pack["LastCarddata"]) do
            if v["CardCount"]~=0 then
                local c_table = {}
                local c  = Card.new()
                for i,v in ipairs(v["cards"])  do
                    local card = Card:Decode(v)
                    c:init(card)
                    table.insert(c_table,{c._value,c._kind})
                end
                local seat = i-1
                local dos,index = require("ddz.ddzSettings"):getDOS(seat)
                if index ~= index_out then
                    self:clearUserDesk(seat)
                    local tm_table = self:showOtherCardRank(c_table)

                    local spdelay = display.newSprite():addTo(self)
                    print("cc.CallFunc:create",tostring(i))
                    spdelay:runAction(cc.Sequence:create(cc.DelayTime:create(0.1*i),cc.CallFunc:create(function() self:showOtherCard(tm_table,index,seat) end),cc.CallFunc:create(function() spdelay:removeSelf() end)))

                    -- self:showOtherCard(tm_table,index,seat)
                    --给玩家出牌表赋值
                    if #c_table > 0 then
                        tbPlayCardInfo["last_cards"] = c_table
                        tbPlayCardInfo["card_type"]  = CardAnalysis:getType(c_table)
                        --自己
                        if seat == USER_INFO["seat"] then
                            tbPlayCardInfo["last_cards"] = nil
                            tbPlayCardInfo["card_type"] = nil
                        end
                    end
                end
            end
        end

        print("onNetReload clock pos:",tostring(index),"uid:",tostring(out_card_uid),USERID2SEAT[out_card_uid])

        local spdelay = display.newSprite():addTo(self)
        spdelay:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),cc.CallFunc:create(function() self:clockAnimation(index_out,pack["LeftTime"]) end),cc.CallFunc:create(function() spdelay:removeSelf() end)))

        local nseat = USERID2SEAT[out_card_uid]--下家出牌的位置
        local tmp2,index2 = require("ddz.ddzSettings"):getDOS(nseat)
        if nseat == USER_INFO["seat"] then
            self:cleanupPlayCardBtn()
            self:clearUserDesk(index2)
            --到自己出牌时，检查手上是否有牌出
            self:showFourButton(1,0,1,0)
            self.layout_ui:setTouchEnabled(false)
            self.layout_effect:setTouchEnabled(false)                  
        end
    end

    --玩家剩余牌数
    self:clearCards()
    USER_INFO["cards"] = nil
    temp_cards = {}
    local c  = Card.new()

    for i,v in ipairs(pack["Carddata"])  do
        table.insert(temp_cards,v)
        local card = Card:Decode(v)
        Card:Encode(card)
        c:init(card)
        local key =  Card:addCard(c)
    end
    dump(USER_INFO["cards"], "onNetReload cards")

    dt_send_card = 0.01
    Card:sortCard()
    self:start()


    if require("hall.gameSettings"):getGameMode() == "group" then
        self:getChips()
    end

    --记录房间用户信息
    bm.USERID2SEAT = USERID2SEAT;

    -- --隐藏解散房间按钮
    local btn_release_group = self._scene:getChildByName("btn_release_group")
    btn_release_group:setVisible(false)

    --隐藏邀请好友按钮
    local invite_ly = self._scene:getChildByName("invite_ly")
    invite_ly:setVisible(false)

    --显示视频录制按钮
    local btn_record = self._scene:getChildByName("btn_record")
    btn_record:setVisible(true)

    --添加视频引导
    require("hall.leader.LeaderLayer"):showLeaderLayer(cc.p(335.61, 505.51))

    local uid_arr = {}
    if bm.Room ~= nil then
        if bm.Room.UserInfo ~= nil then
            for k,v in pairs(bm.Room.UserInfo) do
                if v then
                    table.insert(uid_arr, k)
                end
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
    require("ddz.MatchSetting"):setRankInfo(require("ddz.ddzSettings"):getMatchLevelRankInfo(USER_INFO["gameLevel"]))
    if isMatchWait == 1 then
        require("ddz.MatchSetting"):showMatchWait(true,"ddz")
    end
end
--发送用户重连回比赛开赛后的等待界面
function PlayCardScene:SVR_MATCH_WAIT(pack)
    -- body
    self:displayMine()
    self:setMatchPoint(pack["Matchpoint"])
    require("ddz.DDZHttpNet"):MatchloadBattles(1)
    isMatchWait = 1
    require("hall.gameSettings"):setGameMode("match")
    USER_INFO["match_fee"] = 100
end
--获取房间讯息
function PlayCardScene:SVR_ROOM_INFO(pack)
    -- body
    if isMatchWait == 1 then
        USER_INFO["gameLevel"] = pack["level"]
    end
end
--比赛重连
function PlayCardScene:SVR_MATCH_RELOAD(pack)
    isReload = true
    ddzServer:CLI_REQUEST_CALC_HISTORY()
    require("hall.gameSettings"):setGameMode("match")
    self:setGameMode()
    isMatchWait = 0
    local btn_recharge = self._scene:getChildByName("touxiangbufen_0"):getChildByName("numBg_16")
    if btn_recharge then
        btn_recharge:setEnabled(false)
    end
    --请求比赛轮次列表
    USER_INFO["gameLevel"] = pack["level"]
    require("ddz.ddzSettings"):setMatchLevel(pack["level"])
    require("ddz.DDZHttpNet"):MatchloadBattles(1)
    USER_INFO["match_fee"] = 100
    require("hall.GameData"):enterMatch(1)
    require("ddz.MatchSetting"):offLayers()
    require("ddz.MatchSetting"):setCurrentRound(pack["curRound"],pack["sheaves"])
    --设置玩家座位
    USER_INFO["seat"] = pack["seatid"]
    USERID2SEAT[tonumber(UID)] = pack["seatid"] 
    print("player seatid:%d", tostring(USERID2SEAT[tonumber(UID)]))

    self:setMatchPoint(pack["Matchpoint"])
    self:displayMine()
    USER_INFO["enter_mode"] = 1
    --设置玩家状态
    if pack["ready_start"] > 0 then
        self:ready()
    end
    --设置底分
    self:setBaseChip(pack["Basechip"])
   
    local show_x = 1
    if pack["Gamestatus"] == 1 then 
        iTotalTimes = pack["Landscore"]
        show_x = 1
    else
        iTotalTimes = pack["LandlordScore"]
        show_x = 0
    end
    self:setBaseTime(iTotalTimes,show_x)

    --设置其他玩家状态
    for i, v in ipairs(pack["playerList"]) do
        local uid = tonumber(v["Userid"])
        local table_info = {}
        table_info["uid"] = uid
        table_info["seat"] = v["seatid"]
        USERID2SEAT[uid] = v["seatid"]         
        table_info["ready"] = v["ready_start"]
        table_info["gold"] = v["Matchpoint"]
        local userinfo = json.decode(v["Userinfo"])
        if userinfo then
            print_lua_table(userinfo)
            table_info["nick"] = userinfo["nickName"]
            table_info["sex"] = userinfo["sex"]
            table_info["icon"] = userinfo["photoUrl"]
            table_info["isVip"] = userinfo["isVip"]
        else
            table_info["gold"] = 0
            table_info["nick"] = tostring(uid)
        end

        tbSeatCoin[table_info["seat"]] = table_info["gold"]
        self:drawOther({table_info});
        print("other player %d seatid:%d",i,USERID2SEAT[uid])
        self:setRestCardNum(table_info["seat"],v["HandCardCount"])
    end
    
    REMAINCARDS[USER_INFO["seat"]] = pack["Handcardcount"]
    --牌局状态
    self:sendBaseCard()
    if pack["Gamestatus"] ==1 then--叫地主阶段
        local curUid  = tonumber(pack["Curlandlordscore"])
        local seat = USERID2SEAT[curUid]
        print("seat current uid:"..curUid)
        --叫地主返回
        if curUid > 0 then
            if(curUid == tonumber(UID)) then
                self:clockAnimation(0)
                self:setJiaoPanel()
            else
                local tmp,index = require("ddz.ddzSettings"):getDOS(seat)
                self:clockAnimation(index,pack["Lefttime"])
            end
        end
    else--打牌阶段
        --三张地主牌
        -- require("ddz.calcCards"):setGameState(1)
        local c  = Card.new()
        local table_value = {}
        local land_uid = tonumber(pack["LandlordUserId"])
        local out_card_uid = tonumber(pack["OutCardUserId"])
        loadSeat = USERID2SEAT[land_uid]
        self:setHat(loadSeat,1)
        for i = 0, 2 do
            if i ~= loadSeat then
                self:setHat(i,0)
            end
        end
        if land_uid == tonumber(UID) then
            --地主
            tbResult["type"] = 1
        else
            --农民
            tbResult["type"] = 0
        end
        for i,v in ipairs(pack["LandCarddata"])  do
            local card = Card:Decode(v)
            Card:Encode(card)
            c:init(card)
            table.insert(table_value,{c._value,c._kind})
        end

        self:cardRotation(table_value)
        --设置出牌的玩家
        local tmp2,index = require("ddz.ddzSettings"):getDOS(USERID2SEAT[land_uid])     
        self:clockAnimation(index,pack["LeftTime"])

        for i,v in pairs(pack["LastCarddata"]) do
            if v["CardCount"]~=0 then
                local c_table = {}
                local c  = Card.new()
                for i,v in ipairs(v["cards"])  do
                    local card = Card:Decode(v)
                    c:init(card)
                    table.insert(c_table,{c._value,c._kind})
                end
                local seat = i-1
                local dos,index = require("ddz.ddzSettings"):getDOS(seat)
                self:clearUserDesk(seat)
                local tm_table = self:showOtherCardRank(c_table)
                self:showOtherCard(tm_table,index,seat)
                --给玩家出牌表赋值
                if #c_table > 0 then
                    tbPlayCardInfo["last_cards"] = c_table
                    tbPlayCardInfo["card_type"]  = CardAnalysis:getType(c_table)
                    --自己
                    if seat == USER_INFO["seat"] then
                        tbPlayCardInfo["last_cards"] = nil
                        tbPlayCardInfo["card_type"] = nil
                    end
                end
            end
        end

        local nseat = USERID2SEAT[out_card_uid]--下家出牌的位置
        local tmp2,index2 = require("ddz.ddzSettings"):getDOS(nseat)
        if nseat == USER_INFO["seat"] then
            self:cleanupPlayCardBtn()
            self:clearUserDesk(index2)
            --到自己出牌时，检查手上是否有牌出
            self:showFourButton(1,0,1,0)
            self.layout_ui:setTouchEnabled(false)
            self.layout_effect:setTouchEnabled(false)                  
        end
    end

    --玩家剩余牌数
    self:clearCards()
    USER_INFO["cards"] = nil
    local c  = Card.new()
    for i,v in ipairs(pack["Carddata"])  do
        local card = Card:Decode(v)
        Card:Encode(card)
        c:init(card)
        local key =  Card:addCard(c)
        print("point.."..c._value)
        print("kind.."..c._kind)
    end

    dt_send_card = 0.01
    Card:sortCard()
    self:start()

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

    require("ddz.ddzSettings"):setGroupState(1)
    tbPlayCardInfo["last_cards"] = nil
    tbPlayCardInfo["card_type"]  = nil
    print("state_player---------------------",state_player)
    if bGameOver == false then
        --停止直播
        require("ddz.PlayVideo"):stopVideo()
        print(" PlayCardScene:onNetBillboard()++++++++++++++++++++++++")
        require("ddz.ddzSettings"):setGroupState(0)
        require("ddz.ddzSettings"):showGroupResult(groupRanking)
        cc.SimpleAudioEngine:getInstance():stopAllEffects()
        cc.SimpleAudioEngine:getInstance():stopMusic()
        audio.stopMusic(false)

        -- require("ddz.ddzServer"):CLI_LOGOUT_ROOM()
    end
end
----------------------------------------------------------------
------------------------ 比赛西哦先返回 ------------------------
----------------------------------------------------------------
--比赛开始
function PlayCardScene:onNetMatchStart(pack)
    self:endGame()
    bMatchStatus = 1
    bShowAddCoin = false
    local cut = pack["Seatid"] - 0
    if pack["Seatid"]~=0 then
        pack["Seatid"]=0
    end
    
    -- USER_INFO["match_gold"] = pack["Matchpoint"]
    USER_INFO["match_fee"] = USER_INFO["match_fee"] or 100
    self:setMatchPoint(pack["Matchpoint"])
    self:displayMyselfInfo()
    -- self:displayMine()
    USER_INFO["seat"] = pack["Seatid"]
    USERID2SEAT[tonumber(UID)] = pack["Seatid"] 
    print("player seatid:%d",USERID2SEAT[tonumber(UID)])
    require("ddz.ddzSettings"):setMatchLevel(pack["Level"])

    require("ddz.MatchSetting"):setCurrentRound(pack["Round"],pack["Sheaves"])
    self:ready()
    --设置底分
    self:setBaseChip(pack["Basechip"])

    for i, v in ipairs(pack["playerList"]) do
        local uid = tonumber(v["Userid"])
        local table_info = {}
        if cut==2 then
            v["Seated"] = v["Seated"] + 1
        elseif cut==1 then
            v["Seated"] = v["Seated"] -1
            if v["Seated"]<0 then
                v["Seated"] = 2
            end
        end        
        table_info["seat"] = v["Seated"] 
        table_info["ready"] = 1
        table_info["gold"] = v["Matchpoint"]
        tbSeatCoin[table_info["seat"]] = table_info["gold"]
        local userinfo = json.decode(v["Userinfo"])
        if userinfo then
            table_info["nick"] = userinfo["nickName"]
            table_info["sex"]  = tonumber(userinfo["sex"])
            table_info["icon"] = userinfo["photoUrl"]
            table_info["isVip"] = userinfo["isVip"]
        else
            table_info["nick"] = tostring(v["Userid"])
            table_info["sex"]  = 1
        end
        table_info["uid"]  = uid
        self:drawOther({table_info});
        USERID2SEAT[uid] = v["Seated"]
        print("other player %d seatid:%d",i,USERID2SEAT[uid])
        self:setOtherReady(table_info["seat"])
    end

    if self:getChildByName("match_win") then
        self:removeChildByName("match_win")
    end
    if self:getChildByName("match_lose") then
        self:removeChildByName("match_lose")
    end
    if self:getChildByName("match_wait") then
        self:removeChildByName("match_wait")
    end
    if self:getChildByName("match_result") then
        self:removeChildByName("match_result")
    end
end

--每轮打完之后 会给玩家发送比赛状态信息
function PlayCardScene:onNetMatchGameOver(pack)
    bFakeLogout = true
    bGameOver = true
    if pack then
        local status = pack["Status"]
        require("ddz.ddzSettings"):setMatchLevel(pack["Level"])
        if pack["Tablecount"]>0 then
            require("ddz.MatchSetting"):showMatchWait(true,"ddz")
        else
            if status==0 then --晋级
                bMatchStatus = 3
                if USER_INFO["match_rank"] == nil then
                    USER_INFO["match_rank"] = 0
                end
                if USER_INFO["match_rank"] == 0 then
                    USER_INFO["match_rank"] = pack["Maxnumber"]
                end
                -- self:showMatchWin(pack["Rank"],USER_INFO["match_rank"],currentRound)
                if pack["Tablecount"] == 0 then
                    require("ddz.MatchSetting"):showMatchWin(pack["Rank"],USER_INFO["match_rank"],require("ddz.MatchSetting"):getCurrentRank(),"ddz")
                end
            elseif status==1 then --淘汰后显示结果
                require("ddz.MatchSetting"):setMatchResult(pack["Rank"],pack["Maxnumber"],pack["Strtime"],"ddz",require("ddz.MatchSetting"):getIncentive(pack["Level"],pack["Rank"]))
                require("ddz.MatchSetting"):showMatchLose(pack["Rank"],pack["Maxnumber"],require("ddz.MatchSetting"):getCurrentRank(),"ddz")
                bMatchStatus = 2
                local sp = display.newSprite():addTo(self)
                sp:performWithDelay(function()
                    require("ddz.MatchSetting"):showMatchResult()
                end,5)
            elseif status==2 then --赢了显示结果
                bMatchStatus = 2
                require("ddz.MatchSetting"):setMatchResult(pack["Rank"],pack["Maxnumber"],pack["Strtime"],"ddz",require("ddz.MatchSetting"):getIncentive(pack["Level"],pack["Rank"]))
            end
        end
    end
end

function PlayCardScene:onNetMatchRank(pack)
end

--请求兑换筹码返回
function PlayCardScene:onNetChangeChip(pack)
    local uid = tonumber(pack["uid"])
    if uid == tonumber(UID) then
        USER_INFO["chips"] = pack["chip"]
        USER_INFO["score"] = pack["money"]
        USER_INFO["gold"] = pack["money"]
        self:displayMine()

        -- if pack["ret"] > 0 then--成功
        --     if require("hall.common.GroupGame"):checkChips() then
        --         --发送准备消息
        --         require("ddz.ddzServer"):CLI_READY_GAME()
        --         --发送准备消息后，隐藏准备按钮
        --         self:ready()
        --     else
        --         require("hall.GameTips"):showTips("筹码不足，请兑换","change_chip",1)
        --     end
        -- else
        --     require("hall.GameTips"):showTips("兑换筹码失败，请兑换","change_chip",1)
        -- end

        --发送准备消息
        require("ddz.ddzServer"):CLI_READY_GAME()
        
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
    print("onNetGetChip state_player",tostring(state_player))
    if state_player < 2 then

        require("ddz.ddzServer"):CLI_READY_GAME()
        
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
function PlayCardScene:onNetGroupTime(pack)
    -- body
    local time = pack["time"]
    USER_INFO["group_lift_time"] = time
    -- bShowGroupTime = true
    USER_INFO["start_time"] = os.time()

    local layer_group_time = self._scene:getChildByName("layer_group_time")
    if layer_group_time then
        local txtTime = layer_group_time:getChildByName("txt_time")
        if txtTime then
            txtTime:setString(tostring(string.format("%02d",pack["round"]+1).."/"..tostring(string.format("%02d",pack["round_total"]))))
        end
    end

    local txt_game_no = self._scene:getChildByName("p_game_no"):getChildByName("txt_game_no")
    if txt_game_no then
        txt_game_no:setVisible(true)
        txt_game_no:setString(tostring(pack["round"]+1).."/"..tostring(pack["round_total"]))
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
        display_scene("ddz.SelectChip",1)
        bLogout = false
    end
end

--历史出牌
function PlayCardScene:SVR_CALC_HISTORY(pack)
    if pack then
        -- require("ddz.calcCards"):init()
        -- for i,v in ipairs(pack["cardList"]) do
        --     require("ddz.calcCards"):setHistory(v["cards"])
        -- end
        -- require("ddz.calcCards"):setGameState(1)
        -- require("ddz.calcCards"):updateCards(true)
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
            ddzServer:CLI_LOGOUT_ROOM()
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
    local dos,seat = require("ddz.ddzSettings"):getDOS(USERID2SEAT[uid])
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

function PlayCardScene:get_player_ip( uid )
    -- body
    local ip_ = require("ddz.ddzSettings"):getUserIP(uid)
    return ip_
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

return PlayCardScene
