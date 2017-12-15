-- module(..., package.seeall)
--require("names.init")
mrequire("test.item_template")
Item_Layout = class("Test_Layout", test.item_template.item_Template)

function Item_Layout:_do_after_init()
	self.item_Image:setTouchEnabled(false)
end

function Item_Layout:click_item_Button_event()
	--print("-----click_item_Button_event-------------")
	print("---click_item_Button_event--------self.name_------",self.name_,self.id)
	local id = self.id
	--print("self.item_Button---------------",self.item_Button:getName())
	--printError("click_item_Button_event")
	
	if id == 1 then
		layout.hide_layout("test")
		layout.reback_layout_object("normal")
	end
	
end