

local targetPlatform = cc.Application:getInstance():getTargetPlatform()
local GameCommon  = class("GameCommon")
local PROTOCOL = require("hall.HALL_SERVER_PROTOCOL")


function GameCommon:show_about()
    -- if SCENENOW["name"] ~= "hall.gameScene" then
    --     return
    -- end
    if SCENENOW["scene"] == nil then
        return
    end

    local about_tip =  SCENENOW["scene"]:getChildByName("about_tip")
    if about_tip then
        return
    end

    about_tip = cc.CSLoader:createNode("hall/Settings/about.csb"):addTo(SCENENOW["scene"])
    about_tip:setName("about_tip")
    about_tip:setLocalZOrder(10001)

    local Panel_3 = about_tip:getChildByName("Panel_3")

    local function touchButtonEvent(sender, event)
        if event == TOUCH_EVENT_ENDED then
            if sender == Panel_3 then
                if SCENENOW["scene"]:getChildByName("about_tip") then
                    SCENENOW["scene"]:removeChildByName("about_tip")
                end
            end
        end
    end

    Panel_3:addTouchEventListener(touchButtonEvent)
end

function GameCommon:show_instruction()
    local layout = cc.CSLoader:createNode("hall/common/InstructionLayer.csb"):addTo(SCENENOW["scene"])
    layout:setName("InstructionLayer")
    local floor = layout:getChildByName("floor")

    local back_bt = floor:getChildByName("back_bt")
    local web_plane = floor:getChildByName("web_plane")

    local function touchButtonEvent(sender, event)
        if event == TOUCH_EVENT_ENDED then
            if sender == back_bt then
                layout:removeFromParent()
            end
        end
    end

    back_bt:addTouchEventListener(touchButtonEvent)

    if device.platform ~="windows" then
        dump(ccexp)
        local planeSize = web_plane:getSize()
        local webView = ccexp.WebView:create()
        webView:setPosition(planeSize.width / 2, planeSize.height / 2)
        webView:setContentSize(planeSize.width - 20,  planeSize.height - 20)
        -- webView:loadURL("file://hall/illustrate/index.html")
        local path = "hall/illustrate/index.html"
        if device.platform == "android" then
            --todos
            path = "file:///" .. device.writablePath .. path
        end

        print("loadjs path",path)
        cc.UserDefault:getInstance():setStringForKey("wanfaUrl", path)
        webView:loadFile(path)
        webView:setScalesPageToFit(true)

        web_plane:addChild(webView)
    end
end

function GameCommon:show_Message(msg)
    local layout = cc.CSLoader:createNode("hall/common/gonggaoLayer.csb"):addTo(SCENENOW["scene"])
    layout:setName("gonggaolayer")
    local floor = layout:getChildByName("floor")

    -- local title_img = floor:getChildByName("Image_2")

    -- title_img:loadTexture("hall/common/fin_text_xiaoxi.png")

    local determine_bt = floor:getChildByName("determine_bt")
    -- local web_plane = floor:getChildByName("web_plane")

    local list_View= floor:getChildByName("ListView_1")
    local txt_msg=list_View:getChildByName("Text_3")
    txt_msg:setString(msg)
    local function touchButtonEvent(sender, event)
        if event == TOUCH_EVENT_ENDED then
            if sender == determine_bt then
                layout:removeFromParent()
            end
        end
    end

    determine_bt:addTouchEventListener(touchButtonEvent)

    -- if device.platform ~="windows" then
    --     dump(ccexp)
    --     local planeSize = web_plane:getSize()
    --     local webView = ccexp.WebView:create()
    --     webView:setPosition(planeSize.width / 2, planeSize.height / 2)
    --     webView:setContentSize(planeSize.width - 20,  planeSize.height - 20)
    --     webView:loadURL("http://120.76.103.204:8080/hbiInterface/illustrate/msg.html")
    --     webView:setScalesPageToFit(true)
    --     web_plane:addChild(webView)
    -- end
end


--显示帮助
function GameCommon:showHelp(flag,msg)
    if flag == false then
        SCENENOW["scene"]:removeChildByName("layout_help")
        return
    end
    print("GameCommon:showHelp")
    local layout = cc.CSLoader:createNode("hall/Settings/LayerHelp.csb"):addTo(SCENENOW["scene"])
    layout:setName("layout_help")
    local btn_exit = layout:getChildByName("btn_exit")
    local function touchButtonEvent(sender, event)
        if event == TOUCH_EVENT_ENDED then
            if sender == btn_exit then
                self:showHelp(false)
            end

        end
    end
    btn_exit:addTouchEventListener(touchButtonEvent)--帮助


    local txtWidth = 300
    local txtHeight = 330
    local rowHeight = 20

    local txtCount = string.len(msg)
    local lineCount = (txtCount*10)/txtWidth
    txtHeight = lineCount*rowHeight

    print("GameCommon:showHelp",txtCount,lineCount,txtHeight)


    local label = display.newTTFLabel({
        text = msg,
        font = "res/fonts/fzcy.ttf",
        size = 16,
        color = cc.c3b(234,238,187), -- 使用纯红色
        align = cc.TEXT_ALIGNMENT_LEFT,
        valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
        dimensions = cc.size(txtWidth, txtHeight)
        })
    -- label:enableShadow(cc.c4b(234,238,187,255), cc.size(1,0))
    -- local label = cc.Label:createWithSystemFont(msg,"Arial",16,cc.size(txtWidth, txtHeight),cc.TEXT_ALIGNMENT_LEFT,cc.VERTICAL_TEXT_ALIGNMENT_TOP)
    label:setLineHeight(rowHeight)

    local sv = layout:getChildByName("sv_text")
    sv:setInnerContainerSize(cc.size(txtWidth,txtHeight))
    label:setPosition(cc.p(label:getContentSize().width/2,label:getContentSize().height/2))
    sv:getInnerContainer():addChild(label)
end

--显示用户协议
function GameCommon:showAgreement(flag,msg)
    if flag == false then
        SCENENOW["scene"]:removeChildByName("layout_agreement")
        return
    end
    print("GameCommon:showAgreement")
    local layout = cc.CSLoader:createNode("hall/common/AgreementLayer.csb"):addTo(SCENENOW["scene"])
    layout:setLocalZOrder(91000)
    layout:setAnchorPoint(0.5,0.5)
    if device.platform == "ios" then
        layout:setPosition(960, 540)
    else
        layout:setPosition(480, 270)
    end
    
    layout:setName("layout_agreement")
    local floor = layout:getChildByName("floor")
    floor.noScale = true
    floor:onClick(function()
            layout:removeFromParent()
        end)

    local txtWidth = 650
    local txtHeight = 380
    local rowHeight = 20

    local txtCount = string.len(msg)
    local lineCount = (txtCount*10)/txtWidth

    if lineCount*rowHeight > txtHeight then
        --todo
        txtHeight = lineCount*rowHeight
    end

    print("GameCommon:showAgreement",txtCount,lineCount,txtHeight)


    local label = display.newTTFLabel({
        text = msg,
        font = "res/fonts/fzcy.ttf",
        size = 16,
        color = cc.c3b(234,30,30), -- 使用纯红色
        align = cc.TEXT_ALIGNMENT_LEFT,
        valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
        dimensions = cc.size(txtWidth, txtHeight)
        })
    -- label:enableShadow(cc.c4b(234,238,187,255), cc.size(1,0))
    -- local label = cc.Label:createWithSystemFont(msg,"Arial",16,cc.size(txtWidth, txtHeight),cc.TEXT_ALIGNMENT_LEFT,cc.VERTICAL_TEXT_ALIGNMENT_TOP)
    label:setLineHeight(rowHeight)

    local sv = floor:getChildByName("scroll_v")
    sv:setInnerContainerSize(cc.size(txtWidth,txtHeight))
    label:setPosition(cc.p(label:getContentSize().width/2,label:getContentSize().height/2))
    sv:getInnerContainer():addChild(label)
end

