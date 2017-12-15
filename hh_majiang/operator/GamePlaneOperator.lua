local Card = require("zz_majiang.card.card")
local playerPlaneOperator = require("zz_majiang.operator.PlayerPlaneOperator")
local centerPlaneOperator = require("zz_majiang.operator.CenterPlaneOperator")

local GamePlaneOperator = class("GamePlaneOperator")

local CHILD_NAME_MY_PLANE = "my_card_plane"
local CHILD_NAME_LEFT_PLANE = "left_card_plane"
local CHILD_NAME_RIGHT_PLANE = "right_card_plane"
local CHILD_NAME_TOP_PLANE = "top_card_plane"

local CHILD_NAME_CENTER_PLANE = "center_plane"
local CHILD_NAME_CARD_POINTER = "card_pointer"
local CHILD_NAME_CARD_BOX = "card_bx"
local CHILD_NAME_REMAIN_CARDS_COUNT_LB = "remain_cards_count_lb"
local CHILD_NAME_REMARK_LB = "remark_lb"
local CHILD_NAME_READY_IMG = "ready_bar"

-- local schedulerID

function GamePlaneOperator:init()
	ZZMJ_REMAIN_CARDS_COUNT = ZZMJ_CARDS_LESS_INIT

	playerPlaneOperator:init(CARD_PLAYERTYPE_MY, self:getPlayerPlane(CARD_PLAYERTYPE_MY))
	playerPlaneOperator:init(CARD_PLAYERTYPE_LEFT, self:getPlayerPlane(CARD_PLAYERTYPE_LEFT))
	playerPlaneOperator:init(CARD_PLAYERTYPE_RIGHT, self:getPlayerPlane(CARD_PLAYERTYPE_RIGHT))
	playerPlaneOperator:init(CARD_PLAYERTYPE_TOP, self:getPlayerPlane(CARD_PLAYERTYPE_TOP))

	local centerPlane = ZZMJ_GAME_PLANE:getChildByName(CHILD_NAME_CENTER_PLANE)
	centerPlaneOperator:init(centerPlane)

	local myPlane = self:getPlayerPlane(CARD_PLAYERTYPE_MY)
	myPlane.noScale = true
	myPlane:onClick(function()
			playerPlaneOperator:cancelSelectingCard(myPlane)
		end)

	ZZMJ_CARD_POINTER = ZZMJ_GAME_PLANE:getChildByName(CHILD_NAME_CARD_POINTER)

	local remain_card_count_lb = ZZMJ_GAME_PLANE:getChildByName(CHILD_NAME_REMAIN_CARDS_COUNT_LB)

	remain_card_count_lb:setString("...")

	local card_bx = ZZMJ_GAME_PLANE:getChildByName(CHILD_NAME_CARD_BOX)
	card_bx:setVisible(false)

	local remark_lb = ZZMJ_GAME_PLANE:getChildByName(CHILD_NAME_REMARK_LB)

	if USER_INFO["gameConfig"] then
		--todo
		remark_lb:setString("红中麻将：" ..USER_INFO["gameConfig"])

	else
		remark_lb:setString("正在读取组局信息")
	end
end

function GamePlaneOperator:showCenterPlane()
	local centerPlane = ZZMJ_GAME_PLANE:getChildByName(CHILD_NAME_CENTER_PLANE)
	centerPlane:setVisible(true)
end

function GamePlaneOperator:clearGameDatas()
	ZZMJ_REMAIN_CARDS_COUNT = ZZMJ_CARDS_LESS_INIT

	ZZMJ_CURRENT_CARDNODE = nil

	playerPlaneOperator:clearGameDatas(CARD_PLAYERTYPE_MY, self:getPlayerPlane(CARD_PLAYERTYPE_MY))
	playerPlaneOperator:clearGameDatas(CARD_PLAYERTYPE_LEFT, self:getPlayerPlane(CARD_PLAYERTYPE_LEFT))
	playerPlaneOperator:clearGameDatas(CARD_PLAYERTYPE_RIGHT, self:getPlayerPlane(CARD_PLAYERTYPE_RIGHT))
	playerPlaneOperator:clearGameDatas(CARD_PLAYERTYPE_TOP, self:getPlayerPlane(CARD_PLAYERTYPE_TOP))

	local centerPlane = ZZMJ_GAME_PLANE:getChildByName(CHILD_NAME_CENTER_PLANE)
	centerPlaneOperator:clearGameDatas(centerPlane)

	local card_bx = ZZMJ_GAME_PLANE:getChildByName(CHILD_NAME_CARD_BOX)
	card_bx:setVisible(false)

	ZZMJ_CARD_POINTER:setPosition(cc.p(-20, -20))

	-- local scheduler = cc.Director:getInstance():getScheduler()

	-- if schedulerID then
	-- 	--todo
	-- 	scheduler:unscheduleScriptEntry(schedulerID)
	-- 	schedulerID = nil
	-- end
end

