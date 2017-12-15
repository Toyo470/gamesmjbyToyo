--
-- Author: ZT 
-- Date: 2016-04-15 10:44:49

local pagesBattle = {}
local tbBattles = {}
local tbMatchFee = {}
local bMatchJoin = false
local nCurMatchID = 0


local selectNum=0
local   item =nil
local PROTOCOL         = import("majiang.scenes.Majiang_Protocol")
local MajiangroomServer = require("majiang.scenes.MajiangroomServer")
local mjSetting = require("majiang.setting_help")
local data_manager = require("majiang.datamanager")
local BloodHallHandle  = require("majiang.scenes.MajiangroomHandle")
local PROTOCOL         = import("majiang.scenes.Majiang_Protocol")

local MJselectChip=class("MJselectChip",function ()
	return display.newScene();
end)


function MJselectChip:ctor()
	-- body
    bm.server:setProtocol(PROTOCOL)
    bm.server:setHandle(BloodHallHandle.new())
    
    bm.nodeClickHandler=function (obj,method,...)
        local args = {...}
        print("content:"..json.encode(args))
        obj:setTouchEnabled(true)
        obj:addNodeEventListener(cc.NODE_TOUCH_EVENT,function ( event )
                if event.name == "began" then
                    require("hall.GameCommon"):playEffectSound(audio_path,false)
                    method(self,unpack(args))
                end
        end)
    end

	local s = cc.CSLoader:createNode("majiang/scens/BetSelect.csb"):addTo(self)

	self._scene=s;
    

    local head = self._scene:getChildByName("head")
    if head then
        local user_inf = {}
        user_inf["uid"] = USER_INFO["uid"]
        user_inf["icon_url"] = USER_INFO["icon_url"]
        user_inf["sex"] = USER_INFO["sex"]
        user_inf["nick"] = USER_INFO["nick"]
        require("hall.GameCommon"):setPlayerHead(user_inf,head,81)
    end

    --玩家名称
    local txt_nick = self._scene:getChildByName("txt_nick")
    txt_nick:enableShadow(cc.c4b(255,255,255,255),cc.size(1,0),0)
    txt_nick:setString(require("hall.GameCommon"):formatNick(USER_INFO["nick"]))


    local txt_level = s:getChildByName("vip_txt")
    txt_level:setString(USER_INFO["pLevel"])

    --button
    local btn_help = s:getChildByName("btn_help")
    local btn_setting = s:getChildByName("btn_setting")
    local btn_back = s:getChildByName("btn_back")
    local btn_recharge = s:getChildByName("btn_recharge")

    --金币
    local txt_score = btn_recharge:getChildByName("txt_score")
    -- txt_score:setString(require("net.HttpNet"):formatGold(USER_INFO["gold"]))
    if txt_score then
        txt_score:setString(tostring(USER_INFO["gold"]))
    end
    -- --新增UI
    local mode = require("hall.gameSettings"):getGameMode()

    local function touchButtonEvent(sender, event)
        --缩小ui
        if event == TOUCH_EVENT_BEGAN then
            -- require("hall.GameCommon"):playEffectSound(audio_path)
            require("hall.GameCommon"):playEffectSound(audio_path)
            sender:setScale(0.9)
        end
        if event == 3 then
            sender:setScale(1)
        end

        if event == TOUCH_EVENT_ENDED then
            if sender ~= btn_recharge then
                sender:setScale(1)
            end

            if sender == btn_back then--返回赛场选择
                require("app.HallUpdate"):enterHall()
            end
    
            --设置
            if sender == btn_setting then
                -- mjSetting:show_setting_layout(self._scene)
                require("hall.GameCommon"):showSettings(true)
            end

            --充值
            if sender == btn_recharge then
               -- gRecharge()
                if USER_INFO["isFirstCharged"] and USER_INFO["isFirstCharged"] == 1 then
                    local market = Market.new()
                    SCENENOW["scene"]:addChild(market)
                else
                    require("hall.fRecharge"):showOut()
                end
            end
            --帮助
            if sender == btn_help then
                local msg = 1
                if mode == "free" then
                    msg = "1、战败玩家失去底分*番数，获胜玩家获得底分*番数*80%，20%为系统服务费;\n\n2、战败玩家失去底分*番数，获胜玩家获得底分*番数*80%，20%为系统服务费."
                else
                    msg = "1、玩家选择不同的场次缴纳报名费，报名费越高奖励越丰厚;\n\n2、每个场次凑够系统指定人数则开局，参赛玩家随机分成若干组，每轮淘汰掉末尾的玩家；晋级的玩家重新分组进行下一轮，如此直到决出冠军；\n\n最后按照排名颁发奖励。"
                end
                require("hall.GameCommon"):showHelp(true,msg)

                -- if mode == "free" then
                --     mjSetting:show_help_layout(self._scene,2)
                -- else
                --     mjSetting:show_help_layout(self._scene,3)
                -- end
                
            end
        end
    end

    btn_help:addTouchEventListener(touchButtonEvent)--帮助
    btn_setting:addTouchEventListener(touchButtonEvent)--游戏设置
    btn_back:addTouchEventListener(touchButtonEvent)--退出大厅
    btn_recharge:addTouchEventListener(touchButtonEvent)--充值

    --这里处理是否重新报名
    print("MJselectChip match_fee mode",tostring(USER_INFO["match_fee"]),tostring(mode))
    if USER_INFO["match_fee"] and mode == "match" then
        print("getinto match game again ----------------match_fee:"..USER_INFO["match_fee"])
        if USER_INFO["match_fee"] > 0 then
            MajiangroomServer:c2s_CLIENT_CMD_JOIN_MATCH(USER_INFO["curr_match_level"])
        end
    end
    print("MJselectChip mode",mode)
    if mode == "free" then
        --self:addBattleField(100,"自由畅",500,300)
        cct.createHttRq({
            url=HttpAddr .. "/game/freeMatch",
            date={
                gameId=4,
            },
            type_="GET",
            callBack = function(data)
            self:http_freeMatch_callback(data)
         end
        })
        
    elseif mode == "match" then
        cct.createHttRq({
            url=HttpAddr .. "/game/matchGame",
            date={
                gameId=4,
            },
            type_="GET",
            callBack= function(data)
            self:http_match_callback(data)
         end
        })
    end

    -- local mode = data_manager:get_game_mode()
