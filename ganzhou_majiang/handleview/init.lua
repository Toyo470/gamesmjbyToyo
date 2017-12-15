manager = nil


ZIMO_OPCODE = 1--#自摸
HU_OPCODE = 2--#胡牌
FANG_GANG_OPCODE = 4--#自己抓到3张相同的牌，其他玩家打出1张相同牌
AN_GANG_OPCODE = 8--#自己抓到4张相同的牌
MING_GANG_OPCODE = 16--#自己碰牌后，自己又摸到相同的牌
GANG_OPCODE = 32--#开杠拿（2张牌）
PENG_OPCODE = 64--#碰牌
CHI_OPCODE = 128--#吃牌
HAIDI_OPCODE = 256--#海底
TOUCH_OPCODE = 512--#摸牌
OUT_CARD_OPCODE = 1024--#出牌
 
GANG_CHOOSE_OPCODE = 2048 --杠可能的操作 {205: {32: [0, 205], 8: [0, [205]]}, 101: {}}

--显示其他玩家的操作界面结果。这个是用来显示其他玩家操作结果的喔。
--比如其他玩家杠了，我们就拿这个来显示
function show_handle_result( index,result_tbl,show_time )
	local layout_object = layout.reback_layout_object("room_handleresult")
	if layout_object ~= nil then
		layout_object:reset_result_item( index,result_tbl,show_time)
	end
end
