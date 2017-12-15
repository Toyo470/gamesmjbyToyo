--碰杠胡等操作
local Sender = require(GAMEBASENAME..".".."Sender")
mrequire("cardhandle.deal_card_path")

mrequire("gangchoose.gangchoose_template")
GangChooseLayout = class("GangChooseLayout", gangchoose.gangchoose_template.gangchoose_Template)

function GangChooseLayout:_do_after_init()
	self.gangchoose_txt2:setString("请选择你可以进行的操作：")
	self.gangchoose_close:setVisible(false)
	--gangchoose_txt1
end

function GangChooseLayout:set_txt( paleyer_name,card_value )
	-- body
	local card_type = math.modf(card_value / 100)
	local value = math.modf(card_value % 100)

	local tb = {[1] = "万",[2] = "筒",[3] = "条"}
	local type_str = tb[card_type] or ""
	local txt = ""..tostring(paleyer_name).."开杠"..tostring(value)..type_str.."依次为："
	self.gangchoose_txt1:setString(txt)
end

function GangChooseLayout:set_card( card_value1,card_value2 )
	-- body
	if card_value1 ~= nil then
		local image =  cardhandle.deal_card_path.get_card_path(card_value1)
		self.gangchoose_card1:loadTexture(image)
		self.gangchoose_card3:loadTexture(image)
		self.gangchoose_card3._card_value = card_value1

		self.gangchoose_card1:setVisible(true)
		self.gangchoose_card3:setVisible(true)
	else
		self.gangchoose_card1:setVisible(false)
		self.gangchoose_card3:setVisible(false)
	end

	if card_value2 ~= nil then
		local image =  cardhandle.deal_card_path.get_card_path(card_value2)
		self.gangchoose_card2:loadTexture(image)
		self.gangchoose_card4:loadTexture(image)

		self.gangchoose_card4._card_value = card_value2

		self.gangchoose_card2:setVisible(true)
		self.gangchoose_card4:setVisible(true)
	else
		self.gangchoose_card2:setVisible(false)
		self.gangchoose_card4:setVisible(false)
	end

end

-- function GangChooseLayout:click_gangchoose_close_event()
-- 	self:hide_layout()
-- end

 -- {205: {32: [0, 205], 8: [0, [205]]}, 101: {}}
 function GangChooseLayout:deal_data( data_tbl )
 	-- body
 	local card_tbl = {}

 	local oper1 = {
				 	[128] = self.gangchoose_1c,
				 	[64] = self.gangchoose_1p,
				 	[32] = self.gangchoose_1g,

				 	[8] = self.gangchoose_1b,
				 	[16] = self.gangchoose_1b,

				 	[1] = self.gangchoose_1h,
				 	[2] = self.gangchoose_1h
 	}

	local oper2 = {
					[128] = self.gangchoose_2c,
					[64] =self.gangchoose_2p,
					[32] =self.gangchoose_2g,

					[8] = self.gangchoose_2b,
					[16] = self.gangchoose_2b,

					[1] =self.gangchoose_2h,
					[2] =self.gangchoose_2h
	}

	local txwture = {
					[128] = "majong_chi_bt_p.png",
					[64] ="majong_peng_bt_p.png",
					[32] ="majong_gang_bt_p.png",

					[8] = "majong_buzhang_bt_p.png",
					[16] = "majong_buzhang_bt_p.png",

					[1] ="majong_hu_bt_p.png",
					[2] ="majong_hu_bt_p.png"
	}


	dump(data_tbl,"data_tbl--deal_data---------")
 	for _index,tbl_opater in pairs(data_tbl) do
 		for card_value,tbl_ in pairs(tbl_opater) do
 			card_value = tonumber(card_value)
 			table.insert(card_tbl,card_value)

 			dump(tbl_,"tbl_")
 			for _op,_ in pairs(tbl_) do 
	 			_op = tonumber(_op)
	 			if _index == 1 then
					if oper1[_op] ~= nil then
						oper1[_op]:setTexture(GAMEBASENAME .. "/res/image/"..tostring(txwture[_op]))
						local parent = oper1[_op]:getParent()
						oper1[_op]:setName("hehe")
						oper1[_op].op = _op
						oper1[_op]._card_value = card_value
						oper1[_op].index_id = 0

						parent:onClick(handler(self, self.click_image_event))
					end

	 			elseif _index == 2 then
	 				if oper2[_op] ~= nil then
						oper2[_op]:setTexture(GAMEBASENAME .. "/res/image/"..tostring(txwture[_op]))
						local parent = oper2[_op]:getParent()
						oper2[_op]:setName("hehe")
						oper2[_op].op = _op
						oper2[_op]._card_value = card_value
						oper2[_op].index_id = 1

						parent:onClick(handler(self, self.click_image_event))
					end
	 			end
	 		end

 		end
 	end

 	self:set_card(card_tbl[1],card_tbl[2])
 end

function GangChooseLayout:click_image_event(target)
  local child_target = target:getChildByName("hehe")
  local op = child_target.op
  local card_value = child_target._card_value
  local index_id = child_target.index_id
  print("------op--------",op,"---------card_value--------",card_value)

  local tbl = {}
  tbl["option_index"] = {}
  table.insert(tbl["option_index"] ,2048)
  table.insert(tbl["option_index"] ,op*1000+(index_id))

  Sender:send(mprotocol.H2G_GAME_ACCOUNT_CHOOSE_OPTION,tbl)
  --
  self:hide_layout()
end

function GangChooseLayout:click_gangchoose_card3_event(target)
	local card_value = target._card_value
	print("---------card_value-1---------",card_value)
	  local tbl = {}
  tbl["option_index"] = {}
  table.insert(tbl["option_index"] ,2048)
  table.insert(tbl["option_index"] ,0*1000+card_value)

  Sender:send(mprotocol.H2G_GAME_ACCOUNT_CHOOSE_OPTION,tbl)
  --
  self:hide_layout()

end

function GangChooseLayout:click_gangchoose_card4_event(target)
	local card_value = target._card_value
	print("---------card_value-2---------",card_value)

	  local tbl = {}
  tbl["option_index"] = {}
  table.insert(tbl["option_index"] ,2048)
  table.insert(tbl["option_index"] ,0*1000+card_value)

  Sender:send(mprotocol.H2G_GAME_ACCOUNT_CHOOSE_OPTION,tbl)
  --
  self:hide_layout()

end
