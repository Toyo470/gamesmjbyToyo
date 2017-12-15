

mrequire("result.group_result_template")
GroupResultLayout = class("GroupResultLayout", result.group_result_template.group_result_Template)

function GroupResultLayout:_do_after_init()
	self.callback = nil
end


function GroupResultLayout:set_quit_game( callback )
	-- body
	self.callback = callback
end

function GroupResultLayout:reset_data(pack)
	-- body
	self.group_result_listview:removeAllChildren()
	local uid_style_dict = {}
	local game_account_data = pack["game_account_data"] or {}
	for uid,account_data in pairs(game_account_data) do
		uid_style_dict[uid] = {}
		local tbl = uid_style_dict[uid]
		tbl["dsg"] = 0
		tbl["xsg"] = 0
		tbl["hsg"] = 0
		tbl["bp"] = 0
		tbl["sp"] = 0

		tbl["account_change_chip"] = 0
	end


	local game_group_result = pack["game_group_result"] or {}
	for _,_data in pairs(game_group_result) do
		--_data一个表示一局
		for uid,uid_data in pairs(_data) do
			local tbl = uid_style_dict[uid]
			local account_conbination_style = uid_data[1] or ""
			local account_change_chip = uid_data[2] or 0
			tbl["account_change_chip"] = tbl["account_change_chip"] + account_change_chip
			
			if account_conbination_style == "dsg" then
				tbl["dsg"] = tbl["dsg"] + 1
			elseif account_conbination_style == "xsg" then
				tbl["xsg"] = tbl["xsg"] + 1
			elseif account_conbination_style == "hsg" then
				tbl["hsg"] = tbl["hsg"] + 1
			elseif account_conbination_style == "bp" then
				tbl["bp"] = tbl["bp"] + 1
			elseif account_conbination_style == "sp" then
				tbl["sp"] = tbl["sp"] + 1
			end

		end
	end


	self.group_result_listview:setBounceEnabled(true)

	local fscale = 1
	local best_score = 0
	local best_index = 0
	local index = 1

	if table.nums(game_group_result) == 5 then
		fscale = 0.8
	end

	for uid,account_data in pairs(game_account_data) do
		local item_layout_object = layout.reback_layout_object("gitem",index,self,nil,nil,true)
	    item_layout_object:setTouchEnabled(true)
	    item_layout_object:setContentSize(cc.size(218.00*fscale,364.00*fscale))
	   	item_layout_object:setpeopledata(uid,account_data)
	   	local add_chips = item_layout_object:reset_itemdata(uid_style_dict[uid])
	   	item_layout_object:setScale(fscale)
		self.group_result_listview:addChild(item_layout_object)

	    if tonumber(add_chips) > best_score then
	    	best_score = add_chips
	    	best_index = index
	    end

	    index = index + 1
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
    	require("hall.common.ShareLayer"):showShareLayer("分享结果","","screen","",self.group_result_share_button)
    elseif device.platform ~= "windows" then
    	require("hall.common.ShareLayer"):shareGroupResultForIOS(self.group_result_share_button)
    end
    
end

function GroupResultLayout:click_group_result_back_btn_event()
	self:hide_layout()

	if self.callback ~= nil and type(self.callback) == "function" then
		self.callback()
	end
end