local GroudGameManager = class("GroudGameManager")

---组局创建操作相关-----------
---chenhaiquan--------------------------

function GroudGameManager:ctor()
	-- self.gameStatus = ""
	-- self.ReganizeHistory = {}
	-- self.freeGameList = {}
end

--获取游戏列表
function GroudGameManager:PostFreeGameList()
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

--获取游戏列表返回
function GroudGameManager:freegamelistcallback(data)

    data_netData = data.netData
    if data_netData == nil then
        return
	end
	data_netData = json.decode(data_netData)
	local tbBaseChips = {}
	local tbLevel = {}
	local tbMinCoin = {}
	for i, v in pairs(data_netData.data) do
		if v.gameId == require("hall.hall_data"):getGameID() then
			local pos = 1
			dump(v.groupGameList, "freegamelistcallback")
			for j, k in pairs(v.groupGameList) do
				if k["status"] == "1" then
					print("group game info",k["coins"],k["level"],k["oriCoins"])
					tbBaseChips[pos] = k["coins"]
					tbLevel[pos] = k["level"]
					tbMinCoin[pos] = k["oriCoins"]
					pos = pos + 1
				end
			end
		end
	end
	require("hall.group.GroupSetting"):createGroup(tbBaseChips,tbLevel,tbMinCoin)

end

