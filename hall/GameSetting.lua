

local targetPlatform = cc.Application:getInstance():getTargetPlatform()
local GameSetting  = class("GameSetting")


local nFreeGameCounts = 0
local nMatchGameCounts = 0
local bShowGameAwardPool = false
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
local luaj 
if device.platform == "android" then
    luaj= require "cocos.cocos2d.luaj"
else
    luaj={}
end

--创建http请求
function GameSetting:InitData()

  --   nFreeGameCounts = cc.UserDefault:getInstance():getIntegerForKey("free_game_counts",0)
  --   if nFreeGameCounts > 0 then
        -- self:HttpAddFreeGame()
  --   end

    self:regBridgeHandler()
    self:regBridgeHandlerForDict()
    
    self:regedisCapture()
    self:regedisVedioUrl();

    -- self:regedisBackClick();

end

function GameSetting:regBridgeHandler()

    -- body
    if device.platform == "android" then
        local className = luaJniClass
        local function callbackLua(param)
            print("callBack",param)
            if "reload" == param then
                print("java call back success")
                -- self:onEnter()   
                -- require("app.MyApp").new():run()
            elseif "applyGameAwardPool" == param then
                self:applyGameAwardPool()

            elseif "endGameAwardPool" == param then
                self:endGameAwardPool()

            elseif "exitGameDouniu" == param then
                --nenggou推出
                audio.stopMusic()
                audio.stopAllSounds()
                print("exit dou niu success")
                _G.runScene:onexitDN()
                _G.runScene:removeSelf()
                _G.runScene=nil
            elseif "goldUpdate"==param then
                if USER_INFO["enter_mode"] > 0 then
                    local next = require("src.app.scenes.MainScene").new()
                    SCENENOW["scene"] = next
                    SCENENOW["name"] = "app.scenes.MainScene"
                    display.replaceScene(next)
                    return
                end
                
               --获取本地金币数据
                require("hall.HallHttpNet"):viewAccount()
            elseif "loginSuccess" == param then--app登录成功

                local  ac=cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function()
                    -- SCENENOW["scene"]:initFinished()
                    require("hall.hallScene"):initFinished()
                end
                ))
                SCENENOW["scene"]:runAction(ac)

                -- require("hall.hallScene"):initFinished()
            elseif "loginFail" == param then--app登录失败
                
                local  ac=cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function()
                    -- SCENENOW["scene"]:initFinished()
                    --只有在登录界面并且登录失败才重新login
                    local loginLayer = SCENENOW["scene"]:getChildByName("loginLayer")
                    if loginLayer then
                        require("hall.LoginScene"):show()
                    end
                    
                end
                ))
                SCENENOW["scene"]:runAction(ac)

            elseif "rechargeSuccess" == param then
                --获取本地金币数据
                require("hall.HallHttpNet"):viewAccount()

            elseif "rechargeFail" == param then

                local  ac=cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function()
                        require("hall.GameTips"):showTips("提示", "", 3, "充值失败!")
                    end
                    ))
                SCENENOW["scene"]:runAction(ac)

            elseif "shareSuccess" == param then

                local ac=cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function()
                        require("hall.GameTips"):showTips("提示", "", 3, "分享成功!")
                    end
                ))
                SCENENOW["scene"]:runAction(ac)

            elseif "shareCancel" == param then

                local ac=cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function()
                        require("hall.NetworkLoadingView.NetworkLoadingView"):removeView()
                    end
                ))
                SCENENOW["scene"]:runAction(ac)

            elseif "YaYaLoginRoomSuccess" == param then

                if not mediaSendMode == 1 then
                    return
                end

                require("hall.util.YaYaVoiceServerUtil"):LoginRoomSuccess()

            elseif "YaYaLogoutRoomSuccess" == param then

                if not mediaSendMode == 1 then
                    return
                end

                local ac=cc.Sequence:create(cc.DelayTime:create(2),cc.CallFunc:create(function()
                        require("hall.util.YaYaVoiceServerUtil"):LogoutRoomSuccess()
                    end
                ))
                SCENENOW["scene"]:runAction(ac)

            elseif "micUpSuccess" == param then

                if not mediaSendMode == 1 then
                    return
                end

                require("hall.util.YaYaVoiceServerUtil"):micUpSuccess()

            elseif "micDownSuccess" == param then

                if not mediaSendMode == 1 then
                    return
                end

                require("hall.util.YaYaVoiceServerUtil"):micDownSuccess()

            elseif "payRoomCardSuccess" == param then

                local ac=cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(
                    function()
                        require("hall.BuyRoomCard.PayChannelScene"):payRoomCardSuccess()
                    end
                ))
                SCENENOW["scene"]:runAction(ac)

            elseif "payRoomCardFail" == param then

                local ac=cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(
                    function()
                        require("hall.BuyRoomCard.PayChannelScene"):payRoomCardFail()
                    end
                ))
                SCENENOW["scene"]:runAction(ac)

            elseif "payRoomCardCancel" == param then

                local ac=cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(
                    function()
                        require("hall.BuyRoomCard.PayChannelScene"):payRoomCardCancel()
                    end
                ))
                SCENENOW["scene"]:runAction(ac)

            elseif "payRoomCardInvalid" == param then

                local ac=cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(
                    function()
                        require("hall.BuyRoomCard.PayChannelScene"):payRoomCardInvalid()
                    end
                ))
                SCENENOW["scene"]:runAction(ac)

            else

                local content = json.decode(param)
                local type = content.type
                if type == "game" then
                    --加入组局

                    local gameInfo = content.gameInfo
                    local invitationCode = gameInfo.invitationCode
                    dump(invitationCode, "-----invitationCode-----")
                    local activityId = gameInfo.activityId
                    local level = gameInfo.level

                    if invitationCode == "agent" then

                        local table = {}
                        table["userId"] = USER_INFO["uid"]
                        table["agentId"] = activityId
                        cct.createHttRq({
                            url = HttpAddr .. "/userBindingAgent",
                            date = table,
                            type_= "POST",
                            callBack = function(data)
                                local responseData = data.netData
                                if responseData then
                                    responseData = json.decode(responseData)
                                    local cacheData = responseData.data
                                    if cacheData then
                                        dump(cacheData, "-----房卡信息-----")

                                        local isBindAgent = cacheData.isBindAgent
                                        if isBindAgent == 1 then

                                            require("hall.BuyRoomCard.AgentScene"):removeScene()

                                        end
                                        
                                    end
                                end
                                
                            end
                        })
                    
                    else

                        require("hall.groudgamemanager"):join_freegame(USER_INFO["uid"], invitationCode, "", false, level, false)

                    end

                elseif type == "msg" then

                    --转发消息

                    local ac=cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(
                        function()

                            local data = content.data
                            local url = data.url
                            if url ~= nil and url ~= "" then

                                local userData = {}
                                userData["uid"] = USER_INFO["uid"]
                                userData["nickName"] = USER_INFO["nick"]
                                userData["invote_code"] = USER_INFO["invote_code"]
                                userData["msgType"] = data.msgType
                                if data.msgType == "voice" then
                                    userData["voiceTime"] = data.voiceTime
                                end
                                userData["url"] = url

                                if userData ~= nil then
                                    local PROTOCOL = import("hall.HALL_PROTOCOL")
                                    if PROTOCOL ~= nil then
                                        local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_CMD_SEND_MSG_TO_SERVER)
                                                    :setParameter("level", USER_INFO["GroupLevel"])
                                                    :setParameter("msg", json.encode(userData))
                                                    :build()
                                        if pack ~= nil then
                                            bm.server:send(pack)
                                        end
                                    end
                                end

                            end

                        end
                    ))
                    SCENENOW["scene"]:runAction(ac)

                end

            end

        end
        args = { "callbacklua", callbackLua }
        sigs = "(Ljava/lang/String;I)V"
        ok = luaj.callStaticMethod(className,"callbackLua",args,sigs)
        if not ok then
            print("call callback errosr")
        end

    elseif (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) or (cc.PLATFORM_OS_MAC == targetPlatform) then
        local luaoc = require "cocos.cocos2d.luaoc"
        local function reLoadGame(param,param2)
            print("ocpartemp2")
            print(param,"ocpartemp",param2)

            if "reload" == param then
                print("object c call back success")
                -- self:onEnter()   
                -- require("app.MyApp").new():run()
            elseif "applyGameAwardPool" == param then
                self:applyGameAwardPool()
            elseif "endGameAwardPool" == param then
                self:endGameAwardPool()
            elseif "exitGameDouniu" == param then
                --nenggou推出
                audio.stopMusic()
                audio.stopAllSounds()
                print("exit dou niu success")
                _G.runScene:onexitDN()
                _G.runScene:removeSelf()
                _G.runScene=nil
            elseif "goldUpdate"==param then
                if USER_INFO["enter_mode"] > 0 then
                    local next = require("src.app.scenes.MainScene").new()
                    SCENENOW["scene"] = next
                    SCENENOW["name"] = "app.scenes.MainScene"
                    display.replaceScene(next)
                    return
                end
               --获取本地金币数据
                require("hall.HallHttpNet"):viewAccount()
            elseif "loginSuccess" == param then

                --app登录成功
                -- SCENENOW["scene"]:initFinished()
                require("hall.hallScene"):initFinished()

            elseif "loginFail" == param then--app登录失败
                require("hall.LoginScene"):show()

            elseif "rechargeSuccess" == param then
                require("hall.HallHttpNet"):viewAccount()

            elseif "rechargeFail" == param then
                require("hall.GameTips"):showTips("提示", "", 3, "充值失败!")

            elseif "shareSuccess" == param then
                require("hall.GameTips"):showTips("提示", "", 3, "分享成功")

            elseif "shareCancel" == param then
                require("hall.NetworkLoadingView.NetworkLoadingView"):removeView()

            elseif "YaYaLoginRoomSuccess" == param then

                if not mediaSendMode == 1 then
                    return
                end

                require("hall.util.YaYaVoiceServerUtil"):LoginRoomSuccess()

            elseif "YaYaLogoutRoomSuccess" == param then

                if not mediaSendMode == 1 then
                    return
                end

                local ac=cc.Sequence:create(cc.DelayTime:create(2),cc.CallFunc:create(function()
                        require("hall.util.YaYaVoiceServerUtil"):LogoutRoomSuccess()
                    end
                ))
                SCENENOW["scene"]:runAction(ac)

            elseif "micUpSuccess" == param then

                if not mediaSendMode == 1 then
                    return
                end

                require("hall.util.YaYaVoiceServerUtil"):micUpSuccess()

            elseif "micDownSuccess" == param then

                if not mediaSendMode == 1 then
                    return
                end

                require("hall.util.YaYaVoiceServerUtil"):micDownSuccess()

            elseif "payRoomCardSuccess" == param then

                print("-----pinghu++-----:".. param)

                local ac=cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(
                    function()
                        require("hall.BuyRoomCard.PayChannelScene"):payRoomCardSuccess()
                    end
                ))
                SCENENOW["scene"]:runAction(ac)

            elseif "payRoomCardFail" == param then

                print("-----pinghu++-----:" .. param)

                local ac=cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(
                    function()
                        require("hall.BuyRoomCard.PayChannelScene"):payRoomCardFail()
                    end
                ))
                SCENENOW["scene"]:runAction(ac)

            elseif "payRoomCardCancel" == param then

                print("-----pinghu++-----:" .. param)

                local ac=cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(
                    function()
                        require("hall.BuyRoomCard.PayChannelScene"):payRoomCardCancel()
                    end
                ))
                SCENENOW["scene"]:runAction(ac)

            elseif "payRoomCardInvalid" == param then

                print("-----pinghu++-----:" .. param)

                local ac=cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(
                    function()
                        require("hall.BuyRoomCard.PayChannelScene"):payRoomCardInvalid()
                    end
                ))
                SCENENOW["scene"]:runAction(ac)

            end
        end
        luaoc.callStaticMethod("LuaObjectCBridge","registerScriptHandler", {scriptHandler = reLoadGame } )
    else

    end
