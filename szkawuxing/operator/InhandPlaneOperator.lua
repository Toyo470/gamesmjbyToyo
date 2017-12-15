local Card = require("szkawuxing.card.card")
local cardUtils = require("szkawuxing.utils.cardUtils")

local InhandPlaneOperator = class("InhandPlaneOperator")

local SPLIT_NEWCARD = 25

local selectedTag = 99

local NEW_CARD_TAG = 20

local cardTemp = nil

function InhandPlaneOperator:init(playerType, plane)
	planeTemp = plane

	plane:removeAllChildren()

	if playerType == CARD_PLAYERTYPE_MY then
		--todo
		plane:setSize(cc.size(0, plane:getSize().height))
	elseif playerType == CARD_PLAYERTYPE_LEFT then
		plane:setSize(cc.size(plane:getSize().width, 0))
	elseif playerType == CARD_PLAYERTYPE_RIGHT then
		plane:setSize(cc.size(plane:getSize().width, 0))
	elseif playerType == CARD_PLAYERTYPE_TOP then
		plane:setSize(cc.size(0, plane:getSize().height))
	end
	
end

function InhandPlaneOperator:revertOutCardPosition()
	if cardTemp and self.oriSelectedPosition then
		--todo
		selectedTag = 99
		cardTemp:setPosition(self.oriSelectedPosition)
	end
end

