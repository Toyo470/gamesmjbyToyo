local inhandPlaneOperator = require("yk_majiang.operator.InhandPlaneOperator")
local lefthandPlaneOperator = require("yk_majiang.operator.LefthandPlaneOperator")
local controlPlaneOperator = require("yk_majiang.operator.ControlPlaneOperator")
local outhandPlaneOperator = require("yk_majiang.operator.OuthandPlaneOperator")
local userInfoPlaneOperator = require("yk_majiang.operator.UserInfoPlaneOperator")
local jiapiaoPlaneOperator = require("yk_majiang.operator.JiapiaoPlaneOperator")

local PlayerPlaneOperator = class("PlayerPlaneOperator")

local CHILD_NAME_INHANDPLANE = "inhand_plane"
local CHILD_NAME_LEFTHANDPLANE = "lefthand_plane"
local CHILD_NAME_OUTHANDPLANE = "outhand_plane"
local CHILD_NAME_CONTROL_PLANE = "control_plane"
local CHILD_NAME_CONTROL_IMG = "control_img"
local CHILD_NAME_PLAYERINFO_PLANE = "player_plane"
local CHILD_NAME_LG_PLANE = "lg_plane"
local CHILD_NAME_TING_HU_PLANE = "ting_hu_plane"

local CHILD_NAME_JIAPIAO_PLANE = "jiapiao_plane"
local CHILD_NAME_PIAO_IMG = "piao_img"

local CHILD_NAME_PIAO_PLANE = "piao_plane"
local CHILD_NAME_PIAO_LB = "piao_lb"

function PlayerPlaneOperator:init(playerType, plane)
	local inhandPlane = plane:getChildByName(CHILD_NAME_INHANDPLANE)
	local lefthandPlane = plane:getChildByName(CHILD_NAME_LEFTHANDPLANE)
	local outhandPlane = plane:getChildByName(CHILD_NAME_OUTHANDPLANE)
	local controlPlane = plane:getChildByName(CHILD_NAME_CONTROL_PLANE)
	local controlImg = plane:getChildByName(CHILD_NAME_CONTROL_IMG)
	local userInfoPlane = plane:getChildByName(CHILD_NAME_PLAYERINFO_PLANE)
	local lgPlane = plane:getChildByName(CHILD_NAME_LG_PLANE)
	local tingHuPlane = plane:getChildByName(CHILD_NAME_TING_HU_PLANE)

	local piao_plane = plane:getChildByName(CHILD_NAME_PIAO_PLANE)
	local jiapiao_plane = plane:getChildByName(CHILD_NAME_JIAPIAO_PLANE)
	local piao_img = plane:getChildByName(CHILD_NAME_PIAO_IMG)

	local huipai_bx = plane:getChildByName("huipai_bx")

	if piao_img then
		--todo
		piao_img:setVisible(false)
	end

	if piao_plane then
		--todo
		piao_plane:setVisible(false)
	end
	
	if jiapiao_plane then
		--todo
		jiapiao_plane:setVisible(false)

		jiapiaoPlaneOperator:init(jiapiao_plane)
	end

	if huipai_bx then

		huipai_bx:setVisible(false)
	end

	inhandPlaneOperator:init(playerType, inhandPlane)
	lefthandPlaneOperator:init(playerType, lefthandPlane)
	outhandPlaneOperator:init(playerType, outhandPlane)
	controlPlaneOperator:init(playerType, controlImg, controlPlane, lgPlane, tingHuPlane)
	userInfoPlaneOperator:init(userInfoPlane)
	
end

