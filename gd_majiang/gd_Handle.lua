
--加载框架初始化类
require("framework.init")
mrequire("handleview")
mrequire("tips")
mrequire("music.music_manager")
mrequire("account")
mrequire("zzroom")
mrequire("layout")

local gd_majiangServer = require("gd_majiang.gd_majiangServer")
local MajiangroomServer = require("gd_majiang.MajiangroomServer")

local hallPa = require("hall.HALL_PROTOCOL")
local PROTOCOL = import("gd_majiang.gd_Protocol")

--加载大厅请求处理
local hallHandle = require("hall.HallHandle")
local gd_Handle = class("gd_Handle",hallHandle)


function gd_Handle:ctor()

	gd_Handle.super.ctor(self);
  
  local  func_ = {
    --登陆房间返回
      [PROTOCOL.SVR_LOGIN_ROOM]      = {handler(self, gd_Handle.SVR_LOGIN_ROOM)},
      --用户自己退出成功
      [PROTOCOL.SVR_QUICK_SUC] = {handler(self, gd_Handle.SVR_QUICK_SUC)},
      --广播用户准备
      [PROTOCOL.SVR_USER_READY_BROADCAST] = {handler(self, gd_Handle.SVR_USER_READY_BROADCAST)},
      --登陆房间广播
      [PROTOCOL.SVR_LOGIN_ROOM_BROADCAST] = {handler(self, gd_Handle.SVR_LOGIN_ROOM_BROADCAST)},
      --广播玩家退出返回
      [PROTOCOL.SVR_QUIT_ROOM] = {handler(self, gd_Handle.SVR_QUIT_ROOM)},
      --游戏开始
      [PROTOCOL.SVR_GAME_START] = {handler(self, gd_Handle.SVR_GAME_START)},
      --发牌
      [PROTOCOL.SVR_SEND_USER_CARD] = {handler(self, gd_Handle.SVR_SEND_USER_CARD)},
      --当前抓牌用户广播
      [PROTOCOL.SVR_PLAYING_UID_BROADCAST] = {handler(self, gd_Handle.SVR_PLAYING_UID_BROADCAST)},
      --广播用户出牌
      [PROTOCOL.SVR_SEND_MAJIANG_BROADCAST] = {handler(self, gd_Handle.SVR_SEND_MAJIANG_BROADCAST)},
      --svr通知我抓的牌
      [PROTOCOL.SVR_OWN_CATCH_BROADCAST] = {handler(self, gd_Handle.SVR_OWN_CATCH_BROADCAST)},
      --广播用户进行了什么操作
      [PROTOCOL.SVR_PLAYER_USER_BROADCAST] = {handler(self, gd_Handle.SVR_PLAYER_USER_BROADCAST)},
      --广播胡
      [PROTOCOL.SVR_HUPAI_BROADCAST]       = {handler(self, gd_Handle.SVR_HUPAI_BROADCAST)}, 
      --结算
      [PROTOCOL.SVR_ENDDING_BROADCAST] = {handler(self, gd_Handle.SVR_ENDDING_BROADCAST)}, 
      --请求托管
      [PROTOCOL.SVR_ROBOT] = {handler(self, gd_Handle.SVR_ROBOT)}, 
      --获取房间id结果
      [PROTOCOL.SVR_GET_ROOM_OK]     = {handler(self, gd_Handle.SVR_GET_ROOM_OK)},
        --登陆错误
      [PROTOCOL.SVR_ERROR]      = {handler(self, gd_Handle.SVR_ERROR)},
      --用户重新登录普通房间的消息返回（4105(10进制s)）
      [PROTOCOL.SVR_REGET_ROOM]      = {handler(self, gd_Handle.SVR_REGET_ROOM)},--重登
      --服务器告知客户端可以进行的操作
      [PROTOCOL.SVR_NORMAL_OPERATE]      = {handler(self, gd_Handle.SVR_NORMAL_OPERATE)},--广播可以进行的操作
      --广播刮风下雨（返回）杠
      --[PROTOCOL.SVR_GUFENG_XIAYU]      = {handler(self, gd_Handle.SVR_GUFENG_XIAYU)},
      --组局时长
      [PROTOCOL.SVR_GROUP_TIME]     = {handler(self, gd_Handle.SVR_GROUP_TIME)},
      --组局排行榜
      [PROTOCOL.SVR_GROUP_BILLBOARD]     = {handler(self, gd_Handle.SVR_GROUP_BILLBOARD)},

      [PROTOCOL.SVR_ENTER_PRIVATE_ROOM] = {handler(self, gd_Handle.SVR_ENTER_PRIVATE_ROOM)},
      
       --录音
        [PROTOCOL.SERVER_CMD_MESSAGE] = {handler(self, gd_Handle.SERVER_CMD_MESSAGE)},   
                 --接收服务器发来的距离
        [PROTOCOL.SERVER_CMD_FORWARD_MESSAGE] = {handler(self, gd_Handle.SERVER_CMD_FORWARD_MESSAGE)},

      --解散房间相关
      --没有此房间，解散房间失败  0x908
      [PROTOCOL.G2H_CMD_DISSOLVE_FAILED] = {handler(self, gd_Handle.G2H_CMD_DISSOLVE_FAILED)},
      --广播当前组局解散情况
      [PROTOCOL.G2H_CMD_REFRESH_DISSOLVE_LIST] = {handler(self, gd_Handle.G2H_CMD_REFRESH_DISSOLVE_LIST)},
      --广播桌子用户请求解散组局
      [PROTOCOL.SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP] = {handler(self, gd_Handle.SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP)},
      --广播桌子用户成功解散组局
      [PROTOCOL.SERVER_BROADCAST_DISSOLVE_GROUP] = {handler(self, gd_Handle.SERVER_BROADCAST_DISSOLVE_GROUP)},
      --广播桌子用户解散组局 ，解散组局失败
      [PROTOCOL.SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP] = {handler(self, gd_Handle.SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP)},
      [PROTOCOL.BROADCAST_USER_IP] = {handler(self, gd_Handle.BROADCAST_USER_IP)},
      [PROTOCOL.SVR_MSG_FACE] = {handler(self, gd_Handle.SVR_MSG_FACE)},
      

    }
    table.merge(self.func_, func_)

end

--接收服务器发来的距离数据    0x 0213
function gd_Handle:SERVER_CMD_FORWARD_MESSAGE(pack)

    dump(pack,"-------距离数据---------")   

    local msgList = pack.msgList
    for k,v in pairs(msgList) do
      if v ~= nil and v ~= "" then
        local msg = json.decode(v)
        if msg~= nil and  msg~=""  then 
          require("hall.view.userInfoView.userInfoView"):upDateUserInfo(msg.uid,msg)
        end
      end
    end

end

