
local PlayVideo  = class("PlayVideo")
local targetPlatform = cc.Application:getInstance():getTargetPlatform()

local videoAddress = ""
local decodeType = ""
local isStartLive = 0
local isGetLiveAddress = false
local dtUpdate = 0
local isExitGame = 0


function  PlayVideo:init()

    local layer_ui = SCENENOW["scene"].layer_top
    if layer_ui == nil then
        return
    end

    local btn_live_video = layer_ui:getChildByName("btn_live_video")
    if btn_live_video then
        btn_live_video:setVisible(false)
    end

    if self:regBridgeHandler() == true then
        if btn_live_video and require("hall.group.GroupSetting"):isGroupOwner() then
            btn_live_video:setVisible(true)
        end
    end

    local function touchButtonEvent(sender, event)
        --缩小ui
        if event == TOUCH_EVENT_BEGAN then
            require("hall.GameCommon"):playEffectSound("ddz/audio/Audio_Button_Click.mp3")
        end

        if event == TOUCH_EVENT_ENDED then

            if sender == btn_live_video then--返回赛场选择
                btn_live_video:setEnabled(false)
                -- btn_live_video:setColor(cc.c3b(125,125,125))
                if isStartLive == 0 then
                    if require("hall.group.GroupSetting"):isGroupOwner() then
                        self:startLive()
                    else
                        self:playLive()
                    end
                else
                end
            end
        end
    end

    btn_live_video:addTouchEventListener(touchButtonEvent)--帮助

end

function PlayVideo:setExit()
    isExitGame = 1
end

--网络返回视频地址
function PlayVideo:setVideoAddr(add,flag)
    print("setVideoAddr",type(add),add,flag)
    dump(add, "setVideoAddr")
    if flag == 1 then
        local data = json.decode(add)
        videoAddress = data["liveAddress"]
        decodeType = data["decodeType"]
    end
    local btn_live_video = SCENENOW["scene"].layer_top:getChildByName("btn_live_video")
    if flag == 1 then
    
        print("test3",require("hall.group.GroupSetting"):isGroupOwner(),btn_live_video)
        if require("hall.group.GroupSetting"):isGroupOwner() == false then

            if btn_live_video then
                btn_live_video:setVisible(true)
                self:setStatue(true)
            end
            self:playLive()
        else
            if btn_live_video then
                btn_live_video:setVisible(true)
                self:setStatue(false)
            end
            self:startLive(0)
        end
    else
        if require("hall.group.GroupSetting"):isGroupOwner() == false then
            self:stopPlayLive()
        end
    end
end

--设置按钮状态
function PlayVideo:setStatue(flag)
    local isShowVideo = flag or false
    local btn_live_video = SCENENOW["scene"].layer_top:getChildByName("btn_live_video")
    if btn_live_video then
        if isShowVideo then
            isStartLive = 1
            btn_live_video:loadTextureNormal("ddz/images/live_bt_n.png")
            -- btn_live_video:setColor(cc.c3b(255,255,255))
            btn_live_video:setEnabled(true)
        else
            isStartLive = 0
            btn_live_video:loadTextureNormal("ddz/images/live_bt_p.png")
            -- btn_live_video:setColor(cc.c3b(255,255,255))
            btn_live_video:setEnabled(true)
        end
    end
end

function PlayVideo:update(dt)
    if isGetLiveAddress == false then
        return
    end
    dtUpdate = dt + dtUpdate
    if dtUpdate > 3 then
        dtUpdate = dtUpdate - 3
        self:getLiveInfoFromLocal()
        -- if self:getLiveInfoFromLocal() then
        --     isGetLiveAddress = false
        -- end
    end
end

