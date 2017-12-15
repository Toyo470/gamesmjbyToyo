

local MainNet  = class("MainNet")
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
local Packet   = require("net.Packet")

MainNet.ip = "120.25.203.192"
MainNet.port = 5900

--socket 初始化
function MainNet:create(ip,port)
    self._socket = cc.mySocket:create(ip,port)
    self._socket:init()
    self:handleSchdule()

    -- local table    = {}
    -- table["uid"]   = UID
    -- local cmd      = 1 
    -- local json_str = json.encode(table)
    -- local  p = cc.mySocket:packet(cmd,json_str)
    -- NET:send(p)

end


--连接上
function MainNet:handleSchdule()
    self._handle = scheduler.scheduleGlobal(function()
        local p = self._socket:recv()

        if p ~= 0 then
             local pac  = Packet.new()

             pac._cmd   = tonumber(p[1])
             pac._val   = json.decode(p[3])
             if  pac._val then
                self:handle(pac)
             end
        end
        
    end,0.1)
end

--收协议
function MainNet:onData(__event)
    local pac = Packet.new()
    pac:Prase(__event.data)
    self:handle(pac)
end

--处理协议
function MainNet:handle(packet)

    if packet._cmd ~= 1011 then
        printf("net receive:%d",packet._cmd)
    end
    --登陆大厅返回
    if packet._cmd == 2 then
        local flag = tonumber(packet._val["flag"])
        if(flag < 0 ) then
            return -1
        end
        USER_INFO["win"]   =  tonumber(packet._val["win"])
        USER_INFO["exp"]   =  tonumber(packet._val["exp"])
        USER_INFO["sex"]   =  tonumber(packet._val["sex"])
        USER_INFO["lost"]  =  tonumber(packet._val["lost"])
        USER_INFO["uid"]   =  tonumber(packet._val["uid"])
        USER_INFO["gold"]  =  tonumber(packet._val["gold"])
    end

    --登陆桌子返回
    if packet._cmd == 4 then
       
        local table = packet._val    

        if(table["flag"] == 0 and tonumber(USER_INFO["uid"]) == tonumber(table["uid"]) ) then

            USER_INFO["seat"] = table["seat"]
            display_scene("ddz.PlayCardScene",1)

            table["other"] = json.decode(table["other"])
            SCENENOW["scene"]:drawOther(table["other"],table["seat"]);
            SCENENOW["scene"]:displayMine()
        end
    end 
    
    --发送准备返回
    if packet._cmd == 6 and  SCENENOW["name"] == "ddz.PlayCardScene" then
        local table_t = packet._val
        if tonumber(packet._val["uid"]) == tonumber(USER_INFO["uid"]) then
            SCENENOW["scene"]:ready() 
        else
            SCENENOW["scene"]:setOtherReady(packet._val["seat"])
        end
    end

end

--发送协议
function MainNet:send(packet)
    --printf("net send:%d",packet.header.cmd)
    self._socket:send(packet)
end

return MainNet
 