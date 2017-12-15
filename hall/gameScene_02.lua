--
-- Author: Your Name
-- Date: 2017-03-28 17:58:46
--
-- cc.Director:getInstance():setDisplayStats(true)  -- FPS  
local listGame = {}

local gameUpdating = 0

if device.platform == "windows" then
    -- 初始化
    import(".src.init")
end

local Recharge  = require("hall.src.views.Recharge.Recharge")
local Market = require("hall.market")
local Proxy = require("hall.proxy")
local Signin_layer = require("hall.signin_monthcard")
local gameScene_02 = class("gameScene_02", function()
    return display.newScene("gameScene_02")
end)

local game_scroll
local game_tiyan = {}


function gameScene_02:ctor()

    -- isShowNetLog = false
    -- showDumpData = false

    if device.platform=="android"  then
        --todo
        if not  _G.notifiLayer  then
            --todo
             _G.notifiLayer=require("hall.notificationPhoneInfo").new()
        end
        _G.notifiLayer.rootNode:setPositionY(508.8)   --还原电量位置
        _G.notifiLayer.rootNode:hide();    
        
    end

   
    -- 统计
    display.loadSpriteFrames("hall/hall_02/game_btn/plist_btn.plist","hall/hall_02/game_btn/plist_btn.png")  --现在游戏项
    SDKAdape.onLoginSuccess(USER_INFO["uid"]);

    bm.tiyan=0   --判断是否从体验进入的游戏选项

    --更新一下微信的用户信息
    --add zengtao

    if not bm.notupload then
        --todo
        if device.platform=="android" then
            require("hall.iosHelps"):xyToken(true);
        elseif device.platform == "ios" then
            require("hall.iosHelps"):flushUserInfo();
        end
    end

    
    
    local s
    if device.platform == "ios" then
        if isiOSVerify then
            s = cc.CSLoader:createNode("hall/hall_02/room_789Game_0.csb"):addTo(self)
        else
            s = cc.CSLoader:createNode(cc.FileUtils:getInstance():getWritablePath() .. "hall/hall_02/room_789Game_0.csb"):addTo(self)
        end
    else
        s = cc.CSLoader:createNode("hall/hall_02/room_789Game_0.csb"):addTo(self)
    end
    
    self._scene = s

    bm.isInGame=false
    if USER_INFO['proxyId'] then
        print("已有代理")
        bm.isProxy = false
    else
        Proxy:InquireProxy()  --查询是否有代理
    end
    


    local top_base = self._scene:getChildByName("top_base")       --外围 Layout
    local btn_setting = top_base:getChildByName("btn_setting")  --设置
    local btn_add_score = top_base:getChildByName("btn_coins")  --房卡
    -- local btn_score = top_base:getChildByName("btn_score")  
    local add_9_gold = btn_add_score:getChildByName("add_9")     --房卡 +号  按钮
    local txt_score = btn_add_score:getChildByName("txt_score")  --房卡数
    self.m_txt_score = txt_score

    local btn_share = top_base:getChildByName("btn_share")  --分享
    local btn_message = top_base:getChildByName("btn_message")  --公告
    local btn_help = top_base:getChildByName("btn_help")    --玩法
    local btn_record = top_base:getChildByName("btn_record")  --战绩
    local btn_kefu = top_base:getChildByName("btn_kefu")  --  客服
    local btn_daili = top_base:getChildByName("btn_daili")  -- 代理
    -- local btn_gonghui = top_base:getChildByName("btn_gonghui") --公会  --已经停用
    local dikuang = top_base:getChildByName("Image_4")

    local room_plane = self._scene:getChildByName("room_plane") --创建-加入房间页

    local btn_create = room_plane:getChildByName("btn_create")  --创建房间 

    local btn_tiyan = room_plane:getChildByName("btn_tiyan")   --体验房间
    local btn_begin = room_plane:getChildByName("begin")
    local lizixiaoguo = cc.ParticleSystemQuad:create("hall/hall_02/image/lujinglizi.plist")
    lizixiaoguo:setPosition(cc.p(20,20))
    lizixiaoguo:setName("lizixiaoguo")
    lizixiaoguo:setScale(1.5)
    btn_tiyan:addChild(lizixiaoguo)

    local function moveEnd() -- , cc.CallFunc:create(moveEnd)
        btn_begin:setOpacity(255)
    end
    local rotate = cc.RotateBy:create(0.8, 360)
    local low = cc.ScaleBy:create( 0.8 , 0.8)
    local big = low:reverse()
    local fo = cc.FadeOut:create(0.8)
    local sq = cc.Sequence:create(rotate)
    local sq2 = cc.Sequence:create(big,low,fo,cc.CallFunc:create(moveEnd))
    btn_tiyan:runAction(cc.RepeatForever:create(sq))
    btn_begin:runAction(cc.RepeatForever:create(sq2))





       
    if bm.notCheckReload == 1 then
        btn_create:loadTextures("hall/hall_02/image/hall_back_tb.png", nil, nil,1)
        btn_tiyan:setVisible(false)
        btn_begin:setVisible(false)
    else
        btn_create:loadTextures("hall/hall_02/image/hall_creat_tb.png", nil, nil,1)
        btn_tiyan:setVisible(true)
        btn_begin:setVisible(true)
    end
    -- btn_tiyan:setVisible(false) 
    local btn_join = room_plane:getChildByName("btn_join")  --加入房间


    local drawer_ly = self._scene:getChildByName("drawer_ly") --更多游戏
    drawer_ly:setVisible(true)
    local popular_game = drawer_ly:getChildByName("popular_game")  --热门游戏

    room_plane:setVisible(true)
    -- isiOSVerify=true
    -- ios 版本隐藏
    if isiOSVerify then
        btn_add_score:setVisible(false)
        btn_share:setVisible(false)
        btn_kefu:setVisible(false)
        -- btn_gonghui:setVisible(false)
        btn_daili:setVisible(false)
        btn_help:setVisible(false)
        btn_message:setVisible(false)
        btn_record:setVisible(false)
        dikuang:setVisible(false)
        btn_setting:setPosition(btn_setting:getPositionX(),btn_setting:getPositionY()+80)
        -- drawer_ly:setVisible(false)
        btn_tiyan:setVisible(false)
        btn_begin:setVisible(false)
    end

	audio.playMusic("hall/bgm.mp3",true)
    -- dump(USER_INFO["cardCount"], "-----gameScene cardCount 1-----")
    -- txt_score:setString(USER_INFO["cardCount"] .. "")

    -- 刷新房卡
    self:refreshRoomCard()

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
            require("hall.GameCommon"):playEffectSound("hall/Audio_Button_Click.mp3")
            -- 关闭大厅上层已显示的界面
            self:closeLobbyTopLayer()

            if sender == btn_setting then
                require("hall.GameCommon"):showSettings(true,true)
                
                --test  run majiang
               -- display_scene("xlsg.gameScene")

            elseif sender == btn_add_score or add_9_gold == sender then 

                --充值
                self:InquireMarket()
               
            elseif sender == btn_join then

                if bm.notCheckReload == 1 then
                    require("hall.GameTips"):showTips("提示", "", 3, "你当前有未结束的组局，不能加入其他房间")

                else
                    require("hall.group.GroupSetting"):enterRoom()

                end
           
            -- elseif sender == btn_create then 
            --     --创建组局(创建房间、返回房间)

            --     if bm.notCheckReload == 1 then
            --         dump("返回房间", "-----检查是否有存在组局-----")

            --         cct.createHttRq({
            --         url=HttpAddr .. "/viewReganizeHistory",
            --         date={
            --             userId = USER_INFO["uid"]
            --         },
            --         type_= "POST",
            --         callBack = function(data)
                        
            --             local data_netData = data.netData

            --             if data_netData == nil then

            --                 bm.notCheckReload = 0
            --                 btn_create:loadTextures("hall/hall_02/hall_creat_tb.png", nil, nil)

            --                 return

            --             end

            --             --检查是否有未结束组局
            --             local tbHistory = {}
            --             data_netData = json.decode(data_netData)
            --             for k,v in pairs(data_netData.data) do
            --                 if v.status == nil or v.status ~= "2" then
            --                     table.insert(tbHistory, v)
            --                 end
            --             end
            --             dump(tbHistory, "-----当前用户未结束的组局-----")

            --             --如果没有组局历史
            --             if #tbHistory == 0 then

            --                 bm.notCheckReload = 0
            --                 btn_create:loadTextures("hall/hall_02/hall_creat_tb.png", nil, nil)

            --                 return

            --             end

            --             --有未结束组局，进入最后一次加入的未结束组局
            --             for k, v in pairs(tbHistory) do
            --                 if k == 1 then
            --                     require("hall.groudgamemanager"):join_freegame(USER_INFO["uid"], v["inviteCode"], v["activityId"], true, v["level"], true)
            --                     return
            --                 end
            --             end

            --         end
            --     })

            --     -- else
            --         -- require("hall.group.create.group_create_mj"):CreateScene()

            --     end


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
                        data_netData = json.decode(data["netData"])
                        if data_netData.returnCode == "0" then
                            --todo
                            local sData = data_netData.data
                            -- 关闭大厅上层已显示的界面
                            self:closeLobbyTopLayer()
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

                require("hall.GameTips"):showTips("联系客服", "", 3, "7*24小时在线客服\n  热线电话：020-3993-5789  \n  QQ：400-835-2898","",1, handler(self, self.onCustomServiceCallback))


                -- elseif sender == back_bt then
                --     -- room_plane:setVisible(false)
                --     -- game_scroll:setVisible(true)
                --      self:showGameList()

                --     SCENENOW["scene"]._scene:getChildByName("room_plane"):setVisible(true)
            elseif sender == btn_daili then
                require("hall.GameTips"):Proxy()
                -- elseif sender == btn_gonghui then   --暂时不用工会。已删除
                --     require("hall.GameTips"):showTips("提示", "", 3, "该功能暂未开放")
                -- --todo
            elseif sender == btn_tiyan or sender == btn_begin then
                local tiyan = true
                self:inquiretiyan(tiyan)
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
    btn_daili:addTouchEventListener(touchEvent)
    -- btn_gonghui:addTouchEventListener(touchEvent)
    btn_tiyan:addTouchEventListener(touchEvent)
    btn_begin:addTouchEventListener(touchEvent)
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

