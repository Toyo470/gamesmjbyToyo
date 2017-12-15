--
-- Author: LeoLuo
-- Date: 2015-05-09 10:03:08
--

local T = bm.PACKET_DATA_TYPE
local P = {}

local SZKWX_SERVER_PROTOCOL = P
P.CONFIG = {}
P.CONFIG.CLIENT = {}
P.CONFIG.SERVER = {}
local CLIENT = P.CONFIG.CLIENT
local SERVER = P.CONFIG.SERVER


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
----------------------------------------------------------------
------------------------- 客户端请求  --------------------------
----------------------------------------------------------------

P.CLI_MSG_FACE                 =0x1004
CLIENT[P.CLI_MSG_FACE]={
    ver=1,
    fmt={
        {name="type",type=T.INT},
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

--用户请求操作
P.CLI_REQUEST_HANDLE                      = 0x2004    
CLIENT[P.CLI_REQUEST_HANDLE] = {
    ver = 1,
    fmt = {
        {name = "handle", type = T.INT},  --操作
        {name = "card", type = T.BYTE},  --牌
    }

}

P.CLI_REQUEST_LIANG                      = 0x2013    
CLIENT[P.CLI_REQUEST_LIANG] = {
    ver = 1,
    fmt = {
        {name = "card", type = T.BYTE},  --牌
        {name = "indexCount", type = T.BYTE},
        {name = "indexs", type = T.ARRAY, fixedLengthParser = "indexCount",fixedLength = 0, 
            fmt = {
                {name = "index", type = T.BYTE},
            }
        },
    }
}

P.CLI_REQUEST_LIANG_GANG                      = 0x2014    
CLIENT[P.CLI_REQUEST_LIANG_GANG] = {
    ver = 1,
    fmt = {
        {name = "lgCount", type = T.BYTE},
        {name = "lgCards", type = T.ARRAY, fixedLengthParser = "lgCount",fixedLength = 0, 
            fmt = {
                {name = "card", type = T.BYTE},
            }
        },
    }

}

P.CLI_REQUEST_JIAPIAO                      = 0x2015    
CLIENT[P.CLI_REQUEST_JIAPIAO] = {
    ver = 1,
    fmt = {
        {name = "jiapiao", type = T.BYTE},
    }

}

--请求托管
P.CLI_ROBOT                  = 0x2005    
CLIENT[P.CLI_ROBOT] = {
    ver = 1,
    fmt = {
        {name = "kind", type = T.INT},  --牌
    }
}

--出牌
P.SEND_CARD                     = 0x2002    
CLIENT[P.SEND_CARD] = {
    ver = 1,
    fmt = {
        {name = "card", type = T.BYTE},  --牌
    }
}

--请求退出房间
P.CLI_QUIT_ROOM                     = 0x1002    
CLIENT[P.CLI_QUIT_ROOM] = {
    ver = 1,
}

--选缺
P.CLI_CHOICE_QUE                    = 0x200D    
CLIENT[P.CLI_CHOICE_QUE] = {
    ver = 1,
    fmt = {
        {name = "que", type = T.BYTE},
    }
}

--用户发送准备
P.CLI_READYNOW_ROOM                     = 0x2001    
CLIENT[P.CLI_READYNOW_ROOM] = {
    ver = 1,
}

--登录大厅
P.CLI_LOGIN                      = 0x0116    
CLIENT[P.CLI_LOGIN] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT},
        {name = "storeId", type = T.INT},
        {name = "kind", type = T.INT},
        {name = "userInfo", type = T.STRING},
    }
}

--获取房间id
P.CLI_GET_ROOM                   = 0x0113    
CLIENT[P.CLI_GET_ROOM] = {
    ver = 1,
    fmt = {
        {name = "Level", type = T.SHORT},   --桌子等级
        {name = "Chip", type = T.INT},--请求场次的底注
        {name = "Sid", type = T.INT},--游戏场的id
        {name = "activity_id", type = T.STRING} --带入活动id
        -- {name = "type", type = T.BYTE},   --登陆类型，0--随机登陆，1--指定桌子登陆
        -- {name = "targetid", type = T.INT} --目标桌子ID，0表示随机登陆
    }

}

--登录组局房间
P.CLI_LOGIN_ROOM_GROUP                 = 0x1001    
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

--换牌
P.CLIENT_COMMAND_CHANGE_CARD                 = 0x2011
CLIENT[P.CLIENT_COMMAND_CHANGE_CARD] = {
    ver = 1,
    fmt = {
        {name="pval1",type = T.BYTE},
        {name="pval2",type = T.BYTE},
        {name="pval3",type = T.BYTE},
    }
}

--答复亮倒提示
P.CLIENT_REPLY_LIANGDAO_REMAID                 = 0x2012
CLIENT[P.CLIENT_REPLY_LIANGDAO_REMAID] = {
    ver = 1,
    fmt = {
        {name = "card", type = T.BYTE},    --为出的牌
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

--请求托管
P.SVR_ROBOT                  = 0x4007    
SERVER[P.SVR_ROBOT] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT},  --牌
        {name = "kind", type = T.INT},  --牌
    }
}

