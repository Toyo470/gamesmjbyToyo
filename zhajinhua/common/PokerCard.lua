--
-- Author: Johnny Lee
-- Date: 2014-07-11 11:50:08
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
local pai_path="zhajinhua/res/NewImg/card/"
local CARD_WIDTH      = 96
local CARD_HEIGHT     = 119

local VARIETY_DIAMOND = 0x00 -- 方块
local VARIETY_CLUB    = 0x10 -- 梅花
local VARIETY_HEART   = 0x20 -- 红桃
local VARIETY_SPADE   = 0x30 -- 黑桃


-- 获得花色
local function getVariety(card)
    print("获取花色",bit.band(card, 0xF0))
    return bit.band(card, 0xF0)
end

-- 获得牌值
local function getValue(card)
    local value = bit.band(card, 0x0F)
    print("value111",value)
    if value == 1 then
        value = 14
    end
    return value
end

local getFrame = display.newSpriteFrame

local PokerCard = class("PokerCard", function ()
    return display.newNode()
end)

function PokerCard:ctor()
    -- 初始数值
    self.cardUint_    = 0x11
    self.cardValue_   = 14
    self.cardVariety_ = 3
    self.isBack_ = true

    -- 牌背
    self.backBg_ = display.newSprite("#zhajinhua/res/NewImg/card/".."big_bgcard.png"):pos(0, -4)
    self.backBg_:setScaleX(-1)
    self.backBg_:retain()

    -- 初始化batch node
   -- self.frontBatch_ = display.newBatchNode("zhajinhua/res/common_texture.png"):pos(0, 0)
    self.frontBatch_ = display.newBatchNode("zhajinhua/res/NewImg/card/Plist.png"):pos(0, 0)
    self.frontBatch_:retain()

    -- 前背景
    self.frontBg_         = display.newSprite("#zhajinhua/res/NewImg/card/".."big_card.png"):pos(0, -4):addTo(self.frontBatch_)
    
    -- 大花色
    self.bigVarietySpr_   = display.newSprite("#zhajinhua/res/NewImg/card/".."diamonds.png"):pos(-30, -10):addTo(self.frontBatch_)
    
    -- 小花色
    self.smallVarietySpr_ = display.newSprite("#zhajinhua/res/NewImg/card/".."diamonds.png"):setScale(0.26):pos(-24, 4):addTo(self.frontBatch_)
    
    -- 数字
    self.numberSpr_       = display.newSprite("#zhajinhua/res/NewImg/card/".."small_card_num_14.png"):pos(-24, 32):addTo(self.frontBatch_)

    -- 帧事件
    self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.onEnterFrame))

    -- 打开node event
    self:setNodeEventEnabled(true)
end

-- 设置扑克牌面
function PokerCard:setCard(cardUint)
    local flag=false
    print("cardUint111",tostring(cardUint))
