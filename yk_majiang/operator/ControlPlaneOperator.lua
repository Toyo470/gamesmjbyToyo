local Card = require("yk_majiang.card.card")

local ControlPlaneOperator = class("ControlPlaneOperator")

IMAGE_SHOW_TYPE_HU = "hu0"
IMAGE_SHOW_TYPE_GANG = "gang0"
IMAGE_SHOW_TYPE_PENG = "peng0"
IMAGE_SHOW_TYPE_CHI = "chi0"
IMAGE_SHOW_TYPE_GUO = "majong_guo_bt_n"
IMAGE_SHOW_TYPE_LIANG = "liang0"
IMAGE_SHOW_TYPE_ZIMO = "zimo0"

CHILD_NAME_SELECT_BOX = "select_box"
CHILD_NAME_GANG_SELECT_BOX = "gang_select_box"
CHILD_NAME_LEFT_CHI_BT = "left_chi_bt"
CHILD_NAME_MIDDLE_CHI_BT = "middle_chi_bt"
CHILD_NAME_RIGHT_CHI_BT = "right_chi_bt"

local CHILD_NAME_EFFECT_LIGHT = "light"
local CHILD_NAME_EFFECT_1 = "effect_1"
local CHILD_NAME_EFFECT_2 = "effect_2"
local CHILD_NAME_EFFECT_3 = "effect_3"

local CHILD_NAME_COMMIT_BT = "commit_bt"

local CONTROL_BT_SPLIT = 20

local buttonscale = 0.4

