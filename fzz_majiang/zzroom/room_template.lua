
mrequire("base.layout_base")
mrequire("mymodules")
room_Template = class("room_Template", base.layout_base.LayoutBase)

function room_Template:_do_prepare_init(other_index)
	other_index = other_index or ""
	local ui_manager = mymodules.manager:get_control_manager("ui")
	self.room_head0 = ui_manager:register_widget_object("room_head0",other_index)
	self.room_zuan0 = ui_manager:register_widget_object("room_zuan0",other_index)
	self.room_timertxt = ui_manager:register_widget_object("room_timertxt",other_index)
	self.room_timertxt_shadow = ui_manager:register_widget_object("room_timertxt_shadow",other_index)
	self.room_head2 = ui_manager:register_widget_object("room_head2",other_index)
	self.room_outline2 = ui_manager:register_widget_object("room_outline2",other_index)
	self.room_head3 = ui_manager:register_widget_object("room_head3",other_index)
	self.room_zuan1 = ui_manager:register_widget_object("room_zuan1",other_index)
	self.room_gold2 = ui_manager:register_widget_object("room_gold2",other_index)
	self.room_head1 = ui_manager:register_widget_object("room_head1",other_index)
	self.room_name2 = ui_manager:register_widget_object("room_name2",other_index)
	self.room_gold3 = ui_manager:register_widget_object("room_gold3",other_index)
	self.room_player0 = ui_manager:register_widget_object("room_player0",other_index)
	self.room_timetop = ui_manager:register_widget_object("room_timetop",other_index)
	self.room_outline3 = ui_manager:register_widget_object("room_outline3",other_index)
	self.room_ready1 = ui_manager:register_widget_object("room_ready1",other_index)
	self.room_name1 = ui_manager:register_widget_object("room_name1",other_index)
	self.room_btn_exit = ui_manager:register_widget_object("room_btn_exit",other_index)
	self.room_ready0 = ui_manager:register_widget_object("room_ready0",other_index)
	self.room_gold1 = ui_manager:register_widget_object("room_gold1",other_index)
	self.room_player2 = ui_manager:register_widget_object("room_player2",other_index)
	self.room_player3 = ui_manager:register_widget_object("room_player3",other_index)
	self.room_zuan2 = ui_manager:register_widget_object("room_zuan2",other_index)
	self.room_ready3 = ui_manager:register_widget_object("room_ready3",other_index)
	self.room_outline1 = ui_manager:register_widget_object("room_outline1",other_index)
	self.room_bei = ui_manager:register_widget_object("room_bei",other_index)
	self.room_dong = ui_manager:register_widget_object("room_dong",other_index)
	self.room_name3 = ui_manager:register_widget_object("room_name3",other_index)
	self.room_ready2 = ui_manager:register_widget_object("room_ready2",other_index)
	self.room_timebase = ui_manager:register_widget_object("room_timebase",other_index)
	self.room_zuan3 = ui_manager:register_widget_object("room_zuan3",other_index)
	self.room_nan = ui_manager:register_widget_object("room_nan",other_index)
	self.room_xi = ui_manager:register_widget_object("room_xi",other_index)
	self.room_player1 = ui_manager:register_widget_object("room_player1",other_index)
	self.room_gold0 = ui_manager:register_widget_object("room_gold0",other_index)
	self.room_name0 = ui_manager:register_widget_object("room_name0",other_index)
	self.room_txt_txt = ui_manager:register_widget_object("room_txt_txt",other_index)

	self.sp_clock = ui_manager:register_widget_object("sp_clock",other_index)

	self.room_btn_exit:onClick(handler(self, self.click_room_btn_exit_event))

end

function room_Template:click_room_btn_exit_event()
end



