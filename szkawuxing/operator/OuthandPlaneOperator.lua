local Card = require("szkawuxing.card.card")
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
	--dump(type(cardNode), "OuthandPlaneOperator:playCard")
	print(tolua.type(cardNode))
	print_lua_table(cardNode)
	-- cardNode:setCard(playerType, CARD_TYPE_OUTHAND, CARD_DISPLAY_TYPE_SHOW, cardNode.m_value)
	local cardNode = Card:new(playerType, CARD_TYPE_OUTHAND, CARD_DISPLAY_TYPE_SHOW, cardValue)

	cardNode:setLocalZOrder(200)

	-- cardNode:removeFromParent()

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
		   for i=1,ROW_COUNT do
		   		local countThisRow = (i - 1) * 2 + FIRST_ROW_COUNT
				if col > countThisRow then
					--todo
					row = row + 1
					col = col - countThisRow
				else
					break
				end
		   end

		   local countThisRow = (row - 1) * 2 + FIRST_ROW_COUNT
		   local x = (col - countThisRow / 2 - 0.5) * OUT_CARD_WIDTH_1 + plane:getSize().width / 2
		   local y = plane:getSize().height - ((row - 0.5) * OUT_CARD_SHOW_HEIGHT_1 + (OUT_CARD_HEIGHT_1 - OUT_CARD_SHOW_HEIGHT_1) / 2)

		   cardNode:setScale(1.0)
		   cardNode:setPosition(cc.p(x, y))

		   local worldPoint = cardNode:convertToWorldSpace(cc.p(0, 0))
		   SZKWX_CARD_POINTER:setPosition(cc.p(worldPoint.x + cardNode:getSize().width / 2, worldPoint.y + cardNode:getSize().height + SZKWX_CARD_POINTER:getSize().height / 4))
		   SZKWX_CARD_POINTER:setVisible(true)
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
		   		local countThisRow = (i - 1) * 2 + FIRST_ROW_COUNT
				if col > countThisRow then
					--todo
					row = row + 1
					col = col - countThisRow
				else
					break
				end
		   end

		   local countThisRow = (row - 1) * 2 + FIRST_ROW_COUNT
		   local x = plane:getSize().width - (row - 0.5) * size.width
		   local y = (countThisRow / 2 - col + 0.5) * OUT_CARD_SHOW_WIDTH_2 + plane:getSize().height / 2 - (size.height - OUT_CARD_SHOW_WIDTH_2) / 2 - OFFSET_Y_WITHIN_CARD_AND_PLANE

		   cardNode:setScale(1.0)
		   cardNode:setPosition(cc.p(x, y))

		   local worldPoint = cardNode:convertToWorldSpace(cc.p(0, 0))
		   SZKWX_CARD_POINTER:setPosition(cc.p(worldPoint.x + cardNode:getSize().width / 2, worldPoint.y + cardNode:getSize().height + SZKWX_CARD_POINTER:getSize().height / 4))
		   SZKWX_CARD_POINTER:setVisible(true)
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
		   		local countThisRow = (i - 1) * 2 + FIRST_ROW_COUNT
				if col > countThisRow then
					--todo
					row = row + 1
					col = col - countThisRow
				else
					break
				end
		   end

		   local countThisRow = (row - 1) * 2 + FIRST_ROW_COUNT
		   local x = (row - 0.5) * size.width
		   local y = (col - countThisRow / 2 - 0.5) * OUT_CARD_SHOW_WIDTH_2 + plane:getSize().height / 2 - (size.height - OUT_CARD_SHOW_WIDTH_2) / 2 - OFFSET_Y_WITHIN_CARD_AND_PLANE

		   cardNode:setScale(1.0)
		   cardNode:setPosition(cc.p(x, y))

		   local worldPoint = cardNode:convertToWorldSpace(cc.p(0, 0))
		   SZKWX_CARD_POINTER:setPosition(cc.p(worldPoint.x + cardNode:getSize().width / 2, worldPoint.y + cardNode:getSize().height + SZKWX_CARD_POINTER:getSize().height / 4))
		   SZKWX_CARD_POINTER:setVisible(true)
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
		   for i=1,ROW_COUNT do
		   		local countThisRow = (i - 1) * 2 + FIRST_ROW_COUNT
				if col > countThisRow then
					--todo
					row = row + 1
					col = col - countThisRow
				else
					break
				end
		   end

		   local countThisRow = (row - 1) * 2 + FIRST_ROW_COUNT
		   local x = (countThisRow / 2 - col + 0.5) * OUT_CARD_WIDTH_1 + plane:getSize().width / 2
		   local y = OUT_CARD_HEIGHT_1 / 2 + (row - 1) * OUT_CARD_SHOW_HEIGHT_1

		   cardNode:setScale(1.0)
		   cardNode:setPosition(cc.p(x, y))

		   local worldPoint = cardNode:convertToWorldSpace(cc.p(0, 0))
		   SZKWX_CARD_POINTER:setPosition(cc.p(worldPoint.x + cardNode:getSize().width / 2, worldPoint.y + cardNode:getSize().height + SZKWX_CARD_POINTER:getSize().height / 4))
		   SZKWX_CARD_POINTER:setVisible(true)
		--    scheduler:unscheduleScriptEntry(schedulerID)
		-- end, 1, false)
		-- timer_ids[playerType] = schedulerID
		end

		local wait = cc.DelayTime:create(0.6)
		local callbackAc = cc.CallFunc:create(card_callback)
		local seqAc = cc.Sequence:create(wait, callbackAc)

		cardNode:runAction(seqAc)
	end

	SZKWX_CURRENT_CARDNODE = cardNode
