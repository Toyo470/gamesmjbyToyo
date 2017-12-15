--
-- Author: ZT
-- Date: 2016-09-03 19:43:23
--
local T = bm.PACKET_DATA_TYPE
local P = {}

local CHAT_PROTOCOL = P
P.CONFIG = {}
P.CONFIG.CLIENT = {}
P.CONFIG.SERVER = {}
local CLIENT = P.CONFIG.CLIENT
local SERVER = P.CONFIG.SERVER


P.MSG_LOGIN =                        0x100    --
CLIENT[P.MSG_LOGIN] = {
    ver = 1,
    fmt = {
        {name="data",type=T.STRING}

    }
}





------------------------------------------------------------
P.SVR_SUCCESS               = 0x100    --
SERVER[P.SVR_SUCCESS] = {
    ver = 1,
    fmt = {
        {name="data",type=T.STRING}
    }
}


return CHAT_PROTOCOL