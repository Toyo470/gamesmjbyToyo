mrequire("player.player_template")
mrequire("tips")
mrequire("account")
mrequire("keys")

PlayerLayout = class("PlayerLayout", player.player_template.player_Template)

function PlayerLayout:_do_after_init()
	self:init_other_player()
	self:hide_zuan_icon()
	
	self.player_outline1:setVisible(false)
	self.player_outline2:setVisible(false)
	self.player_outline3:setVisible(false)

	self.player1:setVisible(false)
	self.player2:setVisible(false)
	self.player3:setVisible(false)

	self.init_fine = true

	self:reset_player()
	self:reset_que()
	self:reset_piao_icon()
end

function PlayerLayout:reset_piao_icon()
	-- body
	self.player_piao0:setVisible(false)
	self.player_piao1:setVisible(false)
	self.player_piao2:setVisible(false)
	self.player_piao3:setVisible(false)
end


function PlayerLayout:refresh_data()
	print("PlayerLayout:refresh_data()")

	local account_object = account.get_player_account()
	local gold = account_object:get_account_gold()

	if self.init_fine == true and self.player_gold0 ~= nil then
		self.player_gold0:setString(gold)
	end
end

function PlayerLayout:reset_player()
	-- body
	local account_object = account.get_player_account()
	local gold = account_object:get_account_gold()
	self.player_gold0:setString(gold)

	local name = account_object:get_account_name()
	name = require("hall.GameCommon"):formatNick(name)--调下豪哥借口格式下
	self.player_name0:setString(name)

	local icon_url = account_object:get_account_iconrul()

	local uid = account_object:get_account_id()
	local sex_num = account_object:get_account_sex()
	--print("icon_url-------------",icon_url,"----name----------",name,"sex_num---------",sex_num)
	if self.player_head0 then
	    local user_inf = {}
	    user_inf["uid"] = uid
	    user_inf["icon_url"] = icon_url
	    user_inf["sex"] = sex_num
	    user_inf["nick"] = name

	    dump(user_inf)
		require("hall.GameCommon"):setPlayerHead(user_inf,self.player_head0,69)
	end

end

function PlayerLayout:set_player_visiflag( index ,flag)
	-- body

	index = index or -1
	if index > 3 or index < 0 then
		return
	end

	local tbl = {}
	tbl[0] = self.player0
	tbl[1] = self.player1
	tbl[2] = self.player2
	tbl[3] = self.player3

	local tbl_name = {}
	tbl_name[1] = self.player_name1
	tbl_name[2] = self.player_name2
	tbl_name[3] = self.player_name3

	local tbl_gold = {}
	tbl_gold[1] = self.player_gold1
	tbl_gold[2] = self.player_gold2
	tbl_gold[3] = self.player_gold3

	tbl[index]:setVisible(flag)
	--tbl[index]:setColor(cc.c3b(255,255,255))

	tbl[1] = self.player_outline1
	tbl[2] = self.player_outline2
	tbl[3] = self.player_outline3
	if index > 0  then
		tbl[index]:setVisible(false)
		tbl_name[index]:setColor(cc.c3b(255,255,255))
		tbl_gold[index]:setColor(cc.c3b(255,255,255))
	end
end


function PlayerLayout:set_player_outline( index )
	-- body
	print("------------------set_player_outline--------index------,",index)
	index = index or -1
	if index > 3 or index < 0 then
		return
	end

	local tbl = {}
	tbl[0] = self.player0
	tbl[1] = self.player1
	tbl[2] = self.player2
	tbl[3] = self.player3
	--tbl[index]:setColor(cc.c3b(128,128,128))
	--tbl[index]:setOpacity(125)
	local tbl_name = {}
	tbl_name[1] = self.player_name1
	tbl_name[2] = self.player_name2
	tbl_name[3] = self.player_name3

	local tbl_gold = {}
	tbl_gold[1] = self.player_gold1
	tbl_gold[2] = self.player_gold2
	tbl_gold[3] = self.player_gold3

	tbl[1] = self.player_outline1
	tbl[2] = self.player_outline2
	tbl[3] = self.player_outline3
	if index > 0  then
		tbl[index]:setVisible(true)

		tbl_name[index]:setColor(cc.c3b(128,128,128))
		tbl_gold[index]:setColor(cc.c3b(128,128,128))

	end

end


