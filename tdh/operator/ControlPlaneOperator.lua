local Card = require("tdh.card.card")

local ControlPlaneOperator = class("ControlPlaneOperator")

IMAGE_SHOW_TYPE_HU = "hu0"
IMAGE_SHOW_TYPE_GANG = "gang0"
IMAGE_SHOW_TYPE_PENG = "peng0"
IMAGE_SHOW_TYPE_GUO = "majong_guo_bt_n"
IMAGE_SHOW_TYPE_LIANGXI="liang0"
IMAGE_SHOW_TYPE_TING="ting0"

local CHILD_NAME_EFFECT_LIGHT = "light"
local CHILD_NAME_EFFECT_1 = "effect_1"
local CHILD_NAME_EFFECT_2 = "effect_2"
local CHILD_NAME_EFFECT_3 = "effect_3"

local CONTROL_BT_SPLIT = 20

function ControlPlaneOperator:hideTing()
	local plane=TDHMJ_GAME_PLANE:getChildByName("my_card_plane")
	local ting_bt=plane:getChildByName("ting_bt")
	ting_bt:setVisible(false)
end

function ControlPlaneOperator:init(playerType, img, plane)
	img:setVisible(false)

	local position = cc.p(img:getSize().width / 2, img:getSize().height / 2)

	local light_img = ccui.ImageView:create()
    light_img:loadTexture("tdh/image/effect/effect_guang.png")
    light_img:setPosition(position)
    light_img:setName(CHILD_NAME_EFFECT_LIGHT)
    img:addChild(light_img)

    local effect_3_img = ccui.ImageView:create()
    effect_3_img:loadTexture("tdh/image/effect/effect_hu03.png")
    effect_3_img:setPosition(position)
    effect_3_img:setName(CHILD_NAME_EFFECT_3)
    img:addChild(effect_3_img)

    local effect_2_img = ccui.ImageView:create()
    effect_2_img:loadTexture("tdh/image/effect/effect_hu02.png")
    effect_2_img:setPosition(position)
    effect_2_img:setName(CHILD_NAME_EFFECT_2)
    img:addChild(effect_2_img)

    local effect_1_img = ccui.ImageView:create()
    effect_1_img:loadTexture("tdh/image/effect/effect_hu01.png")
    effect_1_img:setPosition(position)
    effect_1_img:setName(CHILD_NAME_EFFECT_1)
    img:addChild(effect_1_img)

	if plane then
		--todo
		self.hu_bt = ccui.Button:create()
		self.hu_bt:loadTextureNormal("tdh/image/majong_hu_bt_p.png")
		self.hu_bt:setVisible(false)
		plane:addChild(self.hu_bt)

		self.gang_bt = ccui.Button:create()
		self.gang_bt:loadTextureNormal("tdh/image/majong_gang_bt_p.png")
		self.gang_bt:setVisible(false)
		plane:addChild(self.gang_bt)

		self.peng_bt = ccui.Button:create()
		self.peng_bt:loadTextureNormal("tdh/image/majong_peng_bt_p.png")
		self.peng_bt:setVisible(false)
		plane:addChild(self.peng_bt)

		self.guo_bt = ccui.Button:create()
		self.guo_bt:loadTextureNormal("tdh/image/majong_guo_bt_n.png")
		self.guo_bt:setVisible(true)
		plane:addChild(self.guo_bt)

		self.liangxi_bt = ccui.Button:create()
		self.liangxi_bt:loadTextureNormal("tdh/image/majong_liangxi_bt_p.png")
		self.liangxi_bt:setVisible(false)
		plane:addChild(self.liangxi_bt)

		-- self.ting_bt = ccui.Button:create()
		-- self.ting_bt:loadTextureNormal("tdh/image/majong_ting_bt_p.png")
		-- self.ting_bt:setVisible(false)
		-- plane:addChild(self.ting_bt)

		plane:setVisible(false)
       
       --待填
		local bt_callback=function(sender, event)

			if event == TOUCH_EVENT_ENDED then

				local controlType = TDHMJ_CONTROL_TABLE["type"]
				local value = TDHMJ_CONTROL_TABLE["value"]

				if sender == self.hu_bt then             --胡
					--todo
					plane:setVisible(false)
					TDHMJ_CONTROLLER:control(bit.band(controlType, CONTROL_TYPE_HU), value)
				elseif sender == self.gang_bt then       --杠
					plane:setVisible(false)
					TDHMJ_CONTROLLER:control(bit.band(controlType, CONTROL_TYPE_GANG), value)
				elseif sender == self.peng_bt then       --碰
					plane:setVisible(false)
					TDHMJ_CONTROLLER:control(bit.band(controlType, CONTROL_TYPE_PENG), value)
				elseif sender == self.liangxi_bt then       --晾喜
					plane:setVisible(false)
					TDHMJ_CONTROLLER:control(bit.band(controlType, CONTROL_TYPE_LIANGXI), value)
				-- elseif sender == self.ting_bt then       --听牌
				-- 	plane:setVisible(false)
				-- 	TDHMJ_CONTROLLER:control(bit.band(controlType, CONTROL_TYPE_TING), value)
				elseif sender == self.guo_bt then           --过
					plane:setVisible(false)
					TDHMJ_CONTROLLER:control(0, value)
					self:hideTing()
			    end
           end
		end
		self.hu_bt:addTouchEventListener(bt_callback)
		self.gang_bt:addTouchEventListener(bt_callback)
		self.peng_bt:addTouchEventListener(bt_callback)
		self.liangxi_bt:addTouchEventListener(bt_callback)
		-- self.ting_bt:addTouchEventListener(bt_callback)
		self.guo_bt:addTouchEventListener(bt_callback)
	end

	if lgPlane then
		--todo
		lgPlane:setVisible(false)

		-- self.lg_select_box = lgPlane:getChildByName(CHILD_NAME_SELECT_BOX)
		-- self.commit_bt = lgPlane:getChildByName(CHILD_NAME_COMMIT_BT)
		-- self.lg_liang_bt = lgPlane:getChildByName(CHILD_NAME_LG_LIANG_BT)

		-- self.commit_bt:addTouchEventListener(function(sender, event)
		-- 		if event == TOUCH_EVENT_ENDED then
		-- 			lgPlane:setVisible(false)

		-- 			KWX_LG_CARDS = {}

		-- 			for k,v in pairs(self.lg_select_box:getChildren()) do
		-- 				if v:getTag() == 0 then
		-- 					--todo
		-- 					table.insert(KWX_LG_CARDS, v.m_value)
		-- 				end
		-- 			end

		-- 			TDHMJ_CONTROLLER:requestLiangGang()
		-- 		end
		-- 	end)

		-- self.lg_liang_bt:addTouchEventListener(function(sender, event)
		-- 		if event == TOUCH_EVENT_ENDED and table.getn(componentIndexs) > 0 then
		-- 			lgPlane:setVisible(false)

		-- 			TDHMJ_CONTROLLER:requestLiang(outCard, componentIndexs)
		-- 		end
		-- 	end)
	end

	if tingHuPlane then
		--todo
		tingHuPlane:setVisible(false)
	end