--显示提示框
function GameCommon:showAlert(flag, msg, maxBodyWidth)
    if flag == false then
        SCENENOW["scene"]:removeChildByName("layout_alert")
        return
    end
    print("GameCommon:showAlert")
    local layout = cc.CSLoader:createNode("hall/common/AlertLayer.csb"):addTo(SCENENOW["scene"])
    layout:setLocalZOrder(91000)
    layout:setName("layout_alert")
    local floor = layout:getChildByName("floor")
    floor.noScale = true
    floor:onClick(function()
            layout:removeFromParent()
        end)

    local bg_1 = floor:getChildByName("bg_1")
    local bg_2 = floor:getChildByName("bg_2")
    local bg_3 = floor:getChildByName("bg_3")

    local split_1_2 = 40
    local split_2_3 = 20
    local split_3_body = 40

    local maxWidth = maxBodyWidth or 360

    local fontSize = 20
    local rowHeight = fontSize * 3 / 2

    print("GameCommon:showAlert",txtCount,lineCount,txtHeight)


    local label = display.newTTFLabel({
        font = "res/fonts/fzht.TTF",
        size = fontSize,
        color = cc.c3b(158,75,46), -- 使用纯红色
        align = cc.TEXT_ALIGNMENT_LEFT,
        valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
        dimensions = cc.size(maxWidth, 0)
        })
    label:setLineHeight(rowHeight)
    label:setString(msg)

    local width = label:getContentSize().width
    local height = label:getContentSize().height

    bg_3:setSize(width + split_3_body, height + split_3_body)
    bg_2:setSize(width + split_3_body + split_2_3, height + split_3_body + split_2_3)
    bg_1:setSize(width + split_3_body + split_2_3 + split_1_2, height + split_3_body + split_2_3 + split_1_2)

    label:setPosition(480, 270)
    floor:addChild(label)
end

--显示Html内容的对话框
function GameCommon:showHtmlAlert(flag, msg, maxBodyWidth)

    if flag == false then
        SCENENOW["scene"]:removeChildByName("layout_alert")
        return
    end

    local layout = cc.CSLoader:createNode("hall/common/AlertLayer.csb"):addTo(SCENENOW["scene"])
    layout:setLocalZOrder(91000)
    layout:setName("layout_alert")
    local floor = layout:getChildByName("floor")
    floor.noScale = true
    floor:onClick(function()
            layout:removeFromParent()
        end)

    local bg_1 = floor:getChildByName("bg_1")
    local bg_2 = floor:getChildByName("bg_2")
    local bg_3 = floor:getChildByName("bg_3")

    local split_1_2 = 40
    local split_2_3 = 20
    local split_3_body = 40

    bg_3:setSize(maxBodyWidth + split_3_body, maxBodyWidth + split_3_body)
    bg_2:setSize(maxBodyWidth + split_3_body + split_2_3, maxBodyWidth + split_3_body + split_2_3)
    bg_1:setSize(maxBodyWidth + split_3_body + split_2_3 + split_1_2, maxBodyWidth + split_3_body + split_2_3 + split_1_2)

    if device.platform ~="windows" then
        local planeSize = floor:getSize()
        local webView = ccexp.WebView:create()
        webView:setPosition(planeSize.width / 2, planeSize.height / 2)
        webView:setContentSize(planeSize.width - 40,  planeSize.height - 40)
        webView:loadURL("http://www.baidu.com")
        webView:setScalesPageToFit(true)

        floor:addChild(webView)
    end

end

--显示游戏设置
function GameCommon:showSettings(flag,bChangeUser,bDismiss,sDisband,disbandCallback)

    dismiss = bDismiss or false
    print("dismiss:",tostring(dismiss),"bDismiss:",tostring(bDismiss))
    print("flag:",tostring(flag),"bChangeUser:",tostring(bChangeUser))

    change_user = bChangeUser or false

    showDisband = sDisband or false

    if flag == false then
        SCENENOW["scene"]:removeChildByName("layout_settings")
        return
    end

    local layout = cc.CSLoader:createNode("hall/Settings/LayerSetting.csb"):addTo(SCENENOW["scene"])
    layout:setLocalZOrder(10000)
    layout:setName("layout_settings")
    local floor = layout:getChildByName("floor")

    floor.noScale = true
    -- floor:onClick(
    --     function()
    --         self:showSettings(false)
    --     end
    -- )

    local close_bt = floor:getChildByName("close_bt")
    local sound_slide = floor:getChildByName("sound_slide")
    local music_slide = floor:getChildByName("music_slide")
    local sound_bt = floor:getChildByName("sound_bt")
    local music_bt = floor:getChildByName("music_bt")
    local logout_bt = floor:getChildByName("logout_bt")
   -- logout_bt:setVisible(false)
    local audioEngine = cc.SimpleAudioEngine:getInstance()

    dump(audioEngine, "audioEngine test")

    

    -- if btn_change_user then
    --     btn_change_user:setEnabled(change_user)
    --     if change_user == false then

    --         btn_change_user:loadTextureNormal("hall/common/small_disable_bt_n.png")
    --         -- btn_change_user:setColor(cc.c3b(125,125,125))
    --     else
    --         btn_change_user:loadTextureNormal("hall/common/small_green_bt_n.png")
    --         -- btn_change_user:setColor(cc.c3b(255,255,255))
    --     end
    -- end

    if showDisband then
        local disband_ly = ccui.Layout:create()
        disband_ly:setTouchEnabled(true)
        disband_ly:setAnchorPoint(cc.p(0,1))
        disband_ly:setPosition(logout_bt:getPosition().x - 92, logout_bt:getPosition().y + 40)
        disband_ly:setContentSize(cc.size(195, 81))
        floor:addChild(disband_ly)

        local disband_bg = ccui.ImageView:create()
        disband_bg:loadTexture("hall/common/yellow_bt.png")
        disband_bg:setAnchorPoint(cc.p(0,1))
        disband_bg:setPosition(0, disband_ly:getContentSize().height)
        disband_ly:addChild(disband_bg)

        local disband_tt = ccui.ImageView:create()
        disband_tt:loadTexture("hall/common/mahjong_jiesanfangjian.png")
        disband_tt:setAnchorPoint(cc.p(0,1))
        disband_tt:setPosition(33, disband_ly:getContentSize().height -12)
        disband_ly:addChild(disband_tt)

        disband_ly:addTouchEventListener(
            -- function(sender,event)
            --     --触摸开始
            --     if event == TOUCH_EVENT_BEGAN then
            --         sender:setScale(0.9)
            --     end

            --     --触摸取消
            --     if event == TOUCH_EVENT_CANCELED then
            --         sender:setScale(1.0)
            --     end

            --     --触摸结束
            --     if event == TOUCH_EVENT_ENDED then
            --         sender:setScale(1.0)

            --         self:showSettings(false)

            --         require("majiang.scenes.MajiangroomScenes"):disbandGroup()

            --     end
            -- end
            disbandCallback
        )

        logout_bt:setVisible(false)
        
    end

    local function touchButtonEvent(sender, event)

        if event == TOUCH_EVENT_ENDED then

            if sender == close_bt then
                self:showSettings(false)
                local MusicVolume=audioEngine:getMusicVolume()
                local EffectsVolume=audioEngine:getEffectsVolume()
                cc.UserDefault:getInstance():setFloatForKey("MusicVolume", MusicVolume)
                cc.UserDefault:getInstance():setFloatForKey("EffectsVolume", EffectsVolume)
                cc.UserDefault:getInstance():flush()      
            end

            --打开音乐
            if sender == music_bt then
                
                if audioEngine:getMusicVolume() == 0.0 then
                    --todo
                    audioEngine:setMusicVolume(1.0)
                    music_slide:setPercent(100)
                    music_bt:setColor(cc.c3b(255,255,255))
                    cc.UserDefault:getInstance():setIntegerForKey("music_value", 100)
                else
                    audioEngine:setMusicVolume(0.0)
                    music_slide:setPercent(0)
                    music_bt:setColor(cc.c3b(125,125,125))
                    cc.UserDefault:getInstance():setIntegerForKey("music_value", 0)
                end
            elseif sender == sound_bt then

                if audioEngine:getEffectsVolume() == 0.0 then
                    --todo
                    audioEngine:setEffectsVolume(1.0)
                    sound_slide:setPercent(100)
                    sound_bt:setColor(cc.c3b(255,255,255))
                    cc.UserDefault:getInstance():setIntegerForKey("sound_value", 100)
                else
                    audioEngine:setEffectsVolume(0.0)
                    sound_slide:setPercent(0)
                    sound_bt:setColor(cc.c3b(125,125,125))
                    cc.UserDefault:getInstance():setIntegerForKey("sound_value", 0)
                end
                -- cc.UserDefault:getInstance():setBoolForKey("sound_on", SOUND_ON)
            elseif sender == logout_bt then  --退出游戏  scheduler.unscheduleGlobal()触发红屏
                
                --查询用户历史记录返回
                local function viewReganizeHistory_callback(data)

                    --返回数据验证
                    local data_netData = data.netData
                    if data_netData == nil then
                        return
                    end

                    --检查是否有未结束组局
                    local tbHistory = {}
                    data_netData = json.decode(data_netData)
                    for k,v in pairs(data_netData.data) do
                        if v.status == nil or v.status ~= "2" then
                            table.insert(tbHistory, v)
                        end
                    end
                    dump(tbHistory, "-----当前用户未结束的组局-----")

                    --如果没有组局历史
                    if #tbHistory > 0 then
                        require("hall.GameTips"):showTips("提示", "", 2, "您有未解散组局\n不能退出登录")
                    else
                        if isTaoAndroid then
                            bm.isExit=true
                            display_scene("hall.loginGame")
                            SCENENOW["scene"]:exitLogin();
                        

                            
                        end
                        require("hall.LoginScene"):show()
                        self:showSettings(false)
                    end

                end

                cct.createHttRq({
                    url=HttpAddr .. "/viewReganizeHistory",
                    date={
                        userId = tonumber(UID)
                    },
                    type_="POST",
                    callBack = viewReganizeHistory_callback
                })
            end
        end
    end
    close_bt:addTouchEventListener(touchButtonEvent)
    logout_bt:addTouchEventListener(touchButtonEvent)

    local function sliderChanged(sender,eventType)
        if eventType == ccui.SliderEventType.percentChanged then
            local amount = sender:getPercent()
            local audioEngine = cc.SimpleAudioEngine:getInstance()
            -- amount = math.modf(amount/20)*20
            if sender == music_slide then
                --todo
                audioEngine:setMusicVolume(amount / 100)
                if amount == 0 then
                    --todo
                    music_bt:setColor(cc.c3b(125,125,125))
                else
                    music_bt:setColor(cc.c3b(255,255,255))
                end
                cc.UserDefault:getInstance():setIntegerForKey("music_value", amount)
            elseif sender == sound_slide then
                audioEngine:setEffectsVolume(amount / 100)
                if amount == 0 then
                    --todo
                    sound_bt:setColor(cc.c3b(125,125,125))
                else
                    sound_bt:setColor(cc.c3b(255,255,255))
                end
                cc.UserDefault:getInstance():setIntegerForKey("sound_value", amount)
            end
        end
    end

    -- if device.platform~="windows" then

    print("showSettings sound_slide", tostring(audioEngine:getEffectsVolume()))
    print("showSettings music_slide", tostring(audioEngine:getMusicVolume()))

    sound_slide:setPercent(audioEngine:getEffectsVolume() * 100)
    music_slide:setPercent(audioEngine:getMusicVolume() * 100)

    if audioEngine:getMusicVolume() == 0.0 then
        --todo
        music_bt:setColor(cc.c3b(125,125,125))
    else
        music_bt:setColor(cc.c3b(255,255,255))
    end

    if audioEngine:getEffectsVolume() == 0.0 then
        --todo
        sound_bt:setColor(cc.c3b(125,125,125))
    else
        sound_bt:setColor(cc.c3b(255,255,255))
    end

    music_bt:addTouchEventListener(touchButtonEvent)
    sound_bt:addTouchEventListener(touchButtonEvent)
    sound_slide:addEventListener(sliderChanged)
    music_slide:addEventListener(sliderChanged)
    -- end
    

