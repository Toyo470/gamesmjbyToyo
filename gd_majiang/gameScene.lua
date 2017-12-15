

--广东麻将的代码来之于转转麻将，
--如果说有bug，那么可能转转也有bug
--设置父级目录
local writepath = cc.FileUtils:getInstance():getWritablePath()
print("writepath===-----------------",writepath)
cc.FileUtils:getInstance():addSearchPath(writepath)
cc.FileUtils:getInstance():addSearchPath("gd_majiang/")

require("gd_majiang.helptool")
require("gd_majiang.myrequire")

print("--------gameScene-----------------")

--定义麻将界面
local ScriptScene = class("ScriptScene", function()
    return display.newScene("ScriptScene")
end)

function ScriptScene:ctor()

end

function ScriptScene:onEnter()
    mrequire("mymodules")
    mrequire("names")
    mrequire("keys")
    mrequire("jsonparser")
    print("-------gd_majiang----ScriptScene:onEnter()----------------")
   -- print("******************env**********************",env)
   --dump(mymodules)
    mymodules.initialize()
    
    mrequire("layout")
    mrequire("layout.layout_manager")
    
    print("dumpmymodules")

    if bm.Room == nil then
        bm.Room = {}
    end
    bm.Room.isGroupEnd = 0
    
    --设置场景，以后所有的界面都挂在这个场景上
    --初始化

    layout.manager:set_runningscene(self)

    self:init_protocol()
    
    if mymodules.manager ~= nil then
        mymodules.manager:init_logic()
    end

    local function update(dt)
        if mymodules.manager ~= nil then
            mymodules.manager:update(dt)
        end
    end

    self:scheduleUpdateWithPriorityLua(update,0)
    print("+++++++++++++++++++++++++++++++++")
    layout.reback_layout_object("room_base")


    print("tableIdReload-----------",tableIdReload)
    local pack_data = {}
    pack_data['tid'] = tableIdReload

    -- if tonumber(tableIdReload) > 0 then
    --     ZZHandle:SVR_GET_ROOM_OK(pack_data)
    -- else
    local gd_majiangServer = require("gd_majiang.gd_majiangServer")
        gd_majiangServer:LoginGame(63)
    -- end
    print("+++++++++++++++++++++++++++++++++")

        -- audio.playMusic("majiang/music/BG_283.mp3", true)
       -- audio.stopMusic(true)


    -- local sharedDirector = cc.Director:getInstance()
    -- sharedDirector:setDisplayStats(true)

    bm.Room.ShowVoicePosion = {}

    local kwx_face=require("hall.FaceUI.faceUI")
    local sendHandle = require("gd_majiang.gd_majiangServer")
    local kwx_face_node = kwx_face.new();
    kwx_face_node:setHandle(sendHandle)
    self:addChild(kwx_face_node, 9999)
    kwx_face_node:setName("faceUI")

    --cc.Director:getInstance():setDisplayStats(true)
end


function ScriptScene:init_protocol()
    -- body
--dump(ZZPROTOCOL)
    _G.mrequire = require("gd_majiang/myrequire")
    mrequire("handleview")
    mrequire("tips")
    mrequire("music.music_manager")
    mrequire("account")
    mrequire("zzroom")
    mrequire("layout")

    local ZZPROTOCOL = require("gd_majiang.gd_Protocol")
    local ZZHandle = require("gd_majiang.gd_Handle")
    bm.server:setProtocol(ZZPROTOCOL)
    bm.server:setHandle(ZZHandle.new())
end


function ScriptScene:onExit()
    layout.hide_layout("room_base")
     audio.stopMusic(true)
    print("-----------ScriptScene:onExit()----------------")
    if mymodules.manager ~= nil then
        mymodules.manager:release()
    end

    local function unuseModuleRequire()
       -- print("-----------------unuseModuleRequire---------------")
        local package_dict = _G["package_dict"] or {}
       -- dump(package_dict,"package_dict===")
        for _name,_tbl in pairs(package_dict) do
            -- dump(_tbl,"_tbl")
            for _key,_value in pairs(_tbl) do
                local str_key = _name .. ".".._key 
               -- print("++++++++++++++++str_key++++++++++++++++++++++",str_key)
                if package.loaded[str_key] then
                    --dump(package.loaded[str_key],"package.loaded[str_key]")
                    package.loaded[str_key] = nil
                     _G[str_key] = nil
                end
                --print(type(_key),_value,"-----------_key,_value-------------")
            end

            if package.loaded[_name] then
               -- print("+++++++++++++++++++++_name+++++++++++++++++")
                --dump(package.loaded[_name],"package.loaded[_name]")
                package.loaded[_name] = nil
                _G[_name] = nil
            end
        end

        local file_dict =  _G["file_dict"] or {}
        for _name,_tbl in pairs(file_dict)do
            --print(_name,"-----------_name-----file_dict-----------------")
            if package.loaded[_name] then
                --print("+++++++++++++++++++++file_dict+++++++++++++++++")
                --dump(package.loaded[_name],"package.loaded[_name]")
                package.loaded[_name] = nil
                 _G[_name] = nil
            end
        end
    end

    unuseModuleRequire()
    _G["file_dict"] = {}
    _G["package_dict"] = {}
   -- dump(package.loaded)
    _G["check_require"]  = nil

   --移除录音按钮
    require("hall.VoiceRecord.VoiceRecordView"):removeView()
    bm.Room.ShowVoicePosion = {}
    bm.Room.ShowVoicePosion[tonumber(UID)] = cc.p(185,540-375)
end

function ScriptScene:setPosforSeat(index,uid)
    if index == 0 then
        bm.Room.ShowVoicePosion[uid] ={["x"]=185,["y"]=540-375}
    elseif index == 1 then
        bm.Room.ShowVoicePosion[uid] ={["x"]=102,["y"]=540-158}
    elseif index == 2 then
        bm.Room.ShowVoicePosion[uid] ={["x"]=350,["y"]=540-70}
    elseif index == 3 then
        bm.Room.ShowVoicePosion[uid] ={["x"]=928,["y"]=540-159}
    end
    require("hall.view.voicePlayView.voicePlayView"):updateUserPosition(uid,bm.Room.ShowVoicePosion[uid]) 

end

function ScriptScene:getPosforSeat( uid )
    -- body
    --print("uid.................",uid)
    return bm.Room.ShowVoicePosion[uid] or cc.p(0,0)
end


function ScriptScene:get_player_ip( uid )
    -- body
    local ip_ = ""
    if zzroom.manager ~= nil then
        ip_ = zzroom.manager:get_player_ip(uid)
    end
    return ip_
end

return ScriptScene
