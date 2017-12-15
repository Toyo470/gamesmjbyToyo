mrequire("result.round_result_template")
mrequire("cardhandle.deal_card_path")
mrequire("names")
mrequire("ui")

local Sender = require(GAMEBASENAME..".Sender")

RoundResultLayout = class("RoundResultLayout", result.round_result_template.round_result_Template)

function RoundResultLayout:_do_after_init()
    self.__sxzy_jing_point_prefix_dict = {
                            [names.GAME_UP_JING_CARD_LIST] = "round_result_sxzy_sj_point%d",
                            [names.GAME_DOWN_JING_CARD_LIST] = "round_result_sxzy_xj_point%d",
                            [names.GAME_LEFT_JING_CARD_LIST] = "round_result_sxzy_zj_point%d",
                            [names.GAME_RIGHT_JING_CARD_LIST] = "round_result_sxzy_yj_point%d"
                        }

    self.__sx_jing_point_prefix_dict = {
                            [names.GAME_UP_JING_CARD_LIST] = "round_result_sx_sj_point%d",
                            [names.GAME_DOWN_JING_CARD_LIST] = "round_result_sx_xj_point%d",
                        }

    self.__card_style_dict = {
        [names.GAME_UP_JING_CARD_LIST] = "up",
        [names.GAME_DOWN_JING_CARD_LIST] = "down",
        [names.GAME_LEFT_JING_CARD_LIST] = "left",
        [names.GAME_RIGHT_JING_CARD_LIST] = "right"
    }

         --移除录音按钮
  require("hall.VoiceRecord.VoiceRecordView"):removeView()
  local layout_object = layout.reback_layout_object("room_base")
  layout_object:reset_up_doem_tip()
end

function RoundResultLayout:refresh_change_chips(game_account_data_dict)
    for account_id,account_data_dict in pairs(game_account_data_dict) do
        local seat_index = zzroom.manager:get_other_index(tonumber(account_id))
        local account_change_chip = account_data_dict[names.ACCOUNT_CHANGE_CHIP]
        local total_point_widget = ui.manager:get_widget_object("round_result_total_point"..tostring(seat_index))

        if total_point_widget ~= nil then
            total_point_widget:setString(tostring(account_change_chip))
        end
    end
end

function RoundResultLayout:refresh_gang_jing_point(gang_jing_point_dict)
  for account_id,gang_jing_point in pairs(gang_jing_point_dict) do
      local seat_index = zzroom.manager:get_other_index(tonumber(account_id))
      local gang_widget_name = "round_result_gang_jing"..tostring(seat_index)
      local gang_widget = ui.manager:get_widget_object(gang_widget_name)

      if gang_widget ~= nil then
          gang_widget:setString(tostring(gang_jing_point))
      end
  end
end

function RoundResultLayout:refresh_round_result(round_result_dict,jing_style_count)
    local game_hu_point_dict = round_result_dict[names.GAME_HU_POINT_DICT] or {}
    local game_account_data_dict = round_result_dict[names.ACCOUNT_DATA] or {}
    local game_jing_card_dict = round_result_dict[names.GAME_JING_DATA_DICT] or {}--精牌牌值字典
    local game_jing_point_dict = round_result_dict[names.GAME_JING_POINT_DICT] or {}--精牌分字典
    local an_gang_point_dict = round_result_dict[names.GAME_AN_GANG_POINT_DICT] or {}
    local ming_gang_point_dict = round_result_dict[names.GAME_MING_GANG_POINT_DICT] or {}
    local gang_jing_point_dict = round_result_dict[names.GAME_GANG_JING_POINT_DICT] or {}
    self:refresh_hit_jing_data(game_account_data_dict,game_jing_point_dict,jing_style_count)
    self:refresh_hu_widget_point(game_hu_point_dict)
    self:refresh_gang_point(an_gang_point_dict,ming_gang_point_dict)
    self:refresh_change_chips(game_account_data_dict)
    self:refresh_jing_card(game_jing_card_dict,jing_style_count)
    self:refresh_gang_jing_point(gang_jing_point_dict)
    self:ini_my_card(game_account_data_dict)
end

