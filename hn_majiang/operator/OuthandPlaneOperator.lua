local Card = require("hn_majiang.card.card")
local OuthandPlaneOperator = class("OuthandPlaneOperator")

local FIRST_ROW_COUNT = 5
local ROW_COUNT = 4

local OUT_CARD_WIDTH_1 = 27
local OUT_CARD_HEIGHT_1 = 44
local OUT_CARD_SHOW_HEIGHT_1 = 32

local OUT_CARD_WIDTH_2 = 35
local OUT_CARD_SHOW_WIDTH_2 = 23

local OFFSET_Y_WITHIN_CARD_AND_PLANE = 5
local HuapaiScale =1.2

-- local timer_ids = {0, 0, 0, 0}

function OuthandPlaneOperator:init(playerType, plane,huaPlane)
	-- local scheduler = cc.Director:getInstance():getScheduler()

	-- for i=1,table.getn(timer_ids) do
	-- 	if timer_ids ~= 0 then
	-- 		--todo
	-- 		scheduler:unscheduleScriptEntry(timer_ids[i])
	-- 	end

	-- 	timer_ids[i] = 0
	-- end
	plane:removeAllChildren()
	huaPlane:removeAllChildren()
end

function OuthandPlaneOperator:playHuaCard(playerType,plane,cardValue)

	plane:setVisible(true)
	local cardNode = Card:new(playerType, CARD_TYPE_OUTHAND, CARD_DISPLAY_TYPE_SHOW, cardValue)
	cardNode:setLocalZOrder(0)
	-- cardNode:addTouchEventListener(
 --        function(sender,event)
 --            --触摸开始
 --            if event == TOUCH_EVENT_BEGAN then
 --            	sender:setScale(2)
 --            end

 --            --触摸取消
 --            if event == TOUCH_EVENT_CANCELED then
 --            	sender:setScale(1.0)
 --            end

 --            --触摸结束
 --            if event == TOUCH_EVENT_ENDED then
 --            	sender:setScale(1.0)
 --            end
 --        end
 --    )

	local size = cardNode:getSize()

	if playerType == CARD_PLAYERTYPE_MY then

		-- cardNode:setPosition(cc.p(plane:getSize().width / 2, size.height))

		-- cardNode:setScale(2.0)
		plane:addChild(cardNode)

		-- local function card_callback()  
		   local cardCount = plane:getChildrenCount()

		   local x = cardCount* (OUT_CARD_WIDTH_1)*HuapaiScale
		   local y = 0
	       cardNode:setScale(HuapaiScale)
	       cardNode:setPosition(cc.p(x, y))

			   
		   -- local worldPoint = cardNode:convertToWorldSpace(cc.p(0, 0))
		   -- HNMJ_CARD_POINTER:setPosition(cc.p(worldPoint.x + cardNode:getSize().width / 2, worldPoint.y + cardNode:getSize().height + HNMJ_CARD_POINTER:getSize().height / 4))
		   -- HNMJ_CARD_POINTER:setVisible(true)

		-- end

		-- local wait = cc.DelayTime:create(0)
		-- local callbackAc = cc.CallFunc:create(card_callback)
		-- local seqAc = cc.Sequence:create(wait,callbackAc)

		-- cardNode:runAction(seqAc)

	elseif playerType == CARD_PLAYERTYPE_LEFT then
		-- cardNode:setPosition(cc.p(cardNode:getSize().width, plane:getSize().height / 2))

		-- cardNode:setScale(2.0)
		plane:addChild(cardNode)
		 
		-- local function card_callback()  
		   local cardCount = plane:getChildrenCount()

		   local x = cardCount* (OUT_CARD_WIDTH_1)*HuapaiScale
		   local y = 0

		   cardNode:setScale(HuapaiScale)
		   cardNode:setPosition(cc.p(x, y))
		   cardNode:setRotation(270)

		   -- local worldPoint = cardNode:convertToWorldSpace(cc.p(0, 0))
		   -- HNMJ_CARD_POINTER:setPosition(cc.p(worldPoint.x + cardNode:getSize().width / 2, worldPoint.y + cardNode:getSize().height + HNMJ_CARD_POINTER:getSize().height / 4))
		   -- HNMJ_CARD_POINTER:setVisible(true)

		-- end


		-- local wait = cc.DelayTime:create(0)
		-- local callbackAc = cc.CallFunc:create(card_callback)
		-- local seqAc = cc.Sequence:create(wait, callbackAc)

		-- cardNode:runAction(seqAc)
	elseif playerType == CARD_PLAYERTYPE_RIGHT then
		-- cardNode:setPosition(cc.p(plane:getSize().width - size.width, plane:getSize().height / 2))

		-- cardNode:setScale(2.0)
		plane:addChild(cardNode)

		-- local function card_callback()  
		   local cardCount = plane:getChildrenCount()
		   cardNode:setLocalZOrder(0 - cardCount)

		   local x = cardCount* (OUT_CARD_WIDTH_1)*HuapaiScale
		   local y = 0

		   cardNode:setScale(HuapaiScale)
		   cardNode:setPosition(cc.p(x, y))
		   cardNode:setRotation(90)

		   -- local worldPoint = cardNode:convertToWorldSpace(cc.p(0, 0))
		   -- HNMJ_CARD_POINTER:setPosition(cc.p(worldPoint.x + cardNode:getSize().width / 2, worldPoint.y + cardNode:getSize().height + HNMJ_CARD_POINTER:getSize().height / 4))
		--    -- HNMJ_CARD_POINTER:setVisible(true)
		-- end


		-- local wait = cc.DelayTime:create(0)
		-- local callbackAc = cc.CallFunc:create(card_callback)
		-- local seqAc = cc.Sequence:create(wait, callbackAc)

		-- cardNode:runAction(seqAc)
	elseif playerType == CARD_PLAYERTYPE_TOP then
		-- cardNode:setPosition(cc.p(plane:getSize().width / 2, plane:getSize().height - size.height))

		-- cardNode:setScale(2.0)
		   plane:addChild(cardNode)

		-- local function card_callback()  
		   local cardCount = plane:getChildrenCount()

		   local x = cardCount* (OUT_CARD_WIDTH_1)*HuapaiScale
		   local y = 0

		   cardNode:setScale(HuapaiScale)
		   cardNode:setPosition(cc.p(x, y))
		   cardNode:setRotation(180)

		   -- local worldPoint = cardNode:convertToWorldSpace(cc.p(0, 0))
		   -- HNMJ_CARD_POINTER:setPosition(cc.p(worldPoint.x + cardNode:getSize().width / 2, worldPoint.y + cardNode:getSize().height + HNMJ_CARD_POINTER:getSize().height / 4))
		--    -- HNMJ_CARD_POINTER:setVisible(true)
		-- end

		-- local wait = cc.DelayTime:create(0)
		-- local callbackAc = cc.CallFunc:create(card_callback)
		-- local seqAc = cc.Sequence:create(wait, callbackAc)

		-- cardNode:runAction(seqAc)
	end
