

local targetPlatform = cc.Application:getInstance():getTargetPlatform()
local ddzSettings  = class("ddzSettings")

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
--组局结束
local bEndGroup = 0
function ddzSettings:setEndGroup(state)
    bEndGroup = state
end
function ddzSettings:getGroupState()
    return bEndGroup or 1
end

return ddzSettings