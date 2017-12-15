mrequire("zzroom.room_template")
mrequire("tips")
mrequire("account")

ZZRoom_Layout = class("ZZRoom_Layout", zzroom.room_template.room_Template)

function ZZRoom_Layout:_do_after_init()
	self.room_p1:setVisible(false)
	self.room_p2:setVisible(false)
	self.room_p3:setVisible(false)
	self.room_p4:setVisible(false)

	local path_bg = music.manager:get_bg_music_path()
	audio.playMusic(path_bg, true)

	self.qiangbei_dict = {
		{self.room_q0,self.room_bein0,self.room_bei0},
		{self.room_q1,self.room_bein1,self.room_bei1},
		{self.room_q2,self.room_bein2,self.room_bei2},
		{self.room_q3,self.room_bein3,self.room_bei3},
		{self.room_q4,self.room_bein4,self.room_bei4},
	}

	self:reset()
	self:resetBeiNum()
end

function ZZRoom_Layout:reset()

	--玩家只有2到5个人，除去自己，那么其他玩家就只有1到4个人。

	self.room_zuan0:setVisible(false)
	self.room_zuan1:setVisible(false)
	self.room_zuan2:setVisible(false)
	self.room_zuan3:setVisible(false)
	self.room_zuan4:setVisible(false)


	self.room_rd0:setVisible(false)
	self.room_rd1:setVisible(false)
	self.room_rd2:setVisible(false)
	self.room_rd3:setVisible(false)
	self.room_rd4:setVisible(false)
end


function ZZRoom_Layout:reset_player()
	-- body
	local account_object = account.get_player_account()
	local gold = account_object:get_account_gold()
	self.room_gold0:setString(gold)

	local name = account_object:get_account_name()
	name = require("hall.GameCommon"):formatNick(name)--调下豪哥借口格式下
	self.room_name0:setString(name)

	local icon_url = account_object:get_account_iconrul()
	local uid = account_object:get_account_id()
	local sex_num = account_object:get_account_sex()
	
	if self.room_head0 then
	    local user_inf = {}
	    user_inf["uid"] = uid
	    user_inf["icon_url"] = icon_url
	    user_inf["sex"] = sex_num
	    user_inf["nick"] = name

	    dump(user_inf)
		require("hall.GameCommon"):setPlayerHead(user_inf,self.room_head0,69)
	end
	
	local scenes = SCENENOW['scene']
	if SCENENOW['name'] == "xlsg.gameScene" then
		if scenes ~= nil then
			scenes:setPosforSeat(0,uid)
		end
	end

end


function ZZRoom_Layout:show_player( index ,names,gold,icon_url,sex_num,uid)
	-- body
	print(index ,names,gold,icon_url,sex_num,uid,"ZZRoom_Layout:show_player")
	--self:set_player_visiflag(index,true)

	if index == 0 then
		return 
	end
	
	local scenes = SCENENOW['scene']
	if SCENENOW['name'] == "xlsg.gameScene" then
		if scenes ~= nil then
			scenes:setPosforSeat(index,uid)
		end
	end

	names = names or ""
	local name = require("hall.GameCommon"):formatNick(names)--调下豪哥借口格式下
	local url_icon = nil


	if index == 1 then
		self.room_p1:setVisible(true)
		self.room_name1:setString(name)
		self.room_gold1:setString(gold)

		url_icon = self.room_head1

	elseif index == 2 then
		self.room_p2:setVisible(true)
		self.room_name2:setString(name)
		self.room_gold2:setString(gold)

		url_icon = self.room_head2

	elseif index == 3 then
		self.room_p3:setVisible(true)
		self.room_name3:setString(name)
		self.room_gold3:setString(gold)

		url_icon = self.room_head3

	elseif index == 4 then
		self.room_p4:setVisible(true)
		self.room_name4:setString(name)
		self.room_gold4:setString(gold)

		url_icon = self.room_head4
	end

	icon_url = tostring(icon_url) 
	if url_icon then

	    local user_inf = {}
	    user_inf["uid"] = uid
	    user_inf["icon_url"] = icon_url
	    user_inf["sex"] = sex_num
	    user_inf["nick"] = name

	    -- dump(user_inf)
		require("hall.GameCommon"):setPlayerHead(user_inf,url_icon,69)
	end


end


function ZZRoom_Layout:resetZhuang()
	-- body
	self.room_zuan0:setVisible(false)
	self.room_zuan1:setVisible(false)
	self.room_zuan2:setVisible(false)
	self.room_zuan3:setVisible(false)
	self.room_zuan4:setVisible(false)
end

function ZZRoom_Layout:showZhuang( other_index )
	-- body
	local tbl = {}
	tbl[0]  = self.room_zuan0
	tbl[1]  = self.room_zuan1
	tbl[2]  = self.room_zuan2
	tbl[3]  = self.room_zuan3
	tbl[4]  = self.room_zuan4

	if tbl[tonumber(other_index)] then
		tbl[tonumber(other_index)]:setVisible(true)
	end
end


function ZZRoom_Layout:resetReady()
	-- body
    self.room_rd0:setVisible(false)
	self.room_rd1:setVisible(false)
	self.room_rd2:setVisible(false)
	self.room_rd3:setVisible(false)
	self.room_rd4:setVisible(false)
end

function ZZRoom_Layout:show_ready( other_index )
	-- body
	local tbl = {}
	tbl[0]  = self.room_rd0
	tbl[1]  = self.room_rd1
	tbl[2]  = self.room_rd2
	tbl[3]  = self.room_rd3
	tbl[4]  = self.room_rd4

	if tbl[tonumber(other_index)] then
		tbl[tonumber(other_index)]:setVisible(true)
	end
end


function ZZRoom_Layout:resetBeiNum()
	-- body
	for _,icon_list in pairs(self.qiangbei_dict) do
		for _,icon in pairs(icon_list) do
			icon:setVisible(false)
		end
	end
	
end

function ZZRoom_Layout:setBeiNum(other_index,num )
	-- body
	other_index = other_index + 1
	local icon_list = self.qiangbei_dict[other_index] or {}
	for _,icon in pairs(icon_list) do
		icon:setVisible(true)
	end

	icon_list[tonumber(2)]:setString(num)

end

function ZZRoom_Layout:resetgold( index,gold)
	-- body
	if index == 0 then
		self.room_gold0:setString(gold)
	elseif index == 1 then
		self.room_gold1:setString(gold)
	elseif index == 2 then
		self.room_gold2:setString(gold)
	elseif index == 3 then
		self.room_gold3:setString(gold)
	elseif index == 4 then
		self.room_gold4:setString(gold)
	end
end

function ZZRoom_Layout:get_player_head( index )
	-- body
	if index == 0 then
		return self.room_head0
	elseif index == 1 then
		return self.room_head1
	elseif index == 2 then
		return self.room_head2
	elseif index == 3 then
		return self.room_head3
	else
		return self.room_head4
	end
end