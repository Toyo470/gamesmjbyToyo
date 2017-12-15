--
-- Author: chen
-- Date: 2016-07-15-10:26:29
--
mrequire("test.listview_test_template")

ListView_Test_Layout = class("ListView_Test_Layout",test.listview_test_template.listview_test_Template)

function ListView_Test_Layout:_do_after_init()
  self.listview_test_ListView:onEvent(handler(self,self.onEventListView_Test_Layout))
  self.listview_test_ListView:onScroll(handler(self,self.onScrollListView_Test_Layout))
  self.listview_test_ListView:setTouchEnabled(true)--启动点击

	local item_width = 100
	local item_height = 200

   ---不能滑动，不知道为什么
   local direction = self.listview_test_ListView:getDirection()--水平方向还是垂直方向
   print("----------direction---------------------------------------",direction)

   local getItemsMargin = self.listview_test_ListView:getItemsMargin()--每个子项间的间隔是多少
   print("-------------------getItemsMargin--------------------------------------",getItemsMargin)

  self.listview_test_ListView:setBounceEnabled(true)
	for other_index = 1,16 do
		  local layout_object = layout.reback_layout_object("list_item", other_index, self.listview_test_ListView)
    	layout_object:setPosition(cc.p(item_width/2 + (item_width+getItemsMargin)*(other_index-1),item_height/2))
	end

  self.listview_test_ListView:setGravity(ccui.ListViewGravity.centerVertical)
  --set items margin
  self.listview_test_ListView:setItemsMargin(2.0)

  local getInnerContainerSize = self.listview_test_ListView:getInnerContainerSize()
  dump(getInnerContainerSize,"getInnerContainerSize")


  local getLayoutSize = self.listview_test_ListView:getLayoutSize()
   dump(getLayoutSize,"getLayoutSize")
end

function ListView_Test_Layout:onEventListView_Test_Layout(event)
  print("---------------------event.name---------------------------",event.name)
end

function ListView_Test_Layout:onScrollListView_Test_Layout(event)
 -- print("---------------------event.name---------------------------",event.name)
end