function RoundResultLayout:refresh_hu_widget_point(account_hu_point_dict)
    for account_id,hu_point in pairs(account_hu_point_dict) do
        local seat_index = zzroom.manager:get_other_index(tonumber(account_id))
        local hu_point_widget_name = "round_result_hu_point"..tostring(seat_index)
        
        local point_widget = ui.manager:get_widget_object(hu_point_widget_name)
        print("----hu_point_widget_name---",hu_point_widget_name,point_widget)
        if point_widget ~= nil then
            point_widget:setString(tostring(hu_point))
        end
    end
end

function RoundResultLayout:check_fang_gang_count(last_fang_gang_dict)
    local card_count = 0
    for _,card_index_list in pairs(last_fang_gang_dict) do
        card_count = card_count + table.getn(card_index_list)
    end

    return card_count
end

function RoundResultLayout:refresh_jing_card(game_jing_card_dict,jing_style_count)
    if jing_style_count == 2 then
        self.round_result_left_jing_bg:setVisible(false)
        self.round_result_right_jing_bg:setVisible(false)
    else
        self.round_result_left_jing_bg:setVisible(true)
        self.round_result_right_jing_bg:setVisible(true)
    end

    for jing_style,jing_card_list in pairs(game_jing_card_dict) do
        local card_style = self.__card_style_dict[jing_style] or ""
        local zj_card_path = cardhandle.deal_card_path.get_card_path(jing_card_list[1])
        local fj_card_path = cardhandle.deal_card_path.get_card_path(jing_card_list[2])

        local zj_card_widget_name = string.format("round_result_%s_zj_img",card_style)
        local zj_gang_widget = ui.manager:get_widget_object(zj_card_widget_name)
        local fj_card_widget_name =  string.format("round_result_%s_fj_img",card_style)
        local fj_gang_widget = ui.manager:get_widget_object(fj_card_widget_name)

        print("---zj_card_widget_name,fj_card_widget_name = ",zj_card_widget_name,fj_card_widget_name,zj_card_path,fj_card_path)
        if zj_gang_widget ~= nil then
            zj_gang_widget:loadTexture(zj_card_path)
        end
        if fj_gang_widget ~= nil then
            fj_gang_widget:loadTexture(fj_card_path)
        end
    end

end

function RoundResultLayout:refresh_gang_point(an_gang_point_dict,ming_gang_point_dict)
    for account_id,an_gang_point in pairs(an_gang_point_dict) do
        local seat_index = zzroom.manager:get_other_index(tonumber(account_id))
        local ming_gang_point = ming_gang_point_dict[account_id]
        local ming_gang_widget = ui.manager:get_widget_object("round_result_ming_gang"..tostring(seat_index))
        local an_gang_widget = ui.manager:get_widget_object("round_result_an_gang"..tostring(seat_index))

        --print("---------account_id-",account_id,account_data_dict,last_an_gang_list,last_fang_gang_dict)

        if ming_gang_widget ~= nil then
            ming_gang_widget:setString(tostring(ming_gang_point))
        end

        if an_gang_widget ~= nil then
            an_gang_widget:setString(tostring(an_gang_point))
        end

    end
end

function RoundResultLayout:refresh_jing_widget_point(account_jing_dict,total_account_point_dict,prefix_name)


    for account_id,jing_point in pairs(account_jing_dict) do
        local seat_index = zzroom.manager:get_other_index(tonumber(account_id))
        --print ("----account_id--",account_id,seat_index)
        local point_widget_name = string.format(prefix_name,seat_index)
        --print("---------point_widget_name--",point_widget_name,jing_point)
        local point_widget = ui.manager:get_widget_object(point_widget_name)
        if point_widget ~= nil then
            point_widget:setString(tostring(jing_point))
        end
        local last_point = total_account_point_dict[account_id]
        last_point = last_point + jing_point
        total_account_point_dict[account_id] = last_point
    end
end

