

local targetPlatform = cc.Application:getInstance():getTargetPlatform()
local GameUpdate  = class("GameUpdate")


local nFreeGameCounts = 0
local nMatchGameCounts = 0
local updateStatus = 0


--local timerOut=10
--local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
local assetsManager

local assersTools
if isTaoAndroid then
    --todo
    assersTools=require("downLoading")
end

--获取服务器版本
function GameUpdate:queryVersion(gid,code,bSee,name, btn_sender)

    bSee = bSee or 1
    if not code then
        return
    end

    print("queryVersion needUpdate",tostring(needUpdate))

    if not needUpdate then
        --todo
        if bSee >0 then
            --todo
            self:enterGame(code)
        else 
            --todo
            self:enterScene(code)
        end
        return;   
    end

     cct.httpReq2({

            url=HttpAddr.."/version/queryVersion",
            data={
                type=3,
                gameId=tostring(gid)
            },
           
            callBack=function(data)

                local data=data.data;
                if data then
                    local Manual = data["isManual"]
                    local url = data["updateUrl"]
                    local ver = data["version"]
                    -- self:checkLocalVersion(code)
                    dump(data, "queryVersion")
                    if bSee > 0 then
                        if Manual > 0 then
                            self:updateGame(url,ver,gid,code, btn_sender)
                        else
                            self:showTips(code,name,url,ver,gid)
                        end
                    else
                        self:updteGameUnsee(url,ver,gid,code)
                    end
                else
                    --self:queryVersion(gid,code,bSee,name);
                    --return;
                end

           

            end
            ,
            type_='GET'

        
        })

    --[[local h
    
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    local httpurl = HttpAddr .. "/version/queryVersion"
    xhr:open("POST", httpurl)
    print("queryVersion ===== >" .. httpurl)

    local function onReadyStateChange()
        if xhr.readyState == 4 and (xhr.status >= 0 and xhr.status < 207) then
            print(xhr.response)
            xhr.success=true;
            if h then
                --todo
                scheduler.unscheduleGlobal(h)
            end
            
            local data = json.decode(xhr.response)["data"]
            if data then
                local Manual = data["isManual"]
                local url = data["updateUrl"]
                local ver = data["version"]
                -- self:checkLocalVersion(code)
                dump(data, "queryVersion")
                if bSee > 0 then
                    if Manual > 0 then
                        self:updateGame(url,ver,gid,code, btn_sender)
                    else
                        self:showTips(code,name,url,ver,gid)
                    end
                else
                    self:updteGameUnsee(url,ver,gid,code)
                end
            else
                self:queryVersion(gid,code,bSee,name);
                return;
            end
        else
            -- print("xhr.readyState is:", xhr.readyState, "xhr.status is: ",xhr.status)
            -- if USER_INFO["enter_mode"] > 0 then
            --     self:enterScene(code)
            -- else
            --     self:enterGame(code)
            -- end
        end
    end

    xhr:registerScriptHandler(onReadyStateChange)
    local strPost = "type=3".."&gameId="..tostring(gid)
    xhr:send(strPost)
    




    print("USER_INFOnter_mode", USER_INFO["enter_mode"])
    if  USER_INFO["enter_mode"] ~=0 then
        --todo
        xhr.success=false;
        h=scheduler.performWithDelayGlobal(function()
            if not xhr.success then --请求版本失败
                --todo
                --网络异常
                --self:showLoadingTips("请求大厅版本超时");
                --重新开始
                --require(modname)
                -- if isGroup then
                if require("hall.gameSettings"):getGameMode() == "group" then
                    require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])
                else
                    require("hall.GameCommon"):gExitGame();
                end
                
            end
            scheduler.unscheduleGlobal(h)
        end, timerOut)
    end
    
    print(strPost)
    ]]
end

