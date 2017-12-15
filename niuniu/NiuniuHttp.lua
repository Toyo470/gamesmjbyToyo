local NiuniuHttp  = class("NiuniuHttp")
local runScene=nil

--创建http请求
function NiuniuHttp:create(strUrl,content,callback)

	printf("content size:"..table.getn(content))
	local idx = 1
	for key,value in pairs(content) do
		-- if idx == 1 then
		-- 	strUrl = strUrl.."?"..key.."="..value
		-- else
			strUrl = strUrl.."&"..key.."="..value
		-- end
		-- idx = idx + 1
	end

	--url = url.."&m="..m.."&p="..p
	local req = network.createHTTPRequest(callback,strUrl,"GET")

	req:setTimeout(30)
	req:start()
end

function NiuniuHttp:setScene( scene )
	-- body
	runScene=scene
end
--请求游戏人数
function NiuniuHttp:loadGame(uid,token,type)
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
		printf("HallHttpNet:loadGame-->"..strResponse)
		USER_INFO["user_info"] = strResponse
		local gameList  = json.decode(strResponse)
		-- printf("------")
		--dump(strResponse)
		--print_lua_table(gameList)
		-- printf(strResponse["data"])niuniun.niuniunScene
		local data = gameList["data"]
		local tbData = {}
		tbData["level"] = data["level"]
		tbData["nickName"] = data["nickName"]
		tbData["photoUrl"] = data["photoUrl"]
		tbData["sex"] = data["sex"]
		USER_INFO["user_info"] = data["level"]
		USER_INFO["user_info"] = json.encode(tbData)
		
		printf("current scene:"..SCENENOW['name'])
		--dump(SCENENOW["scene"])
		SCENENOW["scene"]:HttpLoadGame(gameList["data"])
		-- cct.luataoPrint("current ZTTJ:"..SCENENOW['name'])
		-- if  SCENENOW["name"] == "niuniun.niuniunScene" then
			
		-- 	dump(SCENENOW["scene"])
		-- 	SCENENOW["scene"]:HttpLoadGame(gameList["data"])
		-- end
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

--请求自由场赛场人数
function NiuniuHttp:FreeloadBattles(battleid)
	
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
		runScene:HttpFreeLoadBattles(gameList["data"])
		-- if  SCENENOW["name"] == "ddz.SelectChip" then
		-- 	SCENENOW["scene"]:HttpFreeLoadBattles(gameList["data"])
		-- end
	end
	local ta = {}
	ta["gameId"] = battleid
    local httpurl = HttpAddr .. "/game/freeMatch"
	self:create(httpurl,ta,backLand)
	return true
end

return NiuniuHttp