function InhandPlaneOperator:showCards(playerType, plane, cardDatas, tingFlag)

	plane:removeAllChildren()

	if playerType == CARD_PLAYERTYPE_MY then
		--todo
		selectedTag = 99

		local oriX = 0
		local oriY = plane:getSize().height / 2

		local isTing = 0 or tingFlag

		local function onTouchBegan(touch, event)
		    if SZKWX_CHUPAI == 1 then
		    	--todo
		    	cardTemp = nil
		    	local children = plane:getChildren()
		    	for k,v in pairs(children) do
		        	
				    --todo
				    local locationInNode = v:convertToNodeSpace(touch:getLocation())

					local s = v:getContentSize()
					local rect = cc.rect(0, 0, s.width, s.height)
					if cc.rectContainsPoint(rect, locationInNode) then
						-- v:setOpacity(180)
						cardTemp = v
						self.cardOriPosition = cardTemp:getPosition()
						cardTemp:setOpacity(180)
			            local card_click_flag = cardTemp.card_click or false
			            if card_click_flag == true then
			            	SZKWX_CONTROLLER:playCard(cardTemp.m_value)
			            	return false
			            else
						    for _,child in pairs(children) do
						        child.card_click = false
						        child:setColor(cc.c3b(250,250,255))
						        child:setOpacity(255)
						    end
			            	cardTemp.card_click = true
			            	cardTemp:setColor(cc.c3b(250,250,0))
			            end
					end
				        	
				end
				if cardTemp then
					--todo
					if selectedTag == 99 then
						--todo
						self.canMove = true

						self.oriSelectedPosition = cardTemp:getPosition()
					else
						if selectedTag ~= cardTemp:getTag() then
							--todo
							self.oriSelectedPosition = cardTemp:getPosition()
						end
						
						self.canMove = false
					end
					return true
				else
					return false
				end
		    end

		    return false
		end

		local function onTouchMoved(touch, event)
		    if self.canMove then
		    	--todo
		    	if cardTemp then
			    	local posX = cardTemp:getPositionX()
			    	local posY = cardTemp:getPositionY()
			    	local delta = touch:getDelta()
			    	cardTemp:setPosition(cc.p(posX + delta.x, posY + delta.y))
		    	end
		    end
		end

		local function onTouchEnded(touch, event)
		   	if cardTemp then
		   		--todo
		   		local target=event:getCurrentTarget()
		   		target:setOpacity(255)
		   		local offsetY = cardTemp:getPosition().y - cardTemp:getSize().height / 2
		   		if offsetY > plane:getSize().height then
		   			--超出范围，出牌
		   			SZKWX_CONTROLLER:playCard(cardTemp.m_value)
		   			-- cardTemp:removeFromParent()
		   		else

		   			cardTemp:setPosition(self.oriSelectedPosition)

		   			return

		   -- 			local locationInNode = cardTemp:convertToNodeSpace(touch:getLocation())
		   -- 			local rect = cc.rect(0, 0, cardTemp:getContentSize().width, cardTemp:getContentSize().height)
					-- if cc.rectContainsPoint(rect, locationInNode) then
					-- 	if selectedTag == cardTemp:getTag() then
					-- 	    --出牌
					-- 		SZKWX_CONTROLLER:playCard(cardTemp.m_value)
					-- 	else
					-- 		self:cancelSelectingCard(plane)

					-- 		local p = cardTemp:getPosition()

					-- 		if self.canMove then
					-- 			--todo
					-- 			p = self.cardOriPosition
					-- 		end

					-- 		cardTemp:setScale(1.2)
					-- 		local offsetX = 0.1 * cardTemp:getSize().width

					-- 		cardTemp:setPosition(cc.p(p.x + offsetX / 2, p.y + 30))

					-- 		local tag = cardTemp:getTag()
					-- 		selectedTag = tag
					-- 		tag = tag + 1
					-- 		local nextCard = plane:getChildByTag(tag)
					-- 		while nextCard do
					-- 			--todo
					-- 			nextCard:setPosition(cc.p(nextCard:getPosition().x + offsetX, nextCard:getPosition().y))

					-- 			tag = tag + 1
					-- 			nextCard = plane:getChildByTag(tag)
					-- 		end
					-- 	end
					-- else
					-- 	self:cancelSelectingCard(plane)
					-- end
		   			
		   		end
		   	end
		end

		local listener1 = cc.EventListenerTouchOneByOne:create()
   		listener1:setSwallowTouches(true)
		listener1:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
		listener1:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
		listener1:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )

		local eventDispatcher = SCENENOW["scene"]:getEventDispatcher()
		    
		for i=1,table.getn(cardDatas) do
			local data = cardDatas[i]

			local card = Card:new(playerType, CARD_TYPE_INHAND, CARD_DISPLAY_TYPE_OPPOSIVE, data)

			card:setScale(1.1)
			-- card:setAnchorPoint(cc.p(0, 0))
			card:setPosition(cc.p(oriX + card:getSize().width * 1.1 / 2, card:getSize().height * 1.1 / 2))

			card:setTouchEnabled(false)

			if isTing ~= 1 then
				--todo
				eventDispatcher:addEventListenerWithSceneGraphPriority(listener1:clone(), card)
			end

			card:setTag(i)

			plane:addChild(card)

			oriX = oriX + card:getSize().width * 1.1
		end

		local width = oriX + 81
		plane:setSize(cc.size(width, plane:getSize().height))
	elseif playerType == CARD_PLAYERTYPE_LEFT then
		--todo
		local oriX = plane:getSize().width / 2
		local count = table.getn(cardDatas)
		local totalHeight = count * 22 + 11 + 44
		local oriY = totalHeight - 22

		for i=1,count do
			local data = cardDatas[i]

			local card = Card:new(playerType, CARD_TYPE_INHAND, CARD_DISPLAY_TYPE_OPPOSIVE, data)

			card:addTouchEventListener(function(sender, event)
					print("123")
				end)

			card:setPosition(cc.p(oriX, oriY))

			card:setTag(i)

			plane:addChild(card)

			oriY = oriY - 22
		end

		plane:setSize(cc.size(plane:getSize().width, totalHeight))
	elseif playerType == CARD_PLAYERTYPE_RIGHT then
		local oriX = plane:getSize().width / 2
		local oriY = 44 / 2
		local count = table.getn(cardDatas)

		for i=1,count do
			local data = cardDatas[i]

			local card = Card:new(playerType, CARD_TYPE_INHAND, CARD_DISPLAY_TYPE_OPPOSIVE, data)

			card:setPosition(cc.p(oriX, oriY))

			card:setLocalZOrder(20 - i)

			card:setTag(i)

			plane:addChild(card)

			oriY = oriY + (44 - 22)
		end

		plane:setSize(cc.size(plane:getSize().width, oriY - 22 + 11 + 44))
	elseif playerType == CARD_PLAYERTYPE_TOP then
		local count = table.getn(cardDatas)
		local totalWidth = count * 30 + 15 + 30
		local oriX = totalWidth - 15
		local oriY = plane:getSize().height / 2

		for i=1,count do
			local data = cardDatas[i]

			local card = Card:new(playerType, CARD_TYPE_INHAND, CARD_DISPLAY_TYPE_OPPOSIVE, data)

			card:setPosition(cc.p(oriX, oriY))

			card:setTag(i)

			plane:addChild(card)

			oriX = oriX - 30
		end

		plane:setSize(cc.size(totalWidth, plane:getSize().height))
	end
end

