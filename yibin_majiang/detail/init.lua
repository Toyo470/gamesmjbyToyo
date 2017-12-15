manager = nil

function show_choose_que(card_type)
	-- body
	local layout_object = layout.reback_layout_object("chooseque")
	layout_object:reset_card_type(card_type)
end

function show_choose_piao()
	-- body
	local layout_object = layout.reback_layout_object("choosepiao")
end

