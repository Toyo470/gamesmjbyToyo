
mrequire("handleview.room_handleresult_template")
RoomHandleResultLayout = class("RoomHandleResultLayout", handleview.room_handleresult_template.room_handleresult_Template)

function RoomHandleResultLayout:_do_after_init()
	self.pos = {cc.p(273.23,307.74),cc.p(464.86,406.29),cc.p(656.02,307.74)}
	self.pos[0] = cc.p(467.57,194.21)

	self:set_update_flag(true)
	self.hide_time = nil --1.5秒后，这个类自动关闭
end

function RoomHandleResultLayout:update(dt)
	if self.hide_time  == nil then
		return
	end

	self.hide_time = self.hide_time - dt
	if self.hide_time < 0 then
		self:set_update_flag(false)
		self:hide_layout()
	end
end


function RoomHandleResultLayout:reset_result_item( index,result_tbl,show_time )
	-- body
	show_time = show_time or 1.5
	self.hide_time = show_time
	index = tonumber(index)


	local pos  = self.pos[index]
	if pos == nil then
		self:hide_layout()
		return
	end

	if result_tbl['g'] or result_tbl['pg'] then
		self.room_handleresult_g:setPosition(pos)

		self.room_handleresult_g:setScale(0.8)
		local action1= cc.ScaleTo:create(0.5,1.2)

 		local showTurnAc = cc.CallFunc:create(function()
				local fo = cc.FadeOut:create(0.5)
				self.room_handleresult_gang_base:runAction(fo)
 			end)
 		local action2 = cc.ScaleTo:create(0.5,1.0)
 		local sq = cc.Sequence:create(action1,action2,showTurnAc)
 		self.room_handleresult_g:runAction(sq)

	elseif result_tbl['p'] then

		self.room_handleresult_p:setPosition(pos)
		self.room_handleresult_p:setScale(0.8)
		local action1= cc.ScaleTo:create(0.5,1.2)

 		local showTurnAc = cc.CallFunc:create(function()
				local fo = cc.FadeOut:create(0.5)
				self.room_handleresult_peng_base:runAction(fo)
 			end)
 		local action2 = cc.ScaleTo:create(0.5,1.0)
 		local sq = cc.Sequence:create(action1,action2,showTurnAc)
 		self.room_handleresult_p:runAction(sq)
	end

end

--扩展，可以显示多个
function RoomHandleResultLayout:reset_result_hu( index,hu_type )
	
	if index > 3 or index < 0 then
		return
	end
	
	local pos  = self.pos[tonumber(index)]
	local _hu = self.room_handleresult_h1
	if index == 1 then
		local _hu = self.room_handleresult_h1
	elseif index == 2 then
		_hu = self.room_handleresult_h2
	elseif index == 3 then
		_hu = self.room_handleresult_h3
	else
		_hu = self.room_handleresult_h0
	end
	

	self.hide_time = 3
	_hu:setPosition(pos)
	_hu:setScale(0.8)
	local action1= cc.ScaleTo:create(0.5,1.2)

	local showTurnAc = cc.CallFunc:create(function()
		local fo = cc.FadeOut:create(0.5)
		local room_handleresult_hu_base = _hu:getChildByName("room_handleresult_hu_base"..tostring(index))
		print("room_handleresult_hu_base---------------------",room_handleresult_hu_base)
		room_handleresult_hu_base:runAction(fo)
		end)
	local action2 = cc.ScaleTo:create(0.5,1.0)
	local sq = cc.Sequence:create(action1,action2,showTurnAc)
 	_hu:runAction(sq)

	
end

function RoomHandleResultLayout:reset_result_showtiem( show_time )
	show_time = show_time or 1.5
	self.hide_time = show_time
end