end

--原生回调Lua
function GameSetting:regBridgeHandlerForDict()

    -- body
    if device.platform == "android" then
        local className = luaJniClass
        local function callbackLuaForDict(param)

            dump(param, "-----regBridgeHandlerForDict-----")
            print(type(param))

            if param == "recordDidClose" then
                require("hall.recordUtils.RecordUtils"):didClose()
            end

            local data = json.decode(param)
            local tbData = data[1][1]

            local callbackType = tbData["type"]

            if callbackType == "showAlert" then
                require("hall.GameTips"):showTips("提示", "", 3, tbData["message"])
            elseif callbackType == "recordDidClose" then
                require("hall.recordUtils.RecordUtils"):didClose()
            end
        end
        args = { "callbackLuaForDict", callbackLuaForDict }
        sigs = "(Ljava/lang/String;I)V"
        ok = luaj.callStaticMethod(className,"callbackLuaForDict",args,sigs)
        if not ok then
            print("call callback errosr")
        end

    elseif (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) or (cc.PLATFORM_OS_MAC == targetPlatform) then
        local luaoc = require "cocos.cocos2d.luaoc"
        local function callbackLuaForDictOC(param)

            local data = json.decode(param)
            local tbData = data[1][1]
            
            local callbackType = tbData["type"]

            if callbackType == "showAlert" then
                require("hall.GameTips"):showTips("提示", "", 3, tbData["message"])
            elseif callbackType == "recordDidClose" then
                require("hall.recordUtils.RecordUtils"):didClose()

            elseif callbackType == "setLocation" then
                    userInfo["Longitude"] = tbData["Longitude"]
                    userInfo["Latitude"] = tbData["Latitude"]

                    print("经度：" .. userInfo["Longitude"])
                    print("纬度" .. userInfo["Latitude"])

            elseif callbackType == "joinGame" then   --魔窗回调进入房间

                local invitationCode = tbData["invitationCode"]
                local activityId = tbData["activityId"]
                local level = tbData["level"]
                if invitationCode ~= nil and activityId ~= nil and level ~= nil then

                    if invitationCode == "agent" then

                        local table = {}
                        table["userId"] = USER_INFO["uid"]
                        table["agentId"] = activityId
                        cct.createHttRq({
                            url = HttpAddr .. "/userBindingAgent",
                            date = table,
                            type_= "POST",
                            callBack = function(data)
                                local responseData = data.netData
                                if responseData then
                                    responseData = json.decode(responseData)
                                    local cacheData = responseData.data
                                    if cacheData then
                                        dump(cacheData, "-----房卡信息-----")

                                        local isBindAgent = cacheData.isBindAgent
                                        if isBindAgent == 1 then

                                            require("hall.BuyRoomCard.AgentScene"):removeScene()

                                        end
                                        
                                    end
                                end
                                
                            end
                        })
                    
                    else
                        display_scene("hall.gameScene")  --先返回大厅，防止排行榜界面覆盖在新进的游戏场景上
                        require("hall.groudgamemanager"):join_freegame(USER_INFO["uid"], invitationCode, "", false, level, false)

                    end
                    
                end

            elseif callbackType == "voice" then
                
                local ac=cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(
                    function()

                        local url = tbData["url"]
                        if url ~= nil and url ~= "" then

                            local userData = {}
                            userData["uid"] = USER_INFO["uid"]
                            userData["nickName"] = USER_INFO["nick"]
                            userData["invote_code"] = USER_INFO["invote_code"]
                            userData["msgType"] = "voice"
                            userData["voiceTime"] = tbData[voiceTime]
                            userData["url"] = url

                            if userData ~= nil then
                                local PROTOCOL = import("hall.HALL_PROTOCOL")
                                if PROTOCOL ~= nil then
                                    local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_CMD_SEND_MSG_TO_SERVER)
                                                :setParameter("level", USER_INFO["GroupLevel"])
                                                :setParameter("msg", json.encode(userData))
                                                :build()
                                    if pack ~= nil then
                                        bm.server:send(pack)
                                    end
                                end
                            end

                        end

                    end
                ))
                SCENENOW["scene"]:runAction(ac)

            elseif callbackType == "video" then
                
                local ac=cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(
                    function()

                        local url = tbData["url"]
                        if url ~= nil and url ~= "" then

                            local userData = {}
                            userData["uid"] = USER_INFO["uid"]
                            userData["nickName"] = USER_INFO["nick"]
                            userData["invote_code"] = USER_INFO["invote_code"]
                            userData["msgType"] = "video"
                            userData["url"] = url

                            if userData ~= nil then
                                local PROTOCOL = import("hall.HALL_PROTOCOL")
                                if PROTOCOL ~= nil then
                                    local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_CMD_SEND_MSG_TO_SERVER)
                                                :setParameter("level", USER_INFO["GroupLevel"])
                                                :setParameter("msg", json.encode(userData))
                                                :build()
                                    if pack ~= nil then
                                        bm.server:send(pack)
                                    end
                                end
                            end

                        end

                    end
                ))
                SCENENOW["scene"]:runAction(ac)
                
            end
        end
        luaoc.callStaticMethod("LuaObjectCBridge","registerScriptHandler1", {scriptHandler = callbackLuaForDictOC } )
    else

    end
