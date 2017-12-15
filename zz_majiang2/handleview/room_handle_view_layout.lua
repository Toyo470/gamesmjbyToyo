--碰杠胡等操作
local MajiangroomServer = require("zz_majiang2.MajiangroomServer")

mrequire("handleview.room_handle_view_template")
HandleViewLayout = class("HandleViewLayout", handleview.room_handle_view_template.room_handle_view_Template)

function HandleViewLayout:_do_after_init()
	self.card_value = -1
	self.room_handle_view_gang:setVisible(false)
	self.room_handle_view_guo:setVisible(false)
	self.room_handle_view_hu:setVisible(false)
	self.room_handle_view_peng:setVisible(false)
end

function HandleViewLayout:click_room_handle_view_gang_event()
	local result = self.room_handle_view_gang.result
	print("room_handle_view_gang------result------------",result)
	self:requestHandle(result)
end

function HandleViewLayout:click_room_handle_view_guo_event()
	local result = self.room_handle_view_guo.result
	print("room_handle_view_guo------result------------",result)
	self:requestHandle(result)
end

function HandleViewLayout:click_room_handle_view_hu_event()
	local result = self.room_handle_view_hu.result
	print("room_handle_view_hu------result------------",result)
	self:requestHandle(result)

  -- if bm.SocketService then
  --     --todo
  --     bm.SocketService:disconnect();
  -- end

  -- -- cc.Director:getInstance():pause();

  -- display_scene("app.scenes.MainScene")

end

function HandleViewLayout:click_room_handle_view_peng_event()
	local result = self.room_handle_view_peng.result
	print("room_handle_view_peng------result------------",result)
	self:requestHandle(result)
end


function HandleViewLayout:requestHandle(result)
	-- body
	print("requestHandle------result------------",result,"self.card_value",self.card_value)
	if self.card_value ~= -1 then
		MajiangroomServer:requestHandle(result,self.card_value)
	end

	self:hide_layout()
end

function HandleViewLayout:reset_state(result,ming_or_an,card)
	-- body
  print("result,ming_or_an,card",result,ming_or_an,card)
  dump(result)
  self.card_value =card
  local has = 0
  local hu_flag = 0
  local peng_flag = 0
  local gang_flag =0

  if result['h'] then
    has   = 1
	self.room_handle_view_hu:setVisible(true)
	self.room_handle_view_hu.result = result['h']
	self.card_value = card
	hu_flag = 1
  end

  local ifpg = 0
  if result['pg'] then
    ifpg  = 1
    has   = 1
    peng_flag = 1
    gang_flag = 1
    
    self.room_handle_view_gang:setVisible(true)
    self.room_handle_view_gang.result = result['pg']

	self.room_handle_view_peng:setVisible(true)
	self.room_handle_view_peng.result = 0x008
 	self.card_value = card

  end

  if result['p'] and ifpg == 0 then
    has   = 1
    peng_flag = 1
	self.room_handle_view_peng:setVisible(true)
	self.room_handle_view_peng.result = result['p']
	self.card_value = card
  end

  if result['g'] and ifpg == 0 then
    has   = 1
    gang_flag = 1

	local  player_card = zzroom.manager:get_card(0)
	local prog_card = player_card["porg"] or {}
	local hand_card = player_card["hand"] or {}

    local find_flag =  false
    local gang = {}
    for i,v in pairs(prog_card) do
      if gang[v] == nil then 
        gang[v]=  1
      else
        gang[v]= gang[v] + 1
      end

      if v == card then
        find_flag = true-----摸到的牌是要杆的牌
      end
    end

    local hand_gang = {}
    for i,v in pairs(hand_card) do
      if hand_gang[v] == nil then 
        hand_gang[v]=  1
      else
        hand_gang[v]= hand_gang[v] + 1
      end
    end

    local hand_gang_one = false 
    if find_flag == false then -----手牌就是要杆的牌
      for i,v in pairs(hand_card) do
        if gang[v] ~= nil and gang[v] == 3  then
          card = v;
          hand_gang_one = true
          break
        end
      end
    end

    if hand_gang_one  == false and find_flag == false then
      for i,v in pairs(hand_card) do-----手牌就有四张要杆的牌
        if hand_gang[v] ~= nil and hand_gang[v] == 4  then
          card = v;
          break
        end
      end
    end

 	self.room_handle_view_gang:setVisible(true)
 	self.room_handle_view_gang.result = result['g']
 	self.card_value = card
  end

  if has  == 1 then
  	self.room_handle_view_guo.result = 0
  	self.room_handle_view_guo:setVisible(true)

  	--调整下位置,下面顺序不能乱
  	local width = self.room_handle_view_guo:getContentSize().width + 30
  	local posX = self.room_handle_view_guo:getPositionX()

  	if peng_flag == 1 then
  		posX = posX - width
  		self.room_handle_view_peng:setPositionX(posX)
  	end

  	if gang_flag == 1 then
  		posX = posX - width
  		self.room_handle_view_gang:setPositionX(posX)
  	end

  	if hu_flag == 1 then
  		posX = posX - width
  		self.room_handle_view_hu:setPositionX(posX)
  	end

  end



end