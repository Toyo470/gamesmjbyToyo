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

P.CLI_HEART                      = 0x0110    --svr心跳
CLIENT[P.CLI_HEART] = {
    ver = 1,
}

P.CLI_XIA_BAIREN                     = 0x21003    --百人场下注
CLIENT[P.CLI_XIA_BAIREN] = {
    ver = 1,
    fmt= {
        {name = "seat", type = T.INT},  --座位
        {name = "gold", type = T.INT},  --金币
    }
}

P.CLI_QUIT_ROOM                     = 0x1002    --请求退出房间
CLIENT[P.CLI_QUIT_ROOM] = {
    ver = 1,
}

P.CLI_QUIT_ROOM_BAIREB                     = 0x21002    --请求退出百人房间
CLIENT[P.CLI_QUIT_ROOM_BAIREB] = {
    ver = 1,
}

P.CLI_READYNOW_ROOM                     = 0x2001    --用户发送准备
CLIENT[P.CLI_READYNOW_ROOM] = {
    ver = 1,
}

P.CLI_USER_BASES                     = 0x2008    --用户加倍倍数
CLIENT[P.CLI_USER_BASES] = {
    ver = 1,
    fmt = {
        {name = "bases", type = T.INT},  --倍数
    }
}


P.CLI_QIANGZHUANG                     = 0x2007    --用户抢庄
CLIENT[P.CLI_QIANGZHUANG] = {
    ver = 1,
    fmt = {
        {name = "if_qiang", type = T.INT},  --是否抢庄
    }
}


P.CLI_PLAY_CARD                     = 0x2003    --玩家出牌
CLIENT[P.CLI_PLAY_CARD] = {
    ver = 1,
    fmt = {
        {name = "mount", type = T.BYTE},  --数量     
        {name = "cards", type = T.ARRAY,fixedLengthParser = "mount",fixedLength = 0,
            fmt = {
                {name="card",type = T.BYTE},   --牌
            }
        },
    }
}



P.CLI_LOGIN                      = 0x0116    --登录大厅
CLIENT[P.CLI_LOGIN] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT},
        {name = "storeId", type = T.INT},
        {name = "kind", type = T.INT},
        {name = "userInfo", type = T.STRING},
    }
}


P.CLI_GET_ROOM                   = 0x0113    --获取房间id
CLIENT[P.CLI_GET_ROOM] = {
    ver = 1,
    fmt = {
        {name = "level", type = T.SHORT},   --桌子等级
        -- {name = "type", type = T.BYTE},   --登陆类型，0--随机登陆，1--指定桌子登陆
        -- {name = "targetid", type = T.INT} --目标桌子ID，0表示随机登陆
         {name = "Chip", type = T.INT},--请求场次的底注
        {name = "Sid", type = T.INT},--游戏场的id
        {name = "activity_id", type = T.STRING} --带入活动id
    }
}


    
P.CLI_LOGIN_ROOM                 = 0x1001    --登录房间
CLIENT[P.CLI_LOGIN_ROOM] = {
    ver = 1,
    fmt = {
        {name = "tid", type = T.INT},   --桌子ID
        {name = "uid", type = T.INT},   --用户ID
        {name = "mtkey", type = T.STRING}, --需要验证的key
        {name = "strinfo", type = T.STRING}, --用户个人信息
    }
}


P.CLI_LOGIN_ROOM_BAIREN                 = 0x21001    --登录百人房间
CLIENT[P.CLI_LOGIN_ROOM_BAIREN] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT},   --桌子ID
        {name = "tid", type = T.INT},   --用户ID
        {name = "mtkey", type = T.STRING}, --需要验证的key
        {name = "strinfo", type = T.STRING}, --用户个人信息
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

