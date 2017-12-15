mrequire("effect.end_effect_template")
mrequire("cardhandle.deal_card_path")

EndEffectLayout = class("EndEffectLayout", effect.end_effect_template.end_effect_Template)

function EndEffectLayout:_do_after_init()
	local base_path = GAMEBASENAME .. "/res/image"
	self.jing_img_dict = {
			[names.GAME_UP_JING_CARD_LIST]=base_path.."/text_shangjing.png",
			[names.GAME_DOWN_JING_CARD_LIST]=base_path.."/text_xiajing.png",
			[names.GAME_LEFT_JING_CARD_LIST]=base_path.."/text_zuojing.png",
			[names.GAME_RIGHT_JING_CARD_LIST]=base_path.."/text_youjing.png",
	}
	self.callback_func = nil
	self.__jing_seat_name_list = {"down","right","up","left"}
end

function EndEffectLayout:reset_zj_fj_card(zj_card_index,fj_card_index)
	local left_img = cardhandle.deal_card_path.get_card_path(zj_card_index)
	local right_img = cardhandle.deal_card_path.get_card_path(fj_card_index)

	for _,seat_name in pairs(self.__jing_seat_name_list) do
		--print("---seat_name--",seat_name)
		local zj_widget_name = string.format("end_effect_%s_side_zj_img",seat_name)
		local fj_widget_name = string.format("end_effect_%s_side_fj_img",seat_name)
		--print("---zj_widget_name,fj_widget_name--",zj_widget_name,fj_widget_name)
		local zj_widget = ui.manager:get_widget_object(zj_widget_name)
		local fj_widget = ui.manager:get_widget_object(fj_widget_name)
		zj_widget:loadTexture(left_img)
		fj_widget:loadTexture(right_img)
	end
end

function EndEffectLayout:show_hit_jing_result(hit_jing_dict,account_pass_off_jing_dict,ba_jing_account_id)
	self.end_effect_effect_img_bg:setOpacity(255)
	for account_id,jing_data in pairs(hit_jing_dict) do
		local zj_count = jing_data[1]
		local fj_count = jing_data[2]
		local index = zzroom.manager:get_other_index(tonumber(account_id)) 
		local seat_name = self.__jing_seat_name_list[index+1]

		local hit_describe = ""

		if ba_jing_account_id == account_id then
			hit_describe = hit_describe .. "霸精X2 "
		end

		local pass_off_mutiple = account_pass_off_jing_dict[account_id] or 0--冲关倍数
		if pass_off_mutiple > 0 then
			hit_describe = hit_describe .. "冲关X"..tostring(pass_off_mutiple)
		end

		local effect_side_widget_name = string.format("end_effect_%s_side_txt",seat_name)
		local zj_text_name = string.format("end_effect_%s_side_zj_count",seat_name)
		local fj_text_name = string.format("end_effect_%s_side_fj_count",seat_name)

		--print("---zj_text_name,fj_text_name,hit_describe--",zj_text_name,fj_text_name,account_id,hit_describe)
		--print("---effect_side_widget_name--",effect_side_widget_name)
		local zj_widget = ui.manager:get_widget_object(zj_text_name)
		local fj_widget = ui.manager:get_widget_object(fj_text_name)
		local effect_side_widget = ui.manager:get_widget_object(effect_side_widget_name)

		if effect_side_widget ~= nil then
			effect_side_widget:setString(hit_describe)
		end

		if zj_widget ~= nil then
			zj_widget:setString(tostring(zj_count))
		end

		if fj_widget ~= nil then
			fj_widget:setString(tostring(fj_count))
		end
	end
end

function EndEffectLayout:show_end_effect(zj_card_index,fj_card_index,jing_style,hit_jing_dict,
												pass_off_jing_dict,ba_jing_dict,callback,callback_param)
	self:reset_zj_fj_card(zj_card_index,fj_card_index)
	print("sssssssssssssssssssssssshow_end_effect",jing_style)
	local account_pass_off_jing_dict = pass_off_jing_dict[jing_style] or {}--
	local ba_jing_account_id = ba_jing_dict[jing_style] or {}
	self:show_hit_jing_result(hit_jing_dict,account_pass_off_jing_dict,ba_jing_account_id)
	self.callback_func = callback
	self.callback_param = callback_param
	self:play_fade_animation()

	local jing_style_img = self.jing_img_dict[jing_style]
	print("-----------jing_style_img---",jing_style_img)
	if jing_style_img ~= nil then
		self.end_effect_jing_img:loadTexture(jing_style_img)
	end
end

function EndEffectLayout:after_play_animation(param)
	self = param[1]
	if self.callback_func ~= nil then
		self.callback_func(self.callback_param)
	end
end

function EndEffectLayout:play_fade_animation()
	local temp_action = cc.Sequence:create(
									cc.FadeOut:create(2),
									cc.CallFunc:create(self.after_play_animation,{self})
									)
	self.end_effect_effect_img_bg:runAction(temp_action)
end
