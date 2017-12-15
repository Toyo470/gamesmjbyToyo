require("framework.init")

--加载麻将游戏服务
local MajiangroomServer  = require("xl_majiang.scenes.MajiangroomServer")

--加载麻将资源路径类
local CARD_PATH_MANAGER = require("xl_majiang.card_path")
CARD_PATH_MANAGER:init()

--判断当前牌的花色是否与已经添加到换牌数组中的牌的花色不相同
local function isNotSameCardVariety(cardVariety)

	--判断当前记录换牌数组是否不为空，当不为空的时候，才有已选择花色
	if #bm.Room.cardHuan > 0 then
		if bm.Room.selectCardVariety ~= cardVariety then
			--不相同
			return true
		end
	end
	--相同
	return false

end

--判断当前牌是否已经添加到换牌数组中
local function getisIndexOf(id)
	if #bm.Room.cardHuan > 0 then
		for k,v in pairs(bm.Room.cardHuan) do
			if v.id == id then
				return true
			end
		end
	end
	return false
end

--定义麻将牌类
local Majiangcard = class("Majiangcard",function ()
	return display.newNode()
end)

--定义麻将牌筛选器
Majiangcard._FILTERS = {

	-- custom
	{"CUSTOM"},

	-- {"CUSTOM", json.encode({frag = "Shaders/example_Flower.fsh",
	-- 					center = {display.cx, display.cy},
	-- 					resolution = {480, 320}})},

	{{"CUSTOM", "CUSTOM"},
		{json.encode({frag = "Shaders/example_Blur.fsh",
			shaderName = "blurShader",
			resolution = {480,320},
			blurRadius = 10,
			sampleNum = 5}),
		json.encode({frag = "Shaders/example_sepia.fsh",
			shaderName = "sepiaShader",})}},

	-- colors
	{"GRAY",{0.1, 250, 10, 0.1}},
	{"RGB",{0.5, 0.5, 0.3}},
	{"HUE", {90}},
	{"BRIGHTNESS", {0.3}},
	{"SATURATION", {0}},
	{"CONTRAST", {2}},
	{"EXPOSURE", {2}},
	{"GAMMA", {2}},
	{"HAZE", {0.1, 0.2}},
	--{"SEPIA", {}},
	-- blurs
	{"GAUSSIAN_VBLUR", {7}},
	{"GAUSSIAN_HBLUR", {7}},
	{"ZOOM_BLUR", {4, 0.7, 0.7}},
	{"MOTION_BLUR", {5, 135}},
	-- others
	{"SHARPEN", {1, 1}},
	{{"GRAY", "GAUSSIAN_VBLUR", "GAUSSIAN_HBLUR"}, {nil, {10}, {10}}},
	{{"BRIGHTNESS", "CONTRAST"}, {{0.1}, {4}}},
	{{"HUE", "SATURATION", "BRIGHTNESS"}, {{240}, {1.5}, {-0.4}}},
}

--初始化牌
function Majiangcard:ctor()

	--为每一张牌赋值一个id，id从0自增
	bm.index_card_tt = bm.index_card_tt or 0
	bm.index_card_tt = bm.index_card_tt + 1
	self.id = bm.index_card_tt

	--0表示未设置状态 1 自己的手牌 2 为自己出的牌 3 出牌时很大的那个
	self.status_      = 0 

	self.darkOverlay_ = false 

	self.handle_      = nil

	--print(self.id,"-------------------------------self,id")
	--4 左边的手牌 5 左边出的牌 6 右边的手牌 7 右边出的牌  8对门的手牌 9对门碰的牌
	--左边玩家手牌的背景
	-- self.left_hand_back_ = display.newSprite("majiang/room/MahjongImage.png"):addTo(self)
	-- self.left_hand_back_:setTextureRect(cc.rect(457,848,24,60))

	--左边玩家手牌的背景
	-- self.left_hand_back_ = display.newSprite("majiang/room/MahjongImage.png"):addTo(self)
	-- self.left_hand_back_:setTextureRect(cc.rect(689,178,36,16))

	self.isZhua_ = false

end

--设置当前牌是刚抓的牌
function Majiangcard:setIsZhua()
	dump("当前牌为新抓的牌", "-----我抓牌-----")
	self.isZhua_ = true
end

