local Card = require("zz_majiang.card.card")
local sendHandle = require("zz_majiang.handle.ZZMJSendHandle")

local RoundEndingLayer = class("RoundEndingLayer")

local CHILD_NAME_FLOOR = "floor"
local CHILD_NAME_TITLE_BG_IMG = "title_bg_img"
local CHILD_NAME_TITLE_IMG = "title_img"
local CHILD_NAME_SHOW_PLANE = "show_plane"
local CHILD_NAME_BIRD_CARD_PLANE = "bird_card_plane"
local CHILD_NAME_START_BT = "start_bt"
local CHILD_NAME_CLOSE_BT = "close_bt"
local CHILD_NAME_ROOM_LB = "room_lb"
local CHILD_NAME_BIRD_LB = "bird_lb"
local CHILD_NAME_TIME_LB = "time_lb"
local CHILD_NAME_JIESAN_BT = "jiesan_bt"

local CHILD_NAME_PLAYER1_PLANE = "player1_plane"
local CHILD_NAME_PLAYER2_PLANE = "player2_plane"
local CHILD_NAME_PLAYER3_PLANE = "player3_plane"
local CHILD_NAME_PLAYER4_PLANE = "player4_plane"

local CHILD_NAME_ZHUANG_SIGNAL = "zhuang_signal"
local CHILD_NAME_NICK_LB = "nick_lb"
local CHILD_NAME_DESC_LB = "desc_lb"
local CHILD_NAME_CARD_PLANE = "card_plane"
local CHILD_NAME_SCORE_LB = "score_lb"
local CHILD_NAME_HU_SIGNAL = "hu_signal"

local TITLE_TYPE_WIN = 1
local TITLE_TYPE_LOSE = 2
local TITLE_TYPE_LIUJU = 3

local win_lose_table = {} -- key = seatId

local isShow = false
local zhongbirdCount

function RoundEndingLayer:showZhuaniao(data, isEnd)
	isShow = true

	win_lose_table = {}

	for k,v in pairs(data.players) do
		local player = v
		-- if player.huTypeCount > 0 then
		-- 	--todo
		-- 	win_lose_table[k - 1] = "Y"
		-- else
		-- 	win_lose_table[k - 1] = "N"
		-- end
	end

	local cards_tb1 = {}
	local zhongcard = {}
	local count = table.getn(data.birdCards)
	-- dump(data.birdCards,"鸟牌")
	for i=1,count do
		table.insert(cards_tb1, data.birdCards[i])
		-- if data.birdCards[i]["position"] == 1 then
		-- 	--todo
			
		-- end
	end
     
    if  data.zhongcard~={} then
		zhongbirdCount = table.getn(data.zhongcard)
		for i=1,zhongbirdCount do
			table.insert(zhongcard, data.zhongcard[i])
		end
	end

	local timeDelay = require("zz_majiang.result_effect_layout"):reset_niaocard_data(cards_tb1, zhongcard)
	
	if timeDelay == 0 then
		--todo
		timeDelay = 3
	else
		timeDelay = timeDelay + 3
	end

	local zhuaniaoLayout = SCENENOW["scene"]:getChildByName("zhuaniaoLayout")
	if zhuaniaoLayout then
		--todo
		local callFuncAc = cc.CallFunc:create(function ()
				zhuaniaoLayout:removeFromParent()
				ZZMJ_CONTROLLER:clearGameDatas()
				self:show(data, isEnd)
			end)

		zhuaniaoLayout:runAction(cc.Sequence:create(cc.DelayTime:create(timeDelay), callFuncAc))
	end
end

