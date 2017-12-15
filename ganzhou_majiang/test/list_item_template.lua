
mrequire("mymodules")
list_item_Template = class("list_item_Template", cc.load("mvc").ViewBase)

function list_item_Template:_do_prepare_init(other_index)
	other_index = other_index or ""
	local ui_manager = mymodules.manager:get_control_manager("ui")
	self.list_item_CheckBox = ui_manager:register_widget_object("list_item_CheckBox",other_index)
	self.list_item_Node = ui_manager:register_widget_object("list_item_Node",other_index)
	self.list_item_Image = ui_manager:register_widget_object("list_item_Image",other_index)

	self.list_item_CheckBox:onEvent(handler(self, self.eventcallback_list_item_CheckBox))

end

function list_item_Template:eventcallback_list_item_CheckBox(event)
end



