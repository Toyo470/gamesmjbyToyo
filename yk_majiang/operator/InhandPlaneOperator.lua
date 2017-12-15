local Card = require("yk_majiang.card.card")
local cardUtils = require("yk_majiang.utils.cardUtils")

local InhandPlaneOperator = class("InhandPlaneOperator")

local SPLIT_NEWCARD = 25

local selectedTag = 99

local NEW_CARD_TAG = 20

local cardTemp = nil

-- cc.UserDefault:getInstance():getIntegerForKey("OperateStyle")  or
-- local OperateStyle =  GOPERATESTYLE

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

function InhandPlaneOperator:showCards(playerType, plane, cardDatas,tingSeq)
	 plane:removeAllChildren()

   if playerType == CARD_PLAYERTYPE_MY then	
   	    local i=0
        local teshuqingkuang=0

	    if HUIPAI~=nil then
	    for k,v in pairs(cardDatas) do
			if v == HUIPAI[1] then
				table.remove(cardDatas,k)
				table.insert(cardDatas,1,v)
				i=i+1
			end
		end
		end

		if i==#cardDatas then
		   teshuqingkuang=1
		end

		selectedTag = 99

		local oriX = 0
		local oriY = plane:getSize().height / 2

	  if  GOPERATESTYLE== 2  then   --操控方式
---------------------------------------------------滑动出牌方式----------------------------------------------
		local function onTouchBegan(touch, event)
		    if YKMJ_CHUPAI == 1 then

		    	cardTemp = nil
		    	local children = plane:getChildren()
		    	for k,v in pairs(children) do
		        	
				    local locationInNode = v:convertToNodeSpace(touch:getLocation())

					local s = v:getContentSize()
					local rect = cc.rect(0, 0, s.width, s.height)
					if cc.rectContainsPoint(rect, locationInNode) then

						cardTemp = v
						self.cardOriPosition = cardTemp:getPosition()
					end
				        	
				end
				if cardTemp then  --and cardTemp:getTag() ~= NEW_CARD_TAG
                                    
					--会牌返回
		              local untouchable = false
		              for k,v in pairs(HUIPAI) do
		                   if cardTemp.m_value == v then
		                      untouchable = true
		                   break
		                   end
		              end

		              if untouchable == true and teshuqingkuang~=1 then
		            	  return
		              end

					YKMJ_CONTROLLER:hideSameCard()
					YKMJ_CONTROLLER:hideTingHuPlane()
					local  myhandcardnode = plane:getChildren()  --手牌不会为0
		            for i,v in pairs(myhandcardnode) do
		            	v:setColor(cc.c3b(255,255,255))
		            end
                    
                    cardTemp:setColor(cc.c3b(250, 250, 0))
					YKMJ_CONTROLLER:showSameCard(cardTemp.m_value)
		            
					if tingSeq~={} and  tingSeq~=nil then  --听队列存在时才遍历
					  for k,v in pairs(tingSeq) do
						if v.card == cardTemp.m_value then
							--显示听得牌
							YKMJ_CONTROLLER:showTingHuPlane(CARD_PLAYERTYPE_MY,v.tingHuCards)
						break
						end
					  end
					end

					--todo
					if selectedTag == 99 then
						--todo
						self.canMove = true

						self.oriSelectedPosition = cardTemp:getPosition()
					else
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

		    	local posX = cardTemp:getPositionX()
		    	local posY = cardTemp:getPositionY()
		    	local delta = touch:getDelta()
		    	cardTemp:setPosition(cc.p(posX + delta.x, posY + delta.y))
		    end
		end

		local function onTouchEnded(touch, event)
		   	if cardTemp then

		   		local offsetY = cardTemp:getPosition().y - cardTemp:getSize().height / 2
		   		if offsetY > plane:getSize().height then
		   			--超出范围，出牌
		   			YKMJ_CONTROLLER:playCard(cardTemp.m_value)
		   			cardTemp:removeFromParent()
		   		else
		   			cardTemp:setPosition(self.oriSelectedPosition)
		   			return

		   -- 			local locationInNode = cardTemp:convertToNodeSpace(touch:getLocation())
		   -- 			local rect = cc.rect(0, 0, cardTemp:getContentSize().width, cardTemp:getContentSize().height)
					-- if cc.rectContainsPoint(rect, locationInNode) then
					-- 	if selectedTag == cardTemp:getTag() then
					-- 	    --出牌
					-- 		YKMJ_CONTROLLER:playCard(cardTemp.m_value)
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

			 	local if_huipai = false
				for k,v in pairs(HUIPAI) do
					if cardDatas[i] == v then
					if_huipai = true
					break
					end
				end

			local data = cardDatas[i]

			local card = Card:new(playerType, CARD_TYPE_INHAND, CARD_DISPLAY_TYPE_OPPOSIVE, data,if_huipai)

			card:setScale(1.1)
			card:setPosition(cc.p(oriX + card:getSize().width * 1.1 / 2, card:getSize().height * 1.1 / 2))
			if  if_huipai == true then
	       		card:setColor(cc.c3b(255, 255, 0))
	       		card:setOpacity(230)
       		end
			card:setTouchEnabled(false)

			eventDispatcher:addEventListenerWithSceneGraphPriority(listener1:clone(), card)

			card:setTag(i)

			plane:addChild(card)

			oriX = oriX + card:getSize().width * 1.1
		end

		local width = oriX + 81
		plane:setSize(cc.size(width, plane:getSize().height))

