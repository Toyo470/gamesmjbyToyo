--碰杠胡等操作
local Sender = require(GAMEBASENAME..".".."Sender")

mrequire("handleview.room_handle_view_template")
HandleViewLayout = class("HandleViewLayout", handleview.room_handle_view_template.room_handle_view_Template)

function HandleViewLayout:_do_after_init()
	self.room_handle_view_gang:setVisible(false)
	self.room_handle_view_guo:setVisible(false)
	self.room_handle_view_hu:setVisible(false)
	self.room_handle_view_peng:setVisible(false)
  self.room_handle_view_chi:setVisible(false)
  self.room_handle_view_buz:setVisible(false)
  
end
function HandleViewLayout:click_room_handle_view_buz_event()
  local result = self.room_handle_view_buz.result
  
  local data = self.room_handle_view_buz.data
  if data == nil or table.nums(data[2]) == 1 then
    self:requestHandle(result)
  else
    dump(data,"click_room_handle_view_buz_eventdata")
    if type(data[2]) == "table" then
      local tal = {}
      for _,card_val in pairs(data[2]) do
        local tl = {}
        table.insert(tl,card_val)
        table.insert(tl,card_val)
        table.insert(tl,card_val)
        table.insert(tl,card_val)

        table.insert(tal,tl)
      end
    self:show_anganbox(tal)
    end

  end

end

function HandleViewLayout:click_room_handle_view_gang_event()
	local result = self.room_handle_view_gang.result
	self:requestHandle(result)
end

function HandleViewLayout:click_room_handle_view_guo_event()
	local result = self.room_handle_view_guo.result
	self:requestHandle(result)
end

function HandleViewLayout:click_room_handle_view_hu_event()
	local result = self.room_handle_view_hu.result
	self:requestHandle(result)
end

function HandleViewLayout:click_room_handle_view_peng_event()
	local result = self.room_handle_view_peng.result
	self:requestHandle(result)
end


function HandleViewLayout:requestHandle(result,item_index)
	-- body

  local tbl = {}
  tbl["option_index"] = {}
  table.insert(tbl["option_index"] ,result)
  if item_index then
    table.insert(tbl["option_index"] ,item_index)
  end
  print("requestHandle------------------")
  dump(tbl)
  Sender:send(mprotocol.H2G_GAME_ACCOUNT_CHOOSE_OPTION,tbl)

	self:hide_layout()
end

function HandleViewLayout:click_room_handle_view_chi_event()
  local card_dic_list = self.room_handle_view_chi.data_tbl
  card_dic_list = card_dic_list[2] or {}
  if table.nums(card_dic_list) > 1 then
    self:show_chibox(card_dic_list)
  else  
    local result = self.room_handle_view_chi.result
    self:requestHandle(result)
  end
end

function HandleViewLayout:show_anganbox(card_dic_list)
  -- body
  self:_do_after_init()
  self.room_handle_view_guo.result = 0
  self.room_handle_view_guo:setVisible(true)
  local width = self.room_handle_view_guo:getContentSize().width
  local posX = self.room_handle_view_guo:getPositionX()
  local posY = self.room_handle_view_guo:getPositionY()

  self.room_handle_view_box:setPositionX(posX - width/2)
  self.room_handle_view_box:setPositionY(posY)
  local num = 0
  for _,card_dic in pairs(card_dic_list) do
    for _,card_value in pairs(card_dic) do
      num = num + 1
    end
  end
  print(num,"====================")
  local box_h = self.room_handle_view_box:getContentSize().height
  self.room_handle_view_box:setContentSize(cc.size((num+2)*54*0.6 ,box_h))
  local box_w =  self.room_handle_view_box:getContentSize().width

  local image_x = 54*0.6*3/2 + 54*0.6/2 + 10

  print("box_h--------------",box_h)
  local item_index = 0
  for _,card_dic in pairs(card_dic_list) do
    local image = ccui.Layout:create();
    image:setAnchorPoint(cc.p(0.0,0.0))
    image:setContentSize(cc.size(54*0.6*table.nums(card_dic),box_h))
    -- image:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
    -- image:setBackGroundColor(cc.c3b(255,0, 0)) 
    image.item_index = item_index
    item_index = item_index + 1
    local x = 54*0.6/2
    local y = box_h/2

    for _,card_value in pairs(card_dic) do
      
      local card_base = cc.Sprite:create(GAMEBASENAME.."/res/majiangCard/my_big_card01.png");
      local card_value_path = cardhandle.deal_card_path.get_card_path(card_value)
      local card_face = cc.Sprite:create(card_value_path);
      card_base:addChild(card_face)
      card_face:setPositionX(card_base:getContentSize().width/2)
      card_face:setPositionY(card_base:getContentSize().height/2-5)

      card_base:setPositionX(x)
      card_base:setPositionY(y)

      image:addChild(card_base)
      card_base:setScale(0.6)
      x = x +  card_base:getContentSize().width*0.6

    end
    self.room_handle_view_box:addChild(image)
    image:setPositionX(image_x)
    image:setPositionY(box_h/2)
    

    print(image:getContentSize().width,image:getContentSize().height)
    image:onClick(function( ... )
      -- body
      print("-----image::onClick------------")
      
      self:requestHandle(self.room_handle_view_buz.result,image.item_index)
    end)

    image_x = image_x + x --+ 54*0.6
  end


end

