--创建一个http请求
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

local FastStartGame  = class("FastStartGame")

function FastStartGame:ctor( )
	-- body
	
end

function FastStartGame:init(rec_coins)
	-- body
 --    local fast_game_list = USER_INFO["fast_game_list"] or {}
	-- if  table.nums(fast_game_list) > 0 then
 --        print("+++++++++++++++++++++++++++++++++++++")
 --        self:freeMatch_callBack(fast_game_list,rec_coins)
	-- else
 --        print("-------------------------------------")
	-- 	self:FreeGameData(rec_coins)
	-- end

    print("FastStartGame init")
    local code = require("hall.hall_data"):getGameCode()
    USER_INFO["gameLevel"] = 51
    require("hall.gameSettings"):setGameMode("fast")
    display_scene(code..".gameScene",1)
end

function FastStartGame:FreeGameData(rec_coins,gameid)
	-- body
    print("FreeGameData----------------------------")
	gameid = gameid or require("hall.hall_data"):getGameID()
    cct.createHttRq({
        url=HttpAddr .. "/game/freeMatch",
        date = { gameId = gameid },
        type_="POST",
        callBack = function(data)
        if data ~= nil then
           local netData = data["netData"]
            netData  = json.decode(netData)
            local gamelist = netData["data"] or {}
            dump(gamelist,"FreeGameData---gamelist")

            self:freeMatch_callBack(gamelist,rec_coins)	        
	    end
        end
    })
end

function FastStartGame:freeMatch_callBack( gamelist , rec_coins )
    if USER_INFO["fast_game_list"] == nil then
	   USER_INFO["fast_game_list"] = gamelist
    end

    local Hall_data = require("hall.hall_data")
    local level_list = Hall_data:get_queryScoreSection()
    dump(level_list,"level_list")
    local tem = 0
    for _,level_data in pairs(level_list) do
        local game_level = level_data.game_level or 0
        if game_level ~= 0 then
            if rec_coins > level_data.lower_section 
                or rec_coins == level_data.upper_section then
                    tem = game_level
            end
        end
    end
    print("tem_level--------------------",tem)
    print("rec_coins--------------------",rec_coins)
    if tem ~= 0 then
        local coins = 0
        for _,game in pairs(gamelist) do
            if tem == game.level then
        	   coins = game.coins or 0
            end
        end
        self:enterGame(coins,tem)

    else
        -- local userBrkui=require("ddz/userBroke")
        -- local u_node=userBrkui.new(222);
        -- SCENENOW["scene"]:addChild(u_node,99999)
        require("hall.GameTips"):showTips("提示","change_money",1,"你的余额已不足，去商城充值吧")
    end

end

function FastStartGame:enterGame(coins,level)
    print("coins-----------------",coins)
    if coins ~= 0 then
        local code = require("hall.hall_data"):getGameCode()
		USER_INFO["gameLevel"] = level
		require("hall.gameSettings"):setGameMode("fast")
		display_scene(code..".gameScene",1)
	end
end


return FastStartGame