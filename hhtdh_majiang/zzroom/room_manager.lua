RoomManager = class("RoomManager")

function RoomManager:ctor()
    self.user_seat = 0

    self.uid_otherindex = {}

    self.Room_Card = {}

    self.last_pos = {}

    self.time_tip_name = {}

    self.last_operator = ""

    self.rec_out_card_index = -1 --最近一次出牌的index

    self.rec_out_card_value = 0 --最近一次出牌的牌值


    self.user_data = {}

    self.ZuanSeatId = nil

    self.group_time = {}


    self.video_flag = false

    --0是游戏没开始，1是游戏开始了
    self.game_state = 0

    self.uid_ip_dict = {}
    self.uid_name_dict = {}
    self.show_sameip_tip_flag = false
    self.me_ip = ""


    self.player_style = 4
    
    self.group_round = 0
    self.group_total_round = 0
end

function RoomManager:set_room_base_gouptime(group_round,group_total_round)
  -- body
  if group_round ~= nil then
      self.group_round = group_round
  end

  if group_total_round ~= nil then
      self.group_total_round = group_total_round
  end
  
end

function RoomManager:get_room_base_gouptime()
  -- body
  return self.group_round, self.group_total_round
end

function RoomManager:set_player_style( num )
  -- body
    self.player_style = num
end

function RoomManager:get_player_style()
  -- body
    return self.player_style
end


function RoomManager:release()
  -- body
  self.user_seat = 0
  self.uid_otherindex = {}
  self.Room_Card = {}

  for i=0,3 do
      self.Room_Card[i] = {}
      self.Room_Card[i]['porg'] = {}
      self.Room_Card[i]['hand'] = {}
      self.Room_Card[i]['out']  = {}
      self.Room_Card[i]['gang']  = {}

      self.last_pos[i] = cc.p(0, 0)
  end
  self.ZuanSeatId = nil
  self.uid_ip_dict = {}
  self.uid_name_dict = {}
  self.me_ip = ""
end

function RoomManager:initialize( )
  -- body
  for i=0,3 do
        self.Room_Card[i] = {}
        self.Room_Card[i]['porg'] = {}
        self.Room_Card[i]['hand'] = {0,0,0,0,0,0,0,0,0,0,0,0,0}
        self.Room_Card[i]['out']  = {}
        self.Room_Card[i]['gang']  = {}

        self.last_pos[i] = cc.p(0, 0)
  end
  self.Room_Card[0]['hand'] = {}
end

function RoomManager:reset_card_state( other_index,hand_card_num)
  -- body
  print("reset_card_state-------------",other_index)
  hand_card_num = hand_card_num or 0
  other_index = tonumber(other_index)
  hand_card_num = tonumber(hand_card_num)

  local hand_card = {}
  if other_index == 0 then
    hand_card = self.Room_Card[0]['hand']
  end

  self.Room_Card[other_index] = {}
  self.Room_Card[other_index]['porg'] = {}
  self.Room_Card[other_index]['out']  = {}
  self.Room_Card[other_index]['gang']  = {}

  if other_index ~= 0 then
    self.Room_Card[other_index]['hand'] = {}
    for i = 1,hand_card_num do
      table.insert(self.Room_Card[other_index]['hand'],0)
    end
  else
    self.Room_Card[0]['hand'] = hand_card
  end

end

function RoomManager:set_user_seat(uid,user_seat)
  -- body
  print("uid,user_seat--------------",uid,user_seat)
 	self.user_seat = user_seat
  self.uid_otherindex[uid] = 0
end

function RoomManager:get_user_seat( )
  -- body
  return self.user_seat
end

function RoomManager:set_other_seat(uid,other_seat)
	-- body
  print("uid,user_seat--------------",uid,other_seat)
  local other_index = other_seat - self.user_seat
  if other_index < 0 then
    other_index = other_index + self.player_style
  end

  --以下代码是为了适应2人麻将，3人麻将
  if self.player_style == 4 then

  elseif self.player_style == 3 then
    if other_index == 2 then
        other_index = 3 
    end

  elseif self.player_style == 2 then
    if other_index == 1 then
        other_index = 2 
    end
  end
  
  self.uid_otherindex[uid] = other_index
end

