--
-- Author: LeoLuo
-- Date: 2015-05-09 10:03:08
--

local T = bm.PACKET_DATA_TYPE
local P = {}

local pdk_PROTOCOL = P
P.CONFIG = {}
P.CONFIG.CLIENT = {}
P.CONFIG.SERVER = {}
local CLIENT = P.CONFIG.CLIENT
local SERVER = P.CONFIG.SERVER

----------------------------------------------------------------
------------------------- 客户端请求  --------------------------
----------------------------------------------------------------

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
    }
}

P.CLI_LOGOUT_ROOM                = 0x1002    --用户请求离开房间
CLIENT[P.CLI_LOGOUT_ROOM] = nil


P.CLI_READY_GAME                = 0x2001    --用户准备
CLIENT[P.CLI_READY_GAME] = nil

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


--托管动作
P.CLI_AUTO                   = 0x2006    --玩家托管动作
CLIENT[P.CLI_AUTO] = {
    ver = 1,
    fmt = {
        {name = "action", type = T.INT} --0:取消托管，1:请求托管
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


P.CLI_MSG_FACE                 =0x1004
CLIENT[P.CLI_MSG_FACE]={
    ver=1,
    fmt={
        {name="type",type=T.INT},
    }

}


-------------------  直播  -------------------
P.CLI_SEND_LIVE_ADDRESS                   = 0x2215   --广播地址
CLIENT[P.CLI_SEND_LIVE_ADDRESS] = {
    ver = 1,
    fmt = {
        {name = "live_addr", type = T.STRING},   --桌子ID
        {name = "flag", type = T.INT},   --用户ID
    }
}


--请求解散房间 
P.C2S_DISSOLVE_ROOM                   = 0x808
CLIENT[P.C2S_DISSOLVE_ROOM] = {
    ver = 1
}

-------------------  解散房间相关  ------------------------------
--请求解散房间 
P.C2G_CMD_DISSOLVE_ROOM                   = 0x808
CLIENT[P.C2G_CMD_DISSOLVE_ROOM] = {
    ver = 1
}

--回复请求解散房间
P.C2G_CMD_REPLY_DISSOLVE_ROOM                   = 0x809
CLIENT[P.C2G_CMD_REPLY_DISSOLVE_ROOM] = {
    ver = 1,
    fmt = {
        {name = "agree", type = T.INT} --0为拒绝解散，1为解散
    }
}

-----------------------------------------------------------
-------------------  服务端返回  --------------------------
-----------------------------------------------------------
--当前玩家被踢下线
P.SVR_KICK_OFF               = 0x0203
SERVER[P.SVR_KICK_OFF] = {
    ver = 1
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

P.SVR_ROOM_INFO            = 0x100F    --获取房间讯息
SERVER[P.SVR_ROOM_INFO] = {
    ver = 1,
    fmt = {
        {name = "show_card", type = T.SHORT},--
        {name = "game_type", type = T.SHORT},--
        {name = "level", type = T.SHORT},--房间level
    }
}

P.SVR_READY_GAME                 = 0x6001    --用户准备返回
SERVER[P.SVR_READY_GAME] = {
    ver = 1,
    fmt = {
        {name = "Uid", type = T.INT}
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
        {name = "score", type = T.INT},--当<0时，标记位
        {name = "gold", type = T.INT,request = "score",requestValue = -1},--玩家金币数
        {name = "chip", type = T.INT,request = "score",requestValue = -1},--玩家筹码数
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
        {name = "playerlist", type = T.ARRAY,fixedLengthParser = "Playercount",fixedLength = 2,
            fmt = {
                {name = "Uid",type = T.INT},   --桌子其他玩家uid
                {name = "Seatid",type = T.SHORT},   --桌子其他玩家seatid
                {name = "gold",type = T.INT},   --玩家分数
                {name = "AIUser",type = T.SHORT},   --玩家是否托管
                {name = "HandCardCount",type = T.SHORT},   --玩家手牌数量
                {name = "UserInfo",type = T.STRING},   --玩家手牌数量
                {name = "ReadyStart",type = T.SHORT},   --是否准备
            }
        },
        {name = "Basechip", type = T.INT},--底注
        {name = "Outcardtime", type = T.SHORT},--出牌时间
        {name = "Handcardcount", type = T.SHORT},--手牌数量
        {name = "Carddata", type = T.ARRAY,fixedLengthParser = "Handcardcount",fixedLength = 2,
            fmt = {
                {type = T.BYTE},   --扑克牌数值
            }
        },
        {name = "OutCardUserId", type = T.INT},--当前要出牌玩家id
        {name = "LeftTime", type = T.SHORT},--出牌剩余时间
        {name = "player_time", type = T.SHORT},--???
        --3个玩家最近一次的出牌
        {name = "LastCarddata", type = T.ARRAY,fixedLength = 3,
            fmt = {
                {name = "CardCount",type = T.SHORT},--出牌数量
                {name = "cards", type = T.ARRAY,fixedLengthParser = "CardCount",fixedLength = 0,
                    fmt = {
                        {type = T.BYTE},   --扑克牌数值
                    }
                },
            }
        }
    }
}


P.SVR_OTHER_OFFLINE              = 0x8005    --服务器广播用户掉线
SERVER[P.SVR_OTHER_OFFLINE] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT}
    }
}

