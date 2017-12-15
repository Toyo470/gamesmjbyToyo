-- 所有的layout_object在用的时候都要判断存不存在。主要是重登回来，有可能这个界面根本就不存在

--加载框架初始化类
require("framework.init")
mrequire("handleview")
mrequire("tips")
mrequire("music.music_manager")
mrequire("account")
mrequire("zzroom")
mrequire("layout")
mrequire("mprotocol")

local ZZ_Send = require(GAMEBASENAME .. ".Sender")
local scheduler = require("framework.scheduler")

mrequire("mprotocol.g2h_list_format")
mrequire("mprotocol.h2g_list_format")
local PROTOCOL_TBL = {}
PROTOCOL_TBL.CONFIG = {}
PROTOCOL_TBL.CONFIG["CLIENT"] = mprotocol.h2g_list_format["PROTOCOL_FORMAT_DICT"] or {}
PROTOCOL_TBL.CONFIG["SERVER"] = mprotocol.g2h_list_format["PROTOCOL_FORMAT_DICT"] or {}


--加载大厅请求处理
local hallHandle = require("hall.HallHandle")
local ZZ_Handle = class("ZZ_Handle",hallHandle)

function ZZ_Handle:ctor()

  ZZ_Handle.super.ctor(self);
  
  local  func_ = {

      --获取房间id结果
      [mprotocol.G2H_LOGIN_ERR]                          = {handler(self, ZZ_Handle.G2H_LOGIN_ERR)},

      --刷新用户头像列表
      [mprotocol.G2H_REFRESH_ACCOUNT_LIST]               = {handler(self, ZZ_Handle.G2H_REFRESH_ACCOUNT_LIST)},
      
      --初始化玩家的手牌
      [mprotocol.G2H_ACCOUNT_HAND_CARD]                 = {handler(self, ZZ_Handle.G2H_ACCOUNT_HAND_CARD)},
     
      --游戏变更属性
      [mprotocol.G2H_BROADCAST_ACCOUNT_GAME_REFRESH]        = {handler(self, ZZ_Handle.G2H_BROADCAST_ACCOUNT_GAME_REFRESH)},

      --服务器通知到我摸牌
      [mprotocol.G2H_ACCOUNT_DRAW_CARD]                  = {handler(self, ZZ_Handle.G2H_ACCOUNT_DRAW_CARD)},
     
      --单局结算
      [mprotocol.G2H_BROADCAST_GAME_RESULT]              = {handler(self, ZZ_Handle.G2H_BROADCAST_GAME_RESULT)}, 
      
      --总结算
      [mprotocol.G2H_BROADCAST_GROUP_RESULT]             = {handler(self, ZZ_Handle.G2H_BROADCAST_GROUP_RESULT)}, 
      
      --玩家准备
      [mprotocol.G2H_BROADCAST_ACCOUNT_READY]            = {handler(self, ZZ_Handle.G2H_BROADCAST_ACCOUNT_READY)},

      --服务器提示玩家处理操作
      [mprotocol.G2H_ACCOUNT_GAME_OPTION]                = {handler(self, ZZ_Handle.G2H_ACCOUNT_GAME_OPTION)},

      --广播玩家进行的操作
      [mprotocol.G2H_BROADCAST_ACCOUNT_OPTION]           = {handler(self, ZZ_Handle.G2H_BROADCAST_ACCOUNT_OPTION)},
      
      --海底
      [mprotocol.G2H_BROADCAST_ACCOUNT_HAIDI]           = {handler(self, ZZ_Handle.G2H_BROADCAST_ACCOUNT_HAIDI)},

      [mprotocol.G2H_BROADCAST_DISSOLVE_FAILED]          = {handler(self, ZZ_Handle.G2H_BROADCAST_DISSOLVE_FAILED)},
      [mprotocol.G2H_BROADCAST_REFRESH_DISSOLVE_LIST]    = {handler(self, ZZ_Handle.G2H_BROADCAST_REFRESH_DISSOLVE_LIST)},
      [0x0210]                                           = {handler(self, ZZ_Handle.RETURN_TableID)},
      [mprotocol.G2H_BROADCAST_ACCOUNT_FACE]             = {handler(self, ZZ_Handle.SVR_MSG_FACE)},
    }
    table.merge(self.func_, func_)

end

--麻将游戏加载请求方法
function ZZ_Handle:callFunc(pack)
  if layout == nil then
    return
  end

  if self.func_[pack.cmd] and self.func_[pack.cmd][1] then
        print("pack.cmd--------------------",string.format("%#x",pack.cmd))
        self.func_[pack.cmd][1](pack)
    end
end

