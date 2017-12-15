--require("framework.init")
local hallHandle=require("hall.HallHandle")
local hallPa=require("hall.HALL_PROTOCOL")
local PROTOCOL         = import("niuniu.Niuniu_Protocol")
-- setmetatable(PROTOCOL, {
--     __index=hallPa
--   })

local NiuniuhallHandle = class("NiuniuhallHandle",hallHandle)
local NiuniuroomHandle = import("niuniu.niuniuNamal.NiuniuroomHandle")
local NiuniubroomHandle = import("niuniu.niuniuBai.NiuniubroomHandle")

function NiuniuhallHandle:ctor()
  NiuniuhallHandle.super.ctor(self);
	local func_ = {
        [PROTOCOL.SVR_ENTER_PRIVATE_ROOM] = {handler(self, NiuniuhallHandle.SVR_ENTER_PRIVATE_ROOM)},
        [PROTOCOL.SVR_GET_ROOM_OK] = {handler(self, NiuniuhallHandle.SVR_GET_ROOM_OK)},
        [PROTOCOL.SVR_LOGIN_ROOM] = {handler(self, NiuniuhallHandle.SVR_LOGIN_ROOM)},
        [PROTOCOL.SVR_LOGIN_ROOM_BAIREN] = {handler(self, NiuniuhallHandle.SVR_LOGIN_ROOM_BAIREN)},
        [PROTOCOL.SVR_ERROR] = {handler(self, NiuniuhallHandle.SVR_ERROR)},
        
    }
    table.merge(self.func_, func_)
end


--
function NiuniuhallHandle:callFunc(pack)
	 if self.func_[pack.cmd] and self.func_[pack.cmd][1] then
        self.func_[pack.cmd][1](pack)
        printf("%smessage codeTT", pack.cmd)
    end
end

--进入房间失败
function NiuniuhallHandle:SVR_ERROR(pack)


  local tbErrorCode = {
    [0] = "成功创建新连接",
    [1] = "重连成功",
    [2] = "成功踢其他玩家",
    [3] = "玩家密匙错误",
    [4] = "数据库连接错误",
    [5] = "无此房间",
    [6] = "玩家登录房间错误",
    [7] = "无房间分配",
    [8] = "没有空桌子",
    [9] = "玩家余额不足",
    [10] = "未知错误",
    [14] = "数据库缓存出错",
    [15] = "对不起，您不是VIP",
    [13] = "您当前不能进低分场",
    [12] = "相同IP",
    [16]="密码错误",
    [17]="要求携带金币不足"
  }

  if tbErrorCode[pack.type] then
    require("hall.GameTips"):showTips(tbErrorCode[pack.type])
  else
    require("hall.GameTips"):showTips("出现一个未知的错误")
  end
end

--进入房间成功
function NiuniuhallHandle:SVR_LOGIN_ROOM_BAIREN(pack)


  bm.Bai = {}
  bm.Bai.Xia_num = 500
  display_scene("niuniu.center.niuniu.scenes.NiuniubroomScenes") 
  local scenes      =  SCENENOW['scene']
  for i,v in pairs(pack.content) do


    local zhuang_nick =  scenes._scene:getChildByTag(334)
    local zhuang_num  =  scenes._scene:getChildByTag(346)
    local my_nick     =  scenes._scene:getChildByTag(390)
    local my_num      =  scenes._scene:getChildByTag(389)

    local jiang_num   = scenes._scene:getChildByTag(395)

    zhuang_num:setString(v.zhuanggold)
    my_nick:setString(USER_INFO["nick"])
    my_num:setString(v.usergold)
    jiang_num:setString(v.allmoney)
   
    if v.zstatus == 2 then
        local pack = {}
        pack.time  = v.starttime 
        pack.info  = {}
        pack.info  = v.status2[1].seatinfo
        
        
        NiuniubroomHandle:SVR_XIAZHU_START(pack)

        NiuniubroomHandle:SVR_XIAZHU_INFO(pack)
    end

     if v.zstatus == 3 then
         local pack    = {}
         pack.time     = v.starttime 
         pack.content  = {}
         pack.content  = v.status3[1].seatinfo
         NiuniubroomHandle:SVR_CARD_RESULT(pack)
    end


    if v.zstatus == 1 then
        local scenes      =  SCENENOW['scene']
        local hide        =  scenes._scene:getChildByTag(391)
        local time        =  scenes._scene:getChildByTag(392)
        hide:setVisible(true)
        time:setVisible(true)
        bm.Bai.time_count =  v.starttime
        time:setString("等待 "..bm.Bai.time_count.." ")
        bm.Bai.time       = bm.SchedulerPool2:loopCall(function ()
            
            bm.Bai.time_count = bm.Bai.time_count -1
            time:setString("休息一下 "..bm.Bai.time_count.." ")
            if bm.Bai.time_count < 0 then
              hide:setVisible(false)
              time:setVisible(false)
              return false
            end

            return true
        end,1)
    end

  end
  
