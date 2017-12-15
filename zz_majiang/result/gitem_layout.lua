

mrequire("result.gitem_template")
GitemLayout = class("GitemLayout", result.gitem_template.gitem_Template)

function GitemLayout:_do_after_init()
  self.gitem_zimo:setString("自摸次数")
  self.gitem_jiepao:setString("接炮次数")
  self.gitem_dianpao:setString("点炮次数")
  self.gitem_minggang:setString("暗杠条数")
  self.gitem_angang:setString("明杠条数")
  self.gitem_bestpao:setVisible(false)
  self.gitem_bestscore:setVisible(false)
  self.gitem_owner:setVisible(false)

end

function GitemLayout:reset_itemdata(index,player_data)
  player_data = player_data or {} 
  local uid = player_data.uid or "000"
  self.gitem_name:setString(tostring(uid))

  local user_info = player_data.user_info or ""
  local user_info_tbl = json.decode(user_info)

	local zimo = user_info_tbl.zimo or 0
	local jiepao = user_info_tbl.jiepao or 0
	local dianpao = user_info_tbl.dianpao or 0
	local angang = user_info_tbl.angang or 0
	local minggang = user_info_tbl.minggang or 0
  local add_chips = user_info_tbl.add_chips or 0
  local chips = user_info_tbl.chips or 0

  self.gitem_zimo_n:setString(tostring(zimo))
  self.gitem_jiepao_n:setString(tostring(jiepao))
  self.gitem_dianpao_n:setString(tostring(dianpao))
  self.gitem_minggang_n:setString(tostring(angang))
  self.gitem_angang_n:setString(tostring(minggang))
  self.gitem_sum:setString(tostring(chips - add_chips))


  local nick_name = user_info_tbl.nick_name or "wangran"
  self.gitem_id:setString(tostring(nick_name))

  local w = self.gitem_base:getContentSize().width
  local h = self.gitem_base:getContentSize().height
  local sp = display.newSprite("zz_majiang/res/image/head_box2.png")
  sp:setAnchorPoint(cc.p(0.5,0.5))
  self.gitem_base:addChild(sp)
  sp:setPosition(cc.p(w/2, h/2))

  local sex_num = user_info_tbl.sex or 2
  local icon_url = user_info_tbl.photo_url or ""
  if sp then
    local user_inf = {}
    user_inf["uid"] = uid
    user_inf["icon_url"] = icon_url
    user_inf["sex"] = sex_num
    user_inf["nick"] = nick_name

    dump(user_inf)
    require("hall.GameCommon"):setPlayerHead(user_inf,sp,70)
  end

  if tonumber(USER_INFO["group_owner"])  == tonumber(uid) then
     self.gitem_owner:setVisible(true)
  end


  return dianpao,add_chips
end

function GitemLayout:set_gitem_bestpao( flag )
  -- body
    self.gitem_bestpao:setVisible(flag)
end

function GitemLayout:set_gitem_bestscore( flag )
  -- body
  self.gitem_bestscore:setVisible(flag)
end