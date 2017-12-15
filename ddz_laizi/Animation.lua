
local Animation  = class("Animation")

local frameTime = 0.8

function Animation:checkAnimation( par )
    -- body
    local sp = par:getChildByName("shunanim")
    if sp then
        sp:stopAllActions()
        par:removeChildByName("shunanim")
    end
end
--春天效果
--par 父节点
function Animation:animSpring(par)
    -- body
    self:checkAnimation(par)

    local  layer = cc.Layer:create()

    local emitter1 = cc.ParticleSystemQuad:create("ddz/Game/hall_ui/effects/spring/baozha01.plist")
    emitter1:setTexture(cc.Director:getInstance():getTextureCache():addImage("ddz/Game/hall_ui/effects/spring/spring_flower.png"))
    layer:addChild(emitter1)
    emitter1:setDuration(-1)
    emitter1:setAutoRemoveOnFinish(true)
    emitter1:setPosition(cc.p(480, 200))

    local spSpring = display.newSprite("ddz/Game/hall_ui/effects/spring/spring.png")
    layer:addChild(spSpring)
    spSpring:setPosition(cc.p(480,200))

    layer:setName("shunanim")
    par:addChild(layer)
end

--报警动画
function Animation:Alarm()
    -- body
    local  layer = cc.Layer:create()
    layer:setAnchorPoint(cc.p(0,0))

    local light = display.newSprite("ddz/Game/hall_ui/effects/baojing/alarm_back.png")
    if light then
        layer:setContentSize(light:getContentSize())
        layer:addChild(light)
        -- light:setVisible(false)
        light:setPosition(cc.p(0,25))
        local dl = cc.DelayTime:create(0.1)
        local sq = cc.Sequence:create(dl,cc.Show:create(),dl,cc.Hide:create())
        light:runAction(cc.RepeatForever:create(sq))
    end

    local sp = display.newSprite("ddz/Game/hall_ui/effects/baojing/alarm_fore.png")
    if sp then
        layer:addChild(sp)
    end

    return layer
end


--火箭
--par 父节点
function Animation:animRocket(par)
    -- body
    self:checkAnimation(par)

    local lay = display.newNode():addTo(par)
    lay:setName("shunanim")
    require("hall.GameCommon"):playEffectSound("ddz/audio/new/CardType_Missile.mp3")  

    display.addSpriteFrames("ddz/Game/hall_ui/effects/rocket/huojian.plist", "ddz/Game/hall_ui/effects/rocket/huojian.png")
    local rocket = display.newSprite("#huojian_0.png", 480, 50):addTo(lay)  
    -- rocket:setRotation(15)
    local fire = display.newSprite("#huojian_1.png",rocket:getContentSize().width/2,rocket:getContentSize().height/2):addTo(rocket,-1)
    fire:setPosition(cc.p(rocket:getContentSize().width/2,-(fire:getContentSize().height/2)))
    local frames = display.newFrames("huojian_%d.png", 1, 2)
    local animation = display.newAnimation(frames, frameTime/2)
    transition.playAnimationForever(fire,animation)
    local move   = cc.MoveTo:create(2,cc.p(480,540+rocket:getContentSize().height+fire:getContentSize().height))


    local function endRocket()
        -- body
        lay:removeSelf()
    end
    local sq = cc.Sequence:create(cc.EaseExponentialInOut:create(move),cc.Hide:create())
    rocket:runAction(sq)  
end

--顺子动画
--par 父节点
--seat 位置
function Animation:animShun(par,seat)
    -- body
    self:checkAnimation(par)

    require("hall.GameCommon"):playEffectSound("ddz/audio/new/CardType_One_Line.mp3")
    local lay = display.newNode():addTo(par)
    lay:setName("shunanim")    

    seat = tonumber(seat)
    local pos = {{480,250+50},{660,350+70},{300,350+70}}
    display.addSpriteFrames("ddz/Game/hall_ui/effects/shunzi/shunzi.plist", "ddz/Game/hall_ui/effects/shunzi/shunzi.png")

    local txt = display.newSprite("#shunzi_0.png",pos[seat+1][1], pos[seat+1][2]):addTo(lay)

    local plane = display.newSprite("#shunzi_1.png",pos[seat+1][1], pos[seat+1][2]):addTo(lay)  
    -- plane:scale(0.5) 
    if seat==1 then
        plane:setFlippedX(true)
    end
    local frames = display.newFrames("shunzi_%d.png", 1, 3)
    local animation = display.newAnimation(frames, frameTime/3)
    local function complete(sender,table)
        par:removeChildByName("shunanim")
    end
    transition.playAnimationOnce(plane,animation,true,complete)
