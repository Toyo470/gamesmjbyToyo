cc.FileUtils:getInstance():addSearchPath("ddz/")
local HttpNet = require("ddz.DDZHttpNet")
local gameID = 1

local PROTOCOL = require("ddz.ddz_PROTOCOL")

local ddzServer = import("ddz.ddzServer")
local ddzHandle  = require("ddz.ddzHandle")

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
    local s = cc.CSLoader:createNode("ddz/csb/SelectMode.csb"):addTo(self)
    self._scene = s

    --调出UI
    --head
    local head = s:getChildByName("head")
    if head then
        local head_info = {}
        head_info["url"] = USER_INFO["icon_url"]
        head_info["uid"] = USER_INFO["sex"]
        head_info["sex"] = USER_INFO["sex"]
        head_info["sp"] = head
        head_info["size"] = 80
        head_info["touchable"] = 1
        head_info["use_sharp"] = 1
        head_info["vip"] = USER_INFO["isVip"]
        require("hall.GameCommon"):getUserHead(head_info)
    end
    --button
    local btn_mode_free = s:getChildByName("btn_mode_1")
    local btn_mode_champion = s:getChildByName("btn_mode_1_0")
    local btn_mode_grade = s:getChildByName("btn_mode_1_1")
    local btn_help = s:getChildByName("btn_help")
    if btn_help then
        btn_help:setTouchEnabled(true)
    end
    local btn_setting = s:getChildByName("btn_setting")
    if btnSetting then
        btnSetting:setTouchEnabled(true)
    end
    local btn_lobby = s:getChildByName("btn_lobby")
    if btn_lobby then
        btn_lobby:setTouchEnabled(true)
    end
    local btn_recharge = s:getChildByName("btn_recharge")
    --text
    local txt_nick = s:getChildByName("txt_nick")
    local txt_level = s:getChildByName("txt_level")
    local txt_score = btn_recharge:getChildByName("txt_score")

    local strNick = require("hall.GameCommon"):formatNick(USER_INFO["nick"])
    txt_nick:setString(strNick)
    txt_nick:enableShadow(cc.c4b(255,255,255,255),cc.size(1,0),0)
    txt_score:setString(require("hall.GameCommon"):formatGold(USER_INFO["gold"]))
    txt_level:setString(USER_INFO["pLevel"])

    local gold = require("hall.GameCommon"):showNums(USER_INFO["gold"],cc.c3b(82,15,33))
    self._scene:getChildByName("btn_recharge"):addChild(gold)
    gold:setPosition(txt_score:getPosition())
    gold:setName("txt_score")
    gold:setScale(0.6)
    txt_score:removeSelf()

    local level = require("hall.GameCommon"):showNums(USER_INFO["pLevel"],cc.c3b(82,15,33))
    self._scene:addChild(level)
    level:setPosition(cc.p(txt_level:getPositionX()-level:getContentSize().width/2 + 6,txt_level:getPositionY()))
    level:setScale(0.5)
    level:setName("txt_level")
    txt_level:removeSelf()

    local function touchButtonEvent(sender, event)
        --缩小ui
        if event == TOUCH_EVENT_BEGAN then
            require("hall.GameCommon"):playEffectSound("ddz/audio/Audio_Button_Click.mp3")
            -- sender:setScale(0.9)
        end

        if event == TOUCH_EVENT_ENDED then
            -- sender:setScale(1)
            --进入赛场分数选择
            if sender == btn_mode_free then
                require("hall.gameSettings"):setGameMode("free")
                display_scene("ddz.SelectChip",1)
            end
            --进入赛场分数选择
            if sender == btn_mode_champion then
                require("hall.gameSettings"):setGameMode("match")
                display_scene("ddz.SelectChip",1)
            end
            --返回游戏选择大厅
            if sender == btn_lobby then
                require("app.HallUpdate"):enterHall()
            end
            --设置
            if sender == btn_setting then
                require("hall.GameCommon"):showSettings(true)
            end
            --充值
            if sender == btn_recharge then
                require("hall.GameCommon"):gRecharge()
            end
            --帮助
            if sender == btn_help then
                -- self:showHelp(true)
                local msg = "斗地主是一种在中国流行的纸牌游戏。游戏由3个玩家进行，用一副54张牌（包括大小王），其中一方为地主，其余两家为另一方，双方对战，先出完牌的一方获胜。\n\n斗地主玩法上手快，简单刺激，加倍和炸弹可以增加获胜倍数。"
                require("hall.GameCommon"):showHelp(true,msg)
                print(msg)
            end

        end

    end

    btn_mode_free:addTouchEventListener(touchButtonEvent)--进入自由场
    btn_mode_champion:addTouchEventListener(touchButtonEvent)--进入比赛场
    btn_mode_grade:addTouchEventListener(touchButtonEvent)--进入段位赛
    btn_help:addTouchEventListener(touchButtonEvent)--帮助
    btn_setting:addTouchEventListener(touchButtonEvent)--游戏设置
    btn_lobby:addTouchEventListener(touchButtonEvent)--退出大厅
    btn_recharge:addTouchEventListener(touchButtonEvent)--退出大厅

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