--游戏开始
P.SVR_GAME_START                  = 0x4003
SERVER[P.SVR_GAME_START] = {
    ver = 1,
}
--结算
P.SVR_ENDDING_BROADCAST                = 0x4008    
SERVER[P.SVR_ENDDING_BROADCAST] = {
    ver = 1,
    fmt = {
        {name = "type", type = T.SHORT}, --结束类型
        {name = "spendTime", type = T.INT}, --持续时间
        {name = "time", type = T.INT}, --当前时间
        {name = "uid", type = T.INT}, -- 自摸为自摸的玩家id，放炮，则为点炮者
        {name = "players", type = T.ARRAY,fixedLength = 3, 
            fmt = {
                {name="uid",type   = T.INT},   --用户id
                {name="isChajiao", type = T.BYTE},  --是否被查叫
                {name="isOnline",type  = T.SHORT},   --是否胡牌
                {name="coins",type = T.INT},   --是否放炮
                {name="changeCoins", type = T.INT},
                {name="isQishou", type = T.BYTE},
                {name="isHaidi", type = T.BYTE},
                {name="dgCount", type = T.BYTE},
                {name="pgCount", type = T.BYTE},
                {name="bgCount", type = T.BYTE},
                {name="winLoseType", type = T.BYTE}, -- -1：点炮 0：默认 1：放炮 2：自摸
                {name="remainCardsCount", type = T.INT},
                {name="remainCards", type = T.ARRAY, fixedLengthParser = "remainCardsCount",fixedLength = 0,
                    fmt = {
                        {type = T.BYTE},
                    }
                },
                {name="agCount", type = T.INT},
                {name="agCards", type = T.ARRAY, fixedLengthParser = "agCount",fixedLength = 0,
                    fmt = {
                        {type = T.BYTE},
                    }
                },
                {name="gCount", type = T.INT},
                {name="gCards", type = T.ARRAY, fixedLengthParser = "gCount",fixedLength = 0,
                    fmt = {
                        {type = T.BYTE},
                    }
                },
                {name="pCount", type = T.INT},
                {name="pCards", type = T.ARRAY, fixedLengthParser = "pCount",fixedLength = 0,
                    fmt = {
                        {type = T.BYTE},
                    }
                },
                {name="cCount", type = T.INT},
                {name="cCards", type = T.ARRAY, fixedLengthParser = "cCount",fixedLength = 0,
                    fmt = {
                        {type = T.BYTE},
                    }
                },
                {name="huTypeCount", type = T.SHORT},
                {name="huTypes", type = T.ARRAY, fixedLengthParser = "huTypeCount",fixedLength = 0,
                    fmt = {
                        {type = T.BYTE},
                    }
                },
                {name="kanCount", type = T.BYTE},
            }
        },
        {name = "birdCount", type = T.BYTE},
        {name = "birdCards", type = T.ARRAY, fixedLengthParser = "birdCount",fixedLength = 0, 
            fmt = {
                {name = "card", type = T.BYTE},
                {name = "position", type = T.BYTE},
            }
        },
        {name = "huCard", type = T.BYTE},
        {name = "isOver", type = T.BYTE},
    }
}

--当前抓牌用户广播
P.SVR_PLAYING_UID_BROADCAST                = 0x4006    
SERVER[P.SVR_PLAYING_UID_BROADCAST] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT}, --用户id
        {name = "if_gang", type = T.BYTE}, --0表示不是，1表示是杠，目前不知道有啥用！
        {name = "simplNum",type = T.SHORT}, --桌面剩余多少张摸牌
        {name = "card", type = T.BYTE},
    }
}

--广播用户进行了什么操作
P.SVR_PLAYER_USER_BROADCAST                = 0x4005    
SERVER[P.SVR_PLAYER_USER_BROADCAST] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT}, --用户id
        {name = "handle", type = T.INT}, --操作类型
        {name = "card", type = T.BYTE}, --牌
        {name = "lid", type = T.INT}, --如果是碰，杠，胡，杠胡。ID为上一个出牌用户ID
        {name = "tingCount", type = T.BYTE},
        {name = "totalCount", type = T.BYTE},
        {name = "lgCount", type = T.BYTE},
        {name = "lgCards", type = T.ARRAY, fixedLengthParser = "lgCount",fixedLength = 0, 
            fmt = {
                {name = "card", type = T.BYTE},
            }
        },
        {name = "liangCount", type = T.BYTE},
        {name = "liangCards", type = T.ARRAY, fixedLengthParser = "liangCount",fixedLength = 0, 
            fmt = {
                {name = "card", type = T.BYTE},
            }
        },
        {name = "tingHuCount", type = T.BYTE},
        {name = "tingHuCards", type = T.ARRAY, fixedLengthParser = "tingHuCount",fixedLength = 0, 
            fmt = {
                {name = "card", type = T.BYTE},
            }
        },
    }
}

--广播用户出牌
P.SVR_SEND_MAJIANG_BROADCAST                = 0x4104    
SERVER[P.SVR_SEND_MAJIANG_BROADCAST] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT}, --用户id
        {name = "card", type = T.BYTE}, --牌
        {name = "handle", type = T.INT}, --自己可以的操作
    }
}

--通知用户我抓的牌
P.SVR_OWN_CATCH_BROADCAST                = 0x3002    
SERVER[P.SVR_OWN_CATCH_BROADCAST] = {
    ver = 1,
    fmt = {
        {name = "card", type = T.BYTE}, --牌
        {name = "handle", type = T.INT}, --操作
        -- {name = "mount", type = T.BYTE}, --数量
        {name = "cards", type = T.ARRAY,--[[fixedLengthParser = 8,]]fixedLength = 8,
            fmt = {
                {type = T.BYTE},   --牌
            }
        },
        {name = "if_gang", type = T.BYTE}, --0表示不是，1表示是杠，目前不知道有啥用！
        {name = "tingCount", type = T.BYTE},
        {name = "lgCount", type = T.BYTE},
        {name = "lgCards", type = T.ARRAY, fixedLengthParser = "lgCount",fixedLength = 0, 
            fmt = {
                {name = "card", type = T.BYTE},
            }
        },
    }
}

--广播胡
P.SVR_HUPAI_BROADCAST                = 0x4013   
SERVER[P.SVR_HUPAI_BROADCAST] = {
    ver = 1,
    fmt = {
        {name = "hu_count", type = T.BYTE}, --胡牌的人数
        {name = "content", type = T.ARRAY,fixedLengthParser = "hu_count",fixedLength = 0,
            fmt = {
                {name="uid",type = T.INT},   --uid
                {name="htype",type = T.SHORT,cache=1},   --胡牌类型
                {name="bases",type = T.BYTE},   --番倍数
                {name="ifgangpao",type = T.INT,cache=1},   --是否杠上炮
                {name="ifqianggang",type = T.BYTE},   --是否抢杠胡
                {name="ifgangshanghua",type = T.INT},   --是否杠上花
                {name="gen_mount",type = T.INT},   --四张牌的总和减去杠的数量
                {name="gang_mount",type = T.INT},   --杠的数量
                {name="hu_kind",type = T.BYTE},   --杠的数量
                {name="card",type = T.INT},   --牌的值
                {name="pao_content",type = T.ARRAY,request="htype",requestValue=1,fixedLength=1,
                    fmt = {
                        {name="paoid",type = T.INT},   --点炮id
                        {name="humoney",type = T.INT,request="ifgangpao",requestValue=1},   --呼叫转移钱数

                    },
                },  
                {name="leftcardmount",type = T.INT},   --剩余的手牌
                {name = "leftcards", type = T.ARRAY,fixedLengthParser = "leftcardmount",fixedLength = 0,
                    fmt = {
                        {type = T.BYTE},   --牌
                    }
                },

            }
        },
    }
}