function InhandPlaneOperator:showCardsForAll(playerType, plane, cardDatas, anke, liangCards)
	plane:removeAllChildren()

	if liangCards then
		--todo
		table.sort(liangCards)
	end

	local cardsTemp = {}

	local index = 1
	for k,v in pairs(cardDatas) do
		local isAnke = false
		for m,n in pairs(anke) do
			if v == n then
				--todo
				isAnke = true
				break
			end
		end

		if liangCards then
			--todo
			isAnke = true

			for i=index,table.getn(liangCards) do
				if v == liangCards[i] then
					--todo
					isAnke = false

					index = index + 1

					break
				end
			end
		end

		if isAnke then
			--todo
			
			if playerType == CARD_PLAYERTYPE_MY then
				--todo
				table.insert(cardsTemp, 100 + v)
			else
				table.insert(cardsTemp, -1)
			end
		else
			table.insert(cardsTemp, v)
		end
	end

	table.sort(cardsTemp)

	if playerType == CARD_PLAYERTYPE_MY then
		--todo
		local size = plane:getSize()
		local oriX = 0

		local function onTouchBegan(touch, event)

		    if SZKWX_CHUPAI == 1 then
		    	--todo
		    	cardTemp = nil
		    	local children = plane:getChildren()
		    	for k,v in pairs(children) do
		        	
				    --todo
				    local locationInNode = v:convertToNodeSpace(touch:getLocation())

					local s = v:getContentSize()
					local rect = cc.rect(0, 0, s.width, s.height)
					if cc.rectContainsPoint(rect, locationInNode) then
						-- v:setOpacity(180)
						cardTemp = v
						-- self.cardOriPosition = cardTemp:getPosition()
						if selectedTag == 99 and cardTemp:getTag() == NEW_CARD_TAG then
							--todo
							self.canclick=true
							self.oriSelectedPosition = cardTemp:getPosition()
						else
							self.canclick=false
							return false
						end
			            if self.canclick then
			            	cardTemp:setOpacity(180)
			           		local card_click_flag = cardTemp.card_click or false
				            if card_click_flag == true then
				            	SZKWX_CONTROLLER:playCard(cardTemp.m_value)
				            	return false
				            else
				            	cardTemp.card_click = true
				            	cardTemp:setColor(cc.c3b(250,250,0))
				            end
				        end
					end
				        	
				end
				-- if cardTemp and cardTemp:getTag() ~= NEW_CARD_TAG then
				if cardTemp then
					--todo
					if selectedTag == 99 and cardTemp:getTag() == NEW_CARD_TAG then
						--todo
						self.canMove = true
						self.canclick=true
						self.oriSelectedPosition = cardTemp:getPosition()
					else
						self.canMove = false
						self.canclick=false
						return false
					end
					return true
				else
					return false
				end
		    end

		    return false
		end

		local function onTouchMoved(touch, event)
		    if self.canMove then
		    	--todo
		    	if cardTemp then
			    	local posX = cardTemp:getPositionX()
			    	local posY = cardTemp:getPositionY()
			    	local delta = touch:getDelta()
			    	cardTemp:setPosition(cc.p(posX + delta.x, posY + delta.y))
			    end
		    end
		end

		local function onTouchEnded(touch, event)
		   	if cardTemp then
		   		--todo
		   		local target=event:getCurrentTarget()
		   		target:setOpacity(255)
		   		local offsetY = cardTemp:getPosition().y - cardTemp:getSize().height / 2
		   		if offsetY > plane:getSize().height then
		   			--超出范围，出牌
		   			SZKWX_CONTROLLER:playCard(cardTemp.m_value)
		   			-- cardTemp:removeFromParent()
		   		else
		   			cardTemp:setPosition(self.oriSelectedPosition)

		   			return
		   			
		   		end
		   	end
		end

		local listener1 = cc.EventListenerTouchOneByOne:create()
   		listener1:setSwallowTouches(true)
		listener1:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
		listener1:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
		listener1:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )

		local eventDispatcher = SCENENOW["scene"]:getEventDispatcher()

		for i=1,table.getn(cardsTemp) do
			local cardData = cardsTemp[i]

			local card

			if cardData > 100 then
				--todo
				card = Card:new(playerType, CARD_TYPE_INHAND, CARD_DISPLAY_TYPE_SHOW, cardData - 100)

				card:setColor(cc.c3b(140, 140, 140))
			else
				card = Card:new(playerType, CARD_TYPE_INHAND, CARD_DISPLAY_TYPE_SHOW, cardData)
			end

			card:setTouchEnabled(false)

			eventDispatcher:addEventListenerWithSceneGraphPriority(listener1:clone(), card)
			
			card:setScale(card:getScale() * 1.1)

			card:setPosition(cc.p(oriX + card:getSize().width * card:getScale() / 2, card:getSize().height * card:getScale() / 2))

			plane:addChild(card)

			oriX = oriX + (card:getSize().width - 1.5) * card:getScale()

		end

		plane:setSize(cc.size(oriX + 75 * 1.1, size.height))
	elseif playerType == CARD_PLAYERTYPE_LEFT then
		print("gang lefthand test")
		local size = plane:getSize()

		local count = table.getn(cardsTemp)

		for i=1,count do
			local cardData = cardsTemp[i]

			local card

			if cardData > 0 then
				--todo
				card = Card:new(playerType, CARD_TYPE_LEFTHAND, CARD_DISPLAY_TYPE_SHOW, cardData)
			else
				card = Card:new(playerType, CARD_TYPE_LEFTHAND, CARD_DISPLAY_TYPE_HIDE, cardData)
			end

			card:setPosition(cc.p(size.width / 2, (count - i + 0.5) * 23 + 46))

			plane:addChild(card)
		end

		plane:setSize(cc.size(plane:getSize().width, count * 23 + 46))
	elseif playerType == CARD_PLAYERTYPE_RIGHT then
		--todo
		local size = plane:getSize()
		local oriY = 0

		for i=1,table.getn(cardsTemp) do
			local cardData = cardsTemp[i]

			local card

			if cardData > 0 then
				--todo
				card = Card:new(playerType, CARD_TYPE_LEFTHAND, CARD_DISPLAY_TYPE_SHOW, cardData)
			else
				card = Card:new(playerType, CARD_TYPE_LEFTHAND, CARD_DISPLAY_TYPE_HIDE, cardData)
			end

			card:setPosition(cc.p(size.width / 2, oriY + 23 / 2))

			card:setLocalZOrder(100 - plane:getChildrenCount())

			plane:addChild(card)

			oriY = oriY + 23
		end

		plane:setSize(cc.size(plane:getSize().width, oriY + 46))
	elseif playerType == CARD_PLAYERTYPE_TOP then
		local size = plane:getSize()

		local count = table.getn(cardsTemp)

		for i=1,count do
			local cardData = cardsTemp[i]

			local card

			if cardData > 0 then
				--todo
				card = Card:new(playerType, CARD_TYPE_LEFTHAND, CARD_DISPLAY_TYPE_SHOW, cardData)
			else
				card = Card:new(playerType, CARD_TYPE_LEFTHAND, CARD_DISPLAY_TYPE_HIDE, cardData)
			end

			card:setPosition(cc.p((count - i + 0.5) * 27 + 27 * 1.5, size.height / 2))

			plane:addChild(card)
		end

		plane:setSize(cc.size(count * 27 + 27 * 1.5, plane:getSize().height))
	end