end

function OuthandPlaneOperator:Big(plane)
	-- dump(cardNode,"what the cardNode")

	-- local function onTouchBegan(touch, event)
	-- 			cardTemp = nil
	-- 	    	local children = plane:getChildren()
	-- 	    	for k,v in pairs(children) do
		        	
	-- 	    --todo
	-- 	    local locationInNode = v:convertToNodeSpace(touch:getLocation())

	-- 		local s = v:getContentSize()
	-- 		local rect = cc.rect(0, 0, s.width, s.height)
	-- 		if cc.rectContainsPoint(rect, locationInNode) then
	-- 			-- v:setOpacity(180)
	-- 			cardTemp = v
	-- 			self.cardOriPosition = cardTemp:getPosition()
	-- 		end
 --            end
 --            if cardTemp then
	-- 			cardTemp:setScale(2)
	-- 		end	        	
	-- end

	-- local function onTouchMoved(touch, event)
	-- 			cardTemp:setScale(1.0)
	-- end

	-- local function onTouchCancelled(touch, event)
	-- 			cardTemp:setScale(1.0) 
	-- end

	-- local function onTouchEnded(touch, event)
	-- 			cardTemp:setScale(1.0)
	-- end

	-- local listener1 = cc.EventListenerTouchOneByOne:create()
 --   		listener1:setSwallowTouches(false)
	-- 	listener1:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
	-- 	listener1:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
	-- 	listener1:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
	-- 	listener1:registerScriptHandler(onTouchCancelled,cc.Handler.EVENT_TOUCH_CANCELLED )

	-- return   listener1
end

