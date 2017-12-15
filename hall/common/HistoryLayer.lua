local HistoryLayer = class("HistoryLayer")

local history_cell
local myRecord_cell
local othersRecord_cell

local history_plane
local myRecord_plane

local isShow = false

local ts=require("hall.roomPlay.transcribe").new()
function HistoryLayer:showHistoryLayer()
	isShow = true

	local layout = cc.CSLoader:createNode("hall/common/HistoryLayer.csb"):addTo(SCENENOW["scene"])
	dump(layout, "history test")
	layout:setName("HistoryLayer")
	history_plane = layout:getChildByName("history_plane")

	myRecord_plane = layout:getChildByName("myRecord_plane")
	local findOthersRecord_plane = layout:getChildByName("findOthersRecord_plane")
	local othersRecord_plane = layout:getChildByName("othersRecord_plane")

	myRecord_plane:setVisible(false)
	findOthersRecord_plane:setVisible(false)
	othersRecord_plane:setVisible(false)

	local back_bt = layout:getChildByName("back_bt")
	local findOthersRecord_bt = layout:getChildByName("findOthersRecord_bt")
	findOthersRecord_bt:setVisible(false)
	local commit_bt = findOthersRecord_plane:getChildByName("commit_bt")
	local cancel_bt = findOthersRecord_plane:getChildByName("cancel_bt")
	local othersRecord_close_bt = othersRecord_plane:getChildByName("othersRecord_close_bt")

	local input_tf = findOthersRecord_plane:getChildByName("input_tf")

	findOthersRecord_plane.noScale = true
	findOthersRecord_plane:onClick(function()
			findOthersRecord_plane:setVisible(false)
		end)

	local function touchButtonEvent(sender, event)
        if event == TOUCH_EVENT_ENDED then
        	require("hall.GameCommon"):playEffectSound("hall/Audio_Button_Click.mp3")

            if sender == back_bt then
            	if history_plane:isVisible() then
            		--todo
            		isShow = false
            		layout:removeFromParent()
            	else
            		history_plane:setVisible(true)
            		myRecord_plane:setVisible(false)
            	end
                
            elseif sender == findOthersRecord_bt then
                findOthersRecord_plane:setVisible(true)
            elseif sender == commit_bt then--确定
            	--[[if device.platform =="windows" then
            		--todo
            		ts:getData() --test
            	end]]
            	
            	local inputStr = input_tf:getString()
            	if string.len(inputStr) == 0 then
            		--todo
            		return
            	end
            	local strs = string.split(inputStr, "-")
            	if table.getn(strs) ~= 2 then
            		--todos
            		return
            	end
            	dump(strs, "findRound")
            	
            	local params = {}
			    params["activityId"] = strs[1]
			    params["roundIndex"] = strs[2]
			    params["interfaceType"] = "J"
			    cct.createHttRq({
			        url=HttpAddr .. "/freeGame/queryFreeGameRound",
			        date= params,
			        type_="POST",
			        callBack = function(data)
			        	if not isShow then
			        		--todo
			        		return
			        	end
			            data_netData = json.decode(data["netData"])
			            dump(data_netData, "findRound")
			            if data_netData.returnCode == "0" then
			                --todo
			                local sData = data_netData.data
			                if sData ~= nil then
			                    --todo
			                    local rounds = {}
			                    table.insert(rounds, sData)
			                    findOthersRecord_plane:setVisible(false)
				            	self:showOthersRecords(othersRecord_cell, othersRecord_plane:getChildByName("othersRecord_scroll"), rounds)
				            	othersRecord_plane:setVisible(true)
			                end
			            end              
			        end
			    })
            elseif sender == cancel_bt then
            	print("cancel test")
            	findOthersRecord_plane:setVisible(false)
            elseif sender == othersRecord_close_bt then
            	othersRecord_plane:setVisible(false)
            end
        end
    end
    back_bt:addTouchEventListener(touchButtonEvent)
    findOthersRecord_bt:addTouchEventListener(touchButtonEvent)
    commit_bt:addTouchEventListener(touchButtonEvent)
    cancel_bt:addTouchEventListener(touchButtonEvent)
    othersRecord_close_bt:addTouchEventListener(touchButtonEvent)

    --cell
    history_cell = layout:getChildByName("history_cell")
    myRecord_cell = layout:getChildByName("myRecord_cell")
    othersRecord_cell = layout:getChildByName("othersRecord_cell")

    -- self.history_cell_5 = layout:getChildByName("history_cell_5")

    local history_scroll = history_plane:getChildByName("history_scroll")

    local params = {}
    params["userId"] = USER_INFO["uid"]
    params["interfaceType"] = "J"
    cct.createHttRq({
        url=HttpAddr .. "/freeGame/queryActivitiesByUserId",
        date= params,
        type_="POST",
        callBack = function(data)
        	if not isShow then
        		--todo
        		return
        	end
            data_netData = json.decode(data["netData"])

            dump(data_netData)

            if data_netData.returnCode == "0" then
                --todo
                local sData = data_netData.data
                if sData ~= nil and table.getn(sData) > 0 then
                    --todo
                    local histories = {}
                    for k,v in pairs(sData) do
                    	table.insert(histories, v)

                    	if k == 10 then
                    		--todo
                    		break
                    	end
                    end
                    if SCENENOW["scene"]:getChildByName("HistoryLayer") then    -- 同时点击时gameScene做了一步清除。可能导致被清除了还调用该方法  战绩
	                    self:showHistories(history_cell, history_scroll, histories)
	                end
                end
            end              
        end
    })
