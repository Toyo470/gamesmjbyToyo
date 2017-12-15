
--定义麻将房服务
local MajiangroomServer = class("MajiangroomServer")

--导入麻将房套接字请求处理（协议）
local PROTOCOL = import("zz_majiang.ZZ_Protocol")

function MajiangroomServer:ctor()
	
end

--退出房间
function MajiangroomServer:quickRoom() 
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_QUIT_ROOM)
        :build()
    bm.server:send(pack)
  
end

--取消托管
function MajiangroomServer:cancelTuo(index)
    index = index or 0
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_ROBOT)
        :setParameter("kind", index)
        :build()
    bm.server:send(pack)
end


--用户发送准备
function MajiangroomServer:readyNow()
    print("-----------send------------i am -readyNow---------------")
	local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_READYNOW_ROOM)
        :build()
    bm.server:send(pack)
end

--选缺
function MajiangroomServer:choiceQue(que)
	local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_CHOICE_QUE)
		:setParameter("que", que)
        :build()
    bm.server:send(pack)
    print("send---------choiceQue-----200D--------",que)
end

--出牌
function MajiangroomServer:sendCard(value)
    print("0x2002------------senfCard-----------value==",value)
    local pack = bm.server:createPacketBuilder(PROTOCOL.SEND_CARD)
        :setParameter("card", value)
        :build()
    bm.server:send(pack)

end

--用户请求操作,这里是哪些碰，杆，胡的操作
function MajiangroomServer:requestHandle(handle,value)


    print("user caozuo peng gan hu caozuo ")
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_REQUEST_HANDLE)
        :setParameter("handle", handle)
        :setParameter("card", value)    
        :build()
    bm.server:send(pack)

end

--发送聊天信息
function MajiangroomServer:send_chat_msg(msg)

    local pack = bm.server:createPacketBuilder(PROTOCOL.CHAT_MSG)
        :setParameter("msg", msg)   
        :build()

    print("msg...................",msg)
    bm.server:send(pack)
end

--发送要换的牌
function MajiangroomServer:send_Huan_card(tb)
    
    dump(tb, "-----发送要换的牌-----")

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_COMMAND_CHANGE_CARD)
        :setParameter("pval1", tb[1])
        :setParameter("pval2", tb[2])
        :setParameter("pval3", tb[3])
        :build()
    bm.server:send(pack)
    
end

--0x0120用户请求进入比赛场
function MajiangroomServer:c2s_CLIENT_CMD_JOIN_MATCH(level)
  -- level = 30
    print("send_-----0x0120----------level----------",level)
     local pack = bm.server:createPacketBuilder(PROTOCOL.c2s_CLIENT_CMD_JOIN_MATCH)
        :setParameter("Level", level)
        :setParameter("flag", 1)
        :build()
    bm.server:send(pack)
end

-- --用户退出比赛：0x3901
function MajiangroomServer:c2s_CLIENT_QUIT_MATCH(MatchID,userID)
     print("send_-----0x3901-------MatchID,userID-------------",MatchID,userID)
         local pack = bm.server:createPacketBuilder(PROTOCOL.c2s_CLIENT_QUIT_MATCH)
        :setParameter("MatchID", MatchID)
         :setParameter("userID", userID)
        :build()
    bm.server:send(pack)
end

--客户端登录房间组
function MajiangroomServer:CLI_LOGIN_ROOM_GROUP()
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_LOGIN_ROOM_GROUP)
    :setParameter("MatchID", MatchID)
    :setParameter("userID", userID)
    :build()
    bm.server:send(pack)
end

--请求解散房间
function MajiangroomServer:C2G_CMD_DISSOLVE_ROOM()
    local pack = bm.server:createPacketBuilder(PROTOCOL.C2G_CMD_DISSOLVE_ROOM)
    :build()
    bm.server:send(pack)
end

--回复请求解散房间
function MajiangroomServer:C2G_CMD_REPLY_DISSOLVE_ROOM(agree)
    print("---------------------C2G_CMD_REPLY_DISSOLVE_ROOM----------------------",agree)
    local pack = bm.server:createPacketBuilder(PROTOCOL.C2G_CMD_REPLY_DISSOLVE_ROOM)
    :setParameter("agree", agree)
    :build()
    bm.server:send(pack)
end

return MajiangroomServer