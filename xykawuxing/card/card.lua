local Card = class("Card", function ()
	return ccui.Button:create()
	end)

function Card:ctor(this, playerType, cardType, cardDisplayType, value)

	-- bm.index_card_tt = bm.index_card_tt  or 0
	-- self.status_      = 0 --0表示未设置状态 1 自己的手牌 2 为自己出的牌 3 出牌时很大的那个
	-- self.darkOverlay_ = false 
	-- self.handle_      = nil
	-- bm.index_card_tt=bm.index_card_tt+1
	-- self.id = bm.index_card_tt

	--print(self.id,"-------------------------------self,id")
	--4 左边的手牌 5 左边出的牌 6 右边的手牌 7 右边出的牌  8对门的手牌 9对门碰的牌
	--左边玩家手牌的背景
	-- self.left_hand_back_ = display.newSprite("majiang/room/MahjongImage.png"):addTo(self)
	-- self.left_hand_back_:setTextureRect(cc.rect(457,848,24,60))

	--左边玩家手牌的背景
	-- self.left_hand_back_ = display.newSprite("majiang/room/MahjongImage.png"):addTo(self)
	-- self.left_hand_back_:setTextureRect(cc.rect(689,178,36,16))

	self.body = display.newSprite():addTo(self)
	
	--self:setTouchEnabled(true)
	

	self:setCard(playerType, cardType, cardDisplayType, value)
end

function Card:setCard(playerType, cardType, cardDisplayType, value)
	self.m_playerType = playerType
	self.m_cardType = cardType
	self.m_cardDisplayType = cardDisplayType
	self.m_value = value

	self:initView()
end

function Card:initView()
	self:loadTextureNormal("xykawuxing/image/card/p_" .. self.m_playerType .. "_" .. self.m_cardDisplayType .. ".png")
	self:loadTextureDisabled("xykawuxing/image/card/p_" .. self.m_playerType .. "_" .. self.m_cardDisplayType .. ".png")

	if self.m_playerType == CARD_PLAYERTYPE_MY then
		--todo
		if self.m_cardDisplayType == CARD_DISPLAY_TYPE_OPPOSIVE then
			--todo
			self.body:setTexture("xykawuxing/image/card/" .. self.m_value .. ".png")
			self.body:setPosition(cc.p(27, 35))
		elseif self.m_cardDisplayType == CARD_DISPLAY_TYPE_SHOW then
			self.body:setTexture("xykawuxing/image/card/" .. self.m_value .. ".png")
			self.body:setScale(32 / 62)
			self.body:setPosition(cc.p(14.5, 28))
		end
	elseif self.m_playerType == CARD_PLAYERTYPE_LEFT then
		if self.m_cardDisplayType == CARD_DISPLAY_TYPE_OPPOSIVE then
			--todo
			self.body:setVisible(false)
		elseif self.m_cardDisplayType == CARD_DISPLAY_TYPE_SHOW then
			self.body:setVisible(true)

			self.body:setTexture("xykawuxing/image/card/" .. self.m_value .. ".png")
			self.body:setScale(32 / 62)
			self.body:setPosition(cc.p(18.5, 23.5))
			self.body:setRotation(90)
		end

	elseif self.m_playerType == CARD_PLAYERTYPE_RIGHT then
		if self.m_cardDisplayType == CARD_DISPLAY_TYPE_OPPOSIVE then
			--todo
			self.body:setVisible(false)
		elseif self.m_cardDisplayType == CARD_DISPLAY_TYPE_SHOW then
			self.body:setVisible(true)

			self.body:setTexture("xykawuxing/image/card/" .. self.m_value .. ".png")
			self.body:setScale(32 / 62)
			self.body:setPosition(cc.p(18.5, 23.5))
			self.body:setRotation(-90)
		end
	elseif self.m_playerType == CARD_PLAYERTYPE_TOP then
		if self.m_cardDisplayType == CARD_DISPLAY_TYPE_OPPOSIVE then
			--todo
			self.body:setVisible(false)
		elseif self.m_cardDisplayType == CARD_DISPLAY_TYPE_SHOW then
			self.body:setVisible(true)

			self.body:setTexture("xykawuxing/image/card/" .. self.m_value .. ".png")
			self.body:setScale(32 / 62)
			self.body:setPosition(cc.p(14.5, 28))
			self.body:setRotation(180)
		end
	end

	if self.m_playerType == CARD_PLAYERTYPE_MY and self.m_cardType == CARD_TYPE_LEFTHAND then
		--todo
		self:setScale(59 / 44)
	end

	if self.m_playerType == CARD_PLAYERTYPE_MY and self.m_cardType == CARD_TYPE_INHAND and (self.m_cardDisplayType == CARD_DISPLAY_TYPE_SHOW or self.m_cardDisplayType == CARD_DISPLAY_TYPE_HIDE) then
		--todo
		self:setScale(54 / 29)
	end
end



return Card