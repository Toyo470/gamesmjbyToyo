mrequire("zzroom.room_template")
mrequire("tips")
mrequire("account")
mrequire("renovator")
mrequire("keys")
mrequire("zzroom.deal_card_path")
mrequire("zzroom.room_out_card_operator")

ZZRoom_Layout = class("ZZRoom_Layout", zzroom.room_template.room_Template)

function ZZRoom_Layout:_do_after_init()
	renovator.manager:add_attr_renvator_reset_callback("AccountObject",keys.ACCOUNT_GOLD,handler(self,self.refresh_data))

	

	self:init_other_player()

    --开启update更新
	self:set_update_flag(true)

	self.update_Opacity = 100
	self.update_value = 1


	self:reset_timerstate()
	self:hide_zuan_icon()

	self.name_icon_dic = {}
	self.name_icon_dic["room_bei"] = self.room_bei
	self.name_icon_dic["room_dong"] = self.room_dong
	self.name_icon_dic["room_xi"] = self.room_xi
	self.name_icon_dic["room_nan"] = self.room_nan


	self.time_txt_num = 0
	self.tip_name = ""

	self:reset_player()
	self.room_timebase:setVisible(false)
	self.room_txt_txt:setVisible(false)

	local path_bg = music.manager:get_bg_music_path()
	audio.playMusic(path_bg, true)

	self.init_fine = true

	self.room_outline1:setVisible(false)
	self.room_outline2:setVisible(false)
	self.room_outline3:setVisible(false)

	zzroom.manager:set_game_state(0)


	--self.room_player0:setVisible(false)
	self.room_player1:setVisible(false)
	self.room_player2:setVisible(false)
	self.room_player3:setVisible(false)

	self:hide_otherplayer_info(0)
end

function ZZRoom_Layout:update(dt)
	self.update_Opacity = self.update_Opacity - self.update_value*dt*80

	if self.update_Opacity < 80 then
		self.update_value = -1
		self.update_Opacity = 80
	elseif self.update_Opacity > 100 then
		self.update_value = 1
		self.update_Opacity = 100
	end
	--print(self.update_Opacity,"+==============")

	if self.name_icon_dic[self.tip_name] then
		--self.name_icon_dic[self.tip_name]:setOpacity(self.update_Opacity)
		if self.update_value == 1 then
			self.name_icon_dic[self.tip_name]:setVisible(true)
		else
			self.name_icon_dic[self.tip_name]:setVisible(false)
		end
	end

	self.time_txt_num = self.time_txt_num - dt
	if self.time_txt_num >= 0 then
		self.room_timertxt:setString(tostring(math.modf(self.time_txt_num)))
	end
end

function ZZRoom_Layout:begin_timer( tip_name,time_num )
	-- body
	self:reset_timerstate()
	self.tip_name = tip_name
	self.time_txt_num = time_num
	if self.name_icon_dic[self.tip_name] then
		self.name_icon_dic[self.tip_name]:setVisible(true)
	end
end

function ZZRoom_Layout:reset_timerstate()
	self.room_bei:setVisible(false)
	self.room_dong:setVisible(false)
	self.room_xi:setVisible(false)
	self.room_nan:setVisible(false)
end

function ZZRoom_Layout:set_left_card_num( simplNum )
	-- body
	self.room_left_card:setString("剩余"..tostring(simplNum).."张")
end

function ZZRoom_Layout:before_release()
    -- body
    print("before_release")
    renovator.manager:del_attr_renvator_reset_callback("AccountObject",keys.ACCOUNT_GOLD,handler(self,self.refresh_data))
end

function ZZRoom_Layout:refresh_data()
	print("ZZRoom_Layout:refresh_data()")

	local account_object = account.get_player_account()
	local gold = account_object:get_account_gold()

	if self.init_fine == true and self.room_gold0 ~= nil then
		self.room_gold0:setString(gold)
	end
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

end



