--
-- Author: chen
-- Date: 2016-07-12-14:22:45
--
-- local Widget = ccui.Widget
-- function Widget:onClick( callback )
--     -- body
--     self:setTouchEnabled(true);
--     self:onTouch(function ( event )
--         -- body
--         if event.name=="began" then --按下
--             --todo
--             if not self.noScale then
--                 self:setScale(0.8)
--             end
            
--         elseif event.name == "cancelled" then
--             self:setScale(1.0)
--         end

--         if event.name == "ended" then
--             --todo
--             self:setScale(1.0)
--             callback(event.target)
--         end
--     end)
-- end

local ListView = ccui.ListView

function ListView:onEvent(callback)
    self:addEventListener(function(sender, eventType)
        local event = {}
        if eventType == 0 then
            event.name = "ON_SELECTED_ITEM_START"
        else
            event.name = "ON_SELECTED_ITEM_END"
        end
        event.target = sender
        callback(event)
    end)
    return self
end

function ListView:onScroll(callback)
    self:addScrollViewEventListener(function(sender, eventType)
        local event = {}
        if eventType == 0 then
            event.name = "SCROLL_TO_TOP"
        elseif eventType == 1 then
            event.name = "SCROLL_TO_BOTTOM"
        elseif eventType == 2 then
            event.name = "SCROLL_TO_LEFT"
        elseif eventType == 3 then
            event.name = "SCROLL_TO_RIGHT"
        elseif eventType == 4 then
            event.name = "SCROLLING"
        elseif eventType == 5 then
            event.name = "BOUNCE_TOP"
        elseif eventType == 6 then
            event.name = "BOUNCE_BOTTOM"
        elseif eventType == 7 then
            event.name = "BOUNCE_LEFT"
        elseif eventType == 8 then
            event.name = "BOUNCE_RIGHT"
        end
        event.target = sender
        callback(event)
    end)
    return self
end
