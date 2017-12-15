local BraodComponent  = class("BraodComponent")
local default_braod_message = "欢迎来到789广东麻将!"
local isShowing = false
local messages = {"欢迎来到789广东麻将!"}
local current_index = 1

function BraodComponent:showBraod(plane)
    local braodWidth = plane:getSize().width --跑马灯的长度   
  
    self.scrollView = cc.ScrollView:create()   
    if nil ~= self.scrollView then   
        self.scrollView:setViewSize(cc.size(braodWidth, plane:getSize().height))   

        self.scrollView:setDirection(cc.SCROLLVIEW_DIRECTION_NONE )   
        self.scrollView:setClippingToBounds(true)   
        self.scrollView:setBounceable(true)  
        self.scrollView:setTouchEnabled(false)   
    end   
    
    plane:addChild(self.scrollView)   

    self:showMessage()
end

function BraodComponent:setDefaultBraodMessage(msg)
    default_braod_message = msg
    print("setDefaultBraodMessage", tostring(default_braod_message))
end

function BraodComponent:addMessage(message)
    table.insert(messages, message)
end

function BraodComponent:showMessage()
    local message
    if table.getn(messages) > 0 then
        if current_index > table.getn(messages) then
            current_index = 1
        end
        message = messages[current_index]
    else
        message = default_braod_message
    end

    -- dump(self.scrollView:getViewSize().width, "braod test")
    -- dump(message, "braod test")

    local label = cc.Label:createWithSystemFont(message,"Microsoft YaHei",self.scrollView:getViewSize().height - 5)   
                    :setPosition(cc.p(self.scrollView:getViewSize().width, 0))   
                    :setAnchorPoint(cc.p(0,0))   
    local labelWidth = label:getContentSize().width
    local time = 5 + labelWidth / (self.scrollView:getViewSize().width / 5)

    self.scrollView:addChild(label)   

    local function showDone()
        -- table.remove(messages, 1)
        current_index = current_index + 1
        self:showMessage()
    end 

    local leftAction = cc.MoveTo:create(time, cc.p(0 - labelWidth ,0))
    local hideAction = cc.RemoveSelf:create(true)
    local callbackAction = cc.CallFunc:create(showDone)
    local seqAction = cc.Sequence:create(leftAction, hideAction, callbackAction)   
    label:runAction(cc.RepeatForever:create(seqAction))  
    
end

return BraodComponent