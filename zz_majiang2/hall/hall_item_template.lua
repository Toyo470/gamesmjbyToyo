
mrequire("base.layout_base")
mrequire ("mymodules")
hall_item_Template = class("hall_item_Template", base.layout_base.LayoutBase)

function hall_item_Template:_do_prepare_init(other_index)
	other_index = other_index or ""
	local ui_manager = mymodules.manager:get_control_manager("ui")
	self.hall_item_nun = ui_manager:register_widget_object("hall_item_nun",other_index)
	self.hall_item_online = ui_manager:register_widget_object("hall_item_online",other_index)
	self.hall_item_base = ui_manager:register_widget_object("hall_item_base",other_index)
	self.hall_item_new = ui_manager:register_widget_object("hall_item_new",other_index)


end



