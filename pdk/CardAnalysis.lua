--------------------- COMMON DATA BEG @Jhao --------------------- 
-- 数据常量

local CARD_VALUE	= 1 -- 牌数值
local CARD_KIND		= 2 -- 牌花色
local CARD_X		= 3 -- 牌桌上的x坐标
local CARD_Y		= 4 -- 牌桌上的x坐标
local CARD_SELETED	= 5 -- 选中状态

local CARD_KIND_DIAMOND	= 0 -- 方块
local CARD_KIND_CLUB	= 1 -- 梅花
local CARD_KIND_HEART	= 2 -- 红心
local CARD_KIND_SPADE	= 3 -- 黑桃
local CARD_KIND_JOKER	= 4 -- 王
--------------------- COMMON DATA END @Jhao --------------------- 

local	CARD_TYPE_MUST 			= -1	-- 有牌出
local	CARD_TYPE_ERROR 		= 0		-- 牌型错误
local	CARD_TYPE_ONE			= 1		-- 单张
local	CARD_TYPE_TWO			= 2		-- 对子
local	CARD_TYPE_THREE			= 3		-- 单三张
local	CARD_TYPE_ONELINE		= 4		-- 顺子
local	CARD_TYPE_TWOLINE		= 5		-- 连对
local	CARD_TYPE_THREEWITHONE	= 7		-- 三带一	
local	CARD_TYPE_THREEWITHTWO	= 8		-- 三带二
local   CARD_TYPE_PLANE			= 9  	-- 飞机
local	CARD_TYPE_BOMB			= 11	-- 4个(炸弹)

