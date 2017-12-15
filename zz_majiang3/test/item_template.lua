mrequire("base.layout_base")
mrequire("mymodules")
item_Template = class("item_Template", base.layout_base.LayoutBase)

function item_Template:_do_prepare_init(other_index)
	other_index = other_index or ""
	local ui_manager = mymodules.manager:get_control_manager("ui")
	self.item_Button = ui_manager:register_widget_object("item_Button",other_index)
	self.item_Node = ui_manager:register_widget_object("item_Node",other_index)
	self.item_Image = ui_manager:register_widget_object("item_Image",other_index)

	self.item_Button:onClick(handler(self, self.click_item_Button_event))

end

function item_Template:click_item_Button_event()
end
