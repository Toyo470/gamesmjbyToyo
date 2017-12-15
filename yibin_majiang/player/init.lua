manager = nil

function  set_player_piao( other_index )
	-- body
	local player_piao = ui.manager:register_widget_object("player_piao"..tostring(other_index))
	player_piao:setVisible(true)
	print("other_index--------",other_index)
	local tex = GAMEBASENAME_RES.."mahjong_piao01_bt.png"
	print("tex--------",tex)
	player_piao:loadTexture(tex)
end

function reset_piao( dict )
	-- body
	dump(dict,"reset_piao")
	game.manager:set_game_piao_dict(dict)
	for account_id,piao_flag in pairs(dict) do
		account_id = tonumber(account_id)
		piao_flag = tonumber(piao_flag)
		

		if piao_flag == 1 then
			local other_index = zzroom.manager:get_other_index(account_id)
			player.set_player_piao(other_index)
		end

	end
end

function set_player_que( index,que_index )
	-- body
	local tx_dict = {"mahjong_wan01_bt","mahjong_tong01_bt","mahjong_suo01_bt"}
	local player_que = ui.manager:register_widget_object("player_que"..tostring(index))
	local tex = GAMEBASENAME_RES..tx_dict[tonumber(que_index)]..".png"
	player_que:loadTexture(tex)
	player_que:setVisible(true)
end

function reset_que( dict )
	-- body
	for account_id,que_index in pairs(dict) do
		account_id = tonumber(account_id)
		que_index = tonumber(que_index)
		
		if que_index == 1 or que_index == 2 or que_index ==3 then
			local other_index = zzroom.manager:get_other_index(account_id)
			player.set_player_que(other_index,que_index)
		end

	end
end