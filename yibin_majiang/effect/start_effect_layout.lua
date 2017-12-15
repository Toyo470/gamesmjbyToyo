mrequire("effect.start_effect_template")
mrequire("cardhandle.deal_card_path")

StartEffectLayout = class("StartEffectLayout", effect.start_effect_template.start_effect_Template)

function StartEffectLayout:_do_after_init()
	self.callback_func = nil
end

function StartEffectLayout:show_start_effect(left_card_index,jing_style,callback)
	local left_img =  cardhandle.deal_card_path.get_card_path(left_card_index)
	self.start_effect_majiang_left:loadTexture(left_img)
	self:play_rotat_animation()

	self.callback_func = callback
	print("-----self.callback_func---",self.callback_func)
end

function StartEffectLayout:after_play_animation()
	
	if self.callback_func  ~= nil then
		self.callback_func()
	end

end

function StartEffectLayout:show_card_effect()
	-- body
	self.start_effect_majiang_bg_left:setVisible(true)
	local jing_img_action = cc.Sequence:create( cc.DelayTime:create(0.5),
												cc.CallFunc:create(handler(self,self.after_play_animation) ) )
	self.start_effect_majiang_bg_left:runAction(jing_img_action)
end
function StartEffectLayout:play_rotat_animation()

	self.start_effect_majiang_bg_left:setVisible(false)
	local jing_img_action = cc.Sequence:create( cc.FadeOut:create(2),cc.CallFunc:create(handler(self,self.show_card_effect)))
	self.start_effect_majiang_bg:runAction(jing_img_action)

end