--非强制，提示更新
function GameUpdate:showTips(code,game,url,ver,gid)
    -- body
    print("show tips")
    if SCENENOW["scene"] then
        local s = cc.CSLoader:createNode("hall/LayerTips.csb")
        s:setName("layer_tips")
        SCENENOW["scene"]:addChild(s)
        local layer = s:getChildByName("tips_back_1")
        local txt = layer:getChildByName("txt_msg")
        if txt then
            txt:setString("更新"..game.."游戏")
            txt:enableOutline(cc.c4b(58,35,10,255),1)
        end
        local lbTitle = layer:getChildByName("txt_title")
        if lbTitle then
            lbTitle:enableOutline(cc.c4b(58,35,10,255),1)
        end

        local btnSubmit = layer:getChildByName("btn_submit")
        local btnCancel = layer:getChildByName("btn_cancel")

        
            local function touchEvent(sender, event)
                if event == TOUCH_EVENT_ENDED then
                    require("hall.GameCommon"):playEffectSound("hall/Audio_Button_Click.mp3")
                    if sender == btnSubmit then
                        if SCENENOW["scene"]:getChildByName("layer_tips") then
                            SCENENOW["scene"]:removeChildByName("layer_tips")
                        end
                        self:updateGame(url,ver,gid,code)
                    end
                    if sender == btnCancel then
                        if SCENENOW["scene"]:getChildByName("layer_tips") then
                            SCENENOW["scene"]:removeChildByName("layer_tips")
                        end
                        self:enterGame(code)
                    end
                end
            end

            btnSubmit:addTouchEventListener(touchEvent)
            btnCancel:addTouchEventListener(touchEvent)

    end

end

--检验本地版本
function GameUpdate:checkLocalVersion(code)
    -- body
    local strKey = code.."_current-version"
    local strVersion = cc.UserDefault:getInstance():getStringForKey(strKey,"")
    print(strKey..":"..strVersion)
    local nPos = string.len(strVersion)
    if nPos > 40 then
        cc.UserDefault:getInstance():setStringForKey(strKey,"")
    end
end

--进入游戏
function GameUpdate:enterGame(code)
    -- bodyenterGame

    dump(code, "-----游戏更新,进入游戏-----")

    code = code or "hall"
    print("entered hall game code id ",code)
    local strGame = code.."."..code.."Scene"
    USER_INFO["current_code"] = code
    print(strGame)
    if device.platform=="android" then
        print("啦啦啦啦啦啦啦啦啦啦啦")
        if _G.notifiLayer.rootNode then
            _G.notifiLayer.rootNode:show();
        end
    end
    display_scene(strGame,1)
    -- end
end

--直接进入游戏
function GameUpdate:enterScene(code)
    -- body
    -- print("zhixingenterScene",USER_INFO["enter_game"])
    -- print("zhixingenterScene",code)

    -- local strGame = code..".".."gameScene"
    -- display_scene(strGame,1)
    if require("hall.GameList"):getReloadTable() > 0 then
        self:enterGroup(code)
    else
        if  SCENENOW["name"] == "hall.hallScene" then
            print("啦啦啦啦啦啦啦啦啦啦啦")
            SCENENOW["scene"]:gameUpdateFinished()
        end
    end

end

--进入组局
function GameUpdate:enterGroup(code)
    print("zhixingenterScene",USER_INFO["enter_game"])
    print("zhixingenterScene",code)

    require("hall.gameSettings"):setGroupState(0)
    local strGame = code .. "." .."gameScene"
    if device.platform=="android" then
        if _G.notifiLayer.rootNode then
            _G.notifiLayer.rootNode:show();
        end
    end
    display_scene(strGame,1)
end

--获取更新状态
function GameUpdate:getUpdateStatus()
    -- body
    return updateStatus
end

--设置更新状态
function GameUpdate:setUpdateStatus(status)
    -- body
    updateStatus = status
end