function RoundResultLayout:refresh_hit_jing_data(game_account_data_dict,game_jing_point_dict,jing_style_count)--设置命中精的
    local hide_jing_bg_widget = nil
    local show_jing_bg_widget = nil

    local total_account_point_dict = {}

    for account_id,account_data_dict in pairs(game_account_data_dict) do
        total_account_point_dict[account_id] = 0
        local hide_widget_name = ""
        local show_widget_name = ""
        local seat_index = zzroom.manager:get_other_index(tonumber(account_id))

        if jing_style_count == 2 then
            hide_widget_name = "round_result_sxzy_bg"..tostring(seat_index)
            show_widget_name = "round_result_sx_bg"..tostring(seat_index)
            hide_jing_bg_widget = ui.manager:get_widget_object(hide_widget_name)
            show_jing_bg_widget = ui.manager:get_widget_object(show_widget_name)
        else
            hide_widget_name = "round_result_sx_bg"..tostring(seat_index)
            show_widget_name = "round_result_sxzy_bg"..tostring(seat_index)
            hide_jing_bg_widget = ui.manager:get_widget_object(hide_widget_name)
            show_jing_bg_widget = ui.manager:get_widget_object(show_widget_name)
        end
        if hide_jing_bg_widget ~= nil then
            hide_jing_bg_widget:setVisible(false)
        end

        if show_jing_bg_widget ~= nil then
            show_jing_bg_widget:setVisible(true)
        end
    end


   
    for jing_style,account_jing_dict in pairs(game_jing_point_dict) do
        local prefix_name = ""
        if jing_style_count == 2 then
            prefix_name = self.__sx_jing_point_prefix_dict[jing_style]
        else
            prefix_name = self.__sxzy_jing_point_prefix_dict[jing_style]
        end

        self:refresh_jing_widget_point(account_jing_dict,total_account_point_dict,prefix_name)
    end

    for account_id,total_point in pairs(total_account_point_dict) do
        local seat_index = zzroom.manager:get_other_index(tonumber(account_id))
        local total_point_widget_name = "round_result_jing_point"..tostring(seat_index)
        local total_point_widget = ui.manager:get_widget_object(total_point_widget_name)
        if total_point_widget ~= nil then
            total_point_widget:setString(tostring(total_point))
        end
    end
end