P.CLIENT_CMD_FORWARD_MESSAGE                = 0x165    --向服务器发送向组局里发送的缓存信息
CLIENT[P.CLIENT_CMD_FORWARD_MESSAGE] = {
    ver = 1,
    fmt = {
        {name = "level", type = T.SHORT},   --游戏level
        {name = "msg", type = T.STRING}
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

-----------------------------------------------------------
-------------------  服务端返回  --------------------------
-----------------------------------------------------------

--玩家进入私人房
P.SVR_ENTER_PRIVATE_ROOM                  = 0x0212
SERVER[P.SVR_ENTER_PRIVATE_ROOM] =  {
    ver = 1,
    fmt = {
        {name = "flag", type = T.SHORT},
        {name = "ret", type = T.SHORT}
    }
}

P.SERVER_CMD_FORWARD_MESSAGE                = 0x0213    --服务器返回组局收到的缓存信息
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

P.SERVER_CMD_MESSAGE                = 0x0214    --服务器返回组局收到的信息
SERVER[P.SERVER_CMD_MESSAGE] = {
    ver = 1,
    fmt = {
        {name = "msgCount", type = T.INT}, --消息长度
        {name = "msg", type = T.STRING}, --消息
    }
}

P.SVR_LOGIN_OK                   = 0x0201    --登录成功
SERVER[P.SVR_LOGIN_OK] = {
    ver = 1,
    fmt = {
        {name = "ver", type = T.INT},--ver
        {name = "levelCount", type = T.INT},--等级场个数
        {name = "usercount", type = T.ARRAY,fixedLengthParser = "levelCount",fixedLength = 0,
            fmt = {
                {type = T.INT},   --人数
            }
        },

        {name = "friends", type = T.INT}, --好友数
        {name = "tid", type = T.INT}, --桌子ID，0表示无桌子，第一次登陆; 不为0时则表示需要重连
        {name = "ip", type = T.STRING}, --ip
        {name = "port", type = T.INT},  --端口
        -- {name = "level", type = T.INT}   -- level
    }
}


P.SVR_BAIREN_START = 0x22001 --广播百人游戏开始
SERVER[P.SVR_BAIREN_START] = {
    ver = 1,
    fmt = {
        {name = "status", type = T.INT},--桌子状态
        {name = "time", type = T.INT},--时间
    }
}


P.SVR_ZHUANG_INFO = 0x22002 --广播百人庄家信息
SERVER[P.SVR_ZHUANG_INFO] = {
    ver = 1,
    fmt = {
        {name = "zhuangid", type = T.INT},--庄家id
        {name = "lefttimes", type = T.INT},--剩余坐庄次数
        {name = "shanggold", type = T.INT},--上庄携带金币
        {name = "zhuanggold", type = T.INT64},--庄金币
        {name = "zhuanginfo", type = T.STRING},--庄信息
    }
}


P.SVR_XIAZHU_START = 0x22003 --广播百人开始下注
SERVER[P.SVR_XIAZHU_START] = {
    ver = 1,
    fmt = {
        {name = "time", type = T.INT},--庄家id
        {name = "maxnum", type = T.INT},--最大下注数
        {name = "mounts", type = T.INT},--玩家数
        {name = "info", type = T.ARRAY,fixedLengthParser = "mounts",fixedLength = 0,
            fmt = {
                {name = "seat", type = T.INT},--座位号
                {name = "cards", type = T.ARRAY,fixedLength = 5,
                    fmt = {
                        {type = T.BYTE}
                    }
                },--该座位总下注数
                
            }
        },
    }
}


P.SVR_CARD_RESULT = 0x22004 --广播牌型结果信息
SERVER[P.SVR_CARD_RESULT] = {
    ver = 1,
    fmt = {
        {name = "time", type = T.INT},--时间
        {name = "mount", type = T.INT},--玩家数量
        {name = "content", type = T.ARRAY,fixedLengthParser = "mount",fixedLength = 0,
            fmt = {
                {name = "seat", type = T.INT,cache=1},--座位号
                {name = "result", type = T.BYTE},--结果
                {name = "cardkind", type = T.BYTE},--牌型
                {name = "cards", type = T.ARRAY,fixedLength = 5,
                    fmt = {
                        {type = T.BYTE}
                    }
                },--该座位总下注数
                {name = "pond", type = T.INT},--牌型 
            }
        },
    }
}


P.SVR_XIAZHU_INFO = 0x22005 --广播下注信息
SERVER[P.SVR_XIAZHU_INFO] = {
    ver = 1,
    fmt = {
        {name = "leftnum", type = T.INT},--剩余可下注的值
        {name = "seats_num", type = T.INT},--座位数
        {name = "info", type = T.ARRAY,fixedLengthParser = "seats_num",fixedLength = 0,
            fmt = {
                {name = "seat", type = T.INT},--座位号
                {name = "seatmoney", type = T.INT},--该座位总下注数
                {name = "mymoney", type = T.INT},--自己的下注数

            }
        },
     
    }
}


P.SVR_PER_BAIREN_END = 0x22006 --广播每个玩家的结算信息
SERVER[P.SVR_PER_BAIREN_END] = {
    ver = 1,
    fmt = {
        {name = "allmoney", type = T.INT64},--总奖池
        {name = "zhuanggold", type = T.INT64},--庄家的金币
        {name = "zhuangshang", type = T.INT},--庄家上庄携带金币
        {name = "zhuangwin", type = T.INT},--庄家的输赢钱
        {name = "usergold", type = T.INT64},--玩家的金币
        {name = "userwin", type = T.INT},--玩家的输赢钱     
    }
}



P.SVR_GET_ROOM_OK                = 0x0210    --获取房间id结果
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

P.SVR_ERROR                = 0x1005    --登陆错误
SERVER[P.SVR_ERROR] = {
    ver = 1,
    fmt = {
        {name = "type", type = T.INT}, --错误码
    }
}

P.SVR_QUIT_ROOM                = 0x100E   --广播玩家推出返回
SERVER[P.SVR_QUIT_ROOM] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT}, --用户id
    }
}

