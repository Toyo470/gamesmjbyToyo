require("framework.init")

--定义麻将房服务
local ZZSend = class("ZZSend")

--导入麻将房套接字请求处理（协议）
local PROTOCOL = import("zz_majiang.ZZ_Protocol")

function ZZSend:ctor()
	
end

--用户发送准备
function ZZSend:readyNow()
    local pack = bm.server:createPacketBuilder(PROTOCOL.C2S_READYNOW)
        :build()
    bm.server:send(pack)
end

--退出房间--改为--申请退出房间
function ZZSend:quickRoom()
    local pack = bm.server:createPacketBuilder(PROTOCOL.C2S_QUIT_ROOM)
        :build()
    bm.server:send(pack)
end

--玩家出牌
function ZZSend:sendCard(value)
    local pack = bm.server:createPacketBuilder(PROTOCOL.C2S_SEND_CARD)
        :setParameter("card", value)
        :build()
    bm.server:send(pack)

end

--用户请求操作,这里是哪些碰，杆，胡的操作
function ZZSend:requestHandle(handle,value)
    local pack = bm.server:createPacketBuilder(PROTOCOL.C2S_REQUEST_HANDLE)
        :setParameter("handle", handle)
        :setParameter("card", value)    
        :build()
    bm.server:send(pack)
end

return ZZSend