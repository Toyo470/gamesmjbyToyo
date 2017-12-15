
mrequire("base.layout_base")
mrequire("mymodules")
room_card_Template = class("room_card_Template", base.layout_base.LayoutBase)

function room_card_Template:_do_prepare_init(other_index)
	other_index = other_index or ""
	local ui_manager = mymodules.manager:get_control_manager("ui")
	self.room_card_hand2 = ui_manager:register_widget_object("room_card_hand2",other_index)
	self.room_card_outimage3 = ui_manager:register_widget_object("room_card_outimage3",other_index)
	self.room_card_out0_image = ui_manager:register_widget_object("room_card_out0_image",other_index)
	self.room_card_hand1 = ui_manager:register_widget_object("room_card_hand1",other_index)
	self.room_card_peng0 = ui_manager:register_widget_object("room_card_peng0",other_index)
	self.room_card_hand3 = ui_manager:register_widget_object("room_card_hand3",other_index)
	self.room_card_peng2 = ui_manager:register_widget_object("room_card_peng2",other_index)
	self.room_card_dot = ui_manager:register_widget_object("room_card_dot",other_index)
	self.room_card_image1 = ui_manager:register_widget_object("room_card_image1",other_index)
	self.room_card_ting_card = ui_manager:register_widget_object("room_card_ting_card",other_index)
	self.room_card_image0 = ui_manager:register_widget_object("room_card_image0",other_index)
	self.room_card_ting_card_baset = ui_manager:register_widget_object("room_card_ting_card_baset",other_index)
	self.room_card_peng2_image = ui_manager:register_widget_object("room_card_peng2_image",other_index)
	self.room_card_peng3 = ui_manager:register_widget_object("room_card_peng3",other_index)
	self.room_card_peng3_image = ui_manager:register_widget_object("room_card_peng3_image",other_index)
	self.room_card_out0 = ui_manager:register_widget_object("room_card_out0",other_index)
	self.room_card_peng0_image = ui_manager:register_widget_object("room_card_peng0_image",other_index)
	self.room_card_ting_renyi = ui_manager:register_widget_object("room_card_ting_renyi",other_index)
	self.room_card_ting = ui_manager:register_widget_object("room_card_ting",other_index)
	self.room_card_image3 = ui_manager:register_widget_object("room_card_image3",other_index)
	self.room_card_peng1_image = ui_manager:register_widget_object("room_card_peng1_image",other_index)
	self.room_card_image2 = ui_manager:register_widget_object("room_card_image2",other_index)
	self.room_card_ting_image = ui_manager:register_widget_object("room_card_ting_image",other_index)
	self.room_card_ting_base = ui_manager:register_widget_object("room_card_ting_base",other_index)
	self.room_card_back0 = ui_manager:register_widget_object("room_card_back0",other_index)
	self.room_card_hand0 = ui_manager:register_widget_object("room_card_hand0",other_index)
	self.room_card_outimage0 = ui_manager:register_widget_object("room_card_outimage0",other_index)
	self.room_card_outimage2 = ui_manager:register_widget_object("room_card_outimage2",other_index)
	self.room_card_hand0_image = ui_manager:register_widget_object("room_card_hand0_image",other_index)
	self.room_card_ting_imageting = ui_manager:register_widget_object("room_card_ting_imageting",other_index)
	self.room_card_image = ui_manager:register_widget_object("room_card_image",other_index)
	self.room_card_back1 = ui_manager:register_widget_object("room_card_back1",other_index)
	self.room_card_back2 = ui_manager:register_widget_object("room_card_back2",other_index)
	self.room_card_outimage1 = ui_manager:register_widget_object("room_card_outimage1",other_index)
	self.room_card_peng1 = ui_manager:register_widget_object("room_card_peng1",other_index)


end