end

function MJselectChip:http_freeMatch_callback(date)
                -- body
                --self:setUerInfoPanl()
    dump(date,"date--------------------")
    date.netData=json.decode(date.netData)
    if date.netData.returnCode~="0" then
        return;
    end

    local tb={}
    local num=0
    local te={}
    table.sort(date.netData.data,function(v1,v2) return v1.coins < v2.coins end)
    for k,v in pairs(date.netData.data) do
        local tp={}
        tp.name=v.name -- 名字
        tp.playNum=v.playerCount --玩得人数
        tp.minScore=v.coins -- 低分
        tp.level = v.level

        num=num+1;
        if num>6 then --last
            table.insert(tb,te)
            te={}
            num=0
        end--游戏的level
        table.insert(te,tp)
    end

    if num ~= 0 then --num == 0表示刚刚好上面6个6个的插入好
        table.insert(tb,te)
        te={}
        num=0
    end
    print("tb------------------------------")
    dump(tb)
    self:addBattleField(tb)
end

function MJselectChip:http_match_callback(data)
    print("http_match_callback")
   -- dump(data)
    data.netData=json.decode(data.netData)
    if data.netData.returnCode~="0" then
        return;
    end
    dump(data.netData)

    local tb={}
    local num=0
    local te={}
    
    table.sort(data.netData.data.roomList,function(v1,v2) return v1.fee < v2.fee end)

    for _,room in pairs(data.netData.data.roomList) do 
        num=num+1;
        if num>6 then --last
            table.insert(tb,te)
            te={}
            num=0
        end--游戏的level
        table.insert(te,room)
    end
    if num ~= 0 then --num == 0表示刚刚好上面6个6个的插入好
        table.insert(tb,te)
        te={}
        num=0
    end

    --经过上面后，tb为新的数据，六个为一组
    --对应容器页

    self:addmatchfield(tb)
end

