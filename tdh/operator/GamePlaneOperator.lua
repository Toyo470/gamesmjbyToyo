local Card = require("tdh.card.card")
local playerPlaneOperator = require("tdh.operator.PlayerPlaneOperator")
local centerPlaneOperator = require("tdh.operator.CenterPlaneOperator")

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
	TDHMJ_REMAIN_CARDS_COUNT = 68

	playerPlaneOperator:init(CARD_PLAYERTYPE_MY, self:getPlayerPlane(CARD_PLAYERTYPE_MY))
	playerPlaneOperator:init(CARD_PLAYERTYPE_LEFT, self:getPlayerPlane(CARD_PLAYERTYPE_LEFT))
	playerPlaneOperator:init(CARD_PLAYERTYPE_RIGHT, self:getPlayerPlane(CARD_PLAYERTYPE_RIGHT))
	playerPlaneOperator:init(CARD_PLAYERTYPE_TOP, self:getPlayerPlane(CARD_PLAYERTYPE_TOP))

	local centerPlane = TDHMJ_GAME_PLANE:getChildByName(CHILD_NAME_CENTER_PLANE)
	centerPlaneOperator:init(centerPlane)

	local myPlane = self:getPlayerPlane(CARD_PLAYERTYPE_MY)
	myPlane.noScale = true
	myPlane:onClick(function()
			playerPlaneOperator:cancelSelectingCard(myPlane)
		end)

	TDHMJ_CARD_POINTER = TDHMJ_GAME_PLANE:getChildByName(CHILD_NAME_CARD_POINTER)

	local remain_card_count_lb = TDHMJ_GAME_PLANE:getChildByName(CHILD_NAME_REMAIN_CARDS_COUNT_LB)

	remain_card_count_lb:setString("等待玩家进入...")

	local card_bx = TDHMJ_GAME_PLANE:getChildByName(CHILD_NAME_CARD_BOX)
	card_bx:setVisible(false)

	local remark_lb = TDHMJ_GAME_PLANE:getChildByName(CHILD_NAME_REMARK_LB)

	if USER_INFO["gameConfig"] then
		--todo
		remark_lb:setString("推倒胡麻将：" .. USER_INFO["gameConfig"])
	else
		remark_lb:setString("正在读取组局信息")
	end
end

function GamePlaneOperator:showCenterPlane()
	local centerPlane = TDHMJ_GAME_PLANE:getChildByName(CHILD_NAME_CENTER_PLANE)
	centerPlane:setVisible(true)
end

function GamePlaneOperator:clearGameDatas()
	TDHMJ_REMAIN_CARDS_COUNT = 68

	TDHMJ_CURRENT_CARDNODE = nil

	playerPlaneOperator:clearGameDatas(CARD_PLAYERTYPE_MY, self:getPlayerPlane(CARD_PLAYERTYPE_MY))
	playerPlaneOperator:clearGameDatas(CARD_PLAYERTYPE_LEFT, self:getPlayerPlane(CARD_PLAYERTYPE_LEFT))
	playerPlaneOperator:clearGameDatas(CARD_PLAYERTYPE_RIGHT, self:getPlayerPlane(CARD_PLAYERTYPE_RIGHT))
	playerPlaneOperator:clearGameDatas(CARD_PLAYERTYPE_TOP, self:getPlayerPlane(CARD_PLAYERTYPE_TOP))

	local centerPlane = TDHMJ_GAME_PLANE:getChildByName(CHILD_NAME_CENTER_PLANE)
	centerPlaneOperator:clearGameDatas(centerPlane)

	local card_bx = TDHMJ_GAME_PLANE:getChildByName(CHILD_NAME_CARD_BOX)
	card_bx:setVisible(false)

	TDHMJ_CARD_POINTER:setPosition(cc.p(-20, -20))
	TDHMJ_CARD_POINTER:stopAllActions()

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
		plane = TDHMJ_GAME_PLANE:getChildByName(CHILD_NAME_MY_PLANE)
	elseif playerType == CARD_PLAYERTYPE_LEFT then
		plane = TDHMJ_GAME_PLANE:getChildByName(CHILD_NAME_LEFT_PLANE)
	elseif playerType == CARD_PLAYERTYPE_RIGHT then
		plane = TDHMJ_GAME_PLANE:getChildByName(CHILD_NAME_RIGHT_PLANE)
	elseif playerType == CARD_PLAYERTYPE_TOP then
		plane = TDHMJ_GAME_PLANE:getChildByName(CHILD_NAME_TOP_PLANE)
	end

	dump(plane, "plane test")

	return plane
end

function GamePlaneOperator:playCard(playerType, tag, value)
	playerPlaneOperator:playCard(playerType, self:getPlayerPlane(playerType), tag, value)

	-- local card_bx = TDHMJ_GAME_PLANE:getChildByName(CHILD_NAME_CARD_BOX)

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

	playerPlaneOperator:hideControlPlane(self:getPlayerPlane(CARD_PLAYERTYPE_MY))

	-- if not tolua.isnull(TDHMJ_CURRENT_CARDNODE) and bit.band(controlType, CONTROL_TYPE_HU) == 0 then
		
 --       if  bit.band(controlType, GANG_TYPE_AN) == 0 and bit.band(controlType, GANG_TYPE_BU) == 0 then

 --       	if bit.band(controlType, LIANGXI_TYPE_L) == 0 and bit.band(controlType, TING_TYPE_T) == 0  then

		-- TDHMJ_CURRENT_CARDNODE:removeFromParent()

		TDHMJ_CARD_POINTER:stopAllActions()
		TDHMJ_CARD_POINTER:setVisible(false)

		TDHMJ_CURRENT_CARDNODE = nil
	-- 	end

	--    end

	-- end
	playerPlaneOperator:control(playerType, self:getPlayerPlane(playerType), progCards, controlType)

	if bit.band(controlType, CONTROL_TYPE_HU) == 0 then
		self:beginPlayCard(playerType)
	end
