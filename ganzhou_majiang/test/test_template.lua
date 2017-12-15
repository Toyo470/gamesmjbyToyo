
mrequire("base.layout_base")
mrequire("mymodules")
test_Template = class("test_Template", base.layout_base.LayoutBase)

function test_Template:_do_prepare_init(other_index)
	other_index = other_index or ""
	local ui_manager = mymodules.manager:get_control_manager("ui")
	self.test_Scene = ui_manager:register_widget_object("test_Scene",other_index)
	self.test_ScrollView = ui_manager:register_widget_object("test_ScrollView",other_index)
	self.test_Button = ui_manager:register_widget_object("test_Button",other_index)

	self.test_ScrollView:onEvent(handler(self, self.eventcallback_test_ScrollView))
	self.test_Button:onClick(handler(self, self.click_test_Button_event))

end

function test_Template:click_test_Button_event()
end

function test_Template:eventcallback_test_ScrollView(event)
end



