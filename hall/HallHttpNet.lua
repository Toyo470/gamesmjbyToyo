

require("hall.config")
local HallHttpNet  = class("HallHttpNet")


--创建http请求
function HallHttpNet:create(strUrl,content,callback,flag)

	flag = flag or false
	print("content size:"..table.getn(content))
	local idx = 1
	for key,value in pairs(content) do
		if flag then
			if idx == 1 then
				strUrl = strUrl.."?"..key.."="..value
			else
				strUrl = strUrl.."&"..key.."="..value
			end
		else
			strUrl = strUrl.."&"..key.."="..value
		end
		idx = idx + 1
	end

	--url = url.."&m="..m.."&p="..p
	local req = network.createHTTPRequest(callback,strUrl,"GET")

	req:setTimeout(5)
	req:start()
end

--获取游戏列表
function HallHttpNet:land()

	local function backLand(event)

		local request = event.request

		--当为completed表示正常结束此事件，否则返回
		if event.name ~= "completed" then
			return
		end

		local code = request:getResponseStatusCode()

		-- 请求成功
		if code ~= 200 then
			print("http request success code:%d",code)
			return
		end

		local strResponse = string.trim(request:getResponseString())

		--获取游戏列表
		local gameList  = json.decode(strResponse)
		dump(gameList, "-----服务器返回的游戏列表-----")

		--当前场景
		print("当前场景:" .. SCENENOW["name"])

		--添加游戏列表
		require("hall.GameList"):loadGameList(gameList["data"])

		--生成游戏列表
		dump("", "-----获取游戏列表成功，生成游戏列表调用-----")
		if SCENENOW["scene"].showGameList then
			SCENENOW["scene"]:showGameList()
		end
		-- print(SCENENOW["name"],"zzzzzzzzzzzzzzzzzz")
		--获取玩家组局状态(检查用户游戏状态，进行重连)
		dump("", "-----获取游戏列表成功，检查重连-----")
    	require("hall.groudgamemanager"):requestGroupStatus()

		--检查当前需要更新的游戏（弃用）
		-- if SCENENOW["name"] == "hall.hallScene" and gameList then

		-- 	--重置更新标志
		-- 	require("hall.GameList"):resetUpdateList()

		-- 	--获取当前需要检查更新的游戏
		-- 	local data = require("hall.GameList"):getCurrentUpdateGame()
		-- 	dump(data,"-----当前需要检查更新的游戏-----")
		-- 	if data then
		-- 		SCENENOW["scene"]:checkGameVersion(data)
		-- 	end

		-- end

	end

	local ta = {}
	ta['platform'] = 1

	-- local targetPlatform = cc.Application:getInstance():getTargetPlatform()
 --    if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
	-- 	ta['platform'] = 1

 --    elseif (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) or (cc.PLATFORM_OS_MAC == targetPlatform) then
 --    	if needUpdate == true then
	-- 		ta['platform'] = 2
 --    	end
	-- else
	-- 	if needUpdate == true then
	-- 		ta['platform'] = 1
	-- 	end
 --    end

    local httpurl = HttpAddr .. "/game/hallLoading"
    dump(httpurl, "-----获取游戏列表-----")

	-- local isVerify = confilg_manager:get_verify()
 --    if isVerify then
 --    	if  SCENENOW["name"] == "hall.gameScene" then
 --    		print("当前场景:"..SCENENOW["name"])
 --    		dump(httpurl, "-----获取游戏列表,需要验证-----")
	-- 		SCENENOW["scene"]:addGameList(date)
	-- 	end
 --    else
 --    	dump(httpurl, "-----获取游戏列表,不需要验证-----")
 --    	self:create(httpurl,ta,backLand,true)
 --    end

 	self:create(httpurl, ta, backLand, true)

	return true

end