end

--210消息，发送进入房间消息113消息后的返回结果,
function NiuniuhallHandle:SVR_GET_ROOM_OK(pack)

  --printError("........chen............SVR_GET_ROOM_OK.................")
  -- if pack.level == 301 then   
  --   local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_LOGIN_ROOM_BAIREN)
  --       :setParameter("tid", pack['tid'])
  --       :setParameter("uid", UID)
  --       :setParameter("mtkey", "")
  --       :setParameter("strinfo", json.encode(USER_INFO))
  --       :build()
  --   bm.server:send(pack)

  -- else

  --测试后发现这个地方其实是其他玩家看到的东西
  print("receive 210   =============SVR_GET_ROOM_OK----------fasongyonghuxiaoxi--------------")

  local info = json.decode(USER_INFO["user_info"])
  info.nickName = USER_INFO["nick"]
  USER_INFO["user_info"] = json.encode(info)
  local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_LOGIN_ROOM)
        :setParameter("tid", pack['tid'])
        :setParameter("uid", tonumber(UID))
        :setParameter("mtkey", "")
        :setParameter("strinfo", USER_INFO["user_info"])
        :build()
    bm.server:send(pack)


    dump("发送1001", "-----牛牛-----")

end


--绘制桌面玩家
function NiuniuhallHandle:drawUser(pack,recent_scene)
    
    -- dump(pack, "-----绘制桌面玩家-----")

    if pack.users_info == nil then
        return false    
    end
    
    local tmp = {}
    for key,value in pairs(pack.users_info) do
        local o_uid = tonumber(value["o_uid"])

        tmp[value.o_seat_id] = value
        bm.Room.User[o_uid] = value.o_seat_id --保存用户座位与id映射

        local other_seat  = value.o_seat_id
        local other_index = other_seat - bm.User.Seat
        if other_index < 0 then
          other_index = other_index + 5
        end
        
        printInfo("................other_index....................============================")
        printInfo(other_index)

        -- local player_move_pos = { {-20.03,6.60}, {-19.32,201.34},  {59.83,346.56}, {658.10,346.84},{772.95,202.05} }

        if other_index == 0 then

            recent_scene:set_player_info_visible(0,"head",true)
            recent_scene:set_player_info_visible(0,"head_kuang",true)
            recent_scene:set_player_info_visible(0,"gold",true)
            recent_scene:set_player_info_visible(0,"chouma_me_14",true)
            recent_scene:set_player_info_visible(0,"sex",false)
            recent_scene:set_player_info_visible(0,"name",true)
            recent_scene:set_player_info_visible(0,"ready_sp",false)

        else

            recent_scene:set_player_info_visible(other_index,"head",true)
            recent_scene:set_player_info_visible(other_index,"head_kuang",true)
            recent_scene:set_player_info_visible(other_index,"gold",true)
            recent_scene:set_player_info_visible(0,"chouma_me_14",true)
            recent_scene:set_player_info_visible(other_index,"sex",false)
            recent_scene:set_player_info_visible(other_index,"name",true)
            recent_scene:set_player_info_visible(other_index,"ready_sp",false)

        end

        local position = {}
        if other_index == 0 then
            position.x = 289.00
            position.y = 75.00
        elseif other_index == 1 then
            position.x = 30.00
            position.y = 390.00
        elseif other_index == 2 then
            position.x = 200.00
            position.y = 420.00
        elseif other_index == 3 then
            position.x = 690.00
            position.y = 420.00
        elseif other_index == 4 then
            position.x = 885.00
            position.y = 390.00
        end
        bm.Room.ShowVoicePosion[o_uid] = position

        --新录音位置显示
        require("hall.view.voicePlayView.voicePlayView"):updateUserPosition(o_uid, position)

        dump(bm.Room.ShowVoicePosion, "-----录音播放效果显示位置-----")

        -- local panel = recent_scene._scene:getChildByName("palyer_panel_"..tostring(other_index))
        -- local move_pos = player_move_pos[other_index+1]
        -- panel:setPositionX(move_pos[1])
        -- panel:setPositionY(move_pos[2])

        local info_y = json.decode(value["o_user_detail"])
        --名字和金币
        dump(value)
        local nickName = info_y["nick"] or info_y["nickName"]
        recent_scene:set_player_name(other_index,nickName)
        recent_scene:set_player_gold(other_index,value["o_user_gold"])
        local icon_url = info_y["photoUrl"] or info_y["icon_url"]
        recent_scene:set_player_icon(other_index,icon_url, info_y["sex"], o_uid,nickName)
        local gold_valuse = tonumber(value["o_user_gold"])
        bm.Room.UserInfo[o_uid] = {gold = gold_valuse}
        -- if value.o_uid ~= tonumber(USER_INFO["uid"]) then
        --   bm.Room.UserInfo[value.o_uid].user_info = value["o_user_detail"]
        -- end
        bm.Room.UserInfo[o_uid].user_info = value["o_user_detail"]
        bm.Room.UserInfo[o_uid].uid = o_uid
        
        if value["o_user_status"] == 1 then
          local data = {}
          data.uid = o_uid
          NiuniuroomHandle:SVR_READY_BROADCAST(data)
        end

        --等待抢庄
        if value["o_user_status"] == 2 then
            --nothing
        end

        --不抢庄
        if value["o_user_status"] == 3 then
            local pack_tmp     = {}
            pack_tmp.uid       = o_uid
            pack_tmp.if_qiang  = 0
            NiuniuroomHandle:SVR_USER_QIANFGZHUANG_RESULT_BROADCAST(pack_tmp)
        end

        --抢庄
        if value["o_user_status"] == 4 then
            local pack_tmp     = {}
            pack_tmp.uid       = o_uid
            pack_tmp.if_qiang  = 1
            NiuniuroomHandle:SVR_USER_QIANFGZHUANG_RESULT_BROADCAST(pack_tmp)
        end

        --等待加倍
        if value["o_user_status"] == 5 then
            --nothing
        end

        --加倍完成
        if value["o_user_status"] == 6 then
            local pack_tmp     = {}
            pack_tmp.uid       = o_uid
            pack_tmp.base      = value.o_user_base_calltime
            NiuniuroomHandle:SVR_USER_BASES_RESULT_BROADCAST(pack_tmp)
        end

        --等待出牌
        if value["o_user_status"] == 7 then
            if  bm.Room.Zid  ~= o_uid then
              local pack_tmp     = {}
              pack_tmp.uid       = o_uid
              pack_tmp.base      = value.o_user_base_waitplay
              NiuniuroomHandle:SVR_USER_BASES_RESULT_BROADCAST(pack_tmp)
            end
            NiuniuroomHandle:sendCardAnimation()
        end

        --出牌完成
        if value["o_user_status"] == 8 then
          -- if bm.Room == nil then
          --   bm.Room = {}
          -- end
          -- if bm.Room.UserCards == nil then
          --   bm.Room.UserCards = {}
          -- end
          -- bm.Room.UserCards[o_uid] = {}
          -- dump(value.o_user_base_out_cards, "o_user_base_out_cards", nesting)
          -- for k, v in pairs(value.o_user_base_out_cards) do
          --   table.insert(bm.Room.UserCards[o_uid],v)
          -- end
           
          bm.callfunc = function()
            -- body
            local pack_tmp     = {}
            pack_tmp.uid       = o_uid
            pack_tmp.kind      = value.o_user_base_out_cards_cardkind
            pack_tmp.cards     = value.o_user_base_out_cards
            dump(pack_tmp, "drawUser UserOutcard", nesting)
            NiuniuroomHandle:SVR_USER_PLAYED_CARDS_BROADCAST(pack_tmp)

            if  bm.Room.Zid  ~= o_uid then
              local pack_tmp     = {}
              pack_tmp.uid       = o_uid
              pack_tmp.base      = value.o_user_base_out
              NiuniuroomHandle:SVR_USER_BASES_RESULT_BROADCAST(pack_tmp)
            end
            bm.callfunc = nil
          end

          dump(bm.callfunc,"drawUser sendCardAnimation")
          NiuniuroomHandle:sendCardAnimation()

        end


    end

