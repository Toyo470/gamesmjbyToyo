local inhandPlaneOperator = require("cs_majiang.operator.InhandPlaneOperator")
local lefthandPlaneOperator = require("cs_majiang.operator.LefthandPlaneOperator")
local controlPlaneOperator = require("cs_majiang.operator.ControlPlaneOperator")
local outhandPlaneOperator = require("cs_majiang.operator.OuthandPlaneOperator")
local userInfoPlaneOperator = require("cs_majiang.operator.UserInfoPlaneOperator")
local seleteOpeLayer		= require("cs_majiang.seleteOpeLayer")

local PlayerPlaneOperator = class("PlayerPlaneOperator")

local CHILD_NAME_INHANDPLANE = "inhand_plane"
local CHILD_NAME_LEFTHANDPLANE = "lefthand_plane"
local CHILD_NAME_OUTHANDPLANE = "outhand_plane"
local CHILD_NAME_CONTROL_PLANE = "control_plane"
local CHILD_NAME_CONTROL_IMG = "control_img"
local CHILD_NAME_PLAYERINFO_PLANE = "player_plane"

function PlayerPlaneOperator:init(playerType, plane)
	local inhandPlane = plane:getChildByName(CHILD_NAME_INHANDPLANE)
	local lefthandPlane = plane:getChildByName(CHILD_NAME_LEFTHANDPLANE)
	local outhandPlane = plane:getChildByName(CHILD_NAME_OUTHANDPLANE)
	local controlPlane = plane:getChildByName(CHILD_NAME_CONTROL_PLANE)
	local controlImg = plane:getChildByName(CHILD_NAME_CONTROL_IMG)
	local userInfoPlane = plane:getChildByName(CHILD_NAME_PLAYERINFO_PLANE)

	inhandPlaneOperator:init(playerType, inhandPlane)
	lefthandPlaneOperator:init(playerType, lefthandPlane)
	outhandPlaneOperator:init(playerType, outhandPlane)
	controlPlaneOperator:init(playerType, controlImg, controlPlane)
	userInfoPlaneOperator:init(userInfoPlane)
end

function PlayerPlaneOperator:clearGameDatas(playerType, plane)
	local inhandPlane = plane:getChildByName(CHILD_NAME_INHANDPLANE)
	local lefthandPlane = plane:getChildByName(CHILD_NAME_LEFTHANDPLANE)
	local outhandPlane = plane:getChildByName(CHILD_NAME_OUTHANDPLANE)
	local userInfoPlane = plane:getChildByName(CHILD_NAME_PLAYERINFO_PLANE)
	local controlPlane = plane:getChildByName(CHILD_NAME_CONTROL_PLANE)

	inhandPlaneOperator:init(playerType, inhandPlane)
	lefthandPlaneOperator:init(playerType, lefthandPlane)
	outhandPlaneOperator:init(playerType, outhandPlane)
	controlPlaneOperator:clearGameDatas(controlPlane)
	userInfoPlaneOperator:clearGameDatas(userInfoPlane)
end

function PlayerPlaneOperator:reLocate(playerType, plane)
	local inhandPlane = plane:getChildByName(CHILD_NAME_INHANDPLANE)
	local lefthandPlane = plane:getChildByName(CHILD_NAME_LEFTHANDPLANE)

	if playerType == CARD_PLAYERTYPE_MY then
		--todo
		local x = (plane:getSize().width - lefthandPlane:getSize().width - inhandPlane:getSize().width) / 2 + lefthandPlane:getSize().width

		inhandPlane:setPosition(cc.p(x, inhandPlane:getPosition().y))

		local controlPlane = plane:getChildByName(CHILD_NAME_CONTROL_PLANE)
		
		local size = inhandPlane:getSize()
		local position = inhandPlane:getPosition()

		local x = position.x + size.width - 75 - controlPlane:getSize().width

		controlPlane:setPosition(cc.p(x, controlPlane:getPosition().y))
	elseif playerType == CARD_PLAYERTYPE_LEFT then
		local y = plane:getSize().height - lefthandPlane:getSize().height - (plane:getSize().height - lefthandPlane:getSize().height - inhandPlane:getSize().height) / 2

		inhandPlane:setPosition(cc.p(inhandPlane:getPosition().x, y))
	elseif playerType == CARD_PLAYERTYPE_RIGHT then
		local y = (plane:getSize().height - lefthandPlane:getSize().height - inhandPlane:getSize().height) / 2 + lefthandPlane:getSize().height

		inhandPlane:setPosition(cc.p(inhandPlane:getPosition().x, y))

	elseif playerType == CARD_PLAYERTYPE_TOP then
		local x = plane:getSize().width - lefthandPlane:getSize().width - (plane:getSize().width - lefthandPlane:getSize().width - inhandPlane:getSize().width - 170) / 2

		inhandPlane:setPosition(cc.p(x, inhandPlane:getPosition().y))
	end
