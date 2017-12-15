
-- function show_hu_result( index )
-- 	-- body
-- 	local _hu_old = SCENENOW["scene"]:getChildByName("_hu"..tostring(index)) 
-- 	if _hu_old ~= nil then
-- 		_hu_old:removeSelf()
-- 	end

-- 	local pos = {cc.p(273.23,307.74),cc.p(464.86,406.29),cc.p(656.02,307.74)}
-- 	pos[0] = cc.p(467.57,194.21)
	
-- 	local pos  = pos[tonumber(index)]
-- 	local _hu = ccui.Layout:create()
-- 	_hu:setAnchorPoint(cc.p(0,0))
-- 	_hu:setContentSize(cc.size(200, 200))
-- 	_hu:setName("_hu"..tostring(index))

-- 	local effect_hu03 = ccui.Layout:create()
-- 	effect_hu03:setAnchorPoint(cc.p(0.5,0.5))
-- 	effect_hu03:setBackGroundImage("fzz_majiang/res/image/effect_hu03.png")
-- 	effect_hu03:setContentSize(cc.size(96, 85))
-- 	_hu:addChild(effect_hu03)

-- 	local hu_base = ccui.Layout:create()
-- 	hu_base:setAnchorPoint(cc.p(0.5,0.5))
-- 	hu_base:setContentSize(cc.size(100, 100))
-- 	_hu:addChild(hu_base)
-- 	hu_base:setName("hu_base")


-- 	local hu_base1 = ccui.Layout:create()
-- 	hu_base1:setAnchorPoint(cc.p(0.5,0.5))
-- 	--hu_base1:setContentSize(cc.size(100, 100))
-- 	hu_base1:setBackGroundImage("fzz_majiang/res/image/effect_guang.png")
-- 	hu_base1:setPosition(cc.p(48,42.5))
-- 	hu_base:addChild(hu_base1)

-- 	local hu_base2 = ccui.Layout:create()
-- 	hu_base2:setAnchorPoint(cc.p(0.5,0.5))
-- 	--hu_base2:setContentSize(cc.size(100, 100))
-- 	hu_base2:setBackGroundImage("fzz_majiang/res/image/effect_hu02.png")
-- 	hu_base2:setPosition(cc.p(48,42.5))
-- 	hu_base:addChild(hu_base2)

-- 	local hu_base3 = ccui.Layout:create()
-- 	hu_base3:setAnchorPoint(cc.p(0.5,0.5))
-- 	--hu_base3:setContentSize(cc.size(100, 100))
-- 	hu_base3:setBackGroundImage("fzz_majiang/res/image/effect_hu01.png")
-- 	hu_base3:setPosition(cc.p(48,42.5))
-- 	hu_base:addChild(hu_base3)


-- 	--hu_base:retain()

-- 	_hu:setPosition(pos)
-- 	_hu:setScale(0.8)

-- 	local action1= cc.ScaleTo:create(0.5,1.2)
-- 	local action2 = cc.ScaleTo:create(0.5,1.0)


-- 	local showTurnAc = cc.CallFunc:create(function()
-- 		--local fo = cc.FadeOut:create(0.5)
-- 		--local room_handleresult_hu_base = _hu:getChildByName("hu_base")
-- 		--hu_base:setVisible(false)--(fo)
-- 		--hu_base:release()
-- 		end)
-- 	local action3 = cc.DelayTime:create(0.4)
-- 	local action_reself = cc.RemoveSelf:create()
-- 	local sq = cc.Sequence:create(action1,action2,showTurnAc,action3,action_reself)
	

--  	_hu:runAction(sq)

--  	 SCENENOW["scene"]:addChild(_hu,100)

-- end

-- function show_handle_result( index,result_tbl )
-- 	-- body
-- 	local pos = {cc.p(273.23,307.74),cc.p(464.86,406.29),cc.p(656.02,307.74)}
-- 	pos[0] = cc.p(467.57,194.21)

