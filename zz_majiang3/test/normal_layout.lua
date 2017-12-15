--
-- Author: chen
-- Date: 2016-07-14-11:51:54
--

mrequire("test.normal_template")
Normal_Layout = class("Normal_Layout",test.normal_template.normal_Template)-- client.lua

function Normal_Layout:_do_after_init()
	--self:set_update_flag(true)
end

function Normal_Layout:update()
	print("----------------Normal_Layout:update()-----------------")
end

function Normal_Layout:click_normal_Image_2_event()
	print("------------------------click_normal_Image_2_event---------------------")
end

function Normal_Layout:click_normal_Text_1_event()
	print("------------------------click_normal_Text_1_event---------------------")
end

function Normal_Layout:eventcallback_normal_Slider_1(event)
	local percent = event.target:getPercent()--这里是获取滚动条
	print("-------------------------eventcallback_normal_Slider_1----------percent---",percent)

	self.normal_LoadingBar_1:setPercent(percent)--这个是修改进度条的进度
end

function Normal_Layout:eventcallback_normal_CheckBox_1(event)
	if  event.name == "selected" then
		print("selected------------")

		layout.hide_layout("normal")
		layout.reback_layout_object("test")
	end

	if  event.name == "unselected" then
		print("unselected------------")
	end
end