end

function PlayerPlaneOperator:showCards(playerType, plane)
	local inhandPlane = plane:getChildByName(CHILD_NAME_INHANDPLANE)

	local seatId = CSMJ_SEAT_TABLE_BY_TYPE[playerType .. ""]

	local cards = CSMJ_GAMEINFO_TABLE[seatId .. ""].hand

	inhandPlaneOperator:showCards(playerType, inhandPlane, cards)

	self:reLocate(playerType, plane)
end

function PlayerPlaneOperator:showControlPlane(plane, controlType, _callBackFunc)
	local controlPlane = plane:getChildByName(CHILD_NAME_CONTROL_PLANE)

	if controlPlane then
		--todo
		dump(controlType, "controlType test")
		controlPlaneOperator:showPlane(controlPlane, controlType, _callBackFunc)

		local inhandPlane = plane:getChildByName(CHILD_NAME_INHANDPLANE)

		if inhandPlane then
			--todo
			local size = inhandPlane:getSize()
			local position = inhandPlane:getPosition()

			local x = position.x + size.width - 75 - controlPlane:getSize().width

			controlPlane:setPosition(cc.p(x, controlPlane:getPosition().y))
		end
	end
end

function PlayerPlaneOperator:hideControlPlane(plane)
	local controlPlane = plane:getChildByName(CHILD_NAME_CONTROL_PLANE)
	-- seleteOpeLayer:onClose()

	if controlPlane then
		--todo
		controlPlane:setVisible(false)
	end
end

function PlayerPlaneOperator:cancelSelectingCard(plane)
	local inhandPlane = plane:getChildByName(CHILD_NAME_INHANDPLANE)

	if inhandPlane then
		--todo
		inhandPlaneOperator:cancelSelectingCard(inhandPlane)
	end
end

function PlayerPlaneOperator:getNewCard(playerType, plane, value)
	local inhandPlane = plane:getChildByName(CHILD_NAME_INHANDPLANE)

	if inhandPlane then
		--todo
		inhandPlaneOperator:getNewCard(playerType, inhandPlane, value)
	end
end

function PlayerPlaneOperator:playCard(playerType, plane, tag, value)
	local inhandPlane = plane:getChildByName(CHILD_NAME_INHANDPLANE)

	if inhandPlane then
		--todo
		inhandPlaneOperator:playCard(playerType, inhandPlane)
		self:showCards(playerType, plane)
	end

	--todo
	local outhandPlane = plane:getChildByName(CHILD_NAME_OUTHANDPLANE)

	if outhandPlane then
		--todo
		outhandPlaneOperator:playCard(playerType, value, outhandPlane)
	end

	self:reLocate(playerType, plane)
end

function PlayerPlaneOperator:control(playerType, plane, progCards, controlType)
	local lefthandPlane = plane:getChildByName(CHILD_NAME_LEFTHANDPLANE)
	local controlImg = plane:getChildByName(CHILD_NAME_CONTROL_IMG)

	dump(playerType .. " " .. controlType, "hu bug test")
	controlPlaneOperator:showImage(controlImg, controlType)

	if lefthandPlane then
		--todo
		-- if controlType == CONTROL_TYPE_GANG then
		-- 	--todo
		-- 	local cardDatas = {}
		-- 	for i=1,3 do
		-- 		local cardData = {}
		-- 		cardData["value"] = 6

		-- 		table.insert(cardDatas, cardData)
		-- 	end

		-- 	lefthandPlaneOperator:addCards(playerType, lefthandPlane, cardDatas)
		-- end

		lefthandPlaneOperator:addProg(playerType, lefthandPlane, progCards, controlType)

		self:showCards(playerType, plane)
		
	end

	self:reLocate(playerType, plane)
