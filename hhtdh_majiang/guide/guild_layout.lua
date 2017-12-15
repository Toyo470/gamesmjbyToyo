mrequire("guide.guide_template")
GuildLayout = class("GuildLayout", guide.guide_template.guide_Template)

function GuildLayout:_do_after_init()
	-- local clipper = cc.ClippingNode:create()
	-- clipper:setContentSize(cc.size(100.0, 100.0))

	-- self:addChild(clipper)
	
end

-- function GuildLayout:_do_after_init()

-- 	local pos = {}
-- 	pos[1] =  self.guide_fighter:getPositionX()
-- 	pos[2] =  self.guide_fighter:getPositionY()

-- 	print("pos type------------",type(pos))
-- 	local item_contentsize = self.guide_fighter:getContentSize()
-- 	dump(item_contentsize)
-- 	local left_dowm = cc.p(pos[1] - item_contentsize.width/2 ,pos[2] - item_contentsize.height/2 )
-- 	local left_up = cc.p(pos[1] - item_contentsize.width/2 ,pos[2] + item_contentsize.height/2 )
-- 	local right_up = cc.p(pos[1] + item_contentsize.width/2 ,pos[2] + item_contentsize.height/2 )
-- 	local right_down = cc.p(pos[1] + item_contentsize.width/2 ,pos[2] - item_contentsize.height/2 )

-- 	local draw = cc.DrawNode:create()
-- 	self:addChild(draw)

-- 	local size = cc.Director:getInstance():getWinSize()
--     local triangle_pos = {
-- 						    cc.p(0,0),
-- 						    left_dowm,
-- 						    cc.p(0,size.height),
-- 						    left_up,
-- 						    cc.p(size.width,size.height),
-- 						    right_up,
-- 						    cc.p(size.width,0),
-- 						    right_down,
-- 						    cc.p(0,0),
-- 						    left_dowm
--     }

--     draw:drawTriangle(triangle_pos[1],triangle_pos[2],triangle_pos[3],cc.c4f(1,1,1,0.5))
--     draw:drawTriangle(triangle_pos[2],triangle_pos[3],triangle_pos[4],cc.c4f(1,1,1,0.5))
--     draw:drawTriangle(triangle_pos[3],triangle_pos[4],triangle_pos[5],cc.c4f(1,1,1,0.5))
--     draw:drawTriangle(triangle_pos[4],triangle_pos[5],triangle_pos[6],cc.c4f(1,1,1,0.5))
--     draw:drawTriangle(triangle_pos[5],triangle_pos[6],triangle_pos[7],cc.c4f(1,1,1,0.5))
--     draw:drawTriangle(triangle_pos[6],triangle_pos[7],triangle_pos[8],cc.c4f(1,1,1,0.5))
--     draw:drawTriangle(triangle_pos[7],triangle_pos[8],triangle_pos[9],cc.c4f(1,1,1,0.5))
--     draw:drawTriangle(triangle_pos[8],triangle_pos[9],triangle_pos[10],cc.c4f(1,1,1,0.5))


-- end
