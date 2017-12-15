
mrequire("base.layout_base")
mrequire("mymodules")
group_result_Template = class("group_result_Template", base.layout_base.LayoutBase)

function group_result_Template:_do_prepare_init(other_index)
	other_index = other_index or ""
	local ui_manager = mymodules.manager:get_control_manager("ui")
	self.group_result_listview = ui_manager:register_widget_object("group_result_listview",other_index)
	self.group_result_result_bg = ui_manager:register_widget_object("group_result_result_bg",other_index)
	self.group_result_back_btn = ui_manager:register_widget_object("group_result_back_btn",other_index)
	self.group_result_share_button = ui_manager:register_widget_object("group_result_share_button",other_index)
	self.group_result_final_text = ui_manager:register_widget_object("group_result_final_text",other_index)
	self.group_result_image = ui_manager:register_widget_object("group_result_image",other_index)
	self.group_result_base = ui_manager:register_widget_object("group_result_base",other_index)
	self.group_result_result_background = ui_manager:register_widget_object("group_result_result_background",other_index)
	self.group_result_final_bg = ui_manager:register_widget_object("group_result_final_bg",other_index)

	self.group_result_back_btn:onClick(handler(self, self.click_group_result_back_btn_event))
	self.group_result_share_button:onClick(handler(self, self.click_group_result_share_button_event))

	if isiOSVerify then
		self.group_result_share_button:setPosition(cc.p(-960, -960)) --屏蔽分享按钮
	end

end

function group_result_Template:click_group_result_back_btn_event()
end

function group_result_Template:click_group_result_share_button_event()
end



