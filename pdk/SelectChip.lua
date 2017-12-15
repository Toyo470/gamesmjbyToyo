
local HttpNet = require("pdk.pdkHttpNet")
local PROTOCOL = require("hall.HALL_SERVER_PROTOCOL")
local Market = require("hall.market")

local countBatllesX = 0
local countBtallesY = 0
local countBatllesPage = 1
local WIDTH_SCROLLVIEW = 835
local HEIGHT_SCROLLVIEW = 416

local pagesBattle = {}
local tbBattles = {}
local tbMatchFee = {}
local bMatchJoin = false
local nCurMatchID = 0

local SelectChip = class("SelectChip", function()
    return display.newScene("SelectChip")
end)

local PROTOCOL = require("pdk.pdk_PROTOCOL")

local pdkHandle  = require("pdk.pdkHandle")

function SelectChip:ctor()

    bm.server:setProtocol(PROTOCOL)
    bm.server:setHandle(pdkHandle.new())

    local s = cc.CSLoader:createNode("pdk/csb/BetSelect.csb"):addTo(self)
    self._scene = s

    local winSize = cc.Director:getInstance():getWinSize()

    --调出UI

    local layer_top = self._scene:getChildByName("layer_top")
    --head
    local head = layer_top:getChildByName("head")
    if head then
        local head_info = {}
        head_info["url"] = USER_INFO["icon_url"]
        head_info["uid"] = tonumber(UID)
        head_info["sex"] = USER_INFO["sex"]
        head_info["sp"] = head
        head_info["size"] = 70
        head_info["touchable"] = 1
        head_info["use_sharp"] = 1
        head_info["vip"] = USER_INFO["isVip"]
        require("hall.GameCommon"):getUserHead(head_info)
    end

    --button
    local btn_help = self._scene:getChildByName("btn_help")
    local btn_setting = layer_top:getChildByName("btn_setting")
    local btn_lobby = layer_top:getChildByName("btn_exit")
    local btn_recharge = layer_top:getChildByName("btn_recharge")
    local btn_firsh_recharge = layer_top:getChildByName("btn_firsh_recharge")
    local btn_fast_game = self._scene:getChildByName("btn_fast_game")
    if btn_fast_game then
        if require("hall.gameSettings"):getGameMode() == "match" then
            btn_fast_game:setVisible(false)
        else
            btn_fast_game:setVisible(true)
        end
    end

    --text
    local txt_nick = layer_top:getChildByName("txt_nick")
    txt_nick:enableShadow(cc.c4b(0,0,0,0.7),cc.size(0,-2),0)
    local txt_score = btn_recharge:getChildByName("txt_score")

    local strNick = require("hall.GameCommon"):formatNick(USER_INFO["nick"])
    txt_nick:setString(strNick)
    txt_score:setString(require("hall.GameCommon"):formatGold(USER_INFO["gold"]))

    local txt_diamond = layer_top:getChildByName("btn_diamond"):getChildByName("txt_diamond")
    if txt_diamond then
        txt_diamond:setString(require("hall.GameCommon"):formatGold(USER_INFO["diamond"]))
    end

    -- --新增UI

    local function touchButtonEvent(sender, event)
        --缩小ui
        if event == TOUCH_EVENT_BEGAN then
            require("hall.GameCommon"):playEffectSound("hall/Audio_Button_Click.mp3")
        end

        if event == TOUCH_EVENT_ENDED then

            if sender == btn_lobby then--返回赛场选择
                require("app.HallUpdate"):enterHall()
            end
    
            --设置
            if sender == btn_setting then
                require("hall.GameCommon"):showSettings(true)
            end

            --充值
            if sender == btn_recharge then
                if USER_INFO["isFirstCharged"] and USER_INFO["isFirstCharged"] == 1 then
                    local market = Market.new()
                    SCENENOW["scene"]:addChild(market)
                else
                    require("hall.fRecharge"):showOut()
                end
            end
            --首充
            if sender == btn_firsh_recharge then
                if USER_INFO["isFirstCharged"] and USER_INFO["isFirstCharged"] == 1 then
                    local market = Market.new()
                    SCENENOW["scene"]:addChild(market)
                else
                    require("hall.fRecharge"):showOut()
                end
            end
            --快速
            if sender == btn_fast_game then
                btn_fast_game:setColor(cc.c3b(125,125,125))
                btn_fast_game:setTouchEnabled(false)
                require("hall.GameTips"):showTips("正为您选择分场","fast_pdk",4)
                local FastStartGame = require("hall.fast_startgame")
                FastStartGame:init(USER_INFO["gold"],"pdk",1)
            end
            --帮助
            if sender == btn_help then
                local msg = 1 
                print("show help mode:",require("hall.gameSettings"):getGameMode())
                if require("hall.gameSettings"):getGameMode() == "free" then
                    msg = "1、玩家选择不同的底分，进场凑够3个人则开局；\n\n2、战败玩家失去底分*倍数，获胜玩家获得底分*倍数*80%，20%为系统服务费 \n \n \n \n"
                else
                    msg = "1、玩家选择不同的场次缴纳报名费，报名费越高奖励越丰厚；\n\n2、每个场次凑够系统指定人数则开局，参赛玩家随机分成若干组，每轮淘汰掉末尾的玩家；晋级的玩家重新分组进行下一轮，如此直到决出冠军；最后按照排名颁发奖励。"
                end
                require("hall.GameCommon"):showHelp(true,msg)
            end
        end
    end

    btn_help:addTouchEventListener(touchButtonEvent)--帮助
    btn_setting:addTouchEventListener(touchButtonEvent)--游戏设置
    btn_lobby:addTouchEventListener(touchButtonEvent)--退出大厅
    btn_recharge:addTouchEventListener(touchButtonEvent)--充值
    btn_firsh_recharge:addTouchEventListener(touchButtonEvent)--充值
    btn_fast_game:addTouchEventListener(touchButtonEvent)--充值


    local spLight = layer_top:getChildByName("effect_light")
    if spLight then
        local rt_back = cc.RotateBy:create(10,360)
        spLight:runAction(cc.RepeatForever:create(rt_back))
    end

    -- cct.showradioMessage(self,true);