--登陆错误
function ZZ_Handle:G2H_LOGIN_ERR(pack)

  local msg_data = pack.msg_data or ""
  local tbl = json.decode(msg_data)
  local game_error = tbl["game_error"] or 0

  if tonumber(game_error) == 1 then
      tips.show_tips_212("提示","桌子不存在",function()
        -- body
        layout.hide_layout("tips")
      end)
  elseif tonumber(game_error) == 2 then
      tips.show_tips_212("提示","桌子已经满人",function()
        -- body
         layout.hide_layout("tips")
      end)
  end

end

function ZZ_Handle:RETURN_TableID( pack )
  -- body
  local tid = pack.tid or 0
  ZZ_Send:account_login(tonumber(tid))

end


 --刷新用户列表
function ZZ_Handle:G2H_REFRESH_ACCOUNT_LIST(pack)
  if layout == nil then
    return
  end

  local msg_data = pack.msg_data or ""
  local tbl = json.decode(msg_data)
  dump(tbl,"G2H_REFRESH_ACCOUNT_LIST")

  local layout_object = layout.manager:get_layout_object("player")
  if layout_object == nil then
    return
  end

  local account_object = account.get_player_account()
  local recuid = account_object:get_account_id()

  local game_account_data = tbl["game_account_data"] or {}
  local group_round = tbl["group_round"] or 0
  local group_total_round = tbl["group_total_round"] or 0
  local game_table_account_upper = tbl["game_table_account_upper"] or 0
  local game_state = tonumber(tbl["game_state"])


