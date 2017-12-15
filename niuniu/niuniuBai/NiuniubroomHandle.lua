require("niuniu.cardkind")

local PROTOCOL         = import("niuniu.Niuniu_Protocol")
local NiuniubroomHandle = class("NiuniubroomHandle")

function NiuniubroomHandle:ctor()
	self.func_ = {
        [PROTOCOL.SVR_QUIT_ROOM_BAIREN] = {handler(self, NiuniubroomHandle.SVR_QUIT_ROOM_BAIREN)},
        [PROTOCOL.SVR_BAIREN_START] = {handler(self, NiuniubroomHandle.SVR_BAIREN_START)},
        [PROTOCOL.SVR_ZHUANG_INFO] = {handler(self, NiuniubroomHandle.SVR_ZHUANG_INFO)},
        [PROTOCOL.SVR_XIAZHU_INFO] = {handler(self, NiuniubroomHandle.SVR_XIAZHU_INFO)},
        [PROTOCOL.SVR_PER_BAIREN_END] = {handler(self, NiuniubroomHandle.SVR_PER_BAIREN_END)},
        [PROTOCOL.SVR_XIAZHU_START] = {handler(self, NiuniubroomHandle.SVR_XIAZHU_START)},
        [PROTOCOL.SVR_CARD_RESULT] = {handler(self, NiuniubroomHandle.SVR_CARD_RESULT)},
        
        
        
    }
end


--
function NiuniubroomHandle:callFunc(pack)
	 if self.func_[pack.cmd] and self.func_[pack.cmd][1] then
        self.func_[pack.cmd][1](pack)
    end
end

--结算
function NiuniubroomHandle:SVR_CARD_RESULT(pack)
	for i,v in pairs(pack.content) do 
		self:sendCard(v.seat,v.cards,1)
		self:showCardType(v.seat,v.cardkind)
	end

	if bm.Bai.time  then
		bm.SchedulerPool:clear(bm.Bai.time)
	end

	local scenes      =  SCENENOW['scene']
	local hide        =  scenes._scene:getChildByTag(391)
	local time        =  scenes._scene:getChildByTag(392)
	hide:setVisible(true)
	time:setVisible(true)
	bm.Bai.time_count =  pack.time
	time:setString("结算 "..bm.Bai.time_count.." ")
	bm.Bai.time       = bm.SchedulerPool:loopCall(function ()	
			bm.Bai.time_count = bm.Bai.time_count -1
			time:setString("结算 "..bm.Bai.time_count.." ")
			if bm.Bai.time_count < 0 then
				hide:setVisible(false)
				time:setVisible(false)
				return false
			end

			return true
	end,1)
end

--显示牌型
function NiuniubroomHandle:showCardType(seat,kind)
	local card_p      = {
		[0] = {
			['x'] = 430,
			['y'] = 550,
		},
		[1] = {
			['x'] = 190,
			['y'] = 250,
		},
		[2] = {
			['x'] = 360,
			['y'] = 250,
		},
		[3] = {
			['x'] = 550,
			['y'] = 250,
		},
		[4] = {
			['x'] = 750,
			['y'] = 250,
		},
	}

	local name_kind = CARDTYPE[kind]
	if name_kind == nil then
		return false
	end

	local scenes      =  SCENENOW['scene']
	local card_node   = scenes:getChildByName("cardnode")
	if not card_node  then
		card_node = display.newNode()
		card_node:setName("cardnode")
		card_node:addTo(scenes)
	end

	local text   = cc.ui.UILabel.new({text = name_kind, size = 40, color = cc.c3b(10, 10, 10)}):addTo(card_node)
	text:pos(card_p[seat]['x'],card_p[seat]['y'])


end

--开始下注
function NiuniubroomHandle:SVR_XIAZHU_START(pack)
	
	if bm.Bai.time  then
		bm.SchedulerPool:clear(bm.Bai.time)
	end

	local scenes      =  SCENENOW['scene']
	local hide        =  scenes._scene:getChildByTag(391)
	local time        =  scenes._scene:getChildByTag(392)
	hide:setVisible(true)
	time:setVisible(true)
	bm.Bai.time_count =  pack.time
	time:setString("开始下注 "..bm.Bai.time_count.." ")
	bm.Bai.time       = bm.SchedulerPool:loopCall(function ()
			
			bm.Bai.time_count = bm.Bai.time_count -1
			time:setString("开始下注 "..bm.Bai.time_count.." ")
			if bm.Bai.time_count < 0 then
				hide:setVisible(false)
				time:setVisible(false)
				return false
			end

			return true
	end,1)

	for i,v in pairs(pack.info) do
		NiuniubroomHandle:sendCard(v.seat,v.cards)
	end
	
end