--更新
function GameUpdate:updateGame(url,version,gid,code,btn_sender)

    dump(url, "-----游戏更新信息url-----")
    dump(version, "-----游戏更新信息version-----")
    dump(gid, "-----游戏更新信息gid-----")
    dump(code, "-----游戏更新信息code-----")
    dump(btn_sender, "-----游戏更新信息btn_sender-----")
    if  tolua.isnull(btn_sender) then
        return;
    end

    if assetsManager then
         --require("hall.GameTips"):showTips("提示", "GameupdateError", 3, "另一个游戏正在下载中...", nil)
         return;
    end

    --检查连接是否正常
    local strUrl = string.lower(url)
    dump(strUrl, "-----游戏更新地址-----")
    if string.find(strUrl,".zip") == nil then
        print("-----游戏更新string.find(strUrl，.zip) == nil-----")
        self:enterGame(code)
        return
    end

    --检查本地版本号
    if require("app.HallUpdate"):checkVersion(code,version) == false then
        print("-----检查本地版本号，返回不用更新游戏-----")

        --设置当前选择的游戏
        -- if SCENENOW["name"] == "hall.gameScene" then
            SCENENOW["scene"]:selectGame(gid, code,btn_sender)
        -- end
        
        return
    end

    dump(code, "-----进入更新游戏-----")

    updateStatus = 1

    local strGame = "layout_game" .. tostring(gid)


    print(strGame)
    local loadingBar = btn_sender:getChildByName("loading")


    dump(strGame, "-----下载圈设置完毕-----")


    local pathToSave = ""
    pathToSave = cc.FileUtils:getInstance():getWritablePath()
    if cc.FileUtils:getInstance():isDirectoryExist(pathToSave.."/"..code) then
        cc.FileUtils:getInstance():removeDirectory(pathToSave.."/"..code);
    end


    dump(pathToSave, "-----储存路径-----")

    local function onError(errorCode)

        dump(errorCode, "-----更新游戏出错，错误码-----")

        local gamedata = {}
        gamedata.url = url
        gamedata.version = version
        gamedata.gid = gid
        gamedata.code = code

        if nil ~= assetsManager then
            assetsManager:release()
            assetsManager = nil
            print("release assets manager")
        end

        updateStatus = 0

        if errorCode == cc.ASSETSMANAGER_NO_NEW_VERSION then

            print("no new version")
            self:enterGame(code)

        elseif errorCode == cc.ASSETSMANAGER_NETWORK then

            print("network error")
            -- require("hall.GameTips"):showTipsUpdate("网络异常下载更新失败",url,version,gid,code)
            
            require("hall.GameTips"):showTips("提示", "GameupdateError", 3, "网络异常，下载更新失败", gamedata)

             --exit game
            --self:enterGame(code)
        else

            -- require("hall.GameTips"):showTipsUpdate("更新出错",url,version,gid,code)
            require("hall.GameTips"):showTips("提示", "GameupdateError", 3, "下载更新失败，请稍候再试", gamedata)

        end

    end
    local loading_txt=cc.Label:createWithTTF("","res/fonts/fzcy.ttf",28)   --创建 游戏项 loading 条的 文字百分比
    loadingBar:addChild(loading_txt)
    loading_txt:setName("loading_txt")
    loading_txt:setColor(cc.c3b(250, 250, 0))
    loading_txt:setPosition(loadingBar:getPositionX(),loadingBar:getPositionY()-10)
    local function onProgress(percent)
        if tolua.isnull(loadingBar) then 
            return
        end

        require('hall.GameUpdateLoading'):setpercent(percent)  --获取loding数据

        if nil ~= loadingBar then
            if loadingBar:isVisible() == false then
                loadingBar:setVisible(true)
                --去掉更新图标
                local spMash = btn_sender:getChildByName("spMash")
                if spMash then
                    spMash:setVisible(false)
                end
            end

            local nPer = 100 - percent
            if nPer < 0 then
                nPer = 0

            elseif nPer > 100 then
                nPer = 100             
            end
            if loadingBar:getChildByName("loading_txt") then  --刷新进度百分比
                loading_txt:setString(tostring(percent).."%")
            end
            if percent==100 then   --加载时完成消失
                if loadingBar:getChildByName("loading_txt") then
                loadingBar:removeChildByName("loading_txt")
            end
            end
            loadingBar:setPercentage(nPer)
        end

    end

    local function onSuccess()
        
        dump(SCENENOW["name"], "-----更新游戏成功，当前情景是-----")

        updateStatus = 0
        local strKey = code .. "_current-version"
        cc.UserDefault:getInstance():setStringForKey(strKey,version)


        if nil ~= assetsManager then
            assetsManager:release()
            assetsManager = nil
            print("release assets manager")
        end

        --设置当前选择的游戏
        -- if SCENENOW["name"] == "hall.gameScene" then
            print(tostring(strKey), tostring(gid), tostring(code))
            SCENENOW["scene"]:selectGame(gid, code,btn_sender)
        -- end

    end

    local function getAssetsManager()

        if nil == assetsManager then
            dump(url, "-----更新游戏getAssetsManager-----")
            if isTaoAndroid then
                 assetsManager = cc.AssetsManager:new(url,code..".zip","")
            else
                 assetsManager = cc.AssetsManager:new(url,version,pathToSave)
            end
            dump(version, "-----更新游戏getAssetsManager-----")
           -- assetsManager = cc.AssetsManager:new(url,version,pathToSave)
            assetsManager:retain()
            assetsManager:setDelegate(onError, cc.ASSETSMANAGER_PROTOCOL_ERROR )
            assetsManager:setDelegate(onProgress, cc.ASSETSMANAGER_PROTOCOL_PROGRESS)
            assetsManager:setDelegate(onSuccess, cc.ASSETSMANAGER_PROTOCOL_SUCCESS )
            assetsManager:setConnectionTimeout(3)
        end

        return assetsManager

    end

    getAssetsManager():update()

    --[[
    local function onNodeEvent(msgName)
        if nil ~= assetsManager then
            assetsManager:release()
            assetsManager = nil
            print("release assets manager")
        end
    end

    print("更新游戏，当前场景名：scene name[%s]",SCENENOW["name"])

    SCENENOW["scene"]:registerScriptHandler(onNodeEvent)
    ]]
