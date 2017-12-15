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

local ZZ_Send = require("xlsg.ZZ_Send")
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
      [mprotocol.G2H_REFRESH_ACCOUNT_LIST]               = {handler(self, ZZ_Handle.G2H_REFRESH_ACCOUNT_LIST)},
      [mprotocol.G2H_BROADCAST_PUSH_CARD]                = {handler(self, ZZ_Handle.G2H_BROADCAST_PUSH_CARD)},
      [mprotocol.G2H_BROADCAST_GRAB_RESULT]              = {handler(self, ZZ_Handle.G2H_BROADCAST_GRAB_RESULT)},     
      --[mprotocol.G2H_BROADCAST_MAKE_MULTIPLE_RESULT]     = {handler(self, ZZ_Handle.G2H_BROADCAST_MAKE_MULTIPLE_RESULT)}, 
      [mprotocol.G2H_BROADCAST_GAME_RESULT]              = {handler(self, ZZ_Handle.G2H_BROADCAST_GAME_RESULT)}, 
      [mprotocol.G2H_BROADCAST_GROUP_RESULT]             = {handler(self, ZZ_Handle.G2H_BROADCAST_GROUP_RESULT)}, 
      [mprotocol.G2H_BROADCAST_ACCOUNT_GRAB]             = {handler(self, ZZ_Handle.G2H_BROADCAST_ACCOUNT_GRAB)}, 
      [mprotocol.G2H_BROADCAST_ACCOUNT_MULTIPLE]         = {handler(self, ZZ_Handle.G2H_BROADCAST_ACCOUNT_MULTIPLE)},
      [mprotocol.G2H_ACCOUNT_OPTION]                     = {handler(self, ZZ_Handle.G2H_ACCOUNT_OPTION)},
      [mprotocol.G2H_BROADCAST_ACCOUNT_READY]            = {handler(self, ZZ_Handle.G2H_BROADCAST_ACCOUNT_READY)},

      [mprotocol.G2H_BROADCAST_DISSOLVE_FAILED]          = {handler(self, ZZ_Handle.G2H_BROADCAST_DISSOLVE_FAILED)},
      [mprotocol.G2H_BROADCAST_REFRESH_DISSOLVE_LIST]    = {handler(self, ZZ_Handle.G2H_BROADCAST_REFRESH_DISSOLVE_LIST)},
      [mprotocol.G2H_REMOVE_ACCOUNT_OPTION]              = {handler(self, ZZ_Handle.G2H_REMOVE_ACCOUNT_OPTION)},
      [0x0210]                                           = {handler(self, ZZ_Handle.RETURN_TableID)},
      [mprotocol.G2H_BROADCAST_ACCOUNT_FACE]             = {handler(self, ZZ_Handle.SVR_MSG_FACE)},
      -- [0x212]                                            = {handler(self, ZZ_Handle.UnKnowError)},

      [mprotocol.G2H_SERVER_CMD_FORWARD_MESSAGE]             = {handler(self, ZZ_Handle.G2H_SERVER_CMD_FORWARD_MESSAGE)},
      [mprotocol.G2H_SERVER_CMD_MESSAGE]             = {handler(self, ZZ_Handle.G2H_SERVER_CMD_MESSAGE)},

    }
    table.merge(self.func_, func_)

end

--麻将游戏加载请求方法
function ZZ_Handle:callFunc(pack)
  if self.func_[pack.cmd] and self.func_[pack.cmd][1] then
        print("pack.cmd--------------------",string.format("%#x",pack.cmd))
        self.func_[pack.cmd][1](pack)
    end
end


function ZZ_Handle:UnKnowError( pack )
  -- body
  dump(pack,"UnKnowError")
end

