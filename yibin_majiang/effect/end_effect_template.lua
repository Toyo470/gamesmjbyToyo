
mrequire("base.layout_base")
mrequire("mymodules")
end_effect_Template = class("end_effect_Template", base.layout_base.LayoutBase)

function end_effect_Template:_do_prepare_init(other_index)
	other_index = other_index or ""
	local ui_manager = mymodules.manager:get_control_manager("ui")
	self.end_effect_left_side_bg = ui_manager:register_widget_object("end_effect_left_side_bg",other_index)
	self.end_effect_down_side_fj_bg = ui_manager:register_widget_object("end_effect_down_side_fj_bg",other_index)
	self.end_effect_up_side_fj_img = ui_manager:register_widget_object("end_effect_up_side_fj_img",other_index)
	self.end_effect_up_side_fj_count = ui_manager:register_widget_object("end_effect_up_side_fj_count",other_index)
	self.end_effect_right_side_fj_count = ui_manager:register_widget_object("end_effect_right_side_fj_count",other_index)
	self.end_effect_right_side_bg = ui_manager:register_widget_object("end_effect_right_side_bg",other_index)
	self.end_effect_down_side_txt = ui_manager:register_widget_object("end_effect_down_side_txt",other_index)
	self.end_effect_left_side_fj_count = ui_manager:register_widget_object("end_effect_left_side_fj_count",other_index)
	self.end_effect_up_side_zj_img = ui_manager:register_widget_object("end_effect_up_side_zj_img",other_index)
	self.end_effect_left_side_fj_bg = ui_manager:register_widget_object("end_effect_left_side_fj_bg",other_index)
	self.end_effect_left_side_zj_bg = ui_manager:register_widget_object("end_effect_left_side_zj_bg",other_index)
	self.end_effect_up_side_txt = ui_manager:register_widget_object("end_effect_up_side_txt",other_index)
	self.end_effect_up_side_zj_bg = ui_manager:register_widget_object("end_effect_up_side_zj_bg",other_index)
	self.end_effect_right_side_zj_img = ui_manager:register_widget_object("end_effect_right_side_zj_img",other_index)
	self.end_effect_down_side_zj_count = ui_manager:register_widget_object("end_effect_down_side_zj_count",other_index)
	self.end_effect_down_side_bg = ui_manager:register_widget_object("end_effect_down_side_bg",other_index)
	self.end_effect_up_side_zj_count = ui_manager:register_widget_object("end_effect_up_side_zj_count",other_index)
	self.end_effect_right_side_zj_count = ui_manager:register_widget_object("end_effect_right_side_zj_count",other_index)
	self.end_effect_left_side_fj_img = ui_manager:register_widget_object("end_effect_left_side_fj_img",other_index)
	self.end_effect_up_side_bg = ui_manager:register_widget_object("end_effect_up_side_bg",other_index)
	self.end_effect_right_side_txt = ui_manager:register_widget_object("end_effect_right_side_txt",other_index)
	self.end_effect_down_side_zj_bg = ui_manager:register_widget_object("end_effect_down_side_zj_bg",other_index)
	self.end_effect_down_side_fj_img = ui_manager:register_widget_object("end_effect_down_side_fj_img",other_index)
	self.end_effect_right_side_fj_bg = ui_manager:register_widget_object("end_effect_right_side_fj_bg",other_index)
	self.end_effect_right_side_fj_img = ui_manager:register_widget_object("end_effect_right_side_fj_img",other_index)
	self.end_effect_right_side_zj_bg = ui_manager:register_widget_object("end_effect_right_side_zj_bg",other_index)
	self.end_effect_jing_img = ui_manager:register_widget_object("end_effect_jing_img",other_index)
	self.end_effect_left_side_zj_count = ui_manager:register_widget_object("end_effect_left_side_zj_count",other_index)
	self.end_effect_effect_img_bg = ui_manager:register_widget_object("end_effect_effect_img_bg",other_index)
	self.end_effect_down_side_fj_count = ui_manager:register_widget_object("end_effect_down_side_fj_count",other_index)
	self.end_effect_left_side_txt = ui_manager:register_widget_object("end_effect_left_side_txt",other_index)
	self.end_effect_left_side_zj_img = ui_manager:register_widget_object("end_effect_left_side_zj_img",other_index)
	self.end_effect_down_side_zj_img = ui_manager:register_widget_object("end_effect_down_side_zj_img",other_index)
	self.end_effect_up_side_fj_bg = ui_manager:register_widget_object("end_effect_up_side_fj_bg",other_index)


end