end

function GamePlaneOperator:showPlayerInfo(playerType, userInfo)
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

function GamePlaneOperator:showControlPlane(controlTable)
	TDHMJ_CONTROL_TABLE = controlTable

	local controlType = controlTable["type"]

	if controlType == CONTROL_TYPE_NONE then
		--todo
		return
	end

	playerPlaneOperator:showControlPlane(self:getPlayerPlane(CARD_PLAYERTYPE_MY), controlType)
end

function GamePlaneOperator:showRemainCardsCount()
	local remain_card_count_lb = TDHMJ_GAME_PLANE:getChildByName(CHILD_NAME_REMAIN_CARDS_COUNT_LB)

	if remain_card_count_lb then
		--todo
		local content = "剩余 " .. TDHMJ_REMAIN_CARDS_COUNT .. " 张"

		if TDHMJ_ROUND then
			--todo
			content = content .. "  第 " .. TDHMJ_ROUND .. " / " .. TDHMJ_TOTAL_ROUNDS .. " 局"
		end

		remain_card_count_lb:setString(content)
	end
end

function GamePlaneOperator:beginPlayCard(playerType)
	local centerPlane = TDHMJ_GAME_PLANE:getChildByName(CHILD_NAME_CENTER_PLANE)

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

function GamePlaneOperator:removeLatestOutCard2(playerType, card)
	if playerType == CARD_PLAYERTYPE_RIGHT or playerType ==CARD_PLAYERTYPE_TOP then
		return playerPlaneOperator:removeLatestOutCard2(self:getPlayerPlane(playerType), card)
	elseif playerType == CARD_PLAYERTYPE_MY or playerType ==CARD_PLAYERTYPE_LEFT then
		return playerPlaneOperator:removeLatestOutCard(self:getPlayerPlane(playerType), card)	
    end
end

function GamePlaneOperator:showCardsForHu(playerType, cardDatas)
	playerPlaneOperator:showCardsForHu(playerType, self:getPlayerPlane(playerType), cardDatas)
end

function GamePlaneOperator:getHeadNode(playerType)
	return playerPlaneOperator:getHeadNode(self:getPlayerPlane(playerType))
end


function GamePlaneOperator:showComponentSelectBox(outCardParam)
	playerPlaneOperator:showComponentSelectBox(self:getPlayerPlane(CARD_PLAYERTYPE_MY), outCardParam)
end

--显示听牌队列
function GamePlaneOperator:showTingHuPlane(tingHuCards)
	dump(tingHuCards,"GamePlaneOperator:showTingHuPlane")
	playerPlaneOperator:showTingHuPlane(self:getPlayerPlane(CARD_PLAYERTYPE_MY), tingHuCards)
end

--隐藏听牌队列
function GamePlaneOperator:hideTingHuPlane()
	playerPlaneOperator:hideTingHuPlane(self:getPlayerPlane(CARD_PLAYERTYPE_MY))
end

--显示听牌暗化
function GamePlaneOperator:showTingCards(tingSeq)
	playerPlaneOperator:showTingCards(self:getPlayerPlane(CARD_PLAYERTYPE_MY), tingSeq)
end

--加漂相关
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
	self:showPiaoImg(CARD_PLAYERTYPE_TOP, 0, false)
	self:showPiaoImg(CARD_PLAYERTYPE_RIGHT, 0, false)
end

function GamePlaneOperator:clearTingFlag()
	self:showTingFlag(CARD_PLAYERTYPE_MY, false)
	self:showTingFlag(CARD_PLAYERTYPE_LEFT, false)
	self:showTingFlag(CARD_PLAYERTYPE_TOP, false)
	self:showTingFlag(CARD_PLAYERTYPE_RIGHT, false)
end

function GamePlaneOperator:showTingFlag(playerType,flag)
	local plane=self:getPlayerPlane(playerType)
	local ting_flag=plane:getChildByName("ting_flag")
    ting_flag:setVisible(flag)
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
	dump(_playerType,"看看是否执行到这了")
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

function GamePlaneOperator:rotateTimer(zhuang_index)
local centerPlane = TDHMJ_GAME_PLANE:getChildByName(CHILD_NAME_CENTER_PLANE)

	centerPlaneOperator:rotateTimer(zhuang_index,centerPlane)
end

--网络状况
function GamePlaneOperator:showNetworkImg(playerType, flag)
	playerPlaneOperator:showNetworkImg(self:getPlayerPlane(playerType), flag)
end

--显示与点击的牌相同的已出的牌
function GamePlaneOperator:showSameCard(value)
    for playerType = 1,4 do 
    	playerPlaneOperator:showSameCard(self:getPlayerPlane(playerType),value)
    end
end

function GamePlaneOperator:hideSameCard()
	for playerType = 1,4 do 
    	playerPlaneOperator:hideSameCard(self:getPlayerPlane(playerType))
    end
end


return GamePlaneOperator
