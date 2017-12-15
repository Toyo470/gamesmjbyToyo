local Card = require("hn_majiang.card.card")
local playerPlaneOperator = require("hn_majiang.operator.PlayerPlaneOperator")
local centerPlaneOperator = require("hn_majiang.operator.CenterPlaneOperator")

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
local CHILD_NAME_LIANZHUANG_LB = "lianzhuang_lb"

-- local schedulerID

function GamePlaneOperator:init()
	HNMJ_REMAIN_CARDS_COUNT = HNMJ_CARDS_LESS_INIT

	playerPlaneOperator:init(CARD_PLAYERTYPE_MY, self:getPlayerPlane(CARD_PLAYERTYPE_MY))
	playerPlaneOperator:init(CARD_PLAYERTYPE_LEFT, self:getPlayerPlane(CARD_PLAYERTYPE_LEFT))
	playerPlaneOperator:init(CARD_PLAYERTYPE_RIGHT, self:getPlayerPlane(CARD_PLAYERTYPE_RIGHT))
	playerPlaneOperator:init(CARD_PLAYERTYPE_TOP, self:getPlayerPlane(CARD_PLAYERTYPE_TOP))

	local centerPlane = HNMJ_GAME_PLANE:getChildByName(CHILD_NAME_CENTER_PLANE)
	centerPlaneOperator:init(centerPlane)

	local myPlane = self:getPlayerPlane(CARD_PLAYERTYPE_MY)
	myPlane.noScale = true
	myPlane:onClick(function()
			playerPlaneOperator:cancelSelectingCard(myPlane)
		end)

	HNMJ_CARD_POINTER = HNMJ_GAME_PLANE:getChildByName(CHILD_NAME_CARD_POINTER)

	local remain_card_count_lb = HNMJ_GAME_PLANE:getChildByName(CHILD_NAME_REMAIN_CARDS_COUNT_LB)
	local lianzhuang_lb = HNMJ_GAME_PLANE:getChildByName(CHILD_NAME_LIANZHUANG_LB)
    lianzhuang_lb:setVisible(false)
	-- remain_card_count_lb:setString("等待玩家进入...")

	local card_bx = HNMJ_GAME_PLANE:getChildByName(CHILD_NAME_CARD_BOX)
	card_bx:setVisible(false)

	local remark_lb = HNMJ_GAME_PLANE:getChildByName(CHILD_NAME_REMARK_LB)

	if USER_INFO["gameConfig"] then
		--todo
		remark_lb:setString("海南麻将：" .. USER_INFO["gameConfig"])
	else
		remark_lb:setString("正在读取组局信息")
	end
end

function GamePlaneOperator:showCenterPlane()
	local centerPlane = HNMJ_GAME_PLANE:getChildByName(CHILD_NAME_CENTER_PLANE)
	centerPlane:setVisible(true)
end

function GamePlaneOperator:clearGameDatas()
	HNMJ_REMAIN_CARDS_COUNT = HNMJ_CARDS_LESS_INIT

	HNMJ_CURRENT_CARDNODE = nil

	playerPlaneOperator:clearGameDatas(CARD_PLAYERTYPE_MY, self:getPlayerPlane(CARD_PLAYERTYPE_MY))
	playerPlaneOperator:clearGameDatas(CARD_PLAYERTYPE_LEFT, self:getPlayerPlane(CARD_PLAYERTYPE_LEFT))
	playerPlaneOperator:clearGameDatas(CARD_PLAYERTYPE_RIGHT, self:getPlayerPlane(CARD_PLAYERTYPE_RIGHT))
	playerPlaneOperator:clearGameDatas(CARD_PLAYERTYPE_TOP, self:getPlayerPlane(CARD_PLAYERTYPE_TOP))

	local centerPlane = HNMJ_GAME_PLANE:getChildByName(CHILD_NAME_CENTER_PLANE)
	centerPlaneOperator:clearGameDatas(centerPlane)

	local card_bx = HNMJ_GAME_PLANE:getChildByName(CHILD_NAME_CARD_BOX)
	card_bx:setVisible(false)

	HNMJ_CARD_POINTER:setPosition(cc.p(-20, -20))

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
		plane = HNMJ_GAME_PLANE:getChildByName(CHILD_NAME_MY_PLANE)
	elseif playerType == CARD_PLAYERTYPE_LEFT then
		plane = HNMJ_GAME_PLANE:getChildByName(CHILD_NAME_LEFT_PLANE)
	elseif playerType == CARD_PLAYERTYPE_RIGHT then
		plane = HNMJ_GAME_PLANE:getChildByName(CHILD_NAME_RIGHT_PLANE)
	elseif playerType == CARD_PLAYERTYPE_TOP then
		plane = HNMJ_GAME_PLANE:getChildByName(CHILD_NAME_TOP_PLANE)
	end

	return plane
end

function GamePlaneOperator:playHuaCard(playerType,value)
	playerPlaneOperator:playHuaCard(playerType,self:getPlayerPlane(playerType),value)
end

function GamePlaneOperator:playCard(playerType, tag, value)
	playerPlaneOperator:playCard(playerType, self:getPlayerPlane(playerType), tag, value)

	-- local card_bx = HNMJ_GAME_PLANE:getChildByName(CHILD_NAME_CARD_BOX)

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



