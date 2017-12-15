
mrequire("base.layout_base")
mrequire("mymodules")
room_card_test_Template = class("room_card_test_Template", base.layout_base.LayoutBase)

function room_card_test_Template:_do_prepare_init(other_index)
	other_index = other_index or ""
	local ui_manager = mymodules.manager:get_control_manager("ui")
	self.room_card_test_hand0 = ui_manager:register_widget_object("room_card_test_hand0",other_index)
	self.room_card_test_hand0_image = ui_manager:register_widget_object("room_card_test_hand0_image",other_index)


end



