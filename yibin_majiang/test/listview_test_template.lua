
mrequire("mymodules")
listview_test_Template = class("listview_test_Template", cc.load("mvc").ViewBase)

function listview_test_Template:_do_prepare_init(other_index)
	other_index = other_index or ""
	local ui_manager = mymodules.manager:get_control_manager("ui")
	self.listview_test_HelloWorld = ui_manager:register_widget_object("listview_test_HelloWorld",other_index)
	self.listview_test_ListView = ui_manager:register_widget_object("listview_test_ListView",other_index)
	self.listview_test_Scene = ui_manager:register_widget_object("listview_test_Scene",other_index)


end