local Card = require("pdk.Card")
require("config")

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
	if not talbet then return false end

	local main_card = self:isType(type, talbet)
	if not main_card then 
		return false 
	end

	print("getsuitcard @@@@@@@@@@@@@@@@@@ fenlei,  type:::::", type, "main_card:", main_card)

	self:fenLei()
	local m_main
	if type == CARD_TYPE_ONE then
		local cards,m_main = self:single(main_card, main_card_arr)
		if cards ~= false then
			return cards, m_main 
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
		print("enter  shun three with one...")
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
		local cards, _main_card  = self:shunDouble(main_card,#talbet,main_card_arr)
		if  cards ~= false then
			return cards, _main_card
		else
			cards, main_card = self:boom(3, main_card_arr)
			if cards ~= false then
				return cards,main_card
			end
		end

		return false
	end

	if type == CARD_TYPE_PLANE then
		-- local cards,main_card = self:shunThreeWithOne(main_card,#talbet,main_card_arr)
		local cards,_main_card = self:planee(main_card,#talbet,main_card_arr)
		if  cards ~= false  then
			return cards,_main_card
		else
			cards, main_card = self:boom(3, main_card_arr)
			if cards ~= false then
				return cards,main_card
			end
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
			local real_value = USER_INFO["four_rank"][i][1]+100
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
function   CardAnalysis:double(max_value, main_card)
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
			local real_value = USER_INFO["four_rank"][i][1]+100
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
			local real_value = USER_INFO["four_rank"][i][1]+100
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

	print("getSuitCard main_card size:" .. tostring(#main_card))
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
			local real_value = USER_INFO["four_rank"][i][1]+100
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
function CardAnalysis:shunDouble(max_value,len,main_card)
	local all = {}

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

	local mount  = len/2
	self:sort(all)
	local start = false
	local count = 0
	local cards = {}
	local doubleFlushMaxValue = nil
	-- dump(all, "shunDouble all")
	for i = #all,2,-2 do 
		if start == false then
			-- print("shunDouble start max_value-mount+1, ", max_value-mount+1, 
			-- 	"main_card[all[i][1] + mount - 1]", main_card[all[i][1] + mount - 1], i)
			if all[i][1] > max_value-mount+1 and not main_card[all[i][1] + mount - 1] then
				-- print("{{{{{{{{{{{{{{{{{{{{{{{{{{", i)
				start = true
				-- dump(all[i], "shunDouble start")
				table.insert(cards,{all[i][1],all[i][2]})
				table.insert(cards,{all[i-1][1],all[i-1][2]})
				doubleFlushMaxValue = all[i][1]
				count = 1
			end
		else
			if  all[i][1] == doubleFlushMaxValue + 1 then
				doubleFlushMaxValue     = all[i][1]
				count     = count + 1
				table.insert(cards,{all[i][1],all[i][2]})
				table.insert(cards,{all[i-1][1],all[i-1][2]})
			else
				count = 0
				cards = {}
				if not  main_card[all[i][1] + mount - 1] then
					start = true

					doubleFlushMaxValue     = all[i][1]
					count     = count + 1

					-- dump(all[i], "shunDouble restart")
					-- dump(main_card, "main_card"..tostring(all[i][1] + mount - 1))
					table.insert(cards,{all[i][1],all[i][2]})
					table.insert(cards,{all[i-1][1],all[i-1][2]})
				end
			end
		end

		if count == mount then
			dump(cards,"shunDouble cards")
			return cards,cards[#cards][1]
		end
	end

	dump(cards,"shunDouble four")
	dump(main_card,"shunDouble main_card:"..tostring(#USER_INFO["four_rank"]))

	if USER_INFO["four_rank"] then
		for i = #USER_INFO["four_rank"], 4, -4  do
			-- local value      = USER_INFO["four"][i]
			local real_value = USER_INFO["four_rank"][i][1]+100
			print("shunDouble real_value",tostring(real_value))
			if not main_card[real_value] then
				return {{USER_INFO["four_rank"][i][1],USER_INFO["four_rank"][i][2]},{USER_INFO["four_rank"][i-1][1],USER_INFO["four_rank"][i-1][2]},{USER_INFO["four_rank"][i-2][1],USER_INFO["four_rank"][i-2][2]},{USER_INFO["four_rank"][i-3][1],USER_INFO["four_rank"][i-3][2]}},real_value
			end
		end
	end

	return false
end

--获得飞机不带
function CardAnalysis:shunThree(max_value,len,main_card)
	if not table then return false end

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
			local real_value = USER_INFO["four_rank"][i][1]+100
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
	-- if not table then return false end

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

	dump(USER_INFO["three"], "shun ****************")
	dump(all, "shun all ****************")
	dump(main_card, "main_card ****************")

	local mount  = len/4
	self:sort(all)
	local start = false
	local count = 0
	local cards = {}
	local tmp_v = nil 
	local del_array = {}
	local main
	local flag = 0

	print("@@@@@@@@@@@@:mount:", mount, "max_value:", max_value, "len:", len)

	for i = #all,3,-3 do 
		if start == false then
			if all[i][1] > max_value - mount + 1 and not  main_card[all[i][1] + mount - 1]   then
				start = true
				table.insert(cards,{all[i][1],all[i][2]})
				table.insert(cards,{all[i-1][1],all[i-1][2]})
				table.insert(cards,{all[i-2][1],all[i-2][2]})
				del_array[all[i][1]] = 1
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

	dump(all, "all ********************")

	print("%%%%%%%%%%%%%%%%flag == ", flag)

	local one_mout = 0
	if flag== 1 then
		for i=#USER_INFO["one_rank"],1,-1 do 

			if(del_array[USER_INFO["one_rank"][i][1]] ~= 1 ) then
	
				table.insert(cards,{USER_INFO["one_rank"][i][1],USER_INFO["one_rank"][i][2]})
				one_mout = one_mout + 1
				if (one_mout == mount ) then
					print("one rank.....", cards, main)
					return cards,main
				end
			end
		end

		for i=#USER_INFO["double_rank"],1,-1 do 
			if(del_array[USER_INFO["double_rank"][i][1]] ~= 1 ) then

				table.insert(cards,{USER_INFO["double_rank"][i][1],USER_INFO["double_rank"][i][2]})
				one_mout = one_mout + 1
				if (one_mout == mount ) then
					print("double rank.....", cards, main)
					return cards,main
				end
			end
		end

		for i=#USER_INFO["three_rank"],1,-1 do 
			if(del_array[USER_INFO["three_rank"][i][1]] ~= 1 ) then

				table.insert(cards,{USER_INFO["three_rank"][i][1],USER_INFO["three_rank"][i][2]})
				one_mout = one_mout + 1
				if (one_mout == mount ) then
					print("three rank.....", cards, main)
					return cards,main
				end
			end
		end
	end

	if USER_INFO["four_rank"] then
		for i = #USER_INFO["four_rank"],4,-4  do
			local value      = USER_INFO["four_rank"][i]
			local real_value = USER_INFO["four_rank"][i][1]+100
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



-- 获取手牌中的飞机
-- @max_value 最大值
-- @len 牌数量
-- @main_card 牌
function CardAnalysis:planee(max_value, len, main_card)
	local tripleSet = {} -- 保存三条牌型的数据集合
	local del_array = {}
	local mainCard  = nil

	if #USER_INFO["cards"] < len then
		return false
	end

	local paramPlaneNum = len / 5 -- 依据牌数长度判断飞机数量

	local main_value = max_value
	for key, v in pairs(main_card) do
		print("kkkkkkkk", key, "value:", v)
		if key > max_value then
			main_value = key
		end
	end

	print("planee max_value",tostring(main_value), "len:", len)
	dump(main_card, "planee main_card ")
	for cardValue, card in pairs(USER_INFO["three"]) do
		if card[1][1] >= 3 and card[1][1] <= 14 and card[1][1] > main_value then
			table.insert(tripleSet, {card[1][1], card[1][2]})
			table.insert(tripleSet, {card[2][1], card[2][2]})
			table.insert(tripleSet, {card[3][1], card[3][2]})
			del_array[card[1][1]] = 1
		end
	end

	dump(USER_INFO["four_rank"], "planee four")

	for cardValue, card in pairs(USER_INFO["four"]) do
		if card[1][1] >= 3 and card[1][1] <= 14 and card[1][1] > main_value then
			table.insert(tripleSet, {card[1][1], card[1][2]})
			table.insert(tripleSet, {card[2][1], card[2][2]})
			table.insert(tripleSet, {card[3][1], card[3][2]})
			del_array[card[1][1]] = 1
		end
	end

	dump(tripleSet, "tripleSet")
	if #tripleSet < 6 then
		if USER_INFO["four_rank"] then
			for i = #USER_INFO["four_rank"],4,-4  do
				local real_value = USER_INFO["four_rank"][i][1]+100
				if not main_card[real_value] then
					return {{USER_INFO["four_rank"][i][1],USER_INFO["four_rank"][i][2]},{USER_INFO["four_rank"][i-1][1],USER_INFO["four_rank"][i-1][2]},{USER_INFO["four_rank"][i-2][1],USER_INFO["four_rank"][i-2][2]},{USER_INFO["four_rank"][i-3][1],USER_INFO["four_rank"][i-3][2]}},real_value
				end
			end
		end
		return false
	end

	table.sort(tripleSet, function(_a, _b)
		return _a[1] > _b[1]
	end)

	local step = 3
	local index = nil
	local count = 1
	for i = 1, #tripleSet, step do
		print("planee i", tostring(i))
		if i + step < #tripleSet then
			if tripleSet[i][1] == tripleSet[i + step][1] + 1 then -- 判断三条是否连续
				if index == nil then
					index = i
				end
				if index > i then
					index = i
				end
				count = count + 1
				print("planee ",tostring(tripleSet[i][1]),tostring(tripleSet[i + step][1]),tostring(count),tostring(index))
				if count == len/5 then
					break
				end
			else
				print("planee 2 ",tostring(tripleSet[i][1]),tostring(tripleSet[i + step][1]))
				index = nil
				count = 1
			end
		end
	end
	if index == nil then -- 没有飞机
		print("     planee index == nil ")
		return false
	end

	-- 飞机长度判断
	if count < paramPlaneNum then
		return false
	end

-- m Jhao.
	local result = {}
	for i = index, paramPlaneNum*2+index+1, 1 do
		print("result index ",tostring(i))
		table.insert(result, {tripleSet[i][1], tripleSet[i][2]})
		-- table.insert(result, {tripleSet[(i - 1) * step + 2][1], tripleSet[(i - 1) * step + 2][2]})
		-- table.insert(result, {tripleSet[(i - 1) * step + 3][1], tripleSet[(i - 1) * step + 3][2]})
	end

	dump(result, "planee result "..tostring(paramPlaneNum))

	print("     #result / step < paramPlaneNum ", #result / step < paramPlaneNum )
	if (#result / step) < paramPlaneNum then -- 手牌中的飞机数量不足
		print("     #result / step < paramPlaneNum ", #result / step < paramPlaneNum )
		return false
	end

	local mainCard = result[#result][1]
	local wingNum = paramPlaneNum * 2 -- 带牌数量
	local tmp = #USER_INFO["cards"] - #result 
	if tmp < wingNum then -- 手牌剩余牌数不足
		wingNum = tmp
	end

	if wingNum == 0 then
		print("return wing Num == 0")
		return result, mainCard
	end

	dump(USER_INFO["one_rank"], "<<<<<<<<<<<<<< one_rank <<<<<<<<<<<<<<")
	local count = 0
	for i=#USER_INFO["one_rank"],1,-1 do 
		if(del_array[USER_INFO["one_rank"][i][1]] ~= 1 ) then
			print("one _ rank:    count:", count, "wingNum:", wingNum)
			table.insert(result,{USER_INFO["one_rank"][i][1],USER_INFO["one_rank"][i][2]})
			count = count + 1
			if count == wingNum then
				print("one _ rank ----------------")
				return result, mainCard
			end
		end
	end

	dump(USER_INFO["double_rank"], "<<<<<<<<<<<<<< double_rank <<<<<<<<<<<<<<")
	for i=#USER_INFO["double_rank"],1,-1 do 
		if(del_array[USER_INFO["double_rank"][i][1]] ~= 1 ) then
			print("double _ rank:    count:", count, "wingNum:", wingNum)
			table.insert(result,{USER_INFO["double_rank"][i][1],USER_INFO["double_rank"][i][2]})
			count = count + 1
			if count == wingNum then
				print("double _ rank ----------------")
				return result, mainCard
			end
		end
	end

	dump(USER_INFO["three_rank"], "<<<<<<<<<<<<<< three_rank <<<<<<<<<<<<<<")
	for i=#USER_INFO["three_rank"],1,-1 do 
		if(del_array[USER_INFO["three_rank"][i][1]] ~= 1 ) then
			print("three _ rank:    count:", count, "wingNum:", wingNum)
			table.insert(cards,{USER_INFO["three_rank"][i][1],USER_INFO["three_rank"][i][2]})
			count = count + 1
			if count == wingNum then
				print("three _ rank ----------------")
				return result, mainCard
			end
		end
	end

	print("                   enenenenenenenenedddddddddd  false")
	return false
end



--获得飞机带二
function CardAnalysis:shunThreeWithTwo(max_value,len,main_card )
	-- if not table then return false end
	print("shunThreeWithTwo",tostring(#USER_INFO["cards"]),tostring(len))
	if #USER_INFO["cards"] < len then
		return false
	end

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
	dump(USER_INFO["three"], "shunThreeWithTwo")

	local mount  = len/5
	self:sort(all)
	local start = false
	local count = 0
	local cards = {}
	local tmp_v = nil 
	local flag  = 0
	local main
	local del_array = {}

	dump(USER_INFO["three_rank"], "shunThreeWithTwo all")
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
		-- for i=#USER_INFO["double_rank"],2,-2 do 
		-- 	if(del_array[USER_INFO["double_rank"][i][1]] ~= 1 ) then

		-- 		table.insert(cards,{USER_INFO["double_rank"][i][1],USER_INFO["double_rank"][i][2]})
		-- 		table.insert(cards,{USER_INFO["double_rank"][i-1][1],USER_INFO["double_rank"][i-1][2]})
		-- 		one_mout = one_mout + 1
		-- 		if (one_mout == mount ) then
		-- 			return cards,main
		-- 		end
		-- 	end
		-- end

		for i=#USER_INFO["three_rank"],3,-3 do 
			if(del_array[USER_INFO["three_rank"][i][1]] ) then

				-- table.insert(cards,{USER_INFO["three_rank"][i][1],USER_INFO["three_rank"][i][2]})
				-- table.insert(cards,{USER_INFO["three_rank"][i-1][1],USER_INFO["three_rank"][i-1][2]})
				one_mout = one_mout + 1
				if (one_mout == mount ) then
					one_mout = 0
					for k = #USER_INFO["one_rank"], 1, -1 do
						table.insert(cards,{USER_INFO["one_rank"][k][1],USER_INFO["one_rank"][k][2]})
						one_mout = one_mout + 1
						if one_mout == mount*2 then
							return cards,main
						end
					end
					for i = #USER_INFO["double_rank"], 2,-2 do 
						print("i", tostring(i))
						-- if(del_array[USER_INFO["double_rank"][i][1]]) then

							table.insert(cards,{USER_INFO["double_rank"][i][1],USER_INFO["double_rank"][i][2]})
							one_mout = one_mout + 1
							print("one_mout", tostring(one_mout), "mount", tostring(mount))
							if (one_mout == mount*2 ) then
								return cards,main
							end
							table.insert(cards,{USER_INFO["double_rank"][i-1][1],USER_INFO["double_rank"][i-1][2]})
							one_mout = one_mout + 1
							if (one_mout == mount*2 ) then
								return cards,main
							end
						-- end
					end
					return cards,main
				end
			end
		end
	end

	print("shunThreeWithTwo 3", tostring(one_mout))
	if USER_INFO["four_rank"] then
		for i = #USER_INFO["four_rank"],4,-4  do
			local value      = USER_INFO["four_rank"][i]
			local real_value = USER_INFO["four_rank"][i][1]+100
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

	print("shunThreeWithTwo 10")

	return false
end


--获得四带二或者四带一
function CardAnalysis:fourWith(main_card)
	if not table then return false end


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
	dump(USER_INFO["four_rank"], "boom------------")
	print(">>>>>>>>>>>>>>>>>>._--", main_value)

	if USER_INFO["four_rank"] then
		for i = #USER_INFO["four_rank"],4,-4  do
			local value      = USER_INFO["four_rank"][i]
			local real_value = USER_INFO["four_rank"][i][1]
			if not main_card[real_value] and USER_INFO["four_rank"][i][1] > main_value then
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

	dump(USER_INFO["one"], "fenlei--------- one")
	dump(USER_INFO["double"], "fenlei--------- double")
	dump(USER_INFO["three"], "fenlei--------- three")
	dump(USER_INFO["four"], "fenlei--------- four")
	dump(USER_INFO["one_rank"], "fenlei--------- one_rank")
	dump(USER_INFO["double_rank"], "fenlei--------- double_rank")
	dump(USER_INFO["three_rank"], "fenlei--------- three_rank")
	dump(USER_INFO["four_rank"], "fenlei--------- four_rank")

end

--对比牌型
function CardAnalysis:isType(_type,talbet)
	if talbet == nil then return false end

	local TYPES_TO_FUNC ={}
	TYPES_TO_FUNC[CARD_TYPE_ONE]			= self.isOne			-- 单牌
	TYPES_TO_FUNC[CARD_TYPE_TWO]			= self.isDouble			-- 对子
	TYPES_TO_FUNC[CARD_TYPE_THREE]			= self.isThree			-- 三条
	TYPES_TO_FUNC[CARD_TYPE_ONELINE]		= self.isShun			-- 顺子
	TYPES_TO_FUNC[CARD_TYPE_TWOLINE]		= self.isDoubleShun		-- 双顺
	TYPES_TO_FUNC[CARD_TYPE_THREEWITHONE]	= self.isThreeWithOne	-- 三带一
	TYPES_TO_FUNC[CARD_TYPE_THREEWITHTWO]	= self.isThreeWithTwo	-- 三带二
	TYPES_TO_FUNC[CARD_TYPE_PLANE]			= self.isPlane			-- 飞机
	TYPES_TO_FUNC[CARD_TYPE_BOMB]			= self.isBoom			-- 炸弹

	for cardKind, func in pairs(TYPES_TO_FUNC) do
		if cardKind == _type then
			print("check type........ isType")
			local main_card = func(self, talbet)
			if  main_card then 
				return main_card 
			end
		end
	end

	return false

end


-- 获得牌型
-- 	@return: 牌型，最大牌，牌数量
function  CardAnalysis:getType(talbet)
	dump(talbet, " ====================================== CardAnalysis:getType")
	local TYPES_TO_FUNC ={}
	TYPES_TO_FUNC[CARD_TYPE_ONE]			= self.isOne			-- 单牌
	TYPES_TO_FUNC[CARD_TYPE_TWO]			= self.isDouble			-- 对子
	TYPES_TO_FUNC[CARD_TYPE_THREE]			= self.isThree			-- 三条
	TYPES_TO_FUNC[CARD_TYPE_ONELINE]		= self.isShun			-- 顺子
	TYPES_TO_FUNC[CARD_TYPE_TWOLINE]		= self.isDoubleShun		-- 双顺
	TYPES_TO_FUNC[CARD_TYPE_THREEWITHONE]	= self.isThreeWithOne	-- 三带一
	TYPES_TO_FUNC[CARD_TYPE_THREEWITHTWO]	= self.isThreeWithTwo	-- 三带二
	TYPES_TO_FUNC[CARD_TYPE_PLANE]			= self.isPlane			-- 飞机
	TYPES_TO_FUNC[CARD_TYPE_BOMB]			= self.isBoom			-- 炸弹

	for cardType, func in pairs(TYPES_TO_FUNC) do
		local main_card = func(self, talbet)
		if main_card then
			return cardType, main_card, #talbet
		end
	end

	-- original --
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

	main_card,length = self:isPlane(talbet)
	if  main_card then
		return CARD_TYPE_PLANE,main_card,#talbet
	end

	main_card = self:isBoom(talbet)
	if  main_card then
		print("getType isBoom")
		dump(talbet, "getType")
		return CARD_TYPE_BOMB,main_card,#talbet
	end

end

-- 是不是单牌
function CardAnalysis:isOne(table)
	if table == nil then return false end

	if #table == 1 then
		return table[#table][CARD_VALUE]
	end
	return false
end

--是不是对子
function CardAnalysis:isDouble(table)
	if not table then return false end

	if (#table == 2) and (table[1][CARD_VALUE] == table[2][CARD_VALUE]) then
		return table[1][CARD_VALUE]
	end

	return false
end

--是不是3张
function CardAnalysis:isThree(table)
	if not table then return false end

	if #table ~= 3 then	
		return false 
	end

	local cardValue = table[1][CARD_VALUE]

	for idx, card in pairs(table) do
		if card[CARD_VALUE] ~= cardValue then 
			return false 
		end
	end

	return cardValue
end

--是不是3张带一
function CardAnalysis:isThreeWithOne(table)
	if not table then return false end

	if #table ~= 4 then 
		return false 
	end

	local tmp = {}
	for key,value in pairs(table) do
		if not tmp[value[CARD_VALUE]] then
			tmp[value[CARD_VALUE]] = 0
		end
		tmp[value[CARD_VALUE]] = tmp[value[CARD_VALUE]] + 1
	end

	for key,value in pairs(tmp) do
		if(value == 3) then
			return key
		end
	end

	return false
end


--是不是3张带2
function CardAnalysis:isThreeWithTwo(tablet)
	if not tablet then return false end

	if #tablet ~= 5 then 
		return false 
	end

	local tmp = {}
	for key,value in pairs(tablet) do
		if not tmp[value[CARD_VALUE]] then 
			tmp[value[CARD_VALUE]] = 0 
		end

		tmp[value[CARD_VALUE]] = tmp[value[CARD_VALUE]] + 1
	end

	for cardValue, count in pairs(tmp) do
		if(count== 3) or count == 4 then 
			return cardValue 
		end
	end

	dump(tmp, "isThreeWithTwo")
	return false
end

--是不是单顺子
function CardAnalysis:isShun(tablet)
	if not tablet then return false end

	print("@@@@@@@@@@@@@@@@@@@@ is shun --------- :", #tablet)

	CardAnalysis:sort(tablet)

	if #tablet<5 or not tablet then 
		print("@@@@@@@@@@@@@@@ is shun ----: < 5")
		return false 
	end

	for idx, card in pairs(tablet) do
		if (card[CARD_VALUE] > 14) or (card[CARD_VALUE] < 3) then 
			print("@@@@@@@@@@@@@@@ is shun ---- idx:", idx)
			return false 
		end
	end

	for i=1, #tablet-1 do 
		if(tablet[i][CARD_VALUE] ~= tablet[i+1][CARD_VALUE] + 1) then
			print("@@@@@@@@@@@@@@  is shun ====-----: out value: idx =", i)
			return false
		end
	end

	return tablet[1][CARD_VALUE], #tablet
end

--是不是双顺(连对)
function CardAnalysis:isDoubleShun(tablet)
	if tablet == nil then return false end

	CardAnalysis:sort(tablet) -- 倒序
	dump(tablet, "function CardAnalysis:isDoubleShun(tablet)")
	-- 闭区间
	local CARD_MIX_NUM		= 4		-- 最少牌数
	local CARD_MAX_NUM		= 16	-- 最大牌数
	local CARD_MIX_VALUE	= 3		-- 最小牌值
	local CARD_MAX_VALUE	= 14	-- 最大牌值

	-- local stepValue = 1 -- 顺子
	local stepValue = 2 -- 连对

	-- 基础信息检查
	if ((#tablet) % stepValue ~= 0) or 
		(#tablet > CARD_MAX_NUM) or (#tablet < CARD_MIX_NUM) or			-- 数量区间
		(tablet[#tablet][CARD_VALUE] > CARD_MAX_VALUE) or (tablet[1][CARD_VALUE] < CARD_MIX_VALUE) then	-- 牌值区间
		return false 
	end

	for idx = 1, #tablet, stepValue do
		local curCardValue = tablet[idx][CARD_VALUE]

		-- 同牌值检查
		for	begPos = idx+1, stepValue do 
			if tablet[begPos][CARD_VALUE] ~= curCardValue then 
				return false 
			end
		end

		-- 差值校验
		if tablet[idx-stepValue] ~= nil then
			if tablet[idx][CARD_VALUE] ~= (tablet[idx-stepValue][CARD_VALUE]-1) then 
				return false 
			end
		end
	end

	print("this is shun double")

	return tablet[1][CARD_VALUE], #tablet
end

--是不是飞机
function CardAnalysis:isPlane(tablet)
	print("------------------------- is plane")
	if not tablet then return false end

	local paramPlaneNum = #tablet / 5

	CardAnalysis:sort(tablet)

	local tmp = {}
	local tmp_value = nil
	local main_card
	local three_value = {}
	for key,value in pairs(tablet) do
		if not tmp[value[1]] then
			tmp[value[1]] = 0
		end

		-- ori
		-- tmp[value[1]] = tmp[value[1]] + 1
		-- if tmp[value[1]] == 3 then
		-- 	table.insert(three_value,value[1])
		-- end
		-- if tmp[value[1]] > 3 then
		-- 	print("@@@@@@@@@@@@@@@@@@ tmp[value] > 3", value[1])
		-- 	return false
		-- end

		-- m 2016-11-14 11:08:54 Jhao
		tmp[value[1]] = tmp[value[1]] + 1
		if tmp[value[1]] >= 3 then
			local insertFlag = true
			for idx, cardValue in pairs(three_value) do
				if cardValue == value[1] then
					insertFlag = false
				end
			end
			if insertFlag then
				table.insert(three_value, value[1])
			end
		end
	end

	dump(three_value, "~~~~~~~~~~~~~~~~ three_value")

	print("############### three_value:", #three_value)
	if #three_value < 2 then
		return false
	end
	
	local CARD_MIX_VALUE = 3 	-- 最小牌值
	local CARD_MAX_VALUE = 14	-- 最大牌值

	for k, value in pairs(three_value) do
		if value > CARD_MAX_VALUE or value < CARD_MIX_VALUE then
			print("@@@@@@@@@@@@@@@@@@@@ out of value *****")
			return false
		end
	end

	local index = nil
	for i=2,#three_value do
		if three_value[i-1] - 1 == three_value[i] then
			local tmpIdx = i-1
			if index == nil then
				index = tmpIdx
			end
			if index > tmpIdx then
				index = tmpIdx
			end
		end
	end

	-- local mainCard = three_value[index][1]

	if USER_INFO ~= nil then
		if USER_INFO["cards"] ~= nil then
			if #USER_INFO["cards"] == #tablet then
				return three_value[index],#tablet
			-- else
			-- 	if #tablet > 10 then
			-- 		return false
			-- 	end
			end
		end
	end


	print("return three_value[index],#tablet:",#tablet, three_value[index])
	return three_value[index],#tablet
end

--是不是boom
function CardAnalysis:isBoom(table)
	if not table then return false end

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


--排序
function  CardAnalysis:sort(tablet)
	if not tablet then return false end

	table.sort(tablet,function(a,b) 
        if( a[2] == 4 and b[2] == 4) then
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


--[[ *****************************************
     *************** 跑得快逻辑 **************
     ***************************************** ]]

-- @brief:鉴别手牌中是否有指定牌型
-- @date:2016-11-7
-- @author:Jhao.
-- 		@param:_cards 		牌集合 (需要逆序排列)
-- 		@param:_type  		牌型
-- 		@patam:_cmpValue	牌值
--
-- 		@return:
-- 			符合牌型的的牌集
function CardAnalysis:hasType(_cards, _type, _cmpValue)
	if not _cards or #_cards <= 0 then 
		return nil 
	end

	local CARD_TYPES = {}
	CARD_TYPES[CARD_TYPE_ONE]			= self.has_CARD_TYPE_ON	-- = 1		-- 单张
	CARD_TYPES[CARD_TYPE_TWO]			= self.has_CARD_TYPE_TWO	-- = 2		-- 对子
	CARD_TYPES[CARD_TYPE_THREE]			= self.has_CARD_TYPE_THREE-- = 3		-- 单三张
	CARD_TYPES[CARD_TYPE_ONELINE]		= self.has_CARD_TYPE_ONELINE-- = 4		-- 顺子
	CARD_TYPES[CARD_TYPE_TWOLINE]		= self.has_CARD_TYPE_TWOLINE	-- = 5		-- 连对
	CARD_TYPES[CARD_TYPE_THREEWITHONE]	= self.has_CARD_TYPE_THREEWITHONE-- = 7		-- 三带一	
	CARD_TYPES[CARD_TYPE_THREEWITHTWO]	= self.has_CARD_TYPE_THREEWITHTWO	-- = 8		-- 三带二
	CARD_TYPES[CARD_TYPE_PLANE]			= self.has_CARD_TYPE_PLANE	-- = 9  	-- 飞机

	for type, func in pairs(CARD_TYPES) do
		if _type == type then
			return func(_cards, _cmpValue)
		end
	end
end

return CardAnalysis