end

function ControlPlaneOperator:clearGameDatas(plane)
	if plane then
		--todo
		plane:setVisible(false)
	end
end


--控制特效
function ControlPlaneOperator:showImage(img, type)
	local img_type = ""
	if bit.band(type, CONTROL_TYPE_HU) > 0 then
		--todo
		img_type = IMAGE_SHOW_TYPE_HU
	elseif bit.band(type, CONTROL_TYPE_GANG) > 0 then
		img_type = IMAGE_SHOW_TYPE_GANG
	elseif bit.band(type, CONTROL_TYPE_PENG) > 0 then
		img_type = IMAGE_SHOW_TYPE_PENG
	elseif bit.band(type, CONTROL_TYPE_LIANGXI) > 0 then
		img_type = IMAGE_SHOW_TYPE_LIANGXI
	elseif bit.band(type, CONTROL_TYPE_TING) > 0 then
		img_type = IMAGE_SHOW_TYPE_TING
	end

	local light_img = img:getChildByName(CHILD_NAME_EFFECT_LIGHT)
	local effect_1_img = img:getChildByName(CHILD_NAME_EFFECT_1)
	local effect_2_img = img:getChildByName(CHILD_NAME_EFFECT_2)
	local effect_3_img = img:getChildByName(CHILD_NAME_EFFECT_3)

	effect_1_img:loadTexture("tdh/image/effect/effect_" .. img_type .. "3.png")
	effect_2_img:loadTexture("tdh/image/effect/effect_" .. img_type .. "2.png")
	effect_3_img:loadTexture("tdh/image/effect/effect_" .. img_type .. "1.png")

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