end


--登录房间
function NiuniuhallHandle:SVR_LOGIN_ROOM(pack)

    dump(pack, "-----NiuniuhallHandle 牛牛登录房间 1007-----")

    bm.round = 0
    bm.round_total = 0

    require("hall.GameCommon"):landLoading(false)
    display_scene(TpackageName.."/niuniuNamal/NiuniuroomScenes")

    --bm.display_scenes("niuniu.center.niuniu.scenes.NiuniuroomScenes")

    local scenes =  SCENENOW['scene']
    
    bm.User.Seat      =  pack.seat --玩家自己本身座位
    bm.User.Gold      =  pack.gold
    bm.User.Win       =  pack.win
    bm.User.Lost      =  pack.lost
    bm.User.Status    =  pack.user_status--9表示是观察者

    bm.Room.User      = {}
    bm.Room.UserInfo  = {}    
    bm.Room.Status    =  pack.table_status
    bm.Room.Usermount =  pack.user_mount
    bm.Room.Zid       =  tonumber(pack["bank_uid"])
    bm.Room.ShowVoicePosion = {}
    bm.Room.is_send_card = 1

    bm.IReady = 0

    scenes:set_player_gold(0,tostring(bm.User.Gold))
    scenes:set_player_name(0,USER_INFO['nick'])
    scenes:show_difeng_base(true,"斗牛"..tostring(pack.base).."底")

    scenes:set_player_icon(0, USER_INFO["icon_url"],USER_INFO["sex"],tonumber(UID),USER_INFO["nick"])

    USER_INFO["base_chip"] = pack.base
   
    self:drawUser(pack,scenes)

    require("hall.leader.LeaderLayer"):showLeaderLayer(cc.p(905.00, 265.00))

    --添加录音按钮
    require("hall.VoiceRecord.VoiceRecordView"):showView(905, 136.38)

    --自己录音的显示位置
    local position = {}
    position.x = 120.00
    position.y = 130.00
    require("hall.view.voicePlayView.voicePlayView"):updateUserPosition(tonumber(UID), position)

    --显示自己断线的状态--

