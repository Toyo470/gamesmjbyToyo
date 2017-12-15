local MenjiroomView   = import("zhajinhua.view.MenjiroomView")
local CompareView   = class("CompareView", function()
    return display.newNode("CompareView")
end)

local original_pos = {}
local card_orginal_pos = {}
local active_uid = nil
local compare_uid = nil
local compare_resutl = 1

function CompareView:ctor()
	-- body

end

function CompareView:showCampare(uid,c_uid,result, delay)
	-- body
	--uid主动发起，c_uid被动比牌
	active_uid = uid
	compare_uid = c_uid
	compare_resutl = result
	card_orginal_pos = {}

	if delay and delay == 1 then
		local user_node_f = MenjiroomView:getUserNode(uid)
		if user_node_f then
			user_node_f:runAction(cc.Sequence:create(cc.DelayTime:create(2), cc.CallFunc:create(function()
		-- result 0:uid失败，1:uid获胜
				CompareView:transUserNode(active_uid, compare_uid)
				CompareView:moveUserNode()
			end)))
		end
	else
		CompareView:transUserNode(active_uid, compare_uid)
		CompareView:moveUserNode()
	end

end

-- 转移玩家节点
function CompareView:transUserNode(uid, compare_uid)

	--复制两个玩家牌的节点
	local scenes  = SCENENOW["scene"].view._view
	local node    = display.newNode()
	node:setName("zhezhao")
	node:addTo(scenes,1)

	local layer = cc.LayerColor:create(cc.c4b(0,0,0,110))
	layer:addTo(node)


	local user_node_f = MenjiroomView:getUserNode(uid)
	if user_node_f == nil then
		return false
	end

	dump(user_node_f:getContentSize(), "transUserNode user_node_f size", nesting)
	original_pos[1] = user_node_f:getPosition()
	if user_node_f:getAnchorPoint().x == 0 then
		original_pos[1].x = original_pos[1].x + user_node_f:getContentSize().width/2
		original_pos[1].y = original_pos[1].y + user_node_f:getContentSize().height/2
		user_node_f:setAnchorPoint(cc.p(0.5,0.5))
	end

	CompareView:resetUserNode(user_node_f, false, uid)

	user_node_f:addTo(node, 20)
	user_node_f:setPosition(original_pos[1].x, original_pos[1].y)
	user_node_clone_f = user_node_f

	local user_node_s = MenjiroomView:getUserNode(compare_uid)
	if user_node_s == nil then
		return false
	end

	dump(user_node_s:getContentSize(), "transUserNode user_node_s size", nesting)
	original_pos[2] = user_node_s:getPosition()
	if user_node_s:getAnchorPoint().x == 0 then
		original_pos[2].x = original_pos[2].x + user_node_s:getContentSize().width/2
		original_pos[2].y = original_pos[2].y + user_node_s:getContentSize().height/2
		user_node_s:setAnchorPoint(cc.p(0.5,0.5))
	end

	CompareView:resetUserNode(user_node_s, false, compare_uid)
	user_node_s:addTo(node, 20)
	user_node_s:setPosition(original_pos[2].x, original_pos[2].y)
	user_node_clone_s = user_node_s

	dump(original_pos, "transUserNode", nesting)

end

-- 是否传牌值进来
function CompareView:resetUserNode(node, is_show, uid, repleace_node)
	if node == nil then
		return
	end
	local flag = repleace_node or 1
	if flag == 1 then
		node:retain()
		node:removeSelf()
	end
	local bets = node:getChildByName("chip_bg")
	if bets then
		bets:setVisible(is_show)
	end
	local card_kan=node:getChildByName("card_kan")
	local  bi_back=node:getChildByName("chat")
	if bi_back then
		bi_back:removeSelf()
	end
	if card_kan~=nil then
		card_kan:removeSelf()
	end
	local kanpai = node:getChildByName("kanpai")
	if kanpai~=nil then
		kanpai:setVisible(is_show)
	end
	local card_node = node:getChildByName("card_node")
	if is_show == true then
		for i=0,2 do
			local card = card_node:getChildByName("card"..i)
			if card then
				if tonumber(uid) == tonumber(UID) and bm.User.isKan[tonumber(UID)] ~= nil then
					card:flip()
				else
					card:showBack()
				end
			end
		end
	end
	if card_node then
		card_node:setVisible(is_show)
	end

	local head_time = node:getChildByName("head_time")
	if head_time then
		head_time:setVisible(is_show)
		if is_show then
		    local pt = cc.ProgressTo:create(bm.Room.time_progress,100)
		    local sq2 = cc.Sequence:create(pt, cc.CallFunc:create(function()
		    	if bm.Room.seatProgressTimer then

					local action_time = 0.3
					local action_in = 0.1
					local st_big = cc.ScaleTo:create(action_time, 1.3)
					local fo = cc.FadeOut:create(action_time)
					local st_small = cc.ScaleTo:create(action_in, 1.1)
					local fi = cc.FadeIn:create(action_in)
					local sqout = cc.Spawn:create(st_big,fo)
					local sqin = cc.Spawn:create(st_small,fi)
					local sq = cc.Sequence:create(sqout,sqin)
		    		bm.Room.seatProgressTimer:runAction(cc.RepeatForever:create(sq))
		    	end
		    	end))
		    head_time:runAction(sq2)
		end
	end