--设置牌
function Majiangcard:setCard(value)

	self.value_ = value

	--设置牌值
    self.cardValue_   = self:getValue(value)

    --设置花色
 self.cardVariety_ = self:getVariety(value)

end

-- 获得牌值
function Majiangcard:getValue(card)
    local value = bit.band(card, 0x0F)
    return value
end

--获得花色
function Majiangcard:getVariety(card)
	return bit.brshift(card, 4)
end

--设置左边玩家手牌精灵
function Majiangcard:setLeftHand()
	if self.pannel_ then
		self.pannel_:removeSelf()
	end
	self.status_ = 4
	local path_lefthandcard = CARD_PATH_MANAGER:get_card_path("path_lefthandcard")
	self.pannel_ = display.newSprite(path_lefthandcard):addTo(self)

end

--设置右边边玩家手牌精灵
function Majiangcard:setRightHand()
	if self.pannel_ then
		self.pannel_:removeSelf()
	end
	self.status_ = 6
	local path_righthandcard = CARD_PATH_MANAGER:get_card_path("path_righthandcard")
	self.pannel_ = display.newSprite(path_righthandcard):addTo(self)

end

--设置左边玩家出牌
function Majiangcard:setLeftOutCard()
	if self.pannel_ then
		self.pannel_:removeSelf()
	end
	local str = CARD_PATH_MANAGER:get_left_out_card_path(self.value_)
	self.pannel_ = display.newSprite(str):addTo(self):pos(0,0)

end

--设置右边边玩家出牌
function Majiangcard:setRightOutCard()
	if self.pannel_ then
		self.pannel_:removeSelf()
	end
	local str = CARD_PATH_MANAGER:get_right_out_card_path(self.value_)
	self.pannel_ = display.newSprite(str):addTo(self):pos(0,0)
end


--设置右边玩家盖住的牌
function Majiangcard:setRightBlack()
	if self.pannel_ then
		self.pannel_:removeSelf()
	end
	local path_leftright_gai = CARD_PATH_MANAGER:get_card_path("path_leftright_gai")
	self.pannel_ = display.newSprite(path_leftright_gai):addTo(self)

end

--设置左边玩家盖住的牌
function Majiangcard:setLeftBlack()
	if self.pannel_ then
		self.pannel_:removeSelf()
	end
	local path_leftright_gai = CARD_PATH_MANAGER:get_card_path("path_leftright_gai")
	self.pannel_ = display.newSprite(path_leftright_gai):addTo(self)

end

--设置对边玩家盖住的牌
function Majiangcard:setTopBlack()
	if self.pannel_ then
		self.pannel_:removeSelf()
	end
	local path_myback = CARD_PATH_MANAGER:get_card_path("path_myback")
	self.pannel_ = display.newSprite(path_myback):addTo(self)
end

--设置我的盖住的牌
function Majiangcard:setMyBlack()
	if self.pannel_ then
		self.pannel_:removeSelf()
	end
	local path_myback = CARD_PATH_MANAGER:get_card_path("path_myback")
	self.pannel_ = display.newSprite(path_myback):addTo(self)
end

--设置自己出的牌
function Majiangcard:setMyOutCard()
	if self.pannel_ then
		self.pannel_:removeSelf()
	end
	local str = CARD_PATH_MANAGER:get_top_topout_card_path(self.value_)
	self.pannel_ = display.newSprite(str):addTo(self):pos(0,0)

end

--设置打出来显示的牌
function Majiangcard:setBigOutCard()
	if self.pannel_ then
		self.pannel_:removeSelf()
	end
	local str = CARD_PATH_MANAGER:get_hand_card_path(self.value_)
	self.pannel_ = display.newSprite(str):addTo(self):pos(0,0)

end

--设置自己的手牌
function Majiangcard:setMyHandCard()
	if self.pannel_ then
		self.pannel_:removeSelf()
	end

	self.darkOverlay_ = false

	local str = CARD_PATH_MANAGER:get_hand_card_path(self.value_)
	self.pannel_ = display.newSprite(str):addTo(self):pos(0,0)

	
	if bm.Room.change_card_over == true then
		print("-----出牌触摸事件-----")
		self:handleMajiangListener()
	else
		print("-----换牌触摸事件-----")
		self:handleHunCard()
	end
	
end