function ControlPlaneOperator:init(playerType, img, plane, lgPlane, tingHuPlane)
	img:setVisible(false)

	local position = cc.p(img:getSize().width / 2, img:getSize().height / 2)

	local light_img = ccui.ImageView:create()
    light_img:loadTexture("yk_majiang/image/effect/effect_guang.png")
    light_img:setPosition(position)
    light_img:setName(CHILD_NAME_EFFECT_LIGHT)
    img:addChild(light_img)

    local effect_3_img = ccui.ImageView:create()
    effect_3_img:loadTexture("yk_majiang/image/effect/effect_hu03.png")
    effect_3_img:setPosition(position)
    effect_3_img:setName(CHILD_NAME_EFFECT_3)
    img:addChild(effect_3_img)

    local effect_2_img = ccui.ImageView:create()
    effect_2_img:loadTexture("yk_majiang/image/effect/effect_hu02.png")
    effect_2_img:setPosition(position)
    effect_2_img:setName(CHILD_NAME_EFFECT_2)
    img:addChild(effect_2_img)

    local effect_1_img = ccui.ImageView:create()
    effect_1_img:loadTexture("yk_majiang/image/effect/effect_hu01.png")
    effect_1_img:setPosition(position)
    effect_1_img:setName(CHILD_NAME_EFFECT_1)
    img:addChild(effect_1_img)

	if plane then
		--todo
		self.hu_bt = ccui.Button:create()
		self.hu_bt:loadTextureNormal("yk_majiang/image/majong_hu_bt_p.png")
		self.hu_bt:setAnchorPoint(cc.p(0.5,0.75))
		self.hu_bt:setVisible(false)
		plane:addChild(self.hu_bt)

		self.gang_bt = ccui.Button:create()
		self.gang_bt:loadTextureNormal("yk_majiang/image/majong_gang_bt_p.png")
		self.gang_bt:setAnchorPoint(cc.p(0.5,0.75))
		self.gang_bt:setVisible(false)
		plane:addChild(self.gang_bt)

		self.peng_bt = ccui.Button:create()
		self.peng_bt:loadTextureNormal("yk_majiang/image/majong_peng_bt_p.png")
		self.peng_bt:setAnchorPoint(cc.p(0.5,0.75))
		self.peng_bt:setVisible(false)
		plane:addChild(self.peng_bt)

		self.chi_bt = ccui.Button:create()
		self.chi_bt:loadTextureNormal("yk_majiang/image/majong_chi_bt_p.png")
		self.chi_bt:setAnchorPoint(cc.p(0.5,0.75))
		self.chi_bt:setVisible(false)
		plane:addChild(self.chi_bt)

		self.guo_bt = ccui.Button:create()
		self.guo_bt:loadTextureNormal("yk_majiang/image/majong_guo_bt_n.png")
		self.guo_bt:setAnchorPoint(cc.p(0.5,0.75))
		self.guo_bt:setVisible(true)
		plane:addChild(self.guo_bt)

		self.xuanfenggang4_bt = ccui.Button:create()
		self.xuanfenggang4_bt:loadTextureNormal("yk_majiang/image/majong_gang_bt_p.png")
		self.xuanfenggang4_bt:setAnchorPoint(cc.p(0.5,0.75))
		self.xuanfenggang4_bt:setVisible(true)
		plane:addChild(self.xuanfenggang4_bt)

		self.xuanfenggang3_bt = ccui.Button:create()
		self.xuanfenggang3_bt:loadTextureNormal("yk_majiang/image/majong_gang_bt_p.png")
		self.xuanfenggang3_bt:setAnchorPoint(cc.p(0.5,0.75))
		self.xuanfenggang3_bt:setVisible(true)
		plane:addChild(self.xuanfenggang3_bt)

		self.select_bx = plane:getChildByName(CHILD_NAME_SELECT_BOX)
		self.select_bx:setVisible(false)

		self.gang_select_bx = plane:getChildByName(CHILD_NAME_GANG_SELECT_BOX)
		self.gang_select_bx:setVisible(false)

		self.left_chi_bt = self.select_bx:getChildByName(CHILD_NAME_LEFT_CHI_BT)
		self.middle_chi_bt = self.select_bx:getChildByName(CHILD_NAME_MIDDLE_CHI_BT)
		self.right_chi_bt = self.select_bx:getChildByName(CHILD_NAME_RIGHT_CHI_BT)

		self.liang_bt = ccui.Button:create()
		self.liang_bt:loadTextureNormal("yk_majiang/image/majong_liang_bt_p.png")
		self.liang_bt:setVisible(true)
		plane:addChild(self.liang_bt)

		plane:setVisible(false)

		local bt_callback = function(sender, event)
			if event == TOUCH_EVENT_ENDED then

				local controlType = YKMJ_CONTROL_TABLE["type"]
				local value = YKMJ_CONTROL_TABLE["value"]
				local gangCards = YKMJ_CONTROL_TABLE["gangCards"]

				if sender == self.hu_bt then
					--todo
					plane:setVisible(false)
					YKMJ_CONTROLLER:control(bit.band(controlType, CONTROL_TYPE_HU), value)
				elseif sender == self.gang_bt then
					if gangCards and table.getn(gangCards) == 1 then
						--todo
						plane:setVisible(false)
						YKMJ_CONTROLLER:control(bit.band(controlType, CONTROL_TYPE_GANG), gangCards[1])
					end
				elseif sender == self.peng_bt then
					plane:setVisible(false)
					YKMJ_CONTROLLER:control(bit.band(controlType, CONTROL_TYPE_PENG), value)
				elseif sender == self.left_chi_bt then
					plane:setVisible(false)
					YKMJ_CONTROLLER:control(CHI_TYPE_LEFT, value)
				elseif sender == self.middle_chi_bt then
					plane:setVisible(false)
					YKMJ_CONTROLLER:control(CHI_TYPE_MIDDLE, value)
				elseif sender == self.right_chi_bt then
					plane:setVisible(false)
					YKMJ_CONTROLLER:control(CHI_TYPE_RIGHT, value)
				elseif sender == self.guo_bt then
					plane:setVisible(false)
					YKMJ_CONTROLLER:control(0, value)
				elseif sender == self.chi_bt then
					local chiType
					local chiCount = 0

					--dump(controlType, "controlType chi test")
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

					--dump(chiCount, "chiCount chi test")
					if chiCount == 1 then
						--todo
						plane:setVisible(false)
						YKMJ_CONTROLLER:control(chiType, value)
					end
				elseif sender == self.liang_bt then
					plane:setVisible(false)
					
					-- if table.getn(YKMJ_CONTROL_TABLE.gangSeq) > 0 then
					-- 	--todo
					-- 	YKMJ_CONTROLLER:showLgSelectBox(YKMJ_CONTROL_TABLE.gangSeq)
					-- else
					-- 	-- YKMJ_CONTROLLER:showTingCards(YKMJ_CONTROL_TABLE.tingSeq)
					-- 	YKMJ_LG_CARDS = {}
					-- 	-- YKMJ_CONTROLLER:requestLiangGang()
					-- end
				elseif sender == self.xuanfenggang4_bt then
					plane:setVisible(false)
					YKMJ_CONTROLLER:control(bit.band(controlType, CONTROL_TYPE_XUANFENG4), value)
				elseif sender == self.xuanfenggang3_bt then
					plane:setVisible(false)
					YKMJ_CONTROLLER:control(bit.band(controlType, CONTROL_TYPE_XUANFENG3), value)
				end
			end
		end

		self.hu_bt:addTouchEventListener(bt_callback)
		self.xuanfenggang4_bt:addTouchEventListener(bt_callback)
		self.xuanfenggang3_bt:addTouchEventListener(bt_callback)
		self.gang_bt:addTouchEventListener(bt_callback)
		self.peng_bt:addTouchEventListener(bt_callback)
		self.left_chi_bt:addTouchEventListener(bt_callback)
		self.middle_chi_bt:addTouchEventListener(bt_callback)
		self.right_chi_bt:addTouchEventListener(bt_callback)
		self.guo_bt:addTouchEventListener(bt_callback)
		self.chi_bt:addTouchEventListener(bt_callback)
		self.liang_bt:addTouchEventListener(bt_callback)
	end

	if lgPlane then
		--todo
		lgPlane:setVisible(false)

		self.lg_select_box = lgPlane:getChildByName(CHILD_NAME_SELECT_BOX)
		self.commit_bt = lgPlane:getChildByName(CHILD_NAME_COMMIT_BT)

		self.commit_bt:addTouchEventListener(function(sender, event)
				if event == TOUCH_EVENT_ENDED then
					lgPlane:setVisible(false)

					YKMJ_LG_CARDS = {}

					for k,v in pairs(self.lg_select_box:getChildren()) do
						if v:getTag() == 0 then
							--todo
							table.insert(YKMJ_LG_CARDS, v.m_value)
						end
					end

					-- YKMJ_CONTROLLER:requestLiangGang()
					-- for i=table.getn(YKMJ_CONTROL_TABLE.tingSeq),1,-1 do
					-- 	for k,v in pairs(YKMJ_LG_CARDS) do
					-- 		if v == YKMJ_CONTROL_TABLE.tingSeq[i] then
					-- 			--todo
					-- 			table.remove(YKMJ_CONTROL_TABLE.tingSeq, i)
					-- 			break
					-- 		end
					-- 	end
					-- end
				end
			end)
	end

	if tingHuPlane then
		--todo
		tingHuPlane:setVisible(false)
	end