end

--这里注册了一个切屏的方法
function GameSetting:regedisCapture()
    
    --todo
    if device.platform == "android" then
        local className = luaJniClass
        local function callbackLuaCap(param)
            --cc.Director:getIntense():resume()
            print("callCapturesuccess")
            scheduler.performWithDelayGlobal(function()
                    print("callCapturesuccess2")
                    cct.getScreenPic(param)
                end, 1)
            
        end
        args = { "callbackLuaCap", callbackLuaCap }
        sigs = "(Ljava/lang/String;I)V"
        ok = luaj.callStaticMethod(className,"callbackLuaCap",args,sigs)
        if not ok then
            print("call callback errosr")
        end
    end
end

--这里注册了一个视频的方法
function GameSetting:regedisVedioUrl()
    if device.platform == "android" then
        local className = luaJniClass
        local function setVideoAddr(param)
            print("-----regedisVedioUrl()-----",param)
            --cc.Director:getInstance():resume()
            scheduler.performWithDelayGlobal(function()
                    --param="http://jsdx.sc.chinaz.com/Files/DownLoad/sound1/201606/7449.wav"
                    bm.chat_server:sendVideo(self:getPlayerUid() or {},param)
                end, 1)   
        end
        args = { "setVideoAddr", setVideoAddr }
        sigs = "(Ljava/lang/String;I)V"
        ok = luaj.callStaticMethod(className,"setVideoAddr",args,sigs)
        if not ok then
            print("call callback errosr")
        end
    elseif device.platform=="ios" or device.platform=="iphone" then
        local luaoc = require "cocos.cocos2d.luaoc"
        local function callbackLuaForDictOC(param)
            cc.Director:getInstance():resume()
            scheduler.performWithDelayGlobal(function()
                    bm.chat_server:sendVideo(self:getPlayerUid() or {},param)
                end, 1)
            
        end
        luaoc.callStaticMethod("LuaObjectCBridge","registRecordCallback", {scriptHandler = callbackLuaForDictOC } )
    end
   
