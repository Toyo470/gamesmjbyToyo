
mrequire("base.layout_base")
mrequire("mymodules")
choosepiao_Template = class("choosepiao_Template", base.layout_base.LayoutBase)

function choosepiao_Template:_do_prepare_init(other_index)
	other_index = other_index or ""
	local ui_manager = mymodules.manager:get_control_manager("ui")
	self.choosepiao_bupiao = ui_manager:register_widget_object("choosepiao_bupiao",other_index)
	self.choosepiao_paio = ui_manager:register_widget_object("choosepiao_paio",other_index)

	self.choosepiao_bupiao:onClick(handler(self, self.click_choosepiao_bupiao_event))
	self.choosepiao_paio:onClick(handler(self, self.click_choosepiao_paio_event))

end

function choosepiao_Template:click_choosepiao_bupiao_event()
end

function choosepiao_Template:click_choosepiao_paio_event()
end



