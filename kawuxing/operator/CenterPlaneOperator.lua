local CenterPlaneOperator = class("CenterPlaneOperator")

local CHILD_NAME_TIMER_LB = "timer_lb"
local CHILD_NAME_INDICATOR_IMG = "indicator_img"

-- local scheduler_pool

local PLAY_CARD_TIME_MAX = 20
local CONTROL_TIME_MAX = 5

local timer_value = 20

-- local timer_id

-- local turn_timer_id

function CenterPlaneOperator:init(plane)
	plane:setVisible(false)
	
	local timer_lb = plane:getChildByName(CHILD_NAME_TIMER_LB)
	timer_lb:setString("00")

	local indicator_img = plane:getChildByName(CHILD_NAME_INDICATOR_IMG)
	indicator_img:loadTexture("")

	timer_lb:stopAllActions()
	indicator_img:stopAllActions()

	indicator_img:setVisible(false)
	-- if not scheduler_pool then
	-- 	--todo
	-- 	scheduler_pool = import("socket.SchedulerPool").new()
	-- end
	
	-- self:stopTimer()
end

function CenterPlaneOperator:clearGameDatas(plane)
	local timer_lb = plane:getChildByName(CHILD_NAME_TIMER_LB)
	timer_lb:setString("00")

	local indicator_img = plane:getChildByName(CHILD_NAME_INDICATOR_IMG)
	indicator_img:loadTexture("")

	timer_lb:stopAllActions()
	indicator_img:stopAllActions()

	indicator_img:setVisible(false)
	-- self:stopTimer()
end

function CenterPlaneOperator:changeTurn(playerType, plane)
	local file = "kawuxing/image/mahjong_turn_" .. playerType .. ".png"

	local indicator_img = plane:getChildByName(CHILD_NAME_INDICATOR_IMG)

	indicator_img:loadTexture(file)
end

function CenterPlaneOperator:beginPlayCard(playerType, plane)
	-- self:stopTimer()

	self:changeTurn(playerType, plane)

	local timer_lb = plane:getChildByName(CHILD_NAME_TIMER_LB)

	if not timer_lb then
		--todo
		return
	end

	local turn_img = plane:getChildByName(CHILD_NAME_INDICATOR_IMG)

	timer_lb:stopAllActions()
	turn_img:stopAllActions()

	timer_value = PLAY_CARD_TIME_MAX

	timer_lb:setString(timer_value .. "")
	turn_img:setVisible(true)

	local showTimerAc = cc.CallFunc:create(function()
			timer_value = timer_value - 1
			timer_lb:setString(timer_value .. "")

			if timer_value == 0 then
				--todo
				timer_lb:stopAllActions()
			end
		end)
	local seqAc = cc.Sequence:create(cc.DelayTime:create(1), showTimerAc)
	
	timer_lb:runAction(cc.RepeatForever:create(seqAc))

	local showTurnAc = cc.CallFunc:create(function()
			if turn_img:isVisible() then
				--todo
				turn_img:setVisible(false)
			else
				turn_img:setVisible(true)
			end

			-- if timer_value == 0 then
			-- 	--todo
			-- 	turn_img:setVisible(true)
			-- 	turn_img:stopAllActions()
			-- end
		end)

	seqAc = cc.Sequence:create(cc.DelayTime:create(0.5), showTurnAc)
	
	turn_img:runAction(cc.RepeatForever:create(seqAc))
end

-- function CenterPlaneOperator:stopTimer()
-- 	if timer_id then
-- 		--todo
-- 		scheduler_pool:clear(timer_id)

-- 		timer_id = nil
-- 	end

-- 	if turn_timer_id then
-- 		--todo
-- 		scheduler_pool:clear(turn_timer_id)

-- 		turn_timer_id = nil
-- 	end
-- end

return CenterPlaneOperator