--提示点炮亮倒
P.SVR_LIANGDAO_REMAID                = 0x4019    
SERVER[P.SVR_LIANGDAO_REMAID] = {
    ver = 1,
    fmt = {
        {name = "card", type = T.BYTE}, --出的牌
        {name = "winCount", type = T.BYTE},
        {name = "winSeats", type = T.ARRAY, fixedLengthParser = "winCount",fixedLength = 0, 
            fmt = {
                {name = "seatId", type = T.BYTE},
            }
        },
    }
}

--提示加飘
P.SVR_JIAPIAO                = 0x4020    
SERVER[P.SVR_JIAPIAO] = {
    ver = 1,
}

--广播用户加飘
P.SVR_JIAPIAO_BROADCAST                = 0x4021    
SERVER[P.SVR_JIAPIAO_BROADCAST] = {
    ver = 1,
    fmt = {
        {name = "seatId", type = T.BYTE}, --座位
        {name = "jiapiao", type = T.BYTE},--加飘值
    }
}

--获取房间id结果
P.SVR_GET_ROOM_OK                = 0x0210    
SERVER[P.SVR_GET_ROOM_OK] = {
    ver = 1,
    fmt = {
        {name = "tid", type = T.INT}, --桌子ID
        {name = "sid", type = T.SHORT}, --serverid
        -- {name = "level", type = T.SHORT}, --游戏等级
        -- {name = "res", type = T.SHORT}, --请求结果
        {name = "ip", type = T.STRING}, -- ip
        {name = "port", type = T.INT}, -- 端口
        {name = "res", type = T.INT}, --请求结果
        {name = "level", type = T.SHORT}, --请求结果
    }
}