--接收服务器返回的组局信息
function gd_Handle:SERVER_CMD_MESSAGE(pack)
  require("hall.view.voicePlayView.voicePlayView"):dealVoiceOrVideo(pack)
  -- if bm.isInGame == false then
  --   return
  -- end
    
  --   local msg = json.decode(pack.msg)
  --   dump(msg, "-----NiuniuroomHandle 接收服务器返回的组局信息-----")
  --   if msg ~= nil then
  --     local msgType = msg.msgType
  --   if msgType ~= nil and msgType ~= "" then

  --     if device.platform == "ios" then

  --       if msgType == "voice" then
  --         dump("voice", "-----接收服务器返回的组局信息-----")

  --         require("hall.view.voicePlayView.voicePlayView"):showView(msg.uid, msg.voiceTime)

  --         --通知本地播放录音
  --         local arr = {}
  --                   arr["url"] = msg.url
  --         cct.getDateForApp("playVoice", arr, "V")

  --       elseif msgType == "video" then
  --         dump("video", "-----接收服务器返回的组局信息-----")

  --         local arr = {}
  --                   arr["url"] = msg.url
  --         cct.getDateForApp("playVideo", arr, "V")

  --       end

  --     else

  --       if msgType == "voice" then
  --                   dump("voice", "-----接收服务器返回的组局信息-----")

  --                   require("hall.view.voicePlayView.voicePlayView"):showView(msg.uid, msg.voiceTime)

  --                   --通知本地播放录音

  --                   local data = {}
  --                   data["url"] = msg.url
                    
  --                   local arr = {}
  --                   table.insert(arr, json.encode(data))
  --                   cct.getDateForApp("playVoice", arr, "V")

  --               elseif msgType == "video" then
  --                   dump("video", "-----接收服务器返回的组局信息-----")
                    
  --                   local data = {}
  --                   data["url"] = msg.url
                    
  --                   local arr = {}
  --                   table.insert(arr, json.encode(data))
  --                   cct.getDateForApp("playVideo", arr, "V")

  --               end
      
  --     end

  --   end
  --   end
    
end


--麻将游戏加载请求方法
function gd_Handle:callFunc(pack)
  if self.func_[pack.cmd] and self.func_[pack.cmd][1] then
        self.func_[pack.cmd][1](pack)
    end
end

-- 游戏开始
function gd_Handle:SVR_GAME_START( pack )
  -- body
  require("hall.gameSettings"):setGroupState(1)

  bm.Room.isStart = 1
  if zzroom.manager:get_group_time().m_GroupTimes == 0 then
    zzroom.manager:after_set_uid_ip()
  end
end

--没有此房间，解散房间失败  0x908
function gd_Handle:G2H_CMD_DISSOLVE_FAILED( pack )
  print("P.G2H_CMD_DISSOLVE_FAILED = 0x908-----------------")
  tips.show_tips_212("解散房间","没有此房间，解散房间失败",function()
        layout.hide_layout("tips")
  end)
end

 --广播当前组局解散情况
function gd_Handle:G2H_CMD_REFRESH_DISSOLVE_LIST( pack )
print("P.G2H_CMD_REFRESH_DISSOLVE_LIST = 0x909--------------------")
    dump(pack, "-----广播当前组局解散情况-----")

  if layout == nil then
    return
  end


  local layout_object_room = layout.manager:get_layout_object("room")
  if layout_object_room == nil then
      return
  end


  local applyId = pack.applyId
  local agreeNum = pack.agreeNum or 0
  local agreeMember_arr = pack.agreeMember_arr or {}

  local showMsg = ""

  --申请解散者信息
  local applyer_info = {}
  mrequire("account")
  local account_object = account.get_player_account()
  local uid = account_object:get_account_id()

  if applyId == uid then
    showMsg = "  您申请解散房间，请等待其他玩家同意（超过\n".."5分钟未做选择，则默认同意）" .. "\n"
  else
      local user_info = zzroom.manager:get_user_data(applyId)
      local user_info_info = json.decode(user_info.user_info)
      user_info_info = user_info_info or {}
      local nick_name =  user_info_info.nickName  or user_info_info.nick
      nick_name = nick_name or ""
      showMsg = "   玩家【" .. nick_name .. "】申请解散房\n间，请等待其他玩家同意（超过5分钟未做选择\n，则默认同意）" .. "\n"
  end

  local isMyAgree = 0
  if applyId ~= uid then
    --假如申请者不是自己，添加自己的选择情况
    if agreeNum > 0 then
      for k,v in pairs(agreeMember_arr) do
        if v == uid then
          isMyAgree = 1
          break
        end
      end
    end
    if isMyAgree == 1 then
      showMsg = showMsg .. "  【我】已同意" .. "\n"
    else
      showMsg = showMsg .. "  【我】等待选择" .. "\n"
    end
  end
  
  local alluser = zzroom.manager:get_alluser_data()
  for other_uid,user_info in pairs(alluser) do
    if other_uid ~= applyId then

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
      local user_info_info = json.decode(user_info.user_info)
      user_info_info = user_info_info or {}
      local nick_name =  user_info_info.nickName  or user_info_info.nick
      nick_name = nick_name or ""


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
        gd_majiangServer:c2sdissove_room(1)
      end,
      function()
        -- body
        gd_majiangServer:c2sdissove_room(0)
      end,true)
    end

  end
end

function gd_Handle:SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP( pack )
  dump(pack, "-----广播桌子用户请求解散组局-----")
end

function gd_Handle:SERVER_BROADCAST_DISSOLVE_GROUP( pack )
    dump(pack, "-----广播桌子用户成功解散组局-----")

 -- bm.isDisbandSuccess = true

end

function gd_Handle:SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP( pack )
  print("P.SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP = 0x104A------------------------")
  dump(pack, "-----广播桌子用户解散组局 ，解散组局失败-----")

  if layout == nil then
    return
  end

  layout.hide_layout("tips_dissove")

  local account_object = account.get_player_account()
  local uid = account_object:get_account_id()

  local rejectId = pack.rejectId
  if rejectId == uid then
    --require("hall.GameTips"):showTips("解散房间失败", "disbandGroup_fail", 2, "您拒绝解散房间")

    tips.show_tips_212("解散房间失败","您拒绝解散房间",function()
          layout.hide_layout("tips")
    end)

  else
      local user_info = zzroom.manager:get_user_data(rejectId)
      local user_info_info = json.decode(user_info.user_info)
      local nick_name =  user_info_info.nickName  or user_info_info.nick
      nick_name = nick_name or ""

     -- require("hall.GameTips"):showTips("解散房间失败", "disbandGroup_fail", 2, rejecter_info.nickName .. "拒绝解散房间")

      tips.show_tips_212("解散房间失败",nick_name.."拒绝解散房间",function()
            layout.hide_layout("tips")
      end)
  end
end