end

function InhandPlaneOperator:cancelSelectingCard(plane)
	if selectedTag == 99 then
		--todo
		return
	end

	SZKWX_CONTROLLER:hideTingHuPlane()

	local selectedCard = plane:getChildByTag(selectedTag)

	if selectedCard then
		--todo
		local oriY = plane:getSize().height / 2

		local position = selectedCard:getPosition()

		if position.y > oriY then
			--todo
			selectedCard:setScale(1.1)
			local offsetX = 0.1 * selectedCard:getSize().width
			selectedCard:setPosition(cc.p(selectedCard:getPosition().x - offsetX / 2, selectedCard:getSize().height * selectedCard:getScale() / 2))

			local tag = selectedCard:getTag()
			tag = tag + 1
			local nextCard = plane:getChildByTag(tag)
			while nextCard do
				--todo
				nextCard:setPosition(cc.p(nextCard:getPosition().x - offsetX, nextCard:getPosition().y))

				tag = tag + 1

				nextCard = plane:getChildByTag(tag)
			end

			selectedTag = 99
		end
	end
end

function InhandPlaneOperator:getNewCard(playerType, plane, value)
	local displayType = CARD_DISPLAY_TYPE_OPPOSIVE
	local seatId = SZKWX_SEAT_TABLE_BY_TYPE[playerType .. ""]
	local tingFlag = SZKWX_GAMEINFO_TABLE[seatId .. ""].ting
	if tingFlag == 1 then
		--todo
		displayType = CARD_DISPLAY_TYPE_SHOW
	end

	if playerType == CARD_PLAYERTYPE_MY then
		--todo
		local card = Card:new(playerType, CARD_TYPE_INHAND, displayType, value)
		card:setTag(NEW_CARD_TAG)

		card:setTouchEnabled(false)

		local size = plane:getSize()

		card:setScale(card:getScale() * 1.1)
		card:setPosition(cc.p(size.width - card:getSize().width / 2 * card:getScale(), card:getSize().height * card:getScale() / 2))

		plane:addChild(card)
		
	elseif playerType == CARD_PLAYERTYPE_LEFT then
		local card = Card:new(playerType, CARD_TYPE_INHAND, displayType, value)
		card:setTag(NEW_CARD_TAG)

		local size = plane:getSize()

		card:setPosition(cc.p(size.width / 2, card:getSize().height / 2))

		plane:addChild(card)
	elseif playerType == CARD_PLAYERTYPE_RIGHT then
		local card = Card:new(playerType, CARD_TYPE_INHAND, displayType, value)
		card:setTag(NEW_CARD_TAG)

		local size = plane:getSize()

		card:setPosition(cc.p(size.width / 2, size.height - card:getSize().height / 2))

		plane:addChild(card)
	elseif playerType == CARD_PLAYERTYPE_TOP then
		local card = Card:new(playerType, CARD_TYPE_INHAND, displayType, value)
		card:setTag(NEW_CARD_TAG)

		local size = plane:getSize()

		card:setPosition(cc.p(30 / 2, size.height / 2))

		plane:addChild(card)
	end
	
