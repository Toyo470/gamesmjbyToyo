cc.FileUtils:getInstance():addSearchPath("ddz_laizi/")
local HttpNet = require("ddz_laizi.DDZHttpNet")
local gameID = 1

local PROTOCOL = require("ddz_laizi.ddz_PROTOCOL")

local ddzServer = import("ddz_laizi.ddzServer")
local ddzHandle  = require("ddz_laizi.ddzHandle")
local Market = require("hall.market")

local ddzScene = class("ddzScene", function()
    return display.newScene("ddzScene")
end)

function ddzScene:ctor()

    bm.server:setProtocol(PROTOCOL)
    bm.server:setHandle(ddzHandle.new())

    -- cc.Director:getInstance():setDisplayStats(true)
    if USER_INFO["enter_mode"] > 0 then
        require("hall.gameSettings"):setGameMode("group")
    end

--    gChangeOrientation(1)
    local s = cc.CSLoader:createNode("ddz_laizi/csb/ddz_laiziScene.csb"):addTo(self)
    self._scene = s

    --调出UI
    --button
    local back_bt = s:getChildByName("btn_exit")
    if back_bt then
        back_bt:setTouchEnabled(true)
    end
     local top_base = self._scene:getChildByName("top_base")
    local btn_setting = top_base:getChildByName("btn_setting")
    if btn_setting then
        btn_setting:setTouchEnabled(true)
    end
    local btn_add_score = top_base:getChildByName("btn_coins")--金币
    local add_9_gold = btn_add_score:getChildByName("add_9")
    local btn_score =top_base:getChildByName("btn_score")--钻石
    local add_9_diamond = btn_score:getChildByName("add_9")
    local btn_fangka = top_base:getChildByName("btn_fangka")--房卡
    local add_fangka = btn_fangka:getChildByName("add_9")

    local main_rachange = s:getChildByName("main_rachange")

    local hall_base = s:getChildByName("hall_base")
    hall_base:setVisible(true)
    local btn_mode_free = hall_base:getChildByName("btn_free")
    local btn_mode_match = hall_base:getChildByName("btn_match")
    local btn_fast_game = self._scene:getChildByName("btn_faststart")

    --人数
    if btn_mode_free then
        local lb = btn_mode_free:getChildByName("txt_count")
        if lb then
            lb:setString(require("hall.GameList"):getModeCount("ddz_laizi","free"))
        end
    end
    if btn_mode_match then
        local lb = btn_mode_match:getChildByName("txt_count")
        if lb then
            lb:setString(require("hall.GameList"):getModeCount("ddz_laizi","match"))
        end
    end
    --按钮事件
    local function touchEvent(sender, event)
        if event == TOUCH_EVENT_BEGAN then
            if sender ~= btn_add_score then 
                sender:setScale(0.9)
            end
        end
        if event == TOUCH_EVENT_CANCELED then
            sender:setScale(1.0)
        end

        if event == TOUCH_EVENT_ENDED then
            sender:setScale(1.0)
            print("exit game")
            require("hall.GameCommon"):playEffectSound("hall/Audio_Button_Click.mp3")

            if sender == back_bt then
                -- cc.Director:getInstance():endToLua()
                require("app.HallUpdate"):enterHall()
            elseif sender == btn_setting then
                require("hall.GameCommon"):showSettings(true,true)
                -- require("hall.group.GroupSetting"):showTips()
            elseif sender == btn_add_score or add_9_gold == sender then 
                --充值
                -- require("hall.GameCommon"):gRecharge()
                print("here++++++++++2+++++++++++++")
                --if USER_INFO["isFirstCharged"] and USER_INFO["isFirstCharged"] == 1 then
                    local market = Market.new()
                    SCENENOW["scene"]:addChild(market)
                    market:setName("market")

                    hall_base:setVisible(false)
               -- else
                  --  require("hall.fRecharge"):showOut()
                --end

           elseif sender == btn_mode_free then
                --进入赛场分数选择
                require("hall.gameSettings"):setGameMode("free")
                require("hall.gameSettings"):setGame("ddz_laizi")
                display_scene(require("hall.gameSettings"):getCurrGameCode()..".SelectChip",1)

            elseif sender == btn_mode_match then --进入赛场分数选择
                require("hall.gameSettings"):setGameMode("match")
                require("hall.gameSettings"):setGame("ddz_laizi")
                display_scene(require("hall.gameSettings"):getCurrGameCode()..".SelectChip",1)
            elseif sender == btn_score  or add_9_diamond == sender then
                local GameTips = require("hall.GameTips")
                GameTips:showTips("该功能还没有喔!")
            --快速
            elseif sender == btn_fast_game then
                print("btn_fast_game")
                btn_fast_game:setColor(cc.c3b(125,125,125))
                btn_fast_game:setTouchEnabled(false)
                require("hall.GameTips"):showTips("正为您选择分场","fast_ddz",4)
                require("hall.fast_startgame"):init(USER_INFO["gold"],"ddz_laizi",101)
            elseif main_rachange == sender then
                if USER_INFO["isFirstCharged"] and USER_INFO["isFirstCharged"] == 0 then
                    require("hall.fRecharge"):showOut()
                else
                    local market = Market.new()
                    SCENENOW["scene"]:addChild(market)
                    market:setName("market")
                    hall_base:setVisible(false)
                end
            end
        end
    end

    back_bt:addTouchEventListener(touchEvent)
    btn_setting:addTouchEventListener(touchEvent)
    btn_add_score:addTouchEventListener(touchEvent)
    add_9_gold:addTouchEventListener(touchEvent)
    btn_score:addTouchEventListener(touchEvent)
    add_9_diamond:addTouchEventListener(touchEvent)
    main_rachange:addTouchEventListener(touchEvent)
    btn_mode_free:addTouchEventListener(touchEvent)--进入自由场
    btn_mode_match:addTouchEventListener(touchEvent)--进入比赛场
    btn_fast_game:addTouchEventListener(touchEvent)--充值

    --校验用户，成功返回hall的ip和port
    if s:getChildByName("layout_loading") then
        s:removeChildByName("layout_loading")
    end
    cct.showradioMessage(self,true);