function gd_Handle:SVR_ENTER_PRIVATE_ROOM( pack )
  -- if layout == nil then
  --   return
  -- end
  -- body0x212 组局已结束，去到大厅
  --0x212 组局已结束，去到大厅
  -- local ret = tonumber(pack.ret) or 5
  --   ERROR_ROOM_NOT_EXIST = 1, //房间不存在
  -- ERROR_MAX_USERCOUNT,    //房间人数已满
  -- ERROR_PASSWORD,     //房间密码错误
  -- ERROR_MATCH_BEGIN,    //房间的比赛已经开始

  -- local tbl = {}
  -- tbl[1] = "房间不存在"
  -- tbl[2] = "房间人数已满"
  -- tbl[3] = "房间密码错误"
  -- tbl[4] = "房间的比赛已经开始"
  -- print(tostring(tbl[ret]),"ret----------",tet)
  -- tips.show_tips_212("error","212:"..tostring(tbl[ret]),function( ... )
  --   -- body
  --   layout.hide_layout("tips")

  -- end)
  -- dump(pack)

  require("hall.GameTips"):showTips("系统错误", "tohall", 3, "房间不存在")

end

function gd_Handle:SVR_ERROR(pack)
  print("============================SVR_ERROR===============================")
  dump(pack)


  tips.show_tips_212("error","1005:错误类型为:"..tostring(pack.type),function( ... )
    -- body
    layout.hide_layout("tips")
  end)
end

--广播用户托管
function gd_Handle:SVR_ROBOT(pack)
  print("------------------------------------------------youxi tuoguan---------------------------------")
  dump(pack)
end

--结算
function gd_Handle:SVR_ENDDING_BROADCAST(pack)
  if layout == nil then
    return
  end

  local layout_object = layout.manager:get_layout_object("room_base")
  if layout_object ~= nil then
    layout_object:set_room_base_video(false)
  end
  print("0x4008--------------------------------")
  dump(pack)


  local result_effect =  layout.reback_layout_object("result_effect")
  result_effect:setVisible(false)
  local function function_name_result_effect()
      result_effect:reset_niaocard_data(pack.niaocard,pack.zhongcard) 
  end

  local action2 = cc.Sequence:create(cc.DelayTime:create(1),cc.Show:create(),cc.CallFunc:create(function_name_result_effect))
  result_effect:runAction(action2)

  
  local niaonum =  pack.niaonum or 0
  local use_deley_time = 1  + niaonum * 0.5 + 3

  local result_object = layout.reback_layout_object("result")
  local VoiceRecordView = SCENENOW["scene"]:getChildByName("VoiceRecordView")
  if VoiceRecordView ~= nil then
    local ZOrder = VoiceRecordView:getLocalZOrder()
    ZOrder = ZOrder + 2
    if ZOrder > 0 then
      result_object:setLocalZOrder(ZOrder)
    end
  end
    --layout_object:setLocalZOrder(2)
  result_object:set_delay_time(use_deley_time)
  result_object:setVisible(false)

  local function function_name()
    -- body
    layout.hide_layout("result_effect")
    
    local room_card_object = layout.manager:get_layout_object("room_card")
    if room_card_object ~= nil then
      room_card_object:remove_alloutimage()
    end
  end
  
  local action3= cc.Sequence:create(cc.DelayTime:create(use_deley_time),cc.Show:create(),cc.CallFunc:create(function_name))
  result_object:runAction(action3)

  local ZuanSeatId = zzroom.manager:getlast_zuanindex()
  local user_seadid = zzroom.manager:get_user_seat()
  print("ZuanSeatId-------user_seadid---------",ZuanSeatId,user_seadid)

  local niao_quanzhong_flag = pack.niao_quanzhong_flag or 0
  local niao_quanzhong_value = pack.niao_quanzhong_value or 0
  local niaonum = pack.niaonum or 0
  if niaonum > 0 then
      result_object:set_niao_card(pack.niaocard,pack.zhongcard)
  end

  local zhongNiaoCount = pack.zhongNiaoCount or 0
  -- local zhonguid_num = {}
  -- if niaonum > 0 then
  --   local zhongcard = pack.niaocard or {}
  --   for _,data in pairs(zhongcard) do
  --       local zhonguid = data.zhonguid or 0
  --       local zhonguid_rnum = zhonguid_num[zhonguid] or 0
  --       zhonguid_rnum = zhonguid_rnum + 1
  --       zhonguid_num[zhonguid] = zhonguid_rnum
  --   end
  -- end

  local content_dic = pack.content or {}


  --先判断有没有自摸
  local someone_zimo = false
  local hu_sum = 0 --胡的数量
  for content_i=1,4 do
    local content = content_dic[content_i] or {}
    if content.ifhu==1 then --胡牌了
      hu_sum = hu_sum + 1
        local hucontent = content.hucontent[1]  --数据放在第一个数组
        if hucontent.hutype == 2 then --自摸
            someone_zimo = true
          break
        end
    end
  end

  local room_card_object = layout.manager:get_layout_object("room_card")

  for content_i=1,4 do
  -- for _,content in pairs(pack.content) do
    local content = content_dic[content_i] or {}
    local index = zzroom.manager:get_other_index(content.uid)
    if index == 3 then 
        index = 1 
    elseif index == 1 then 
      index = 3 
    end

    --输赢判断
    if index == 0 then
        result_object:reset_title_state(content.userpergold)
    end

    result_object:reset_result_score(index,content.userpergold)
    local hucard = 0 --牌值都是大于0的
    local str=""
    if content.ifhu==1 then --胡牌了
      --todo
      local hucontent = content.hucontent[1]  --数据放在第一个数组
      if hucontent.hutype==1 then --平胡
        
        print(type(hucontent.pinghu),"----------hucontent.pinghu-----------")
        dump(hucontent.pinghu,"hucontent.pinghu ")
        local pinghu = hucontent.pinghu or {}
        pinghu = pinghu[1] or {}
        hucard = pinghu.hucard or 0

        local ifgangbao = pinghu.ifgangbao or 0
        local ifqiangganghu = pinghu.ifqiangganghu or 0
        if ifgangbao == 1 then
          str = str .. "杠爆"
        elseif ifqiangganghu == 1 then
          str = str .. "抢杠胡"
        else
          str = str .. "自摸"
        end


      else --自摸
       
        local zimo = hucontent.zimo or {}
        zimo = zimo[1] or {}
        hucard = zimo.hucard or 0

        local ifgangshanghua = zimo.ifgangshanghua or 0
        if ifgangshanghua == 1 then
          str = str .. "杠爆"
        else
           str = str .. "自摸"
        end

      end

      local fanshu=hucontent.fanshu--番数

      result_object:reset_hupos(index)
    end

    -- if content.ifpao == 1 then --放炮了
    --   --todo
    --     str=str.."    放炮"
    -- end
    local anGangNum = content.anGangNum or 0
    if anGangNum > 0 then
      str=str.."    暗杠X"..tostring(anGangNum)
    end

    --补杆个数
    local buGangNum = content.buGangNum or 0
    if buGangNum > 0 then
      str=str.."    补杠X"..tostring(buGangNum)
    end
    
    --点杆个数
    local dianGangNum = content.dianGangNum or 0
    if dianGangNum > 0 then
      str=str.."    点杠X"..tostring(dianGangNum)
    end

    local mingGangNum = content.mingGangNum or 0
    if mingGangNum > 0 then
      mingGangNum = mingGangNum - buGangNum
      if mingGangNum > 0 then
        str=str.."    明杠X"..tostring(mingGangNum)
      end
    end
    
    if someone_zimo == true then --如果是有人自摸了的话，那么全部都要显示中鸟
         if zhongNiaoCount > 0 and content.ifhu==1 and niao_quanzhong_flag == 0 then
            str = str .. "  中鸟x"..tostring(zhongNiaoCount)
         elseif niao_quanzhong_value > 0  and niao_quanzhong_flag == 1 and content.ifhu==1 then
             str = str .. "  中鸟x"..tostring(niao_quanzhong_value)
         end
    else
      if hu_sum > 1 then --多人胡
          if content.ifpao == 1 then
             if zhongNiaoCount > 0 and niao_quanzhong_flag == 0 then
              str = str .. "  中鸟x"..tostring(zhongNiaoCount)
             elseif niao_quanzhong_value > 0  and niao_quanzhong_flag == 1 then
              str = str .. "  中鸟x"..tostring(niao_quanzhong_value)
             end
          end
      else
        if content.ifhu == 1 then
            if zhongNiaoCount > 0 and niao_quanzhong_flag == 0 then
              str = str .. "  中鸟x"..tostring(zhongNiaoCount)
            elseif niao_quanzhong_value > 0 and niao_quanzhong_flag == 1 then
              str = str .. "  中鸟x"..tostring(niao_quanzhong_value)
            end
        end
      end


    end

    local wuLaiziDouble = content.wuLaiziDouble or 0
    local ifgenzhuang = content.ifgenzhuang or 0
    local m_nLianZhuangCount = content.m_nLianZhuangCount or 0
    local baseScore = content.baseScore or 0

    if wuLaiziDouble == 1 then
      str=str.."    无赖子加倍"
    end
    
    if ifgenzhuang == 1 then
      str=str.."    跟庄"
    end

    if m_nLianZhuangCount > 0 then
      str=str.."    连庄"..tostring(m_nLianZhuangCount).."次"
    end

    if baseScore > 0 then
      str=str.."    底分X"..tostring(baseScore)
    end

    result_object:reset_result_txt(index,str)

    local nick_name = ""
    if index == 0 then
      local account_object = account.get_player_account()
      nick_name = account_object:get_account_name()

 
      
      if ZuanSeatId == user_seadid then
        result_object:reset_zuanpos(0)
      end
    else
      local user_info = zzroom.manager:get_user_data(content.uid)
      local user_info_info = json.decode(user_info.user_info)
      nick_name =  user_info_info.nickName  or user_info_info.nick

      local seat_id = user_info.seat_id
      print("seat_id-----user_info_info----------",seat_id)
      if ZuanSeatId == seat_id then
          result_object:reset_zuanpos(index)
      end
    end

    result_object:reset_name(index,nick_name)


 
    result_object:draw_card(index,content,hucard)

    if content.ifhu == 1 then

      if index == 3 then
        index = 1
      elseif index == 1 then
        index = 3 
      end

      local userleftcardmount = content.userleftcardmount or 0
      local userleftcard = content.userleftcard or {}
      if userleftcardmount > 0 and  table.nums(userleftcard) > 0 then
          zzroom.manager:set_hand_card_tbl(index,userleftcard)
      end
      if index ~=0 then   --胡牌后不能拖动牌。  index =0 对自身胡牌的动画不影响
        room_card_object:drawHandCard(index)
      end
    end

  end


  zzroom.manager:set_game_state(0)