function GamePlaneOperator:control(playerType, progCards, controlType,fromplayerType)
	-- dump(HNMJ_CURRENT_CARDNODE, "HNMJ_CURRENT_CARDNODE test")

	if not tolua.isnull(HNMJ_CURRENT_CARDNODE) and bit.band(controlType, CONTROL_TYPE_HU) == 0 then
     
     if bit.band(GANG_TYPE_BU,controlType)==0 and bit.band(GANG_TYPE_AN,controlType)==0 and bit.band(HU_TYPE_HH,controlType)==0 then  

		HNMJ_CURRENT_CARDNODE:removeFromParent()

		HNMJ_CARD_POINTER:setVisible(false)

		HNMJ_CURRENT_CARDNODE = nil
	
	end

	end
	playerPlaneOperator:control(playerType, self:getPlayerPlane(playerType), progCards, controlType,fromplayerType)

	self:beginPlayCard(playerType)
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

function GamePlaneOperator:showControlPlane(controlTable)
	HNMJ_CONTROL_TABLE = controlTable

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
	local remain_card_count_lb = HNMJ_GAME_PLANE:getChildByName(CHILD_NAME_REMAIN_CARDS_COUNT_LB)
    
    local lianzhuang_lb = HNMJ_GAME_PLANE:getChildByName(CHILD_NAME_LIANZHUANG_LB)

    if lianzhuang_lb then
		if HNMJ_LIANZHUANG_ROUND>0 then 
			local content = " 已连庄"..HNMJ_LIANZHUANG_ROUND.."局"
			lianzhuang_lb:setVisible(true)
			lianzhuang_lb:setString(content)
		end
	end
    
	if remain_card_count_lb then
		local content =  tostring(HNMJ_REMAIN_CARDS_COUNT)
             -- "剩余" .... " 张牌 "

		-- if HNMJ_ROUND then
		-- 	--todo
		-- 	content = content .. "   第 " .. HNMJ_ROUND .. " / " .. HNMJ_TOTAL_ROUNDS .. " 局"
		-- end
		local remark_lb = HNMJ_GAME_PLANE:getChildByName(CHILD_NAME_REMARK_LB)
		if HNMJ_ROUND then
			--todo
		remark_lb:setString("海南麻将: 第".. HNMJ_ROUND.." / ".. USER_INFO["gameConfig"])
		end

		remain_card_count_lb:setString(content)
	end
end

function GamePlaneOperator:beginPlayCard(playerType)
	local centerPlane = HNMJ_GAME_PLANE:getChildByName(CHILD_NAME_CENTER_PLANE)

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

--
function GamePlaneOperator:rotateTimer(zhuang_index)
local centerPlane = HNMJ_GAME_PLANE:getChildByName(CHILD_NAME_CENTER_PLANE)

	centerPlaneOperator:rotateTimer(zhuang_index,centerPlane)
end

function GamePlaneOperator:buHua(playerType)
	local playerType = playerType
    playerPlaneOperator:buHua(self:getPlayerPlane(playerType))
end

function GamePlaneOperator:showFan(playerType,flag)
-- local config = {[0]={['x'] = 480,['y'] = 200,},
-- 				[1]={['x'] = 300,['y'] = 250,},--左
-- 				[2]={['x'] = 480,['y'] = 450,},--上
-- 				[3]={['x'] = 750,['y'] = 300,},--右
-- }

-- local index = playerType

-- local fan = display.newSprite("hn_majiang/image/fan.png")
--       fan:addTo(HNMJ_GAME_PLANE)
--       fan:setLocalZOrder(200)
--       fan:setPosition(config[index]['x'],config[index]['y'])
--       fan:setVisible(flag)
end

function GamePlaneOperator:hideFan()

-- if PLAYERNUM==4 then
-- 	self:showFan(CARD_PLAYERTYPE_MY, false)
-- 	self:showFan(CARD_PLAYERTYPE_LEFT,false)
-- 	self:showFan(CARD_PLAYERTYPE_RIGHT,false)
-- 	self:showFan(CARD_PLAYERTYPE_TOP,false)
-- end

-- if PLAYERNUM==2 then
-- 	self:showFan(CARD_PLAYERTYPE_MY, false)
-- 	self:showFan(CARD_PLAYERTYPE_TOP,false)
-- end

end

--玩家准备
function GamePlaneOperator:show_player_ready(index, show_flag)

	--print("show_player_ready", tostring(index))
    if show_flag then
        local spReady = cc.Sprite:create("hn_majiang/image/mahjong_ready.png")
        if spReady then
            local pos = nil
    		local plane = nil
            if index == 0 then
            	plane = self:getPlayerPlane(CARD_PLAYERTYPE_MY)
                pos = cc.p(460, plane:getContentSize().height/2)
            elseif index == 1 then
            	plane = self:getPlayerPlane(CARD_PLAYERTYPE_LEFT)
                pos = cc.p(200, plane:getContentSize().height/2 -50)
            elseif index == 2 then
            	plane = self:getPlayerPlane(CARD_PLAYERTYPE_TOP)
                pos = cc.p(260, 100)
            elseif index == 3 then
            	plane = self:getPlayerPlane(CARD_PLAYERTYPE_RIGHT)
                pos = cc.p(100, plane:getContentSize().height/2)
            end
            if plane then
            	dump(plane:getPosition(), "show_player_ready  "..tostring(index))
	            spReady:addTo(plane)
	            spReady:setPosition(pos)
	            spReady:setName("user_ready")
            end
        end
    else
    	local plane = nil
    	if index == 0 then
            plane = self:getPlayerPlane(CARD_PLAYERTYPE_MY)
    	elseif index == 1 then
            plane = self:getPlayerPlane(CARD_PLAYERTYPE_LEFT)
    	elseif index == 2 then
            plane = self:getPlayerPlane(CARD_PLAYERTYPE_TOP)
    	elseif index == 3 then
            plane = self:getPlayerPlane(CARD_PLAYERTYPE_RIGHT)
    	end
    	if plane then
	        local spReady = plane:getChildByName("user_ready")
	        if spReady then
	            spReady:removeSelf()
	        end
    	end
    end
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