end

--绑定按钮声音
function ddzScene:addBtAudio(a,b,c,d,e)
    a:addTouchEventListener(function(event,type)
        if(type == 2) then
            require("hall.GameCommon"):playEffectSound("ddz/audio/Audio_Button_Click.mp3")
            b:setVisible(false)
            c:setVisible(true)
            c:setVisible(false)
            d:setVisible(true)
        end
    end)
end

function ddzScene:onEnter()
    require("hall.GameCommon"):landLoading(true)
    HttpNet:loadGame(UID,gameID)
    require("hall.GameSetting"):showGameAwardPool()
     --显示版本号
    local lbVersion = ccui.Text:create()
    lbVersion:setString("version:"..require("hall.GameData"):getGameVersion("hall"))
    lbVersion:setFontSize(18)
    self._scene:addChild(lbVersion)
    lbVersion:setColor(cc.c3b(47,47,47))
    lbVersion:setPosition(cc.p(lbVersion:getContentSize().width/2,lbVersion:getContentSize().height/2))

    self:setScore()
    local strNick = require("hall.GameCommon"):formatNick(USER_INFO["nick"])
    local top_base = self._scene:getChildByName("top_base")
    local lbNick = top_base:getChildByName("txt_nick")
    if lbNick then
        lbNick:setString(strNick)
    end
    local txt_level = top_base:getChildByName("txt_level")
    if txt_level then
        txt_level:setString("LV "..tostring(USER_INFO["pLevel"]))
    end

    local sp_head = top_base:getChildByName("sp_head")
    if sp_head then
        local head_info = {}
        head_info["url"] = USER_INFO["icon_url"]
        head_info["uid"] = USER_INFO["uid"]
        head_info["sex"] = USER_INFO["sex"]
        head_info["sp"] = sp_head
        head_info["size"] = 60
        head_info["touchable"] = 1
        head_info["use_sharp"] = 1
        head_info["vip"] = USER_INFO["isVip"]
        require("hall.GameCommon"):getUserHead(head_info)
    end

    local action_ry = cc.RotateBy:create(1, 45)
    local action = cc.RepeatForever:create(action_ry)

    local effect_light_2 = self._scene:getChildByName("effect_light_2")
    effect_light_2:runAction(action)
end

function ddzScene:onExit()
end

--更新vip
function ddzScene:updateVIP()
    local top_base = self._scene:getChildByName("top_base")
    local sp_head = top_base:getChildByName("sp_head")
    if sp_head then
        local head_info = {}
        head_info["uid"] = USER_INFO["uid"]
        head_info["sex"] = USER_INFO["sex"]
        head_info["url"] = USER_INFO["icon_url"]
        head_info["sp"] = sp_head
        head_info["size"] = 60
        head_info["touchable"] = 1
        head_info["use_sharp"] = 1
        head_info["vip"] = USER_INFO["isVip"]
        require("hall.GameCommon"):getUserHead(head_info)
    end
end
--更新道具
function ddzScene:updateGoods(goods_type)
    self:updateVIP()
    self:setScore()
end
--更新金币
function ddzScene:goldUpdate()
    -- body
    self:setScore()
end

function ddzScene:setScore()

    local top_base = self._scene:getChildByName("top_base")

    local lbScore = top_base:getChildByName("btn_coins"):getChildByName("txt_score")
    if lbScore then
        lbScore:setString(require("hall.GameCommon"):formatGold(USER_INFO["gold"]))
    end
    --房卡
    lbScore = top_base:getChildByName("btn_fangka"):getChildByName("txt_score")
    if lbScore then
        if USER_INFO["fangka"] then
            lbScore:setString(require("hall.GameCommon"):formatGold(USER_INFO["fangka"]))
        else
            lbScore:setString("0")
        end
    end
end

function ddzScene:HttpLoadGame(modeList)
    require("hall.GameCommon"):landLoading(false)
    print("load modles:"..json.encode(modeList))
    -- if modeList then
    --     local mode1 = self._scene:getChildByName("btn_mode_1")
    --     if mode1 ~= nil then
    --         local txt = mode1:getChildByName("txt_count_0")
    --         if txt ~= nil then
    --             txt:setString(tostring(modeList["freeCount"]))
    --         end
    --     end
    --     local mode2 = self._scene:getChildByName("btn_mode_1_0")
    --     if mode2 ~= nil then
    --         local txt = mode2:getChildByName("txt_count_0")
    --         if txt ~= nil then
    --             txt:setString(tostring(modeList["matchCount"]))
    --         end
    --     end
    --     local mode3 = self._scene:getChildByName("btn_mode_1_1")
    --     if mode3 ~= nil then
    --         local txt = mode3:getChildByName("txt_count_0")
    --         if txt ~= nil then
    --             txt:setString(tostring(modeList["rankCount"]))
    --         end
    --     end
    -- end
end

return ddzScene