end


--胡牌协议
function gd_Handle:SVR_HUPAI_BROADCAST(pack)
  print("------------hupaixieyi------0x4013----------")
  dump(pack)
  if layout == nil then
    return
  end

  local layout_object = nil
  local hu_count_ = pack.hu_count or 0
  if hu_count_ > 0 then
     layout_object = layout.reback_layout_object("room_handleresult")
  end

  for i ,content in pairs(pack.content) do
    local  index  = zzroom.manager:get_other_index(content.uid)
    local get_user_data = zzroom.manager:get_user_data(content.uid)
    dump(get_user_data,"get_user_data")
    
    local hu_type = content.htype
    if hu_type  == 1 then --平胡

    else --自摸

    end

    if layout_object ~= nil then
        layout_object:reset_result_hu(index,hu_type)
    end

    if index == 0 then
        local account_object = account.get_player_account()
        local sex_num = account_object:get_account_sex()
         music.manager:playEffectHu(sex_num)
      else
        --播放胡牌声音
        local user_info = zzroom.manager:get_user_data(content.uid)
        local user_info_info = json.decode(user_info.user_info)
        user_info_info = user_info_info or {}
        local sex = user_info_info.sex or 2

        music.manager:playEffectHu(sex)
    end

  end

  if layout_object ~= nil then
        layout_object:reset_result_showtiem(1.5)
  end

  zzroom.manager:set_last_operator("otherhand")
  self:showLastEvent()

end


--广播用户进行了什么操作
function gd_Handle:SVR_PLAYER_USER_BROADCAST(pack)
  print("-------------tongzhiyouhuchaozuo--------------------------------")
  dump(pack)
  

  
  if layout == nil then
    return
  end

  pack.card = self:check_error_card_value(pack.card)

  local room_card_object = layout.manager:get_layout_object("room_card")
  if room_card_object == nil then
    return
  end

  local result,mingoran = zzroom.manager:getHandles(pack.handle)
  local index           =  zzroom.manager:get_other_index(pack.uid)
  gd_Handle:showTimer(pack.uid,8)

  room_card_object:remove_zhua_card()

  if tonumber(pack["uid"]) == tonumber(UID) then

     room_card_object:reset_ting_func(pack)
    local room_handle_view = layout.manager:get_layout_object("room_handle_view")
    if room_handle_view ~= nil then
        room_handle_view:hide_layout()
    end

    local account_object = account.get_player_account()
    local sex_num = account_object:get_account_sex()

    dump(result, "SVR_PLAYER_USER_BROADCAST")

    if result['g'] or result['pg'] then
      if zzroom.manager:deal_gang(0,pack.card,mingoran) then
        room_card_object:drawHandCard(0)
        music.manager:playEffectGang(sex_num)
      end
    end

    if result['p'] then
      zzroom.manager:insert_porg_card(0,{pack.card,pack.card,pack.card})
      if zzroom.manager:remove_hand_card(0,pack.card,2) then
        room_card_object:drawHandCard(0,true)
        music.manager:playEffectPeng(sex_num)
      end
      
    end

  else
    -- 显示其他玩家的操作结果  --可能会出现崩溃
    handleview.show_handle_result(index,result,2)

    --播放出牌声音
    local user_info = zzroom.manager:get_user_data(pack.uid)
    local user_info_info = json.decode(user_info.user_info)
    user_info_info = user_info_info or {}
    local sex = user_info_info.sex or 2
  

    if result['g'] or result['pg'] then
      if zzroom.manager:deal_gang(index,pack["card"],mingoran,result['g']) then
        room_card_object:drawHandCard(index)

        music.manager:playEffectGang(sex)
      end
    end 

    if result['p'] then
      
      zzroom.manager:insert_porg_card(index,{pack.card,pack.card,pack.card})

      if zzroom.manager:remove_hand_card(index,0,2) then
        room_card_object:drawHandCard(index)

        music.manager:playEffectPeng(sex)
      end
      
      
    end
  end
  zzroom.manager:set_last_operator("otherhand")
  self:showLastEvent()

