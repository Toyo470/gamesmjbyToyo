mrequire("card.card_template")

CardLayout = class("CardLayout", card.card_template.card_Template)

function CardLayout:_do_after_init()

	self.card_dict = {
						self.card0_p0,
						self.card0_p1,
						self.card0_p2,
						
						self.card1_p0,
						self.card1_p1,
						self.card1_p2,

						self.card2_p0,
						self.card2_p1,
						self.card2_p2,

						self.card3_p0,
						self.card3_p1,
						self.card3_p2,

						self.card4_p0,
						self.card4_p1,
						self.card4_p2,
					}

	for _,icon in pairs(self.card_dict) do
		icon:setVisible(false)
		icon.srcS = icon:getScale()
		icon.srcP = icon:getPosition()
		icon:loadTexture("xlsg/res/image/pokercard/lord_card_backface_big.png")
	end

	self.delay_time = 0
	self.icon_inex = 0

	-- local sprite = cc.Sprite:create("xlsg/res/image/close.png")
	-- sprite:setPositionX(500)
	-- sprite:setPositionY(500)
 --    self:addChild(sprite)

end

function CardLayout:update(dt)
	--print("------------------CardLayout:update------------------------------------------")
	-- self.delay_time = self.delay_time or 0

	-- self.delay_time = self.delay_time + dt
	-- if self.delay_time > 0.2 then
	-- 	self.delay_time = 0 

	-- 	self.icon_inex = self.icon_inex  or 0

	-- 	self.icon_inex = self.icon_inex + 1

	-- 	local icon = self.card_dict[self.icon_inex]
		

	-- 	if icon ~= nil then
	-- 		local action1 = cc.MoveTo:create(0.5, icon.srcP)
	-- 		local action2 = cc.ScaleTo:create(0.5,icon.srcS)
	-- 		icon:runAction(cc.Spawn:create(action1,action2))
	-- 	else
	-- 		self:set_update_flag(false)
	-- 	end
	-- end
end

function CardLayout:show_all_cion()
	-- body
	-- for _,icon in pairs(self.card_dict) do
	-- 	icon:setVisible(true)
	-- end

end
--发牌
function CardLayout:startSendCard(game_account_data)
	-- body
	print("-------------------------------startSendCard----------------------------------")
	local certer_p = cc.p(465.59,307.80)
	for _,icon in pairs(self.card_dict) do
		-- icon:setVisible(true)
		icon:setScale(0.3)
		icon:setPosition(certer_p)
	end

	local delay_time = 0
	for user_id,user_data in pairs(game_account_data) do
    	local other_index = zzroom.manager:get_other_index(tonumber(user_id))
    	if other_index == nil then
    		break;
    	end
    	
    	if other_index == 0 then
    		self.card_dict[1]:setVisible(true)
    		self.card_dict[2]:setVisible(true)
    		self.card_dict[3]:setVisible(true)
    		

    	elseif other_index == 1 then
    		self.card_dict[4]:setVisible(true)
    		self.card_dict[5]:setVisible(true)
    		self.card_dict[6]:setVisible(true)
    		delay_time = delay_time + 0.2
    	elseif other_index == 2 then
    		self.card_dict[7]:setVisible(true)
    		self.card_dict[8]:setVisible(true)
    		self.card_dict[9]:setVisible(true)
    		delay_time = delay_time + 0.2
    	elseif other_index == 3 then
    		self.card_dict[10]:setVisible(true)
    		self.card_dict[11]:setVisible(true)
    		self.card_dict[12]:setVisible(true)
    		delay_time = delay_time + 0.2
    	elseif other_index == 4 then
    		self.card_dict[13]:setVisible(true)
    		self.card_dict[14]:setVisible(true)
    		self.card_dict[15]:setVisible(true)
    		delay_time = delay_time + 0.2
    	end

    	for _index = other_index*3+1,other_index*3+3 do
    		local icon = self.card_dict[_index]
    		if icon  then
		    	local action_delay = cc.DelayTime:create(delay_time)
				local action1 = cc.MoveTo:create(0.5, icon.srcP)
				local action2 = cc.ScaleTo:create(0.5,icon.srcS)
				icon:runAction(cc.Spawn:create(action_delay,action1,action2))

				delay_time = delay_time + 0.2
			end
		end

    end

    return delay_time
end

function CardLayout:set_paler_card(index,account_handcard)
	dump(account_handcard,"account_handcard")
	index = tonumber(index)
	local card_value_path = {}
    for _index,card_value in pairs(account_handcard) do
    	local card_path = card.get_card_path(card_value) or ""
        card_value_path[_index] = card_path
    end

    print("--------------------index-----------------",index)
    dump(card_value_path)
	if index == 0 then
		self.card0_p0:loadTexture(card_value_path[1] or "")
		self.card0_p1:loadTexture(card_value_path[2] or "")
		self.card0_p2:loadTexture(card_value_path[3] or "")
	elseif index == 1 then
		self.card1_p0:loadTexture(card_value_path[1] or "")
		self.card1_p1:loadTexture(card_value_path[2] or "")
		self.card1_p2:loadTexture(card_value_path[3] or "")
	elseif index == 2 then
		self.card2_p0:loadTexture(card_value_path[1] or "")
		self.card2_p1:loadTexture(card_value_path[2] or "")
		self.card2_p2:loadTexture(card_value_path[3] or "")
	elseif index == 3 then
		self.card3_p0:loadTexture(card_value_path[1] or "")
		self.card3_p1:loadTexture(card_value_path[2] or "")
		self.card3_p2:loadTexture(card_value_path[3] or "")
	elseif index == 4 then
		self.card4_p0:loadTexture(card_value_path[1] or "")
		self.card4_p1:loadTexture(card_value_path[2] or "")
		self.card4_p2:loadTexture(card_value_path[3] or "")
	end
end

function CardLayout:addBaseTip(index,base)
	self.card_base:addChild(base)
	if index == 0 then
		base:setPosition(self.card0_p1:getPosition())
	elseif index == 1 then
		base:setPosition(self.card1_p1:getPosition())
	elseif index == 2 then
		base:setPosition(self.card2_p1:getPosition())
	elseif index == 3 then
		base:setPosition(self.card3_p1:getPosition())
	elseif index == 4 then
		base:setPosition(self.card4_p1:getPosition())
	end

end

function CardLayout:before_release()
    -- body
    self.card_base:removeAllChildren()
end