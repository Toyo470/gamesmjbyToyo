mrequire("zzroom.deal_card_path")
mrequire("zzroom.room_card_template")
local MajiangroomServer = require("zz_majiang.MajiangroomServer")

RoomCardLayout = class("RoomCardLayout", zzroom.room_card_template.room_card_Template)

function RoomCardLayout:_do_after_init()
	self:set_update_flag(true)
	self.delty = 0
	self.flag = 1
	self.src_dot_y = -30

	self.ting_tbl = {}
	self.room_card_ting_card:setVisible(false)

	--self.ting_tbl[36] = {2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2}
	-- print("-------------------function RoomCardLayout:_do_after_init-----------------------")
	-- print(self.room_card_ting_base:getPositionX(),"---",self.room_card_ting_base:getPositionY())
	-- print(self.room_card_ting_image:getPositionX(),"---",self.room_card_ting_image:getPositionY())

end

function RoomCardLayout:update(dt)
	self.delty = self.delty + dt*10*self.flag

	if self.flag == 1 then
		if self.delty > 6  then
			self.flag = -1
		end
	end

	if self.flag == -1 then
		if self.delty < 0  then
		  self.flag = 1
		end
	end
	--print(self.delty,"-------------------delty-------------------self.flag-",self.flag)

	
	self.room_card_dot:setPositionY(self.src_dot_y + self.delty)

end