function HandleViewLayout:show_chibox(card_dic_list)
  -- body
  self:_do_after_init()
  self.room_handle_view_guo.result = 0
  self.room_handle_view_guo:setVisible(true)
  local width = self.room_handle_view_guo:getContentSize().width
  local posX = self.room_handle_view_guo:getPositionX()
  local posY = self.room_handle_view_guo:getPositionY()

  self.room_handle_view_box:setPositionX(posX - width/2)
  self.room_handle_view_box:setPositionY(posY)
  local num = 0
  for _,card_dic in pairs(card_dic_list) do
    for _,card_value in pairs(card_dic) do
      num = num + 1
    end
  end
  print(num,"====================")
  local box_h = self.room_handle_view_box:getContentSize().height
  self.room_handle_view_box:setContentSize(cc.size((num+2)*54*0.6 ,box_h))
  local box_w =  self.room_handle_view_box:getContentSize().width

  local image_x = 54*0.6*3/2 + 54*0.6/2

  print("box_h--------------",box_h)
  local item_index = 0
  for _,card_dic in pairs(card_dic_list) do
    local image = ccui.Layout:create();
    image:setAnchorPoint(cc.p(0.0,0.0))
    image:setContentSize(cc.size(54*0.6*table.nums(card_dic),box_h))
    -- image:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
    -- image:setBackGroundColor(cc.c3b(255,0, 0)) 
    image.item_index = item_index
    item_index = item_index + 1
    local x = 54*0.6/2
    local y = box_h/2

    for _,card_value in pairs(card_dic) do
      
      local card_base = cc.Sprite:create(GAMEBASENAME.."/res/majiangCard/my_big_card01.png");
      local card_value_path = cardhandle.deal_card_path.get_card_path(card_value)
      local card_face = cc.Sprite:create(card_value_path);
      card_base:addChild(card_face)
      card_face:setPositionX(card_base:getContentSize().width/2)
      card_face:setPositionY(card_base:getContentSize().height/2-5)

      card_base:setPositionX(x)
      card_base:setPositionY(y)

      image:addChild(card_base)
      card_base:setScale(0.6)
      x = x +  card_base:getContentSize().width*0.6

    end
    self.room_handle_view_box:addChild(image)
    image:setPositionX(image_x)
    image:setPositionY(box_h/2)
    

    print(image:getContentSize().width,image:getContentSize().height)
    image:onClick(function( ... )
      -- body
      print("-----image::onClick------------")
      
      self:requestHandle(self.room_handle_view_chi.result,image.item_index)
    end)

    image_x = image_x + x --+ 54*0.6
  end


end

function HandleViewLayout:reset_state(notice_index_list)
	-- body
  -- if table.nums(notice_index_list) == 0 then
  --   return
  -- end

 -- table.sort(notice_index_list,function(v1,v2) return v1 > v2 end)
  local has = 0
  local hu_flag = 0
  local bu_zhang = 0
  local peng_flag = 0
  local gang_flag = 0
  local chi_flag = 0
-- {"64": [508, 307]}
  dump(notice_index_list,"notice_index_list")
  for handle_v,handle_dict in pairs(notice_index_list) do
      has   = 1
    handle_v = tonumber(handle_v) --fuck server
    if handle_v == handleview.ZIMO_OPCODE  or handle_v == handleview.HU_OPCODE   then
      hu_flag = 1
      self.room_handle_view_hu:setVisible(true)
      self.room_handle_view_hu.result = handle_v
    end

    if handleview.FANG_GANG_OPCODE == handle_v
      or handleview.MING_GANG_OPCODE == handle_v then

      self.room_handle_view_buz:setVisible(true)
      self.room_handle_view_buz.result = handle_v
      bu_zhang = 1
    end

    --暗杠
    if handleview.AN_GANG_OPCODE == handle_v then
      self.room_handle_view_buz:setVisible(true)
      self.room_handle_view_buz.result = handle_v
      bu_zhang = 1

       self.room_handle_view_buz.data = handle_dict
    end

    if handleview.GANG_OPCODE == handle_v then
      self.room_handle_view_gang:setVisible(true)
      self.room_handle_view_gang.result = handle_v
      gang_flag = 1
    end

    if handleview.CHI_OPCODE == handle_v then
      self.room_handle_view_chi:setVisible(true)
      self.room_handle_view_chi.result = handle_v
      chi_flag  = 1

      self.room_handle_view_chi.data_tbl = handle_dict
    end

    if handleview.PENG_OPCODE == handle_v then
      self.room_handle_view_peng:setVisible(true)
      self.room_handle_view_peng.result = handle_v
      peng_flag = 1
    end

  end



  if has  == 1 then
  	self.room_handle_view_guo.result = 0
  	self.room_handle_view_guo:setVisible(true)

  	--调整下位置,下面顺序不能乱
  	local width = self.room_handle_view_guo:getContentSize().width + 30
  	local posX = self.room_handle_view_guo:getPositionX()
    local posY = self.room_handle_view_guo:getPositionY()
    
    if chi_flag == 1 then
      posX = posX - width
      self.room_handle_view_chi:setPositionX(posX)
      self.room_handle_view_chi:setPositionY(posY)
    end

  	if peng_flag == 1 then
  		posX = posX - width
  		self.room_handle_view_peng:setPositionX(posX)
      self.room_handle_view_peng:setPositionY(posY)
  	end

    if gang_flag == 1 then
      posX = posX - width
      self.room_handle_view_gang:setPositionX(posX)
      self.room_handle_view_gang:setPositionY(posY)
    end

  	if hu_flag == 1 then
  		posX = posX - width
  		self.room_handle_view_hu:setPositionX(posX)
      self.room_handle_view_hu:setPositionY(posY)
  	end

    if bu_zhang == 1 then
      posX = posX - width
      self.room_handle_view_buz:setPositionX(posX)
      self.room_handle_view_buz:setPositionY(posY)
    end

  end

end