end

--登陆loading
function GameCommon:landLoading(flag,par)

    if bm.isConnectBytao then
        --todo
        return;
    end
    par = par or SCENENOW["scene"]

    local layerLoading = par:getChildByName("layout_loading")
    if layerLoading == nil then
        layerLoading = cc.CSLoader:createNode("res/loading/loading.csb"):addTo(par)
        layerLoading:getChildByName("logo_3"):setVisible(false)

        if gameTypeTTT and gameTypeTTT==7 then
            layerLoading:setScaleX(640/960)
            layerLoading:setScaleY(440/540)
        else
            --todo
            layerLoading:setScaleX(1)
            layerLoading:setScaleY(1)
        end
        -- layerLoading = cc.CSLoader:createNode("hall/LayerGameLoading.csb"):addTo(SCENENOW["scene"])


        layerLoading:setName("layout_loading")
    end

    if layerLoading then
        if flag == false then
            -- layerLoading:setVisible(false)
            SCENENOW["scene"]:removeChildByName("layout_loading")
            print("GameCommon:landLoading false")
            return
        end

        layerLoading:setLocalZOrder(20000)
        layerLoading:setVisible(true)

        --进度条
        local progress = layerLoading:getChildByName("loading_bar")
        progress:setPercent(0)
        local txt_progress = layerLoading:getChildByName("txt_progress")
        txt_progress:setString(0)
    end

end

--加载过程中提示
function GameCommon:showLoadingTips(str)
    -- body
    print("GameCommon:showLoadingTips")
    if bm.isConnectBytao then
        --todo
        return;
    end
    if not SCENENOW["scene"] then
        --todo
        return;
    end
    local layerLoading = SCENENOW["scene"]:getChildByName("layout_loading")
    if layerLoading then
        local txt = layerLoading:getChildByName("lb_tips")
        if txt then
            txt:setString(str)
            txt:setColor(cc.c3b(255,255,255))
        else
            print("can't match Text_1")
        end
    else
        self:landLoading(true)
        layerLoading = SCENENOW["scene"]:getChildByName("layout_loading")
        if layerLoading then
            local txt = layerLoading:getChildByName("lb_tips")
            if txt then
                txt:setString(str)
                txt:setColor(cc.c3b(0xff,0xff,0xff))
            else
                print("can't match Text_1")
            end
        else
            print("can't match layout_loading")
        end
    end
end

--显示更新进度
function GameCommon:setLoadingProgress(progress)
    -- body
    local layerLoading = SCENENOW["scene"]:getChildByName("layout_loading")
    if layerLoading then
        if progress < 0 then
            progress = 0
        end
        local spLoading = layerLoading:getChildByName("loading_bar")
        if spLoading then
            if spLoading:isVisible() == false then
                spLoading:setVisible(true)
            end
            spLoading:setPercent(progress)
        end
        local txt_progress = layerLoading:getChildByName("txt_progress")
        txt_progress:setString(tostring(progress).."%")
    end
end

--默认更新进度条
function GameCommon:DefaultProgress()
    -- body
    local layerLoading = SCENENOW["scene"]:getChildByName("layout_loading")
    if layerLoading then
        local spLoading = layerLoading:getChildByName("loading_bar")
        if spLoading then
            local progress = 0
            local seq = cc.Sequence:create(cc.DelayTime:create(0.1),cc.CallFunc:create(function ( ... )
                -- body
                progress = progress + 9.8
                self:setLoadingProgress(progress)
            end))
            local rep = cc.Repeat:create(seq,10)
            spLoading:runAction(rep)
        end
    end
end

