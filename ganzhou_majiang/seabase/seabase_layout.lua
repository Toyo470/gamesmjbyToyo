
local Sender = require(GAMEBASENAME..".".."Sender")
mrequire("cardhandle.deal_card_path")

mrequire("seabase.seabase_template")
SeaBaseLayout = class("SeaBaseLayout", seabase.seabase_template.seabase_Template)

function SeaBaseLayout:_do_after_init()
	local action_ry = cc.RotateBy:create(1, 45)
	local action = cc.RepeatForever:create(action_ry)
	self.seabase_effect:runAction(action)

  self.seabase_card_base:setVisible(false)
  self.seabase_card:setVisible(false)

end

function SeaBaseLayout:click_seabase_mo_event()
	self:require_server(1)

  self.seabase_mo:setVisible(false)
  self.seabase_bumo:setVisible(false)
end

function SeaBaseLayout:click_seabase_bumo_event()
	self:require_server(0)
  self:hide_layout()
end

function SeaBaseLayout:require_server( item_index )
	-- body
  local tbl = {}
  tbl["option_index"] = {}
  table.insert(tbl["option_index"] ,handleview.HAIDI_OPCODE)

  if item_index then
    table.insert(tbl["option_index"] ,item_index)
  end
  print("requestHandle------------------")
  dump(tbl)
  Sender:send(mprotocol.H2G_GAME_ACCOUNT_CHOOSE_OPTION,tbl)
  
end

function SeaBaseLayout:set_sea_card( card_value )
  -- body

  self.seabase_mo:setVisible(false)
  self.seabase_bumo:setVisible(false)

  self.seabase_card_base:setVisible(true)
  self.seabase_card:setVisible(true)

  local image =  cardhandle.deal_card_path.get_card_path(card_value)
  self.seabase_card:loadTexture(image)
end