--用户重新登录普通房间的消息返回（4105(10进制s)）
P.SVR_REGET_ROOM               = 0x1009   
SERVER[P.SVR_REGET_ROOM] = {
    ver = 1,
    fmt = {
        {name = "round", type = T.BYTE},
        {name = "totalRounds", type = T.BYTE},
        {name = "isBufenLiang", type = T.BYTE}, --是否部分亮
        {name = "from", type = T.INT}, --
        {name = "nTableType", type = T.SHORT}, --
        {name = "seat_id", type = T.SHORT}, --重连用户座位ID
        {name = "gold", type = T.INT}, --重连用户拥有金币数 
        {name = "jiapiaoStatus", type = T.BYTE}, --加飘状态  0：未进行 1：进行中 2：不需要
        {name = "piao", type = T.BYTE}, --加飘
        {name = "nTingFlag", type = T.SHORT}, --
        {name = "newCard", type = T.BYTE}, --抓的牌

        --房间配置
        {name = "nBaseChips", type = T.INT}, --桌子信息: 
        {name = "nBaseRadix", type = T.INT}, --桌子信息: --底注基数
        {name = "nQuan", type = T.SHORT},
        {name = "nOutCardTimeout", type = T.SHORT}, --桌子信息: 出牌超时时间
        {name = "nOperationTimeout", type = T.SHORT}, --桌子信息: 出牌超时时间
        {name = "nCurQuan", type = T.SHORT},
        {name = "m_nEastSeatId", type = T.SHORT},
        {name = "m_nBankSeatId", type = T.SHORT}, --桌子信息: 庄家位置
        {name = "m_nShaiZi", type = T.SHORT}, --桌子信息: 筛子数
        {name = "card_less", type = T.SHORT}, --//桌上剩余麻将数

        {name = "nPlayerCount", type = T.SHORT}, --其他用户信息:其他用户数
        {name = "users_info", type = T.ARRAY,fixedLengthParser = "nPlayerCount",fixedLength = 0,
            fmt = {
                    {name = "uid", type = T.INT},--其他用户信息:用户id
                    {name = "seat_id", type = T.SHORT},--其他用户信息:用户座位id
                    {name = "m_bAI", type = T.SHORT},--其他用户信息:用户是否托管
                    {name = "piao", type = T.BYTE}, --加飘
                    {name = "countHandCards", type = T.SHORT},--
                    {name = "countForTing", type = T.SHORT},--
                    {name = "liangCards", type = T.ARRAY,fixedLengthParser = "countForTing",fixedLength = 0,
                        fmt = {
                                {name = "card", type = T.BYTE},--其他用户信息: 用户所碰的牌
                            }
                    },
                    -- {name = "handCards", type = T.ARRAY,fixedLengthParser = "countForTing",fixedLength = 0,
                    --     fmt = {
                    --             {name = "card", type = T.BYTE},--其他用户信息: 用户所碰的牌
                    --         }
                    -- },
                    {name = "user_info", type = T.STRING},
                    {name = "user_gold", type = T.INT},--其他用户信息: 用户金币数量
                    --花牌
                    {name = "huaCount", type = T.SHORT},
                    {name = "huaCards", type = T.ARRAY,fixedLengthParser = "huaCount",fixedLength = 0,
                        fmt = {
                                {name = "card", type = T.BYTE},--其他用户信息: 用户所碰的牌
                            }
                    },
                    --吃牌
                    {name = "cCount", type = T.SHORT},--其他用户信息: 用户碰牌数量
                    {name = "cCards", type = T.ARRAY,fixedLengthParser = "cCount",fixedLength = 0,
                        fmt = {
                                {name = "card", type = T.BYTE},--其他用户信息: 用户所碰的牌
                            }
                    },
                    --碰牌
                    {name = "pCount", type = T.SHORT},--其他用户信息: 用户碰牌数量
                    {name = "pCards", type = T.ARRAY,fixedLengthParser = "pCount",fixedLength = 0,
                        fmt = {
                                {name = "card", type = T.BYTE},--其他用户信息: 用户所碰的牌
                            }
                    },
                        
                    --杠牌
                    {name = "gCount", type = T.SHORT},--其他用户信息: 用户杠牌数量
                    --明杠
                    {name = "gCards", type = T.ARRAY,fixedLengthParser = "gCount",fixedLength = 0,
                        fmt = {
                                {name = "card", type = T.BYTE},--其他用户信息: 用户所杠的牌，0是明杠。1是暗杠
                                {name = "isAg", type = T.BYTE},--其他用户信息: 杠牌的类型 0 不是 1 暗杠
                            }
                    },
                    --出牌
                    {name = "outCount", type = T.SHORT},--其他用户信息: 其他用户所出牌的数量
                    {name = "outCards", type = T.ARRAY,fixedLengthParser = "outCount",fixedLength = 0,
                        fmt = {
                                {name = "card", type = T.BYTE},--其他用户信息: 所出的牌
                        }
                    },
                    --亮牌可杠的暗刻
                    {name = "ankeCount", type = T.BYTE},--其他用户信息: 其他用户所出牌的数量
                    {name = "ankeCards", type = T.ARRAY,fixedLengthParser = "ankeCount",fixedLength = 0,
                        fmt = {
                                {name = "card", type = T.BYTE},--其他用户信息: 所出的牌
                        }
                    },
                    {name = "tingHuCount", type = T.BYTE},--其他用户信息: 其他用户所出牌的数量
                    {name = "tingHuCards", type = T.ARRAY,fixedLengthParser = "tingHuCount",fixedLength = 0,
                        fmt = {
                                {name = "card", type = T.BYTE},--其他用户信息: 所出的牌
                        }
                    },
            }
        },

        {name = "handCount", type = T.SHORT}, --重连用户信息:手牌数量
        {name = "handCards", type = T.ARRAY,fixedLengthParser = "handCount",fixedLength = 0,
            fmt = {
                    {name = "card", type = T.BYTE},--重连用户信息:手牌的值
                }
        },
        -- 花牌
        {name = "huaCount", type = T.SHORT},--重连用户信息:碰牌的数量
        {name = "huaCards", type = T.ARRAY,fixedLengthParser = "huaCount",fixedLength = 0,
            fmt = {
                    {name = "card", type = T.BYTE},--重连用户信息:碰牌的值
                  }
        },
        -- 吃牌
        {name = "cCount", type = T.SHORT},--重连用户信息:碰牌的数量
        {name = "cCards", type = T.ARRAY,fixedLengthParser = "cCount",fixedLength = 0,
            fmt = {
                    {name = "card", type = T.BYTE},--重连用户信息:碰牌的值
                  }
        },
        -- 碰牌
        {name = "pCount", type = T.SHORT},--重连用户信息:碰牌的数量
        {name = "pCards", type = T.ARRAY,fixedLengthParser = "pCount",fixedLength = 0,
            fmt = {
                    {name = "card", type = T.BYTE},--重连用户信息:碰牌的值
                  }
        },

        --杠牌
        {name = "gCount", type = T.SHORT},--重连用户信息:杠牌的数量
        --明杠
        {name = "gCards", type = T.ARRAY,fixedLengthParser = "gCount",fixedLength = 0,
            fmt = {
                    {name = "card", type = T.BYTE},--重连用户信息:杠牌的值
                    {name = "isAg", type = T.BYTE},--重连用户信息:0表示明杠，1表示暗杠
                  }
        },

        -- 出牌历史
        {name = "outCount", type = T.SHORT},--重连用户信息:出牌历史
        {name = "outCards", type = T.ARRAY,fixedLengthParser = "outCount",fixedLength = 0,
            fmt = {
                    {name = "card", type = T.BYTE},--重连用户信息:所出的牌
                  }
        },
        {name = "gameStatus", type = T.SHORT},
        {name = "currentPlayerId", type = T.INT, request="gameStatus", requestValue = 2},
        {name = "currentPlayerId", type = T.INT, request="gameStatus", requestValue = 3},
        {name = "handle", type = T.INT, request="gameStatus", requestValue = 3},
        {name = "handleCard", type = T.BYTE, request="gameStatus", requestValue = 3},
        {name = "ableGangCards", type = T.ARRAY,--[[fixedLengthParser = 8,]]fixedLength = 8, request="gameStatus", requestValue = 3,
            fmt = {
                {type = T.BYTE},   --牌
            }
        },
        {name = "liangStatus", type = T.BYTE},  -- 0：未亮 1：已亮杠 2：已亮 3：亮倒已出牌
        {name = "tingCount", type = T.BYTE},
        {name = "tingCards", type = T.ARRAY,fixedLengthParser = "tingCount",fixedLength = 0,
            fmt = {
                    {name = "card", type = T.BYTE},--听牌所需打出的牌
                    {name = "tingHuCount", type = T.BYTE},
                    {name = "tingHuCards", type = T.ARRAY,fixedLengthParser = "tingHuCount",fixedLength = 0,
                        fmt = {
                                {name = "huCardsCount", type = T.BYTE},--打出对应牌后，听胡的牌
                                {name = "huCards", type = T.ARRAY,fixedLengthParser = "huCardsCount",fixedLength = 0,
                                    fmt = {
                                            {name = "card", type = T.BYTE},--打出对应牌后，听胡的牌
                                          }
                                },
                                {name = "componentCount", type = T.BYTE},--打出对应牌后，听胡的牌
                                {name = "component", type = T.ARRAY,fixedLengthParser = "componentCount",fixedLength = 0,
                                    fmt = {
                                            {name = "card", type = T.BYTE},--打出对应牌后，听胡的牌
                                          }
                                },
                              }
                    },
                  }
        },
        {name = "lgCount", type = T.BYTE},
        {name = "lgCards", type = T.ARRAY,fixedLengthParser = "lgCount",fixedLength = 0,
            fmt = {
                    {name = "card", type = T.BYTE},--重连用户信息:所出的牌
                  }
        },
        --亮牌可杠的暗刻
        {name = "ankeCount", type = T.BYTE},--其他用户信息: 其他用户所出牌的数量
        {name = "ankeCards", type = T.ARRAY,fixedLengthParser = "ankeCount",fixedLength = 0,
            fmt = {
                    {name = "card", type = T.BYTE},--其他用户信息: 所出的牌
            }
        },
        {name = "tingHuCount", type = T.BYTE},--其他用户信息: 其他用户所出牌的数量
        {name = "tingHuCards", type = T.ARRAY,fixedLengthParser = "tingHuCount",fixedLength = 0,
            fmt = {
                    {name = "card", type = T.BYTE},--其他用户信息: 所出的牌
            }
        },
        {name = "liangCount", type = T.BYTE},
        {name = "liangCards", type = T.ARRAY,fixedLengthParser = "liangCount",fixedLength = 0,
            fmt = {
                    {name = "card", type = T.BYTE},--重连用户信息:所出的牌
                  }
        },
    }
}