function RoomCardLayout:drawHandCard( other_index,listener_flag,zhua_card,need_kongge,_handle)
	-- body
	local  player_card = zzroom.manager:get_card(other_index)
	local prog_card = player_card["porg"] or {}
	local hand_card = player_card["hand"] or {}
	local gang_card = player_card["gang"] or {}

	dump(player_card)

	if other_index == 0 then
		listener_flag = listener_flag or false

		if listener_flag == false then
			local num_less = table.nums(hand_card) % 3
			if num_less == 2 then
				listener_flag = true
			end
		end
		if _handle then
			if _handle==0x800 or _handle ==0x200 or _handle== 0x400 then  --通过handle控制是否可以出牌的动作
				listener_flag=false
  			end
		end
		local x = 30
		local y = 2.49
		self.room_card_image0:removeAllChildren()	--清空手牌 
		local width = self.room_card_peng0:getContentSize().width  --获取碰杠牌的width
		local card_num = 0
		for _,card_value in pairs(prog_card) do
			if gang_card[card_value] == 1 then 
				card_num = card_num + 1 
			else
				card_num = 0
			end

			if card_num == 4 then
				local card = self.room_card_back0:clone()
				card:setPosition(cc.p(x-2*width,y+20))
				self.room_card_image0:addChild(card)
				card_num = 0
			else
				local image =  zzroom.deal_card_path.get_card_path(card_value)  --获取牌的texture路径
				local card = self.room_card_peng0:clone()		--新建一个碰牌
				card:setPosition(cc.p(x,y))
				local room_peng_card0_image = card:getChildByName("room_card_peng0_image")
				room_peng_card0_image:loadTexture(image)	--设置牌的花色
				self.room_card_image0:addChild(card)
				x = x + width
			end
		end
		
		width = self.room_card_hand0:getContentSize().width  --获取手牌的width
		width = width * 1.1
		x = x + 20
		-- if USER_INFO['uid']==1570 then   -- 测牌型问题专用
		-- 	hand_card={1,2,3,4,5,6,7,8,9,33,35,37,65}
		-- end
		table.sort(hand_card,function(v1,v2) return v1 < v2 end)  --手牌排序
		dump(hand_card,"hand_card")

		local last_card_spr = nil
		for _,card_value in pairs(hand_card) do
			if tonumber(card_value) == 0x41 then --先绘制红中癞子，呵呵
				local image =  zzroom.deal_card_path.get_card_path(card_value)  --获取牌的texture路径
				local card = self.room_card_hand0:clone()  --新建一个手牌
				local room_card_hand_image = card:getChildByName("room_card_hand0_image")
				--print("image------------",image)
				room_card_hand_image:loadTexture(image)

				card:setPosition(cc.p(x,y))
				card._card_value = card_value
				card:setTouchEnabled(false)
				if listener_flag == true then
					self:add_eventlistener(card)
				end
				self.room_card_image0:addChild(card)
				x = x + width
				last_card_spr = card
			end
		end

		for _,card_value in pairs(hand_card) do
			if tonumber(card_value) ~= 0x41 then--再绘制其他牌，呵呵
				local image =  zzroom.deal_card_path.get_card_path(card_value)  --获取牌的texture路径
				local card = self.room_card_hand0:clone()   --新建一个手牌
				local room_card_hand_image = card:getChildByName("room_card_hand0_image")
				--print("image------------",image)
				room_card_hand_image:loadTexture(image)  --绘制手牌

				card:setPosition(cc.p(x,y))
				card._card_value = card_value
				card:setTouchEnabled(false)
				if listener_flag == true then
					self:add_eventlistener(card)
				end
				self.room_card_image0:addChild(card)
				x = x + width

				last_card_spr = card
			end
		end

		if zhua_card ~= nil then
			x = x + 5
			local image =  zzroom.deal_card_path.get_card_path(zhua_card)
			local card = self.room_card_hand0:clone()
			local room_card_hand_image = card:getChildByName("room_card_hand0_image")
			--print("image------------",image)
			room_card_hand_image:loadTexture(image)

			card:setPosition(cc.p(x,y))
			card._card_value = zhua_card
			card:setTouchEnabled(false)
			if listener_flag == true then
				self:add_eventlistener(card)
			end
			self.room_card_image0:addChild(card)
			x = x + width
			last_card_spr = card
		end
		dump(self.room_card_image0,"self.room_card_image0")
		need_kongge = need_kongge or false

		if need_kongge == true and last_card_spr ~= nil and listener_flag == true then
			local spr_x = last_card_spr:getPositionX()
			spr_x =spr_x + 5
			last_card_spr:setPositionX(spr_x)
		end

		zzroom.manager:set_last_pos(0,cc.p(x, y))

	elseif other_index == 1 then
		self.room_card_image1:removeAllChildren()
		local x = 133.40
		local y = 462.62
		local height = 20.8
		local index = 1
		local card_num = 0
		for _,card_value in pairs(prog_card) do
			if gang_card[card_value] == 1 then 
				card_num = card_num + 1 
			else
				card_num = 0
			end

			if card_num == 4 then
				local card = self.room_card_back1:clone()
				card:setPosition(cc.p(x,y+2*height+15))
				self.room_card_image1:addChild(card)
				card_num = 0
			else
				local card = self.room_card_peng1:clone()
				card:setPosition(cc.p(x, y))

				local image =  zzroom.deal_card_path.get_card_path(card_value)
				local room_peng_card1_image = card:getChildByName("room_card_peng1_image")
				room_peng_card1_image:loadTexture(image)

				self.room_card_image1:addChild(card)
				y = y -  height
			end
		end

		y = y -  height/2
		table.sort(hand_card,function(v1,v2) return v1 < v2 end)
		for _,card_value in pairs(hand_card) do
			if card_value == 0 then
				local card = self.room_card_hand1:clone()
				card:setPosition(cc.p(x, y))
				self.room_card_image1:addChild(card)
				y = y -  height
			else
				local card = self.room_card_peng1:clone()
				card:setPosition(cc.p(x, y))

				local image =  zzroom.deal_card_path.get_card_path(card_value)
				local room_peng_card1_image = card:getChildByName("room_card_peng1_image")
				room_peng_card1_image:loadTexture(image)

				self.room_card_image1:addChild(card)
				y = y -  (height+1.5)
			end
		end

		zzroom.manager:set_last_pos(1,cc.p(x, y))

	elseif other_index == 2 then
		self.room_card_image2:removeAllChildren()
		local x = 790
		local y = 454.24

		local width = self.room_card_peng2:getContentSize().width
		local card_num = 0
		for _,card_value in pairs(prog_card) do
			if gang_card[card_value] == 1 then 
				card_num = card_num + 1 
			else
				card_num = 0
			end
			if card_num == 4 then
				local card = self.room_card_back2:clone()
				card:setPosition(cc.p(x+2*width,y+10))
				self.room_card_image2:addChild(card)
				card_num = 0
			else
				local card = self.room_card_peng2:clone()
				card:setPosition(cc.p(x,y))
				local image =  zzroom.deal_card_path.get_card_path(card_value)
				local room_peng_card2_image = card:getChildByName("room_card_peng2_image")
				room_peng_card2_image:loadTexture(image)
				self.room_card_image2:addChild(card)
				x = x - width
			end
		end

		x = x - 20
		width = self.room_card_hand2:getContentSize().width
		table.sort(hand_card,function(v1,v2) return v1 < v2 end)
		for _,card_value in pairs(hand_card) do
			if card_value == 0 then
				local card = self.room_card_hand2:clone()
				card:setPosition(cc.p(x,y))
				self.room_card_image2:addChild(card)

				x = x - width
			else
				local card = self.room_card_peng2:clone()
				card:setPosition(cc.p(x,y))
				local image =  zzroom.deal_card_path.get_card_path(card_value)
				local room_peng_card2_image = card:getChildByName("room_card_peng2_image")
				room_peng_card2_image:loadTexture(image)
				self.room_card_image2:addChild(card)
				x = x - (width-1.6)
			end
		end
		zzroom.manager:set_last_pos(2,cc.p(x, y))

	elseif other_index == 3 then
		self.room_card_image3:removeAllChildren()
		local x = 809.62
		local y = 384.31
		local height = 20.8--这个高不是控件的高

		zzroom.manager:set_last_pos(3,cc.p(x, y+height))

		table.sort(hand_card,function(v1,v2) return v1 < v2 end)
		for _,card_value in pairs(hand_card) do
			if card_value == 0 then
				local card = self.room_card_hand3:clone()
				card:setPosition(cc.p(x,y))
				self.room_card_image3:addChild(card)
				y = y - height
			else
				local card = self.room_card_peng3:clone()
				card:setPosition(cc.p(x,y))

				local image =  zzroom.deal_card_path.get_card_path(card_value)
				local room_peng_card3_image = card:getChildByName("room_card_peng3_image")
				room_peng_card3_image:loadTexture(image)

				self.room_card_image3:addChild(card)
				y = y - height
			end
		end

		y = y - 20
		local card_num = 0
		for _,card_value in pairs(prog_card) do
			if gang_card[card_value] == 1 then 
				card_num = card_num + 1 
			else
				card_num = 0
			end

			if card_num == 4 then
				local card = self.room_card_back1:clone()
				card:setPosition(cc.p(x,y+2.5*height))
				self.room_card_image3:addChild(card)
				card_num = 0
			else
				local card = self.room_card_peng3:clone()
				card:setPosition(cc.p(x,y))

				local image =  zzroom.deal_card_path.get_card_path(card_value)
				local room_peng_card3_image = card:getChildByName("room_card_peng3_image")
				room_peng_card3_image:loadTexture(image)

				self.room_card_image3:addChild(card)
				y = y - (height + 1.5)
			end
		end

		
 	end