end

function ControlPlaneOperator:clearGameDatas(plane, lgPlane, tingHuPlane)
	if plane then
		--todo
		plane:setVisible(false)
	end

	if lgPlane then
		--todo
		lgPlane:setVisible(false)
	end

	if tingHuPlane then
		--todo
		tingHuPlane:setVisible(false)
	end
end

function ControlPlaneOperator:showImage(img, type)
	
	local img_type = ""
	if bit.band(type, CONTROL_TYPE_HU) > 0 then
		if bit.band(type, HU_TYPE_ZM) > 0 then
			img_type = IMAGE_SHOW_TYPE_ZIMO 
		else
			img_type = IMAGE_SHOW_TYPE_HU
		end
	elseif bit.band(type, CONTROL_TYPE_GANG) > 0 then
		img_type = IMAGE_SHOW_TYPE_GANG
	elseif bit.band(type, CONTROL_TYPE_PENG) > 0 then
		img_type = IMAGE_SHOW_TYPE_PENG
	elseif bit.band(type, CONTROL_TYPE_CHI) > 0 then
		img_type = IMAGE_SHOW_TYPE_CHI
	elseif bit.band(type, CONTROL_TYPE_TING) > 0 then
		img_type = IMAGE_SHOW_TYPE_LIANG
	elseif bit.band(type, CONTROL_TYPE_XUANFENG4) > 0 then
		img_type = IMAGE_SHOW_TYPE_GANG
	elseif bit.band(type, CONTROL_TYPE_XUANFENG3) > 0 then
		img_type = IMAGE_SHOW_TYPE_GANG
	end

	local light_img = img:getChildByName(CHILD_NAME_EFFECT_LIGHT)
	local effect_1_img = img:getChildByName(CHILD_NAME_EFFECT_1)
	local effect_2_img = img:getChildByName(CHILD_NAME_EFFECT_2)
	local effect_3_img = img:getChildByName(CHILD_NAME_EFFECT_3)

	effect_1_img:loadTexture("yk_majiang/image/effect/effect_" .. img_type .. "3.png")
	effect_2_img:loadTexture("yk_majiang/image/effect/effect_" .. img_type .. "2.png")
	effect_3_img:loadTexture("yk_majiang/image/effect/effect_" .. img_type .. "1.png")

	img:setVisible(true)

	light_img:setVisible(false)
	effect_1_img:setVisible(true)
	effect_2_img:setVisible(false)
	effect_3_img:setVisible(false)
     
	effect_1_img:setOpacity(255 * 0.3)
	local Sequence1 = cc.FadeTo:create(0.2, 255)
	local Sequence2 = cc.ScaleTo:create(0.4, 1.2)
	local DelayTime = cc.DelayTime:create(0.2)
	local Sequence3 = cc.FadeTo:create(0.5, 0)
	local effect_1_img_Sequence=cc.Sequence:create(Sequence1,Sequence2,DelayTime,Sequence3)
	effect_1_img:runAction(effect_1_img_Sequence)

	-- light_img:setOpacity(255 * 0.2)
	-- effect_3_img:setOpacity(255 * 0.3)
	-- light_img:setScale(0.8)
	-- effect_3_img:setScale(1)

	-- local scale_light = cc.ScaleTo:create(0.2, 1.1, 1.1, 1)
	-- local opacity_light = cc.FadeTo:create(0.2, 255 * 0.7)
	-- local scale_light_1 = cc.ScaleTo:create(0.1, 1, 1, 1)
	-- local opacity_light_1 = cc.FadeTo:create(0.1, 255 * 0.3)
	-- light_img:runAction(cc.Sequence:create(scale_light, cc.DelayTime:create(0.2), scale_light_1, cc.DelayTime:create(0.0), cc.FadeTo:create(1.2, 0)))
	-- light_img:runAction(cc.Sequence:create(opacity_light, cc.DelayTime:create(0.2), opacity_light_1, cc.DelayTime:create(0.0), cc.ScaleTo:create(1.2, 0.7, 0.7, 1)))

	-- local scale_3 = cc.ScaleTo:create(0.2, 1.2, 1.2, 1)
	-- local opacity_3 = cc.FadeTo:create(0.2, 255)
	-- local scale_3_1 = cc.ScaleTo:create(0.1, 1, 1, 1)
	-- local opacity_3_1 = cc.FadeTo:create(0.1, 255 * 0.3)
	-- effect_3_img:runAction(cc.Sequence:create(scale_3, cc.DelayTime:create(0.2), scale_3_1, cc.DelayTime:create(0.0), cc.FadeTo:create(1.2, 0)))
	-- effect_3_img:runAction(cc.Sequence:create(opacity_3, cc.DelayTime:create(0.2), opacity_3_1, cc.DelayTime:create(0.0), cc.ScaleTo:create(1.2, 0.7, 0.7, 1)))

	-- local callFunc_2 = cc.CallFunc:create(function()
	-- 		effect_2_img:setVisible(true)
	-- 		effect_2_img:setScale(0.8)
	-- 		effect_2_img:setOpacity(0)
	-- 	end)
	-- effect_2_img:runAction(cc.Sequence:create(cc.DelayTime:create(0.4), callFunc_2, cc.FadeTo:create(0.1, 255 * 0.5), cc.FadeTo:create(1.2, 0)))
	-- effect_2_img:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.ScaleTo:create(1.2, 0.7, 0.7, 1)))

	-- local callFunc_1 = cc.CallFunc:create(function()
	-- 		effect_1_img:setVisible(true)
	-- 		effect_1_img:setScale(0.7)
	-- 		effect_1_img:setOpacity(0)
	-- 	end)

	-- effect_1_img:runAction(cc.Sequence:create(cc.DelayTime:create(0.4), callFunc_1, cc.FadeTo:create(0.3, 255), cc.DelayTime:create(0.5), cc.FadeTo:create(0.5, 0)))

