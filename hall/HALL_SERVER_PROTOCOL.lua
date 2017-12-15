--
-- Author: LeoLuo
-- Date: 2015-05-09 10:03:08
--

local T = bm.PACKET_DATA_TYPE
local P = {}

local HALL_SERVER_PROTOCOL = P
P.CONFIG = {}
P.CONFIG.CLIENT = {}
P.CONFIG.SERVER = {}
local CLIENT = P.CONFIG.CLIENT
local SERVER = P.CONFIG.SERVER

----------------------------------------------------------------
------------------------- 客户端请求  --------------------------
----------------------------------------------------------------
P.CLI_HEART = 0x2008 --发送心跳
CLIENT[P.CLI_HEART] = nil

P.CLI_LOGIN =                        0x116    --登录大厅
CLIENT[P.CLI_LOGIN] = {
    ver = 1,
    fmt = {
        {name = "Uid", type = T.INT},
        {name = "isOnline", type = T.SHORT},
        {name = "terminalType", type = T.SHORT},
        {name = "Version", type = T.INT},
        {name = "Gid", type = T.INT},
        {name = "Strver", type = T.STRING}
    }
}

P.CLI_LOGIN_GAME =                        0x113    --进入游戏
CLIENT[P.CLI_LOGIN_GAME] = {
    ver = 1,
    fmt = {
        {name = "Level", type = T.SHORT},--游戏场等级
        {name = "Chip", type = T.INT},--请求场次的底注
        {name = "Sid", type = T.INT},--游戏场的id
        {name = "activity_id", type = T.STRING},--组局增加字段,活动ID
    }
}

P.CLI_GET_ONLINE                 = 0x0311    --客户端请求获取各等级场在线人数
CLIENT[P.CLI_GET_ONLINE] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT},
        {name = "userInfo", type = T.STRING}
    }
}

P.CLI_GET_ROOM                   = 0x6113    --获取房间id
CLIENT[P.CLI_GET_ROOM] = {
    ver = 1,
    fmt = {
        {name = "level", type = T.INT},   --桌子等级
        {name = "type", type = T.BYTE},   --登陆类型，0--随机登陆，1--指定桌子登陆
        {name = "targetid", type = T.INT} --目标桌子ID，0表示随机登陆
    }
}

