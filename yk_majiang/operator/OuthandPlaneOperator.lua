local Card = require("yk_majiang.card.card")
local OuthandPlaneOperator = class("OuthandPlaneOperator")

local FIRST_ROW_COUNT = 5
local ROW_COUNT = 4

local OUT_CARD_WIDTH_1 = 27
local OUT_CARD_HEIGHT_1 = 44
local OUT_CARD_SHOW_HEIGHT_1 = 32

local OUT_CARD_WIDTH_2 = 35
local OUT_CARD_SHOW_WIDTH_2 = 23

local OFFSET_Y_WITHIN_CARD_AND_PLANE = 5

-- local timer_ids = {0, 0, 0, 0}

function OuthandPlaneOperator:init(playerType, plane)
	-- local scheduler = cc.Director:getInstance():getScheduler()

	-- for i=1,table.getn(timer_ids) do
	-- 	if timer_ids ~= 0 then
	-- 		--todo
	-- 		scheduler:unscheduleScriptEntry(timer_ids[i])
	-- 	end

	-- 	timer_ids[i] = 0
	-- end

	plane:removeAllChildren()
end

function OuthandPlaneOperator:playCard(playerType, cardValue, plane)
	--print(tolua.type(cardNode))
	--print_lua_table(cardNode)
	local cardNode = Card:new(playerType, CARD_TYPE_OUTHAND, CARD_DISPLAY_TYPE_SHOW, cardValue)

	cardNode:setLocalZOrder(200)

	local size = cardNode:getSize()

	if playerType == CARD_PLAYERTYPE_MY then
		--todo
		cardNode:setPosition(cc.p(plane:getSize().width / 2, size.height))

		cardNode:setScale(2.0)
 	
		plane:addChild(cardNode)

		local function card_callback()  
		   local cardCount = plane:getChildrenCount()

		   local row = 1
		   local col = cardCount

		  if PLAYERNUM == 4 then

		   for i=1,ROW_COUNT do
		   		local countThisRow = 10
				if col > countThisRow then
					--todo
					row = row + 1
					col = col - countThisRow
				else
					break
				end
		   end

		   local countThisRow = 10
		   local x = (col - countThisRow / 2 - 0.5) * OUT_CARD_WIDTH_1 + plane:getSize().width / 2
		   local y = plane:getSize().height - ((row - 0.5) * OUT_CARD_SHOW_HEIGHT_1 + (OUT_CARD_HEIGHT_1 - OUT_CARD_SHOW_HEIGHT_1) / 2)

		   cardNode:setScale(1.0)
		   cardNode:setPosition(cc.p(x, y))

		  elseif PLAYERNUM == 2 then

		    for i=1,ROW_COUNT do
		   		local countThisRow = 18
				if col > countThisRow then
					--todo
					row = row + 1
					col = col - countThisRow
				else
					break
				end
		    end



		   local countThisRow = 18
		   local x = (col - countThisRow / 2 - 0.5) * OUT_CARD_WIDTH_1 + plane:getSize().width / 2
		   local y = plane:getSize().height - ((row - 0.5) * OUT_CARD_SHOW_HEIGHT_1 + (OUT_CARD_HEIGHT_1 - OUT_CARD_SHOW_HEIGHT_1) / 2)

		   cardNode:setScale(1.0)
		   cardNode:setPosition(cc.p(x, y))

		  end

		   local worldPoint = cardNode:convertToWorldSpace(cc.p(0, 0))
		   YKMJ_CARD_POINTER:setPosition(cc.p(worldPoint.x + cardNode:getSize().width / 2, worldPoint.y + cardNode:getSize().height + YKMJ_CARD_POINTER:getSize().height / 4))
		   YKMJ_CARD_POINTER:setVisible(true)
		   -- scheduler:unscheduleScriptEntry(schedulerID)
		end
		-- timer_ids[playerType] = schedulerID
		local wait = cc.DelayTime:create(0.6)
		local callbackAc = cc.CallFunc:create(card_callback)
		local seqAc = cc.Sequence:create(wait, callbackAc)

		cardNode:runAction(seqAc)
	elseif playerType == CARD_PLAYERTYPE_LEFT then
		cardNode:setPosition(cc.p(cardNode:getSize().width, plane:getSize().height / 2))

		cardNode:setScale(2.0)
		plane:addChild(cardNode)

		-- local scheduler = cc.Director:getInstance():getScheduler()  
		-- local schedulerID = nil  
		-- schedulerID = scheduler:scheduleScriptFunc(function()  
		local function card_callback()  
		   local cardCount = plane:getChildrenCount()

		   local row = 1
		   local col = cardCount
		   for i=1,ROW_COUNT do
		   		local countThisRow = 10
				if col > countThisRow then
					--todo
					row = row + 1
					col = col - countThisRow
				else
					break
				end
		   end

		   local countThisRow = 10
		   local x = plane:getSize().width - (row - 0.5) * size.width - OUT_CARD_HEIGHT_1
		   local y = (countThisRow / 2 - col + 0.5) * OUT_CARD_SHOW_WIDTH_2 + plane:getSize().height / 2 - (size.height - OUT_CARD_SHOW_WIDTH_2) / 2 - OFFSET_Y_WITHIN_CARD_AND_PLANE

		   cardNode:setScale(1.0)
		   cardNode:setPosition(cc.p(x, y))

		   local worldPoint = cardNode:convertToWorldSpace(cc.p(0, 0))
		   YKMJ_CARD_POINTER:setPosition(cc.p(worldPoint.x + cardNode:getSize().width / 2, worldPoint.y + cardNode:getSize().height + YKMJ_CARD_POINTER:getSize().height / 4))
		   YKMJ_CARD_POINTER:setVisible(true)
		--    scheduler:unscheduleScriptEntry(schedulerID)
		-- end, 1, false)
		end
		-- timer_ids[playerType] = schedulerID

		local wait = cc.DelayTime:create(0.6)
		local callbackAc = cc.CallFunc:create(card_callback)
		local seqAc = cc.Sequence:create(wait, callbackAc)

		cardNode:runAction(seqAc)
	elseif playerType == CARD_PLAYERTYPE_RIGHT then
		cardNode:setPosition(cc.p(plane:getSize().width - size.width, plane:getSize().height / 2))

		cardNode:setScale(2.0)	
		plane:addChild(cardNode)

		-- local scheduler = cc.Director:getInstance():getScheduler()  
		-- local schedulerID = nil  
		-- schedulerID = scheduler:scheduleScriptFunc(function()  
		local function card_callback()  
		   local cardCount = plane:getChildrenCount()

		   cardNode:setLocalZOrder(200 - cardCount)

		   local row = 1
		   local col = cardCount
		   for i=1,ROW_COUNT do
		   		local countThisRow = 10
				if col > countThisRow then
					--todo
					row = row + 1
					col = col - countThisRow
				else
					break
				end
		   end

		   local countThisRow = 10
		   local x = (row - 0.5) * size.width + OUT_CARD_HEIGHT_1
		   local y = (col - countThisRow / 2 - 0.5) * OUT_CARD_SHOW_WIDTH_2 + plane:getSize().height / 2 - (size.height - OUT_CARD_SHOW_WIDTH_2) / 2 - OFFSET_Y_WITHIN_CARD_AND_PLANE

		   cardNode:setScale(1.0)
		   cardNode:setPosition(cc.p(x, y))

		   local worldPoint = cardNode:convertToWorldSpace(cc.p(0, 0))
		   YKMJ_CARD_POINTER:setPosition(cc.p(worldPoint.x + cardNode:getSize().width / 2, worldPoint.y + cardNode:getSize().height + YKMJ_CARD_POINTER:getSize().height / 4))
		   YKMJ_CARD_POINTER:setVisible(true)
		end
		--    scheduler:unscheduleScriptEntry(schedulerID)
		-- end, 1, false)
		-- timer_ids[playerType] = schedulerID

		local wait = cc.DelayTime:create(0.6)
		local callbackAc = cc.CallFunc:create(card_callback)
		local seqAc = cc.Sequence:create(wait, callbackAc)

		cardNode:runAction(seqAc)
	elseif playerType == CARD_PLAYERTYPE_TOP then
		cardNode:setPosition(cc.p(plane:getSize().width / 2, plane:getSize().height - size.height))

		cardNode:setScale(2.0)
		plane:addChild(cardNode)

		-- local scheduler = cc.Director:getInstance():getScheduler()  
		-- local schedulerID = nil  
		-- schedulerID = scheduler:scheduleScriptFunc(function()  
		local function card_callback()  
		   local cardCount = plane:getChildrenCount()
		   cardNode:setLocalZOrder(200 - cardCount)

		   local row = 1
		   local col = cardCount

		  if PLAYERNUM == 4 then

		   for i=1,ROW_COUNT do
		   		local countThisRow = 10
				if col > countThisRow then
					--todo
					row = row + 1
					col = col - countThisRow
				else
					break
				end
		   end

		   local countThisRow = 10
		   local x = (countThisRow / 2 - col + 0.5) * OUT_CARD_WIDTH_1 + plane:getSize().width / 2 
		   local y = OUT_CARD_HEIGHT_1 / 2 + (row - 1) * OUT_CARD_SHOW_HEIGHT_1

		   cardNode:setScale(1.0)
		   cardNode:setPosition(cc.p(x, y))

		   elseif PLAYERNUM == 2 then

		   for i=1,ROW_COUNT do
		   		local countThisRow = 18
				if col > countThisRow then
					--todo
					row = row + 1
					col = col - countThisRow
				else
					break
				end
		   end

		   local countThisRow = 18
		   local x = (countThisRow / 2 - col + 0.5) * OUT_CARD_WIDTH_1 + plane:getSize().width / 2
		   local y = OUT_CARD_HEIGHT_1 / 2 + (row - 1) * OUT_CARD_SHOW_HEIGHT_1

		   cardNode:setScale(1.0)
		   cardNode:setPosition(cc.p(x, y))
		   end

		   local worldPoint = cardNode:convertToWorldSpace(cc.p(0, 0))
		   YKMJ_CARD_POINTER:setPosition(cc.p(worldPoint.x + cardNode:getSize().width / 2, worldPoint.y + cardNode:getSize().height + YKMJ_CARD_POINTER:getSize().height / 4))
		   YKMJ_CARD_POINTER:setVisible(true)
		--    scheduler:unscheduleScriptEntry(schedulerID)
		-- end, 1, false)
		-- timer_ids[playerType] = schedulerID
		end

		local wait = cc.DelayTime:create(0.6)
		local callbackAc = cc.CallFunc:create(card_callback)
		local seqAc = cc.Sequence:create(wait, callbackAc)

		cardNode:runAction(seqAc)
	end

	YKMJ_CURRENT_CARDNODE = cardNode
