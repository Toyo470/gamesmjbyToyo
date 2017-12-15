local Card = require("cs_majiang.card.card")
local playerPlaneOperator = require("cs_majiang.operator.PlayerPlaneOperator")
local centerPlaneOperator = require("cs_majiang.operator.CenterPlaneOperator")

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


local CHILD_NAME_READY_IMG = "ready_img"
-- local schedulerID

function GamePlaneOperator:init()
	CSMJ_REMAIN_CARDS_COUNT = 56

	playerPlaneOperator:init(CARD_PLAYERTYPE_MY, self:getPlayerPlane(CARD_PLAYERTYPE_MY))
	playerPlaneOperator:init(CARD_PLAYERTYPE_LEFT, self:getPlayerPlane(CARD_PLAYERTYPE_LEFT))
	playerPlaneOperator:init(CARD_PLAYERTYPE_RIGHT, self:getPlayerPlane(CARD_PLAYERTYPE_RIGHT))
	playerPlaneOperator:init(CARD_PLAYERTYPE_TOP, self:getPlayerPlane(CARD_PLAYERTYPE_TOP))

	local centerPlane = CSMJ_GAME_PLANE:getChildByName(CHILD_NAME_CENTER_PLANE)
	centerPlaneOperator:init(centerPlane)

	local myPlane = self:getPlayerPlane(CARD_PLAYERTYPE_MY)
	myPlane.noScale = true
	myPlane:onClick(function()
			playerPlaneOperator:cancelSelectingCard(myPlane)
		end)

	CSMJ_CARD_POINTER = CSMJ_GAME_PLANE:getChildByName(CHILD_NAME_CARD_POINTER)

	local remain_card_count_lb = CSMJ_GAME_PLANE:getChildByName(CHILD_NAME_REMAIN_CARDS_COUNT_LB)

	remain_card_count_lb:setString("等待玩家进入...")

	local card_bx = CSMJ_GAME_PLANE:getChildByName(CHILD_NAME_CARD_BOX)
	card_bx:setVisible(false)

	local remark_lb = CSMJ_GAME_PLANE:getChildByName(CHILD_NAME_REMARK_LB)

	if USER_INFO["gameConfig"] then
		--todo
		remark_lb:setString("长沙麻将：" .. USER_INFO["gameConfig"])
	else
		remark_lb:setString("正在读取组局信息")
	end
end

function GamePlaneOperator:showCenterPlane()
	local centerPlane = CSMJ_GAME_PLANE:getChildByName(CHILD_NAME_CENTER_PLANE)
	centerPlane:setVisible(true)
end

function GamePlaneOperator:clearGameDatas()
	CSMJ_REMAIN_CARDS_COUNT = 56

	CSMJ_CURRENT_CARDNODE = nil

	playerPlaneOperator:clearGameDatas(CARD_PLAYERTYPE_MY, self:getPlayerPlane(CARD_PLAYERTYPE_MY))
	playerPlaneOperator:clearGameDatas(CARD_PLAYERTYPE_LEFT, self:getPlayerPlane(CARD_PLAYERTYPE_LEFT))
	playerPlaneOperator:clearGameDatas(CARD_PLAYERTYPE_RIGHT, self:getPlayerPlane(CARD_PLAYERTYPE_RIGHT))
	playerPlaneOperator:clearGameDatas(CARD_PLAYERTYPE_TOP, self:getPlayerPlane(CARD_PLAYERTYPE_TOP))

	local centerPlane = CSMJ_GAME_PLANE:getChildByName(CHILD_NAME_CENTER_PLANE)
	centerPlaneOperator:clearGameDatas(centerPlane)

	local card_bx = CSMJ_GAME_PLANE:getChildByName(CHILD_NAME_CARD_BOX)
	card_bx:setVisible(false)

	CSMJ_CARD_POINTER:setPosition(cc.p(-20, -20))
	CSMJ_CARD_POINTER:stopAllActions()

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
	if not tolua.isnull(CSMJ_GAME_PLANE) then   --防止CSMJ_GAME_PLANE为空
		if playerType == CARD_PLAYERTYPE_MY then
			plane = CSMJ_GAME_PLANE:getChildByName(CHILD_NAME_MY_PLANE)
		elseif playerType == CARD_PLAYERTYPE_LEFT then
			plane = CSMJ_GAME_PLANE:getChildByName(CHILD_NAME_LEFT_PLANE)
		elseif playerType == CARD_PLAYERTYPE_RIGHT then
			plane = CSMJ_GAME_PLANE:getChildByName(CHILD_NAME_RIGHT_PLANE)
		elseif playerType == CARD_PLAYERTYPE_TOP then
			plane = CSMJ_GAME_PLANE:getChildByName(CHILD_NAME_TOP_PLANE)
		end
	end
	dump(plane, "plane test")

	return plane
end

function GamePlaneOperator:playCard(playerType, tag, value)
	playerPlaneOperator:playCard(playerType, self:getPlayerPlane(playerType), tag, value)

	-- local card_bx = CSMJ_GAME_PLANE:getChildByName(CHILD_NAME_CARD_BOX)

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