P.SVR_PLAY_GAME                   = 0x6004    --服务器广播开始打牌
SERVER[P.SVR_PLAY_GAME] = {
    ver = 1,
    fmt = {
        {name = "nOutCardUserId", type = T.INT},--出牌玩家的uid
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
        {name = "playerList", type = T.ARRAY,fixedLength = 3,
            fmt = {
                {name = "Uid", type = T.INT},--玩家uid
                {name = "Turningscore", type = T.INT},--变化的钱
                {name = "isOnline", type = T.INT}, --是否在线
                {name = "Level", type = T.INT},--玩家等级
                {name = "bomb_times", type = T.BYTE},--玩家炸弹数
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
        {name = "Expend", type = T.INT}, --台费
        {name = "winerId", type = T.INT}, -- 赢家id
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

--组局排行榜
P.SVR_GROUP_BILLBOARD                   = 0x5100
SERVER[P.SVR_GROUP_BILLBOARD] =  {
    ver = 1,
    fmt = {
        {name = "playercount", type = T.INT},--土豪
        {name = "playerlist", type = T.ARRAY,fixedLengthParser = "playercount",fixedLength = 0,
            fmt = {
                {name = "uid", type = T.INT},
                {name = "user_info", type = T.STRING},--游戏玩家数
            }
        },
        {name = "game_amount", type = T.INT},--总局数
    }
}
--组局历史记录
P.SVR_GET_HISTORY                   = 0x907
SERVER[P.SVR_GET_HISTORY] =  {
    ver = 1,
    fmt = {
        {name = "playercount", type = T.INT},--土豪
        {name = "playerlist", type = T.ARRAY,fixedLengthParser = "playercount",fixedLength = 0,
            fmt = {
                {name = "uid", type = T.INT},
                {name = "user_info", type = T.STRING},--游戏玩家数
            }
        },
        {name = "history", type = T.STRING},--土豪
    }
}

--组局时长
P.SVR_GROUP_TIME                  = 0x5101
SERVER[P.SVR_GROUP_TIME] =  {
    ver = 1,
    fmt = {
        {name = "time", type = T.INT},--当前组局剩余时间
        {name = "round", type = T.INT},--当前组局已进行多少局
        {name = "round_total", type = T.INT},--当前组局总局数
    }
}

--玩家进入私人房
P.SVR_ENTER_PRIVATE_ROOM                  = 0x0212
SERVER[P.SVR_ENTER_PRIVATE_ROOM] =  {
    ver = 1,
    fmt = {
        {name = "flag", type = T.SHORT},
        {name = "ret", type = T.SHORT}
    }
}

--历史出牌
P.SVR_CALC_HISTORY                  = 0x4010
SERVER[P.SVR_CALC_HISTORY] =  {
    ver = 1,
    fmt = {
        {name = "counts", type = T.INT},--出牌历史次数
        {name = "cardList", type = T.ARRAY,fixedLengthParser = "counts",fixedLength = 0,
            fmt = {
                {name = "uid", type = T.INT},
                {name = "cards", type = T.STRING},--游戏玩家数
            }
        }
    }
}

P.SVR_MSG_FACE                 =0x1004
SERVER[P.SVR_MSG_FACE]={
    ver=1,
    fmt={
        {name="uid",type=T.INT},
        {name="type",type=T.INT}
    }

}
-------------------  直播  -------------------
P.SER_BROADCAST_LIVE_ADDRESS                   = 0x6020   --广播地址
SERVER[P.SER_BROADCAST_LIVE_ADDRESS] = {
    ver = 1,
    fmt = {
        {name = "live_addr", type = T.STRING},   --桌子ID
        {name = "flag", type = T.INT},   --用户ID
    }
}

--解散房间相关（废弃）
--没有此房间，解散房间失败  0x908
P.S2C_DISSOLVE_FAILED = 0x908
SERVER[P.S2C_DISSOLVE_FAILED] = {
    ver = 1
}

--解散房间相关（新）
--没有此房间，解散房间失败  0x908
P.G2H_CMD_DISSOLVE_FAILED = 0x908
SERVER[P.G2H_CMD_DISSOLVE_FAILED] = {
    ver = 1
}

--广播当前组局解散情况
P.G2H_CMD_REFRESH_DISSOLVE_LIST = 0x909
SERVER[P.G2H_CMD_REFRESH_DISSOLVE_LIST] = {
    ver = 1,
    fmt = {
        {name = "applyId",type = T.INT},--申请解散房间的用户id
        {name = "agreeNum", type = T.INT},--当前同意解散的人数
        {name = "agreeMember_arr", type = T.ARRAY,fixedLengthParser = "agreeNum",fixedLength = 0,
            fmt = {
                {name = "uid", type = T.INT}--已经同意解散的用户
            }
        }
    }
}

--广播桌子用户请求解散组局
P.SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP = 0x102A
SERVER[P.SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP] = {
    ver = 1,
    fmt = {
         {name = "applyId",type = T.INT}, --申请解散房间的用户id
    }
}


--广播桌子用户成功解散组局
P.SERVER_BROADCAST_DISSOLVE_GROUP = 0x103A
SERVER[P.SERVER_BROADCAST_DISSOLVE_GROUP] = {
    ver = 1
}

--广播桌子用户解散组局 ，解散组局失败
P.SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP = 0x104A
SERVER[P.SERVER_BROADCAST_FORBIT_DISSOLVE_GROUP] = {
    ver = 1,
    fmt = {
         {name = "rejectId",type = T.INT}, --拒绝的用户id
    }
}






--广播玩家ip
P.BROADCAST_USER_IP = 0x106A
SERVER[P.BROADCAST_USER_IP] = {
    ver = 1,
    fmt ={
        {name = "playercount",type = T.INT},
        {name = "playeripdata", type = T.ARRAY,fixedLengthParser = "playercount",fixedLength = 0,
            fmt = {
                {name = "uid", type = T.INT},
                {name = "ip", type = T.STRING},--游戏玩家数
            }
        }
    }

}

P.CLIENT_CMD_SEND_MSG_TO_SERVER                = 0x166    --向服务器发送向组局里发送的缓存信息
CLIENT[P.CLIENT_CMD_SEND_MSG_TO_SERVER] = {
    ver = 1,
    fmt = {
        {name = "level", type = T.SHORT},   --游戏level
        {name = "msg", type = T.STRING}
    }
}

P.CLIENT_CMD_FORWARD_MESSAGE                = 0x165    --向服务器发送向组局里发送的文字信息
CLIENT[P.CLIENT_CMD_FORWARD_MESSAGE] = {
    ver = 1,
    fmt = {
        {name = "level", type = T.SHORT},   --游戏level
        {name = "msg", type = T.STRING}
    }
}

--2017年3月6号新增距离消息
P.SERVER_CMD_FORWARD_MESSAGE                = 0x0213    --服务器返回组局收到的信息
SERVER[P.SERVER_CMD_FORWARD_MESSAGE] = {
    ver = 1,
    fmt = {
        {name = "msgCount", type = T.INT}, --消息个数
        {name = "msgList", type = T.ARRAY, fixedLengthParser = "msgCount", fixedLength = 0,
            fmt = {
                {name = "msg", type = T.STRING}, --消息
            }
        },
    }
}

P.SERVER_CMD_MESSAGE                = 0x0214    --服务器返回组局收到的信息
SERVER[P.SERVER_CMD_MESSAGE] = {
    ver = 1,
    fmt = {
        {name = "msgCount", type = T.INT}, --消息长度
        {name = "msg", type = T.STRING}, --消息
    }
}

return pdk_PROTOCOL
