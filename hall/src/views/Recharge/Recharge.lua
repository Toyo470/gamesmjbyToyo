

local Alipay = import(".SDK.Alipay")
local Wechat = import(".SDK.Wechat")

local Recharge = class("Recharge", function()
    return display.newNode()
end)

local CONTROLS_LIST = {
    ["bg.btn_close"]  = { click = "onClose" }, -- 关闭
    ["bg.node_pay_bt.btn_pay_alipay"] = { name = "m_btn_alipay", click = "onAlipayPay" }, -- 支付宝支付
    ["bg.node_pay_bt.btn_pay_wx"] = { name = "m_btn_wechat", click = "onWechatPay" }, -- 微信支付
    ["bg.bg_list.ListView"] = { name = "m_Listview" },  -- 商品列表
}

function Recharge:ctor(data)
    --dump(cc.FileUtils:getInstance():getSearchPaths())
    -- 选中的房卡
    self.m_select_price = 1
    -- 房卡价格表
    self.m_data = data

    -- 加载界面
    local main_layer = CSBUtil.load("csb/Recharge/recharge.csb", CONTROLS_LIST, self) 
    --main_layer:setPosition(cc.p(display.cx, display.cy))
    self:addChild(main_layer)

    -- 初始化
    self:init()
end

-- 初始化
function Recharge:init()
    -- 设置默认列表项
    self.m_Listview:setItemModel(self.m_Listview:getItem(0))
    -- 清空列表
    self.m_Listview:removeAllItems()

    self:updateListView()

    if device.platform == "ios" then
        self.m_btn_alipay:setVisible(false)
        local posWx = self.m_btn_wechat:getPosition()
        self.m_btn_wechat:setPosition(cc.p((posWx.x + self.m_btn_alipay:getPosition().x)/2, posWx.y))    
    end
end

-- 刷新列表
function Recharge:updateListView()

    --local data = DataMgr:getInstance():getData("recharge")
    local data = self.m_data
    if not data then
        return
    end
    
    -- 清空列表
    self.m_Listview:removeAllItems()
    for i=1, #data do
        -- status  1：显示，0：隐藏
        if data[i].status == 1 then
            self.m_Listview:pushBackDefaultItem()
            self:updateListItem(self.m_Listview, tonumber(data[i].price) / 100, data[i].amount, i)
        end
    end
end

-- 更新列表项
function Recharge:updateListItem(listview, price, amount, tag)
    local itemCounts = table.getn(listview:getItems())
    local item = listview:getItem(itemCounts-1)
    -- 选中框
    local itemSelect = item:getChildByName("Image_Select")
    -- 按钮
    local itemBtn = item:getChildByName("bt_list_item")
    -- 房卡数量
    local label_amount = itemBtn:getChildByName("Text_shop")
    -- 房卡价格
    local label_price = itemBtn:getChildByName("Text_price")
    
    -- 房卡数量
    local strAmount = string.format("%s张",tostring(amount))
    label_amount:setString(strAmount)    
    -- 价格
    local strPrice = string.format("%s元",tostring(price))
    label_price:setString(strPrice)
    -- 按钮
    itemBtn:setTag(tag)
    itemBtn:addTouchEventListener(handler(self, self.onPriceTouchEvent))
    if tag == 1 then
        itemSelect:setVisible(true)
        itemBtn:setColor(cc.c3b(241,241,241))
    else
        itemSelect:setVisible(false)
        itemBtn:setColor(cc.c3b(255,255,255))
    end

end

-- 价格选中
function Recharge:onPriceTouchEvent(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        self.m_select_price = sender:getTag()

        local items = self.m_Listview:getItems()
        for k,v in pairs(items) do
            -- 选中框
            local itemSelect = v:getChildByName("Image_Select")
            -- 按钮
            local itemBtn = v:getChildByName("bt_list_item")
            if itemBtn == sender then
                itemSelect:setVisible(true)
                itemBtn:setColor(cc.c3b(241,241,241))
            else
                itemSelect:setVisible(false)
                itemBtn:setColor(cc.c3b(255,255,255))
            end
        end
    end
end

-- 支付宝支付
function Recharge:onAlipayPay()

    if not self.m_data then
        return
    end

    local data = self.m_data
    local p = self.m_select_price
    if p > #data then
        return
    end

    Alipay.reqOrderId(data[p].id, handler(self, self.onPayCallback))
end

-- 微信支付
function Recharge:onWechatPay()
    if not self.m_data then
        return
    end

    local data = self.m_data
    local p = self.m_select_price
    if p > #data then
        return
    end

    Wechat.reqOrderId(data[p].id, handler(self, self.onPayCallback))
end

-- 支付回调
function Recharge:onPayCallback(code)
     if code == "true" then
         -- 支付成功
         --require("hall.GameTips"):showTips("提示", "", 3, "支付成功")
         
        if SCENENOW["scene"] and SCENENOW["scene"].paySuccessHandle then
            SCENENOW["scene"]:paySuccessHandle()
        end
     elseif code == "false" then
         -- 支付失败
         self:runAction(
            cc.Sequence:create(
                cc.DelayTime:create(0.001),
                cc.CallFunc:create(
                        function( ... )
                            require("hall.GameTips"):showTips("提示", "", 3, "支付失败")                   
                        end
                    )))
     elseif code == "up" then
        -- 刷新支付 （现在主要适用ios）
        if SCENENOW["scene"] and SCENENOW["scene"].paySuccessHandle then
            SCENENOW["scene"]:paySuccessHandle()
        end
     end
end

-- 关闭
function Recharge:onClose()
    self:removeFromParent()
end

return Recharge