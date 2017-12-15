local Card = require("yk_majiang.card.card")

local LefthandPlaneOperator = class("LefthandPlaneOperator")

local LEFTHAND_SPLIT = 10

function LefthandPlaneOperator:init(playerType, plane)
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

function LefthandPlaneOperator:addProg(playerType, plane, progCards, controlType,fromplayerType)
    
	if table.getn(progCards) == 4 then   --去除第四张牌的显示
		table.remove(progCards, 4)
	end

    if bit.band(controlType, GANG_TYPE_BU) > 0 then   --补杠
		--todo
		self:addGangCard(playerType, plane, progCards[1], false)
	else
		if bit.band(controlType, CONTROL_TYPE_GANG) > 0 then   --明杠暗杠
			--todo
			local isAg
			if bit.band(controlType, GANG_TYPE_AN) > 0 then
				isAg = true
			else
				isAg = false	
			end
			self:addCards(playerType, plane, progCards,isAg)

			self:addGangCard(playerType, plane, progCards[1], isAg,fromplayerType)

		elseif bit.band(controlType, CONTROL_TYPE_XUANFENG4) > 0  then  --旋风杠
			self:addCards(playerType, plane, progCards,true)
			self:addGangCard(playerType, plane,XFGNUM, true)
            XFGNUM=XFGNUM+1
		else                 --吃，中发白旋风，碰
			self:addCards(playerType, plane, progCards,false,fromplayerType)

		end
	end
	
end

function LefthandPlaneOperator:addGangCard(playerType, plane, card, isAg,fromplayerType)
	local floorCard = plane:getChildByName(card .. "")
	if not floorCard then
		return
	end
  
	local showType
	if isAg then
		showType = CARD_DISPLAY_TYPE_HIDE
	else
		showType = CARD_DISPLAY_TYPE_SHOW
	end

	local cardNode = Card:new(playerType, CARD_TYPE_LEFTHAND, showType, card,fromplayerType)
	local p = floorCard:getPosition()

	if playerType == CARD_PLAYERTYPE_MY then
		cardNode:setPosition(cc.p(p.x, p.y + 12))
	elseif playerType == CARD_PLAYERTYPE_LEFT then
		cardNode:setPosition(cc.p(p.x, p.y + 12))
	elseif playerType == CARD_PLAYERTYPE_RIGHT then
		cardNode:setPosition(cc.p(p.x, p.y + 12))
	elseif playerType == CARD_PLAYERTYPE_TOP then
		cardNode:setPosition(cc.p(p.x, p.y + 12))
	end
	cardNode:setLocalZOrder(200)
	plane:addChild(cardNode)
end