end

-- 关闭大厅上层已显示的界面
function gameScene_02:closeLobbyTopLayer()
    if SCENENOW["scene"]:getChildByName("layout_settings") then
        SCENENOW["scene"]:removeChildByName("layout_settings")
    end
    if SCENENOW["scene"]:getChildByName("layout_alert") then
        SCENENOW["scene"]:removeChildByName("layout_alert")
    end
    if SCENENOW["scene"]:getChildByName("layer_tips") then
        SCENENOW["scene"]:removeChildByName("layer_tips")
    end
    if SCENENOW["scene"]:getChildByName("enter_room") then
        SCENENOW["scene"]:removeChildByName("enter_room")
    end
    if SCENENOW["scene"]:getChildByName("shareLayer") then
        SCENENOW["scene"]:removeChildByName("shareLayer")
    end
    if SCENENOW["scene"]:getChildByName("gonggaolayer") then
        SCENENOW["scene"]:removeChildByName("gonggaolayer")
    end
    if SCENENOW["scene"]:getChildByName("InstructionLayer") then
        SCENENOW["scene"]:removeChildByName("InstructionLayer")
    end 
    if SCENENOW["scene"]:getChildByName("HistoryLayer") then
        SCENENOW["scene"]:removeChildByName("HistoryLayer")
    end 
    if SCENENOW['scene']:getChildByName("proxy") then
        SCENENOW['scene']:removeChildByName("proxy")     
    end