P.CLI_CHANGE_ROOM               = 0x0115  --用户请求换桌
CLIENT[P.CLI_CHANGE_ROOM] = {
    ver = 1,
    fmt = {
        {name = "level", type = T.INT},   --桌子等级
        {name = "tid", type = T.INT} --原来的桌子id
    }
}

    
P.CLI_LOGIN_ROOM                 = 0x1001    --登录房间
CLIENT[P.CLI_LOGIN_ROOM] = {
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


P.CLI_LOGOUT_ROOM                = 0x1002    --用户请求离开房间
CLIENT[P.CLI_LOGOUT_ROOM] = nil


P.CLI_SEAT_DOWN                  = 0x1013    --用户请求坐下
CLIENT[P.CLI_SEAT_DOWN] = {
    ver = 1,
    fmt = {
        {name = "seatId", type = T.INT},   -- 座位ID
        {name = "ante", type = T.INT64},    -- 携带金额      
        {name = "autoBuyin", type = T.INT}  -- 自动买入
    }
}

P.CLI_STAND_UP                   = 0x1004    --用户请求站立
CLIENT[P.CLI_STAND_UP] = nil

P.CLI_READY_GAME                = 0x2001    --用户准备
CLIENT[P.CLI_READY_GAME] = nil

P.CLI_OTHER_CARD                 = 0x7005    --用户请求第三张牌
CLIENT[P.CLI_OTHER_CARD] = {
    ver = 1,
    fmt = {
        {name = "type", type = T.INT} --是否需要第三张牌，0--不需要，1--需要
    }
}

P.CLI_SET_BET                    = 0x2002    --用户下注
CLIENT[P.CLI_SET_BET] = {
    ver = 1,
    fmt = {
        {name = "Score", type = T.SHORT} --玩家叫的分数
    }
}

P.CLI_PLAYER_CARD                    = 0x2003    --玩家出牌
CLIENT[P.CLI_PLAYER_CARD] = {
    ver = 1,
    fmt = {
        {name = "Cardcount", type = T.BYTE},--玩家出牌的的数量
        {name = "Cardbuf", type = T.ARRAY,fixedLengthParser = "Cardcount",fixedLength = 0,
            fmt = {
                {name = "card", type = T.BYTE},   --扑克牌数值
            }
        }
    }
}

P.CLI_PASS                = 0x2004    --玩家pass
CLIENT[P.CLI_PASS] = nil

P.CLI_SEND_MSG                   = 0x7007    --用户请求房间内聊天
CLIENT[P.CLI_SEND_MSG] = {
    ver = 1,
    fmt = {
        {name = "type", type = T.INT}, --聊天类型，目前无区分，默认为0；/*0--字符，1--表情*/
        {name = "strChat", type = T.STRING} --聊天内容
    }
}

--托管动作
P.CLI_AUTO                   = 0x2006    --玩家托管动作
CLIENT[P.CLI_AUTO] = {
    ver = 1,
    fmt = {
        {name = "action", type = T.INT} --0:取消托管，1:请求托管
    }
}

P.CLI_SEND_ROOM_BROADCAST                   = 0x1050   --发送房间广播
CLIENT[P.CLI_SEND_ROOM_BROADCAST] = {
    ver = 1,
    fmt = {
        {name = "info", type = T.STRING} -- 发送内容json
    }
}
--请求私人房间
P.CLI_CREATE_PRIVATEROOM                 = 0x149
CLIENT[P.CLI_CREATE_PRIVATEROOM] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT}, --用户id
        {name = "svid", type = T.INT}, --serverid，底分连接：底分100-->20201,500-->20401,1000-->20601
        {name = "level", type = T.INT}, --服务器等级，底分：100-->11,500-->12,1000-->13
        {name = "roomtype", type = T.INT}, --房间类型，2
        {name = "basechip", type = T.INT}, --底分
        {name = "money", type = T.INT}, --带入筹码
        {name = "roomName", type = T.STRING}, --房间名
        {name = "password", type = T.STRING}, --密码
        {name = "islovegirl", type = T.INT}, --保留，0
        {name = "lovegirl", type = T.STRING}, --保留
        {name = "invitecode", type = T.STRING}, --保留
        {name = "activity", type = T.STRING}, --保留
        {name = "liftTime", type = T.INT} --保留，0
    }
}
--兑换筹码
P.CLI_CHANGE_CHIP                   = 0x805
CLIENT[P.CLI_CHANGE_CHIP] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT}, --用户id
        {name = "chip", type = T.INT} --请求兑换筹码数
    }
}
--获取筹码
P.CLI_GET_CHIP                   = 0x806
CLIENT[P.CLI_GET_CHIP] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT} --用户id
    }
}
-------------------  斗地主比赛  -------------------
P.CLI_SEND_JOIN_MATCH                   = 0x0120   --用户请求进入比赛场
CLIENT[P.CLI_SEND_JOIN_MATCH] = {
    ver = 1,
    fmt = {
        {name = "Level", type = T.SHORT}, -- 比赛等级
        {name = "flag", type = T.SHORT} -- 比赛等级
    }
}

--P.CLI_SEND_ENTER_MATCH                   = 0x1001   --用户进入比赛场
--CLIENT[P.CLI_SEND_ENTER_MATCH] = {
--    ver = 1,
--    fmt = {
--        {name = "MatchID", type = T.INT},   --桌子ID
--        {name = "nUserId", type = T.INT},   --用户ID
--        {name = "strkey", type = T.STRING}, --需要验证的key
--        {name = "strinfo", type = T.STRING}, --用户个人信息
--        {name = "iflag", type = T.INT},   --登陆标志
--    }
--}

P.CLI_SEND_LOGOUT_MATCH                   = 0x3901   --用户退出比赛
CLIENT[P.CLI_SEND_LOGOUT_MATCH] = {
    ver = 1,
    fmt = {
        {name = "MatchID", type = T.INT},   --桌子ID
        {name = "nUserId", type = T.INT},   --用户ID
    }
}

P.CLI_REQUEST_HISTORY                = 0x807    --用户请求离开房间
CLIENT[P.CLI_REQUEST_HISTORY] = {
    ver = 1,
    fmt = {
        {name = "gameno", type = T.INT} --当前gameno
    }
}