-- #本金癞子组合 wzx
  local game_benjin_card = tbl["game_benjin_card"] or 0
  local game_laizi_card_list = tbl["game_laizi_card_list"] or {}
  
  if game_laizi_card_list[1] ~= nil and game_laizi_card_list[2] ~= nil then
    cardhandle.game_up_jing_card_list = game_laizi_card_list
    game.game_operator.reset_up_jing_list(game_laizi_card_list[1],game_laizi_card_list[2],2,game_benjin_card)
  end

  local game_dingpiao_flag = tbl["game_dingpiao_flag"] or 0
  local game_dingque_flag = tbl["game_dingque_flag"] or 0

  --------------------------

  --设置当前轮次
  zzroom.manager:set_room_base_gouptime(group_round,group_total_round)
  zzroom.manager:set_player_style(tonumber(game_table_account_upper)) --设置游戏的人数
  local layout_room_base = layout.manager:get_layout_object("room_base")
  layout_room_base:set_room_base_gouptime(group_round,group_total_round)


  if table.nums(game_account_data) < game_table_account_upper then
     layout.reback_layout_object("roomhandle")
  else
     local roomhandle =  layout.manager:get_layout_object("roomhandle")
     if roomhandle ~= nil then
       roomhandle:hide_layout()
     end
  end



  local game_account_dingpiao_dict = {}
  local game_account_data_que_dict = {}

  for user_id,user_data in pairs(game_account_data) do
     user_id = tonumber(user_id)
      if recuid == user_id then
        local account_seat_id = user_data.account_seat_id
        zzroom.manager:set_user_seat(user_id,account_seat_id)
        zzroom.manager:set_user_data(user_id,user_data)

        local account_is_ready = user_data.account_is_ready or 0 --#0为未准备

        local result_object = layout.manager:get_layout_object("result")
        if account_is_ready == 0 and game_state == 0 and result_object == nil then
            layout_object:showOtherReady(0)
            ZZ_Send:H2G_ACCOUNT_READY()
        end

        if account_is_ready == 1 and game_state == 0 then
          layout_object:showOtherReady(0)
        end

        local account_chip  = user_data.account_chip or 0
        print("account_chip------------",account_chip)
      --  layout_object:set_player_gold(0,account_chip)

        local account_name = user_data.account_name or ""
        account_object:set_account_name(account_name)

        local account_head = user_data.account_head or ""
        --layout_object:show_player(0,user_data["account_name"],user_data["account_chip"],user_data["account_head"],user_data["account_sex"],user_id)
        account_object:set_account_gold(account_chip)
        account_object:set_account_iconrul(account_head)
        layout_object:reset_player()


        cardhandle.refresh_user_card(0,user_data)

        local _is_dingpiao = user_data.account_is_dingpiao or ""
        game_account_dingpiao_dict[user_id] = _is_dingpiao

        local account_dingque_type = user_data.account_dingque_type or 0
        account_dingque_type = tonumber(account_dingque_type)

        game_account_data_que_dict[user_id] = account_dingque_type

        break
      end
  end


  for user_id,user_data in pairs(game_account_data) do
      user_id = tonumber(user_id)
      if recuid ~= user_id then
        local account_seat_id = user_data.account_seat_id
        zzroom.manager:set_other_seat(user_id,account_seat_id)

        local have_draw_flag = false
        if zzroom.manager:get_user_data(user_id) then
          have_draw_flag = false
          print("--------- have_draw_flag = true------")
        end
        zzroom.manager:set_user_data(user_id,user_data)

        --设置抢了多少备
        local other_index = zzroom.manager:get_other_index(user_id)

        --游戏状态为0，还没有开始游戏，如果准备的状态为1，那么显示准备图
        local account_is_ready = user_data.account_is_ready or 0
        if account_is_ready == 1 and game_state == 0 then
            layout_object:showOtherReady(other_index)
        end

        if have_draw_flag == false then
          print("have_draw_flag == false----------")
          layout_object:show_player(other_index,user_data["account_name"],user_data["account_chip"],user_data["account_head"],user_data["account_sex"],user_id)
        end

        local account_chip = user_data.account_chip or 0
        layout_object:set_player_gold(other_index,account_chip)


         cardhandle.refresh_user_card(other_index,user_data)


        local account_dingque_type = user_data.account_dingque_type or 0
        account_dingque_type = tonumber(account_dingque_type)

         game_account_data_que_dict[user_id] = account_dingque_type

        local _is_dingpiao = user_data.account_is_dingpiao or ""
        game_account_dingpiao_dict[user_id] = _is_dingpiao

      end

  end


  player.reset_piao(game_account_dingpiao_dict)
  player.reset_que(game_account_data_que_dict)

  --重登看是否要显示定飘
  if game_account_dingpiao_dict[recuid] == "" and  game_state == 1 and game_dingpiao_flag == 1 then
      choose.show_choose_piao()
  end


  if game_account_data_que_dict[recuid] == 0 and game_state == 1 and game_dingque_flag == 1 then
     local layout_object_choosepiao = layout.manager:get_layout_object("choosepiao")
     if layout_object_choosepiao == nil then
        choose.show_choose_que()
     end

  end

  
  if table.nums(game_account_data) == 4 and game_state ~= 0 then
      local  layout_object = layout.reback_layout_object("room_card")
      layout_object:draw_out_card(0)
      for i=1,3 do
        layout_object:drawHandCard(i)
        layout_object:draw_out_card(i)
      end

      local uid_arr = {}
      for user_id,user_data in pairs(game_account_data) do
          user_id = tonumber(user_id)
          table.insert(uid_arr,user_id)
      end   
      require("hall.GameSetting"):setPlayerUid(uid_arr)
  end


  local game_turner_seat_id = tbl["game_turner_seat_id"] or 0
  game_turner_seat_id = tonumber(game_turner_seat_id)
  if game_turner_seat_id ~= 0 then
     local other_index_id = zzroom.manager:get_other_index_by_seat(game_turner_seat_id)
     local room_base_object = layout.reback_layout_object("room_base")
     room_base_object:begin_timer(other_index_id)
  end

  local game_hu_account_data_dict =  tbl["game_hu_account_data_dict"] or {}
  game.deal_player_hu(game_hu_account_data_dict)


  

  local account_object = account.get_player_account()
  local recuid = account_object:get_account_id()
  local uid_arr = {}
  table.insert(uid_arr, recuid)
  local all_user_data = zzroom.manager:get_alluser_data()
  for _uid,v in pairs(all_user_data) do
    table.insert(uid_arr, _uid)
  end
  
  dump(uid_arr,"uid_arr")
  require("hall.GameSetting"):setPlayerUid(uid_arr)

  --视频录制引导
  local w = 80
  local h = 60
  require("hall.leader.LeaderLayer"):showLeaderLayer(cc.p(857.79+w/2, 126.96+h/2))

end

--初始化玩家的手牌
function ZZ_Handle:G2H_ACCOUNT_HAND_CARD(pack)
  -- body
    if layout == nil then
    return
  end

  local msg_data = pack.msg_data or ""
  local tbl = json.decode(msg_data)

  local account_object = account.get_player_account()
  local recuid = account_object:get_account_id()
  dump(tbl,"G2H_ACCOUNT_HAND_CARD")

  local game_account_data = tbl["game_account_data"] or {}

  local player_object = layout.manager:get_layout_object("player")
  if player_object ~= nil then
    player_object:hideallReady()
  end

  for _uid,data_tbl in pairs(game_account_data) do
    print("_uid == tonumber(recuid)",_uid,recuid)
    if tonumber(_uid) == tonumber(recuid) then
     -- local account_handcard = data_tbl["account_handcard"] or {}
        zzroom.manager:init_card(data_tbl)

        local  layout_object = layout.reback_layout_object("room_card")
        for i=0,3 do
          layout_object:drawHandCard(i)
        end
    end
  end

  local game_maker = tbl["game_maker"] or 0
  if game_maker ~= 0 then
    local other_index = zzroom.manager:get_other_index(tonumber(game_maker))
    zzroom.manager:set_ZuanSeatId(tonumber(game_maker))
    zzroom.manager:init_zuan_flag(other_index)

    local room_base_object = layout.manager:get_layout_object("room_base")
    if room_base_object ~= nil then
      room_base_object:showZhuang(other_index)
    end

    local player_object = layout.manager:get_layout_object("player")
    player_object:hide_zuan_icon()
    player_object:set_player_zuan(other_index)
  end

  require("hall.VoiceRecord.VoiceRecordView"):showView(877.00+20, 147.00-20)