function OuthandPlaneOperator:HuaRedraw(playerType,outplane,cardValue)
    local plane = (outplane:getParent()):getChildByName("hua_plane")
	plane:setVisible(true)
	local cardNode = Card:new(playerType, CARD_TYPE_OUTHAND, CARD_DISPLAY_TYPE_SHOW, cardValue)

	cardNode:setLocalZOrder(0)
	-- cardNode:addTouchEventListener(
 --        function(sender,event)
 --            --触摸开始
 --            if event == TOUCH_EVENT_BEGAN then
 --            	sender:setScale(3)
 --            end

 --            --触摸取消
 --            if event == TOUCH_EVENT_CANCELED then
 --            	sender:setScale(1.0)
 --            end

 --            --触摸结束
 --            if event == TOUCH_EVENT_ENDED then
 --            	sender:setScale(1.0)
 --            end
 --        end
 --    )
	-- local listener1 = self:Big(plane)
	-- local eventDispatcher = SCENENOW["scene"]:getEventDispatcher()
	--       eventDispatcher:addEventListenerWithSceneGraphPriority(listener1:clone(), cardNode)

	local size = cardNode:getSize()

	if playerType == CARD_PLAYERTYPE_MY then

		-- cardNode:setPosition(cc.p(plane:getSize().width / 2, size.height))

		-- cardNode:setScale(2.0)
		plane:addChild(cardNode)

		   local cardCount = plane:getChildrenCount()

		   local x = cardCount* (OUT_CARD_WIDTH_1)*HuapaiScale
		   local y = 0
	       cardNode:setScale(HuapaiScale)
	       cardNode:setPosition(cc.p(x, y))

			   
		   -- local worldPoint = cardNode:convertToWorldSpace(cc.p(0, 0))
		   -- HNMJ_CARD_POINTER:setPosition(cc.p(worldPoint.x + cardNode:getSize().width / 2, worldPoint.y + cardNode:getSize().height + HNMJ_CARD_POINTER:getSize().height / 4))
		   -- HNMJ_CARD_POINTER:setVisible(true)

	elseif playerType == CARD_PLAYERTYPE_LEFT then
		-- cardNode:setPosition(cc.p(cardNode:getSize().width, plane:getSize().height / 2))

		-- cardNode:setScale(2.0)
		plane:addChild(cardNode)
		 
		   local cardCount = plane:getChildrenCount()

		   local x = cardCount* (OUT_CARD_WIDTH_1)*HuapaiScale
		   local y = 0

		   cardNode:setScale(HuapaiScale)
		   cardNode:setPosition(cc.p(x, y))
		   cardNode:setRotation(-90)

		   -- local worldPoint = cardNode:convertToWorldSpace(cc.p(0, 0))
		   -- HNMJ_CARD_POINTER:setPosition(cc.p(worldPoint.x + cardNode:getSize().width / 2, worldPoint.y + cardNode:getSize().height + HNMJ_CARD_POINTER:getSize().height / 4))
		   -- HNMJ_CARD_POINTER:setVisible(true)

	elseif playerType == CARD_PLAYERTYPE_RIGHT then
		-- cardNode:setPosition(cc.p(plane:getSize().width - size.width, plane:getSize().height / 2))

		-- cardNode:setScale(2.0)
		plane:addChild(cardNode)

		   local cardCount = plane:getChildrenCount()
		   cardNode:setLocalZOrder(0 - cardCount)

		   local x = cardCount* (OUT_CARD_WIDTH_1)*HuapaiScale
		   local y = 0

		   cardNode:setScale(HuapaiScale)
		   cardNode:setPosition(cc.p(x, y))
		   cardNode:setRotation(90)

		   -- local worldPoint = cardNode:convertToWorldSpace(cc.p(0, 0))
		   -- HNMJ_CARD_POINTER:setPosition(cc.p(worldPoint.x + cardNode:getSize().width / 2, worldPoint.y + cardNode:getSize().height + HNMJ_CARD_POINTER:getSize().height / 4))
		   -- HNMJ_CARD_POINTER:setVisible(true)

	elseif playerType == CARD_PLAYERTYPE_TOP then
		-- cardNode:setPosition(cc.p(plane:getSize().width / 2, plane:getSize().height - size.height))

		-- cardNode:setScale(2.0)
		plane:addChild(cardNode)

		   local cardCount = plane:getChildrenCount()

		   local x = cardCount* (OUT_CARD_WIDTH_1)*HuapaiScale
		   local y = 0

		   cardNode:setScale(HuapaiScale)
		   cardNode:setPosition(cc.p(x, y))
		   cardNode:setRotation(180)

		   -- local worldPoint = cardNode:convertToWorldSpace(cc.p(0, 0))
		   -- HNMJ_CARD_POINTER:setPosition(cc.p(worldPoint.x + cardNode:getSize().width / 2, worldPoint.y + cardNode:getSize().height + HNMJ_CARD_POINTER:getSize().height / 4))
		   -- HNMJ_CARD_POINTER:setVisible(true)

	end
end

