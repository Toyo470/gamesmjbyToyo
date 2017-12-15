fileExitend=".lua";

-- 初始化
import(".src.init")
--初始化本地的config
local Config_File = require("hall.config_file")

confilg_manager=Config_File

local targetPlatform = cc.Application:getInstance():getTargetPlatform()
-- cc.FileUtils:getInstance():addSearchPath("hall/")
local HttpNet = require("hall.HallHttpNet")

--bm的设置
bm.PACKET_DATA_TYPE = import("socket.PACKET_DATA_TYPE")
bm.Logger = import("socket.Logger")
import("socket.functions").exportMethods(bm)
ddzReload = 0
tableIdReload = 0

--local PROTOCOL = require("hall.HALL_PROTOCOL")
local HallServer = import("hall.HallServer")
-- local HallHandle  = require("hall.HallHandle")

--token = "80a34f516354b403b2d620ecbfc5f307" --338

-- token="1b9b9362effcac4c9051cbf19ddcfb1" --414
token="8d3f7c39cbe908e5a2ced25818552104"
local mtKey = "403443447a1449a3f51612f7e3bdd11e"
local bTest = false
isGroup=false
local hall_ip = ""
local hall_port = 4700
local phpLogined = 0

local gameData=require("hall.GameData")
local gameCommom=require("hall.GameCommon")

import(".Video")
import(".netLoad")


local isNewScene=false
local hallScene = class("hallScene", function()
    return display.newScene("hallScene")
end)

function hallScene:ctor()
    -- if needUpdate then

    dump("初始化", "-----hallScene-----")

    isiOSVerify = false

    --语音视频通过什么发送，1为呀呀，2为游戏服
    mediaSendMode = 1

    bm.netdisConnect=false
    bm.SchedulerPool = import("socket.SchedulerPool").new()
    bm.SocketService = require("socket.SocketService")

    bm.server = HallServer.new()
    
    if device.platform == "windows" then
        local filePath =  cc.FileUtils:getInstance():fullPathForFilename( "config.json" )
        local f = io.open( filePath, "r" )
        local t = f:read( "*all" )
        f:close()
        local j=require('json');
        local tb=json.decode(t)
        bm.jsonData=tb.init_cfg;
        dump(tb,"tableData")
    end


  

    --cc.Director:getInstance():setDisplayStats(true);

   -- cc.Director:getInstance():
    -- end

    --连接广播服
    -- if not bm.chat_server then
    --     --todo
    --    bm.chat_server = require("hall.Chat.chatServer").getInstanse("120.76.103.204", 12358)

    -- end
   
end

--进入hallScene
function hallScene:onEnter()

    dump("进入", "-----hallScene-----")

    isNewScene = true

    require("hall.GameCommon"):landLoading(true)
    require("hall.GameCommon"):setLoadingProgress(10)
    require("hall.GameCommon"):showLoadingTips("正为您准备游戏")

    --初始化用户数据
    self:initData()

    if isiOSVerify then 
        -- 请求uid
        HttpNet:reqIosAuditingUID()
    end
end

--初始化用户数据
function hallScene:initData()

    USER_INFO["match_fee"] = 0

    if bTest == false then
        require("hall.GameSetting"):InitData()
    end

    require("hall.GameCommon"):showLoadingTips("进入大厅")

    if bm.server:isConnected() then
        --已经登录过
        print("重新进入大厅")
        self:initFinished()

    else

        --注册回调函数完成
        if (cc.PLATFORM_OS_ANDROID == targetPlatform) then

            cc.Director:getInstance():purgeCachedData();
            local luaj = require "cocos.cocos2d.luaj"
            local className = luaJniClass
            local ok,ret  = luaj.callStaticMethod(className,"autoLogin")

            if not ok then
                print("exitGame luaj error:", ret)
            else
                print("exitGame PLATFORM_OS_ANDROID")
            end

        elseif (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) or (cc.PLATFORM_OS_MAC == targetPlatform) then

            local args = {}
            local luaoc = require "cocos.cocos2d.luaoc"
            local className = "CocosCaller"
            local ok,ret  = luaoc.callStaticMethod(className,"autoLogin")

            if not ok then
                cc.Director:getInstance():resume()
                print("exitGame PLATFORM_OS_IPHONE failed")
            else
                print("exitGame PLATFORM_OS_IPHONE")
            end

        else

            self:initFinished()

        end
    end

end