P.CLI_REQUEST_USER_TABLE                = 0x0022    --用户请求离开房间
CLIENT[P.CLI_REQUEST_USER_TABLE] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT}, --用户id
    }
}


--请求房间返回
P.SVR_REQUEST_USER_TABLE               = 0x0022
SERVER[P.SVR_REQUEST_USER_TABLE] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT}, --成功与否标注，0失败
    }
}
-----------------------------------------------------------
-------------------  服务端返回  --------------------------
-----------------------------------------------------------
P.SVR_HEART               = 0x600d    --接收心跳
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

--请求房间返回
P.SVR_CREATE_PRIVATEROOM                = 0x206
SERVER[P.SVR_CREATE_PRIVATEROOM] = {
    ver = 1,
    fmt = {
        {name = "ret", type = T.INT}, --成功与否标注，0失败
        {name = "ServerID", type = T.INT,request = "ret",requestValue = 0}, --服务器ID
        {name = "Tid", type = T.INT,request = "ret",requestValue = 0}, --房间号
        {name = "Ip", type = T.STRING,request = "ret",requestValue = 0},--服务器ip，如果ip为空的话，则是服务器不够用了，客户端可显示服务器繁忙
        {name = "Port", type = T.INT,request = "ret",requestValue = 0}, --端口号
        {name = "RoomIndex", type = T.INT,request = "ret",requestValue = 0}, --房间下标
        {name = "CreateTime", type = T.INT,request = "ret",requestValue = 0} --创建时间
    }
}

--请求兑换筹码返回
P.SVR_CHANGE_CHIP                = 0x905
SERVER[P.SVR_CHANGE_CHIP] = {
    ver = 1,
    fmt = {
        {name = "ret", type = T.INT}, --成功与否标注，0成功
        {name = "uid", type = T.INT}, --兑换筹码的uid
        {name = "chip", type = T.INT}, --服务器ID
        {name = "money", type = T.INT} --玩家剩余宝贝币
    }
}
--请求获取筹码返回
P.SVR_GET_CHIP                = 0x906
SERVER[P.SVR_GET_CHIP] = {
    ver = 1,
    fmt = {
        {name = "ret", type = T.INT}, --成功与否标注，0失败
        {name = "chip", type = T.INT}, --兑换筹码数
    }
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
        {name = "Serverlevel", type = T.SHORT,request = "Tid",requestValue = 0}--服务器等级
    }
}


P.SVR_ONLINE                     = 0x0311    --服务器返回客户端各等级场在线人数
SERVER[P.SVR_ONLINE] = {
    ver = 1,
    fmt = {
        {
            name = "levelOnlines", type = T.ARRAY,
            lengthType = T.INT,
            fmt = {
                {name = "level", type = T.INT},   --等级场ID
                {name = "userCount", type = T.INT} --在线人数
            }
        }
    }
}


P.SVR_LOGIN_ROOM_OK              = 0x1007    --登录房间OK
SERVER[P.SVR_LOGIN_ROOM_OK] = {
    ver = 1,
    fmt = {
        {name = "Level", type = T.INT},--房间等级
        {name = "Basechip", type = T.INT},--房间底注
        {name = "Tabletype", type = T.SHORT}, --房间类型
        {name = "Seatid", type = T.INT},--座位ID
        {name = "Userscore", type = T.INT},--玩家金币
        {name = "Playcount", type = T.INT},--桌子上其他玩家的个数
        {name = "playerlist", type = T.ARRAY,fixedLengthParser = "Playcount",fixedLength = 0,
            fmt = {
                {name = "Userid", type = T.INT},--其他玩家的uid
                {name = "Seatid", type = T.INT}, -- 其他玩家的seatid
                {name = "ReadyStart", type = T.INT}, -- 其他玩家是否准备
                {name = "Userinfo", type = T.STRING}, -- 其他玩家的信息
                {name = "Playerscore", type = T.INT},--其他玩家的金币
            }
        },
        {name = "OwnerID", type = T.INT}--房主ID
    }
}


P.SVR_LOGIN_ROOM_FAIL            = 0x1005    --登录房间失败
SERVER[P.SVR_LOGIN_ROOM_FAIL] = {
    ver = 1,
    fmt = {
        {name = "nErrno", type = T.INT}--错误码
    }
}


