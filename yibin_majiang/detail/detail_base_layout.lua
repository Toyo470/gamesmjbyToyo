mrequire("detail.detail_base_template")
DetailBaseLayout = class("DetailBaseLayout", detail.detail_base_template.detail_base_Template)
local Sender = require(GAMEBASENAME..".Sender")


function DetailBaseLayout:_do_after_init()
	self.detail_data = {}
  self.piao_dict = {}

  local m_rec_time,m_GroupTimes = zzroom.manager:get_room_base_gouptime()
  m_GroupTimes = m_GroupTimes+1

  if m_GroupTimes ==  m_rec_time then
    self:set_overstate()
  end

end

function DetailBaseLayout:reset_data(account_id,game_hu_account_data_one_dict,account_change_chip,piao_dict)
	-- body
	self.detail_base_id:setString(account_id)
	local user_data = zzroom.manager:get_user_data(account_id)
	local account_name = user_data["account_name"] or ""
	self.detail_base_name:setString(account_name)
	self:reset_people(user_data)

	self.detail_base_sum:setString(account_change_chip)
	-- dump("game_hu_reset_data",game_hu_account_data_one_dict)
	self.detail_data = game_hu_account_data_one_dict
  self.piao_dict = piao_dict
end

function DetailBaseLayout:reset_people(player_data )
	-- body
  local w = self.detail_base_people_base:getContentSize().width
  local h = self.detail_base_people_base:getContentSize().height
  local sp = display.newSprite(GAMEBASENAME .. "/res/image/head_box2.png")
  sp:setAnchorPoint(cc.p(0.5,0.5))
  self.detail_base_people_base:addChild(sp)
  sp:setPosition(cc.p(w/2, h/2))

  local icon_url = player_data["account_head"] or ""
  local sex_num = player_data["account_sex"] or 2
  if sp then
    local user_inf = {}
    user_inf["uid"] = player_id
    user_inf["icon_url"] = icon_url
    user_inf["sex"] = sex_num
    user_inf["nick"] = nick_name

    require("hall.GameCommon"):setPlayerHead(user_inf,sp,70)
  end

end

function DetailBaseLayout:click_detail_base_detail_btn_event()
	local layout_object = layout.reback_layout_object("detail")
    layout_object:reset_data(self.detail_data,self.piao_dict)
end

function DetailBaseLayout:set_overstate()
  -- bodytext_kaishiyouxi
  local tx = GAMEBASENAME .. "/res/image/text_kaishiyouxi.png"
  self.detail_base_regain_btn:loadTexture(tx)

end

function DetailBaseLayout:click_detail_base_regain_btn_event()

--再来一盘，清空当前盘一局打出去的牌
  zzroom.manager:initialize()
  
  local room_card_object = layout.manager:get_layout_object("room_card")
  if room_card_object ~= nil then
    room_card_object:remove_alloutimage()
    room_card_object:hide_layout()
  end

  local room_base_specil = ui.manager:register_widget_object("room_base_specil")
  if room_base_specil then
  	room_base_specil:setVisible(false)
  end
  

  --如果牌局结束了，那么就不发登陆消息了
  local group_result_object = layout.manager:get_layout_object("group_result")
  if group_result_object ~=  nil then
    --print("click_result_regain_btn_event----2--------------------")
    group_result_object:setVisible(true)
    self:hide_layout()
    return
  end
  
  local m_rec_time,m_GroupTimes = zzroom.manager:get_room_base_gouptime()
  m_GroupTimes = m_GroupTimes+1

  if m_GroupTimes ==  m_rec_time then
    --print("click_result_regain_btn_event------3------------------")
    self:hide_layout()
    return
  end

  Sender:H2G_ACCOUNT_READY()

  self:hide_layout()
end