--设置对面的手牌
function Majiangcard:setTopHandCard()
	if self.pannel_ then
		self.pannel_:removeSelf()
	end
	local path_tophandcard = CARD_PATH_MANAGER:get_card_path("path_tophandcard")
	self.pannel_ = display.newSprite(path_tophandcard):addTo(self):pos(0,0)

end

--暗化我的手牌
function Majiangcard:dark()	
	local __curFilter = Majiangcard._FILTERS[4]
	local __filters, __params = unpack(__curFilter)
	if __params and #__params == 0 then
		__params = nil
	end
	if self.pannel_ then
		self.pannel_:removeSelf()
	end
	
	self.darkOverlay_ = true

	local str = CARD_PATH_MANAGER:get_hand_card_path(self.value_)
	self.pannel_ = display.newFilteredSprite(str, __filters, __params):addTo(self):pos(0,0)

end

--麻将监听事件
function  Majiangcard:handleMajiangListener()
	self:setTouchEnabled(true)
	self:addNodeEventListener(cc.NODE_TOUCH_EVENT,function ( event )
			-- if bm.Room.tuoguan_ing == 1 then
			-- 	return true 
			-- end
			-- print("handleMajiangListener=====================value_=========",self.value_)
			-- local scenes = SCENENOW['scene']
			-- if SCENENOW['name'] ~= "majiang.scenes.MajiangroomScenes" then
			-- 	return true
			-- end
			--print("bm.Room.tuoguan_ing------------",bm.Room.tuoguan_ing,"---bm.Room.my_out_card_time------------",bm.Room.my_out_card_time)
			if bm.Room.tuoguan_ing ~= nil and bm.Room.tuoguan_ing == 1 then
				dump("1 托管,触摸牌无效", "-----血流牌触摸事件-----")
				return true
			end

			if  bm.Room.my_out_card_time ~= 1 then
				dump("2 不是自己的出牌时间,触摸牌无效", "-----血流牌触摸事件-----")
				return true
			end

		    if self.darkOverlay_ == true then
		    	dump("3 暗化,触摸牌无效", "-----血流牌触摸事件-----")
		    	return false
		    end

		    if self.isZhua_ == false then
		    	dump("不是抓牌", "-----牌-----")
		    	if bm.isMyHu == 1 then
			    	dump("4 已经胡牌,手牌触摸牌无效", "-----血流牌触摸事件-----")
			    	return false
			    end
			else
				dump("是抓牌", "-----牌-----")
				dump("4 已经胡牌,抓牌可触摸", "-----血流牌触摸事件-----")
		    end
		    
		    --按下牌
			if event.name == "began" then
				print("------------------4------------------")
				self.moved_ = false
				local scenes = SCENENOW['scene']
				if SCENENOW['name'] == "xl_majiang.scenes.MajiangroomScenes" then
					local node = scenes:getChildByName("myhandles")
					if node then
						MajiangroomServer:requestHandle(0,bm.guo_card )
						node:removeSelf()
					end
				end
				return true
			end

			--放出牌
			if event.name == "ended" then
				print("------------------5------------------")
				if self.moved_ ==  false then
					local x,y = self:getPosition()
					y = y or 0
					if y > 90.27 then
						self:setPositionY(y-30)
					else
						self:setPositionY(y+30)
					end
				end
				
				require("hall.GameCommon"):playEffectSound(audio_path,false)
				MajiangroomServer:sendCard(self.value_)
				bm.Room.my_out_card_time  = 0

				self.isZhua = 0

				return true
			end

			--拖动牌
			if event.name == "moved" then
				self.moved_ = true
				self:setPositionX(event.x)
				self:setPositionY(event.y)
				return true
			end

	end)

end

-- --换牌监听事件
-- function Majiangcard:handleHunCard()

