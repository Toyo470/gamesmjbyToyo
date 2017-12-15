local Card = require("cs_majiang.card.card")
local cardUtils = require("cs_majiang.utils.cardUtils")

local InhandPlaneOperator = class("InhandPlaneOperator")

local SPLIT_NEWCARD = 25

local selectedTag = 99

local NEW_CARD_TAG = 20

local cardTemp = nil

function InhandPlaneOperator:init(playerType, plane)
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

function InhandPlaneOperator:showCards(playerType, plane, cardDatas)
	plane:removeAllChildren()

	if playerType == CARD_PLAYERTYPE_MY then
		--todo
		local oriX = 0
		local oriY = plane:getSize().height / 2

		local function onTouchBegan(touch, event)
		    if CSMJ_CHUPAI == 1 then
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
					end
				        	
				end
				-- if cardTemp and cardTemp:getTag() ~= NEW_CARD_TAG then
				if cardTemp then
					--todo
					if cardTemp.tingStartus then
						return false
					end

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

						-- return false
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
		   		local offsetY = cardTemp:getPosition().y - cardTemp:getSize().height / 2
		   		if offsetY > plane:getSize().height then
		   			--超出范围，出牌
		   			CSMJ_CONTROLLER:playCard(cardTemp.m_value)
		   			-- cardTemp:removeFromParent()
		   		else
		   			cardTemp:setPosition(self.oriSelectedPosition)

		   			-- return	

		   			local locationInNode = cardTemp:convertToNodeSpace(touch:getLocation())
		   			local rect = cc.rect(0, 0, cardTemp:getContentSize().width, cardTemp:getContentSize().height)
					if cc.rectContainsPoint(rect, locationInNode) then
						if selectedTag == cardTemp:getTag() then
						    --出牌
							CSMJ_CONTROLLER:playCard(cardTemp.m_value)
						else
							self:cancelSelectingCard(plane)

							local p = cardTemp:getPosition()

							if self.canMove then
								--todo
								p = self.cardOriPosition
							end

							cardTemp:setScale(1.2)
							local offsetX = 0.1 * cardTemp:getSize().width

							cardTemp:setPosition(cc.p(p.x + offsetX / 2, p.y + 30))

							local tag = cardTemp:getTag()
							selectedTag = tag
							tag = tag + 1
							local nextCard = plane:getChildByTag(tag)
							while nextCard do
								--todo
								nextCard:setPosition(cc.p(nextCard:getPosition().x + offsetX, nextCard:getPosition().y))

								tag = tag + 1
								nextCard = plane:getChildByTag(tag)
							end
						end
					else
						self:cancelSelectingCard(plane)
					end	   			
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

			card:setScale(card:getScale() * 1.1)
			-- card:setAnchorPoint(cc.p(0, 0))
			card:setPosition(cc.p(oriX + card:getSize().width * card:getScale() / 2, card:getSize().height * card:getScale() / 2))

			card:setTouchEnabled(false)
			card.tingStartus = false

			dump(_G.G_CARDS_4_TING_TB, "@@@@@@@@@@@@ - - 99999999999999999999999")
			for tingKey, tingValue in pairs(_G.G_CARDS_4_TING_TB) do
				print("tingValue", tingValue, "data", data)
				if tingValue == data then
					card:setColor(cc.c3b(140, 140, 140))
					card.tingStartus = true
				end
			end

			eventDispatcher:addEventListenerWithSceneGraphPriority(listener1:clone(), card)

			card:setTag(i)

			plane:addChild(card)

			oriX = oriX + card:getSize().width * card:getScale()
		end

		local width = oriX + 81 * 1.1
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