function RoundEndingLayer:show(data, isEnd)
	isShow = true
	local isEndT = isEnd or false

	win_lose_table = {}

	self._scene = cc.CSLoader:createNode("zz_majiang/roundEndingLayer.csb")
	self.floor = self._scene:getChildByName(CHILD_NAME_FLOOR)
	self.showPlane = self.floor:getChildByName(CHILD_NAME_SHOW_PLANE)
    
	local endType = data.type --流局与否控制字段
	local uid = data.uid

	local players = data.players

	local me = nil
	for i=1,table.getn(players) do

		local isZhuang = false
		if ZZMJ_ZHUANG_UID == players[i].uid then
			--todo
			isZhuang = true
		end

		-- self:dealPlayerCards(players[i].remainCards, players[i].huCard, players[i].huTypeCount)
		self:showPlayerPlane(players[i], i, isZhuang)

		if tonumber(players[i].uid) == tonumber(USER_INFO["uid"]) then
			--todo
			me = players[i]
		end
	end

	local titleType = TITLE_TYPE_LIUJU
	if endType ~= 0 then
		if me.changeCoins > 0 then
			--todo
			titleType = TITLE_TYPE_WIN
		else
			titleType = TITLE_TYPE_LOSE
		end
	end

	self:showTitle(titleType)

	self:showBirdCards(data.birdCards,data.zhongcard)

	for i=1,table.getn(players) do

		self:showEndingInfo(players[i], i)
	end
    
    local current_time = os.time()
	local timeStr = os.date("%Y-%m-%d %H:%M:%S",data["time"]+current_time)
	self:showGameRemark(timeStr)

	local start_bt = self.floor:getChildByName(CHILD_NAME_START_BT)

	if start_bt then
		--todo
		local function bt_callback(sender, event)
			if event == TOUCH_EVENT_ENDED then
				--todo
				sendHandle:readyNow()

				self._scene:removeFromParent()
				isShow = false
			end
		end

		start_bt:addTouchEventListener(bt_callback)

		if isEndT then
			--todo
			start_bt:setVisible(false)
		else
			start_bt:setVisible(true)
		end
	end

	local close_bt = self.floor:getChildByName(CHILD_NAME_CLOSE_BT)

	if close_bt then
		--todo
		local function bt_callback(sender, event)
			if event == TOUCH_EVENT_ENDED then
				--todo
				self._scene:removeFromParent()

				if ZZMJ_GROUP_ENDING_DATA then
					--todo
					require("zz_majiang.GroupEndingLayer"):showGroupResult(ZZMJ_GROUP_ENDING_DATA)
				end

				isShow = false

			end
		end

		close_bt:addTouchEventListener(bt_callback)

		if isEndT then
			--todo
			close_bt:setVisible(true)
		else
			close_bt:setVisible(false)
		end
	end

	local jiesan_bt = self.floor:getChildByName(CHILD_NAME_JIESAN_BT)

	if jiesan_bt then
		--todo
		local function bt_callback(sender, event)
			if event == TOUCH_EVENT_ENDED then
				--todo
				SCENENOW["scene"]:disbandGroup()

			end
		end

		jiesan_bt:addTouchEventListener(bt_callback)

		if isEndT then
			--todo
			jiesan_bt:setVisible(false)
		else
			jiesan_bt:setVisible(true)
		end
	end

	self._scene:setName("roundEndingLayer")
	SCENENOW["scene"]:addChild(self._scene)
end

function RoundEndingLayer:hide()
	local layer = SCENENOW["scene"]:getChildByName("roundEndingLayer")

	if layer then
		--todo
		layer:removeFromParent()
	end
end

function RoundEndingLayer:isShow()
	return isShow
end

function RoundEndingLayer:setIsShow(param)
	isShow = param
end