end

function InhandPlaneOperator:playCard(playerType, plane)
	-- if not tag then
	-- 	--todo
	-- 	tag = NEW_CARD_TAG
	-- end

	-- local card = plane:getChildByTag(tag)

	-- if not card then
	-- 	--todo
	-- 	return
	-- end

	-- self:showCards(playerType, plane)

	if playerType == CARD_PLAYERTYPE_MY then
		--todo
		selectedTag = 99
	end
end

function InhandPlaneOperator:showTingCards(plane, cards, tingSeq)
	plane:removeAllChildren()

	selectedTag = 99

	local oriX = 0
	local oriY = plane:getSize().height / 2

		for i=1,table.getn(cards) do
			local data = cards[i]

			local isTing = false

			for k,v in pairs(tingSeq) do
				if data == v.card then
					--todo
					isTing = true
					break
				end
			end

			local card = Card:new(CARD_PLAYERTYPE_MY, CARD_TYPE_INHAND, CARD_DISPLAY_TYPE_OPPOSIVE, data)
			card:setScale(card:getScale() * 1.1)
			card:setPosition(cc.p(oriX + card:getSize().width * card:getScale() / 2, card:getSize().height * card:getScale() / 2))
			card:setTag(i)

			if isTing then
				--todo
				card:setTouchEnabled(true)

				card:addTouchEventListener(function(sender, event)

				

				if event == TOUCH_EVENT_ENDED then
					--todo
					print("card value")
					dump(sender.m_value, "card value") 
					dump(sender:getAnchorPoint())

					
					if selectedTag == sender:getTag() then
						
							-- dump(sender.m_value, "liang card test")
							-- SZKWX_CONTROLLER:requestLiang(sender.m_value)
						
					else
						self:cancelSelectingCard(plane)

						local p = sender:getPosition()

						sender:setScale(1.2)
						local offsetX = 0.1 * sender:getSize().width

						sender:setPosition(cc.p(p.x + offsetX / 2, p.y + 30))

						local tag = sender:getTag()
						selectedTag = tag
						tag = tag + 1
						local nextCard = plane:getChildByTag(tag)
						while nextCard do
							--todo
							nextCard:setPosition(cc.p(nextCard:getPosition().x + offsetX, nextCard:getPosition().y))

							tag = tag + 1
							nextCard = plane:getChildByTag(tag)
						end

						for k,v in pairs(tingSeq) do
							if v.card == sender.m_value then
								--todo
								SZKWX_CONTROLLER:showComponentSelectBox(v)

								break
							end
						end
					end
				end

				end)
			else
				card:setTouchEnabled(false)
				card:setColor(cc.c3b(150, 150, 150))
			end

			card:setTag(i)

			plane:addChild(card)

			oriX = oriX + card:getSize().width * card:getScale()
		end

		local width = oriX
		plane:setSize(cc.size(width, plane:getSize().height))
end

return InhandPlaneOperator