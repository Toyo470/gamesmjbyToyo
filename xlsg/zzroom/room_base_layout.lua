mrequire("zzroom.room_base_template")

RoomBaseLayout = class("RoomBaseLayout", zzroom.room_base_template.room_base_Template)

function RoomBaseLayout:_do_after_init()

	self.room_base_video:setVisible(true)
	self.room_base_video:setPositionX(897.79)
	self.room_base_video:setPositionY(190.96)

	self.room_base_talk:setVisible(true)
	self.room_base_talk:setPositionX(897.79)
	self.room_base_talk:setPositionY(186.96+68)


	self.room_base_txt:setString("房间号:")
	self.room_base_num:setString(tostring(USER_INFO["invote_code"])) --邀请码

	-- local tbl = USER_INFO["players"] or {}
	-- local num = table.nums(tbl)
	--self.room_base_sumpeo:setString(tostring(num).."人")
	self.room_base_sumpeo:setString("")
	self.room_base_gouptime:setString("第/局")--第1/4局

	self.room_base_text_btn:setVisible(false)
	self.room_base_text_btntxt:setString("配牌")
end

function RoomBaseLayout:set_room_base_sumpeo( num )
	-- body
	self.room_base_sumpeo:setString(tostring(num).."人场")
end

function RoomBaseLayout:set_room_base_gouptime( group_round, group_total_round)
	-- body
	group_round = tonumber(group_round)
	group_round = group_round + 1
	self.room_base_gouptime:setString("第"..tostring(group_round).."/"..tostring(group_total_round).."局")--第1/4局
end
-- function RoomBaseLayout:set_room_base_gouptime(pack)
-- 	-- body
-- 	local m_rec_time = pack.m_rec_time or 0
-- 	local m_GroupTimes = pack.m_GroupTimes or 0
-- 	m_GroupTimes = m_GroupTimes+1
-- 	self.room_base_gouptime:setString("第"..tostring(m_GroupTimes).."/"..tostring(m_rec_time).."局")
-- end

function RoomBaseLayout:click_room_base_btn_event()
	layout.reback_layout_object("setting")
end

function RoomBaseLayout:click_room_base_exit_event()

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




function RoomBaseLayout:click_room_base_rd_event()

  local layout_object = layout.manager:get_layout_object("room")
  if layout_object == nil then
    return
  end

  layout_object:show_ready(0)
  local ZZ_Send = require("xlsg.ZZ_Send")
  ZZ_Send:send(mprotocol.H2G_ACCOUNT_READY)
  self.room_base_rd:setVisible(false)
end

function RoomBaseLayout:setf_room_rd( flag )
	-- body
	self.room_base_rd:setVisible(flag)
end

function RoomBaseLayout:click_room_base_text_btn_event()
		local CARD_INDEX_LIST = {
				101,201,301,401,
				102,202,302,402,
				103,203,303,403,
				104,204,304,404,
				105,205,305,405,
				106,206,306,406,
				107,207,307,407,
				108,208,308,408,
				109,209,309,409,
				110,210,310,410,
				111,211,311,411,
				112,212,312,412,
				113,213,313,413}
	local test_dict = {}



	if macros then
		local card_value_list = macros.manager:get_macros_str_value("card_value_list")
		print(card_value_list,"card_value_list")
		if card_value_list ~= "" then
			for _,card_value in pairs(CARD_INDEX_LIST) do
				test_dict[card_value] = 1
			end
		

			local packageName_tbl = string.split(card_value_list,",")
			dump(packageName_tbl)

			local tbl = {}
			for _,card_value in pairs(packageName_tbl) do
				--print("------------card_value---------",card_value,"----------------",type(card_value))
				card_value = tonumber(card_value)
				if test_dict[card_value] ~= nil then --测试牌值的合法性
					--print("------------in---------",card_value)
					table.insert(tbl,card_value)
				end
			end

			local data_tbl = {}
			data_tbl["account_handcard"] = tbl
			dump(data_tbl,"data_tbl")
			local ZZ_Send = require("xlsg.ZZ_Send")
    		ZZ_Send:send(mprotocol.H2G_GAME_MATCHING_CARD,data_tbl)
		end
	end
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
	print(SCENENOW["name"],"-------------------------")
    if SCENENOW["name"] == "xlsg.gameScene" then
    	local faceUI = SCENENOW["scene"]:getChildByName("faceUI")
    	local pos = self.room_base_talk:getPosition()
    	faceUI:showTxtPanle(pos,8)
    end
end