--加入组局（包括重连加入组局和使用邀请码加入组局）
function GroudGameManager:join_freegame(user_id, invitationCode, activityId, history, level, reload)

	dump(user_id, "-----加入组局入参user_id-----")
	dump(invitationCode, "-----加入组局入参invitationCode-----")
	dump(activityId, "-----加入组局入参activityId-----")
	dump(history, "-----加入组局入参history-----")
	dump(level, "-----加入组局入参level-----")
	dump(reload, "-----加入组局入参reload-----")

	--网络请求Loading
	require("hall.NetworkLoadingView.NetworkLoadingView"):showLoading("加入房间中")

	--记录是否为重连加入组局
	local enter_history = history or false
	local isReload = reload or false

	--请求加入组局结果返回
	local function joinFreeGame_callback(data)

		require("hall.NetworkLoadingView.NetworkLoadingView"):removeView()

		local netData = data.netData
		netData = json.decode(netData)
		dump(netData,"-----请求加入组局结果返回-----")
		if netData.returnCode == "0" then

			---加入组局成功
			require("hall.gameSettings"):setGameMode("group")
			USER_INFO["enter_mode"] = require("hall.hall_data"):getGameID()
			USER_INFO["GroupLevel"] = netData["data"]["level"]
			USER_INFO["enter_code"] = netData["data"]["gameCode"]
			USER_INFO["activity_id"] = netData["data"]["gameActivityId"]
			USER_INFO["invote_code"] = netData["data"]["inviteCode"]
			USER_INFO["group_chip"] = netData["data"]["oriCoins"]
			USER_INFO["gameConfig"] = netData["data"]["activityDiscription"]

			--设置需要检查重连
    		bm.notCheckReload = 0

			--记录组局创建者
			USER_INFO["group_owner"] = netData["data"]["creatorId"]

			dump("界面选择游戏的 enter_mode:" .. USER_INFO["enter_mode"] .. "，enter_code：" .. USER_INFO["enter_code"], "----------")

			--获取加入的游戏Id
			local gameId = tonumber(netData["data"]["gameId"])
			--检查需要加入的游戏是否存在或是否需要更新
			local gameList = require("hall.GameList"):getList()
			for k,v in pairs(gameList) do
				if v[1] == gameId then

					USER_INFO["enter_mode"] = v[1]
					USER_INFO["enter_code"] = v[2]

					dump("最后进入游戏的 enter_mode:" .. USER_INFO["enter_mode"] .. "，enter_code：" .. USER_INFO["enter_code"], "----------")

					bm.isInGame = true

					--通知本地退出房间
                    require("hall.util.GameUtil"):LogoutRoom()

					--标记呀呀语音进入房间
					require("hall.util.YaYaVoiceServerUtil"):LoginRoom()

					--通知本地加入房间
	                require("hall.util.GameUtil"):LoginRoom(USER_INFO["invote_code"])

					--检查本地版本号
	                local bShowMash = 0
	                if v[4] ~= "-1"  then
	                    if v[2] ~= nil then
	                        if require("hall.GameData"):getGameVersion(v[2]) == "" then
	                            --本地没有游戏
	                            if require("hall.GameUpdate"):getUpdateStatus() == 0 then
							        require("hall.GameUpdate"):queryVersionInJoinGame(v[1], v[2], 1, v[3])
							    end
	                        elseif require("hall.GameData"):compareLocalVersion(v[4],v[2]) > 0 then
	                            --本地游戏版本低
	                            if require("hall.GameUpdate"):getUpdateStatus() == 0 then
							        require("hall.GameUpdate"):queryVersionInJoinGame(v[1], v[2], 1, v[3])
							    end
	                        else
	                        	--本地游戏可用，直接进入游戏
	                        	require("hall.GameUpdate"):enterGroup(USER_INFO["enter_code"])
	                        end
	                    end
	                end
					
				end
			end

			-- 旧的检查重连，已弃用
			-- if isReload then
			-- 	dump("-----重连组局-----", "-----加入组局成功-----")
			-- 	require("hall.HallHandle"):reloadGame(USER_INFO["enter_mode"])
			-- else
			-- 	dump("-----加入组局-----", "-----加入组局成功-----")
   --  			require("hall.GameUpdate"):enterGroup(USER_INFO["enter_code"])
			-- end

		else

			if netData.error then
				require("hall.GameTips"):showTips("提示", "", 3, netData.error)
			else
				require("hall.GameTips"):showTips("提示", "", 3, "未知错误")
			end
 			
		end
	end

	--查询用户历史记录返回
	local function viewReganizeHistory_callback(data)

		--返回数据验证
		local data_netData = data.netData
	    if data_netData == nil then
	        return
	    end

	    --检查是否有未结束组局
	    local tbHistory = {}
	    data_netData = json.decode(data_netData)
	    for k,v in pairs(data_netData.data) do
	    	if v.status == nil or v.status ~= "2" then
	    		table.insert(tbHistory, v)
	    	end
	    end
	    dump(tbHistory, "-----当前用户未结束的组局-----")

	    --如果没有组局历史
	    if #tbHistory == 0 then
	    	--使用邀请码进入新组局
    		local tbl = {}
	        tbl["userId"] = user_id
	        tbl["invitationCode"] = tostring(invitationCode)
	        -- tbl["level"] = tostring(level)
	        tbl["type"] =  "P"
	        -- if activityId then
	        -- 	tbl["activityId"] = activityId
	        -- end
	        dump(tbl, "viewReganizeHistory_callback joinFreeGame", nesting)
		   	cct.createHttRq({
	            url=HttpAddr .. "/joinFreeGame",
	            date=tbl,
	            type_="POST",
	            callBack = joinFreeGame_callback
	 		})
    		return
    	end

	    --有未结束组局，进入最后一次加入的未结束组局
    	for k, v in pairs(tbHistory) do
    		if k == 1 then
    			self:join_freegame(USER_INFO["uid"], v["inviteCode"], v["activityId"], true, v["level"], true)
    			return
    		end
    	end

	end

	--检查当前用户游戏状态返回
	local function queryUserOnlineGameStatus_callback(data)

		dump(data, "-----检查当前用户游戏状态返回-----")
		if data == nil then
			require("hall.GameTips"):showTips("数据异常", "", 2, "用户游戏状态异常，请稍候再试")
	        return
	    end

	    local data_netData = data.netData
	    data_netData = json.decode(data_netData)
	    if data_netData.data.gameStatus == "0" or data_netData.data.gameStatus == "1" then

	       	cct.createHttRq({
	            url=HttpAddr .. "/viewReganizeHistory",
	            date={
	                userId = user_id
	            },
	            type_="POST",
	            callBack = viewReganizeHistory_callback
 		   })

	    else

	    	require("hall.GameTips"):showTips("数据异常", "", 2, "用户游戏状态异常，请稍候再试")

	    end

	end

	--判断是否为重连加入组局
	if enter_history then

		--重连加入组局
	    local tbl = {}
        tbl["userId"] = user_id
        tbl["invitationCode"] = tostring(invitationCode)
        tbl["activityId"] = activityId
        -- tbl["level"] = tostring(level)
        tbl["type"] = "P"
        
	        dump(tbl, "enter_history joinFreeGame", nesting)
	   	cct.createHttRq({
            url=HttpAddr .. "/joinFreeGame",
            date=tbl,
            type_="POST",
            callBack = joinFreeGame_callback
 		})

	else

		--检查用户游戏状态
		cct.createHttRq({
            url=HttpAddr .. "/game/queryUserOnlineGameStatus",
            date={
                userId = tostring(user_id)
            },
            type_="POST",
            callBack = queryUserOnlineGameStatus_callback
	    })

	end