--广播缺一门选择
P.SVR_BROADCAST_QUE                = 0x200C    
SERVER[P.SVR_BROADCAST_QUE] = {
    ver = 1,
    fmt = {
        {name = "mount", type = T.BYTE}, --用户数量
        {name = "content", type = T.ARRAY,fixedLengthParser = "mount",fixedLength = 0,
            fmt = {
                {name="uid",type = T.INT},   --用户id
                {name="que",type = T.BYTE},   --座位id
            }
        },
    }
}

--登陆错误
P.SVR_ERROR                = 0x1005    
SERVER[P.SVR_ERROR] = {
    ver = 1,
    fmt = {
        {name = "type", type = T.INT}, --错误码
    }
}

--广播玩家退出返回
P.SVR_QUIT_ROOM                = 0x100E   
SERVER[P.SVR_QUIT_ROOM] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT}, --用户id
    }
}

--广播用户准备
P.SVR_USER_READY_BROADCAST              = 0x4001   
SERVER[P.SVR_USER_READY_BROADCAST] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT}, --用户id
    }
}

--登陆房间返回
P.SVR_LOGIN_ROOM                = 0x1007    
SERVER[P.SVR_LOGIN_ROOM] = {
    ver = 1,
    fmt = {
        {name = "totalRounds", type = T.BYTE}, --组局总局数
        {name = "base", type = T.INT}, --砥柱
        {name = "f_base", type = T.INT}, --底注基数
        {name = "play_count", type = T.SHORT}, --圈数
        {name = "seat_id", type = T.INT}, --用户id
        {name = "gold", type = T.INT}, --金币
        {name = "user_mount", type = T.INT}, --其他桌上用户数
        {name = "users_info", type = T.ARRAY,fixedLengthParser = "user_mount",fixedLength = 0,
            fmt = {
                {name="uid",type = T.INT},   --用户id
                {name="seat_id",type = T.INT},   --座位id
                {name="if_ready",type = T.INT},   --用户是否准备
                {name="user_info",type = T.STRING},   --用户json字符串
                {name="user_gold",type = T.INT},   --用户金币
            }
        },
        {name = "lesstime", type = T.SHORT}, --出牌超时时间
        {name = "handletime", type = T.SHORT}, --操作超时时间

    }
}

--登陆房间广播
P.SVR_LOGIN_ROOM_BROADCAST                = 0x100D   
SERVER[P.SVR_LOGIN_ROOM_BROADCAST] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT}, --用户id
        {name = "seat_id", type = T.INT}, --用户座位ID
        {name = "if_ready", type = T.INT}, --用户Json串
        {name = "user_info", type = T.STRING}, --用户Json串
        {name = "user_gold", type = T.INT}, --用户金币
    }
}

--发牌
P.SVR_SEND_USER_CARD = 0x3001 
SERVER[P.SVR_SEND_USER_CARD] = {
    ver = 1,
    fmt = {
        {name = "seat", type = T.BYTE}, --庄家座位id
        {name = "shai", type = T.SHORT}, --筛子数值
        {name = "mount", type = T.INT}, --用户Json串
        {name = "cards", type = T.ARRAY,fixedLengthParser = "mount",fixedLength = 0,
            fmt = {
                {type = T.BYTE},   --牌
            }
        },
        {name = "isBufenLiang", type = T.BYTE}, --是否部分亮
    }
}

--开始选择缺一门
P.SVR_START_QUE_CHOICE = 0x3006          
SERVER[P.SVR_START_QUE_CHOICE] = {
    ver = 1,
}

--用户退出游戏成功
P.SVR_QUICK_SUC               = 0x1008   
SERVER[P.SVR_QUICK_SUC] = {
    ver = 1,
}

--通知漫游
P.SVR_MANYOU               = 0x4010   
SERVER[P.SVR_MANYOU] = {
    ver = 1,
}

--服务器告知客户端可以进行的操作 --有可能在玩家选择补杠后，其他家可以胡该牌 没用到
P.SVR_NORMAL_OPERATE = 0x3005 
SERVER[P.SVR_NORMAL_OPERATE] = {
    ver = 1,
    fmt={
        {name="handle",type=T.SHORT},--操作类型
        {name="card",type=T.BYTE},--操作的牌
        {name="seatId",type=T.BYTE},--操作用户座位id
        {name="isLiang",type=T.BYTE}, --0：普通操作提示 1：亮牌流程相关
        {name="tingCount",type=T.BYTE},
        {name="tingCards", type = T.ARRAY,fixedLengthParser = "tingCount",fixedLength = 0,
            fmt={
                {name="card",type=T.BYTE},
                {name = "tingHuCount", type = T.BYTE},
                {name = "tingHuCards", type = T.ARRAY,fixedLengthParser = "tingHuCount",fixedLength = 0,
                    fmt = {
                            {name = "huCardsCount", type = T.BYTE},--打出对应牌后，听胡的牌
                                {name = "huCards", type = T.ARRAY,fixedLengthParser = "huCardsCount",fixedLength = 0,
                                    fmt = {
                                            {name = "card", type = T.BYTE},--打出对应牌后，听胡的牌
                                          }
                                },
                                {name = "componentCount", type = T.BYTE},--打出对应牌后，听胡的牌
                                {name = "component", type = T.ARRAY,fixedLengthParser = "componentCount",fixedLength = 0,
                                    fmt = {
                                            {name = "card", type = T.BYTE},--打出对应牌后，听胡的牌
                                          }
                                },
                            }
                },
            }
        },
        {name="lgCount",type=T.BYTE},
        {name="lgCards", type = T.ARRAY,fixedLengthParser = "lgCount",fixedLength = 0,
            fmt={
                {name="card",type=T.BYTE},
            }
        },
    }
}

--广播结束游戏 --没用
P.SVR_GAME_OVER = 0x4009 
SERVER[P.SVR_GAME_OVER] = {
    ver = 1,
    fmt={
        {name = "userdate", type = T.ARRAY,fixedLength = 3,
            fmt={
                {name="userid",type=T.INT},--用户id
                {name="gold",type=T.INT},--用户本轮金币变化
                {name="cgold",type=T.INT},--用户当前金币数
                {name="userstate",type=T.SHORT},--用户状态 在线=1，离线=0
            }
        }
        
    }
}