function ZZRoom_Layout:click_room_btn_exit_event()
	-- local gd_Handle = require("zz_majiang2.gd_Handle")
	-- local tbl = {}
 --    tbl["card"]    = 38
 --     tbl["handle"]    = 0x010

 --    gd_Handle:SVR_OWN_CATCH_BROADCAST(tbl) --测代码


  -- local layout_object = layout.manager:get_layout_object("room_card")
  -- if layout_object == nil then
  --     return
  -- end

  --  layout_object:draw_zhua_card(3) 

	tips.show_tips("go_hall_title","go_hall_content",handler(self,self.go_hall),handler(self,self.cancal))
end

--返回大厅
function ZZRoom_Layout:go_hall()
	-- body
	bm.notCheckReload = 1
	layout.hide_layout("tips")
	layout.hide_layout("room")
	display_scene("hall.gameScene")
end

--取消回调
function ZZRoom_Layout:cancal()
	-- body
	layout.hide_layout("tips")
end

function ZZRoom_Layout:set_player_visiflag( index ,flag)
	-- body

	index = index or -1
	if index > 3 or index < 0 then
		return
	end

	local tbl = {}
	tbl[0] = self.room_player0
	tbl[1] = self.room_player1
	tbl[2] = self.room_player2
	tbl[3] = self.room_player3

	local tbl_name = {}
	tbl_name[1] = self.room_name1
	tbl_name[2] = self.room_name2
	tbl_name[3] = self.room_name3

	local tbl_gold = {}
	tbl_gold[1] = self.room_gold1
	tbl_gold[2] = self.room_gold2
	tbl_gold[3] = self.room_gold3

	tbl[index]:setVisible(flag)
	--tbl[index]:setColor(cc.c3b(255,255,255))

	tbl[1] = self.room_outline1
	tbl[2] = self.room_outline2
	tbl[3] = self.room_outline3
	if index > 0  then
		tbl[index]:setVisible(false)
		tbl_name[index]:setColor(cc.c3b(255,255,255))
		tbl_gold[index]:setColor(cc.c3b(255,255,255))
	end
end


function ZZRoom_Layout:set_player_outline( index )
	-- body
	print("------------------set_player_outline--------index------,",index)
	index = index or -1
	if index > 3 or index < 0 then
		return
	end

	local tbl = {}
	tbl[0] = self.room_player0
	tbl[1] = self.room_player1
	tbl[2] = self.room_player2
	tbl[3] = self.room_player3
	--tbl[index]:setColor(cc.c3b(128,128,128))
	--tbl[index]:setOpacity(125)
	local tbl_name = {}
	tbl_name[1] = self.room_name1
	tbl_name[2] = self.room_name2
	tbl_name[3] = self.room_name3

	local tbl_gold = {}
	tbl_gold[1] = self.room_gold1
	tbl_gold[2] = self.room_gold2
	tbl_gold[3] = self.room_gold3

	tbl[1] = self.room_outline1
	tbl[2] = self.room_outline2
	tbl[3] = self.room_outline3
	if index > 0  then
		tbl[index]:setVisible(true)

		tbl_name[index]:setColor(cc.c3b(128,128,128))
		tbl_gold[index]:setColor(cc.c3b(128,128,128))

	end

end