end

function SelectChip:fastTipCallBack(code)
    local btn_fast_game = self._scene:getChildByName("btn_fast_game")
    if btn_fast_game then
        btn_fast_game:setColor(cc.c3b(255,255,255))
        btn_fast_game:setTouchEnabled(true)
    end
end
--绑定按钮声音
function SelectChip:addBtAudio(a,b,c,d,e)
    a:addTouchEventListener(function(event,type)
        if(type == 2) then
            require("hall.GameCommon"):playEffectSound("hall/Audio_Button_Click.mp3")
            b:setVisible(false)
            c:setVisible(true)
            c:setVisible(false)
            d:setVisible(true)
        end
    end)
end

--更新vip
function SelectChip:updateVIP()
    local layer_top = self._scene:getChildByName("layer_top")
    --head
    local head = layer_top:getChildByName("head")
    if head then
        local head_info = {}
        head_info["uid"] = tonumber(UID)
        head_info["sex"] = USER_INFO["sex"]
        head_info["url"] = USER_INFO["icon_url"]
        head_info["sp"] = head
        head_info["size"] = 70
        head_info["touchable"] = 1
        head_info["use_sharp"] = 1
        head_info["vip"] = USER_INFO["isVip"]
        require("hall.GameCommon"):getUserHead(head_info)
    end
end
--更新道具
function SelectChip:updateGoods(goods_type)
    self:updateVIP()
    self:updateScore()
end
function SelectChip:updateScore()
    -- body
    local btn_recharge = self._scene:getChildByName("layer_top"):getChildByName("btn_recharge")

    --text
    local txt_score = btn_recharge:getChildByName("txt_score")
    if txt_score then
        print("updateScore:"..USER_INFO["gold"])
        txt_score:setString(require("hall.GameCommon"):formatGold(USER_INFO["gold"]))
    end

end