function PlayerPlaneOperator:clearGameDatas(playerType, plane)
	local inhandPlane = plane:getChildByName(CHILD_NAME_INHANDPLANE)
	local lefthandPlane = plane:getChildByName(CHILD_NAME_LEFTHANDPLANE)
	local outhandPlane = plane:getChildByName(CHILD_NAME_OUTHANDPLANE)
	local userInfoPlane = plane:getChildByName(CHILD_NAME_PLAYERINFO_PLANE)
	local controlPlane = plane:getChildByName(CHILD_NAME_CONTROL_PLANE)
	local lgPlane = plane:getChildByName(CHILD_NAME_LG_PLANE)
	local tingHuPlane = plane:getChildByName(CHILD_NAME_TING_HU_PLANE)
	local piao_plane = plane:getChildByName(CHILD_NAME_PIAO_PLANE)
	local jiapiao_plane = plane:getChildByName(CHILD_NAME_JIAPIAO_PLANE)
	local piao_img = plane:getChildByName(CHILD_NAME_PIAO_IMG)

	if piao_img then
		--todo
		piao_img:setVisible(false)
	end

	if piao_plane then
		--todo
		piao_plane:setVisible(false)
	end
	
	if jiapiao_plane then
		--todo
		jiapiao_plane:setVisible(false)
	end

	if huipai_bx then

		huipai_bx:setVisible(false)
	end


	inhandPlaneOperator:init(playerType, inhandPlane)
	lefthandPlaneOperator:init(playerType, lefthandPlane)
	outhandPlaneOperator:init(playerType, outhandPlane)
	controlPlaneOperator:clearGameDatas(controlPlane, lgPlane, tingHuPlane)
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

function PlayerPlaneOperator:showCards(playerType, plane,tingSeq)
	local inhandPlane = plane:getChildByName(CHILD_NAME_INHANDPLANE)

	local seatId = YKMJ_SEAT_TABLE_BY_TYPE[playerType .. ""]

	local cards = YKMJ_GAMEINFO_TABLE[seatId .. ""].hand
	
	-- local tingFlag = YKMJ_GAMEINFO_TABLE[seatId .. ""].ting
	-- local anke = YKMJ_GAMEINFO_TABLE[seatId .. ""].anke

	-- if tingFlag ~= 1 or YKMJ_ROOM.isBufenLiang == 1 then
		--todo
	inhandPlaneOperator:showCards(playerType, inhandPlane,cards,tingSeq)
	-- else
	-- 	inhandPlaneOperator:showCardsForAll(playerType, inhandPlane, cards, anke)
	-- end
	
	self:reLocate(playerType, plane)
end

function PlayerPlaneOperator:showControlPlane(plane, controlType)
	local controlPlane = plane:getChildByName(CHILD_NAME_CONTROL_PLANE)

	if controlPlane then
		--todo

		--dump(controlType, "controlType test")
		controlPlaneOperator:showPlane(controlPlane, controlType)

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

function PlayerPlaneOperator:getNewCard(playerType, plane, value,tingSeq)
	local inhandPlane = plane:getChildByName(CHILD_NAME_INHANDPLANE)

	if inhandPlane then
		--todo
		inhandPlaneOperator:getNewCard(playerType, inhandPlane, value,tingSeq)
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