-- 	self:setTouchEnabled(true)
-- 	self:addNodeEventListener(cc.NODE_TOUCH_EVENT,function (event)

-- 		print("handleHunCard=====================value_=========",self.value_)
-- 		bm.Room.cardHuan = bm.Room.cardHuan or {}

-- 		--换牌开始
-- 		if not bm.huanCardsStart then
-- 			return;
-- 		end

-- 		--选择了三张牌
-- 		if #bm.Room.cardHuan >=3 then
-- 			return true
-- 		end

-- 		--判断当前是否在麻将游戏界面里
-- 		local scenes = SCENENOW['scene']
-- 		if SCENENOW['name'] ~= "majiang.scenes.MajiangroomScenes" then
-- 			return true
-- 		end

-- 		--开始换牌
-- 		if event.name == "began" then
-- 			return true
-- 		end

-- 		--结束换牌
-- 		if event.name == "ended" then

-- 			if getisIndexOf(self.id) == false then --没有选的牌

-- 				--todo
-- 				self:setPositionY(self:getPositionY()+20)
-- 				table.insert(bm.Room.cardHuan,self)

-- 				--选择的牌大于等于3只
-- 				if #bm.Room.cardHuan>=3 then
-- 					--todo
-- 					--显示确定和取消换牌按钮
-- 					local btn_huan_ok = scenes._scene:getChildByName("Button_11")
-- 					local btn_huan_Canle = scenes._scene:getChildByName("Button_11_0")
-- 					btn_huan_ok:show();
-- 					btn_huan_Canle:show();
-- 					return false;
-- 				end

-- 			else
-- 				self:setPositionY(103.27)
-- 				table.removebyvalue(bm.Room.cardHuan,self)
-- 			end
			
-- 			require("hall.GameCommon"):playEffectSound(audio_path,false)
-- 			return true

-- 		end

-- 	end)
-- end


local cishu = 1

--换牌监听事件
function Majiangcard:handleHunCard()

	self:setTouchEnabled(true)
	self:addNodeEventListener(cc.NODE_TOUCH_EVENT,function (event)

		dump(self.id, "-----换牌当前选中牌的ID-----")
		dump(self.cardValue_, "-----换牌当前选中牌的值-----")
		dump(self.cardVariety_, "-----换牌当前选中牌的花色-----")
		dump(cishu, "-----换牌当前输出次数-----")
		cishu = cishu + 1

		bm.Room.cardHuan = bm.Room.cardHuan or {}

		--换牌开始
		if not bm.huanCardsStart then
			return
		end

		--判断当前是否在麻将游戏界面里
		local scenes = SCENENOW['scene']
		if SCENENOW['name'] ~= "xl_majiang.scenes.MajiangroomScenes" then
			return
		end

		--开始换牌
		if event.name == "began" then
			return true
		end

		--结束换牌
		if event.name == "ended" then

			--判断是否不为相同的花色
			if isNotSameCardVariety(self.cardVariety_) then
				return true
			end

			--判断是否为已经添加的牌
			if getisIndexOf(self.id) then 

				--当前牌是已经添加的牌
				self:setPositionY(self:getPositionY() - 20)
				--移除已经选中的牌
				table.removebyvalue(bm.Room.cardHuan, self)

				--假如当前记录换牌数组没有记录牌，则重置记录花色
				if #bm.Room.cardHuan == 0 then

					bm.Room.selectCardVariety = 0

				end

				--选择的牌小于3只,隐藏确定和取消换牌按钮
				if #bm.Room.cardHuan < 3 then
					local btn_huan_ok = scenes._scene:getChildByName("Button_11")
					local btn_huan_Canle = scenes._scene:getChildByName("Button_11_0")
					btn_huan_ok:setVisible(false)
					btn_huan_Canle:setVisible(false)
				end

			else
				
				--把当前牌往上移20
				self:setPositionY(self:getPositionY() + 20)

				--假如当前记录换牌数组没有记录牌，则记录花色
				if #bm.Room.cardHuan == 0 then

					bm.Room.selectCardVariety = self.cardVariety_

				end

				--添加当前牌到换牌数组
				table.insert(bm.Room.cardHuan, self)

				--选择的牌大于等于3只,显示确定和取消换牌按钮
				if #bm.Room.cardHuan >= 3 then
					local btn_huan_ok = scenes._scene:getChildByName("Button_11")
					local btn_huan_Canle = scenes._scene:getChildByName("Button_11_0")
					btn_huan_ok:show();
					btn_huan_Canle:show();
					return true;
				end

			end
			
			require("hall.GameCommon"):playEffectSound(audio_path,false)
			return true

		end

	end)
	
end

--麻将触发事件设置
function Majiangcard:setMajiangEvent(handle)
	self.handle_ = handle
end


return Majiangcard