end

function HistoryLayer:testData()
	local datas = {}
	local history = {}
	history["num"] = "1"
	history["roomName"] = "testRoom"
	history["time"] = "08-29 11:21"
	
	local players = {}
	local player1 = {}
	player1["name"] = "zh"
	player1["score"] = "80"
	table.insert(players, player1)
	local player2 = {}
	player2["name"] = "zh"
	player2["score"] = "80"
	table.insert(players, player2)
	local player3 = {}
	player3["name"] = "zh"
	player3["score"] = "80"
	table.insert(players, player3)
	local player4 = {}
	player4["name"] = "zh"
	player4["score"] = "80"
	table.insert(players, player4)

	history["players"] = players

	local records = {}
	local record = {}
	record["time"] = "08-30 01:41"
	record["results"] = {"80","80","80","80"}

	table.insert(records, record)
	table.insert(records, record)
	table.insert(records, record)
	table.insert(records, record)
	table.insert(records, record)
	table.insert(records, record)

	history["records"] = records


	table.insert(datas, history)
	table.insert(datas, history)
	table.insert(datas, history)
	table.insert(datas, history)
	table.insert(datas, history)

	return datas
end

function HistoryLayer:testData1()
	local records = {}
	local record = {}
	record["time"] = "08-30 01:41"
	record["players"] = {"zh","xc","cv","vb"}

	table.insert(records, record)
	table.insert(records, record)
	table.insert(records, record)
	table.insert(records, record)
	table.insert(records, record)
	table.insert(records, record)
	table.insert(records, record)
	table.insert(records, record)
	table.insert(records, record)
	table.insert(records, record)
	table.insert(records, record)
	table.insert(records, record)
	table.insert(records, record)
	table.insert(records, record)

	return records
end