end

function PlayerPlaneOperator:showPlayerInfo(userInfo, plane)
	local infoPlane = plane:getChildByName(CHILD_NAME_PLAYERINFO_PLANE)
	userInfoPlaneOperator:showInfo(userInfo, infoPlane)

	return infoPlane
end

function PlayerPlaneOperator:showZhuang(plane)
	local infoPlane = plane:getChildByName(CHILD_NAME_PLAYERINFO_PLANE)

	userInfoPlaneOperator:showZhuang(true, infoPlane)
end

function PlayerPlaneOperator:redrawGameInfo(playerType, plane, data)
	local progCards = {}

	if data.gCount > 0 then
		--todo
		local controlCards = data.gCards
		for i=1,data.gCount do
			local controlCard = controlCards[i]
			local gCard = {}
			gCard.cards = {}
			local gType
			if controlCard.isAg > 0 then
				--todo
				gType = GANG_TYPE_AN
			else
				gType = GANG_TYPE_PG
			end

			gCard.type = gType

			for i=1,4 do
				table.insert(gCard.cards, controlCard.card)
			end

			table.insert(progCards, gCard)
		end
	end

	if data.pCount > 0 then
		--todo
		local controlCards = data.pCards
		for i=1,data.pCount do
			local controlCard = controlCards[i]
			local pCard = {}
			pCard.cards = {}
			pCard.type = CONTROL_TYPE_PENG

			for i=1,3 do
				table.insert(pCard.cards, controlCard)
			end

			table.insert(progCards, pCard)
		end
	end

	local p = nil
	local cs = nil
	for i=1,data.cCount do
		if i % 3 == 1 then
			--todo
			p = {}
			p.type = CONTROL_TYPE_CHI
			cs = {}
			p.cards = cs
			table.insert(cs, data.cCards[i])
		elseif i % 3 == 0 then
			table.insert(cs, data.cCards[i])

			table.insert(progCards, p)
		else
			table.insert(cs, data.cCards[i])
		end
	end

	local lefthandPlane = plane:getChildByName(CHILD_NAME_LEFTHANDPLANE)

	if lefthandPlane then
		--todo
		lefthandPlaneOperator:redraw(playerType, lefthandPlane, progCards)
	end

	self:showCards(playerType, plane)

	local outhandPlane = plane:getChildByName(CHILD_NAME_OUTHANDPLANE)

	if outhandPlane then
		--todo
		outhandPlaneOperator:redraw(playerType, outhandPlane, data.outCards)
	end
end

function PlayerPlaneOperator:removeLatestOutCard(plane, card)
	local outPlane = plane:getChildByName(CHILD_NAME_OUTHANDPLANE)

	if outPlane then
		--todo
		return outhandPlaneOperator:removeLatestOutCard(outPlane, card)
	end

	return false
end

function PlayerPlaneOperator:showCardsForHu(playerType, plane, cardDatas)
	local inhandPlane = plane:getChildByName(CHILD_NAME_INHANDPLANE)

	if inhandPlane then
		-- todo
		inhandPlaneOperator:showCardsForAll(playerType, inhandPlane, cardDatas, {})
	end
end



-- function PlayerPlaneOperator:showCardsForQiShouHu(playerType, plane, cardDatas, _huType)
function PlayerPlaneOperator:showCardsForQiShouHu(playerType, plane, cardDatas, _liangCards)
	local inhandPlane = plane:getChildByName(CHILD_NAME_INHANDPLANE)

	if inhandPlane then
		-- todo
		-- inhandPlaneOperator:showCard4QiShouHu(playerType, inhandPlane, cardDatas, _huType)
		inhandPlaneOperator:showCard4QiShouHu(playerType, inhandPlane, cardDatas, _liangCards)
	end
end



function PlayerPlaneOperator:getHeadNode(plane)
	local infoPlane = plane:getChildByName(CHILD_NAME_PLAYERINFO_PLANE)

	return userInfoPlaneOperator:getHeadNode(infoPlane)
end

--[[
	@brief:设置玩家离线/在线状态
	@author:Jhao.
]]
function PlayerPlaneOperator:setUserOnline(plane, _isOnline)
	userInfoPlaneOperator:setUserOnline(plane, _isOnline)
end



return PlayerPlaneOperator