end

--创建各家的抓牌
function RoomCardLayout:draw_zhua_card(index,card_value)
	 
  	local pos = zzroom.manager:get_last_pos(index)
  	self:remove_zhua_card()
  	if index == 0 and card_value ~= nil then

		local image =  zzroom.deal_card_path.get_card_path(card_value)
		local card = self.room_card_hand0:clone()
		local room_card_hand_image = card:getChildByName("room_card_hand0_image")
		room_card_hand_image:loadTexture(image)
		pos.x = pos.x + 5
		card:setPosition(pos)
		card._card_value = card_value

		card:setTouchEnabled(false)
		self:add_eventlistener(card)
		self.room_card_image:addChild(card)

		card:setName("zhua")

	elseif index == 1 then
		local card = self.room_card_hand1:clone()
		pos.y = pos.y - 10

		card:setPosition(pos)
		self.room_card_image:addChild(card)

		card:setName("zhua")

	elseif index == 2 then
		local card = self.room_card_hand2:clone()
		pos.x = pos.x - 5
		card:setPosition(pos)
		self.room_card_image:addChild(card)

		card:setName("zhua")

	elseif index == 3 then
		local card = self.room_card_hand3:clone()
		pos.y = pos.y + 10
		card:setPosition(pos)
		self.room_card_image:addChild(card)
		card:setLocalZOrder(-100)

		card:setName("zhua")
	end