--6个参数
function PlayerPlaneOperator:control(playerType, plane, progCards, controlType,tingSeq,fromplayerType)
	local lefthandPlane = plane:getChildByName(CHILD_NAME_LEFTHANDPLANE)
	local controlImg = plane:getChildByName(CHILD_NAME_CONTROL_IMG)

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
        
        --5个参数
		lefthandPlaneOperator:addProg(playerType, lefthandPlane, progCards, controlType,fromplayerType)

		self:showCards(playerType, plane, tingSeq)
		
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
    
    if  data.xfgFengCount then
		if data.xfgFengCount > 0 then
			--todo
			for i=1,data.xfgFengCount/4 do
				--dump(data.xfgFengCount, "xfgCount4次数")
				local xfgCard = {}
				xfgCard.cards = {}
				xfgCard.type = CONTROL_TYPE_XUANFENG4

				for i=49,52 do
					table.insert(xfgCard.cards, i)
				end
		      table.insert(progCards, xfgCard)
			 end
		end
	end

    if  data.xfgJianCount then
		if data.xfgJianCount > 0 then
			--todo
			for i=1,data.xfgJianCount/3 do
				-- --dump(data.xfgCount3, "xfgCount3次数")
				local xfgCard = {}
				xfgCard.cards = {}
				xfgCard.type = CONTROL_TYPE_XUANFENG3

				for i=65,67 do
					table.insert(xfgCard.cards, i)
				end
		      table.insert(progCards, xfgCard)
			 end
		end
	end



	local lefthandPlane = plane:getChildByName(CHILD_NAME_LEFTHANDPLANE)

	if lefthandPlane then
		--todo
		lefthandPlaneOperator:redraw(playerType, lefthandPlane, progCards)
	end
    
	self:showCards(playerType, plane, data.tingCards)

	local outhandPlane = plane:getChildByName(CHILD_NAME_OUTHANDPLANE)

	if outhandPlane then
		--todo
		outhandPlaneOperator:redraw(playerType, outhandPlane, data.outCards)
	end

    if playerType == CARD_PLAYERTYPE_MY then
		if YKMJ_GAMEINFO_TABLE[YKMJ_MY_USERINFO.seat_id .. ""].ting==1 then
			self:showTingHuPlane(plane, data.tingHuCards)
		end
	end
end

function PlayerPlaneOperator:showTingCards(plane, tingSeq)
	local inhandPlane = plane:getChildByName(CHILD_NAME_INHANDPLANE)

	local seatId = YKMJ_MY_USERINFO.seat_id

	local cards = YKMJ_GAMEINFO_TABLE[seatId .. ""].hand

	inhandPlaneOperator:showTingCards(inhandPlane, cards, tingSeq)

end

function PlayerPlaneOperator:removeLatestOutCard(plane, card)
	local outPlane = plane:getChildByName(CHILD_NAME_OUTHANDPLANE)

	if outPlane then
		return outhandPlaneOperator:removeLatestOutCard(outPlane, card)
	end

	return false
end

function PlayerPlaneOperator:removeLatestOutCard2(plane, card)
	local outPlane = plane:getChildByName(CHILD_NAME_OUTHANDPLANE)

	if outPlane then
		return outhandPlaneOperator:removeLatestOutCard2(outPlane, card)
	end

	return false
end

function PlayerPlaneOperator:showLgSelectBox(plane, lgCards)
	local lgPlane = plane:getChildByName(CHILD_NAME_LG_PLANE)

	if lgPlane then
		--todo
		controlPlaneOperator:showLgSelectBox(lgPlane, lgCards)

		local inhandPlane = plane:getChildByName(CHILD_NAME_INHANDPLANE)

		local size = inhandPlane:getSize()
		local position = inhandPlane:getPosition()

		local x = position.x + size.width - 75 - lgPlane:getSize().width

		lgPlane:setPosition(cc.p(x, lgPlane:getPosition().y))
	end
end

function PlayerPlaneOperator:showTingHuPlane(plane, tingHuCards)
	local tingHuPlane = plane:getChildByName(CHILD_NAME_TING_HU_PLANE)

	if tingHuPlane then
		--todo
		controlPlaneOperator:showTingHuPlane(tingHuPlane, tingHuCards)
	end
end

function PlayerPlaneOperator:hideTingHuPlane(plane)
	local tingHuPlane = plane:getChildByName(CHILD_NAME_TING_HU_PLANE)
	-- local tingFlag = YKMJ_GAMEINFO_TABLE[YKMJ_MY_USERINFO.seat_id .. ""].ting
	if tingHuPlane then
		--todo
		tingHuPlane:setVisible(false)
	end
end

function PlayerPlaneOperator:showCardsForHu(playerType, plane, cardDatas,hucard)
	local inhandPlane = plane:getChildByName(CHILD_NAME_INHANDPLANE)

	if inhandPlane then
		--todo
		inhandPlaneOperator:showCardsForAll(playerType, inhandPlane, cardDatas,{},hucard)
	end