-- 苹果审核版本请求uid
function HallHttpNet:reqIosAuditingUID()
	if USER_INFO["uid"] and string.len(string.trim(USER_INFO["uid"])) > 0 then
		--print("=======》已存在uid = ",USER_INFO["uid"])
		return
	end
	USER_INFO["uid"] = cc.UserDefault:getInstance():getStringForKey("iosAuditingUID","")
	if USER_INFO["uid"] and string.len(string.trim(USER_INFO["uid"])) > 0 then
		--print("=======》2 已存在uid = ",USER_INFO["uid"])
		return
	end
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
		print("HallHttpNet:strResponse-->"..strResponse)
		-- USER_INFO["user_info"] = strResponse
		if not USER_INFO["uid"] or string.len(string.trim(USER_INFO["uid"])) <= 0 then
			USER_INFO["uid"] = strResponse
            UID = USER_INFO["uid"]
			cc.UserDefault:getInstance():setStringForKey("iosAuditingUID", USER_INFO["uid"])
		end
	end
	local ta = {}
	local httpurl = "http://hall.789youxi.com:3002/getiosuid"
	print(httpurl)
	self:create(httpurl,ta,backLand)
end
--旧的登录验证
function HallHttpNet:Verification(uid,token,type)
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
		print("HallHttpNet:loadGame-->"..strResponse)
		-- USER_INFO["user_info"] = strResponse
		local gameList  = json.decode(strResponse)
		-- print("------")
		-- dump(strResponse)
		print_lua_table(gameList)


		-- print(strResponse["data"])
		local data = gameList["data"]
		local tbData = {}
		tbData["level"] = data["level"]
		tbData["nickName"] = data["nickName"]
		tbData["photoUrl"] = data["photoUrl"]
		tbData["sex"] = data["sex"]
		tbData["money"] = data["coinAmount"]
		tbData["type"] = USER_INFO["type"]
		USER_INFO["user_info"] = json.encode(tbData)
		print_lua_table(USER_INFO)


		print("current scene:"..SCENENOW["name"])
		if  SCENENOW["name"] == "hall.hallScene" then
			SCENENOW["scene"]:PHPLogin(gameList["data"])
		end
	end
	print("uid:"..uid)
	print("token:"..token)
	print("type:"..type)
	local ta = {}
	ta['userid'] = uid
	ta['token'] = token
	ta['type'] = type
	USER_INFO["token"]=token

	local addr = phpLoginAddr .. "/cgi?new=1&mod=user&act=login"
	print(addr)
	self:create(addr,ta,backLand)
	return true
end

--请求PHP登录验证
function HallHttpNet:PHPLogin(uid,token,type)

    local httpurl = require("hall.GameData"):getVerificationAddr()
    print("请求地址：",httpurl)
    print("当前登录的用户Id：",USER_INFO["uid"])
    cct.createHttRq({
		url = httpurl,
		date={
			userId = USER_INFO["uid"]
		},
		callBack=function(data)

			local gameList = json.decode(data.netData)

				dump(gameList,"-----请求PHP登录验证返回-----")

				--假如返回数据为空
				if gameList["data"] == nil then
					if  SCENENOW["name"] == "hall.hallScene" then
						SCENENOW["scene"]:HttpLogin(gameList["data"],0)
					end
					return false
				end

				--获取用户个人信息
				local data = nil
				if USER_INFO["type"] == "P" or USER_INFO["type"] == "p" then
					data = gameList["data"]["playerProfile"]
				elseif USER_INFO["type"] == "C" or USER_INFO["type"] == "c" then
					data = gameList["data"]["compereProfile"] or gameList["data"]["playerProfile"]
				end

				--假如返回数据为空
				if data == nil then
					require("hall.GameTips"):showTips("提示", "", 3, "用户数据异常，请联系客服处理")
					return
				end

				local tbData = {}
				tbData["level"] = data["level"]
				tbData["nickName"] = data["nickName"]
				tbData["photoUrl"] = data["photoUrl"]
				tbData["sex"] = data["sex"]
				tbData["money"] = data["coinAmount"]
				USER_INFO["user_info"] = json.encode(tbData)
				USER_INFO["phone"] = data["phone"]

				--是否首充
				USER_INFO["isFirstCharged"] = gameList["data"]["isFirstCharged"]
				USER_INFO["hasRedMonthCard"] = gameList["data"]["hasRedMonthCard"]
				USER_INFO["hasBlueMonthCard"] = gameList["data"]["hasBlueMonthCard"]
				USER_INFO["isGameSignIn"] = gameList["data"]["isGameSignIn"]

				USER_INFO["blueMonthCardEndDate"] = gameList["data"]["blueMonthCardEndDate"]
				USER_INFO["blueMonthCardSignInAmount"] = gameList["data"]["blueMonthCardSignInAmount"]
				USER_INFO["monthCardSignInAmount"] = gameList["data"]["monthCardSignInAmount"]
				USER_INFO["redMonthCardSignInAmount"] = gameList["data"]["redMonthCardSignInAmount"]
				USER_INFO["redMonthCardPrice"] = gameList["data"]["redMonthCardPrice"]

				print("当前场景:" .. SCENENOW["name"])

				-- if SCENENOW["name"] == "hall.hallScene" then
				-- 	SCENENOW["scene"]:HttpLogin(gameList["data"])
				-- end 

				require("hall.hallScene"):HttpLogin(gameList["data"])

		end,
		type="POST"
	})
    
	return true

