
mrequire("base.layout_base")
mrequire("mymodules")
result_effect_Template = class("result_effect_Template", base.layout_base.LayoutBase)

function result_effect_Template:_do_prepare_init(other_index)
	other_index = other_index or ""
	local ui_manager = mymodules.manager:get_control_manager("ui")
	self.result_effect_item = ui_manager:register_widget_object("result_effect_item",other_index)
	self.result_effect_bg = ui_manager:register_widget_object("result_effect_bg",other_index)
	self.result_effect_base = ui_manager:register_widget_object("result_effect_base",other_index)
	self.result_effect_center = ui_manager:register_widget_object("result_effect_center",other_index)
	self.result_effect_card = ui_manager:register_widget_object("result_effect_card",other_index)
	self.result_effect_value = ui_manager:register_widget_object("result_effect_value",other_index)


end