function PlayerLayout:show_player( index ,names,gold,icon_url,sex_num,uid,ip)
	-- body
	print(index ,names,gold,icon_url,sex_num,uid,"PlayerLayout:show_player")
	self:set_player_visiflag(index,true)

	names = names or ""
	local name = require("hall.GameCommon"):formatNick(names)--调下豪哥借口格式下
	local url_icon = nil

	local scenes = SCENENOW['scene']

	if SCENENOW['name'] == GAMEBASENAME..".".."gameScene" then
		if scenes ~= nil then
			scenes:setPosforSeat(index,uid)
		end
	end

	if index == 1 then
		self.player_name1:setString(name)
		self.player_gold1:setString(gold)

		self.player_name1:setVisible(true)
		self.player_gold1:setVisible(true)
		url_icon = self.player_head1

	elseif index == 2 then
		self.player_name2:setString(name)
		self.player_gold2:setString(gold)

		self.player_name2:setVisible(true)
		self.player_gold2:setVisible(true)
		url_icon = self.player_head2

	elseif index == 3 then
		self.player_name3:setString(name)
		self.player_gold3:setString(gold)

		self.player_name3:setVisible(true)
		self.player_gold3:setVisible(true)

		url_icon = self.player_head3
	end

	if url_icon then
		url_icon:setVisible(true)
	    local user_inf = {}
	    user_inf["uid"] = uid
	    user_inf["icon_url"] = icon_url
	    user_inf["sex"] = sex_num
	    user_inf["nick"] = name
	    user_inf["ip"] = ip

	    -- dump(user_inf)
		require("hall.GameCommon"):setPlayerHead(user_inf,url_icon,69)
	end

end


function PlayerLayout:set_player_gold( other_index,gold_txt )
	-- body
	if other_index == 0 then
		self.player_gold0:setString(gold_txt)
	elseif other_index == 1 then
		self.player_gold1:setString(gold_txt)
	elseif other_index == 2 then
		self.player_gold2:setString(gold_txt)
	elseif other_index == 3 then
		self.player_gold3:setString(gold_txt)
	end

end

function PlayerLayout:showOtherReady( other_index )
	-- body
	if other_index == 0 then
			self.player_ready0:setVisible(true)
	elseif other_index == 1 then
			self.player_ready1:setVisible(true)
	elseif other_index == 2 then
			self.player_ready2:setVisible(true)
	elseif other_index == 3 then
			self.player_ready3:setVisible(true)
	end
end

function PlayerLayout:hideallReady()
	self.player_ready0:setVisible(false)
	self.player_ready1:setVisible(false)
	self.player_ready2:setVisible(false)
	self.player_ready3:setVisible(false)
end

function PlayerLayout:hide_zuan_icon( )
	-- body
	self.player_zuan0:setVisible(false)
	self.player_zuan1:setVisible(false)
	self.player_zuan2:setVisible(false)
	self.player_zuan3:setVisible(false)
end

function PlayerLayout:set_player_zuan( other_index )
	-- body
	if other_index == 0 then
		self.player_zuan0:setVisible(true)
	elseif other_index == 1 then
		self.player_zuan1:setVisible(true)
	elseif other_index == 2 then
		self.player_zuan2:setVisible(true)
	elseif other_index == 3 then
		self.player_zuan3:setVisible(true)
	end

end

function PlayerLayout:init_other_player()
	-- body头像相关
	self.player_head3:setVisible(false)
	self.player_name3:setVisible(false)
	self.player_gold3:setVisible(false)

	self.player_head1:setVisible(false)
	self.player_name1:setVisible(false)
	self.player_gold1:setVisible(false)

	self.player_head2:setVisible(false)
	self.player_name2:setVisible(false)
	self.player_gold2:setVisible(false)

	self:hideallReady()
	self:reset_que()
	self:reset_piao_icon()
end

function PlayerLayout:get_player_head( index )
	-- body
	if index == 0 then
		return self.player_head0
	elseif index == 1 then
		return self.player_head1
	elseif index == 2 then
		return self.player_head2
	else
		return self.player_head3
	end 
end

function PlayerLayout:reset_que()
	self.player_que0:setVisible(false)
	self.player_que1:setVisible(false)
	self.player_que2:setVisible(false)
	self.player_que3:setVisible(false)
end

function PlayerLayout:set_que(index,que_index)
	-- body
	local tx_dict = {"mahjong_wan01_bt","mahjong_tong01_bt","mahjong_suo01_bt"}
	local player_que = ui_manager:register_widget_object("player_que"..tostring(index))
	local tex = GAMEBASENAME_RES..tx_dict[tonumber(que_index)]..".png"
	player_que:loadTexture(tex)
	player_que:setVisible(true)
end