end

-- 移动玩家节点到比牌位置
function CompareView:moveUserNode()

	local pos_end = {
		[0] = {
			['x']    = 268,
			['y']    = 304,
		},
		[1] = {
			['x']    = 709,
			['y']    = 273,
		}
	}

	local move = cc.MoveTo:create(0.4,cc.p(pos_end[0]["x"], pos_end[0]["y"]))
	user_node_clone_f:runAction(move)

	local move = cc.MoveTo:create(0.4,cc.p(pos_end[1]["x"], pos_end[1]["y"]))
	local sq = cc.Sequence:create(move, cc.CallFunc:create(function()
		CompareView:movePK()
		end))
	user_node_clone_s:runAction(sq)
end

-- 移动玩家节点回原来位置
function CompareView:moveUsernode2Original()

	print("moveUsernode2Original")

	local scenes  = SCENENOW["scene"].view._view
	local node    = scenes:getChildByName("zhezhao")
	if node == nil then
		return
	end

	user_node_clone_f:retain()
	user_node_clone_f:removeSelf()
	user_node_clone_s:retain()
	user_node_clone_s:removeSelf()
	node:removeSelf()

	user_node_clone_f:addTo(scenes, 1)
	user_node_clone_f:setAnchorPoint(cc.p(0.5, 0.5))
	user_node_clone_s:addTo(scenes, 1)
	user_node_clone_s:setAnchorPoint(cc.p(0.5, 0.5))


	dump(original_pos, "original_pos", nesting)
	local move = cc.MoveTo:create(0.4,cc.p(original_pos[1].x, original_pos[1].y))
	user_node_clone_f:runAction(move)

	local move = cc.MoveTo:create(0.4,cc.p(original_pos[2].x, original_pos[2].y))
	local sq = cc.Sequence:create(move, cc.CallFunc:create(function()
		-- 还原玩家节点
		CompareView:resetUserNode(user_node_clone_f, true, active_uid, 0)
		CompareView:resetUserNode(user_node_clone_s, true, compare_uid, 0)
		MenjiroomView:CallBackCompare(active_uid, compare_uid, compare_resutl)
		end))
	user_node_clone_s:runAction(sq)
end

-- 出PK效果
function CompareView:movePK()
	local pos_end_back = {
		[0] = {
			['x']    = 318,
			['y']    = 295,
		},
		[1] = {
			['x']    = 662,
			['y']    = 269,
		}
	}
	local pos_end_txt = {
		[0] = {
			['x']    = 435,
			['y']    = 309,
		},
		[1] = {
			['x']    = 550,
			['y']    = 280,
		}
	}

	local scenes  = SCENENOW["scene"].view._view
	local node    = scenes:getChildByName("zhezhao")
	if node == nil then
		return
	end

	local offset_x = 500
	local move_time = 0.1

	local back_left = display.newSprite("zhajinhua/res/room/compareCard/pk_left_box01.png")
	back_left:addTo(node, 1)
	back_left:setPosition(pos_end_back[0].x - offset_x, pos_end_back[0].y)
	local mt = cc.MoveTo:create(move_time, cc.p(pos_end_back[0].x, pos_end_back[0].y))
	back_left:runAction(mt)

	local back_right = display.newSprite("zhajinhua/res/room/compareCard/pk_right_box01.png")
	back_right:addTo(node, 1)
	back_right:setPosition(pos_end_back[1].x + offset_x, pos_end_back[1].y)
	local mt = cc.MoveTo:create(move_time, cc.p(pos_end_back[1].x, pos_end_back[1].y))
	back_right:runAction(mt)

	local txt_left = display.newSprite("zhajinhua/res/room/compareCard/pk_p.png")
	txt_left:addTo(node, 4)
	txt_left:setPosition(pos_end_txt[0].x - offset_x, pos_end_txt[0].y)
	local mt = cc.MoveTo:create(move_time, cc.p(pos_end_txt[0].x, pos_end_txt[0].y))
	txt_left:runAction(mt)

	local txt_right = display.newSprite("zhajinhua/res/room/compareCard/pk_k.png")
	txt_right:addTo(node, 4)
	txt_right:setPosition(pos_end_txt[1].x + offset_x, pos_end_txt[1].y)
	local mt = cc.MoveTo:create(move_time, cc.p(pos_end_txt[1].x, pos_end_txt[1].y))
	local sq = cc.Sequence:create(mt, cc.DelayTime:create(1), cc.CallFunc:create(function()
		CompareView:showFire()
		end))
	txt_right:runAction(sq)