end

--删除打出的显示用的大牌，创建一张打出的out牌
function gd_Handle:showLastEvent()
  local layout_object = layout.manager:get_layout_object("room_card")
  if layout_object == nil then
      return
  end

  local operator_name = zzroom.manager:get_last_operator()

  if operator_name == "chupai" then

    local index = zzroom.manager:get_out_card_index()
    local card_value = zzroom.manager:get_rec_out_card_value()

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



--显示可以操作的界面  --这个界面可以了
function gd_Handle:showHandlesView(handle,card)

  local result,ming_or_an = zzroom.manager:getHandles(handle)
  print("-------------handle,card---------------------------------",handle,card)
  dump(result)
  if table.nums(result) > 0 then
    handleview.show_handle_view(result,ming_or_an,card)
  end
end


--通知我抓的牌
function gd_Handle:SVR_OWN_CATCH_BROADCAST(pack)
  print("-------------------tong zhi wo zhua pai-----------0x3002----------------------")
  dump(pack)
  -- if layout == nil then
  --   return
  -- end
  pack.card = self:check_error_card_value(pack.card)

  local layout_object = layout.manager:get_layout_object("room_card")
  if layout_object == nil then
     layout_object = layout.reback_layout_object("room_card")
  end


  layout_object:reset_ting_func(pack)
  self:showLastEvent()

  gd_Handle:showTimer(tonumber(UID),8)

  
  layout_object:drawHandCard(0,true,pack.card,false,pack.handle)  --通过handle控制是否能拖牌以及抓牌的动作. 暗杠和补杠以及胡牌不能摸牌
  
  zzroom.manager:insert_hand_card(0,{pack.card})

  --layout_object:draw_zhua_card(0,pack.card)

  self:showHandlesView(pack.handle,pack.card)


  local simplNum = pack.simplNum or 0

    --设置剩余的牌数
  local layout_object = layout.manager:get_layout_object("room_base")
  if layout_object ~= nil then 
    layout_object:set_left_card_num(tostring(simplNum))

    local vedio_flag = zzroom.manager:get_video_flag()
    if vedio_flag == false then
      local account_object = account.get_player_account()
      local uid = account_object:get_account_id()
      local all_user_data = zzroom.manager:get_alluser_data()
      local uid_arr = {}
     -- table.insert(uid_arr, uid)
      for _uid,v in pairs(all_user_data) do
        table.insert(uid_arr, _uid)
      end
      dump(uid_arr,"uid_arr")
      require("hall.GameSetting"):setPlayerUid(uid_arr)
      layout_object:set_room_base_video(true)
      --视频录制引导
      local w = 80
      local h = 60
      require("hall.leader.LeaderLayer"):showLeaderLayer(cc.p(897.79+w/2, 186.96+h/2))

      if zzroom.manager.set_video_flag then
        zzroom.manager:set_video_flag(true)
      end
    end
  end
end



--广播抓牌用户,不知道有没有包括自己
function gd_Handle:SVR_PLAYING_UID_BROADCAST(pack)
  print("-------------------guangbozhuapaiyonghu---------------------------------")
  dump(pack)
  if layout == nil then
    return
  end

  local layout_object = layout.manager:get_layout_object("room_card")
  if layout_object == nil then
      return
  end

  self:showLastEvent()
  gd_Handle:showTimer(pack.uid,8)

  local index = zzroom.manager:get_other_index(pack.uid)
  layout_object:draw_zhua_card(index) 
  zzroom.manager:insert_hand_card(index,{0})

  --设置剩余的牌数
  local layout_object = layout.manager:get_layout_object("room_base")
  if layout_object ~= nil then
    layout_object:set_left_card_num(tostring(pack.simplNum))


    local vedio_flag = zzroom.manager:get_video_flag()
    if vedio_flag == false then
      local account_object = account.get_player_account()
      local uid = account_object:get_account_id()
      local all_user_data = zzroom.manager:get_alluser_data()
      local uid_arr = {}
      table.insert(uid_arr, uid)
      for _uid,v in pairs(all_user_data) do
        table.insert(uid_arr, _uid)
      end
      dump(uid_arr,"uid_arr")
      require("hall.GameSetting"):setPlayerUid(uid_arr)
      layout_object:set_room_base_video(true)
      --视频录制引导
      local w = 80
      local h = 60
      require("hall.leader.LeaderLayer"):showLeaderLayer(cc.p(857.79+w/2, 126.96+h/2))

      if zzroom.manager.set_video_flag then
        zzroom.manager:set_video_flag(true)
      end
    end
  end

end

--广播用户出牌
function gd_Handle:SVR_SEND_MAJIANG_BROADCAST(pack)
  print("pack-------- 0x4104-------")
  dump(pack)
  if layout == nil then
    return
  end

  local layout_object = layout.manager:get_layout_object("room_card")
  if layout_object == nil then
    return
  end
  pack.card = self:check_error_card_value(pack.card)

  self:showHandlesView(pack.handle,pack.card)

  local index = zzroom.manager:get_other_index(pack.uid)

  layout_object:remove_zhua_card()
    
  if index == 0 then
    zzroom.manager:remove_hand_card(index,pack.card,1) 

    local account_object = account.get_player_account()
     local sex = account_object:get_account_sex()
     sex =sex or 2
     music.manager:playEffectCard(sex,pack.card)

  else
    zzroom.manager:remove_hand_card(index,0,1) 
    --播放出牌声音
    local user_info = zzroom.manager:get_user_data(pack.uid)
    local user_info_info = json.decode(user_info.user_info)
    user_info_info = user_info_info or {}
    local sex = user_info_info.sex or 2
    music.manager:playEffectCard(sex,pack.card)
  end

  layout_object:draw_chu_card(index,pack.card)

  zzroom.manager:set_last_operator("chupai")

  zzroom.manager:set_out_card_index(index)
  zzroom.manager:set_rec_out_card_value(pack.card)

  layout_object:drawHandCard(index)

end

--显示倒计时器
function gd_Handle:showTimer(uid,time)
  local layout_object = layout.manager:get_layout_object("room")
  if layout_object == nil then
    return
  end

  local index = zzroom.manager:get_other_index(uid)
  local tip_name = zzroom.manager:get_timertip_name(index)

  layout_object:begin_timer(tip_name,time)

end