P.SVR_SELF_SEAT_DOWN_OK                  = 0x8003
SERVER[P.SVR_SELF_SEAT_DOWN_OK] = {
    ver = 1,
    fmt = {
        {name = "ret", type = T.INT}
    }
}

P.SVR_STAND_UP                   = 0x8004    --用户请求站立
SERVER[P.SVR_STAND_UP] = {
    ver = 1,
    fmt = {
        {name = "ret", type = T.INT},
        {name = "seatId", type = T.INT},
        {name = "money", type = T.INT64}
    }
}

P.SVR_READY_GAME                 = 0x6001    --用户准备返回
SERVER[P.SVR_READY_GAME] = {
    ver = 1,
    fmt = {
        {name = "Uid", type = T.INT}
    }
}

P.SVR_OTHER_CARD                 = 0x2005    --用户请求第三张牌结果
SERVER[P.SVR_OTHER_CARD] = {
    ver = 1,
    fmt = {
        {name = "card", type = T.BYTE}
    }
}

P.SVR_SET_BET                    = 0x2006    --用户请求修改底注结果
SERVER[P.SVR_SET_BET] = {
    ver = 1,
    fmt = {
        {name = "ret", type = T.BYTE},
        {name = "errno", type = T.INT, depends=function(ctx) return ctx.ret == 1 end}
    }
}

P.SVR_MSG                        = 0x8007    --服务器广播房间内聊天
SERVER[P.SVR_MSG] = {
    ver = 1,
    fmt = {
        {name = "type", type = T.INT}, -- 聊天类型，目前无区分，默认为0；/*0--字符，1--表情*/
        {name = "strChat", type = T.STRING} --聊天内容
    }
}

P.SVR_DEAL                       = 0x4001    --发牌
SERVER[P.SVR_DEAL] = {
    ver = 1,
    fmt = {
        {name = "Cardcount", type = T.SHORT}, -- 总共多少牌
        {name = "Cardbuf", type = T.ARRAY,fixedLengthParser = "Cardcount",fixedLength = 0,
            fmt = {
                {type = T.BYTE},   --扑克牌数值
            }
        }
    }
}

P.SVR_LOGIN_ROOM                 = 0x100D    --服务器广播用户登陆房间
SERVER[P.SVR_LOGIN_ROOM] = {
    ver = 1,
    fmt = {
        {name = "userid", type = T.INT},--玩家uid
        {name = "seatid", type = T.INT},--玩家座位号
        {name = "ready", type = T.INT},--玩家座位号
        {name = "userinfo", type = T.STRING},--玩家信息
        {name = "score", type = T.INT}--玩家座位号
    }
}

P.SVR_LOGOUT_ROOM_OK                = 0x1008    --服务器返回玩家退出游戏成功
SERVER[P.SVR_LOGOUT_ROOM_OK] = {
    ver = 1
}

P.SVR_LOGOUT_ROOM                = 0x100E    --服务器广播玩家退出
SERVER[P.SVR_LOGOUT_ROOM] = {
    ver = 1,
    fmt = {
        {name = "Uid", type = T.INT}
    }
}

