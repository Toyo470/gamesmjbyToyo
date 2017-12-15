require("framework.init")


local ZhajinHuaServer = class("ZhajinHuaServer")
local PROTOCOL        = import("zhajinhua.Zhajinhua_Protocol")

function ZhajinHuaServer:ctor()
	
end

--进入房间
function ZhajinHuaServer:enterRoom()
    print("ZhajinHuaServer:enterRoom", tostring(USER_INFO["GroupLevel"]))
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_GET_ROOM)
        :setParameter("level", USER_INFO["GroupLevel"])
        :setParameter("Chip", 1)
        :setParameter("Sid", 1)
        :setParameter("activity_id", USER_INFO["activity_id"])
        :build()
    bm.server:send(pack)
end

--发送准备
function ZhajinHuaServer:CLI_READYNOW_ROOM()
        local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_READYNOW_ROOM)
        :build()
    bm.server:send(pack)
end

--请求推出房间
function ZhajinHuaServer:CLI_QUIT_ROOM()
	local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_QUIT_ROOM)
        :build()
    bm.server:send(pack)

end

--请求比牌
function ZhajinHuaServer:CLI_BI_CARD(seat)
    print("CLI_BI_CARD", tostring(seat))
    if seat == nil then
        dump(bm.Room.uid_seat, "CLI_BI_CARD", nesting)
    end
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_BI_CARD)
        :setParameter("seat", seat)
        :build()
    bm.server:send(pack)

end

--弃牌
function ZhajinHuaServer:CLI_DIU_CARD()
	local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_DIU_CARD)
        :build()
    bm.server:send(pack)
end

--跟注
function ZhajinHuaServer:CLI_GEN_CARD()
    local zhu  = bm.Room.now_zhu
    
    if bm.User.isKan[tonumber(UID)]  ~= nil then
        zhu = zhu * 2
    end

    print("CLI_GEN_CARD", tostring(zhu))

	local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_GEN_CARD)
		:setParameter("gold", zhu)
        :build()
    bm.server:send(pack)
end

--看牌
function ZhajinHuaServer:CLI_SEE_CARD()
	local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_SEE_CARD)
        :build()
    bm.server:send(pack)
end

--加注
function ZhajinHuaServer:CLI_JIA_CARD(gold)
	local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_JIA_CARD)
		:setParameter("gold", gold)
        :build()
    bm.server:send(pack)
end

--火拼
function ZhajinHuaServer:CLI_BET_ALLIN()
    print("CLI_BET_ALLIN", tostring(UID))
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_BET_ALLIN)
        :build()
    bm.server:send(pack)
end
--
function ZhajinHuaServer:CLI_MSG_FACE(id)
    local sendpack = bm.server:createPacketBuilder(PROTOCOL.CLI_MSG_FACE)
                    :setParameter("type", id)
                    :build()
    bm.server:send(sendpack)
end


function ZhajinHuaServer:C2S_DISSOLVE_ROOM()
    print("C2S_DISSOLVE_ROOM ----- 808-------------------------");
    local sendpack = bm.server:createPacketBuilder(PROTOCOL.C2S_DISSOLVE_ROOM)
                    :build()
    bm.server:send(sendpack)
end

--------解散相关-----------
--请求解散房间
function ZhajinHuaServer:C2G_CMD_DISSOLVE_ROOM()
    local pack = bm.server:createPacketBuilder(PROTOCOL.C2G_CMD_DISSOLVE_ROOM)
    :build()
    bm.server:send(pack)
end

--回复请求解散房间
function ZhajinHuaServer:C2G_CMD_REPLY_DISSOLVE_ROOM(agree)
    print("---------------------C2G_CMD_REPLY_DISSOLVE_ROOM----------------------",agree)
    local pack = bm.server:createPacketBuilder(PROTOCOL.C2G_CMD_REPLY_DISSOLVE_ROOM)
    :setParameter("agree", agree)
    :build()
    bm.server:send(pack)
end

return ZhajinHuaServer