end

-- --这里注册了一个返回按钮点击的方法
-- function GameSetting:regedisBackClick()

--     if device.platform == "android" then

--         local className = luaJniClass
--         local function backClick(param)
--             dump(param, "-----返回按钮点击-----")

--         end
--         args = {"backClick", backClick}
--         sigs = "(Ljava/lang/String;I)V"
--         ok = luaj.callStaticMethod(className,"backClick",args,sigs)
--         if not ok then
--             print("call callback errosr")
--         end

--     end
   
-- end


function GameSetting:getPlayerUid()
    return self.uidlist
end

function GameSetting:setPlayerUid(uidlist)
    self.uidlist=uidlist
end

function GameSetting:getPos(uid)
    print("getSeatid",tonumber(uid))
    if uid and SCENENOW["scene"].getPosforSeat  then
        return SCENENOW["scene"]:getPosforSeat(tonumber(uid))
    end

    return {x=0,y=0};
end

function GameSetting:showGameAwardPool()
    -- body
    if bShowGameAwardPool == false then
        return
    end
    if SCENENOW["scene"] then
        local pt = cc.p(200,440)
        local spLottery = display.newSprite("hall/common/sp_lottery.png")
        SCENENOW["scene"]:addChild(spLottery)
        spLottery:setPosition(pt)
        local st1 = cc.ScaleTo:create(1,0.8)
        local st2 = cc.ScaleTo:create(1,1)
        local rt = cc.RotateBy:create(2,360)
        local seq = cc.Sequence:create(st1,st2)
        local swp = cc.Spawn:create(rt,seq)
        local rp = cc.RepeatForever:create(swp)

        spLottery:runAction(rp)
        spLottery:setName("sp_lottery")

        local button = ccui.Button:create()
        button:setTouchEnabled(true)
        button:loadTextures("hall/common/btn_lottery.png",nil,nil)
        -- button:setAnchorPoint(cc.p(0,0))
        button:setPosition(pt)
        SCENENOW["scene"]:addChild(button)
        button:setName("btn_lottery")

        local function touchEvent(sender, event)
            if event == TOUCH_EVENT_ENDED then
                require("hall.GameCommon"):playEffectSound("hall/Audio_Button_Click.mp3")
                if sender == button then
                    --不在比赛中
                    if USER_INFO["match_game_id"] and USER_INFO["match_game_id"] > 0 then
                        local xhr = cc.XMLHttpRequest:new()
                        xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
                        xhr:open("POST", HttpAddr .. "/game/applyGameAwardPool")
                        -- xhr:open("POST", "http://192.168.100.118/hbiInterface/game/applyGameAwardPool")
                        local function onReadyStateChange()
                            if xhr.readyState == 4 and (xhr.status >= 0 and xhr.status < 207) then
                                print(xhr.response)
                                local result = tonumber(json.decode(xhr.response)["returnCode"])
                                print("applyGameAwardPool   ================ >"..tostring(result))
                                if result == 0 then
                                    require("hall.GameTips"):showTips("恭喜你，报名成功")
                                    SCENENOW["scene"]:removeChildByName("btn_lottery")
                                    SCENENOW["scene"]:removeChildByName("sp_lottery")
                                else
                                    self:showTips("报名失败，请再次报名")
                                end
                            else
                                print("xhr.readyState is:", xhr.readyState, "xhr.status is: ",xhr.status)
                            end
                        end
                        xhr:registerScriptHandler(onReadyStateChange)
                        local strPost = "gameId=1".."&userId="..USER_INFO["uid"].."&userType="..USER_INFO["type"]
                        xhr:send(strPost)
                    else
                        require("hall.GameTips"):showTips("彩池已爆，请尽快参与比赛","GameAwardPool",1)
                    end
                end
            end
        end

        button:addTouchEventListener(touchEvent)
    end