--本地获取直播参数
function PlayVideo:getLiveInfoFromLocal()
    if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
        print("getLiveInfoFromLocal")
        local data = cc.UserDefault:getInstance():getStringForKey("getLiveData","")
        print("getLiveInfoFromLocal222",data)
        local tbStr=string.split(data,",");

        local tbData = {}
        tbData["command"] = tbStr[1]
        tbData["returnCode"] = tbStr[2]

        dump(tbData, "getLiveInfoFromLocal")
        if tbData == nil or tbData["returnCode"] == nil or tbData["command"] == nil then
            return false
        end
        if tbData["returnCode"] ~= "0" then
            require("hall.GameTips"):showTips(tbStr[3])
        else
            if tbData["command"] == "startLive" then--开直播
                videoAddress = tbStr[3]
                local tbdata = {}
                tbdata["liveAddress"] = tbStr[3]
                tbdata["decodeType"] = tbStr[4]
                dump(tbdata, "getLiveInfoFromLocaltbdata")
                --广播直播地址
                require("ddz.ddzServer"):CLI_SEND_LIVE_ADDRESS(json.encode(tbdata),1)

                isStartLive = 1
                cc.UserDefault:getInstance():setStringForKey("getLiveData","")
            elseif tbData["command"] == "stopLive" then--关直播
                require("ddz.ddzServer"):CLI_SEND_LIVE_ADDRESS("",0)
                cc.UserDefault:getInstance():setStringForKey("getLiveData","")
                isGetLiveAddress = false
                self:setStatue(false)
                isStartLive = 0
                if isExitGame == 1 then
                    require("app.HallUpdate"):enterHall()
                    isExitGame = 0
                end
            elseif tbData["command"] == "playLive" then--看直播
                self:setStatue(true)
                cc.UserDefault:getInstance():setStringForKey("getLiveData","")
                isGetLiveAddress = true
                isStartLive = 1
            elseif tbData["command"] == "stopPlayLive" then--不看直播
                self:setStatue(false)
                isStartLive = 0
                cc.UserDefault:getInstance():setStringForKey("getLiveData","")
                isGetLiveAddress = false
                if isExitGame == 1 then
                    require("app.HallUpdate"):enterHall()
                    isExitGame = 0
                end
            elseif tbData["command"] == "zoomLive" then--缩小
                print("···")
               
                self:setStatue(true)
                 isStartLive = 0
            elseif tbData["command"] == "zoomOutLive" then--变大
                
                self:setStatue(false)
                isStartLive = 1
            end
        end
        return true
    end
    return true
end

--获取直播参数
function PlayVideo:getLiveInfo()
    if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
        print("getLiveInfo")
        local args = {}
        local sigs = "()Ljava/lang/String;"
        local luaj = require "cocos.cocos2d.luaj"
        local className = luaJniClass
        local ok,ret  = luaj.callStaticMethod(className,"getLiveData",args,sigs)
        if not ok then
            print("luaj error:", ret)
        else
            local tbStr=string.split(ret,",");

            local tbData = tb--data[1][1]
            if tbData == nil or tbData["returnCode"] == nil or tbData["command"] == nil then
                return
            end
            if tbData["returnCode"] ~= "0" then
                require("hall.GameTips"):showTips(tbData["errorMessage"])
            else
                if tbData["command"] == "startLive" then--开直播
                    videoAddress = tbData["liveAddress"]
                    local tbdata = {}
                    tbdata["liveAddress"] = tbData["liveAddress"]
                    tbdata["decodeType"] = tbData["decodeType"]
                    --广播直播地址
                    require("ddz.ddzServer"):CLI_SEND_LIVE_ADDRESS(json.encode(tbdata),1)
                elseif tbData["command"] == "stopLive" then--关直播
                    require("ddz.ddzServer"):CLI_SEND_LIVE_ADDRESS("",0)
                    self:setStatue(false)
                elseif tbData["command"] == "playLive" then--看直播
                    self:setStatue(true)
                elseif tbData["command"] == "stopPlayLive" then--不看直播
                    self:setStatue(false)
                end
            end
            --告诉app清直播地址
            sigs = "()V"
            ok,ret  = luaj.callStaticMethod(className,"resetStartLiveData",args,sigs)
            if not ok then
                print("resetStartLiveData error:", ret)
            end
            return true
        end
    else
        return true
    end
    return false
end

