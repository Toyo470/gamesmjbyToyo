-- 0 - disable debug info, 1 - less debug info, 2 - verbose debug info
DEBUG = 1

-- use framework, will disable all deprecated API, false - use legacy API
CC_USE_FRAMEWORK = true

-- show FPS on screen
CC_SHOW_FPS = false

-- disable create unexpected global variable
CC_DISABLE_GLOBAL = false

-- for module display
CC_DESIGN_RESOLUTION = {
    width = 960,
    height = 540,
    autoscale = "FIXED_WIDTH",
    callback = function(framesize)
        local ratio = framesize.width / framesize.height
        if ratio <= 1.34 then
            -- iPad 768*1024(1536*2048) is 4:3 screen
            return {autoscale = "FIXED_WIDTH"}
        end
    end
}



urlUpdate = "120.25.216.48:8080/gameUpdate"
--urlUpdate = "192.168.100.106:80"
--urlUpdate = "120.25.216.48:8080/testUpdate"

 -- HttpAddr = "http://douyou.net.cn/hbiInterface"
--HttpAddr = "http://120.25.165.221/hbiInterface"

--HttpAddr = "http://120.76.133.49/hbiInterface"
-- HttpAddr = "http://120.25.216.48:8081/hbiInterface"--中手游麻将
-- HttpAddr = "http://120.76.103.204:8080/hbiInterface"--闲来麻将馆（外网演示服）
-- HttpAddr = "http://120.24.152.139:8080/hbiInterface"--闲来麻将馆（外网演示服）
-- HttpAddr = "http://192.168.1.191:8081/hbiInterface"--闲来麻将馆（内网）
 --HttpAddr = "http://119.23.29.253/hbiInterface"--789广东麻将（外网演示服）
--HttpAddr = "http://interface.game789.com/hbiInterface"--星晋（生产）
HttpAddr = "http://101.37.68.57/hbiInterface"--789广东麻将（生产）


 -- HttpAddr = "http://yingkou.doudougame.com.cn:8080/hbiInterface"--闲来麻将馆（外网私服）
 


-- isVerify = true
isVerify = false
-- needUpdate = true

ios_class="CocosCaller"

android_class="com/cocos2dx/sample/LuaJavaBridgeTest/LuaJavaBridgeTest"

luaJniClass="com/cocos2dx/sample/LuaJavaBridgeTest/LuaJavaBridgeTest"
confilg_manager = nil
isShowErrorScene = true

isShowNetLog = true

showDumpData = true



--HttpAddr2="http://interface.game789.com/game-web/"
HttpAddr2="http://101.37.68.57/game-web/"