end

function OuthandPlaneOperator:redraw(playerType, plane, outCards)
	local count = table.getn(outCards)
	for i=1,count do
		local cardValue = outCards[i]
		local cardNode = Card:new(playerType, CARD_TYPE_OUTHAND, CARD_DISPLAY_TYPE_SHOW, cardValue)

		local size = cardNode:getSize()

		if playerType == CARD_PLAYERTYPE_MY then
			--todo
			local cardCount = i

			local row = 1
			local col = cardCount
			for i=1,ROW_COUNT do
			    local countThisRow = (i - 1) * 2 + FIRST_ROW_COUNT
				if col > countThisRow then
					--todo
					row = row + 1
					col = col - countThisRow
				else
					break
				end
			end

			local countThisRow = (row - 1) * 2 + FIRST_ROW_COUNT
			local x = (col - countThisRow / 2 - 0.5) * OUT_CARD_WIDTH_1 + plane:getSize().width / 2
			local y = plane:getSize().height - ((row - 0.5) * OUT_CARD_SHOW_HEIGHT_1 + (OUT_CARD_HEIGHT_1 - OUT_CARD_SHOW_HEIGHT_1) / 2)

			cardNode:setPosition(cc.p(x, y))

			plane:addChild(cardNode)
		elseif playerType == CARD_PLAYERTYPE_LEFT then
			   local cardCount = i

			   local row = 1
			   local col = cardCount
			   for i=1,ROW_COUNT do
			   		local countThisRow = (i - 1) * 2 + FIRST_ROW_COUNT
					if col > countThisRow then
						--todo
						row = row + 1
						col = col - countThisRow
					else
						break
					end
			   end

			   local countThisRow = (row - 1) * 2 + FIRST_ROW_COUNT
			   local x = plane:getSize().width - (row - 0.5) * size.width
			   local y = (countThisRow / 2 - col + 0.5) * OUT_CARD_SHOW_WIDTH_2 + plane:getSize().height / 2 - (size.height - OUT_CARD_SHOW_WIDTH_2) / 2 - OFFSET_Y_WITHIN_CARD_AND_PLANE

			   cardNode:setPosition(cc.p(x, y))

			   plane:addChild(cardNode)
		elseif playerType == CARD_PLAYERTYPE_RIGHT then
			

			   local cardCount = i

			   cardNode:setLocalZOrder(200 - cardCount)

			   local row = 1
			   local col = cardCount
			   for i=1,ROW_COUNT do
			   		local countThisRow = (i - 1) * 2 + FIRST_ROW_COUNT
					if col > countThisRow then
						--todo
						row = row + 1
						col = col - countThisRow
					else
						break
					end
			   end

			   local countThisRow = (row - 1) * 2 + FIRST_ROW_COUNT
			   local x = (row - 0.5) * size.width
			   local y = (col - countThisRow / 2 - 0.5) * OUT_CARD_SHOW_WIDTH_2 + plane:getSize().height / 2 - (size.height - OUT_CARD_SHOW_WIDTH_2) / 2 - OFFSET_Y_WITHIN_CARD_AND_PLANE

			   cardNode:setPosition(cc.p(x, y))

			   plane:addChild(cardNode)
		elseif playerType == CARD_PLAYERTYPE_TOP then
			   local cardCount = i
			   cardNode:setLocalZOrder(200 - cardCount)

			   local row = 1
			   local col = cardCount
			   for i=1,ROW_COUNT do
			   		local countThisRow = (i - 1) * 2 + FIRST_ROW_COUNT
					if col > countThisRow then
						--todo
						row = row + 1
						col = col - countThisRow
					else
						break
					end
			   end

			   local countThisRow = (row - 1) * 2 + FIRST_ROW_COUNT
			   local x = (countThisRow / 2 - col + 0.5) * OUT_CARD_WIDTH_1 + plane:getSize().width / 2
			   local y = OUT_CARD_HEIGHT_1 / 2 + (row - 1) * OUT_CARD_SHOW_HEIGHT_1

			   cardNode:setPosition(cc.p(x, y))

			   plane:addChild(cardNode)
		end
	end
end

function OuthandPlaneOperator:removeLatestOutCard(outPlane, card)
	local cardNodes = outPlane:getChildren()

	local count = table.getn(cardNodes)

	if count > 0 then
		--todo
		if cardNodes[count].m_value == card then
			--todo
			cardNodes[count]:removeFromParent()
			return true
		end
	end
	return false
end

return OuthandPlaneOperator