end

function ControlPlaneOperator:showPlane(plane, controlType)
	if controlType == 0 then
		--todo
		return
	end

	plane:setVisible(true)

	self.hu_bt:setVisible(false)
	self.gang_bt:setVisible(false)
	self.peng_bt:setVisible(false)
	self.chi_bt:setVisible(false)
	self.liang_bt:setVisible(false)
    self.xuanfenggang4_bt:setVisible(false)
    self.xuanfenggang3_bt:setVisible(false)
	self.select_bx:setVisible(false)
	self.gang_select_bx:setVisible(false)

	local oriX = 20

	-- --dump(controlType, "controlType test")

	if bit.band(controlType, CONTROL_TYPE_HU) > 0 then
		--todo
		self.hu_bt:setVisible(true)
		local size = self.hu_bt:getSize()
		self.hu_bt:setPosition(cc.p(oriX + size.width / 2, size.height / 2))

		oriX = oriX + size.width + CONTROL_BT_SPLIT -50
	end

	if bit.band(controlType, CONTROL_TYPE_GANG) > 0 then
		--todo
		self.gang_bt:setVisible(true)
		self.gang_select_bx:setVisible(true)
		local size = self.gang_bt:getSize()
		self.gang_bt:setPosition(cc.p(oriX + size.width / 2, size.height / 2))

		oriX = oriX + size.width

		if bit.band(controlType, CONTROL_TYPE_HU) == 0 then	   --没有胡时才显示杠选择框

		local box_width = self:showGangSelectBox(plane, controlType)

		self.gang_select_bx:setPosition(cc.p(oriX + box_width / 2, self.gang_select_bx:getSize().height / 2))
		self.gang_select_bx:setSize(cc.size(box_width, self.gang_select_bx:getSize().height))

		oriX = oriX + box_width

		end
	end

	if bit.band(controlType, CONTROL_TYPE_PENG) > 0 then
		--todo
		self.peng_bt:setVisible(true)
		local size = self.peng_bt:getSize()
		self.peng_bt:setPosition(cc.p(oriX + size.width / 2, size.height / 2))

		oriX = oriX + size.width + CONTROL_BT_SPLIT* buttonscale
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
    
    if bit.band(controlType, CONTROL_TYPE_XUANFENG4) > 0 then
		--todo
		self.xuanfenggang4_bt:setVisible(true)
		self.gang_select_bx:setVisible(true)

		local size = self.xuanfenggang4_bt:getSize()
		self.xuanfenggang4_bt:setPosition(cc.p(oriX + size.width / 2, size.height / 2))

		oriX = oriX + size.width

		local box_width = self:showXuanFeng4SelectBox(plane, controlType)

		self.gang_select_bx:setPosition(cc.p(oriX + box_width / 2, self.gang_select_bx:getSize().height / 2))
		self.gang_select_bx:setSize(cc.size(box_width, self.gang_select_bx:getSize().height))

		oriX = oriX + box_width
	end

	if bit.band(controlType, CONTROL_TYPE_XUANFENG3) > 0 then
		--todo
		self.xuanfenggang3_bt:setVisible(true)
		self.gang_select_bx:setVisible(true)

		local size = self.xuanfenggang3_bt:getSize()
		self.xuanfenggang3_bt:setPosition(cc.p(oriX + size.width / 2, size.height / 2))

		oriX = oriX + size.width

		local box_width = self:showXuanFeng3SelectBox(plane, controlType)

		self.gang_select_bx:setPosition(cc.p(oriX + box_width / 2, self.gang_select_bx:getSize().height / 2))
		self.gang_select_bx:setSize(cc.size(box_width, self.gang_select_bx:getSize().height))

		oriX = oriX + box_width
	end


	if bit.band(controlType, CONTROL_TYPE_TING) > 0 then
		-- self.liang_bt:setVisible(true)
		-- local size = self.liang_bt:getSize()
		-- self.liang_bt:setPosition(cc.p(oriX + size.width / 2, size.height / 2))

		-- oriX = oriX + size.width + CONTROL_BT_SPLIT
		
		-- plane:setVisible(false)
		-- local value = HNMJ_CONTROL_TABLE["value"]
		-- YKMJ_CONTROLLER:control(0, value)
	end

	local size = self.guo_bt:getSize()
	self.guo_bt:setPosition(cc.p(oriX + size.width / 2, size.height / 2))

	local width = oriX + size.width

	plane:setSize(cc.size(width, plane:getSize().height))
