mrequire("zzroom.deal_card_path")
mrequire("result.result_template")

ResultLayout = class("ResultLayout", result.result_template.result_Template)

function ResultLayout:_do_after_init()

  self.card_firstpos = {}
  self.card_firstpos[0] = cc.p(79.76, 374.13)
  self.card_firstpos[1] = cc.p(79.76, 281.97)
  self.card_firstpos[2] = cc.p(79.76, 192.84)
  self.card_firstpos[3] = cc.p(79.76, 100.11)

  self.niaocard_pos = cc.p(81.40,16.84)
  self.result_niaotxt:setString("抓鸟")
  self.result_niaotxt:setVisible(false)

  local room_num = USER_INFO["invote_code"] or ""
  self.result_roomnum:setString("房号："..tostring(room_num))

  local gameConfig = USER_INFO["gameConfig"] or ""
  self.result_config:setString("广东麻将："..gameConfig)

  local time_tbl = os.date("*t")
  local time_str = tostring(time_tbl.year) .."-".. tostring(time_tbl.month).."-".. tostring(time_tbl.day )
  time_str = time_str .."  ".. tostring(time_tbl.hour) ..":".. tostring(time_tbl.min )..":".. tostring(time_tbl.sec  )
 -- print(time_str)
  self.result_time:setString(time_str)

  self.result_over_btn:setVisible(false)

  layout.hide_layout("room_handle_view")

  -- local room_card_object = layout.manager:get_layout_object("room_card")
  -- if room_card_object ~= nil then
  --   room_card_object:remove_alloutimage()
  -- end

  local pack = zzroom.manager:get_group_time()
  dump(pack,"pack")
  local m_rec_time = pack.m_rec_time or 0
  local m_GroupTimes = pack.m_GroupTimes or 0
  m_GroupTimes = m_GroupTimes+1

  if m_GroupTimes ==  m_rec_time then
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

  print("ResultLayout:_do_after_init--------m_GroupTimes-------------m_rec_time-----------")

  self.delay_time_f = 0
end

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
            local image_tx =  zzroom.deal_card_path.get_card_path(card_value)
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
    self.result_title:setBackGroundImage("gd_majiang/res/image/mahjong_lose_bt.png")
    self.result_title_image:loadTexture("gd_majiang/res/image/text_liuju .png")

  elseif state > 0 then --赢了
    self.result_title:setBackGroundImage("gd_majiang/res/image/red_button_p.png")
    self.result_title_image:loadTexture("gd_majiang/res/image/mahjong_win.png")
  else
    self.result_title:setBackGroundImage("gd_majiang/res/image/mahjong_lose_bt.png")
    self.result_title_image:loadTexture("gd_majiang/res/image/mahjong_lose.png")
  end

end


