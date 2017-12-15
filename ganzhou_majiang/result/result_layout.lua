mrequire("cardhandle.deal_card_path")
mrequire("result.result_template")

ResultLayout = class("ResultLayout", result.result_template.result_Template)
local Sender = require(GAMEBASENAME..".Sender")
function ResultLayout:_do_after_init()

  self.card_firstpos = {}
  self.card_firstpos[0] = cc.p(79.76, 372.13)
  self.card_firstpos[1] = cc.p(79.76, 279.97)
  self.card_firstpos[2] = cc.p(79.76, 190.84)
  self.card_firstpos[3] = cc.p(79.76, 98.11)

  self.niaocard_pos = cc.p(81.40,16.84)
  self.result_niaotxt:setString("抓鸟")
  self.result_niaotxt:setVisible(false)

  local room_num = USER_INFO["invote_code"] or ""
  self.result_roomnum:setString("房号："..tostring(room_num))

  local gameConfig = USER_INFO["gameConfig"] or ""
  self.result_config:setString("推倒胡"..gameConfig)

  local time_tbl = os.date("*t")
  local time_str = tostring(time_tbl.year) .."-".. tostring(time_tbl.month).."-".. tostring(time_tbl.day )
  time_str = time_str .."  ".. tostring(time_tbl.hour) ..":".. tostring(time_tbl.min )..":".. tostring(time_tbl.sec  )
 -- print(time_str)
  self.result_time:setString(time_str)

  self.result_over_btn:setVisible(false)

  layout.hide_layout("room_handle_view")

 local layout_object = layout.manager:get_layout_object("group_result")

  local m_GroupTimes,m_rec_time= zzroom.manager:get_room_base_gouptime()
  -- m_GroupTimes = m_GroupTimes+1

  if m_GroupTimes ==  m_rec_time or layout_object ~= nil then
    self:set_overstate()
  else
      self.result_regain_btn:setVisible(false)
      local action_te = cc.Sequence:create(
        cc.DelayTime:create(1.5),
        cc.CallFunc:create(function()
            self.result_regain_btn:setVisible(true)
        end)
      )
      self:runAction(action_te)
  end

  print("ResultLayout:_do_after_init--------m_GroupTimes-------------m_rec_time-----------",m_GroupTimes,m_rec_time)

  self.delay_time_f = 0

     --移除录音按钮
  require("hall.VoiceRecord.VoiceRecordView"):removeView()


  local player_style = zzroom.manager:get_player_style()
  if player_style == 3 then
    self.result_score2:setVisible(false)
    self.result_name2:setVisible(false)
  end

end

-- function ResultLayout:before_release()
--   -- body
  
-- end

function ResultLayout:set_niao_card( cards_tbl,zhongcard )
  local zhong_tbl = {}
  zhongcard = zhongcard or {}
  for _,card in pairs(zhongcard)do
    zhong_tbl[card] = 1
  end

  -- body
  if #cards_tbl > 0 then
  
    self.result_niaotxt:setVisible(true)
    local pos = self.niaocard_pos
    local width = self.result_card:getContentSize().width
    for _,card_value in pairs(cards_tbl) do
          local card = self.result_card:clone()
          card:setPosition(pos)

        if card_value == nil then
           card_value = card_data.card
        end
        
         -- local card_value = card_data.card
        if card_value ~= nil and card_value ~= 0 then
            local image_tx =  cardhandle.deal_card_path.get_card_path(card_value)
            local image = card:getChildByName("result_card_image")
            image:loadTexture(image_tx)

            self:addChild(card)
            pos.x = pos.x + width
   

            if zhong_tbl[card_value] == 1 then
              card:setColor(cc.c3b(255,255,0))
            end
        end
    end

  end
  
end

function ResultLayout:reset_zuanpos(index)
  print("ResultLayoutreset_zuanpos(index)---------------------",index)
  index = index or 0
  local pos = {}
  pos[0] = cc.p(47.96, 405.28)
  pos[1] = cc.p(47.96, 310.83)
  pos[2] = cc.p(47.96, 218.72)
  pos[3] = cc.p(47.96, 128.26)
  self.result_zuan:setPosition(pos[index])
end

function ResultLayout:reset_hupos( index )
  print("index------------------")
   index = index or 0
  local hu_pos = {}
  hu_pos[0]= cc.p(868.37,399.41)
  hu_pos[1]=cc.p(868.37,318.06)
  hu_pos[2]=cc.p(868.37,222.94)
  hu_pos[3]=cc.p(868.37,140.34)

  local hu = self.result_hu:clone()
  hu:setPosition(hu_pos[index])

  self.result_cardbase:addChild(hu)
