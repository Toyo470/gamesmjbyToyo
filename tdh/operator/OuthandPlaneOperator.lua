local Card = require("tdh.card.card")
local OuthandPlaneOperator = class("OuthandPlaneOperator")

local FIRST_ROW_COUNT = 5
local ROW_COUNT = 4

local OUT_CARD_WIDTH_1 = 27
local OUT_CARD_HEIGHT_1 = 44
local OUT_CARD_SHOW_HEIGHT_1 = 32

local OUT_CARD_WIDTH_2 = 35
local OUT_CARD_SHOW_WIDTH_2 = 23

local OFFSET_Y_WITHIN_CARD_AND_PLANE = 5
local OUT_CARD_SCALE = 1.0

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

function OuthandPlaneOperator:putCard()
	-- PrintTable(SEQ,"self.cardNode")
	-- print_lua_table(cardNode,"self.cardNode")
	-- and not tolua.isnull(SEQ)
    if not tolua.isnull(TDHMJ_CURRENT_CARDNODE)  then
    	-- TDHMJ_CURRENT_CARDNODE:runAction(SEQ)
    -- else
    	self:action()
    end
end


function OuthandPlaneOperator:action()
	if  tolua.isnull(TDHMJ_CURRENT_CARDNODE) then
		return
	end

	local cardCount = self.plane:getChildrenCount()
	local size = TDHMJ_CURRENT_CARDNODE:getSize()
	local row = 1
	local col = cardCount
	
    if self.playerType == CARD_PLAYERTYPE_MY then

		   for i=1,ROW_COUNT do
		   		local countThisRow = (row - 1) * 2 + FIRST_ROW_COUNT
				if col > countThisRow then
					--todo
					row = row + 1
					col = col - countThisRow
				else
					break
				end
		   end

		   local countThisRow = (row - 1) * 2 + FIRST_ROW_COUNT
		   local x = (col - countThisRow / 2 - 0.5) * OUT_CARD_WIDTH_1 + self.plane:getSize().width / 2
		   local y = self.plane:getSize().height - ((row - 0.5) * OUT_CARD_SHOW_HEIGHT_1 + (OUT_CARD_HEIGHT_1 - OUT_CARD_SHOW_HEIGHT_1) / 2)

		   self:Sequence(x,y)
		  
	elseif self.playerType == CARD_PLAYERTYPE_LEFT then

		   for i=1,ROW_COUNT do
		   		local countThisRow = (row - 1) * 2 + FIRST_ROW_COUNT
				if col > countThisRow then
					--todo
					row = row + 1
					col = col - countThisRow
				else
					break
				end
		   end

		   local countThisRow = (row - 1) * 2 + FIRST_ROW_COUNT
		   local x = self.plane:getSize().width - (row - 0.5) * size.width
		   local y = (countThisRow / 2 - col + 0.5) * OUT_CARD_SHOW_WIDTH_2 + self.plane:getSize().height / 2 - (size.height - OUT_CARD_SHOW_WIDTH_2) / 2 - OFFSET_Y_WITHIN_CARD_AND_PLANE
		   
           self:Sequence(x,y)

	elseif self.playerType == CARD_PLAYERTYPE_RIGHT then
		   TDHMJ_CURRENT_CARDNODE:setLocalZOrder(200 - cardCount)
		   for i=1,ROW_COUNT do
		   		local countThisRow = (row - 1) * 2 + FIRST_ROW_COUNT
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
		   local y = (col - countThisRow / 2 - 0.5) * OUT_CARD_SHOW_WIDTH_2 + self.plane:getSize().height / 2 - (size.height - OUT_CARD_SHOW_WIDTH_2) / 2 - OFFSET_Y_WITHIN_CARD_AND_PLANE

		  self:Sequence(x,y)

	elseif self.playerType == CARD_PLAYERTYPE_TOP then
		   TDHMJ_CURRENT_CARDNODE:setLocalZOrder(200 - cardCount)

		   for i=1,ROW_COUNT do
		   		local countThisRow = (row - 1) * 2 + FIRST_ROW_COUNT
				if col > countThisRow then
					--todo
					row = row + 1
					col = col - countThisRow
				else
					break
				end
		   end

		   local countThisRow = (row - 1) * 2 + FIRST_ROW_COUNT
		   local x = (countThisRow / 2 - col + 0.5) * OUT_CARD_WIDTH_1 + self.plane:getSize().width / 2
		   local y = OUT_CARD_HEIGHT_1 / 2 + (row - 1) * OUT_CARD_SHOW_HEIGHT_1

		   self:Sequence(x,y)
	end