end

function OuthandPlaneOperator:redraw(playerType, plane, outCards)

	local count = table.getn(outCards)
	for i=1,count do
		local cardValue = outCards[i]
		local cardNode = Card:new(playerType, CARD_TYPE_OUTHAND, CARD_DISPLAY_TYPE_SHOW, cardValue)
		-- for k=0,2 do
		--    if  not plane:getChildByTag((cardValue)..""..k) then     --如果存在
		--        cardNode:setTag((cardValue)..""..k)     --如果不存在
		--        break    
		--    end	
		--    end  	
		plane:addChild(cardNode)
		local cardCount = i
		local row = 1
		local col = cardCount

		local size = cardNode:getSize()

		if playerType == CARD_PLAYERTYPE_MY then

		if PLAYERNUM == 4 then

			for i=1,ROW_COUNT do
			    local countThisRow = 10
				if col > countThisRow then
					--todo
					row = row + 1
					col = col - countThisRow
				else
					break
				end
			end

			local countThisRow = 10
			local x = (col - countThisRow / 2 - 0.5) * OUT_CARD_WIDTH_1 + plane:getSize().width / 2
			local y = plane:getSize().height - ((row - 0.5) * OUT_CARD_SHOW_HEIGHT_1 + (OUT_CARD_HEIGHT_1 - OUT_CARD_SHOW_HEIGHT_1) / 2)

			cardNode:setPosition(cc.p(x, y))
         elseif PLAYERNUM == 2 then

			for i=1,ROW_COUNT do
			    local countThisRow = 18
				if col > countThisRow then
					--todo
					row = row + 1
					col = col - countThisRow
				else
					break
				end
			end

			local countThisRow = 18
			local x = (col - countThisRow / 2 - 0.5) * OUT_CARD_WIDTH_1 + plane:getSize().width / 2
			local y = plane:getSize().height - ((row - 0.5) * OUT_CARD_SHOW_HEIGHT_1 + (OUT_CARD_HEIGHT_1 - OUT_CARD_SHOW_HEIGHT_1) / 2)

			cardNode:setPosition(cc.p(x, y))

          	end

		elseif playerType == CARD_PLAYERTYPE_LEFT then

			   for i=1,ROW_COUNT do
			   		local countThisRow = 10
					if col > countThisRow then
						--todo
						row = row + 1
						col = col - countThisRow
					else
						break
					end
			   end

			   local countThisRow = 10
			   local x = plane:getSize().width - (row - 0.5) * size.width - OUT_CARD_HEIGHT_1
			   local y = (countThisRow / 2 - col + 0.5) * OUT_CARD_SHOW_WIDTH_2 + plane:getSize().height / 2 - (size.height - OUT_CARD_SHOW_WIDTH_2) / 2 - OFFSET_Y_WITHIN_CARD_AND_PLANE

			   cardNode:setPosition(cc.p(x, y))

		elseif playerType == CARD_PLAYERTYPE_RIGHT then
			
			   cardNode:setLocalZOrder(200 - cardCount)

			   for i=1,ROW_COUNT do
			   		local countThisRow = 10
					if col > countThisRow then
						--todo
						row = row + 1
						col = col - countThisRow
					else
						break
					end
			   end

			   local countThisRow = 10
			   local x = (row - 0.5) * size.width + OUT_CARD_HEIGHT_1
			   local y = (col - countThisRow / 2 - 0.5) * OUT_CARD_SHOW_WIDTH_2 + plane:getSize().height / 2 - (size.height - OUT_CARD_SHOW_WIDTH_2) / 2 - OFFSET_Y_WITHIN_CARD_AND_PLANE

			   cardNode:setPosition(cc.p(x, y))

		elseif playerType == CARD_PLAYERTYPE_TOP then

			   cardNode:setLocalZOrder(200 - cardCount)


			if PLAYERNUM == 4 then

			   for i=1,ROW_COUNT do
			   		local countThisRow = 10
					if col > countThisRow then
						--todo
						row = row + 1
						col = col - countThisRow
					else
						break
					end
			   end

			   local countThisRow = 10
			   local x = (countThisRow / 2 - col + 0.5) * OUT_CARD_WIDTH_1 + plane:getSize().width / 2
			   local y = OUT_CARD_HEIGHT_1 / 2 + (row - 1) * OUT_CARD_SHOW_HEIGHT_1

			   cardNode:setPosition(cc.p(x, y))

		    elseif  PLAYERNUM == 2 then

		    	for i=1,ROW_COUNT do
			   		local countThisRow = 18
					if col > countThisRow then
						--todo
						row = row + 1
						col = col - countThisRow
					else
						break
					end
			   end

			   local countThisRow = 18
			   local x = (countThisRow / 2 - col + 0.5) * OUT_CARD_WIDTH_1 + plane:getSize().width / 2
			   local y = OUT_CARD_HEIGHT_1 / 2 + (row - 1) * OUT_CARD_SHOW_HEIGHT_1

			   cardNode:setPosition(cc.p(x, y))

			end
		end
	end
end

function OuthandPlaneOperator:removeLatestOutCard(outPlane, card)
	local cardNodes = outPlane:getChildren()
 
	local count = table.getn(cardNodes)
	if count > 0 then
		if cardNodes[count].m_value == card then
			--todo
			cardNodes[count]:removeFromParent()
			return true
		end
	end
	return false
end

--因为右边和上面的牌是倒序的，所以要这样
function OuthandPlaneOperator:removeLatestOutCard2(outPlane, card)
	local cardNodes = outPlane:getChildren()
    
	local count = table.getn(cardNodes)
	if count > 0 then
		if cardNodes[1].m_value == card  then
			--todo
			cardNodes[1]:removeFromParent()
			return true
		end
	end
	return false
end

 
return OuthandPlaneOperator