--用户退出房间
function gd_Handle:SVR_QUIT_ROOM(pack)
  print("---------------yonghutuichufangjian-------------------------------")
  dump(pack)
  if layout == nil then
    return
  end

  local layout_object = layout.manager:get_layout_object("room")
  if layout_object == nil then
    return
  end

  local index = zzroom.manager:get_other_index(pack.uid)
  layout_object:set_player_outline(index)

  --zzroom.manager:set_user_data(pack.uid,nil)

  if pack["uid"] == tonumber(UID) then
    require("hall.GameTips"):enterHall()
  end

end


--玩家退出
function gd_Handle:SVR_QUICK_SUC(pack)
  printInfo("-----------------wangjiatuichu---------------------")
  dump(pack)
  if layout == nil then
    return
  end

  local function function_name()
    -- body 
    if bm.Room and bm.Room.isGroupEnd == 1 then
      layout.hide_layout("tips")
      layout.hide_layout("room")
      display_scene("hall.gameScene")
    else
      require("hall.GameTips"):enterHall()
    end
  end


  local layout_object = layout.manager:get_layout_object("group_result")
  if layout_object ~= nil then
    layout_object:set_quit_game(function_name)
  else
    function_name()
  end
  
end


--处理进入房间
function gd_Handle:SVR_GET_ROOM_OK(pack_data)
  print("---------------------------SVR_GET_ROOM_OK----------------------------------")
  dump(pack_data) 
  print("sending----------------1001............")
  print("denglusuccess table id is ",pack_data['tid'],bm.isGroup,USER_INFO["activity_id"])

  local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_LOGIN_ROOM_GROUP)
      :setParameter("tableid", pack_data['tid'])
      :setParameter("nUserId", tonumber(UID))
      :setParameter("strkey", json.encode("kadlelala"))
      :setParameter("strinfo", USER_INFO["user_info"])
      :setParameter("iflag", 2)
      :setParameter("version", 1)
      :setParameter("activity_id", USER_INFO["activity_id"])
      :build()
    bm.server:send(pack)

end



--用户重登房间1009
function gd_Handle:SVR_REGET_ROOM(pack)
  print("----------------SVR_REGET_ROOM-----------------------------------------")
  dump(pack)

  require("hall.gameSettings"):setGroupState(1)
  bm.Room.isStart = 1

  if SCENENOW["name"] == "gd_majiang.gameScene" then
    local loading = SCENENOW["scene"]:getChildByName("loading")
    if loading then
      SCENENOW["scene"]:removeChildByName("loading")
    end
  end

  local pHuSeatId = pack.pHuSeatId or 0
  local HuSeatId = 0
  for _i,_user_data in pairs(pack.users_info) do
      HuSeatId =  _user_data.HuSeatId or 0
      if HuSeatId == 1 then
        break
      end
  end

  if pHuSeatId == 1 or HuSeatId ==  1 then
    local gd_majiangServer = require("gd_majiang.gd_majiangServer")
    gd_majiangServer:LoginGame(63)
    return
  end



  zzroom.manager:release()

  local gold
  if pack["user_gold"] then
    gold = pack["user_gold"] - USER_INFO["group_chip"]
  else
    gold = 0
  end
  local account_object = account.get_player_account()
  account_object:set_account_gold(gold)

  local uid = account_object:get_account_id()
  zzroom.manager:set_user_seat(uid,pack.seat_id)


  local room_layout = layout.reback_layout_object("room")
  room_layout:hideallReady()
   zzroom.manager:set_game_state(1)

    --显示其他玩家
  local nPlayerCount = pack.nPlayerCount or 0
  if nPlayerCount > 0  then
    for player_index,user_data in pairs(pack.users_info) do
      dump(pack.users_info, "otherDate")
      local data = {}
      data.seat_id = user_data.SeatId
      data.user_info = user_data.m_strUserInfo
      data.uid = user_data.UserId
      data.user_gold = user_data.m_nMoney
      
      self:showPlayer(data)
    end
  end
   
  local myVoiceLocation= {["x"]=185,["y"]=540-375}
  require("hall.view.voicePlayView.voicePlayView"):updateUserPosition(uid,myVoiceLocation)


  --设置剩余的牌数
  local layout_object = layout.manager:get_layout_object("room_base")
  if layout_object ~= nil then
    layout_object:set_left_card_num(tostring(pack["card_less"]))
  end

  -- room_layout:hide_otherplayer_info(0)
  -- room_layout:hide_otherplayer_info(1)--false表示隐藏
  -- room_layout:hide_otherplayer_info(2)--false表示隐藏
  -- room_layout:hide_otherplayer_info(3)--false表示隐藏
  --显示庄家
  local other_index = zzroom.manager:get_other_index_by_seat(pack.m_nBankSeatId)
  room_layout:showZhuang(other_index)
  
  for card_index,card in pairs(pack.holds_info) do
      -- card = self:check_error_card_value(card)
      pack.holds_info[card_index] = self:check_error_card_value(card)
  end

  zzroom.manager:init_card(pack.holds_info) --0号玩家的手牌
  zzroom.manager:init_zuan_flag(other_index)
  zzroom.manager:set_ZuanSeatId(pack.m_nBankSeatId)

  if pack.gangCount and pack.gangCount > 0 then
    for _,gangdata in pairs(pack.gangCount_infoming) do
        gangdata.gang = self:check_error_card_value(gangdata.gang)
        zzroom.manager:insert_porg_card(0,{gangdata.gang,gangdata.gang,gangdata.gang,gangdata.gang})
        zzroom.manager:set_gang_type(0,gangdata.gang,gangdata.gangtype)
    end
  end

  if pack.pengCount and pack.pengCount > 0 then
      for _,card in pairs(pack.peng_info) do
        card = self:check_error_card_value(card)
        zzroom.manager:insert_porg_card(0,{card,card,card})
      end
  end

  if pack.outcardSize and pack.outcardSize > 0 then
      for _,card_data in pairs(pack.outcardSize_info) do
        if card_data.outcardtype == 0 then
          card_data.outcard = self:check_error_card_value(card_data.outcard) 
          zzroom.manager:insert_out_card(0,{card_data.outcard})
        end
      end
  end

  local spec = false
  if pack.chupai_seatid == pack.seat_id then --到我出牌
      local result,ming_or_an = zzroom.manager:getHandles(pack.chupai_handle)
      if table.nums(result) > 0 then
        spec = true
      end
  end

  local last_out_card = 0
  local out_card_max_index = nil

  local rec_chupai_uid = nil
  for i,user_data in pairs(pack.users_info) do
    local other_index = zzroom.manager:get_other_index(user_data.UserId)
    for _,card_data in pairs(user_data.minggang) do
        card_data.data1 = self:check_error_card_value(card_data.data1) 
        zzroom.manager:insert_porg_card(other_index,{card_data.data1,card_data.data1,card_data.data1,card_data.data1})
        zzroom.manager:set_gang_type(other_index,card_data.data1,card_data.data2)
    end

    for _,card in pairs(user_data.pengdata) do
        card = self:check_error_card_value(card) 
        zzroom.manager:insert_porg_card(other_index,{card,card,card})
    end

    dump(user_data.outCarddata,"user_data.outCarddata")
    for  _,card_data  in pairs(user_data.outCarddata) do
        if card_data.outcardtype == 0 then
          card_data.outCards = self:check_error_card_value(card_data.outCards) 
          zzroom.manager:insert_out_card(other_index,{card_data.outCards})

          if pack.chupai_card == card_data.outCards then
            out_card_max_index = other_index
          end

        end
    end


    for index_k = 1,user_data.countHandCards do
      zzroom.manager:insert_hand_card(other_index,{0})
    end

    if user_data.SeatId == pack.chupai_seatid then 
     rec_chupai_uid = user_data.UserId 
    end

    local online = user_data.online or 1
    if online ==  0 then
      room_layout:set_player_outline(other_index)
    end

  end


  if spec == true and out_card_max_index ~= nil and last_out_card == pack.chupai_card then
    --  zzroom.manager:remove_cout_card(out_card_max_index,last_out_card)
  end

  local roomcard_layoutobject = layout.reback_layout_object("room_card")


  if pack.chupai_seatid == pack.seat_id then --到我出牌
      local result,ming_or_an = zzroom.manager:getHandles(pack.chupai_handle)
      if table.nums(result) > 0 then
          roomcard_layoutobject:drawHandCard(0)

      else
        roomcard_layoutobject:drawHandCard(0,true,nil,true)

        gd_Handle:showTimer(tonumber(UID),8)
      end
  else
    local draw_able = false 
    if rec_chupai_uid == tonumber(UID)  then
      draw_able = true 
    end

    roomcard_layoutobject:drawHandCard(0,draw_able,nil,true)

      --别人出牌，我判断可进行的操作
    if rec_chupai_uid ~= nil then
      gd_Handle:showTimer(rec_chupai_uid,8)
    end
  end

 --  --把最后一张牌删掉
    local result = zzroom.manager:getHandles(pack.chupai_handle)
    dump(result,"result----------1009")
    if result['p'] ~= nil then
      if out_card_max_index ~= nil then 
        zzroom.manager:remove_cout_card(out_card_max_index,pack.chupai_card)

        roomcard_layoutobject:draw_chu_card(out_card_max_index,pack.chupai_card)
        zzroom.manager:set_last_operator("chupai")
        zzroom.manager:set_out_card_index(out_card_max_index)
        zzroom.manager:set_rec_out_card_value(pack.chupai_card)
      end
    end




    self:showHandlesView(pack.chupai_handle,pack.chupai_card)
    roomcard_layoutobject:draw_out_card(0)
   
    for i=1,3 do
      roomcard_layoutobject:drawHandCard(i)
      roomcard_layoutobject:draw_out_card(i)
    end

    if zzroom.manager.set_video_flag then
     zzroom.manager:set_video_flag(false)
    end

    roomcard_layoutobject:reset_justting_func(pack)
    roomcard_layoutobject:reset_ting_func(pack)

      --发送距离信息
  -- gd_majiangServer:CLIENT_CMD_FORWARD_MESSAGE("")