function GamePlaneOperator:removePlayer(playerType)
	playerPlaneOperator:clearGameDatas(playerType, self:getPlayerPlane(playerType))
end

function GamePlaneOperator:getPlayerPlane(playerType)
	local plane
	if playerType == CARD_PLAYERTYPE_MY then
		--todo
		plane = ZZMJ_GAME_PLANE:getChildByName(CHILD_NAME_MY_PLANE)
	elseif playerType == CARD_PLAYERTYPE_LEFT then
		plane = ZZMJ_GAME_PLANE:getChildByName(CHILD_NAME_LEFT_PLANE)
	elseif playerType == CARD_PLAYERTYPE_RIGHT then
		plane = ZZMJ_GAME_PLANE:getChildByName(CHILD_NAME_RIGHT_PLANE)
	elseif playerType == CARD_PLAYERTYPE_TOP then
		plane = ZZMJ_GAME_PLANE:getChildByName(CHILD_NAME_TOP_PLANE)
	end

	-- dump(plane, "plane test")

	return plane
end

function GamePlaneOperator:playCard(playerType, tag, value)
	playerPlaneOperator:playCard(playerType, self:getPlayerPlane(playerType), tag, value)

	-- local card_bx = ZZMJ_GAME_PLANE:getChildByName(CHILD_NAME_CARD_BOX)

	-- card_bx:setVisible(true)

	-- card_bx:removeAllChildren()

	-- local card = Card:new(CARD_PLAYERTYPE_MY, CARD_TYPE_INHAND, CARD_DISPLAY_TYPE_OPPOSIVE, value)

	-- local size = card:getSize()

	-- local scale = (card_bx:getSize().height - 20) / size.height

	-- card:setScale(scale)

	-- card:setPosition(cc.p(card_bx:getSize().width / 2, card_bx:getSize().height / 2))

	-- card_bx:addChild(card)

	-- local wait = cc.DelayTime:create(1)
	-- local hide = cc.Hide:create()

	-- local seqAction = cc.Sequence:create(wait, hide)

	-- card_bx:runAction(seqAction)


	-- local scheduler = cc.Director:getInstance():getScheduler()  

	-- schedulerID = scheduler:scheduleScriptFunc(function()  
		   
	-- 	   card_bx:setVisible(false)

	-- 	   scheduler:unscheduleScriptEntry(schedulerID)

	-- 	   schedulerID = nil
	-- 	end, 1, false)
end

function GamePlaneOperator:control(playerType, progCards, controlType, tingSeq)
	-- dump(ZZMJ_CURRENT_CARDNODE, "ZZMJ_CURRENT_CARDNODE test")

	if not tolua.isnull(ZZMJ_CURRENT_CARDNODE) and bit.band(controlType, CONTROL_TYPE_HU) == 0 then
		--todo
		ZZMJ_CURRENT_CARDNODE:removeFromParent()

		ZZMJ_CARD_POINTER:setVisible(false)

		ZZMJ_CURRENT_CARDNODE = nil
	end
	
	playerPlaneOperator:control(playerType, self:getPlayerPlane(playerType), progCards, controlType, tingSeq)

	self:beginPlayCard(playerType)
end

function GamePlaneOperator:showPlayerInfo(playerType, userInfo)
	-- dump(userInfo, "player test")
	-- dump(playerType, "player test")
	return playerPlaneOperator:showPlayerInfo(userInfo, self:getPlayerPlane(playerType))
end

function GamePlaneOperator:showZhuang(playerType)
	playerPlaneOperator:showZhuang(self:getPlayerPlane(playerType))
end

function GamePlaneOperator:showCards(playerType,tingSeq)
	playerPlaneOperator:showCards(playerType, self:getPlayerPlane(playerType),tingSeq)
end

function GamePlaneOperator:getNewCard(playerType, value,tingSeq)
	playerPlaneOperator:getNewCard(playerType, self:getPlayerPlane(playerType), value,tingSeq)
	-- playerPlaneOperator:hideControlPlane(self:getPlayerPlane(CARD_PLAYERTYPE_MY))

	self:beginPlayCard(playerType)
end

function GamePlaneOperator:showControlPlane(controlTable)
	ZZMJ_CONTROL_TABLE = controlTable

	local controlType = controlTable["type"]

	if controlType == CONTROL_TYPE_NONE then
		--todo
		return
	end

	playerPlaneOperator:showControlPlane(self:getPlayerPlane(CARD_PLAYERTYPE_MY), controlType)
end

function GamePlaneOperator:hideControlPlane()
	playerPlaneOperator:hideControlPlane(self:getPlayerPlane(CARD_PLAYERTYPE_MY))
end

