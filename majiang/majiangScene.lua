
--设置父级目录
cc.FileUtils:getInstance():addSearchPath("majiang/")

--定义麻将界面
local majiangScene = class("majiangScene", function()
    return display.newScene("majiangScene")
end)

local BloodHallHandle  = require("majiang.scenes.MajiangroomHandle")
 --导入麻将套接字请求处理（协议）
local PROTOCOL         = import("majiang.scenes.Majiang_Protocol")

require("majiang.setting_help")
require("majiang.card_type")
require("majiang.card_path")


function majiangScene:ctor()
        bm.server:setProtocol(PROTOCOL)
        bm.server:setHandle(BloodHallHandle.new())
    require("hall.GameCommon"):landLoading(true,self)
end

function majiangScene:onEnter()
    printf("majiangScene onEnter")

    bm.server=bm.server
    SCENES_NOW=SCENES_NOW or {} 
    bm.display_scenes = function(path)
        SCENENOW["name"]  = path;
        local scene=require(path).new()
        scene:retain();
        SCENENOW["scene"] = scene

        SCENES_NOW["name"]  = path;
        SCENES_NOW["scenes"] = scene
        scene:retain();
        cc.Director:getInstance():getRunningScene():removeSelf();
        display.replaceScene(scene)

    end


    bm.nodeClickHandler = function (obj, method, ...)
        local args = {...}
        print("content:"..json.encode(args))
        obj:setTouchEnabled(true)
        obj:addNodeEventListener(cc.NODE_TOUCH_EVENT,function ( event )
                if event.name == "began" then
                    require("hall.GameCommon"):playEffectSound(audio_path,false)
                    method(self,unpack(args))
                end
        end)
    end
    

    bm.isGroup=false

    print("majiangScene:onEnter",require("hall.gameSettings"):getGameMode())
    if require("hall.gameSettings"):getGameMode() == "group" then
    -- if USER_INFO["enter_mode"]==4 then
            --todo
        bm.isGroup=true
    end


    print("tableIdReload--------",tableIdReload,"bm.isGroup----------",bm.isGroup)
    -- if tableIdReload == 0 then --非重登
    -- -- if bm.isGroup then
    --     if require("hall.gameSettings"):getGameMode() == "group" then
    --                 --todo
    --         self:groupRun();
    --     else
    --         display_scene("majiang/gameScenes")
    --     end

    -- else
    --     local pack_data = {}
    --     pack_data.tid = tableIdReload

    --     BloodHallHandle:SVR_GET_ROOM_OK(pack_data)
    --     tableIdReload = 0
    -- end

    self:groupRun();

end


function majiangScene:onExit()
end





return majiangScene
