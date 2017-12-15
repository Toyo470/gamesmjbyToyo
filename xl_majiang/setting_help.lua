
--获取资源管理类
local CARD_PATH_MANAGER = require("xl_majiang.card_path")
--资源管理类初始化
CARD_PATH_MANAGER:init()

--定义麻将设置类（麻将公共方法类）
local mjSetting=class("mjSetting",function ()
end)


function mjSetting:ctor()
end

--显示帮助界面
function mjSetting:show_help_layout(Parent,mode)

    --获取帮助界面视图资源
    local help_layout = cc.CSLoader:createNode("xl_majiang/scens/LayerHelp.csb")
    help_layout:setLocalZOrder(10000)
    Parent:addChild(help_layout)

    --退出按钮
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
    btn_exit:addTouchEventListener(exit_touchButtonEvent)

    --规则说明
    local txtWidth = 300
    local txtHeight = 330
    local rowHeight = 20
    mode = mode or 1
    local show_txt = ""
    if mode == 1 then
        show_txt = "血战麻将的是四川成都地区一种特色麻将的玩法\n\n去掉字牌、花牌，只留条、筒、万的108张牌。\n\n不能吃牌，可以碰牌或杠牌，手牌满足相关规定的牌型条件时胡牌.\n\n游戏开始前，玩家需要选择一门要打缺的花色来定缺,定缺后玩家必须在打完所持有的已定缺花色的牌之后,才可以胡牌。\n\n每盘中一家胡牌后牌局并不结束,而是直到胡走三家或抓光牌为止。"

        txtHeight = rowHeight*18
    elseif mode == 2 then
        show_txt = "           自由场说明\n\n1、战败玩家失去底分*番数，获胜玩家获得底分*番数*80%，20%为系统服务费;\n\n2、战败玩家失去底分*番数，获胜玩家获得底分*番数*80%，20%为系统服务费."

        txtHeight = rowHeight*9
    elseif mode == 3 then
        show_txt = "           比赛场说明\n\n1、玩家选择不同的场次缴纳报名费，报名费越高奖励越丰厚;\n\n2、每个场次凑够系统指定人数则开局，参赛玩家随机分成若干组，每轮淘汰掉末尾的玩家；晋级的玩家重新分组进行下一轮，如此直到决出冠军；\n\n最后按照排名颁发奖励。"  

        txtHeight = rowHeight*11
    end


    local txtCount = string.len(show_txt)
    local lineCount = (txtCount*10)/txtWidth
    txtHeight = lineCount*rowHeight
    print("show_help_layout",txtCount,lineCount,txtHeight)

        local label = display.newTTFLabel({
        text = show_txt,
        font = "res/fonts/fzcy.ttf",
        size = 16,
        color = cc.c3b(234,238,187), -- 使用纯红色
        align = cc.TEXT_ALIGNMENT_LEFT,
        valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
        dimensions = cc.size(txtWidth, txtHeight)
        })
        -- local label = cc.LabelTTF:create(show_txt,"res/fonts/fzcy.ttf",16)
        -- label:enableShadow(cc.c4b(234,238,187,255), cc.size(1,0))
        label:setLineHeight(rowHeight)
        -- help_layout:addChild(label)
        -- label:setPositionX(539.57)
        -- label:setPositionY(210)

    local sv = help_layout:getChildByName("sv_text")
    sv:setInnerContainerSize(cc.size(txtWidth,txtHeight))
    label:setPosition(cc.p(label:getContentSize().width/2,label:getContentSize().height/2))
    sv:getInnerContainer():addChild(label)

end

--显示设置界面
function mjSetting:show_setting_layout(Parent)

    --获取设置界面视图资源
    local help_layout = cc.CSLoader:createNode("xl_majiang/scens/LayerSetting.csb")
    Parent:addChild(help_layout)
    help_layout:setLocalZOrder(10000)

    --定义控件
    local btn_exit = help_layout:getChildByName("btn_exit")
    local btn_shock = help_layout:getChildByName("btn_shock")
    local music_slider = help_layout:getChildByName("Slider_music")
    local sound_slider = help_layout:getChildByName("Slider_sound")

    if SHOCK_ON then
        str = "xl_majiang/majiang/Settings/btn_on.png"
    else
        str = "xl_majiang/majiang/Settings/btn_off.png"
    end
    btn_shock:loadTextures(str,nil,nil)

    local function exit_touchButtonEvent(sender,event)
        -- body
        if event == TOUCH_EVENT_ENDED then
            if sender == btn_exit then
                local parent = btn_exit:getParent()
                parent:removeFromParent()
            end

            if sender == btn_shock then
                SHOCK_ON = not SHOCK_ON
                if SHOCK_ON then
                    str = "xl_majiang/majiang/Settings/btn_on.png"
                else
                    str = "xl_majiang/majiang/Settings/btn_off.png"
                end
                btn_shock:loadTextures(str,nil,nil)
                cc.UserDefault:getInstance():setBoolForKey("shock_on", SHOCK_ON)
            end

        end

    end

    btn_shock:addTouchEventListener(exit_touchButtonEvent)--退出按钮
    btn_exit:addTouchEventListener(exit_touchButtonEvent)--退出按钮

    --音量和音效大小
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
          --print(".......sound_slider...........set......percent",percent)
        end
    end

    music_slider:addEventListener(slider_call_back)
    sound_slider:addEventListener(slider_call_back)


    return help_layout
end

