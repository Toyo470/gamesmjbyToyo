mrequire("zzroom.deal_card_path")
mrequire("zzroom.room_card_test_template")

RoomCardTestLayout = class("RoomCardTestLayout", zzroom.room_card_test_template.room_card_test_Template)

function RoomCardTestLayout:_do_after_init()
	self:addChild(self.room_card_test_hand0:clone())

end