end

--游戏变更属性
function ZZ_Handle:G2H_BROADCAST_ACCOUNT_GAME_REFRESH(pack)
  -- body
  if layout == nil then
    return
  end

  local msg_data = pack.msg_data or ""
  local tbl = json.decode(msg_data)
  dump(tbl,"G2H_BROADCAST_ACCOUNT_GAME_REFRESH")


  --游戏轮次更新
  local group_round =  tbl["group_round"]
  zzroom.manager:set_room_base_gouptime(group_round)

  local group_round,group_total_round = zzroom.manager:get_room_base_gouptime() 
  local layout_room_base = layout.manager:get_layout_object("room_base")
  layout_room_base:set_room_base_gouptime(group_round,group_total_round)


 --玩家准备
  local account_ready = tbl["account_ready"]
  if account_ready then
    for _uid,reday_flag in pairs(account_ready) do
      local index = zzroom.manager:get_other_index(tonumber(_uid))
      local layout_object = layout.manager:get_layout_object("player")
      layout_object:showOtherReady(index)
      break;
    end
  end

  local game_remain_card_count = tbl["game_remain_card_count"] or 0
  if game_remain_card_count ~= 0 then
    local layout_object = layout.manager:get_layout_object("room_base")
    layout_object:set_left_card_num(game_remain_card_count)
  end

  --当前摸牌玩家广播
  local game_draw_card_uid = tbl["game_draw_card"] or 0
  if game_draw_card_uid ~= 0 then
    local other_index = zzroom.manager:get_other_index(tonumber(game_draw_card_uid))
    if other_index ~= 0 then
      
      self:showLastEvent()

      local layout_object = layout.manager:get_layout_object("room_card")
      layout_object:draw_zhua_card(other_index)
      zzroom.manager:insert_hand_card(other_index,{0})
      
      local layout_object_room_base = layout.manager:get_layout_object("room_base")
      layout_object_room_base:begin_timer(other_index,8)
    end

  end
-- # 游戏是否定飘 wzx
  local game_dingpiao_flag = tbl["game_dingpiao_flag"] or 0
  if tonumber(game_dingpiao_flag) == 1 then
     choose.show_choose_piao()
  end
  -- # 游戏是否定缺 wzx
  local game_dingque_flag = tbl["game_dingque_flag"] or 0
  if tonumber(game_dingque_flag) == 1 then
     choose.show_choose_que()
  end

-- #本金癞子组合 wzx
  local game_benjin_card = tbl["game_benjin_card"]
  local game_laizi_card_list = tbl["game_laizi_card_list"] or {}
  if game_laizi_card_list[1] ~= nil and game_laizi_card_list[2] ~= nil then
    cardhandle.game_up_jing_card_list = game_laizi_card_list
    game.game_operator.reset_up_jing_list(game_laizi_card_list[1],game_laizi_card_list[2],2,game_benjin_card)
  end


-- # 用户定缺选项 wzx
  local game_account_dingque_dict =  tbl["game_account_dingque_dict"] or {}
  player.reset_que(game_account_dingque_dict)

-- # 用户定飘选项 wzx
  local game_account_dingpiao_dict = tbl["game_account_dingpiao_dict"] or {}
  player.reset_piao(game_account_dingpiao_dict)


  local game_hu_account_data_one_dict = tbl["game_hu_account_data_one_dict"] or {}
  dump("game_hu_account_data_one_dict",game_hu_account_data_one_dict)
  game.deal_player_hu(game_hu_account_data_one_dict)

--用户出牌
  local game_outcard = tbl["game_out_card"]
  dump(game_outcard,"game_outcard")
  if game_outcard then
    for _uid,card_value in pairs(game_outcard) do
       local index = zzroom.manager:get_other_index(tonumber(_uid))
       local layout_object = layout.manager:get_layout_object("room_card")
       layout_object:remove_zhua_card()


      if index == 0 then
          zzroom.manager:remove_hand_card(index,card_value,1) 
      else
          zzroom.manager:remove_hand_card(index,0,1) 
      end

      layout_object:draw_chu_card(index,card_value)

      zzroom.manager:set_last_operator("chupai")

      zzroom.manager:set_out_card_index(index)
      zzroom.manager:set_rec_out_card_value(card_value)

      layout_object:drawHandCard(index)


      music.playEffectCard(_uid,card_value)
      break
    end
  end

