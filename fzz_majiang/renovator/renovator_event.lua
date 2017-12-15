-- require "mymodules"
-- require "common_func"

-- function deal_renovator_event(self)
-- 	--print("------------deal_mouse_click = ",self)
-- 	local ui_manager = mymodules.manager:get_control_manager("ui")
-- 	local widget_object = ui_manager:get_widget_object(self.name)
-- 	if widget_object == nil then
-- 		return
-- 	end
	
-- 	widget_object:deal_no_check_mouse_event("MouseClick")
-- 	if common_func.click_common_widget(self) == true then
-- 		return
-- 	end
	
-- 	widget_object:deal_check_mouse_event("MouseClick")
-- end