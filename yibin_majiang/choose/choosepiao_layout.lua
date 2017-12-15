mrequire("choose.choosepiao_template")
local Sender = require(GAMEBASENAME..".Sender")
ChoosepiaoLayout = class("ChoosepiaoLayout", choose.choosepiao_template.choosepiao_Template)

function ChoosepiaoLayout:_do_after_init()
	
end

function ChoosepiaoLayout:click_choosepiao_bupiao_event()
	self:send_msg(1)
end

function ChoosepiaoLayout:click_choosepiao_paio_event()
	self:send_msg(0)
end


function ChoosepiaoLayout:send_msg( num )
		local is_dingpiao = {}
	is_dingpiao["account_is_dingpiao"] = num
	Sender:send(mprotocol.H2G_ACCOUNT_CHOOSE_DINGPIAO,is_dingpiao)
	self:hide_layout()
end
