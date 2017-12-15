mrequire("choose.chooseque_template")
local Sender = require(GAMEBASENAME..".Sender")
ChoosequeLayout = class("ChoosequeLayout", choose.chooseque_template.chooseque_Template)

function ChoosequeLayout:_do_after_init()
	
	self.icon_dict = {
		self.chooseque_wang,
		self.chooseque_tong,
		self.chooseque_suo
	}
end

function ChoosequeLayout:reset_card_type(index )
	if index == nil then
		return
	end
	
	self.card_type = index
	self.flag = false
	self.time_deley = 0
	self:set_update_flag(true)

end

function ChoosequeLayout:update(dt)
	self.time_deley = self.time_deley + dt
	if self.icon_dict[self.card_type] ~= nil and self.time_deley > 0.5 then
		if self.flag == false then
			self.icon_dict[self.card_type]:setColor(cc.c3b(255,165,0))
			self.flag = true
		else
			self.icon_dict[self.card_type]:setColor(cc.c3b(255,255,255))
			self.flag = false
		end
		self.time_deley = 0
	end
	
end

function ChoosequeLayout:click_chooseque_tong_event()
	self:send_msg(2)
	self:hide_layout()
end

function ChoosequeLayout:click_chooseque_wang_event()
	self:send_msg(1)
	self:hide_layout()
end

function ChoosequeLayout:click_chooseque_suo_event()
	self:send_msg(3)
	self:hide_layout()
end
function ChoosequeLayout:send_msg( num )
		local dingque_type = {}
	dingque_type["account_dingque_type"] = num
	Sender:send(mprotocol.H2G_ACCOUNT_CHOOSE_DINGQUE,dingque_type)
	self:hide_layout()
end