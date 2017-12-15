local RoomlevelMap  =  import("zhajinhua.pintu.RoomlevelMap")
local UiCommon      = class("UiCommon")


--显示漂亮的数字
function UiCommon:numFnt(num)
	local num_str  = ""
	      num      =  tonumber(num)
	if num < 10000 then
		local thousand = math.modf(num/1000)
		local hundrand = num%1000
		if thousand ~= 0 then
			num_str = thousand..","..hundrand
		else
			num_str = hundrand
		end
	else
		local ten_thousand = math.modf(num/10000)
		local thousand     = math.modf(num%10000/1000)
		if thousand >= 5 then
			thousand = thousand +1
		end
		if thousand ~= 0 then
			num_str = ten_thousand..","..thousand.."w"
		else
			num_str = ten_thousand.."w"
		end
	end

	num_str = tostring(num_str)

	local num_node = display:newNode()
	local point    =  0

	for i=1,#num_str do
		local t_byte = string.sub(num_str,i,i)
		local image  = ""
		local width  = 0
		if t_byte == "," then
			image = "dou.png"
			width = 20
		elseif  t_byte == 'w' then
			image = "wan.png"
			width = 40
		else
			image = t_byte..".png"
			width = 30
		end

		local map_b = RoomlevelMap[image]

		if map_b == nil then
			return false
		end

		local num_tmp = display.newSprite(map_b["file"])
		num_tmp:setTextureRect(cc.rect(map_b['x'],map_b['y'],map_b['width'],map_b['height']))
		if i >=1 then
			num_tmp:pos(point+width,0)
			point = point+width
		else
			num_tmp:pos(0,0)
		end
		num_tmp:addTo(num_node)
		i=i+1
	end


	return num_node

end

--返回数字
function UiCommon:numFormat(num)
	return tostring(num)
	-- local num_str  = ""
	--       num      =  tonumber(num)
	-- if num < 10000 then
	-- 	local thousand = math.modf(num/1000)
	-- 	local hundrand = num%1000
	-- 	if thousand ~= 0 then
	-- 		num_str = thousand..","..hundrand
	-- 	else
	-- 		num_str = hundrand
	-- 	end
	-- else
	-- 	local ten_thousand = math.modf(num/10000)
	-- 	local thousand     = math.modf(num%10000/1000)
	-- 	if thousand >= 5 then
	-- 		thousand = thousand +1
	-- 	end
	-- 	if thousand ~= 0 then
	-- 		num_str = ten_thousand..","..thousand.."w"
	-- 	else
	-- 		num_str = ten_thousand.."w"
	-- 	end
	-- end

	-- num_str = tostring(num_str)

	-- return num_str

end

--显示房间信息的数字
function UiCommon:numRoom(num)
	-- body
	num_str        = tostring(num)
	local num_node = display:newNode()
	local point    = 0
	for i=1,#num_str do
		local t_byte = string.sub(num_str,i,i)
		local file   = "num"..t_byte..".png"
		local num_tmp    = display.newSprite("zhajinhua/res/room/roombase/"..file)
		num_tmp:addTo(num_node)
		local width  = 20
		if i >=1 then
			num_tmp:pos(point+width,0)
			point = point+width
		else
			num_tmp:pos(0,0)
		end
	end

	return num_node

end