end

--退出组局，（不是散组局）
function GroudGameManager:exitFreeGame(userId,invitationCode)
	-- body
	local tbl = {}
	tbl["type"] =  "P"
	tbl["userId"] = userId
	tbl["invitationCode"] = invitationCode

	cct.createHttRq({
            url=HttpAddr .. "/exitFreeGame",--http://120.76.133.49:80/hbiInterface/goods/queryGoodsList
            date=tbl,
            type_="POST",
            callBack = function ( data )
            	-- body
            	dump(data,"exitFreeGame")
	            local netData = data.netData
	            netData = json.decode(netData)
            	if netData.returnCode == "0" then
            	print("-------exitFreeGame-----------------")
            	--退出组局成功
            	end
            end
    })

end

--解散组局
function GroudGameManager:closeFreeGame(inviteCode,activityId,rounds)
	-- body
	local tbl = {}
	tbl["inviteCode"] =  inviteCode
	tbl["activityId"] = activityId
	tbl["rounds"] = rounds

	cct.createHttRq({
            url=HttpAddr .. "/closeFreeGame",--http://120.76.133.49:80/hbiInterface/goods/queryGoodsList
            date=tbl,
            type_="POST",
            callBack = function ( data )
            	-- body
            	dump(data,"closeFreeGame")
	            local netData = data.netData
	            netData = json.decode(netData)
            	if netData.returnCode == "0" then
            		print("-------exitFreeGame-----------------")
            		--解散组局
            	end
            end
    })

end

--查看组局记录（检查重连）
function GroudGameManager:requestGroupStatus(flag,callback)

	-- if bm.notCheckReload == 1 then
	-- 	dump("不需要检查重连", "-----查看组局记录（检查重连）-----")
	-- 	return
	-- else
	-- 	dump("检查重连", "-----查看组局记录（检查重连）-----")
	-- end

 	local enter_game = flag or false
 	local isCallback = callback or 0

 	--查看组局记录返回
	local function viewReganizeHistory_callback(data)

		--验证返回数据
		local data_netData = data.netData
	    if data_netData == nil then
	        return
	    end

	    --检查是否有未结束组局
	    local tbHistory = {}
	    data_netData = json.decode(data_netData)
	    for k,v in pairs(data_netData.data) do
	    	if v.status == nil or v.status ~= "2" then
	    		table.insert(tbHistory, v)
	    	end
	    end

	    dump(tbHistory, "-----当前用户未结束的组局-----")

	    --如果没有组局历史
	    if #tbHistory == 0 then
    		return
    	end

	    --有未结束组局，进入最后一次加入的未结束组局
    	for k, v in pairs(tbHistory) do
    		if k == 1 then

    			if bm.notCheckReload == 1 then
					dump("创建房间改为返回房间", "-----查看组局记录（检查重连）-----")

					if SCENENOW["scene"] then
			    		if SCENENOW["scene"]._scene then
			    			local room_plane = SCENENOW["scene"]._scene:getChildByName("room_plane")
			    			if room_plane then
			    				local btn_create = room_plane:getChildByName("btn_create")
			    				btn_create:loadTextures("hall/hall_02/hall_back_tb.png", nil, nil)  
			    			end
			    		end
			    	end

					return
				else
					dump("检查重连", "-----查看组局记录（检查重连）-----")
					self:join_freegame(USER_INFO["uid"], v["inviteCode"], v["activityId"], true, v["level"], true)
				end

    			-- self:join_freegame(USER_INFO["uid"], v["inviteCode"], v["activityId"], true, v["level"], true)

    			return
    		end
    	end

	    if isCallback == 1 then
	    	if SCENENOW["scene"] then
	    		SCENENOW["scene"]:checkGroupEnd()
	    	end
	    end

	end

	--查询当前用户组局历史记录
	dump(HttpAddr .. "/viewReganizeHistory" .. "   user:" .. USER_INFO["uid"], "-----重连操作，查询当前用户组局历史记录-----")
	cct.createHttRq({
		url=HttpAddr .. "/viewReganizeHistory",
		date={
			userId = USER_INFO["uid"]
		},
		type_="POST",
		callBack = viewReganizeHistory_callback
	})

end

