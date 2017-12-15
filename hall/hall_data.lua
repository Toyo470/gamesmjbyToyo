cct = cct or {}
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

local Hall_data = class("class")

local game_id = 4
local game_code = "majiang"


function Hall_data:init()
	-- body
	self:init_queryScoreSection()
end

function Hall_data:getGameID()
    return game_id
end
function Hall_data:getGameCode()
    return game_code
end

--查询游戏分场进入区间
function Hall_data:init_queryScoreSection()
 	if USER_INFO["landlord_section"] == nil then
	    cct.createHttRq({
	        url=HttpAddr .. "/game/queryScoreSection",
	        date = {},
	        type_="POST",
	        callBack = function(data)
	        if data ~= nil then
	           local netData = data["netData"]
	            netData  = json.decode(netData)
	            local data_re = netData["data"] or {}
	            self:queryScoreSection_callBack(data_re)	        
		    end
	        end
	    })
	end
 end

--查询游戏分场进入区间返回
function Hall_data:queryScoreSection_callBack(data_re)
	local data_re_tbl = json.decode(data_re.sectionInfo)
	local landlord_section = data_re_tbl.landlord_section or {}
	USER_INFO["landlord_section"] = landlord_section
end


function Hall_data:get_queryScoreSection()
	-- body
	return USER_INFO["landlord_section"]
end

return Hall_data