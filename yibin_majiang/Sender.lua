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
        print("-------------------------str----------",str,"-----protocl_num------",protocl_num)
        local pack = bm.server:createPacketBuilder(protocl_num)
            :setParameter("msg_data", str)
            :build()
        bm.server:send(pack)
    end
end

function ZZSend:LoginGame()
    local activity_id = USER_INFO["activity_id"]
    local level = USER_INFO["GroupLevel"]
    -- level = 75
    -- activity_id = 372
    print("sending 113----------activity_id---------------",activity_id,"-----level------",level)

    local pack = bm.server:createPacketBuilder(0x0113)
                    :setParameter("level", level)
                    :setParameter("Chip", 100)
                    :setParameter("Sid", 1)
                    :setParameter("activity_id", activity_id)
                    :build()
    bm.server:send(pack)
end


function ZZSend:account_login(table_id)
    -- body
    print("sending ------------1001-------table_id------------",table_id)
    local pack = bm.server:createPacketBuilder(mprotocol.H2G_ACCOUNT_LOGIN)
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


function ZZSend:sendCard(card_Value )
    -- body
   -- printError("card_Value")
    local tbl = {}
    tbl["card_index"] = card_Value
    self:send(mprotocol.H2G_ACCOUNT_CHOOSE_CARD,tbl)

end

function ZZSend:requestHandle(result,card_Value )
    -- body
end

function ZZSend:H2G_ACCOUNT_READY()
    -- body
   self:send(mprotocol.H2G_ACCOUNT_READY)
end

return ZZSend