-- function InhandPlaneOperator:showCard4QiShouHu(playerType, plane, cardDatas, _huType)
function InhandPlaneOperator:showCard4QiShouHu(playerType, plane, cardDatas, _liangCards)
	plane:removeAllChildren()

	dump(_liangCards, "-------------   liangCards -=++++++++++++++ ")

	local cardsTemp = {}

	local cardCountTb = {}

	local liangCardsCount = {}
	
	for _, c in pairs(_liangCards) do
		if liangCardsCount[c] == nil then
			liangCardsCount[c] = 0
		end
		liangCardsCount[c] = liangCardsCount[c] + 1
	end

	dump(liangCardsCount, "----- @@@@  InhandPlaneOperator:showCard4QiShouHu")

	local liangCounter = 0
	for idx, c in pairs(cardDatas) do
		if playerType == CARD_PLAYERTYPE_MY then
			if liangCardsCount[c] ~= nil and liangCardsCount[c] > 0 then
				cardsTemp[idx] = c + 100
				liangCardsCount[c] = liangCardsCount[c] - 1
			else
				cardsTemp[idx] = c
			end
		else
			if liangCardsCount[c] ~= nil and liangCardsCount[c] > 0 then
				cardsTemp[idx] = c
				liangCardsCount[c] = liangCardsCount[c] - 1
			else
				cardsTemp[idx] = -1
			end
		end

		if c == 0 and _liangCards[idx] ~= nil then
			cardsTemp[idx] = _liangCards[idx]
		end
	end

	-- for k, v in pairs(cardDatas) do
	-- 	print("k------------", k, v)
	-- 	if cardCountTb[v] == nil then
	-- 		print(v, "@@@@@@@@@@@@ == 1")
	-- 		cardCountTb[v] = 1
	-- 	else
	-- 		cardCountTb[v] = cardCountTb[v] + 1
	-- 		print(v, "@@@@@@@@@@@@ == 1----", cardCountTb[v])
	-- 	end
	-- end

	-- print(_huType, "++++++++++++ @@@@  InhandPlaneOperator:showCard4QiShouHu")
	-- dump(cardCountTb, "----- @@@@  InhandPlaneOperator:showCard4QiShouHu")

	-- local huType = 0
	-- local keziCount = 0
	-- for k, v in pairs(cardCountTb) do
	-- 	if v == 4 then
	-- 		huType = HU_TYPE_SI_XI 
	-- 		keziCount = keziCount + 1
	-- 	elseif v == 3 then
	-- 		keziCount = keziCount + 1
	-- 	end
	-- end

	-- if keziCount >= 2 and huType ~= HU_TYPE_SI_XI then
	-- -- if keziCount >= 0 and huType ~= HU_TYPE_SI_XI then
	-- 	huType = HU_TYPE_LIU_LIU_SHUN
	-- end

	-- for k, v in pairs(cardDatas) do
	-- 	if huType == HU_TYPE_SI_XI then
	-- 		if cardCountTb[v] == 4 then
	-- 			if playerType == CARD_PLAYERTYPE_MY then
	-- 				table.insert(cardsTemp, v + 100)
	-- 			else
	-- 				table.insert(cardsTemp, -1)
	-- 			end
	-- 		else
	-- 			table.insert(cardsTemp, v)
	-- 		end

	-- 	elseif huType == HU_TYPE_LIU_LIU_SHUN then
	-- 		if cardCountTb[v] == 3 then
	-- 			if playerType == CARD_PLAYERTYPE_MY then
	-- 				table.insert(cardsTemp, v + 100)
	-- 			else
	-- 				table.insert(cardsTemp, -1)
	-- 			end
	-- 		else
	-- 			table.insert(cardsTemp, v)
	-- 		end

	-- 	else
	-- 		table.insert(cardsTemp, v)
	-- 	end
	-- end


	dump(cardsTemp, "----- @@@@  InhandPlaneOperator:showCard4QiShouHu")

	table.sort(cardsTemp)

	if playerType == CARD_PLAYERTYPE_MY then
		--todo
		local size = plane:getSize()
		local oriX = 0

		for i=1, table.getn(cardsTemp) do
			local cardData = cardsTemp[i]

			local card

			if cardData > 100 then
				-- todo
				card = Card:new(playerType, CARD_TYPE_INHAND, CARD_DISPLAY_TYPE_SHOW, cardData - 100)

				-- card:setColor(cc.c3b(140, 140, 140))
			else
				card = Card:new(playerType, CARD_TYPE_INHAND, CARD_DISPLAY_TYPE_OPPOSIVE, cardData)
			end

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

			if cardData ~= -1 then
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

			if cardData ~= -1 then
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

			if cardData ~= -1 then
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