--初始化完成
function hallScene:initFinished()



    
    --开启心跳检测,这里他们要求loginLayer隐藏的时候开始检测心跳。
    --loginLayer显示的时候不检测心跳包
    bm.checknetworking = true
    -- local loginScene = self:getChildByName("loginLayer")


    --隐藏登陆界面
    local loginScene = SCENENOW["scene"]:getChildByName("loginLayer")
    if loginScene ~= nil then
        --todo
        loginScene:removeFromParent()
    end

    -- bm.isQuickLogin = "1"

    --获取用户数据
    gameData:InitData()
    gameCommom:showLoadingTips("获取用户信息")


    --在这里做一下配置 by zengtao
    if bm.jsonData then
        
        USER_INFO["uid"]=tonumber(bm.jsonData.UID);
        UID=tonumber(bm.jsonData.UID);
        print(bm.jsonData.UID,"bm.jsonData.UID;")
    end


    dump("php登录", "-----php登录-----")
    HttpNet:PHPLogin(USER_INFO["uid"],token,USER_INFO["type"])

    -- if phpLogined == 0 then

    --     -- local isVerify = confilg_manager:get_verify()
    --     -- isVerify = true
    --     -- print("hallScene:onEnter isVerify:"..tostring(isVerify))

    --     isVerify = false

    --     if isVerify then

    --         dump("不知干嘛", "-----php登录-----")

    --         --todo
    --         --  needUpdate=false
    --         local tbData = {}
    --         tbData["level"] = 4
    --         tbData["nickName"] = "¹þ¹þ¹þ"
    --         tbData["photoUrl"] = "http://hbirdtest.oss-cn-shenzhen.aliyuncs.com/(null)userHeader20160410184111.jpg"
    --         tbData["sex"] = 1
    --         USER_INFO["user_info"] = json.encode(tbData)

    --         -- USER_INFO["user_info"]=""
    --         self:PHPLogin({
    --             mtkey="jajsjnalskdnklasnl",
    --             userId=490,
    --             mtKey="zdsdsd",
    --             playerProfile={}
    --         }   
    --         )

    --         -- test
    --         --display_scene("majiang.majiangScene")

    --     else

    --         dump("php登录", "-----php登录-----")

    --         HttpNet:PHPLogin(USER_INFO["uid"],token,USER_INFO["type"])

    --     end

    -- else

    --     dump("进入大厅", "-----php登录-----")

    --     self:enterNormal()

    -- end


    print("hallScene:initFinished")

    -- require("hall.GameSetting"):showGameAwardPool()
end

function hallScene:doLoginFail()

    dump("", "-----登录失败-----")

    require("hall.LoginScene"):show()

end

--Socket登录游戏大厅
function hallScene:enterNormal()

    
    self:connectSocket()

    require("hall.GameCommon"):showLoadingTips("正在连接游戏服务器")
    require("hall.GameCommon"):setLoadingProgress(20)


    
    if bm.server:isConnected() then
        --已经连上scoket 不管
        -- bm.server:disconnect();
        -- bm.server:connect(ip, port, 0)

        -- if bm.isConnectedCount > 1 then
        --     --断线重连

        --     bm.server:disconnect();

        --     self:connectSocket()
        --     require("hall.GameCommon"):showLoadingTips("正在重连游戏服务器")
        --     require("hall.GameCommon"):setLoadingProgress(25)
        --     return
        -- end

        -- bm.isConnectedCount = bm.isConnectedCount + 1

        -- dump("", "-----当前已经连接-----")
        -- self:LoginGame()
        -- require("hall.GameCommon"):showLoadingTips("正在恢复游戏服务器连接")
        -- require("hall.GameCommon"):setLoadingProgress(30)

    else

        dump("", "-----当前没有连接-----")

        
    end

end

function hallScene:connectSocket()

    dump(hall_ip, "-----连接Socket hall_ip-----")
    if bm.server:isConnected() then
        bm.server:disconnect()
    end

    bm.isConnectedCount = 0

    -- bm.server:connect("game." .. hall_ip, hall_port, 0)

    bm.server:connect(hall_ip, hall_port, 0)

    --[[
    if not bm.chat_server then

        local hasGame = string.find(hall_ip, "game")
        dump(hasGame, "-----hasGame-----")
        if hasGame ~= nil then
            local chat_ip = string.gsub(hall_ip, "game", "chat")
            dump(chat_ip, "-----chat_ip-----")
            bm.chat_server = require("hall.Chat.chatServer").getInstanse(chat_ip, 12358)
        else
            bm.chat_server = require("hall.Chat.chatServer").getInstanse(hall_ip, 12358)
        end

       -- bm.chat_server = require("hall.Chat.chatServer").getInstanse("chat." .. hall_ip, 12358)

       -- bm.chat_server = require("hall.Chat.chatServer").getInstanse("120.76.103.204", 12358)

    end
    ]]
    -- showDumpData = false
        
    -- bm.server:connect("192.168.10.90", hall_port, 0)
        
    -- bm.server:connect("192.168.1.129", hall_port, 0)

