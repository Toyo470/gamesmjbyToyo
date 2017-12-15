local Scene = class("Scene")

local back_bt

local content_sv

local share_ly

local gameresultData = {"","","",""}

function Scene:CreateScene()
	print("new group_create_mj scene")

    --获取界面
    local s = cc.CSLoader:createNode("xl_majiang/common/GameResult.csb")
    SCENENOW["scene"]:addChild(s)

    --定义控件
    --返回按钮
    back_bt = s:getChildByName("back_bt")

    --结果显示区域
    content_sv = s:getChildByName("content_ly"):getChildByName("content_sv")
    for k,v in pairs(gameresultData) do

    	--定义结果显示分项
        local ly = cc.CSLoader:createNode("xl_majiang/common/GameResult_Item.csb")
        content_sv:addChild(ly)

        local item_ly = ly:getChildByName("item_ly")
        item_ly:setAnchorPoint(cc.p(0,0))
        item_ly:setPosition(219 * (k-1) + 3, 0)

    end

    --分享按钮
    share_ly = s:getChildByName("share_ly")


    --触摸事件
    local function touchEvent(sender, event)

        --触摸开始
        if event == TOUCH_EVENT_BEGAN then
            if sender ~= majiang_a_ly and sender ~= majiang_b_ly and sender ~= majiang_c_ly then 
                sender:setScale(0.9)
            end
        end

        --触摸取消
        if event == TOUCH_EVENT_CANCELED then
            sender:setScale(1.0)
        end

        --触摸结束
        if event == TOUCH_EVENT_ENDED then
            sender:setScale(1.0)

            if sender == back_bt then
                s:removeSelf()
            elseif sender == share_ly then

            end
        end
    end

    back_bt:addTouchEventListener(touchEvent)
    share_ly:addTouchEventListener(touchEvent)

end

return Scene