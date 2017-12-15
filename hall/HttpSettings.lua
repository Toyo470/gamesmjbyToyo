

local HttpSettings  = class("HttpSettings")


--更新段位积分
--gameid：游戏ID
--uid：用户ID
--result：0：输，1：赢，2：平
function HttpSettings:UpdateDanPoint(gameid,result)
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    local httpurl = HttpAddr .. "/game/updateDanPoint"
    -- httpurl = "http://192.168.100.144:8080/hbiInterface/game/updateDanPoint"
    xhr:open("POST", httpurl)
    local function onReadyStateChange()
        if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
            print(xhr.response.."HttpSettings:UpdateDanPoint")
        else
            print("xhr.readyState is:", xhr.readyState, "xhr.status is: ",xhr.status)
        end
    end
    xhr:registerScriptHandler(onReadyStateChange)
    local strPost = "gameId="..tostring(gameid).."&userId="..tostring(USER_INFO["uid"]).."&result="..tostring(result).."&userType=".."P"
    xhr:send(strPost)
    print("UpdateDanPoint ==>"..strPost)
end

--比赛报名分成
--matchID：从后台返回的比赛场列表中获取
--cost：比赛报名费
function HttpSettings:gameMatchExtract(gameid,matchID,cost)
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    local httpurl = HttpAddr .. "/game/signUpGameMatch"
    -- httpurl = "http://192.168.100.101/hbiInterface/game/signUpGameMatch"
    print(httpurl)
    xhr:open("POST", httpurl)
    -- xhr:open("POST", "http://192.168.100.118/hbiInterface/game/gameMatchExtract")
    local function onReadyStateChange()
        if xhr.readyState == 4 and (xhr.status >= 0 and xhr.status < 207) then
            print(xhr.response)
        else
            print("xhr.readyState is:", xhr.readyState, "xhr.status is: ",xhr.status)
        end
    end
    xhr:registerScriptHandler(onReadyStateChange)
    local strPost = "gameId="..tonumber(gameid).."&gameMatchId="..tostring(matchID).."&userId="..USER_INFO["uid"].."&userType="..USER_INFO["type"].."&totalIncome="..math.modf(cost)
    xhr:send(strPost)
    print("gameMatchExtract ==>"..strPost)
end

--自由场分成,只有在玩家赢分的情况下才发送请求
--gameid,游戏id
--totalIncome,总收入,没扣台费的赢分
--extractIncome,分成收入
function HttpSettings:quickGameExtract(gameid,totalIncome,extractIncome)
    -- body
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    local httpurl = HttpAddr .. "/game/quickGameExtract"
    print(httpurl)
    xhr:open("POST", httpurl)
    -- xhr:open("POST", "http://192.168.100.118/hbiInterface/game/quickGameExtract")
    local function onReadyStateChange()
        if xhr.readyState == 4 and (xhr.status >= 0 and xhr.status < 207) then
            print(xhr.response)
        else
            print("xhr.readyState is:", xhr.readyState, "xhr.status is: ",xhr.status)
        end
    end
    xhr:registerScriptHandler(onReadyStateChange)
    local strPost = "quickGameId="..tonumber(gameid).."&totalIncome="..tostring(math.modf(totalIncome)).."&extractIncome="..tostring(math.modf(extractIncome))
    xhr:send(strPost)
    print("quickGameExtract ==>"..strPost)
end

--比赛中报名
--gameid：游戏ID
--uid：用户ID
function HttpSettings:applyGameAwardPool()
            local xhr = cc.XMLHttpRequest:new()
            xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    local httpurl = HttpAddr .. "/game/gameMatchExtract"
            xhr:open("POST", httpurl)
            -- xhr:open("POST", "http://192.168.100.118/hbiInterface/game/applyGameAwardPool")
            local function onReadyStateChange()
                if xhr.readyState == 4 and (xhr.status >= 0 and xhr.status < 207) then
                    print(xhr.response)
                else
                    print("xhr.readyState is:", xhr.readyState, "xhr.status is: ",xhr.status)
                end
            end
            xhr:registerScriptHandler(onReadyStateChange)
            local strPost = "gameId=1".."&userId="..USER_INFO["uid"].."&userType="..USER_INFO["type"]
            xhr:send(strPost)
            print("applyGameAwardPool ==>"..strPost)
end


--比赛中报名
--gameid：游戏ID
--uid：用户ID
function HttpSettings:applyGameAwardPool()
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    -- xhr:open("POST", "http://120.25.216.48:8080/hbiInterface/game/gameMatchExtract")
    local httpurl = HttpAddr .. "/game/applyGameAwardPool"
    xhr:open("POST", httpurl)
    local function onReadyStateChange()
        if xhr.readyState == 4 and (xhr.status >= 0 and xhr.status < 207) then
            print(xhr.response)
        else
            print("xhr.readyState is:", xhr.readyState, "xhr.status is: ",xhr.status)
        end
    end
    xhr:registerScriptHandler(onReadyStateChange)
    local strPost = "gameId=1".."&userId="..USER_INFO["uid"].."&userType="..USER_INFO["type"]
    xhr:send(strPost)
    print("applyGameAwardPool ==>"..strPost)
end

return HttpSettings