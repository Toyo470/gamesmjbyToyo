cc.utils                = require("framework.cc.utils.init")
cc.net                  = require("framework.cc.net.init")

local targetPlatform = cc.Application:getInstance():getTargetPlatform()
local ddzSettings  = class("ddzSettings")

local tbDDZErrorCode = {
    [0] = "成功创建新连接",
    [1] = "重连成功",
    [2] = "成功踢其他玩家",
    [3] = "玩家密匙错误",
    [4] = "数据库连接错误",
    [5] = "无此房间",
    [6] = "玩家登录房间错误",
    [7] = "无房间分配",
    [8] = "没有空桌子",
    [9] = "玩家余额不足",
    [10] = "游戏策略错误",
    [11] = "未知错误",
    [12] = "黑名单",
    [13] = "玩家请求准备",
    [14] = "添加黑名单错误",
    [15] = "您当前不能进低分场",
    [16] = "等级不够",
    [17] = "等级太高",
    [18] = "经验不够",
    [19] = "经验太多",
    [20] = "比赛中退赛马上有报名错误",
    [21] = "比赛场金币不足",
    [22] = "比赛场钻石不足",
}

local gameData = {}
local gameMode = {"free","match","group"}

function ddzSettings:reset()
    -- body
    gameData = {}
end

function ddzSettings:getErrorCode( type )
    -- body
    return tbDDZErrorCode[type]
end
function ddzSettings:getDOS(seat)

    --位置的位移
    local u_seat = seat;
    if USER_INFO["seat"] == 1 then
        u_seat = 2 + seat
    elseif USER_INFO["seat"] == 2 then
        u_seat = 1 + seat
    end

    --位置调整
    if(u_seat >= 3) then
        u_seat = u_seat -3
    end

    local dos
    if u_seat==0 then
        dos = "touxiangbufen_0"
    end
    if u_seat==1 then
        dos = "touxiangbufen_1"
    end
    if u_seat==2 then
        dos = "touxiangbufen_2"
    end    
    return dos,u_seat
end


local tbMatchRank = {}
local matchData = {}
--重置比赛轮次
function ddzSettings:resetMatchRank()
    -- body
    tbMatchRank = {}
end
--比赛轮次设置
function ddzSettings:addMatchRank(level,tbRank)
    -- body
    tbMatchRank[level] = tbRank
    print("addMatchRank:",level)
end
--根据level获取轮次信息
function ddzSettings:getMatchLevelRankInfo(level)
    -- body
    if level == nil then
        return nil
    end
    return tbMatchRank[level]
end

--设置游戏模式
--free 自由场
--match 比赛场
--group 组局
function ddzSettings:setGameMode( mode )
    -- body
    if gameData == nil then
        gameData = {}
    end
    gameData["gameMode"] = mode
end
function ddzSettings:getGameMode()
    -- body
    local mode = gameData["gameMode"] or "free"
    return mode
end

--设置玩游戏次数
function ddzSettings:addGame()
    -- body
    if gameData == nil then
        gameData = {}
    end
    local modeCount = ""
    modeCount = require("hall.gameSettings"):getGameMode().."Counts"
    if gameData[modeCount] == nil then
        gameData[modeCount] = 0
    end
    gameData[modeCount] = gameData[modeCount] + 1
end
--获取玩了多少次
function ddzSettings:getGameCount()
    -- body
    local modeCount = ""
    modeCount = require("hall.gameSettings"):getGameMode().."Counts"
    local counts = gameData[modeCount] or 0
    print("getGameCount",modeCount,gameData[modeCount],counts)
    return counts
end

--请求退出游戏
function ddzSettings:requestExit()
    -- body
    local mode = require("hall.gameSettings"):getGameMode()
    if mode == "free" or mode == "group" then
        require("ddz_laizi.ddzServer"):CLI_LOGOUT_ROOM()
    elseif mode == "match" then
        require("ddz_laizi.ddzServer"):CLI_SEND_LOGOUT_MATCH(self:getMatchId())
    end
end

--设置当前比赛场id
function ddzSettings:setMatchId( id )
    -- body
    if matchData == nil then
        matchData = {}
    end
    matchData["tid"] = id
end
function ddzSettings:getMatchId( ... )
    -- body
    local id = matchData["tid"]
    return id
end
--设置当前比赛场level
function ddzSettings:setMatchLevel( level )
    -- body
    if matchData == nil then
        matchData = {}
    end
    matchData["level"] = level
end
function ddzSettings:getMatchLevel( ... )
    -- body
    local id = matchData["level"]
    return id
end
--设置位置tid
function ddzSettings:setOnlookTable(tid)
    if gameData == nil then
        gameData = {}
    end
    gameData["on_look_table"] = tid
end
function ddzSettings:getLookingTable()
    return gameData["on_look_table"]
end
--设置围观状态
---1,初始化值，玩家第一次进入
--0,非围观状态，默认值
--1，准备围观
--2，进入围观
function ddzSettings:setLookState(state)
    if gameData == nil then
        gameData = {}
    end
    gameData["look_state"] = state
end
function ddzSettings:getLookState()
    if gameData == nil or gameData["look_state"] == nil then
        return -1
    end
    return gameData["look_state"]
end

return ddzSettings