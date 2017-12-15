local Card = require("cs_majiang.card.card")

local ControlPlaneOperator = class("ControlPlaneOperator")

IMAGE_SHOW_TYPE_HU = "hu0"
IMAGE_SHOW_TYPE_GANG = "gang0"
IMAGE_SHOW_TYPE_PENG = "peng0"
IMAGE_SHOW_TYPE_CHI = "chi0"
IMAGE_SHOW_TYPE_GUO = "majong_guo_bt_n"

CHILD_NAME_SELECT_BOX = "select_box"
CHILD_NAME_LEFT_CHI_BT = "left_chi_bt"
CHILD_NAME_MIDDLE_CHI_BT = "middle_chi_bt"
CHILD_NAME_RIGHT_CHI_BT = "right_chi_bt"

local CHILD_NAME_EFFECT_LIGHT = "light"
local CHILD_NAME_EFFECT_1 = "effect_1"
local CHILD_NAME_EFFECT_2 = "effect_2"
local CHILD_NAME_EFFECT_3 = "effect_3"

local CONTROL_BT_SPLIT = 20

-- 美术资源
local RES_BTN_GANG		= "cs_majiang/image/majong_gang_bt_p.png"		-- “杠”按钮
local RES_BTN_BUZHANG	= "cs_majiang/image/majong_buzhang_bt_p.png"	-- “补张”按钮