end
--结束奖池比赛报名
function GameSetting:endGameAwardPool()
    -- body
    bShowGameAwardPool = false
    if SCENENOW["scene"] then
        if SCENENOW["scene"]:getChildByName("btn_lottery") then
            SCENENOW["scene"]:removeChildByName("btn_lottery")
        end
        if SCENENOW["scene"]:getChildByName("sp_lottery") then
            SCENENOW["scene"]:removeChildByName("sp_lottery")
        end
        require("hall.GameTips"):showTips("彩池活动已结束")
    end
end
--开始报名奖池
function GameSetting:applyGameAwardPool()
    -- body
    bShowGameAwardPool = true
    self:showGameAwardPool()
end


--比赛中报名
--gameid：游戏ID
--uid：用户ID
function GameSetting:PostApplyGameAwardPool()
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    local httpurl = HttpAddr .. "/game/applyGameAwardPool"
    xhr:open("POST", httpurl)
    -- xhr:open("POST", "http://192.168.100.118/hbiInterface/game/applyGameAwardPool")
    local function onReadyStateChange()
        if xhr.readyState == 4 and (xhr.status >= 0 and xhr.status < 207) then
            print(xhr.response)
        else
            print("xhr.readyState is:", xhr.readyState, "xhr.status is: ",xhr.status)
        end
    end
    xhr:registerScriptHandler(onReadyStateChange)
    local strPost = "gameId=1".."&userId="..USER_INFO["uid"].."&userType="..USER_INFO["type"]
    xhr:send(strPost)
    print("applyGameAwardPool ==>"..strPost)
