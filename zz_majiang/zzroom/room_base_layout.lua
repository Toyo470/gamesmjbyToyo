mrequire("zzroom.room_base_template")

RoomBaseLayout = class("RoomBaseLayout", zzroom.room_base_template.room_base_Template)

function RoomBaseLayout:_do_after_init()
	self.room_base_txt:setString("房间号")
	self.room_base_num:setString(tostring(USER_INFO["invote_code"]))

	local gameConfig = USER_INFO["gameConfig"] or ""
	self.room_base_gamemsg:setString("红中麻将：".. tostring(gameConfig))
	self.room_base_gouptime:setVisible(false)
	self.room_base_lessnum:setVisible(false)
	self.room_base_video:setVisible(false)
	self.room_base_video:setPositionX(897.79)
	self.room_base_video:setPositionY(190.96)

	self.room_base_talk:setVisible(true)
	self.room_base_talk:setPositionX(897.79)
	self.room_base_talk:setPositionY(186.96+68)
	self:set_room_base_video_ex(true)

	self.room_base_txt1:setString("还剩     牌")
	self.room_base_txt2:setString("剩     局")
end

function RoomBaseLayout:set_left_card_num( simplNum )
	self.room_base_lessnum:setString(tostring(simplNum))
	self.room_base_lessnum:setVisible(true)
end

function RoomBaseLayout:set_gamemsg( game_msg )
	-- body
	self.room_base_gamemsg:setString("红中麻将："..tostring(game_msg))
end

function RoomBaseLayout:set_room_base_gouptime(pack)
	-- body
	local m_rec_time = pack.m_rec_time or 0
	local m_GroupTimes = pack.m_GroupTimes or 0
	m_GroupTimes = m_GroupTimes+1
	self.room_base_gouptime:setVisible(true)
	self.room_base_gouptime:setString(tostring(m_rec_time - m_GroupTimes))
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

function RoomBaseLayout:set_room_base_video( flag )
	-- body
end

function RoomBaseLayout:set_room_base_video_ex(flag)
	self.room_base_video:setVisible(flag)
	self.room_base_talk:setVisible(flag)

	if flag == true then
	   --添加录音按钮
       require("hall.VoiceRecord.VoiceRecordView"):showView(877.00+20, 147.00-20,1)
	else
		--移除录音按钮
       require("hall.VoiceRecord.VoiceRecordView"):removeView()
	end
end

function RoomBaseLayout:click_room_base_talk_event()
	--SCENENOW["scene"] 
    print(SCENENOW["name"],"-------------------------")
    if SCENENOW["name"] == "zz_majiang.gameScene" then
    	local faceUI = SCENENOW["scene"]:getChildByName("faceUI")
    	local pos = self.room_base_talk:getPosition()
    	if faceUI ~= nil then
    		faceUI:showTxtPanle(pos,8)
    	end
    end
end