end


 --摸牌
function ZZ_Handle:G2H_ACCOUNT_DRAW_CARD(pack)
  if layout == nil then
    return
  end



  local msg_data = pack.msg_data or ""
  local tbl = json.decode(msg_data)
  dump(tbl,"G2H_ACCOUNT_DRAW_CARD")
  for _uid,card_value in pairs(tbl) do
      local layout_object_room_base = layout.manager:get_layout_object("room_base")
      layout_object_room_base:begin_timer(0,8)

      local layout_object = layout.manager:get_layout_object("room_card")


      layout_object:drawHandCard(0,true,card_value,true)
      cardhandle.last_hand_card = card_value
      
        local  player_card = zzroom.manager:get_card(0)
  dump(player_card,"player_card")
  
      zzroom.manager:insert_hand_card(0,{card_value})

      print("card_value--------------",card_value)
     

      self:showLastEvent()

      break
  end

end

--广播用户准备
function ZZ_Handle:G2H_BROADCAST_ACCOUNT_READY( pack )
  -- body
  if layout == nil then
    return
  end

  local msg_data = pack.msg_data or ""
  local tbl = json.decode(msg_data)

  local account_id = tbl["account_id"] or 0
  local other_index = zzroom.manager:get_other_index(tonumber(account_id))

  local layout_object = layout.manager:get_layout_object("player")
  if layout_object ~= nil then
    layout_object:showOtherReady(other_index)
  end

end

--服务器提示玩家处理操作
function ZZ_Handle:G2H_ACCOUNT_GAME_OPTION( pack )
  -- body
  if layout == nil then
    return
  end

  local msg_data = pack.msg_data or ""
  local tbl = json.decode(msg_data)

  local haidi_flag = false
  local gang_choose = false
 -- local notice_option_dict = tbl["tbl"]
  for handle_v,handle_dict in pairs(tbl) do
    handle_v = tonumber(handle_v) --fuck server
    if handle_v == handleview.HAIDI_OPCODE then
      haidi_flag = true
      break
    end

    if handle_v == handleview.GANG_CHOOSE_OPCODE then
      gang_choose = true
      dump(handle_dict,"handle_dict")
      local gangchoose_object = layout.reback_layout_object("gangchoose")
      gangchoose_object:deal_data(handle_dict)
      break
    end
  end

  if haidi_flag == true then
      layout.reback_layout_object("seabase")

  elseif gang_choose == true then
     
  else

    local handleviewlayout = layout.reback_layout_object("room_handle_view")
    if handleviewlayout then
      handleviewlayout:reset_state(tbl)
    end

  end

end