end



function gameScene_02:tiyanfangjian()   --体验房间操作
    local drawer_ly = SCENENOW["scene"]._scene:getChildByName("drawer_ly")
    local roomplane = SCENENOW["scene"]._scene:getChildByName("room_plane")
        self:showGameList()
        drawer_ly:setPosition(0.00,270.00)
        SCENENOW["scene"]._scene:getChildByName("room_plane"):setVisible(false)
        local mark_ly = SCENENOW["scene"]._scene:getChildByName("mark_ly")
        local back_bt = drawer_ly:getChildByName("back_bt")
        mark_ly:setVisible(true)
        local function touchEvent_more(sender,event)
            -- body 
            if event == TOUCH_EVENT_ENDED then
                if require("hall.GameUpdate"):getUpdateStatus() ~= 0 then
                    require("hall.GameUpdateLoading"):updateLoading()
                else
                    -- self:showGameList()
                    drawer_ly:setPosition(960.00,270.00)
                    local mark_ly = SCENENOW["scene"]._scene:getChildByName("mark_ly")
                    mark_ly:setVisible(false)
                    SCENENOW["scene"]._scene:getChildByName("room_plane"):setVisible(true)
                end
            end
        end
        mark_ly:addTouchEventListener(touchEvent_more)
        back_bt:addTouchEventListener(touchEvent_more)            
end


function gameScene_02:inquiretiyan(tiyan)  --体验房间接口
    local uid = USER_INFO['uid']
    cct.createHttRq({
        url=HttpAddr2 .. "/front/game/selectExperienceRoomList",
        date={
            playerId = tostring(uid),
        },
        type_="GET",
        callBack = function(data)
            local Netdata=json.decode(data.netData)
            if Netdata then 
                self:tiyanhandle(Netdata,tiyan)
            end
        end
    })
end