function InhandPlaneOperator:showCardsForAll(playerType, plane, cardDatas, anke)
	plane:removeAllChildren()

	local cardsTemp = {}
	for k,v in pairs(cardDatas) do
		local isAnke = false
		for m,n in pairs(anke) do
			if v == n then
				--todo
				isAnke = true
				break
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

		for i=1,table.getn(cardsTemp) do
			local cardData = cardsTemp[i]

			local card

			if cardData > 100 then
				-- todo
				card = Card:new(playerType, CARD_TYPE_INHAND, CARD_DISPLAY_TYPE_SHOW, cardData - 100)

				card:setColor(cc.c3b(140, 140, 140))
			else
				card = Card:new(playerType, CARD_TYPE_INHAND, CARD_DISPLAY_TYPE_SHOW, cardData)
			end

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

			if cardData ~= -1 then
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

			if cardData ~= -1 then
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

			if cardData ~= -1 then
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
	if playerType == CARD_PLAYERTYPE_MY then
		--todo
		local card = Card:new(playerType, CARD_TYPE_INHAND, CARD_DISPLAY_TYPE_OPPOSIVE, value)
		card:setTag(NEW_CARD_TAG)

		card:setTouchEnabled(false)

		-- card:addTouchEventListener(function(sender, event)
		-- 		if event == TOUCH_EVENT_ENDED then
		-- 			--todo
		-- 			if sender:getTag() == NEW_CARD_TAG and CSMJ_CHUPAI == 1 then
		-- 				--todo
		-- 				CSMJ_CONTROLLER:playCard(value)
		-- 			end
		-- 		end
		-- 	end)

		local size = plane:getSize()

		card:setScale(card:getScale() * 1.1)

		card:setPosition(cc.p(size.width - card:getSize().width * card:getScale() / 2, card:getSize().height * card:getScale() / 2))

		plane:addChild(card)

		-- local function onTouchBegan(touch, event)

		--     if CSMJ_CHUPAI == 1 then
		--     	--todo
		--     	dump("newcard touch began")
		--     	cardTemp = nil
		--     	local children = plane:getChildren()
		--     	dump(children, "newcard touch began")
		--     	for k,v in pairs(children) do
		        	
		-- 		    --todo
		-- 		    local locationInNode = v:convertToNodeSpace(touch:getLocation())

		-- 		    dump(locationInNode, "newcard touch began" .. v.m_value)

		-- 			local s = v:getContentSize()
		-- 			local rect = cc.rect(0, 0, s.width, s.height)
		-- 			if cc.rectContainsPoint(rect, locationInNode) then
		-- 				-- v:setOpacity(180)
		-- 				cardTemp = v
		-- 				self.cardOriPosition = cardTemp:getPosition()
		-- 			end
				        	
		-- 		end
		-- 		if cardTemp then
		-- 			--todo
		-- 			if selectedTag == 99 then
		-- 				--todo
		-- 				self.canMove = true
		-- 			else
		-- 				self.canMove = false
		-- 			end
		-- 			return true
		-- 		else
		-- 			return false
		-- 		end
		--     end

		--     return false
		-- end

		-- local function onTouchMoved(touch, event)
		--     if self.canMove then
		--     	--todo
		--     	local posX = cardTemp:getPositionX()
		--     	local posY = cardTemp:getPositionY()
		--     	local delta = touch:getDelta()
		--     	cardTemp:setPosition(cc.p(posX + delta.x, posY + delta.y))
		--     end
		-- end

		-- local function onTouchEnded(touch, event)
		--    	if cardTemp then
		--    		--todo
		--    		local offsetY = cardTemp:getPosition().y - cardTemp:getSize().height / 2
		--    		if offsetY > plane:getSize().height then
		--    			--超出范围，出牌
		--    			CSMJ_CONTROLLER:playCard(cardTemp.m_value)
		--    			cardTemp:removeFromParent()
		--    		else
		--    			if selectedTag == cardTemp:getTag() then
		-- 				--出牌
		-- 				CSMJ_CONTROLLER:playCard(cardTemp.m_value)
		-- 			else
		-- 				self:cancelSelectingCard(plane)

		-- 				local p = self.cardOriPosition

		-- 				cardTemp:setScale(1.2)
		-- 				local offsetX = 0.2 * 54

		-- 				cardTemp:setPosition(cc.p(p.x + offsetX / 2, p.y + 30))

		-- 				local tag = cardTemp:getTag()
		-- 				selectedTag = tag
		-- 				tag = tag + 1
		-- 				local nextCard = plane:getChildByTag(tag)
		-- 				while nextCard do
		-- 					--todo
		-- 					nextCard:setPosition(cc.p(nextCard:getPosition().x + offsetX, nextCard:getPosition().y))

		-- 					tag = tag + 1
		-- 					nextCard = plane:getChildByTag(tag)
		-- 				end
		-- 			end
		--    		end
		--    	end
		-- end

		-- listener1 = cc.EventListenerTouchOneByOne:create()
  --  		listener1:setSwallowTouches(true)
		-- listener1:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
		-- listener1:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
		-- listener1:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )

		-- local eventDispatcher = plane:getEventDispatcher()
		
		-- eventDispatcher:addEventListenerWithSceneGraphPriority(listener1:clone(), card)

		
	elseif playerType == CARD_PLAYERTYPE_LEFT then
		local card = Card:new(playerType, CARD_TYPE_INHAND, CARD_DISPLAY_TYPE_OPPOSIVE, value)
		card:setTag(NEW_CARD_TAG)

		local size = plane:getSize()

		card:setPosition(cc.p(size.width / 2, 44 / 2))

		plane:addChild(card)
	elseif playerType == CARD_PLAYERTYPE_RIGHT then
		local card = Card:new(playerType, CARD_TYPE_INHAND, CARD_DISPLAY_TYPE_OPPOSIVE, value)
		card:setTag(NEW_CARD_TAG)

		local size = plane:getSize()

		card:setPosition(cc.p(size.width / 2, size.height - 44 / 2))

		plane:addChild(card)
	elseif playerType == CARD_PLAYERTYPE_TOP then
		local card = Card:new(playerType, CARD_TYPE_INHAND, CARD_DISPLAY_TYPE_OPPOSIVE, value)
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

	-- card:removeFromParent()

	-- if playerType == CARD_PLAYERTYPE_MY then
	-- 	--todo
	-- 	if tag ~= NEW_CARD_TAG then
	-- 		--todo
	-- 		dump(NEW_CARD_TAG, "NEW_CARD_TAG")
	-- 		local newCard = plane:getChildByTag(NEW_CARD_TAG)

	-- 		if newCard then
	-- 			--todo
				
	-- 			local children = plane:getChildren()

	-- 			cardUtils:insertCards(cardDatas, newCardData)

	-- 			self:showCards(playerType, plane)
	-- 		else
	-- 			local offsetX = 52 * 1.2
	-- 			tag = tag + 1
	-- 			local nextCard = plane:getChildByTag(tag)
	-- 			while nextCard do
	-- 				--todo
	-- 				nextCard:setPosition(cc.p(nextCard:getPosition().x - offsetX, nextCard:getPosition().y))
	-- 				nextCard:setTag(tag - 1)

	-- 				tag = tag + 1
	-- 				nextCard = plane:getChildByTag(tag)
	-- 			end

	-- 			plane:setSize(cc.size(plane:getSize().width - 52, plane:getSize().height))
	-- 		end

			
	-- 	end
	-- 	selectedTag = 99
	-- elseif playerType == CARD_PLAYERTYPE_LEFT then
	-- 	if tag ~= NEW_CARD_TAG then
	-- 		--todo
	-- 		local newCard = plane:getChildByTag(NEW_CARD_TAG)

	-- 		if newCard then
	-- 			--todo
				
	-- 			local cardDatas = {}
	-- 			local children = plane:getChildren()
	-- 			for i=1,table.getn(children) do
	-- 				local child = children[i]
	-- 				if child:getTag() ~= NEW_CARD_TAG then
	-- 					--todo
	-- 					local cardData = {}
	-- 					cardData["value"] = child.m_value

	-- 					table.insert(cardDatas, cardData)
	-- 				end
	-- 			end

	-- 			local newCardData = {}
	-- 			newCardData["value"] = newCard.m_value

	-- 			cardUtils:insertCards(cardDatas, newCardData)

	-- 			self:showCards(playerType, plane, cardDatas)
	-- 		else
	-- 			local offsetY = 22

	-- 			local nextTag = tag + 1
	-- 			tag = tag - 1
	-- 			local preCard = plane:getChildByTag(tag)
	-- 			while preCard do
	-- 				--todo
	-- 				preCard:setPosition(cc.p(preCard:getPosition().x, preCard:getPosition().y - offsetY))

	-- 				tag = tag - 1

	-- 				if tag == 0 then
	-- 					--todo
	-- 					break
	-- 				end

	-- 				preCard = plane:getChildByTag(tag)
	-- 			end
	-- 			local nextCard = plane:getChildByTag(nextTag)
	-- 			while nextCard do
	-- 				--todo
	-- 				nextCard:setTag(nextTag - 1)

	-- 				nextTag = nextTag + 1

	-- 				nextCard = plane:getChildByTag(nextTag)
	-- 			end

	-- 			plane:setSize(cc.size(plane:getSize().width, plane:getSize().height - offsetY))
	-- 		end

			
	-- 	end
	-- elseif playerType == CARD_PLAYERTYPE_RIGHT then
	-- 	if tag ~= NEW_CARD_TAG then
	-- 		--todo
	-- 		local newCard = plane:getChildByTag(NEW_CARD_TAG)

	-- 		if newCard then
	-- 			--todo
				
	-- 			local cardDatas = {}
	-- 			local children = plane:getChildren()
	-- 			for i=1,table.getn(children) do
	-- 				local child = children[i]
	-- 				if child:getTag() ~= NEW_CARD_TAG then
	-- 					--todo
	-- 					local cardData = {}
	-- 					cardData["value"] = child.m_value

	-- 					table.insert(cardDatas, cardData)
	-- 				end
	-- 			end

	-- 			local newCardData = {}
	-- 			newCardData["value"] = newCard.m_value

	-- 			cardUtils:insertCards(cardDatas, newCardData)

	-- 			self:showCards(playerType, plane, cardDatas)
	-- 		else
	-- 			local offsetY = 22
	-- 			tag = tag + 1
	-- 			local nextCard = plane:getChildByTag(tag)
	-- 			while nextCard do
	-- 				--todo
	-- 				nextCard:setPosition(cc.p(nextCard:getPosition().x, nextCard:getPosition().y - offsetY))
	-- 				nextCard:setTag(tag - 1)

	-- 				tag = tag + 1
	-- 				nextCard = plane:getChildByTag(tag)
	-- 			end

	-- 			plane:setSize(cc.size(plane:getSize().width, plane:getSize().height - offsetY))
	-- 		end

			
	-- 	end
	-- elseif playerType == CARD_PLAYERTYPE_TOP then
	-- 	if tag ~= NEW_CARD_TAG then
	-- 		--todo
	-- 		local newCard = plane:getChildByTag(NEW_CARD_TAG)

	-- 		if newCard then
	-- 			--todo
				
	-- 			local cardDatas = {}
	-- 			local children = plane:getChildren()
	-- 			for i=1,table.getn(children) do
	-- 				local child = children[i]
	-- 				if child:getTag() ~= NEW_CARD_TAG then
	-- 					--todo
	-- 					local cardData = {}
	-- 					cardData["value"] = child.m_value

	-- 					table.insert(cardDatas, cardData)
	-- 				end
	-- 			end

	-- 			local newCardData = {}
	-- 			newCardData["value"] = newCard.m_value

	-- 			cardUtils:insertCards(cardDatas, newCardData)

	-- 			self:showCards(playerType, plane, cardDatas)
	-- 		else
	-- 			local offsetX = 30
	-- 			local nextTag = tag + 1
	-- 			tag = tag - 1
	-- 			local preCard = plane:getChildByTag(tag)
	-- 			while preCard do
	-- 				--todo
	-- 				preCard:setPosition(cc.p(preCard:getPosition().x - offsetX, preCard:getPosition().y))

	-- 				tag = tag - 1

	-- 				if tag == 0 then
	-- 					--todo
	-- 					break
	-- 				end

	-- 				preCard = plane:getChildByTag(tag)
	-- 			end

	-- 			local nextCard = plane:getChildByTag(nextTag)
	-- 			while nextCard do
	-- 				--todo
	-- 				nextCard:setTag(nextTag - 1)

	-- 				nextTag = nextTag + 1

	-- 				nextCard = plane:getChildByTag(nextTag)
	-- 			end

	-- 			plane:setSize(cc.size(plane:getSize().width - offsetX, plane:getSize().height))
	-- 		end
			
	-- 	end
	-- end

end

return InhandPlaneOperator