end

function ControlPlaneOperator:showSelectBox(controlType)
    local SelectBoxScale=1.3
	self.select_bx:setVisible(true)

	self.left_chi_bt:setVisible(false)
	self.middle_chi_bt:setVisible(false)
	self.right_chi_bt:setVisible(false)

	local value = YKMJ_CONTROL_TABLE["value"]

	local bx_width = 30


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
				card:setColor(cc.c3b(250, 250, 0))
			end
			
			card:setEnabled(false)
			self.right_chi_bt:addChild(card)

			bt_width = bt_width + size.width * scale
		end

		local position = self.right_chi_bt:getPosition()
		self.right_chi_bt:setPosition(cc.p(bx_width + bt_width / 2, position.y))
		local size = self.right_chi_bt:getSize()
		self.right_chi_bt:setSize(cc.size(bt_width, size.height))

		bx_width = bx_width + bt_width + 30

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
				card:setColor(cc.c3b(250, 250, 0))
			end

			card:setEnabled(false)
			self.middle_chi_bt:addChild(card)

			bt_width = bt_width + size.width * scale
		end

		local position = self.middle_chi_bt:getPosition()
		self.middle_chi_bt:setPosition(cc.p(bx_width + bt_width / 2, position.y))
		local size = self.middle_chi_bt:getSize()
		self.middle_chi_bt:setSize(cc.size(bt_width, size.height))

		bx_width = bx_width + bt_width + 30
	end

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
				card:setColor(cc.c3b(250, 250, 0))
			end

			card:setEnabled(false)
			self.left_chi_bt:addChild(card)

			bt_width = bt_width + size.width * scale
		end

		local position = self.left_chi_bt:getPosition()
		self.left_chi_bt:setPosition(cc.p(bx_width + bt_width / 2, position.y))
		local size = self.left_chi_bt:getSize()
		self.left_chi_bt:setSize(cc.size(bt_width, size.height))

		bx_width = bx_width + bt_width + 20
	end

	return bx_width