-- 	local effect_hu03_image_path = "fzz_majiang/res/image/effect_peng03.png"
-- 	local effect_peng02 = "fzz_majiang/res/image/effect_peng02.png"
-- 	local effect_peng01 = "fzz_majiang/res/image/effect_peng01.png" 
-- 	if result_tbl['g'] or result_tbl['pg'] then
-- 		effect_hu03_image_path = "fzz_majiang/res/image/effect_gang03.png"
-- 		effect_peng02 = "fzz_majiang/res/image/effect_gang02.png"
-- 		effect_peng01 = "fzz_majiang/res/image/effect_gang01.png" 
-- 	elseif result_tbl['p'] then
--         effect_hu03_image_path = "fzz_majiang/res/image/effect_peng03.png"
--         effect_peng02 = "fzz_majiang/res/image/effect_peng02.png"
--         effect_peng01 = "fzz_majiang/res/image/effect_peng01.png"
-- 	end

-- 	local peng_layout_old = SCENENOW["scene"]:getChildByName("peng_layout") 
-- 	if peng_layout_old ~= nil then
-- 		peng_layout_old:removeSelf()
-- 	end

-- 	local peng_layout = ccui.Layout:create()
-- 	peng_layout:setAnchorPoint(cc.p(0,0))
-- 	peng_layout:setContentSize(cc.size(200, 200))
-- 	peng_layout:setName("peng_layout")

-- 	local peng1 = ccui.Layout:create()
-- 	peng1:setAnchorPoint(cc.p(0.5,0.5))
-- 	peng1:setBackGroundImage(effect_hu03_image_path)
-- 	peng1:setContentSize(cc.size(96, 85))
-- 	peng_layout:addChild(peng1)

-- 	local peng_base = ccui.Layout:create()
-- 	peng_base:setAnchorPoint(cc.p(0.5,0.5))
-- 	peng_base:setContentSize(cc.size(100, 100))
-- 	peng_base:setName("peng_base")


-- 	local peng2 = ccui.Layout:create()
-- 	peng2:setAnchorPoint(cc.p(0.5,0.5))
-- 	--peng1:setContentSize(cc.size(100, 100))
-- 	peng2:setBackGroundImage("fzz_majiang/res/image/effect_guang.png")
-- 	peng2:setPosition(cc.p(48,42.5))
-- 	peng_base:addChild(peng2)

-- 	local peng3 = ccui.Layout:create()
-- 	peng3:setAnchorPoint(cc.p(0.5,0.5))
-- 	--peng3:setContentSize(cc.size(100, 100))
-- 	peng3:setBackGroundImage(effect_peng02)
-- 	peng3:setPosition(cc.p(48,42.5))
-- 	peng_base:addChild(peng3)

-- 	local peng4 = ccui.Layout:create()
-- 	peng4:setAnchorPoint(cc.p(0.5,0.5))
-- 	--peng4:setContentSize(cc.size(100, 100))
-- 	peng4:setBackGroundImage(effect_peng01)
-- 	peng4:setPosition(cc.p(48,42.5))
-- 	peng_base:addChild(peng4)
-- 	--hu_base:retain()
-- 	peng_layout:addChild(peng_base)

-- 	peng_layout:setPosition(pos[tonumber(index)])
-- 	peng_layout:setScale(0.8)

-- 	local action1= cc.ScaleTo:create(0.5,1.2)
-- 	local action2 = cc.ScaleTo:create(0.5,1.0)


-- 	local showTurnAc = cc.CallFunc:create(function()
-- 		--local fo = cc.FadeOut:create(0.5)
-- 		--local room_handleresult_hu_base = _hu:getChildByName("hu_base")
-- 		--hu_base:setVisible(false)--(fo)
-- 		--hu_base:release()
-- 		end)
-- 	local action3 = cc.DelayTime:create(0.4)
-- 	local action_reself = cc.RemoveSelf:create()
-- 	local sq = cc.Sequence:create(action1,action2,showTurnAc,action3,action_reself)
	

--  	peng_layout:runAction(sq)

--  	 SCENENOW["scene"]:addChild(peng_layout,101)
-- end