end


--进入比赛
function GameSetting:enterMatch(gid)
    -- body
    USER_INFO["match_game_id"] = gid
end
function GameSetting:UrlGetPic(url)
    -- body
    local strUrl = string.reverse(url)
    local nPos = string.find(strUrl,"/")
    local strPic = nil
    if nPos then
        strPic = string.sub(strUrl,1,nPos-1)
    else
        strPic = strUrl
    end
    strPic = string.reverse(strPic)
    print(strPic)
    return strPic
end
--http获取图片
function GameSetting:PicHttpRequest(url,sp)
    -- body
    local file = nil
    local fileErr = nil
    --链接空，载入默认头像
    if url == nil or url == "" then
        return
    end
    --先在本地获取
    local strHead = self:UrlGetPic(url)
    local imgFullPath = device.writablePath..strHead
    file,fileErr = io.open(imgFullPath)
    if fileErr == nil then
        sp:setTexture(imgFullPath)
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

            if tolua.isnull(sp) == false then
                sp:setTexture(imgFullPath)
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
function GameSetting:urlPicture(url,button)
    -- body
    local file = nil
    local fileErr = nil
    --链接空，载入默认头像
    if url == nil or url == "" then
        return ""
    end
    --先在本地获取
    local strHead = self:UrlGetPic(url)
    local imgFullPath = device.writablePath..strHead
    file,fileErr = io.open(imgFullPath)
    if fileErr == nil then
        if tolua.isnull(button) == false then
            button:loadTextures(imgFullPath,nil,nil)
        end
        return imgFullPath
    else
        local function onRequestFinished(event,filename)
            -- body    
            local ok = (event.name == "completed")
            print("onRequestFinished")
            local request = event.request
            if not ok then
                -- 请求失败，显示错误代码和错误消息
                print(request:getErrorCode(), request:getErrorMessage())
                return ""
            end

            local code = request:getResponseStatusCode()
            if code ~= 200 then
                -- 请求结束，但没有返回 200 响应代码
                print(code)
                return ""
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

            if tolua.isnull(button) == false then
                button:loadTextures(imgFullPath,nil,nil)
            end

            return imgFullPath
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