--增加地方场
function SelectChip:addBattleField(index,chip,counts,level)

    local strFile = "pdk/BetSelect/classical_bt_"..tostring(index)..".png"

    local button = ccui.Button:create()
    button:setTouchEnabled(true)
    button:loadTextures(strFile, nil, nil)

    --房间名
    strFile = "pdk/BetSelect/classical_text_"..tostring(index)..".png"
    local sp = cc.Sprite:create(strFile)
    button:addChild(sp)
    sp:setPosition(183, 135)

    strFile = "pdk/BetSelect/classical_box_"..tostring(index)..".png"
    sp = cc.Sprite:create(strFile)
    button:addChild(sp)
    sp:setPosition(183, 87)

    strFile = "pdk/BetSelect/ziyou_people.png"
    sp = cc.Sprite:create(strFile)
    button:addChild(sp)
    sp:setPosition(47, 43)

    strFile = "pdk/BetSelect/ziyou_gold.png"
    sp = cc.Sprite:create(strFile)
    button:addChild(sp)
    sp:setPosition(208, 43)

    if USER_INFO["landlord_section"]["pdk"] then
        local data = USER_INFO["landlord_section"]["pdk"]
        local str = ""
        for i, v in pairs(data) do
            if v["game_level"] == level then
                if v["upper_section"] then
                    str = tostring(require("hall.GameCommon"):formatGoldSys(tonumber(v["lower_section"]))).."-"..tostring(require("hall.GameCommon"):formatGoldSys(tonumber(v["upper_section"])))
                else
                    str = tostring(require("hall.GameCommon"):formatGoldSys(tonumber(v["lower_section"]))).."以上"
                end
                local lbTitle = cc.Label:createWithTTF(str,"res/fonts/fzcy.ttf",24)

                lbTitle:setAnchorPoint(cc.p(0,0.5))
                lbTitle:setPosition(cc.p(225,43))
                button:addChild(lbTitle)
            end
        end
    end

    local lbChip = cc.Label:createWithTTF("","res/fonts/fzcy.ttf",30)
    lbChip:setAnchorPoint(cc.p(0.5,0.5))
    lbChip:setPosition(cc.p(200,85))
    lbChip:setString(require("hall.GameCommon"):formatGold(chip))
    button:addChild(lbChip)

    local lbOnline = cc.Label:createWithTTF(tostring(counts),"res/fonts/fzcy.ttf",18)
    lbOnline:setPosition(cc.p(65,43))
    lbOnline:setColor(cc.c3b(252,244,198))
    lbOnline:setAnchorPoint(cc.p(0,0.5))
    button:addChild(lbOnline)

    tbBattles[button] = {["chip"]=chip,["level"]=level}

    local function touchBattle(sender, event)
        --缩小ui
        if event == TOUCH_EVENT_BEGAN then
            require("hall.GameCommon"):playEffectSound("hall/Audio_Button_Click.mp3")
            -- sender:setScale(0.9)
        end

        if event == TOUCH_EVENT_CANCEL then
            -- sender:setScale(1)
        end

        if event == TOUCH_EVENT_ENDED then
            -- sender:setScale(1)

            --进入游戏
            if sender == button then
                print("enter battle field:",tbBattles[button]["level"],USER_INFO["gold"],tbBattles[button]["chip"])
                local ret = require("hall.hall_data"):checkEnter("pdk",tbBattles[button]["level"])
                if ret == 1 then--少于低分
                    require("hall.GameTips"):showTips("你的余额已不足，去商城充值吧","change_money_battle",1)
                elseif ret == 2 then
                    require("hall.GameTips"):showTips("请选择高分场")
                elseif ret == 3 then
                    require("hall.GameTips"):showTips("您不能进入该分场")
                elseif ret == 0 then
                    if tbBattles[button] then
                        USER_INFO["gameLevel"] = tbBattles[button]["level"]
                        require("hall.gameSettings"):setGameMode("free")
                        display_scene("pdk.gameScene",1)
                    end
                end
            end

        end
    end
    button:addTouchEventListener(touchBattle)

    local pv = self._scene:getChildByTag(1001)
    if pv == nil then
        print("page view nil")
        return
    end

    if  button == nil then
        print("scroll view item nil")
        return
    end

    local itemWidth = 270 
    local itemHeight = 203
    local xHead = 60
    local x = 1
    local y = 1
    if index == 1 then
        x = 220
        y = 266
    elseif index == 2 then
        x = 621
        y = 266
    elseif index == 3 then
        x = 220
        y = 85
    elseif index == 4 then
        x = 621
        y = 85
    end
    button:setPosition(x,y)

    local item = pagesBattle[countBatllesPage]
    if item == nil then
        print("new page item")
        -- item = pv:newItem()
        -- pv:addItem(item)
        item = ccui.Layout:create()
        local spBack = cc.Sprite:create("hall/hall/main_bg01.png")
        item:addChild(spBack)
        spBack:setPosition(spBack:getContentSize().width/2,spBack:getContentSize().height/2-40)
        item:setContentSize(cc.size(spBack:getContentSize().width/2,spBack:getContentSize().height/2))
        pv:addPage(item)
        pagesBattle[countBatllesPage] = item
    end


    item:addChild(button)