--广播玩家进行的操作
function ZZ_Handle:G2H_BROADCAST_ACCOUNT_OPTION(pack)
  local msg_data = pack.msg_data or ""
  local tbl = json.decode(msg_data)
  dump(tbl,"G2H_BROADCAST_ACCOUNT_OPTION")
  for account_id,data in pairs(tbl) do
    
    for _handle,v_data_list in pairs(data) do

      _handle = tonumber(_handle)
      local room_card_object = layout.manager:get_layout_object("room_card")
      room_card_object:remove_zhua_card()

      local other_index =  zzroom.manager:get_other_index(tonumber(account_id))
      local layout_object_room_base = layout.manager:get_layout_object("room_base")
      layout_object_room_base:begin_timer(other_index,8)


      if other_index == 0 then
        cardhandle.last_hand_card = nil
        layout.hide_layout("room_handleresult")

        --if result['g'] or result['pg'] then杠
        --自己抓到3张相同的牌，其他玩家打出1张相同牌
        if  handleview.FANG_GANG_OPCODE == _handle 
        or handleview.MING_GANG_OPCODE == _handle 
         then--or handleview.GANG_OPCODE == _handle
          print("hehelelheh-----------------------------buzhang-------")
          local card_value = v_data_list[2]
          zzroom.manager:deal_gang(0,card_value,0)
          room_card_object:drawHandCard(0)

          music.playEffectGang(account_id)
        end
        --32
        if handleview.GANG_OPCODE == _handle then
          local gang_type = v_data_list[1] 
          local card_value = v_data_list[2] or {}
          card_value = card_value[1]
          if gang_type == 0 then -- 暗杠
            zzroom.manager:deal_gang(0,card_value,1)
          else
            zzroom.manager:deal_gang(0,card_value,0)
          end
          music.playEffectGang(account_id)

          room_card_object:drawHandCard(0)
          print("hehelelheh-----------------------------gang-------")
          local gangchoose_object = layout.reback_layout_object("gangchoose")
          gangchoose_object:set_txt("你",card_value)

        
        end

        --自己抓到4张相同的牌
        if  handleview.AN_GANG_OPCODE == _handle then
          print("hehelelheh-----------------------------angang-------")
          dump(v_data_list,"card_value_dict")
          local card_value_dict = v_data_list[2] or {}
          for _,card_value in pairs(card_value_dict) do
              zzroom.manager:deal_gang(0,card_value,1)
          end
          room_card_object:drawHandCard(0)

           music.playEffectGang(account_id)
        end

       -- if result['p'] then碰
        if handleview.PENG_OPCODE == _handle then
           print("hehelelheh-----------------------------peng-------")
          local card_value = v_data_list[2]
          zzroom.manager:insert_porg_card(0,{card_value,card_value,card_value})
          zzroom.manager:remove_hand_card(0,card_value,2)
          
          room_card_object:drawHandCard(0,true)

          music.playEffectPeng(account_id)
        end

        --吃
        if handleview.CHI_OPCODE == _handle then
           print("hehelelheh-----------------------------chi-------")
          local v_data_list_dict = v_data_list[2] or {}
          local card_index = v_data_list[3] 
          for _,data_tbl in pairs(v_data_list_dict) do
            zzroom.manager:insert_porg_card(0,data_tbl)


            for _,card_value in pairs(data_tbl) do
               if card_index ~= card_value then
                  zzroom.manager:remove_hand_card(0,card_value,1)
               end
            end

          end

          room_card_object:drawHandCard(0,true)

          music.playEffectChi(account_id)
        end

        --
        if handleview.FEI_OPCODE == _handle then
          handleview.operator.fei_operator(account_id,v_data_list)
        end
        
        if handleview.TI_OPCODE == _handle then
          handleview.operator.ti_operator(account_id,v_data_list)
        end

      else
        -- -- 显示其他玩家的操作结果
          local room_handleresult = layout.reback_layout_object("room_handleresult")
          room_handleresult:reset_result_item(other_index,_handle)

          if  handleview.FANG_GANG_OPCODE == _handle 
          or handleview.MING_GANG_OPCODE == _handle 
           then
            local card_value = v_data_list[2]
            zzroom.manager:deal_gang(other_index,card_value,0,_handle)
            room_card_object:drawHandCard(other_index)

            music.playEffectGang(account_id)
          end

          if handleview.GANG_OPCODE == _handle then
            local gang_type = v_data_list[1] 
            local card_value = v_data_list[2] or {}
            card_value = card_value[1]
            
            if gang_type == 0 then
              zzroom.manager:deal_gang(other_index,card_value,1,_handle)
            else
              zzroom.manager:deal_gang(other_index,card_value,0,_handle)
            end
            room_card_object:drawHandCard(other_index)

             music.playEffectGang(account_id)
          end

          --自己抓到4张相同的牌
          if  handleview.AN_GANG_OPCODE == _handle then
            print("hehelelheh-----------------------------angang-------")
            local card_value_dict = v_data_list[2] or {}
            for _,card_value in pairs(card_value_dict) do
               zzroom.manager:insert_porg_card(other_index,{card_value,card_value,card_value,card_value})
               zzroom.manager:set_gang_type(other_index,card_value,1)
               zzroom.manager:remove_hand_card(other_index,0,4)
            end
            room_card_object:drawHandCard(other_index)

             music.playEffectGang(account_id)

          end

          if handleview.PENG_OPCODE == _handle then
            local card_value = v_data_list[2]
            zzroom.manager:insert_porg_card(other_index,{card_value,card_value,card_value})

            zzroom.manager:remove_hand_card(other_index,0,2)

            room_card_object:drawHandCard(other_index)

            music.playEffectPeng(account_id)
          end

          if handleview.CHI_OPCODE == _handle then
            zzroom.manager:remove_hand_card(other_index,0,2)
            

            local v_data_list_dict = v_data_list[2] or {}
            local card_index = v_data_list[3] 
            for _,data_tbl in pairs(v_data_list_dict) do
              zzroom.manager:insert_porg_card(other_index,data_tbl)
              break
            end
            room_card_object:drawHandCard(other_index)

            music.playEffectChi(account_id)
          end

          if handleview.FEI_OPCODE == _handle then
            handleview.operator.fei_operator(account_id,v_data_list)
          end
          
          if handleview.TI_OPCODE == _handle then
            handleview.operator.ti_operator(account_id,v_data_list)
          end

      end

      zzroom.manager:set_last_operator("otherhand")
      self:showLastEvent()
    end
  end

end

