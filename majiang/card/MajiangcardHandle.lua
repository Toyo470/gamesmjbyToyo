require("framework.init")

--定义麻将牌操作类
local MajiangcardHandle = class("MajiangcardHandle")

--获取麻将牌类
local Majiangcard = require("majiang.card.Majiangcard")

function MajiangcardHandle:ctor()
	
end

--设置自己的牌
function MajiangcardHandle:setMyCards(table)
	bm.User.Mycards  = {}
	bm.User.Mycards  = table
end

--排序我的牌
function MajiangcardHandle:sortCards(mytable)
	table.sort(mytable, function ( a,b )
		 local tmp1 = Majiangcard.new()
		 tmp1:setCard(a)
		 local tmp2 = Majiangcard.new()
		 tmp2:setCard(b)
		 if tmp1.cardVariety_ ~= tmp2.cardVariety_ then
		 	return tmp1.cardVariety_>tmp2.cardVariety_
		 else
		 	return tmp1.cardValue_<tmp2.cardValue_
		 end
	end )

	return mytable
end

--向队列中插入牌
function MajiangcardHandle:insertCardTo(mytable,mycards)
	for i,v in pairs(mycards) do
		table.insert(mytable, v)
	end
	-- body 
end

--队列中删除牌
function MajiangcardHandle:removeCardValue(mytable,value,mount,index)
	--print("table:"..json.encode(mytable))
	--print("index:"..index)
	--print("mount:"..mount)

	local i = 1
	local count = 0
	while i <= #mytable do
	  if count >= mount and mount ~= 0 then
	  	break
	  end
	  if mytable[i] == value then
	    table.remove(mytable, i)
	    count = count + 1
	  else
	    i = i + 1
	  end
	end

	--print("tableend:"..json.encode(mytable))
	-- body 
end

--获得可进行的操作
function MajiangcardHandle:getHandles(handle)

	local result = {}

	local mingoran = nil  --1  暗杠  0明杠
	
	--是否碰杠
	if bit.band(handle, 0x010) == 0x010 then
		result['pg'] = 0x010
		mingoran     = 0
	end

	--是否碰
	if bit.band(handle,  0x008) ==  0x008 then
		result['p'] = 0x008
	end

	--是否胡
	if bit.band(handle,  0x040) ==  0x040 then
		result['h'] = 0x040
	end

	--抢杠胡
	if bit.band(handle,   0x080) ==   0x080 then
		result['h'] =  0x080
	end

	--八花胡
	if bit.band(handle, 0x100) ==    0x100 then
		result['h'] =   0x100
	end

	--暗杠
	if bit.band(handle, 0x200) ==    0x200 then
		result['g'] =   0x200
		mingoran    =   1
	end

	--补杠
	if bit.band(handle, 0x400) ==    0x400 then
		result['g'] =   0x400
		mingoran    =   0
	end

	--自摸
	if bit.band(handle, 0x800) ==    0x800 then
		result['h'] =   0x800
	end

	return result,mingoran
end

return MajiangcardHandle