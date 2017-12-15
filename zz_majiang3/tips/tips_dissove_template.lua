
mrequire("base.layout_base")
mrequire("mymodules")
tips_dissove_Template = class("tips_dissove_Template", base.layout_base.LayoutBase)

function tips_dissove_Template:_do_prepare_init(other_index)
	other_index = other_index or ""
	local ui_manager = mymodules.manager:get_control_manager("ui")
	self.tips_dissove_tips_Panel_1 = ui_manager:register_widget_object("tips_dissove_tips_Panel_1",other_index)
	self.tips_dissove_tips_Panel_51 = ui_manager:register_widget_object("tips_dissove_tips_Panel_51",other_index)
	self.tips_dissove_tips_player3 = ui_manager:register_widget_object("tips_dissove_tips_player3",other_index)
	self.tips_dissove_tips_content = ui_manager:register_widget_object("tips_dissove_tips_content",other_index)
	self.tips_dissove_tips_player2 = ui_manager:register_widget_object("tips_dissove_tips_player2",other_index)
	self.tips_dissove_tips_btn_cancel = ui_manager:register_widget_object("tips_dissove_tips_btn_cancel",other_index)
	self.tips_dissove_tips_player1 = ui_manager:register_widget_object("tips_dissove_tips_player1",other_index)
	self.tips_dissove_tips_Panel_5 = ui_manager:register_widget_object("tips_dissove_tips_Panel_5",other_index)
	self.tips_dissove_tips_btn_sure = ui_manager:register_widget_object("tips_dissove_tips_btn_sure",other_index)
	self.tips_dissove_time = ui_manager:register_widget_object("tips_dissove_time",other_index)
	self.tips_dissove_tips_title = ui_manager:register_widget_object("tips_dissove_tips_title",other_index)
	self.tips_dissove_clock_2 = ui_manager:register_widget_object("tips_dissove_clock_2",other_index)
	self.tips_dissove_tips_Panel_2 = ui_manager:register_widget_object("tips_dissove_tips_Panel_2",other_index)
	self.tips_dissove_tips_Panel_3 = ui_manager:register_widget_object("tips_dissove_tips_Panel_3",other_index)

	self.tips_dissove_tips_btn_sure:onClick(handler(self, self.click_tips_dissove_tips_btn_sure_event))
	self.tips_dissove_tips_btn_cancel:onClick(handler(self, self.click_tips_dissove_tips_btn_cancel_event))

end

function tips_dissove_Template:click_tips_dissove_tips_btn_sure_event()
end

function tips_dissove_Template:click_tips_dissove_tips_btn_cancel_event()
end