function ZZ_Handle:G2H_BROADCAST_ACCOUNT_HAIDI(pack )
  -- body
    if layout == nil then
    return
  end

  local msg_data = pack.msg_data or ""
  local tbl = json.decode(msg_data)
  dump(tbl,"G2H_BROADCAST_ACCOUNT_HAIDI")

  local card_value_ = 0
  for _account_id, card_value in pairs(tbl) do
    card_value_ = card_value
  end

  if card_value_ ~= 0 then
    local layout_object = layout.reback_layout_object("seabase")
    layout_object:set_sea_card(card_value_)
  end 

end



--删除打出的显示用的大牌，创建一张打出的out牌
function ZZ_Handle:showLastEvent()
  local operator_name = zzroom.manager:get_last_operator()

  local layout_object = layout.manager:get_layout_object("room_card")
  if layout_object == nil then
    return
  end
  
  if operator_name == "chupai" then

    local index = zzroom.manager:get_out_card_index()
    local card_value = zzroom.manager:get_rec_out_card_value()
    print("index-----card_value--------",index,"--------------",card_value)
    if card_value ~= 0 then
      zzroom.manager:insert_out_card(index,{card_value})

      local function CallFucnCallback2()
          layout_object:remove_chu_card()
          layout_object:create_one_out_card(index,card_value,true)
      end

      local delay_time = 0.5
      if index ~= 0 then
        delay_time = 1
      end

      local action2 = cc.Sequence:create(cc.DelayTime:create(delay_time),cc.CallFunc:create(CallFucnCallback2))
      layout_object:runAction(action2)
    end

  end

  if  operator_name  == "otherhand"  then
    layout_object:remove_other_chu_card()
  end

end



--解散组局拜，返回拒绝者
function ZZ_Handle:G2H_BROADCAST_DISSOLVE_FAILED( pack )
  -- body
  if layout == nil then
    return
  end
  dump(pack)
  local msg_data = pack.msg_data or ""
  if msg_data == "" then
    return
  end

  local tbl = json.decode(msg_data)
  dump(tbl,"G2H_BROADCAST_DISSOLVE_FAILED")
  layout.hide_layout("tips_dissove")

  local account_object = account.get_player_account()
  local uid = account_object:get_account_id()

  local rejectId = tbl["group_dissolve_refuse_account"] or 0

  if rejectId == 0 then
    return
  end

  rejectId = tonumber(rejectId)
  if rejectId == uid then
    tips.show_tips_212("解散房间失败","您拒绝解散房间",function()
          layout.hide_layout("tips")
    end)

  else
      local user_info = zzroom.manager:get_user_data(rejectId)
      local nick_name = user_info["account_name"] or "房间里有人"

      tips.show_tips_212("解散房间失败",nick_name.."拒绝解散房间",function()
            layout.hide_layout("tips")
      end)
  end
end

 --广播当前组局解散情况
function ZZ_Handle:G2H_BROADCAST_REFRESH_DISSOLVE_LIST( pack )
  -- body
  if layout == nil then
    return
  end

  local msg_data = pack.msg_data or ""
  local tbl = json.decode(msg_data)
  dump(tbl,"G2H_BROADCAST_REFRESH_DISSOLVE_LIST")
  local applyId = tonumber(tbl["group_dissolve_sponsor_id"])
  local agreeMember_arr = tbl["group_dissolve_list"] or {}
  local agreeNum = table.nums(agreeMember_arr)
  local showMsg = ""

  --显示申请人
  mrequire("account")
  local account_object = account.get_player_account()
  local uid = account_object:get_account_id()

  if applyId == uid then
      showMsg = "  您申请解散房间，请等待其他玩家同意（超过\n".."5分钟未做选择，则默认同意）" .. "\n"
  else
      local user_data = zzroom.manager:get_user_data(applyId)
      local account_name = user_data["account_name"] or ""

      showMsg = "   玩家【" .. tostring(account_name) .. "】申请解散房\n间，请等待其他玩家同意（超过5分钟未做选择\n，则默认同意）" .. "\n"
  end
  local isMyAgree = 0 --自己是否已经同意
  local alluser = zzroom.manager:get_alluser_data()
  for other_uid,user_data in pairs(alluser) do
    if other_uid ~= applyId   then

      --记录当前用户是否已经同意
      local isAgree = 0
      if agreeNum > 0 then
        for k,v in pairs(agreeMember_arr) do
          if other_uid == v then
            --当前用户已经同意
            isAgree = 1
            break
          end
        end
      end


      local account_name = user_data["account_name"] or "路人甲"
      if other_uid == uid then
          account_name = "我"
       
      end
      if isAgree == 1 and other_uid == uid then
         isMyAgree = 1
      end

      if isAgree == 1 then
        showMsg = showMsg .. "  【" .. tostring(account_name) .. "】已同意" .. "\n"  

      else
        showMsg = showMsg .. "  【" .. tostring(account_name) .. "】等待选择" .. "\n"
      end
    end
  end

  --假如申请者是自己，则直接显示其他用户的选择情况
  mrequire("tips")
  if applyId == uid then
    tips.show_tips_dissove("提示", showMsg)
  else
    --申请者不是自己，根据自己的同意情况进行界面显示
    if isMyAgree == 1 then
       tips.show_tips_dissove("提示", showMsg)

    else
      tips.show_tips_dissove("提示", showMsg,
      function()
        -- body
        local data_tbl = {}
        data_tbl["group_dissolve_state"] = 1
        local Sender = require(GAMEBASENAME..".Sender")
        Sender:send(mprotocol.H2G_REPLY_DISSOLVE_ROOM,data_tbl)

      end,
      function()
        -- body
        local data_tbl = {}
        data_tbl["group_dissolve_state"] = 2

        local Sender = require(GAMEBASENAME..".Sender")
        Sender:send(mprotocol.H2G_REPLY_DISSOLVE_ROOM,data_tbl)
      end,true)
    end
  end
  