end

--删除各家的抓牌
function RoomCardLayout:remove_zhua_card()
	local zhua = self.room_card_image:getChildByName("zhua")
	if  zhua then
		zhua:removeSelf()
	end
end

--在当前玩家前展示出牌的效果，一张2倍大的牌，然后缩小放到桌面
function RoomCardLayout:draw_chu_card(index,card_value)
	-- body  
	--这里表示的是牌从哪个位置开始打出来
  local config = {
  		  [0]={['x'] = 470.81,['y'] = 186.19,},
          [1]={['x'] = 212.41,['y'] = 314.60,},
          [2]={['x'] = 470.81,['y'] = 425.79,},
          [3]={['x'] = 763.66,['y'] = 314.60,}
      }
	local chu = self.room_card_image:getChildByName("chu")
	if chu then
		chu:removeSelf()
	end

	local card = self.room_card_peng0:clone()
	local room_peng_card0_image = card:getChildByName("room_card_peng0_image")
	local image =  zzroom.deal_card_path.get_card_path(card_value)
	room_peng_card0_image:loadTexture(image)

	card:setName("chu")
	card:setScale(2.0)
	card:setAnchorPoint(cc.p(0.5, 0.5))
	card:setPosition(config[index]['x'],config[index]['y'])

	self.room_card_image:addChild(card)

end

--删除各家的出牌
function RoomCardLayout:remove_chu_card()
	-- body
	local chu = self.room_card_image:getChildByName("chu")
	--local action2 = cc.Sequence:create(cc.FadeOut:create(0.1),cc.RemoveSelf:create())
	local action2 = cc.RemoveSelf:create()
	if  chu then
      	chu:runAction(action2)
	end
end

function RoomCardLayout:remove_other_chu_card()
	-- body
	local chu = self.room_card_image:getChildByName("chu")
	if  chu then
      	chu:removeSelf()
	end
end


--绘制打出的牌 重登需要才需要调用这个
function RoomCardLayout:draw_out_card( index )
	--print("---------------index-------------",index)
	local  player_card = zzroom.manager:get_card(index)
	local out_card = player_card["out"] or {}
	dump(out_card,"out_card")

	if index == 0 then
		self.room_card_outimage0:removeAllChildren()
	elseif index == 1 then
		self.room_card_outimage1:removeAllChildren()
	elseif index == 2 then
		self.room_card_outimage2:removeAllChildren()
	elseif index == 3 then
		self.room_card_outimage3:removeAllChildren()
	end
	
	for _,card_value in pairs(out_card) do
		self:create_one_out_card(index,card_value)
	end
end