--兑换筹码界面
function GameCommon:showChange(flag,sef)
    -- body
    if SCENENOW["scene"] == nil then
        return
    end
    
    SCENENOW["scene"]=SCENENOW["scene"] or sef
    if flag == false then
        SCENENOW["scene"]:removeChildByName("layout_change")
        return
    end

    local layout = cc.CSLoader:createNode("hall/change/Change.csb"):addTo(SCENENOW["scene"],99999)
    layout:setName("layout_change")

    local btnClose=layout:getChildByName("Button_3")
    btnClose:onClick(function()
            layout:removeSelf();
        end)

    
    local tPanle=layout:getChildByName("creat_text_box_2")
    local txt_score = tPanle:getChildByName("txt_score")
    local txt_tax = layout:getChildByName("txt_tax")
    local txt_diamond = layout:getChildByName("txt_change_money")



    -- local btn_exit = layout:getChildByName("btn_exit")
    local btn_submit = layout:getChildByName("btn_submit")
    local slider_amount = layout:getChildByName("slider_amount")
    -- slider_amount:setMinimumValue(0)
    -- slider_amount:setMaximumValue(5)

    local nMinChip
    USER_INFO["group_chip"] = USER_INFO["group_chip"] or 1000
    -- print(USER_INFO["group_chip"],type(USER_INFO["group_chip"]),"USER_INFO[group_chip]")
    -- print(USER_INFO["gold"],type(USER_INFO["gold"]),"USER_INFO[gold]")
    USER_INFO["gold"] = tonumber(USER_INFO["gold"])--这个忽然变成了string类型，不知怎么回事，这里做强转
    if USER_INFO["group_chip"] > USER_INFO["gold"] then
        nMinChip = USER_INFO["group_chip"]
    else
        nMinChip = 0
    end
    local totalChips = (USER_INFO["gold"]-nMinChip)
    if totalChips > USER_INFO["group_chip"]*5 then
        totalChips = USER_INFO["group_chip"] * 5
    end
    print("showChange|| totalChips[%d]",totalChips)
    print("showChange || group_chip:"..USER_INFO["group_chip"])
    slider_amount:setPercent(0);
    tPanle:setPosition(230,310)--end 715
    txt_score:setString(0)

    local silderChips = math.modf(totalChips*slider_amount:getPercent()+nMinChip)
    if txt_tax then
        txt_tax:setString(tostring(silderChips*USER_INFO["group_cost_rate"]/100))
    end
    if txt_score then
        --txt_score:setString(self:formatGold(USER_INFO["gold"]))
    end
    if txt_diamond then
        txt_diamond:setString(--[[tostring(nMinChip)]]self:formatGold(USER_INFO["gold"]))
        -- txt_diamond:enableShadow(cc.c4b(0xff,0xff,0xff,255),cc.size(1,0))
    end

    local function touchEvent(sender,event)
        if event == TOUCH_EVENT_BEGAN then
            self:playEffectSound("res/audio/Audio_Button_Click.mp3")
        end
        if event == TOUCH_EVENT_ENDED then
            -- if sender == btn_exit then
            --     self:showChange(false)
            -- end
            if sender == btn_submit then
                self:changeChip(silderChips)
                self:showChange(false)
            end
        end
    end
    -- btn_exit:addTouchEventListener(touchEvent)
    btn_submit:addTouchEventListener(touchEvent)

    local function sliderChanged(sender,eventType)
        if eventType == ccui.SliderEventType.percentChanged then
            local amount = sender:getPercent()
            -- amount = math.modf(amount/20)*20
            for i=0,4 do
                if amount > (i*20) and amount < (i+1)*20 then
                    amount = (i+1)*20
                end
            end
            sender:setPercent(amount)
            print(amount)
            silderChips = math.modf(totalChips*amount/100 + nMinChip)
            -- if txt_diamond then
            --     txt_diamond:setString(tostring(silderChips))
            -- end
            if txt_tax then
                txt_tax:setString(tostring(silderChips*USER_INFO["group_cost_rate"]/100))
            end
            
            txt_score:setString(silderChips)
            tPanle:setPositionX(230+((715-230)/100)*amount)


        end
    end
    if slider_amount then
        slider_amount:setPercent(0)
        slider_amount:addEventListener(sliderChanged)
    end

        local layEffect = layout:getChildByName("Panel_1")
        if layEffect then
            layEffect:setTouchEnabled(true)
            layEffect:addTouchEventListener(function(sender,event)
                if event==2 then
                    if require("hall.common.GroupGame"):checkChips() then
                        self:showChange(false)
                    end
                end
            end)

        end
end

--请求兑换筹码
function GameCommon:changeChip(value)
    print("changeChip ===> add_chip[%d]",value)
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_CHANGE_CHIP)
    :setParameter("uid", UID)
    :setParameter("chip", value)
    :build()
    bm.server:send(pack)
end

--请求历史记录
function GameCommon:getHistory()
    --body
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_REQUEST_HISTORY)
    :setParameter("gameno", 0)
    :build()
    bm.server:send(pack)

    -- local gameno = 1
    -- local tbPlayers = {}
    -- table.insert(tbPlayers,{121,"zh",300,"",1})
    -- table.insert(tbPlayers,{4,"zh",300,"",0})
    -- table.insert(tbPlayers,{5,"zh",-600,"",1})
    -- self:addHistoryItem(gameno,tbPlayers)

    -- gameno = 2
    -- self:addHistoryItem(gameno,tbPlayers)

    -- gameno = 3
    -- self:addHistoryItem(gameno,tbPlayers)

    -- gameno = 4
    -- self:addHistoryItem(gameno,tbPlayers)

    -- self:showHistory(true)
end

--检查图片格式
function GameCommon:getUrlPicture(url)
    -- body
    if url == "" or url == nil then
        return ""
    end
    dump(url,"getUrlPicture")
    local strLower = string.lower(url)
    if string.find(strLower,".jpg") == nil and string.find(strLower,".png") == nil then
        return self:getUnformatPic(url)
    end
    local strUrl = string.reverse(url)
    local nPos = string.find(strUrl,"/")
    local strPic = string.sub(strUrl,1,nPos-1)
    strPic = string.reverse(strPic)
    print("getUrlPicture:",strPic)
    return strPic
end
--获取非格式化图片名称
function GameCommon:getUnformatPic(url)
    local strUrl = string.reverse(url)
    local nPos = string.find(strUrl,"/")
    strUrl = string.sub(strUrl,nPos+1,string.len(strUrl))
    nPos = string.find(strUrl,"/")
    local strPic = string.sub(strUrl,1,nPos-1)
    strPic = string.reverse(strPic)
    print("getUnformatPic:",strPic)
    return strPic..".jpg"
end
function GameCommon:setDefaultHead(head,uid,sex,size,isCircle)
    isCircle = isCircle or false
    local userid = math.abs(uid)
    print("setDefaultHead",userid)
    if sex == 0 then
        sex = sex + 1
    end
    if sex == 1 then--男
        local index = math.mod(userid,4) + 1
        print("setDefaultHead boy random:"..index,uid,userid)
        strIco = "hall/heads/boy-"..tostring(index)..".png"
    elseif sex == 2 then--女
        local index = math.mod(userid,7) + 1
        print("setDefaultHead girl random:"..index,uid,userid)
        strIco = "hall/heads/girl-"..tostring(index)..".png"
    end
    -- head:setTexture(strIco)
    if isCircle then
        self:setCirleHead(head, strIco, size, uid, sex, "", "")
    end
end

function GameCommon:setCirleHead(head, strIco, size, uid, sex, url, nick)
    
    local clipnode = cc.ClippingNode:create()
    clipnode:setInverted(false)
    clipnode:setAlphaThreshold(0)

    local stencil = cc.Node:create()
    clipnode:setStencil(stencil)

    local spStnecil = display.newSprite("hall/common/head_lord_man.png")
    spStnecil:setScale(size/spStnecil:getContentSize().width)
    stencil:addChild(spStnecil)

    local content = display.newSprite(strIco)
    content:setScaleX(size/content:getContentSize().width)
    content:setScaleY(size/content:getContentSize().height)
    clipnode:addChild(content)

    clipnode:setPosition(clipnode:getContentSize().width/2,clipnode:getContentSize().height/2)
    head:addChild(clipnode)

    head:setTexture("")

    local layerTouch = ccui.Layout:create()
    layerTouch:setAnchorPoint(cc.p(0.5,0.5))
    layerTouch:setTouchEnabled(true)
    layerTouch:addTouchEventListener(
        function(sender,event)
            if event == 2  then
                self:showPlayerInfoForGetHead(strIco,uid,sex,nick)
            end
    end)
    layerTouch:setContentSize(cc.size(size,size))
    head:addChild(layerTouch)