function GameSetting:urlPictureSprite(url,sp)
    -- body
    local file = nil
    local fileErr = nil
    --链接空，载入默认头像
    if url == nil or url == "" then
        return ""
    end
    --先在本地获取
    local strHead = self:UrlGetPic(url)
    local imgFullPath = device.writablePath..strHead
    file,fileErr = io.open(imgFullPath)
    if fileErr == nil then
        if tolua.isnull(sp) == false then
            sp:setTexture(imgFullPath)
        end
        return imgFullPath
    else
        local function onRequestFinished(event,filename)
            -- body    
            local ok = (event.name == "completed")
            print("onRequestFinished")
            local request = event.request
            if not ok then
                -- 请求失败，显示错误代码和错误消息
                print(request:getErrorCode(), request:getErrorMessage())
                return ""
            end

            local code = request:getResponseStatusCode()
            if code ~= 200 then
                -- 请求结束，但没有返回 200 响应代码
                print(code)
                return ""
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

            if tolua.isnull(sp) == false then
                sp:setTexture(imgFullPath)
            end

            return imgFullPath
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
--创建http请求
function GameSetting:create(strUrl,content,callback)
    print("content size:"..table.getn(content))
    print_lua_table(content)
    local idx = 1
    for key,value in pairs(content) do
        if idx == 1 then
            strUrl = strUrl.."?"..key.."="..value
        else
            strUrl = strUrl.."&"..key.."="..value
        end
        print(strUrl)
        idx = idx + 1
    end

    local req = network.createHTTPRequest(callback,strUrl,"GET")

    req:setTimeout(30)
    req:start()