end

--顺对
--par 父节点
--seat 位置
function Animation:animDoubleLine(par)
    -- body
    self:checkAnimation(par)

    require("hall.GameCommon"):playEffectSound("ddz/audio/new/CardType_One_Line.mp3")
    local lay = display.newNode():addTo(par)
    lay:setName("shunanim")    

    display.addSpriteFrames("ddz/Game/hall_ui/effects/DoubleLine/DoubleLine.plist", "ddz/Game/hall_ui/effects/DoubleLine/DoubleLine.png")

    local pos = {480,270}
    --光
    local light = display.newSprite("#DoubleLine4.png",pos[1], pos[2]):addTo(lay)
    local txt = display.newSprite("#DoubleLine0.png",pos[1], pos[2]):addTo(lay)

    local plane = display.newSprite("#DoubleLine1.png",pos[1], pos[2]):addTo(lay)
    local frames = display.newFrames("DoubleLine%d.png", 1, 3)
    local animation = display.newAnimation(frames, (frameTime+0.2)/3)
    local function complete(sender,table)
        par:removeChildByName("shunanim")
    end
    transition.playAnimationOnce(plane,animation,true,complete)
end

--飞机
--par 父节点
--seat 位置
function Animation:animPlane(par)
    -- body
    self:checkAnimation(par)

    local lay = display.newNode():addTo(par)
    lay:setName("shunanim")
    require("hall.GameCommon"):playEffectSound("ddz/audio/new/CardType_Aircraft.mp3")

    display.addSpriteFrames("ddz/Game/hall_ui/effects/plane/plane.plist", "ddz/Game/hall_ui/effects/plane/plane.png")

    local pos = {480,270}

    local light = display.newSprite("#plane4.png",pos[1], pos[2]):addTo(lay)

    local plane = display.newSprite("#plane1.png",pos[1]-80, pos[2]+50):addTo(lay)
    -- plane:scale(0.5) 
    if seat==1 then
        plane:setFlippedX(true)
    end
    local frames = display.newFrames("plane%d.png", 1, 3)
    local animation = display.newAnimation(frames, frameTime/3)
    local function complete(sender,table)
        par:removeChildByName("shunanim")
    end
    transition.playAnimationOnce(plane,animation,true,complete)

    --光
    local txt = display.newSprite("#plane0.png",pos[1], pos[2]):addTo(lay)
end


--炸弹
--par 父节点
--seat 位置
function Animation:animBoom(par)
    -- body
    self:checkAnimation(par)

    local lay = display.newNode():addTo(par)
    lay:setName("shunanim")
    require("hall.GameCommon"):playEffectSound("ddz/audio/new/CardType_Aircraft.mp3")

    display.addSpriteFrames("ddz/Game/hall_ui/effects/boom.plist", "ddz/Game/hall_ui/effects/boom.png")

    local pos = {480,270}


    local plane = display.newSprite("#boom1.png",pos[1], pos[2]):addTo(lay)
    -- plane:scale(0.5) 
    if seat==1 then
        plane:setFlippedX(true)
    end
    local frames = display.newFrames("boom%d.png", 1, 3)
    local animation = display.newAnimation(frames, frameTime/3)
    local function complete(sender,table)
        par:removeChildByName("shunanim")
    end
    transition.playAnimationOnce(plane,animation,true,complete)

    --光
    local light = display.newSprite("#boom4.png",pos[1], pos[2]):addTo(lay)
    local txt = display.newSprite("#boom0.png",pos[1], pos[2]):addTo(lay)
end