--获得数字筹码
function UiCommon:getChipsNum(gold)
	local num_str  = gold
	if gold >=1000 and gold <2000 then
		num_str = math.modf(num_str/1000)
		num_str = tostring(num_str).."k"
	elseif gold>=2000 and gold<10000 then
		num_str = math.modf(num_str/1000)
		num_str = tostring(num_str).."k"
	elseif gold >=10000 then
		num_str = math.modf(num_str/10000)
		num_str = tostring(num_str).."w"

	end
	num_str     = tostring(num_str)
	local point = -30
	local width = 12

	if #num_str == 4 then
		point = -30
		width = 12
	end

	if #num_str == 2 then
		point = -23
		width = 15
	end

	if #num_str == 3 then
		point = -25
		width = 12
	end

	local num_node = display:newNode()
	num_node:setContentSize(cc.size(0,0))
	local x = 0

	for i=1,#num_str do
		local t_byte   = string.sub(num_str,i,i)
		local file     = t_byte..".png"
		if t_byte == 'k' then
			file = "q.png"
		end
		if t_byte == 'w' then
			file = "w.png"
		end
		local num      = display.newSprite("zhajinhua/res/room/chip/"..file)
		num:addTo(num_node)

		num:pos(x + num:getContentSize().width/2, 0)
		x = x + num:getContentSize().width
		local height = 0
		if num:getContentSize().height > num_node:getContentSize().height then
			height = num:getContentSize().height
		else
			height = num_node:getContentSize().height
		end
		num_node:setContentSize(cc.size(x, height))
	end
	return num_node
end
--获得筹码
function UiCommon:getChips(gold)
	local img_name = "" 
	local num_str  = gold

	local node  =display.newNode()
	if gold <500 then
		img_name ="chipBtn1.png"
	elseif gold >=500 and gold<1000 then
		img_name ="chipBtn2.png"
	elseif gold >=1000 and gold <2000 then
		img_name ="chipBtn2.png"
	elseif gold>=2000 and gold<10000 then
		num_str = math.modf(num_str/1000)
		num_str = tostring(num_str).."k"
		img_name ="chipBtn4.png"
	elseif gold >=10000 then
		num_str = math.modf(num_str/10000)
		num_str = tostring(num_str).."w"
		img_name ="chipBtn5.png"
	end

	local chip =  display.newSprite("zhajinhua/res/room/chip/"..img_name)
	chip:addTo(node)
	chip:setScale(0.5)

	num_str     = tostring(num_str)
	local point = -30
	local width = 12

	if #num_str == 4 then
		point = -30
		width = 12
	end

	if #num_str == 2 then
		point = -23
		width = 15
	end

	if #num_str == 3 then
		point = -25
		width = 12
	end
	
	local num_node = display:newNode()

	for i=1,#num_str do
		local t_byte   = string.sub(num_str,i,i)
		local file     = t_byte..".png"
		if t_byte == 'k' then
			file = "q.png"
		end
		if t_byte == 'w' then
			file = "w.png"
		end
		local num      = display.newSprite("zhajinhua/res/room/chip/"..file)
		num:addTo(num_node)
		
		if i >=1 then
			num:pos(point+width,2)
			point = point+width
		else
			num:pos(point,2)
		end
		num:setScale(0.7)
	end

	
	num_node:addTo(node)
	node:setScale(0.7)

	return node