end

function GameCommon:getUserHead(url,uid,sex,sp,size,isCircle,nick)
    -- body
    isCircle = isCircle or false
    sex = sex or 0
    local file = nil
    local fileErr = nil
    local spHead = nil
    
    --链接空，载入默认头像
    local strHead = self:getUrlPicture(url)
    if strHead == nil or strHead == "" then
        self:setDefaultHead(sp,uid,sex,size,isCircle)
        return
    end
    sp:retain();
    --先在本地获取
    local imgFullPath = device.writablePath..strHead
    file,fileErr = io.open(imgFullPath)
    if fileErr == nil then

        spHead = display.newSprite(imgFullPath)
        cc.Director:getInstance():getTextureCache():reloadTexture(imgFullPath)

        if not isCircle then
            sp:loadTexture(imgFullPath)
            sp:setContentSize(cc.size(size,size))
            sp:setTouchEnabled(true)
            sp:addTouchEventListener(

                function(sender,event)

                    --触摸结束
                    if event == TOUCH_EVENT_ENDED then
                        self:showPlayerInfoForGetHead(imgFullPath,uid,sex,nick)
                    end

                end

            )

        else
            -- self:setCirleHead(sp,imgFullPath,size)
            self:setCirleHead(sp, imgFullPath, size, uid, sex, url, nick)
        end

    else

        local function onRequestFinished(event,filename)
            -- body    
            local ok = (event.name == "completed")
            print("onRequestFinished")
            local request = event.request
            if not ok then
                -- 请求失败，显示错误代码和错误消息
                print(request:getErrorCode(), request:getErrorMessage())
                return
            end

            local code = request:getResponseStatusCode()
            if code ~= 200 then
                -- 请求结束，但没有返回 200 响应代码
                print(code)
                return
            end

            -- 请求成功，显示服务端返回的内容
            local response = request:getResponseString()
            print(response)
            
            --保存下载数据到本地文件，如果不成功，重试30次。
            local times = 1
            print("savedata:"..filename)
            while (not request:saveResponseData(filename)) and times < 30 do
                times = times + 1
            end
            local isOvertime = (times == 30) --是否超时

            cc.Director:getInstance():getTextureCache():reloadTexture(imgFullPath)
        
                if not isCircle then
                    sp:loadTexture(imgFullPath)
                    sp:setContentSize(cc.size(size,size))
                    sp:setTouchEnabled(true)
                    sp:addTouchEventListener(

                        function(sender,event)

                            --触摸结束
                            if event == TOUCH_EVENT_ENDED then
                                self:showPlayerInfoForGetHead(imgFullPath,uid,sex,nick)
                            end

                        end

                    )

                else
                    -- self:setCirleHead(sp,imgFullPath,size)
                    self:setCirleHead(sp, imgFullPath, size, uid, sex, url, nick)
                end
    
        end

        local request = network.createHTTPRequest(function (event)
            -- body
            if event.name == "completed" then
                onRequestFinished(event,imgFullPath)
            end
        end,url,"GET")
        request:start()

    end
end

function GameCommon:setDefaultPlayerHead(head,user_info,size)
    isCircle = isCircle or false
    local userid = math.abs(user_info["uid"])
    if user_info["sex"] == 0 then
        user_info["sex"] = user_info["sex"] + 1
    end
    local strIco = ""
    if user_info["sex"] == 1 or user_info["sex"] == "1" then--男
        local index = math.mod(userid,4) + 1
        print("setDefaultPlayerHead 1",tostring(sex),tostring(index))
        strIco = "hall/heads/boy-"..tostring(index)..".png"
    elseif user_info["sex"] == 2 or user_info["sex"] == "2" then--女
        local index = math.mod(userid,7) + 1
        print("setDefaultPlayerHead 2",tostring(sex),tostring(index))
        strIco = "hall/heads/girl-"..tostring(index)..".png"
    end
    -- head:setTexture(strIco)
    user_info["icon_url"] = strIco
    dump(user_info, "setDefaultPlayerHead", nesting)
    print("setDefaultPlayerHead 3",tostring(user_info["sex"]),tostring(user_info["icon_url"]))
    self:setHead(head,user_info,size)
end

function GameCommon:setHead(head,user_info,size,touchabled)
    if head == nil then
        return
    end

    head:setTexture("")
    
    if head:getChildByName("head_img") then
        head:getChildByName("head_img"):removeSelf()
    end
    if head:getChildByName("head_touch") then
        head:getChildByName("head_touch"):removeSelf()
    end
    -- if head:getChildByName("head_vip") then
    --     head:getChildByName("head_vip"):removeSelf()
    -- end

    local show_info = touchabled or 1
    local clipnode = cc.ClippingNode:create()
    clipnode:setInverted(false)
    clipnode:setAlphaThreshold(0)

    local stencil = cc.Node:create()
    clipnode:setStencil(stencil)
    local spStnecil = display.newSprite("hall/common/head_box2.png")
    spStnecil:setScale(size/spStnecil:getContentSize().width)
    stencil:addChild(spStnecil)

    local content = display.newSprite(user_info["icon_url"])
    content:setScaleX(size/content:getContentSize().width)
    content:setScaleY(size/content:getContentSize().height)
    clipnode:addChild(content)

    clipnode:setPosition(clipnode:getContentSize().width/2,clipnode:getContentSize().height/2)
    head:addChild(clipnode)
    head:setScale(1)
    clipnode:setName("head_img")

    local layerTouch = ccui.Layout:create()
    layerTouch:setAnchorPoint(cc.p(0.5,0.5))

    local spHeadMask = display.newSprite("hall/common/head_box1.png")
    spHeadMask:setAnchorPoint(cc.p(0.5,0.5))
    local s = size/(spHeadMask:getContentSize().width-20)
    spHeadMask:setScale(s)
    
    spHeadMask:setPosition(spHeadMask:getContentSize().width/2, spHeadMask:getContentSize().height/2)
  
    layerTouch:addChild(spHeadMask)
    -- layerTouch:ssize(spHeadMask:getWidth(),spHeadMask:getHeight())

    if show_info == 1 then
        layerTouch:setTouchEnabled(true)
        layerTouch:addTouchEventListener(function(sender,event)
                if event == 2  then
                    print("head touch")
                    self:showPlayerInfo(user_info)
                end
            end)
    end
    layerTouch:setContentSize(spHeadMask:getContentSize())
    --layerTouch:setPosition(head:getPositionX(), head:getPositionY())
    clipnode:setName("head_touch")
    head:addChild(layerTouch)

    print(head:getName(),tolua.type(head),"shishishishishishi")
    head:setTexture("")
end

function GameCommon:setPlayerHead(user_info,sp,size)
    -- body
    local file = nil
    local fileErr = nil
    local spHead = nil
    --链接空，载入默认头像
    sp:retain();

    local strHead = self:getUrlPicture(user_info["icon_url"])
    if strHead == nil or strHead == "" then
        self:setDefaultPlayerHead(sp,user_info,size)
        return
    end
    --先在本地获取
    local imgFullPath = device.writablePath..strHead
    file,fileErr = io.open(imgFullPath)
    if fileErr == nil then
        spHead = display.newSprite(imgFullPath)
        cc.Director:getInstance():getTextureCache():reloadTexture(imgFullPath)
       -- sp:performWithDelay(function()
            user_info["icon_url"] = imgFullPath
            self:setHead(sp,user_info,size)
        --end, 0.1)
        print("load local png",imgFullPath)
    else
        local function onRequestFinished(event,filename)
            -- body    
            local ok = (event.name == "completed")
            print("onRequestFinished")
            local request = event.request
            if not ok then
                -- 请求失败，显示错误代码和错误消息
                print(request:getErrorCode(), request:getErrorMessage())
                return
            end

            local code = request:getResponseStatusCode()
            if code ~= 200 then
                -- 请求结束，但没有返回 200 响应代码
                print(code)
                return
            end


            -- 请求成功，显示服务端返回的内容
            local response = request:getResponseString()
            print(response)
            
            --保存下载数据到本地文件，如果不成功，重试30次。
            local times = 1
            print("savedata:"..filename)
            while (not request:saveResponseData(filename)) and times < 30 do
                times = times + 1
            end
            local isOvertime = (times == 30) --是否超时

            cc.Director:getInstance():getTextureCache():reloadTexture(imgFullPath)
            --sp:performWithDelay(function()
                user_info["icon_url"] = imgFullPath
                self:setHead(sp,user_info,size)
            --end, 0.1)
        end

        local request = network.createHTTPRequest(function (event)
            -- body
            if event.name == "completed" then
                onRequestFinished(event,imgFullPath)
            end
        end,user_info["icon_url"],"GET")
        request:start()
    end
