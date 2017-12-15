

local targetPlatform = cc.Application:getInstance():getTargetPlatform()
local fRecharge  = class("fRecharge")
local Market = require("hall.market")
local price = 0
local amount_coin = 0

function fRecharge:showOut(call_back)
    if SCENENOW["scene"] == nil then
        return
    end
    local layout = SCENENOW["scene"]:getChildByName("layout_frecharge")
    if layout then
        layout:removeSelf()
    end
    -- self:call_http()
    layout = cc.CSLoader:createNode("hall/firstRecharge/fRecharge.csb"):addTo(SCENENOW["scene"])
    layout:setName("layout_frecharge")

    local effect_light = layout:getChildByName("effect_light")
    local action_ry = cc.RotateBy:create(1, 45)
    local action = cc.RepeatForever:create(action_ry)
    effect_light:runAction(action)

    self.call_back=call_back

    local Panel_1 = layout:getChildByName("Panel_1")
    local btn_msm = layout:getChildByName("btn_msm")
    local function touchButtonEvent(sender, event)
        if event == TOUCH_EVENT_BEGAN then
            if Panel_1 ~= sender then
                sender:setScale(0.9)
            end
        end
        if event == TOUCH_EVENT_CANCELED then
            sender:setScale(1.0)
        end

        if event == TOUCH_EVENT_ENDED then
            sender:setScale(1)

            if btn_msm == sender then 

               if SCENENOW["scene"].set_hall_base then
                    SCENENOW["scene"]:set_hall_base()
                end

                local  market = Market.new(self.call_back)
                SCENENOW["scene"]:addChild(market)
                market:setName("market")

                self:remove_this()

            elseif Panel_1 == sender then
              

              --  print("不购买新手",self.call_back)
                if self.call_back then
                    self.call_back()
                end
                self:remove_this() 
            end
         end
    end

    btn_msm:addTouchEventListener(touchButtonEvent)
    Panel_1:addTouchEventListener(touchButtonEvent)
end

function fRecharge:remove_this( )
    -- bod
    if SCENENOW["scene"]:getChildByName("layout_frecharge") then
        SCENENOW["scene"]:removeChildByName("layout_frecharge")
    end
end
return fRecharge
    -- local btn_msm = layout:getChildByName("btn_msm")
    -- local btn_weixin = layout:getChildByName("btn_weixin")
    -- local txt_pay_more = layout:getChildByName("txt_pay_more")
    -- local panel = layout:getChildByName("Panel_1")
    -- if txt_pay_more then
    --     txt_pay_more:setTouchEnabled(true)
    -- end
    -- if panel then
    --     panel:setTouchEnabled(true)
    -- end
    -- self:setButton(false)

    -- local function touchButtonEvent(sender, event)
    --     if event == TOUCH_EVENT_CANCELED then
    --         if sender == txt_pay_more then
    --             sender:setScale(1)
    --         end
    --     end
    --     if event == TOUCH_EVENT_MOVED then
    --         if sender == txt_pay_more then
    --             sender:setScale(1.2)
    --         end
    --     end
    --     if event == TOUCH_EVENT_BEGAN then
    --         if sender == txt_pay_more then
    --             sender:setScale(1.2)
    --         end
    --     end
    --     if event == TOUCH_EVENT_ENDED then
    --         if sender == btn_msm then
    --             print("短信支付")
    --             require("hall.Recharge"):call_recharge(price,"P",amount_coin)
    --             layout:removeSelf()
    --         end
    --         if sender == btn_weixin then
    --             print("微信支付")
    --             require("hall.Recharge"):call_recharge(price,"W",amount_coin)
    --             layout:removeSelf()
    --         end
    --         if sender == txt_pay_more then
    --             sender:setScale(1)
    --             print("更多支付")
    --         end
    --         if sender == panel then
    --             layout:removeSelf()
    --         end
    --     end
    -- end
    -- btn_msm:addTouchEventListener(touchButtonEvent)--帮助
    -- btn_weixin:addTouchEventListener(touchButtonEvent)--帮助
    -- txt_pay_more:addTouchEventListener(touchButtonEvent)--帮助
    -- panel:addTouchEventListener(touchButtonEvent)--帮助


-- function fRecharge:setButton(flag)

--     local layout = SCENENOW["scene"]:getChildByName("layout_frecharge")
--     if layout == nil then
--         return
--     end

--     local btn_msm = layout:getChildByName("btn_msm")
--     if btn_msm then
--         btn_msm:setVisible(flag)
--     end
--     local btn_weixin = layout:getChildByName("btn_weixin")
--     if btn_weixin then
--         btn_weixin:setVisible(flag)
--     end
--     local txt_pay_more = layout:getChildByName("txt_pay_more")
--     if txt_pay_more then
--         txt_pay_more:setVisible(flag)
--     end
-- end
