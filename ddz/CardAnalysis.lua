local Card     = require("ddz.Card")
require("config")


local	CARD_TYPE_ERROR = 0		-- 牌型错误
local	CARD_TYPE_ONE = 1			    -- 单张
local	CARD_TYPE_TWO = 2		    -- 对子
local	CARD_TYPE_THREE = 3		-- 单三张
local	CARD_TYPE_ONELINE = 4	    -- 顺子
local	CARD_TYPE_TWOLINE = 5	    -- 连对
local	CARD_TYPE_THREELINE = 6	-- 飞机不带
local	CARD_TYPE_THREEWITHONE = 7   -- 三带一	
local	CARD_TYPE_THREEWITHTWO = 8 	-- 三带二
local	CARD_TYPE_FOURWITHTWO = 9 	-- 4个带二（牌不够时可以少带，带1-2张）
local	CARD_TYPE_FOURWITHFOUR = 10     -- 4个带二对
local	CARD_TYPE_BOMB = 11			-- 4个		炸弹
local  CARD_TYPE_ROCKET = 12			-- 火箭
local  CARD_TYPE_PLANEWITHONE = 13  --飞机带单
local  CARD_TYPE_PLANEWITHWING = 14 --飞机带双
local CardAnalysis = class("CardAnalysis")


--获得做小牌
function CardAnalysis:getLitleCard(tmp)
	if USER_INFO["cards"] == nil then
		return false
	end
	if self:fenLei() == false then
		return false
	end
	local min_value
	local max = #USER_INFO["cards"]
	for i = max,1,-1 do
		if not tmp[USER_INFO["cards"][i][1]] then
			min_value = USER_INFO["cards"][i][1]
			break
		end
	end

	if 	USER_INFO["one"][min_value] then
		return USER_INFO["one"][min_value]
	end

	if 	USER_INFO["double"][min_value] then
		return USER_INFO["double"][min_value]
	end

	if 	USER_INFO["three"][min_value] then
		return USER_INFO["three"][min_value]
	end

	if 	USER_INFO["four"][min_value] then
		return USER_INFO["four"][min_value]
	end
end