function RoundResultLayout:ini_my_card( game_account_data_dict )
    -- body
    local account_object = account.get_player_account()
    local recuid = account_object:get_account_id()

    for account_id,content in pairs(game_account_data_dict) do
        account_id = tonumber(account_id)
        if recuid == account_id then
          dump(content,"content")

          local pos = cc.p(129.60,80.67)

          local width = self.round_result_cardbase:getContentSize().width

          local des_txt = ""
          --暗杠
          local anGangNum = table.nums(content.account_last_an_gang_list)
          if anGangNum > 0 then
              for _,card_value in pairs(content.account_last_an_gang_list) do
                for i = 1,3 do
                  local card = self.round_result_cardbase:clone()
                  self:addChild(card)
                  card:setPosition(pos)
                  local image_tx =  cardhandle.deal_card_path.get_card_path(card_value)
                  local image = card:getChildByName("round_result_cardimage")
                  image:loadTexture(image_tx)

                  pos.x = pos.x + width
                end
                local result_backcard = self.round_result_back0:clone()
                self:addChild(result_backcard)
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
                local card = self.round_result_cardbase:clone()
                self:addChild(card)
                card:setPosition(pos)
                local image_tx =  cardhandle.deal_card_path.get_card_path(card_value)
                local image = card:getChildByName("round_result_cardimage")
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
                    local card = self.round_result_cardbase:clone()
                    self:addChild(card)
                    card:setPosition(pos)
                    local image_tx =  cardhandle.deal_card_path.get_card_path(card_value)
                    local image = card:getChildByName("round_result_cardimage")
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
                  local card = self.round_result_cardbase:clone()
                  self:addChild(card)
                  card:setPosition(pos)
                  local image_tx =  cardhandle.deal_card_path.get_card_path(card_value)
                  local image = card:getChildByName("round_result_cardimage")
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
                    local card = self.round_result_cardbase:clone()
                    card:setPosition(pos)
                    self:addChild(card)

                    local image_tx =  cardhandle.deal_card_path.get_card_path(card_value)
                    local image = card:getChildByName("round_result_cardimage")
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
                    local card = self.round_result_cardbase:clone()
                    card:setPosition(pos)
                    self:addChild(card)

                    local image_tx =  cardhandle.deal_card_path.get_card_path(card_value)
                    local image = card:getChildByName("round_result_cardimage")
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
            local card = self.round_result_cardbase:clone()
            card:setPosition(pos)
            self:addChild(card)

            local image_tx =  cardhandle.deal_card_path.get_card_path(hucard)
            local image = card:getChildByName("round_result_cardimage")
            image:loadTexture(image_tx)
          end


          -- local score = content.account_change_chip or 0
          -- self:reset_result_score(index,score)
          -- if index == 0 then
          --   self:reset_title_state(score)
          -- end

          -- if account_hu_conbination_list[1] ~= nil then
          --   self:reset_hupos(index)
          -- end
          local account_hu_conbination_list = content.account_hu_conbination_list or {}
          account_hu_conbination_list = account_hu_conbination_list[1] or {}

          local account_hu_conbination_list_str = account_hu_conbination_list[2] or {}
          local str = ""
          for _,hu_name in pairs(account_hu_conbination_list_str) do
            str = str .. result.get_hu_style(hu_name)
          end
          self.round_result_game_describe:setString(str)

          break;
        end
    end

    local dict_name = {
      self.round_result_account_name0,self.round_result_account_name1,self.round_result_account_name2,self.round_result_account_name3
    }

    local id_name = {
        self.round_result_account_id0,self.round_result_account_id1,self.round_result_account_id2,self.round_result_account_id3
    }
    
    local photo_dict = {
        self.round_result_head_photo0,self.round_result_head_photo1,self.round_result_head_photo2,self.round_result_head_photo3,
    }

    local index = 1
    for account_id,_ in pairs(game_account_data_dict) do
      account_id = tonumber(account_id)

      local player_data = zzroom.manager:get_user_data(account_id)
      id_name[index]:setString(tostring(account_id))

      local nick_name = player_data["account_name"] or ""
      dict_name[index]:setString(tostring(nick_name))

      local w = photo_dict[index]:getContentSize().width
      local h = photo_dict[index]:getContentSize().height
      local sp = display.newSprite(GAMEBASENAME .. "/res/image/head_box2.png")
      sp:setAnchorPoint(cc.p(0.5,0.5))
      photo_dict[index]:addChild(sp)
      sp:setPosition(cc.p(w/2, h/2))

      local icon_url = player_data["account_head"] or ""
      local sex_num = player_data["account_sex"] or 2
      if sp then
        local user_inf = {}
        user_inf["uid"] = account_id
        user_inf["icon_url"] = icon_url
        user_inf["sex"] = sex_num
        user_inf["nick"] = nick_name

        require("hall.GameCommon"):setPlayerHead(user_inf,sp,46)
      end

      if recuid == account_id then
          

          local w = self.round_result_cur_account_head:getContentSize().width
          local h = self.round_result_cur_account_head:getContentSize().height
          local sp = display.newSprite(GAMEBASENAME .. "/res/image/head_box2.png")
          sp:setAnchorPoint(cc.p(0.5,0.5))
          self.round_result_cur_account_head:addChild(sp)
          sp:setPosition(cc.p(w/2, h/2))
          if sp then
            local user_inf = {}
            user_inf["uid"] = account_id
            user_inf["icon_url"] = icon_url
            user_inf["sex"] = sex_num
            user_inf["nick"] = nick_name

            require("hall.GameCommon"):setPlayerHead(user_inf,sp,46)
          end

          self.round_result_cur_account_name:setString(tostring(nick_name))

      end

      index =  index + 1
    end

    ----
    local gameConfig = USER_INFO["gameConfig"] or ""
    self.round_result_config:setString(gameConfig)


end


function RoundResultLayout:click_round_result_reback_btn_event()
    print("-------RoundResultLayout----click_round_result_reback_btn_event----------------")

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

function RoundResultLayout:click_round_result_group_result_share_button_event()
     print("-----RoundResultLayout------click_round_result_group_result_share_button_event----------------")
     self.group_result_share_button:setTouchEnabled(false)
    if device.platform == "android" then
        require("hall.common.ShareLayer"):showShareLayer("分享结果","","screen","",share_ly)
    elseif device.platform ~= "windows" then
        require("hall.common.ShareLayer"):shareGroupResultForIOS(share_ly)
    end

end