end






--非视更新
function GameUpdate:updteGameUnsee(url,version,gid,code)
    -- body
    if assetsManager then
         --require("hall.GameTips"):showTips("提示", "GameupdateError", 3, "另一个游戏正在下载中...", nil)
         return;
    end


    --检查本地版本号
    if require("app.HallUpdate"):checkVersion(code,version) == false then
        self:enterScene(code)
        return
    end

    local assetsManager = nil
    local pathToSave = ""
    local strGame = "game"..tostring(id)

    require("hall.GameCommon"):showLoadingTips("正在更新游戏")
    pathToSave = cc.FileUtils:getInstance():getWritablePath()

    updateStatus = 1

    if cc.FileUtils:getInstance():isDirectoryExist(pathToSave.."/"..code) then
        cc.FileUtils:getInstance():removeDirectory(pathToSave.."/"..code);
    end

    local function onError(errorCode)

        local gamedata = {}
        gamedata.url = url
        gamedata.version = version
        gamedata.gid = gid
        gamedata.code = code

        if nil ~= assetsManager then
            assetsManager:release()
            assetsManager = nil
            print("release assets manager")
        end

        updateStatus = 0
        if errorCode == cc.ASSETSMANAGER_NO_NEW_VERSION then
            print("no new version")
            self:enterScene(code)
        elseif errorCode == cc.ASSETSMANAGER_NETWORK then
            print("network error")
            -- require("hall.GameTips"):showTipsUpdate("网络异常下载更新失败",url,version,gid,code,0)

            require("hall.GameTips"):showTips("提示", "GameupdateError", 3, "网络异常，下载更新失败", gamedata)


        else
            -- require("hall.GameTips"):showTipsUpdate("更新出错",url,version,gid,code,0)

            require("hall.GameTips"):showTips("提示", "GameupdateError", 3, "下载更新失败，请稍候再试", gamedata)

        end

        print("onError:%d",errorCode)

    end

    local function onProgress(percent)
        if SCENENOW["name"] == "hall.hallScene" then
            require("hall.GameCommon"):setLoadingProgress(percent)
        end
    end

    local function onSuccess()
        print("updteGameUnsee success")
        updateStatus = 0
        -- if USER_INFO["reload_type"] then
        --     --todo
        --     if USER_INFO["reload_type"] == "R" or USER_INFO["reload_type"] == "r" then
        --         USER_INFO["enter_mode"] = require("hall.hall_data"):getGameID()
        --         require("hall.gameSettings"):setGameMode("group")
        --         require("hall.groudgamemanager"):requestGroupStatus(true)
        --     else
        --         require("hall.HallHandle"):reloadGame(data["gameId"])
        --     end
            
        -- end
         if nil ~= assetsManager then
            assetsManager:release()
            assetsManager = nil
            print("release assets manager")
        end
        self:enterScene(code)
    end

    local function getAssetsManager(strGame)
        if nil == assetsManager then

             if isTaoAndroid then
                 assetsManager = cc.AssetsManager:new(url,code..".zip","")
            else
                 assetsManager = cc.AssetsManager:new(url,version,pathToSave)
            end
            --assetsManager = cc.AssetsManager:new(url,version,pathToSave)
            assetsManager:retain()
            assetsManager:setDelegate(onError, cc.ASSETSMANAGER_PROTOCOL_ERROR )
            assetsManager:setDelegate(onProgress, cc.ASSETSMANAGER_PROTOCOL_PROGRESS)
            assetsManager:setDelegate(onSuccess, cc.ASSETSMANAGER_PROTOCOL_SUCCESS )
            assetsManager:setConnectionTimeout(3)
        end

        return assetsManager
    end

    getAssetsManager():update()
    --[[
    local function onNodeEvent(msgName)
        if nil ~= assetsManager then
            assetsManager:release()
            assetsManager = nil
            print("release assets manager")
        end
    end

    SCENENOW["scene"]:registerScriptHandler(onNodeEvent)]]
