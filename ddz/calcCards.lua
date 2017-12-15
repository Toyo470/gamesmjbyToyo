
local calcCards  = class("calcCards")
local Card          = require("ddz.Card")

--剩余牌数 1:大王，2：小王，。。。，13：A，14：2
local tbNumbers = {1,1,4,4,4,4,4,4,4,4,4,4,4,4,4}
--{"小王","大王","3","4","5","6","7","8","9","10","J","Q","K","A","2"}
local tbKind = {"大王","小王","2","A","K","Q","J","10","9","8","7","6","5","4","3"}
local bshow_calc = false
local game_state = 0


function  calcCards:init()

    local layer_ui = SCENENOW["scene"].layer_top
    if layer_ui == nil then
        return
    end
    self:reset()

    local btn_calc = layer_ui:getChildByName("btn_calc")
    if btn_calc then
        btn_calc:setVisible(false)
    end

    local function touchButtonEvent(sender, event)
        --缩小ui
        if event == TOUCH_EVENT_BEGAN then
            require("hall.GameCommon"):playEffectSound("ddz/audio/Audio_Button_Click.mp3")
        end

        if event == TOUCH_EVENT_ENDED then

            if sender == btn_calc then--返回赛场选择
                if game_state == 0 then
                    self:showTips("游戏尚未开战，请稍后再使用记牌器")
                else
                    self:isVerifyCalc()
                end
            end
        end
    end

    btn_calc:addTouchEventListener(touchButtonEvent)--帮助

end

--重置记牌器
function calcCards:reset()
    for i=1, 15 do
        if i < 3 then
            tbNumbers[i] = 1
        else
            tbNumbers[i] = 4
        end
    end
    game_state = 0
    bshow_calc = false
end

--设置游戏状态
function calcCards:setGameState(state)
    game_state = state
end

--设置历史
function calcCards:setHistory(cards)
    -- print("setHistory",cards)
    local list = string.split(cards,",")
    local c  = Card.new()
    for i = 1, #list do
        -- print("split cards ",tostring(i), tostring(tonumber("0x"..list[i])))
        local value = tonumber("0x"..list[i])
        if list[i] and value then
            local card = Card:Decode(value)
            c:init(card)
            self:subCard(c._value)
        end
    end
    -- dump(tbNumbers, "setHistory")
end

--出牌
function calcCards:subCard(card)
    if card < 0 or card > 15 then
        return
    end
    if tbNumbers[card] == nil then
        return
    end
    --{"小王","大王","3","4","5","6","7","8","9","10","J","Q","K","A","2"}实际顺序
    --{"大王","小王","2","A","K","Q","J","10","9","8","7","6","5","4","3"}显示顺序
    local pos = card
    if card == 1 then--小王
        pos = 2
    elseif card == 2 then--大王
        pos = 1
    elseif card == 14 then--A
        pos = 4
    elseif card == 15 then--2
        pos = 3
    else
        pos = 18 - card
    end
    tbNumbers[pos] = tbNumbers[pos] - 1
end

--获取单个牌剩余牌数
function calcCards:getCard(card)
    return tbNumbers[card]
end