function ZZRoom_Layout:show_player( index ,names,gold,icon_url,sex_num,uid,ip)
	-- body
	print(index ,names,gold,icon_url,sex_num,uid,"ZZRoom_Layout:show_player")
	self:set_player_visiflag(index,true)

	names = names or ""
	local name = require("hall.GameCommon"):formatNick(names)--调下豪哥借口格式下
	local url_icon = nil

	local scenes = SCENENOW['scene']

	if SCENENOW['name'] == "zz_majiang2.gameScene" then
		if scenes ~= nil then
			scenes:setPosforSeat(index,uid)
		end
	end

	if index == 1 then
		self.room_name1:setString(name)
		self.room_gold1:setString(gold)

		self.room_name1:setVisible(true)
		self.room_gold1:setVisible(true)
		url_icon = self.room_head1

	elseif index == 2 then
		self.room_name2:setString(name)
		self.room_gold2:setString(gold)

		self.room_name2:setVisible(true)
		self.room_gold2:setVisible(true)
		url_icon = self.room_head2

	elseif index == 3 then
		self.room_name3:setString(name)
		self.room_gold3:setString(gold)

		self.room_name3:setVisible(true)
		self.room_gold3:setVisible(true)

		url_icon = self.room_head3
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

	-- if index == 1 or index == 2 or index == 3 then
	-- 	self:hide_otherplayer_info(index)
	-- end

end

function ZZRoom_Layout:showOtherReady( other_index )
	-- body
	if other_index == 0 then
			self.room_ready0:setVisible(true)
	elseif other_index == 1 then
			self.room_ready1:setVisible(true)
	elseif other_index == 2 then
			self.room_ready2:setVisible(true)
	elseif other_index == 3 then
			self.room_ready3:setVisible(true)
	end
end

function ZZRoom_Layout:hideallReady()
	self.room_ready0:setVisible(false)
	self.room_ready1:setVisible(false)
	self.room_ready2:setVisible(false)
	self.room_ready3:setVisible(false)
end

function ZZRoom_Layout:hide_zuan_icon( )
	-- body
	self.room_zuan0:setVisible(false)
	self.room_zuan1:setVisible(false)
	self.room_zuan2:setVisible(false)
	self.room_zuan3:setVisible(false)
end

function ZZRoom_Layout:init_other_player()
	-- body头像相关
	self.room_head3:setVisible(false)
	self.room_name3:setVisible(false)
	self.room_gold3:setVisible(false)

	self.room_head1:setVisible(false)
	self.room_name1:setVisible(false)
	self.room_gold1:setVisible(false)

	self.room_head2:setVisible(false)
	self.room_name2:setVisible(false)
	self.room_gold2:setVisible(false)

	self:hideallReady()

end


--开始游戏时需要隐藏其他玩家的一些东西，在这里处理
function  ZZRoom_Layout:hide_otherplayer_info( index )

	-- local panel = nil 
	-- local p = cc.p(20.72,96.40)
	-- if index == 0 then
	-- 	panel = self.room_player0
	-- 	p = cc.p(20.72,96.40)
		
	-- elseif index == 1 then
	-- 	panel = self.room_player1
	-- 	p = cc.p(27.14,260.65)

	-- elseif index == 2 then 
	-- 	panel = self.room_player2
	-- 	p = cc.p(184.79,461.73)

	-- elseif index  == 3 then
	-- 	panel = self.room_player3
	-- 	p = cc.p(850.87,301.64)
	-- end

	-- if panel ~= nil then
	-- 	--开始移动
	-- 	panel:setVisible(true)
	-- 	local action_move = cc.MoveTo:create(1,p)
	-- 	local action_scale = cc.ScaleTo:create(0.77,0.77)
	-- 	local sum_action = cc.Spawn:create(action_move,action_scale)
	-- 	panel:runAction(sum_action)
	-- end
end

function ZZRoom_Layout:showZhuang( other_index )
	-- body
	self.room_timebase:setVisible(true)
	self.room_txt_txt:setVisible(true)
	if other_index == 0 then
		self.room_zuan0:setVisible(true)
		self.room_timebase:setRotation(0)
	elseif other_index == 1 then
		self.room_zuan1:setVisible(true)
		self.room_timebase:setRotation(90)
	elseif other_index == 2 then
		self.room_zuan2:setVisible(true)
		self.room_timebase:setRotation(180)
	elseif other_index == 3 then
		self.room_zuan3:setVisible(true)
		self.room_timebase:setRotation(270)
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
	else
		return self.room_head3
	end 
end