--------------------------------------------------双击和滑动出牌-----------------------------------------------
    elseif  GOPERATESTYLE== 1  then  --操控方式

		local function onTouchBegan(touch, event)
		    if YKMJ_CHUPAI == 1 then

		    	cardTemp = nil
		    	local children = plane:getChildren()

		    	for k,v in pairs(children) do
		        	
				    local locationInNode = v:convertToNodeSpace(touch:getLocation())

					local s = v:getContentSize()
					local rect = cc.rect(0, 0, s.width, s.height)
					if cc.rectContainsPoint(rect, locationInNode) then
						cardTemp = v
						self.cardOriPosition = cardTemp:getPosition()
					end
				        	
				end

				if cardTemp  then  --and cardTemp:getTag() ~= NEW_CARD_TAG
					--会牌返回

		              local untouchable = false
		              for k,v in pairs(HUIPAI) do
		                   if cardTemp.m_value == v then
		                      untouchable = true
		                   break
		                   end
		              end
                     
		              if untouchable == true and teshuqingkuang~=1 then
		            	  return
		              end

					YKMJ_CONTROLLER:hideSameCard()
					YKMJ_CONTROLLER:hideTingHuPlane()

					local  myhandcardnode = plane:getChildren()  --手牌不会为0
		            for i,v in pairs(myhandcardnode) do
		            	v:setColor(cc.c3b(255,255,255))
		            end
                    
                    cardTemp:setColor(cc.c3b(250, 250, 0))
					YKMJ_CONTROLLER:showSameCard(cardTemp.m_value)
		            
					if tingSeq~={} and  tingSeq~=nil then  --听队列存在时才遍历
					  for k,v in pairs(tingSeq) do
						if v.card == cardTemp.m_value then
							--显示听得牌
							YKMJ_CONTROLLER:showTingHuPlane(CARD_PLAYERTYPE_MY,v.tingHuCards)
						break
						end
					  end
					end

					if selectedTag == 99 then

						self.canMove = true
					else
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
			if cardTemp then
		    if self.canMove then

		    	local posX = cardTemp:getPositionX()
		    	local posY = cardTemp:getPositionY()
		    	local delta = touch:getDelta()
		    	cardTemp:setPosition(cc.p(posX + delta.x, posY + delta.y))
		    end
			end
		end

		local function onTouchEnded(touch, event)
		   	if cardTemp then

		   		local offsetY = cardTemp:getPosition().y - cardTemp:getSize().height / 2
		   		if offsetY > plane:getSize().height then
		   			--超出范围，出牌
		   			YKMJ_CONTROLLER:playCard(cardTemp.m_value)
		   			cardTemp:removeFromParent()
		   		else
		   			local locationInNode = cardTemp:convertToNodeSpace(touch:getLocation())
		   			local rect = cc.rect(0, 0, cardTemp:getContentSize().width, cardTemp:getContentSize().height)
					if cc.rectContainsPoint(rect, locationInNode) then
						if selectedTag == cardTemp:getTag() then
						    --出牌
							YKMJ_CONTROLLER:playCard(cardTemp.m_value)
						else
							self:cancelSelectingCard(plane)

							local p = cardTemp:getPosition()

							if self.canMove then

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

				local if_huipai = false
				for k,v in pairs(HUIPAI) do
				if cardDatas[i] == v then
				if_huipai = true
				break
				end
				end

			local data = cardDatas[i]
				local card = Card:new(playerType, CARD_TYPE_INHAND, CARD_DISPLAY_TYPE_OPPOSIVE, data,if_huipai)
					card:setScale(card:getScale() * 1.1)
					card:setPosition(cc.p(oriX + card:getSize().width * card:getScale() / 2, card:getSize().height * card:getScale() / 2))

					card:setTouchEnabled(false)

					eventDispatcher:addEventListenerWithSceneGraphPriority(listener1:clone(), card)
			                
					if  if_huipai == true then
			       		card:setColor(cc.c3b(255, 255, 0))
			       		card:setOpacity(230)
			   		end

					card:setTag(i)

					plane:addChild(card)

					oriX = oriX + card:getSize().width * card:getScale()
		end

		local width = oriX + 81 * 1.1
		plane:setSize(cc.size(width, plane:getSize().height))
	end --end operateStyle judge