--癞子动画
function Animation:animLaizi(card,flag)
    local isShow = flag or 1

    print("animLaizi isShow",tostring(isShow))
    local layer_laizi = SCENENOW["scene"]:getChildByName("layer_laizi_select")
    if layer_laizi then
        layer_laizi:removeSelf()
    end
    if isShow == 0 then
        return
    end
    layer_laizi = cc.CSLoader:createNode("hall/layerLaizi.csb"):addTo(SCENENOW["scene"])
    layer_laizi:setName("layer_laizi_select")
    layer_laizi:setPosition(0, 80)
    --背景
    local spRotLight = layer_laizi:getChildByName("sp_lottery")
    if spRotLight then
        local action_ry = cc.RotateBy:create(1, 45)
        local action = cc.RepeatForever:create(action_ry)

        spRotLight:runAction(action)
    end
    local spEffct = layer_laizi:getChildByName("effect_fangguang")
    if spEffct then
        spEffct:setVisible(false)
    end
    display.addSpriteFrames("ddz/Game/cards/cards.plist", "ddz/Game/cards/cards.png")
    local randCardKind = math.random(0,3)
    local randCardValue = math.random(3,15)
    local spCard = require("ddz_laizi.Card"):getCard(randCardValue,randCardKind,0,1)
    SCENENOW["scene"]:addChild(spCard)
    spCard:setPosition(480,330)
    spCard:setName("card_laizi_animation")

    local actionTime = 0.3
    local rotTimes = 1
    local angleZ = 0

    local function showLight()
        local outTime = 0.5
        if spEffct then
            spEffct:setVisible(true)
            spEffct:setScale(0.5)
            local st = cc.ScaleTo:create(outTime,4,2)
            local fo = cc.FadeOut:create(outTime)
            local sw = cc.Spawn:create(st,fo)
            spEffct:runAction(cc.Sequence:create(sw,cc.CallFunc:create(function()
                    -- layer_laizi:removeSelf()
                    -- print("animLaizi",tostring(SCENENOW["name"]))
                    -- if SCENENOW["name"] == "ddz_laizi.gameScene" then
                    --     SCENENOW["scene"]:setLaizi(card)
                    -- end
                end)))
        end
    end

    local function actionEnd()
        spCard:removeSelf()
        dump(card, "animLaizi")
        randCardKind = card["kind"]
        randCardValue = card["value"]
        spCard = require("ddz_laizi.Card"):getCard(randCardValue,randCardKind,0,1)
        rotTimes = rotTimes + 1
        layer_laizi:addChild(spCard)
        spCard:setPosition(480,330)

        local r = cc.OrbitCamera:create(actionTime-rotTimes/50,100,0,-90,90,0,0)
        spCard:runAction(cc.Sequence:create(r,cc.CallFunc:create(showLight)))
    end

    local function rotEnd()
        print("rotEnd")
        spCard:removeSelf()
        if rotTimes%2 == 1 then
            spCard = cc.Scale9Sprite:create("ddz/Game/cards/lord_card_backface_big.png")
            spCard:setCapInsets(cc.rect(12,10,45,61))
            spCard:setPreferredSize(cc.size(118,150))
            angleZ = 90
        else
            if rotTimes < 10 then
                randCardKind = math.random(0,3)
                randCardValue = math.random(3,15)
            else
                dump(card, "animLaizi")
                randCardKind = card["kind"]
                randCardValue = card["value"]
            end
            spCard = require("ddz_laizi.Card"):getCard(randCardValue,randCardKind,0,1)
            angleZ = -90
        end
        rotTimes = rotTimes + 1
        layer_laizi:addChild(spCard)
        spCard:setPosition(480,330)

        local r           = cc.OrbitCamera:create(actionTime-rotTimes/50,100,0,angleZ,180,0,0)
        local call_hide   = nil
        if rotTimes < 10 then
            call_hide   = cc.CallFunc:create(rotEnd)
        else
            call_hide   = cc.CallFunc:create(actionEnd)
        end
        local delay       = cc.DelayTime:create(actionTime-rotTimes/50)
        local se          = cc.Sequence:create(delay,call_hide)
        local sp          = cc.Spawn:create(r,se)
        spCard:runAction(sp)
    end

    local function rotBackEnd()
        spCard:removeSelf()
        spCard = cc.Scale9Sprite:create("ddz/Game/cards/lord_card_backface_big.png")
        spCard:setCapInsets(cc.rect(12,10,45,61))
        spCard:setPreferredSize(cc.size(118,150))
        angleZ = 90
        rotTimes = rotTimes + 1
        layer_laizi:addChild(spCard)
        spCard:setPosition(480,330)

        local r           = cc.OrbitCamera:create(actionTime-rotTimes/50,100,0,angleZ,180,0,0)
        local call_hide   = cc.CallFunc:create(rotEnd)
        local delay       = cc.DelayTime:create(actionTime-rotTimes/50)
        local se          = cc.Sequence:create(delay,call_hide)
        local sp          = cc.Spawn:create(r,se)
        spCard:runAction(sp)
    end

    local r           = cc.OrbitCamera:create(actionTime/2,100,0,0,90,0,0)
    local call_hide   = cc.CallFunc:create(rotBackEnd)
    local delay       = cc.DelayTime:create(actionTime/2)
    local se          = cc.Sequence:create(delay,call_hide)
    local sp          = cc.Spawn:create(r,se)
    spCard:runAction(sp)
end

return Animation