end

-- 碰撞火花
function CompareView:showFire()
	local scenes  = SCENENOW["scene"].view._view
	local node    = scenes:getChildByName("zhezhao")
	if node == nil then
		return
	end

	-- 爆炸光
	local boom_light = display.newSprite("zhajinhua/res/room/compareCard/light02.png")
	boom_light:setBlendFunc(cc.blendFunc(gl.SRC_ALPHA, gl.ONE))
	boom_light:addTo(node, 3)
	boom_light:setPosition(480, 280)
	boom_light:setScale(0.1)
	boom_light:setAnchorPoint(cc.p(0.5,0.5))
	local st = cc.ScaleTo:create(0.4, 2)
	boom_light:runAction(st)

	-- PK光
	local pk_light = display.newSprite("zhajinhua/res/room/compareCard/light01.png")
	pk_light:setBlendFunc(cc.blendFunc(gl.SRC_ALPHA, gl.ONE))
	pk_light:addTo(node, 40)
	pk_light:setPosition(428, 361)
	pk_light:setScale(2)
	-- local mt = cc.MoveTo:create(0.4, cc.p(628, 361))
	-- pk_light:runAction(mt)


	local boom = display.newSprite("#boom_01.png")
	local frames = display.newFrames("boom_%02d.png", 1, 4)
	local animation = display.newAnimation(frames, 0.1)

	local function onComplete()
		boom_light:removeSelf()
		pk_light:removeSelf()
		CompareView:showWinner()
	end
	boom:playAnimationOnce(animation, true, onComplete)
	boom:addTo(node, 2)
	boom:setScale(3)
	boom:setBlendFunc(cc.blendFunc(gl.SRC_ALPHA, gl.ONE))
	boom:setPosition(480, 280)

end

-- 显示赢家
function CompareView:showWinner()

	print("showWinner", tostring(compare_resutl))

	local scenes  = SCENENOW["scene"].view._view
	local node    = scenes:getChildByName("zhezhao")
	if node == nil then
		return
	end

	local user_node = nil
	if compare_resutl == 1 then
		user_node = user_node_clone_f
	else
		user_node = user_node_clone_s
	end

	if user_node == nil then
		return
	end

	dump(user_node:getPosition(), "showWinner", nesting)
	local effect_winner = display.newSprite("#effect_winner_1.png")
	local frames = display.newFrames("effect_winner_%d.png", 1, 10)
	local animation = display.newAnimation(frames, 0.1)

	local function onComplete()
		CompareView:moveUsernode2Original()
		-- effect_winner:runAction(cc.Sequence:create(cc.DelayTime:create(3), cc.CallFunc:create(function()
		-- 		CompareView:moveUsernode2Original()
		-- 	end)))
	end

	effect_winner:playAnimationOnce(animation, true, onComplete)
	effect_winner:addTo(node, 21)
	effect_winner:setBlendFunc(cc.blendFunc(gl.SRC_ALPHA, gl.ONE))
	effect_winner:setScaleX(user_node:getContentSize().width/effect_winner:getContentSize().width + 0.5)
	effect_winner:setScaleY(user_node:getContentSize().height/effect_winner:getContentSize().height)
	effect_winner:setPosition(cc.p(user_node:getPositionX(), user_node:getPositionY()))
end


return CompareView