end


function ResultLayout:reset_title_state( state )
  -- body
  state = state or 0
  if state == 0 then--流局
    self.result_title:setBackGroundImage(GAMEBASENAME.."/res/image/mahjong_lose_bt.png")
    self.result_title_image:loadTexture(GAMEBASENAME.."/res/image/text_liuju .png")

  elseif state > 0 then --赢了
    self.result_title:setBackGroundImage(GAMEBASENAME.."/res/image/red_button_p.png")
    self.result_title_image:loadTexture(GAMEBASENAME.."/res/image/mahjong_win.png")
  else
    self.result_title:setBackGroundImage(GAMEBASENAME.."/res/image/mahjong_lose_bt.png")
    self.result_title_image:loadTexture(GAMEBASENAME.."/res/image/mahjong_lose.png")
  end

end


function ResultLayout:draw_card( index,content)
  -- body
  print(index,"-------------index--------------")
  dump(content,"content")
  index = index or 0
  local pos = self.card_firstpos[index]

  local width = self.result_card:getContentSize().width

  local des_txt = ""
  --暗杠
  local anGangNum = table.nums(content.account_last_an_gang_list)
  if anGangNum > 0 then
      for _,card_value in pairs(content.account_last_an_gang_list) do
        for i = 1,3 do
          local card = self.result_card:clone()
          self.result_cardbase:addChild(card)
          card:setPosition(pos)
          local image_tx =  cardhandle.deal_card_path.get_card_path(card_value)
          local image = card:getChildByName("result_card_image")
          image:loadTexture(image_tx)

          pos.x = pos.x + width
        end
        local result_backcard = self.result_backcard:clone()
        self.result_cardbase:addChild(result_backcard)
         result_backcard:setPosition(pos)
        pos.x = pos.x + width
      end
  end
  if anGangNum > 0 then
    pos.x = pos.x + width/3
    des_txt = des_txt .. "暗杠X"..tostring(anGangNum).." "
  end
  
  --放杠
  local fang_gangNum = 0

  for _,card_value_list in pairs(content.account_last_fang_gang_dict) do
    for _,card_value in pairs(card_value_list) do
      fang_gangNum = fang_gangNum + 1
      for i = 1,4 do
        local card = self.result_card:clone()
        self.result_cardbase:addChild(card)
        card:setPosition(pos)
        local image_tx =  cardhandle.deal_card_path.get_card_path(card_value)
        local image = card:getChildByName("result_card_image")
        image:loadTexture(image_tx)

        pos.x = pos.x + width
      end
    end
  end

  if fang_gangNum > 0 then
    pos.x = pos.x + width/3
    des_txt = des_txt .."放杠X"..tostring(fang_gangNum).." "
  end

  --明杆
  local mingGangNum = table.nums(content.account_last_ming_gang_list)
  if mingGangNum > 0 then
      for _,card_value in pairs(content.account_last_ming_gang_list) do
        --for _,card_value in pairs(card_value_list) do
          for i = 1,4 do
            local card = self.result_card:clone()
            self.result_cardbase:addChild(card)
            card:setPosition(pos)
            local image_tx =  cardhandle.deal_card_path.get_card_path(card_value)
            local image = card:getChildByName("result_card_image")
            image:loadTexture(image_tx)

            pos.x = pos.x + width
          end
        --end
      end
  end

  if mingGangNum > 0 then
    pos.x = pos.x + width/3
    des_txt = des_txt .."明杆X"..tostring(mingGangNum).." "
  end

  --吃
  local chi_num = table.nums(content.account_last_chi_list)
  if chi_num > 0 then
    for _,card_value_list in pairs(content.account_last_chi_list) do
      for _,card_value in pairs(card_value_list) do
          local card = self.result_card:clone()
          self.result_cardbase:addChild(card)
          card:setPosition(pos)
          local image_tx =  cardhandle.deal_card_path.get_card_path(card_value)
          local image = card:getChildByName("result_card_image")
          image:loadTexture(image_tx)

          pos.x = pos.x + width
      end
    end
  end

  if chi_num > 0 then
    pos.x = pos.x + width/3
  end

  --碰
  local pengNum =  table.nums(content.account_last_peng_list)-- or 0
  if pengNum > 0 then
    for _,card_value in pairs(content.account_last_peng_list) do
        for i = 1,3 do
            local card = self.result_card:clone()
            card:setPosition(pos)
            self.result_cardbase:addChild(card)

            local image_tx =  cardhandle.deal_card_path.get_card_path(card_value)
            local image = card:getChildByName("result_card_image")
            image:loadTexture(image_tx)

            pos.x = pos.x + width
        end
    end
  end

  if pengNum > 0 then
    pos.x = pos.x + width/3
  end

  --获取胡的那张牌
  local account_hu_conbination_list = content.account_hu_conbination_list or {}
  account_hu_conbination_list = account_hu_conbination_list[1] or {}
  local hucard = account_hu_conbination_list[3] or 0
  hucard = tonumber(hucard)

  local draw_flag = false

  --手牌
  local userleftcardmount = table.nums(content.account_handcard)
  if userleftcardmount%3 == 1 then --如果是余一张的话，那么不处理
    draw_flag = true
  end

  if userleftcardmount > 0 then
    for _,card_value in pairs(content.account_handcard) do
          if draw_flag == false and card_value == hucard then
            draw_flag = true
          else
            local card = self.result_card:clone()
            card:setPosition(pos)
            self.result_cardbase:addChild(card)

            local image_tx =  cardhandle.deal_card_path.get_card_path(card_value)
            local image = card:getChildByName("result_card_image")
            image:loadTexture(image_tx)

            pos.x = pos.x + width
          end
    end
    
    pos.x = pos.x + width/3
  end

  -- if userleftcardmount > 0 then
  --   pos.x = pos.x + width/3
  -- end


  if  hucard ~= 0 then
    local card = self.result_card:clone()
    card:setPosition(pos)
    self.result_cardbase:addChild(card)

    local image_tx =  cardhandle.deal_card_path.get_card_path(hucard)
    local image = card:getChildByName("result_card_image")
    image:loadTexture(image_tx)
  end


  local score = content.account_change_chip or 0
  self:reset_result_score(index,score)
  if index == 0 then
    self:reset_title_state(score)
  end

  if account_hu_conbination_list[1] ~= nil then
    self:reset_hupos(index)
  end

  return des_txt
