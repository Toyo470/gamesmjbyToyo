-- module(..., package.seeall)

mrequire("test.test_template")
Test_Layout = class("Test_Layout", test.test_template.test_Template)

function Test_Layout:_do_after_init()

	self.test_ScrollView:setTouchEnabled(true)--启动点击
	--self.test_ScrollView:setInertiaScrollEnabled(true)--设置是否开启滚动惯性,；默认是开启的
	local size = self.test_ScrollView:getInnerContainerSize()
	dump(size,"size")

	---要做的事件就是 给子节点设置position，容器的坐下角为（0,0）点。在此基础上排列就好了。
	local item_width = 200
	local index = 1
	local space = 10
	for i = 1,6 do
		local item_layout_object = layout.reback_layout_object("item",index,self,nil,nil,true)
		self.test_ScrollView:addChild(item_layout_object)
		
		item_layout_object:setPosition(cc.p(item_width/2 + (item_width+space)*(index-1),size.height/2))
		item_layout_object.id = index
		index = index + 1
		
		print("index-------------------------",index)
	end
	size.width = (item_width+space)*(index-1)
	self.test_ScrollView:setInnerContainerSize(size)
	local size = self.test_ScrollView:getInnerContainerSize()
	dump(size,"size")
	

	local dispatcher = self:getEventDispatcher()
	local event = cc.EventTouch:new()

	--cc.EVENT_TOUCH_ONE_BY_ONE
end

function Test_Layout:eventcallback_test_ScrollView(event)
	--print("click_test_ScrollView---------------",event.name)
end