
mrequire("base.layout_base")
mrequire("mymodules")
detail_base_Template = class("detail_base_Template", base.layout_base.LayoutBase)

function detail_base_Template:_do_prepare_init(other_index)
	other_index = other_index or ""
	local ui_manager = mymodules.manager:get_control_manager("ui")
	self.detail_base_people_base = ui_manager:register_widget_object("detail_base_people_base",other_index)
	self.detail_base_sum = ui_manager:register_widget_object("detail_base_sum",other_index)
	self.detail_base_base2 = ui_manager:register_widget_object("detail_base_base2",other_index)
	self.detail_base_id = ui_manager:register_widget_object("detail_base_id",other_index)
	self.detail_base_regain_btn = ui_manager:register_widget_object("detail_base_regain_btn",other_index)
	self.detail_base_name = ui_manager:register_widget_object("detail_base_name",other_index)
	self.detail_base_result_room_Image_2 = ui_manager:register_widget_object("detail_base_result_room_Image_2",other_index)
	self.detail_base_base = ui_manager:register_widget_object("detail_base_base",other_index)
	self.detail_base_detail_btn = ui_manager:register_widget_object("detail_base_detail_btn",other_index)
	self.detail_base_result_regain_image = ui_manager:register_widget_object("detail_base_result_regain_image",other_index)

	self.detail_base_regain_btn:onClick(handler(self, self.click_detail_base_regain_btn_event))
	self.detail_base_detail_btn:onClick(handler(self, self.click_detail_base_detail_btn_event))

end

function detail_base_Template:click_detail_base_regain_btn_event()
end

function detail_base_Template:click_detail_base_detail_btn_event()
end