end
--选择game level
function SelectChip:fillGameLevel(chip)
    if chip == 100 then
        USER_INFO["gameLevel"] = 11
        return true
    elseif chip == 200 then
        USER_INFO["gameLevel"] = 12
        return true
    elseif chip == 500 then
        USER_INFO["gameLevel"] = 13
        return true
    end

    return false
end
--添加比赛场
function SelectChip:addMatchBattle(index,chip,cost4match,counts,playerLevel,matchLevel,matchId,mode)

    local strFile = "pdk/BetSelect/classical_bt_"..tostring(index)..".png"

    local button = ccui.Button:create()
    button:setTouchEnabled(true)
    button:loadTextures(strFile, nil, nil)

    --房间名
    strFile = "pdk/BetSelect/classical_text_"..tostring(index)..".png"
    local sp = cc.Sprite:create(strFile)
    button:addChild(sp)
    sp:setPosition(183, 135)

    strFile = "pdk/BetSelect/classical_box_"..tostring(index)..".png"
    sp = cc.Sprite:create(strFile)
    button:addChild(sp)
    sp:setPosition(183, 87)

    strFile = "pdk/BetSelect/ziyou_people.png"
    sp = cc.Sprite:create(strFile)
    button:addChild(sp)
    sp:setPosition(47, 43)


    local lbChip = cc.Label:createWithTTF("","res/fonts/fzcy.ttf",30)
    lbChip:setAnchorPoint(cc.p(0.5,0.5))
    lbChip:setPosition(cc.p(200,85))
    lbChip:setString(require("hall.GameCommon"):formatGold(cost4match))
    button:addChild(lbChip)
    tbMatchFee[button] = cost4match

    local lbOnline = cc.Label:createWithTTF(tostring(counts),"res/fonts/fzcy.ttf",18)
    lbOnline:setPosition(cc.p(65,43))
    lbOnline:setColor(cc.c3b(252,244,198))
    lbOnline:setAnchorPoint(cc.p(0,0.5))
    button:addChild(lbOnline)

    tbBattles[button] = {["chip"]=chip,["level"]=level}

    local function touchBattle(sender, event)
        --缩小ui
        if event == TOUCH_EVENT_BEGAN then
            require("hall.GameCommon"):playEffectSound("hall/Audio_Button_Click.mp3")
            -- sender:setScale(0.9)
        end

        if event == TOUCH_EVENT_CANCEL then
            -- sender:setScale(1)
        end

        if event == TOUCH_EVENT_ENDED then
            -- sender:setScale(1)

            if USER_INFO["gold"] > tbMatchFee[button] then
                require("pdk.pdkSettings"):setMatchId(matchId)
                require("pdk.pdkSettings"):setMatchLevel(matchLevel)
                require("pdk.MatchSetting"):showMatchSignup(true,0,playerLevel,tbMatchFee[button],"pdk",matchLevel)
                -- require("hall.GameData"):setPlayerRoute("pdk","match",tbMatchFee[button],0)
            else
                require("hall.GameTips"):showTips("你的余额已不足，去商城充值吧","change_money",1)
                
            end

        end
    end
    button:addTouchEventListener(touchBattle)

    local pv = self._scene:getChildByTag(1001)
    if pv == nil then
        print("page view nil")
        return
    end

    if  button == nil then
        print("scroll view item nil")
        return
    end

    local itemWidth = 270 
    local itemHeight = 203
    local xHead = 60
    local x = 1
    local y = 1
    if index == 1 then
        x = 220
        y = 286
    elseif index == 2 then
        x = 621
        y = 286
    elseif index == 3 then
        x = 220
        y = 105
    elseif index == 4 then
        x = 621
        y = 105
    end
    button:setPosition(x,y)

    local item = pagesBattle[countBatllesPage]
    if item == nil then
        print("new page item")
        -- item = pv:newItem()
        -- pv:addItem(item)
        item = ccui.Layout:create()
        local spBack = cc.Sprite:create("hall/hall/main_bg01.png")
        item:addChild(spBack)
        spBack:setPosition(spBack:getContentSize().width/2,spBack:getContentSize().height/2-20)
        item:setContentSize(cc.size(spBack:getContentSize().width/2,spBack:getContentSize().height/2))
        pv:addPage(item)
        pagesBattle[countBatllesPage] = item
    end


    item:addChild(button)

end


