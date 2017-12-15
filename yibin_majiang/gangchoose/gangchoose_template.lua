
mrequire("base.layout_base")
mrequire("mymodules")
gangchoose_Template = class("gangchoose_Template", base.layout_base.LayoutBase)

function gangchoose_Template:_do_prepare_init(other_index)
	other_index = other_index or ""
	local ui_manager = mymodules.manager:get_control_manager("ui")
	self.gangchoose_2c = ui_manager:register_widget_object("gangchoose_2c",other_index)
	self.gangchoose_card4 = ui_manager:register_widget_object("gangchoose_card4",other_index)
	self.gangchoose_1p = ui_manager:register_widget_object("gangchoose_1p",other_index)
	self.gangchoose_2chi = ui_manager:register_widget_object("gangchoose_2chi",other_index)
	self.gangchoose_2g = ui_manager:register_widget_object("gangchoose_2g",other_index)
	self.gangchoose_txt2 = ui_manager:register_widget_object("gangchoose_txt2",other_index)
	self.gangchoose_1chi = ui_manager:register_widget_object("gangchoose_1chi",other_index)
	self.gangchoose_2peng = ui_manager:register_widget_object("gangchoose_2peng",other_index)
	self.gangchoose_1h = ui_manager:register_widget_object("gangchoose_1h",other_index)
	self.gangchoose_Image_70 = ui_manager:register_widget_object("gangchoose_Image_70",other_index)
	self.gangchoose_im4 = ui_manager:register_widget_object("gangchoose_im4",other_index)
	self.gangchoose_im2 = ui_manager:register_widget_object("gangchoose_im2",other_index)
	self.gangchoose_1gang = ui_manager:register_widget_object("gangchoose_1gang",other_index)
	self.gangchoose_2hu = ui_manager:register_widget_object("gangchoose_2hu",other_index)
	self.gangchoose_1b = ui_manager:register_widget_object("gangchoose_1b",other_index)
	self.gangchoose_2bu = ui_manager:register_widget_object("gangchoose_2bu",other_index)
	self.gangchoose_card1 = ui_manager:register_widget_object("gangchoose_card1",other_index)
	self.gangchoose_1bu = ui_manager:register_widget_object("gangchoose_1bu",other_index)
	self.gangchoose_close = ui_manager:register_widget_object("gangchoose_close",other_index)
	self.gangchoose_1hu = ui_manager:register_widget_object("gangchoose_1hu",other_index)
	self.gangchoose_txt1 = ui_manager:register_widget_object("gangchoose_txt1",other_index)
	self.gangchoose_Image_71 = ui_manager:register_widget_object("gangchoose_Image_71",other_index)
	self.gangchoose_2gang = ui_manager:register_widget_object("gangchoose_2gang",other_index)
	self.gangchoose_2h = ui_manager:register_widget_object("gangchoose_2h",other_index)
	self.gangchoose_Image_72 = ui_manager:register_widget_object("gangchoose_Image_72",other_index)
	self.gangchoose_card2 = ui_manager:register_widget_object("gangchoose_card2",other_index)
	self.gangchoose_im1 = ui_manager:register_widget_object("gangchoose_im1",other_index)
	self.gangchoose_2b = ui_manager:register_widget_object("gangchoose_2b",other_index)
	self.gangchoose_1peng = ui_manager:register_widget_object("gangchoose_1peng",other_index)
	self.gangchoose_1c = ui_manager:register_widget_object("gangchoose_1c",other_index)
	self.gangchoose_2p = ui_manager:register_widget_object("gangchoose_2p",other_index)
	self.gangchoose_card3 = ui_manager:register_widget_object("gangchoose_card3",other_index)
	self.gangchoose_im3 = ui_manager:register_widget_object("gangchoose_im3",other_index)
	self.gangchoose_1g = ui_manager:register_widget_object("gangchoose_1g",other_index)

	self.gangchoose_close:onClick(handler(self, self.click_gangchoose_close_event))
	self.gangchoose_card3:onClick(handler(self, self.click_gangchoose_card3_event))
	self.gangchoose_card4:onClick(handler(self, self.click_gangchoose_card4_event))

end

function gangchoose_Template:click_gangchoose_close_event()
end

function gangchoose_Template:click_gangchoose_card3_event(target)
end

function gangchoose_Template:click_gangchoose_card4_event(target)
end

