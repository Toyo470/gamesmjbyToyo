
mrequire("base.layout_base")
mrequire("mymodules")
card_Template = class("card_Template", base.layout_base.LayoutBase)

function card_Template:_do_prepare_init(other_index)
	other_index = other_index or ""
	local ui_manager = mymodules.manager:get_control_manager("ui")
	self.card2_p2 = ui_manager:register_widget_object("card2_p2",other_index)
	self.card4_p2 = ui_manager:register_widget_object("card4_p2",other_index)
	self.card1_p2 = ui_manager:register_widget_object("card1_p2",other_index)
	self.card0_p0 = ui_manager:register_widget_object("card0_p0",other_index)
	self.card4_p0 = ui_manager:register_widget_object("card4_p0",other_index)
	self.card3_p0 = ui_manager:register_widget_object("card3_p0",other_index)
	self.card4_p1 = ui_manager:register_widget_object("card4_p1",other_index)
	self.card0_p2 = ui_manager:register_widget_object("card0_p2",other_index)
	self.card1_p1 = ui_manager:register_widget_object("card1_p1",other_index)
	self.card3_p2 = ui_manager:register_widget_object("card3_p2",other_index)
	self.card2_p1 = ui_manager:register_widget_object("card2_p1",other_index)
	self.card1_p0 = ui_manager:register_widget_object("card1_p0",other_index)
	self.card3_p1 = ui_manager:register_widget_object("card3_p1",other_index)
	self.card2_p0 = ui_manager:register_widget_object("card2_p0",other_index)
	self.card_base = ui_manager:register_widget_object("card_base",other_index)
	self.card0_p1 = ui_manager:register_widget_object("card0_p1",other_index)

end




