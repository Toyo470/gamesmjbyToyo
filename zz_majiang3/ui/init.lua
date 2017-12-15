--
-- Author: chen
-- Date: 2016-07-11-16:00:31
--
manager = nil 


function dump_widget()
	if manager == nil then
		return
	end
	local get_widget_object_dict = manager:get_widget_object_dict()
	for _widget_name,_ in pairs(get_widget_object_dict)do
		print("widget_nmae-----------------",_widget_name)
	end
end