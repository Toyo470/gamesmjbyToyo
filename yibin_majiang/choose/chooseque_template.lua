
mrequire("base.layout_base")
mrequire("mymodules")
chooseque_Template = class("chooseque_Template", base.layout_base.LayoutBase)

function chooseque_Template:_do_prepare_init(other_index)
	other_index = other_index or ""
	local ui_manager = mymodules.manager:get_control_manager("ui")
	self.chooseque_wang = ui_manager:register_widget_object("chooseque_wang",other_index)
	self.chooseque_tong = ui_manager:register_widget_object("chooseque_tong",other_index)
	self.chooseque_suo = ui_manager:register_widget_object("chooseque_suo",other_index)

	self.chooseque_tong:onClick(handler(self, self.click_chooseque_tong_event))
	self.chooseque_wang:onClick(handler(self, self.click_chooseque_wang_event))
	self.chooseque_suo:onClick(handler(self, self.click_chooseque_suo_event))

end

function chooseque_Template:click_chooseque_tong_event()
end

function chooseque_Template:click_chooseque_wang_event()
end

function chooseque_Template:click_chooseque_suo_event()
end



