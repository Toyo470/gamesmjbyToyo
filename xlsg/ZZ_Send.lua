require("framework.init")

--定义麻将房服务
local ZZSend = class("ZZSend")

function ZZSend:ctor()
	
end

function ZZSend:send(protocl_num,protocl_tbl)
	-- body
	protocl_tbl = protocl_tbl or {}
	if type(protocl_tbl) == "table" then
		local str = json.encode(protocl_tbl)
		print("-------------------------str---------------------",str)
		local pack = bm.server:createPacketBuilder(protocl_num)
	        :setParameter("msg_data", str)
	        :build()
	    bm.server:send(pack)
	end
end

function ZZSend:LoginGame(level)
--USER_INFO["activity_id"] = 372

	local pack = bm.server:createPacketBuilder(0x0113)
	                :setParameter("level", level)
	                :setParameter("Chip", 100)
	                :setParameter("Sid", 1)
	                :setParameter("activity_id", USER_INFO["activity_id"])
	                :build()
	bm.server:send(pack)
  print("sending 113-------------------------")
  dump("进入组局", "进入组局")

end


function ZZSend:account_login(protocl_num,table_id)
	-- body
	print("sending ------------1001-------rotocl_num,table_id,user_id,------------",protocl_num,table_id,user_id)
	local pack = bm.server:createPacketBuilder(protocl_num)
	                :setParameter("table_id", table_id)
	                :setParameter("nUserId", USER_INFO["uid"])
	                :setParameter("strKey", json.encode("kadlelala"))
	                :setParameter("strInfo", USER_INFO["user_info"])
	                :setParameter("iflag", 2)
	                :setParameter("version", 1)
	                :setParameter("activity_id", USER_INFO["activity_id"])
	                :build()
	bm.server:send(pack)
end


function ZZSend:CLI_MSG_FACE(id)
    local sendpack = bm.server:createPacketBuilder(mprotocol.H2G_ACCOUNT_SEND_FACE)
                    :setParameter("type", id)
                    :build()
    bm.server:send(sendpack)
    print("sending_face id ",id,mprotocol.H2G_ACCOUNT_SEND_FACE,"mprotocol.H2G_ACCOUNT_SEND_FACE")
end


function ZZSend:SendGameMsg(level,msg)

    dump(level, "-----当前组局level-----")
    dump(msg, "-----发送组局信息-----")

    local pack = bm.server:createPacketBuilder(mprotocol.H2G_CLIENT_CMD_FORWARD_MESSAGE)
                    :setParameter("level", level)
                    :setParameter("msg", msg)
                    :build()
    bm.server:send(pack)

end

return ZZSend
