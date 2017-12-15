--

function get_num( rec_num )
	-- body
	if rec_num <= 5 then
		return 1,rec_num
	elseif rec_num <= 12 then
		return 2,rec_num-5
	elseif rec_num <= 21 then
		return 3,rec_num-12
	elseif rec_num <= 32 then
		return 4,rec_num-21
	elseif rec_num <= 45 then
		return 5,rec_num-32
	end
end

-- local width = card_image::getContentSize().width

function get_out_card_pos(index,rec_num)

	local row,num = get_num(rec_num)

	if index == 0 then
		local width = 29
		local x = 417.56 - (row - 1)*width + (num-1)*width
		local y = 210.04 - (row - 1)*30.82
		return cc.p(x,y)
		
	elseif index == 1 then
		local width = 37
		local x = 337.22  - (row - 1)*width
		local y = 338.26  + (row - 1)*22.4 - (num-1)*22.4
		return cc.p(x,y)

	elseif index == 2 then
		local width = 29
		local x = 524.49 + (row - 1)*width - (num-1)*width
		local y = 367.02 + (row - 1)*30.82
		return cc.p(x,y)

	elseif index == 3 then
		local width = 37.00
		local x = 595.81 + (row - 1)*width
		local y = 250.73 - (row - 1)*24.47 + (num - 1)*24.47
		return cc.p(x,y)
	end
end