P.SVR_RELOAD_ROOM                = 0x1009    --玩家重连逻辑
SERVER[P.SVR_RELOAD_ROOM] = {
    ver = 1,
    fmt = {
        {name = "Gamelevel", type = T.INT},--游戏场次唯一level
        {name = "Tabletyle", type = T.SHORT},--桌子类型
        {name = "Seated", type = T.SHORT},--座位ID
        {name = "Readystart", type = T.SHORT},--是否准备
        {name = "Playercount", type = T.SHORT},--其他玩家的个数
        {name = "playerlist", type = T.ARRAY,fixedLength = 2,
            fmt = {
                {name = "Uid",type = T.INT},   --桌子其他玩家uid
                {name = "Seatid",type = T.SHORT},   --桌子其他玩家seatid
                {name = "AIUser",type = T.SHORT},   --玩家是否托管
                {name = "HandCardCount",type = T.SHORT},   --玩家手牌数量
                {name = "UserInfo",type = T.STRING},   --玩家手牌数量
                {name = "ReadyStart",type = T.SHORT},   --是否准备
            }
        },
        {name = "Basechip", type = T.INT},--底注
        {name = "Outcardtime", type = T.SHORT},--出牌时间
        {name = "Gamestatus", type = T.SHORT},--桌子状态
        {name = "Handcardcount", type = T.SHORT},--手牌数量
        {name = "Carddata", type = T.ARRAY,fixedLengthParser = "Handcardcount",fixedLength = 2,
            fmt = {
                {type = T.BYTE},   --扑克牌数值
            }
        },
        --叫分状态
        {name = "Gamemode", type = T.INT,request = "Gamestatus",requestValue = 1},--叫分还是叫抢
        {name = "Landscorewin", type = T.INT,request = "Gamestatus",requestValue = 1},--最高的叫分玩家
        {name = "Curlandlordscore", type = T.INT,request = "Gamestatus",requestValue = 1},--当前的叫分玩家
        {name = "Landscore", type = T.SHORT,request = "Gamestatus",requestValue = 1},--当前分数
        {name = "Lefttime", type = T.SHORT,request = "Gamestatus",requestValue = 1},--剩余时间
        --打牌状态
        --3张地主牌
        {name = "LandCarddata", type = T.ARRAY,fixedLength = 3,request = "Gamestatus",requestValue = 2,
            fmt = {
                {type = T.BYTE},   --扑克牌数值
            }
        },
        {name = "LandlordUserId", type = T.INT,request = "Gamestatus",requestValue = 2},--地主玩家id
        {name = "OutCardUserId", type = T.INT,request = "Gamestatus",requestValue = 2},--当前出牌玩家id
        {name = "LeftTime", type = T.SHORT,request = "Gamestatus",requestValue = 2},--出牌剩余时间
        {name = "mutiple", type = T.SHORT,request = "Gamestatus",requestValue = 2},--???
        {name = "LandlordScore", type = T.SHORT,request = "Gamestatus",requestValue = 2},--当前分数
        {name = "iTime", type = T.SHORT,request = "Gamestatus",requestValue = 2},--???
        --3个玩家最近一次的出牌
        {name = "LastCarddata", type = T.ARRAY,fixedLength = 3,request = "Gamestatus",requestValue = 2,
            fmt = {
                {name = "CardCount",type = T.SHORT},--出牌数量
                {name = "cards", type = T.ARRAY,fixedLengthParser = "CardCount",fixedLength = 0,
                    fmt = {
                        {type = T.BYTE},   --扑克牌数值
                    }
                },
            }
        },
        {name = "bFlag", type = T.BYTE},--保留字段，value = 0
        {name = "sFlag", type = T.SHORT},--保留字段，value = 0
        {name = "OwnewUid", type = T.INT,request = "Gamelevel",requestValue = 0},--房间持有玩家id
        {name = "RoomName", type = T.STRING,request = "Gamelevel",requestValue = 0},--房间持有玩家id
        {name = "countShowCards", type = T.INT},--显示牌人数
        {name = "bShowCards", type = T.SHORT}--是否显示牌
    }
}


P.SVR_OTHER_OFFLINE              = 0x8005    --服务器广播用户掉线
SERVER[P.SVR_OTHER_OFFLINE] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT}
    }
}

P.SVR_GAME_START                 = 0x6002    --服务器广播游戏开始
SERVER[P.SVR_GAME_START] = {
    ver = 1,
    fmt = {
        {name = "Landlordtime", type = T.INT}, --叫地主时间
        {name = "Outcardtime", type = T.INT}, --出牌时间
    }
}

P.SVR_BET                   = 0x6003    --服务器广播玩家下注
SERVER[P.SVR_BET] = {
    ver = 1,
    fmt = {
        {name = "PreScoreUserId", type = T.INT},--上一个叫分玩家的userid
        {name = "PreScore", type = T.INT},--上一个叫分玩家的分数
        {name = "nCurAnte", type = T.INT}--下一个叫分玩家的用户id
    }
}

P.SVR_CAN_OTHER_CARD             = 0x8009    --服务器广播可以开始获取第三张牌
SERVER[P.SVR_CAN_OTHER_CARD] = {
    ver = 1,
    fmt = {
        {name = "seatId", type = T.INT}
    }
}

P.SVR_OTHER_OTHER_CARD           = 0x6010    --服务器广播其它用户操作获取第三张牌结果
SERVER[P.SVR_OTHER_OTHER_CARD] = {
    ver = 1,
    fmt = {
        {name = "seatId", type = T.INT},
        {name = "type", type = T.INT} --是否需要第三张牌，0--不需要，1--需要
    }
}

