

mrequire("result.gitem_template")
GitemLayout = class("GitemLayout", result.gitem_template.gitem_Template)

function GitemLayout:_do_after_init()
  self.gitem_zimo:setString("大胡次数")
  self.gitem_jiepao:setString("小胡次数")
  self.gitem_dianpao:setString("暗杠次数")
  self.gitem_minggang:setString("明杠次数")
  self.gitem_angang:setString("接杠次数")

  self.gitem_bestpao:setVisible(false)
  self.gitem_bestscore:setVisible(false)
  self.gitem_owner:setVisible(false)

end

function GitemLayout:set_da_hu(txt)
  -- body
  txt = txt or 0
  self.gitem_zimo_n:setString(tostring(txt))
end

function GitemLayout:set_xiao_hu(txt)
   txt = txt or 0
  -- body
  self.gitem_jiepao_n:setString(tostring(txt))
end

function GitemLayout:set_angang( txt )
   txt = txt or 0
  -- body
  self.gitem_dianpao_n:setString(tostring(txt))

end

function GitemLayout:set_minggang( txt )
   txt = txt or 0
  -- body
  self.gitem_minggang_n:setString(tostring(txt))
end

function GitemLayout:set_jiegang( txt )
   txt = txt or 0
  -- body
  self.gitem_angang_n:setString(tostring(txt))
end

function GitemLayout:set_sum( add_chips )
  add_chips = add_chips or 0
  -- body
  self.gitem_sum:setString(tostring(add_chips))

  return add_chips
end

function GitemLayout:reset_itemdata(player_id,player_data)
  self.gitem_name:setString(tostring(player_id))

  local nick_name = player_data["account_name"] or ""
  self.gitem_id:setString(tostring(nick_name))

  local w = self.gitem_base:getContentSize().width
  local h = self.gitem_base:getContentSize().height
  local sp = display.newSprite(GAMEBASENAME .. "/res/image/head_box2.png")
  sp:setAnchorPoint(cc.p(0.5,0.5))
  self.gitem_base:addChild(sp)
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

  if tonumber(USER_INFO["group_owner"])  == tonumber(player_id) then
     self.gitem_owner:setVisible(true)
  end
  
end

function GitemLayout:set_gitem_bestpao( flag )
  -- body
    self.gitem_bestpao:setVisible(flag)
end

function GitemLayout:set_gitem_bestscore( flag )
  -- body
  self.gitem_bestscore:setVisible(flag)
end