function gameScene_02:tiyanhandle(data,tiyan)  --体验房间数据处理
    if data then
        dump(data, "desciption, nesting")
        if data.code == "1"  then
            if #data.data == 0 then
                if tiyan then
                    require("hall.GameTips"):showTips("提示", "", 3, "非常抱歉，体验房已经爆满。请您通过创建房间或者加入房间进行游戏。祝您游戏愉快")
                else
                    game_tiyan={}
                    self:showGameList()
                    require("hall.GameTips"):showTips("提示", "", 3, "非常抱歉，体验房已经爆满。请您通过创建房间或者加入房间进行游戏。祝您游戏愉快")
                end
            else


                bm.tiyan = 1
                game_tiyan = data.data

                local tb={}
                for k,v in pairs(game_tiyan) do
                    if not tb[v.gameId] then
                        tb[v.gameId]={}
                    end

                    for k1,v1 in pairs(tb) do
                        if k1== v.gameId then
                            table.insert(v1,v.inviteCode)
                        end
                    end
                    
                end
                game_tiyan = tb
                if tiyan then
                    self:tiyanfangjian()
                else
                    self:showGameList()
                end
            end
        else
            require("hall.GameTips"):showTips("提示", "", 3, "非常抱歉，体验房已经爆满。请您通过创建房间或者加入房间进行游戏。祝您游戏愉快")
        end
    end
end


function gameScene_02:showNotification()  --公告

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
                if table.getn(sData) > 0 then
                    --todo
                    if table.getn(sData[1]) > 0 then
                        --todo
                        if sData[1][1]["content"] and sData[1][1]["content"] ~= "" then
                            if isiOSVerify==false then
                                require("hall.GameCommon"):show_Message(sData[1][1]["content"])
                                bm.isShowNotification = 1
                            end
                        end
                    end
                end
            end              
        end
    })

end

--显示游戏列表
function gameScene_02:showGameList()

    if SCENENOW["scene"] == nil then
        return
    end

    if SCENENOW["scene"]._scene == nil then
        return
    end


    require("hall.NetworkLoadingView.NetworkLoadingView"):removeView()

    backgameList = require("hall.GameList"):getList()
    -- local gameList = cc.UserDefault:getInstance():getStringForKey("showOutGame")
    -- dump(gameList, "-----显示游戏列表gameList-----")
    -- if gameList == nil or gameList == "" then

    --     gameList = {}
    --     for k,v in pairs(backgameList) do
    --         if v[7] == 1 then
    --             table.insert(gameList, v)
    --         end
    --     end
    --     cc.UserDefault:getInstance():setStringForKey("showOutGame", json.encode(gameList))

    -- else

    --     gameList = json.decode(gameList)

    -- end

    -- --游戏列表
    local moregameList = {}
    for k,v in pairs(backgameList) do
        if v[7] == 1 then
            v[7] = 0
        end
        table.insert(moregameList, v)
    end

    -- dump(gameList, "-----显示游戏列表gameList-----")
    if moregameList ~= nil and table.nums(moregameList) > 0 then
        print("vvvvvvvvvvvvvvvvv")
        --记录当前游戏布局是否打开
        local isMoreShow = 0

        --游戏列表
        local drawer_ly = SCENENOW["scene"]._scene:getChildByName("drawer_ly")
        local roomplane = SCENENOW["scene"]._scene:getChildByName("room_plane")
        local popular_game = drawer_ly:getChildByName("popular_game")
        local create_bt = roomplane:getChildByName("btn_create")
        --显示更多游戏
        -- local showMore_ly = drawer_ly:getChildByName("showMore_ly")
        create_bt:addTouchEventListener(

            function(sender,event)

                --触摸结束
                if event == TOUCH_EVENT_ENDED then
                    -- drawer_ly:setScale(1.0)
                   
                    local bShowMash = 0
                    if bm.notCheckReload == 1 then

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
                                    create_bt:loadTextures("hall/hall_02/image/hall_creat_tb.png", nil, nil,1)

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

                                --如果没有组局历史
                                if #tbHistory == 0 then

                                    bm.notCheckReload = 0
                                    create_bt:loadTextures("hall/hall_02/image/hall_creat_tb.png", nil, nil,1)

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
                        if isMoreShow == 0 then
                            
                            -- local p = cc.p(0.00, 270.00)
                            -- local action_move = cc.MoveTo:create(0.5,p)
                            -- local sum_action = cc.Spawn:create(action_move)
                            -- drawer_ly:runAction(sum_action)
            			    if isiOSVerify then
            				    if not self.m_gdmj_info then
                                    for k,v in pairs(backgameList) do
                                        if v[3] == "广东麻将" then
                                            self.m_gdmj_info = v
                                            break
                                        end
                                    end    
            	               end
	                            if self.m_gdmj_info then
	                                self:selectGame(self.m_gdmj_info[1], self.m_gdmj_info[2])
	                            end
            			    else
	                            drawer_ly:setPosition(0.00,270.00)
	                            isMoreShow = 1
	                            bm.tiyan = 0 
	                            self:showGameList()
	                            SCENENOW["scene"]._scene:getChildByName("room_plane"):setVisible(false)

	                            local mark_ly = SCENENOW["scene"]._scene:getChildByName("mark_ly")
	                            local back_bt = drawer_ly:getChildByName("back_bt")
	                            mark_ly:setVisible(true)
	                            local function touchEvent_more(sender,event)
	                                -- body 
	                                if event == TOUCH_EVENT_ENDED then
	                                    if require("hall.GameUpdate"):getUpdateStatus() ~= 0 then
	                                        require("hall.GameUpdateLoading"):updateLoading()
	                                    else

	                                        -- drawer_ly:stopAllActions()

	                                        -- self:showGameList()
	                                        -- 滑动动画
	                                        -- local p = cc.p(960.00, 270.00)
	                                        -- local action_move = cc.MoveTo:create(0.5,p)
	                                        -- local sum_action = cc.Spawn:create(action_move)
	                                        -- drawer_ly:runAction(sum_action)
	                                        drawer_ly:setPosition(960.00,270.00)
	                                        isMoreShow = 0
	                                        local mark_ly = SCENENOW["scene"]._scene:getChildByName("mark_ly")
	                                        mark_ly:setVisible(false)
	                                        SCENENOW["scene"]._scene:getChildByName("room_plane"):setVisible(true)
	                                    end
	                                end
	                            end
	                            mark_ly:addTouchEventListener(touchEvent_more)
	                            back_bt:addTouchEventListener(touchEvent_more)
			                 end

                        else

                            -- self:showGameList()
                            
                            -- local p = cc.p(960.00, 270.00)
                            -- local action_move = cc.MoveTo:create(0.5,p)
                            -- local sum_action = cc.Spawn:create(action_move)
                            -- drawer_ly:runAction(sum_action)
                            drawer_ly:setPosition(960.00,270.00)
                            isMoreShow = 0
                            local mark_ly = SCENENOW["scene"]._scene:getChildByName("mark_ly")
                            mark_ly:setVisible(false)
                            SCENENOW["scene"]._scene:getChildByName("room_plane"):setVisible(true)
                        end
                    
                       
                    end    
                     -- drawer_ly:stopAllActions()

                       
                end

            end

        )
        --游戏列表目录
        self:upateList(drawer_ly,moregameList,popular_game);
        

        ---content_sv:setInnerContainerSize(cc.size(583.00, 50 * (a+2) - 25))
    end
    
