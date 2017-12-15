--显示帮助界面
function show_help_layout(Parent)
    local help_layout = cc.CSLoader:createNode("niuniu/LayerHelp.csb")
    help_layout:setLocalZOrder(10000)
    Parent:addChild(help_layout)
    local btn_exit = help_layout:getChildByName("btn_exit")
    local function exit_touchButtonEvent(sender,event)
        -- body
        if event == TOUCH_EVENT_ENDED then
            if sender == btn_exit then
                local parent = btn_exit:getParent()
                parent:removeFromParent()
            end
        end
    end

    btn_exit:addTouchEventListener(exit_touchButtonEvent)--退出按钮 

    local text_music = help_layout:getChildByName("Text_1")
    text_music:setVisible(false)
    local text_music_x = text_music:getPositionX()
    local text_music_y = text_music:getPositionY()
    local params =
    {
        text = "游戏玩法",
        font = "res/fonts/wryh.ttf",
        size = 20,
        color = cc.c3b(250,242,193), 
        align = cc.TEXT_ALIGNMENT_LEFT,
        valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
    }
    local niu_txt = display.newTTFLabel(params)
    niu_txt:enableShadow(cc.c4b(250,242,193,255), cc.size(1,0))

    help_layout:addChild(niu_txt)
    niu_txt:setPositionX(text_music_x)
    niu_txt:setPositionY(text_music_y)

    local text_music = help_layout:getChildByName("ScrollView_1"):getChildByName("Text_2")
    text_music:setColor(cc.c3b(250,242,193))
    text_music:enableShadow(cc.c4b(250,242,193,255), cc.size(1,0))
    text_music:show();

--     text_music:setVisible(false)

--     local label = display.newTTFLabel({
--         text = [[1、每个玩家拥有5张手牌。如果其中3张手牌（JQK按10计算）相加为10的倍数（如10、20），即为有牛，否则为无牛；
-- 五小牛>五花牛>四炸>牛牛>牛九>……>牛一>无牛
-- 2、玩家选择不同的底分，2-5个人即可开始。
-- 3、游戏开始时，玩家可选择"抢庄/不抢"决定自己是否愿意当庄，在"抢庄"玩家中随机选择庄家。庄家确定后，闲家可以进行倍数选择，选择的倍数将影响输赢结果的大小。闲家与庄家比牌，牌大获胜。
-- 4、战败玩家失去底分*倍数，获胜玩家获得底分*倍数*80%，20%为系统服务费；庄家获得的游戏币为赢分减去输的。]],
--         font = "res/fonts/wryh.ttf",
--         size = 18,
--         color = cc.c3b(250,242,193), -- 使用纯红色FAF2C1
--         align = cc.TEXT_ALIGNMENT_LEFT,
--         valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
--         dimensions = cc.size(456, 216)
--     })
--     label:enableShadow(cc.c4b(250,242,193,255), cc.size(1,0))
--     label:setLineHeight(32)
--     help_layout:addChild(label)
--     label:setPositionX(488.32)
--     label:setPositionY(200.16)

end