function RoundEndingLayer:showPlayerPlane(player, index, isZhuang)
	local playerPlaneName = "player" .. index .. "_plane"
	local playerPlane = self.showPlane:getChildByName(playerPlaneName)
     
	local zhuang_signal = playerPlane:getChildByName(CHILD_NAME_ZHUANG_SIGNAL)
	zhuang_signal:setVisible(isZhuang)
    
	local hu_signal = playerPlane:getChildByName(CHILD_NAME_HU_SIGNAL)
    
    local huCard
    if hutype==1 then     --平胡 
	      huCard = player.hucontent.pinghu.hucard
	      self:dealPlayerCards(player.remainCards, huCard)
	elseif  hutype==2 then    --自摸
	      huCard = player.hucontent.zimo.hucard
	      self:dealPlayerCards(player.remainCards, huCard)
	end
    
   
	if player.changeCoins > 0 then
		--todo
		win_lose_table[index - 1] = "Y"
	elseif player.changeCoins == 0 then
		win_lose_table[index - 1] = "N"
	else
		win_lose_table[index - 1] = "Y"
	end

	if player.ifhu == 1 then
		--todo
		hu_signal:setVisible(true)
	else
		hu_signal:setVisible(false)
	end

	local score_lb = playerPlane:getChildByName(CHILD_NAME_SCORE_LB)
	score_lb:setString("" .. player.changeCoins)

	local seatId = ZZMJ_SEAT_TABLE[player.uid .. ""]

	local nickname = ZZMJ_USERINFO_TABLE[seatId .. ""].nick

	local nick_lb = playerPlane:getChildByName(CHILD_NAME_NICK_LB)

	nick_lb:setString(nickname)

	local card_plane = playerPlane:getChildByName(CHILD_NAME_CARD_PLANE)

	local progCards = {}

	for i=1,player.agCount do
		local p = {}
		p.type = "ag"

		local cs = {player.agCards[i], player.agCards[i], player.agCards[i], player.agCards[i]}

		p.cards = cs

		table.insert(progCards, p)
	end

	for i=1,player.gCount do
		local p = {}
		p.type = "g"

		local cs = {player.gCards[i], player.gCards[i], player.gCards[i], player.gCards[i]}

		p.cards = cs

		table.insert(progCards, p)
	end

	for i=1,player.pCount do
		local p = {}
		p.type = "p"

		local cs = {player.pCards[i], player.pCards[i], player.pCards[i]}

		p.cards = cs

		table.insert(progCards, p)
	end

	-- local p = nil
	-- local cs = nil
	-- for i=1,player.cCount do
	-- 	if i % 3 == 1 then
	-- 		--todo
	-- 		p = {}
	-- 		p.type = "c"
	-- 		cs = {}
	-- 		p.cards = cs
	-- 		table.insert(cs, player.cCards[i])
	-- 	elseif i % 3 == 0 then
	-- 		table.insert(cs, player.cCards[i])

	-- 		table.insert(progCards, p)
	-- 	else
	-- 		table.insert(cs, player.cCards[i])
	-- 	end
	-- end

	if player.ifhu==1  then
		--todo
		self:showPlayerCards(progCards, player.remainCards, card_plane, huCard)
	else
		self:showPlayerCards(progCards, player.remainCards, card_plane, nil)
	end

	
end

function RoundEndingLayer:showEndingInfo(player, index)
	local playerPlaneName = "player" .. index .. "_plane"
	local playerPlane = self.showPlane:getChildByName(playerPlaneName)

	local desc_lb = playerPlane:getChildByName(CHILD_NAME_DESC_LB)

	local endingInfo = ""

	if player.ifpao == 1 then
		endingInfo = endingInfo .. "点炮 ".." "
	end
    
    dump(ifhu,"是否胡牌")
    if player.ifhu == 1 then
    	if zhongbirdCount>0 then
			endingInfo = endingInfo .. "中" .. zhongbirdCount .. "鸟".." "
	    end

		if player.hucontent.hutype  == 1 then
			endingInfo = endingInfo .. "接炮 ".." "
			if   player.hucontent.pinghu.ifgangpao == 1 then 
			     endingInfo = endingInfo .. "杠上炮".." "
			elseif player.hucontent.pinghu.ifqiangganghu ==1 then
			     endingInfo = endingInfo .. "抢杠胡 ".." "
			end
		elseif player.hucontent.hutype == 2 then
			endingInfo = endingInfo .. "自摸".." "
			if player.hucontent.zimo.ifgangshanghua== 1 then
			     endingInfo = endingInfo .. "杠上花".." "
			end
		end
	end
	
	if player.dgCount > 0 then
		--todo
		endingInfo = endingInfo .. "点杠x" .. player.dgCount .. " "
	end
	if (player.gCount-player.bgCount) > 0 then
		--todo
		endingInfo = endingInfo .. "直杠x" .. (player.gCount-player.bgCount) .. " "
	end
	if player.bgCount > 0 then
		--todo
		endingInfo = endingInfo .. "补杠x" .. player.bgCount .. " "
	end
	if player.agCount > 0 then
		--todo
		endingInfo = endingInfo .. "暗杠x" .. player.agCount .. " "
	end

	desc_lb:setString(endingInfo)
end

function RoundEndingLayer:showTitle(titleType)
	local title_bg_img = self.floor:getChildByName(CHILD_NAME_TITLE_BG_IMG)
	local title_img = self.floor:getChildByName(CHILD_NAME_TITLE_IMG)

	if titleType == TITLE_TYPE_WIN then
		--todo
		title_bg_img:loadTexture("zz_majiang/image/red_button_p.png")
		title_img:loadTexture("zz_majiang/image/mahjong_win.png")
	elseif titleType == TITLE_TYPE_LOSE then
		title_bg_img:loadTexture("zz_majiang/image/mahjong_lose_bt.png")
		title_img:loadTexture("zz_majiang/image/mahjong_lose.png")
	else
		title_bg_img:loadTexture("zz_majiang/image/grey_button.png")
		title_img:loadTexture("zz_majiang/image/text_liuju.png")
	end
