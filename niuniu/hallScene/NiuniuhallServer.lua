local NiuniuhallServer = class("NiuniuhallServer")
local PROTOCOL         = import("niuniu.Niuniu_Protocol")
function NiuniuhallServer:ctor()
	
end

--进入组局 113 服务器会返回210消息
function NiuniuhallServer:enterGroupRoom(Level,Chip,Sid,activity_id)

    dump("获取房间id 0113", "-----牛牛-----")

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_GET_ROOM)
    :setParameter("level", Level)
    :setParameter("Chip", Chip)
    :setParameter("Sid", Sid)
    :setParameter("activity_id", activity_id)
    :build()
    bm.server:send(pack)
    
end

--进入普通  113 服务器会返回210消息
function NiuniuhallServer:enterRoom(level_num)

	print("request NiuniuhallServer:enterRoom")
        local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_GET_ROOM)
        :setParameter("level", level_num)
        :setParameter("Chip", 0)
        :setParameter("Sid", 0)
        :setParameter("activity_id", "")
        :build()
    bm.server:send(pack)
end


--进入百人房间
function NiuniuhallServer:enterBairenRoom()
        local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_GET_ROOM)
        :setParameter("level", 301)
        :build()
    bm.server:send(pack)
end




return NiuniuhallServer