--增加比赛场
function MJselectChip:addmatchfield(list_table)
    local pv=self._scene:getChildByName("base_page")
    if pv == nil then
        print("-----------base_page is null-----------")
        return
    end

    local len = 0
    for k,v in pairs(list_table) do--页
        local onePage=ccui.Layout:create();
        onePage:setContentSize(cc.p(960,400))

        len = 0
        for k1,v1 in pairs(v) do--每一页
            local _pppan=self._scene:getChildByName("Panel_match "):clone();
            onePage:addChild(_pppan)

            len=len+1;
            if len >6 then
                break;
            end

            local _x,_y;
            if len >3 then
                _y=73.58
                _x=95.15 + (363.95 - 95.15) * (len - 3-1)
            else
                _y=261.70
                _x=95.15 + (363.95 - 95.15) * (len-1)
            end
            _pppan:setPosition(_x,_y)

            --报名费
            local Text_3 = _pppan:getChildByName("Text_3")
            Text_3:setString(v1.fee)
            --人数
            local Text_4 = _pppan:getChildByName("Text_4")
            Text_4:setString(v1.presentPlayerCount)

            local Button_1 = _pppan:getChildByName("Button_1")
            Button_1:setTag(v1.level)
            Button_1.data = v1
            Button_1:onTouch(handler(self,self.ontouchbtn_match))
        end
        pv:addPage(onePage)
    end
end

--增加自由场
function MJselectChip:addBattleField(listTable)
    local pv=self._scene:getChildByName("base_page")
    if pv == nil then
        print("-----------base_page is null-----------")
        return
    end

    local len = 0
    for k,v in pairs(listTable) do--页
        local onePage=ccui.Layout:create();
        onePage:setContentSize(cc.p(960,400))

        len = 0
        for k1,v1 in pairs(v) do--每一页
            local _pppan=self._scene:getChildByName("Panel_1"):clone();
            onePage:addChild(_pppan)

            len=len+1;
            if len >6 then
                break;
            end

            local _x,_y;
            if len >3 then
                _y=73.58
                _x=95.15 + (363.95 - 95.15) * (len - 3-1)
            else
                _y=261.70
                _x=95.15 + (363.95 - 95.15) * (len-1)
            end
            _pppan:setPosition(_x,_y)

            --设置数据相关
            local Text_3 = _pppan:getChildByName("Text_3")
            Text_3:setString(v1.minScore)
            
            local Text_4 = _pppan:getChildByName("Text_4")
            Text_4:setString(v1.playNum)

            local Button_1 = _pppan:getChildByName("Button_1")
            Button_1:setTag(v1.level)
            Button_1.data = v1
            Button_1:onTouch(handler(self,self.ontouchbtn))
        end
        pv:addPage(onePage)
    end

end

function  MJselectChip:ontouchbtn( event)
        print("----------------------event-----------------")
        --缩小ui
        if event.name == "began" then
            event.target:getParent():setScale(1.2)
            require("hall.GameCommon"):playEffectSound(audio_path)
        end


        if event.name == "ended" then
           event.target:getParent():setScale(1)
           -- 进入游戏

            --这个是为了游戏在中途中断开了，检测网络断开的时候重连用
            bm.nomallevel= event.target:getTag()
            print("bm.nomallevel-------------------",bm.nomallevel)
            require("majiang.majiangServer"):LoginGame(bm.nomallevel)
        end
end

function MJselectChip:setUserInfo()
    -- body
end

function MJselectChip:goldUpdate()
    --金币
    local btn_recharge = self._scene:getChildByName("btn_recharge")
    local txt_score = btn_recharge:getChildByName("txt_score")
    -- txt_score:setString(require("net.HttpNet"):formatGold(USER_INFO["gold"]))
    if txt_score then
        txt_score:setString(tostring(USER_INFO["gold"]))
    end
end

function MJselectChip:onExit()
    --self:removeChildByTag(1000)

    pagesBattle = {}
    tbBattles = {}
    tbMatchFee = {}
    bMatchJoin = false
    nCurMatchID = 0
    selectNum=0
    item =nil
    
    --self._scene:removeChildByTag(1001)
end

--比赛场按钮回调函数
function MJselectChip:ontouchbtn_match(event)
    if event.name == "began" then
        event.target:getParent():setScale(1.2)
        require("hall.GameCommon"):playEffectSound(audio_path)
    end


    if event.name == "ended" then
       event.target:getParent():setScale(1)
       -- 进入游戏

        local data = event.target.data
        dump(data,"data")
        local playerGoons = data.playerGoons

        dump(playerGoons, "playerGoons")
        print("data.level",data.level)
        local tbRank = {}
        for j,v in pairs(playerGoons) do
            tbRank[j] = v.playerCount
        end
        dump(tbRank, "tbRank")
        require("majiang.ddzSettings"):addMatchRank(data.level,tbRank)

        dump(data,"ontouchbtn_match")
        require("majiang.MatchSetting"):showMatchSignup(true,0,playerGoons[1].playerCount,data.fee,"majiang",data.level,data.matchId)
    end
end

return MJselectChip