manager = nil

hu_dict = {}
hu_card_dict = {}

function show_zimo(account_id,hu_data )
	-- body
		local other_index = zzroom.manager:get_other_index(account_id)
		hu_data = hu_data[1] or {}
		local hu_id = hu_data[1]
		local hu_people = zzroom.manager:get_user_data(hu_id)
		local tex = "" 
		if hu_id == 0 then -- 自摸胡
			tex = GAMEBASENAME_RES.."majong_zimo_bt_n.png"
		elseif hu_people ~= nil then -- 普通胡
			tex = GAMEBASENAME_RES.."majong_hu_bt02.png"
		end

		local cardImage = ccui.ImageView:create()
		cardImage:loadTexture(tex)

		local layout_object = layout.manager:get_layout_object("room_card")
		layout_object:addChild(cardImage,2000)

		if other_index == 0 then
			cardImage:setPosition(cc.p(468.32,60.92))
		elseif other_index == 1 then
			cardImage:setPosition(cc.p(809.47,335.80))
		elseif other_index == 2 then
			cardImage:setPosition(cc.p(459.97,475.14))
		elseif other_index == 3 then
			cardImage:setPosition(cc.p(161.59,333.04))
		end
end


function deal_player_hu( game_hu_account_data_one_dict )
	-- body
	dump(game_hu_account_data_one_dict,"game_hu_account_data_one_dict")
	if table.nums(game_hu_account_data_one_dict) == 0 then
		return
	end

	for account_id,hu_data in pairs(game_hu_account_data_one_dict) do
		local account_id = tonumber(account_id)
		-- dump(hu_data,"hu_data")

		show_zimo(account_id,hu_data)
		local layout_room_card = layout.manager:get_layout_object("room_card")
		local other_index = zzroom.manager:get_other_index(account_id)
		hu_data = hu_data[1] or {}
		dump(hu_data,"hu_data")

		if other_index ~= nil then
			hu_dict[other_index] = 1
			hu_card_dict[other_index] = hu_data[3]
		end
		
		if other_index ~= 0 then
			local Room_Card = zzroom.manager:get_card(other_index)
			local hand_card_dict = Room_Card["hand"] or {}
			local hand_new_dict = {}
			for _,card_value in pairs(hand_card_dict) do
				table.insert(hand_new_dict,-1)
			end
			
			local num_less = table.nums(hand_card_dict) % 3
			if num_less == 2 then
				table.remove(hand_new_dict,1)
			end

			-- if game.hu_card_dict[other_index] ~= nil then
			-- 	table.remove(hand_new_dict,1)
			-- end
			
			zzroom.manager:set_hand_card_tbl(other_index,hand_new_dict)
			
			layout_room_card:drawHandCard(other_index)

		end
		print("--------------------other_index--------------------------------------",other_index)
		if other_index == 0 then
			print("---------------------layout_room_card:remove_card_event()-------------")
			layout_room_card:remove_card_event()
		end


		--break;
	end
end