--显示碰杠胡按钮
function ControlPlaneOperator:showPlane(plane, controlType)
	if controlType == 0 then
		--todo
		return
	end

	plane:setVisible(true)

	self.hu_bt:setVisible(false)
	self.gang_bt:setVisible(false)
	self.peng_bt:setVisible(false)
	self.liangxi_bt:setVisible(false)
	-- self.ting_bt:setVisible(false)

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
	end

	if bit.band(controlType, CONTROL_TYPE_PENG) > 0 then
		--todo
		self.peng_bt:setVisible(true)
		local size = self.peng_bt:getSize()
		self.peng_bt:setPosition(cc.p(oriX + size.width / 2, size.height / 2))

		oriX = oriX + size.width + CONTROL_BT_SPLIT
	end

	
	if bit.band(controlType, CONTROL_TYPE_LIANGXI) > 0 then
		--todo
		self.liangxi_bt:setVisible(true)
		local size = self.liangxi_bt:getSize()
		self.liangxi_bt:setPosition(cc.p(oriX + size.width / 2, size.height / 2))

		oriX = oriX + size.width + CONTROL_BT_SPLIT
	end

	-- if bit.band(controlType, CONTROL_TYPE_TING) > 0 then
	-- 	--todo
	-- 	self.ting_bt:setVisible(true)
	-- 	local size = self.ting_bt:getSize()
	-- 	self.ting_bt:setPosition(cc.p(oriX + size.width / 2, size.height / 2))

	-- 	oriX = oriX + size.width + CONTROL_BT_SPLIT
	-- end

	local size = self.guo_bt:getSize()
	self.guo_bt:setPosition(cc.p(oriX + size.width / 2, size.height / 2))

	local width = oriX + size.width

	plane:setSize(cc.size(width, plane:getSize().height))
end


