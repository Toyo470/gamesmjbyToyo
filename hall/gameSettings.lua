

local targetPlatform = cc.Application:getInstance():getTargetPlatform()
local gameSettings  = class("gameSettings")

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

function gameSettings:reset()
    -- body
    gameData = {}
end

--设置游戏模式
--free 自由场
--match 比赛场
--group 组局
function gameSettings:setGameMode( mode )
    -- body
    if gameData == nil then
        gameData = {}
    end
    if mode == "group" then
        isGroup=true
        require("hall.GameData"):getGroupInfo()
    end
    gameData["gameMode"] = mode
    print("setGameMode",self:getGameMode())
end
function gameSettings:getGameMode()
    -- body
    local mode = gameData["gameMode"] or "free"
    return mode
end


local state_group = 0 --组局状态 0：未开始，1：开始游戏
function gameSettings:setGroupState(state)
    state_group = state
    if bm.Room == nil then
        bm.Room = {}
    end
    bm.Room.isStart = state
    bm.Room.start_group = state
end
-- 获取当前组局状态
function gameSettings:getGroupState()
    local state = 0
    if bm.Room and bm.Room.start_group then
        state = bm.Room.start_group
    end
    return state
end

-- 退出房间
function gameSettings:exitRoom()
    -- body
    dump(USER_INFO["activity_id"], "-----退出房间按钮，当前activityid-----")

    cct.createHttRq({
        url = HttpAddr .. "/freeGame/queryGroupGameStatus",
        date = {
            activityId = USER_INFO["activity_id"],
            interfaceType = "j"
        },
        type_= "POST",
        callBack = function(data)
            dump(data, "检查当前组局状态")
            local responseData = data.netData
            responseData = json.decode(responseData)
            local returnCode = responseData.returnCode
            if returnCode == "0" then
                local data = tonumber(responseData.data)
                -- dump(data, "检查当前组局状态")
                if data == 1 then
                    --开始组局
                    require("hall.GameTips"):showTips("提示", "", 2, "游戏已经开始，不能返回大厅")

                elseif data == 0 then
                    --创建组局
                    -- if bm.Room and bm.Room.isStart and bm.Room.isStart == 1 then -- 开始游戏
                    if state_group == 1 then
                        require("hall.GameTips"):showTips("提示", "", 2, "游戏已经开始，不能返回大厅")
                    else
                        require("hall.GameTips"):showTips("提示", "tohall", 1, "你正在房间中，是否返回大厅？")
                        bm.notCheckReload = 1
                    end
                    
                elseif data == 2 then
                    --结束组局
                    require("hall.GameTips"):showTips("提示", "tohall", 1, "当前组局已结束，是否返回大厅？")
                    bm.notCheckReload = 0
                end
            else
                require("hall.GameTips"):showTips("提示", "", 2, "游戏数据异常，不能退出房间")
            end

        end
    })
end

--解散房间
function gameSettings:disbandGroup(code)

    --查询用户当前的游戏状态来判断当前通过怎样的方式来解散组局
    cct.createHttRq({
        url = HttpAddr .. "/freeGame/queryGroupGameStatus",
        date = {
            activityId = USER_INFO["activity_id"],
            interfaceType = "j"
        },
        type_= "POST",
        callBack = function(data)
            local responseData = data.netData
            responseData = json.decode(responseData)
            local returnCode = responseData.returnCode
            if returnCode == "0" then
                local data = tonumber(responseData.data)
                local strCode = "disbandGroup"
                if code then
                    strCode = code.."_"..strCode
                end
                dump(data, "检查当前组局状态")
                if data == 1 then
                    --创建组局
                    require("hall.GameTips"):showDisbandTips("解散房间", strCode, 1, "当前已经扣除房卡，是否申请解散房间？")

                elseif data == 0 then
                    --开始组局
                    require("hall.GameTips"):showDisbandTips("解散房间", strCode, 1, "当前解散房间不需扣除房卡，是否解散？")
                    
                elseif data == 2 then
                    --结束组局
                    require("hall.GameTips"):showTips("提示", "tohall", 1, "当前组局已结束，是否返回大厅？")
                    bm.notCheckReload = 0
                end
            else
                    
            end

        end
    })

end

return gameSettings