--创建一张-打出的牌
function RoomCardLayout:create_one_out_card( index,card_value,show_dot)
		local image_name = ""
		local card = nil
		local childrenCount = 0
		if index == 0 then
			childrenCount = self.room_card_outimage0:getChildrenCount()
			image_name = "room_card_out0_image"
			card = self.room_card_out0:clone()
		elseif index == 1 then
			childrenCount = self.room_card_outimage1:getChildrenCount()
			image_name = "room_card_peng1_image"
			card = self.room_card_peng1:clone()
		elseif index == 2 then
			childrenCount = self.room_card_outimage2:getChildrenCount()
			image_name = "room_card_peng2_image"
			card = self.room_card_peng2:clone()
		elseif index == 3 then
			childrenCount = self.room_card_outimage3:getChildrenCount()
			image_name = "room_card_peng3_image"
			card = self.room_card_peng3:clone()
		end

		local pos = zzroom.room_out_card_operator.get_out_card_pos(index,childrenCount + 1)
		card:setAnchorPoint(cc.p(0.5,0.5))
		card:setPosition(pos)

		local image =  zzroom.deal_card_path.get_card_path(card_value)
		local room_out_card0_image = card:getChildByName(image_name)
		room_out_card0_image:loadTexture(image)

		if index == 0 then
			self.room_card_outimage0:addChild(card)
		elseif index == 1 then
			self.room_card_outimage1:addChild(card)
		elseif index == 2 then
			self.room_card_outimage2:addChild(card)
			card:setLocalZOrder(-childrenCount)
		elseif index == 3 then
			self.room_card_outimage3:addChild(card)
			card:setLocalZOrder(-childrenCount)
		end

		--那个小点在上下动的效果
		show_dot = show_dot or false
		if show_dot == true then
			pos.y = pos.y + 10
			self.room_card_dot:setPosition(pos)
			self.src_dot_y = pos.y
		end
end

function RoomCardLayout:reset_ting_func( pack )

	self.ting_tbl = {}
	local ting_num = pack.ting_num or 0
	if ting_num > 0 then
		local ting_tbl = pack.ting_tbl or {}
		dump(ting_tbl,"RoomCardLayout:reset_ting_func")
		for _,data_card in pairs(ting_tbl) do
			local ting_card = data_card.ting_card or 0
			local ting_card_num = data_card.ting_card_num or 0

			if ting_card ~= 0 and ting_card_num > 0 then
				local card_tbl =  data_card.card_tbl or {}
				self.ting_tbl[ting_card] = card_tbl
			end
		end
	end
	dump(self.ting_tbl,"deal_ting_function")
end

function RoomCardLayout:reset_justting_func( pack )
	local ting_num_ex = pack.ting_num_ex or 0
	if ting_num_ex > 0 then
		local ting_tbl_ex = pack.ting_tbl_ex or {}
		
		self.room_card_ting_card:setVisible(true)
		self.room_card_ting_card_baset:removeAllChildren()
		local pos = self.room_card_ting_image:getPosition()
		pos.x = pos.x + 52/2+3
		pos.y = pos.y + 5
		local card_width = 19
		self.room_card_ting_base:setContentSize(cc.size(72 + table.nums(ting_tbl_ex)*card_width,49))

		for _ ,card_value_ in pairs(ting_tbl_ex) do
			local image =  zzroom.deal_card_path.get_card_path(card_value_)
			local card = self.room_card_ting:clone()
			--card:setScale(0.35)
			local room_card_hand_image = card:getChildByName("room_card_ting_imageting")
			room_card_hand_image:loadTexture(image)
			pos.x = pos.x + card_width
			card:setPosition(pos)

			self.room_card_ting_card_baset:addChild(card)
		end

	end
end

function RoomCardLayout:deal_ting_flag( card_value )
	-- body
	--print("card_value---deal_ting_flag---------",card_value)
	--dump(self.ting_tbl,"self.ting_tbl")
	local card_ting_tbl = self.ting_tbl[card_value] or {}
	if table.nums(card_ting_tbl) > 0 then
		self.room_card_ting_card:setVisible(true)
		self.room_card_ting_card_baset:removeAllChildren()
		local pos = self.room_card_ting_image:getPosition()
		pos.x = pos.x + 52/2+3
		pos.y = pos.y + 5
		local card_width = 19
		self.room_card_ting_base:setContentSize(cc.size(72 + table.nums(card_ting_tbl)*card_width,49))

		for _ ,card_value_ in pairs(card_ting_tbl) do
			local image =  zzroom.deal_card_path.get_card_path(card_value_)
			local card = self.room_card_ting:clone()
			--card:setScale(0.35)
			local room_card_hand_image = card:getChildByName("room_card_ting_imageting")
			room_card_hand_image:loadTexture(image)
			pos.x = pos.x + card_width
			card:setPosition(pos)

			self.room_card_ting_card_baset:addChild(card)
		end
	end