--重连查询组局历史记录
function GroudGameManager:reConnectGroupStatus(callBack)

	local function viewReganizeHistory_callback(data)
		--验证返回数据
		local data_netData = data.netData
	    if data_netData == nil then
	        return
	    end

	    --检查是否有未结束组局
	    local tbHistory = {}
	    data_netData = json.decode(data_netData)
	    for k,v in pairs(data_netData.data) do
	    	if v.status == nil or v.status ~= "2" then
	    		table.insert(tbHistory, v)
	    	end
	    end

	    dump(tbHistory, "-----当前用户未结束的组局-----")

	    --如果没有组局历史 应该是重连进来之后组局已经结束了
	    if #tbHistory == 0 then
	    	display_scene("hall.gameScene")
    		return
    	end

	    --有未结束组局，进入最后一次加入的未结束组局
    	for k, v in pairs(tbHistory) do
    		if k == 1 then

    			--通知本地加入房间
	            require("hall.util.GameUtil"):LoginRoom(v["inviteCode"])
    			
    			callBack(v["activityId"], v["level"])
    			--self:join_freegame(USER_INFO["uid"], v["inviteCode"], v["activityId"], true, v["level"], true)
    			return
    		end
    	end
	end

	cct.createHttRq({
		url=HttpAddr .. "/viewReganizeHistory",
		date={
			userId = USER_INFO["uid"]
		},
		type_="POST",
		callBack = viewReganizeHistory_callback
	})

end

--创建组局
function GroudGameManager:createfreegame(user_id, create_freegame_tbl)

	local function viewReganizeHistory_callback(data)

		local data_netData = data.netData
	    if data_netData == nil then
	        return
	    end

	    --检查是否有未结束组局
	    local tbHistory = {}
	    data_netData = json.decode(data_netData)
	    for k,v in pairs(data_netData.data) do
	    	if v.status == nil or v.status ~= "2" then
	    		table.insert(tbHistory, v)
	    	end
	    end
	    dump(tbHistory, "-----当前用户未结束的组局-----")

	    --如果没有组局历史
	    if #tbHistory == 0 then
	    	--创建组局
	    	self:FreeGame(create_freegame_tbl)
    		return
    	end

	    --有未结束组局，进入最后一次加入的未结束组局
    	for k, v in pairs(tbHistory) do
    		if k == 1 then
    			self:join_freegame(USER_INFO["uid"], v["inviteCode"], v["activityId"], true, v["level"], true)
    			return
    		end
    	end

	end

	--获取用户当前游戏状态返回
	local function queryUserOnlineGameStatus_callback(data)

		dump(data,"-----创建组局，获取用户当前游戏状态返回-----")
		if data == nil then
			require("hall.GameTips"):showTips("数据异常", "", 2, "用户游戏状态异常，请稍候再试")
	        return
	    end

	    local data_netData = data.netData
	    data_netData = json.decode(data_netData)
	    if data_netData.data.gameStatus == "0" or data_netData.data.gameStatus == "1" then

	       	cct.createHttRq({
		        url=HttpAddr .. "/viewReganizeHistory",
		        date={
		            userId = user_id
		        },
		        type_="POST",
		        callBack = viewReganizeHistory_callback
 		   })

	    else

	    	require("hall.GameTips"):showTips("数据异常", "", 2, "用户游戏状态异常，请稍候再试")

	    end

	end

	--网络请求Loading
	require("hall.NetworkLoadingView.NetworkLoadingView"):showLoading("正在为您创建房间")

	--获取用户当前游戏状态
	dump(data,"-----创建组局，获取用户当前游戏状态-----")
	cct.createHttRq({
            url=HttpAddr .. "/game/queryUserOnlineGameStatus",
            date={
                userId = tostring(user_id)
            },
            type_="POST",
            callBack = queryUserOnlineGameStatus_callback
    })

end

--请求创建组局
function GroudGameManager:FreeGame(tbl)

	dump(tbl,"------请求创建组局------")

	cct.createHttRq({
       url=HttpAddr .. "/freeGame/createFreeGame",
       date= tbl,
       type_="POST",
       callBack = function(data)
       self:FreeGame_callback(data)
	end})

end

--请求创建组局返回
function GroudGameManager:FreeGame_callback(data)

	local data_netData = data.netData
    if data_netData == nil then
        return
    end
    data_netData = json.decode(data_netData)
	dump(data_netData,"-----请求创建组局返回-----")

    if data_netData.returnCode == "0" then
    	--创建成功的话，直接进游戏
		self:join_freegame(USER_INFO["uid"], data_netData["data"]["inviteCode"], data_netData["data"]["activityId"], true, data_netData["data"]["level"],true)
 	else
 		require("hall.GameTips"):showTips("提示", "", 3, data_netData["error"])
    end
    
end


return GroudGameManager