P.SVR_QUIT_ROOM_BAIREN                = 0x21002   --广播玩家推出百人
SERVER[P.SVR_QUIT_ROOM_BAIREN] = {
    ver = 1,
    fmt = {
        {name = "ret", type = T.INT}, --返回码
    }
}


P.SVR_NO_GOLD               = 0x700A   --svr返回金币不足
SERVER[P.SVR_NO_GOLD] = {
    ver = 1,
    fmt = {
        {name = "type", type = T.INT}, --返回码
    }
}


P.SVR_BRANKRUPT              = 0x7002   --破产
SERVER[P.SVR_BRANKRUPT] = {
    ver = 1,
    fmt = {
        {name = "type", type = T.INT}, --返回码
    }
}

P.SERVER_COMMAND_KICK_OUT_ROOM              = 0x7007   --新加协议
SERVER[P.SERVER_COMMAND_KICK_OUT_ROOM] = {
    ver = 1,
    fmt = {
        {name = "type", type = T.INT}, --返回码
    }
}


P.SVR_USER_READY_BROADCAST              = 0x6001   --广播用户准备
SERVER[P.SVR_USER_READY_BROADCAST] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT}, --用户id
    }
}


P.SVR_USER_QIANFGZHUANG_RESULT_BROADCAST              = 0x6013   --广播玩家抢庄结果（返回）
SERVER[P.SVR_USER_QIANFGZHUANG_RESULT_BROADCAST] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT}, --用户id
        {name = "if_qiang", type = T.INT}, --是否抢庄

    }
}

P.SVR_USER_BASES_RESULT_BROADCAST              = 0x6014   --广播玩家加倍倍数
SERVER[P.SVR_USER_BASES_RESULT_BROADCAST] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT}, --用户id
        {name = "base", type = T.INT}, --倍数

    }
}

P.SVR_USER_PLAYED_CARDS_BROADCAST              = 0x6005   --广播玩家出牌
SERVER[P.SVR_USER_PLAYED_CARDS_BROADCAST] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT}, --用户id
        {name = "kind", type = T.BYTE}, --牌型
        {name = "mount", type = T.BYTE}, --数量
        {name = "cards", type = T.ARRAY,fixedLengthParser = "mount",fixedLength = 0,
            fmt = {
                {type = T.BYTE},   --倍数
            }
        },

    }
}


