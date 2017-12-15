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