--广播刮风下雨（返回）杠
P.SVR_GUFENG_XIAYU = 0x4012 
SERVER[P.SVR_GUFENG_XIAYU] = {
    ver = 1,
    fmt={
        {name="userid",type=T.INT},--操作用户id
        {name="wingold",type=T.INT},--用户赢得钱
        {name="gangType",type=T.SHORT},--杠的类型（显示动画）操作杠的类型operation_reques,1刮风，2下雨
        {name="czgangType",type=T.BYTE,cache=1},--操作杠的类型operation_reques操作杠的类型operation_reques
        {name="fuqianUserId",type=T.INT,request="czgangType",requestValue=1}, --需要付钱的用户id
        {name="fuqiannum",type=T.INT,request="czgangType",requestValue=1},--需要付的钱
        {name="sheMoenyNum",type=T.BYTE,request="czgangType",requestValue=0},--算钱涉及人数
        {name="sheMoenydate", type = T.ARRAY,fixedLengthParser = "sheMoenyNum",fixedLength = 0,request="czgangType",requestValue=0,
            fmt={
                {name="userid",type=T.INT},--用户id
                {name="userPaymoney",type=T.INT},--用户应付的钱
            }
        }
    }
}

--海底牌
P.SVR_HAIDI_CARD = 0x4017
SERVER[P.SVR_HAIDI_CARD] = {
    ver = 1,
    fmt={
        {name = "uid", type=T.INT}, -- 摸牌的用户id
        {name="card",type=T.BYTE} -- 海底牌
    }
}

--出牌错误返回
P.SVR_CHUPAI_ERROR = 0x4018
SERVER[P.SVR_CHUPAI_ERROR] = {
    ver = 1,
    fmt={
        {name="errorCode",type=T.BYTE} -- 1 无此牌类型 2 非出牌状态 3 非当前出牌玩家 4 手上无此牌
    }
}

--服务器和客户端都公用的消息
P.CHAT_MSG                 = 0x1003    --用户聊天消息
CLIENT[P.CHAT_MSG] = {
    ver = 1,
    fmt = {
        {name = "msg", type = T.STRING}, --聊天内容
    }
}
SERVER[P.CHAT_MSG] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT},   --用户ID
        {name = "msg", type = T.STRING}, --聊天内容
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

