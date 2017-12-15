local Card = class("Card", function ()
	return ccui.Button:create()
	end)

function Card:ctor(this, playerType, cardType, cardDisplayType, value, flag)

	-- bm.index_card_tt = bm.index_card_tt  or 0
	-- self.status_      = 0 --0表示未设置状态 1 自己的手牌 2 为自己出的牌 3 出牌时很大的那个
	-- self.darkOverlay_ = false 
	-- self.handle_      = nil
	-- bm.index_card_tt=bm.index_card_tt+1
	-- self.id = bm.index_card_tt

	----print(self.id,"-------------------------------self,id")
	--4 左边的手牌 5 左边出的牌 6 右边的手牌 7 右边出的牌  8对门的手牌 9对门碰的牌
	--左边玩家手牌的背景
	-- self.left_hand_back_ = display.newSprite("majiang/room/MahjongImage.png"):addTo(self)
	-- self.left_hand_back_:setTextureRect(cc.rect(457,848,24,60))

	--左边玩家手牌的背景
	-- self.left_hand_back_ = display.newSprite("majiang/room/MahjongImage.png"):addTo(self)
	-- self.left_hand_back_:setTextureRect(cc.rect(689,178,36,16))

	self.body = display.newSprite():addTo(self)
	
	--self:setTouchEnabled(true)
	

	self:setCard(playerType, cardType, cardDisplayType, value, flag)
end

function Card:setCard(playerType, cardType, cardDisplayType, value, flag)
	self.m_playerType = playerType
	self.m_cardType = cardType
	self.m_cardDisplayType = cardDisplayType
	self.m_value = value
	
	if self.m_value == -127 then
		self.m_value=145
	end

	if self.m_value == -111 then
		self.m_value=129
	end
	self.m_huipai_flag = flag or false
    
	self:initView()
end

function Card:initView()
	self:loadTextureNormal("zz_majiang/image/card/p_" .. self.m_playerType .. "_" .. self.m_cardDisplayType .. ".png")
	self:loadTextureDisabled("zz_majiang/image/card/p_" .. self.m_playerType .. "_" .. self.m_cardDisplayType .. ".png")

	if self.m_playerType == CARD_PLAYERTYPE_MY then
		--todo
		if self.m_cardDisplayType == CARD_DISPLAY_TYPE_OPPOSIVE then
			--todo
			self.body:setTexture("zz_majiang/image/card/" .. self.m_value .. ".png")
			self.body:setPosition(cc.p(27, 35))
		elseif self.m_cardDisplayType == CARD_DISPLAY_TYPE_SHOW then
			self.body:setTexture("zz_majiang/image/card/" .. self.m_value .. ".png")
			self.body:setScale(32 / 62)
			self.body:setPosition(cc.p(14.5, 28))

		    if self.m_huipai_flag == true then 
               self:darkNode(self.body)
            end
		end
	elseif self.m_playerType == CARD_PLAYERTYPE_LEFT then
		if self.m_cardDisplayType == CARD_DISPLAY_TYPE_OPPOSIVE then
			--todo
			self.body:setVisible(false)
		elseif self.m_cardDisplayType == CARD_DISPLAY_TYPE_SHOW then
			self.body:setVisible(true)

			self.body:setTexture("zz_majiang/image/card/" .. self.m_value .. ".png")
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

			self.body:setTexture("zz_majiang/image/card/" .. self.m_value .. ".png")
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

			self.body:setTexture("zz_majiang/image/card/" .. self.m_value .. ".png")
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

--暗化手牌卡面
function Card:darkNode(node)
    local vertDefaultSource = "\n"..
    "attribute vec4 a_position; \n" ..
    "attribute vec2 a_texCoord; \n" ..
    "attribute vec4 a_color; \n"..                                                    
    "#ifdef GL_ES  \n"..
    "varying lowp vec4 v_fragmentColor;\n"..
    "varying mediump vec2 v_texCoord;\n"..
    "#else                      \n" ..
    "varying vec4 v_fragmentColor; \n" ..
    "varying vec2 v_texCoord;  \n"..
    "#endif    \n"..
    "void main() \n"..
    "{\n" ..
    "gl_Position = CC_PMatrix * a_position; \n"..
    "v_fragmentColor = a_color;\n"..
    "v_texCoord = a_texCoord;\n"..
    "}"
     
    local pszFragSource = "#ifdef GL_ES \n" ..
    "precision mediump float; \n" ..
    "#endif \n" ..
    "varying vec4 v_fragmentColor; \n" ..
    "varying vec2 v_texCoord; \n" ..
    "void main(void) \n" ..
    "{ \n" ..
    "vec4 c = texture2D(CC_Texture0, v_texCoord); \n" ..
    "gl_FragColor.xyz = vec3(0.1*c.r + 0.1*c.g +0.1*c.b); \n"..
    "gl_FragColor.w = c.w; \n"..
    "}"
 
    local pProgram = cc.GLProgram:createWithByteArrays(vertDefaultSource,pszFragSource)
     
    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION,cc.VERTEX_ATTRIB_POSITION)
    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR,cc.VERTEX_ATTRIB_COLOR)
    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD,cc.VERTEX_ATTRIB_FLAG_TEX_COORDS)
    pProgram:link()
    pProgram:updateUniforms()
    node:setGLProgram(pProgram)
end



return Card