function ControlPlaneOperator:init(playerType, img, plane)
	img:setVisible(false)

	local position = cc.p(img:getSize().width / 2, img:getSize().height / 2)

	local light_img = ccui.ImageView:create()
    light_img:loadTexture("cs_majiang/image/effect/effect_guang.png")
    light_img:setPosition(position)
    light_img:setName(CHILD_NAME_EFFECT_LIGHT)
    img:addChild(light_img)

    local effect_3_img = ccui.ImageView:create()
    effect_3_img:loadTexture("cs_majiang/image/effect/effect_hu03.png")
    effect_3_img:setPosition(position)
    effect_3_img:setName(CHILD_NAME_EFFECT_3)
    img:addChild(effect_3_img)

    local effect_2_img = ccui.ImageView:create()
    effect_2_img:loadTexture("cs_majiang/image/effect/effect_hu02.png")
    effect_2_img:setPosition(position)
    effect_2_img:setName(CHILD_NAME_EFFECT_2)
    img:addChild(effect_2_img)

    local effect_1_img = ccui.ImageView:create()
    effect_1_img:loadTexture("cs_majiang/image/effect/effect_hu01.png")
    effect_1_img:setPosition(position)
    effect_1_img:setName(CHILD_NAME_EFFECT_1)
    img:addChild(effect_1_img)

	if plane then
		--todo
		self.hu_bt = ccui.Button:create()
		self.hu_bt:loadTextureNormal("cs_majiang/image/majong_hu_bt_p.png")
		self.hu_bt:setVisible(false)
		plane:addChild(self.hu_bt)

		self.gang_bt = ccui.Button:create()
		-- @brief:非听状态下杠操作的资源显示为"补张", 听状态下显示为"杠".默认为补张
		-- @modify @Jhao. @2017-1-6 15:30:48 
		-- self.gang_bt:loadTextureNormal("cs_majiang/image/majong_gang_bt_p.png")
		self.gang_bt:loadTextureNormal(RES_BTN_BUZHANG)
		self.gang_bt:setVisible(false)
		plane:addChild(self.gang_bt)

		self.peng_bt = ccui.Button:create()
		self.peng_bt:loadTextureNormal("cs_majiang/image/majong_peng_bt_p.png")
		self.peng_bt:setVisible(false)
		plane:addChild(self.peng_bt)

		self.chi_bt = ccui.Button:create()
		self.chi_bt:loadTextureNormal("cs_majiang/image/majong_chi_bt_p.png")
		self.chi_bt:setVisible(false)
		plane:addChild(self.chi_bt)

		self.guo_bt = ccui.Button:create()
		self.guo_bt:loadTextureNormal("cs_majiang/image/majong_guo_bt_n.png")
		self.guo_bt:setVisible(true)
		plane:addChild(self.guo_bt)

		self.buzhang_bt = ccui.Button:create()
		self.buzhang_bt:loadTextureNormal("cs_majiang/image/majong_buzhang_bt_p.png")
		self.buzhang_bt:setVisible(true)
		plane:addChild(self.buzhang_bt)

		self.select_bx = plane:getChildByName(CHILD_NAME_SELECT_BOX)
		self.select_bx:setVisible(false)

		self.left_chi_bt = self.select_bx:getChildByName(CHILD_NAME_LEFT_CHI_BT)
		self.middle_chi_bt = self.select_bx:getChildByName(CHILD_NAME_MIDDLE_CHI_BT)
		self.right_chi_bt = self.select_bx:getChildByName(CHILD_NAME_RIGHT_CHI_BT)

		-- 变大 半径加5
		local addOffset = 5 * 2
		local fatherWidget = self.left_chi_bt:getParent()
		local fatherScale = (fatherWidget:getSize().height + addOffset) / fatherWidget:getSize().height
		fatherWidget:setScale(fatherScale)
		local scale = (self.left_chi_bt:getSize().height + addOffset) / self.left_chi_bt:getSize().height
		self.left_chi_bt:setScale(scale)
		self.middle_chi_bt:setScale(scale)
		self.right_chi_bt:setScale(scale)
		self.left_chi_bt:setPosition(cc.p(self.left_chi_bt:getPosition().x - addOffset/2, self.left_chi_bt:getPosition().y))
		self.right_chi_bt:setPosition(cc.p(self.right_chi_bt:getPosition().x + addOffset/2, self.right_chi_bt:getPosition().y))



		plane:setVisible(false)

		local bt_callback = function(sender, event)
			if event == TOUCH_EVENT_ENDED then

				local controlType = CSMJ_CONTROL_TABLE["type"]
				local value = CSMJ_CONTROL_TABLE["value"]

				if self.btnCallBackFunc ~= nil then -- 按钮回调
					self.btnCallBackFunc()
					self.btnCallBackFunc = nil 
				end

				if sender == self.hu_bt then
					--todo
					plane:setVisible(false)
					CSMJ_CONTROLLER:control(bit.band(controlType, CONTROL_TYPE_HU), value)
				elseif sender == self.gang_bt then
					plane:setVisible(false)
					-- CSMJ_CONTROLLER:control(bit.band(controlType, CONTROL_TYPE_GANG), value)
					
					if self.buzhang_bt:isVisible() then
						CSMJ_CONTROLLER:control(bit.band(controlType, CONTROL_TYPE_GANG), value, 1)
					else
						CSMJ_CONTROLLER:control(bit.band(controlType, CONTROL_TYPE_GANG), value)
					end

				elseif sender == self.buzhang_bt then
					plane:setVisible(false)
					CSMJ_CONTROLLER:control(bit.band(controlType, CONTROL_TYPE_GANG), value)
				elseif sender == self.peng_bt then
					plane:setVisible(false)
					CSMJ_CONTROLLER:control(bit.band(controlType, CONTROL_TYPE_PENG), value)
				elseif sender == self.left_chi_bt then
					plane:setVisible(false)
					CSMJ_CONTROLLER:control(CHI_TYPE_LEFT, value)
				elseif sender == self.middle_chi_bt then
					plane:setVisible(false)
					CSMJ_CONTROLLER:control(CHI_TYPE_MIDDLE, value)
				elseif sender == self.right_chi_bt then
					plane:setVisible(false)
					CSMJ_CONTROLLER:control(CHI_TYPE_RIGHT, value)
				elseif sender == self.guo_bt then
					plane:setVisible(false)
					CSMJ_CONTROLLER:control(0, value)
				elseif sender == self.chi_bt then
					local chiType
					local chiCount = 0

					dump(controlType, "controlType chi test")
					if bit.band(controlType, CHI_TYPE_LEFT) > 0 then
						--todo
						chiType = CHI_TYPE_LEFT
						chiCount = chiCount + 1
					end
					if bit.band(controlType, CHI_TYPE_MIDDLE) > 0 then
						--todo
						chiType = CHI_TYPE_MIDDLE
						chiCount = chiCount + 1
					end
					if bit.band(controlType, CHI_TYPE_RIGHT) > 0 then
						--todo
						chiType = CHI_TYPE_RIGHT
						chiCount = chiCount + 1
					end

					dump(chiCount, "chiCount chi test")
					if chiCount == 1 then
						--todo
						plane:setVisible(false)
						CSMJ_CONTROLLER:control(chiType, value)
					end
				end
			end
		end

		self.hu_bt:addTouchEventListener(bt_callback)
		self.gang_bt:addTouchEventListener(bt_callback)
		self.buzhang_bt:addTouchEventListener(bt_callback)
		self.peng_bt:addTouchEventListener(bt_callback)
		self.left_chi_bt:addTouchEventListener(bt_callback)
		self.middle_chi_bt:addTouchEventListener(bt_callback)
		self.right_chi_bt:addTouchEventListener(bt_callback)
		self.guo_bt:addTouchEventListener(bt_callback)
		self.chi_bt:addTouchEventListener(bt_callback)
	end