end
--
-- 金币按钮
function UiCommon:getChipBtn(gold,index)
	local img_name = "" 
	local num_str  = gold

	if gold <500 then
		img_name ="chipBtn1.png"
	elseif gold >=500 and gold<1000 then
		img_name ="chipBtn2.png"
	elseif gold >=1000 and gold <2000 then
		img_name ="chipBtn2.png"
	elseif gold>=2000 and gold<10000 then
		num_str = math.modf(num_str/1000)
		num_str = tostring(num_str).."k"
		img_name ="chipBtn4.png"
	elseif gold >=10000 then
		num_str = math.modf(num_str/10000)
		num_str = tostring(num_str).."w"
		img_name ="chipBtn5.png"
	end
	if index then
		if index < 1 then
			img_name ="chipBtn1.png"
		elseif index > 5 then
			img_name ="chipBtn5.png"
		else
			img_name ="chipBtn"..tostring(index)..".png"
		end
	end

	local scale_chip = 0.3
	local chip =  ccui.Button:create("zhajinhua/res/NewImg/chip/"..img_name, nil, nil)
	chip:setScale(scale_chip)
	local center_x = chip:getContentSize().width/2*scale_chip

	num_str     = tostring(num_str)
	local width = 15
	local point = center_x - (width*(#num_str))/2

	-- if #num_str == 4 then
	-- 	point = -30
	-- 	width = 12
	-- end

	-- if #num_str == 2 then
	-- 	point = -23
	-- 	width = 15
	-- end

	-- if #num_str == 3 then
	-- 	point = -25
	-- 	width = 12
	-- end
	
	local num_node = display:newNode()

	for i=1,#num_str do
		local t_byte   = string.sub(num_str,i,i)
		local file     = t_byte..".png"
		if t_byte == 'k' then
			file = "q.png"
		end
		if t_byte == 'w' then
			file = "w.png"
		end
		local num      = display.newSprite("zhajinhua/res/room/chip/"..file)
		num:addTo(num_node)
		
		if i >=1 then
			num:pos(point+width,2)
			point = point+width
		else
			num:pos(point,2)
		end
		-- num:setScale(0.7)
	end

	
	num_node:addTo(chip)
	num_node:setPosition(chip:getContentSize().width/2, chip:getContentSize().height/2)

	return chip
end
-- 金币按钮
function UiCommon:getChipBtnNew(gold,index)
	local img_name = ""
	local num_str  = gold
	if gold>=1000 and gold<10000 then
		num_str = math.modf(num_str/1000)
		num_str = tostring(num_str).."k"

	elseif gold >=10000 then
		num_str = math.modf(num_str/10000)
		num_str = tostring(num_str).."w"
	else
		num_str = math.modf(gold)
	end
	if index then
		if index == 1 then
			img_name ="refuel_g.png"
		elseif index == 2 then
			img_name ="refuel_b.png"
		elseif index==3 then
			img_name ="refuel_p.png"
		else
			img_name ="refuel_h.png"
		end

	end


	local scale_chip = 0.3
	local offset_x = 1
	local offset_y = 8
	local chip =  cc.Sprite:create("zhajinhua/res/NewImg/"..img_name)
	chip:setScale(scale_chip)
	local center_x = chip:getContentSize().width/2

	num_str     = tostring(num_str)
	local width = 18
	local point = center_x - (width*(#num_str))/2
	print("getChipBtnNew center_x  point gold", tostring(center_x), tostring(point), tostring(gold))


	for i=1,#num_str do
		local t_byte   = string.sub(num_str,i,i)
		local file     = t_byte..".png"
		if t_byte == 'k' then
			file = "q.png"
		end
		if t_byte == 'w' then
			file = "w.png"
		end
		local num = display.newSprite("zhajinhua/res/room/chip/"..file)
		num:addTo(chip)

		num:pos(point + width*(i-1) + width/2,chip:getContentSize().height/2 + offset_y)
	end

	return chip
end

--显示输金币
function UiCommon:gameLostGold(num)
	num_str        = tostring(num)
	local num_node = display:newNode()
	local fu       = display.newSprite("zhajinhua/res/room/gameOver/num/minus.png")
	fu:addTo(num_node)
	local point    = 20
	for i=1,#num_str do
		local t_byte = string.sub(num_str,i,i)
		local file   = "gray_"..t_byte..".png"
		local num_tmp    = display.newSprite("zhajinhua/res/room/gameOver/num/"..file)
		num_tmp:addTo(num_node)
		local width  = 40
		if i >=1 then
			num_tmp:pos(point+width,0)
			point = point+width
		else
			num_tmp:pos(0,0)
		end
	end

	return num_node
end

--显示赢金币
function UiCommon:gameWinGold(num)
	num_str        = tostring(num)
	local num_node = display:newNode()
	local fu       = display.newSprite("zhajinhua/res/room/gameOver/num/plus.png")
	fu:addTo(num_node)
	local point    = 20
	for i=1,#num_str do
		local t_byte = string.sub(num_str,i,i)
		local file   = "light_"..t_byte..".png"
		local num_tmp    = display.newSprite("zhajinhua/res/room/gameOver/num/"..file)
		num_tmp:addTo(num_node)
		local width  = 40
		if i >=1 then
			num_tmp:pos(point+width,0)
			point = point+width
		else
			num_tmp:pos(0,0)
		end
	end

	return num_node
end





return UiCommon