end
--显示历史记录
function GameCommon:showHistory(flag)
    -- body
    print("GameCommon:showHistory:"..tostring(flag))
    local layHistory = SCENENOW["scene"]:getChildByName("layerHistory")
    if layHistory == nil then
        layHistory = cc.CSLoader:createNode("hall/group/history/history.csb"):addTo(SCENENOW["scene"])
        layHistory:setName("layerHistory")
        local Panel_10 = layHistory:getChildByName("Panel_10")
        if Panel_10 then
            Panel_10:addTouchEventListener(function(sender,event)
                if event==2 then
                    self:showHistory(false)
                end
            end)
        end
        local btn_exit = layHistory:getChildByName("btn_exit")
        if btn_exit then
            btn_exit:addTouchEventListener(function(sender,event)
                if event==2 then
                    self:showHistory(false)
                end
            end)
        end
    end
    if flag == false then
        if layHistory then
            SCENENOW["scene"]:removeChildByName("layerHistory")
        end
        return
    end
end
--历史项目
function GameCommon:addHistoryItem(gameNo,playerlist,scale)
    -- body k["Userid"],k["nick"],k["win"],k["icon"],k["sex"]
    scale = scale or 1
    table.sort( playerlist, function(a,b)
        local at = a[1]
        local bt = b[1]

        return at<bt
    end )
    local layHistory = SCENENOW["scene"]:getChildByName("layerHistory")
    if layHistory == nil then
        layHistory = cc.CSLoader:createNode("hall/group/history/history.csb"):addTo(SCENENOW["scene"])
        layHistory:setName("layerHistory")
        local Panel_10 = layHistory:getChildByName("Panel_10")
        if Panel_10 then
            Panel_10:addTouchEventListener(function(sender,event)
                if event==2 then
                    self:showHistory(false)
                end
            end)
        end
        local btn_exit = layHistory:getChildByName("btn_exit")
        if btn_exit then
            btn_exit:addTouchEventListener(function(sender,event)
                if event==2 then
                    self:showHistory(false)
                end
            end)
        end
    end
    local lsHistory = layHistory:getChildByName("lv_history")
    local itemCount = 2
    local sizeWidth = 550
    local sizeHeight = 280
    local headWidth = 40
    local itemWidth = (sizeWidth-headWidth)/3
    local itemHeight = sizeHeight/itemCount

    local  layer = ccui.Layout:create()
    layer:setContentSize(cc.size(550,sizeHeight/2))
    layer:setScale(scale)
    --分割线
    local spLine = display.newSprite("hall/group/count_line.png")
    layer:addChild(spLine)
    spLine:setPosition(cc.p(sizeWidth/2,spLine:getContentSize().height/2 - 10))

    --局数
    local lbTitle = cc.Label:createWithBMFont("hall/group/history/history_num.fnt",tostring(gameNo))
    layer:addChild(lbTitle)
    lbTitle:setPosition(cc.p(headWidth/2,itemHeight/2))

    --先画头像
    local x = 0
    local y = 0
    for i,v in pairs(playerlist) do
        x = headWidth + (i-1)*itemWidth + itemWidth/2
        y = itemHeight - itemHeight/2 + 35
        local spHead = display.newSprite()
        layer:addChild(spHead)
        self:getUserHead(v[4],v[1],v[5],spHead,70,true)
        spHead:setPosition(x,y)
        --光圈
        local spHeadMask = display.newSprite("hall/common/touxiangkuang_07.png")
        layer:addChild(spHeadMask)
        spHeadMask:setPosition(x, y)
        local s = 70/spHeadMask:getContentSize().width + 0.1
        spHeadMask:setScale(s)
    end

    for i,v in pairs(playerlist) do

        x = headWidth + (i-1)*itemWidth + itemWidth/2
        y = itemHeight/4 + 20

        --昵称
        local lbNick = cc.Label:createWithTTF(v[2],"res/fonts/fzcy.ttf",26)
        lbNick:setColor(cc.c3b(0x27,0x8f,0xe6))
        layer:addChild(lbNick)
        lbNick:setPosition(x,y)

        local str = nil
        if v[3] > 0 then
            str = "+"..tostring(v[3])
        else
            str = tostring(v[3])
        end

        local spback = display.newSprite("hall/hall/main_gold_box.png")
        spback:setScale(0.8)

        local spChip = display.newSprite("hall/common/game_chip.png")
        spChip:setScale(0.5)
        spback:addChild(spChip)
        spChip:setPosition(20, spback:getContentSize().height/2)
        -- spChip:setPosition(spChip:getContentSize().width/2*0.4 - spback:getContentSize().width*0.8, spback:getContentSize().height/2)

        local lbWin = cc.Label:createWithTTF(v[2],"res/fonts/fzcy.ttf",26)
        lbWin:setString(str)
        if v[3] > 0 then
            lbWin:setColor(cc.c3b(0,255,0))
        else
            lbWin:setColor(cc.c3b(255,0,0))
        end
        spback:addChild(lbWin)
        lbWin:setPosition(spback:getContentSize().width/2,spback:getContentSize().height/2)

        layer:addChild(spback)
        spback:setPosition(x, spback:getContentSize().height/2 + 10)

    end
    lsHistory:insertCustomItem(layer, 0)
end

--推出组局
function GameCommon:gExitGroupGame(gameId)
    
    --断开连接
    -- if tolua.isnull(SCENENOW["scene"]) == false then
    --     SCENENOW["scene"]:removeSelf()
    -- end
    -- SCENENOW["scene"]=nil;
    -- SCENENOW["name"]=""
    -- bm.server:disconnect()
    audio.stopMusic()
    audio.stopAllSounds()
    -- print("gExitGroupGame")
    --退出直播
    bm.isGroup = false

    require("hall.VoiceRecord.VoiceRecordView"):removeView()

    require("app.HallUpdate"):enterHall()
    
    -- require("ddz.PlayVideo"):setExit()
    -- require("ddz.PlayVideo"):stopVideo()
    -- local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
    --                   scheduler.performWithDelayGlobal(function()
    --                       --返回大厅界面
    --                     require("app.HallUpdate"):enterHall()
    --                   end, 5)


    -- if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
    --     cc.Director:getInstance():endToLua()
        
    -- --      cc.Director:getInstance():purgeCachedData();
    -- --     --cc.Director:getInstance():endToLua();
    -- --     collectgarbage("collect")
    -- --     local args = {gameId}
    -- --     local sigs = "(I)I"
    -- --     local luaj = require "cocos.cocos2d.luaj"
    -- --     local className = luaJniClass
    -- --     local ok,ret  = luaj.callStaticMethod(className,"exitGroupGame",args,sigs)
    -- --     if not ok then
    -- --         print("exitGroupGame luaj error:", ret)
    -- --     else
    -- --         print("exitGroupGame PLATFORM_OS_ANDROID")
    -- --     end
    -- elseif (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) or (cc.PLATFORM_OS_MAC == targetPlatform) then
    --     require("app.HallUpdate"):enterHall()
    --     -- require("hall.GameSetting"):applyChangeUser()
    -- --     local args = {num1 = gameId}
    -- --     local luaoc = require "cocos.cocos2d.luaoc"
    -- --     local className = "CocosCaller"
    -- --     local ok,ret  = luaoc.callStaticMethod(className,"exitGroupGame",args)
    -- --     if not ok then
    -- --         cc.Director:getInstance():resume()
    -- --         print("exitGame PLATFORM_OS_IPHONE failed")
    -- --     else
    -- --         print("exitGame PLATFORM_OS_IPHONE")
    -- --     end
    -- --     display.replaceScene(display.newScene("null"))
    -- -- else
    -- --     print("go back to hall")
    -- --     --·µ»Ø´óÌü
    -- --    display_scene("hall.hallScene",1)
    -- else
    --     require("app.HallUpdate"):enterHall()
    -- end