end

--连接成功
function hallScene:onConnected()
    print("hallScene:onConnected")
    require("hall.GameCommon"):setLoadingProgress(40)
    self:LoginGame()
end

function hallScene:LoginGame()
    require("hall.GameCommon"):setLoadingProgress(60)
    require("hall.GameCommon"):showLoadingTips("登录游戏大厅")
    HallServer:LoginHall()
end

--更新金币
function hallScene:goldUpdate()
    -- body
end

--检查游戏更新
function hallScene:checkGameVersion(data)

    dump(data, "-----检查游戏更新-----")

    require("hall.GameCommon"):showLoadingTips("检查"..tostring(data[3]).."游戏更新")

    --检查版本号
    if require("app.HallUpdate"):checkVersion(data[2], data[4]) == false then
        --没有新版本
        self:gameUpdateFinished()
    else
        --更新新版本
        require("hall.GameUpdate"):queryVersion(data[1], data[2], 0, data[3])
    end

end

--游戏更新完成
function hallScene:gameUpdateFinished()

    dump("", "-----游戏更新完成-----")

    if require("hall.GameList"):isLastUpdate() then

        self:enterNormal()

    else

        local data = require("hall.GameList"):getCurrentUpdateGame()
        dump(data, "gameUpdateFinished")
        if data then
            self:checkGameVersion(data)
        else

        end

    end
end

----------------------------------------------------------------
------------------------- ·µ»ØhttpÏûÏ¢ -------------------------
----------------------------------------------------------------

function hallScene:PHPLogin(userinfo)
    -- body

    require("hall.GameCommon"):setLoadingProgress(20)
    print("enter_mode:"..USER_INFO["enter_mode"])
    if userinfo ~= nil then

        print_lua_table(userinfo)
        local hall = json.decode(userinfo["hall"]) or {{}}
        print_lua_table(hall)

        local tem_ip = confilg_manager:get_ip()

        hall_ip = hall[1]["IP"] or  tem_ip
	if isiOSVerify then
	        hall_ip = "hall.789youxi.com"
	end
        local tem_port = confilg_manager:get_ip_port()
        hall_port = hall[1]["PORT"] or tem_port

        -- hall_ip = "120.25.75.103"
        -- hall_ip = "120.25.216.48"
        --socket登录验证
        hall_ip = "192.168.1.162"
        hall_port = 4700
        if USER_INFO["enter_mode"] >=4 and USER_INFO["enter_mode"]<7 then
            isGroup=true
            require("hall.GameData"):getGroupInfo()
        else
            if USER_INFO["enter_mode"] == 100 then
                print("check update game[zbzd]")
                require("hall.GameData"):getZbzdInfo()
            end
        end
        
        -- end
        USER_INFO["gold"] = userinfo["coinAmount"] or 1000000
        print("HttpLoadGame gold:"..USER_INFO["gold"]) 
        USER_INFO["diamond"] = userinfo["jewelAmount"] or 10000
        print("gold:"..USER_INFO["gold"] )

        USER_INFO["nick"] = userinfo["nickName"] or "luoye"

        USER_INFO["pLevel"] = userinfo["level"] or 100
        USER_INFO["sex"] = tonumber(userinfo["sex"]) or 1
        if userinfo["photoUrl"] then
            USER_INFO["icon_url"] = userinfo["photoUrl"]
        else
            USER_INFO["icon_url"] = ""
        end
        require("hall.HallHttpNet"):land()
        self:enterNormal()
        phpLogined = 1

    end
end