--发牌
function NiuniubroomHandle:sendCard(seat,cards,flag)
	print("seandcard")
	local card_p      = {
		[0] = {
			['x'] = 430,
			['y'] = 550,
		},
		[1] = {
			['x'] = 190,
			['y'] = 250,
		},
		[2] = {
			['x'] = 360,
			['y'] = 250,
		},
		[3] = {
			['x'] = 550,
			['y'] = 250,
		},
		[4] = {
			['x'] = 750,
			['y'] = 250,
		},
	}
	local scenes      =  SCENENOW['scene']
	local card_node   = scenes:getChildByName("cardnode")
	if not card_node  then
		card_node = display.newNode()
		card_node:setName("cardnode")
		card_node:addTo(scenes)
	end

	local seat_card_node = card_node:getChildByName("seat"..seat)
	if seat_card_node then
		seat_card_node:removeSelf()
	end

	seat_card_node = display.newNode() 
	seat_card_node:setName("seat"..seat)
	seat_card_node:addTo(card_node)

	for i,v in pairs(cards) do
		local card            = require("foundation.PokerCard").new():addTo(seat_card_node)
		card:pos(display.cx,display.cy)
		card:showBack()
		card:setScale(0.5)
		if v ~= 0 then
			card:setCard(v)
			card:showFront()
		end
		if flag == nil then
			local move = cc.MoveTo:create(0.1,cc.p(card_p[seat]['x']+(i-1)*15,card_p[seat]['y']))
			local delay= cc.DelayTime:create((i)*0.1)
			local se   = cc.Sequence:create(delay,move)
			card:runAction(se)	
		else
			card:showFront()
			card:pos(card_p[seat]['x']+(i-1)*15,card_p[seat]['y'])	
		end

	end

end

--广播每个玩家的结算信息
function NiuniubroomHandle:SVR_PER_BAIREN_END(pack)
	local p_config = {
		['z'] = {
			['x'] = 320,
			['y'] = 550,
		},
		['m'] = {
			['x'] = 20,
			['y'] = 250,
		}
	}

	local scenes      =  SCENENOW['scene']
	local card_node   = scenes:getChildByName("cardnode")
	if not card_node  then
		card_node = display.newNode()
		card_node:setName("cardnode")
		card_node:addTo(scenes)
	end
	local zmoney = tonumber(pack.zhuangwin)
	local zmoneystr = ""
	if zmoney > 0 then
		zmoneystr = "+"..zmoney
	else
		zmoneystr = zmoney
	end
	local text   = cc.ui.UILabel.new({text = zmoneystr, size = 40, color = cc.c3b(255, 251, 240)}):addTo(card_node)
	text:pos(p_config['z']['x'],p_config['z']['y'])

	local mmoney = tonumber(pack.userwin)
	local mmoneystr = ""
	if mmoney > 0 then
		mmoneystr = "+"..mmoney
	else
		mmoneystr = mmoney
	end

	local text  = cc.ui.UILabel.new({text = mmoneystr, size = 40, color = cc.c3b(255, 251, 240)}):addTo(card_node)
	text:pos(p_config['m']['x'],p_config['m']['y'])

	bm.SchedulerPool:delayCall(function ()
		card_node:removeSelf()
		--清除下注信息
		local pack = {
			['info'] = {
				{	
					['seat'] = 1,
					['seatmoney'] = 0,
					['mymoney'] = 0,
				},
				{	
					['seat'] = 2,
					['seatmoney'] = 0,
					['mymoney'] = 0,
				},
				{	
					['seat'] = 3,
					['seatmoney'] = 0,
					['mymoney'] = 0,
				},
				{	
					['seat'] = 4,
					['seatmoney'] = 0,
					['mymoney'] = 0,
				}
			}
		}
		self:SVR_XIAZHU_INFO(pack)
	end,3)

end
--广播下注信息
function NiuniubroomHandle:SVR_XIAZHU_INFO(pack)
	local seat_config  = {
		[1] = {
			['z'] = 350,
			['m'] = 401,
		},
		[2] = {
			['z'] = 352,
			['m'] = 403,
		},
		[3] = {
			['z'] = 354,
			['m'] = 404,
		},
		[4] = {
			['z'] = 356,
			['m'] = 405,
		}
	}

	local scenes      =  SCENENOW['scene']
	for i,v in pairs(pack.info) do

		local seat = tonumber(v.seat)
		if seat ~= 0 then
			local zhuang = scenes._scene:getChildByTag(seat_config[seat]['z'])
			zhuang:setString(v.seatmoney)

			local my    = scenes._scene:getChildByTag(seat_config[seat]['m'])
			my:setString(v.mymoney)
		end
	end
end


--广播庄家信息
function NiuniubroomHandle:SVR_ZHUANG_INFO(pack)
	
	local scenes      =  SCENENOW['scene']
	local zhuang_nick =  scenes._scene:getChildByTag(334)
    local zhuang_num  =  scenes._scene:getChildByTag(346)
	zhuang_num:setString(pack.zhuanggold)
end
--推出百人场
function NiuniubroomHandle:SVR_QUIT_ROOM_BAIREN(pack)
	bm.display_scenes("niuniu.center.niuniu.scenes.NiuniuhallScenes") 
end

--广播游戏开始
function NiuniubroomHandle:SVR_BAIREN_START(pack)
	if bm.Bai.time  then
		bm.SchedulerPool:clear(bm.Bai.time)
	end

	local scenes      =  SCENENOW['scene']
	local hide        =  scenes._scene:getChildByTag(391)
	local time        =  scenes._scene:getChildByTag(392)
	hide:setVisible(true)
	time:setVisible(true)
	bm.Bai.time_count =  pack.time
	time:setString("休息一下 "..bm.Bai.time_count.." ")
	bm.Bai.time       = bm.SchedulerPool:loopCall(function ()
			
			bm.Bai.time_count = bm.Bai.time_count -1
			time:setString("休息一下 "..bm.Bai.time_count.." ")
			if bm.Bai.time_count < 0 then
				hide:setVisible(false)
				time:setVisible(false)
				return false
			end

			return true
	end,1)

end




return NiuniubroomHandle