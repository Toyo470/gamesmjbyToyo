
mrequire("base.layout_base")
mrequire ("mymodules")
guide_Template = class("guide_Template", base.layout_base.LayoutBase)

function guide_Template:_do_prepare_init(other_index)
	other_index = other_index or ""
	local ui_manager = mymodules.manager:get_control_manager("ui")
	self.guide_fighter = ui_manager:register_widget_object("guide_fighter",other_index)


end