end

function ddzScene:onExit()
end

--更新vip
function ddzScene:updateVIP()
    local top_base = self._scene:getChildByName("top_base")
    local sp_head = top_base:getChildByName("sp_head")
    if sp_head then
        local head_info = {}
        head_info["uid"] = tonumber(UID)
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
--更新金币
function ddzScene:goldUpdate()
    -- body
    local btn_recharge = self._scene:getChildByName("btn_recharge")
    local txt_nick = self._scene:getChildByName("txt_nick")
    local txt_level = self._scene:getChildByName("txt_level")
    local txt_score = btn_recharge:getChildByName("txt_score")

    --text
    if txt_score then
        print("updateScore:"..USER_INFO["gold"])
        -- txt_score:setString(require("hall.GameCommon"):formatGold(USER_INFO["gold"]))
        local gold = require("hall.GameCommon"):showNums(USER_INFO["gold"],cc.c3b(82,15,33))
        btn_recharge:addChild(gold)
        gold:setPosition(txt_score:getPosition())
        gold:setName("txt_score")
        gold:setScale(0.6)
        txt_score:removeSelf()
    end

    if txt_level then
        local level = require("hall.GameCommon"):showNums(USER_INFO["pLevel"],cc.c3b(82,15,33))
        self._scene:addChild(level)
        level:setPosition(cc.p(txt_level:getPositionX()-level:getContentSize().width/2 + 6,txt_level:getPositionY()))
        level:setScale(0.5)
        level:setName("txt_level")
        txt_level:removeSelf()
    end

    local strNick = require("hall.GameCommon"):formatNick(USER_INFO["nick"])
    txt_nick:setString(strNick)
    txt_nick:enableShadow(cc.c4b(255,255,255,255),cc.size(1,0),0)
    -- txt_score:setString(require("hall.GameCommon"):formatGold(USER_INFO["gold"]))
    -- txt_level:setString(USER_INFO["pLevel"])
end

function ddzScene:HttpLoadGame(modeList)
    require("hall.GameCommon"):landLoading(false)
    print("load modles:"..json.encode(modeList))
    if modeList then
        local mode1 = self._scene:getChildByName("btn_mode_1")
        if mode1 ~= nil then
            local txt = mode1:getChildByName("txt_count_0")
            if txt ~= nil then
                txt:setString(tostring(modeList["freeCount"]))
            end
        end
        local mode2 = self._scene:getChildByName("btn_mode_1_0")
        if mode2 ~= nil then
            local txt = mode2:getChildByName("txt_count_0")
            if txt ~= nil then
                txt:setString(tostring(modeList["matchCount"]))
            end
        end
        local mode3 = self._scene:getChildByName("btn_mode_1_1")
        if mode3 ~= nil then
            local txt = mode3:getChildByName("txt_count_0")
            if txt ~= nil then
                txt:setString(tostring(modeList["rankCount"]))
            end
        end
    end
end

return ddzScene
