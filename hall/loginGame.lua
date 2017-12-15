--
-- Author: Zeng Tao
-- Date: 2017-03-30 21:46:38
--

-- 初始化

fileExitend=".lua";

import(".src.init")

bm.PACKET_DATA_TYPE = import("socket.PACKET_DATA_TYPE")
bm.Logger = import("socket.Logger")
import("socket.functions").exportMethods(bm)



local gameCommom=require("hall.GameCommon")


local loginHelp=require("hall.iosHelps")

local HallServer = import("hall.HallServer")
import(".netLoad")

local loginObj;

local loginGame=class("loginGame",function ( ... )
	-- body
	return display.newScene("loginGame")
end)
local userdefine=cc.UserDefault:getInstance()

function loginGame:ctor(data)
	-- body
	dump("初始化", "-----hallScene-----")

    print("这里用的是久的loginGame")
 
    

    if not bm.server  then
        --todo

        require("hall.GameSetting"):InitData()
        require("hall.GameData"):InitData()

        bm.netdisConnect=false
        bm.SchedulerPool = import("socket.SchedulerPool").new()
        bm.SocketService = require("socket.SocketService")
  
        bm.server = HallServer.new()

    end



    
    bm.isLoginScene = 0
 
    
    if device.platform == "windows" then
        local filePath =  cc.FileUtils:getInstance():fullPathForFilename( "config.json" )
        local f = io.open( filePath, "r" )
        local t = f:read( "*all" )
        f:close()
        local tb=json.decode(t)
        bm.jsonData=tb.init_cfg;
        dump(tb,"tableData")
    end



   


	if loginObj==nil then
        --todo
        loginObj=loginHelp.new(function ( msg )
          -- body
          gameCommom:showLoadingTips(msg)
        end);
    end
    


    self.login=loginObj


end


--Http登录
function loginGame:HttpLogin(userinfo,flag)


	UID=USER_INFO["uid"]



    print("Http登录验证进入:"..UID)
    flag = flag or 1
    print("Http登录验证转换:"..tostring(flag))

    if flag == 0 then
        require("hall.GameCommon"):showLoadingTips("登录验证出错")
        return
    end

    --登录成功，设置当前进度为20%
    require("hall.GameCommon"):setLoadingProgress(20)


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


        hall_ip = hall["ip"]

        print("hall ip:" .. hall_ip)

        hall_port = hall["port"]
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




        --请求登录大厅
        if not  bm.isExit then
            --todo
              self:connectSocket()
        else
            require("hall.GameCommon"):landLoading(false)
            display_scene("hall.gameScene", 1)
        end
      
      	bm.isExit=false
      	phpLogined = 1

    end
end

--开始连接socket
function loginGame:connectSocket( ... )
	-- body
	 dump(hall_ip, "-----连接Socket hall_ip-----")
    if bm.server:isConnected() then
        bm.server:disconnect()
    end

    bm.isConnectedCount = 0

    require("hall.GameCommon"):showLoadingTips("正在连接服务器")

    bm.server:connect(hall_ip, hall_port, 0)
end

function loginGame:onEnter()
	-- body

    require("hall.GameCommon"):landLoading(true)
    require("hall.GameCommon"):setLoadingProgress(10)
    require("hall.GameCommon"):showLoadingTips("正为您准备游戏")
    if bm.isExit then
        return;
    end


     if device.platform=="android" then
        local dataString=userdefine:getStringForKey("loginData", "")
        local wxInfp=userdefine:getStringForKey("WXINFO", "")
        local userinfo=userdefine:getStringForKey("USER_INFO", "")

        print(dataString,"1")

        print(wxInfp,"2")

        print(uid,"3")
         if wxInfp=="" then
            --self.login:ios_wx_login();
            require("hall.LoginScene"):show()
         elseif dataString=="" then
            self.login:getIsZC(cct.unserialize(wxInfp))
         elseif userinfo=="" then

            local ob=cct.unserialize(dataString)
            self.login:login(ob.phone,ob.password,cct.unserialize(wxInfp))
         else


         
            userinfo=cct.unserialize(userinfo)
            USER_INFO["uid"]=userinfo.uid
            USER_INFO["gold"]=userinfo.gold
            USER_INFO["cardCount"]=userinfo.cardCount
            USER_INFO["nick"]=userinfo.nick
            USER_INFO["headUrl"]=userinfo.headUrl
            USER_INFO["sex"]=userinfo.sex
            USER_INFO["type"] = "P"
            self.login:PHPLogin(USER_INFO["uid"])
            
            
         end
    else

        if bm.jsonData then
            USER_INFO["uid"]=tonumber(bm.jsonData.UID);
            UID=tonumber(bm.jsonData.UID);
            print(bm.jsonData.UID,"bm.jsonData.UID;")
        end
        USER_INFO["type"] = "P"
        self.login:PHPLogin(USER_INFO["uid"])
    end

         bm.checknetworking = true

end




function loginGame:wxLogin( ... )
	-- body
	self.login:ios_wx_login();
end


function loginGame:exitLogin( ... )
    -- body
    self.login:exitLogin();
end


-- 渠道跳转
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






return loginGame




