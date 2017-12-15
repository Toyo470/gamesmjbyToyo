require("framework.init")

--加载骰子动画资源
local shaiziPin_map = require("hn_majiang.pintu.MajiangshuaiziMap")

--定义麻将游戏动画类
local AniUtils = class("AniUtils")

local order = {
	[1] = 1,
	[2] = 10,
	[3] = 11,
	[4] = 12,
	[5] = 13,
	[6] = 14,
	[7] = 15,
	[8] = 16,
	[9] = 2,
	[10]= 3,
	[11]= 4,
	[12]= 5,
	[13]= 6,
	[14]= 7,
	[15]= 8,
	[16]= 9,
}

-- local MajiangroomAnim = class("MajiangroomAnim",function ()
-- 	return display.newNode()
-- end)

function AniUtils:ctor()
	-- created with TexturePacker (http://www.texturepacker.com)
end

--骰子动画
function AniUtils:shuaiZi(point)

	--获取当前主场景
	local scenes = SCENENOW['scene']

	--新创建一个节点并添加到当前主场景
	local node = display.newNode():addTo(scenes)
	node:pos(480,270)

	local pannel = display.newSprite("hn_majiang/image/shaiziPin.png"):addTo(node)
	if tolua.isnull(pannel) then
        return 
    end
	bm.shaizi_count = 1
	if tolua.isnull(pannel) then
        return 
    end
	pannel:setVisible(false)

	bm.SchedulerPool:loopCall(function()
		
		if bm.shaizi_count == 17 then
			
			if point <= 1 or point >= 17 then
				point = 2 
			end

			local s_point = 1
			local e_point = 6
			if point > 6 then
				s_point = point - 6
			end

			if point <= 6 then
				e_point = point-1
			end

			local one = math.random(s_point,e_point)
			local two = point - one
			-- if two== 0 then
			-- 	two=3
			-- end

			pannel:removeSelf()

			local pannel_one = display.newSprite("hn_majiang/image/".."dian"..tostring(one)..".png"):addTo(node)
			pannel_one:pos(-60,0)

			local pannel_two =  display.newSprite("hn_majiang/image/".."dian"..tostring(two)..".png"):addTo(node)
			pannel_two:pos(60,0)

			bm.shaizi_count  =bm.shaizi_count +1
			return true

		end

		if  bm.shaizi_count == 18 then
			bm.shaizi_count = bm.shaizi_count +1
			return true
		end

		if  bm.shaizi_count > 18 then
			node:removeSelf()
			return false
		end

		if tolua.isnull(pannel) then
            return 
        end
		pannel:setVisible(true)

		local order_t = order[bm.shaizi_count]
		local map_b  = shaiziPin_map['shaizi_anmi'..order_t..'.png']
		if tolua.isnull(pannel) then
            return 
        end
		pannel:setTextureRect(cc.rect(map_b['x'],map_b['y'],map_b['width'],map_b['height']))
		bm.shaizi_count =bm.shaizi_count +1
		return true
	end,0.1)
end

return AniUtils