--拼记牌器
function calcCards:setCalcs(flag)
    local show_calc = flag or false
    local layer_ui = SCENENOW["scene"].layout_effect
    if layer_ui == nil then
        return
    end
    local calc_ui = layer_ui:getChildByName("layer_calc")
    if calc_ui then
        if show_calc then
            calc_ui:removeSelf()
        else
            local st = cc.ScaleTo:create(0.2,0,1)
            local function acEnd()
                calc_ui:removeSelf()
            end
            calc_ui:runAction(cc.Sequence:create(st,cc.CallFunc:create(acEnd)))
            return
        end
    elseif show_calc == false then
        return
    end
    --非0牌个数
    local amount = 0
    if show_all then
        amount = 15
    else
        for i = 1, #tbNumbers do
            if tbNumbers[i] > 0 then
                amount = amount + 1
            end
        end
    end
    calc_ui = cc.Layer:create()
    calc_ui:setName("layer_calc")
    layer_ui:addChild(calc_ui,99)
    calc_ui:setPosition(120, 50)
    calc_ui:setAnchorPoint(cc.p(0,0.5))
    calc_ui:setScaleX(0)

    local spHead = cc.Sprite:create("ddz/card_calc/record_cards_left_text.png"):addTo(calc_ui)
    spHead:setPosition(spHead:getContentSize().width/2, spHead:getContentSize().height/2)

    local spCalcBack = cc.Scale9Sprite:create("ddz/card_calc/record_box.png"):addTo(calc_ui)
    spCalcBack:setAnchorPoint(cc.p(0,0.5))
    local _size = spCalcBack:getContentSize()
    spCalcBack:setCapInsets(cc.rect(0,0,_size.width,_size.height))
    spCalcBack:setPreferredSize(cc.size(amount*_size.width,_size.height))
    spCalcBack:setPosition(cc.p(spHead:getContentSize().width,_size.height/2))

    local spTail = cc.Sprite:create("ddz/card_calc/record_box2.png"):addTo(calc_ui)
    spTail:setPosition(spCalcBack:getPositionX()+ amount*_size.width+ spTail:getContentSize().width/2, spTail:getContentSize().height/2)

    local x = _size.width/2
    local y = _size.height/2
    for i=1, #tbNumbers do
        if show_all then
            local lb_card = cc.Label:createWithTTF(tbKind[i],"res/fonts/fzcy.ttf",20):addTo(spCalcBack)
            lb_card:setColor(cc.c3b(255,254,10))
            local lb_count = cc.Label:createWithTTF(tostring(tbNumbers[i]),"res/fonts/fzcy.ttf",20):addTo(spCalcBack)
            lb_count:setColor(cc.c3b(255,255,255))
            lb_card:setPosition(cc.p(x,y+_size.height/4))
            lb_count:setPosition(cc.p(x,y-_size.height/4))
            x = x + _size.width
        else
            if tbNumbers[i] > 0 then
                local lb_card = cc.Label:createWithTTF(tbKind[i],"res/fonts/fzcy.ttf",20):addTo(spCalcBack)
                lb_card:setColor(cc.c3b(255,254,10))
                local lb_count = cc.Label:createWithTTF(tostring(tbNumbers[i]),"res/fonts/fzcy.ttf",20):addTo(spCalcBack)
                lb_count:setColor(cc.c3b(255,255,255))
                lb_card:setPosition(cc.p(x,y+_size.height/4))
                lb_count:setPosition(cc.p(x,y-_size.height/4))
                x = x + _size.width
            end
        end
    end
    --闪出动作
    local st = cc.ScaleTo:create(0.2,1)
    calc_ui:runAction(st)
end
--更新牌数
function calcCards:updateCards(flag)
    local layer_ui = SCENENOW["scene"].layout_effect
    if layer_ui == nil then
        return
    end
    local calc_ui = layer_ui:getChildByName("layer_calc")
    if calc_ui then
        calc_ui:removeSelf()
    else
        return
    end
    local layerTips = layer_ui:getChildByName("layer_calc_tips")
    if layerTips then
        layerTips:removeSelf()
    end
    local show_all = true
    if flag~= nil then
        show_all = flag
    end
    calc_ui = cc.Layer:create()
    calc_ui:setName("layer_calc")
    layer_ui:addChild(calc_ui,99)
    calc_ui:setPosition(120, 50)
    calc_ui:setAnchorPoint(cc.p(0,0.5))

    --非0牌个数
    local amount = 0
    if show_all then
        amount = 15
    else
        for i = 1, #tbNumbers do
            if tbNumbers[i] > 0 then
                amount = amount + 1
            end
        end
    end

    local spHead = cc.Sprite:create("ddz/card_calc/record_cards_left_text.png"):addTo(calc_ui)
    spHead:setPosition(spHead:getContentSize().width/2, spHead:getContentSize().height/2)

    print("amount ",amount)

    local spCalcBack = cc.Scale9Sprite:create("ddz/card_calc/record_box.png"):addTo(calc_ui)
    spCalcBack:setAnchorPoint(cc.p(0,0.5))
    local _size = spCalcBack:getContentSize()
    spCalcBack:setCapInsets(cc.rect(0,0,_size.width,_size.height))
    spCalcBack:setPreferredSize(cc.size(amount*_size.width,_size.height))
    spCalcBack:setPosition(cc.p(spHead:getContentSize().width,_size.height/2))

    local spTail = cc.Sprite:create("ddz/card_calc/record_box2.png"):addTo(calc_ui)
    spTail:setPosition(spCalcBack:getPositionX()+ amount*_size.width+ spTail:getContentSize().width/2, spTail:getContentSize().height/2)

    local x = _size.width/2
    local y = _size.height/2

    for i=1, #tbNumbers do
        if show_all then
            local lb_card = cc.Label:createWithTTF(tbKind[i],"res/fonts/fzcy.ttf",20):addTo(spCalcBack)
            lb_card:setColor(cc.c3b(255,254,10))
            local lb_count = cc.Label:createWithTTF(tostring(tbNumbers[i]),"res/fonts/fzcy.ttf",20):addTo(spCalcBack)
            lb_count:setColor(cc.c3b(255,255,255))
            lb_card:setPosition(cc.p(x,y+_size.height/4))
            lb_count:setPosition(cc.p(x,y-_size.height/4))
            x = x + _size.width
        else
            if tbNumbers[i] > 0 then
                local lb_card = cc.Label:createWithTTF(tbKind[i],"res/fonts/fzcy.ttf",20):addTo(spCalcBack)
                lb_card:setColor(cc.c3b(255,254,10))
                local lb_count = cc.Label:createWithTTF(tostring(tbNumbers[i]),"res/fonts/fzcy.ttf",20):addTo(spCalcBack)
                lb_count:setColor(cc.c3b(255,255,255))
                lb_card:setPosition(cc.p(x,y+_size.height/4))
                lb_count:setPosition(cc.p(x,y-_size.height/4))
                x = x + _size.width
            end
        end
    end
