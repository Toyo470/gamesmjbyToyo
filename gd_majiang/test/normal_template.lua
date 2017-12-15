
mrequire("mymodules")
normal_Template = class("normal_Template", cc.load("mvc").ViewBase)

function normal_Template:_do_prepare_init(other_index)
	other_index = other_index or ""
	local ui_manager = mymodules.manager:get_control_manager("ui")
	self.normal_Slider_1 = ui_manager:register_widget_object("normal_Slider_1",other_index)
	self.normal_Button_1 = ui_manager:register_widget_object("normal_Button_1",other_index)
	self.normal_Scene = ui_manager:register_widget_object("normal_Scene",other_index)
	self.normal_CheckBox_1 = ui_manager:register_widget_object("normal_CheckBox_1",other_index)
	self.normal_LoadingBar_1 = ui_manager:register_widget_object("normal_LoadingBar_1",other_index)
	self.normal_Image_2 = ui_manager:register_widget_object("normal_Image_2",other_index)
	self.normal_Text_1 = ui_manager:register_widget_object("normal_Text_1",other_index)
	self.normal_TextField_1 = ui_manager:register_widget_object("normal_TextField_1",other_index)

	self.normal_Slider_1:onEvent(handler(self, self.eventcallback_normal_Slider_1))
	self.normal_Image_2:onClick(handler(self, self.click_normal_Image_2_event))
	self.normal_CheckBox_1:onEvent(handler(self, self.eventcallback_normal_CheckBox_1))
	self.normal_Text_1:onClick(handler(self, self.click_normal_Text_1_event))

end

function normal_Template:click_normal_Image_2_event()
end

function normal_Template:click_normal_Text_1_event()
end

function normal_Template:eventcallback_normal_Slider_1(event)
end

function normal_Template:eventcallback_normal_CheckBox_1(event)
end



