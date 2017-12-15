mrequire("effect.start_effect_template")
mrequire("cardhandle.deal_card_path")

StartEffectLayout = class("StartEffectLayout", effect.start_effect_template.start_effect_Template)

function StartEffectLayout:_do_after_init()
	local base_path = GAMEBASENAME .. "/res/image"
	self.jing_img_dict = {
			["up_jing"]=base_path.."text_shangjing.png",
			["down_jing"]=base_path.."text_xiajing.png",
			["left_jing"]=base_path.."text_zuojing.png",
			["right_jing"]=base_path.."text_youjing.png",
	}
	self.callback_func = nil
end

function StartEffectLayout:show_start_effect(left_card_index,right_card_index,jing_style,callback)
	local left_img =  cardhandle.deal_card_path.get_card_path(left_card_index)
	local right_img =  cardhandle.deal_card_path.get_card_path(right_card_index)
	self.start_effect_majiang_left:loadTexture(left_img)
	self.start_effect_majiang_right:loadTexture(right_img)
	self:play_rotat_animation()

	local jing_img = self.jing_img_dict[jing_style]

	if jing_img ~= nil then
		self.start_effect_shangjing_img:loadTexture(jing_img)
	end

	self.callback_func = callback
	print("-----self.callback_func---",self.callback_func)
end

function StartEffectLayout:after_play_animation(param)
	self = param[1]
	self.callback_func()
end

function StartEffectLayout:play_next_move_animation(param)
	self = param[1]

	self.start_effect_majiang_bg_right:setVisible(true)
	local left_x = self.start_effect_majiang_bg_left:getPositionX()
    local left_y = self.start_effect_majiang_bg_left:getPositionY()

    local left_action = cc.Sequence:create(
    					cc.MoveTo:create(0.5,cc.p(left_x-50,left_y)),
    					cc.FadeOut:create(2),
    					cc.CallFunc:create(self.after_play_animation,{self})
    					)

	local right_x = self.start_effect_majiang_bg_right:getPositionX()
    local right_y = self.start_effect_majiang_bg_right:getPositionY()
	local right_action = cc.Sequence:create(
						cc.MoveTo:create(0.5,cc.p(right_x+50,right_y)),
						cc.FadeOut:create(2)
						)

	self.start_effect_majiang_bg_left:runAction(left_action)
	self.start_effect_majiang_bg_right:runAction(right_action)
end

function StartEffectLayout:play_next_rotat_animation(param)
	self = param[1]
	print("---------------------StartEffectLayout:test1",param)
	self.start_effect_majiang_bg_left:setVisible(true)
	local temp_action = cc.Sequence:create(
									cc.DelayTime:create(0.1),
									cc.OrbitCamera:create(0.05 + 1 / 20.0, 2, 0, 90, -90, 0, 0),
									--cc.Hide:create(),
									cc.CallFunc:create(self.play_next_move_animation,{self})
									)
	self.start_effect_majiang_bg_left:runAction(temp_action)
	-- body
end

function StartEffectLayout:play_rotat_animation()
	self.start_effect_majiang_bg_right:setVisible(false)
	self.start_effect_majiang_bg_left:setVisible(false)
	local temp_action = cc.Sequence:create(
									cc.DelayTime:create(1),
									cc.OrbitCamera:create(0.05 + 1 / 20.0, 2, 0, 0, -90, 0, 0),
									cc.Hide:create(),
									cc.CallFunc:create(self.play_next_rotat_animation,{self})
									)
	self.start_effect_majiang_bg:runAction(temp_action)

	local jing_img_action = cc.Sequence:create(
									cc.FadeOut:create(2)
									)

	self.start_effect_shangjing_img:runAction(jing_img_action)
end