end



--服务器告知客户端可以进行的操作
function gd_Handle:SVR_NORMAL_OPERATE( pack )
  -- body
  dump(pack, "SVR_NORMAL_OPERATE=================================");
  pack.operacard = self:check_error_card_value(pack.operacard)

  self:showHandlesView(pack.operatype,pack.operacard)

end

function gd_Handle:SVR_GROUP_TIME(pack)
  print("SVR_GROUP_TIME-----0x5101-----------")
  dump(pack, "SVR_GROUP_TIME-----0x5101-----------")
  if layout == nil then
    return
  end

   zzroom.manager:set_group_time(pack)
    local layout_object = layout.manager:get_layout_object("room_base")
    if layout_object ~= nil then
      layout_object:set_room_base_gouptime(pack)

    end
end




--组局排行榜
function gd_Handle:SVR_GROUP_BILLBOARD(pack)
  print("SVR_GROUP_BILLBOARD---------------5100-----------")
  dump(pack)
  if bm.Room == nil then
    bm.Room = {}
  end
  bm.Room.isGroupEnd = 1
  require("hall.gameSettings"):setGroupState(0)

  if layout == nil then
    return
  end

  layout.hide_layout("tips_dissove")

  local layout_object = layout.reback_layout_object("group_result")

  layout_object:setVisible(false)
   layout_object:setLocalZOrder(2)

  local layout_result = layout.manager:get_layout_object("result")

  -- local delay_time = 2.5
  -- if layout_result ~= nil then
  --   delay_time = layout_result:get_delay_time()
  --   if delay_time == nil or delay_time == 0 then
  --      delay_time = 5
  --   end

  -- end
  local function function_name()
    -- body
    layout.hide_layout("room_card")
  end

  -- local action2 = cc.Sequence:create(cc.DelayTime:create(delay_time),cc.CallFunc:create(function_name),cc.Show:create())
  -- layout_object:runAction(action2)

  local z_resultZOrder = layout_object:getLocalZOrder()
  
  if layout_object ~= nil then
    layout_object:reset_data(pack)
  end

  if layout_result then
     layout_result:setLocalZOrder(z_resultZOrder+1)
     layout_result:set_overstate()
  else
    layout.hide_layout("room_card")
    layout_object:setVisible(true)
  end

end


--登录房间成功1007
function gd_Handle:SVR_LOGIN_ROOM(pack)
  print("----------------enterMajiangRoomSuccess------1007-----------------------------------")
  --dump(pack)
  if SCENENOW["name"] == "gd_majiang.gameScene" then
    local loading = SCENENOW["scene"]:getChildByName("loading")
    if loading then
      SCENENOW["scene"]:removeChildByName("loading")
    end
  end

  local gold =  pack["gold"] - USER_INFO["group_chip"] or 0
  dump(account,"account")
  if account then
    local account_object = account.get_player_account()
    account_object:set_account_gold(gold)

    local uid = account_object:get_account_id()
    zzroom.manager:set_user_seat(uid,pack.seat_id)
    
    local nick_name = account_object:get_account_name()
    zzroom.manager:set_uid_ip(uid,"",nick_name)
  end


  local layout_object = layout.reback_layout_object("room")
  layout_object:hide_zuan_icon() 

  local group_time = zzroom.manager:get_group_time()
 -- dump(group_time,"group_time")
  local m_GroupTimes = group_time.m_GroupTimes or 0
  if m_GroupTimes == 0 then
    layout.reback_layout_object("roomhandle")
  end

  local user_mount = pack.user_mount or 0
  if user_mount > 0  then
    for i,v in pairs(pack.users_info) do
      self:showPlayer(v)
    end
  end
   
  gd_majiangServer:CLI_READY_GAME()

  if zzroom.manager.set_video_flag then
    zzroom.manager:set_video_flag(false)
  end

   
  --发送距离信息
  -- gd_majiangServer:CLIENT_CMD_FORWARD_MESSAGE("")

  local myVoiceLocation= {["x"]=185,["y"]=540-375}
  require("hall.view.voicePlayView.voicePlayView"):updateUserPosition(uid,myVoiceLocation)

 -- local tbl = {36,39,41,36,39,41,41,41,41,36}
 -- zzroom.manager:init_card(tbl) --初始化牌值
 -- zzroom.manager:set_porg_card_tbl(0,{41,41,41})

 --  local  room_card_object =  layout.reback_layout_object("room_card")
 --  room_card_object:drawHandCard(0,true,39)
 --  layout_object:showZhuang(0)

  -- local result_effect =  layout.reback_layout_object("result_effect")
  -- result_effect:reset_niaocard_data(tbl,{41,41,41})