end

function RoundEndingLayer:showGameRemark(timeStr)
	local room_lb = self.floor:getChildByName(CHILD_NAME_ROOM_LB)
	local bird_lb = self.floor:getChildByName(CHILD_NAME_BIRD_LB)
	local time_lb = self.floor:getChildByName(CHILD_NAME_TIME_LB)

	room_lb:setString("房号" .. USER_INFO["invote_code"])
	-- bird_lb:setString("抓2鸟")
	if USER_INFO["gameConfig"] then
		--todo
		bird_lb:setString("红中麻将：" .. USER_INFO["gameConfig"])
	else
		bird_lb:setString("正在读取组局信息")
	end
	time_lb:setString(timeStr)
end

function RoundEndingLayer:showBirdCards(cards,zhongcard)
	if not cards then
		--todo
		return
	end

	local bird_card_plane = self.floor:getChildByName(CHILD_NAME_BIRD_CARD_PLANE)

	local height = bird_card_plane:getSize().height

	local count = table.getn(zhongcard)
	for i=1,count do
		local card = Card:new(CARD_PLAYERTYPE_MY, CARD_TYPE_OUTHAND, CARD_DISPLAY_TYPE_SHOW, cards[i])

		local scale = height / card:getSize().height

		-- if cards[i]["position"] == 1 then
		-- 	--todo

		    card:setColor(cc.c3b(200, 200, 50))

		-- 	local countKey = cards[i]["position"] .. "birdCount"

		-- 	if win_lose_table[countKey] then
		-- 		--todo
		-- 		local count = win_lose_table[countKey] + 1

		-- 		win_lose_table[countKey] = count
		-- 	else
		-- 		local count = 1
		-- 		win_lose_table[countKey] = count
		-- 	end
		-- end

		card:setScale(scale)

		card:setPosition(cc.p(card:getSize().width * scale * (i - 1) + card:getSize().width * scale / 2, height / 2))

		bird_card_plane:addChild(card)
	end
end

function RoundEndingLayer:showPlayerCards(progCards, handCards, cardPlane, huCard)
	if not cardPlane then
		--todo
		return
	end

	local progCount = table.getn(progCards)
	local handCount = table.getn(handCards)

	local oriX = 0

	for i=1,progCount do
		local cType = progCards[i].type
		local cards = progCards[i]["cards"]

		for j=1,table.getn(cards) do
			local card

			if cType == "ag" and j == 1 then
				--todo
				card = Card:new(CARD_PLAYERTYPE_MY, CARD_TYPE_OUTHAND, CARD_DISPLAY_TYPE_HIDE, cards[j])
			else
				card = Card:new(CARD_PLAYERTYPE_MY, CARD_TYPE_OUTHAND, CARD_DISPLAY_TYPE_SHOW, cards[j])
			end

			local size = card:getSize()

			card:setPosition(cc.p(oriX + size.width / 2, size.height / 2))

			cardPlane:addChild(card)

			oriX = oriX + size.width
		end

		oriX = oriX + 20
	end

	for i=1,handCount do
		local card = Card:new(CARD_PLAYERTYPE_MY, CARD_TYPE_OUTHAND, CARD_DISPLAY_TYPE_SHOW, handCards[i])

		local size = card:getSize()

		card:setPosition(cc.p(oriX + size.width / 2, size.height / 2))

		cardPlane:addChild(card)

		oriX = oriX + size.width
	end

	if huCard then
		--todo
		oriX = oriX + 20

		local card = Card:new(CARD_PLAYERTYPE_MY, CARD_TYPE_OUTHAND, CARD_DISPLAY_TYPE_SHOW, huCard)

		local size = card:getSize()

		card:setPosition(cc.p(oriX + size.width / 2, size.height / 2))

		cardPlane:addChild(card)
	end
end


function RoundEndingLayer:dealPlayerCards(cards, huCard)
	if huCard and huCard > 0 then
		--todo
		for i=1,table.getn(cards) do
			if cards[i] == huCard then
				--todo
				table.remove(cards, i)

				break
			end
		end
	end
end

return RoundEndingLayer