end

--提示
function calcCards:showTips(msg)
    local layer_ui = SCENENOW["scene"].layout_effect
    if layer_ui == nil then
        return
    end
    local layerTips = layer_ui:getChildByName("layer_calc_tips")
    if layerTips then
        -- layerTips:removeAllActions()
        layerTips:removeSelf()
    end
    local calc_ui = layer_ui:getChildByName("layer_calc")
    if calc_ui then
        calc_ui:removeSelf()
    end
    layerTips = cc.Layer:create()
    layerTips:setName("layer_calc_tips")
    layer_ui:addChild(layerTips,99)
    layerTips:setPosition(120, 50)
    layerTips:setAnchorPoint(cc.p(0,0.5))

    local lb = cc.Label:createWithTTF(msg,"res/fonts/fzcy.ttf",20)
    layerTips:addChild(lb,2)

    local spBack = cc.Scale9Sprite:create("ddz/card_calc/record_text_box.png")
    layerTips:addChild(spBack, 1)
    local _size = spBack:getContentSize()
    spBack:setCapInsets(cc.rect(10,10,30,42))
    spBack:setPreferredSize(cc.size(lb:getContentSize().width+40,_size.height))
    spBack:setPosition((lb:getContentSize().width+40)/2, _size.height/2)
    layerTips:setContentSize(cc.size(lb:getContentSize().width+40,_size.height))

    lb:setPosition(spBack:getContentSize().width/2, spBack:getContentSize().height/2)

    layerTips:setPosition(480-layerTips:getContentSize().width/2, 70)
    local sq = cc.Sequence:create(cc.DelayTime:create(3),cc.Hide:create())
    layerTips:runAction(sq)
end

--记牌器是否可用
function calcCards:isVerifyCalc()
    local account = user or tonumber(UID)
    local httpurl = HttpAddr .. "/goods/queryMyGoods"
    print("queryMyGoods user:",tostring(account))
    cct.createHttRq({
            url=httpurl,
            date={
                userId=account,
                type=4
            },
            callBack=function(data)
                dump(data, "queryMyGoods")
                local gameList =json.decode(data.netData)
                --local gameList  = json.decode(xhr.response)
                dump(gameList,"queryMyGoods 1")
                if gameList["data"] == nil then
                    require("hall.GameTips"):showTips("没有记牌器可用")
                    return false
                end
                local dataAccount = gameList["data"]

                dump(dataAccount,"dataAccount")
                if dataAccount == nil or #dataAccount == 0 then
                    require("hall.GameTips"):showTips("没有记牌器可用")
                    return false
                end

                bshow_calc = not bshow_calc
                self:setCalcs(bshow_calc)
                if bshow_calc == true then
                    self:updateCards(true)
                end
            end,
            type="POST"
        })
    print(httpurl)
    return true
end

return calcCards


