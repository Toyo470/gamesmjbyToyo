
mrequire("base.layout_base")
mrequire("mymodules")
player_Template = class("player_Template", base.layout_base.LayoutBase)

function player_Template:_do_prepare_init(other_index)
	other_index = other_index or ""
	local ui_manager = mymodules.manager:get_control_manager("ui")
	self.player_name1 = ui_manager:register_widget_object("player_name1",other_index)
	self.player2 = ui_manager:register_widget_object("player2",other_index)
	self.player_head3 = ui_manager:register_widget_object("player_head3",other_index)
	self.player_ready3 = ui_manager:register_widget_object("player_ready3",other_index)
	self.player_ready0 = ui_manager:register_widget_object("player_ready0",other_index)
	self.player_outline2 = ui_manager:register_widget_object("player_outline2",other_index)
	self.player_zuan2 = ui_manager:register_widget_object("player_zuan2",other_index)
	self.player_name3 = ui_manager:register_widget_object("player_name3",other_index)
	self.player_head0 = ui_manager:register_widget_object("player_head0",other_index)
	self.player1 = ui_manager:register_widget_object("player1",other_index)
	self.player_outline3 = ui_manager:register_widget_object("player_outline3",other_index)
	self.player_head2 = ui_manager:register_widget_object("player_head2",other_index)
	self.player_piao0 = ui_manager:register_widget_object("player_piao0",other_index)
	self.player_zuan0 = ui_manager:register_widget_object("player_zuan0",other_index)
	self.player_gold3 = ui_manager:register_widget_object("player_gold3",other_index)
	self.player_piao1 = ui_manager:register_widget_object("player_piao1",other_index)
	self.player_gold0 = ui_manager:register_widget_object("player_gold0",other_index)
	self.player_piao2 = ui_manager:register_widget_object("player_piao2",other_index)
	self.player_name0 = ui_manager:register_widget_object("player_name0",other_index)
	self.player_head1 = ui_manager:register_widget_object("player_head1",other_index)
	self.player_que2 = ui_manager:register_widget_object("player_que2",other_index)
	self.player_ready1 = ui_manager:register_widget_object("player_ready1",other_index)
	self.player_zuan1 = ui_manager:register_widget_object("player_zuan1",other_index)
	self.player_zuan3 = ui_manager:register_widget_object("player_zuan3",other_index)
	self.player_ready2 = ui_manager:register_widget_object("player_ready2",other_index)
	self.player_que3 = ui_manager:register_widget_object("player_que3",other_index)
	self.player3 = ui_manager:register_widget_object("player3",other_index)
	self.player_gold2 = ui_manager:register_widget_object("player_gold2",other_index)
	self.player_piao3 = ui_manager:register_widget_object("player_piao3",other_index)
	self.player_gold1 = ui_manager:register_widget_object("player_gold1",other_index)
	self.player_que1 = ui_manager:register_widget_object("player_que1",other_index)
	self.player_outline1 = ui_manager:register_widget_object("player_outline1",other_index)
	self.player_que0 = ui_manager:register_widget_object("player_que0",other_index)
	self.player_name2 = ui_manager:register_widget_object("player_name2",other_index)
	self.player0 = ui_manager:register_widget_object("player0",other_index)


end