P.SVR_SETTLEMENT_BROADCAST              = 0x6008   --广播游戏结算信息
SERVER[P.SVR_SETTLEMENT_BROADCAST] = {
    ver = 1,
    fmt = {
        {name = "o_user_mount", type = T.INT}, --闲家数量
        {name = "o_userinfo", type = T.ARRAY,fixedLengthParser = "o_user_mount",fixedLength = 0,
            fmt = {
                {name = "uid", type = T.INT}, --用户id
                {name = "base", type = T.INT}, --玩家输赢倍数
                {name = "cardgold", type = T.INT}, --玩家输赢金币
                {name = "gold", type = T.INT}, --玩家金币
            }
        },
        
        {name = "brank_id", type = T.INT}, --庄家id
        {name = "brank_base", type = T.INT}, --庄家输赢倍数
        {name = "brank_cardgold", type = T.INT}, --庄家 输赢数
        {name = "brank_gold", type = T.INT}, --庄家金币
        {name = "time", type = T.INT}, --播动画时间
        
        {name = "round", type = T.INT}, --当前结算时的局数

    }
}



P.SVR_PLAY_CARD_BROADCAST              = 0x6004   --广播玩家开始出牌
SERVER[P.SVR_PLAY_CARD_BROADCAST] = {
    ver = 1,
    fmt = {
        {name = "time", type = T.INT}, --超时时间

    }
}


P.SVR_READY_BROADCAST              = 0x6001   --广播玩家准备
SERVER[P.SVR_READY_BROADCAST] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT}, --用户id
    }
}


P.SVR_GAME_START              = 0x6002   --不知道什么鬼
SERVER[P.SVR_GAME_START] = {
    ver = 1,
  
}

P.SVR_COST_TAI           = 0x6017   --扣除台费
SERVER[P.SVR_COST_TAI] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT}, --用户id
        {name = "tai", type = T.INT}, --台费
        {name = "money", type = T.INT}, --用户金币
        {name = "lmoney", type = T.INT64}, --用户超级金币
    }
}

P.SVR_BRANK_BROADCAST              = 0x6003   --广播庄家id
SERVER[P.SVR_BRANK_BROADCAST] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT}, --用户id
    }
}

P.SVR_SEND_BASES_TO_USER_BROADCAST              = 0x7001   --向特定用户发送可翻倍的数值列表
SERVER[P.SVR_SEND_BASES_TO_USER_BROADCAST] = {
    ver = 1,
    fmt = {
        {name = "mount", type = T.INT}, --数量
        {name = "bases", type = T.ARRAY,fixedLengthParser = "mount",fixedLength = 0,
            fmt = {
                {type = T.INT},   --倍数
            }
        },
        {name = "time", type = T.INT}, --超时时间
    }
}




P.SVR_SEND_USER_CARD              = 0x4001   --发送用户的牌信息
SERVER[P.SVR_SEND_USER_CARD] = {
    ver = 1,
    fmt = {
        {name = "mount", type = T.SHORT}, --牌的数量
        {name = "cards", type = T.ARRAY,fixedLengthParser = "mount",fixedLength = 0,
            fmt = {
                {type = T.BYTE},   --牌
            }
        },
    }
}



P.SVR_BEGIN_QIANFGZHUANG_BROADCAST              = 0x6015   --广播开始抢庄（返回）
SERVER[P.SVR_BEGIN_QIANFGZHUANG_BROADCAST] = {
    ver = 1,
    fmt = {
        {name = "mount", type = T.INT}, --数量
        {name = "ids", type = T.ARRAY,fixedLengthParser = "mount",fixedLength = 0,
            fmt = {
                {type = T.INT},   --用户id
            }
        },
        {name = "time", type = T.INT}, --抢庄超时时间
    }
}