end

function OuthandPlaneOperator:Sequence(x,y)

	local function card_callback()
		TDHMJ_CARD_POINTER:stopAllActions()

		local worldPoint = TDHMJ_CURRENT_CARDNODE:convertToWorldSpace(cc.p(0, 0))
		TDHMJ_CARD_POINTER:setPosition(cc.p(worldPoint.x + TDHMJ_CURRENT_CARDNODE:getSize().width / 2, worldPoint.y + TDHMJ_CURRENT_CARDNODE:getSize().height + TDHMJ_CARD_POINTER:getSize().height / 4))
		TDHMJ_CARD_POINTER:setVisible(true)

		local pointPosition = TDHMJ_CARD_POINTER:getPosition()

		local seqAcT = cc.Sequence:create(cc.MoveTo:create(0.5, cc.p(pointPosition.x, pointPosition.y + 10)), cc.MoveTo:create(0.5, pointPosition))

		TDHMJ_CARD_POINTER:runAction(cc.RepeatForever:create(seqAcT))
	end
     
    local delaytime = cc.DelayTime:create(0.5)
    local callbackAc = cc.CallFunc:create(card_callback)
    local sequenceAc = cc.Sequence:create(delaytime,cc.ScaleTo:create(0,1),cc.MoveTo:create(0, cc.p(x,y)),callbackAc)

    TDHMJ_CURRENT_CARDNODE:runAction(sequenceAc)

end


