
mrequire("base.layout_base")
mrequire("mymodules")
tips_Template = class("tips_Template", base.layout_base.LayoutBase)

function tips_Template:_do_prepare_init(other_index)
	other_index = other_index or ""
	local ui_manager = mymodules.manager:get_control_manager("ui")
	self.tips_Panel_1 = ui_manager:register_widget_object("tips_Panel_1",other_index)
	self.tips_Panel_51 = ui_manager:register_widget_object("tips_Panel_51",other_index)
	self.tips_Panel_3 = ui_manager:register_widget_object("tips_Panel_3",other_index)
	self.tips_btn_sure = ui_manager:register_widget_object("tips_btn_sure",other_index)
	self.tips_Panel_2 = ui_manager:register_widget_object("tips_Panel_2",other_index)
	self.tips_content = ui_manager:register_widget_object("tips_content",other_index)
	self.tips_btn_cancel = ui_manager:register_widget_object("tips_btn_cancel",other_index)
	self.tips_title = ui_manager:register_widget_object("tips_title",other_index)
	self.tips_Panel_5 = ui_manager:register_widget_object("tips_Panel_5",other_index)

	self.tips_btn_sure:onClick(handler(self, self.click_tips_btn_sure_event))
	self.tips_btn_cancel:onClick(handler(self, self.click_tips_btn_cancel_event))

end

function tips_Template:click_tips_btn_sure_event()
end

function tips_Template:click_tips_btn_cancel_event()
end