end

function ControlPlaneOperator:clearGameDatas(plane)
	if plane then
		--todo
		plane:setVisible(false)
	end
end

function ControlPlaneOperator:showImage(img, type)
	local img_type = ""
	if bit.band(type, CONTROL_TYPE_HU) > 0 then
		--todo
		img_type = IMAGE_SHOW_TYPE_HU
	elseif bit.band(type, CONTROL_TYPE_GANG) > 0 then
		img_type = IMAGE_SHOW_TYPE_GANG
	elseif bit.band(type, CONTROL_TYPE_PENG) > 0 then
		img_type = IMAGE_SHOW_TYPE_PENG
	elseif bit.band(type, CONTROL_TYPE_CHI) > 0 then
		img_type = IMAGE_SHOW_TYPE_CHI
	end

	local light_img = img:getChildByName(CHILD_NAME_EFFECT_LIGHT)
	local effect_1_img = img:getChildByName(CHILD_NAME_EFFECT_1)
	local effect_2_img = img:getChildByName(CHILD_NAME_EFFECT_2)
	local effect_3_img = img:getChildByName(CHILD_NAME_EFFECT_3)

	effect_1_img:loadTexture("cs_majiang/image/effect/effect_" .. img_type .. "3.png")
	effect_2_img:loadTexture("cs_majiang/image/effect/effect_" .. img_type .. "2.png")
	effect_3_img:loadTexture("cs_majiang/image/effect/effect_" .. img_type .. "1.png")

	img:setVisible(true)

	light_img:setVisible(true)
	effect_1_img:setVisible(false)
	effect_2_img:setVisible(false)
	effect_3_img:setVisible(true)

	light_img:setOpacity(255 * 0.2)
	effect_3_img:setOpacity(255 * 0.3)
	light_img:setScale(0.8)
	effect_3_img:setScale(1)

	local scale_light = cc.ScaleTo:create(0.2, 1.1, 1.1, 1)
	local opacity_light = cc.FadeTo:create(0.2, 255 * 0.7)
	local scale_light_1 = cc.ScaleTo:create(0.1, 1, 1, 1)
	local opacity_light_1 = cc.FadeTo:create(0.1, 255 * 0.3)
	light_img:runAction(cc.Sequence:create(scale_light, cc.DelayTime:create(0.2), scale_light_1, cc.DelayTime:create(0.0), cc.FadeTo:create(1.2, 0)))
	light_img:runAction(cc.Sequence:create(opacity_light, cc.DelayTime:create(0.2), opacity_light_1, cc.DelayTime:create(0.0), cc.ScaleTo:create(1.2, 0.7, 0.7, 1)))

	local scale_3 = cc.ScaleTo:create(0.2, 1.2, 1.2, 1)
	local opacity_3 = cc.FadeTo:create(0.2, 255)
	local scale_3_1 = cc.ScaleTo:create(0.1, 1, 1, 1)
	local opacity_3_1 = cc.FadeTo:create(0.1, 255 * 0.3)
	effect_3_img:runAction(cc.Sequence:create(scale_3, cc.DelayTime:create(0.2), scale_3_1, cc.DelayTime:create(0.0), cc.FadeTo:create(1.2, 0)))
	effect_3_img:runAction(cc.Sequence:create(opacity_3, cc.DelayTime:create(0.2), opacity_3_1, cc.DelayTime:create(0.0), cc.ScaleTo:create(1.2, 0.7, 0.7, 1)))

	local callFunc_2 = cc.CallFunc:create(function()
			effect_2_img:setVisible(true)
			effect_2_img:setScale(0.8)
			effect_2_img:setOpacity(0)
		end)
	effect_2_img:runAction(cc.Sequence:create(cc.DelayTime:create(0.4), callFunc_2, cc.FadeTo:create(0.1, 255 * 0.5), cc.FadeTo:create(1.2, 0)))
	effect_2_img:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.ScaleTo:create(1.2, 0.7, 0.7, 1)))

	local callFunc_1 = cc.CallFunc:create(function()
			effect_1_img:setVisible(true)
			effect_1_img:setScale(0.7)
			effect_1_img:setOpacity(0)
		end)

	effect_1_img:runAction(cc.Sequence:create(cc.DelayTime:create(0.4), callFunc_1, cc.FadeTo:create(0.3, 255), cc.DelayTime:create(0.5), cc.FadeTo:create(0.5, 0)))