P.SVR_LOGIN_ROOM_BAIREN                = 0x21001   --登陆房间返回
SERVER[P.SVR_LOGIN_ROOM_BAIREN] = {
    ver = 1,
    fmt = {
        {name = "ret", type = T.INT,cache=1}, --返回码
        {name = "content", type = T.ARRAY,request="ret",requestValue=0,fixedLength = 1,
            fmt = {
                {name = "zid", type = T.INT}, --桌子id
                {name = "sversion", type = T.INT}, --服务器版本
                {name = "allmoney", type = T.INT}, --当前总奖池
                {name = "usergold", type = T.INT64}, --用户金币
                {name = "zhuangid", type = T.INT}, --庄家id
                {name = "waitshang", type = T.INT}, --待上庄人数
                {name = "shanggold", type = T.INT}, --上庄时的金币
                {name = "zhuanggold", type = T.INT64}, --庄家的金币
                {name = "zhuanginfo", type = T.STRING}, --庄家的信息
                {name = "starttime", type = T.INT}, --当前桌子开始的时间
                {name = "zstatus", type = T.INT,cache=1}, --桌子状态
                {name="status2",type = T.ARRAY,request ="zstatus",requestValue=2, fixedLength = 1,
                    fmt = {
                        {name = "leftxiagold", type = T.INT}, --本桌剩余下注额
                        {name = "seatmount", type = T.INT}, --桌子座位数
                        {name="seatinfo",type=T.ARRAY,fixedLengthParser = "seatmount",fixedLength = 0,
                            fmt = {
                                {name="seat",type = T.INT},   --第几个座位
                                {name="seatmoney",type = T.INT},   --当前座位总下注数
                                {name="mymoney",type = T.INT},   --当前座位总下注数
                                {name="cards",type = T.ARRAY,fixedLength = 5,
                                    fmt = {
                                        {type =T.BYTE} --牌
                                    }
                                }
                             }
                        }
                    },
                },
                {name="status3",type = T.ARRAY,request ="zstatus",requestValue=3, fixedLength = 1,
                    fmt = {
                        {name = "seatmount", type = T.INT}, --桌子座位数
                        {name="seatinfo",type=T.ARRAY,fixedLengthParser = "seatmount",fixedLength = 0,
                            fmt = {
                                {name="seat",type = T.INT},   --第几个座位
                                {name="cardkind",type = T.INT},   --牌的类型
                                {name="cards",type = T.ARRAY,fixedLength = 5,
                                    fmt = {
                                        {type =T.BYTE} --牌
                                    }
                                }
                             }
                        }
                    },
                }
            },

        }, --内容
    }

}