function RoomManager:get_other_index( uid )
  -- body
  return self.uid_otherindex[uid]
  
end

function RoomManager:get_other_index_by_seat(other_seat)

  local other_index = other_seat - self.user_seat
  if other_index < 0 then
    other_index = other_index + self.player_style
  end

  --以下代码是为了适应2人麻将，3人麻将
  if self.player_style == 4 then

  elseif self.player_style == 3 then
    if other_index == 2 then
        other_index = 3 
    end

  elseif self.player_style == 2 then
    if other_index == 1 then
        other_index = 2 
    end
  end

  return other_index
end

function RoomManager:init_card(cards)
  dump(cards,"init_card")
  self.Room_Card[0]['hand'] = cards
  -- self.Room_Card[0]['porg'] = {102,102,102,102,103,103,103,103}
  -- self.Room_Card[0]['gang'][102]  = 1
  
  -- self.Room_Card[1]['hand'] = {0,0,0,0,0,0,0}
  -- self.Room_Card[1]['porg'] = {102,102,102,102,103,103,103,103}
  -- self.Room_Card[1]['gang'][102]  = 1
  
  -- self.Room_Card[2]['hand'] = {0,0,0,0,0,0,0}
  -- self.Room_Card[2]['porg'] = {102,102,102,102,103,103,103,103}
  -- self.Room_Card[2]['gang'][102]  = 1

  -- self.Room_Card[3]['hand'] = {0,0,0,0,0,0,0}
  -- self.Room_Card[3]['porg'] =  {102,102,102,102,103,103,103,103}
  -- self.Room_Card[3]['gang'][102]  = 1


   -- self.Room_Card[0]['out']  = {102,102,102,102,103,103,103,103}
  --  self.Room_Card[1]['out']  = {102,102,102,102,103,103,103,103}
  --  self.Room_Card[2]['out']  = {102,102,102,102,103,103,103,103}
  --  self.Room_Card[3]['out']  = {102,102,102,102,103,103,103,103}

end

function RoomManager:get_timertip_name( other_index )
  return self.time_tip_name[other_index] or ""
  -- body
end
function RoomManager:init_zuan_flag(other_index)
  print("other_index-----init_zuan_flag--------",other_index)
   local tbl = {}
   if other_index == 0 then
     tbl[0] = "room_base_dong"
     tbl[1] = "room_base_nan"
     tbl[2] = "room_base_xi"
     tbl[3] = "room_base_bei"

   elseif other_index == 1 then
     tbl[0] = "room_base_bei"
     tbl[1] = "room_base_dong"
     tbl[2] = "room_base_nan"
     tbl[3] = "room_base_xi"
    

   elseif other_index == 2 then
     tbl[2] = "room_base_dong"
     tbl[3] = "room_base_nan"
     tbl[0] ="room_base_xi"
     tbl[1] ="room_base_bei"

   elseif other_index == 3 then
     tbl[3] = "room_base_dong"
     tbl[0] = "room_base_nan"
     tbl[1] ="room_base_xi"
     tbl[2] ="room_base_bei"
   end


  self.time_tip_name[0] = tbl[0]
  self.time_tip_name[1] = tbl[1]
  self.time_tip_name[2] = tbl[2]
  self.time_tip_name[3] = tbl[3]

end

function RoomManager:get_card( other_index )
  -- body
   return self.Room_Card[other_index] or {}
end

function RoomManager:insert_hand_card(index,cards)
  for _,card in pairs(cards) do
    table.insert(self.Room_Card[index]['hand'],card)
  end
end

function RoomManager:insert_porg_card( index,cards )
  for _,card in pairs(cards) do

    if type(card) == "table" then
      printError("table"..tostring(index))
    end

    table.insert(self.Room_Card[index]['porg'],card)
  end
end

function RoomManager:set_porg_card_tbl(index,tbl)
    self.Room_Card[index]['porg'] = tbl
end

function RoomManager:set_hand_card_tbl(index,tbl)
    self.Room_Card[index]['hand'] = tbl
end

function RoomManager:set_gang_type( index,card_value,gang_type )
  -- body
  self.Room_Card[index]['gang'][card_value]  = gang_type
end


