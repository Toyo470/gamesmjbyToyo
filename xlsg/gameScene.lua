
--设置父级目录
local writepath = cc.FileUtils:getInstance():getWritablePath()
print("writepath===-----------------",writepath)
cc.FileUtils:getInstance():addSearchPath(writepath)
cc.FileUtils:getInstance():addSearchPath("xlsg/")

require("xlsg.helptool")
require("xlsg.myrequire")

print("--------gameScene-----------------")


--定义麻将界面
local ScriptScene = class("ScriptScene", function()
    return display.newScene("ScriptScene")
end)

function ScriptScene:ctor()
end

function ScriptScene:onEnter() 
    print("------xlsg-----ScriptScene:onEnter()----------------")

  --  print("------------USER_INFO[user_info]----------------------",USER_INFO["user_info"])
    mrequire("mymodules")
    mrequire("names")
    mrequire("keys")
    mrequire("jsonparser")

    mymodules.initialize()
    
    mrequire("layout")
    mrequire("layout.layout_manager")

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
    self.ShowVoicePosion = {}
    self:setPosforSeat(0,UID)
    
    layout.reback_layout_object("room_base")
    local layout_object = layout.reback_layout_object("room")
    layout_object:reset_player()
   -- local card_object = layout.reback_layout_object("card")
    --layout.reback_layout_object("roomhandle")

--以下是测试代码
   -- card_object:startSendCard()

    -- local handler_data = {101,102}
    -- card_object:set_paler_card(0,handler_data)
    -- card_object:set_paler_card(1,handler_data)
    -- card_object:set_paler_card(2,handler_data)
    -- card_object:set_paler_card(3,handler_data)
    -- card_object:set_paler_card(4,handler_data)

   -- handler_data["handler_data"] = "hsg"
    -- handler_data["account_handcard"] = {101,102,107}
    -- card.handler_result(0,handler_data) 
    -- card.handler_result(1,handler_data)
    -- card.handler_result(2,handler_data)
    -- card.handler_result(3,handler_data)
    -- card.handler_result(4,handler_data) 

    -- local tbl = {}
    -- local game_dialog ={}
    
    -- game_dialog["option_content"]="抢庄"
    -- game_dialog["option_x"]="100"
    -- game_dialog["option_y"]="100"

    -- local game_dialog2 ={}
    
    -- game_dialog2["option_content"]="抢庄"
    -- game_dialog2["option_x"]="200"
    -- game_dialog2["option_y"]="100"

    -- table.insert(tbl,game_dialog)
    -- table.insert(tbl,game_dialog2)

    -- local dialog_choose = layout.reback_layout_object("dialog_choose")
    -- dialog_choose:resetdata(tbl)
    

    -- local pack = {}
    -- pack["game_account_data"] = {}
    -- pack["game_account_data"][1001] = {}
    -- pack["game_account_data"][1001]["account_name"] = "奴哈"

    -- pack["game_account_data"][1002] = {}
    -- pack["game_account_data"][1002]["account_name"] = "奴哈"

  
    -- pack["game_group_result"] = {}
    -- local tbl = {}
    -- tbl[1001] = {}
    -- tbl[1001]["account_conbination_style"] = "dsg"
    -- table.insert(pack["game_group_result"],tbl)

    -- local tbl = {}
    -- tbl[1002] = {}
    -- tbl[1002]["account_conbination_style"] = "dsg"
    -- table.insert(pack["game_group_result"],tbl)

    -- dump(pack)

    -- local group_result = layout.reback_layout_object("group_result")
    -- group_result:reset_data(pack)


    --测试解散房间
    -- local tbl = {}
    -- tbl["group_dissolve_refuse_account"] = 819
    -- local str = json.encode(tbl)

    -- local data_tbl = {}
    -- data_tbl["msg_data"] = str

    -- dump(data_tbl)
    -- local ZZHandle = require("xlsg.ZZ_Handle").new()
    -- ZZHandle:G2H_BROADCAST_DISSOLVE_FAILED(data_tbl)

    -- --测试刷新组局解散情况
    -- local tbl = {}
    -- tbl["account_name"] = "chen"
    -- zzroom.manager:set_user_data(818,tbl)

    -- local tbl = {}
    -- tbl["account_name"] = "chen819"
    -- zzroom.manager:set_user_data(819,tbl)

    -- local tbl = {}
    -- tbl["account_name"] = "chen820"
    -- zzroom.manager:set_user_data(820,tbl)

    -- local tbl = {}
    -- tbl["group_dissolve_sponsor_id"] = 819
    -- tbl["group_dissolve_list"] = {818,819,820}
    -- local str = json.encode(tbl)

    -- local data_tbl = {}
    -- data_tbl["msg_data"] = str

    -- local ZZHandle = require("xlsg.ZZ_Handle").new()
    -- ZZHandle:G2H_BROADCAST_REFRESH_DISSOLVE_LIST(data_tbl)

    -- local tbl = {}
    -- tbl["game_error"] = 1
    -- local str = json.encode(tbl)
    -- local data_tbl = {}
    -- data_tbl["msg_data"] = str

    -- local ZZHandle = require("xlsg.ZZ_Handle").new()
    -- ZZHandle:G2H_LOGIN_ERR(data_tbl)

