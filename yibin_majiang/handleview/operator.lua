
function fei_operator( account_id,v_data_list )
	-- body
	dump(v_data_list,"fei_operator")
	local other_index =  zzroom.manager:get_other_index(tonumber(account_id))

	local des_uid = v_data_list[1]
	local laizi_dict = v_data_list[2]
	local card_value = v_data_list[3]

	if other_index == 0 then
		zzroom.manager:set_fei_card(other_index,tonumber(card_value),laizi_dict[1])
		zzroom.manager:remove_hand_card(other_index,tonumber(card_value),1)
		zzroom.manager:remove_hand_card(other_index,laizi_dict[1],1)
	else
		zzroom.manager:set_fei_card(other_index,tonumber(card_value),laizi_dict[1])
		zzroom.manager:remove_hand_card(other_index,0,1)
		zzroom.manager:remove_hand_card(other_index,0,1)
	end

	local roomhandle =  layout.manager:get_layout_object("room_card")
    if roomhandle ~= nil then
     	roomhandle:drawHandCard(other_index)
    end

end


function ti_operator( account_id,v_data_list )
	-- body
	dump(v_data_list,"ti_operator")
	local other_index =  zzroom.manager:get_other_index(tonumber(account_id))
	local ti_cardvalue_dict = v_data_list[2] or {}
	local ti_cardvalue = ti_cardvalue_dict[1] or 0
	if ti_cardvalue == 0 then
		return
	end

	--if other_index == 0 then
		zzroom.manager:remove_hand_card(other_index,tonumber(ti_cardvalue),1)
		zzroom.manager:set_fei_card(other_index,tonumber(ti_cardvalue),nil)
		zzroom.manager:insert_porg_card(other_index,{ti_cardvalue,ti_cardvalue,ti_cardvalue})
	--else

	--end
	local roomhandle =  layout.manager:get_layout_object("room_card")
    if roomhandle ~= nil then
     	roomhandle:drawHandCard(other_index)
    end
end