P.SVR_PLAY_GAME                   = 0x6004    --服务器广播开始打牌
SERVER[P.SVR_PLAY_GAME] = {
    ver = 1,
    fmt = {
        {name = "nOutCardUserId", type = T.INT},--出牌玩家的uid
        {name = "Cardcount", type = T.SHORT},--底牌的数量
        {
            name = "Cardbuf", type = T.ARRAY,
            fixedLengthParser = "Cardcount",fixedLength = 0,
            fmt = {
                {type = T.BYTE}   --扑克牌数值
            }
        }
    }
}

P.SVR_PLAY_CARD                   = 0x6005    --服务器广播玩家出牌
SERVER[P.SVR_PLAY_CARD] = {
    ver = 1,
    fmt = {
        {name = "nPreOutUserId", type = T.INT},--上一个出牌玩家的uid
        {name = "nNextOutUserId", type = T.INT},--下一个出牌玩家的uid
        {name = "Cardtype", type = T.BYTE},--玩家出牌类型
        {name = "Cardcount", type = T.BYTE},--底牌的数量
        {
            name = "Cardbuf", type = T.ARRAY,
            fixedLengthParser = "Cardcount",fixedLength = 0,
            fmt = {
                {type = T.BYTE}   --扑克牌数值
            }
        }
    }
}

P.SVR_PLAY_CARD_ERROR                   = 0x4002    --返回出牌错误
SERVER[P.SVR_PLAY_CARD_ERROR] = {
    ver = 1,
    fmt = {
        {name = "nError", type = T.INT},--错误类型
    }
}
P.SVR_PASS                   = 0x6006  --服务器广播玩家pass
SERVER[P.SVR_PASS] =  {
    ver = 1,
    fmt = {
        {name = "nIsNewTurn", type = T.INT},--是否是新回合
        {name = "nPassUserId", type = T.INT},--Pass的玩家uid
        {name = "nNextOutUserId", type = T.INT}--下一个出牌玩家
    }
}
    --服务器广播牌局结束，结算结果
P.SVR_GAME_OVER                  =0x6008
SERVER[P.SVR_GAME_OVER] = {
    ver = 1,
    fmt = {
        {name = "Basechip", type = T.INT},--底注
        {name = "CurLandScore", type = T.INT},--叫分/叫抢的倍数
        {name = "BombTimes", type = T.INT},--炸弹的倍数
        {name = "Sprint", type = T.INT},--是否是春天
        {name = "Totoltimes", type = T.INT},--总倍数
        {name = "winnerType", type = T.INT},--地主还是农民赢
        {name = "playerList", type = T.ARRAY,fixedLength = 3,
            fmt = {
                {name = "Uid", type = T.INT},--玩家uid
                {name = "Turningscore", type = T.INT},--变化的钱
                {name = "isOnline", type = T.INT}, --是否在线
                {name = "Level", type = T.INT},--玩家等级
                {name = "Cardcount", type = T.SHORT},--玩家还剩的牌的数量
                {name = "Cardbuf", type = T.ARRAY,fixedLengthParser = "Cardcount",fixedLength = 0,
                    fmt = {
                        {type = T.BYTE}   --扑克牌数值
                    }
                },
                {name = "Kickoff", type = T.INT},--是否踢人
            }
        },
        {name = "scoreList", type = T.ARRAY,fixedLength = 3,
            fmt = {
                {name = "score", type = T.INT},--玩家金币
                {name = "safebox", type = T.INT},--玩家保险箱
            }
        },
        {name = "expInter", type = T.ARRAY,fixedLength = 3,
            fmt = {
                {name = "exp",type = T.INT}   --玩家保险箱
            }
        },--玩家经验增量
        {name = "Expend", type = T.INT}--台费
    }
}

P.SVR_SHOW_CARD                  = 0x6011    --服务器广播用户亮牌
SERVER[P.SVR_SHOW_CARD] = {
    ver = 1,
    fmt = {
        {name = "seatId", type = T.INT},
        {
            name = "cards", type = T.ARRAY,
            lengthType = T.INT,
            fmt = {
                {type = T.BYTE},   --扑克牌数值
            }
        }
    }
}