--获得比较大的牌
function CardAnalysis:getSuitCard(type,talbet,main_card_arr)
	local main_card = self:isType(type,talbet)
	if not main_card then
		return false
	end

	if self:fenLei() == false then
		return false
	end
	local m_main
	if type == CARD_TYPE_ONE then
		local cards,m_main = self:single(main_card,main_card_arr)
		if cards ~= false then
			return cards,m_main 
		else
			return false
		end
	end

	if type == CARD_TYPE_TWO then
		local cards,m_main = self:double(main_card,main_card_arr)
		if cards ~= false then
			return cards,m_main
		else
			return false
		end
	end

	if type == CARD_TYPE_THREE then
		local cards,m_main = self:three(main_card,main_card_arr)
		if cards ~= false then
			return cards,m_main
		else
			return false
		end
	end

	if type == CARD_TYPE_THREEWITHONE then
		local cards,m_main = self:shunThreeWithOne(main_card,#talbet,main_card_arr)
		if cards ~= false then
			return cards,m_main
		else
			return false
		end
	end

	if type == CARD_TYPE_THREEWITHTWO then
		local cards,m_main = self:shunThreeWithTwo(main_card,#talbet,main_card_arr)
		if   cards ~= false then
			return cards,m_main
		end
		return false
	end

	if type == CARD_TYPE_ONELINE then
		local cards,main_card = self:shun(main_card,#talbet,main_card_arr)
		if  cards ~= false then
			return cards,main_card
		end
		return false
	end

	if type == CARD_TYPE_TWOLINE then
		local cards,main_card  = self:shunDouble(main_card,#talbet,main_card_arr)
		if  cards ~= false then
			return cards,main_card
		end
		return false
	end

	if type == CARD_TYPE_THREELINE then
		local  cards,main_card = self:shunThree(main_card,#talbet,main_card_arr)
		if  cards ~= false then
			return  cards,main_card
		end
		return false
	end

	if type == CARD_TYPE_PLANEWITHONE then

		local cards,main_card = self:shunThreeWithOne(main_card,#talbet,main_card_arr)
		if  cards ~= false  then
			return cards,main_card
		end
		return false
	end

	if type == CARD_TYPE_PLANEWITHWING then
		local cards,main_card = self:shunThreeWithTwo(main_card,#talbet,main_card_arr)
		if  cards ~= false then
			return cards,main_card
		end
		return false
	end

	if type == CARD_TYPE_BOMB then
		local cards,main_card = self:boom(main_card,main_card_arr)
		if  cards ~= false then
			return cards,main_card
		end
		return false
	end

	if type == CARD_TYPE_FOURWITHTWO  or type == CARD_TYPE_FOURWITHFOUR then
		local cards,main_card = self:fourWith(main_card_arr)
		if  cards ~= false then
			return cards,main_card
		end
		return false
	end

	return false
end

--获得单张牌
function   CardAnalysis:single(max_value,main_card)
	local big_boom  = 0
	if USER_INFO["one_rank"] then
		if  USER_INFO["one"][1]  and   USER_INFO["one"][2]  then
			big_boom = 1
		end
		
		for i = #USER_INFO["one_rank"],1,-1 do
			local value      = USER_INFO["one_rank"][i]
			local real_value = USER_INFO["one_rank"][i][1]
			

			local real_value_t  = real_value
			if real_value == 1 then
				real_value = 16
			end

			if real_value == 2 then
				real_value = 17
			end

			if big_boom == 1 then
				if real_value>max_value and not main_card[real_value] and real_value ~= 16 and real_value ~= 17 then
					return {{value[1],value[2]}},value[1]
				end
			else
				if real_value>max_value and not main_card[real_value_t]  then
					return {{value[1],value[2]}},value[1]
				end
			end
		end
	end

	if USER_INFO["double_rank"] then
		for i = #USER_INFO["double_rank"],1,-1  do
			local value      = USER_INFO["double_rank"][i]
			local real_value = USER_INFO["double_rank"][i][1]


			if real_value>max_value and not main_card[real_value] then
				return {{value[1],value[2]}},value[1]
			end
		end
	end

	if USER_INFO["three_rank"] then
		for i = #USER_INFO["three_rank"],1,-1  do
			local value      = USER_INFO["three_rank"][i]
			local real_value = USER_INFO["three_rank"][i][1]

			if real_value>max_value and not main_card[real_value] then
				return {{value[1],value[2]}},value[1]
			end
		end
	end

	if USER_INFO["four_rank"] then
		for i = #USER_INFO["four_rank"],4,-4  do
			local value      = USER_INFO["four_rank"][i]
			local real_value = USER_INFO["four_rank"][i][1]
			if not main_card[real_value] then
				return {{USER_INFO["four_rank"][i][1],USER_INFO["four_rank"][i][2]},{USER_INFO["four_rank"][i-1][1],USER_INFO["four_rank"][i-1][2]},{USER_INFO["four_rank"][i-2][1],USER_INFO["four_rank"][i-2][2]},{USER_INFO["four_rank"][i-3][1],USER_INFO["four_rank"][i-3][2]}},real_value
			end
		end
	end

	if big_boom == 1 then
		if not main_card[1] then
			return {{USER_INFO["one"][1][1][1],USER_INFO["one"][1][1][2]},{USER_INFO["one"][2][1][1],USER_INFO["one"][2][1][2]}},1
		end
	end

	print("suit single card false")
	return false
end

--获得对子
function   CardAnalysis:double(max_value,main_card)
	local big_boom  = 0
	if  USER_INFO["one"][1]  and   USER_INFO["one"][2]  then
		big_boom = 1
	end

	if USER_INFO["double_rank"] then
		for i = #USER_INFO["double_rank"],2,-2  do
			local value      = USER_INFO["double_rank"][i]
			local real_value = USER_INFO["double_rank"][i][1]


			if real_value>max_value and not main_card[real_value]  then
				return {{USER_INFO["double_rank"][i][1],USER_INFO["double_rank"][i][2]},{USER_INFO["double_rank"][i-1][1],USER_INFO["double_rank"][i-1][2]}},USER_INFO["double_rank"][i][1]
			end
		end
	end

	if USER_INFO["three_rank"] then
		for i = #USER_INFO["three_rank"],2,-3  do
			local value      = USER_INFO["three_rank"][i]
			local real_value = USER_INFO["three_rank"][i][1]


			if real_value>max_value and not main_card[real_value]  then
				return {{USER_INFO["three_rank"][i][1],USER_INFO["three_rank"][i][2]},{USER_INFO["three_rank"][i-1][1],USER_INFO["three_rank"][i-1][2]}},USER_INFO["three_rank"][i][1]
			end
		end
	end

	if USER_INFO["four_rank"] then
		for i = #USER_INFO["four_rank"],4,-4  do
			local value      = USER_INFO["four_rank"][i]
			local real_value = USER_INFO["four_rank"][i][1]
			if not main_card[real_value] then
				return {{USER_INFO["four_rank"][i][1],USER_INFO["four_rank"][i][2]},{USER_INFO["four_rank"][i-1][1],USER_INFO["four_rank"][i-1][2]},{USER_INFO["four_rank"][i-2][1],USER_INFO["four_rank"][i-2][2]},{USER_INFO["four_rank"][i-3][1],USER_INFO["four_rank"][i-3][2]}},real_value
			end
		end
	end

	if big_boom == 1 then
		if not main_card[1] then
			return {{USER_INFO["one"][1][1][1],USER_INFO["one"][1][1][2]},{USER_INFO["one"][2][1][1],USER_INFO["one"][2][1][2]}},1
		end
	end

	return false
end

--获得三张
function   CardAnalysis:three(max_value,main_card)
	local big_boom  = 0
	if  USER_INFO["one"][1]  and   USER_INFO["one"][2]  then
		big_boom = 1
	end


	if USER_INFO["three_rank"] then
		for i = #USER_INFO["three_rank"],3,-3  do
			local value      = USER_INFO["three_rank"][i]
			local real_value = USER_INFO["three_rank"][i][1]


			if real_value>max_value and not main_card[real_value]  then
				return {{USER_INFO["three_rank"][i][1],USER_INFO["three_rank"][i][2]},{USER_INFO["three_rank"][i-1][1],USER_INFO["three_rank"][i-1][2]},{USER_INFO["three_rank"][i-2][1],USER_INFO["three_rank"][i-2][2]}},USER_INFO["three_rank"][i][1]
			end
		end
	end

	if USER_INFO["four_rank"] then
		for i = #USER_INFO["four_rank"],4,-4  do
			local value      = USER_INFO["four_rank"][i]
			local real_value = USER_INFO["four_rank"][i][1]
			if not main_card[real_value] then
				return {{USER_INFO["four_rank"][i][1],USER_INFO["four_rank"][i][2]},{USER_INFO["four_rank"][i-1][1],USER_INFO["four_rank"][i-1][2]},{USER_INFO["four_rank"][i-2][1],USER_INFO["four_rank"][i-2][2]},{USER_INFO["four_rank"][i-3][1],USER_INFO["four_rank"][i-3][2]}},real_value
			end
		end
	end

	if big_boom == 1 then
		if not main_card[1] then
			return {{USER_INFO["one"][1][1][1],USER_INFO["one"][1][1][2]},{USER_INFO["one"][2][1][1],USER_INFO["one"][2][1][2]}},1
		end
	end


	return false
end

--获得顺子
function   CardAnalysis:shun(max_value,len,main_card)
	local all = {}
	local big_boom  = 0
	if  USER_INFO["one"][1]  and   USER_INFO["one"][2]  then
		big_boom = 1
	end

	if USER_INFO["one"] then
		for key,value in pairs(USER_INFO["one"]) do
			if value[1][1] >=3 and   value[1][1] <=14 then
				table.insert(all,{value[1][1],value[1][2]})
			end
		end
	end

	if USER_INFO["double"] then
		for key,value in pairs(USER_INFO["double"]) do
			if value[1][1] >=3 and value[1][1] <=14 then
				table.insert(all,{value[1][1],value[1][2]})
			end
		end
	end

	if USER_INFO["three"] then
		for key,value in pairs(USER_INFO["three"]) do
			if value[1][1] >=3 and value[1][1] <=14 then
				table.insert(all,{value[1][1],value[1][2]})
			end
		end
	end
	if USER_INFO["four"] then
		for key,value in pairs(USER_INFO["four"]) do
			if value[1][1] >=3 and value[1][1] <=14 then
				table.insert(all,{value[1][1],value[1][2]})
			end
		end
	end

	local mount  = len
	self:sort(all)
	local start = false
	local count = 0
	local cards = {}
	local tmp_v = nil 
	local minValue = max_value - len + 1

	print("getSuitCard main_card size:"..tostring(#main_card))
	print_lua_table(main_card)
	-- if #main_card > 0 then
		for i = 3, 14 do
			if main_card[i] and main_card[i] > 0 then
				local min = i - len + 1
				print("min:"..tostring(min))
				if minValue < min then
					minValue = min
				end
			end
		end
	-- end
	print("getSuitCard shun:"..minValue.."  len:"..mount)
	print("all")
	print_lua_table(all)
	for i = #all,1,-1 do 
		if start == false then
			if all[i][1] > minValue and not main_card[all[i][1] + mount - 1] then
				start = true
				table.insert(cards,{all[i][1],all[i][2]})
				tmp_v = all[i][1]
				count = 1
			end
		else
			if  all[i][1] == tmp_v + 1 then
				tmp_v     = all[i][1]
				count     = count + 1
				table.insert(cards,{all[i][1],all[i][2]})
			else
				start = true
				count = 0
				cards = {}

				tmp_v     = all[i][1]
				count     = count + 1
				table.insert(cards,{all[i][1],all[i][2]})
			end
		end

		print("-------------------- round cards -------------------->"..tostring(i))
		print("count:"..count)
		print_lua_table(cards)

		if count == mount then
			print("len:"..len)
			print("alllen:"..#cards)
			print("main_Card:"..cards[mount][1])
			return cards,cards[mount][1]
		end
	end

	if USER_INFO["four_rank"] then
		for i = #USER_INFO["four_rank"],4,-4  do
			local value      = USER_INFO["four_rank"][i]
			local real_value = USER_INFO["four_rank"][i][1]
			if not main_card[real_value] then
				return {{USER_INFO["four_rank"][i][1],USER_INFO["four_rank"][i][2]},{USER_INFO["four_rank"][i-1][1],USER_INFO["four_rank"][i-1][2]},{USER_INFO["four_rank"][i-2][1],USER_INFO["four_rank"][i-2][2]},{USER_INFO["four_rank"][i-3][1],USER_INFO["four_rank"][i-3][2]}},real_value
			end
		end
	end

	if big_boom == 1 then
		if not main_card[1] then
			return {{USER_INFO["one"][1][1][1],USER_INFO["one"][1][1][2]},{USER_INFO["one"][2][1][1],USER_INFO["one"][2][1][2]}},1
		end
	end

	return false
end

--获得双顺
function   CardAnalysis:shunDouble(max_value,len,main_card)
	local all = {}
	local big_boom  = 0
	if  USER_INFO["one"][1]  and   USER_INFO["one"][2]  then
		big_boom = 1
	end

	print("CardAnalysis:shunDouble")
	print_lua_table(USER_INFO["double"])

	if USER_INFO["double"] then
		for key,value in pairs(USER_INFO["double"]) do
			if value[1][1] >=3 and   value[1][1] <=14 then
				table.insert(all,{value[1][1],value[1][2]})
				table.insert(all,{value[2][1],value[2][2]})
			end
		end
	end

	if USER_INFO["three"] then
		for key,value in pairs(USER_INFO["three"]) do
			if value[1][1] >=3 and   value[1][1] <=14 then
				table.insert(all,{value[1][1],value[1][2]})
				table.insert(all,{value[2][1],value[2][2]})
			end
		end
	end

	if USER_INFO["four"] then
		for key,value in pairs(USER_INFO["four"]) do
			if value[1][1] >=3 and   value[1][1] <=14 then
				table.insert(all,{value[1][1],value[1][2]})
				table.insert(all,{value[2][1],value[2][2]})
			end
		end
	end

	print_lua_table(all)

	local mount  = len/2
	self:sort(all)
	local start = false
	local count = 0
	local cards = {}
	local tmp_v = nil 
	for i = #all,2,-2 do 
		if start == false then
			if all[i][1] >max_value-mount+1 and not  main_card[all[i][1] + mount - 1]   then
				start = true
				table.insert(cards,{all[i][1],all[i][2]})
				table.insert(cards,{all[i-1][1],all[i-1][2]})
				tmp_v = all[i][1]
				count = 1
			end
		else
			if  all[i][1] == tmp_v + 1 then
				tmp_v     = all[i][1]
				count     = count + 1
				table.insert(cards,{all[i][1],all[i][2]})
				table.insert(cards,{all[i-1][1],all[i-1][2]})
			else
				start = true
				count = 0
				cards = {}

				tmp_v     = all[i][1]
				count     = count + 1
				table.insert(cards,{all[i][1],all[i][2]})
				table.insert(cards,{all[i-1][1],all[i-1][2]})
			end
		end

		if count == mount then
			return cards,cards[#cards][1]
		end
	end

	if USER_INFO["four_rank"] then
		for i = #USER_INFO["four_rank"],4,-4  do
			local value      = USER_INFO["four_rank"][i]
			local real_value = USER_INFO["four_rank"][i][1]
			if not main_card[real_value] then
				return {{USER_INFO["four_rank"][i][1],USER_INFO["four_rank"][i][2]},{USER_INFO["four_rank"][i-1][1],USER_INFO["four_rank"][i-1][2]},{USER_INFO["four_rank"][i-2][1],USER_INFO["four_rank"][i-2][2]},{USER_INFO["four_rank"][i-3][1],USER_INFO["four_rank"][i-3][2]}},real_value
			end
		end
	end

	if big_boom == 1 then
		if not main_card[1] then
			return {{USER_INFO["one"][1][1][1],USER_INFO["one"][1][1][2]},{USER_INFO["one"][2][1][1],USER_INFO["one"][2][1][2]}},1
		end
	end

	return false
end

--获得飞机不带
function CardAnalysis:shunThree(max_value,len,main_card )
	local all = {}
	local big_boom  = 0
	if  USER_INFO["one"][1]  and   USER_INFO["one"][2]  then
		big_boom = 1
	end

	if USER_INFO["three"] then
		for key,value in pairs(USER_INFO["three"]) do
			if value[1][1] >=3 and   value[1][1] <=14 then
				table.insert(all,{value[1][1],value[1][2]})
				table.insert(all,{value[2][1],value[2][2]})
				table.insert(all,{value[3][1],value[3][2]})
			end
		end
	end

	local mount  = len/3
	self:sort(all)
	local start = false
	local count = 0
	local cards = {}
	local tmp_v = nil 
	for i =#all, 3,-3 do 
		if start == false then
			if all[i][1] > max_value-mount+1 and not  main_card[all[i][1] + mount - 1]   then
				start = true
				table.insert(cards,{all[i][1],all[i][2]})
				table.insert(cards,{all[i-1][1],all[i-1][2]})
				table.insert(cards,{all[i-2][1],all[i-2][2]})
				tmp_v = all[i][1]
				count = 1
			end
		else
			if  all[i][1] == tmp_v + 1 then
				tmp_v     = all[i][1]
				count     = count + 1
				table.insert(cards,{all[i][1],all[i][2]})
				table.insert(cards,{all[i-1][1],all[i-1][2]})
				table.insert(cards,{all[i-2][1],all[i-2][2]})
			else
				start = true
				count = 0
				cards = {}

				tmp_v     = all[i][1]
				count     = count + 1
				table.insert(cards,{all[i][1],all[i][2]})
				table.insert(cards,{all[i-1][1],all[i-1][2]})
				table.insert(cards,{all[i-2][1],all[i-2][2]})
			end
		end

		if count == mount then
			return cards,cards[#cards][1]
		end
	end

	if USER_INFO["four_rank"] then
		for i = #USER_INFO["four_rank"],4,-4  do
			local value      = USER_INFO["four_rank"][i]
			local real_value = USER_INFO["four_rank"][i][1]
			if not main_card[real_value] then
				return {{USER_INFO["four_rank"][i][1],USER_INFO["four_rank"][i][2]},{USER_INFO["four_rank"][i-1][1],USER_INFO["four_rank"][i-1][2]},{USER_INFO["four_rank"][i-2][1],USER_INFO["four_rank"][i-2][2]},{USER_INFO["four_rank"][i-3][1],USER_INFO["four_rank"][i-3][2]}},real_value
			end
		end
	end

	if big_boom == 1 then
		if not main_card[1] then
			return {{USER_INFO["one"][1][1][1],USER_INFO["one"][1][1][2]},{USER_INFO["one"][2][1][1],USER_INFO["one"][2][1][2]}},1
		end
	end

	return false
end

--获得飞机带一
function CardAnalysis:shunThreeWithOne(max_value,len,main_card )
	local all = {}
	local big_boom  = 0
	if  USER_INFO["one"][1]  and   USER_INFO["one"][2]  then
		big_boom = 1
	end

	if USER_INFO["three"] then
		for key,value in pairs(USER_INFO["three"]) do
			if value[1][1] >=3 and   value[1][1] <=14 and len > 4 then
				table.insert(all,{value[1][1],value[1][2]})
				table.insert(all,{value[2][1],value[2][2]})
				table.insert(all,{value[3][1],value[3][2]})
			elseif value[1][1] >=3 and   value[1][1] <=15 and len == 4 then
				table.insert(all,{value[1][1],value[1][2]})
				table.insert(all,{value[2][1],value[2][2]})
				table.insert(all,{value[3][1],value[3][2]})
			end
		end
	end

	local mount  = len/4
	self:sort(all)
	local start = false
	local count = 0
	local cards = {}
	local tmp_v = nil 
	local del_array = {}
	local main
	local flag = 0

	for i = #all,3,-3 do 
		if start == false then
			if all[i][1] > max_value-mount+1 and not  main_card[all[i][1] + mount - 1]   then
				start = true
				table.insert(cards,{all[i][1],all[i][2]})
				table.insert(cards,{all[i-1][1],all[i-1][2]})
				table.insert(cards,{all[i-2][1],all[i-2][2]})
				del_array[all[i][1]]  = 1
				tmp_v = all[i][1]
				count = 1
			end
		else
			if  all[i][1] == tmp_v + 1 then
				tmp_v     = all[i][1]
				count     = count + 1
				table.insert(cards,{all[i][1],all[i][2]})
				table.insert(cards,{all[i-1][1],all[i-1][2]})
				table.insert(cards,{all[i-2][1],all[i-2][2]})
				del_array[all[i][1]]  = 1
			else
				start = false
				count = 0
				cards = {}
				del_array = {}

				tmp_v     = all[i][1]
				count     = count + 1
				table.insert(cards,{all[i][1],all[i][2]})
				table.insert(cards,{all[i-1][1],all[i-1][2]})
				table.insert(cards,{all[i-2][1],all[i-2][2]})
				del_array[all[i][1]]  = 1
			end
		end

		if count == mount then
			flag =  1 
			main =  cards[#cards][1]
			break
		end
	end

	local one_mout = 0
	if flag== 1 then
		for i=#USER_INFO["one_rank"],1,-1 do 

			if(del_array[USER_INFO["one_rank"][i][1]] ~= 1 ) then
	
				table.insert(cards,{USER_INFO["one_rank"][i][1],USER_INFO["one_rank"][i][2]})
				one_mout = one_mout + 1
				if (one_mout == mount ) then
					return cards,main
				end
			end
		end

		for i=#USER_INFO["double_rank"],1,-1 do 
			if(del_array[USER_INFO["double_rank"][i][1]] ~= 1 ) then

				table.insert(cards,{USER_INFO["double_rank"][i][1],USER_INFO["double_rank"][i][2]})
				one_mout = one_mout + 1
				if (one_mout == mount ) then
					return cards,main
				end
			end
		end

		for i=#USER_INFO["three_rank"],1,-1 do 
			if(del_array[USER_INFO["three_rank"][i][1]] ~= 1 ) then

				table.insert(cards,{USER_INFO["three_rank"][i][1],USER_INFO["three_rank"][i][2]})
				one_mout = one_mout + 1
				if (one_mout == mount ) then
					return cards,main
				end
			end
		end
	end

	if USER_INFO["four_rank"] then
		for i = #USER_INFO["four_rank"],4,-4  do
			local value      = USER_INFO["four_rank"][i]
			local real_value = USER_INFO["four_rank"][i][1]
			if not main_card[real_value] then
				return {{USER_INFO["four_rank"][i][1],USER_INFO["four_rank"][i][2]},{USER_INFO["four_rank"][i-1][1],USER_INFO["four_rank"][i-1][2]},{USER_INFO["four_rank"][i-2][1],USER_INFO["four_rank"][i-2][2]},{USER_INFO["four_rank"][i-3][1],USER_INFO["four_rank"][i-3][2]}},real_value
			end
		end
	end

	if big_boom == 1 then
		if not main_card[1] then
			return {{USER_INFO["one"][1][1][1],USER_INFO["one"][1][1][2]},{USER_INFO["one"][2][1][1],USER_INFO["one"][2][1][2]}},1
		end
	end

	return false
end


--获得飞机带二
function CardAnalysis:shunThreeWithTwo(max_value,len,main_card )
	local all = {}
	local big_boom  = 0
	if  USER_INFO["one"][1]  and   USER_INFO["one"][2]  then
		big_boom = 1
	end

	if USER_INFO["three"] then
		for key,value in pairs(USER_INFO["three"]) do
			if value[1][1] >=3 and   value[1][1] <=14 and len>5 then
				table.insert(all,{value[1][1],value[1][2]})
				table.insert(all,{value[2][1],value[2][2]})
				table.insert(all,{value[3][1],value[3][2]})
			elseif value[1][1] >=3 and   value[1][1] <=15 and len==5 then
				table.insert(all,{value[1][1],value[1][2]})
				table.insert(all,{value[2][1],value[2][2]})
				table.insert(all,{value[3][1],value[3][2]})
			end
		end
	end

	local mount  = len/5
	self:sort(all)
	local start = false
	local count = 0
	local cards = {}
	local tmp_v = nil 
	local flag  = 0
	local main
	local del_array = {}

	for i = #all,3,-3 do 
		if start == false then
			if all[i][1] > max_value-mount+1 and not  main_card[all[i][1] + mount - 1]   then
				start = true
				table.insert(cards,{all[i][1],all[i][2]})
				table.insert(cards,{all[i-1][1],all[i-1][2]})
				table.insert(cards,{all[i-2][1],all[i-2][2]})
				del_array[all[i][1]]  = 1
				tmp_v = all[i][1]
				count = 1
			end
		else
			if  all[i][1] == tmp_v + 1 then
				tmp_v     = all[i][1]
				count     = count + 1
				table.insert(cards,{all[i][1],all[i][2]})
				table.insert(cards,{all[i-1][1],all[i-1][2]})
				table.insert(cards,{all[i-2][1],all[i-2][2]})
				del_array[all[i][1]]  = 1
			else
				start = false
				count = 0
				cards = {}
				del_array = {}

				tmp_v     = all[i][1]
				count     = count + 1
				table.insert(cards,{all[i][1],all[i][2]})
				table.insert(cards,{all[i-1][1],all[i-1][2]})
				table.insert(cards,{all[i-2][1],all[i-2][2]})
				del_array[all[i][1]]  = 1
			end
		end

		if count == mount then
			flag =  1 
			main =  cards[#cards][1]
			break
		end
	end

	local one_mout = 0
	if flag== 1 then
		for i=#USER_INFO["double_rank"],2,-2 do 
			if(del_array[USER_INFO["double_rank"][i][1]] ~= 1 ) then

				table.insert(cards,{USER_INFO["double_rank"][i][1],USER_INFO["double_rank"][i][2]})
				table.insert(cards,{USER_INFO["double_rank"][i-1][1],USER_INFO["double_rank"][i-1][2]})
				one_mout = one_mout + 1
				if (one_mout == mount ) then
					return cards,main
				end
			end
		end

		for i=#USER_INFO["three_rank"],3,-3 do 
			if(del_array[USER_INFO["three_rank"][i][1]] ~= 1 ) then

				table.insert(cards,{USER_INFO["three_rank"][i][1],USER_INFO["three_rank"][i][2]})
				table.insert(cards,{USER_INFO["three_rank"][i-1][1],USER_INFO["three_rank"][i-1][2]})
				one_mout = one_mout + 1
				if (one_mout == mount ) then
					return cards,main
				end
			end
		end
	end

	if USER_INFO["four_rank"] then
		for i = #USER_INFO["four_rank"],4,-4  do
			local value      = USER_INFO["four_rank"][i]
			local real_value = USER_INFO["four_rank"][i][1]
			if not main_card[real_value] then
				return {{USER_INFO["four_rank"][i][1],USER_INFO["four_rank"][i][2]},{USER_INFO["four_rank"][i-1][1],USER_INFO["four_rank"][i-1][2]},{USER_INFO["four_rank"][i-2][1],USER_INFO["four_rank"][i-2][2]},{USER_INFO["four_rank"][i-3][1],USER_INFO["four_rank"][i-3][2]}},real_value
			end
		end
	end

	if big_boom == 1 then
		if not main_card[1] then
			return {{USER_INFO["one"][1][1][1],USER_INFO["one"][1][1][2]},{USER_INFO["one"][2][1][1],USER_INFO["one"][2][1][2]}},1
		end
	end

	return false
end


--获得四带二或者四带一
function CardAnalysis:fourWith(main_card)

	local big_boom  = 0
	if  USER_INFO["one"][1]  and   USER_INFO["one"][2]  then
		big_boom = 1
	end

	if USER_INFO["four_rank"] then
		for i = #USER_INFO["four_rank"],4,-4  do
			local value      = USER_INFO["four_rank"][i]
			local real_value = USER_INFO["four_rank"][i][1]
			if not main_card[real_value] then
				return {{USER_INFO["four_rank"][i][1],USER_INFO["four_rank"][i][2]},{USER_INFO["four_rank"][i-1][1],USER_INFO["four_rank"][i-1][2]},{USER_INFO["four_rank"][i-2][1],USER_INFO["four_rank"][i-2][2]},{USER_INFO["four_rank"][i-3][1],USER_INFO["four_rank"][i-3][2]}},real_value
			end
		end
	end

	if big_boom == 1 then
		if not main_card[1] then
			return {{USER_INFO["one"][1][1][1],USER_INFO["one"][1][1][2]},{USER_INFO["one"][2][1][1],USER_INFO["one"][2][1][2]}},1
		end
	end

	return false
end

--获得炸弹
function CardAnalysis:boom(main_value,main_card)

	if value == 1  then
		return false
	end

	local big_boom  = 0
	if  USER_INFO["one"][1]  and   USER_INFO["one"][2]  then
		big_boom = 1
	end

	if USER_INFO["four_rank"] then
		for i = #USER_INFO["four_rank"],4,-4  do
			local value      = USER_INFO["four_rank"][i]
			local real_value = USER_INFO["four_rank"][i][1]
			if not main_card[real_value] and USER_INFO["four_rank"][i][1] >main_value then
				return {{USER_INFO["four_rank"][i][1],USER_INFO["four_rank"][i][2]},{USER_INFO["four_rank"][i-1][1],USER_INFO["four_rank"][i-1][2]},{USER_INFO["four_rank"][i-2][1],USER_INFO["four_rank"][i-2][2]},{USER_INFO["four_rank"][i-3][1],USER_INFO["four_rank"][i-3][2]}},real_value
			end
		end
	end

	if big_boom == 1 then
		if not main_card[1] then
			return {{USER_INFO["one"][1][1][1],USER_INFO["one"][1][1][2]},{USER_INFO["one"][2][1][1],USER_INFO["one"][2][1][2]}},1
		end
	end

	return false
end

--得到玩家按同类分类的牌型数组
function CardAnalysis:fenLei()
	if USER_INFO["cards"] == nil then
		return false
	end
	local tmp = {}
	Card:sortCard()
	local tmp_flag = {}
	for key,value in pairs(USER_INFO["cards"]) do 
		local tmp_value = value[1]
		
		if tmp_flag[value[1]] ~= 1 then
			tmp[value[1]]  =  {}
		end
		
		table.insert(tmp[value[1]], {value[1],value[2]})
	
		tmp_flag[value[1]] = 1
		
	end

	USER_INFO["one"] = {}
	USER_INFO["double"] = {}
	USER_INFO["three"] = {}
	USER_INFO["four"] = {}
	USER_INFO["one_rank"]  = {}
	USER_INFO["double_rank"]  = {}
	USER_INFO["three_rank"]  = {}
	USER_INFO["four_rank"]  = {}
	
	for key,value in pairs(tmp) do
		local mount = #value
		if mount == 1 then
			USER_INFO["one"][key] = value
			for k,v in pairs(value) do
				table.insert(USER_INFO["one_rank"],v)   
			end
		end

		if mount == 2 then
			USER_INFO["double"][key] = value 
			for k,v in pairs(value) do
				table.insert(USER_INFO["double_rank"],v)   
			end
		end


		if mount == 3 then
			USER_INFO["three"][key] = value 
			for k,v in pairs(value) do
				table.insert(USER_INFO["three_rank"],v)   
			end
		end


		if mount == 4 then
			USER_INFO["four"][key] = value
			for k,v in pairs(value) do
				table.insert(USER_INFO["four_rank"],v)   
			end
		end

	end

	table.sort(USER_INFO["one_rank"],function(a,b)
		local at = a[1]
		local bt = b[1]
		if(a[1] ==1 ) then
			at = 16
		end
		if(a[1] ==2 ) then
			at = 17
		end

		if(b[1] ==1 ) then
			bt = 16
		end
		if(b[1] ==2 ) then
			bt = 17
		end

		return at>bt
	end)

	table.sort(USER_INFO["double_rank"],function(a,b)
		local at = a[1]
		local bt = b[1]
		if(a[1] ==1 ) then
			at = 16
		end
		if(a[1] ==2 ) then
			at = 17
		end

		if(b[1] ==1 ) then
			bt = 16
		end
		if(b[1] ==2 ) then
			bt = 17
		end

		return at>bt
	end)

	table.sort(USER_INFO["three_rank"],function(a,b)
		local at = a[1]
		local bt = b[1]
		if(a[1] ==1 ) then
			at = 16
		end
		if(a[1] ==2 ) then
			at = 17
		end

		if(b[1] ==1 ) then
			bt = 16
		end
		if(b[1] ==2 ) then
			bt = 17
		end

		return at>bt
	end)

	table.sort(USER_INFO["four_rank"],function(a,b)
		local at = a[1]
		local bt = b[1]
		if(a[1] ==1 ) then
			at = 16
		end
		if(a[1] ==2 ) then
			at = 17
		end

		if(b[1] ==1 ) then
			bt = 16
		end
		if(b[1] ==2 ) then
			bt = 17
		end

		return at>bt
	end)

	return true

end


--对比牌型
function CardAnalysis:isType(type,talbet)
	if type == CARD_TYPE_ONE then
		if #talbet ~= 1 then
			return false
		end
		local v =talbet[1][1]
		if talbet[1][1] == 1 then
			v = 16
		end
		if talbet[1][1] == 2 then
			v = 17
		end
		return v
	end

	if type == CARD_TYPE_TWO then
		local main_card = self:isDouble(talbet)
		if  main_card then
			return main_card
		end
		return false
	end

	if type == CARD_TYPE_THREE then
		local main_card = self:isThree(talbet)
		if  main_card then
			return main_card
		end
		return false
	end


	if type == CARD_TYPE_THREEWITHONE then
		local main_card = self:isThreeWithOne(talbet)
		if  main_card then
			return main_card
		end
		return false
	end


	if type == CARD_TYPE_THREEWITHTWO then

		local main_card = self:isThreeWithTwo(talbet)
		if  main_card then
			return main_card
		end
		return false
	end



	if type == CARD_TYPE_ONELINE then
		local main_card = self:isShun(talbet)
		if  main_card then
			return main_card
		end
		return false
	end

	if type == CARD_TYPE_TWOLINE then
		local main_card = self:isDoubleShun(talbet)
		if  main_card then
			return main_card
		end
		return false
	end


	if type == CARD_TYPE_THREELINE then
		local main_card = self:isThreeShunNoWing(talbet)
		if  main_card then
			return main_card
		end
		return false
	end


	if type == CARD_TYPE_PLANEWITHONE then
		local main_card = self:isThreeShunWingOne(talbet)
		if  main_card then
			return main_card
		end
		return false
	end

	if type == CARD_TYPE_PLANEWITHWING then
		local main_card = self:isThreeShunWingTwo(talbet)
		if  main_card then
			return main_card
		end
		return false
	end


	if type == CARD_TYPE_BOMB then
		local main_card = self:isBoom(talbet)
		if  main_card then
			return main_card
		end
		return false
	end

	if type == CARD_TYPE_FOURWITHTWO then
		local main_card = self:isBoomWithTwo(talbet)
		if  main_card then
			return main_card
		end
		return false
	end


	if type == CARD_TYPE_FOURWITHFOUR then
		local main_card = self:isBoomWithFour(talbet)
		if  main_card then
			return main_card
		end
		return false
	end


	return false
end


-- 获得牌型
function  CardAnalysis:getType(talbet)

	if #talbet == 1 then
		return CARD_TYPE_ONE,talbet[1][1],1
	end

	local main_card
	local length
	main_card = self:isDouble(talbet)
	if  main_card then
		return CARD_TYPE_TWO,main_card,2
	end

	main_card = self:isThree(talbet)
	if  main_card then
		return CARD_TYPE_THREE,main_card,3
	end
	
	main_card = self:isThreeWithOne(talbet)
	if  main_card then
		return CARD_TYPE_THREEWITHONE,main_card,4
	end

	main_card = self:isThreeWithTwo(talbet)
	if  main_card then
		return CARD_TYPE_THREEWITHTWO,main_card,5
	end

	main_card,length = self:isShun(talbet)
	if  main_card then
		return CARD_TYPE_ONELINE,main_card,#talbet
	end

	main_card,length = self:isDoubleShun(talbet)
	if  main_card then
		return CARD_TYPE_TWOLINE,main_card,#talbet
	end

	main_card,length = self:isThreeShunNoWing(talbet)
	if  main_card then
		print("getType isThreeShunNoWing")
		dump(talbet, "getType")
		return CARD_TYPE_THREELINE,main_card,#talbet
	end

	main_card,length = self:isThreeShunWingOne(talbet)
	if  main_card then
		return CARD_TYPE_PLANEWITHONE,main_card,#talbet
	end

	main_card,length = self:isThreeShunWingTwo(talbet)
	if  main_card then
		return CARD_TYPE_PLANEWITHWING,main_card,#talbet
	end

	main_card = self:isBoom(talbet)
	if  main_card then
		print("getType isBoom")
		dump(talbet, "getType")
		return CARD_TYPE_BOMB,main_card,#talbet
	end


	main_card = self:isBoomWithTwo(talbet)
	if  main_card then
		return CARD_TYPE_FOURWITHTWO,main_card,#talbet
	end

	main_card = self:isBoomWithFour(talbet)
	if  main_card then
		return CARD_TYPE_FOURWITHFOUR,main_card,#talbet
	end

	

end


--是不是对子
function CardAnalysis:isDouble(table)
	if #table ~= 2 then
		return false
	end
	if table[1][1] ~= table[2][1] then
		return false
	end


	return table[1][1]
end

--是不是3张
function CardAnalysis:isThree(table)

		if #table ~= 3 then
			return false
		end
	if table[1][1] ~= table[2][1] or table[1][1] ~= table[3][1]  or #table ~= 3 then
		return false
	end
	return table[1][1]
end

--是不是3张带一
function CardAnalysis:isThreeWithOne(table)
	if #table ~= 4 then
		return false
	end

	local tmp = {}
	for key,value in pairs(table) do
		if not tmp[value[1]] then
			tmp[value[1]] = 0
		end
		tmp[value[1]] = tmp[value[1]] + 1
	end

	for key,value in pairs(tmp) do
		if(value == 3) then
			return key
		end
	end

	return false
end


--是不是3张带2
function CardAnalysis:isThreeWithTwo(table)
	if #table ~= 5 then
		return false
	end

	local tmp = {}
	for key,value in pairs(table) do
		if not tmp[value[1]] then
			tmp[value[1]] = 0
		end
		tmp[value[1]] = tmp[value[1]] + 1
	end

	local three_flag  = false
	local main_card   = 0
	local double_flag = false

	for key,value in pairs(tmp) do
		if(value == 3) then
			three_flag =  true
			main_card = key
		end

		if(value == 2) then
			double_flag =  true
		end

	end

	if three_flag and double_flag then
		return main_card
	end

	return false
end

--是不是单顺子
function CardAnalysis:isShun(tablet)
	CardAnalysis:sort(tablet)

	if #tablet<5 then
		return false
	end

	for i=1,#tablet do
		if tablet[i][1]>14 or tablet[i][1]<3 then
			return false
		end
	end


	for i=1,#tablet-1 do 
		if(tablet[i][1] ~= tablet[i+1][1] + 1) then
			return false
		end
	end

	return tablet[1][1],#tablet
end

--是不是双顺
function CardAnalysis:isDoubleShun(tablet)
	CardAnalysis:sort(tablet)
	if #tablet<6 or tablet[1][1] > 14 or tablet[#tablet][1] < 3 then
		return false
	end

	local tmp = {}
	local tmp_value =  nil
	for key,value in pairs(tablet) do
		if not tmp[value[1]] then
			tmp[value[1]] = 0
		end
		tmp[value[1]] = tmp[value[1]] + 1


		if tmp[value[1]] == 2  and tmp_value ~= nil then
			if tmp_value -1 ~= value[1] then
				return false
			end

			tmp_value = value[1]
		end

		if tmp[value[1]] == 2  and tmp_value == nil then
			tmp_value = value[1]
		end

		if tmp[value[1]] > 2 then
			return false
		end
	end


	return tablet[1][1],#tablet
end

--是不是飞机不带翅膀
function CardAnalysis:isThreeShunNoWing(tablet)
	CardAnalysis:sort(tablet)
	if #tablet%3 ~= 0 or #tablet<6 then
		return false
	end
	-- if tablet[1][1] > 14 or #tablet%3 ~= 0 or #tablet<6  or tablet[#tablet][1] < 3 then
	-- 	return false
	-- end
	if table[1] and tablet[1][1] and tablet[#tablet] and tablet[#tablet][1] then
    	if  tablet[1][1] > 14 or tablet[#tablet][1] < 3 then
    		return nil
    	end
	end


	local tmp = {}
	local tmp_value =  nil
	for key,value in pairs(tablet) do
		if not tmp[value[1]] then
			tmp[value[1]] = 0
		end
		tmp[value[1]] = tmp[value[1]] + 1
		if tmp[value[1]] == 3 and tmp_value ~= nil then
			
			if tmp_value -1 ~= value[1] then
				return false
			end
			tmp_value = value[1]
		end
		if tmp[value[1]] == 3 and tmp_value == nil then
			tmp_value = value[1]
		end



		if tmp[value[1]] > 3 then
			return false
		end
	end

	return tablet[1][1],#tablet
end


--是不是飞机带翅膀1
function CardAnalysis:isThreeShunWingOne(table)
	CardAnalysis:sort(table)
	if#table%4 ~= 0   then
		return false
	end

	local tmp = {}
	local tmp_value = nil
	local main_card 
	for key,value in pairs(table) do
		if not tmp[value[1]] then
			tmp[value[1]] = 0
		end
		tmp[value[1]] = tmp[value[1]] + 1
		if tmp[value[1]] > 3 then
			return false
		end

		if tmp[value[1]] == 3 then
			if value[1] >14 or  value[1] <3 then
			 	return false
			end

			if  tmp_value ~= nil then
				if tmp_value -1 ~= value[1] then
					return false
				end
				tmp_value = value[1]
			end

			if  tmp_value == nil then
				tmp_value = value[1]
				main_card = value[1]
			end




		end

		if tmp[value[1]] > 3 then
			return false
		end

	end

	return main_card,#table
end

--是不是飞机带翅膀2
function CardAnalysis:isThreeShunWingTwo(table)
	CardAnalysis:sort(table)
	if#table%5 ~= 0   then
		return false
	end

	local tmp = {}
	local tmp_value = nil
	local main_card 
	for key,value in pairs(table) do
		if not tmp[value[1]] then
			tmp[value[1]] = 0
		end
		tmp[value[1]] = tmp[value[1]] + 1
		if tmp[value[1]] > 3 then
			return false
		end

		if tmp[value[1]] == 3 then
			if value[1] >14 or  value[1] <3 then
			 	return false
			end

			if  tmp_value ~= nil then
				if tmp_value -1 ~= value[1] then
					return false
				end
				tmp_value = value[1]
			end
			if  tmp_value == nil then
				tmp_value = value[1]
				main_card = value[1]
			end




		end

		if tmp[value[1]] > 3 then
			return false
		end
	end

	for key,value in pairs(tmp) do
		if value <2 then
			return false
		end
	end



	return main_card,#table
end



--是不是boom
function CardAnalysis:isBoom(table)
	if #table ~= 2 and #table ~= 4 then
		return false
	end

	local main_card 
	if #table == 2 then
		if table[1][1] >3 or table[2][1] >3 then
			return false
		end
		main_card = 1
	end

	if #table == 4 then
		if table[1][1]  ~= table[2][1] or table[1][1]  ~= table[3][1]  or table[1][1]  ~= table[4][1]  then
			return false
		end
		main_card = table[1][1]
	end

	return main_card
end


--是不是4带2
function CardAnalysis:isBoomWithTwo(table)
	if #table ~= 6 then
		return false
	end
	local tmp = {}
	local flag = false
	local main_card 
	for key,value in pairs(table) do
		if not tmp[value[1]] then
			tmp[value[1]] = 0
		end
		tmp[value[1]] = tmp[value[1]] + 1
		if tmp[value[1]] == 4 then
			main_card = value[1]
			return main_card,6
		end
	end

	return false
end


--是不是4带2对
function CardAnalysis:isBoomWithFour(table)
	if #table ~= 8 then
		return false
	end
	local tmp = {}
	local flag = false
	local main_card 
	for key,value in pairs(table) do
		if not tmp[value[1]] then
			tmp[value[1]] = 0
		end
		tmp[value[1]] = tmp[value[1]] + 1
		if tmp[value[1]] == 4 then
			main_card = value[1]
			flag = true
		end
	end


	if flag == true then
		for key,value in pairs(tmp)  do
			if value ~=4 and value ~= 2 then
				return false
			end
		end

		return main_card,8
	end

	return false
end




--排序
function  CardAnalysis:sort(tablet)
	table.sort(tablet,function(a,b) 
        if( a[2]  == 4 and b[2] == 4) then
            return a[1]>b[1]
        end

        if(a[2] == 4 and b[2] ~= 4) then
            return true
        end

        if(a[2] ~= 4 and b[2] == 4) then
            return false
        end

        if(a[2] ~= 4 and b[2] ~= 4) then
            return a[1]>b[1] 
        end
    end )
end


return CardAnalysis
