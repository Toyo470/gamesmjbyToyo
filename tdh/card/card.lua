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
	self.m_ting_flag= flag
	self:initView()
	-- dump(self.m_ting_flag,"听队列显示暗化")
end

function Card:initView()
	self:loadTextureNormal("tdh/image/card/p_" .. self.m_playerType .. "_" .. self.m_cardDisplayType .. ".png")
	self:loadTextureDisabled("tdh/image/card/p_" .. self.m_playerType .. "_" .. self.m_cardDisplayType .. ".png")

	if self.m_playerType == CARD_PLAYERTYPE_MY then

		if self.m_cardDisplayType == CARD_DISPLAY_TYPE_OPPOSIVE then

			self.body:setTexture("tdh/image/card/" .. self.m_value .. ".png")
			self.body:setPosition(cc.p(27, 35))
         
			if self.m_ting_flag == true then 
               self:darkNode(self.body)
            end

		elseif self.m_cardDisplayType == CARD_DISPLAY_TYPE_SHOW then
			self.body:setTexture("tdh/image/card/" .. self.m_value .. ".png")
			self.body:setScale(32 / 62)
			self.body:setPosition(cc.p(14.5, 28))
		end
	elseif self.m_playerType == CARD_PLAYERTYPE_LEFT then
		if self.m_cardDisplayType == CARD_DISPLAY_TYPE_OPPOSIVE then

			self.body:setVisible(false)
		elseif self.m_cardDisplayType == CARD_DISPLAY_TYPE_SHOW then
			self.body:setVisible(true)

			self.body:setTexture("tdh/image/card/" .. self.m_value .. ".png")
			self.body:setScale(32 / 62)
			self.body:setPosition(cc.p(18.5, 23.5))
			self.body:setRotation(90)
		end

	elseif self.m_playerType == CARD_PLAYERTYPE_RIGHT then
		if self.m_cardDisplayType == CARD_DISPLAY_TYPE_OPPOSIVE then
			
			self.body:setVisible(false)
		elseif self.m_cardDisplayType == CARD_DISPLAY_TYPE_SHOW then
			self.body:setVisible(true)

			self.body:setTexture("tdh/image/card/" .. self.m_value .. ".png")
			self.body:setScale(32 / 62)
			self.body:setPosition(cc.p(18.5, 23.5))
			self.body:setRotation(-90)
		end
	elseif self.m_playerType == CARD_PLAYERTYPE_TOP then
		if self.m_cardDisplayType == CARD_DISPLAY_TYPE_OPPOSIVE then
			
			self.body:setVisible(false)
		elseif self.m_cardDisplayType == CARD_DISPLAY_TYPE_SHOW then
			self.body:setVisible(true)

			self.body:setTexture("tdh/image/card/" .. self.m_value .. ".png")
			self.body:setScale(32 / 62)
			self.body:setPosition(cc.p(14.5, 28))
			self.body:setRotation(180)
		end
	end

	if self.m_playerType == CARD_PLAYERTYPE_MY and self.m_cardType == CARD_TYPE_LEFTHAND then
		
		self:setScale(59 / 44)
	end

	if self.m_playerType == CARD_PLAYERTYPE_MY and self.m_cardType == CARD_TYPE_INHAND and (self.m_cardDisplayType == CARD_DISPLAY_TYPE_SHOW or self.m_cardDisplayType == CARD_DISPLAY_TYPE_HIDE) then
		
		self:setScale(54 / 29)
	end
end


-- --定义麻将牌筛选器
-- Card._FILTERS = {

-- 	-- custom
-- 	{"CUSTOM"},

-- 	-- {"CUSTOM", json.encode({frag = "Shaders/example_Flower.fsh",
-- 	-- 					center = {display.cx, display.cy},
-- 	-- 					resolution = {480, 320}})},

-- 	{{"CUSTOM", "CUSTOM"},
-- 		{json.encode({frag = "Shaders/example_Blur.fsh",
-- 			shaderName = "blurShader",
-- 			resolution = {480,320},
-- 			blurRadius = 10,
-- 			sampleNum = 5}),
-- 		json.encode({frag = "Shaders/example_sepia.fsh",
-- 			shaderName = "sepiaShader",})}},

-- 	-- colors
-- 	{"GRAY",{0.1, 250, 10, 0.1}},
-- 	{"RGB",{0.5, 0.5, 0.3}},
-- 	{"HUE", {90}},
-- 	{"BRIGHTNESS", {0.3}},
-- 	{"SATURATION", {0}},
-- 	{"CONTRAST", {2}},
-- 	{"EXPOSURE", {2}},
-- 	{"GAMMA", {2}},
-- 	{"HAZE", {0.1, 0.2}},
-- 	--{"SEPIA", {}},
-- 	-- blurs
-- 	{"GAUSSIAN_VBLUR", {7}},
-- 	{"GAUSSIAN_HBLUR", {7}},
-- 	{"ZOOM_BLUR", {4, 0.7, 0.7}},
-- 	{"MOTION_BLUR", {5, 135}},
-- 	-- others
-- 	{"SHARPEN", {1, 1}},
-- 	{{"GRAY", "GAUSSIAN_VBLUR", "GAUSSIAN_HBLUR"}, {nil, {10}, {10}}},
-- 	{{"BRIGHTNESS", "CONTRAST"}, {{0.1}, {4}}},
-- 	{{"HUE", "SATURATION", "BRIGHTNESS"}, {{240}, {1.5}, {-0.4}}},
-- }

-- --暗化我的手牌
-- function Card:dark()	
-- 	local __curFilter = Card._FILTERS[4]
-- 	local __filters, __params = unpack(__curFilter)
-- 	if __params and #__params == 0 then
-- 		__params = nil
-- 	end
-- 	if self.pannel_ then
-- 		self.pannel_:removeSelf()
-- 	end
	
-- 	self.darkOverlay_ = true
-- 	local str = "tdh/image/moniao_card02.png"
-- 	self.pannel_ = display.newFilteredSprite(str, __filters, __params):addTo(self):pos(0.5,0.5)

-- end

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