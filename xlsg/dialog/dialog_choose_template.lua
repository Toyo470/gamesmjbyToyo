
mrequire("base.layout_base")
mrequire("mymodules")
dialog_choose_Template = class("dialog_choose_Template", base.layout_base.LayoutBase)

function dialog_choose_Template:_do_prepare_init(other_index)
	other_index = other_index or ""
	local ui_manager = mymodules.manager:get_control_manager("ui")
	self.dialog_choose_btn_buqiang = ui_manager:register_widget_object("dialog_choose_btn_buqiang",other_index)
	self.dialog_choose_btn_4 = ui_manager:register_widget_object("dialog_choose_btn_4",other_index)
	self.dialog_choose_Image_27 = ui_manager:register_widget_object("dialog_choose_Image_27",other_index)
	self.dialog_choose_btn_qiang = ui_manager:register_widget_object("dialog_choose_btn_qiang",other_index)
	self.dialog_choose_qiangfeng = ui_manager:register_widget_object("dialog_choose_qiangfeng",other_index)
	self.dialog_choose_bei4 = ui_manager:register_widget_object("dialog_choose_bei4",other_index)
	self.dialog_choose_txt1 = ui_manager:register_widget_object("dialog_choose_txt1",other_index)
	self.dialog_choose_bei2 = ui_manager:register_widget_object("dialog_choose_bei2",other_index)
	self.dialog_choose_txt2 = ui_manager:register_widget_object("dialog_choose_txt2",other_index)
	self.dialog_choose_btn_1 = ui_manager:register_widget_object("dialog_choose_btn_1",other_index)
	self.dialog_choose_Image_22 = ui_manager:register_widget_object("dialog_choose_Image_22",other_index)
	self.dialog_choose_btn_3 = ui_manager:register_widget_object("dialog_choose_btn_3",other_index)
	self.dialog_choose_txt4 = ui_manager:register_widget_object("dialog_choose_txt4",other_index)
	self.dialog_choose_txt3 = ui_manager:register_widget_object("dialog_choose_txt3",other_index)
	self.dialog_choose_bei3 = ui_manager:register_widget_object("dialog_choose_bei3",other_index)
	self.dialog_choose_Image_28 = ui_manager:register_widget_object("dialog_choose_Image_28",other_index)
	self.dialog_choose_btn_not = ui_manager:register_widget_object("dialog_choose_btn_not",other_index)
	self.dialog_choose_qiangzang = ui_manager:register_widget_object("dialog_choose_qiangzang",other_index)
	self.dialog_choose_bei1 = ui_manager:register_widget_object("dialog_choose_bei1",other_index)
	self.dialog_choose_btn_2 = ui_manager:register_widget_object("dialog_choose_btn_2",other_index)


end



