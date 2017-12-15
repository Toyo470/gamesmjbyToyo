manager = nil

--显示玩家可进行的操作
function show_handle_view( result,ming_or_an,card )
	-- body
	print("result,ming_or_an,card",result,ming_or_an,card)
	local layout_object = layout.reback_layout_object("room_handle_view")
	if layout_object ~= nil then
		layout_object:reset_state(result,ming_or_an,card)
	end
end

	-- local result = {}
	-- result['h'] = 0x040
	-- result['pg'] = 0x010
	-- handleview.show_handle_view(result,0,33)


--显示其他玩家的操作界面结果。这个是用来显示其他玩家操作结果的喔。
--比如其他玩家杠了，我们就拿这个来显示
function show_handle_result( index,result_tbl,show_time )
	local layout_object = layout.reback_layout_object("room_handleresult")
	if layout_object ~= nil then
		layout_object:reset_result_item( index,result_tbl,show_time)
	end
end
