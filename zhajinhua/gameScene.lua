
local PROTOCOL = require("zhajinhua.Zhajinhua_Protocol")

local zjhServer = import("zhajinhua.ZhajinHuaServer")
local zjhHandle  = require("zhajinhua.ZjhHandle")

local gameScene = class("gameScene", function()
    return display.newScene("gameScene")
end)


function gameScene:ctor()

    bm.server:setProtocol(PROTOCOL)
    bm.server:setHandle(zjhHandle.new())

    bm.Room = {}
    bm.User = {}
end

function gameScene:onEnter()

    require("hall.GameCommon"):landLoading(true)

    cc.SimpleAudioEngine:getInstance():stopAllEffects()
    cc.SimpleAudioEngine:getInstance():stopMusic()
    audio.preloadMusic("zhajinhua/res/audio/game_back.mp3")
    require("hall.GameCommon"):playEffectMusic("zhajinhua/res/audio/game_back.mp3",true)

    local mode = require("hall.gameSettings"):getGameMode()
    if mode == "free" then
        local adapLevel = require("hall.hall_data"):getAdapterLevel("zhajinhua")
        if adapLevel < 0 then
            require("hall.GameTips"):showTips("余额不足，请充值","change_money",1)
            return
        end
        USER_INFO["gameLevel"] = adapLevel
    end
    zjhServer:enterRoom()
    -- end
end


function gameScene:getPosforSeat(uid)
    return cc.p(1000,1000)
end

return gameScene
