--设置父级目录

GAMEBASENAME = "hhtdh_majiang"
local writepath = cc.FileUtils:getInstance():getWritablePath()
cc.FileUtils:getInstance():addSearchPath(writepath)
cc.FileUtils:getInstance():addSearchPath(GAMEBASENAME.."/")
require(GAMEBASENAME..".helptool")
require(GAMEBASENAME..".myrequire")

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
    mymodules.initialize()

    mrequire("layout")
    mrequire("layout.layout_manager")
    
    print("dumpmymodules")
    
    --设置场景，以后所有的界面都挂在这个场景上
    --初始化

    layout.manager:set_runningscene(self)

    
    
    if mymodules.manager ~= nil then
        mymodules.manager:init_logic()
    end

    local function update(dt)
        if mymodules.manager ~= nil then
            mymodules.manager:update(dt)
        end
    end

    self:scheduleUpdateWithPriorityLua(update,0)
    -- audio.playMusic("majiang/music/BG_283.mp3", true)
    -- audio.stopMusic(true)

    self.ShowVoicePosion = {}

    local kwx_face=require("hall.FaceUI.faceUI")
    local sendHandle = require(GAMEBASENAME..".Sender")
    local kwx_face_node = kwx_face.new();
    kwx_face_node:setHandle(sendHandle)
    self:addChild(kwx_face_node, 9999)
    kwx_face_node:setName("faceUI")

    local path_bg = music.manager:get_bg_music_path()
    audio.playMusic(path_bg, true)

    layout.reback_layout_object("room_base")
    layout.reback_layout_object("player")
    layout.reback_layout_object("room_card")
    layout.reback_layout_object("roomhandle")

    -- local room_card_object = layout.reback_layout_object("room_card")
    -- zzroom.manager:init_card({101,102,103,104,105,106,107,108,109})
    -- room_card_object:drawHandCard(0)
    -- room_card_object:drawHandCard(1)
    -- room_card_object:drawHandCard(2)
    -- room_card_object:drawHandCard(3)
    
    -- room_card_object:draw_out_card(0)
    -- room_card_object:draw_out_card(1)
    -- room_card_object:draw_out_card(2)
    -- room_card_object:draw_out_card(3)
    -- local tbl = {{101,101,101},{102,102,102},{102,102,102}}
    -- local room_handle_view_object = layout.reback_layout_object("room_handle_view")
    -- room_handle_view_object:click_room_handle_view_chi_event(tbl)

    -- local room_handle_view_object = layout.reback_layout_object("room_handleresult")
    -- room_handle_view_object:reset_result_item(1,128)

    self:init_protocol()
    --cc.Director:getInstance():setDisplayStats(true)

    -- local tbl = {}
    -- tbl["account_handcard"]={101,102}
    -- --[0, ['pph', 'jjh'], 305]#10001自摸，胡牌类型我pph和jjh，胡的牌为305
    -- tbl["account_hu_conbination_list"]={0, {'pph', 'jjh'}, 305}

    -- tbl["account_last_handcard"]={101,201}
    -- tbl["account_last_peng_list"]={101}

    -- tbl["account_last_an_gang_list"]={101}
    -- tbl["account_last_ming_gang_list"] = {102}
    -- tbl["account_last_fang_gang_list"]={}
    -- -- tbl["account_last_fang_gang_list"][511]={101,102}
    -- -- tbl["account_last_fang_gang_list"][522]={103}

    -- tbl["account_last_chi_list"] = {{101,102,103}}
    -- tbl["account_chip"] = 100
    -- tbl["account_change_chip"] = -100

    -- local result_object = layout.reback_layout_object("result")
    -- result_object:draw_card(0,tbl)

  -- layout.reback_layout_object("seabase")
    -- local result_object = layout.reback_layout_object("gangchoose")
    -- result_object:set_txt("hahh",103)
    -- result_object:set_card(104,105)

end


function ScriptScene:init_protocol()
    -- body
--dump(ZZPROTOCOL)
    mrequire("handleview")
    mrequire("tips")
    mrequire("music.music_manager")
    mrequire("account")
    mrequire("zzroom")
    mrequire("layout")

    mrequire("mprotocol")
    mrequire("mprotocol.g2h_list_format")
    mrequire("mprotocol.h2g_list_format")

    --dump(mprotocol.h2g_list_format)
    --dump(mprotocol.g2h_list_format)
   

    local protocol_dict = {}
    protocol_dict.CONFIG = {}
    protocol_dict.CONFIG["CLIENT"] = mprotocol.h2g_list_format["PROTOCOL_FORMAT_DICT"] or {}
    protocol_dict.CONFIG["SERVER"] = mprotocol.g2h_list_format["PROTOCOL_FORMAT_DICT"] or {}
    --dump(protocol_dict)
    
    local T = bm.PACKET_DATA_TYPE
    --加几个恶心的代码在这，呵呵，
    protocol_dict.CONFIG["CLIENT"][0x0113] = {
        ver = 1,
        fmt = {
            {name = "level", type = T.SHORT},   --桌子等级
            {name = "Chip", type = T.INT},--请求场次的底注
            {name = "Sid", type = T.INT},--游戏场的id
            {name = "activity_id", type = T.STRING} --带入活动id
        }
    }

    protocol_dict.CONFIG["SERVER"][0x0210] = {
        ver = 1,
        fmt = {
            {name = "tid", type = T.INT}, --桌子ID
            {name = "sid", type = T.SHORT}, --serverid
            {name = "ip", type = T.STRING}, -- ip
            {name = "port", type = T.INT}, -- 端口
            {name = "res", type = T.INT}, --请求结果
            {name = "level", type = T.SHORT}, --请求结果
        }
    }

    local ZZHandle = require(GAMEBASENAME..".".."handle")
    bm.server:setProtocol(protocol_dict)
    bm.server:setHandle(ZZHandle.new())
    
    local ZZ_Send = require(GAMEBASENAME..".".."Sender")
    ZZ_Send:LoginGame()
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
    self.ShowVoicePosion = {}
    self.ShowVoicePosion[UID] = cc.p(185,540-375)
end



--以下是提供给外部调用的代码

function ScriptScene:setPosforSeat(index,uid)
    --print("index,,,,,,,,,,,,,,",index)
    if index == 0 then
        self.ShowVoicePosion[uid] = cc.p(185,540-375)
    elseif index == 3 then
        self.ShowVoicePosion[uid] = cc.p(102,540-158)
    elseif index == 2 then
        self.ShowVoicePosion[uid] = cc.p(350,540-70)
    elseif index == 1 then
        self.ShowVoicePosion[uid] = cc.p(928,540-159)
    end

end


function ScriptScene:getPosforSeat( uid )
    -- body
    --print("uid.................",uid)
    return self.ShowVoicePosion[uid] or cc.p(0,0)
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