--组局局数
P.SVR_GROUP_TIME                  = 0x5101
SERVER[P.SVR_GROUP_TIME] =  {
    ver = 1,
    fmt = {
        {name = "time", type = T.INT},
        {name = "round", type = T.INT},
        {name = "round_total", type = T.INT}
    }
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


--玩家进入私人房
P.SVR_ENTER_PRIVATE_ROOM                  = 0x0212
SERVER[P.SVR_ENTER_PRIVATE_ROOM] =  {
    ver = 1,
    fmt = {
        {name = "flag", type = T.SHORT},
        {name = "ret", type = T.SHORT}
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

--服务器告诉客户端，可以换牌
P.SERVER_COMMAND_NEED_CHANGE_CARD = 0x3007 
SERVER[P.SERVER_COMMAND_NEED_CHANGE_CARD] = {
    ver = 1,
    fmt = {
       
    }
}

--服务器广播换牌的结果
P.SERVER_COMMAND_CHANGE_CARD_RESULT = 0x3008 
SERVER[P.SERVER_COMMAND_CHANGE_CARD_RESULT] = {
    ver = 1,
    fmt = {
        {name = "mount", type = T.SHORT}, --用户Json串
        {name = "cards", type = T.ARRAY,fixedLengthParser = "mount",fixedLength = 0,
            fmt = {
                {type = T.BYTE},   --牌
            }
        }
    }
}

---5.30新建的协议,听说是比赛相关
--用户请求进入比赛场
P.c2s_CLIENT_CMD_JOIN_MATCH = 0x0120      
CLIENT[P.c2s_CLIENT_CMD_JOIN_MATCH] = {
    ver = 1,
    fmt = {
         {name = "Level",type = T.SHORT}, --比赛等级
         {name = "flag", type = T.SHORT} -- 比赛等级
    }
}

--用户请求进入比赛场，上面0120的返回值
P.s2c_JOIN_MATCH_RETURN = 0x211  
SERVER[P.s2c_JOIN_MATCH_RETURN] = {
    ver = 1,
    fmt = {
    {name = "Matched",type = T.INT},--比赛ID
    {name = "serverID",type = T.SHORT},--ServerID
    {name = "Ip",type = T.STRING},--Ip
    {name = "Port",type = T.INT},--端口
}
}

--P.c2s_ENTER_MATCH_GAME = 0x1001 -- 跟上面的1001一样。

--进入比赛失败 0x7109
P.s2c_JOIN_MATCH_FAIL = 0x7109
SERVER[P.s2c_JOIN_MATCH_FAIL] = {
    ver = 1,
    fmt = {
    {name = "Errortype",type = T.INT},--失败类型
}
}

-- 进入比赛成功：0x7101
P.s2c_JOIN_MATCH_SUCCESS = 0x7101
SERVER[P.s2c_JOIN_MATCH_SUCCESS] = {
    ver = 1,
    fmt = {
    {name = "Matched",type = T.INT},--比赛ID
    {name = "MatchUserCount",type = T.INT},--当前比赛多少人
    {name = "totalCount",type = T.INT},--总过多少人
    {name = "Gametype",type = T.INT},--比赛类型
    {name = "Costformatch",type = T.INT},--报名费
    -- {name = "Logintype",type = T.INT},--报名方式
    {name = "Score",type = T.INT},--剩余金币
}
}

--同时，已经报名的玩家会收到其他玩家进入的消息0x7103
P.s2c_OTHER_PEOPLE_JOINT_IN = 0x7103
SERVER[P.s2c_OTHER_PEOPLE_JOINT_IN] = {
    ver = 1,
    fmt = {
    {name = "Usercount",type = T.INT},--当前参加比赛人数
    {name = "Totalcount",type = T.INT},--当前比赛多少人

}
}

--用户退出比赛：0x3901
P.c2s_CLIENT_QUIT_MATCH = 0x3901-- //用户请求进入比赛场
CLIENT[P.c2s_CLIENT_QUIT_MATCH] = {
    ver = 1,
    fmt = {
         {name = "MatchID",type = T.INT}, --比赛ID
         {name = "userID",type = T.INT} --用户ID
    }
}

-- 返回退出比赛结果：0x7110
P.s2c_QUIT_MATCH_RETURN = 0x7110
SERVER[P.s2c_QUIT_MATCH_RETURN] = {
    ver = 1,
    fmt = {
    {name = "Flag",type = T.INT},--Nlogintype 1、2表示成功 其他的失败
    {name = "Nlogintype",type = T.INT},--报名方式
    {name = "nCostForMatch",type = T.INT},--报名费
    {name = "Errortype",type = T.INT},--报名费
}
}

--比赛开始逻辑0x7104//牌局，开始发送其他玩家信息
P.s2c_GAME_BEGIN_LOGIC = 0x7104
SERVER[P.s2c_GAME_BEGIN_LOGIC] = {
    ver = 1,
    fmt = {
            {name = "Userid",type = T.INT},--用户ID
            {name = "seat_id",type = T.INT},--座位ID
            {name = "Matchrank",type = T.INT},--比赛排名
            {name = "Matchpoint",type = T.INT},--比赛分数
            {name = "Userinfo",type = T.STRING},--自己的用户信息

            {name = "Usercount",type = T.INT},--桌子上其他玩家的个数
            {name = "other_players", type = T.ARRAY,fixedLengthParser = "Usercount",fixedLength = 0,
                fmt = {
                            {name = "uid",type = T.INT},--用户ID
                            {name = "seat_id",type = T.INT},--座位ID
                            {name = "Matchrank",type = T.INT},--比赛排名
                            {name = "Matchpoint",type = T.INT},--比赛分数
                            {name = "user_info",type = T.STRING},--用户信息
                    }
            },
            {name = "Level",type = T.INT},--当前比赛的level
            {name = "base",type = T.INT},--底注
            {name = "Round",type = T.INT},--第几轮
            {name = "Sheaves",type = T.INT},--第几局
            {name = "Lowpoint",type = T.INT},--淘汰分数
            {name = "Number",type = T.INT},--决赛每轮打多少局
            {name = "Currentcount",type = T.INT},--当前还剩多少人
            {name = "gameID",type = T.STRING},--比赛ID
            {name = "Finaltablecount",type = T.INT},--决赛阶段每桌打几场
}
}

--每轮打完之后 会给玩家发送比赛状态信息0x7106
P.s2c_GAME_STATE_MSG = 0x7106
SERVER[P.s2c_GAME_STATE_MSG] = {
    ver = 1,
    fmt = {
    {name = "Maxnumber",type = T.INT},--最大的人数
    {name = "Rank",type = T.INT},--自己的排名
    {name = "Status",type = T.INT},--状态
    {name = "Strtime",type = T.STRING},--当前时间
    {name = "Tablecount",type = T.INT},--未完成比赛的次数
    {name = "Level",type = T.INT},--当前比赛等级
    {name = "Logintype",type = T.INT},--报名方式

}
}

--发送用户重连回比赛开赛后的等待界面
P.s2c_SVR_MATCH_WAIT                   = 0x7113
SERVER[P.s2c_SVR_MATCH_WAIT] =  {
    ver = 1,
    fmt = {
        {name = "Flag", type = T.INT},--0
        {name = "whatmean", type = T.STRING},--???
        {name = "table_count", type = T.INT},--桌子数
        {name = "gameid", type = T.STRING},--gameId
        {name = "Matchrank", type = T.INT},--当前排名
        {name = "Matchpoint", type = T.INT},--当前积分
        {name = "round", type = T.INT},--当前比赛轮次
        {name = "user_count", type = T.INT},--参数总人数
        {name = "type", type = T.INT},--0积分赛  1 金币赛
    }
}

-- 比赛的过程中会收到比赛的排名信息  0x7114
P.s2c_PAI_MING_MSG = 0x7114
SERVER[P.s2c_PAI_MING_MSG] = {
    ver = 1,
    fmt = {
        {name = "courrentSize",type = T.INT},--当前多少人
        {name = "Rankcount",type = T.INT},--排行榜人数
        {name = "Userid",type = T.INT},--用户ID
        {name = "Rank",type = T.INT},--用户排名
        {name = "Rank",type = T.INT},--用户分数
        {name = "Username",type = T.STRING},--用户昵称
    }
}

--用户重新登录比赛场房间的消息返回
P.s2c_SVR_REGET_MATCH_ROOM               = 0x7112   
SERVER[P.s2c_SVR_REGET_MATCH_ROOM] = {
    ver = 1,
    fmt = {
        {name = "nTableType", type = T.SHORT}, --
        {name = "seat_id", type = T.SHORT}, --重连用户座位ID
        {name = "user_gold", type = T.INT}, --重连用户拥有金币数 
        {name = "nTingFlag", type = T.SHORT}, --

        --房间配置
        {name = "nBaseChips", type = T.INT}, --桌子信息: 
        {name = "nBaseRadix", type = T.INT}, --桌子信息: --底注基数
        {name = "nOutCardTimeout", type = T.SHORT}, --桌子信息: 出牌超时时间
        {name = "nOperationTimeout", type = T.SHORT}, --桌子信息: 出牌超时时间
        {name = "m_nBankSeatId", type = T.SHORT}, --桌子信息: 庄家位置
        {name = "m_nShaiZi", type = T.SHORT}, --桌子信息: 筛子数
        {name = "card_less", type = T.SHORT}, --//桌上剩余麻将数

        {name = "nPlayerCount", type = T.SHORT}, --其他用户信息:其他用户数
        {name = "users_info", type = T.ARRAY,fixedLengthParser = "nPlayerCount",fixedLength = 0,
            fmt = {
                    {name = "UserId", type = T.INT},--其他用户信息:用户id
                    {name = "SeatId", type = T.SHORT},--其他用户信息:用户座位id
                    {name = "m_bAI", type = T.SHORT},--其他用户信息:用户是否托管
                    {name = "nTingFlag", type = T.SHORT},--
                    {name = "HuSeatId", type = T.BYTE,cache=1},--是否胡 0 没有胡 1 胡
                    {name = "HuType",type = T.BYTE,request="HuSeatId",requestValue=1},
                    {name = "HuCard",type = T.BYTE,request="HuSeatId",requestValue=1},
                    {name = "countHandCards", type = T.SHORT},--
                    {name = "m_strUserInfo", type = T.STRING},

                    {name = "m_nMoney", type = T.INT},--其他用户信息: 用户金币数量
                    --碰牌
                    {name = "pengCount", type = T.SHORT},--其他用户信息: 用户碰牌数量
                    {name = "pengdata", type = T.ARRAY,fixedLengthParser = "pengCount",fixedLength = 0,
                        fmt = {
                                {name = "pengCards", type = T.BYTE},--其他用户信息: 用户所碰的牌
                            }
                    },
                        
                    --杠牌
                    {name = "gangCount", type = T.SHORT},--其他用户信息: 用户杠牌数量
                    --明杠
                    {name = "minggang", type = T.ARRAY,fixedLengthParser = "gangCount",fixedLength = 0,
                        fmt = {
                                {name = "data1", type = T.BYTE},--其他用户信息: 用户所杠的牌，0是明杠。1是暗杠
                                {name = "data2", type = T.BYTE},--其他用户信息: 杠牌的类型
                            }
                    },

                    -- {name = "angang", type = T.ARRAY,fixedLengthParser = "gangCount",fixedLength = 0,
                    --     fmt = {
                    --             {name = "data1", type = T.BYTE},--其他用户信息: 用户所杠的牌，0是明杠。1是暗杠
                    --             {name = "data2", type = T.BYTE},--其他用户信息: 杠牌的类型
                    --         }
                    -- },
                    --出牌
                    {name = "outCardCount", type = T.SHORT},--其他用户信息: 其他用户所出牌的数量
                    {name = "outCarddata", type = T.ARRAY,fixedLengthParser = "outCardCount",fixedLength = 0,
                        fmt = {
                                {name = "outCards", type = T.BYTE},--其他用户信息: 所出的牌
                                {name = "outCardState", type = T.BYTE},--其他用户信息: 该牌有没有被吃碰杠，1是有，0是没有
                        }
                    },
                    -- 如果是定缺，写入定缺类型
                    {name = "que", type = T.BYTE,cache=1},--其他用户信息: 其他用户所出牌的数量
                    {name = "isDQ", type = T.BYTE ,request="que",requestValue=1},
            }
        },
        {name = "pHuSeatId", type = T.BYTE,cache=1}, --是否胡
        {name = "pHudate_p", type = T.BYTE,request="pHuSeatId",requestValue=1},
        {name = "pHudate_c", type = T.BYTE,request="pHuSeatId",requestValue=1},


        {name = "holdssize", type = T.SHORT}, --重连用户信息:手牌数量
        {name = "holds_info", type = T.ARRAY,fixedLengthParser = "holdssize",fixedLength = 0,
            fmt = {
                    {name = "holds", type = T.BYTE},--重连用户信息:手牌的值
                }
        },

        -- 碰牌
        {name = "pengCount", type = T.SHORT},--重连用户信息:碰牌的数量
        {name = "peng_info", type = T.ARRAY,fixedLengthParser = "pengCount",fixedLength = 0,
            fmt = {
                    {name = "peng", type = T.BYTE},--重连用户信息:碰牌的值
                  }
        },

        --杠牌
        {name = "gangCount", type = T.SHORT},--重连用户信息:杠牌的数量
        --明杠
        {name = "gangCount_infoming", type = T.ARRAY,fixedLengthParser = "gangCount",fixedLength = 0,
            fmt = {
                    {name = "gang", type = T.BYTE},--重连用户信息:杠牌的值
                    {name = "gangtype", type = T.BYTE},--重连用户信息:0表示明杠，1表示暗杠
                  }
        },

        --按杠
        -- {name = "gangCount_infoming", type = T.ARRAY,fixedLengthParser = "gangCount",fixedLength = 0,
        --     fmt = {
        --             {name = "gang", type = T.BYTE},--重连用户信息:杠牌的值
        --             {name = "gangtype", type = T.BYTE},--重连用户信息:0表示明杠，1表示暗杠
        --           }
        -- },

        -- 出牌历史
        {name = "outcardSize", type = T.SHORT},--重连用户信息:出牌历史
        {name = "outcardSize_info", type = T.ARRAY,fixedLengthParser = "outcardSize",fixedLength = 0,
            fmt = {
                    {name = "outcard", type = T.BYTE},--重连用户信息:所出的牌
                    {name = "outcardtype", type = T.BYTE},--重连用户信息:该牌有没有被吃碰杠，1是有，0是没有
                  }
        },

        -- 如果是定缺，写入定缺类型
        {name = "quew", type = T.BYTE,cache=1},--其他用户信息: 其他用户所出牌的数量
        {name = "isDQw", type = T.BYTE,request="quew",requestValue=1},


        {name = "m_nMatchRank",type = T.INT},--用户比赛的排名
        {name = "m_nPoint",type = T.INT},--用户比赛积分
        {name = "m_strUserInfo",type = T.STRING},--用户信息
        {name = "m_nplayecount",type = T.INT},

        {name = "other_point", type = T.ARRAY,fixedLengthParser = "m_nplayecount",fixedLength = 0,
            fmt = {
                    {name = "m_userid", type = T.INT},
                    {name = "m_seatid", type = T.INT},
                    {name = "m_nMatchRank",type = T.INT},
                    {name = "m_nPoint", type = T.INT},--其他用户信息:用户积分
                    {name = "m_strUserInfo", type = T.STRING},
            }
        },
        {name = "m_nLevel",type = T.INT},
        {name = "m_nSheaves",type = T.INT},--当前轮第几局
        {name = "m_nRound",type = T.INT},--当前轮第几轮
        {name = "m_nLowPoint",type = T.INT},--淘汰的最低分数
        {name = "m_nNuber",type = T.INT},--决赛每轮打多少局
        {name = "m_nCurrentCount",type = T.INT},--当前还剩多少人
        {name = "m_nstr",type = T.STRING},
        {name = "m_nFinalplayTimesInTable",type = T.INT},
    }
}
---5.30新建的协议,听说是比赛相关

--解散房间相关
--没有此房间，解散房间失败  0x908
P.G2H_CMD_DISSOLVE_FAILED = 0x908
SERVER[P.G2H_CMD_DISSOLVE_FAILED] = {
    ver = 1
}

--广播桌子用户请求解散组局
P.SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP = 0x102A
SERVER[P.SERVER_BROADCAST_REQUEST_DISSOLVE_GROUP] = {
    ver = 1
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


P.SERVER_CMD_MESSAGE                = 0x0214    --服务器返回组局收到的信息
SERVER[P.SERVER_CMD_MESSAGE] = {
    ver = 1,
    fmt = {
        {name = "msgCount", type = T.INT}, --消息长度
        {name = "msg", type = T.STRING}, --消息
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


return SZKWX_SERVER_PROTOCOL