end

function ResultLayout:reset_result_score( index,score )
  -- body
  local tbl = {}
  tbl[0] = self.result_score0
  tbl[1] = self.result_score1
  tbl[2] = self.result_score2
  tbl[3] = self.result_score3
  tbl[tonumber(index)]:setString(score)
end


function ResultLayout:reset_result_txt( index,txt )
  -- body
  local tbl = {}
  tbl[0] =self.result_txt0
  tbl[1] =self.result_txt1
  tbl[2] =self.result_txt2
  tbl[3] =self.result_txt3
  tbl[tonumber(index)]:setString(txt)

end


function ResultLayout:reset_name( index,name )
  -- body
  local tbl = {}
  tbl[0] =self.result_name0
  tbl[1] =self.result_name1
  tbl[2] =self.result_name2
  tbl[3] =self.result_name3

tbl[tonumber(index)]:setString(name)

end


function ResultLayout:after_show()
  local action_te = cc.Sequence:create(
    cc.DelayTime:create(10),
    cc.CallFunc:create(function()
    self:click_result_regain_btn_event()
    end)
    )
  self:runAction(action_te)
end

function ResultLayout:click_result_regain_btn_event()
 -- print("click_result_regain_btn_event------1------------------")
--再来一盘，清空当前盘一局打出去的牌
  zzroom.manager:initialize()
  
  local room_card_object = layout.manager:get_layout_object("room_card")
  if room_card_object ~= nil then
    room_card_object:remove_alloutimage()
  end

  

  --如果牌局结束了，那么就不发登陆消息了
  local group_result_object = layout.manager:get_layout_object("group_result")
  if group_result_object ~=  nil then
    --print("click_result_regain_btn_event----2--------------------")
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

function ResultLayout:click_result_over_btn_event()
  --再来一盘，清空当前盘一局打出去的牌
  local room_card_object = layout.manager:get_layout_object("room_card")
  if room_card_object ~= nil then
    room_card_object:remove_alloutimage()
  end
  
  local layout_object = layout.manager:get_layout_object("group_result")
  if layout_object ~= nil then
     self:hide_layout()
  end
end

function ResultLayout:set_overstate()
  self.result_over_btn:setVisible(true)
  self.result_regain_btn:setVisible(false)

  local room_card_object = layout.manager:get_layout_object("room_card")
  if room_card_object ~= nil then
    room_card_object:remove_alloutimage()
  end

end

function ResultLayout:click_result_room_btn_quit_room_event()

    local data_tbl = {}
    Sender:send(mprotocol.H2G_DISSOLVE_ROOM,data_tbl)
end

function ResultLayout:set_delay_time( delay_time )
  -- body
  self.delay_time_f = delay_time
end

function ResultLayout:get_delay_time()
  -- body
  return  self.delay_time_f or 0
end