P.SVR_LOGIN_ROOM                = 0x1007    --登陆房间返回
SERVER[P.SVR_LOGIN_ROOM] = {
    ver = 1,
    fmt = {
        {name = "base", type = T.INT}, --砥柱
        {name = "table_kind", type = T.SHORT}, --桌子类型
        {name = "seat", type = T.INT}, --座位id
        {name = "gold", type = T.INT}, --金币
        {name = "win", type = T.INT}, --赢的次数
        {name = "lost", type = T.INT}, --输的次数
        {name = "table_status", type = T.BYTE}, --桌子状态
        {name = "bank_uid", type = T.INT}, --庄家uid
        {name = "less_time", type = T.INT}, --剩余时间
        {name = "user_status", type = T.INT}, --用户状态
        {name = "card_mount", type = T.INT}, --牌的数量
        {name = "cards", type = T.ARRAY,fixedLengthParser = "card_mount",fixedLength = 0,
            fmt = {
                {type = T.BYTE},   --牌
            }
        },
        {name = "selects_base_mount", type = T.INT}, --可选的倍数
        {name = "selects_base", type = T.ARRAY,fixedLengthParser = "selects_base_mount",fixedLength = 0,
            fmt = {
                {type = T.INT},   --倍数
            }
        },

        {name = "user_base_calltime", type = T.INT}, --用户状态calltime的叫分倍数


        {name = "user_base_waitplay", type = T.INT}, --用户状态等待出牌的叫分倍数

        {name = "user_base_waitplay_cards_mount", type = T.INT}, --用户状态等待出牌的牌的数量

        {name = "user_base_waitplay_cards", type = T.ARRAY,fixedLengthParser = "user_base_waitplay_cards_mount",fixedLength = 0,
            fmt = {
                {type = T.BYTE},   --倍数
            }
        },

        {name = "user_base_out", type = T.INT}, --用户状态出牌阶段的叫分倍数

        {name = "user_base_out_card_kind", type = T.BYTE}, --用户状态出牌阶段牌的类型

        {name = "user_base_out_cards_mount", type = T.INT}, --用户状态出牌阶段的牌的数量

        {name = "user_base_out_cards", type = T.ARRAY,fixedLengthParser = "user_base_out_cards_mount",fixedLength = 0,
            fmt = {
                {type = T.BYTE},   --牌
            }
        },


        {name = "user_mount", type = T.INT}, --用户数量

        {name = "users_info", type = T.ARRAY,fixedLengthParser = "user_mount",fixedLength = 0,
            fmt = {
                {name="o_uid",type = T.INT},   --用户id
                {name="o_seat_id",type = T.INT},   --座位id
                {name="o_user_detail",type = T.STRING},   --用户json字符串
                {name="o_user_gold",type = T.INT},   --用户金币
                {name="o_user_win",type = T.INT},   --用户赢数
                {name="o_user_lost",type = T.INT},   --用户输数
                {name="o_user_status",type = T.INT},   --用户状态
                {name="o_user_base_calltime",type = T.INT},   --用户倍数
                {name="o_user_base_waitplay",type = T.INT},   --用户倍数
                {name="o_user_base_waitplay_cards_mount",type = T.INT},   --用户 牌数量
                {name="o_user_base_out",type = T.INT},   --用户倍数
                {name="o_user_base_out_cards_cardkind",type = T.BYTE},   --用户牌型
                {name="o_user_base_out_cards_mount",type = T.INT},   --用户牌数量
                {name = "o_user_base_out_cards", type = T.ARRAY,fixedLengthParser = "o_user_base_out_cards_mount",fixedLength = 0,
                    fmt = {
                        {type = T.BYTE},   --牌
                    }
                },
                {name="o_user_if_outline",type = T.BYTE},   --用户是否掉线

            }
        },

    }
}

P.SVR_LOGIN_ROOM_BROADCAST                = 0x100D   --登陆房间广播
SERVER[P.SVR_LOGIN_ROOM_BROADCAST] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT}, --用户id
        {name = "seat_id", type = T.INT}, --用户座位ID
        {name = "user_info", type = T.STRING}, --用户Json串
        {name = "user_gold", type = T.INT}, --用户金币
        {name = "user_win", type = T.INT}, --用户赢局数
        {name = "user_lost", type = T.INT}, --用户输局数

    }
}


P.SVR_READY_TIME                = 0x6009   --广播牌局可以开始准备
SERVER[P.SVR_READY_TIME] = {
    ver = 1,
    fmt = {
        {name = "time", type = T.INT}, --准备超时时间

    }
}


P.SVR_QUICK_SUC               = 0x1008   --用户自己退出成功
SERVER[P.SVR_QUICK_SUC] = {
    ver = 1,
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
        {name = "time", type = T.INT},
        {name = "round", type = T.INT},
        {name = "round_total", type = T.INT}
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

--请求获取筹码返回
P.SVR_GET_CHIP                = 0x906
SERVER[P.SVR_GET_CHIP] = {
    ver = 1,
    fmt = {
        {name = "ret", type = T.INT}, --成功与否标注，0失败
        {name = "chip", type = T.INT}, --兑换筹码数
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
--心跳
P.CLISVR_HEART_BEAT              = 0x0110    --server心跳包

--解散房间相关
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

--文字聊天相关
P.CLI_MSG_FACE                 =0x1104
CLIENT[P.CLI_MSG_FACE]={
    ver=1,
    fmt={
        {name="type",type=T.INT},
    }

}

P.SVR_MSG_FACE                 =0x1104
SERVER[P.SVR_MSG_FACE]={
    ver=1,
    fmt={
        {name="uid",type=T.INT},
        {name="type",type=T.INT}
    }

}




--广播玩家IP
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


return HALL_SERVER_PROTOCOL