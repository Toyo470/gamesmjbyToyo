manager = nil

function show_choose_que(card_type)
	-- body
	local layout_object = layout.reback_layout_object("chooseque")
	layout_object:reset_card_type(card_type)
end

function show_choose_piao()
	-- body
	local dict = game.manager:get_game_piao_dict()
  	local account_object = account.get_player_account()
  	local recuid = account_object:get_account_id()

  	if dict[recuid] == "" then

		local layout_object = layout.reback_layout_object("choosepiao")
	end
	
end