function OuthandPlaneOperator:playCard(playerType, cardValue, plane)
	--dump(type(cardNode), "OuthandPlaneOperator:playCard")
	-- --print(tolua.type(cardNode))
	--print_lua_table(cardNode)
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

			if PLAYERNUM == 4 or PLAYERNUM ==3  then	

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

			elseif PLAYERNUM == 2 then	
					
					   for i=1,ROW_COUNT do
					   		local countThisRow = 12
							if col > countThisRow then
								--todo
								row = row + 1
								col = col - countThisRow
							else
								break
							end
					   end
					   local countThisRow = (row - 1) * 2 + FIRST_ROW_COUNT
					   local x = (col - countThisRow / 2 - 0.5) * OUT_CARD_WIDTH_1 - plane:getSize().width / 2 + 200
					   local y = plane:getSize().height - ((row - 0.5) * OUT_CARD_SHOW_HEIGHT_1 + (OUT_CARD_HEIGHT_1 - OUT_CARD_SHOW_HEIGHT_1) / 2)
				       cardNode:setScale(1.0)
				       cardNode:setPosition(cc.p(x, y))
			end

			   
		   local worldPoint = cardNode:convertToWorldSpace(cc.p(0, 0))
		   HNMJ_CARD_POINTER:setPosition(cc.p(worldPoint.x + cardNode:getSize().width / 2, worldPoint.y + cardNode:getSize().height + HNMJ_CARD_POINTER:getSize().height / 4))
		   HNMJ_CARD_POINTER:setVisible(true)
		   -- scheduler:unscheduleScriptEntry(schedulerID)
		end


		local wait = cc.DelayTime:create(0.6)
		local callbackAc = cc.CallFunc:create(card_callback)
		local seqAc = cc.Sequence:create(wait,callbackAc)

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
		   HNMJ_CARD_POINTER:setPosition(cc.p(worldPoint.x + cardNode:getSize().width / 2, worldPoint.y + cardNode:getSize().height + HNMJ_CARD_POINTER:getSize().height / 4))
		   HNMJ_CARD_POINTER:setVisible(true)
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
		   HNMJ_CARD_POINTER:setPosition(cc.p(worldPoint.x + cardNode:getSize().width / 2, worldPoint.y + cardNode:getSize().height + HNMJ_CARD_POINTER:getSize().height / 4))
		   HNMJ_CARD_POINTER:setVisible(true)
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

			if PLAYERNUM == 4 or PLAYERNUM ==3 then	
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

			elseif PLAYERNUM == 2 then	
				   for i=1,ROW_COUNT do
				   		local countThisRow = 12
						if col > countThisRow then
							--todo
							row = row + 1
							col = col - countThisRow
						else
							break
						end
				   end

				   local countThisRow = (row - 1) * 2 + FIRST_ROW_COUNT
				   local x = (countThisRow / 2 - col + 0.5) * OUT_CARD_WIDTH_1 + plane:getSize().width / 2 + 200
				   local y = OUT_CARD_HEIGHT_1 / 2 + (row - 1) * OUT_CARD_SHOW_HEIGHT_1


				   cardNode:setScale(1.0)
				   cardNode:setPosition(cc.p(x, y))
			end

		   local worldPoint = cardNode:convertToWorldSpace(cc.p(0, 0))
		   HNMJ_CARD_POINTER:setPosition(cc.p(worldPoint.x + cardNode:getSize().width / 2, worldPoint.y + cardNode:getSize().height + HNMJ_CARD_POINTER:getSize().height / 4))
		   HNMJ_CARD_POINTER:setVisible(true)
		--    scheduler:unscheduleScriptEntry(schedulerID)
		-- end, 1, false)
		-- timer_ids[playerType] = schedulerID
		end

		local wait = cc.DelayTime:create(0.6)
		local callbackAc = cc.CallFunc:create(card_callback)
		local seqAc = cc.Sequence:create(wait, callbackAc)

		cardNode:runAction(seqAc)
	end

	HNMJ_CURRENT_CARDNODE = cardNode
end

function OuthandPlaneOperator:redraw(playerType, plane, outCards)
	local count = table.getn(outCards)
	for i=1,count do
		local cardValue = outCards[i]
		if cardValue>80 then self:HuaRedraw(playerType,plane,cardValue) 
        else
		local cardNode = Card:new(playerType, CARD_TYPE_OUTHAND, CARD_DISPLAY_TYPE_SHOW, cardValue)

		local size = cardNode:getSize()

		if playerType == CARD_PLAYERTYPE_MY then
			--todo
			local cardCount = plane:getChildrenCount()+1

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
			   local cardCount = plane:getChildrenCount()+1

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
			

			   local cardCount = plane:getChildrenCount()+1

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
			   local cardCount = plane:getChildrenCount()+1
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
		end  --end if card>80
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