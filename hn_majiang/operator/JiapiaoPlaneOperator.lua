local JiapiaoPlaneOperator = class("JiapiaoPlaneOperator")

local CHILD_NAME_BUPIAO_BT = "bupiao_bt"
local CHILD_NAME_JIAYIPIAO_BT = "jiayipiao_bt"
local CHILD_NAME_JIAERPIAO_BT = "jiaerpiao_bt"
local CHILD_NAME_JIASANPIAO_BT = "jiasanpiao_bt"
local CHILD_NAME_JIASIPIAO_BT = "jiasipiao_bt"
local CHILD_NAME_JIAWUPIAO_BT = "jiawupiao_bt"

function JiapiaoPlaneOperator:init(plane)
	local bupiao_bt = plane:getChildByName(CHILD_NAME_BUPIAO_BT)
	local jiayipiao_bt = plane:getChildByName(CHILD_NAME_JIAYIPIAO_BT)
	local jiaerpiao_bt = plane:getChildByName(CHILD_NAME_JIAERPIAO_BT)
	local jiasanpiao_bt = plane:getChildByName(CHILD_NAME_JIASANPIAO_BT)
	local jiasipiao_bt = plane:getChildByName(CHILD_NAME_JIASIPIAO_BT)
	local jiawupiao_bt = plane:getChildByName(CHILD_NAME_JIAWUPIAO_BT)

	local function callFunc(sender, event)
		if event == TOUCH_EVENT_ENDED then
			plane:setVisible(false)

			if sender == bupiao_bt then
				--todo
				HNMJ_CONTROLLER:requestJiapiao(0)
			elseif sender == jiayipiao_bt then
				HNMJ_CONTROLLER:requestJiapiao(1)
			elseif sender == jiaerpiao_bt then
				HNMJ_CONTROLLER:requestJiapiao(2)
			elseif sender == jiasanpiao_bt then
				HNMJ_CONTROLLER:requestJiapiao(3)
			elseif sender == jiasipiao_bt then
				HNMJ_CONTROLLER:requestJiapiao(4)
			elseif sender == jiawupiao_bt then
				HNMJ_CONTROLLER:requestJiapiao(5)
			end
		end
	end

	bupiao_bt:addTouchEventListener(callFunc)
	jiayipiao_bt:addTouchEventListener(callFunc)
	jiaerpiao_bt:addTouchEventListener(callFunc)
	jiasanpiao_bt:addTouchEventListener(callFunc)
	jiasipiao_bt:addTouchEventListener(callFunc)
	jiawupiao_bt:addTouchEventListener(callFunc)
end

return JiapiaoPlaneOperator