function GamePlaneOperator:showRemainCardsCount()
	local remain_card_count_lb = ZZMJ_GAME_PLANE:getChildByName(CHILD_NAME_REMAIN_CARDS_COUNT_LB)
    local remark_lb = ZZMJ_GAME_PLANE:getChildByName(CHILD_NAME_REMARK_LB)
    
	if remain_card_count_lb then
		--todo
		local content = ZZMJ_REMAIN_CARDS_COUNT

		if ZZMJ_ROUND then
			--todo
			if USER_INFO["gameConfig"] then
				remark_lb:setString("红中麻将：" .. "第"..ZZMJ_ROUND.."/"..USER_INFO["gameConfig"])
			end	
		end

		remain_card_count_lb:setString(content)
	end
end

function GamePlaneOperator:beginPlayCard(playerType)
	local centerPlane = ZZMJ_GAME_PLANE:getChildByName(CHILD_NAME_CENTER_PLANE)

	if centerPlane then
		--todo
		centerPlaneOperator:beginPlayCard(playerType, centerPlane)
	end
end

function GamePlaneOperator:redrawGameInfo(playerType, data)
	playerPlaneOperator:redrawGameInfo(playerType, self:getPlayerPlane(playerType), data)
end

function GamePlaneOperator:showTingCards(tingSeq)
	playerPlaneOperator:showTingCards(self:getPlayerPlane(CARD_PLAYERTYPE_MY), tingSeq)
end

function GamePlaneOperator:removeLatestOutCard(playerType, card)
	return playerPlaneOperator:removeLatestOutCard(self:getPlayerPlane(playerType), card)
end

function GamePlaneOperator:showLgSelectBox(lgCards)
	playerPlaneOperator:showLgSelectBox(self:getPlayerPlane(CARD_PLAYERTYPE_MY), lgCards)
end

function GamePlaneOperator:showTingHuPlane(playerType, tingHuCards)
	playerPlaneOperator:showTingHuPlane(self:getPlayerPlane(playerType), tingHuCards)
end

function GamePlaneOperator:hideTingHuPlane()
	playerPlaneOperator:hideTingHuPlane(self:getPlayerPlane(CARD_PLAYERTYPE_MY))
end

function GamePlaneOperator:showCardsForHu(playerType, cardDatas)
	playerPlaneOperator:showCardsForHu(playerType, self:getPlayerPlane(playerType), cardDatas)
end

function GamePlaneOperator:getHeadNode(playerType)
	return playerPlaneOperator:getHeadNode(self:getPlayerPlane(playerType))
end

function GamePlaneOperator:showNetworkImg(playerType, flag)
	playerPlaneOperator:showNetworkImg(self:getPlayerPlane(playerType), flag)
end

function GamePlaneOperator:showJiapiaoPlane(flag)
	playerPlaneOperator:showJiapiaoPlane(self:getPlayerPlane(CARD_PLAYERTYPE_MY), flag)
end

function GamePlaneOperator:showPiaoImg(playerType, piao, flag)
	playerPlaneOperator:showPiaoImg(self:getPlayerPlane(playerType), piao, flag)
end

function GamePlaneOperator:showPiaoPlane(playerType, piao, flag)
	playerPlaneOperator:showPiaoPlane(self:getPlayerPlane(playerType), piao, flag)
end

function GamePlaneOperator:clearPiaoImg()
	self:showPiaoImg(CARD_PLAYERTYPE_MY, 0, false)
	self:showPiaoImg(CARD_PLAYERTYPE_LEFT, 0, false)
	self:showPiaoImg(CARD_PLAYERTYPE_RIGHT, 0, false)
	self:showPiaoImg(CARD_PLAYERTYPE_TOP, 0, false)
end

function GamePlaneOperator:HuiPai(playerType,huipai)
	playerPlaneOperator:HuiPai(self:getPlayerPlane(playerType),huipai)
end

--旋转中央方向指示器
function GamePlaneOperator:rotateTimer(zhuang_index)
local centerPlane = ZZMJ_GAME_PLANE:getChildByName(CHILD_NAME_CENTER_PLANE)

	centerPlaneOperator:rotateTimer(zhuang_index,centerPlane)
end
--[[
	@brief:设置玩家准备状态
	@param:_playerType 座位id
	@author:Jhao.
]]
function GamePlaneOperator:setReadyStatus(playerType)
	local panel = self:getPlayerPlane(playerType)
	if panel == nil then return end

	local ready_img = panel:getChildByName(CHILD_NAME_READY_IMG)
	if ready_img ~= nil then 
		ready_img:setVisible(true)	 
	end
	-- dump(playerType,"看看是否执行到这了")
end

--[[
	@brief:清除所有玩家的准备状态
	@author:Jhao.
]]
function GamePlaneOperator:clearAllReadyStatus()
	local tbPlayerType = {CARD_PLAYERTYPE_MY,
							CARD_PLAYERTYPE_LEFT,
							CARD_PLAYERTYPE_RIGHT,
							CARD_PLAYERTYPE_TOP,}

	for key, playerType in pairs(tbPlayerType) do
		local panel = self:getPlayerPlane(playerType)
		local ready_img = panel:getChildByName(CHILD_NAME_READY_IMG)
		if ready_img ~= nil then ready_img:setVisible(false) end
	end
end



return GamePlaneOperator