

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

	self.group_result_listview:setBounceEnabled(true)
	local last_dianpao = 0
	local last_index = 0

	local best_score = 0
	local best_index = 0

	if pack.playercount > 0 then
		for index,player_data in pairs(pack.playerlist) do
			local item_layout_object = layout.reback_layout_object("gitem",index,self,nil,nil,true)
		    item_layout_object:setTouchEnabled(true)
		    item_layout_object:setContentSize(cc.size(218.00,364.00))
		    local rec_dianpao,add_chips = item_layout_object:reset_itemdata(index,player_data)
		    if tonumber(rec_dianpao) > last_dianpao then
		    	last_dianpao = rec_dianpao
		    	last_index = index
		    end

		    if tonumber(add_chips) > best_score then
		    	best_score = add_chips
		    	best_index = index
		    end

			self.group_result_listview:addChild(item_layout_object)
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