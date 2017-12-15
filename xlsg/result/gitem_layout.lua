

mrequire("result.gitem_template")
GitemLayout = class("GitemLayout", result.gitem_template.gitem_Template)

function GitemLayout:_do_after_init()
  self.gitem_zimo:setString("9倍分")
  self.gitem_jiepao:setString("7倍分")
  self.gitem_dianpao:setString("5倍分")
  self.gitem_minggang:setString("3倍分")
  self.gitem_angang:setString("1倍分")


  self.gitem_bestpao:setVisible(false)
  self.gitem_bestscore:setVisible(false)
  self.gitem_owner:setVisible(false)

end

function GitemLayout:reset_itemdata(player_data)
	local zimo_n = player_data.dsg or 0
	local jiepao_n = player_data.xsg or 0
	local dianpao_n = player_data.hsg or 0
  local minggang_n = player_data.bp or 0
  local angang_n = player_data.sp or 0

  self.gitem_zimo_n:setString(tostring(zimo_n))
  self.gitem_jiepao_n:setString(tostring(jiepao_n))
  self.gitem_dianpao_n:setString(tostring(dianpao_n))
  self.gitem_minggang_n:setString(tostring(minggang_n))
  self.gitem_angang_n:setString(tostring(angang_n))

  local account_change_chip = player_data.account_change_chip or 0
  self.gitem_sum:setString(tostring(account_change_chip))

  return account_change_chip
end


function GitemLayout:setpeopledata( uid,account_data )
  -- body
  local account_sex = account_data["account_sex"] or 2
  local account_head = account_data["account_head"] or ""
  local account_name = account_data["account_name"] or ""

  self.gitem_name:setString(tostring(uid))

  self.gitem_id:setString(tostring(account_name))


  local w = self.gitem_base:getContentSize().width
  local h = self.gitem_base:getContentSize().height
  local sp = display.newSprite("xlsg/res/image/head_box2.png")
  sp:setAnchorPoint(cc.p(0.5,0.5))
  self.gitem_base:addChild(sp)
  sp:setPosition(cc.p(w/2, h/2))

  if sp then
    local user_inf = {}
    user_inf["uid"] = uid
    user_inf["icon_url"] = account_head
    user_inf["sex"] = account_sex
    user_inf["nick"] = account_name

    require("hall.GameCommon"):setPlayerHead(user_inf,sp,70)
  end

  if tonumber(USER_INFO["group_owner"])  == tonumber(uid) then
     self.gitem_owner:setVisible(true)
  end

end


function GitemLayout:set_gitem_bestpao( flag )
  -- body
   -- self.gitem_bestpao:setVisible(flag)
end

function GitemLayout:set_gitem_bestscore( flag )
  -- body
  self.gitem_bestscore:setVisible(flag)
end