-------------------------------------------------------------------------------------------------------------
	elseif playerType == CARD_PLAYERTYPE_LEFT then
		
		local oriX = plane:getSize().width / 2
		local count = table.getn(cardDatas)
		local totalHeight = count * 22 + 11 + 44
		local oriY = totalHeight - 22

		for i=1,count do
			local data = cardDatas[i]

			local card = Card:new(playerType, CARD_TYPE_INHAND, CARD_DISPLAY_TYPE_OPPOSIVE, data)

			card:addTouchEventListener(function(sender, event)
					--print("123")
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

function InhandPlaneOperator:showCardsForAll(playerType, plane, cardDatas, anke, hucard)
	plane:removeAllChildren()

	local cardsTemp = {}
	-- for k,v in pairs(cardDatas) do
	-- -- 	local isAnke = false
	-- -- 	-- for m,n in pairs(anke) do
	-- -- 	-- 	if v == n then
	-- -- 	-- 		--todo
	-- -- 	-- 		isAnke = true
	-- -- 	-- 		break
	-- -- 	-- 	end
	-- -- 	-- end
	-- -- 	if isAnke then
	-- -- 		--todo
			
	-- -- 		if playerType == CARD_PLAYERTYPE_MY then
	-- -- 			--todo
	-- -- 			table.insert(cardsTemp, 100 + v)
	-- -- 		else
	-- -- 			table.insert(cardsTemp, -1)
	-- -- 		end
	-- -- 	else
	--      if  v == hucard then
	--      	table.remove(cardDatas, k)
	--      	break
	--      end
	-- 		-- table.insert(cardsTemp, v)
	-- -- 	end
	-- end

	cardsTemp = cardDatas
	for k,v in pairs(cardsTemp) do
		 if  v == hucard then
		 	table.remove(cardsTemp, k)
		 	break
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
            
        	local if_huipai = false
			for k,v in pairs(HUIPAI) do
				if cardData== v then
				if_huipai = true
				break
				end
			end

			card = Card:new(playerType, CARD_TYPE_INHAND, CARD_DISPLAY_TYPE_SHOW, cardData,if_huipai)

			card:setScale(card:getScale() * 1.1)

			card:setPosition(cc.p(oriX + card:getSize().width * card:getScale() / 2, card:getSize().height * card:getScale() / 2))

			plane:addChild(card)

			oriX = oriX + (card:getSize().width - 1.5) * card:getScale()
		end
        
		card = Card:new(playerType, CARD_TYPE_INHAND, CARD_DISPLAY_TYPE_SHOW, hucard)
		card:setColor(cc.c3b(250,250,0))
		card:setScale(card:getScale() * 1.1)
		card:setPosition(cc.p(oriX + card:getSize().width * card:getScale() / 2, card:getSize().height * card:getScale() / 2))
  		plane:addChild(card)

  		plane:setSize(cc.size(oriX + 75 * 1.1, size.height))
	elseif playerType == CARD_PLAYERTYPE_LEFT then

		local size = plane:getSize()

		local count = table.getn(cardsTemp)

		for i=1,count do
			local cardData = cardsTemp[i]

			local card

			local if_huipai = false
			for k,v in pairs(HUIPAI) do
				if cardData== v then
				if_huipai = true
				break
				end
			end

			if cardData ~= -1 then
				--todo
				card = Card:new(playerType, CARD_TYPE_LEFTHAND, CARD_DISPLAY_TYPE_SHOW, cardData,if_huipai)
			else
				card = Card:new(playerType, CARD_TYPE_LEFTHAND, CARD_DISPLAY_TYPE_HIDE, cardData,if_huipai)
			end

			card:setPosition(cc.p(size.width / 2, (count - i + 0.5) * 23 + 46))

			plane:addChild(card)
		end

		card = Card:new(playerType, CARD_TYPE_LEFTHAND, CARD_DISPLAY_TYPE_SHOW, hucard)
		card:setColor(cc.c3b(250,250,0))
		card:setPosition(cc.p(size.width / 2, -0.5* 23+46))
		plane:addChild(card)

		plane:setSize(cc.size(plane:getSize().width, count * 23 + 46))
	elseif playerType == CARD_PLAYERTYPE_RIGHT then
		--todo
		local size = plane:getSize()
		local oriY = 0

		for i=1,table.getn(cardsTemp) do
			local cardData = cardsTemp[i]

			local card
			local if_huipai = false
			for k,v in pairs(HUIPAI) do
				if cardData== v then
				if_huipai = true
				break
				end
			end

			if cardData ~= -1 then
				card = Card:new(playerType, CARD_TYPE_LEFTHAND, CARD_DISPLAY_TYPE_SHOW, cardData,if_huipai)
			else
				card = Card:new(playerType, CARD_TYPE_LEFTHAND, CARD_DISPLAY_TYPE_HIDE, cardData,if_huipai)
			end

			card:setPosition(cc.p(size.width / 2, oriY + 23 / 2))

			card:setLocalZOrder(100 - plane:getChildrenCount())

			plane:addChild(card)

			oriY = oriY + 23
		end

		card = Card:new(playerType, CARD_TYPE_LEFTHAND, CARD_DISPLAY_TYPE_SHOW, hucard,if_huipai)
		card:setColor(cc.c3b(250,250,0))
		card:setPosition(cc.p(size.width / 2, oriY + 23 / 2))
		card:setLocalZOrder(100 - plane:getChildrenCount())
		plane:addChild(card)

		plane:setSize(cc.size(plane:getSize().width, oriY + 46))
	elseif playerType == CARD_PLAYERTYPE_TOP then
		local size = plane:getSize()

		local count = table.getn(cardsTemp)

		for i=1,count do
			local cardData = cardsTemp[i]

			local card
			local if_huipai = false
			for k,v in pairs(HUIPAI) do
				if cardData== v then
				if_huipai = true
				break
				end
			end

			if cardData ~= -1 then
				--todo
				card = Card:new(playerType, CARD_TYPE_LEFTHAND, CARD_DISPLAY_TYPE_SHOW, cardData,if_huipai)
			else
				card = Card:new(playerType, CARD_TYPE_LEFTHAND, CARD_DISPLAY_TYPE_HIDE, cardData,if_huipai)
			end

			card:setPosition(cc.p((count - i + 0.5) * 27 + 27 * 1.5, size.height / 2))

			plane:addChild(card)
		end

		card = Card:new(playerType, CARD_TYPE_LEFTHAND, CARD_DISPLAY_TYPE_SHOW, hucard)
		card:setColor(cc.c3b(250,250,0))
		card:setPosition(cc.p(0.5*27, size.height / 2))
		plane:addChild(card)

		plane:setSize(cc.size(count * 27 + 27 * 1.5, plane:getSize().height))
	end

	table.insert(cardsTemp, hucard)   --复原卡组，重要，因为这个数组指针指向renmaindcards
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

function InhandPlaneOperator:getNewCard(playerType, plane, value,tingSeq)
	local displayType = CARD_DISPLAY_TYPE_OPPOSIVE
	local seatId = YKMJ_SEAT_TABLE_BY_TYPE[playerType .. ""]
	-- local tingFlag = YKMJ_GAMEINFO_TABLE[seatId .. ""].ting
	-- if tingFlag == 1 and YKMJ_ROOM.isBufenLiang ~= 1 then
	-- 	--todo
	-- 	displayType = CARD_DISPLAY_TYPE_SHOW
	-- end
    
	if playerType == CARD_PLAYERTYPE_MY then
		--todo
		local if_huipai = false
			for k,v in pairs(HUIPAI) do
				if value == v then
					if_huipai = true
				break
				end
			end

		-- local card = Card:new(playerType, CARD_TYPE_INHAND, displayType, value,if_huipai)
		-- card:setTag(NEW_CARD_TAG)
		-- -- if  if_huipai == true then
		-- -- card:setColor(cc.c3b(140, 140, 140))
		-- -- end

		-- card:addTouchEventListener(function(sender, event)

			
		-- 	    if event == TOUCH_EVENT_BEGAN then
		-- 	    	if  if_huipai==true then
		-- 	    		return
		-- 	    	end
		-- 	    	YKMJ_CONTROLLER:hideSameCard()   
  --               	YKMJ_CONTROLLER:showSameCard(value)
  --               	YKMJ_CONTROLLER:hideTingHuPlane()
		-- 	    end

		-- 		if event == TOUCH_EVENT_ENDED then
		-- 			if  if_huipai==true then
		-- 	    		return
		-- 	    	end 	
                             
  --                   if tingSeq~={} and tingSeq~=nil then   --听牌队列不为空的时候
		-- 	        for k,v in pairs(tingSeq) do
		-- 				if v.card == value then  --当前点的牌在听牌队列的时候
		-- 					--显示听得牌
		-- 					YKMJ_CONTROLLER:showTingHuPlane(CARD_PLAYERTYPE_MY,v.tingHuCards)
		-- 				break
		-- 				end
		-- 		    end
		-- 			end

		-- 			if sender:getTag() == NEW_CARD_TAG and YKMJ_CHUPAI == 1 then
		-- 				--todo
		-- 				YKMJ_CONTROLLER:playCard(value)
		-- 			end
		-- 		end
		-- 	end)

		-- local size = plane:getSize()

		-- card:setScale(card:getScale() * 1.1)
		-- card:setPosition(cc.p(size.width - card:getSize().width / 2 * card:getScale(), card:getSize().height * card:getScale() / 2))
   
		-- plane:addChild(card)
		local card = Card:new(playerType, CARD_TYPE_INHAND, displayType, value,if_huipai)
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

--显示听牌（注意屏蔽会牌）
function InhandPlaneOperator:showTingCards(plane, cardDatas, tingSeq)
    plane:removeAllChildren()
---------------------------------------------------滑动出牌方式------------------------------------
 --    if HUIPAI~=nil then
 --    for k,v in pairs(cards) do
	-- 	if v == HUIPAI[1] then
	-- 		-- cardUtils:removeTableData(cardDatas, k)
	-- 		table.remove(cards,k)
	-- 		table.insert(cards,1,v)
	-- 	end
	-- end
	-- end

  	
 --  	selectedTag = 99
 --  	local playerType = CARD_PLAYERTYPE_MY

 --    local oriX = 0
 --    local oriY = plane:getSize().height / 2
        
	-- 	local function onTouchBegan(touch, event)

	-- 	    if YKMJ_CHUPAI == 1 then
	-- 	    	--todo
	-- 	    	cardTemp = nil
	-- 	    	local children = plane:getChildren()
	-- 	    	for k,v in pairs(children) do
		        	
	-- 			    --todo
	-- 			    local locationInNode = v:convertToNodeSpace(touch:getLocation())

	-- 				local s = v:getContentSize()
	-- 				local rect = cc.rect(0, 0, s.width, s.height)
	-- 				if cc.rectContainsPoint(rect, locationInNode) then
	-- 					-- v:setOpacity(180)
	-- 					cardTemp = v
	-- 					self.cardOriPosition = cardTemp:getPosition()
	-- 				end
				        	
	-- 			end
	-- 			if cardTemp and cardTemp:getTag() ~= NEW_CARD_TAG then
                     
	-- 	            for k,v in pairs(tingSeq) do
	-- 					if v.card == cardTemp.m_value then
	-- 						--显示听得牌
	-- 						if  v.tingHuCards~={} then
	-- 						YKMJ_CONTROLLER:showTingHuPlane(CARD_PLAYERTYPE_MY,v.tingHuCards)
	-- 						end
	-- 					break
	-- 					else   YKMJ_CONTROLLER:hideTingHuPlane()
	-- 					end
	-- 			    end

	-- 				--会牌返回
	-- 	              local untouchable = false
	-- 	              for k,v in pairs(HUIPAI) do
	-- 	                   if cardTemp.m_value == v then
	-- 	                      untouchable = true
	-- 	                   break
	-- 	                   end
	-- 	              end
	-- 	              if untouchable == true then
	-- 	            	return
	-- 	              end
					
 --                    cardTemp:setColor(cc.c3b(250,250,0))
	-- 				--todo
	-- 				if selectedTag == 99 then
	-- 					--todo
	-- 					self.canMove = true

	-- 					self.oriSelectedPosition = cardTemp:getPosition()
	-- 				else
	-- 					self.canMove = false
	-- 				end
	-- 				return true
	-- 			else
	-- 				return false
	-- 			end
	-- 	    end

	-- 	    return false
	-- 	end

	-- 	local function onTouchMoved(touch, event)
	-- 	    if self.canMove then
	-- 	    	--todo
	-- 	    	local posX = cardTemp:getPositionX()
	-- 	    	local posY = cardTemp:getPositionY()
	-- 	    	local delta = touch:getDelta()
	-- 	    	cardTemp:setPosition(cc.p(posX + delta.x, posY + delta.y))
	-- 	    end
	-- 	end

	-- 	local function onTouchEnded(touch, event)
	-- 	   	if cardTemp then
	-- 	   		--todo
	-- 	   		cardTemp:setColor(cc.c3b(255,255,255))
	-- 	   		local offsetY = cardTemp:getPosition().y - cardTemp:getSize().height / 2
	-- 	   		if offsetY > plane:getSize().height then
	-- 	   			--超出范围，出牌
	-- 	   			YKMJ_CONTROLLER:playCard(cardTemp.m_value)
	-- 	   			cardTemp:removeFromParent()
	-- 	   		else

	-- 	   			cardTemp:setPosition(self.oriSelectedPosition)

	-- 	   			return
		   			
	-- 	   		end
	-- 	   	end
	-- 	end

	-- 	local listener1 = cc.EventListenerTouchOneByOne:create()
 --   		listener1:setSwallowTouches(true)
	-- 	listener1:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
	-- 	listener1:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
	-- 	listener1:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )

	-- 	local eventDispatcher = SCENENOW["scene"]:getEventDispatcher()
		    
	-- 	for i=1,table.getn(cards) do

	-- 		 	local if_huipai = false
	-- 			for k,v in pairs(HUIPAI) do
	-- 				if cards[i] == v then
	-- 				if_huipai = true
	-- 				break
	-- 				end
	-- 			end

	-- 		local data = cards[i]

	-- 		local card = Card:new(playerType, CARD_TYPE_INHAND, CARD_DISPLAY_TYPE_OPPOSIVE, data,if_huipai)

	-- 		card:setScale(1.1)
	-- 		-- card:setAnchorPoint(cc.p(0, 0))
	-- 		card:setPosition(cc.p(oriX + card:getSize().width * 1.1 / 2, card:getSize().height * 1.1 / 2))
	-- 		if  if_huipai == true then
 --            card:setColor(cc.c3b(140, 140, 140))
 --       		end
	-- 		card:setTouchEnabled(false)
    
	-- 		eventDispatcher:addEventListenerWithSceneGraphPriority(listener1:clone(), card)

	-- 		card:setTag(i)

	-- 		plane:addChild(card)

	-- 		oriX = oriX + card:getSize().width * 1.1
	-- 	end

	-- 	local width = oriX + 81
	-- 	plane:setSize(cc.size(width, plane:getSize().height))