--显示设置界面
function show_setting_layout(Parent)
    -- body
    local help_layout = cc.CSLoader:createNode("niuniu/LayerSetting.csb")
    Parent:addChild(help_layout)
    help_layout:setLocalZOrder(10000)
    local btn_exit = help_layout:getChildByName("btn_exit")
    local btn_shock_on = help_layout:getChildByName("btn_shock_on")
    local btn_shock_off = help_layout:getChildByName("btn_shock_off")
    local music_slider = help_layout:getChildByName("Slider_music")
    local sound_slider = help_layout:getChildByName("Slider_sound")

    btn_shock_on:setVisible(SHOCK_ON)
    btn_shock_off:setVisible(not SHOCK_ON)

    local function exit_touchButtonEvent(sender,event)
        -- body
        if event == TOUCH_EVENT_ENDED then
            if sender == btn_exit then
                local parent = btn_exit:getParent()
                parent:removeFromParent()
            end

            if sender == btn_shock_on then
                btn_shock_on:setVisible(false)
                btn_shock_off:setVisible(true)
                SHOCK_ON = true
                cc.UserDefault:getInstance():setBoolForKey("shock_on", SHOCK_ON)
            end

            if sender == btn_shock_off then
                btn_shock_on:setVisible(true)
                btn_shock_off:setVisible(false)
                SHOCK_ON = false
                cc.UserDefault:getInstance():setBoolForKey("shock_on", SHOCK_ON)
            end
        end

    end

    btn_shock_on:addTouchEventListener(exit_touchButtonEvent)--退出按钮
    btn_shock_off:addTouchEventListener(exit_touchButtonEvent)--退出按钮
    btn_exit:addTouchEventListener(exit_touchButtonEvent)--退出按钮

    local music_volume = audio.getMusicVolume()
    local sound_volume = audio.getSoundsVolume()
    music_volume,_ = math.modf(music_volume * 100)
    sound_volume,_ = math.modf(sound_volume * 100)
   -- print("..................src......music_volume",music_volume)
   -- print("..................src......sound_volume",sound_volume)

    music_slider:setPercent(music_volume)
    sound_slider:setPercent(sound_volume)

    local function slider_call_back(sender,event)
        if sender == music_slider then
            local percent = music_slider:getPercent()
            percent = percent / 100
            audio.setMusicVolume(percent)
           -- print("......music_slider............set......percent",percent)
        end

        if sender == sound_slider then
           local percent = music_slider:getPercent()
           percent = percent / 100
           audio.setSoundsVolume(percent)
          -- print(".......sound_slider...........set......percent",percent)
        end
    end

    music_slider:addEventListener(slider_call_back)
    sound_slider:addEventListener(slider_call_back)


    -- --替换文本
    -- local text_music = help_layout:getChildByName("Text_5_0_0")
    -- text_music:setVisible(false)
    -- local text_music_x = text_music:getPositionX()
    -- local text_music_y = text_music:getPositionY()
    -- local params =
    -- {
    --     text = "游戏音乐",
    --     font = "res/fonts/wryh.ttf",
    --     size = 20,
    --     color = cc.c3b(175,51,2), 
    --     align = cc.TEXT_ALIGNMENT_LEFT,
    --     valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
    -- }
    -- local niu_txt = display.newTTFLabel(params)
    -- niu_txt:enableShadow(cc.c4b(175,51,2,255), cc.size(1,0))

    -- help_layout:addChild(niu_txt)
    -- niu_txt:setPositionX(text_music_x)
    -- niu_txt:setPositionY(text_music_y)

    --游戏音效
    -- local text_sound = help_layout:getChildByName("Text_5_0")
    -- text_sound:setVisible(false)
    --  text_music_x = text_sound:getPositionX()
    --  text_music_y = text_sound:getPositionY()
    -- local sound_text = display.newTTFLabel(params)
    -- sound_text:enableShadow(cc.c4b(175,51,2,255), cc.size(1,0))
    -- sound_text:setString("游戏音效")
    -- help_layout:addChild(sound_text)
    -- sound_text:setPositionX(text_music_x)
    -- sound_text:setPositionY(text_music_y)

    -- local text_sound = help_layout:getChildByName("Text_5")
    -- text_sound:setVisible(false)
    -- text_music_x = text_sound:getPositionX()
    -- text_music_y = text_sound:getPositionY()
    -- local sound_text = display.newTTFLabel(params)
    -- sound_text:enableShadow(cc.c4b(175,51,2,255), cc.size(1,0))
    -- sound_text:setString("震动")
    -- help_layout:addChild(sound_text)
    -- sound_text:setPositionX(text_music_x)
    -- sound_text:setPositionY(text_music_y)

    -- --Text_1
    -- local text_sound = help_layout:getChildByName("Text_1")
    -- text_sound:setVisible(false)
    -- text_music_x = text_sound:getPositionX()
    -- text_music_y = text_sound:getPositionY()
    -- params =
    -- {
    --     text = "设置",
    --     font = "res/fonts/wryh.ttf",
    --     size = 30,
    --     color = cc.c3b(255,255,255), 
    --     align = cc.TEXT_ALIGNMENT_LEFT,
    --     valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
    -- }
    -- local sound_text = display.newTTFLabel(params)
    -- sound_text:enableShadow(cc.c4b(255,255,255,255), cc.size(1,0))
    -- help_layout:addChild(sound_text)
    -- sound_text:setPositionX(text_music_x)
    -- sound_text:setPositionY(text_music_y)

    return help_layout
end

-- -- 获得花色 
-- local function getVariety(card)
--     return bit.band(card, 0xF0)
-- end


require("niuniu.cardkind")
-- 获得牌值
local function getValue(card)
    local value = bit.band(card, 0x0F)
    if value == 1 then
        value = 14
    end

    --下面是我加的--计算真正的牌值
    if value > 10 and value <14 then --这种奇葩数据格式定义，唉
        value =  10 
    elseif value > 13 then
        value = 1
    end

    return value
end

function is_nuw_num( niuniu_kind )
    -- body

    if niuniu_kind > 1 and niuniu_kind < 11 then
        return true
    else
        return false
    end

end

--这里的排序，不关心花色了，只关心值
function sort_niu_card(card_data_tbl,niuniu_kind)
    print("deal sorting______________________________________",niuniu_kind)
    

    --如果是没牛，或者是牛牛以上的，那么不处理
    if niuniu_kind < 2 or niuniu_kind > 10 then
        return card_data_tbl,false
    end

    -- local niuniu_kind = niuniu_kind - 1
    -- -- body
    -- local type_tbl = {
    --     {1,2,3},
    --     {1,2,4},
    --     {1,2,5},

    --     {1,3,4},
    --     {1,3,5},

    --     {1,4,5},

    --     {2,3,4},
    --     {2,3,5},

    --     {3,4,5},
    -- }
    -- --计算真正的牌值
    -- local tbl = {}
    -- for key,value_card in pairs(card_data_tbl)do
    --     local tmp = getValue(value_card)
    --     tbl[key] = tmp
    -- end

    -- dump(tbl)

    -- local sum = 0
    -- local find_index = 0
    -- for index,type_index in pairs(type_tbl) do 
    --     sum = tbl[type_index[1]] + tbl[type_index[2]] + tbl[type_index[3]]
    --     print(" sum % 10========================", sum % 10)
    --     if sum % 10 == 0 then
    --         find_index = index
    --         break
    --     end
    -- end

    -- local tbl_for_return = {}
    -- print("find_index-------------------------------", find_index)
    -- if find_index  ~= 0 then
    --     local index_tbl = type_tbl[find_index]

    --     for i= 1,3 do
    --         local tem = index_tbl[i]
    --         table.insert(tbl_for_return, card_data_tbl[tem])
    --         card_data_tbl[tem] = nil
    --     end

    --     for _,item in pairs(card_data_tbl) do
    --          table.insert(tbl_for_return,item)
    --     end

    --     return tbl_for_return,true
    -- else
    --     return card_data_tbl,false
    -- end

end