end
--推出大厅
function GameCommon:gExitGame()
    --断开连接
    print("GameCommon:gExitGame-------------------------")

    -- SCENENOW["scene"]:removeSelf()
    -- SCENENOW["scene"]=nil;
    -- SCENENOW["name"]=""
    -- bm.server:disconnect()
    audio.stopMusic()
    audio.stopAllSounds()
    if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
        require("hall.GameSetting"):applyChangeUser()
    --     cc.Director:getInstance():purgeCachedData();
    --     --cc.Director:getInstance():endToLua();
    --     local luaj = require "cocos.cocos2d.luaj"
    --     local className =luaJniClass
      
    --     local ok,ret  = luaj.callStaticMethod(className,"exitGame")
    --     if not ok then
    --         print("exitGame luaj error:", ret)
    --     else
    --         print("exitGame PLATFORM_OS_ANDROID")
    --     end
    elseif (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) or (cc.PLATFORM_OS_MAC == targetPlatform) then
        require("hall.GameSetting"):applyChangeUser()
    --     local args = {}
    --     local luaoc = require "cocos.cocos2d.luaoc"
    --     local className = "CocosCaller"
    --     local ok,ret  = luaoc.callStaticMethod(className,"exitGame")
    --     if not ok then
    --         cc.Director:getInstance():resume()
    --         print("exitGame PLATFORM_OS_IPHONE failed")
    --     else
    --         print("exitGame PLATFORM_OS_IPHONE")
    --     end
    else
        cc.Director:getInstance():endToLua()
    end


    -- display.replaceScene(display.newScene("null"))

end
--³äÖµ
function GameCommon:gRecharge()
    local market = require("hall.market").new()
    SCENENOW["scene"]:addChild(market)
    market:setName("market")
end

--格式化金币
function GameCommon:formatGold(gold)
    if not gold then
        printError("error formatGold gold is null")
    end
     gold = tonumber(gold)
    -- return gold
    if( gold < 10000) then
        return gold
    -- elseif gold >=1000 and  gold< 10000 then
    --     local k = getIntPart(gold/1000)
    --     local lest = gold%1000
    --     if lest < 100 then 
    --         lest = '0'..lest
    --     elseif lest < 10 then
    --         lest = '00'..lest
    --     end
    --     return k.."."..lest.."k"
    -- elseif  gold>=10000 and gold< 100000000 then
    else
        local w = math.modf(gold/10000)
        local lest = math.modf(gold%10000/1000)

        return w.."."..lest.."w"
    -- else
    --     local w    = math.modf(gold/100000000)
    --     local lest = math.modf(gold%100000000/10000000)

    --     return w.."."..lest.."b"
    end
end

--格式化系统字体金币
function GameCommon:formatGoldSys(gold)
    if not gold then
        printError("error formatGold gold is null")
    end
     gold = tonumber(gold)
    -- return gold
    if( gold < 10000) then
        return gold
    else
        local w = math.modf(gold/10000)
        local lest = math.modf(gold%10000/1000)

        return w.."万"
    end
end
--格式化昵称
function GameCommon:formatNick(str,len)
    -- body
    local width = 0
    local size = len or 4
    local char_count = 0
    local pos = 1
    local lenInByte = #str

    if lenInByte < 10 then
        return str
    else
        local nick = ""
        for i=1,lenInByte do
            local curByte = string.byte(str, pos)
            if curByte == nil then
                return nick
            end
            local byteCount = 1;
            if curByte>0 and curByte<=127 then
                byteCount = 1
            elseif curByte>=192 and curByte<223 then
                byteCount = 2
            elseif curByte>=224 and curByte<239 then
                byteCount = 3
            elseif curByte>=240 and curByte<=247 then
                byteCount = 4
            end

            print("formatNick", tostring(i), tostring(curByte))
            local char = string.sub(str, pos, pos+byteCount-1)
            nick = nick .. char
            char_count = char_count + 1
            pos = pos + byteCount
            if char_count >= size then
                return nick .. "..."
            end
        end
    end

end

--自动裁剪label内容
function GameCommon:formatLabelStr(str, lb, maxWidth)
    lb:setString("a")
    local widthByByte = lb:getContentSize().width
    dump(maxWidth, "maxWidth")
    dump(widthByByte, "widthByByte")

    local totalBytes = maxWidth / widthByByte - 3

    if totalBytes <= 0 then
        --todo
        lb:setString("...")
        return
    end

    local length = string.len(str)

    local tBytes = 0
    local dealStr = ""
    local isOver = false
    for i=1,length do
        local b = string.byte(str, i)

        if b > 255 then
            --todo
            if tBytes + 2 > totalBytes then
                --todo
                if i == 1 then
                    --todo
                    isOver = true
                    break
                else
                    dealStr = string.sub(str, 1, i - 1)
                    isOver = true
                    break
                end
            elseif tBytes + 2 == totalBytes then
                dealStr = string.sub(str, 1, i)
                if i ~= length then
                    --todo
                    isOver = true
                end
                break
            else
                tBytes = tBytes + 2
            end
        else
            if tBytes + 1 > totalBytes then
                --todo
                if i == 1 then
                    --todo
                    isOver = true
                    break
                else
                    dealStr = string.sub(str, 1, i - 1)
                    isOver = true
                    break
                end
            elseif tBytes + 1 == totalBytes then
                dealStr = string.sub(str, 1, i)
                if i ~= length then
                    --todo
                    isOver = true
                end
                break
            else
                tBytes = tBytes + 1
            end
        end
    end

    if not isOver then
        --todo
        lb:setString(str)
    else
        lb:setString(dealStr .. "...")
    end

    
end

--获取svid
function GameCommon:getSvid(tid)
    -- body
    local id = bit.brshift(tid,16)
    return id
end

--播放游戏音效
function GameCommon:playEffectSound(filename,flag)
    print("GameCommon:playEffectSound", tostring(SOUND_ON))
    if  SOUND_ON == true then
        local bRepeat = true
        if flag then
            bRepeat = flag
        else
            bRepeat = false
        end
        -- cc.SimpleAudioEngine:getInstance():setEffectsVolume(0.5)
        dump(cc.SimpleAudioEngine:getInstance():getEffectsVolume(), "effect volume --")
        -- cc.SimpleAudioEngine:getInstance():playEffect(filename,bRepeat)
        require("hall.VoiceUtil"):playEffect(filename,bRepeat)
    end
end

--播放游戏音效
function GameCommon:playEffectMusic(filename,flag)
    if  MUSIC_ON == true then
        local bRepeat = true
        if flag then
            bRepeat = flag
        else
            bRepeat = false
        end
        cc.SimpleAudioEngine:getInstance():playMusic(filename,bRepeat)
        
    end
end