end

function ControlPlaneOperator:showXuanFeng4SelectBox(plane, controlType)
    self.gang_select_bx:removeAllChildren()

	local bx_width = 20

	local bt = ccui.Button:create()
	local bt_width = 0
	local bt_height = 38.55
	local xfg_feng={49,50,51,52}
	for i=1,4 do
		
		local card = Card:new(CARD_PLAYERTYPE_MY, CARD_TYPE_INHAND, CARD_DISPLAY_TYPE_OPPOSIVE, xfg_feng[i])
		local size = card:getSize()
		local scale = bt_height / size.height
		card:setScale(scale)
		card:setPosition(cc.p((i - 1) * size.width * scale + size.width * scale / 2, bt_height / 2))

		card:setTouchEnabled(true)
		card.noScale = true
		card:addTouchEventListener(function(sender, event)
			if event == TOUCH_EVENT_ENDED then
				-- local value = gangCards[sender:getTag()]

				plane:setVisible(false)
				YKMJ_CONTROLLER:control(bit.band(controlType, CONTROL_TYPE_XUANFENG4), 0)
			end
		end)

		bt:addChild(card)

		bt_width = bt_width + size.width * scale
	end
	bt:setPosition(cc.p(bx_width, (self.gang_select_bx:getSize().height - bt_height) / 2))
	bt:setSize(cc.size(bt_width, bt_height))

	self.gang_select_bx:addChild(bt)
   --dump(xfg_feng[i],"旋风杠风牌")
	bx_width = bx_width + bt_width + 20

	return bx_width
