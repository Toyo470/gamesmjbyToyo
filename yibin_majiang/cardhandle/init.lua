manager = nil
last_hand_card = nil

game_up_jing_card_list = nil
game_total_jing_count = 0


function if_special_card( card_value )
  -- body


  local find_flag = false

  if cardhandle.game_up_jing_card_list ~= nil then
    dump("cardhandle.game_up_jing_card_list")
    for _,_value in pairs(cardhandle.game_up_jing_card_list) do
      if card_value == _value then
         find_flag = true
      end
    end
  end

  return find_flag

end

function refresh_user_card( other_index,user_data )
	-- body
    local account_last_an_gang_list = user_data.account_last_an_gang_list or {}
    local account_last_chi_list = user_data.account_last_chi_list or {}
    local account_last_fang_gang_dict = user_data.account_last_fang_gang_dict or {}
    local account_last_outcard = user_data.account_last_outcard or {}
    local account_last_peng_list = user_data.account_last_peng_list or {}
    local account_handcard_count = user_data.account_handcard_count or 0
    local account_last_fei_dict = user_data.account_last_fei_dict or {}


    -- dump(account_last_an_gang_list,"account_last_an_gang_list"..tostring(other_index))
    -- dump(account_last_chi_list,"account_last_chi_list"..tostring(other_index))
    -- dump(account_last_outcard,"account_last_outcard"..tostring(other_index))
    -- dump(account_last_peng_list,"account_last_peng_list"..tostring(other_index))
   	
    if account_handcard_count == 0 then
      account_handcard_count = 13
    end
    
   	zzroom.manager:reset_card_state(other_index,account_handcard_count)

    for card_val,laizi_card  in pairs(account_last_fei_dict) do
      zzroom.manager:set_fei_card(other_index,tonumber(card_val),laizi_card)
    end

    for _, card_val in pairs(account_last_an_gang_list) do
        local tbl = {}
        table.insert(tbl,card_val)
         table.insert(tbl,card_val)
          table.insert(tbl,card_val)
           table.insert(tbl,card_val)
   	    zzroom.manager:insert_porg_card(other_index,tbl)

        zzroom.manager:set_gang_type(other_index,card_val,1)
    end

    --吃
    for _,chi_list in pairs(account_last_chi_list) do
      dump(chi_list,"chi_list")
      -- local tbl = {}
      -- for card_val,_ in pairs(chi_list) do
      --     table.insert(tbl,card_val)
      -- end
  	  zzroom.manager:insert_porg_card(other_index,chi_list)
    end

    for _,card_val_list in pairs(account_last_fang_gang_dict) do
       local tbl = {}
       for _,card_val in pairs(card_val_list) do
        table.insert(tbl,card_val)
         table.insert(tbl,card_val)
          table.insert(tbl,card_val)
           table.insert(tbl,card_val)
       end

  	   zzroom.manager:insert_porg_card(other_index,tbl)
    end



    for _,card_val in pairs(account_last_peng_list) do
        local tbl = {}
        table.insert(tbl,card_val)
        table.insert(tbl,card_val)
        table.insert(tbl,card_val)

        zzroom.manager:insert_porg_card(other_index,tbl)
    end

    zzroom.manager:insert_out_card(other_index,account_last_outcard)
end