--    if self.cardUint_ == cardUint then
--        return self
--    end
    self.cardUint_ = cardUint

    -- 获取值与花色
    self.cardValue_ = getValue(cardUint)
    self.cardVariety_ = getVariety(cardUint)
    -- 设置纹理
    if self.cardVariety_ == VARIETY_DIAMOND then
        self.smallVarietySpr_:setSpriteFrame(getFrame(pai_path.."diamonds.png"))
        self.smallVarietySpr_:setScale(0.26)
        self.numberSpr_:setSpriteFrame(getFrame(pai_path.."small_card_num_"..self.cardValue_..".png"))
        if self.cardValue_==11 then
            self.bigVarietySpr_:setSpriteFrame(getFrame(pai_path.."cards_jake.png"))
        elseif self.cardValue_==12 then
            self.bigVarietySpr_:setSpriteFrame(getFrame(pai_path.."cards_queen.png"))
        elseif self.cardValue_==13 then
            self.bigVarietySpr_:setSpriteFrame(getFrame(pai_path.."cards_king.png"))
        else
            flag=true
            self.bigVarietySpr_:setSpriteFrame(getFrame(pai_path.."diamonds.png"))
            self.bigVarietySpr_:setScale(0.72):pos(54.06,41.96)

        end
    elseif self.cardVariety_ == VARIETY_HEART then
        self.smallVarietySpr_:setSpriteFrame(getFrame(pai_path.."hearts.png"))
        self.numberSpr_:setSpriteFrame(getFrame(pai_path.."small_card_num_"..self.cardValue_..".png"))
        if self.cardValue_==11 then
            self.bigVarietySpr_:setSpriteFrame(getFrame(pai_path.."cards_jake.png"))
        elseif self.cardValue_==12 then
            self.bigVarietySpr_:setSpriteFrame(getFrame(pai_path.."cards_queen.png"))
        elseif self.cardValue_==13 then
            self.bigVarietySpr_:setSpriteFrame(getFrame(pai_path.."cards_king.png"))
        else
            flag=true
            self.bigVarietySpr_:setSpriteFrame(getFrame(pai_path.."hearts.png"))
            self.bigVarietySpr_:setScale(0.72):pos(54.06,41.96)
        end
    elseif self.cardVariety_ == VARIETY_CLUB then
        self.smallVarietySpr_:setSpriteFrame(getFrame(pai_path.."clubs.png"))
        self.numberSpr_:setSpriteFrame(getFrame(pai_path.."small_card_num_balck_"..self.cardValue_..".png"))
        if self.cardValue_==11 then
            self.bigVarietySpr_:setSpriteFrame(getFrame(pai_path.."cards_jake.png"))
        elseif self.cardValue_==12 then
            self.bigVarietySpr_:setSpriteFrame(getFrame(pai_path.."cards_queen.png"))
        elseif self.cardValue_==13 then
            self.bigVarietySpr_:setSpriteFrame(getFrame(pai_path.."cards_king.png"))
        else
            flag=true
            self.bigVarietySpr_:setSpriteFrame(getFrame(pai_path.."clubs.png"))
            self.bigVarietySpr_:setScale(0.72):pos(54.06,41.96)
        end
    elseif self.cardVariety_ == VARIETY_SPADE then
        self.smallVarietySpr_:setSpriteFrame(getFrame(pai_path.."26spades.png"))
        self.numberSpr_:setSpriteFrame(getFrame(pai_path.."small_card_num_balck_"..self.cardValue_..".png"))
        if self.cardValue_==11 then
            self.bigVarietySpr_:setSpriteFrame(getFrame(pai_path.."cards_jake.png"))
        elseif self.cardValue_==12 then
            self.bigVarietySpr_:setSpriteFrame(getFrame(pai_path.."cards_queen.png"))
        elseif self.cardValue_==13 then
            self.bigVarietySpr_:setSpriteFrame(getFrame(pai_path.."cards_king.png"))
        else
            flag=true
            self.bigVarietySpr_:setSpriteFrame(getFrame(pai_path.."26spades.png"))
            self.bigVarietySpr_:setScale(0.72):pos(54.06,41.96)
        end
    end
    
    local bigVarietySize = self.bigVarietySpr_:getContentSize()
    if flag then
        self.bigVarietySpr_:pos(CARD_WIDTH * 0.5 - bigVarietySize.width * 0.5-2, bigVarietySize.height * 0.5 - CARD_HEIGHT * 0.5+2)
    else
        print("bigVarietySize.width",bigVarietySize.width)
        print("bigVarietySize.height",bigVarietySize.height)
        self.bigVarietySpr_:pos(CARD_WIDTH * 0.5 - bigVarietySize.width*0.5-15 , bigVarietySize.height * 0.5 - CARD_HEIGHT*0.5+13)
    end

    return self
end

-- 翻牌动画
function PokerCard:flip()
    -- if self.isBack_ == false then
    --     return
    -- end
    self.backBg_:stopAllActions()
    self.isBack_ = false
    if not self.flipBackAction_ then
        local delayAction = cc.DelayTime:create(0.2)
        local orbitAction = cc.OrbitCamera:create(0.25, 1, 0, 0, 90, 0, 0)
        local callback = cc.CallFunc:create(handler(self, self.onBackActionComplete_))
        -- local array = cc.Array:create()
        -- array:addObject(delayAction)
        -- array:addObject(orbitAction)
        -- array:addObject(callback)
        self.flipBackAction_ = cc.Sequence:create(delayAction,orbitAction,callback)
        self.flipBackAction_:retain()
    end

    if not self.flipFrontAction_ then
        local orbitAction = cc.OrbitCamera:create(0.25, 1, 0, -90, 90, 0, 0)
        local callback = cc.CallFunc:create(handler(self, self.onFrontActionComplete_))
        -- local array = cc.Array:create()
        -- array:addObject(orbitAction)
        -- array:addObject(callback)
        self.flipFrontAction_ = cc.Sequence:create(orbitAction,callback)
        self.flipFrontAction_:retain()
    end

    -- 首先显示牌背，0.5s后开始翻牌动画
    self:showBack_()
    -- self.backBg_:removeAllActions()
    self.backBg_:runAction(self.flipBackAction_)
    self.delayHandle_ = scheduler.performWithDelayGlobal(handler(self, self.playSoundDelayCall_), 0.5)
    return self
