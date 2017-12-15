
mrequire("base.layout_base")
mrequire("mymodules")
start_effect_Template = class("start_effect_Template", base.layout_base.LayoutBase)

function start_effect_Template:_do_prepare_init(other_index)
	other_index = other_index or ""
	local ui_manager = mymodules.manager:get_control_manager("ui")
	self.start_effect_majiang_bg = ui_manager:register_widget_object("start_effect_majiang_bg",other_index)
	self.start_effect_majiang_bg_left = ui_manager:register_widget_object("start_effect_majiang_bg_left",other_index)
	self.start_effect_majiang_left = ui_manager:register_widget_object("start_effect_majiang_left",other_index)


end