end

function ControlPlaneOperator:showPlane(plane, controlType, _callBackFunc)
	if controlType == 0 then
		--todo
		return
	end

	if _callBackFunc ~= nil then
		self.btnCallBackFunc = _callBackFunc
	end

	plane:setVisible(true)

	self.hu_bt:setVisible(false)
	self.gang_bt:setVisible(false)
	self.buzhang_bt:setVisible(false)
	self.peng_bt:setVisible(false)
	self.chi_bt:setVisible(false)

	self.select_bx:setVisible(false)

	local oriX = 0

	dump(controlType, "controlType test")

	if bit.band(controlType, CONTROL_TYPE_HU) > 0 then
		--todo
		self.hu_bt:setVisible(true)
		local size = self.hu_bt:getSize()
		self.hu_bt:setPosition(cc.p(oriX + size.width / 2, size.height / 2))

		oriX = oriX + size.width + CONTROL_BT_SPLIT
	end

	if bit.band(controlType, CONTROL_TYPE_GANG) > 0 then
		--todo
		self.gang_bt:setVisible(true)
		local size = self.gang_bt:getSize()
		self.gang_bt:setPosition(cc.p(oriX + size.width / 2, size.height / 2))

		oriX = oriX + size.width + CONTROL_BT_SPLIT

		if bit.band(controlType, CONTROL_TYPE_BUZHANG) > 0 then
			self.gang_bt:loadTextureNormal(RES_BTN_GANG)
		else
			self.gang_bt:loadTextureNormal(RES_BTN_BUZHANG)
		end
	end

	if bit.band(controlType, CONTROL_TYPE_BUZHANG) > 0 then
		--todo
		self.buzhang_bt:setVisible(true)
		local size = self.buzhang_bt:getSize()
		self.buzhang_bt:setPosition(cc.p(oriX + size.width / 2, size.height / 2))

		oriX = oriX + size.width + CONTROL_BT_SPLIT
	end

	if bit.band(controlType, CONTROL_TYPE_PENG) > 0 then
		--todo
		self.peng_bt:setVisible(true)
		local size = self.peng_bt:getSize()
		self.peng_bt:setPosition(cc.p(oriX + size.width / 2, size.height / 2))

		oriX = oriX + size.width + CONTROL_BT_SPLIT
	end

	if bit.band(controlType, CONTROL_TYPE_CHI) > 0 then
		--todo
		self.chi_bt:setVisible(true)
		self.select_bx:setVisible(true)

		local size = self.chi_bt:getSize()
		self.chi_bt:setPosition(cc.p(oriX + size.width / 2, size.height / 2))

		oriX = oriX + size.width

		local box_width = self:showSelectBox(controlType)

		self.select_bx:setPosition(cc.p(oriX + box_width / 2, self.select_bx:getSize().height / 2))
		self.select_bx:setSize(cc.size(box_width, self.select_bx:getSize().height))

		oriX = oriX + box_width
	end

	local size = self.guo_bt:getSize()
	self.guo_bt:setPosition(cc.p(oriX + size.width / 2, size.height / 2))

	local width = oriX + size.width

	plane:setSize(cc.size(width, plane:getSize().height))
