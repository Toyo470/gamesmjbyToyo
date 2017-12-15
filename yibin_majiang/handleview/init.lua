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


FEI_OPCODE = 65536--#飞操作（癞子碰）                                         [target_account_id,102]
TI_OPCODE = 131072--#提操作（提取碰中的癞子）                                 [target_account_id,102]

--显示其他玩家的操作界面结果。这个是用来显示其他玩家操作结果的喔。
--比如其他玩家杠了，我们就拿这个来显示
function show_handle_result( index,result_tbl,show_time )
	local layout_object = layout.reback_layout_object("room_handleresult")
	if layout_object ~= nil then
		layout_object:reset_result_item( index,result_tbl,show_time)
	end
end

function get_operator_image( handle_v ,handle_dict )
	-- body
  local ti = ccui.ImageView:create()
  local ex_len = 0

  if handle_v == handleview.ZIMO_OPCODE  
  	or handle_v == handleview.HU_OPCODE   then --胡牌

  	ti:loadTexture(GAMEBASENAME_RES.."majong_hu_bt_p.png")

  elseif handleview.FANG_GANG_OPCODE == handle_v 
  	or handleview.AN_GANG_OPCODE == handle_v 
    or handleview.MING_GANG_OPCODE == handle_v --#自己碰牌后，自己又摸到相同的牌
  	or handleview.GANG_OPCODE == handle_v then--杠

  	ti:loadTexture(GAMEBASENAME_RES.."majong_gang_bt_p.png")

  elseif handleview.CHI_OPCODE == handle_v then --吃牌

  	ti:loadTexture(GAMEBASENAME_RES.."majong_chi_bt_p.png")

  elseif handleview.PENG_OPCODE == handle_v then --碰牌

  	ti:loadTexture(GAMEBASENAME_RES.."majong_peng_bt_p.png")

  elseif handleview.FEI_OPCODE == handle_v then

  	ti:loadTexture(GAMEBASENAME_RES.."majong_fei_bt_p.png")
  	local card_value = handle_dict[3] or 0
    local laizi_dic =  handle_dict[2] or {}
  	if card_value ~= 0 then
  		local card = handleview.get_operator_card(card_value)
  		ti:addChild(card)
  		card:setPositionX(ti:getContentSize().width + card:getContentSize().width/2-5)
		  card:setPositionY(ti:getContentSize().height/2)
		  ex_len = card:getContentSize().width/2-5
      ti.laizi = laizi_dic[1]
  	end

  elseif handleview.TI_OPCODE == handle_v then

  	ti:loadTexture(GAMEBASENAME_RES.."majong_ti_bt_p.png")
  	
  	local card_value = handle_dict[2] or 0
    card_value = card_value[1]
  	if card_value ~= 0 then
  		local card = handleview.get_operator_card(card_value)
  		ti:addChild(card)
      ti.ti_card = card_value
  		card:setPositionX(ti:getContentSize().width + card:getContentSize().width/2-5)
		  card:setPositionY(ti:getContentSize().height/2)
		  ex_len = card:getContentSize().width/2-5
  	end

  end

  return ti,ex_len
end

function get_operator_card( card_value )
	-- body
	local Image = ccui.ImageView:create()
	Image:loadTexture(GAMEBASENAME.."/res/majiangCard/my_big_card01.png")

	local cardImage = ccui.ImageView:create()
	local tex = cardhandle.deal_card_path.get_card_path(card_value)
	cardImage:loadTexture(tex)

	Image:addChild(cardImage)
	cardImage:setPositionX(Image:getContentSize().width/2)
	cardImage:setPositionY(Image:getContentSize().height/2)

	return Image
end