

mrequire("result.gitem_template")
GitemLayout = class("GitemLayout", result.gitem_template.gitem_Template)

function GitemLayout:_do_after_init()
  -- self.gitem_zimo:setString("自摸次数")
  -- self.gitem_jiepao:setString("接炮次数")
  -- self.gitem_dianpao:setString("点炮次数")
  -- self.gitem_minggang:setString("暗杠条数")
  -- self.gitem_angang:setString("明杠条数")
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
  local tax_times = user_info_tbl["count_timeout_times"] or 0
  local timeout_times = user_info_tbl["outcard_timeout_times"] or 0

  -- self.gitem_jiepao_n:setString(tostring(jiepao))
  -- self.gitem_dianpao_n:setString(tostring(dianpao))
  -- self.gitem_minggang_n:setString(tostring(angang))
  -- self.gitem_angang_n:setString(tostring(minggang))
  self.gitem_sum:setString(tostring(chips - add_chips))

  --
  local layer_item = ccui.Layout:create()
  layer_item:setContentSize(cc.size(208,34))
  self.lv_items:pushBackCustomItem(layer_item)
  local txt_title = cc.Label:createWithTTF(tostring("自摸次数"),"res/fonts/fzcy.ttf",20)
  if txt_title then
    txt_title:setColor(cc.c3b(0xbb,0x6f,0x4f))
    txt_title:setAnchorPoint(cc.p(0,0.5))
    txt_title:setPosition( 40, 17)
    layer_item:addChild(txt_title)
  end
  local txt_num = cc.Label:createWithTTF(tostring(zimo),"res/fonts/fzcy.ttf",20)
  if txt_num then
    txt_num:setColor(cc.c3b(0xbb,0x6f,0x4f))
    txt_num:setAnchorPoint(cc.p(0,0.5))
    txt_num:setPosition( 160, 17)
    layer_item:addChild(txt_num)
  end
  --
  layer_item = ccui.Layout:create()
  layer_item:setContentSize(cc.size(208,34))
  self.lv_items:pushBackCustomItem(layer_item)
  txt_title = cc.Label:createWithTTF(tostring("暗杠条数"),"res/fonts/fzcy.ttf",20)
  if txt_title then
    txt_title:setColor(cc.c3b(0xbb,0x6f,0x4f))
    txt_title:setAnchorPoint(cc.p(0,0.5))
    txt_title:setPosition( 40, 17)
    layer_item:addChild(txt_title)
  end
  txt_num = cc.Label:createWithTTF(tostring(angang),"res/fonts/fzcy.ttf",20)
  if txt_num then
    txt_num:setColor(cc.c3b(0xbb,0x6f,0x4f))
    txt_num:setAnchorPoint(cc.p(0,0.5))
    txt_num:setPosition( 160, 17)
    layer_item:addChild(txt_num)
  end
  --
  layer_item = ccui.Layout:create()
  layer_item:setContentSize(cc.size(208,34))
  self.lv_items:pushBackCustomItem(layer_item)
  txt_title = cc.Label:createWithTTF(tostring("明杠条数"),"res/fonts/fzcy.ttf",20)
  if txt_title then
    txt_title:setColor(cc.c3b(0xbb,0x6f,0x4f))
    txt_title:setAnchorPoint(cc.p(0,0.5))
    txt_title:setPosition( 40, 17)
    layer_item:addChild(txt_title)
  end
  txt_num = cc.Label:createWithTTF(tostring(minggang),"res/fonts/fzcy.ttf",20)
  if txt_num then
    txt_num:setColor(cc.c3b(0xbb,0x6f,0x4f))
    txt_num:setAnchorPoint(cc.p(0,0.5))
    txt_num:setPosition( 160, 17)
    layer_item:addChild(txt_num)
  end
  --
  layer_item = ccui.Layout:create()
  layer_item:setContentSize(cc.size(208,34))
  self.lv_items:pushBackCustomItem(layer_item)
  txt_title = cc.Label:createWithTTF(tostring("扣分次数"),"res/fonts/fzcy.ttf",20)
  if txt_title then
    txt_title:setColor(cc.c3b(0xbb,0x6f,0x4f))
    txt_title:setAnchorPoint(cc.p(0,0.5))
    txt_title:setPosition( 40, 17)
    layer_item:addChild(txt_title)
  end
  txt_num = cc.Label:createWithTTF(tostring(tax_times),"res/fonts/fzcy.ttf",20)
  if txt_num then
    txt_num:setColor(cc.c3b(0xbb,0x6f,0x4f))
    txt_num:setAnchorPoint(cc.p(0,0.5))
    txt_num:setPosition( 160, 17)
    layer_item:addChild(txt_num)
  end
  --
  layer_item = ccui.Layout:create()
  layer_item:setContentSize(cc.size(208,34))
  self.lv_items:pushBackCustomItem(layer_item)
  txt_title = cc.Label:createWithTTF(tostring("超时次数"),"res/fonts/fzcy.ttf",20)
  if txt_title then
    txt_title:setColor(cc.c3b(0xbb,0x6f,0x4f))
    txt_title:setAnchorPoint(cc.p(0,0.5))
    txt_title:setPosition( 40, 17)
    layer_item:addChild(txt_title)
  end
  txt_num = cc.Label:createWithTTF(tostring(timeout_times),"res/fonts/fzcy.ttf",20)
  if txt_num then
    txt_num:setColor(cc.c3b(0xbb,0x6f,0x4f))
    txt_num:setAnchorPoint(cc.p(0,0.5))
    txt_num:setPosition( 160, 17)
    layer_item:addChild(txt_num)
  end
  if jiepao > 0 then
    layer_item = ccui.Layout:create()
    layer_item:setContentSize(cc.size(208,34))
    self.lv_items:pushBackCustomItem(layer_item)
    txt_title = cc.Label:createWithTTF(tostring("接炮次数"),"res/fonts/fzcy.ttf",20)
    if txt_title then
      txt_title:setColor(cc.c3b(0xbb,0x6f,0x4f))
      txt_title:setAnchorPoint(cc.p(0,0.5))
      txt_title:setPosition( 40, 17)
      layer_item:addChild(txt_title)
    end
    txt_num = cc.Label:createWithTTF(tostring(jiepao),"res/fonts/fzcy.ttf",20)
    if txt_num then
      txt_num:setColor(cc.c3b(0xbb,0x6f,0x4f))
      txt_num:setAnchorPoint(cc.p(0,0.5))
      txt_num:setPosition( 160, 17)
      layer_item:addChild(txt_num)
    end
  end
  if dianpao > 0 then
    layer_item = ccui.Layout:create()
    layer_item:setContentSize(cc.size(208,34))
    self.lv_items:pushBackCustomItem(layer_item)
    txt_title = cc.Label:createWithTTF(tostring("点炮次数"),"res/fonts/fzcy.ttf",20)
    if txt_title then
      txt_title:setColor(cc.c3b(0xbb,0x6f,0x4f))
      txt_title:setAnchorPoint(cc.p(0,0.5))
      txt_title:setPosition( 40, 17)
      layer_item:addChild(txt_title)
    end
    txt_num = cc.Label:createWithTTF(tostring(dianpao),"res/fonts/fzcy.ttf",20)
    if txt_num then
      txt_num:setColor(cc.c3b(0xbb,0x6f,0x4f))
      txt_num:setAnchorPoint(cc.p(0,0.5))
      txt_num:setPosition( 160, 17)
      layer_item:addChild(txt_num)
    end
  end


  local nick_name = user_info_tbl.nick_name or "wangran"
  self.gitem_id:setString(tostring(nick_name))

  local w = self.gitem_base:getContentSize().width
  local h = self.gitem_base:getContentSize().height
  local sp = display.newSprite("fzz_majiang/res/image/head_box2.png")
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


  return dianpao,(chips - add_chips)
end

function GitemLayout:set_gitem_bestpao( flag )
  -- body
    self.gitem_bestpao:setVisible(flag)
end

function GitemLayout:set_gitem_bestscore( flag )
  -- body
  self.gitem_bestscore:setVisible(flag)
end