function OuthandPlaneOperator:playCard(playerType, cardValue, plane)
	 dump(plane:getChildren(),"OuthandPlaneOperator:playCard")
	--dump(type(cardNode), "OuthandPlaneOperator:playCard")
	--print(tolua.type(cardNode))
	--print_lua_table(cardNode)
	-- cardNode:setCard(playerType, CARD_TYPE_OUTHAND, CARD_DISPLAY_TYPE_SHOW, cardNode.m_value)
    local cardNode = Card:new(playerType, CARD_TYPE_OUTHAND, CARD_DISPLAY_TYPE_SHOW, cardValue)
    self.plane=plane
    self.playerType=playerType
	cardNode:setLocalZOrder(200)
	cardNode:setScale(2.0)
    
	-- cardNode:removeFromParent()
	local size = cardNode:getSize()

	if playerType == CARD_PLAYERTYPE_MY then
		cardNode:setPosition(cc.p(plane:getSize().width / 2, size.height))
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

		   TDHMJ_CARD_POINTER:stopAllActions()
		   
		   local worldPoint = cardNode:convertToWorldSpace(cc.p(0, 0))
		   TDHMJ_CARD_POINTER:setPosition(cc.p(worldPoint.x + cardNode:getSize().width / 2, worldPoint.y + cardNode:getSize().height + TDHMJ_CARD_POINTER:getSize().height / 4))
		   TDHMJ_CARD_POINTER:setVisible(true)

		   local pointPosition = TDHMJ_CARD_POINTER:getPosition()

		   local seqAcT = cc.Sequence:create(cc.MoveTo:create(0.5, cc.p(pointPosition.x, pointPosition.y + 10)), cc.MoveTo:create(0.5, pointPosition))

		   TDHMJ_CARD_POINTER:runAction(cc.RepeatForever:create(seqAcT))
		   -- scheduler:unscheduleScriptEntry(schedulerID)
		end
		-- timer_ids[playerType] = schedulerID
		local wait = cc.DelayTime:create(0.5)
		local callbackAc = cc.CallFunc:create(card_callback)


	elseif playerType == CARD_PLAYERTYPE_LEFT then
		cardNode:setPosition(cc.p(cardNode:getSize().width, plane:getSize().height / 2))
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

		   TDHMJ_CARD_POINTER:stopAllActions()

		   local worldPoint = cardNode:convertToWorldSpace(cc.p(0, 0))
		   TDHMJ_CARD_POINTER:setPosition(cc.p(worldPoint.x + cardNode:getSize().width / 2, worldPoint.y + cardNode:getSize().height + TDHMJ_CARD_POINTER:getSize().height / 4))
		   TDHMJ_CARD_POINTER:setVisible(true)

		   local pointPosition = TDHMJ_CARD_POINTER:getPosition()

		   local seqAcT = cc.Sequence:create(cc.MoveTo:create(0.5, cc.p(pointPosition.x, pointPosition.y + 10)), cc.MoveTo:create(0.5, pointPosition))

		   TDHMJ_CARD_POINTER:runAction(cc.RepeatForever:create(seqAcT))
		--    scheduler:unscheduleScriptEntry(schedulerID)
		-- end, 1, false)
		end
		-- timer_ids[playerType] = schedulerID

		local wait = cc.DelayTime:create(0.5)
		local callbackAc = cc.CallFunc:create(card_callback)


	elseif playerType == CARD_PLAYERTYPE_RIGHT then
		cardNode:setPosition(cc.p(plane:getSize().width - size.width, plane:getSize().height / 2))

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

		   TDHMJ_CARD_POINTER:stopAllActions()

		   local worldPoint = cardNode:convertToWorldSpace(cc.p(0, 0))
		   TDHMJ_CARD_POINTER:setPosition(cc.p(worldPoint.x + cardNode:getSize().width / 2, worldPoint.y + cardNode:getSize().height + TDHMJ_CARD_POINTER:getSize().height / 4))
		   TDHMJ_CARD_POINTER:setVisible(true)

		   local pointPosition = TDHMJ_CARD_POINTER:getPosition()

		   local seqAcT = cc.Sequence:create(cc.MoveTo:create(0.5, cc.p(pointPosition.x, pointPosition.y + 10)), cc.MoveTo:create(0.5, pointPosition))

		   TDHMJ_CARD_POINTER:runAction(cc.RepeatForever:create(seqAcT))
		end
		--    scheduler:unscheduleScriptEntry(schedulerID)
		-- end, 1, false)
		-- timer_ids[playerType] = schedulerID

		local wait = cc.DelayTime:create(0.5)
		local callbackAc = cc.CallFunc:create(card_callback)


	elseif playerType == CARD_PLAYERTYPE_TOP then
		cardNode:setPosition(cc.p(plane:getSize().width / 2, plane:getSize().height - size.height))
        plane:addChild(cardNode)
		cardNode:setScale(2.0)

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

		   TDHMJ_CARD_POINTER:stopAllActions()

		   local worldPoint = cardNode:convertToWorldSpace(cc.p(0, 0))
		   TDHMJ_CARD_POINTER:setPosition(cc.p(worldPoint.x + cardNode:getSize().width / 2, worldPoint.y + cardNode:getSize().height + TDHMJ_CARD_POINTER:getSize().height / 4))
		   TDHMJ_CARD_POINTER:setVisible(true)

		   local pointPosition = TDHMJ_CARD_POINTER:getPosition()

		   local seqAcT = cc.Sequence:create(cc.MoveTo:create(0.5, cc.p(pointPosition.x, pointPosition.y + 10)), cc.MoveTo:create(0.5, pointPosition))

		   TDHMJ_CARD_POINTER:runAction(cc.RepeatForever:create(seqAcT))
		--    scheduler:unscheduleScriptEntry(schedulerID)
		-- end, 1, false)
		-- timer_ids[playerType] = schedulerID
		end

		local wait = cc.DelayTime:create(0.5)
		local callbackAc = cc.CallFunc:create(card_callback)
		 
	end
	TDHMJ_CURRENT_CARDNODE = cardNode
end

function OuthandPlaneOperator:redraw(playerType, plane, outCards)
	local count = table.getn(outCards)
	for i=1,count do
		local cardValue = outCards[i]
		local cardNode = Card:new(playerType, CARD_TYPE_OUTHAND, CARD_DISPLAY_TYPE_SHOW, cardValue)
        
		local size = cardNode:getSize()


		if playerType == CARD_PLAYERTYPE_MY then

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
				local row = 1
				local col = cardCount
				cardNode:setLocalZOrder(200 - cardCount)
			   
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
				local row = 1
				local col = cardCount
				cardNode:setLocalZOrder(200 - cardCount)
			   
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
	-- 	print(card,"card")
	-- for i=1,count do 
 --  	  print(cardNodes[i].m_value,"removeLatestOutCard")
	-- end
	-- print(USER_INFO["nick"],"我的昵称")
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
	dump(card,"card")
	for i=1,count do 
  	  dump(cardNodes[i].m_value,"removeLatestOutCard2")
	end
	dump(USER_INFO["nick"],"我的昵称")
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