function HistoryLayer:showHistories(templateCell, plane, datas)
	plane:setInnerContainerSize(cc.size(plane:getSize().width,(templateCell:getSize().height + 5) * table.getn(datas)))
	table.foreach(datas, function(i, v) 
		local data = json.decode(v["content"])

		if data then
			--todo
			dump(data, "history test")

			local playerCount = table.getn(data["userinfos"])

			local cell

			-- if playerCount == 5 then
			-- 	--todo
			-- 	cell = self.history_cell_5:clone()
			-- else
				cell = templateCell:clone()
			-- end

			local num_lb = cell:getChildByName("num_lb")
			local roomName_lb = cell:getChildByName("roomName_lb")
			local time_lb = cell:getChildByName("time_lb")
			local player1_lb = cell:getChildByName("player1_lb")
			local player2_lb = cell:getChildByName("player2_lb")
			local player3_lb = cell:getChildByName("player3_lb")
			local player4_lb = cell:getChildByName("player4_lb")
			local player5_lb = cell:getChildByName("player5_lb")
			local score1_lb = cell:getChildByName("score1_lb")
			local score2_lb = cell:getChildByName("score2_lb")
			local score3_lb = cell:getChildByName("score3_lb")
			local score4_lb = cell:getChildByName("score4_lb")
			local score5_lb = cell:getChildByName("score5_lb")

			player1_lb:setString("")
			player2_lb:setString("")
			player3_lb:setString("")
			player4_lb:setString("")
			player5_lb:setString("")
			score1_lb:setString("")
			score2_lb:setString("")
			score3_lb:setString("")
			score4_lb:setString("")
			score5_lb:setString("")

			num_lb:setString(i .. "")

	
			USER_INFO["invote_code"] = data["roomNum"]


			--local num=loadstring("return 0x"..data["roomNum"])()

			roomName_lb:setString(require("hall.GameList"):getGameNameByLevel(tonumber(v["level"])) .. "   " .. data["roomNum"])
			print("time_lb",time_lb,data["gameTime"],os.date("%Y-%m-%d %H:%M:%S",data["gameTime"]))
			time_lb:setString("时间：" .. os.date("%Y-%m-%d %H:%M:%S",data["gameTime"]))
			local function getTurnningChips( info_data )
				local chips = 0
				if info_data["chips"] then -- 广东麻将
					-- if info_data["score"] == info_data["chips"] then
					-- 	if info_data["add_chips"] and info_data["add_chips"] == 20000 then
					-- 		chips = tonumber(info_data["score"])-tonumber(info_data["add_chips"])
					-- 	else
					-- 		if info_data["add_chips"] and info_data["add_chips"] == 2000 then
					-- 			chips = tonumber(info_data["score"])-tonumber(info_data["add_chips"] or 2000)
					-- 		else
					-- 			if info_data["add_chips"] == 0 then -- 炸金花
					-- 				chips = info_data["chips"]
					-- 			else
					-- 				chips = info_data["add_chips"]
					-- 			end
					-- 		end
					-- 	end
					-- end
					chips = tonumber(info_data["chips"])-tonumber(info_data["add_chips"] or 2000)
				else
					chips = tonumber(info_data["score"])-tonumber(info_data["add_chips"] or 2000)
				end
				return chips
			end
			for i = 1, 5 do
				if data["userinfos"][i] then
					--todo
					--data["userinfos"][4]
					local txt_nick = cell:getChildByName("player"..tostring(i).."_lb")
					if txt_nick then
						txt_nick:setString(data["userinfos"][i]["nickName"])
					end
					local txt_chips = cell:getChildByName("score"..tostring(i).."_lb")
					if txt_chips then
						local chips = getTurnningChips(data["userinfos"][i])
						txt_chips:setString(tostring(chips))
					end
				end
			end

			
			cell:setPosition(plane:getWidth() / 2, plane:getInnerContainerSize().height - cell:getSize().height / 2 - 5 - (5 + cell:getSize().height) * (i - 1))

			cell:setTag(i)

	    	plane:getInnerContainer():addChild(cell)

			cell.noScale = true
			cell:onClick(function(sender)
				dump(sender:getTag(), "history tag")
				

				local params = {}
			    params["activityId"] = datas[sender:getTag()]["activityId"]
			    params["interfaceType"] = "J"
			    cct.createHttRq({
			        url=HttpAddr .. "/freeGame/querRoundsByActivityId",
			        date= params,
			        type_="POST",
			        callBack = function(data)
			        	if not isShow then
			        		--todo
			        		return
			        	end
			            data_netData = json.decode(data["netData"])
			            if data_netData.returnCode == "0" then
			                --todo
			                dump(data_netData,"ddddddd")
			                local sData = data_netData.data
			                if sData ~= nil and table.getn(sData) > 0 then
			                    --todo
			                    history_plane:setVisible(false)
								myRecord_plane:setVisible(true)
								self:showMyRecords(myRecord_cell, myRecord_plane:getChildByName("myRecord_top"), myRecord_plane:getChildByName("myRecord_scroll"), sData)
			                end
			            end              
			        end
			    })

				end)
		end

		
		end)
	