end

function PlayerPlaneOperator:getHeadNode(plane)
	local infoPlane = plane:getChildByName(CHILD_NAME_PLAYERINFO_PLANE)

	return userInfoPlaneOperator:getHeadNode(infoPlane)
end

function PlayerPlaneOperator:showNetworkImg(plane, flag)
	local infoPlane = plane:getChildByName(CHILD_NAME_PLAYERINFO_PLANE)

	userInfoPlaneOperator:showNetworkImg(infoPlane, flag)
end

function PlayerPlaneOperator:showJiapiaoPlane(plane, flag)
	local jiapiaoPlane = plane:getChildByName(CHILD_NAME_JIAPIAO_PLANE)

	jiapiaoPlane:setVisible(flag)
end

function PlayerPlaneOperator:showPiaoImg(plane, piao, flag)
	local piaoImg = plane:getChildByName(CHILD_NAME_PIAO_IMG)

	piaoImg:setVisible(flag)

	if flag then
		--todo

		local imgPath = "majong_bujia_bt_p.png"
		if piao == 1 then
			imgPath = "majong_jiagang_bt_p.png"
		elseif piao == 2 then
			imgPath = "majong_jiaerpiao_bt_p.png"
		end

		piaoImg:loadTexture("yk_majiang/image/" .. imgPath)
	end
end

function PlayerPlaneOperator:showPiaoPlane(plane, piao, flag)
	local piaoPlane = plane:getChildByName(CHILD_NAME_PIAO_PLANE)
	local piaoLb = piaoPlane:getChildByName(CHILD_NAME_PIAO_LB)

	piaoPlane:setVisible(false)

	if flag then
		--todo

		local txt = "不加"
		if piao == 1 then
			txt = "加钢"
		elseif piao == 2 then
			txt = "加二飘"
		end

		piaoLb:setString(txt)
	else
		piaoPlane:setVisible(false)
	end
end

--显示墙头牌
function PlayerPlaneOperator:HuiPai(plane,qiangtoupai)
	local card = require("yk_majiang.card.card")
    local huipai_box=plane:getChildByName("huipai_bx")
    if qiangtoupai>0 then
   		 huipai_box:setVisible(true)
   	else
   		 huipai_box:setVisible(false)
	end
    -- huipai_box:removeAllChildren()
    local value = qiangtoupai
    local card = card:new(CARD_PLAYERTYPE_MY, CARD_TYPE_INHAND, CARD_DISPLAY_TYPE_OPPOSIVE, value)
	local size = card:getSize()
	local scale = (huipai_box:getSize().height - 20) / size.height
	card:setScale(scale)
	-- card:setColor(cc.c3b(250,250,0))
	card:setPosition(cc.p(huipai_box:getSize().width / 2, huipai_box:getSize().height / 2))
    huipai_box:addChild(card)
end

--显示相同的出牌
function PlayerPlaneOperator:showSameCard(plane,value)
   	local outPlane = plane:getChildByName(CHILD_NAME_OUTHANDPLANE)
	if outPlane then
		  outcardnodes = outPlane:getChildren()
			if outcardnodes then
				for i,v in pairs(outcardnodes) do
			    if v.m_value == value then
			       v:setColor(cc.c3b(255,255,0))
				end
				end
		    end	
	end
end

--隐藏相同的出牌
function PlayerPlaneOperator:hideSameCard(plane)
    local outPlane = plane:getChildByName(CHILD_NAME_OUTHANDPLANE)

    if outPlane then
    	outcardnodes=outPlane:getChildren()
    	if outcardnodes then
    		for i,v in pairs(outcardnodes) do
    			v:setColor(cc.c3b(255,255,255))
    		end
    	end
	end 
end

return PlayerPlaneOperator