function ZZ_Handle:RETURN_TableID( pack )
  -- body
  local tid = pack.tid or 0
  -- print("tid------------------",tid)
  -- local data_tbl = {}
  -- data_tbl["game_table_id"] = tonumber(tid)
  -- data_tbl["account_id"] = tonumber(UID)
  -- data_tbl["account_name"] = USER_INFO["nick"]
  -- data_tbl["account_head"] = USER_INFO["icon_url"]
  -- data_tbl["account_sex"] = tonumber(USER_INFO["sex"])

  print("sending---------H2G_ACCOUNT_LOGIN = --用户登陆--------------------",mprotocol.H2G_ACCOUNT_LOGIN)
  -- local str = json.encode(data_tbl)
  ZZ_Send:account_login(mprotocol.H2G_ACCOUNT_LOGIN,tonumber(tid))

end

--登陆错误
function ZZ_Handle:G2H_LOGIN_ERR(pack)
  if layout == nil then
    return
  end
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

 --刷新用户列表 
 --这个消息，思维说要集合重登和初次登陆返回等等功能。搞死人了。
function ZZ_Handle:G2H_REFRESH_ACCOUNT_LIST(pack)
  if layout == nil then
    return
  end

  local msg_data = pack.msg_data or ""
  local tbl = json.decode(msg_data)
  dump(tbl,"G2H_REFRESH_ACCOUNT_LIST")


  local layout_object = layout.manager:get_layout_object("room")
  if layout_object == nil then
    return
  end
  layout_object:resetReady()

  local account_object = account.get_player_account()
  local recuid = account_object:get_account_id()
  --print("recuid--------",recuid,"type(recuid)",type(recuid))
  local game_account_data = tbl["game_account_data"] or {}
  local game_state = tbl.game_state or 0
  

  local group_round = tbl["group_round"] or 0
  local group_total_round = tbl["group_total_round"] or 0
  local game_table_account_upper = tbl["game_table_account_upper"] or 0

  zzroom.manager:set_group_round(group_round,group_total_round)
  local layout_room_base = layout.manager:get_layout_object("room_base")
  layout_room_base:set_room_base_gouptime(group_round,group_total_round)
  layout_room_base:set_room_base_sumpeo(game_table_account_upper)


  if table.nums(game_account_data) < game_table_account_upper then
     layout.reback_layout_object("roomhandle")
  else
     local roomhandle =  layout.manager:get_layout_object("roomhandle")
     if roomhandle ~= nil then
       roomhandle:hide_layout()
     end
  end

  for user_id,user_data in pairs(game_account_data) do
     --print("user_id--------",user_id,"type(user_id)",type(user_id))
     user_id = tonumber(user_id)
      if recuid == user_id then
        local account_seat_id = user_data.account_seat_id
        zzroom.manager:set_user_seat(user_id,account_seat_id)
        zzroom.manager:set_user_data(user_id,user_data)
        local account_grab_state = user_data.account_grab_state or 0 --#0为未抢庄，1为抢庄，2为不抢


        local account_multiple = user_data.account_multiple or 0 --加倍状态
        if account_multiple ~= 0 then
          layout_object:setBeiNum(0,account_multiple)
        end

        local account_is_ready = user_data.account_is_ready or 0 --#0为未准备
        if account_is_ready == 1 and game_state == 0 then
            --显示出准备的图标
            layout_object:show_ready(0)

            local layout_room_base = layout.manager:get_layout_object("room_base")
            if layout_room_base ~= nil then
               layout_room_base:setf_room_rd(false)
            end



        end

        if account_is_ready == 0 and game_state == 0 then
            local layout_room_base = layout.manager:get_layout_object("room_base")
            if layout_room_base ~= nil then
               layout_room_base:setf_room_rd(true)
            end

            local card_object = layout.manager:get_layout_object("card")
            if card_object  ~= nil then
              card_object:hide_layout()
            end

            local dialog_choose_object = layout.reback_layout_object("dialog_choose")
            if dialog_choose_object ~= nil then
              dialog_choose_object:hide_layout()
            end

        end

        if game_state == 2 then
           local layout_room_base = layout.manager:get_layout_object("room_base")
            if layout_room_base ~= nil then
               layout_room_base:setf_room_rd(false)
            end
        end

        local account_chip  = user_data.account_chip or 0
        account_object:set_account_gold(account_chip)

        layout_object:reset_player()
        break
      end
  end

  for user_id,user_data in pairs(game_account_data) do
      user_id = tonumber(user_id)
      if recuid ~= user_id then
        local account_seat_id = user_data.account_seat_id
        zzroom.manager:set_other_seat(user_id,account_seat_id)
        zzroom.manager:set_user_data(user_id,user_data)
        --设置抢了多少备
        local other_index = zzroom.manager:get_other_index(user_id)
        local account_multiple = user_data.account_multiple or 0 --加倍状态
        if account_multiple ~= 0 then
          layout_object:setBeiNum(other_index,account_multiple)
        end

        --游戏状态为0，还没有开始游戏，如果准备的状态为1，那么显示准备图
         local account_is_ready = user_data.account_is_ready or 0
        if account_is_ready == 1 and game_state == 0 then
            layout_object:show_ready(other_index)
        end

        layout_object:show_player(other_index,user_data["account_name"],user_data["account_chip"],user_data["account_head"],user_data["account_sex"],user_id)
      end

  end


  for user_id,user_data in pairs(game_account_data) do
        local other_index = zzroom.manager:get_other_index(tonumber(user_id))
            --新录音位置显示
        local position = {}
        if other_index == 0 then
            position.x = 120.83
            position.y = 149.94
        elseif other_index == 1 then
            position.x = 767.07
            position.y = 330.06
        elseif other_index == 2 then
            position.x = 652.77
            position.y = 477.01
        elseif other_index == 3 then
            position.x = 242.32
            position.y = 474.83
        elseif other_index == 4 then
            position.x = 112.37
            position.y = 347.66
        end
        require("hall.view.voicePlayView.voicePlayView"):updateUserPosition(tonumber(user_id), position)
  end
  -- if game_state == 0 then --游戏还没开始，发送准备
  --     -- layout_object:show_ready(0)
  --     -- ZZ_Send:send(mprotocol.H2G_ACCOUNT_READY)
  --     print("send ready--------------------------")
  -- end
  local account_object = account.get_player_account()
  local recuid = account_object:get_account_id()
  local uid_arr = {}
  table.insert(uid_arr, recuid)
  local all_user_data = zzroom.manager:get_user()
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

 --发牌
