--
-- Author: chen
-- Date: 2016-07-04-16:17:04
--
local NiuniuManager=class("NiuniuManager")

function NiuniuManager:ctor()
end

local need_tip_flag = false
function NiuniuManager:get_need_tip_flag()
	return need_tip_flag
end

function NiuniuManager:set_need_tip_flag(tip_flag)
	need_tip_flag = tip_flag
end

return NiuniuManager