end

function ControlPlaneOperator:showXuanFeng3SelectBox(plane, controlType)
    self.gang_select_bx:removeAllChildren()

	local bx_width = 20

	local bt = ccui.Button:create()
	local bt_width = 0
	local bt_height = 38.55
	local xfg_jian={65,66,67}
	for i=1,3 do
		local card = Card:new(CARD_PLAYERTYPE_MY, CARD_TYPE_INHAND, CARD_DISPLAY_TYPE_OPPOSIVE, xfg_jian[i])
		local size = card:getSize()
		local scale = bt_height / size.height
		card:setScale(scale)
		card:setPosition(cc.p((i - 1) * size.width * scale + size.width * scale / 2, bt_height / 2))

		-- card:setEnabled(false)
		card:setTouchEnabled(true)
		card.noScale = true
		card:addTouchEventListener(function(sender, event)
			if event == TOUCH_EVENT_ENDED then
				-- local value = gangCards[sender:getTag()]

				plane:setVisible(false)
				YKMJ_CONTROLLER:control(bit.band(controlType, CONTROL_TYPE_XUANFENG3), 0)
			end
		end)

		bt:addChild(card)

		bt_width = bt_width + size.width * scale
	end
	bt:setPosition(cc.p(bx_width, (self.gang_select_bx:getSize().height - bt_height) / 2))
	bt:setSize(cc.size(bt_width, bt_height))

	self.gang_select_bx:addChild(bt)

	bx_width = bx_width + bt_width + 20

	return bx_width
end

function ControlPlaneOperator:showGangSelectBox(plane, controlType)
	self.gang_select_bx:removeAllChildren()
	local gangCards = YKMJ_CONTROL_TABLE["gangCards"]

	local bx_width = 20
	for k,v in pairs(gangCards) do
		local bt = ccui.Button:create()
		local bt_width = 0
		local bt_height = 38.55
		for i=1,4 do
			local card = Card:new(CARD_PLAYERTYPE_MY, CARD_TYPE_INHAND, CARD_DISPLAY_TYPE_OPPOSIVE, v)
			local size = card:getSize()
			local scale = bt_height / size.height
			card:setScale(scale)
			card:setPosition(cc.p((i - 1) * size.width * scale + size.width * scale / 2, bt_height / 2))

			-- card:setEnabled(false)
			card:setTouchEnabled(true)
			card.noScale = true
			card:addTouchEventListener(function(sender, event)
				if event == TOUCH_EVENT_ENDED then
					-- local value = gangCards[sender:getTag()]

					plane:setVisible(false)
					YKMJ_CONTROLLER:control(bit.band(controlType, CONTROL_TYPE_GANG), sender.m_value)
				end
			end)

			bt:addChild(card)

			bt_width = bt_width + size.width * scale
		end
		--print("bt_width, bt_height-------------------",bt_width, bt_height)
		bt:setPosition(cc.p(bx_width, (self.gang_select_bx:getSize().height - bt_height) / 2))
		bt:setSize(cc.size(bt_width, bt_height))

		self.gang_select_bx:addChild(bt)
		-- bt:setEnabled(true)
		-- bt:setTouchEnabled(true)
		bt:setTag(k)

		

		bx_width = bx_width + bt_width + 20
	end

	return bx_width