function SelectChip:onEnter()
    require("hall.GameCommon"):landLoading(true)
    local mode = require("hall.gameSettings"):getGameMode()
    if mode == "free" then
        HttpNet:FreeloadBattles(1)
    elseif mode == "match" then
        HttpNet:MatchloadBattles(1)
    end

    require("pdk.pdkSettings"):reset()
    bMatchJoin = false
    require("hall.GameSetting"):showGameAwardPool()
    
    if USER_INFO["match_fee"] then
        print("match_fee:"..USER_INFO["match_fee"])
        if USER_INFO["match_fee"] > 0 then
            require("pdk.pdkServer"):CLI_SEND_JOIN_MATCH(require("pdk.pdkSettings"):getMatchLevel())
        end
    else
        print("match_fee----------------------null")
    end
    -- for test
--    self:addBattleField("自由场1",100,123)
--    local pv = self:getChildByTag(1001)
--    pv:reload()
end

function SelectChip:onExit()
    --self:removeChildByTag(1000)
    countBatllesPage = 1
    countBtallesY = 0
    countBatllesX = 0
    pagesBattle = {}
    self._scene:removeChildByTag(1001)
end

--更新金币
function SelectChip:goldUpdate()
    -- body
    local layer_top = self._scene:getChildByName("layer_top")
    if layer_top == nil then
        return
    end

    local btn_recharge = layer_top:getChildByName("btn_recharge")
    if btn_recharge == nil then
        return
    end
    local txt_level = layer_top:getChildByName("txt_level")
    local txt_score = btn_recharge:getChildByName("txt_score")

    --text
    if txt_score then
        print("updateScore:"..USER_INFO["gold"])
        txt_score:setString(require("hall.GameCommon"):formatGold(USER_INFO["gold"]))
        -- local gold = require("hall.GameCommon"):showNums(USER_INFO["gold"],cc.c3b(82,15,33))
        -- btn_recharge:addChild(gold)
        -- gold:setPosition(txt_score:getPosition())
        -- gold:setName("txt_score")
        -- gold:setScale(0.6)
        -- txt_score:removeSelf()
    end

    if txt_level then
        local level = require("hall.GameCommon"):showNums(USER_INFO["pLevel"],cc.c3b(82,15,33))
        self._scene:addChild(level)
        level:setPosition(cc.p(txt_level:getPositionX()-level:getContentSize().width/2 + 6,txt_level:getPositionY()))
        level:setScale(0.5)
        level:setName("txt_level")
        txt_level:removeSelf()
    end
end
----------------------------------------------------------------
------------------------- 返回http消息 -------------------------
----------------------------------------------------------------
--自由场赛场
function SelectChip:HttpFreeLoadBattles(battleList)
    require("hall.GameCommon"):landLoading(false)
    if battleList == nil then
        return
    end

    countBatllesPage = 1
    countBtallesY = 0
    countBatllesX = 0
    pagesBattle = {}
    if self._scene:getChildByTag(1001) then
        self._scene:removeChildByTag(1001)
    end
    -- local pvBattle = cc.ui.UIPageView:new(lvParas)
    local pvBattle = ccui.PageView:create()
    pvBattle:setContentSize(cc.size(WIDTH_SCROLLVIEW,HEIGHT_SCROLLVIEW))
    if pvBattle ~= nil then
        pvBattle:setTag(1001)
        pvBattle:setAnchorPoint(cc.p(0.5,0.5))
        pvBattle:setPosition(cc.p(485,274))
        self._scene:addChild(pvBattle,3)
    end

    local function sortGameList()
        table.sort(battleList,function(a,b)
            return a["coins"]<b["coins"]
        end )
    end
    sortGameList()
    for i, v in ipairs(battleList) do
        if v["level"] ~= nil and v["coins"] ~= nil then
            self:addBattleField(i,v["coins"],v["playerCount"],v["level"])
        end
    end

    -- pvBattle:reload()