function GamePlaneOperator:control(playerType, progCards, controlType)
	dump(CSMJ_CURRENT_CARDNODE, "CSMJ_CURRENT_CARDNODE test")

	playerPlaneOperator:hideControlPlane(self:getPlayerPlane(CARD_PLAYERTYPE_MY))
	if controlType ~= 0x200 and controlType ~= 0x400 then  --除了补杠和暗杠  均不调用
		if not tolua.isnull(CSMJ_CURRENT_CARDNODE) and bit.band(controlType, CONTROL_TYPE_HU) == 0 then
			--todo
			CSMJ_CURRENT_CARDNODE:removeFromParent()

			CSMJ_CARD_POINTER:stopAllActions()
			CSMJ_CARD_POINTER:setVisible(false)

			CSMJ_CURRENT_CARDNODE = nil
		end
	end
	playerPlaneOperator:control(playerType, self:getPlayerPlane(playerType), progCards, controlType)

	if bit.band(controlType, CONTROL_TYPE_HU) == 0 then
		self:beginPlayCard(playerType)
	end
end

function GamePlaneOperator:showPlayerInfo(playerType, userInfo)
	dump(userInfo, "player test")
	dump(playerType, "player test")
	return playerPlaneOperator:showPlayerInfo(userInfo, self:getPlayerPlane(playerType))
end

function GamePlaneOperator:showZhuang(playerType)
	playerPlaneOperator:showZhuang(self:getPlayerPlane(playerType))
end

function GamePlaneOperator:showCards(playerType)
	playerPlaneOperator:showCards(playerType, self:getPlayerPlane(playerType))
end

function GamePlaneOperator:getNewCard(playerType, value)
	playerPlaneOperator:getNewCard(playerType, self:getPlayerPlane(playerType), value)
	-- playerPlaneOperator:hideControlPlane(self:getPlayerPlane(CARD_PLAYERTYPE_MY))

	self:beginPlayCard(playerType)
end

function GamePlaneOperator:showControlPlane(controlTable, _callBackFunc)
	CSMJ_CONTROL_TABLE = controlTable

	local controlType = controlTable["type"]

	if controlType == CONTROL_TYPE_NONE then
		--todo
		return
	end

	playerPlaneOperator:showControlPlane(self:getPlayerPlane(CARD_PLAYERTYPE_MY), controlType, _callBackFunc)
end

function GamePlaneOperator:showRemainCardsCount()
	local remain_card_count_lb = CSMJ_GAME_PLANE:getChildByName(CHILD_NAME_REMAIN_CARDS_COUNT_LB)

	if remain_card_count_lb then
		--todo
		local content = "剩余 " .. CSMJ_REMAIN_CARDS_COUNT .. " 张"

		if CSMJ_ROUND then
			--todo
			content = content .. "  第 " .. CSMJ_ROUND .. " / " .. CSMJ_TOTAL_ROUNDS .. " 局"
		end

		remain_card_count_lb:setString(content)
	end
end

function GamePlaneOperator:beginPlayCard(playerType)
	local centerPlane = CSMJ_GAME_PLANE:getChildByName(CHILD_NAME_CENTER_PLANE)

	if centerPlane then
		--todo
		centerPlaneOperator:beginPlayCard(playerType, centerPlane)
	end
end

function GamePlaneOperator:redrawGameInfo(playerType, data)
	playerPlaneOperator:redrawGameInfo(playerType, self:getPlayerPlane(playerType), data)
end

function GamePlaneOperator:removeLatestOutCard(playerType, card)
	return playerPlaneOperator:removeLatestOutCard(self:getPlayerPlane(playerType), card)
end

function GamePlaneOperator:showCardsForHu(playerType, cardDatas)
	playerPlaneOperator:showCardsForHu(playerType, self:getPlayerPlane(playerType), cardDatas)
end

-- function GamePlaneOperator:showCardsForQiShouHu(playerType, cardDatas, _huType)
function GamePlaneOperator:showCardsForQiShouHu(playerType, cardDatas, _liangCards)
	playerPlaneOperator:showCardsForQiShouHu(playerType, self:getPlayerPlane(playerType), cardDatas, _liangCards)
end

function GamePlaneOperator:getHeadNode(playerType)
	return playerPlaneOperator:getHeadNode(self:getPlayerPlane(playerType))
end



--[[
	@brief:设置玩家准备状态
	@param:_playerType 座位id
	@author:Jhao.
]]
function GamePlaneOperator:setReadyStatus(_playerType, _isReady)
	local panel = self:getPlayerPlane(_playerType)
	if _isReady == nil then
		_isReady = true
	else
		_isReady = false
	end

	if panel == nil then return end

	local ready_img = panel:getChildByName(CHILD_NAME_READY_IMG)
	if ready_img ~= nil then 
		ready_img:setVisible(_isReady) 
	end
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


--[[
	@brief:设置玩家离线/在线状态
	@author:Jhao.
]]
function GamePlaneOperator:setUserOnline(_playerType, _isOnline)
	local plane = self:getPlayerPlane(_playerType)
	print("--- @@@@  GamePlaneOperator:setUserOnline", tostring(plane), _playerType)
	playerPlaneOperator:setUserOnline(plane, _isOnline)
end

return GamePlaneOperator