function ZZ_Handle:G2H_BROADCAST_PUSH_CARD(pack)
  if layout == nil then
    return
  end

  local msg_data = pack.msg_data or ""
  local tbl = json.decode(msg_data)
  dump(tbl,"G2H_BROADCAST_PUSH_CARD")
  local game_account_data = tbl["game_account_data"] or {}

  if table.nums(zzroom.manager:get_user()) == 0 then
    return
  end

  local delay_time = 1
  local layout_object = layout.manager:get_layout_object("card")
  if layout_object == nil then
    layout_object = layout.reback_layout_object("card")
    delay_time =  layout_object:startSendCard(game_account_data)
  end
  
  local function  func()
    -- body
    for user_id,user_data in pairs(game_account_data) do
      local other_index = zzroom.manager:get_other_index(tonumber(user_id))
      -- local account_handcard = user_data["account_handcard"] or {}
      if layout_object ~= nil then
          layout_object:set_paler_card(other_index,user_data)
      end
    end

  end


  layout_object:runAction(cc.Sequence:create(cc.DelayTime:create(delay_time),cc.CallFunc:create(func)))



  local layout_object = layout.manager:get_layout_object("room")
  layout_object:resetReady()




end


--广播抢庄结果
function ZZ_Handle:G2H_BROADCAST_GRAB_RESULT(pack)
  if layout == nil then
    return
  end

  local msg_data = pack.msg_data or ""
  local tbl = json.decode(msg_data)
  dump(tbl,"G2H_BROADCAST_GRAB_RESULT")
  local game_maker = tbl["game_maker"] or 0
  if game_maker ~= 0 then
 
    local other_index = zzroom.manager:get_other_index(tonumber(game_maker))
    local layout_object = layout.manager:get_layout_object("room")
    if layout_object ~= nil then
          layout_object:resetZhuang()
          layout_object:showZhuang(tonumber(other_index))
    end
  end

  --  print("----------other_index----------------",other_index)
  --收到抢庄消息后，发牌
   -- local card_object = layout.reback_layout_object("card")
   -- print("----------card-------------------------")
   -- if card_object ~= nil then
   --    card_object:startSendCard()
   -- end