end
--比赛场赛场
function SelectChip:HttpMatchLoadBattles(battleList)
    require("hall.GameCommon"):landLoading(false)

    if battleList == nil then
        self:addMatchBattle("比赛场1",100,100,100,9)
        local pv = self._scene:getChildByTag(1001)
        -- pv:reload()
        return
    end    

    countBatllesPage = 1
    countBtallesY = 0
    countBatllesX = 0
    pagesBattle = {}
    if self._scene:getChildByTag(1001) then
        self._scene:removeChildByTag(1001)
    end
    --UIPageView
    local lvParas = {
        viewRect = cc.rect(0,0,WIDTH_SCROLLVIEW,HEIGHT_SCROLLVIEW)
    }
    -- local pvBattle = ccui.ui.UIPageView:new(lvParas)
    local pvBattle = ccui.PageView:create()
    pvBattle:setContentSize(cc.size(WIDTH_SCROLLVIEW,HEIGHT_SCROLLVIEW))
    if pvBattle ~= nil then
        pvBattle:setTag(1001)
        pvBattle:setAnchorPoint(cc.p(0.5,0.5))
        pvBattle:setPosition(cc.p(485,254))
        self._scene:addChild(pvBattle,3)
    end
    local function sortGameList()
        table.sort(battleList["roomList"],function(a,b)
            return a["fee"]<b["fee"]
        end )
    end
    sortGameList()
    for i, v in ipairs(battleList["roomList"]) do
        --名称，底分，报名费，人数,满多少人开赛
        if v["level"] ~= nil and v["fee"] ~= nil then
            self:addMatchBattle(i,v["coin"],v["fee"],v["presentPlayerCount"],v["playerGoons"][1]["playerCount"],v["level"],v["matchId"])
        end
    end

    -- pvBattle:reload()
end
----------------------------------------------------------------
------------------------- 返回网络消息 -------------------------
----------------------------------------------------------------
function SelectChip:onNetLoginGameFailed(pack)
    print("login game failed ecode:%d",pack["nErrno"])
end
--请求进入比赛场返回
function SelectChip:onNetMatchJoin(pack)
    if pack == nil then
        return
    end

    local tid = pack["MatchID"]
    require("pdk.pdkSettings"):setMatchId(tid)
    print("MatchID id:%d",require("pdk.pdkSettings"):getMatchId())
    local sendpack = bm.server:createPacketBuilder(PROTOCOL.CLI_LOGIN_ROOM)
    :setParameter("tableid", tid)
    :setParameter("nUserId", tonumber(UID))
    :setParameter("strkey", json.encode("kadlelala"))
    :setParameter("strinfo", USER_INFO["user_info"])
    :setParameter("iflag", 1)
    :setParameter("version", 1)
    :build()
    bm.server:send(sendpack)

end
--进入比赛场失败
function SelectChip:onNetMatchLoginFailed(pack)
    --显示失败原因
    USER_INFO["match_fee"] = 0
    require("pdk.MatchSetting"):setJoinMatch(false)
end
--成功进入比赛
function SelectChip:onNetMatchLoginOk(pack)
    --增加一个等待比赛开始页面

    if USER_INFO["match_fee"] then
        if USER_INFO["match_fee"] > 0 then
            bMatchJoin = true
            require("pdk.MatchSetting"):showMatchSignup(true,pack["MatchUserCount"],pack["totalCount"],pack["Costformatch"],"pdk",require("pdk.pdkSettings"):getMatchLevel())
        end
    end

    require("pdk.MatchSetting"):setJoinMatch(true)

    USER_INFO["match_fee"] = pack["Costformatch"]
    USER_INFO["gold"] = pack["Score"]
    require("hall.GoldRecord.GoldRecord"):writeData(USER_INFO["gold"], -USER_INFO["match_fee"])
    self:updateScore()

    --进入比赛模式
    require("hall.GameData"):enterMatch(1)
end
--其他玩家进入比赛
function SelectChip:onNetMatchOtherLogin(pack)
    --增加一个等待比赛的页面
    require("pdk.MatchSetting"):joinMatch(pack["Usercount"],pack["Totalcount"])
end
--用户退出比赛
function SelectChip:onNetMatchLogout(pack)
    if pack then
        local flag = pack["Flag"]
        -- 成功退赛
        if flag == 1 or flag == 2 then
            --退回报名费
            USER_INFO["gold"] = USER_INFO["gold"] + pack["nCostForMatch"]
            require("hall.GoldRecord.GoldRecord"):writeData(USER_INFO["gold"], pack["nCostForMatch"])
            self:updateScore()
            
            require("pdk.MatchSetting"):setJoinMatch(false)
            local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_LOGOUT_ROOM)
            :build()
            bm.server:send(pack)

            local layer_sign = self:getChildByName("layer_sign")

            USER_INFO["match_fee"] = 0
            bMatchJoin = false


        else
            --失败原因
            print("match logout failed,error type:"..pack["Errortype"])
            require("pdk.MatchSetting"):setJoinMatch(true)
        end

    end

end

return SelectChip
