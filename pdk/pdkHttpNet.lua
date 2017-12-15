local pdkHttpNet  = class("pdkHttpNet")


--创建http GET请求
function pdkHttpNet:create(strUrl,content,callback)

	local idx = 1
	for key,value in pairs(content) do
		if idx == 1 then
			strUrl = strUrl.."?"..key.."="..value
		else
			strUrl = strUrl.."&"..key.."="..value
		end
		idx = idx + 1
	end

	--url = url.."&m="..m.."&p="..p
	local req = network.createHTTPRequest(callback,strUrl,"GET")

	req:setTimeout(30)
	req:start()
end
--请求游戏人数
function pdkHttpNet:loadGame(uid,gameid)
	local function backLand( event )
		local request = event.request

		if event.name ~= "completed" then -- 當為completed表示正常結束此事件
			return
		end

		local code = request:getResponseStatusCode()
		if code ~= 200 then -- 成功
			print("http request success:"..code)
			return
		end

		local strResponse = string.trim(request:getResponseString())
		local gameList  = json.decode(strResponse)

		print_lua_table(gameList)


		if  SCENENOW["name"] == "pdk.pdkScene" then
			SCENENOW["scene"]:HttpLoadGame(gameList["data"])
		end
	end
	local ta = {}
	ta['userId'] = uid
	ta['gameId'] = gameid
    local httpurl = HttpAddr .. "/game/matchLoading"
    print("matchLoading:"..httpurl)
	self:create(httpurl,ta,backLand)
	return true
end
--请求自由场赛场人数
function pdkHttpNet:FreeloadBattles(battleid)
	local function backLand( event )
		local request = event.request

		if event.name ~= "completed" then -- 當為completed表示正常結束此事件
			return
		end

		local code = request:getResponseStatusCode()
		if code ~= 200 then -- 成功
			print("http request success")
			return
		end

		local strResponse = string.trim(request:getResponseString())
		local gameList  = json.decode(strResponse)

		print_lua_table(gameList)

		if  SCENENOW["name"] == "pdk.SelectChip" then
			SCENENOW["scene"]:HttpFreeLoadBattles(gameList["data"])
		end
	end
	local ta = {}
	ta['gameId'] = battleid
    local httpurl = HttpAddr .. "/game/freeMatch"
	self:create(httpurl,ta,backLand)
	return true
end
--请求比赛场赛场人数
function pdkHttpNet:MatchloadBattles(battleid)
	local function backLand( event )
		local request = event.request

		if event.name ~= "completed" then -- 當為completed表示正常結束此事件
		return
		end

		local code = request:getResponseStatusCode()
		if code ~= 200 then -- 成功
		print("http request success")
		return
		end

		local strResponse = string.trim(request:getResponseString())
		local gameList  = json.decode(strResponse)

		print("=================================neo")
		print_lua_table(gameList["data"]["roomList"])

	    for i, v in ipairs(gameList["data"]["roomList"]) do
	        if v["level"] ~= nil and v["fee"] ~= nil then
	            --设置等级轮次
	            local tbRank = {}
	            for j, v in ipairs(v["playerGoons"]) do
	                tbRank[j] = v["playerCount"]
	            end
	            require("pdk.pdkSettings"):addMatchRank(v["level"],tbRank)
	        end
	    end

		if  SCENENOW["name"] == "pdk.SelectChip" then
			SCENENOW["scene"]:HttpMatchLoadBattles(gameList["data"])
		end

		--重连，直接进入游戏界面
		if  SCENENOW["name"] == "pdk.gameScene" then
			SCENENOW["scene"]:HttpMatchLoadBattles()
		end
	end
	local ta = {}
	ta['gameId'] = battleid
    local httpurl = HttpAddr .. "/game/matchGame"
	self:create(httpurl,ta,backLand)
	return true
end


--比赛中报名
--gameid：游戏ID
--uid：用户ID
function pdkHttpNet:applyGameAwardPool()
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
            local strPost = "gameId=1".."&userId="..tostring(UID).."&userType="..USER_INFO["type"]
            xhr:send(strPost)
            print("applyGameAwardPool ==>"..strPost)
end


--比赛中报名
--gameid：游戏ID
--uid：用户ID
function pdkHttpNet:applyGameAwardPool()
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
	local strPost = "gameId=1".."&userId="..tostring(UID).."&userType="..USER_INFO["type"]
	xhr:send(strPost)
	print("applyGameAwardPool ==>"..strPost)
end

--请求比赛奖励配置
function pdkHttpNet:requestIncentive( matchLevel )
	-- body
    local url= HttpAddr .. "/game/queryGameMatchAwardByCondition"
    local date={
    gameId=1,
    level=matchLevel
}
    local type_= "POST"
    -- body
    local function reqCallback(event)
        -- body
        local ok = (event.name == "completed")
        local request = event.request
     
        if not ok then
            -- 请求失败，显示错误代码和错误消息
            print(request:getErrorCode(), request:getErrorMessage())
            return
        end

     
        local code = request:getResponseStatusCode()
        if code ~= 200 then
            -- 请求结束，但没有返回 200 响应代码
            print("getHttp error",url)
            return
        end
     
        -- 请求成功，显示服务端返回的内容
        local response = request:getResponseString()
        print(response)
        local data = json.decode(response)
        print_lua_table(data)
        require("pdk.MatchSetting"):setIncentive(data)

        --xpcall(callBack, cct.runErrorScene,arg)
        --callBack(json.decode(response))

    end
    if type_=="GET" then
        local str="?"
        for k,v in pairs(date) do
            str=str..k.."="..v.."&"
        end
        url=url..str
    end

    local request = network.createHTTPRequest(reqCallback, url, type_)
    -- request:addRequestHeader('Content-Type:application/x-www-form-urlencoded')
    if type_=="POST" then
        for k,v in pairs(date) do
            request:addPOSTValue(k, v)
        end
        print_lua_table(date)
    end
    request:setTimeout(30)
    -- 开始请求。当请求完成时会调用 callback() 函数
    request:start()
    return request
end

return pdkHttpNet