end

function GameUpdate:getState()
    -- body
    return updateStatus
end

-------------------------------------------------------------------------------------------------------------------------------------------------

--获取游戏最新版本（加入组局时用）
function GameUpdate:queryVersionInJoinGame(gid,code,bSee,name)

    dump("", "-----检查游戏版本（加入组局时用）-----")

    bSee = bSee or 1
    if not code then
        return
    end

    --假如配置中记录不需要更新，则直接进入游戏
    if not needUpdate then
        require("hall.GameUpdate"):enterGroup(USER_INFO["enter_code"])
        return;   
    end
    local pathToSave=cc.FileUtils:getInstance():getWritablePath();

     if cc.FileUtils:getInstance():isDirectoryExist(pathToSave.."/"..code) then
        cc.FileUtils:getInstance():removeDirectory(pathToSave.."/"..code);
    end

    cct.httpReq2({

            url=HttpAddr.."/version/queryVersion",
            data={
                type=3,
                gameId=tostring(gid)
            },
           
            callBack=function(data)

                local data=data.data;
                if data then
                    local Manual = data["isManual"]
                    local url = data["updateUrl"]
                    local ver = data["version"]

                    --更新游戏
                    self:updateGameInJoinGame(url,ver,gid,code)

            
                end

           

            end
            ,
            type_='GET'

        
        })
    --[[

    local h
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    local httpurl = HttpAddr .. "/version/queryVersion"
    xhr:open("POST", httpurl)
    print("获取服务器版本的链接 ===== >" .. httpurl)

    local function onReadyStateChange()
        if xhr.readyState == 4 and (xhr.status >= 0 and xhr.status < 207) then
            print(xhr.response)
            xhr.success=true;
            if h then
                --todo
                scheduler.unscheduleGlobal(h)
            end
            
            local data = json.decode(xhr.response)["data"]
            if data then
                local Manual = data["isManual"]
                local url = data["updateUrl"]
                local ver = data["version"]
                -- self:checkLocalVersion(code)
                -- dump(data, "queryVersion")
                -- if bSee > 0 then
                --     if Manual > 0 then
                --         --更新游戏
                --         self:updateGameInJoinGame(url,ver,gid,code)
                --     else
                --         -- self:showTips(code,name,url,ver,gid)
                --     end
                -- else
                --     -- self:updteGameUnsee(url,ver,gid,code)
                -- end


                --更新游戏
                self:updateGameInJoinGame(url,ver,gid,code)

            else
                --重新获取游戏版本
                self:queryVersionInJoinGame(gid,code,bSee,name);
                return;
            end

        else
            --重新获取游戏版本
            self:queryVersionInJoinGame(gid,code,bSee,name);
        end
    end

    xhr:registerScriptHandler(onReadyStateChange)
    local strPost = "type=3".."&gameId="..tostring(gid)
    xhr:send(strPost)

    print("USER_INFOnter_mode", USER_INFO["enter_mode"])
    if USER_INFO["enter_mode"] ~=0 then
        --todo
        xhr.success=false;
        h=scheduler.performWithDelayGlobal(function()
            if not xhr.success then --请求版本失败
                --网络异常
                require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])
                
            end
            scheduler.unscheduleGlobal(h)
        end, timerOut)
    end
    
    print(strPost)
    ]]



end