--显示特效
function show_particle_effect(parent_scence,positonX,positonY,sprite_path)
    -- body
    local action_scale = cc.ScaleTo:create(1,2.5)
    local action_hide = cc.RemoveSelf:create()
    local action_sequence = cc.Sequence:create(action_scale,action_hide)
    local path_guan = CARD_PATH_MANAGER:get_card_path("path_guan")
    local backbg = display.newSprite(path_guan)
    backbg:setScale(0.1)
    backbg:setPosition(positonX,positonY)
    parent_scence:addChild(backbg,1600)
    backbg:runAction(action_sequence)

    local _emitter =cc.ParticleSystemQuad:create("xl_majiang/image/Plist/NewParticle_1.plist")
    local batch =cc.ParticleBatchNode:createWithTexture(_emitter:getTexture())
    batch:addChild(_emitter)
    batch:setName("plistTest2")
    parent_scence:addChild(batch,1601)
    _emitter:setPosition(positonX,positonY)

    local _emitter =cc.ParticleSystemQuad:create("xl_majiang/image/Plist/NewParticle_2.plist")
    local batch =cc.ParticleBatchNode:createWithTexture(_emitter:getTexture())
    batch:addChild(_emitter)
    parent_scence:addChild(batch,1602)
    batch:setName("plistTest1")
    _emitter:setPosition(positonX,positonY)

    --碰，杆，听
    if sprite_path ~= nil then
        local special_spr = display.newSprite(sprite_path)
        special_spr:setPosition(positonX,positonY)
        parent_scence:addChild(special_spr,1603)

        local special_spr_scale = cc.DelayTime:create(3.0)
        local hide_Plist=cc.CallFunc:create(function()
                local p1=parent_scence:getChildByName("plistTest1")
                local p2=parent_scence:getChildByName("plistTest2")
                p1:removeSelf();
                p2:removeSelf();
            end)
        local special_spr_hide = cc.RemoveSelf:create()
        local special_spr_sequence = cc.Sequence:create(special_spr_scale,hide_Plist,special_spr_hide)
        special_spr:runAction(special_spr_sequence)
    end
end

--显示杆特效
function show_guan_effect(parent_scence,positonX,positonY)
    -- body
    show_particle_effect(parent_scence,positonX,positonY,"xl_majiang/image/effect_gang.png")

end

--显示碰特效
function show_peng_effect(parent_scence,positonX,positonY)
    -- body
    show_particle_effect(parent_scence,positonX,positonY,"xl_majiang/image/effect_peng.png")
    
end

--显示听牌特效
function show_ting_effect(parent_scence,positonX,positonY)
    -- body
    show_particle_effect(parent_scence,positonX,positonY,"xl_majiang/image/quan_ting.png")
    
end

--显示自摸特效
function show_zimo_effect(parent_scence,positonX,positonY,hu_type)
    -- body
    local action_scale = cc.ScaleTo:create(1,2.5)
    local action_hide = cc.Hide:create()
    local action_sequence = cc.Sequence:create(action_scale,action_hide)
    local path_guan = CARD_PATH_MANAGER:get_card_path("path_guan")
    local backbg = display.newSprite(path_guan)
    backbg:setScale(0.1)
    backbg:setPosition(positonX,positonY)
    parent_scence:addChild(backbg,1600)

    backbg:runAction(action_sequence)

    if hu_type == 2 then
        local sprite_path = "xl_majiang/image/effectzimo.png"

        local special_spr = display.newSprite(sprite_path)
        special_spr:setPosition(positonX,positonY + 25 )
        parent_scence:addChild(special_spr,1601)

        local special_spr_scale = cc.DelayTime:create(3.0)
        local special_spr_hide = cc.RemoveSelf:create()
        local special_spr_sequence = cc.Sequence:create(special_spr_scale,special_spr_hide)
        special_spr:runAction(special_spr_sequence)
    end

    if hu_type == 1 then
        local sprite_path = "xl_majiang/image/effect_pinghu.png"
        local special_spr = display.newSprite(sprite_path)
        special_spr:setPosition(positonX,positonY + 25 )
        parent_scence:addChild(special_spr,1601)

        local special_spr_scale = cc.DelayTime:create(3.0)
        local special_spr_hide = cc.RemoveSelf:create()
        local special_spr_sequence = cc.Sequence:create(special_spr_scale,special_spr_hide)
        special_spr:runAction(special_spr_sequence)
    end
    
end

--显示胜利界面
function show_win_layout( scene )
    -- body
    local layout_win = scene:getChildByName("layout_lose")
    if layout_win ~= nil then --已存在
        return
    end

    local layout = cc.CSLoader:createNode("xl_majiang/scens/Layerwin.csb"):addTo(scene)
    layout:setName("layout_lose")
    layout:setLocalZOrder(10000)

    local btn_exit = layout:getChildByName("close_btn")
    local function touchButtonEvent(sender, event)
        if event == TOUCH_EVENT_ENDED then
            if sender == btn_exit then
                local parent = btn_exit:getParent()
                parent:removeFromParent()
            end
        end
    end
    btn_exit:addTouchEventListener(touchButtonEvent)

    return layout
end

--显示失败界面
function show_lose_layout(scene)
    -- body
    local layout_win = scene:getChildByName("layout_lose")
    if layout_win ~= nil then --已存在
        return
    end

    local layout = cc.CSLoader:createNode("xl_majiang/scens/Layerlose.csb"):addTo(scene)
    layout:setName("layout_lose")
    layout:setLocalZOrder(10000)

    local btn_exit = layout:getChildByName("close_btn")

    local function touchButtonEvent(sender, event)
        if event == TOUCH_EVENT_ENDED then
            if sender == btn_exit then
                local parent = btn_exit:getParent()
                parent:removeFromParent()
            end
        end
    end
    btn_exit:addTouchEventListener(touchButtonEvent)


    return layout
end

return mjSetting