function ControlPlaneOperator:showComponentSelectBox(plane, outCardParam)
	-- self.lg_select_box:removeAllChildren()
	-- self.commit_bt:setVisible(false)
	-- self.lg_liang_bt:setVisible(true)
	-- plane:setVisible(true)

	-- local bx_width = 20

	-- outCard = outCardParam.card

	-- local huCardParams = outCardParam.tingHuCards
	-- for k,v in pairs(huCardParams) do
	-- 	local bt = ccui.Button:create()
	-- 	local bt_width = 0
	-- 	local bt_height = 38.55
	-- 	for k1,v1 in pairs(v.component) do
	-- 		local card = Card:new(CARD_PLAYERTYPE_MY, CARD_TYPE_INHAND, CARD_DISPLAY_TYPE_OPPOSIVE, v1)
	-- 		local size = card:getSize()
	-- 		local scale = bt_height / size.height
	-- 		card:setScale(scale)
	-- 		card:setPosition(cc.p((k1 - 1) * size.width * scale + size.width * scale / 2, bt_height / 2))

	-- 		card:setTouchEnabled(true)
	-- 		card.noScale = true
	-- 		card:addTouchEventListener(function(sender, event)
	-- 			if event == TOUCH_EVENT_ENDED then

	-- 				if sender:getParent():getTag() < 0 then
	-- 					--todo
	-- 					sender:getParent():setTag(0 - sender:getParent():getTag())

	-- 					for k2,v2 in pairs(sender:getParent():getChildren()) do
	-- 						v2:setColor(cc.c3b(255, 255, 255))
	-- 					end
						
	-- 				else
	-- 					sender:getParent():setTag(0 - sender:getParent():getTag())
						

	-- 					for k2,v2 in pairs(sender:getParent():getChildren()) do
	-- 						v2:setColor(cc.c3b(140, 140, 140))
	-- 					end
	-- 				end

	-- 				componentIndexs = {}

	-- 				local tingHuCards = {}
	-- 				for k2,v2 in pairs(self.lg_select_box:getChildren()) do

	-- 					if v2:getTag() > 0 then
	-- 						--todo
	-- 						table.insert(componentIndexs, v2:getTag())

	-- 						local huCards = huCardParams[v2:getTag()].huCards

	-- 						for k3,v3 in pairs(huCards) do
	-- 							local isExist = false
	-- 							for k4,v4 in pairs(tingHuCards) do
	-- 								if v3 == v4 then
	-- 									--todo
	-- 									isExist = true
	-- 									break
	-- 								end
	-- 							end
	-- 							if not isExist then
	-- 								--todo
	-- 								table.insert(tingHuCards, v3)
	-- 							end
	-- 						end
	-- 					end
	-- 				end

	-- 				TDHMJ_CONTROLLER:showTingHuPlane(tingHuCards)
	-- 			end
	-- 		end)

	-- 		bt:addChild(card)

	-- 		bt_width = bt_width + size.width * scale
	-- 	end
	-- 	bt:setPosition(cc.p(bx_width, (self.lg_select_box:getSize().height - bt_height) / 2))
	-- 	bt:setSize(cc.size(bt_width, bt_height))

	-- 	self.lg_select_box:addChild(bt)
	-- 	bt:setTag(k)

	-- 	bx_width = bx_width + bt_width + 20
	-- end

	-- plane:setSize(cc.size(bx_width + self.lg_liang_bt:getSize().width, plane:getSize().height))
	-- self.lg_select_box:setSize(cc.size(bx_width, self.lg_select_box:getSize().height))
	-- self.lg_select_box:setPosition(cc.p(self.lg_select_box:getSize().width / 2, self.lg_select_box:getPosition().y))
	-- self.lg_liang_bt:setPosition(cc.p(self.lg_select_box:getSize().width + self.lg_liang_bt:getSize().width / 2, self.lg_liang_bt:getPosition().y))

	-- 				componentIndexs = {}

					-- local tingHuCards = {}
					
	-- 				for k,v in pairs(huCardParams) do
	-- 					--todo
	-- 						table.insert(componentIndexs, k)

	-- 						local huCards = v.huCards

	-- 						for k3,v3 in pairs(huCards) do
	-- 							local isExist = false
	-- 							for k4,v4 in pairs(tingHuCards) do
	-- 								if v3 == v4 then
	-- 									--todo
	-- 									isExist = true
	-- 									break
	-- 								end
	-- 							end
	-- 							if not isExist then
	-- 								--todo
	-- 								table.insert(tingHuCards, v3)
	-- 							end
	-- 						end
	-- 				end

     --                local tingHuCards = outCardParam.tingHuCards
					-- TDHMJ_CONTROLLER:showTingHuPlane(tingHuCards)
end

function ControlPlaneOperator:showTingHuPlane(plane, tingHuCards)
	for k,v in pairs(plane:getChildren()) do
		if v:getName() ~= "title" then
			--todo
			v:removeFromParent()
		end
	end

	plane:setVisible(true)

	local title = plane:getChildByName("title")
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

	   for k1,v1 in pairs(newtingHuCards) do

		local card = Card:new(CARD_PLAYERTYPE_MY, CARD_TYPE_INHAND, CARD_DISPLAY_TYPE_OPPOSIVE, v1)
		local size = card:getSize()
		local scale = cardHeight / size.height
		card:setScale(scale)
		card:setPosition(cc.p(oriX + size.width * scale / 2, oriY))

		plane:addChild(card)

		card:setTag(0)
		card:setEnabled(true)

		oriX = oriX + size.width * scale
	   end  --end for


	plane:setSize(cc.size(oriX + 20, plane:getSize().height))
end

return ControlPlaneOperator