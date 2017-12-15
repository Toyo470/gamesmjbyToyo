
local listGame = {}

local gameUpdating = 0
local Market = require("hall.market")
local Signin_layer = require("hall.signin_monthcard")
local gameScene = class("gameScene", function()
    return display.newScene("gameScene")
end)

local game_scroll

function gameScene:ctor()

    -- isShowNetLog = false

    -- showDumpData = false

    bm.isInGame = false
  
    local s
    if device.platform == "ios" then
        if isiOSVerify then
            s = cc.CSLoader:createNode("hall/room_789Game.csb"):addTo(self)
        else
            s = cc.CSLoader:createNode(cc.FileUtils:getInstance():getWritablePath() .. "hall/room_789Game.csb"):addTo(self)
        end
    else
        s = cc.CSLoader:createNode("hall/room_789Game.csb"):addTo(self)
    end
    
    self._scene = s

    local top_base = self._scene:getChildByName("top_base")
    local btn_setting = top_base:getChildByName("btn_setting")
    local btn_add_score = top_base:getChildByName("btn_coins")
    -- local btn_score = top_base:getChildByName("btn_score")
    local add_9_gold = btn_add_score:getChildByName("add_9")
    local txt_score = btn_add_score:getChildByName("txt_score")

    local btn_share = top_base:getChildByName("btn_share")
    local btn_message = top_base:getChildByName("btn_message")
    local btn_help = top_base:getChildByName("btn_help")
    local btn_record = top_base:getChildByName("btn_record")
    local btn_kefu = top_base:getChildByName("btn_kefu")

    local room_plane = self._scene:getChildByName("room_plane") --创建-加入房间页

    local btn_create = room_plane:getChildByName("btn_create")

    
    if bm.notCheckReload == 1 then
        btn_create:loadTextures("hall/hall_01/hall_back_tb.png", nil, nil)
    else
        btn_create:loadTextures("hall/hall_01/hall_creat_tb.png", nil, nil)
    end

    local btn_join = room_plane:getChildByName("btn_join")


    local drawer_ly = self._scene:getChildByName("drawer_ly") --更多游戏
    drawer_ly:setVisible(true)
  
  

    room_plane:setVisible(true)
    if isiOSVerify then
        btn_add_score:setVisible(false)
        btn_share:setVisible(false)
        btn_kefu:setVisible(false)
        drawer_ly:setVisible(false)
    end

	audio.playMusic("hall/bgm.mp3",true)

    local params = {}
    params["userId"] = USER_INFO["uid"]
    params["interfaceType"] = "J"

    -- dump(USER_INFO["cardCount"], "-----gameScene cardCount 1-----")
    -- txt_score:setString(USER_INFO["cardCount"] .. "")

    cct.createHttRq({
        url=HttpAddr .. "/roomCard/queryRoomCardCount",
        date= params,
        type_="POST",
        callBack = function(data)
            dump(data, "-----查询房卡数量-----")
            data_netData = json.decode(data["netData"])
            if data_netData.returnCode == "0" then
                --todo
                local sData = data_netData.data
                dump(data["netData"], "fangka test 1")
                dump(sData, "fangka test 2")
                if sData ~= nil then

                    --todo
                    USER_INFO["cardCount"] = sData

                    dump(USER_INFO["cardCount"], "-----gameScene cardCount 2-----")

                    if tolua.isnull(txt_score) then
                        return 
                    end

                    txt_score:setString(sData .. "")

                end
            end
                        
        end
    })

    local code = require("hall.hall_data"):getGameCode()

    --按钮事件
    local function touchEvent(sender, event)
        if event == TOUCH_EVENT_BEGAN then
            if sender ~= btn_add_score then 
                -- sender:setScale(0.9)
            end
        end
        if event == TOUCH_EVENT_CANCELED then
            -- sender:setScale(1.0)
        end

        if event == TOUCH_EVENT_ENDED then
            -- sender:setScale(1.0)
            print("exit game")
            require("hall.GameCommon"):playEffectSound("hall/Audio_Button_Click.mp3")


            if sender == btn_setting then
                require("hall.GameCommon"):showSettings(true,true)
                
                --test  run majiang
               -- display_scene("xlsg.gameScene")

            elseif sender == btn_add_score or add_9_gold == sender then 
                --充值
                local params = {}
                params["type"] = "1"
                cct.createHttRq({
                    url=HttpAddr .. "/baseData/queryAnnouncements",
                    date= params,
                    type_="POST",
                    callBack = function(data)
                        dump(data, "fangka test")
                        data_netData = json.decode(data["netData"])
                        dump(data_netData, "-----查询购买房卡信息-----")
                        if data_netData.returnCode == "0" then
                            --todo
                            local sData = data_netData.data
                            dump(data["netData"], "-----查询购买房卡信息-----")
                            dump(sData, "-----查询购买房卡信息-----")
                            if table.getn(sData) > 0 then
                                --todo
                                if table.getn(sData[1]) > 0 then
                                    --todo
                                    require("hall.GameCommon"):showAlert(true, sData[1][1]["content"], 300)

                                    -- require("hall.GameCommon"):showHtmlAlert(true, sData[1][1]["content"], 300)
                                    
                                end
                            end
                        end
                        
                    end
                })
            elseif sender == btn_join then

                if bm.notCheckReload == 1 then
                    require("hall.GameTips"):showTips("提示", "", 3, "你当前有未结束的组局，不能加入其他房间")

                else
                    require("hall.group.GroupSetting"):enterRoom()

                end
           
            elseif sender == btn_create then 
                --创建组局(创建房间、返回房间)

                if bm.notCheckReload == 1 then
                    dump("返回房间", "-----检查是否有存在组局-----")

                    cct.createHttRq({
                    url=HttpAddr .. "/viewReganizeHistory",
                    date={
                        userId = USER_INFO["uid"]
                    },
                    type_= "POST",
                    callBack = function(data)
                        
                        local data_netData = data.netData

                        if data_netData == nil then

                            bm.notCheckReload = 0
                            btn_create:loadTextures("hall/hall_01/hall_creat_tb.png", nil, nil)

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
                        if #tbHistory == 0 then

                            bm.notCheckReload = 0
                            btn_create:loadTextures("hall/hall_01/hall_creat_tb.png", nil, nil)

                            return

                        end

                        --有未结束组局，进入最后一次加入的未结束组局
                        for k, v in pairs(tbHistory) do
                            if k == 1 then
                                require("hall.groudgamemanager"):join_freegame(USER_INFO["uid"], v["inviteCode"], v["activityId"], true, v["level"], true)
                                return
                            end
                        end

                    end
                })

                -- else
                    -- require("hall.group.create.group_create_mj"):CreateScene()

                end


            elseif sender == btn_share then 

                --分享
                require("hall.common.ShareLayer"):showShareLayerInHall("【789广东麻将】", "http://gametest2017.oss-cn-shenzhen.aliyuncs.com/download/index.html", "url", "全国人民都爱玩的棋牌游戏，简单好玩，随时随地组局，亲们快快加入吧！猛戳下载！")
            
            elseif sender == btn_message then 
                
                --消息
                local params = {}
                params["type"] = "3"
                cct.createHttRq({
                    url=HttpAddr .. "/baseData/queryAnnouncements",
                    date= params,
                    type_="POST",
                    callBack = function(data)
                        dump(data, "fangka test")
                        data_netData = json.decode(data["netData"])
                        if data_netData.returnCode == "0" then
                            --todo
                            local sData = data_netData.data
                            dump(data["netData"], "fangka test 1")
                            dump(sData, "fangka test 2")
                            if table.getn(sData) > 0 then
                                --todo
                                if table.getn(sData[1]) > 0 then
                                    --todo
                                    require("hall.GameCommon"):show_Message(sData[1][1]["content"])
                                end
                            else
                                require("hall.GameCommon"):show_Message()
                            end

                        end
                    end
                })

                -- require("hall.GameCommon"):show_Message()

                -- require("hall.GameTips"):showTips("提示", "", 3, "快乐游戏，健康生活")

            elseif sender == btn_help then 
                --玩法介绍
                require("hall.GameCommon"):show_instruction()

                -- require("majiang.common.GameResult"):CreateScene()

            elseif sender == btn_record then
                require("hall.common.HistoryLayer"):showHistoryLayer()

            elseif sender == btn_kefu then
                -- require("hall.GameTips"):showTips("联系客服", "", 3, "客服电话：18200664456" .. "\n" .. "\n" .. "客服微信：18200664456")
                require("hall.GameTips"):showTips("联系客服", "", 3, "")

            -- elseif sender == back_bt then
            --     -- room_plane:setVisible(false)
            --     -- game_scroll:setVisible(true)
            --      self:showGameList()

            --     SCENENOW["scene"]._scene:getChildByName("room_plane"):setVisible(true)

            end
        end
    end

    btn_setting:addTouchEventListener(touchEvent)
    btn_add_score:addTouchEventListener(touchEvent)
    add_9_gold:addTouchEventListener(touchEvent)
    btn_join:addTouchEventListener(touchEvent)--加入组局
    -- btn_create:addTouchEventListener(touchEvent)--创建组局
    btn_share:addTouchEventListener(touchEvent)
    btn_message:addTouchEventListener(touchEvent)
    btn_help:addTouchEventListener(touchEvent)
    btn_record:addTouchEventListener(touchEvent)
    btn_kefu:addTouchEventListener(touchEvent)
    -- back_bt:addTouchEventListener(touchEvent)

    --校验用户，成功返回hall的ip和port
    if s:getChildByName("layout_loading") then
        s:removeChildByName("layout_loading")
    end

    --检查签到
    -- self:deal_sign_in()

    --获取游戏列表
    bm.isConnectBytao=false
    require("hall.HallHttpNet"):land()

    --获取组局配置
    self:getCreateGroupGameConfig()
    
    --魔窗进入组局的入口
    --通知原生已进入大厅
    cct.getDateForApp("nowInHall", {}, "V")

    -- bm.chat_server:getHandle():SVR_SUCCESS({
    --         data={
    --             cmd="103",
    --             data={
    --                 videoUrl="http://hbirdtest.oss-cn-shenzhen.aliyuncs.com/1256_video_2016_09_30_20_56_02.mp4",
    --                 userNickName="测试"
    --             }
                
    --         }
    --     })