end

function HistoryLayer:showMyRecords(templateCell, myRecord_top, plane, datas)
	plane:removeAllChildren()
	if table.getn(datas) == 0 then
		--todo
		return
	end

	dump(datas,"<<<<<<<<<<<<<<<<<<<<<<post")
	local player1_lb = myRecord_top:getChildByName("player1_lb")
	local player2_lb = myRecord_top:getChildByName("player2_lb")
	local player3_lb = myRecord_top:getChildByName("player3_lb")
	local player4_lb = myRecord_top:getChildByName("player4_lb")
	local player5_lb = myRecord_top:getChildByName("player5_lb")
	player1_lb:setString("")
	player2_lb:setString("")
	player3_lb:setString("")
	player4_lb:setString("")
	player5_lb:setString("")		

	local userinfos = json.decode(datas[1]["content"])["userinfos"]
	dump(userinfos, "rounds content")
	local userName= {}
	for k,v in pairs(userinfos) do
		if v["nickName"] then
			local strNick = require("hall.GameCommon"):formatNick(v["nickName"])
			table.insert(userName,strNick)
		end
	end
	dump(userName, "rounds userName")
	if userinfos[1] then
		--todo
		player1_lb:setString(userName[1])
	end
	if userinfos[2] then
		--todo
		player2_lb:setString(userName[2])
	end
	if userinfos[3] then
		--todo
		player3_lb:setString(userName[3])
	end
	if userinfos[4] then
		--todo
		player4_lb:setString(userName[4])
	end
	if userinfos[5] then
		--todo
		player5_lb:setString(userName[5])
	end


	plane:setInnerContainerSize(cc.size(plane:getSize().width, templateCell:getSize().height * table.getn(datas)))
	table.foreach(datas, function(i, v) 
		local data = json.decode(v["content"])
		local cell = templateCell:clone()
		local num_lb = cell:getChildByName("num_lb")
		local othersRecord_cell_bg = cell:getChildByName("othersRecord_cell_bg")
		local time_lb = cell:getChildByName("time_lb")
		local score1_lb = cell:getChildByName("score1_lb")
		local score2_lb = cell:getChildByName("score2_lb")
		local score3_lb = cell:getChildByName("score3_lb")
		local score4_lb = cell:getChildByName("score4_lb")
		local score5_lb = cell:getChildByName("score5_lb")


		score1_lb:setString("")
		score2_lb:setString("")
		score3_lb:setString("")
		score4_lb:setString("")
		score5_lb:setString("")

		num_lb:setString("" .. i)
		if i % 2 == 0 then
			--todo
			othersRecord_cell_bg:setVisible(false)
		else
			othersRecord_cell_bg:setVisible(true)
		end
		dump(v["endTime"], "gameTime test")
		time_lb:setString(os.date("%m-%d %H:%M",v["endTime"] / 1000))
		for i = 1, 5 do
			if data["userinfos"][i] then
				--todo
				local txt_chips = cell:getChildByName("score" ..tostring(i).."_lb")
				if txt_chips then
					if data["userinfos"][i]["user_chip_variation"] then
						txt_chips:setString(data["userinfos"][i]["user_chip_variation"])
					else
						txt_chips:setString(data["userinfos"][i]["score"])
					end
						-- txt_chips:setString(data["userinfos"][i]["score"])
				end
			end
		end
		
		
		cell:setPosition(plane:getSize().width / 2, plane:getInnerContainerSize().height - cell:getSize().height / 2 - cell:getSize().height * (i - 1))

    	plane:getInnerContainer():addChild(cell)

    	local replay_bt = cell:getChildByName("replay_bt")
    	replay_bt:setVisible(false)
    	replay_bt:setTag(i)

    	replay_bt:addTouchEventListener(function(sender, event)
    			if event == TOUCH_EVENT_ENDED then
    				--todo
    				local index = sender:getTag()
    				local roundIndex = datas[index]["roundIndex"]
    				local activityId = datas[index]["activityId"]

    				ts:getData(activityId, roundIndex)
    			end
    		end)

    	local share_bt = cell:getChildByName("share_bt")
		share_bt:setTag(i)
		local pos = share_bt:getPosition()
		share_bt:setPosition(cc.p(pos.x + 70, pos.y))


		share_bt:addTouchEventListener(function(sender, event)
    			if event == TOUCH_EVENT_ENDED then
    				--todo
    				local index = sender:getTag()
    				local roundIndex = datas[index]["roundIndex"]
    				local activityId = datas[index]["activityId"]
    				USER_INFO["activity_id"] = activityId
    				USER_INFO["GroupLevel"] = datas[index]["level"]
    				dump(USER_INFO, "showMyRecords", nesting)
    				require("hall.common.ShareLayer"):showShareLayer("【789广东麻将】", "https://a.mlinks.cc/AK3b", "url", "首次登录送房卡,约定您,快来吧~", nil, true);
    			end
    		end)
		
		end)

		
