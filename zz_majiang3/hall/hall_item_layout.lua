-- module(..., package.seeall)

mrequire("hall.hall_item_template")
Hall_Item_Layout = class("Hall_Item_Layout", hall.hall_item_template.hall_item_Template)

function Hall_Item_Layout:_do_after_init()

end


function Hall_Item_Layout:deal_event()
	print("--------------------deal_event-------")
	dump(self.item_data,"item_data")
end

function Hall_Item_Layout:click_hall_item_bg_event(event)
		print("-----------onClick----------")
end
