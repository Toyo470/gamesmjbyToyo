
--加载大厅更新类
local HallUpdate = require("app.HallUpdate")

--实例化初始界面
local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

--初始界面初始化
function MainScene:ctor()

end

function MainScene:onEnter()





    print("MainScene:onEnter")
    --[[


    ]]

    local androidVer=cc.Label:createWithTTF("","res/fonts/fzcy.ttf",20):addTo(self)  --显示版本号
    androidVer:setName("androidVer")
    androidVer:setPosition(cc.p(820,45))
    local banbenhao=cc.UserDefault:getInstance():getStringForKey("androidVer","")
    androidVer:setString("版本号："..banbenhao)


    HallUpdate:landLoading(true)

    --记录游戏是否需要更新
    if device.platform == "windows" then
        needUpdate = false
    else
        needUpdate = true
    end

    --记录大厅是否需要更新
    if device.platform == "windows" then

        --windows平台大厅不需要检查更新
        hallNeedUpdate = false

    elseif device.platform == "ios" then

        local sigs = "Ljava/lang/String;"
        local ios_hallNeedUpdate = cct.getDateForApp("getIsHallNeedUpdate",{},sigs)
        self:getAppData(ios_hallNeedUpdate)

    else

        --其他平台，大厅都需要检查更新
        hallNeedUpdate = true

    end

    if not hallNeedUpdate then

        --进入大厅
        display_scene("hall.loginGame",1)

    else

        --检查大厅更新
        HallUpdate:showLoadingTips("检查大厅更新")
        HallUpdate:queryVersion(2)

    end
 
end




function MainScene:getAppData(data)

    if data == "1" then
        --需要时，大厅和游戏都需要检查更新
        hallNeedUpdate = true
        needUpdate = true

    elseif data == "2" then

        -- local function regetData()

            -- --iOS平台从本地获取是否需要更新大厅
            -- local sigs = "Ljava/lang/String;"
            -- local ios_hallNeedUpdate = cct.getDateForApp("getIsHallNeedUpdate",{},sigs)
            -- self:getAppData(ios_hallNeedUpdate)

        -- end

        -- local scheduler = cc.Director:getInstance():getScheduler()
        -- scheduler:scheduleScriptFunc(regetData, 2, false)

        local action = cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function()
            
            --iOS平台从本地获取是否需要更新大厅
            local sigs = "Ljava/lang/String;"
            local ios_hallNeedUpdate = cct.getDateForApp("getIsHallNeedUpdate",{},sigs)
            self:getAppData(ios_hallNeedUpdate)

        end))
        SCENENOW["scene"]:runAction(action)

    else
        --不需要时，大厅和游戏都不需要检查更新
        hallNeedUpdate = false
        needUpdate = false

    end

end


return MainScene
