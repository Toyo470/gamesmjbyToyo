--碰杠胡等操作
local Sender = require(GAMEBASENAME..".".."Sender")

mrequire("handleview.room_handle_view_template")
HandleViewLayout = class("HandleViewLayout", handleview.room_handle_view_template.room_handle_view_Template)

function HandleViewLayout:_do_after_init()
end


function HandleViewLayout:click_room_handle_view_guo_event()
  local result = self.room_handle_view_guo.result
  self:requestHandle(result)
end


function HandleViewLayout:callback_Image( Image_target )
  -- body
    local handle_v = Image_target.result
    local handle_dict = Image_target.data
    local laizi  = Image_target.laizi

    if handle_v == handleview.ZIMO_OPCODE or 
       handle_v == handleview.HU_OPCODE or  --胡牌
       handleview.FANG_GANG_OPCODE == handle_v or -- 放杠
       handleview.FEI_OPCODE ==  handle_v or -- 飞操作（癞子碰）
       handleview.MING_GANG_OPCODE == handle_v or -- 放杠
       handleview.PENG_OPCODE == handle_v then --碰牌

      self:requestHandle(handle_v,laizi)

    elseif handleview.TI_OPCODE == handle_v then --ti
      local ti_card = Image_target.ti_card
      self:requestHandle(handle_v,ti_card)

    elseif handleview.AN_GANG_OPCODE == handle_v  then 

          if handle_dict == nil or table.nums(handle_dict[2]) == 1 then
            self:requestHandle(handle_v)
          else
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
    elseif handleview.CHI_OPCODE == handle_v then --吃牌
        handle_dict = handle_dict[2] or {}
        if table.nums(handle_dict) > 1 then
          self:show_chibox(handle_dict)
        else  
          self:requestHandle(handle_v)
        end

    end

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

function HandleViewLayout:reset_state(notice_index_list)

  dump(notice_index_list,"notice_index_list")
  --调整下位置,下面顺序不能乱
  local width = self.room_handle_view_guo:getContentSize().width + 30
  local posX = self.room_handle_view_guo:getPositionX()
  local posY = self.room_handle_view_guo:getPositionY()
  self.room_handle_view_guo.result = 0

  for handle_v,handle_dict in pairs(notice_index_list) do
    handle_v = tonumber(handle_v)
    
    -- if handleview.FEI_OPCODE == handle_v or handleview.TI_OPCODE == handle_v  then
    --   local Image_target = handleview.get_operator_card(handle_dict[2])
    --   self:addChild(Image_target)
    --   posX = posX - 50
    --   Image_target:setPositionX(posX)
    --   Image_target:setPositionY(posY)

    -- end



    local Image_target,ex_len = handleview.get_operator_image(handle_v,handle_dict)

    posX = posX - width-ex_len
    Image_target:setPositionX(posX)
    Image_target:setPositionY(posY)

    Image_target.result = handle_v
   
    Image_target:onClick(handler(self, self.callback_Image))
    self:addChild(Image_target)

    Image_target.data = handle_dict


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