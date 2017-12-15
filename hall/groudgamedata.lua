
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

---组局http请求相关-----------
---chenhaiquan--------------------------

local GroudGameData = class("GroudGameData")
function GroudGameData:ctor()
    --self.ddz_groud_list = {}
    self.groud_manager = nil
    self.freeGameList = {} --开场的显示数据用，有多少的低分组局
end

function GroudGameData:set_groud_manager( groud_manager )
    -- body
    self.groud_manager = groud_manager
end


--获取游戏列表
function GroudGameData:PostFreeGameList()
  --  local HttpAddr = "http://120.76.133.49/hbiInterface"
    cct.createHttRq({
            url=HttpAddr .. "/game/freeGameList",--http://120.76.133.49:80/hbiInterface/goods/queryGoodsList
            date={
            },
            type_="POST",
            callBack = function(data)
            self:freegamelistcallback(data)
         end
     })
end
function GroudGameData:freegamelistcallback( data )
    -- body
    data_netData = data.netData
    if data_netData == nil then
        return
    end
    data_netData = json.decode(data_netData)
   -- self.freeGameList = data

    if self.groud_manager ~= nil then
       self.groud_manager:set_freeGameList(data_netData.data)
    end
end

--查询用户游戏在线情况
function  GroudGameData:queryUserOnlineGameStatus(user_id)
    -- body
    --local HttpAddr = "http://120.76.133.49/hbiInterface"
    cct.createHttRq({
            url=HttpAddr .. "/game/queryUserOnlineGameStatus",--http://120.76.133.49:80/hbiInterface/goods/queryGoodsList
            date={
                userId = tonumber(user_id)
            },
            type_="POST",
            callBack = function(data)
            self:queryUserOnlineGameStatus_callback(data)
         end
     })
end

function  GroudGameData:queryUserOnlineGameStatus_callback(data)
    if data == nil then
        return
    end
    local data_netData = data.netData
    if data_netData == nil then
        return
    end
    data_netData = json.decode(data_netData)

   -- dump(data_netData)
    if data_netData.returnCode == "0" then
        local gameStatus = data_netData.data.gameStatus --为0表示没有在组局游戏中
        if self.groud_manager ~= nil then
            --print("--------------------------self.gameStatus ---",gameStatus)
            self.groud_manager:set_gamestatus(gameStatus)
        end
    end
end


---查看历史记录
function GroudGameData:viewReganizeHistory( user_id )
    -- body
     cct.createHttRq({
            url=HttpAddr .. "/viewReganizeHistory",
            date={
                userId = tonumber(user_id)
            },
            type_="POST",
            callBack = function(data)
            self:viewReganizeHistory_callback(data)
         end
     })
end

function GroudGameData:viewReganizeHistory_callback( data )
    -- body
    dump(data)
    local data_netData = data.netData
    if data_netData == nil then
        return
    end
    data_netData = json.decode(data_netData)
    dump(data_netData,"viewReganizeHistory_callback")

    if data_netData.returnCode == "0" then
        if self.groud_manager ~= nil then
            --print("--------------------------self.gameStatus ---",gameStatus)
            self.groud_manager:set_ReganizeHistory(data_netData.data)
        end
    end
end


--- 创建组局
function GroudGameData:createFreeGame(_userId,_phone,_coins,_gameId,_minutes,_type,_oriCoins,_name,_level)
    -- body
    local tbl = {}
    -- tbl.userId = tostring(_userId)--用户ID
    -- tbl.phone = tostring(_phone)--电话
    -- tbl.coins = tonumber(_coins)--底注
    -- tbl.gameId = tostring(_gameId)--游戏ID
    -- tbl.minutes = tonumber(_minutes)--时长
    -- tbl["type"] =tostring(_type)--用户类型
    -- tbl.oriCoins = tonumber(_oriCoins)-- 带入筹码
    -- tbl.name = tostring(_name)--组局名称
    -- tbl.level = tonumber(_level)--level

    tbl.userId = 517--用户ID
    tbl.phone = tostring("13710015758")--电话
    tbl.coins = 100--底注
    tbl.gameId = "1"--游戏ID
    tbl.minutes = 5--tonumber(_minutes)--时长
    tbl["type"] ="P"--tostring(_type)--用户类型
    tbl.oriCoins = 2000--tonumber(_oriCoins)-- 带入筹码
    tbl.name ="chen" --tostring(_name)--组局名称
    tbl.level = 110--tonumber(110)--level

     cct.createHttRq({
            url=HttpAddr .. "/createFreeGame",
            date= tbl,
            type_="POST",
            callBack = function(data)
            self:createFreeGame_callback(data)
         end
     })


end

function GroudGameData:createFreeGame_callback( data )
    -- body
    --dump(data)
    local data_netData = data.netData
    if data_netData == nil then
        return
    end
    data_netData = json.decode(data_netData)
    dump(data_netData,"createFreeGame_callback")
    print("------createFreeGame_callback----------")
    if data_netData.returnCode == "0" then
    end


--创建组局成功格式
  --   --
  --   {
  -- "data": {
  --   "activityName": "chen",
  --   "chatRoomId": "222814290472600004",
  --   "coins": 100,
  --   "creatorId": "517",
  --   "creatorNickname": "可乐",
  --   "creatorPhotoUrl": "http://hbirdtest.oss-cn-shenzhen.aliyuncs.com/2667e39c-1434-4f47-9b2b-3b65937f7ae8.jpg",
  --   "gameActivityId": "963",
  --   "gameCode": "ddz",
  --   "gameId": "1",
  --   "gameName": "斗地主",
  --   "gamePhoto": "http://hbirdtest.oss-cn-shenzhen.aliyuncs.com/game27gamePhoto20160530152059.jpg",
  --   "inviteCode": "044218",--邀请码
  --   "level": 110,
  --   "minutes": 5,
  --   "oriCoins": 2000,
  --   "players": [
  --     {
  --       "drawRounds": 0,
  --       "loseRounds": 0,
  --       "nickName": "可乐",
  --       "nowCoins": 2000,
  --       "oriCoins": 2000,
  --       "photoUrl": "http://hbirdtest.oss-cn-shenzhen.aliyuncs.com/2667e39c-1434-4f47-9b2b-3b65937f7ae8.jpg",
  --       "status": 0,
  --       "userId": "517",
  --       "winRounds": 0
  --     }
  --   ],
  --   "startDate": 1469442794580,
  --   "status": 0,
  --   "tableId": 1441792001
  -- },
  -- "returnCode": "0"
--}

end





--startFreeGame ---如果上面成功的话，就掉这个，这个成功的话，就进游戏
--从邀请码方似进入

function GroudGameData:startFreeGame( ... )
    -- body
    cct.createHttRq({
            url=HttpAddr .. "/startFreeGame",
            date= tbl,
            type_="POST",
            callBack = function(data)
            self:startFreeGame_callback(data)
         end
     })
end

function GroudGameData:startFreeGame_callback( data )
    -- body
    if data.returnCode == "0" then
        print("加入组局成功-------------------------")
        --切换到游戏场景
    else
        print("加入组局失败------------------------")
    end

end

return GroudGameData