end

--用户进入房间
function gd_Handle:SVR_LOGIN_ROOM_BROADCAST(pack)
  print("--------------yonghujinrufangjian--------------------")
 -- dump(pack)
  if pack ~= nil then
    self:showPlayer(pack)
  end
  --layout.hide_layout("roomhandle")
end

--显示其他玩家
function  gd_Handle:showPlayer( pack )
  if layout == nil then
    return
  end

  local layout_object = layout.manager:get_layout_object("room")
  if layout_object == nil then
    return
  end

  zzroom.manager:set_other_seat(pack.uid,pack.seat_id)
  zzroom.manager:set_user_data(pack.uid,pack)

  local other_index = zzroom.manager:get_other_index(pack.uid)


  local info = json.decode(pack.user_info)
  dump(info)
  local nick_name 
  local user_gold
  local icon_url
  local sex_num
  local ip = nil
  if not info then
    --todo
    nick_name=pack.nick
    user_gold=pack.user_gold - USER_INFO["group_chip"]
    icon_url= pack.icon_url
    icon_url = icon_url or info.photoUrl
    sex_num = pack.sex
    ----ip = pack.ip
  else
    nick_name = pack.nick or info.nickName 
    if pack.user_gold then
      user_gold = pack.user_gold  - USER_INFO["group_chip"]
    else
      user_gold = info.money - USER_INFO["group_chip"]
      end 
    icon_url = pack.icon_url or pack.smallHeadPhoto
    icon_url = icon_url or info.photoUrl 
    sex_num = pack.sex or info.sex
   -- ip = pack.ip or info.ip
  end
  print("icon_url-----------------",icon_url)
  layout_object:show_player(other_index,nick_name,user_gold,icon_url,sex_num,pack.uid,ip)

  local state = zzroom.manager:get_game_state()
  if pack.if_ready == 1 and state == 0 then
    layout_object:showOtherReady(other_index)
  end

  --if ip ~= nil and ip ~= "" then
    zzroom.manager:set_uid_ip(pack.uid,ip,nick_name)
  --end
  
end

--广播用户准备
function gd_Handle:SVR_USER_READY_BROADCAST(pack)
  if layout == nil then
    return
  end

  local layout_object = layout.manager:get_layout_object("room")
  if layout_object == nil then
    return
  end

  local other_index = zzroom.manager:get_other_index(pack.uid)
  layout_object:showOtherReady(other_index)

end



--发牌协议
function gd_Handle:SVR_SEND_USER_CARD(pack)
  if layout == nil then
    return
  end

  local layout_object = layout.manager:get_layout_object("room")
  if layout_object == nil or pack == nil then
    return
  end

  zzroom.manager:set_rec_out_card_value(0)

  layout.hide_layout("roomhandle")

  print("---------------fapaixieyi---0x3001----------------------")
  dump(pack)

  layout_object:hideallReady()
  zzroom.manager:set_game_state(1)

  --layout_object:hide_otherplayer_info(0)
  -- layout_object:hide_otherplayer_info(1)--false表示隐藏
  -- layout_object:hide_otherplayer_info(2)--false表示隐藏
  -- layout_object:hide_otherplayer_info(3)--false表示隐藏

  --显示庄家
  local other_index = zzroom.manager:get_other_index_by_seat(pack.seat)
  if pack.seat  then
    layout_object:showZhuang(other_index)
  end

  zzroom.manager:initialize()
  for card_index,card in pairs(pack.cards) do
      -- card = self:check_error_card_value(card)
      pack.cards[card_index] = self:check_error_card_value(card)
  end

  zzroom.manager:init_card(pack.cards) --初始化牌值

  zzroom.manager:init_zuan_flag(other_index)
  zzroom.manager:set_ZuanSeatId(pack.seat)

  local room_card_object = layout.manager:get_layout_object("room_card")
  if room_card_object ~= nil then
    room_card_object:remove_alloutimage()
  end

  local function CallFucnCallback2()
      print("CallFucnCallback2")

      local tip_name = zzroom.manager:get_timertip_name(other_index)
      layout_object:begin_timer(tip_name,8)
      
      local player_card_object = layout.reback_layout_object("room_card")
       -- player_card_object:draw_out_card(0)
       -- player_card_object:draw_out_card(1)
       -- player_card_object:draw_out_card(2)
       -- player_card_object:draw_out_card(3)
      for i=0,3 do
        self:showPlayerCards(player_card_object,i)
      end
     -- layout.dump_layout_name()
  end

  CallFucnCallback2()
  -- local action2 = cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(CallFucnCallback2))
  -- layout_object:runAction(action2)

end

--显示玩家的牌
function gd_Handle:showPlayerCards(layout_object, index )
  layout_object:drawHandCard(index)
end


function gd_Handle:check_error_card_value( card_value )
  -- body
    if card_value < 0 then
      card_value = card_value +256
    end
    return card_value
end
function gd_Handle:BROADCAST_USER_IP( pack )
  for k,v in pairs(pack.playeripdata) do
    if tonumber(v.uid) == tonumber(UID) then
      require("hall.view.userInfoView.userInfoView"):sendUserPosition(v.ip)
    end
  end
  
  -- body
    print("------------------0x106A----------------------")
    dump(pack)

    local playeripdata = pack.playeripdata or {}
    for _,ip_data in pairs(playeripdata) do
      local ip_ = ip_data.ip or ""
      local uid_ = ip_data.uid or 0
      if uid_ ~= 0 then
        zzroom.manager:set_player_ip(uid_,ip_)
        require("hall.GameData"):setUserIP(uid_, ip_)
      end
    end

end
function gd_Handle:SVR_MSG_FACE(pack)
 
  if SCENENOW["name"] == "gd_majiang.gameScene" then
    local faceUI = SCENENOW["scene"]:getChildByName("faceUI")
    local  index  = zzroom.manager:get_other_index(pack.uid)
    local sexT = 2
    local isLeft = false

    if index == 0 then
        local account_object = account.get_player_account()
        sexT = account_object:get_account_sex()
      else
        --播放胡牌声音
        local user_info = zzroom.manager:get_user_data(pack.uid)
        local user_info_info = json.decode(user_info.user_info)
        user_info_info = user_info_info or {}
        sexT = user_info_info.sex or 2
    end

    if index == 3 then
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
return gd_Handle