function RoomManager:remove_hand_card(index,card,mount)
  print("index------------",index)
 -- dump(self.Room_Card[index]['hand'],"self.Room_Card[index]['hand']")
  local mytable =  self.Room_Card[index]['hand'] or {}
  local i = 1
  local count = 0
  while i <= #mytable do
    if count >= mount and mount ~= 0 then
      break
    end
    if mytable[i] == card then
      table.remove(mytable, i)
      count = count + 1
    else
      i = i + 1
    end
  end
  --dump(self.Room_Card[index]['hand'],"self.Room_Card[index]['hand']")
end

function RoomManager:insert_out_card( index,cards )
  -- body
  for _,card in pairs(cards) do
    table.insert(self.Room_Card[index]['out'],card)
  end
end

function RoomManager:remove_cout_card( index, card )
  -- body
  local out_cards = self.Room_Card[index]['out']
  local card_num = table.nums(out_cards)
  if card_num > 0 then
      local index_target = nil
      for _index,d in pairs(self.Room_Card[index]['out']) do
          if card == d then
            index_target = _index
          end
      end
      if index_target ~= nil then
        table.remove(self.Room_Card[index]['out'],index_target)
      end
  end
end

function RoomManager:set_last_pos( index,pos )
  -- body
  if index < 0 or index > 3 then
    return
  end

  self.last_pos[index] = pos
end

function RoomManager:get_last_pos( index )
  -- body
  if index < 0 or index > 3 then
    return
  end
  
  return self.last_pos[index]
end


function RoomManager:set_last_operator(operator_name)
  -- body
  self.last_operator = operator_name
end

function RoomManager:get_last_operator()
  -- body
  return self.last_operator or ""
end


function RoomManager:set_out_card_index( index )
  -- body
    self.rec_out_card_index = index
end

function RoomManager:get_out_card_index()
  -- body
  return self.rec_out_card_index
end


function RoomManager:set_rec_out_card_value( card_value )
  -- body
  self.rec_out_card_value = card_value
end

function RoomManager:get_rec_out_card_value( )
  -- body
  return self.rec_out_card_value
end




function RoomManager:deal_gang(  index,cards_value,gang_type,gang_result)
  -- ZIMO_OPCODE = 1#自摸                            [target_account_id,["pph"]]
  -- HU_OPCODE = 2#胡牌                              [target_account_id,["pph"]]
  -- FANG_GANG_OPCODE = 4#自己抓到3张相同的牌，其他玩家打出1张相同牌       [target_account_id,102]
  -- AN_GANG_OPCODE = 8#自己抓到4张相同的牌                     [target_account_id,[101,102]]
  -- MING_GANG_OPCODE = 16#自己碰牌后，自己又摸到相同的牌             [target_account_id,102]
  -- GANG_OPCODE = 32#开杠拿（2张牌）                       [target_account_id,102]
  -- PENG_OPCODE = 64#碰牌                             [target_account_id,102]
  -- CHI_OPCODE = 128#吃牌                           [target_account_id,[[101,102,103],[202,203,204]]]
  -- HAIDI_OPCODE = 256#海底                           [target_account_id]

 --杠思路：如果原先有碰的话，那么先删除掉，然后再插入4张牌
  -- 
  --思路：如果原先有碰的话，那么先删除掉，然后再插入4张牌
  -- if tonumber(cards_value) == 201 then
  --   printError("deal_gang")
  -- end

  local item_index = 1
  while item_index <= #self.Room_Card[index]['porg'] do
    local temp_card = tonumber(self.Room_Card[index]['porg'][item_index])
    if tonumber(cards_value) == temp_card then
      table.remove(self.Room_Card[index]['porg'], item_index)
    else
      item_index = item_index + 1
    end
  end
  local cards = {cards_value,cards_value,cards_value,cards_value}
  for _,card in pairs(cards) do
    table.insert(self.Room_Card[index]['porg'],card)
  end

  self:set_gang_type(index,cards_value,gang_type)



  if index ==  0 then
      --删除手上的杠牌
      local item_index = 1
      while item_index <= #self.Room_Card[index]['hand'] do
        local temp_card = tonumber(self.Room_Card[index]['hand'][item_index])
        if tonumber(cards_value) == temp_card then
          table.remove(self.Room_Card[index]['hand'], item_index)
        else
          item_index = item_index + 1
        end
      end
  else
    print("gang_result-------------------------",gang_result)
    if handleview.MING_GANG_OPCODE == gang_result then --补杆
        self:remove_hand_card(index,0,1)
    elseif handleview.AN_GANG_OPCODE == gang_result then--暗杠
       self:remove_hand_card(index,0,4)
    elseif handleview.FANG_GANG_OPCODE == gang_result then--放杠
      self:remove_hand_card(index,0,3)
    elseif  handleview.GANG_OPCODE == gang_result then --#开杠拿（2张牌）
      self:remove_hand_card(index,0,4)
    end
  end