end


 -- -游戏结算
 function ZZ_Handle:G2H_BROADCAST_GAME_RESULT(pack)
   -- body
    if layout == nil then
      return
    end

    local msg_data = pack.msg_data or ""
    local tbl = json.decode(msg_data)
    dump(tbl,"G2H_BROADCAST_GAME_RESULT")
    local layout_object = layout.manager:get_layout_object("card")

    local room_layout_object = layout.manager:get_layout_object("room")

    for user_id,user_data in pairs(tbl) do
      --设置最终的牌
      user_id = tonumber(user_id)
      local other_index = zzroom.manager:get_other_index(user_id)
      dump(user_data,"user_data")
      local account_handcard = user_data["account_handcard"] or {}
      if layout_object ~= nil then
          layout_object:set_paler_card(other_index,account_handcard)
      end

      --设置最终的多少点还是3公之类的结果
      local base_tip =  card.handler_result(user_data)
      if layout_object ~= nil then
        layout_object:addBaseTip(other_index,base_tip)
      end

      --设置当前金币数
      local account_chip = user_data["account_chip"]
      if room_layout_object ~= nil and account_chip ~= nil then
        room_layout_object:resetgold(other_index,tonumber(account_chip))
      end

      --显示变化数
      local account_change_chip = tonumber(user_data["account_change_chip"]) or 0
      local value = account_change_chip
      if account_change_chip > 0 then
         account_change_chip = "+"..tostring(account_change_chip)
      end

      local base_tip =  card.handler_num(account_change_chip)
      if layout_object ~= nil then
        layout_object:addBaseTip(other_index,base_tip)
      end

      base_tip:setScale(1.5)
      local str = ""
      if value > 0 then
          base_tip:setColor(cc.c3b(255,255,255))
      else
          base_tip:setColor(cc.c3b(255,0,0))
      end

      local mb = cc.MoveBy:create(1.5,cc.p(0,60))
      local mb2 = cc.MoveBy:create(0.1,cc.p(0,-60))
      local hide = cc.Hide:create()
      local fo = cc.FadeOut:create(0.5)
      local remove =cc.RemoveSelf:create()

      local action_seq = cc.Sequence:create(mb, fo, hide, mb2, remove)
      base_tip:runAction(action_seq)

    end

  --几秒后，清理界面。然后发送游戏准备消息。
  scheduler.performWithDelayGlobal(function()
    --把牌界面重设掉
       print("-------------------------------------------")
       local layout_object = layout.manager:get_layout_object("card")
       if layout_object ~= nil then
          layout_object:hide_layout()
         -- layout_object:before_release()
       end

       layout_object = layout.manager:get_layout_object("room")
       if layout_object ~= nil then
          layout_object:reset()
          layout_object:resetBeiNum()
       end


       local group_round,group_total_round = zzroom.manager:get_group_round()
       group_round = group_round + 1

       if layout.manager:get_layout_object("group_result") == nil and group_total_round ~= group_round then
            -- and group_round < group_total_round
           local ZZ_Send = require("xlsg.ZZ_Send")
            ZZ_Send:LoginGame(170)
       end

       layout_object = layout.manager:get_layout_object("room_base")
       if layout_object ~= nil then
          layout_object:setf_room_rd(true)
       end

  end,5)

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

  local function function_name()
    -- body  
    layout.hide_layout("tips")
    layout.hide_layout("room")
    display_scene("hall.gameScene")
  end

  local tips_dissove = layout.manager:get_layout_object("tips_dissove")
  if tips_dissove ~= nil then
    tips_dissove:hide_layout()
  end

  local group_result = layout.reback_layout_object("group_result")
  
  local tbl = json.decode(msg_data)
  dump(tbl,"G2H_BROADCAST_GROUP_RESULT")
  if group_result ~= nil then
    group_result:set_quit_game(function_name)
    group_result:reset_data(tbl)
  end
  

  local group_round,group_total_round = zzroom.manager:get_group_round()
  group_round = group_round + 1
  print("group_round < group_total_round",group_round,group_total_round)
  if group_round < group_total_round then

  else
      group_result:setVisible(false)
      local action2 = cc.Sequence:create(cc.DelayTime:create(5),cc.Show:create())
      group_result:runAction(action2)
  end

 end

