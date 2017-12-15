cc.utils                = require("framework.cc.utils.init")
cc.net                  = require("framework.cc.net.init")
local Card     = require("ddz_laizi.Card")
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
	self:fenLei()
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

	dump(main_card, "getSuitCard")
	local max_value = main_card[1]["main_card"]

	self:fenLei()
	local m_main
	if type == CARD_TYPE_ONE then
		local cards,m_main = self:single(max_value,main_card_arr)
		if cards ~= false then
			return cards,m_main 
		else
			return false
		end
	end

	if type == CARD_TYPE_TWO then
		local cards,m_main = self:double(max_value,main_card_arr)
		if cards ~= false then
			return cards,m_main
		else
			return false
		end
	end

	if type == CARD_TYPE_THREE then
		local cards,m_main = self:three(max_value,main_card_arr)
		if cards ~= false then
			return cards,m_main
		else
			return false
		end
	end

	if type == CARD_TYPE_THREEWITHONE then
		local cards,m_main = self:shunThreeWithOne(max_value,#talbet,main_card_arr)
		if cards ~= false then
			return cards,m_main
		else
			return false
		end
	end

	if type == CARD_TYPE_THREEWITHTWO then
		local cards,m_main = self:shunThreeWithTwo(max_value,#talbet,main_card_arr)
		if   cards ~= false then
			return cards,m_main
		end
		return false
	end

	if type == CARD_TYPE_ONELINE then
		local cards,main_card = self:shun(max_value,#talbet,main_card_arr)
		if  cards ~= false then
			return cards,main_card
		end
		return false
	end

	if type == CARD_TYPE_TWOLINE then
		local cards,main_card  = self:shunDouble(max_value,#talbet,main_card_arr)
		if  cards ~= false then
			return cards,main_card
		end
		return false
	end

	if type == CARD_TYPE_THREELINE then
		local  cards,main_card = self:shunThree(max_value,#talbet,main_card_arr)
		if  cards ~= false then
			return  cards,main_card
		end
		return false
	end

	if type == CARD_TYPE_PLANEWITHONE then

		local cards,main_card = self:shunThreeWithOne(max_value,#talbet,main_card_arr)
		if  cards ~= false  then
			return cards,main_card
		end
		return false
	end

	if type == CARD_TYPE_PLANEWITHWING then
		local cards,main_card = self:shunThreeWithTwo(max_value,#talbet,main_card_arr)
		if  cards ~= false then
			return cards,main_card
		end
		return false
	end

	if type == CARD_TYPE_BOMB then
		local cards,main_card = self:boom(max_value,main_card_arr)
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

end


--对比牌型
function CardAnalysis:isType(typeCards,talbet)
	if typeCards == CARD_TYPE_ONE then
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
		local tempCards = {}
		local dataCard = {}
		dataCard["cards"] = talbet
		dataCard["main_card"] = v
		dataCard["type"] = CARD_TYPE_ONE
		table.insert(tempCards,dataCard)
		return tempCards
	end

	if typeCards == CARD_TYPE_TWO then
		local main_card = self:isDouble(talbet)
		if  main_card then
			return main_card
		end
		return false
	end

	if typeCards == CARD_TYPE_THREE then
		local main_card = self:isThree(talbet)
		if  main_card then
			return main_card
		end
		return false
	end


	if typeCards == CARD_TYPE_THREEWITHONE then
		local main_card = self:isThreeWithOne(talbet)
		if  main_card then
			return main_card
		end
		return false
	end


	if typeCards == CARD_TYPE_THREEWITHTWO then

		local main_card = self:isThreeWithTwo(talbet)
		if  main_card then
			return main_card
		end
		return false
	end



	if typeCards == CARD_TYPE_ONELINE then
		local main_card = self:isShun(talbet)
		if  main_card then
			return main_card
		end
		return false
	end

	if typeCards == CARD_TYPE_TWOLINE then
		local main_card = self:isDoubleShun(talbet)
		if  main_card then
			return main_card
		end
		return false
	end


	if typeCards == CARD_TYPE_THREELINE then
		local main_card = self:isThreeShunNoWing(talbet)
		if  main_card then
			return main_card
		end
		return false
	end


	if typeCards == CARD_TYPE_PLANEWITHONE then
		local main_card = self:isThreeShunWingOne(talbet)
		if  main_card then
			return main_card
		end
		return false
	end

	if typeCards == CARD_TYPE_PLANEWITHWING then
		local main_card = self:isThreeShunWingTwo(talbet)
		if  main_card then
			return main_card
		end
		return false
	end


	if typeCards == CARD_TYPE_BOMB then
		local main_card = self:isBoom(talbet)
		if  main_card then
			return main_card
		end
		return false
	end

	if typeCards == CARD_TYPE_FOURWITHTWO then
		local main_card = self:isBoomWithTwo(talbet)
		if  main_card then
			return main_card
		end
		return false
	end


	if typeCards == CARD_TYPE_FOURWITHFOUR then
		local main_card = self:isBoomWithFour(talbet)
		if  main_card then
			return main_card
		end
		return false
	end


	return false
end

local listCards = {}--返回多个牌型，供玩家选择

-- 获得牌型
function  CardAnalysis:getType(talbet)

	listCards = {}

	if #talbet == 1 then
		local v =talbet[1][1]
		if talbet[1][1] == 1 then
			v = 16
		end
		if talbet[1][1] == 2 then
			v = 17
		end
		local dataCard = {}
		dataCard["cards"] = talbet
		dataCard["main_card"] = v
		dataCard["type"] = CARD_TYPE_ONE
		table.insert(listCards,dataCard)
		return listCards
	end

	local main_card
	main_card = self:isDouble(talbet)
	if  main_card then
		return main_card
	end

	main_card = self:isThree(talbet)
	if  main_card then
		return main_card
	end
	--先把通吃牌型加进来
	self:isBoom(talbet)
	
	main_card = self:isThreeWithOne(talbet)
	if  main_card then
		return main_card
	end

	main_card = self:isThreeWithTwo(talbet)
	if  main_card then
		return main_card
	end

	main_card = self:isShun(talbet)

	main_card = self:isDoubleShun(talbet)

	main_card = self:isThreeShunNoWing(talbet)

	main_card = self:isThreeShunWingOne(talbet)

	main_card = self:isThreeShunWingTwo(talbet)

	main_card = self:isBoomWithTwo(talbet)

	main_card = self:isBoomWithFour(talbet)

	if #listCards > 0 then
		return listCards
	else
		return false
	end
end

--添加牌型
function CardAnalysis:addTypeCards(card,main_card,type)
	local temp = {}
	temp["cards"] = card
	temp["main_card"] = main_card
	temp["type"] = type
	listCards[#listCards+1] = temp
end

--存非癞子牌以及个数
local tbNotLaiziCards = {}
local laiziCount = 0
local countCards = {}--牌数统计
local noLaiziList = {}
function CardAnalysis:countLaizi(cards)
	local laiziValue = Card:getLaizi()
	laiziCount = 0
	tbNotLaiziCards = {}
	countCards = {}
	-- listCards = {}
	noLaiziList = {}

	local function addCount(value)
		--牌数统计
		if countCards[value] == nil then
			countCards[value] = 0
		end
		countCards[value] = countCards[value] + 1
		for i, v in pairs(tbNotLaiziCards) do
			if v["card"] == value then
				v["count"] = v["count"] + 1
				return
			end
		end
		local data = {}
		data["card"] = value
		data["count"] = 1
		tbNotLaiziCards[#tbNotLaiziCards+1] = data
	end

	for i, v in pairs(cards) do
		if v[1] == laiziValue then
			laiziCount = laiziCount + 1
		else
			addCount(v[1])
			table.insert(noLaiziList,v)
		end
	end
end

--是不是对子
function CardAnalysis:isDouble(table)
	if #table ~= 2 then
		return false
	end
	-- listCards = {}
	local laiziValue = Card:getLaizi()
	if table[1][1] ~= table[2][1] then
		local tbCards = {}
		if laiziValue == table[1][1] or laiziValue == table[2][1] then
			if laiziValue == table[1][1] then
				tbCards[#tbCards+1] = {table[2][1],table[2][2]}
				tbCards[#tbCards+1] = {table[2][1],5}
				CardAnalysis:addTypeCards(tbCards,table[2][1],CARD_TYPE_TWO)
				return listCards
			end
			tbCards[#tbCards+1] = {table[1][1],table[1][2]}
			tbCards[#tbCards+1] = {table[1][1],5}
			CardAnalysis:addTypeCards(tbCards,table[1][1],CARD_TYPE_TWO)
			return listCards
		end
		return false
	end

	CardAnalysis:addTypeCards(table,table[1][1],CARD_TYPE_TWO)
	return listCards
end

--是不是3张
function CardAnalysis:isThree(table)

	if #table ~= 3 then
		return false
	end
	-- listCards = {}
	CardAnalysis:sort(table)
	self:countLaizi(table)
	if #tbNotLaiziCards > 1 then
		return false
	end
	local laiziValue = Card:getLaizi()
	if #tbNotLaiziCards == 0 then
		CardAnalysis:addTypeCards(table,laiziValue,CARD_TYPE_THREE)
	elseif #tbNotLaiziCards == 1 then
		local tbCards = {}
		for i, v in pairs(table) do
			if v[1] == laiziValue then
				tbCards[#tbCards+1] = {tbNotLaiziCards[1]["card"],5}
			else
				tbCards[#tbCards+1] = {v[1],v[2]}
			end
		end
		CardAnalysis:addTypeCards(tbCards,tbNotLaiziCards[1]["card"],CARD_TYPE_THREE)
	end
	return listCards
end

--是不是3张带一
function CardAnalysis:isThreeWithOne(tablet)
	if #tablet ~= 4 then
		return false
	end
	-- listCards = {}
	CardAnalysis:sort(tablet)

	self:countLaizi(tablet)
	if #tbNotLaiziCards > 2 then
		return false
	end
	local laiziValue = Card:getLaizi()
	if laiziCount == 3 then
		CardAnalysis:addTypeCards(tablet,laiziValue,CARD_TYPE_THREEWITHONE)
		return listCards
	end
	--只有其他牌总类为2的情况
	for i, v in pairs(tbNotLaiziCards) do
		if v["count"] == 3 then
			CardAnalysis:addTypeCards(tablet,v["card"],CARD_TYPE_THREEWITHONE)
			return listCards
		end
	end
	for i, v in pairs(tbNotLaiziCards) do
		if laiziCount == 1 and v["count"] == 2 then
			local tbCards = {}
			for i, vv in pairs(tablet) do
				if vv[1] == laiziValue then
					tbCards[#tbCards+1] = {v["card"],5}
				else
					tbCards[#tbCards+1] = {vv[1],vv[2]}
				end
			end
			CardAnalysis:addTypeCards(tbCards,v["card"],CARD_TYPE_THREEWITHONE)
			return listCards
		end
	end
	if laiziCount == 2 then
		local needCount = 3
		print("isThreeWithOne needCount",tostring(needCount))
		for k = 1, #tbNotLaiziCards do
			local tbCards = {}
			for i, v in pairs(tablet) do
				if v[1] ~= laiziValue then
					table.insert(tbCards,{v[1],v[2]})
					needCount = needCount - 1
				end
			end
			print("isThreeWithOne",tostring(tbNotLaiziCards[k]["card"]))
			for i, v in pairs(tablet) do
				if v[1] == laiziValue then
					if needCount > 0 then
						table.insert(tbCards,{tbNotLaiziCards[k]["card"],5})
						needCount = needCount - 1
					else
						table.insert(tbCards,{v[1],v[2]})
					end
				end
			end
			CardAnalysis:addTypeCards(tbCards,tbNotLaiziCards[k]["card"],CARD_TYPE_THREEWITHONE)
		end
		return listCards
	end

	return false
end


--是不是3张带2
function CardAnalysis:isThreeWithTwo(tablet)
	if #tablet ~= 5 then
		return false
	end

	CardAnalysis:sort(tablet)
	self:countLaizi(tablet)
	local notLaiziCount = #tbNotLaiziCards
	if notLaiziCount > 2 then
		return false
	end
	local laiziValue = Card:getLaizi()
	if notLaiziCount == 1 then
		if tbNotLaiziCards[1]["count"] > 3 then
			return false
		end
		local tbCards = {}
		local countThree = tbNotLaiziCards[1]["count"]
		for i, v in pairs(tablet) do
			if v[1] == laiziValue then
				if countThree < 3 then
					tbCards[#tbCards+1] = {tbNotLaiziCards[1]["card"],5}
					countThree = countThree + 1
				else
					tbCards[#tbCards+1] = {v[1],v[2]}
				end
			else
				tbCards[#tbCards+1] = {v[1],v[2]}
			end
		end
		CardAnalysis:addTypeCards(tbCards,tbNotLaiziCards[1]["card"],CARD_TYPE_THREEWITHTWO)
		--癞子做头牌
		if laiziCount >= 3 then
			tbCards = tablet
			if laiziCount > 3 then
				tbCards = {}
				countThree = 0
				for i, v in pairs(tablet) do
					if v[1] == laiziValue then
						if countThree < 3 then
							tbCards[#tbCards+1] = {v[1],v[2]}
							countThree = countThree + 1
						else
							tbCards[#tbCards+1] = {tbNotLaiziCards[1]["card"],5}
						end
					else
						tbCards[#tbCards+1] = {v[1],v[2]}
					end
				end
			end
			CardAnalysis:addTypeCards(tbCards,laiziValue,CARD_TYPE_THREEWITHTWO)
		end
		return listCards
	end
	if notLaiziCount == 2 then
		if laiziCount == 0 then
			for k = 1, 2 do
				if tbNotLaiziCards[k]["count"] == 3 then
					CardAnalysis:addTypeCards(tablet,tbNotLaiziCards[k]["card"],CARD_TYPE_THREEWITHTWO)
					break
				end
			end
		else
			for k = 1, 2 do
				if tbNotLaiziCards[k]["count"] > 3 then
					return false
				end
				local tbCards = {}
				local countThree = 3
				print("CARD_TYPE_THREEWITHTWO needCount",tostring(countThree))
				local findHead = true

				for i, v in pairs(tablet) do
					if v[1] == tbNotLaiziCards[k]["card"] then
						table.insert(tbCards,{v[1],v[2]})
						countThree = countThree - 1
					end
				end
				--拿癞子变头牌
				local leaveLaiz = laiziCount
				if countThree > 0 then
					if laiziCount >= countThree then
						for i=1,countThree do
							table.insert(tbCards,{tbNotLaiziCards[k]["card"],5})
							leaveLaiz = leaveLaiz - 1
						end
					else
						print("变3癞子不够",tostring(laiziCount),tostring(countThree))
						findHead = false
					end
				end
				--对子
				if findHead then
					dump(tbCards, "CARD_TYPE_THREEWITHTWO double")
					local countDouble = 2
					for i, v in pairs(tablet) do
						if v[1] == tbNotLaiziCards[3-k]["card"] then
							table.insert(tbCards,{v[1],v[2]})
							countDouble = countDouble - 1
					dump(tbCards, "CARD_TYPE_THREEWITHTWO double 1")
						end
					end
					if countDouble > 0 and leaveLaiz >= countDouble then
						if leaveLaiz >= countDouble then
							for i=1,countDouble do
								table.insert(tbCards,{tbNotLaiziCards[3-k]["card"],5})
					dump(tbCards, "CARD_TYPE_THREEWITHTWO double 2")
							end
						else
							print("变2癞子不够",tostring(leaveLaiz))
							findHead = false
						end
					end
				end

				if findHead then
					CardAnalysis:addTypeCards(tbCards,tbNotLaiziCards[k]["card"],CARD_TYPE_THREEWITHTWO)
				end
			end
		end
		return listCards
	end

	return false
end

--是不是单顺子
function CardAnalysis:isShun(tablet)
	CardAnalysis:sort(tablet)

	if #tablet < 5 or #tablet > 12 then
		return false
	end

	--计算有多少个癞子
	self:countLaizi(tablet)
	for i=1,#tbNotLaiziCards do
		if tbNotLaiziCards[i]["card"]>14 or tbNotLaiziCards[i]["card"]<3 then
			return false
		end
	end
	--拿出癞子牌
	local vCards = {}
	local laiziValue = Card:getLaizi()
	for i, v in pairs(tablet) do
		if v[1] ~= laiziValue then
			table.insert(vCards,v)
		end
	end
	local iPos = 1
	for i=1,#tablet-1 do
		if vCards[i] ~= nil and vCards[i+1] ~= nil then
			if(vCards[iPos][1] == vCards[iPos+1][1] ) then
				--非癞子牌中有两个相同的牌
				return false
			end
			if(vCards[iPos][1] ~= vCards[iPos+1][1] + 1) then
				--拿一个癞子来变
				if laiziCount > 0 then
					laiziCount = laiziCount - 1
					local data = {vCards[iPos][1]-1,5}
					table.insert(vCards,data)
					CardAnalysis:sort(vCards)
					iPos = iPos + 1
				else
					return false
				end
			else
				iPos = iPos + 1
			end
		end
	end
	-- dump(vCards, "isShun")
	local maxCard = vCards[1][1]
	local minCard = vCards[#vCards][1]
	--还有癞子多
	if laiziCount > 0 then
		if maxCard >= 14 then
			local overCard = 0
			local leave_laizi = laiziCount
			local temp = {}
			for k, n in pairs(vCards) do
				table.insert(temp,n)
			end
			for k = 1, leave_laizi do
				if minCard-k+1 < 3 then
					overCard = 1
				else
					local data = {minCard-k,5}
					table.insert(temp,data)
					leave_laizi = leave_laizi - 1
				end
			end
			if overCard == 0 then
				CardAnalysis:addTypeCards(temp,maxCard,CARD_TYPE_ONELINE)
			end
		else
			for i=1, laiziCount + 1 do
				local max_temp = maxCard + laiziCount - i + 1
				if max_temp == maxCard then
					local overCard = 0
					local leave_laizi = laiziCount
					local temp = {}
					for k, n in pairs(vCards) do
						table.insert(temp,n)
					end
					for k = 1, leave_laizi do
						if minCard-k < 3 then
							overCard = 1
						else
							local data = {minCard-k,5}
							table.insert(temp,data)
							leave_laizi = leave_laizi - 1
						end
					end
					if overCard == 0 then
						CardAnalysis:addTypeCards(temp,maxCard,CARD_TYPE_ONELINE)
					end
				else
					if max_temp < 14 then
						local leave_laizi = laiziCount
						local temp = {}
						for k, n in pairs(vCards) do
							table.insert(temp,n)
						end
						local overCard = 0
						-- dump(temp, "add before")
						for k = 1, leave_laizi do
							if max_temp-k+1 > vCards[1][1] then
								local data = {max_temp-k+1,5}
								table.insert(temp,data)
								leave_laizi = leave_laizi - 1
							end
						end
						-- dump(temp, "desciption")
						-- print("leave_laizi",tostring(leave_laizi))
						if leave_laizi > 0 then
							for k = 1, leave_laizi do
								if minCard-k < 3 then
									overCard = 1
								else
									local data = {minCard-k,5}
									table.insert(temp,data)
									leave_laizi = leave_laizi - 1
								end
							end
						end
						dump(temp, "isShun")
						if overCard == 0 then
							CardAnalysis:addTypeCards(temp,max_temp,CARD_TYPE_ONELINE)
						end
					end
				end
			end
		end
	else
		CardAnalysis:addTypeCards(vCards,maxCard,CARD_TYPE_ONELINE)
	end

	if #listCards > 0 then
		return listCards
	else
		return false
	end

end

--
function CardAnalysis:sortCard(vCards)
	table.sort(vCards,function(a,b)
		return a["card"] > b["card"]
    end )
end
--是不是双顺
function CardAnalysis:isDoubleShun(tablet)
	CardAnalysis:sort(tablet)
	if #tablet<6 or tablet[1][1] > 14 or tablet[#tablet][1] < 3 or #tablet%2 ~= 0 then
		return false
	end
	--计算有多少个癞子
	self:countLaizi(tablet)
	local vCards = {}
	for i, v in pairs(tbNotLaiziCards) do
		table.insert(vCards,v)
	end
	local iPos = 1
	while vCards[iPos]["card"] >= tbNotLaiziCards[#tbNotLaiziCards]["card"] do
		if vCards[iPos] ~= nil then
			if vCards[iPos]["count"] > 2 then
				return false
			elseif vCards[iPos]["count"] == 1 then
				--拿一个癞子来变
				if laiziCount > 0 then
					laiziCount = laiziCount - 1
					local dataCard = {vCards[iPos]["card"],5}
					table.insert(noLaiziList,dataCard)
				else
					return false
				end
			end

			if vCards[iPos+1] ~= nil then
				if(vCards[iPos]["card"] ~= vCards[iPos+1]["card"] + 1) then
					--拿一个癞子来变
					if laiziCount >= 2 then
						laiziCount = laiziCount - 2
						local data = {}
						data["card"] = vCards[iPos]["card"]-1
						data["count"] = 2
						table.insert(vCards,data)
						local dataCard = {vCards[iPos]["card"]-1,5}
						table.insert(noLaiziList,dataCard)
						dataCard = {vCards[iPos]["card"]-1,5}
						table.insert(noLaiziList,dataCard)
						CardAnalysis:sortCard(vCards)
					else
						return false
					end
				end
			end

		end

		if vCards[iPos]["card"] == tbNotLaiziCards[#tbNotLaiziCards]["card"] then
			break
		end
		iPos = iPos + 1
	end

	-- dump(noLaiziList, "isDoubleShun")
	if #noLaiziList == #tablet then
		CardAnalysis:addTypeCards(noLaiziList,noLaiziList[1][1],CARD_TYPE_TWOLINE)
		return listCards
	end

	CardAnalysis:checkXLine(CARD_TYPE_TWOLINE)

	-- dump(listCards, "CARD_TYPE_TWOLINE")

	if #listCards > 0 then
		return listCards
	else
		return false
	end
end
--处理xLine
function CardAnalysis:checkXLine(typeCards)
	local count = 0
	if typeCards == CARD_TYPE_ONELINE then
		count = 1
	elseif typeCards == CARD_TYPE_TWOLINE then
		count = 2
	elseif typeCards == CARD_TYPE_THREELINE then
		count = 3
	else
		return
	end
	CardAnalysis:sort(noLaiziList)

	local maxCard = noLaiziList[1][1]
	local minCard = noLaiziList[#noLaiziList][1]
	-- print("checkXLine maxCard minCard",tostring(maxCard),tostring(minCard))
	local function addChangeCard(value,tbTemp)
		for i = 1, count do
			local data = {value,5}
			table.insert(tbTemp,data)
		end
	end
	--还有癞子多
	if laiziCount > 0 then
		if maxCard >= 14 then
			local overCard = 0
			local leave_laizi = laiziCount
			local temp = {}
			for k, n in pairs(noLaiziList) do
				table.insert(temp,n)
			end
			for k = 1, leave_laizi do
				if minCard-k+1 < 3 then
					overCard = 1
				else
					if leave_laizi >= count then
						addChangeCard(minCard-k,temp)
						-- dump(temp, "addChangeCard 1")
						leave_laizi = leave_laizi - count
					end
				end
			end
			if overCard == 0 then
				CardAnalysis:addTypeCards(temp,maxCard,typeCards)
			end
		else
			for i=1, laiziCount + 1 do
				local max_temp = maxCard + math.modf(laiziCount/count) - i + 1
				local leave_laizi = laiziCount
				local overCard = 0
				local temp = {}
				for k, n in pairs(noLaiziList) do
					table.insert(temp,n)
				end
				if max_temp == maxCard then
					for k = 1, leave_laizi do
						if minCard-k+1 < 3 then
							overCard = 1
						else
							if leave_laizi >= count then
								addChangeCard(minCard-k,temp)
						-- dump(temp, "addChangeCard 2")
								leave_laizi = leave_laizi - count
							end
						end
					end
					if overCard == 0 then
						CardAnalysis:addTypeCards(temp,maxCard,typeCards)
					end
				else
					if max_temp < 14 then
						-- dump(temp, "add before")
						for k = 1, leave_laizi do
							if max_temp-k+1 > noLaiziList[1][1] then
								if leave_laizi >= count then
									addChangeCard(max_temp-k+1,temp)
						-- dump(temp, "addChangeCard 3")
									leave_laizi = leave_laizi - count
								end
							end
						end
						-- dump(temp, "desciption")
						-- print("leave_laizi",tostring(leave_laizi))
						if max_temp >= noLaiziList[1][1] then
							if leave_laizi > 0 then
								for k = 1, leave_laizi do
									if minCard-k < 3 then
										overCard = 1
									else
										if leave_laizi >= count then
											addChangeCard(minCard-k,temp)
								-- dump(temp, "addChangeCard 4")
											leave_laizi = leave_laizi - count
										end
									end
								end
							end
						else
							overCard = 1
						end
						if overCard == 0 then
							CardAnalysis:addTypeCards(temp,max_temp,typeCards)
						end
					end
				end
			end
		end
	else
		CardAnalysis:addTypeCards(vCards,maxCard,typeCards)
	end
end

--是不是飞机不带翅膀
function CardAnalysis:isThreeShunNoWing(tablet)
	CardAnalysis:sort(tablet)
	if #tablet%3 ~= 0 or #tablet<6 then
		return false
	end
	if table[1] and tablet[1][1] and tablet[#tablet] and tablet[#tablet][1] then
    	if  tablet[1][1] > 14 or tablet[#tablet][1] < 3 then
    		return false
    	end
	end

	--计算有多少个癞子
	self:countLaizi(tablet)
	local vCards = {}
	for i, v in pairs(tbNotLaiziCards) do
		table.insert(vCards,v)
	end
	-- dump(vCards, "isThreeShunNoWing")
	print("laiziCount",tostring(laiziCount))
	local iPos = 1
	print(tostring(vCards[iPos]["card"]),tostring(tbNotLaiziCards[#tbNotLaiziCards]["card"]))
	while vCards[iPos]["card"] >= tbNotLaiziCards[#tbNotLaiziCards]["card"] do
		if vCards[iPos] ~= nil then
			if vCards[iPos]["count"] > 3 then
				return false
			elseif vCards[iPos]["count"] < 3 then
				--拿一个癞子来变
				local changeCount = 3 - vCards[iPos]["count"]
				if laiziCount >= changeCount then
					print("isThreeShunNoWing changeCount",tostring(changeCount))
					for k=1,changeCount do
						local dataCard = {vCards[iPos]["card"],5}
						table.insert(noLaiziList,dataCard)
					end
					laiziCount = laiziCount - changeCount
				else
					return false
				end
			end

			if vCards[iPos+1] ~= nil then
				if(vCards[iPos]["card"] ~= vCards[iPos+1]["card"] + 1) then
					--拿一个癞子来变
					if laiziCount >= 3 then
						laiziCount = laiziCount - 3
						local data = {}
						data["card"] = vCards[iPos]["card"]-1
						data["count"] = 3
						table.insert(vCards,data)
						for k=1,3 do
							local dataCard = {vCards[iPos]["card"]-1,5}
							table.insert(noLaiziList,dataCard)
						end
						CardAnalysis:sortCard(vCards)
					else
						return false
					end
				end
			end
		end
		if vCards[iPos]["card"] == tbNotLaiziCards[#tbNotLaiziCards]["card"] then
			break
		end
		iPos = iPos + 1
	end

	if #noLaiziList == #tablet then
		CardAnalysis:addTypeCards(noLaiziList,noLaiziList[1][1],CARD_TYPE_THREELINE)
		return listCards
	end

	CardAnalysis:checkXLine(CARD_TYPE_THREELINE)
	if #listCards > 0 then
		return listCards
	else
		return false
	end

end

--是不是飞机带翅膀1
function CardAnalysis:isThreeShunWingOne(tablet)
	CardAnalysis:sort(tablet)
	if #tablet%4 ~= 0 then
		print("isThreeShunWingOne 牌数:",tostring(#tablet%4))
		return false
	end
	--飞机长度
	local lenPanel = #tablet/4
	print("飞机长度",tostring(lenPanel))
	if lenPanel < 2 then
		return false
	end
	--拿出非癞子牌
	self:countLaizi(tablet)
	--癞子总数
	local totalLaizi = laiziCount

	local cardTypes = {}
	local startCard = tbNotLaiziCards[1]["card"] + 2
	if startCard > 14 then
		while startCard > 14 do
			--todo
			startCard = startCard - 1
		end
	end
	-- print("panel head:",tostring(startCard))
	-- dump(countCards, "countCards")
	-- dump(table, "countCards tables")
	for i = 1, startCard - tbNotLaiziCards[#tbNotLaiziCards]["card"] + 1 do
		local data = {}
		local count_que = 0
		local isBounds = 0
		for k=1, lenPanel do
			local cards = {}
			cards["cards"] = startCard+2-i-k
			if cards["cards"] < 3 or cards["cards"] > 14 then
				isBounds = 1
				break
			end
			if countCards[cards["cards"]] == nil then
				count_que = count_que + 3
				cards["count"] = 0
			else
				if countCards[cards["cards"]] < 3 then
					count_que = count_que + (3-countCards[cards["cards"]])
				end
				cards["count"] = countCards[cards["cards"]]
			end
			-- table.insert(data,cards)
			data[#data+1] = cards
			if count_que > laiziCount then
				break
			end
		end
		-- dump(data, "data")
		print("count_que isBounds",tostring(count_que),tostring(isBounds),tostring(startCard))
		if count_que <= laiziCount and isBounds == 0 then
			local tbdata = {}
			tbdata["type_card"] = data
			tbdata["count_que"] = count_que
			-- table.insert(cardTypes,tbdata)
			cardTypes[#cardTypes+1] = tbdata
			-- dump(tbdata, "cardTypes")
		end
	end
	if #cardTypes > 0 then
		local laiziValue = Card:getLaizi()
		for k, n in pairs(cardTypes) do
			local tempCards = {}
			local tempTable = {}
			for j, m in pairs(tablet) do
				table.insert(tempTable,m)
			end
			-- dump(tempTable, "isThreeShunWingOne")
			for i, v in pairs(cardTypes[k]["type_card"]) do
				local delPos = {}
				for j, m in pairs(tempTable) do
					if m[1] == v["cards"] and m[1] ~= laiziValue then
						local dataCard = {m[1],m[2]}
						table.insert(tempCards,dataCard)
						--移除
						table.insert(delPos,j)
					end
				end
				-- dump(v, "cardTypes")
				if v["count"] < 3 then--变癞子
					local count_que = 3-v["count"]
					for j = 1, count_que do
						local dataCard = {v["cards"],5}
						table.insert(tempCards,dataCard)
					end
					--移除癞子
					for j, m in pairs(tempTable) do
						if count_que > 0 then
							if m[1] == laiziValue then
								table.insert(delPos,j)
								count_que = count_que - 1
								if count_que <= 0 then
									break
								end
							end
						end
					end
				end
				table.sort(delPos,function(a,b)
					return a > b
					end)
				-- dump(delPos, "delPos")
				for j = 1, #delPos do
					table.remove(tempTable,delPos[j])
				end
				-- dump(tempTable, "isThreeShunWingOne after remove")

			end
			for j, m in pairs(tempTable) do
				table.insert(tempCards,m)
			end
			-- dump(tempCards, "type_card"..tostring(k))
			CardAnalysis:addTypeCards(tempCards,tempCards[1][1],CARD_TYPE_PLANEWITHONE)
		end
		return listCards
	end
	return false
end

--是不是飞机带翅膀2
function CardAnalysis:isThreeShunWingTwo(tablet)
	CardAnalysis:sort(tablet)
	if #tablet%5 ~= 0 then
		print("isThreeShunWingTwo 牌数:",tostring(#tablet%5))
		return false
	end
	--飞机长度
	local lenPanel = #tablet/5
	print("飞机长度",tostring(lenPanel))
	if lenPanel < 2 then
		return false
	end
	--拿出非癞子牌
	self:countLaizi(tablet)
	--癞子总数
	local totalLaizi = laiziCount

	local cardTypes = {}
	local startCard = tbNotLaiziCards[1]["card"] + 2
	if startCard > 14 then
		while startCard > 14 do
			--todo
			startCard = startCard - 1
		end
	end
	-- print("panel head:",tostring(startCard))
	-- dump(countCards, "countCards")
	-- dump(table, "countCards tables")
	for i = 1, startCard - tbNotLaiziCards[#tbNotLaiziCards]["card"] + 1 do
		local data = {}
		local count_que = 0
		local isBounds = 0
		for k=1, lenPanel do
			local cards = {}
			cards["cards"] = startCard+2-i-k
			if cards["cards"] < 3 or cards["cards"] > 14 then
				isBounds = 1
				break
			end
			if countCards[cards["cards"]] == nil then
				print("panel",tostring(cards["cards"]))
				count_que = count_que + 3
				cards["count"] = 0
			else
				if countCards[cards["cards"]] < 3 then
					count_que = count_que + (3-countCards[cards["cards"]])
				end
				cards["count"] = countCards[cards["cards"]]
			end
			data[#data+1] = cards
			if count_que > laiziCount then
				isBounds = 1
				break
			end
		end
		-- print("count_que",tostring(count_que))
		if isBounds == 0 then
			-- dump(data, "data")
			--检查对子情况
			local countDouble = 0
			local wingCard = {}
			for n=1, #tbNotLaiziCards do
				local matchCard = false
				for k, v in pairs(data) do
					if v["cards"] == tbNotLaiziCards[n]["card"] then
						matchCard = true
						break
					end
				end
				if matchCard == false then
					if tbNotLaiziCards[n]["count"] <= 2 then
						countDouble = countDouble + 1
						count_que = count_que + (2-tbNotLaiziCards[n]["count"])
						if count_que > laiziCount then
							break
						end
						local dataCard = {}
						dataCard["card"] = tbNotLaiziCards[n]["card"]
						dataCard["count"] = tbNotLaiziCards[n]["count"]
						table.insert(wingCard,dataCard)
					else
						countDouble = countDouble + 2
						count_que = count_que + (4-tbNotLaiziCards[n]["count"])
						if count_que > laiziCount then
							break
						end
						local dataCard = {}
						dataCard["card"] = tbNotLaiziCards[n]["card"]
						dataCard["count"] = 2
						table.insert(wingCard,dataCard)
						dataCard = {}
						dataCard["card"] = tbNotLaiziCards[n]["card"]
						dataCard["count"] = 4-tbNotLaiziCards[n]["count"]
						table.insert(wingCard,dataCard)
					end
				end
			end
			print("count_que isBounds",tostring(count_que),tostring(isBounds),tostring(startCard))
			if count_que <= laiziCount then
				local tbdata = {}
				tbdata["type_card"] = data
				tbdata["wing_card"] = wingCard
				tbdata["count_que"] = count_que
				cardTypes[#cardTypes+1] = tbdata
				-- dump(tbdata, "cardTypes")
			end
		end
	end

	if #cardTypes > 0 then
		local laiziValue = Card:getLaizi()
		for k, n in pairs(cardTypes) do
			local tempCards = {}
			-- dump(n, "isThreeShunWingOne")
			--机体
			for i, v in pairs(cardTypes[k]["type_card"]) do
				for j, m in pairs(tablet) do
					if m[1] == v["cards"] and m[1] ~= laiziValue then
						local dataCard = {m[1],m[2]}
						table.insert(tempCards,dataCard)
					end
				end
				-- dump(v, "cardTypes")
				if v["count"] < 3 then--变癞子
					local count_que = 3-v["count"]
					for j = 1, count_que do
						local dataCard = {v["cards"],5}
						table.insert(tempCards,dataCard)
					end
				end
				-- dump(tempTable, "isThreeShunWingOne after remove")
			end
			--翅膀
			for i, v in pairs(cardTypes[k]["wing_card"]) do
				-- dump(v, "wing_card "..tostring(k))
				local count_need = v["count"]
				for j, m in pairs(tablet) do
					if m[1] == v["card"] and m[1] ~= laiziValue then
						local dataCard = {m[1],m[2]}
						table.insert(tempCards,dataCard)
						count_need = count_need - 1
						if count_need <= 0 then
							break
						end
					end
				end
				if v["count"] < 2 then--变癞子
					local count_que = 2-v["count"]
					for j = 1, count_que do
						local dataCard = {v["card"],5}
						table.insert(tempCards,dataCard)
					end
				end
			end
			--翅膀不够
			if #cardTypes[k]["wing_card"] < lenPanel then
				for j = 1, (lenPanel-#cardTypes[k]["wing_card"]) do
					for k = 1, 2 do
						local dataCard = {laiziValue,5}
						table.insert(tempCards,dataCard)
					end
				end
			end
			-- dump(tempCards, "type_card"..tostring(k))
			CardAnalysis:addTypeCards(tempCards,tempCards[1][1],CARD_TYPE_PLANEWITHWING)
		end
		return listCards
	end
	return false
end



--是不是boom
function CardAnalysis:isBoom(tablet)
	if #tablet == 2 then
		if tablet[1][1] > 3 or tablet[2][1] > 3 then
			return false
		end
		CardAnalysis:addTypeCards(tablet,tablet[1][1],CARD_TYPE_BOMB)
		return listCards
	end
	if #tablet == 4 then
		--拿出非癞子牌
		self:countLaizi(tablet)
		if #tbNotLaiziCards > 1 then
			return false
		end
		if laiziCount >= 4 then--癞子炸弹
			CardAnalysis:addTypeCards(tablet,tablet[1][1],CARD_TYPE_BOMB)
			-- dump(listCards,"isBoom")
			return listCards
		end
		local tempCards = {}
		for i, v in pairs(tablet) do
			if v[1] == tbNotLaiziCards[1]["card"] then
				table.insert(tempCards,v)
			else
				local dataCard = {tbNotLaiziCards[1]["card"],5}
				table.insert(tempCards,dataCard)
			end
		end
		CardAnalysis:addTypeCards(tempCards,tempCards[1][1],CARD_TYPE_BOMB)
		return listCards
	end

	return false
end


--是不是4带2
function CardAnalysis:isBoomWithTwo(tablet)
	if #tablet ~= 6 then
		return false
	end

	CardAnalysis:sort(tablet)
	--拿出非癞子牌
	self:countLaizi(tablet)
	if #tbNotLaiziCards > 3 then
		return false
	end
	local cardLaizi = Card:getLaizi()
	local tempCards = {}
	if laiziCount == 4 then--癞子炸弹
		CardAnalysis:addTypeCards(tablet,cardLaizi,CARD_TYPE_FOURWITHTWO)
	end
	for i, v in pairs(tbNotLaiziCards) do
		if v["count"] + laiziCount >= 4 then
			local needCount = 4
			tempCards = {}
			local tbPos = {}
			for k=1,#tablet do
				table.insert(tbPos,1)
			end
			--本身有多少张
			for k, m in pairs(tablet) do
				if m[1] == v["card"] then
					table.insert(tempCards,m)
					needCount = needCount - 1
					tbPos[k] = 0
				end
			end
			--还需要癞子变一下
			if needCount > 0 then
				for k, m in pairs(tablet) do
					if m[1] == cardLaizi then
						local dataCard = {v["card"],5}
						table.insert(tempCards,dataCard)
						needCount = needCount - 1
						tbPos[k] = 0
						if needCount == 0 then
							break
						end
					end
				end
			end
			if #tbPos > 0 then
				dump(tempCards, "desciption")
				for k, m in pairs(tbPos) do
					if m == 1 then
						print("pos"..tostring(k),tostring(k))
						table.insert(tempCards,tablet[k])
					end
				end
			end
			CardAnalysis:addTypeCards(tempCards,v["card"],CARD_TYPE_FOURWITHTWO)
		end
	end

	if #listCards > 0 then
		return listCards
	else
		return false
	end

end


--是不是4带2对
function CardAnalysis:isBoomWithFour(tablet)
	if #tablet ~= 8 then
		return false
	end
	CardAnalysis:sort(tablet)
	--拿出非癞子牌
	self:countLaizi(tablet)
	if #tbNotLaiziCards > 3 then
		return false
	end
	local cardLaizi = Card:getLaizi()
	local tempCards = {}
	--癞子炸弹
	if laiziCount == 4 and #tbNotLaiziCards == 2 then
		CardAnalysis:addTypeCards(tablet,cardLaizi,CARD_TYPE_FOURWITHFOUR)
	end

	for i, v in pairs(tbNotLaiziCards) do
		local useLaizi = 0
		if v["count"] + laiziCount >= 4 then
			local needCount = 4
			local isBounds = 0
			tempCards = {}
			local tbPos = {}
			for k=1,#tablet do
				table.insert(tbPos,1)
			end
			--本身有多少张
			for k, m in pairs(tablet) do
				if m[1] == v["card"] then
					table.insert(tempCards,m)
					needCount = needCount - 1
					tbPos[k] = 0
				end
			end
			--还需要癞子变一下
			if needCount > 0 then
				for k, m in pairs(tablet) do
					if m[1] == cardLaizi then
						local dataCard = {v["card"],5}
						table.insert(tempCards,dataCard)
						needCount = needCount - 1
						tbPos[k] = 0
						useLaizi = useLaizi + 1
						if useLaizi > laiziCount then
							isBounds = 1
							break
						end
						if needCount == 0 then
							break
						end
					end
				end
			end
			-- dump(tempCards, "isBoomWithFour 4")
			if isBounds == 0 then
				--对子翅膀
				for k, m in pairs(tbNotLaiziCards) do
					if m["card"] ~= v["card"] then
						if m["count"] > 2 then
							isBounds = 1
							break
						end
						needCount = 2
						--本身有多少张
						for j, d in pairs(tablet) do
							if d[1] == m["card"] then
								table.insert(tempCards,d)
								needCount = needCount - 1
								tbPos[j] = 0
							end
						end
						--还需要癞子变一下
						if (laiziCount-useLaizi) >= needCount then
							if needCount > 0 then
								for j, d in pairs(tablet) do
									if d[1] == cardLaizi then
										if tbPos[j] > 0 then
											local dataCard = {m["card"],5}
											table.insert(tempCards,dataCard)
											needCount = needCount - 1
											tbPos[j] = 0
											useLaizi = useLaizi + 1
											if useLaizi > laiziCount then
												isBounds = 1
												break
											end
											if needCount == 0 then
												break
											end
										end
									end
								end
							end
						else
							isBounds = 1
							break
						end
					end
				end
				if isBounds == 0 then
					if #tbPos > 0 then
						-- dump(tempCards, "desciption")
						for k, m in pairs(tbPos) do
							if m == 1 then
								print("pos"..tostring(k),tostring(k))
								table.insert(tempCards,tablet[k])
							end
						end
					end
					CardAnalysis:addTypeCards(tempCards,v["card"],CARD_TYPE_FOURWITHFOUR)
				end
			end
		end
	end

	if #listCards > 0 then
		return listCards
	else
		return false
	end
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