end



function gameScene_02:upateList(drawer_ly,moregameList,popular_game)
    local btn_shuaxin = drawer_ly:getChildByName("btn_shuaxin")  -- 刷新游戏列表
    btn_shuaxin:addTouchEventListener(
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
                self:inquiretiyan()

            end

        end
    )
    local _y=50 * (#moregameList-2)   --第一行游戏项目 Y轴
    if bm.tiyan == 0 then
        btn_shuaxin:setVisible(false)    
    else
        btn_shuaxin:setVisible(true)
        _y=50 * (#game_tiyan+5)   --第一行游戏项目 Y轴
    end
    local content_sv = drawer_ly:getChildByName("content_sv")
    content_sv:setCascadeOpacityEnabled(true)
    -- if 50 * #moregameList - 25 >=334 then
    --     content_sv:setInnerContainerSize(cc.size(583.00, 50 * #moregameList - 25))
    -- end
    local content_ly=content_sv:getChildByName("content_ly")

    -- local content_ly=content_sv:getInnerContainer()


    local a = 0
    local subitem=0
    
    local action_time=0  --特效间隔时间
    content_ly:removeAllChildren()
    for k,v in pairs(moregameList) do

        local gameId = tonumber(v[1])
        
        local pic = ""
        local spLoading = cc.ProgressTimer:create(display.newSprite("#hall/hall_02/image/loading_bg.png"))                     
        spLoading:setVisible(false)
        spLoading:setType(cc.PROGRESS_TIMER_TYPE_BAR)
        spLoading:setName("loading")
        spLoading:setMidpoint(cc.p(1,0))
        spLoading:setBarChangeRate(cc.p(1,0)) 
        local button = ccui.Button:create()
        button:setTouchEnabled(true)
        button:setName("layout_game"..tostring(v[3]))
        button:setAnchorPoint(cc.p(0.5,0.5))
        button:setContentSize(320.00, 105.00)
        button:setTag(v[1])     
        button:addChild(spLoading)
        spLoading:setPosition(button:getPositionX()+145,button:getPositionY()+50)
        if subitem>1 then         
            _y = _y-100
            subitem=0
        end
        if bm.tiyan == 0 then   --判断是否由体验进入游戏选项
            if v[8] == 1 then
                a = a + 1
                local x = 0 
                x = 135.00+subitem*305
                subitem=subitem+1
                local y = _y
                button:setPosition(x,y)
                if isiOSVerify then 
                    if v[3] == "广东麻将" then
                        content_ly:addChild(button)
                    end
                else
                    content_ly:addChild(button)
                end
                
                pic = "hall/hall_02/game_btn/bt_"..v[2]..".png"       
                button:setName(pic)
                print("pic",pic)
                button:loadTextures(pic, nil, nil,1)
            end
        else
            if table.nums(game_tiyan)>0 then
                for k1,v1 in pairs(game_tiyan) do
                    if tonumber(v[1]) == tonumber(k1) then
                        a = a + 1
                        local x = 0 
                        x = 135.00+subitem*305
                        subitem=subitem+1
                        local y = _y
                        button:setPosition(x,y)
                        if isiOSVerify then 
                            if v[3] == "广东麻将" then
                                content_ly:addChild(button)
                            end
                        else                     
                            content_ly:addChild(button)
                        end

                        local inviteCode = math.floor(math.random()*#v1) +1
                        button.inviteCode=v1[inviteCode]                        
                        pic = "hall/hall_02/game_btn/bt_"..v[2]..".png"       
                        button:setName(pic)
                        button:loadTextures(pic, nil, nil,1)
                    end
                end

            end
        end

       
        
        if  bm.tiyan == 0 and k == 1 then
            popular_game:setTouchEnabled(true)
            local popular_loading=cc.ProgressTimer:create(display.newSprite("#hall/hall_02/image/loading_bg_02.png"))    
            popular_loading:setVisible(false)
            popular_loading:setMidpoint(cc.p(0,0))
            popular_loading:setBarChangeRate(cc.p(0,1)) 
            popular_loading:setType(cc.PROGRESS_TIMER_TYPE_BAR)
            popular_loading:setName("loading")
            popular_game:addChild(popular_loading)
            popular_loading:setPosition(popular_game:getContentSize().width/2,popular_game:getContentSize().height/2)
            local popular_pic= ""
            popular_pic="hall/hall_02/popular/popular_"..v[2]..".png"
            popular_game:loadTextures(popular_pic,nil,nil)
            popular_game:addTouchEventListener(
            function(sender,event)
                if event == TOUCH_EVENT_ENDED then
                    require("hall.GameCommon"):playEffectSound("hall/Audio_Button_Click.mp3")
                    if sender == popular_game then      --检查更新
                        if needUpdate then
                            self:updateGame(v[1],v[2],v[3], popular_game)
                        else
                            self:selectGame(v[1], v[2],popular_game)
                        end
                        
                    end
                end
            
            end)
        elseif bm.tiyan == 1 then
            popular_game:setTouchEnabled(false)
        end
        if gameId ~= "" then
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
                    spMash:setPosition(cc.p(button:getContentSize().width/2 + 68,button:getContentSize().height/2 - 30))
                    spMash:setName("spMash")
                end
            else   --游戏动作
                -- 游戏按钮特效
                -- 区域裁剪
                if bm.tiyan == 0 then
                    if v[8] == 1 then
                        local clipnode = cc.ClippingNode:create()
                        clipnode:setInverted(false)
                        clipnode:setAlphaThreshold(0)
                        clipnode:setScaleY(0.8)

                        local stencil = cc.Node:create()
                        clipnode:setStencil(stencil)
                        local spStnecil = display.newSprite("#"..pic)
                        -- spStnecil:setScaleY(0.8)
                        stencil:addChild(spStnecil)

                        -- 设置目标图片的混合属性
                        local boom_light = display.newSprite("#hall/hall_02/image/action_guang.png")
                        boom_light:setBlendFunc(cc.blendFunc(gl.SRC_ALPHA , gl.ONE))
                        boom_light:setAnchorPoint(cc.p(1.5,0.5))
                        boom_light:setPosition(-50, 0)
                        local mt = cc.MoveTo:create(2, cc.p(button:getContentSize().width-30, 0))
                        local fo = cc.FadeOut:create(0.5)
                        -- local mo = cc.MoveTo:create(0.5, cc.p(-50,0))
                        -- local fi = cc.FadeIn:create(0.5)
                        local function moveEnd() -- , cc.CallFunc:create(moveEnd)
                            boom_light:setOpacity(255)
                            boom_light:setPosition(-50,0)
                        end
                        local flipxAction= cc.FlipX:create(true)
                        action_time=action_time+1
                        local sq = cc.Sequence:create(cc.DelayTime:create(action_time),mt,fo,cc.CallFunc:create(moveEnd))
                        boom_light:runAction(cc.RepeatForever:create(sq))
                        clipnode:addChild(boom_light)

                        clipnode:setPosition(button:getContentSize().width/2+10,button:getContentSize().height/2 + 5)
                        button:addChild(clipnode)
                    end
                else
                    if #game_tiyan>0 then
                        for k1,v1 in pairs(game_tiyan) do
                            if v[1] == v1.gameId then
                                local clipnode = cc.ClippingNode:create()
                                clipnode:setInverted(false)
                                clipnode:setAlphaThreshold(0)
                                clipnode:setScaleY(0.8)

                                local stencil = cc.Node:create()
                                clipnode:setStencil(stencil)
                                local spStnecil = display.newSprite("#"..pic)
                                -- spStnecil:setScaleY(0.8)
                                stencil:addChild(spStnecil)

                                -- 设置目标图片的混合属性
                                local boom_light = display.newSprite("#hall/hall_02/image/action_guang.png")
                                boom_light:setBlendFunc(cc.blendFunc(gl.SRC_ALPHA , gl.ONE))
                                boom_light:setAnchorPoint(cc.p(1.5,0.5))
                                boom_light:setPosition(-50, 0)
                                local mt = cc.MoveTo:create(2, cc.p(button:getContentSize().width-30, 0))
                                local fo = cc.FadeOut:create(0.5)
                                -- local mo = cc.MoveTo:create(0.5, cc.p(-50,0))
                                -- local fi = cc.FadeIn:create(0.5)
                                local function moveEnd() -- , cc.CallFunc:create(moveEnd)
                                    boom_light:setOpacity(255)
                                    boom_light:setPosition(-50,0)
                                end
                                local flipxAction= cc.FlipX:create(true)
                                action_time=action_time+1
                                local sq = cc.Sequence:create(cc.DelayTime:create(action_time),mt,fo,cc.CallFunc:create(moveEnd))
                                boom_light:runAction(cc.RepeatForever:create(sq))
                                clipnode:addChild(boom_light)

                                clipnode:setPosition(button:getContentSize().width/2+10,button:getContentSize().height/2 + 5)
                                button:addChild(clipnode)
                            end
                        end
                    end
                end

            end
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
                        --检查本地版本号

                        if sender == button then

                                if needUpdate then
                                    dump(button, "-----点击按钮，检查更新游戏-----")
                                    self:updateGame(v[1],v[2],v[3], button)
                                else
                                    dump("", "-----点击按钮，选择游戏-----")
                                    self:selectGame(v[1], v[2],button)
                                end
                                
                        end
                

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
    print(a,"多少个游戏")
    if 50 * (a+1) + 25  > 334 then
        content_sv:setInnerContainerSize(cc.size(583.00, 50 * (a+1) + 25 ))
    else
        content_sv:setInnerContainerSize(cc.size(583.00, 334.00 ))
    end

end

--获取组局配置
function gameScene_02:getCreateGroupGameConfig()

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
                        require("hall.GameList"):loadGroupConfig(bm.groupGameConfig)
                    end
                end
            end
        end
    })

end

--检查更新游戏
function gameScene_02:updateGame(id,code,name, btn_sender)

    print("-----大厅更新游戏:".. code .." 状态:" .. require("hall.GameUpdate"):getUpdateStatus())
    dump(btn_sender, "gameScene:updateGame", nesting)

    if require("hall.GameUpdate"):getUpdateStatus() == 0 then
        require("hall.GameUpdate"):queryVersion(id,code,1,name, btn_sender)
    else

        require("hall.GameUpdateLoading"):updateLoading()
    end
    
end

--设置当前游戏
function gameScene_02:selectGame(gid, code,btn_sender)
    USER_INFO["enter_mode"] = gid
    USER_INFO["enter_code"] = code
    if SCENENOW["scene"]:getChildByName("group_create_mj") then
        SCENENOW["scene"]:removeChildByName("group_create_mj")
    end

    if not tolua.isnull(btn_sender) then
        local spMash = btn_sender:getChildByName("spMash")
        if spMash then
            spMash:setVisible(false)
        end
    end
    if bm.tiyan == 0 then
        require("hall.group.create.group_create_mj"):CreateScene()
    else

        if not tolua.isnull(btn_sender) then
            print(btn_sender.inviteCode,"btn_sender.inviteCode")
            require("hall.group.GroupSetting"):enterRoom(btn_sender.inviteCode)    
        end
    end
    if SCENENOW["scene"]:getChildByName("update_loading") then
        SCENENOW["scene"]:removeChildByName("update_loading")
    end
end

function gameScene_02:onEnter()

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
                        require("hall.BraodComponent"):addMessage(sData[1][1]["content"])
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

        else

            self:showNotification()

        end

    end

    print("进入大厅")

    local braodPlane = self._scene:getChildByName("Image_1"):getChildByName("braod_plane")
    if isiOSVerify then
   	 braodPlane:setVisible(false)
    end
    require("hall.BraodComponent"):showBraod(braodPlane)
    
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
        if bm.isProxy then
            user_inf["proxyId"] = USER_INFO['proxyId']
        end
        -- require("hall.GameCommon"):setPlayerHead(user_inf,sp_head,70)
        require("hall.GameCommon"):getUserHead(user_inf["icon_url"], user_inf["uid"], user_inf["sex"], sp_head, 70, true, USER_INFO["nick"])
    end


    self:setSex()

    local Hall_data = require("hall.hall_data")
    Hall_data:init()
end

--检查是否有存在组局返回
function gameScene_02:checkGroupEnd()
    print("checkGroupEnd",require("hall.gameSettings"):getGameMode())
    display_scene("majiang.MJselectChip",1)
end

function gameScene_02:initFinished()

    require("app.HallUpdate"):enterHall()

end

function gameScene_02:doLoginFail()

    dump("", "-----登录失败-----")

    require("hall.LoginScene"):show()

end

function gameScene_02:onExit()
    print("hall exit")
end

--更新金币
function gameScene_02:goldUpdate()
    -- body
    -- self:setScore()
end

-- 支付成功后的处理
function gameScene_02:paySuccessHandle()
    self:refreshRoomCard()
    if self._scene then
        self._scene:runAction(
            cc.Sequence:create(
                cc.DelayTime:create(5),
                cc.CallFunc:create(
                    function ( ... )
                        self:refreshRoomCard()
                    end)
                ))    
    end
end

-- 刷新房卡
function gameScene_02:refreshRoomCard()
    local params = {}
    params["userId"] = USER_INFO["uid"]
    params["interfaceType"] = "J"
    cct.createHttRq({
        url=HttpAddr .. "/roomCard/queryRoomCardCount",
        date= params,
        type_="POST",
        callBack = function(data)
            dump(data, "-----查询房卡数量-----")
            data_netData = json.decode(data["netData"])
            if data_netData.returnCode == "0" then
                --todo
                local sData = data_netData.data.cardCount
                -- dump(data["netData"], "fangka test 1")
                -- dump(sData, "fangka test 2")
                if sData ~= nil then

                    --todo
                    USER_INFO["cardCount"] = sData
                    dump(sData,"nima")
                    dump(USER_INFO["cardCount"], "-----gameScene_02 cardCount 2-----")

                    if tolua.isnull(self.m_txt_score) then
                        return 
                    end

                    self.m_txt_score:setString(sData .. "")

                end
            end
                        
        end
    })
end

--¸üÐÂ½ð±Ò
function gameScene_02:setScore()


end

function gameScene_02:setSex()
    -- body
    local top_base = self._scene:getChildByName("top_base")
    local sex = top_base:getChildByName("img_sex")
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


function gameScene_02:deal_sign_in()
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

function gameScene_02:from_market_back( )
    -- body
end

function gameScene_02:set_hall_base()
    -- body
end

-- 联系客服确定按钮回调事件
function gameScene_02:onCustomServiceCallback()
    
    local url = "http://wpa.b.qq.com/cgi/wpa.php?ln=2&uin=4008352898"
    if url and string.len(url) > 0 then
         cc.Application:getInstance():openURL(url)
     end
end


function gameScene_02:callback_test( )
    -- body
    require("hall.GameTips"):showTips("回调")
end

function gameScene_02:InquireMarket()   --请求商品列表
    local httpurl = HttpAddr2.."front/goods/selectPackageList"
    local params = {}
    cct.createHttRq({
        url = httpurl,
        date = params,
        type_ = "GET", --"POST",

        callBack = function(data)
            data_netData = json.decode(data["netData"])
            if not data_netData then
                print("查询购买房卡信息, 解析失败。。。")
                return 
            end
            -- code = 1,请求成功
            if data_netData.code == "1" then
                --todo
                local sData = data_netData.data
                if table.getn(sData) > 0 then
                    if not self:getChildByName("rechargeaaa") then
                        -- 充值
                        local recharge = Recharge.new(sData)
                        recharge:setName("rechargeaaa")
                        self:addChild(recharge)  
                         if bm.isProxy then
                            if USER_INFO['romm_cards'] then
                                Proxy:BindProxy(USER_INFO['romm_cards'])   
                            else
                                Proxy:BindProxy()
                            end
                        end
                    end
                end
            end
        end
    })

end




return gameScene_02