--Http登录
function hallScene:HttpLogin(userinfo,flag)

    print("Http登录验证进入:"..tostring(flag))
    flag = flag or 1
    print("Http登录验证转换:"..tostring(flag))

    if flag == 0 then
        require("hall.GameCommon"):showLoadingTips("登录验证出错")
        return
    end

    --登录成功，设置当前进度为20%
    require("hall.GameCommon"):setLoadingProgress(20)
    if USER_INFO["enter_mode"] then
        print("当前enter_mode:" .. USER_INFO["enter_mode"])
    end
    print("当前mtkey:"..userinfo["mtKey"])

    if userinfo ~= nil then

        if userinfo["mtKey"] == nil then
            require("hall.GameCommon"):showLoadingTips("登录验证失败")
            return
        end

        mtKey = userinfo["mtKey"]
        local ip = 1
        local port = 1
        local hall = userinfo["hall"] or {{}}
        dump(hall, "-----大厅信息-----")

        local tem_ip = confilg_manager:get_ip()
        hall_ip = hall["ip"] or tem_ip
	if isiOSVerify then
	    hall_ip = "hall.789youxi.com"
	end
        print("hall ip:" .. hall_ip)

        local tem_port = confilg_manager:get_ip_port()
        hall_port = hall["port"] or tem_port
        print("hall port:"..hall_port)

        if USER_INFO["type"] == "P" or USER_INFO["type"] == "p" then

            USER_INFO["gold"] = userinfo["playerProfile"]["coinAmount"] or 1000000
            print("HttpLoadGame gold:"..USER_INFO["gold"]) 
            USER_INFO["diamond"] = userinfo["playerProfile"]["jewelAmount"] or 10000
            print("gold:"..USER_INFO["gold"] )

            USER_INFO["nick"] = userinfo["playerProfile"]["nickName"] or "luoye"

            USER_INFO["pLevel"] = userinfo["playerProfile"]["level"] or 100
            USER_INFO["sex"] = tonumber(userinfo["playerProfile"]["sex"]) or 1
            if userinfo["playerProfile"]["photoUrl"] then
                USER_INFO["icon_url"] = userinfo["playerProfile"]["photoUrl"]
            else
                USER_INFO["icon_url"] = ""
            end

        elseif USER_INFO["type"] == "C" or USER_INFO["type"] == "c" then

            USER_INFO["gold"] = userinfo["compereProfile"]["coinAmount"] or 1000000
            print("HttpLoadGame gold:"..USER_INFO["gold"]) 
            USER_INFO["diamond"] = userinfo["compereProfile"]["jewelAmount"] or 10000
            print("gold:"..USER_INFO["gold"] )

            USER_INFO["nick"] = userinfo["compereProfile"]["nickName"] or "luoye"

            USER_INFO["pLevel"] = userinfo["compereProfile"]["level"] or 100
            USER_INFO["sex"] = tonumber(userinfo["compereProfile"]["sex"]) or 1
            if userinfo["compereProfile"]["photoUrl"] then
                USER_INFO["icon_url"] = userinfo["compereProfile"]["photoUrl"]
            else
                USER_INFO["icon_url"] = ""
            end

        end

        dump(USER_INFO["sex"], "-----用户性别-----")

        --获取游戏列表
        -- dump("", "-----开始获取游戏列表-----")
        -- require("hall.HallHttpNet"):land()


        --请求登录大厅
        self:enterNormal()
        phpLogined = 1

    end
end
----------------------------------------------------------------
------------------------- ·µ»ØÍøÂçÏûÏ¢ -------------------------
----------------------------------------------------------------
--登录大厅成功
function hallScene:onNetLoginOK(pack)

end

function hallScene:onExit()
    print("hall exit")
end 

 
-- 渠道跳转  已从loginGame中跳转  IOS还从这里跳
function display_scene(name,flag)
    
    if name=="hall.gameScene" then
        name="hall.gameScene_02"
    end
    -- print(name,"ssssssssssssssssssssssssss")
    if not SCENE[name] or flag == 1 then
        local next = require(name).new()
        SCENENOW["scene"] = next
        SCENENOW["name"]  = name
    else
        SCENENOW["scene"] = SCENE[name]
        SCENENOW["name"]  = name
    end
    display.replaceScene(SCENENOW["scene"])
    -- print(SCENENOW["name"],"xxxxxxxxxxxxxxxxxxxx")
end



local spriteFrameCache = cc.SpriteFrameCache:getInstance()
display=display or {}
function display.loadSpriteFrames(dataFilename, imageFilename, callback)

    if not callback then
        spriteFrameCache:addSpriteFrames(dataFilename, imageFilename)
    else
        spriteFrameCache:addSpriteFramesAsync(dataFilename, imageFilename, callback)
    end

end

return hallScene
