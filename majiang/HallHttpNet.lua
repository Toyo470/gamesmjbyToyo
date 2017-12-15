

local HallHttpNet  = class("HallHttpNet")


--创建http请求
function HallHttpNet:create(strUrl,content,callback)

	printf("content size:"..table.getn(content))
	local idx = 1
	for key,value in pairs(content) do
--		if idx == 1 then
--			strUrl = strUrl.."?"..key.."="..value
--		else
			strUrl = strUrl.."&"..key.."="..value
--		end
--		idx = idx + 1
	end

	--url = url.."&m="..m.."&p="..p
	local req = network.createHTTPRequest(callback,strUrl,"GET")

	req:setTimeout(30)
	req:start()
end

--请求PHP登录验证
function HallHttpNet:PHPLogin(uid,token,type)
	local function backLand( event )
		local request = event.request

		if event.name ~= "completed" then -- 當為completed表示正常結束此事件
			return
		end

		local code = request:getResponseStatusCode()
		if code ~= 200 then -- 成功
			printf("http request success:"..code)
			return
		end

		local strResponse = string.trim(request:getResponseString())
		printf("HallHttpNet:PHPLogin-->"..strResponse)
		-- USER_INFO["user_info"] = strResponse
		local gameList  = json.decode(strResponse)
		-- printf("------")
		-- dump(strResponse)
		print_lua_table(gameList)
		-- printf(strResponse["data"])
		print("HallHttpNet:PHPLogin current scene:"..SCENENOW["name"])


		if  SCENENOW["name"] == "majiang.majiangScene" then
			SCENENOW["scene"]:PHPLogin(gameList["data"])
		end
	end
	printf("uid:"..uid)
	printf("token:"..token)
	printf("type:"..type)
	local ta = {}
	ta['userid'] = uid
	ta['token'] = token
	ta['type'] = type
	-- self:create("http://120.25.221.194/cgi?mod=user&act=login",ta,backLand)
	self:create("http://119.29.149.157/cgi?new=1&mod=user&act=login",ta,backLand)
	-- self:create("http://120.25.221.194/cgi?new=1&mod=user&act=login",ta,backLand)
	return true
end

--请求比赛场赛场人数
function HallHttpNet:MatchloadBattles(battleid)
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
	            require("majiang.ddzSettings"):addMatchRank(v["level"],tbRank)
	        end
	    end

		--重连，直接进入游戏界面
		if  SCENENOW["name"] == "majiang.scenes.MajiangroomScenes" then
			SCENENOW["scene"]:HttpMatchLoadBattles()
		end
	end
	local ta = {}
	ta['gameId'] = battleid
    local httpurl = HttpAddr .. "/game/matchGame"
   	print("httpurl----------",httpurl)
	self:create(httpurl,ta,backLand)
	return true
end

--请求比赛奖励配置
function HallHttpNet:requestIncentive( matchLevel )
	-- body
	--matchLevel = 61

    local url= HttpAddr .. "/game/queryGameMatchAwardByCondition"
    local date={
			    gameId=4,
			    level=matchLevel
	}
	print("url---------------------",url)
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
        dump(data,"majiang httpcall")
        require("majiang.MatchSetting"):setIncentive(data)

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


return HallHttpNet