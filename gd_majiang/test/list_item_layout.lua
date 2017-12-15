--
-- Author: chen
-- Date: 2016-07-15-10:27:10
--
mrequire("test.list_item_template")

List_Item_Layout = class("List_Item_Layout",test.list_item_template.list_item_Template)

function List_Item_Layout:_do_after_init()
	
end

function List_Item_Layout:eventcallback_list_item_CheckBox(event)
	print( event.name,"---------------event.name----------")
end