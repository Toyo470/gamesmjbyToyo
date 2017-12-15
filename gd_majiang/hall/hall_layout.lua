-- module(..., package.seeall)

mrequire("hall.Hall_template")
mrequire("tips")
HallLayout = class("HallLayout", hall.Hall_template.Hall_Template)

function HallLayout:_do_after_init()
end
function HallLayout:set_game_list( game_list )

	-- if game_list == nil then
	-- 	return
	-- end
	
	-- -- body
	-- self.Hall_sv_game_list:onEvent(handler(self,self.onEventListView_Test_Layout))
 --    self.Hall_sv_game_list:onScroll(handler(self,self.onScrollListView_Test_Layout))
	-- --self.Hall_sv_game_list:setTouchEnabled(true)--启动点击

 --   ---不能滑动，不知道为什么
 --   local direction = self.Hall_sv_game_list:getDirection()--水平方向还是垂直方向
 --   print("----------direction---------------------------------------",direction)

 --   local getItemsMargin = self.Hall_sv_game_list:getItemsMargin()--每个子项间的间隔是多少
 --   print("-------------------getItemsMargin--------------------------------------",getItemsMargin)
  	
	-- self.Hall_sv_game_list:setBounceEnabled(true)

	-- for index,game_data in pairs(game_list) do
	-- 	local item_layout_object = layout.reback_layout_object("hall_item",index,self,nil,nil,true)
	--     item_layout_object:setTouchEnabled(true)
	--     item_layout_object:setContentSize(cc.size(230.00,270.00))
	-- 	self.Hall_sv_game_list:addChild(item_layout_object)
	-- 	item_layout_object.item_data = game_data
	-- end

	-- self.Hall_sv_game_list:setItemsMargin(2.0)--多了这个就可以滑动，

 --   local getItemsMargin = self.Hall_sv_game_list:getItemsMargin()--每个子项间的间隔是多少
 --   print("-------------------getItemsMargin--------------------------------------",getItemsMargin)

end

function HallLayout:click_Hall_btn_exit_event()
	print("click_Hall_btn_exit_event---------------------")
	tips.show_tips("go_hall_title","go_hall_content",handler(self,self.back),handler(self,self.cancal))

	--ui.dump_widget()
end

function HallLayout:back()
	-- body
	print("back------------------")
end

function HallLayout:cancal()
	-- body
	print("cancal------------------")
	layout.hide_layout("tips")
end

function HallLayout:onEventListView_Test_Layout(event)
 -- print("---------------------event.name---------------------------",event.name)

  if event.name == "ON_SELECTED_ITEM_END" then
  	local Index = event.target:getCurSelectedIndex()
  	print("getCurSelectedIndex------------------",Index)
  	local Item_object = event.target:getItem(Index)
	Item_object:deal_event()
  end
   	
end

function HallLayout:onScrollListView_Test_Layout(event)
 	--print("------onScrollListView_Test_Layout---------------event.name---------------------------",event.name)
end