end

function PokerCard:playSoundDelayCall_()
    -- nk.SoundManager:playSound(nk.SoundManager.FLIP_CARD)
end

function PokerCard:onBackActionComplete_()
    self:showFront();
    self.frontBatch_:runAction(self.flipFrontAction_)
end

function PokerCard:onFrontActionComplete_()
    self.backBg_:runAction(cc.OrbitCamera:create(0, 1, 0, 0, 0, 0, 0))
    self.frontBatch_:runAction(cc.OrbitCamera:create(0, 1, 0, 0, 0, 0, 0))
end

-- 显示正面
function PokerCard:showFront()
    self.isBack_ = false
    self.backBg_:removeFromParent()
    if not self.frontBatch_:getParent() then
        self.frontBatch_:addTo(self)
        self.frontBatch_:runAction(cc.OrbitCamera:create(0, 1, 0, 0, 0, 0, 0))
    end

    return self
end

-- 显示背面
function PokerCard:showBack()
    self.isBack_ = true
    self:showBack_()
end

function PokerCard:showBack_()
    self.frontBatch_:removeFromParent()
    if not self.backBg_:getParent() then
        self.backBg_:addTo(self)
        self.backBg_:runAction(cc.OrbitCamera:create(0, 1, 0, 0, 0, 0, 0))
    end
    return self
end

function PokerCard:isBack()
    return self.isBack_
end

-- 震动扑克牌
function PokerCard:shake()
    if self._isShaking then
        self:unscheduleUpdate()
    end
    self:scheduleUpdate();
    self._isShaking = true

    return self
end

function PokerCard:onEnterFrame(dt)
    local posX, posY = self.frontBatch_:getPosition()
    if posX <= -1 or posX >= 1 then
        posX = 0
        self.frontBatch_:setPositionX(posX)
    end
    if posY <= -1 or posY >= 1 then
        posY = 0
        self.frontBatch_:setPositionY(posY)
    end
    posX = posX + math.random(-1, 1)
    posY = posY + math.random(-1, 1)
    self.frontBatch_:pos(posX, posY)

    return self
end

-- 停止震动扑克牌
function PokerCard:stopShake()
    if self._isShaking then
        self:unscheduleUpdate()
    end
    self.frontBatch_:pos(0, 0)
    self._isShaking = false

    return self
end

-- 暗化牌
function PokerCard:addDark()
    if not self.darkOverlay_ then
        self.darkOverlay_ = display.newSprite("#"..pai_path.."head_balck_img.png")
    end
    print("darkOverlay_",type(self.darkOverlay_))
    print("frontBatch_",type(self.frontBatch_))
    if not self.darkOverlay_:getParent() then
        if self.isBack_ == true then
            self.darkOverlay_:addTo(self.backBg_):pos(44, 61)
        else
            self.darkOverlay_:addTo(self.frontBatch_):pos(0, 0)
        end
    end
    return self
end

-- 移除暗化
function PokerCard:removeDark()
    if self.darkOverlay_ then
        self.darkOverlay_:removeFromParent()
        self.darkOverlay_ = nil
    end
end

-- 获取扑克宽度（不包括阴影）
function PokerCard:getCardWidth()
    return CARD_WIDTH
end

-- 获取扑克高度（不包括阴影）
function PokerCard:getCardHeight()
    return CARD_HEIGHT
end

-- 重置扑克牌（移除舞台时自动调用）
function PokerCard:onCleanup()
    -- 恢复扑克
    self:stopShake()
    self:removeDark()

    -- 移除scheduler的handle
    if self.delayHandle_ then
        scheduler.unscheduleGlobal(self.delayHandle_)
    end

    -- 移除扑克视图
    self.frontBatch_:removeFromParent()
    self.backBg_:removeFromParent()
end

-- 清理
function PokerCard:dispose()
    -- 释放retain的对象
    self.backBg_:release()
    self.frontBatch_:release()
    if self.flipBackAction_ then
        self.flipBackAction_:release()
    end
    if self.flipFrontAction_ then
        self.flipFrontAction_:release()
    end

    -- 移除node事件
    self:unscheduleUpdate();
    self:removeAllNodeEventListeners()

    -- 移除scheduler的handle
    if self.delayHandle_ then
        scheduler.unscheduleGlobal(self.delayHandle_)
    end
end

return PokerCard