------------------------------------------------双击出牌和滑动出牌----------------------------------
    local playerType = CARD_PLAYERTYPE_MY 
        
	    if HUIPAI~=nil then
	    for k,v in pairs(cardDatas) do
			if v == HUIPAI[1] then
				-- cardUtils:removeTableData(cardDatas, k)
				table.remove(cardDatas,k)
				table.insert(cardDatas,1,v)
			end
		end
		end

		local oriX = 0
		local oriY = plane:getSize().height / 2

		local function onTouchBegan(touch, event)
		    if YKMJ_CHUPAI == 1 then
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
				if cardTemp and cardTemp:getTag() ~= NEW_CARD_TAG then
					--会牌返回

		              for k,v in pairs(HUIPAI) do
		                   if cardTemp.m_value == v then
		                      return false
		                   end
		              end



					 cardTemp:setColor(cc.c3b(250,250,0))


					if selectedTag == 99 then
						--todoh
						self.canMove = true
					else
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
		   if cardTemp then
			    if self.canMove then
			    	--todo
			    	local posX = cardTemp:getPositionX()
			    	local posY = cardTemp:getPositionY()
			    	local delta = touch:getDelta()
			    	cardTemp:setPosition(cc.p(posX + delta.x, posY + delta.y))
			    end
		    end
		end

		local function onTouchEnded(touch, event)
		   	if cardTemp then

	   			  for k,v in pairs(tingSeq) do
					if v.card == cardTemp.m_value then
						--显示听得牌
						if  v.tingHuCards~={} then
						YKMJ_CONTROLLER:showTingHuPlane(CARD_PLAYERTYPE_MY,v.tingHuCards)
						end
					break
					end
				  end

		   		 cardTemp:setColor(cc.c3b(255,255,255))
		   		--todo
		   		local offsetY = cardTemp:getPosition().y - cardTemp:getSize().height / 2
		   		if offsetY > plane:getSize().height then
		   			--超出范围，出牌
		   			YKMJ_CONTROLLER:playCard(cardTemp.m_value)
		   			cardTemp:removeFromParent()
		   		else
		   			local locationInNode = cardTemp:convertToNodeSpace(touch:getLocation())
		   			local rect = cc.rect(0, 0, cardTemp:getContentSize().width, cardTemp:getContentSize().height)
					if cc.rectContainsPoint(rect, locationInNode) then
						if selectedTag == cardTemp:getTag() then
						    --出牌
							YKMJ_CONTROLLER:playCard(cardTemp.m_value)
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

				local if_huipai = false
				for k,v in pairs(HUIPAI) do
					if cardDatas[i] == v then
						if_huipai = true
						break
					end
				end

			local data = cardDatas[i]
				local card = Card:new(playerType, CARD_TYPE_INHAND, CARD_DISPLAY_TYPE_OPPOSIVE, data,if_huipai)
					card:setScale(card:getScale() * 1.1)
					card:setPosition(cc.p(oriX + card:getSize().width * card:getScale() / 2, card:getSize().height * card:getScale() / 2))
					card:setTouchEnabled(false)
					eventDispatcher:addEventListenerWithSceneGraphPriority(listener1:clone(), card)
			                
					-- if  if_huipai == true then
			  --       	card:setColor(cc.c3b(140, 140, 140))
			  --  		end

					card:setTag(i)

					plane:addChild(card)

					oriX = oriX + card:getSize().width * card:getScale()
		end

		local width = oriX + 81 * 1.1
		plane:setSize(cc.size(width, plane:getSize().height))

end

return InhandPlaneOperator
