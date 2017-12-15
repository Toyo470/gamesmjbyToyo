mrequire("zzroom.room_base_template")
mrequire("cardhandle.deal_card_path")

RoomBaseLayout = class("RoomBaseLayout", zzroom.room_base_template.room_base_Template)

function RoomBaseLayout:_do_after_init()
	self.room_base_txt:setString("房间号")
	self.room_base_num:setString(tostring(USER_INFO["invote_code"]))

	local gameConfig = USER_INFO["gameConfig"] or ""
	self.room_base_gamemsg:setString("宜宾麻将：".. tostring(gameConfig))

	self.room_base_video:setPositionX(897.79)
	self.room_base_video:setPositionY(190.96)
	self.room_base_talk:setPositionX(897.79)
	self.room_base_talk:setPositionY(186.96+68)
	require("hall.VoiceRecord.VoiceRecordView"):showView(877.00+20, 147.00-20)

	self.name_icon_dic = {}
	self.name_icon_dic["room_base_bei"] = self.room_base_bei
	self.name_icon_dic["room_base_dong"] = self.room_base_dong
	self.name_icon_dic["room_base_xi"] = self.room_base_xi
	self.name_icon_dic["room_base_nan"] = self.room_base_nan

    self.time_txt_num = 0
	self.update_Opacity = 100
	self.update_value = 1
	
	self:reset_timerstate()
	self.room_base_txt1:setString("还剩    牌")
	self.room_base_txt2:setString("剩   局")


	self.room_base_video:setVisible(true)
	self.room_base_timebase:setVisible(false)
	self.room_base_tab:setVisible(false)
	
	self.room_base_timertxt:setVisible(false)

	self:set_update_flag(true)

	self.bg_card_image_path = GAMEBASENAME .. "/res/majiangCard/top_card01.png"
	self.fg_card_image_path = GAMEBASENAME .. "/res/majiangCard/top_card01.png"

	self.jing_count = 0

	self.room_base_specil:setVisible(false)
	
	
end

function RoomBaseLayout:reset_up_doem_tip()
	-- body
	self.room_base_specil:setVisible(false)

end

function RoomBaseLayout:init_jing_card(jing_count)
	

	self.jing_count = jing_count
end

function RoomBaseLayout:show_up_jing()
	local up_jing_card_list = game.manager:get_up_jing_list()
	local game_benjin_card =game.manager:get_game_benjin_card()

	self.room_base_specil:setVisible(true)
	self.up_jing_img_widget_list = {self.room_base_up_zj_img,self.room_base_up_fj_img1}
	self:show_jing_card_img_list(self.up_jing_img_widget_list,up_jing_card_list)

	if game_benjin_card ~= 0 then
		print(game_benjin_card,"game_benjin_card-------------")
		local jing_path = cardhandle.deal_card_path.get_card_path(game_benjin_card)
		self.room_base_up_fj_img:loadTexture(jing_path)
		self.room_base_up_fj_bg:setColor(cc.c3b(250,250,0))
	end

end

function RoomBaseLayout:_do_after_show()
end

function RoomBaseLayout:show_jing_widget_img(widget_list,jing_path)
	for _,widget in pairs(widget_list) do
		widget:loadTexture(jing_path)
	end
end

function RoomBaseLayout:show_jing_card_img_list(widget_list,card_index_list)
	for index,widget in pairs(widget_list) do
		local card_path = cardhandle.deal_card_path.get_card_path(card_index_list[index])
		widget:loadTexture(card_path)
	end
end

function RoomBaseLayout:show_jing_widget_visible(widget_list,jing_visible)
	for _,widget in pairs(widget_list) do
		--print("--widget",widget:getName())
		widget:setVisible(jing_visible)
	end
end

function RoomBaseLayout:set_up_jing_visible(jing_visible)
	-- 初始化上精
	self:show_jing_widget_visible(self.up_jing_bg_widget_list,jing_visible)
end

function RoomBaseLayout:set_down_left_right_jing_visible(jing_visible)
	-- 初始化下左右精
	self:show_jing_widget_visible(self.left_down_right_jing_bg_widget_list,jing_visible)
end

function RoomBaseLayout:set_down_s_jing_visible(jing_visible)
	-- 初始化单个下精
	self:show_jing_widget_visible(self.down_jing_bg_s_widget_list,jing_visible)
end

function RoomBaseLayout:begin_timer( index,time_num )
	-- body
	self.room_base_tab:setVisible(true)
	self.room_base_timebase:setVisible(true)
	print("index----begin_timer--------------------",index,time_num)
	time_num = time_num or 8
	self:reset_timerstate()
	self.time_txt_num = time_num
	local tip_name = zzroom.manager:get_timertip_name(index)
	self.tip_name = tip_name
print("self.tip_name-----1-----------",self.tip_name)
	if self.name_icon_dic[self.tip_name] then
		print("self.tip_name-----2-----------",self.tip_name)
		self.name_icon_dic[self.tip_name]:setVisible(true)
	end
end

function RoomBaseLayout:reset_timerstate()

	self.room_base_bei:setVisible(false)
	self.room_base_dong:setVisible(false)
	self.room_base_xi:setVisible(false)
	self.room_base_nan:setVisible(false)
end

function RoomBaseLayout:update(dt)
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
		self.room_base_timertxt:setVisible(true)
		self.room_base_timertxt:setString(tostring(math.modf(self.time_txt_num)))
	end
end

function RoomBaseLayout:set_left_card_num( simplNum )
	self.room_base_lessnum:setString(tostring(simplNum))
end

function RoomBaseLayout:set_room_base_gouptime(m_rec_time,total)
	m_rec_time = m_rec_time + 1
	self.room_base_gouptime:setString(tostring(total - m_rec_time))
	
end

function RoomBaseLayout:click_room_base_btn_event()
	layout.reback_layout_object("setting")
end

function RoomBaseLayout:click_room_base_video_event()
	-- print("------------------------click_room_base_video_event---------")
	local a = {}
	a.x = 0
	a.y = 0

	local b = {}
	b.width = 0
	b.height = 0

	require("hall.recordUtils.RecordUtils"):showRecordFrame(cc.p(480, 270), cc.size(264, 218), USER_INFO["activity_id"])

end

function RoomBaseLayout:click_room_base_talk_event()
	--SCENENOW["scene"] 
    print(SCENENOW["name"],"-------------------------")
    if SCENENOW["name"] == GAMEBASENAME..".".."gameScene" then
    	local faceUI = SCENENOW["scene"]:getChildByName("faceUI")
    	local pos = self.room_base_talk:getPosition()
    	faceUI:showTxtPanle(pos,8)
    end
end

function RoomBaseLayout:click_room_base_btn_exit_event()
	tips.show_tips("go_hall_title","go_hall_content",handler(self,self.go_hall),handler(self,self.cancal))
end

--返回大厅
function RoomBaseLayout:go_hall()
	-- body
	bm.notCheckReload = 1
	layout.hide_layout("tips")
	layout.hide_layout("room")
	display_scene("hall.gameScene")
end

--取消回调
function RoomBaseLayout:cancal()
	-- body
	layout.hide_layout("tips")
end

function RoomBaseLayout:showZhuang( other_index )
	-- body
	if other_index == 0 then
		self.room_base_timebase:setRotation(0)
	elseif other_index == 1 then
		self.room_base_timebase:setRotation(270)
	elseif other_index == 2 then
		self.room_base_timebase:setRotation(180)
	elseif other_index == 3 then
		self.room_base_timebase:setRotation(90)
	end
end