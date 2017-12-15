

local HttpNet  = class("HttpNet")
--local url      = "http://192.168.100.117:8080/hbiInterface/game/hallLoading"

--创建http请求
function HttpNet:create(strUrl,content,callback)

	for key,value in pairs(content) do
		strUrl = strUrl.."&"..key.."="..value
	end

	--url = url.."&m="..m.."&p="..p
	local req = network.createHTTPRequest(callback,strUrl,"GET")

	req:setTimeout(30)
	req:start()
end

--登陆和注册
function HttpNet:land()

	local function backLand( event )
		local request = event.request

		if event.name ~= "completed" then -- 當為completed表示正常結束此事件
		    return
		end
		 
		local code = request:getResponseStatusCode()
		if code ~= 200 then -- 成功
			printf("http request success code:%d",code)
		    return
		end
		 
		local strResponse = string.trim(request:getResponseString())
		print("response:"..strResponse)
		local gameList  = json.decode(strResponse)

		if  SCENENOW["name"] == "hall.Hall" then
			SCENENOW["scene"]:loadGame(gameList["data"])
		end
	end
	local ta = {}
	self:create("http://192.168.100.117:8080/hbiInterface/game/hallLoading",ta,backLand)
	return true
end

function gGetIntPart(x)
	if x <= 0 then
		return math.ceil(x);
	end

	if math.ceil(x) == x then
		x = math.ceil(x);
	else
		x = math.ceil(x) - 1;
	end
	return x;
end

function getIntPart(x)
	if x <= 0 then
		return math.ceil(x);
	end

	if math.ceil(x) == x then
		x = math.ceil(x);
	else
		x = math.ceil(x) - 1;
	end
	return x;
end
--格式化金币
function HttpNet:formatGold(gold)

	gold = tonumber(gold)
	if(gold<1000) then
		return gold
	elseif gold >=1000 and  gold< 10000 then
		local k = getIntPart(gold/1000)
		local lest = gold%1000
		if lest < 100 then 
			lest = '0'..lest
		elseif lest < 10 then
			lest = '00'..lest
		end
		return k.."."..lest.."k"
	elseif 	gold>=10000 and gold< 100000000 then
		local w = getIntPart(gold/10000)
		local lest = getIntPart(gold%10000/1000)

		return w.."."..lest.."w"
	else
		local w    = getIntPart(gold/100000000)
		local lest = getIntPart(gold%100000000/10000000)

		return w.."."..lest.."b"
	end

end


return HttpNet