end

--广播组局结果
 function ZZ_Handle:G2H_BROADCAST_GROUP_RESULT(pack)
   -- body
    if layout == nil then
      return
    end
    local msg_data = pack.msg_data or ""
    if "" == msg_data then
      return
    end
    local tbl = json.decode(msg_data)
    dump(tbl,"G2H_BROADCAST_GROUP_RESULT")

    local tips_dissove = layout.manager:get_layout_object("tips_dissove")
    if tips_dissove ~= nil then
      tips_dissove:hide_layout()
    end

    local function function_name()
      -- body  
      layout.hide_layout("tips")
      layout.hide_layout("room")
      display_scene("hall.gameScene")
    end

    local group_result = layout.reback_layout_object("group_result")
    local detail_base_object = layout.manager:get_layout_object("detail_base")
    if detail_base_object ~= nil then
      group_result:setVisible(false)
    end

    -- local action2 = cc.Sequence:create(cc.DelayTime:create(5),cc.Show:create())
    -- group_result:runAction(action2)
    group_result:set_quit_game(function_name)
    group_result:reset_data(tbl)

    require("hall.VoiceRecord.VoiceRecordView"):removeView()


    local result_object = layout.manager:get_layout_object("detail_base")
    if result_object ~= nil then
      result_object:set_overstate()
    end

 end

 -- -游戏结算--单局结算
 function ZZ_Handle:G2H_BROADCAST_GAME_RESULT(pack)
   -- body
    if layout == nil then
      return
    end

    local msg_data = pack.msg_data or ""
    local tbl = json.decode(msg_data)
    dump(tbl,"G2H_BROADCAST_GAME_RESULT")


    local account_data = tbl["account_data"] or {}
    local game_account_dingpiao_dict = tbl["game_account_dingpiao_dict"] or {}

    local room_card_object = layout.manager:get_layout_object("room_card")
    game.hu_card_dict = {}
    for account_id,account_content in pairs(account_data) do
      local account_id = tonumber(account_id)

      local other_index = zzroom.manager:get_other_index(tonumber(account_id)) 
      if other_index ~= 0  then
          --获取胡的那张牌
          local account_handcard = account_content.account_handcard or {}
          zzroom.manager:set_hand_card_tbl(other_index,account_handcard)
          room_card_object:drawHandCard(other_index)
          
      else
          local game_hu_account_data_one_dict = account_content.game_hu_account_data_one_dict or {}
          local account_change_chip = account_content.account_change_chip or 0
          
          local layout_object = layout.reback_layout_object("detail_base")
          layout_object:reset_data(account_id,game_hu_account_data_one_dict,account_change_chip,game_account_dingpiao_dict)
      end

    end


 end

 

function ZZ_Handle:SVR_MSG_FACE(pack)
  if SCENENOW["name"] == GAMEBASENAME..".gameScene" then
    local faceUI = SCENENOW["scene"]:getChildByName("faceUI")
    local  index  = zzroom.manager:get_other_index(pack.uid)
    local user_info = zzroom.manager:get_user_data(pack.uid)



    local sexT = user_info["account_sex"] or 2
    local isLeft = false

    if index == 1  then--or --index == 2
       isLeft = true
    end
    
    local layout_object_room = layout.manager:get_layout_object("player")
    local node_head = layout_object_room:get_player_head(index)
    print("SVR_MSG_FACE---sexT-----------------",sexT)

    if faceUI ~= nil and node_head ~= nil then
      faceUI:showGetFace(pack.uid, pack.type, tonumber(sexT), node_head, isLeft)
    end
  end
end




return ZZ_Handle