--   scenes:onNetHistory()

   --pack.user_status 的可能值
    -- 0 //牌局已结束
    -- 1 准备
    -- 2 等待用户抢庄
    -- 3 牌局开始
    -- 4 GRABDEALER
    -- 5 等待用户选择倍数
    -- 6 CALLTIMES
    -- 7 等待出牌
    -- 8 OUTCARD
    -- 9 ISSPECTATOR


    if  pack.user_status > 1 then
        local recscene = SCENENOW['scene']
        recscene:move_player_panel(0)
        require("hall.gameSettings"):setGroupState(1)
        if bm.Room == nil then
            bm.Room = {}
        end
        bm.Room.start_group = 1
    end

    if pack.user_status == 1 then--准备状态
      local pack_tmp = {}
      pack_tmp.uid   = tonumber(UID)
      pack_tmp.time  = pack.less_time
      NiuniuroomHandle:SVR_READY_TIME(pack) --广播牌局可以开始准备
      NiuniuroomHandle:SVR_READY_BROADCAST(pack_tmp) --广播玩家准备
    end

    --发的前三张牌
    if pack.user_status >= 2 and pack.user_status<=6 then
      local pack_tmp     = {}
      pack_tmp.cards     = pack.cards
      bm.Room.Sendlasrcard = false
      NiuniuroomHandle:SVR_SEND_USER_CARD(pack_tmp)
    end

    --等待抢庄
    if pack.user_status == 2 or pack.user_status == 3 or pack.user_status == 4 then
      local pack_tmp     = {}
      pack_tmp.ids       = {}
      pack_tmp.time      = pack.less_time
      for i,v in pairs( bm.Room.User) do
        table.insert(pack_tmp.ids,i)
      end
      table.insert(pack_tmp.ids,tonumber(UID))
      NiuniuroomHandle:SVR_BEGIN_QIANFGZHUANG_BROADCAST(pack_tmp)
    end
    
     -- if pack.table_status > 0 then -- 表示棋牌还没有结束,但是已经开始了
     --    printInfo("======pack.table_status================================================")
     --    NiuniuroomHandle:sendCardAnimation(false)
     -- end

    if pack.user_status == 3 then
      local pack_tmp     = {}
      pack_tmp.uid       = tonumber(UID)
      pack_tmp.if_qiang  = 0
      NiuniuroomHandle:SVR_USER_QIANFGZHUANG_RESULT_BROADCAST(pack_tmp)
    end

    if pack.user_status == 4 then
      local pack_tmp     = {}
      pack_tmp.uid       = tonumber(UID)
      pack_tmp.if_qiang  = 1
      NiuniuroomHandle:SVR_USER_QIANFGZHUANG_RESULT_BROADCAST(pack_tmp)
    end

    --等待加倍
    if pack.user_status == 5 or  pack.user_status == 6 then
      local pack_tmp     = {}
      pack_tmp.time      = pack.less_time
      pack_tmp.bases     = pack.selects_base
      NiuniuroomHandle:SVR_SEND_BASES_TO_USER_BROADCAST(pack_tmp)
    end

    if pack.user_status == 6 then
      local pack_tmp     = {}
      pack_tmp.uid       = tonumber(UID)
      pack_tmp.base     = pack.user_base_calltime
      NiuniuroomHandle:SVR_USER_BASES_RESULT_BROADCAST(pack_tmp)
    end

    --出牌阶段
    if pack.user_status == 7 or  pack.user_status == 8 then
        local pack_tmp     = {}
        pack_tmp.time      = pack.less_time
        NiuniuroomHandle:SVR_PLAY_CARD_BROADCAST(pack_tmp)
    end

    --等待出牌
    if pack.user_status == 7  then
      
      local pack_tmp       = {}
      pack_tmp.cards       = pack.user_base_waitplay_cards
      bm.Room.Sendlasrcard = false
      NiuniuroomHandle:SVR_SEND_USER_CARD(pack_tmp,1)   --有第二个参数表示只绘制自己的牌
      bm.Room.Sendlasrcard = true
      NiuniuroomHandle:SVR_SEND_USER_CARD(pack_tmp,1)
      if  bm.Room.Zid  ~= tonumber(UID) then
        local pack_tmp     = {}
        pack_tmp.uid       = tonumber(UID)
        pack_tmp.base     = pack.user_base_waitplay
        NiuniuroomHandle:SVR_USER_BASES_RESULT_BROADCAST(pack_tmp)
      end

    end

    --出牌完了
    if pack.user_status == 8  then
      
      local pack_tmp       = {}
      pack_tmp.cards       = pack.user_base_out_cards
      bm.Room.Sendlasrcard = false
      NiuniuroomHandle:SVR_SEND_USER_CARD(pack_tmp)
      bm.Room.Sendlasrcard = true
      NiuniuroomHandle:SVR_SEND_USER_CARD(pack_tmp)

      if  bm.Room.Zid  ~= tonumber(UID) then
        local pack_tmp     = {}
        pack_tmp.uid       = tonumber(UID)
        pack_tmp.base      = pack.user_base_out
        NiuniuroomHandle:SVR_USER_BASES_RESULT_BROADCAST(pack_tmp)
      end

      local pack_tmp     = {}
      pack_tmp.uid       = tonumber(UID)
      pack_tmp.kind      = pack.user_base_out_card_kind
      pack_tmp.cards     = pack.user_base_out_cards
      NiuniuroomHandle:SVR_USER_PLAYED_CARDS_BROADCAST(pack_tmp)

      -- NiuniuroomHandle:showGameTips(false)
    end

    if pack.user_status == 9  then--观察者
       scenes:set_spectator(true)

      for key,value in pairs(pack.users_info) do
          local tem_pack = {}
          tem_pack.uid = value.o_uid
          NiuniuroomHandle:SVR_READY_BROADCAST( tem_pack )
      end

      -- local tem_pack = {}
      -- tem_pack.uid = tonumber(UID)
      -- NiuniuroomHandle:SVR_READY_BROADCAST( tem_pack )

       -- if pack.table_status > 0 then -- 表示棋牌还没有结束,但是已经开始了
       --    printInfo("======pack.table_status================================================")
       --    NiuniuroomHandle:sendCardAnimation(false)
       -- end
    end


    --end显示自己断线的状态--

    --显示庄家位置
    if bm.Room.Zid ~= 0  and bm.Room.Status >=2 then
        local pack_tmp = {}
        pack_tmp.uid = pack.bank_uid
        NiuniuroomHandle:SVR_BRANK_BROADCAST(pack_tmp)
    end

    --添加用户
    local uid_arr = {}
    if bm.Room ~= nil then
        if bm.Room.User ~= nil then
            for k,v in pairs(bm.Room.User) do
                if k ~= tonumber(UID) then
                    table.insert(uid_arr, k)
                end
            end
        end
    end

    dump(uid_arr, "-----用户Id-----")
    require("hall.GameSetting"):setPlayerUid(uid_arr)

end


function NiuniuhallHandle:SVR_ENTER_PRIVATE_ROOM( pack )

  require("hall.GameTips"):showTips("系统错误", "tohall", 3, "房间不存在")

end



return NiuniuhallHandle