P.SVR_CARD_NUM                   = 0x6012  --服务器广播发牌开始
SERVER[P.SVR_CARD_NUM] =  {
    ver = 1,
    fmt = {
        {name = "totalAnte", type = T.INT64}
    }
}
--服务器返回托管
P.SVR_DDZ_AUTO                   = 0x6007
SERVER[P.SVR_DDZ_AUTO] =  {
    ver = 1,
    fmt = {
        {name = "Userid", type = T.INT},--玩家id
        {name = "action", type = T.INT}--0:取消托管，1：请求托管
    }
}
--用户请求进入比赛场返回
P.SVR_MATCH_LOGIN                   = 0x211
SERVER[P.SVR_MATCH_LOGIN] =  {
    ver = 1,
    fmt = {
        {name = "MatchID", type = T.INT},--赛场id
        {name = "serverID", type = T.SHORT},--serverid
        {name = "Ip", type = T.STRING},
        {name = "Port", type = T.INT}
    }
}
--用户请求进入比赛场返回失败
P.SVR_MATCH_LOGIN_FAILED                   = 0x7109
SERVER[P.SVR_MATCH_LOGIN_FAILED] =  {
    ver = 1,
    fmt = {
        {name = "Errortype", type = T.INT}--错误代码
    }
}
--用户请求进入比赛场返回成功
P.SVR_MATCH_LOGIN_OK                   = 0x7101
SERVER[P.SVR_MATCH_LOGIN_OK] =  {
    ver = 1,
    fmt = {
        {name = "MatchId", type = T.INT},--比赛ID
        {name = "MatchUserCount", type = T.INT},--当前比赛多少人
        {name = "totalCount", type = T.INT},--总共多少人
        {name = "Gametype", type = T.INT},--比赛类型
        {name = "Costformatch", type = T.INT},--报名费
        {name = "Logintype", type = T.INT},--报名方式
        {name = "Score", type = T.INT},--剩余金币
    }
}
--已经报名的玩家会收到其他玩家进入的消息
P.SVR_MATCH_OTHER_LOGIN                   = 0x7103
SERVER[P.SVR_MATCH_OTHER_LOGIN] =  {
    ver = 1,
    fmt = {
        {name = "Usercount", type = T.INT},--当前参加比赛人数
        {name = "Totalcount", type = T.INT}--当前比赛多少人
    }
}
--返回退出比赛结果
P.SVR_MATCH_LOGOUT                   = 0x7110
SERVER[P.SVR_MATCH_LOGOUT] =  {
    ver = 1,
    fmt = {
        {name = "Flag", type = T.INT},--是否成功退赛
        {name = "Nlogintype", type = T.INT},--报名方式
        {name = "nCostForMatch", type = T.INT},--报名费
        {name = "Errortype", type = T.INT}--失败原因
    }
}
--牌局，开始发送其他玩家信息
P.SVR_MATCH_START                   = 0x7104
SERVER[P.SVR_MATCH_START] =  {
    ver = 1,
    fmt = {
        {name = "Userid", type = T.INT},--用户ID
        {name = "Seatid", type = T.INT},--座位ID
        {name = "Matchrank", type = T.INT},--比赛排名
        {name = "Matchpoint", type = T.INT},--比赛分数
        {name = "Userinfo", type = T.STRING},--自己的用户信息
        {name = "Usercount", type = T.INT},--桌子上其他玩家的个数
        {name = "playerList", type = T.ARRAY,fixedLengthParser = "Usercount",fixedLength = 0,
            fmt = {
                {name = "Userid", type = T.INT},--玩家ID
                {name = "Seated", type = T.INT},--座位ID
                {name = "Matchrank", type = T.INT}, --比赛排名
                {name = "Matchpoint", type = T.INT},--比赛分数
                {name = "Userinfo", type = T.STRING}--玩家信息
            }
        },
        {name = "Level", type = T.INT},--当前比赛的level
        {name = "Basechip", type = T.INT},--底注
        {name = "Round", type = T.INT},--第几轮
        {name = "Sheaves", type = T.INT},--第几局
        {name = "Lowpoint", type = T.INT},--淘汰分数
        {name = "Number", type = T.INT},--决赛每轮打多少局
        {name = "Currentcount", type = T.INT},--当前还剩多少人
        {name = "gameID", type = T.STRING},--比赛ID
        {name = "Finaltablecount", type = T.INT}--决赛阶段每桌打几场
    }
}
--每轮打完之后 会给玩家发送比赛状态信息
P.SVR_MATCH_GAME_OVER                   = 0x7106
SERVER[P.SVR_MATCH_GAME_OVER] =  {
    ver = 1,
    fmt = {
        {name = "Maxnumber", type = T.INT},--最大的人数
        {name = "Rank", type = T.INT},--自己的排名
        {name = "Status", type = T.INT},--状态:0表示等待，2表示淘汰
        {name = "Strtime", type = T.STRING},--当前时间
        {name = "Tablecount", type = T.INT},--未完成比赛的次数
        {name = "Level", type = T.INT},--当前比赛等级
        {name = "Logintype", type = T.INT}--报名方式
    }
}
--比赛的过程中会收到比赛的排名信息
P.SVR_MATCH_RANK                   = 0x7114
SERVER[P.SVR_MATCH_RANK] =  {
    ver = 1,
    fmt = {
        {name = "courrentSize", type = T.INT},--当前多少人
        {name = "Rankcount", type = T.INT},--排行榜人数
        {name = "playerList", type = T.ARRAY,fixedLengthParser = "Rankcount",fixedLength = 0,
            fmt = {
                {name = "Userid", type = T.INT},--用户ID
                {name = "Rank", type = T.INT},--用户排名
                {name = "Point", type = T.INT}, --用户分数
                {name = "Username", type = T.STRING}--用户昵称
            }
        },
    }
}