end

function HistoryLayer:showOthersRecords(templateCell, plane, datas)
	plane:removeAllChildren()
	plane:setInnerContainerSize(cc.size(plane:getSize().width, templateCell:getSize().height * table.getn(datas)))
	table.foreach(datas, function(i, v) 
		local data = json.decode(v["content"])
		local cell = templateCell:clone()
		local num_lb = cell:getChildByName("num_lb")
		local othersRecord_cell_bg = cell:getChildByName("othersRecord_cell_bg")
		local time_lb = cell:getChildByName("time_lb")
		local player1_lb = cell:getChildByName("player1_lb")
		local player2_lb = cell:getChildByName("player2_lb")
		local player3_lb = cell:getChildByName("player3_lb")
		local player4_lb = cell:getChildByName("player4_lb")
		local player5_lb = cell:getChildByName("player5_lb")

		player1_lb:setString("")
		player2_lb:setString("")
		player3_lb:setString("")
		player4_lb:setString("")
		player5_lb:setString("")

		num_lb:setString("" .. i)
		if i % 2 == 0 then
			--todo
			othersRecord_cell_bg:setVisible(false)
		else
			othersRecord_cell_bg:setVisible(true)
		end
		time_lb:setString(os.date("%m-%d %H:%M",v["endTime"] / 1000))
		if data["userinfos"][1] then
			--todo
			player1_lb:setString(data["userinfos"][1]["nickName"])
		end
		
		if data["userinfos"][2] then
			--todo
			player2_lb:setString(data["userinfos"][2]["nickName"])
		end
		if data["userinfos"][3] then
			--todo
			player3_lb:setString(data["userinfos"][3]["nickName"])
		end
		if data["userinfos"][4] then
			--todo
			player4_lb:setString(data["userinfos"][4]["nickName"])
		end
		
		
		
		
		cell:setPosition(plane:getSize().width / 2, plane:getInnerContainerSize().height - cell:getSize().height / 2 - cell:getSize().height * (i - 1))

		local replay_bt = cell:getChildByName("replay_bt")
    	replay_bt:setTag(i)

    	replay_bt:addTouchEventListener(function(sender, event)
    			if event == TOUCH_EVENT_ENDED then
    				--todo
    				local index = sender:getTag()
    				local roundIndex = datas[index]["roundIndex"]
    				local activityId = datas[index]["activityId"]
    				ts:getData(activityId, roundIndex)
    				--require("hall.transcribe.transcribe"):new(activityId, roundIndex)
    			end
    		end)

    	plane:getInnerContainer():addChild(cell)

		end)
end

return HistoryLayer