function PlayVideo:regBridgeHandler()
    -- body
    if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
        local className = luaJniClass
        local function callbackVideo(param)

            local data = json.decode(param)
            local tbData = data[1][1]

            if tbData == nil or tbData["returnCode"] == nil or tbData["command"] == nil then
                return
            end

            if tbData["returnCode"] ~= "0" then
                require("hall.GameTips"):showTips(tbData["errorMessage"])
            else

                if tbData["command"] == "startLive" then--开直播
                    -- videoAddress = tbData["liveAddress"]
                    -- local tbdata = {}
                    -- tbdata["liveAddress"] = tbData["liveAddress"]
                    -- tbdata["decodeType"] = tbData["decodeType"]

                    -- local data_tst=json.encode(tbdata)

                    -- dump(tbData, "测试安卓发过来的数据")
                    -- print(tbData["liveAddress"],tbData["decodeType"],"测试本身收到的数据")
                    -- dump(data_tst, "测试发送的编码数据")


                    -- --广播直播地址
                    -- xpcall(require("ddz.ddzServer"):CLI_SEND_LIVE_ADDRESS(json.encode(tbdata),1),function()
                    --         printError("出现的错误了")
                    --     end)
                elseif tbData["command"] == "stopLive" then--关直播
                    require("ddz.ddzServer"):CLI_SEND_LIVE_ADDRESS("",0)
                    self:setStatue(false)
                elseif tbData["command"] == "playLive" then--看直播
                    self:setStatue(true)
                elseif tbData["command"] == "stopPlayLive" then--不看直播
                    self:setStatue(false)

                end
            end
        end
        args = { "callbackVideo", callbackVideo }
        sigs = "(Ljava/lang/String;I)V"
        ok = luaj.callStaticMethod(className,"callbackVideo",args,sigs)
        if not ok then
            print("call callback errosr")
        else
            return true
        end

    elseif (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) or (cc.PLATFORM_OS_MAC == targetPlatform) then
        local luaoc = require "cocos.cocos2d.luaoc"
        local function reLoadGame(param,param2)
            print("ocpartemp2")
            print(param,"ocpartemp",param2)

            if "reload" == param then
            end
        end
        luaoc.callStaticMethod("LuaObjectCBridge","registerScriptHandler", {scriptHandler = reLoadGame } )
    else
        return true
    end

    return false
end


--申请直播
function PlayVideo:startLive(send)
    local isSend = send or 1
    if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
        local args = {480-80,0,160,160}
        local sigs = "(IIII)V"
        local luaj = require "cocos.cocos2d.luaj"
        local className = luaJniClass
        local ok,ret  = luaj.callStaticMethod(className,"startLive",args,sigs)
        if not ok then
            print("luaj error:", ret)
        else
            self:setStatue(true)

            if isSend == 1 then
                isGetLiveAddress = true
                dtUpdate = 0
            end
        end
    else
            isGetLiveAddress = true
            dtUpdate = 0
        -- local tbdata = {}
        -- tbdata["liveAddress"] = "alkjdfaljdf a kdflkjsd;lfa"
        -- tbdata["decodeType"] = "R"
        -- --广播直播地址
        -- require("ddz.ddzServer"):CLI_SEND_LIVE_ADDRESS(json.encode(tbdata),1)
    end
end
--关闭直播
function PlayVideo:stopLive()
    --是否已开直播
    -- if isStartLive ~= 1 then
    --     return
    -- end
    if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
        local luaj = require "cocos.cocos2d.luaj"
        local className = luaJniClass
        local ok,ret  = luaj.callStaticMethod(className,"stopLive")
        if not ok then
            print("luaj error:", ret)
        else
            -- self:setStatue(false)
        end
    else
        self:setStatue(false)
    end
end

--观看直播
function PlayVideo:playLive()
    if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
        local args = {480-80,0,160,160,videoAddress,decodeType}
        local sigs = "(IIIILjava/lang/String;Ljava/lang/String;)V"
        local luaj = require "cocos.cocos2d.luaj"
        local className = luaJniClass
        local ok,ret  = luaj.callStaticMethod(className,"playLive",args,sigs)
        if not ok then
            print("luaj error:", ret)
        else
            self:setStatue(true)
        end
    else
        self:setStatue(true)
    end
end
--停止直播
function PlayVideo:stopPlayLive()
    if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
        local luaj = require "cocos.cocos2d.luaj"
        local className = luaJniClass
        local ok,ret  = luaj.callStaticMethod(className,"stopPlayLive")
        if not ok then
            print("luaj error:", ret)
        else
            self:setStatue(false)
        end
    else
        self:setStatue(false)
    end
end

--
function PlayVideo:stopVideo()
    if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
        if require("hall.group.GroupSetting"):isGroupOwner() then
            self:stopLive()
        else
            self:stopPlayLive()
        end
        isGetLiveAddress = true
    else
        if isExitGame == 1 then
            require("app.HallUpdate"):enterHall()
            isExitGame = 0
        end
    end
    -- if isStartLive == 1 then
    -- else
    --     if isExitGame == 1 then
    --         require("app.HallUpdate"):enterHall()
    --         isExitGame = 0
    --     end
    -- end
end


return PlayVideo