end

function gameScene:showNotification()

    if bm.isShowNotification then
        return
    end
    
    local params = {}
    params["type"] = "3"
    cct.createHttRq({
        url=HttpAddr .. "/baseData/queryAnnouncements",
        date= params,
        type_="POST",
        callBack = function(data)
            data_netData = json.decode(data["netData"])
            if data_netData.returnCode == "0" then
                --todo
                local sData = data_netData.data
                dump(sData, "-----查询公告-----")
                if table.getn(sData) > 0 then
                    --todo
                    if table.getn(sData[1]) > 0 then
                        --todo
                        if sData[1][1]["content"] and sData[1][1]["content"] ~= "" then
                            dump(sData[1][1]["content"], "-----查询公告-----")
                            -- require("hall.GameTips"):showNotice("公告", "", 3, sData[1][1]["content"])
                            require("hall.GameCommon"):show_Message(sData[1][1]["content"])
                            bm.isShowNotification = 1
                        end
                    end
                end
            end              
        end
    })

end

--显示游戏列表
function gameScene:showGameList()

    if SCENENOW["scene"] == nil then
        return
    end

    if SCENENOW["scene"]._scene == nil then
        return
    end

    -- require("hall.LoginScene"):show()

    require("hall.NetworkLoadingView.NetworkLoadingView"):removeView()

    -- --更多游戏(废弃)
    -- local morecontent_sv = SCENENOW["scene"]._scene:getChildByName("content_sv")
    -- if  morecontent_sv then
    --      morecontent_sv:setVisible(false)
    -- end

    -- -- if game_scroll == nil then
    -- --     return
    -- -- else
    -- --     game_scroll:removeAllChildren()
    -- -- end

    -- --获取本地记录的显示到外面的游戏
    backgameList = require("hall.GameList"):getList()
    local gameList = cc.UserDefault:getInstance():getStringForKey("showOutGame")
    dump(gameList, "-----显示游戏列表gameList-----")
    if gameList == nil or gameList == "" then

        gameList = {}
        for k,v in pairs(backgameList) do
            if v[7] == 1 then
                table.insert(gameList, v)
            end
        end
        cc.UserDefault:getInstance():setStringForKey("showOutGame", json.encode(gameList))

    else

        gameList = json.decode(gameList)

    end

    -- --更多游戏
    local moregameList = {}
    for k,v in pairs(backgameList) do
        if v[7] == 1 then
            v[7] = 0
        end
        table.insert(moregameList, v)
    end

    dump(gameList, "-----显示游戏列表gameList-----")
    dump(moregameList, "-----显示游戏列表moregameList-----")

    -- if gameList ~= nil and #gameList > 0 then

    --     --定义内容显示区域
    --     local content_ly = ccui.Layout:create()
    --     content_ly:setName("content_ly")
    --     content_ly:setAnchorPoint(cc.p(0,1))
    --     content_ly:setPosition(0, 0)
    --     content_ly:setContentSize(cc.size(0, 0))
    --     content_ly:setTouchEnabled(false)

    --     -- game_scroll:addChild(content_ly)

    --     if isiOSVerify then

    --         --定义一个按钮
    --         local button = ccui.Button:create()
    --         button:setTouchEnabled(true)
    --         button:setAnchorPoint(cc.p(0,1))
    --         button:setSize(320.00, 105.00)
    --         button:setPosition(-10, -50)
    --         button:setName("layout_game"..tostring(4))
    --         button:loadTextures("hall/images/xz_bt.png", nil, nil)
    --         content_ly:addChild(button)
    --         local function touchEvent(sender, event)
    --             if event == TOUCH_EVENT_ENDED then
    --                 require("hall.GameCommon"):playEffectSound("hall/Audio_Button_Click.mp3")
    --                 if sender == button then

    --                     self:selectGame(4, majiang)
                        
    --                 end
    --             end
    --         end
    --         button:addTouchEventListener(touchEvent)

    --     else

    --         local i = 1
    --         table.foreach(gameList, 

    --             function(k, v)

    --                 local gameId = tonumber(v[1])

    --                 -- if gameId == 4 then

    --                     --定义一个按钮
    --                     local button = ccui.Button:create()
    --                     button:setTouchEnabled(true)
    --                     button:setAnchorPoint(cc.p(0,1))
    --                     button:setSize(320.00, 105.00)
    --                     button:setPosition(-10 * (k - 1) , 102 * (k - 1) * -1)
    --                     button:setName("layout_game"..tostring(v[1]))
                        
    --                     if gameId == 1 then
    --                         button:loadTextures("hall/images/ddz_bt.png", nil, nil)
    --                     elseif gameId == 4 then
    --                         button:loadTextures("hall/images/xz_bt.png", nil, nil)
    --                     elseif gameId == 40 then
    --                         button:loadTextures("hall/images/cs_bt.png", nil, nil)
    --                     elseif gameId == 41 then
    --                         button:loadTextures("hall/images/zz_bt.png", nil, nil)
    --                     elseif gameId == 42 then
    --                         button:loadTextures("hall/images/kwx_bt.png", nil, nil)
    --                     elseif gameId == 5 then
    --                         button:loadTextures("hall/images/dn_bt.png", nil, nil)
    --                     elseif gameId == 6 then
    --                         button:loadTextures("hall/images/dzpk_bt.png", nil, nil)
    --                     elseif gameId == 43 then
    --                         button:loadTextures("hall/images/gdmj_bt.png", nil, nil)
    --                     elseif gameId == 44 then
    --                         button:loadTextures("hall/images/szkwx_bt.png", nil, nil)
    --                     elseif gameId == 45 then
    --                         button:loadTextures("hall/images/main_xueliu_bt.png", nil, nil)
    --                     elseif gameId == 46 then
    --                         button:loadTextures("hall/images/main_tuidaohu_bt.png", nil, nil)
    --                     elseif gameId == 47 then
    --                         button:loadTextures("hall/images/main_xiangyangkawuxing_bt.png", nil, nil)
    --                     elseif gameId == 51 then
    --                         button:loadTextures("hall/images/main_hainanmajaing_bt.png", nil, nil)
    --                     elseif gameId == 52 then
    --                         button:loadTextures("hall/images/main_yingkongmajiang_bt.png", nil, nil)
    --                     elseif gameId == 75 then
    --                         button:loadTextures("hall/images/main_xiangyinmajiang_bt.png", nil, nil)
    --                     elseif gameId == 11 then
    --                         button:loadTextures("hall/images/pdk_bt.png", nil, nil)
    --                     elseif gameId == 8 then
    --                         button:loadTextures("hall/images/phz_bt.png", nil, nil)
    --                     elseif gameId == 9 then
    --                         button:loadTextures("hall/images/sg_bt.png", nil, nil)
    --                     elseif gameId == 7 then
    --                         button:loadTextures("hall/images/main_zhajinhua_bt.png", nil, nil)
    --                     elseif gameId == 78 then
    --                         button:loadTextures("hall/images/main_yibinmajiang_bt.png", nil, nil)

    --                     end

    --                     content_ly:addChild(button)

                        -- --检查本地版本号
                        -- local bShowMash = 0
                        -- if v[4] ~= "-1" and needUpdate == true then
                        --     if v[2] ~= nil then
                        --         if require("hall.GameData"):getGameVersion(v[2]) == "" then
                        --             --本地没有游戏
                        --             bShowMash = 1
                        --         elseif require("hall.GameData"):compareLocalVersion(v[4],v[2]) > 0 then
                        --             --本地游戏版本低
                        --             bShowMash = 2
                        --         end
                        --     end
                        -- end

    --                     --显示新版本标签
    --                     if bShowMash > 0 then
    --                         local spMash = display.newSprite("hall/hall/new.png")
    --                         if spMash then
    --                             button:addChild(spMash)
    --                             spMash:setAnchorPoint(cc.p(0,0))
    --                             spMash:setPosition(cc.p(235, 30))
    --                             spMash:setName("spMash")
    --                         end
    --                     end

    --                     local spLoading = cc.ProgressTimer:create(cc.Sprite:create("hall/hall/loading_bg.png"))
    --                     button:addChild(spLoading)
    --                     spLoading:setVisible(false)
    --                     spLoading:setName("loading")
    --                     spLoading:setPosition(160,55)
    --                     spLoading:setScale(0.8)

    --                     local function touchEvent(sender, event)
    --                         if event == TOUCH_EVENT_ENDED then
    --                             require("hall.GameCommon"):playEffectSound("hall/Audio_Button_Click.mp3")
    --                             if sender == button then

    --                                 if needUpdate then
    --                                     dump("", "-----点击按钮，检查更新游戏-----")
    --                                     self:updateGame(v[1],v[2],v[3])
    --                                 else
    --                                     dump("", "-----点击按钮，选择游戏-----")
    --                                     self:selectGame(v[1], v[2])
    --                                 end
                                    
    --                             end
    --                         end
    --                     end
    --                     button:addTouchEventListener(touchEvent)

    --                 -- end
                    
    --             end
    --         )

    --     end

    -- end

    if moregameList ~= nil and #moregameList > 0 then

        --记录当前更多游戏布局是否打开
        local isMoreShow = 0

        --更多游戏布局
        local drawer_ly = SCENENOW["scene"]._scene:getChildByName("drawer_ly")
        local roomplane = SCENENOW["scene"]._scene:getChildByName("room_plane")
        local create_bt = roomplane:getChildByName("btn_create")
        --显示更多游戏
        local showMore_ly = drawer_ly:getChildByName("showMore_ly")
        create_bt:addTouchEventListener(

            function(sender,event)

                --触摸结束
                if event == TOUCH_EVENT_ENDED then
                    -- drawer_ly:setScale(1.0)

                    local bShowMash = 0
   
                    if bm.notCheckReload == 1 then
                        dump("返回房间", "-----检查是否有存在组局-----")

                        cct.createHttRq({
                            url=HttpAddr .. "/viewReganizeHistory",
                            date={
                                userId = USER_INFO["uid"]
                            },
                            type_= "POST",
                            callBack = function(data)
                                
                                local data_netData = data.netData

                                if data_netData == nil then

                                    bm.notCheckReload = 0
                                    create_bt:loadTextures("hall/hall_01/hall_creat_tb.png", nil, nil)

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
                                if #tbHistory == 0 then

                                    bm.notCheckReload = 0
                                    create_bt:loadTextures("hall/hall_01/hall_creat_tb.png", nil, nil)

                                    return

                                end

                                --有未结束组局，进入最后一次加入的未结束组局
                                for k, v in pairs(tbHistory) do
                                    if k == 1 then
                                        require("hall.groudgamemanager"):join_freegame(USER_INFO["uid"], v["inviteCode"], v["activityId"], true, v["level"], true)
                                        return
                                    end
                                end

                            end
                        })

                    else
                        -- require("hall.group.create.group_create_mj"):CreateScene()

                    
                       
                    end    
                     drawer_ly:stopAllActions()

                        if isMoreShow == 0 then
                            
                            local p = cc.p(0.00, 270.00)
                            local action_move = cc.MoveTo:create(0.5,p)
                            local sum_action = cc.Spawn:create(action_move)
                            drawer_ly:runAction(sum_action)

                            isMoreShow = 1

                            SCENENOW["scene"]._scene:getChildByName("room_plane"):setVisible(false)

                            local mark_ly = SCENENOW["scene"]._scene:getChildByName("mark_ly")
                            local back_bt = drawer_ly:getChildByName("back_bt")
                            mark_ly:setVisible(true)
                            local function touchEvent_more(sender,event)
                                -- body 
                                    if event == TOUCH_EVENT_ENDED then

                                        drawer_ly:stopAllActions()

                                        self:showGameList()

                                        local p = cc.p(960.00, 270.00)
                                        local action_move = cc.MoveTo:create(0.5,p)
                                        local sum_action = cc.Spawn:create(action_move)
                                        drawer_ly:runAction(sum_action)

                                        isMoreShow = 0

                                        local mark_ly = SCENENOW["scene"]._scene:getChildByName("mark_ly")
                                        mark_ly:setVisible(false)
                                        SCENENOW["scene"]._scene:getChildByName("room_plane"):setVisible(true)
                                    end
                            end
                            mark_ly:addTouchEventListener(touchEvent_more)
                            back_bt:addTouchEventListener(touchEvent_more)

                        else

                            self:showGameList()

                            local p = cc.p(960.00, 270.00)
                            local action_move = cc.MoveTo:create(0.5,p)
                            local sum_action = cc.Spawn:create(action_move)
                            drawer_ly:runAction(sum_action)

                            isMoreShow = 0

                            local mark_ly = SCENENOW["scene"]._scene:getChildByName("mark_ly")
                            mark_ly:setVisible(false)
                            SCENENOW["scene"]._scene:getChildByName("room_plane"):setVisible(true)
                        end
                end

            end

        )

        --更多游戏
        local content_sv = drawer_ly:getChildByName("content_sv")
        content_sv:setCascadeOpacityEnabled(true)
        content_sv:setInnerContainerSize(cc.size(268.00, (59 + 0) * #moregameList - 25))
        local content_ly=content_sv:getChildByName("content_ly")
        dump(content_ly:getChildrenCount(),"content_ly:getChildren()")

        local a = 0
        local subitem=0
        local _y=260  --第一行游戏项目 Y轴
        local page=0
        content_ly:removeAllChildren()
        for i=0,content_sv:getChildrenCount() do
            if i>0 then
                content_sv:removePageAtIndex(i)
            end
        end
        for k,v in pairs(moregameList) do

            local gameId = tonumber(v[1])

            local spLoading = cc.ProgressTimer:create(cc.Sprite:create("hall/hall/loading_bg.png"))                     
            spLoading:setVisible(false)
            spLoading:setName("loading")
            -- spLoading:setScale(0.8)
            local button = ccui.Button:create()
            button:setTouchEnabled(true)
            button:setName("layout_game"..tostring(v[3]))
            button:setAnchorPoint(cc.p(0.5,0.5))
            button:setSize(320.00, 105.00)
            button:setTag(v[1])     
            button:addChild(spLoading)
            spLoading:setPosition(button:getContentSize().width/2+80,button:getContentSize().height/2+70)
            if subitem>3 then         
                _y = 80
                subitem=0
            end
            if v[8] == 1 then
                a = a + 1
                local x = 0 
                x = 90.00+subitem*205
                subitem=subitem+1
                
                if a>8 then
                    local _content=content_ly:clone()
                    _content:removeAllChildren()
                    content_sv:addPage(_content)
                    page=page+1
                    a=1
                    _y=260
                end
                local y = _y
                -- print(x,y,"坐标")
                button:setPosition(x,y)
                content_sv:getItem(page):addChild(button)
                dump(content_sv:getItem(page):getChildrenCount(),"content_sv:getItem(page):getChildrenCount()")
            end

            local pic = ""
            pic = "hall/hall_01/game_btn/bt_"..v[2]..".png"
            print("load game", pic)

            button:setName(pic)


            -- if v[7] == 1 then
            --     pic = pic .. "_p.png"
            -- else
            --     pic = pic .. "_n.png"
            -- end

            button:loadTextures(pic, nil, nil)

            if gameId ~= "" then

                button:addTouchEventListener(
                    function(sender,event)

                        if event == TOUCH_EVENT_BEGAN then
                            -- sender:setScale(0.8)
                        end

                        --触摸取消
                        if event == TOUCH_EVENT_CANCELED then
                            -- sender:setScale(1.0)
                        end

                        --触摸结束
                        if event == TOUCH_EVENT_ENDED then
                            -- sender:setScale(1.0)

                            require("hall.GameCommon"):playEffectSound("hall/Audio_Button_Click.mp3")

                            --获取点击的游戏Id
                            local gameId = tonumber(sender:getTag())

                            --检查本地版本号
                            local bShowMash = 0
                            if v[4] ~= "-1" and needUpdate == true then
                                if v[2] ~= nil then
                                    if require("hall.GameData"):getGameVersion(v[2]) == "" then
                                        --本地没有游戏
                                        bShowMash = 1
                                    elseif require("hall.GameData"):compareLocalVersion(v[4],v[2]) > 0 then
                                        --本地游戏版本低
                                        bShowMash = 2
                                    end
                                end
                            end
                            --显示新版本标签
                            if bShowMash > 0 then
                                local spMash = display.newSprite("hall/hall/new.png")
                                if spMash then
                                    button:addChild(spMash)
                                    spMash:setAnchorPoint(cc.p(0,0))
                                    spMash:setPosition(cc.p(button:getContentSize().width/2 + 14,button:getContentSize().height/2))
                                    spMash:setName("spMash")
                                end
                            end

                            -- local spLoading = cc.ProgressTimer:create(cc.Sprite:create("hall/hall/loading_bg.png"))
                            -- button:addChild(spLoading)
                            -- spLoading:setVisible(false)
                            -- spLoading:setName("loading")
                            -- spLoading:setPosition(button:getContentSize().width/2 +80,button:getContentSize().height/2 + 70)
                            -- spLoading:setScale(0.8)
                            dump(gameId, "-----当前点击的游戏Id-----")

                            local gameName = sender:getName()
                            dump(gameName, "-----当前点击的游戏名称-----")
                            if sender == button then

                                    if needUpdate then
                                        dump(button, "-----点击按钮，检查更新游戏-----")
                                        self:updateGame(v[1],v[2],v[3], button)
                                    else
                                        dump("", "-----点击按钮，选择游戏-----")
                                        self:selectGame(v[1], v[2])
                                    end
                                    
                            end
                            -- --获取当前显示到外面的游戏个数
                            -- local nowShowGameCount = 0
                            -- for k,v in pairs(moregameList) do
                            --     if v[7] == 1 then
                            --         nowShowGameCount = nowShowGameCount + 1
                            --     end
                            -- end
                            -- dump(nowShowGameCount, "-----当前显示的游戏个数-----")

                            -- --判断当前点击的游戏是否已经添加显示
                            -- local isShow = 0
                            -- for k,v in pairs(moregameList) do

                            --     if v[1] == gameId then

                            --         --当前点击的游戏已经选择，取消选择
                            --         if v[7] == 1 then

                            --             isShow = 1

                            --             --设置当前游戏没选择
                            --             v[7] = 0
                            --             sender:loadTextures(gameName .. "_n.png", nil, nil)

                            --         end

                            --     end

                            -- end

                            -- --当前点击的游戏没有选择
                            -- if isShow == 0 then

                            --     dump(isShow, "-----当前点击的游戏没有选择-----")

                            --     if nowShowGameCount == 3 then

                            --         --当前已经选择三款游戏
                            --         require("hall.GameTips"):showTips("提示", "", 3, "最多选择三款游戏")

                            --     else
                            --         --当前未选满三款游戏，把点击的游戏设为选中
                            --         sender:loadTextures(gameName .. "_p.png", nil, nil)
                            --         for k,v in pairs(moregameList) do

                            --             --当前点击的游戏已经选择，取消选择
                            --             if v[1] == gameId then

                            --                 --设置当前游戏选择
                            --                 v[7] = 1

                            --             end

                            --         end

                            --     end
                                
                            -- end

                        end

                    end
                )

            else

                button:addTouchEventListener(
                    function(sender,event)

                        if event == TOUCH_EVENT_BEGAN then
                            sender:setScale(0.8)
                        end

                        --触摸取消
                        if event == TOUCH_EVENT_CANCELED then
                            sender:setScale(1.0)
                        end

                        --触摸结束
                        if event == TOUCH_EVENT_ENDED then
                            sender:setScale(1.0)
                            
                            require("hall.GameCommon"):playEffectSound("hall/Audio_Button_Click.mp3")
                            require("hall.GameTips"):showTips("提示", "", 3, "即将到来，敬请期待！")

                        end

                    end
                )

            end

        end

         -- content_sv:setInnerContainerSize(cc.size(268.00, (59 + 0) * a - 25))
        -- if a > 6 then
        --     -- content_ly:setPosition(0,(59 + 0) * a - 25)
        -- end

        -- local sure_bt = drawer_ly:getChildByName("sure_bt")
        -- sure_bt:addTouchEventListener(

        --     function(sender,event)

        --         if event == TOUCH_EVENT_BEGAN then
        --             require("hall.GameCommon"):playEffectSound("hall/Audio_Button_Click.mp3")
        --             sender:setScale(0.8)
        --         end

        --         --触摸取消
        --         if event == TOUCH_EVENT_CANCELED then
        --             sender:setScale(1.0)
        --         end

        --         --触摸结束
        --         if event == TOUCH_EVENT_ENDED then
        --             sender:setScale(1.0)

        --             if require("hall.GameUpdate"):getUpdateStatus() ~= 0 then
        --                 require("hall.GameTips"):showTips("提示", "", 3, "正在更新游戏！")
        --                 return
        --             end

        --             drawer_ly:stopAllActions()

        --             local nowShowGameCount = 0
        --             for k,v in pairs(moregameList) do
        --                 if v[7] == 1 then
        --                     nowShowGameCount = nowShowGameCount + 1
        --                 end
        --             end

        --             -- if nowShowGameCount < 3 then
        --             --     require("hall.GameTips"):showTips("提示", "", 3, "请选择三款游戏")
        --             --     return
        --             -- end

        --             --更新显示在外面的游戏记录
        --             local newGameList = {}
        --             for k,v in pairs(moregameList) do
        --                 if v[7] == 1 then
        --                     table.insert(newGameList, v)
        --                 end
        --             end
        --             cc.UserDefault:getInstance():setStringForKey("showOutGame", json.encode(newGameList))

        --             --隐藏更多游戏布局
        --             local p = cc.p(895.00, 266.00)
        --             local action_move = cc.MoveTo:create(0.5,p)
        --             local sum_action = cc.Spawn:create(action_move)
        --             drawer_ly:runAction(sum_action)

        --             isMoreShow = 0

        --             self:showGameList()

        --             local mark_ly = SCENENOW["scene"]._scene:getChildByName("mark_ly")
        --             mark_ly:setVisible(false)

        --         end

        --     end

        -- )

    end
    
end

--获取组局配置
function gameScene:getCreateGroupGameConfig()

    dump("", "-----获取组局配置-----")

    cct.createHttRq({
        url = HttpAddr .. "/game/queryGameConfig",
        date = {
            
        },
        type_= "GET",
        callBack = function(data)
            local responseData = data.netData
            if responseData then
                responseData = json.decode(responseData)
                local cacheData = responseData.data
                if cacheData then
                    local content = cacheData.content
                    if content then
                        local decodeData = json.decode(content)
                        bm.groupGameConfig = decodeData
                        dump(bm.groupGameConfig, "-----获取组局配置返回-----")
                    end
                end
            end
        end
    })

end

--检查更新游戏
function gameScene:updateGame(id,code,name, btn_sender)

    print("-----大厅更新游戏:".. code .." 状态:" .. require("hall.GameUpdate"):getUpdateStatus())
    dump(btn_sender, "gameScene:updateGame", nesting)

    if require("hall.GameUpdate"):getUpdateStatus() == 0 then
        require("hall.GameUpdate"):queryVersion(id,code,1,name, btn_sender)
    else
        require("hall.GameTips"):showTips("提示", "", 4, "正在更新游戏！","",0)
    end
    
end

--设置当前游戏
function gameScene:selectGame(gid, code)
    USER_INFO["enter_mode"] = gid
    USER_INFO["enter_code"] = code
    require("hall.group.create.group_create_mj"):CreateScene()
    -- self._scene:getChildByName("game_scroll"):setVisible(false)
    -- self._scene:getChildByName("room_plane"):setVisible(true)
    -- SCENENOW["scene"]._scene:getChildByName("room_plane"):setVisible(true)
    -- require("hall.GameTips"):showTips("提示", "", 4, "欢迎进入游戏！")
    if SCENENOW["scene"]:getChildByName("layer_tips") then
        SCENENOW["scene"]:removeChildByName("layer_tips")
    end
end

function gameScene:onEnter()

    local params = {}
    params["type"] = "2"
    cct.createHttRq({
        url=HttpAddr .. "/baseData/queryAnnouncements",
        date= params,
        type_="POST",
        callBack = function(data)
            data_netData = json.decode(data["netData"])
            if data_netData.returnCode == "0" then
                --todo
                local sData = data_netData.data
                dump(sData, "-----查询走马灯-----")
                if table.getn(sData) > 0 then
                    --todo
                    if table.getn(sData[1]) > 0 then
                        --todo
                        dump(sData[1][1]["content"], "-----查询走马灯-----")
                        require("hall.BraodComponent"):setDefaultBraodMessage(sData[1][1]["content"])
                    end
                end
            end              
        end
    })

    if device.platform == "windows" then

        self:showNotification()

    else

        local cardCount = cct.getDataForApp("getSendCardCount", {}, "I") or 3

        if cardCount > 0 then
            
            --显示房卡
            -- require("hall.GameTips"):showTips("提示", "hall", "3", "首次登录，送您 " .. cardCount .. "张房卡")

        else

            self:showNotification()

        end

    end

    print("进入大厅")

    local braodPlane = self._scene:getChildByName("Image_1"):getChildByName("braod_plane")
    require("hall.BraodComponent"):showBraod(braodPlane)

    -- --显示版本号
    -- local lbVersion = ccui.Text:create()
    -- lbVersion:setString("version:"..require("hall.GameData"):getGameVersion("hall"))
    -- lbVersion:setFontSize(18)

    --     -- local lbVersion = cc.Label:createWithTTF("version:"..require("hall.GameData"):getGameVersion("hall"), "MarkerFelt.ttf", 18)
    -- self._scene:addChild(lbVersion)
    -- lbVersion:setColor(cc.c3b(47,47,47))
    -- lbVersion:setPosition(cc.p(lbVersion:getContentSize().width/2,lbVersion:getContentSize().height/2))

    -- self:setScore()
    
    local strNick = require("hall.GameCommon"):formatNick(USER_INFO["nick"])
    local top_base = self._scene:getChildByName("top_base")
    local lbNick = top_base:getChildByName("txt_nick")
    if lbNick then
        lbNick:setString(strNick)
        lbNick:enableShadow(cc.c4b(0,0,0,178),cc.size(1,-2),4)
    end

    local userId = tostring(USER_INFO["uid"])
    local lbId = top_base:getChildByName("txt_nick_0")
    if lbId then
        lbId:setString("ID: " .. userId)
        lbId:enableShadow(cc.c4b(0,0,0,178),cc.size(1,-2),4)
    end

    local sp_head = top_base:getChildByName("sp_head")
    if sp_head then
        print("++++++++++++++++++++++sp_head++++++++++++++++++++++++++++++++++++")
        local user_inf = {}
        user_inf["uid"] = USER_INFO["uid"]
        user_inf["icon_url"] = USER_INFO["icon_url"]
        user_inf["sex"] = USER_INFO["sex"]
        user_inf["nick"] = USER_INFO["nick"]
        -- require("hall.GameCommon"):setPlayerHead(user_inf,sp_head,70)
        require("hall.GameCommon"):getUserHead(user_inf["icon_url"], user_inf["uid"], user_inf["sex"], sp_head, 70, true, USER_INFO["nick"])
    end


    self:setSex()

    local Hall_data = require("hall.hall_data")
    Hall_data:init()
--test
            -- local BuyCard = require("hall.bug_card")
            -- local buy = BuyCard.new()
            -- buy:set_content_txt(1) -- 0是红卡，1是蓝卡

            -- self:addChild(buy)
end
--test
-- function gameScene:refresh_layout(flag)
--     print(flag,"flag---------------")
-- end

--检查是否有存在组局返回
function gameScene:checkGroupEnd()
    print("checkGroupEnd",require("hall.gameSettings"):getGameMode())
    display_scene("majiang.MJselectChip",1)
end

function gameScene:initFinished()

    require("app.HallUpdate"):enterHall()


    -- require("hall.GameData"):InitData()
    -- self:setScore()
    -- local strNick = require("hall.GameCommon"):formatNick(USER_INFO["nick"])
    -- self._scene:getChildByName("txt_nick"):setString(strNick)

    -- local sp_head = self._scene:getChildByName("sp_head")
    -- if sp_head then
    --     require("hall.GameCommon"):getUserHead(USER_INFO["icon_url"],USER_INFO["uid"],USER_INFO["sex"],sp_head,70,true)
    --         -- sp_head:setRotation(-25)
    --         -- local rt = cc.RotateBy:create(1,50)
    --         -- local rt_back = cc.RotateBy:create(1,-50)
    --         -- sp_head:runAction(cc.RepeatForever:create(cc.Sequence:create(rt,cc.DelayTime:create(0.1),rt_back,cc.DelayTime:create(0.1))))

    -- end
    -- self:setSex()


end

function gameScene:doLoginFail()

    dump("", "-----登录失败-----")

    require("hall.LoginScene"):show()

end

function gameScene:onExit()
    print("hall exit")
end

--更新金币
function gameScene:goldUpdate()
    -- body
    -- self:setScore()
end

--¸üÐÂ½ð±Ò
function gameScene:setScore()

    -- local top_base = self._scene:getChildByName("top_base")

    -- local lbScore = top_base:getChildByName("btn_coins"):getChildByName("txt_score")
    -- if lbScore then
    --     lbScore:setString(require("hall.GameCommon"):formatGold(USER_INFO["gold"]))
    -- end

end

function gameScene:setSex()
    -- body
    local top_base = self._scene:getChildByName("top_base")
    local sex = top_base:getChildByName("img_sex")
    print("user sex:"..USER_INFO["sex"])
    if sex then
        local img = ""
        if USER_INFO["sex"] == 1 then
            img = "hall/hall/player_boy.png"
        elseif USER_INFO["sex"] == 2 then
            img = "hall/hall/player_girl.png"
        end
        sex:setTexture(img)
    end
end


function gameScene:deal_sign_in()
    -- body
    local  isGameSignIn = USER_INFO["isGameSignIn"] or 1 --没有的话，默认就是签到过了
    print("isGameSignIn++++++++++++++++++++++",isGameSignIn)
   --isGameSignIn = 0

    if isGameSignIn == 0 then
        local signinlayer = Signin_layer.new()
        self:addChild(signinlayer)
        isGameSignIn = 1
    end

end

function gameScene:from_market_back( )
    -- body
end

function gameScene:set_hall_base()
    -- body
end


function gameScene:callback_test( )
    -- body
    require("hall.GameTips"):showTips("回调")
end

return gameScene