end

function RoomManager:set_user_data( uid,data_tbl )
  -- body
   self.user_data[uid] = data_tbl
end

function RoomManager:get_user_data( uid )
  -- body
   return self.user_data[uid]
end

function RoomManager:get_alluser_data()
  -- body
   return self.user_data
end

function RoomManager:getlast_zuanindex()
  -- body
  return self.ZuanSeatId or -1
end

function RoomManager:set_ZuanSeatId( ZuanSeatId )
  -- body
  self.ZuanSeatId = ZuanSeatId
end

function RoomManager:set_group_time( pack )
  -- body
  self.group_time = pack
end

function RoomManager:get_group_time( )
  -- body
  return self.group_time or {}
end

function RoomManager:set_video_flag( flag )
  -- body
  self.video_flag = flag
end

function RoomManager:get_video_flag( )
  -- body
  return self.video_flag or false
end

function RoomManager:set_game_state(state)
  -- body
  if state == nil then
    state = 1
  end

  --state = state or 1
  self.game_state = state
end


function RoomManager:get_game_state()
  -- body
  return self.game_state or 0
end

function RoomManager:set_uid_ip(uid,ip,nick_name)
  -- body
  nick_name = require("hall.GameCommon"):formatNick(nick_name)--调下豪哥借口格式下
  self.uid_name_dict[uid] = nick_name

  self:after_set_uid_ip()

end

function RoomManager:set_player_ip( uid,ip )
  -- body
  if self.uid_ip_dict[ip] == nil then
     self.uid_ip_dict[ip] = {}
     if tonumber(uid) == tonumber(USER_INFO["uid"]) then
        self.me_ip = ip
     else
        table.insert(self.uid_ip_dict[ip],uid)
     end
  else
     local find_flag = false
     for _,_uid in pairs(self.uid_ip_dict[ip]) do
        if _uid == uid then
          find_flag = true
          break
        end
     end
     if find_flag == false then
        if tonumber(uid) == tonumber(USER_INFO["uid"]) then
            self.me_ip = ip
        else
            table.insert(self.uid_ip_dict[ip],uid)
        end
     end
  end

  self:after_set_uid_ip()
end


function RoomManager:get_player_ip( uid )
  -- body
  local ip_str = ""
  if tonumber(uid) == tonumber(USER_INFO["uid"]) then
    ip_str = self.me_ip or ""
  else
    for _ip,uid_tbl in pairs(self.uid_ip_dict) do
      for _,uid_ in pairs(uid_tbl) do
        if uid_ ==  uid then
          ip_str = _ip
          break
        end
      end
    end
  end
  return ip_str

end


function RoomManager:after_set_uid_ip()
  -- body
  mrequire("tips")
  if table.nums(self.uid_name_dict) > 3 then
    for _ip,uid_tbl in pairs(self.uid_ip_dict) do
      uid_tbl =uid_tbl or {}

      if table.nums(uid_tbl) > 1 then
          local uid_str = ""
          for _,uid_num in pairs(uid_tbl) do
            local name = self.uid_name_dict[uid_num] or ""
            if name == "" then
              return
            end
            uid_str = uid_str ..name .." "
          end

          uid_str = uid_str .. "\n拥有相同的IP：" .. tostring(_ip)
          

          local pack = self:get_group_time()
          local m_GroupTimes = pack.m_GroupTimes or 0
          dump(pack,"RoomManager:after_set_uid_ip")
          if m_GroupTimes == 0 and self.show_sameip_tip_flag == false then
           
            tips.show_tips_212("提示",uid_str,
              function() 
                  self.show_sameip_tip_flag = true
                  layout.hide_layout("tips")
              end)
          end
      end 
    end
  end
end