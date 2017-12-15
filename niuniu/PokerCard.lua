--
-- Author: Johnny Lee
-- Date: 2014-07-11 11:50:08
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")

local CARD_WIDTH      = 80
local CARD_HEIGHT     = 108

local VARIETY_DIAMOND = 0x00 -- 方块
local VARIETY_CLUB    = 0x10 -- 梅花
local VARIETY_HEART   = 0x20 -- 红桃
local VARIETY_SPADE   = 0x30 -- 黑桃

local pai_path = "niuniu/newimage/card/"

-- 获得花色
local function getVariety(card)
    return bit.band(card, 0xF0)
end

-- 获得牌值
local function getValue(card)
    local value = bit.band(card, 0x0F)
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

    self.isBack_ = true

    -- 牌背

    -- self.backBg_ = display.newSprite(pai_path .. "big_card.png")
    -- self.backBg_:retain()

    local s
    if device.platform == "ios" then
        s = cc.CSLoader:createNode(cc.FileUtils:getInstance():getWritablePath() .. pai_path .. "PokerCardLayer_kong.csb"):addTo(self)
    else
        s = cc.CSLoader:createNode(pai_path .. "PokerCardLayer_kong.csb"):addTo(self)
    end

    self.backBg_ = s
    self.backBg_:retain()

    -- 帧事件
    self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.onEnterFrame))

    -- 打开node event
    self:setNodeEventEnabled(true)

end

-- 设置扑克牌面
function PokerCard:setCard(cardUint)

    if cardUint ~= nil then
        self.cardUint_  = cardUint
    end

    -- 获取值与花色
    self.cardValue_ = getValue(cardUint)
    self.cardVariety_ = getVariety(cardUint)
   
    printInfo("牌值==================花色============================")
    printInfo(self.cardValue_)
    printInfo(self.cardVariety_)

    local s
    if device.platform == "ios" then
        s = cc.CSLoader:createNode(cc.FileUtils:getInstance():getWritablePath() .. pai_path .. "PokerCardLayer.csb"):addTo(self)
    else
        s = cc.CSLoader:createNode(pai_path .. "PokerCardLayer.csb"):addTo(self)
    end

    local cardValue_iv = s:getChildByName("cardValue_iv")
    local cardVarietySmall_iv = s:getChildByName("cardVarietySmall_iv")
    local cardVariety_iv = s:getChildByName("cardVariety_iv")
    
    if self.cardVariety_ == VARIETY_DIAMOND then -- 方块

        cardValue_iv:loadTexture(pai_path .. "small_card_num_" .. tostring(self.cardValue_ ) .. ".png")
        cardVarietySmall_iv:loadTexture(pai_path .. "diamonds.png")
        cardVariety_iv:loadTexture(pai_path .. "diamonds.png")

    elseif self.cardVariety_ == VARIETY_CLUB then-- 梅花

        cardValue_iv:loadTexture(pai_path .. "small_card_num_balck_" .. tostring(self.cardValue_ ) .. ".png")
        cardVarietySmall_iv:loadTexture(pai_path .. "clubs.png")
        cardVariety_iv:loadTexture(pai_path .. "clubs.png")

    elseif self.cardVariety_ == VARIETY_HEART then-- 红桃
        
        cardValue_iv:loadTexture(pai_path .. "small_card_num_" .. tostring(self.cardValue_ ) .. ".png")
        cardVarietySmall_iv:loadTexture(pai_path .. "hearts.png")
        cardVariety_iv:loadTexture(pai_path .. "hearts.png")

    elseif self.cardVariety_ == VARIETY_SPADE then-- 黑桃

        cardValue_iv:loadTexture(pai_path .. "small_card_num_balck_" .. tostring(self.cardValue_ ) .. ".png")
        cardVarietySmall_iv:loadTexture(pai_path .. "spades.png")
        cardVariety_iv:loadTexture(pai_path .. "spades.png")

    end

    self.font_pai_ = s
    self.font_pai_:retain()

    return self

end

-- 翻牌动画
function PokerCard:flip()
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
    self.backBg_:runAction(self.flipBackAction_)
    self.delayHandle_ = scheduler.performWithDelayGlobal(handler(self, self.playSoundDelayCall_), 0.5)
    return self
end

function PokerCard:playSoundDelayCall_()
    nk.SoundManager:playSound(nk.SoundManager.FLIP_CARD)
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

    if self.font_pai_ == nil then
        self:setCard()
    end
    
    if not self.font_pai_:getParent() then
        self.font_pai_:addTo(self)
        self.font_pai_:runAction(cc.OrbitCamera:create(0, 1, 0, 0, 0, 0, 0))
    end

    return self
end

-- 显示背面
function PokerCard:showBack()
    self.isBack_ = true
    self:showBack_()
end

function PokerCard:showBack_()
    if  self.font_pai_ ~= nil then
        self.font_pai_:removeFromParent()
    end
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
    -- local posX, posY = self.frontBatch_:getPosition()
    -- if posX <= -1 or posX >= 1 then
    --     posX = 0
    --     self.frontBatch_:setPositionX(posX)
    -- end
    -- if posY <= -1 or posY >= 1 then
    --     posY = 0
    --     self.frontBatch_:setPositionY(posY)
    -- end
    -- posX = posX + math.random(-1, 1)
    -- posY = posY + math.random(-1, 1)
    -- self.frontBatch_:pos(posX, posY)

    -- return self
end

-- 停止震动扑克牌
function PokerCard:stopShake()
    if self._isShaking then
        self:unscheduleUpdate()
    end
    if font_pai_ ~= nil then
        self.font_pai_:pos(0, 0)
    end
    
    self._isShaking = false

    return self
end

-- 暗化牌
function PokerCard:addDark()
    if not self.darkOverlay_ then
        self.darkOverlay_ = display.newSprite("#poker_dark_overlay.png")
    end
    if not self.darkOverlay_:getParent() then
        self.darkOverlay_:addTo(self.frontBatch_):pos(0, 0)
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
    if  self.font_pai_ ~= nil then
       self.font_pai_:removeFromParent()
    end

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