--广播玩家抢钻 --标示玩家是否抢庄了
function ZZ_Handle:G2H_BROADCAST_ACCOUNT_GRAB(pack)
   -- body
end

 ----广播账号选择倍数
function ZZ_Handle:G2H_BROADCAST_ACCOUNT_MULTIPLE(pack)
   -- body
  if layout == nil then
    return
  end

  local msg_data = pack.msg_data or ""
  local tbl = json.decode(msg_data)
  dump(tbl,"G2H_BROADCAST_ACCOUNT_MULTIPLE")
  local account_multiple = tbl["account_multiple"] or 0
  local account_id = tbl["account_id"] or 0
  local other_index = zzroom.manager:get_other_index(tonumber(account_id))

  local layout_object = layout.manager:get_layout_object("room")
  if layout_object ~= nil then
    layout_object:setBeiNum(other_index,account_multiple)
  end
 end


--请求弹出对话框
function ZZ_Handle:G2H_ACCOUNT_OPTION(pack)
   -- body
  if layout == nil then
    return
  end

  local msg_data = pack.msg_data or ""
  local tbl = json.decode(msg_data)

  -- local game_dialog = tbl["game_dialog"] or {}
   dump(tbl,"game_dialog")
  if table.nums(tbl) > 0 then
     local dialog_choose_object = layout.reback_layout_object("dialog_choose")
     if dialog_choose_object ~= nil then
        dialog_choose_object:resetdata(tbl)
     end
  end

  layout.hide_layout("roomhandle")


  --发现一个问题，玩家如果没有对加倍界面作出选择的时候，服务器没有发默认的1倍给这个玩家。
  --现在这个问题客户端来处理。
  --处理的方式是：在服务器通知玩家进行抢倍的时候，默认的先显示该玩家为1倍。
  local option_style = tbl["option_style"] or 0
  if tonumber(option_style) == 2 then --2是通知我加倍
      local layout_object = layout.manager:get_layout_object("room")
      if layout_object ~= nil then
        layout_object:setBeiNum(0,1)
      end
  end

 end

function ZZ_Handle:G2H_REMOVE_ACCOUNT_OPTION( )
  -- body
  layout.hide_layout("dialog_choose")
end

function ZZ_Handle:G2H_BROADCAST_ACCOUNT_READY( pack )
  -- body
  if layout == nil then
    return
  end

  local msg_data = pack.msg_data or ""
  local tbl = json.decode(msg_data)

  local account_id = tbl["account_id"] or 0
  local account_object = account.get_player_account()
  local uid = account_object:get_account_id()

  if account_id ~= uid then
    local other_index = zzroom.manager:get_other_index(tonumber(account_id))
    local layout_object = layout.manager:get_layout_object("room")
    if layout_object ~= nil then
      layout_object:show_ready(other_index)
    end
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
      local user_info = zzroom.manager:get_user_data(applyId)
      local nick_name = user_info["account_name"] or ""

      showMsg = "   玩家【" .. nick_name .. "】申请解散房\n间，请等待其他玩家同意（超过5分钟未做选择\n，则默认同意）" .. "\n"
  end

  local alluser = zzroom.manager:get_user()
  for other_uid,user_info in pairs(alluser) do
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


      local user_info = zzroom.manager:get_user_data(other_uid)
      local nick_name = user_info["account_name"] or "路人甲"
      if other_uid == uid then
          nick_name = "我"
      end

      if isAgree == 1 then
        showMsg = showMsg .. "  【" .. nick_name .. "】已同意" .. "\n"
      else
        showMsg = showMsg .. "  【" .. nick_name .. "】等待选择" .. "\n"
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
      tips.show_tips_dissove("提示", showMsg,function()
        -- body
        local data_tbl = {}
        data_tbl["group_dissolve_state"] = 1
        local ZZ_Send = require("xlsg.ZZ_Send")
        ZZ_Send:send(mprotocol.H2G_REPLY_DISSOLVE_ROOM,data_tbl)

       -- zz_majiangServer:c2sdissove_room(1)
      end,
      function()
        -- body
        local data_tbl = {}
        data_tbl["group_dissolve_state"] = 2

        local ZZ_Send = require("xlsg.ZZ_Send")
       -- zz_majiangServer:c2sdissove_room(0)
        ZZ_Send:send(mprotocol.H2G_REPLY_DISSOLVE_ROOM,data_tbl)
      end,true)
    end
  end