end
--修改自由场游戏次数
function GameSetting:HttpAddFreeGame()
    --没玩游戏，不请求
    if nFreeGameCounts == 0 then
        return
    end
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    local httpurl = HttpAddr .. "/game/gameNumChanged"
    xhr:open("POST", httpurl)
    local function onReadyStateChange()
        if xhr.readyState == 4 and (xhr.status >= 0 and xhr.status < 207) then
            print("GameSetting:HttpAddFreeGame()")
            print(xhr.response)
            nFreeGameCounts = 0
            cc.UserDefault:getInstance():setIntegerForKey("free_game_counts", nFreeGameCounts)
        else
            print("xhr.readyState is:", xhr.readyState, "xhr.status is: ",xhr.status)
        end
    end
    xhr:registerScriptHandler(onReadyStateChange)
    local strPost = "userId="..tostring(USER_INFO["uid"]).."&userType="..USER_INFO["type"].."&amount="..tostring(nFreeGameCounts)
    xhr:send(strPost)
    print("gameNumChanged ==>"..strPost)
    return true
end

--让原生那边切换用户(现改成通知lua登录失败)
function GameSetting:applyChangeUser()
    if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
         cc.Director:getInstance():purgeCachedData();
   
        local className = luaJniClass
        -- local ok,ret  = luaj.callStaticMethod(className,"applyChangeUser")
        local ok,ret  = luaj.callStaticMethod(className,"loginFail")
        if not ok then
            print("exitGame luaj error:", ret)
        else
            print("exitGame PLATFORM_OS_ANDROID")
        end
    elseif (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) or (cc.PLATFORM_OS_MAC == targetPlatform) then
        local args = {}
        local luaoc = require "cocos.cocos2d.luaoc"
        local className = "CocosCaller"
        -- local ok,ret  = luaoc.callStaticMethod(className,"applyChangeUser")
        local ok,ret  = luaoc.callStaticMethod(className,"loginFail")
        if not ok then
            cc.Director:getInstance():resume()
            print("exitGame PLATFORM_OS_IPHONE failed")
        else
            print("exitGame PLATFORM_OS_IPHONE")
        end
    else
        local next = require("src.app.scenes.MainScene").new()
        SCENENOW["scene"] = next
        SCENENOW["name"] = "app.scenes.MainScene"
        display.replaceScene(next)
    end
end
return GameSetting