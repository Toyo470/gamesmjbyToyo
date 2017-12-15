local JiapiaoPlaneOperator = class("JiapiaoPlaneOperator")

local CHILD_NAME_BUPIAO_BT = "bupiao_bt"
local CHILD_NAME_JIAYIPIAO_BT = "jiayipiao_bt"
local CHILD_NAME_JIAERPIAO_BT = "jiaerpiao_bt"

function JiapiaoPlaneOperator:init(plane)
	local bupiao_bt = plane:getChildByName(CHILD_NAME_BUPIAO_BT)
	local jiayipiao_bt = plane:getChildByName(CHILD_NAME_JIAYIPIAO_BT)
	local jiaerpiao_bt = plane:getChildByName(CHILD_NAME_JIAERPIAO_BT)

	local function callFunc(sender, event)
		if event == TOUCH_EVENT_ENDED then
			plane:setVisible(false)

			if sender == bupiao_bt then
				--todo
				YKMJ_CONTROLLER:requestJiapiao(0)
			elseif sender == jiayipiao_bt then
				YKMJ_CONTROLLER:requestJiapiao(1)
			elseif sender == jiaerpiao_bt then
				YKMJ_CONTROLLER:requestJiapiao(2)
			end
		end
	end

	bupiao_bt:addTouchEventListener(callFunc)
	jiayipiao_bt:addTouchEventListener(callFunc)
	jiaerpiao_bt:addTouchEventListener(callFunc)
end

return JiapiaoPlaneOperator