end

function ControlPlaneOperator:showSelectBox(controlType)
	self.select_bx:setVisible(true)

	self.left_chi_bt:setVisible(false)
	self.middle_chi_bt:setVisible(false)
	self.right_chi_bt:setVisible(false)

	local value = CSMJ_CONTROL_TABLE["value"]

	local bx_width = 20
	if bit.band(controlType, CHI_TYPE_LEFT) > 0 then
		--todo
		self.left_chi_bt:setVisible(true)
		self.left_chi_bt:removeAllChildren()

		local bt_width = 0
		for i=value,value + 2 do
			local card = Card:new(CARD_PLAYERTYPE_MY, CARD_TYPE_INHAND, CARD_DISPLAY_TYPE_OPPOSIVE, i)
			local size = card:getSize()
			local scale = self.left_chi_bt:getSize().height / size.height
			card:setScale(scale)
			card:setPosition(cc.p((i - value) * size.width * scale + size.width * scale / 2, self.left_chi_bt:getSize().height / 2))

			if value == i then
				--todo
				card:setColor(cc.c3b(140, 140, 140))
			end

			card:setEnabled(false)
			self.left_chi_bt:addChild(card)

			bt_width = bt_width + size.width * scale
		end

		local position = self.left_chi_bt:getPosition()
		self.left_chi_bt:setPosition(cc.p(bx_width + bt_width / 2 - 5, position.y))
		local size = self.left_chi_bt:getSize()
		self.left_chi_bt:setSize(cc.size(bt_width, size.height))

		bx_width = bx_width + bt_width + 20
	end

	if bit.band(controlType, CHI_TYPE_MIDDLE) > 0 then
		self.middle_chi_bt:setVisible(true)
		self.middle_chi_bt:removeAllChildren()

		local bt_width = 0
		for i=value - 1,value + 1 do
			local card = Card:new(CARD_PLAYERTYPE_MY, CARD_TYPE_INHAND, CARD_DISPLAY_TYPE_OPPOSIVE, i)
			local size = card:getSize()
			local scale = self.middle_chi_bt:getSize().height / size.height
			card:setScale(scale)
			card:setPosition(cc.p((i - value + 1) * size.width * scale + size.width * scale / 2, self.middle_chi_bt:getSize().height / 2))

			if value == i then
				--todo
				card:setColor(cc.c3b(140, 140, 140))
			end

			card:setEnabled(false)
			self.middle_chi_bt:addChild(card)

			bt_width = bt_width + size.width * scale
		end

		local position = self.middle_chi_bt:getPosition()
		self.middle_chi_bt:setPosition(cc.p(bx_width + bt_width / 2, position.y))
		local size = self.middle_chi_bt:getSize()
		self.middle_chi_bt:setSize(cc.size(bt_width, size.height))

		bx_width = bx_width + bt_width + 20
	end

	if bit.band(controlType, CHI_TYPE_RIGHT) > 0 then
		self.right_chi_bt:setVisible(true)
		self.right_chi_bt:removeAllChildren()

		local bt_width = 0
		for i=value - 2,value do
			local card = Card:new(CARD_PLAYERTYPE_MY, CARD_TYPE_INHAND, CARD_DISPLAY_TYPE_OPPOSIVE, i)
			local size = card:getSize()
			local scale = self.right_chi_bt:getSize().height / size.height
			card:setScale(scale)
			card:setPosition(cc.p((i - value + 2) * size.width * scale + size.width * scale / 2, self.right_chi_bt:getSize().height / 2))

			if value == i then
				--todo
				card:setColor(cc.c3b(140, 140, 140))
			end
			
			card:setEnabled(false)
			self.right_chi_bt:addChild(card)

			bt_width = bt_width + size.width * scale
		end

		local position = self.right_chi_bt:getPosition()
		self.right_chi_bt:setPosition(cc.p(bx_width + bt_width / 2 + 5, position.y))
		local size = self.right_chi_bt:getSize()
		self.right_chi_bt:setSize(cc.size(bt_width, size.height))

		bx_width = bx_width + bt_width + 20
	end

	return bx_width
end

return ControlPlaneOperator