function LefthandPlaneOperator:addCards(playerType, plane, cardDatas,isAg,fromplayerType)
	if table.getn(cardDatas) < 3 then
		--todo
		return
	end
	local isSame
	if cardDatas[1] == cardDatas[2] then
		--todo
		isSame = true
	else
		isSame = false
	end
     
    local isXFG=false
	if cardDatas[1]==49 and cardDatas[2]==50 then 
		isXFG=true
	end

	local showType
	if isAg then
		showType = CARD_DISPLAY_TYPE_HIDE
	else
		showType = CARD_DISPLAY_TYPE_SHOW
	end

	if playerType == CARD_PLAYERTYPE_MY then
		--todo
		local size = plane:getSize()
		local oriX = size.width

		for i=1,table.getn(cardDatas) do
			local cardData = cardDatas[i]

			local card 	
            if i == 2 then
            	card = Card:new(playerType, CARD_TYPE_LEFTHAND, CARD_DISPLAY_TYPE_SHOW, cardData,_,fromplayerType)
            else 
            	card = Card:new(playerType, CARD_TYPE_LEFTHAND, CARD_DISPLAY_TYPE_SHOW, cardData)
            end

			card:setPosition(cc.p(oriX + card:getSize().width * card:getScale() / 2, card:getSize().height * card:getScale() / 2))

			plane:addChild(card)

			oriX = oriX + (card:getSize().width - 2) * card:getScale()

			if i == 2 and isSame then
				card:setName(cardData .. "")
			end

			if i == 2 and isXFG==true then
				card:setName(XFGNUM.."")
			end
		end

		plane:setSize(cc.size(oriX + LEFTHAND_SPLIT, plane:getSize().height))

	elseif playerType == CARD_PLAYERTYPE_LEFT then

		local size = plane:getSize()

		local count = table.getn(cardDatas)
		local addHeight = count * 23 + LEFTHAND_SPLIT

		local children = plane:getChildren()
		for i=1,table.getn(children) do
			local child = children[i]
			child:setPosition(child:getPosition().x, child:getPosition().y + addHeight)
		end

		for i=1,count do
			local cardData = cardDatas[i]

            local card
            if i == 2 then
			card = Card:new(playerType, CARD_TYPE_LEFTHAND, showType, cardData,_,fromplayerType)
            else
            card = Card:new(playerType, CARD_TYPE_LEFTHAND, showType, cardData)
            end

			card:setPosition(cc.p(card:getSize().width / 2, (count - i + 0.5) * 23))

			plane:addChild(card)

			if i == 2 and isSame then
				card:setName(cardData .. "")
			end

			if i == 2 and isXFG==true then
				card:setName(XFGNUM.."")
			end
		end

		plane:setSize(cc.size(plane:getSize().width, plane:getSize().height + addHeight))

	elseif playerType == CARD_PLAYERTYPE_RIGHT then

		local size = plane:getSize()
		local oriY = size.height

		for i=1,table.getn(cardDatas) do
			local cardData = cardDatas[i]

            local card
            if i == 2 then
			card = Card:new(playerType, CARD_TYPE_LEFTHAND, showType, cardData, _,fromplayerType)
            else
            card = Card:new(playerType, CARD_TYPE_LEFTHAND, showType, cardData)
            end

			card:setPosition(cc.p(card:getSize().width / 2, oriY + 23 / 2))

			card:setLocalZOrder(100 - plane:getChildrenCount())

			plane:addChild(card)

			oriY = oriY + 23

			if i == 2 and isSame then
				--todo
				card:setName(cardData .. "")
			end

			if i == 2 and isXFG==true then
				card:setName(XFGNUM.."")
			end
		end

		plane:setSize(cc.size(plane:getSize().width, oriY + LEFTHAND_SPLIT))
	elseif playerType == CARD_PLAYERTYPE_TOP then
		local size = plane:getSize()

		local count = table.getn(cardDatas)
		local addWidth = count * 27 + LEFTHAND_SPLIT

		local children = plane:getChildren()
		for i=1,table.getn(children) do
			local child = children[i]
			child:setPosition(child:getPosition().x + addWidth, child:getPosition().y)
		end

		for i=1,count do
			local cardData = cardDatas[i]

            local card
            if i == 2 then
			card = Card:new(playerType, CARD_TYPE_LEFTHAND, showType, cardData,_,fromplayerType)
            else
            card = Card:new(playerType, CARD_TYPE_LEFTHAND, showType, cardData)
            end

			card:setPosition(cc.p((count - i + 0.5) * 27, card:getSize().height / 2))

			plane:addChild(card)

			if i == 2 and isSame then
				card:setName(cardData .. "")
			end

			if i == 2 and isXFG==true then
				card:setName(XFGNUM.."")
			end
		end

		plane:setSize(cc.size(plane:getSize().width + addWidth, plane:getSize().height))
	end
end

function LefthandPlaneOperator:redraw(playerType, plane, progCards)
	local count = table.getn(progCards)

	for i=1,count do
		self:addProg(playerType, plane, progCards[i].cards, progCards[i].type)
	end
end

return LefthandPlaneOperator