--显示数字
function GameCommon:showNums(num,color,isBack)
    -- body
    -- display.addSpriteFrames("hall/nums.plist", "hall/nums.png")
    isBack = isBack or false
    -- print("showNums:"..tostring(num))
    local spLayer = cc.Layer:create()
    num = num or 0
    local str = tostring(num)
    local len = string.len(num)
    local x = 0
    local y = 0
    local width = 0
    local height = 0
    if len < 1 then
        return nil
    end
    if isBack then
        if len == 1 then
            local left = display.newSprite("hall/no/num_bg_left.png"):addTo(spLayer)
            x = x + left:getContentSize().width/2
            width = width + left:getContentSize().width
            height = left:getContentSize().height
            left:setPosition(cc.p(x,y))
            x = x + left:getContentSize().width/2
            local right = display.newSprite("hall/no/num_bg_right.png"):addTo(spLayer)
            x = x + right:getContentSize().width/2
            width = width + right:getContentSize().width
            right:setPosition(cc.p(x,y))
            x = x + right:getContentSize().width/2
            local txt = self:getNum(str,color)
            txt:setScale(0.8)
            right:addChild(txt)
            txt:setPosition(cc.p(right:getContentSize().width/2,right:getContentSize().height/2))
            spLayer:setContentSize(cc.size(width,height))
        else
            for i=1,len do
                -- print(string.byte(str,i))
                local ch = string.char(string.byte(str,i))
                    if i == 1 then
                        local left = display.newSprite("hall/no/num_bg_left.png"):addTo(spLayer)
                        x = x + left:getContentSize().width/2
                        width = width + left:getContentSize().width
                        height = left:getContentSize().height
                        left:setPosition(cc.p(x,y))
                        x = x + left:getContentSize().width/2
                        local txt = self:getNum(ch,color)
                        txt:setScale(0.8)
                        left:addChild(txt)
                        txt:setPosition(cc.p(left:getContentSize().width/2,left:getContentSize().height/2))
                        spLayer:setContentSize(cc.size(width,height))
                    elseif i == len then
                        local right = display.newSprite("hall/no/num_bg_right.png"):addTo(spLayer)
                        x = x + right:getContentSize().width/2
                        width = width + right:getContentSize().width
                        right:setPosition(cc.p(x,y))
                        x = x + right:getContentSize().width/2
                        local txt = self:getNum(ch,color)
                        txt:setScale(0.8)
                        right:addChild(txt)
                        txt:setPosition(cc.p(right:getContentSize().width/2,right:getContentSize().height/2))
                        spLayer:setContentSize(cc.size(width,height))
                    else
                        local center = display.newSprite("hall/no/num_bg_center.png"):addTo(spLayer)
                        x = x + center:getContentSize().width/2
                        width = width + center:getContentSize().width
                        center:setPosition(cc.p(x,y))
                        x = x + center:getContentSize().width/2
                        local txt = self:getNum(ch,color)
                        txt:setScale(0.8)
                        center:addChild(txt)
                        txt:setPosition(cc.p(center:getContentSize().width/2,center:getContentSize().height/2))
                        spLayer:setContentSize(cc.size(width,height))
                    end
            end
        end
    else
        for i=1,len do
            -- print(string.byte(str,i))
            local ch = string.char(string.byte(str,i))
            local txt = self:getNum(ch,color)
            spLayer:addChild(txt)
            -- x = x - txt:getContentSize().width/2
            -- print("showNums x:"..tostring(x))
            txt:setPosition(cc.p(x,y))
            x = x + txt:getContentSize().width
            width = width + txt:getContentSize().width
            spLayer:setContentSize(cc.size(width,height))
        end
    end
    -- spLayer:setCascadeColorEnabled(true)
    spLayer:setCascadeOpacityEnabled(true)
    return spLayer
end
function GameCommon:getNum(str,color)
    -- body
    -- local spLayer = cc.Layer:create()
    color = color or cc.c3b(125,125,125)
    -- print("getNum:"..str)
    local spBack = display.newSprite("hall/no/mask"..str..".png")
    spBack:setColor(color)
    local spNum = display.newSprite("hall/no/"..str..".png")
    spBack:addChild(spNum)
    spNum:setPosition(cc.p(spBack:getContentSize().width/2,spBack:getContentSize().height/2))
    spBack:setCascadeOpacityEnabled(true)
    return spBack
end

--设置头像
function GameCommon:setUserHead(head_info)
    -- body
    -- local spHead = display.newSprite(file)

    if head_info["sp"] == nil then
        return
    end
    if head_info["sp"]:getChildByName("head_img") then
        head_info["sp"]:getChildByName("head_img"):removeSelf()
    end
    if head_info["sp"]:getChildByName("head_touch") then
        head_info["sp"]:getChildByName("head_touch"):removeSelf()
    end
    if head_info["sp"]:getChildByName("head_vip") then
        head_info["sp"]:getChildByName("head_vip"):removeSelf()
    end
    local show_info = head_info["touchable"] or 0
    local size = head_info["size"] or 80
    local clipnode = nil
    if head_info["use_sharp"] and head_info["use_sharp"] == 1 then
        clipnode = cc.ClippingNode:create()
        clipnode:setInverted(false)
        clipnode:setAlphaThreshold(0)

        local stencil = cc.Node:create()
        clipnode:setStencil(stencil)
        local spStnecil = display.newSprite("hall/common/head_box2.png")
        spStnecil:setScale(size/spStnecil:getContentSize().width)
        stencil:addChild(spStnecil)

        local content = display.newSprite(head_info["url"])
        content:setScaleX(size/content:getContentSize().width)
        content:setScaleY(size/content:getContentSize().height)
        clipnode:addChild(content)

        clipnode:setPosition(clipnode:getContentSize().width/2,clipnode:getContentSize().height/2)
    else
        clipnode = display.newSprite(head_info["url"])
        clipnode:setScaleX(size/clipnode:getContentSize().width)
        clipnode:setScaleY(size/clipnode:getContentSize().height)
    end
    clipnode:setName("head_img")
    head_info["sp"]:addChild(clipnode)

    local layerTouch = ccui.Layout:create()
    layerTouch:setAnchorPoint(cc.p(0.5,0.5))
    layerTouch:setName("head_touch")

    local spHeadMask = display.newSprite("hall/common/head_box1.png")
    local s = size/(spHeadMask:getContentSize().width-25)
    spHeadMask:setScale(s)
    spHeadMask:setAnchorPoint(cc.p(0.5,0.5))
    spHeadMask:setPosition(spHeadMask:getContentSize().width/2, spHeadMask:getContentSize().height/2)
    layerTouch:addChild(spHeadMask)

    if show_info == 1 then
        layerTouch:setTouchEnabled(true)
        layerTouch:addTouchEventListener(function(sender,event)
                if event == 2  then
                    print("head touch")
                    self:showPlayerInfo(head_info["uid"])
                    --require("hall.GameTips"):showTips("玩家详情")
                end
            end)
    end
    layerTouch:setContentSize(spHeadMask:getContentSize())
    layerTouch:setPosition(clipnode:getPosition())
    head_info["sp"]:addChild(layerTouch)

    -- if head_info["vip"] then
    --     local sp_vip = display.newSprite("hall/common/main_vip_tb01.png")
    --     sp_vip:setPosition(-size/2+10,-size/2+10)
    --     head_info["sp"]:addChild(sp_vip)
    --     sp_vip:setName("head_vip")
    -- end

    head_info["sp"]:setTexture("")
end

--玩家详情
function GameCommon:showPlayerInfo(user_info)

    dump(user_info, "-----showPlayerInfo-----")

    local userInfo = {}
    userInfo["isShowInGame"] = bm.isInGame
    userInfo["nickName"] = tostring(user_info.uid)
    userInfo["uid"] = user_info.uid
    userInfo["location_arr"] = {}

    require("hall.view.userInfoView.userInfoView"):showView(user_info.icon_url, userInfo)

end

--玩家详情(新)
function GameCommon:showPlayerInfoForGetHead(icon_url, uid, sex_num, nick)

    dump(icon_url, "-----玩家详情(新)-----")
    dump(uid, "-----玩家详情(新)-----")
    dump(sex_num, "-----玩家详情(新)-----")

    if nick == nil then
        nick = uid
    end

    local userInfo = {}
    userInfo["isShowInGame"] = bm.isInGame
    userInfo["nickName"] = nick
    userInfo["uid"] = uid
    userInfo["location_arr"] = {}

    require("hall.view.userInfoView.userInfoView"):showView(icon_url, userInfo)
end

return GameCommon