end

--获取游戏重连gameid
function HallHttpNet:requestReloadGame()

	dump("", "-----请求获取游戏重连gameid-----")

    local httpurl = HttpAddr .. "/game/queryUserOnlineGameStatus"
    print("requestReloadGame user:",USER_INFO["uid"])
    cct.createHttRq({
			url=httpurl,
			date={
				userId=USER_INFO["uid"]
			},
			callBack = function(data)
				local gameList = json.decode(data.netData)
				dump(gameList, "-----请求获取游戏重连gameid返回-----")
				if gameList["data"] == nil then
					if  SCENENOW["name"] == "hall.hallScene" then
	                    require("hall.GameCommon"):landLoading(false)
	                    require("hall.GameCommon"):setLoadingProgress(100)
	                    display_scene("hall.gameScene",1)
					end
					return false
				end
				local data = gameList["data"]

				print_lua_table(data)

				print("current scene:"..SCENENOW["name"])
				if data["type"] == "R" or data["type"] == "r" then
					USER_INFO["enter_mode"] = require("hall.hall_data"):getGameID()
        			require("hall.gameSettings"):setGameMode("group")
    				require("hall.groudgamemanager"):requestGroupStatus(true)
        		else
					require("hall.HallHandle"):reloadGame(data["gameId"])
				end
			end,
			type="POST"
		})
    print(httpurl)
	return true
end

--查询用户余额
function HallHttpNet:viewAccount(user)
	local account = user or USER_INFO["uid"]
    local httpurl = HttpAddr .. "/user/viewAccount"
    print("viewAccount user:",account)
    cct.createHttRq({
			url=httpurl,
			date={
				userId=account
			},
			callBack=function(data)
				dump(data, "viewAccount")
				local gameList =json.decode(data.netData)
				--local gameList  = json.decode(xhr.response)
				dump(gameList,"viewAccount 1")
				if gameList["data"] == nil then
					require("app.HallUpdate"):enterHall()
					return false
				end
				local dataAccount = gameList["data"]

				dump(dataAccount,"dataAccount")
				if dataAccount["coinAmount"] == nil then
					require("app.HallUpdate"):enterHall()
					return false
				end
				if USER_INFO["gold"] >= dataAccount["coinAmount"] then
					self:viewAccount()
					return
				end
		        USER_INFO["gold"] = dataAccount["coinAmount"] or 1000000
		        USER_INFO["diamond"] = dataAccount["jewelAmount"] or 10000

                if SCENENOW["scene"] then
                    if _G.runScene and _G.runScene.goldUpdate  then
                        --todo
                        _G.runScene:goldUpdate()
                    else
                        SCENENOW["scene"]:goldUpdate()
                    end
                end
                local ac=cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function()
                        	require("hall.GameTips"):showTips("提示", "", 3, "充值成功!")
                    	end
                    	))
                SCENENOW["scene"]:runAction(ac)
			end,
			type="POST"
		})
    print(httpurl)
	return true
end

cct = cct or {}

--创建一个http请求
function cct.createHttRq(parm)
    local url=parm.url;
    local date=parm.date or {}
    local callBack=parm.callBack 
    local type_=parm.type_ or "POST"
    local arg=parm.arg or {}
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
        arg.net=event
        arg.netData=response
        callBack(arg)

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
    request:addRequestHeader('Content-Type:application/x-www-form-urlencoded')
    if type_=="POST" then
        for k,v in pairs(date) do
            request:addPOSTValue(k, v)
        end
    end
    request:setTimeout(30)
    -- 开始请求。当请求完成时会调用 callback() 函数
    request:start()
    return request
end

return HallHttpNet