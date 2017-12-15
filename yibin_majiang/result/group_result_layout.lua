

mrequire("result.group_result_template")
GroupResultLayout = class("GroupResultLayout", result.group_result_template.group_result_Template)

function GroupResultLayout:_do_after_init()
	self.callback = nil
   
end

function GroupResultLayout:set_quit_game( callback )
	-- body
	self.callback = callback
end

function GroupResultLayout:reset_data(pack_tbl)
	-- body


	--玩家输赢统计
	local palyer_change_chip = {}

	--小胡统计
	local player_xiaohu_dict = {}
    
    --大胡统计
	local player_bighu_dict = {}

	--暗杠次数统计
	local player_angang_dict = {}

	--放杠次数统计
	local player_fanggang_dict = {}

	--明杠次数统计
	local player_minggang_dict = {}

	local game_group_result = pack_tbl["game_group_result"] or {}
	for _,game_data in pairs(game_group_result) do

		for player_id,palyer_data in pairs(game_data) do
			player_id = tonumber(player_id)

			-- #胡类型
			local hu_data = palyer_data[1] or {}
			player_xiaohu_dict[player_id] = player_xiaohu_dict[player_id] or 0
			player_bighu_dict[player_id] = player_bighu_dict[player_id] or 0

			for _,hu_item in pairs(hu_data) do
				local hu_detail = hu_item[2] or {}
				for _,hu_style in pairs(hu_detail) do
					if hu_style == result.XIAO_HU then
						player_xiaohu_dict[player_id] = player_xiaohu_dict[player_id] + 1
					else
						player_bighu_dict[player_id] = player_bighu_dict[player_id] + 1
					end
				end

			end

			--#暗杠类型
			local angang_data = palyer_data[2] or {}
			player_angang_dict[player_id] = player_angang_dict[player_id] or 0
			for _,card_value in pairs(angang_data) do
				player_angang_dict[player_id] = player_angang_dict[player_id] + 1
			end



			--#放杠
			local fanggang_data =  palyer_data[3] or {}
			player_fanggang_dict[player_id] = player_fanggang_dict[player_id] or 0
			for _,gang_list in pairs(fanggang_data) do
				for _,card_value in pairs(gang_list) do
					player_fanggang_dict[player_id] = player_fanggang_dict[player_id] + 1
				end
			end

			--明杠
			local minggang_data =  palyer_data[4] or {}
			player_minggang_dict[player_id] = player_minggang_dict[player_id] or 0
			for _,card_value in pairs(minggang_data) do
				player_minggang_dict[player_id] = player_minggang_dict[player_id] + 1
			end

			--输赢数
			local chang_chip = palyer_data[5] or 0
			palyer_change_chip[player_id] = palyer_change_chip[player_id] or 0
			palyer_change_chip[player_id] = palyer_change_chip[player_id] + chang_chip
		end
	end


	dump(palyer_change_chip,"palyer_change_chip")
	self.group_result_listview:setBounceEnabled(true)
	local last_dianpao = 0
	local last_index = 0
	local best_score = 0
	local best_index = 0

	local game_account_data = pack_tbl["game_account_data"] or {}
	local index = 1
	for player_id,player_data in pairs(game_account_data) do
		player_id = tonumber(player_id)
		local item_layout_object = layout.reback_layout_object("gitem",index,self,nil,nil,true)
	    item_layout_object:setTouchEnabled(true)
	    item_layout_object:setContentSize(cc.size(218.00,364.00))
	    item_layout_object:reset_itemdata(player_id,player_data)

	    -- local rec_dianpao,
	    item_layout_object:set_da_hu(player_bighu_dict[player_id])
	    item_layout_object:set_xiao_hu(player_xiaohu_dict[player_id])

	    item_layout_object:set_angang(player_angang_dict[player_id])
	    item_layout_object:set_minggang(player_minggang_dict[player_id])
	    item_layout_object:set_jiegang(player_fanggang_dict[player_id])
	    print("palyer_change_chip[player_id]-----",palyer_change_chip[player_id],"---player_id--",player_id)
	    local add_chips = item_layout_object:set_sum(palyer_change_chip[player_id])
	    -- if tonumber(rec_dianpao) > last_dianpao then
	    -- 	last_dianpao = rec_dianpao
	    -- 	last_index = index
	    -- end

	    if tonumber(add_chips) > best_score then
	    	best_score = add_chips
	    	best_index = index
	    end

		self.group_result_listview:addChild(item_layout_object)

		index = index + 1
	end

	--设置最佳炮手
	if last_index ~= 0 then
		local item_object = layout.manager:get_layout_object("gitem",last_index)
		if item_object ~= nil then
			item_object:set_gitem_bestpao(true)
		end
	end
   
   --设置最大赢家
	if best_index ~= 0 then
		local item_object = layout.manager:get_layout_object("gitem",best_index)
		if item_object ~= nil then
			item_object:set_gitem_bestscore(true)
		end
	end

    self.group_result_listview:setItemsMargin(2.0)--多了这个就可以滑动，
end

function GroupResultLayout:click_group_result_share_button_event()
	--分享。。
	--print("-----------------click_group_result_share_button_event-----------------------")
	--require("hall.common.ShareLayer"):showShareLayer("分享结果","","screen","")
	self.group_result_share_button:setTouchEnabled(false)
	if device.platform == "android" then
    	require("hall.common.ShareLayer"):showShareLayer("分享结果","","screen","",share_ly)
    elseif device.platform ~= "windows" then
    	require("hall.common.ShareLayer"):shareGroupResultForIOS(share_ly)
    end
    
end

function GroupResultLayout:click_group_result_back_btn_event()
	self:hide_layout()

	if self.callback ~= nil and type(self.callback) == "function" then
		self.callback()
	end
end