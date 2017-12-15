
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
return Animation