--更新游戏（加入组局时用）
function GameUpdate:updateGameInJoinGame(url,version,gid,code)

    dump("", "-----更新游戏（加入组局时用）-----")
    if assetsManager then
         --require("hall.GameTips"):showTips("提示", "GameupdateError", 3, "另一个游戏正在下载中...", nil)
         return;
    end

    --检查连接是否正常
    local strUrl = string.lower(url)
    dump(strUrl, "-----游戏更新地址-----")
    if string.find(strUrl,".zip") == nil then
        require("hall.GameUpdate"):enterGroup(USER_INFO["enter_code"])
        return
    end

    --检查本地版本号
    if require("app.HallUpdate"):checkVersion(code,version) == false then
        print("-----检查本地版本号，返回不用更新游戏，则直接进入游戏-----")
        require("hall.GameUpdate"):enterGroup(USER_INFO["enter_code"])
        return
    end

    updateStatus = 1

    local assetsManager = nil
    local pathToSave = ""

    -- if SCENENOW["name"] == "hall.gameScene" then
        require("hall.GameCommon"):showLoadingTips("正在更新游戏")
    -- end
    pathToSave = cc.FileUtils:getInstance():getWritablePath()

     if cc.FileUtils:getInstance():isDirectoryExist(pathToSave.."/"..code) then
        cc.FileUtils:getInstance():removeDirectory(pathToSave.."/"..code);
    end
    --更新错误处理
    local function onError(errorCode)

        updateStatus = 0

        if nil ~= assetsManager then
            assetsManager:release()
            assetsManager = nil
        end

        local data = {}
        data["url"] = url
        data["version"] = version
        data["gid"] = gid
        data["code"] = code

        if errorCode == cc.ASSETSMANAGER_NO_NEW_VERSION then
            --没有新版本，直接进入游戏
            require("hall.GameUpdate"):enterGroup(USER_INFO["enter_code"])

        elseif errorCode == cc.ASSETSMANAGER_NETWORK then
            --网络不可用
            -- require("hall.GameTips"):showTipsUpdate("网络异常下载更新失败",url,version,gid,code)

            require("hall.GameTips"):showTips("更新游戏", updateGame, 1, "网络异常", data)

        else
            --其他原因导致更新出错
            -- require("hall.GameTips"):showTipsUpdate("更新出错",url,version,gid,code)

            require("hall.GameTips"):showTips("更新游戏", updateGame, 1, "更新游戏出错", data)

        end

        print("onError:%d",errorCode)

    end

    --更新进度显示
    local function onProgress(percent)
        dump(code .. ":" ..percent, "-----游戏更新，当前进度-----")
        -- if SCENENOW["name"] == "hall.gameScene" then
            require("hall.GameCommon"):setLoadingProgress(percent)
        -- end
    end

    local function onSuccess()
        
        dump(SCENENOW["name"], "-----更新游戏成功，进入游戏，当前场景是：-----")

        --重置更新状态
        updateStatus = 0

        local strKey = code .. "_current-version"
        cc.UserDefault:getInstance():setStringForKey(strKey,version)
        --进入游戏
        -- if SCENENOW["name"] == "hall.gameScene" then
        --    require("hall.GameUpdate"):enterGroup(USER_INFO["enter_code"])
        -- end

        if nil ~= assetsManager then
            assetsManager:release()
            assetsManager = nil
        end


        require("hall.GameUpdate"):enterGroup(USER_INFO["enter_code"])

    end

    local function getAssetsManager()
        if nil == assetsManager then
            print(url)
            print(version)
             if isTaoAndroid then
                 assetsManager = cc.AssetsManager:new(url,code..".zip","")
            else
                 assetsManager = cc.AssetsManager:new(url,version,pathToSave)
            end
            --assetsManager = cc.AssetsManager:new(url,version,pathToSave)
            -- assetsManager = cc.AssetsManager:new(strFile,strVersion,pathToSave)
            assetsManager:retain()
            assetsManager:setDelegate(onError, cc.ASSETSMANAGER_PROTOCOL_ERROR )
            assetsManager:setDelegate(onProgress, cc.ASSETSMANAGER_PROTOCOL_PROGRESS)
            assetsManager:setDelegate(onSuccess, cc.ASSETSMANAGER_PROTOCOL_SUCCESS )
            assetsManager:setConnectionTimeout(3)
        end

        return assetsManager
    end

    getAssetsManager():update()
    --[[
    local function onNodeEvent(msgName)
        if nil ~= assetsManager then
            assetsManager:release()
            assetsManager = nil
            print("release assets manager")
        end
    end

    print("scene name[%s]",SCENENOW["name"])
    SCENENOW["scene"]:registerScriptHandler(onNodeEvent)]]
    
end

return GameUpdate