end

function RoomCardLayout:after_send_ting_func( card_value )
	local card_ting_tbl = self.ting_tbl[card_value] or {}
	local find_flag = false
	if table.nums(card_ting_tbl) > 0 then
		find_flag = true
	end

	--if find_flag == false then
		self.room_card_ting_card:setVisible(find_flag)
	--end
end

function RoomCardLayout:hide_ting_base( flag )
	-- body
	self.room_card_ting_card:setVisible(flag)
	self.room_card_ting_card_baset:removeAllChildren()
end


function RoomCardLayout:add_eventlistener( card_image )
	-- body
	--print("card_value------------",card_image._card_value)
	local function onTouchBegan(touch, event)
        local target = event:getCurrentTarget()
        --dump(touch:getLocation())
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
		-- print(string.format("... x = %f, y = %f", locationInNode.x, locationInNode.y))

        local s = target:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)
       -- dump(rect)
        if cc.rectContainsPoint(rect, locationInNode) then
            --print(string.format("sprite began... x = %f, y = %f", locationInNode.x, locationInNode.y))
            target:setOpacity(180)

            local card_click_flag = target.card_click or false
            if card_click_flag == true then
            	local _card_value = target._card_value
            	MajiangroomServer:sendCard(_card_value)
            	self:after_send_ting_func(_card_value)
            	return false
            else
            	local getChildren = self.room_card_image0:getChildren()
			    for _,child in pairs(getChildren) do
			        child.card_click = false
			        child:setColor(cc.c3b(250,250,255))
			    end
            	
            	target.card_click = true
            	target:setColor(cc.c3b(250,250,0))
            	local _card_value = target._card_value
            	self:hide_ting_base(false)
            	self:deal_ting_flag(_card_value)
            end
            
            return true
        end
        return false
    end

    local function onTouchMoved(touch, event)
        local target = event:getCurrentTarget()
        local posX = target:getPositionX()
        local posY = target:getPositionY()
        local delta = touch:getDelta()
        --dump(delta)
        target:setPosition(cc.p(posX + delta.x, posY + delta.y))
--         return true
    end

    local function onTouchEnded(touch, event)
        local target = event:getCurrentTarget()
        --print("sprite onTouchesEnded..")
        target:setOpacity(255)
 		local posY = target:getPositionY()
 		--print("posY------------------",posY)
 		local src_posY = target.src_posY
 		local src_posX = target.src_posX

        if math.abs(posY - src_posY ) > 100 then
			--print("------------出牌-------------")
			local _card_value = target._card_value
			MajiangroomServer:sendCard(_card_value)
			self:after_send_ting_func(_card_value)
        else
        	local p = cc.p(src_posX,src_posY)
			local action_move = cc.MoveTo:create(0.1,p)
			target:runAction(action_move)

        end

        return true
    end

    local listener1 = cc.EventListenerTouchOneByOne:create()
    listener1:setSwallowTouches(true)
    listener1:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener1:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    listener1:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )

    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener1:clone(), card_image)

	local posY = card_image:getPositionY()
	local posX = card_image:getPositionX()
    card_image.src_posY = posY
    card_image.src_posX = posX
end


--添加这个消息是在继续下一盘的时候，可以实现清空上一盘打出的牌
function RoomCardLayout:remove_alloutimage()
	-- body
	self.room_card_outimage0:removeAllChildren()
	self.room_card_outimage1:removeAllChildren()
	self.room_card_outimage2:removeAllChildren()
	self.room_card_outimage3:removeAllChildren()

	self.room_card_image0:removeAllChildren()
	self.room_card_image1:removeAllChildren()
	self.room_card_image2:removeAllChildren()
	self.room_card_image3:removeAllChildren()

	self.room_card_image:removeAllChildren()
	self.src_dot_y = -30 
	self:hide_ting_base(false)
end

