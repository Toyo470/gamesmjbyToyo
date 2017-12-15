
mrequire("base.layout_base")
mrequire("mymodules")
gitem_Template = class("gitem_Template", base.layout_base.LayoutBase)

function gitem_Template:_do_prepare_init(other_index)
	other_index = other_index or ""
	local ui_manager = mymodules.manager:get_control_manager("ui")
	-- self.gitem_angang_n = ui_manager:register_widget_object("gitem_angang_n",other_index)
	-- self.gitem_dianpao = ui_manager:register_widget_object("gitem_dianpao",other_index)
	-- self.gitem_zimo_n = ui_manager:register_widget_object("gitem_zimo_n",other_index)
	self.gitem_name = ui_manager:register_widget_object("gitem_name",other_index)
	-- self.gitem_jiepao = ui_manager:register_widget_object("gitem_jiepao",other_index)
	self.gitem_owner = ui_manager:register_widget_object("gitem_owner",other_index)
	self.gitem_bestscore = ui_manager:register_widget_object("gitem_bestscore",other_index)
	self.gitem_base = ui_manager:register_widget_object("gitem_base",other_index)
	self.gitem_bestpao = ui_manager:register_widget_object("gitem_bestpao",other_index)
	self.gitem_id = ui_manager:register_widget_object("gitem_id",other_index)
	-- self.gitem_jiepao_n = ui_manager:register_widget_object("gitem_jiepao_n",other_index)
	self.gitemImager = ui_manager:register_widget_object("gitemImager",other_index)
	-- self.gitem_minggang = ui_manager:register_widget_object("gitem_minggang",other_index)
	self.gitemImages = ui_manager:register_widget_object("gitemImages",other_index)
	self.gitem_panelbase = ui_manager:register_widget_object("gitem_panelbase",other_index)
	self.gitem_topl = ui_manager:register_widget_object("gitem_topl",other_index)
	self.gitem_imageb = ui_manager:register_widget_object("gitem_imageb",other_index)
	-- self.gitem_dianpao_n = ui_manager:register_widget_object("gitem_dianpao_n",other_index)
	self.gitem_sum = ui_manager:register_widget_object("gitem_sum",other_index)
	-- self.gitem_angang = ui_manager:register_widget_object("gitem_angang",other_index)
	-- self.gitem_minggang_n = ui_manager:register_widget_object("gitem_minggang_n",other_index)
	-- self.gitem_zimo = ui_manager:register_widget_object("gitem_zimo",other_index)
	self.gitem_but = ui_manager:register_widget_object("gitem_but",other_index)
	self.gitemImagel = ui_manager:register_widget_object("gitemImagel",other_index)
	self.lv_items = ui_manager:register_widget_object("lv_items",other_index)


end



