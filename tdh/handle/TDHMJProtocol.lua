--
-- Author: LeoLuo                             
-- Date: 2015-05-09 10:03:08
--
-- 推倒胡麻将版本，删除了部分没有用到的协议

local T = bm.PACKET_DATA_TYPE
local P = {}

local TDHMJ_SERVER_PROTOCOL = P
P.CONFIG = {}
P.CONFIG.CLIENT = {}
P.CONFIG.SERVER = {}
local CLIENT = P.CONFIG.CLIENT
local SERVER = P.CONFIG.SERVER

----------------------------------------------------------------
------------------------- 客户端请求  --------------------------
----------------------------------------------------------------

--表情聊天相关
P.CLI_MSG_FACE                 =0x1004
CLIENT[P.CLI_MSG_FACE]={
    ver=1,
    fmt={
        {name="type",type=T.INT},
    }

}

--请求退出房间
P.CLI_QUIT_ROOM                     = 0x1002    
CLIENT[P.CLI_QUIT_ROOM] = {
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

--用户请求操作
P.CLI_REQUEST_HANDLE                      = 0x2004    
CLIENT[P.CLI_REQUEST_HANDLE] = {
    ver = 1,
    fmt = {
        {name = "handle", type = T.INT},  --操作
        {name = "card", type = T.BYTE},  --牌
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



--用户发送准备 8193
P.CLI_READYNOW_ROOM                     = 0x2001    
CLIENT[P.CLI_READYNOW_ROOM] = {
    ver = 1,
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

--用户请求加飘
P.CLI_REQUEST_JIAPIAO                      = 0x2015    
CLIENT[P.CLI_REQUEST_JIAPIAO] = {
    ver = 1,
    fmt = {
        {name = "jiapiao", type = T.BYTE},
    }

}
-----------------------------------------------------------
-------------------  服务端返回  --------------------------
-----------------------------------------------------------


-----------------------------------------界面功能相关--------------------------------
-- 发送听牌信息
P.SVR_TING_INFO             = 0x101B
SERVER[P.SVR_TING_INFO] = {
    ver = 1,
    fmt={
        {name="opeCode",type=T.INT},
        {name="tingCount",type=T.INT},
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
    }
}

--广播用户IP
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

--表情聊天相关
P.SVR_MSG_FACE                 =0x1004
SERVER[P.SVR_MSG_FACE]={
    ver=1,
    fmt={
        {name="uid",type=T.INT},
        {name="type",type=T.INT}
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

P.CLI_REQUEST_SEND_POSITION                      = 0x2016    
CLIENT[P.CLI_REQUEST_SEND_POSITION] = {
    ver = 1,
    fmt = {
        {name = "latitude", type = T.STRING},
        {name = "longitude", type = T.STRING},
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


--玩家进入私人房
P.SVR_ENTER_PRIVATE_ROOM                  = 0x0212
SERVER[P.SVR_ENTER_PRIVATE_ROOM] =  {
    ver = 1,
    fmt = {
        {name = "flag", type = T.SHORT},
        {name = "ret", type = T.SHORT}
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

--用户退出游戏成功
P.SVR_QUICK_SUC               = 0x1008   
SERVER[P.SVR_QUICK_SUC] = {
    ver = 1,
}

--广播结束游戏 --没用
P.SVR_GAME_OVER = 0x4009 
SERVER[P.SVR_GAME_OVER] = {
    ver = 1,
    fmt={
        {name = "userdate", type = T.ARRAY,fixedLength = 4,
            fmt={
                {name="userid",type=T.INT},--用户id
                {name="gold",type=T.INT},--用户本轮金币变化
                {name="cgold",type=T.INT},--用户当前金币数
                {name="userstate",type=T.SHORT},--用户状态 在线=1，离线=0
            }
        }
        
    }
}

-- --通知漫游
-- P.SVR_MANYOU               = 0x4010   
-- SERVER[P.SVR_MANYOU] = {
--     ver = 1,
-- }

----------------------------------------用户操作相关-------------------------------------------

--当前抓牌用户广播
P.SVR_PLAYING_UID_BROADCAST                = 0x4006    
SERVER[P.SVR_PLAYING_UID_BROADCAST] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT}, --用户id
        {name = "if_gang", type = T.BYTE}, --0表示不是，1表示是杠，目前不知道有啥用！
        {name = "simplNum",type = T.SHORT}, --桌面剩余多少张摸牌
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
        {name = "if_piaohu", type = T.BYTE},
        -- {name = "zhanweifu", type = T.INT}, --如果是碰，杠，胡，杠胡。ID为上一个出牌用户ID
        -- {name = "zhanweifu_", type = T.SHORT},
        -- {name="cardNum", type = T.INT},
        -- {name="cardSet", type = T.ARRAY, fixedLengthParser = "cardNum", fixedLength = 0,
        --     fmt = {
        --         {type = T.BYTE},
        --     }
        -- },
        {name = "next_handle", type = T.INT},
        {name = "gangCardSize", type = T.INT},
        {name="gangCardSet", type = T.ARRAY, fixedLengthParser = "gangCardSize", fixedLength = 0,
            fmt = {
                {type = T.BYTE},
            }
        },

    }
}

--广播用户进行了什么操作
P.SVR_PLAYER_USER_BROADCAST_WITH_HU_TYPE                = 0x4019
SERVER[P.SVR_PLAYER_USER_BROADCAST_WITH_HU_TYPE] = {
    ver = 1,
    fmt = {
        {name = "huType", type = T.INT},
        {name = "uid", type = T.INT}, --用户id
        {name = "handle", type = T.INT}, --操作类型
        {name = "card", type = T.BYTE}, --牌
        {name = "lid", type = T.INT}, --如果是碰，杠，胡，杠胡。ID为上一个出牌用户ID
        {name = "if_piaohu", type = T.BYTE},
        -- {name = "zhanweifu", type = T.INT}, --如果是碰，杠，胡，杠胡。ID为上一个出牌用户ID
        -- {name = "zhanweifu_", type = T.SHORT},
        -- {name="cardNum", type = T.INT},
        -- {name="cardSet", type = T.ARRAY, fixedLengthParser = "cardNum", fixedLength = 0,
        --     fmt = {
        --         {type = T.BYTE},
        --     }
        -- },
        {name = "next_handle", type = T.INT},
        {name = "gangCardSize", type = T.INT},
        {name="gangCardSet", type = T.ARRAY, fixedLengthParser = "gangCardSize", fixedLength = 0,
            fmt = {
                {type = T.BYTE},
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
            fmt = {                                                --前面四个是暗杠，后面4个补杠的牌值
                {type = T.BYTE},   --牌
            }
        },
        {name = "if_gang", type = T.BYTE}, --0表示不是，1表示是杠，目前不知道有啥用！


    }
}

-- --通知用户我抓的牌
-- P.SVR_OWN_CATCH_BROADCAST                = 0x3002    
-- SERVER[P.SVR_OWN_CATCH_BROADCAST] = {
--     ver = 1,
--     fmt = {
--         {name = "card", type = T.BYTE}, --牌
--         {name = "handle", type = T.INT}, --操作
--         -- {name = "mount", type = T.BYTE}, --数量
--         {name = "cards", type = T.ARRAY,--[[fixedLengthParser = 8,]]fixedLength = 8,
--             fmt = {
--                 {type = T.BYTE},   --牌
--             }
--         },
--         {name = "if_gang", type = T.BYTE}, --0表示不是，1表示是杠，目前不知道有啥用！

--         {name = "tingCount", type = T.BYTE},            --听
--         {name = "tingCards", type = T.ARRAY, fixedLengthParser = "tingCount",fixedLength = 0, 
--             fmt = {
--                 {name = "card", type = T.BYTE},
--                 {name = "tingHuCount", type = T.BYTE},
--                 {name = "tingHuCards", type = T.ARRAY,fixedLengthParser = "tingHuCount",fixedLength = 0,
--                     fmt = {
--                         {name = "card", type = T.BYTE},--打出对应牌后，听胡的牌
--                     }
--                 },
--             }
--         },
--         {name = "lgCount", type = T.BYTE},
--         {name = "lgCards", type = T.ARRAY, fixedLengthParser = "lgCount",fixedLength = 0, 
--             fmt = {
--                 {name = "card", type = T.BYTE},
--             }
--         },
--     }
-- }

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


--用户重新登录普通房间的消息返回（4105(10进制s)）
P.SVR_REGET_ROOM               = 0x1009   
SERVER[P.SVR_REGET_ROOM] = {
    ver = 1,
    fmt = {
        {name = "from", type = T.INT}, --
        {name = "nTableType", type = T.SHORT}, --
        {name = "seat_id", type = T.SHORT}, --重连用户座位ID
        {name = "gold", type = T.INT}, --重连用户拥有金币数 
        {name = "nTingFlag", type = T.SHORT}, --   0：没有听牌 ； 1：进入听牌状态
        -- {name = "jiapiaoStatus", type = T.BYTE}, --加飘状态  0：未进行 1：进行中 2：不需要
        -- {name = "piao", type = T.BYTE}, --加飘

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
        {name = "gameStatus", type = T.INT}, -- 牌桌状态 0：游戏停止状态  1:中间停止状态 2:下注状态  3：打牌状态  4：等待操作状态   5：游戏准备停止状态

        {name = "lCount", type = T.INT}, -- 晾喜次数

        {name = "is_pao", type = T.BYTE,cache = 1},--是否叫分阶段
        {name = "users_info", type = T.ARRAY,fixedLength = 3,
                fmt = {
					-- 跑字段
					{name = "uid", type = T.INT},--其他用户信息:用户id
                    {name = "seat_id", type = T.SHORT},--其他用户信息:用户座位id
                    {name = "m_bAI", type = T.SHORT},--其他用户信息:用户是否托管
                    {name = "user_info", type = T.STRING},
                    {name = "user_gold", type = T.INT},--其他用户信息: 用户金币数量
                	{name = "paoValue", type = T.BYTE},-- 叫的跑的值   -1代表还没跑

                	{name = "isTingStatus", type = T.BYTE},-- @Brief:玩家听牌状态 @2017-1-23 @Add

					-- 打牌字段
                    {name = "nTingFlag", type = T.SHORT},--听
                    -- {name = "piao", type = T.BYTE}, --加飘
                    {name = "countHandCards", type = T.SHORT},--

                    --晾喜次数
                    {name = "lCount", type = T.INT}, 

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

        -- 听牌状态
        {name="tingStatus", type=T.BYTE},    --0：未听牌；1：已进入听牌状态 

        -- 进行听牌操作下选择出牌的列表
        {name="tingCount",type=T.INT},
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

        -- 听牌状态下的听牌列表
        {name="huCardSum",type=T.INT},
        {name="tingOutCards", type = T.ARRAY,fixedLengthParser = "huCardSum",fixedLength = 0,
            fmt={
                {name="card",type=T.BYTE},
            }
        },  

        -- {name = "gameStatus", type = T.SHORT},
        {name = "currentPlayerId", type = T.INT, request="gameStatus", requestValue = 3},
        {name = "currentPlayerId", type = T.INT, request="gameStatus", requestValue = 4},
        {name = "handle", type = T.INT, request="gameStatus", requestValue = 4},
        {name = "handleCard", type = T.BYTE, request="gameStatus", requestValue = 4},
        {name = "paoValue", type = T.BYTE},-- -1,还没跑;0,不跑;1,跑1;2,跑2
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
    }
}

--服务器告知客户端可以进行的操作 --有可能在玩家选择补杠后，其他家可以胡该牌 没用到
P.SVR_NORMAL_OPERATE = 0x3005 
SERVER[P.SVR_NORMAL_OPERATE] = {
    ver = 1,
    fmt={
        {name="handle",type=T.INT},--操作类型
        {name="card",type=T.BYTE},--操作的牌
        {name="seatId",type=T.BYTE},--操作用户座位id
    }
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
        {name = "players", type = T.ARRAY,fixedLength = 4, 
            fmt = {
                {name="uid",type   = T.INT},   --用户id
                {name="isOnline",type  = T.SHORT},   --是否胡牌
                {name="coins",type = T.INT},   --是否放炮
                {name="changeCoins", type = T.INT},
                {name="isQishou", type = T.BYTE},
                {name="isHaidi", type = T.BYTE},
                {name="remainCardsCount", type = T.INT},
                {name="remainCards", type = T.ARRAY, fixedLengthParser = "remainCardsCount",fixedLength = 0,
                    fmt = {
                        {type = T.BYTE},
                    }
                },
                {name="agCount", type = T.INT},--暗杠
                {name="agCards", type = T.ARRAY, fixedLengthParser = "agCount",fixedLength = 0,
                    fmt = {
                        {type = T.BYTE},
                    }
                },
                {name="mgCount", type = T.INT}, --明杠/碰杠次数
                {name="mgCards", type = T.ARRAY, fixedLengthParser = "mgCount",fixedLength = 0,
                    fmt = {
                        {type = T.BYTE},
                    }
                },    
                {name="bgCount", type = T.INT}, --补杠
                {name="bgCards", type = T.ARRAY, fixedLengthParser = "bgCount",fixedLength = 0,
                    fmt = {
                        {type = T.BYTE},
                    }
                },
                {name="dgCount", type = T.INT}, --点杠次数


                {name="pCount", type = T.INT},
                {name="pCards", type = T.ARRAY, fixedLengthParser = "pCount",fixedLength = 0,
                    fmt = {
                        {type = T.BYTE},
                    }
                },

                {name="liangxiCount", type = T.SHORT},

                -- {name="cCount", type = T.INT},
                -- {name="cCards", type = T.ARRAY, fixedLengthParser = "cCount",fixedLength = 0,
                --     fmt = {
                --         {type = T.BYTE},
                --     }
                -- },

                {name="huTypeCount", type = T.SHORT},
                {name="huTypes", type = T.ARRAY, fixedLengthParser = "huTypeCount",fixedLength = 0,
                    fmt = {
                        {type = T.BYTE},
                    }
                },
            }
        },
        -- {name = "birdCount", type = T.BYTE},
        -- {name = "birdCards", type = T.ARRAY, fixedLengthParser = "birdCount",fixedLength = 0, 
        --     fmt = {
        --         {name = "card", type = T.BYTE},
        --         {name = "position", type = T.BYTE},
        --     }
        -- },
        
        {name = "huCard", type = T.BYTE},
        {name = "isOver", type = T.BYTE},
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

P.CLIENT_CMD_SEND_MSG_TO_SERVER                = 0x166    --向服务器发送向组局里发送的缓存信息
CLIENT[P.CLIENT_CMD_SEND_MSG_TO_SERVER] = {
    ver = 1,
    fmt = {
        {name = "level", type = T.SHORT},   --游戏level
        {name = "msg", type = T.STRING}
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


------------------------------------解散房间相关--------------------------------------

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
------------------------------------------------------------------------------------------
return TDHMJ_SERVER_PROTOCOL
