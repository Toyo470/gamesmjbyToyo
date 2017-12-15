--
-- Author: LeoLuo
-- Date: 2015-05-09 10:03:08
--

local T = bm.PACKET_DATA_TYPE
local P = {}

local HALL_PROTOCOL = P
HALL_PROTOCOL.HALL_PROTOCOL_EX = "HALL_PROTOCOL_EX"
P.CONFIG = {}
P.CONFIG.CLIENT = {}
P.CONFIG.SERVER = {}
local CLIENT = P.CONFIG.CLIENT
local SERVER = P.CONFIG.SERVER

----------------------------------------------------------------
------------------------- 客户端请求  --------------------------
----------------------------------------------------------------
P.CLI_HEART = 0x110 --发送心跳
CLIENT[P.CLI_HEART] = nil

P.CLI_LOGIN =                        0x116    --登录大厅
CLIENT[P.CLI_LOGIN] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT},
        {name = "storeId", type = T.INT},
        {name = "kind", type = T.INT},
        {name = "userInfo", type = T.STRING},
    }
}


P.CLI_LOGIN_GAME =                        0x113    --进入游戏
CLIENT[P.CLI_LOGIN_GAME] = {
    ver = 1,
    fmt = {
        {name = "Level", type = T.SHORT},--游戏场等级
        {name = "Chip", type = T.INT},--请求场次的底注
        {name = "Sid", type = T.INT},--游戏场的id
        {name = "activity_id", type = T.STRING} --带入活动id
    }
}

P.CLI_LOGIN_ROOM_GROUP                 = 0x1001    --登录组局房间
CLIENT[P.CLI_LOGIN_ROOM_GROUP] = {
    ver = 1,
    fmt = {
        {name = "tableid", type = T.INT},   --桌子ID
        {name = "nUserId", type = T.INT},   --用户ID
        {name = "strkey", type = T.STRING}, --需要验证的key
        {name = "strinfo", type = T.STRING}, --用户个人信息
        {name = "iflag", type = T.INT},   --登陆标志
        {name = "version", type = T.STRING}, --用户版本
        {name = "activity_id", type = T.STRING} --带入活动id
    }
}

P.CLIENT_CMD_SEND_MSG_TO_SERVER                = 0x166    --向服务器发送向组局里发送的文字信息
CLIENT[P.CLIENT_CMD_SEND_MSG_TO_SERVER] = {
    ver = 1,
    fmt = {
        {name = "level", type = T.SHORT},   --游戏level
        {name = "msg", type = T.STRING}
    }
}

-----------------------------------------------------------
-------------------  服务端返回  --------------------------
-----------------------------------------------------------

P.SERVER_CMD_FORWARD_MESSAGE                = 0x0213    --服务器返回组局收到的信息
SERVER[P.SERVER_CMD_FORWARD_MESSAGE] = {
    ver = 1,
    fmt = {
        {name = "msgCount", type = T.INT}, --消息长度
        {name = "msgList", type = T.ARRAY, fixedLengthParser = "msgCount", fixedLength = 0,
            fmt = {
                {name = "msg", type = T.STRING}, --消息
            }
        },
    }
}

P.SVR_HEART               = 0x110    --接收心跳
SERVER[P.SVR_HEART] = {
    ver = 1
}

P.SVR_CLOSE_NET               = 0x0301    --当前玩家被服务器断网
SERVER[P.SVR_CLOSE_NET] = {
    ver = 1
}
P.SVR_KICK_OFF               = 0x0203    --当前玩家被踢下线
SERVER[P.SVR_KICK_OFF] = {
    ver = 1
}

P.SVR_LOGIN_GAME                = 0x0210    --服务器返回进入游戏
SERVER[P.SVR_LOGIN_GAME] = {
    ver = 1,
    fmt = {
        {name = "Tid", type = T.INT}, --桌子ID
        {name = "ServerID", type = T.SHORT}, --服务器ID
        {name = "Ip", type = T.STRING},--服务器ip，如果ip为空的话，则是服务器不够用了，客户端可显示服务器繁忙
        {name = "Port", type = T.INT}, --端口号
        {name = "Res", type = T.INT} --返回标注
    }
}


P.SVR_LOGIN_OK                   = 0x201    --登录成功
SERVER[P.SVR_LOGIN_OK] = {
    ver = 1,
    fmt = {
        {name = "Ver", type = T.INT},--成功与否标注，1为成功
        {name = "Levelcount", type = T.INT},--等级场个数
        {name = "Usercount", type = T.ARRAY,fixedLengthParser = "Levelcount",fixedLength = 0,
            fmt = {
                {name = "counts", type = T.INT},   --等级场人数
            }
        },
        {name = "Friendcount", type = T.INT},
        {name = "Tid", type = T.INT}, --桌子ID，0表示无桌子，第一次登陆; 不为0时则表示需要重连
        {name = "Ip", type = T.STRING,request = "Tid",requestValue = 0}, --服务器ip
        {name = "port", type = T.INT,request = "Tid",requestValue = 0},--服务器端口
        {name = "Serverlevel", type = T.SHORT,request = "Tid",requestValue = 0},--服务器等级
        {name = "on_look_user", type = T.INT},--围观用户id
        {name = "type", type = T.INT},--游戏类型
        -- {name = "battles_count", type = T.INT},--场次列表
        -- {name = "battles_list", type = T.ARRAY,fixedLengthParser = "battles_count",fixedLength = 0,
        --     fmt = {
        --         {name = "level", type = T.INT},   --等级
        --         {name = "counts", type = T.INT},   --等级场人数
        --     }
        -- },
    }
}



--围观重连
P.SVR_LOGINLOOK_OK                   = 0x532
SERVER[P.SVR_LOGINLOOK_OK] = {
    ver = 1,
    fmt = {
        {name = "Ver", type = T.INT},--成功与否标注，1为成功
        {name = "Levelcount", type = T.INT},--等级场个数
        {name = "Usercount", type = T.ARRAY,fixedLengthParser = "Levelcount",fixedLength = 0,
            fmt = {
                {name = "counts", type = T.INT},   --等级场人数
            }
        },
        {name = "Friendcount", type = T.INT},
        {name = "Tid", type = T.INT}, --桌子ID，0表示无桌子，第一次登陆; 不为0时则表示需要重连
        {name = "Ip", type = T.STRING,request = "Tid",requestValue = 0}, --服务器ip
        {name = "port", type = T.INT,request = "Tid",requestValue = 0},--服务器端口
        {name = "Serverlevel", type = T.SHORT,request = "Tid",requestValue = 0},--服务器等级
        {name = "on_look_user", type = T.INT},--围观用户id
        {name = "type", type = T.INT},--游戏类型
        -- {name = "battles_count", type = T.INT},--场次列表
        -- {name = "battles_list", type = T.ARRAY,fixedLengthParser = "battles_count",fixedLength = 0,
        --     fmt = {
        --         {name = "level", type = T.INT},   --等级
        --         {name = "counts", type = T.INT},   --等级场人数
        --     }
        -- },
    }
}

--心跳
P.CLISVR_HEART_BEAT              = 0x0110    --server心跳包

return HALL_PROTOCOL