end


function ZZ_Handle:SVR_MSG_FACE(pack)
 
  if SCENENOW["name"] == "xlsg.gameScene" then
    local faceUI = SCENENOW["scene"]:getChildByName("faceUI")
    local  index  = zzroom.manager:get_other_index(pack.uid)
    local user_info = zzroom.manager:get_user_data(pack.uid)



    local sexT = user_info["account_sex"] or 2
    local isLeft = false

    if index == 1 or index == 2 then
       isLeft = true
    end
    
    local layout_object_room = layout.manager:get_layout_object("room")
    local node_head = layout_object_room:get_player_head(index)
    print("SVR_MSG_FACE---sexT-----------------",sexT)

    if faceUI ~= nil and node_head ~= nil then
      faceUI:showGetFace(pack.uid, pack.type, tonumber(sexT), node_head, isLeft)
    end
  end
end



function ZZ_Handle:G2H_SERVER_CMD_FORWARD_MESSAGE(pack)

    dump(pack, "-----NiuniuroomHandle 接收服务器返回的缓存信息-----")
    
    local msgList = pack.msgList
    for k,v in pairs(msgList) do
      if v ~= nil and v ~= "" then
        local msg = json.decode(v)
        if msg ~= nil and msg ~= "" then
          if msg.uid ~= nil and msg.uid ~= "" then
            require("hall.view.userInfoView.userInfoView"):upDateUserInfo(msg.uid, msg)
          end
        end
      end
    end
    
end

--接收服务器返回的组局信息
function ZZ_Handle:G2H_SERVER_CMD_MESSAGE(pack)

  if bm.isInGame == false then
    return
  end
    
    local msg = json.decode(pack.msg)
    dump(msg, "-----NiuniuroomHandle 接收服务器返回的组局信息-----")
    if msg ~= nil then
      local msgType = msg.msgType
    if msgType ~= nil and msgType ~= "" then

      if device.platform == "ios" then

        if msgType == "voice" then
          dump("voice", "-----接收服务器返回的组局信息-----")

          require("hall.view.voicePlayView.voicePlayView"):showView(msg.uid, msg.voiceTime)

          --通知本地播放录音
          local arr = {}
                    arr["url"] = msg.url
          cct.getDateForApp("playVoice", arr, "V")

        elseif msgType == "video" then
          dump("video", "-----接收服务器返回的组局信息-----")

          local arr = {}
                    arr["url"] = msg.url
          cct.getDateForApp("playVideo", arr, "V")

        end

      else

        if msgType == "voice" then
          dump("voice", "-----接收服务器返回的组局信息-----")

          require("hall.view.voicePlayView.voicePlayView"):showView(msg.uid, msg.voiceTime)

          --通知本地播放录音

          local data = {}
          data["url"] = msg.url
          
          local arr = {}
          table.insert(arr, json.encode(data))
          cct.getDateForApp("playVoice", arr, "V")

        elseif msgType == "video" then
          dump("video", "-----接收服务器返回的组局信息-----")
          
          local data = {}
          data["url"] = msg.url
          
          local arr = {}
          table.insert(arr, json.encode(data))
          cct.getDateForApp("playVideo", arr, "V")

        end
      
      end

    end
    end
    
end


return ZZ_Handle