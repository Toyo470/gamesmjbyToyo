

local targetPlatform = cc.Application:getInstance():getTargetPlatform()
local GameUpdate  = class("GameUpdate")


local nFreeGameCounts = 0
local nMatchGameCounts = 0

--获取remote更新版本
function GameUpdate:queryVersion(gid,code)
    -- body
    if code == nil then
        return
    end
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    local httpurl = HttpAddr .. "/version/queryVersion"
    xhr:open("POST", httpurl)
    -- xhr:open("POST", "http://192.168.100.118/version/queryVersion")
    local function onReadyStateChange()
        if xhr.readyState == 4 and (xhr.status >= 0 and xhr.status < 207) then
            print(xhr.response)
            local data = json.decode(xhr.response)["data"]
            if data then
                local url = data["updateUrl"]
                local ver = data["version"]
                self:updateGame(url,ver,gid,code)
            else
                self:enterGame(code)
            end
        else
            print("xhr.readyState is:", xhr.readyState, "xhr.status is: ",xhr.status)
        end
    end
    xhr:registerScriptHandler(onReadyStateChange)
    local strPost = "type=3".."&gameId="..tostring(gid)
    xhr:send(strPost)
    print(strPost)
end
--进入游戏
function GameUpdate:enterGame(code)
    -- body
    local strGame = code.."."..code.."Scene"
    display_scene(strGame,1)
end
--更新
function GameUpdate:updateGame(url,version,gid,code)
    -- body
    --检查连接是否正常
    local strUrl = string.lower(url)
    print(strUrl)
    if string.find(strUrl,".zip") == nil then
        self:enterGame(code)
        return
    end

    local strGame = "layout_game"..tostring(gid)
    local layerout = SCENENOW["scene"]._scene:getChildByName("sv_game_list"):getChildByName(strGame)
    local loadingBar = layerout:getChildByName("loading")
    pathToSave = cc.FileUtils:getInstance():getWritablePath()

    local function onError(errorCode)
        if errorCode == cc.ASSETSMANAGER_NO_NEW_VERSION then
            print("no new version")
            self:enterGame(code)
        elseif errorCode == cc.ASSETSMANAGER_NETWORK then
            print("network error")
            self:enterGame(code)
        end

        SCENENOW["scene"]:enableGameButtons(true)
        print("onError:%d",errorCode)
    end

    local function onProgress( percent )
        if nil ~= loadingBar then
            if loadingBar:isVisible() == false then
                loadingBar:setVisible(true)
                local spMash = layerout:getChildByName("spMash")
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
            loadingBar:setPercentage(nPer)
        end
    end

    local function onSuccess()
        print("update success")
        SCENENOW["scene"]:enableGameButtons(true)
        self:enterGame(code)
    end

    local function getAssetsManager()
        if nil == assetsManager then
            print(url)
            print(version)
            assetsManager = cc.AssetsManager:new(url,version,pathToSave)
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

    local function onNodeEvent(msgName)
        if nil ~= assetsManager then
            assetsManager:release()
            assetsManager = nil
            print("release assets manager")
        end
    end

    print("scene name[%s]"..SCENENOW["name"])
    SCENENOW["scene"]:registerScriptHandler(onNodeEvent)
end

return GameUpdate