--测试抢倍，抢庄
--     local tbl = {}
--     tbl["option_style"] = 2
--     local tbl1 = {20}
-- local tbl2 = {20}
-- local tbl3 = {20}
-- local tbl4 = {20}
--      tbl["option_content"] = {}
--      table.insert(tbl["option_content"],tbl1)
--      table.insert(tbl["option_content"],tbl2)
--      table.insert(tbl["option_content"],tbl3)
--      table.insert(tbl["option_content"],tbl4)
--     local str = json.encode(tbl)
--     local data_tbl = {}
--     data_tbl["msg_data"] = str

--     local ZZHandle = require("xlsg.ZZ_Handle").new()
--     ZZHandle:G2H_ACCOUNT_OPTION(data_tbl) 

  --  cc.Director:getInstance():setDisplayStats(true)
--以上是测试代码
    self:init_protocol()


    self.ShowVoicePosion = {}

    local kwx_face=require("hall.FaceUI.faceUI")
    local sendHandle = require("xlsg.ZZ_Send")
    local kwx_face_node = kwx_face.new();
    kwx_face_node:setHandle(sendHandle)
    self:addChild(kwx_face_node, 9999)
    kwx_face_node:setName("faceUI")


    require("hall.VoiceRecord.VoiceRecordView"):showView(877.00+20, 147.00-20,1)
    self.ShowVoicePosion = {}
    self.ShowVoicePosion[UID] = cc.p(185,540-375)


end

function ScriptScene:setPosforSeat(index,uid)
    --print("index,,,,,,,,,,,,,,",index)
    if self.ShowVoicePosion == nil then
        self.ShowVoicePosion = {}
    end

    if index == 0 then
        self.ShowVoicePosion[uid] = cc.p(132,142)
    elseif index == 1 then
        self.ShowVoicePosion[uid] = cc.p(864,334)
    elseif index == 2 then
        self.ShowVoicePosion[uid] = cc.p(760,455)
    elseif index == 3 then
        self.ShowVoicePosion[uid] = cc.p(132,455)
    elseif index == 4 then
        self.ShowVoicePosion[uid] = cc.p(26,324)
    end
end


function ScriptScene:getPosforSeat( uid )
    -- body
    print("uid.................",uid)
    return self.ShowVoicePosion[uid] or cc.p(0,0)
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
    local ZZHandle = require("xlsg.ZZ_Handle")

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


    bm.server:setProtocol(protocol_dict)
    bm.server:setHandle(ZZHandle.new())


    local ZZ_Send = require("xlsg.ZZ_Send")
    ZZ_Send:LoginGame(170)


        --发送我的组局信息（地理位置）
    local userData = {}
    userData["uid"] = USER_INFO["uid"]
    userData["nickName"] = USER_INFO["nick"]
    userData["invote_code"] = USER_INFO["invote_code"]
    if device.platform == "ios" then

        userData["latitude"] = cct.getDataForApp("getLatitude", {}, "string")
        userData["longitude"] = cct.getDataForApp("getLongitude", {}, "string")

    elseif device.platform == "android" then

        local args = {}
        local sigs = "()Ljava/lang/String;"
        local luaj = require "cocos.cocos2d.luaj"
        local className = luaJniClass

        ok,ret  = luaj.callStaticMethod(className,"getLatitude",args,sigs)
        if not ok then
            print("luaj error:", ret)
        else
            userData["latitude"] = ret
        end

        ok,ret  = luaj.callStaticMethod(className,"getLongitude",args,sigs)
        if not ok then
            print("luaj error:", ret)
        else
            userData["longitude"] = ret
        end

    else

        userData["latitude"] = "10.00"
        userData["longitude"] = "10.00"

    end
    ZZ_Send:SendGameMsg(USER_INFO["GroupLevel"], json.encode(userData))


end



function ScriptScene:onExit()
    --场景退出的时候回调
    layout.hide_layout("room_base")
    audio.stopMusic(true)
    print("-----------ScriptScene:onExit()----------------")
    if mymodules.manager ~= nil then
        mymodules.manager:release()
    end

    --以下代码一行都不能注释

    local function unuseModuleRequire()
       -- print("-----------------unuseModuleRequire---------------")
        local package_dict = _G["package_dict"] or {}
        --dump(package_dict,"package_dict===")
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


return ScriptScene