function ResultLayout:draw_card( index,content,hucard)
  -- body
  index = index or 0
  local pos = self.card_firstpos[index]

  local width = self.result_card:getContentSize().width

  local anGangNum = content.anGangNum or 0
  if anGangNum > 0 then
      for _,card_value in pairs(content.anGangArray) do
        for i = 1,3 do
          local card = self.result_card:clone()
          self.result_cardbase:addChild(card)
          card:setPosition(pos)
          local image_tx =  zzroom.deal_card_path.get_card_path(card_value)
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
  end
  
  local mingGangNum = content.mingGangNum or 0
  if mingGangNum > 0 then
      for _,card_value in pairs(content.mingGangArray) do
        for i = 1,4 do
          local card = self.result_card:clone()
          self.result_cardbase:addChild(card)
          card:setPosition(pos)
          local image_tx =  zzroom.deal_card_path.get_card_path(card_value)
          local image = card:getChildByName("result_card_image")
          image:loadTexture(image_tx)

          pos.x = pos.x + width
        end
      end
  end
  if mingGangNum > 0 then
    pos.x = pos.x + width/3
  end
  
  local pengNum =  content.pengNum or 0
  if pengNum > 0 then
    for _,card_value in pairs(content.pengArray) do
        for i = 1,3 do
            local card = self.result_card:clone()
            card:setPosition(pos)
            self.result_cardbase:addChild(card)

            local image_tx =  zzroom.deal_card_path.get_card_path(card_value)
            local image = card:getChildByName("result_card_image")
            image:loadTexture(image_tx)

            pos.x = pos.x + width
        end
    end
  end

  if pengNum > 0 then
    pos.x = pos.x + width/3
  end




  dump(content,"content")
  print("hucard---------------------",hucard)
  local userleftcardmount = content.userleftcardmount or 0
  local ignore = false
  if hucard == 0 then --跟踪了下，流局的话，大家都没有胡的话，那么服务器发过来的是0
    ignore = true
  end

  if userleftcardmount > 0 then
    for _,card_value in pairs(content.userleftcard) do
        if hucard == card_value and ignore == false then 
          ignore = true
          
        else
          local card = self.result_card:clone()
          card:setPosition(pos)
          self.result_cardbase:addChild(card)

          local image_tx =  zzroom.deal_card_path.get_card_path(card_value)
          local image = card:getChildByName("result_card_image")
          image:loadTexture(image_tx)

          pos.x = pos.x + width
        end
    end
    
    pos.x = pos.x + width/3

    if hucard ~= 0 then
      local card = self.result_card:clone()
      card:setPosition(pos)
      self.result_cardbase:addChild(card)

      local image_tx =  zzroom.deal_card_path.get_card_path(hucard)
      local image = card:getChildByName("result_card_image")
      image:loadTexture(image_tx)
    end

  end
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


function ResultLayout:reset_name( index,name )
  -- body
  local tbl = {}
  tbl[0] =self.result_name0
  tbl[1] =self.result_name1
  tbl[2] =self.result_name2
  tbl[3] =self.result_name3

tbl[tonumber(index)]:setString(name)

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
  local room_card_object = layout.manager:get_layout_object("room_card")
  if room_card_object ~= nil then
    room_card_object:remove_alloutimage()
    if room_card_object.room_card_ting_renyi then
      room_card_object.room_card_ting_renyi:setVisible(false) --清除任意牌可胡
    end
  end

  --如果牌局结束了，那么就不发登陆消息了
  local group_result_object = layout.manager:get_layout_object("group_result")
  if group_result_object ~=  nil then
    --print("click_result_regain_btn_event----2--------------------")
    self:hide_layout()
    return
  end
  
  local pack = zzroom.manager:get_group_time()
  local m_rec_time = pack.m_rec_time or 0
  local m_GroupTimes = pack.m_GroupTimes or 0
  m_GroupTimes = m_GroupTimes+1

  if m_GroupTimes ==  m_rec_time then
    --print("click_result_regain_btn_event------3------------------")
    self:hide_layout()
    return
  end

--print("click_result_regain_btn_event------------------------")
local gd_majiangServer = require("gd_majiang.gd_majiangServer")
gd_majiangServer:LoginGame(63)
--print("click_result_regain_btn_event--------4----------------")

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
  
    layout.hide_layout("room_card")
    layout_object:setVisible(true)
end

function ResultLayout:set_overstate()
  self.result_over_btn:setVisible(true)
  self.result_regain_btn:setVisible(false)
  self.result_room_btn_quit_room:setVisible(false)
end

function ResultLayout:click_result_room_btn_quit_room_event()
  -- local gd_majiangServer = require("gd_majiang.gd_majiangServer")
  -- gd_majiangServer:c2s_request_dissove()
  require("hall.gameSettings"):disbandGroup("gd")
end

function ResultLayout:set_delay_time( delay_time )
  -- body
  self.delay_time_f = delay_time
end

function ResultLayout:get_delay_time()
  -- body
  return  self.delay_time_f or 0
end