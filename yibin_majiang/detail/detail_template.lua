
mrequire("base.layout_base")
mrequire("mymodules")
detail_Template = class("detail_Template", base.layout_base.LayoutBase)

function detail_Template:_do_prepare_init(other_index)
	other_index = other_index or ""
	local ui_manager = mymodules.manager:get_control_manager("ui")
	self.detail_close_btn = ui_manager:register_widget_object("detail_close_btn",other_index)
	self.detail_tips_dissove_tips_Panel_3 = ui_manager:register_widget_object("detail_tips_dissove_tips_Panel_3",other_index)
	self.detail_tips_dissove_tips_Panel_2 = ui_manager:register_widget_object("detail_tips_dissove_tips_Panel_2",other_index)
	self.detail_tips_dissove_tips_content = ui_manager:register_widget_object("detail_tips_dissove_tips_content",other_index)
	self.detail_tips_dissove_tips_Panel_1 = ui_manager:register_widget_object("detail_tips_dissove_tips_Panel_1",other_index)

	self.detail_close_btn:onClick(handler(self, self.click_detail_close_btn_event))

end

function detail_Template:click_detail_close_btn_event()
end