--组局排行榜
P.SVR_GROUP_BILLBOARD                   = 0x5100
SERVER[P.SVR_GROUP_BILLBOARD] =  {
    ver = 1,
    fmt = {
        {name = "playercount", type = T.INT},--土豪
        {name = "playerList", type = T.ARRAY,fixedLengthParser = "playercount",fixedLength = 0,
            fmt = {
                {name = "nick", type = T.STRING},--用户详情
                {name = "add_chips", type = T.INT},--带入筹码
                {name = "chips", type = T.INT} --当前筹码
            }
        },
        --土豪
        {name = "richMan_id", type = T.INT},--id
        {name = "richMan_icon", type = T.STRING},--头像连接
        {name = "richMan_nick", type = T.STRING},--昵称
        --大鱼
        {name = "loser_id", type = T.INT},--id
        {name = "loser_icon", type = T.STRING},--头像连接
        {name = "loser_nick", type = T.STRING},--昵称
        --MVP
        {name = "mvp_id", type = T.INT},--id
        {name = "mvp_icon", type = T.STRING},--头像连接
        {name = "mvp_nick", type = T.STRING},--昵称
        --个人讯息
        {name = "chips", type = T.INT},--自己的剩余筹码
        {name = "countGames", type = T.INT},--组局总局数
        {name = "total_chips", type = T.INT},--组局总带入筹码
    }
}
--组局历史记录
P.SVR_GET_HISTORY                   = 0x907
SERVER[P.SVR_GET_HISTORY] =  {
    ver = 1,
    fmt = {
        {name = "amount", type = T.INT},--土豪
        {name = "history", type = T.ARRAY,fixedLengthParser = "amount",fixedLength = 0,
            fmt = {
                {name = "gameno", type = T.INT},
                {name = "playercount", type = T.INT},--游戏玩家数
                {name = "items", type = T.ARRAY,fixedLengthParser = "playercount",fixedLength = 0,
                    fmt = {
                        {name = "Userid", type = T.INT},--用户ID
                        {name = "nick", type = T.STRING},--剩余筹码
                        {name = "icon", type = T.STRING},--玩家讯息
                        {name = "sex", type = T.INT},--玩家性别
                        {name = "win", type = T.INT} --输赢结果
                    }
                }
            }
        }
    }
}

--组局局数
P.SVR_GROUP_TIME                  = 0x5101
SERVER[P.SVR_GROUP_TIME] =  {
    ver = 1,
    fmt = {
        {name = "time", type = T.INT},
        {name = "round", type = T.INT},
        {name = "round_total", type = T.INT},
    }
}


--心跳
P.CLISVR_HEART_BEAT              = 0x0110    --server心跳包

return HALL_SERVER_PROTOCOL