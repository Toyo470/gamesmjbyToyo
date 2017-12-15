
mrequire("layout")
mrequire("game")
mrequire("names")
mrequire("zzroom")

function reset_up_jing_list(up_zj_index,up_fj_index,jing_count,game_benjin_card)
	game.manager:set_up_jing_list({up_zj_index,up_fj_index})
	game.manager:set_game_benjin_card(game_benjin_card)
	local room_layout = layout.reback_layout_object("room_base")
	room_layout:init_jing_card(jing_count)

	local layout_object = layout.reback_layout_object("start_effect")
    layout_object:show_start_effect(game_benjin_card,"up_jing",after_show_up_jing)

end

function after_show_up_jing()
	local layout_object = layout.reback_layout_object("room_base")
	layout_object:show_up_jing()

	layout.hide_layout("start_effect")
end

function show_jing_result(zj_card_index,fj_card_index,jing_style,hit_jing_dict,pass_off_jing_dict,ba_jing_dict,param)
	local layout_object = layout.reback_layout_object("end_effect")
	layout_object:show_end_effect(zj_card_index,fj_card_index,jing_style,hit_jing_dict,
						pass_off_jing_dict,ba_jing_dict,refresh_jing_interface,param)
end

function refresh_jing_interface(param)
	-- body
	local round_result_dict = param[1]
	local jing_style_list = param[2]
	local cur_index = param[3]
	
	cur_index = cur_index + 1
	local hit_jing_dict = round_result_dict[names.GAME_HIT_JING_DICT] or {}
	local jing_data_dict = round_result_dict[names.GAME_JING_DATA_DICT] or {}
	local pass_off_jing_dict = round_result_dict[names.GAME_PASS_OFF_JING_DICT] or {}--麻将冲关字典
	local ba_jing_dict = round_result_dict[names.GAME_BA_JING_DICT] or {}--霸精字典

	local jing_style = jing_style_list[cur_index]

	--print("------refresh_jing_interface--",round_result_dict,jing_style_list,cur_index)
	local jing_style_count = table.getn(jing_style_list)

	if cur_index > table.getn(jing_style_list) then
		local layout_object = layout.reback_layout_object("round_result")
		layout_object:refresh_round_result(round_result_dict,jing_style_count)
	else
		local card_data_list = jing_data_dict[jing_style]
		--print("---------jing_style--",jing_style)
		local zj_card_index = card_data_list[1]
		local fj_card_index = card_data_list[2]
		local hit_jing_dict = hit_jing_dict[jing_style]

		show_jing_result(zj_card_index,fj_card_index,jing_style,hit_jing_dict,pass_off_jing_dict,ba_jing_dict,
			{round_result_dict,jing_style_list,cur_index})
	end
	print "---------------after_jing_result--------------------------------------"
end

function show_round_result(round_result_dict)
	local hit_jing_dict = round_result_dict[names.GAME_HIT_JING_DICT] or {}
	local jing_style_list = {}

	for jing_style,_ in pairs(hit_jing_dict) do
		table.insert(jing_style_list,jing_style)
	end
	print("-------------showxxxxxxxxxxxxxxxx")
	dump(jing_style_list)

	local cur_index = 0
	local jing_style_count = table.getn(jing_style_list)
	refresh_jing_interface({round_result_dict,jing_style_list,cur_index})
end