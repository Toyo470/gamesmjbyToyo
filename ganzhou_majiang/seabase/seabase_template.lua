
mrequire("base.layout_base")
mrequire("mymodules")
seabase_Template = class("seabase_Template", base.layout_base.LayoutBase)

function seabase_Template:_do_prepare_init(other_index)
	other_index = other_index or ""
	local ui_manager = mymodules.manager:get_control_manager("ui")
	self.seabase_peo = ui_manager:register_widget_object("seabase_peo",other_index)
	self.seabase_tu2 = ui_manager:register_widget_object("seabase_tu2",other_index)
	self.seabase_Image_5 = ui_manager:register_widget_object("seabase_Image_5",other_index)
	self.seabase_card_base = ui_manager:register_widget_object("seabase_card_base",other_index)
	self.seabase_mo = ui_manager:register_widget_object("seabase_mo",other_index)
	self.seabase_bumo = ui_manager:register_widget_object("seabase_bumo",other_index)
	self.seabase_top = ui_manager:register_widget_object("seabase_top",other_index)
	self.seabase_Panel_1 = ui_manager:register_widget_object("seabase_Panel_1",other_index)
	self.seabase_Image_3 = ui_manager:register_widget_object("seabase_Image_3",other_index)
	self.seabase_effect = ui_manager:register_widget_object("seabase_effect",other_index)
	self.seabase_card = ui_manager:register_widget_object("seabase_card",other_index)
	self.seabase_yu1 = ui_manager:register_widget_object("seabase_yu1",other_index)
	self.seabase_Image_4 = ui_manager:register_widget_object("seabase_Image_4",other_index)

	self.seabase_mo:onClick(handler(self, self.click_seabase_mo_event))
	self.seabase_bumo:onClick(handler(self, self.click_seabase_bumo_event))

end

function seabase_Template:click_seabase_mo_event()
end

function seabase_Template:click_seabase_bumo_event()
end