end

function ControlPlaneOperator:showLgSelectBox(plane, lgCards)
	self.lg_select_box:removeAllChildren()
	plane:setVisible(true)

	local oriX = 30
	for k,v in pairs(lgCards) do
		local card = Card:new(CARD_PLAYERTYPE_MY, CARD_TYPE_INHAND, CARD_DISPLAY_TYPE_OPPOSIVE, v)
		local size = card:getSize()
		local scale = 45.0 / size.height
		card:setScale(scale)
		card:setPosition(cc.p(oriX + size.width * scale / 2, self.lg_select_box:getSize().height / 2))

		self.lg_select_box:addChild(card)

		card:setTag(0)
		card:setEnabled(true)

		card:addTouchEventListener(function(sender, event)
				if event == TOUCH_EVENT_ENDED then
					if sender:getTag() == 999 then
						--todo
						sender:setTag(0)
						sender:setColor(cc.c3b(255, 255, 255))
					else
						sender:setTag(999)
						sender:setColor(cc.c3b(140, 140, 140))
					end
				end
			end)

		oriX = oriX + size.width * scale + 30
	end

	plane:setSize(cc.size(oriX + self.commit_bt:getSize().width, plane:getSize().height))
	self.lg_select_box:setSize(cc.size(oriX, self.lg_select_box:getSize().height))
	self.lg_select_box:setPosition(cc.p(self.lg_select_box:getSize().width / 2, self.lg_select_box:getPosition().y))
	self.commit_bt:setPosition(cc.p(self.lg_select_box:getSize().width + self.commit_bt:getSize().width / 2, self.commit_bt:getPosition().y))
end

function ControlPlaneOperator:showTingHuPlane(plane, tingHuCards)
	for k,v in pairs(plane:getChildren()) do
		if v:getName() == "title" or v:getName() =="renyipai" then
			--todo
		else
			v:removeFromParent()
		end
	end
	plane:setVisible(true)
   
	local title = plane:getChildByName("title")
	local renyipai = plane:getChildByName("renyipai")
	      renyipai:setVisible(false)
	local oriX = title:getPosition().x + title:getSize().width / 2
	local cardHeight = plane:getSize().height - 15
	local oriY = plane:getSize().height / 2

    ----------------数组去重
		local aa={} 
		for key,val in pairs(tingHuCards) do 
		aa[val]=true 
		end 
		local newtingHuCards={} 
		for key1,val1 in pairs(aa) do 
		table.insert(newtingHuCards,key1)         	
		end 
        table.sort(newtingHuCards)  
     -----------------
    if #newtingHuCards>25 then --胡任意牌
    	 renyipai:setVisible(true)
         local size = renyipai:getSize()
         
         oriX = oriX + size.width
    elseif  #newtingHuCards==0  then  --重连没给我发胡的牌的时候
    	 plane:setVisible(false)
    else	--不胡任意牌，胡特定牌
	for k,v in pairs(newtingHuCards) do
        renyipai:setVisible(false)

		local card = Card:new(CARD_PLAYERTYPE_MY, CARD_TYPE_INHAND, CARD_DISPLAY_TYPE_OPPOSIVE, v)
		local size = card:getSize()
		local scale = cardHeight / size.height
		card:setScale(scale)
		card:setPosition(cc.p(oriX + size.width * scale / 2, oriY))

		plane:addChild(card)

		card:setTag(0)
		card:setEnabled(true)

		oriX = oriX + size.width * scale
	end

	end--end  if #newtingHuCards>20

	plane:setSize(cc.size(oriX + 20, plane:getSize().height))
end

return ControlPlaneOperator