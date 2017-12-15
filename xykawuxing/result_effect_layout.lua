
ResultEffectLayout = class("ResultEffectLayout")

function ResultEffectLayout:reset_niaocard_data( cards_tbl,zhongcard )
	-- body
    self.layout = cc.CSLoader:createNode("xykawuxing/result_effect.csb")

	local zhong_tbl = {}
	zhongcard = zhongcard or {}
	for _,card in pairs(zhongcard)do
		zhong_tbl[card] = 1
	end

	local cards_num = table.nums(cards_tbl)
	local cards_num_half = math.modf(cards_num / 2)
	local cards_num_less = cards_num % 2
	--74.6为牌的间隔
	local x = 416.56
	local y = 229.85
	if cards_num_less == 0 then  --偶数个
		x = x - (cards_num_half - 1)*74.6
	else
		x = x + 74.6/2
		x = x - (cards_num_half )*74.6
	end

	local effect_base_w = 171.00/2 - 5
	local effect_base_h = 110.0

    self.result_effect_bg = self.layout:getChildByName("result_effect_bg")
    self.result_effect_item = self.layout:getChildByName("result_effect_item")
	self.result_effect_bg:setContentSize(cc.size(effect_base_w*cards_num,effect_base_h))


	local time_deley = 0
	for _,card_value in pairs(cards_tbl) do
          local result_effect_item = self.result_effect_item:clone()
          result_effect_item:setPosition(cc.p(x,y))
          x = x + 74.6

         -- local card_value = card_data.card
        if card_value ~= nil and card_value ~= 0 then
            local image_tx = "xykawuxing/image/card/" .. card_value .. ".png"
            local result_effect_card = result_effect_item:getChildByName("result_effect_card")
            local result_effect_center = result_effect_item:getChildByName("result_effect_center")
            local result_effect_base = result_effect_item:getChildByName("result_effect_base")

            local result_effect_value = result_effect_card:getChildByName("result_effect_value")
            result_effect_value:loadTexture(image_tx)

            self.layout:addChild(result_effect_item)

            result_effect_card:setVisible(false)
            result_effect_center:setVisible(false)

            local action2 = cc.Sequence:create(cc.DelayTime:create(time_deley + 0.3),cc.Hide:create())
            result_effect_base:runAction(action2)


            local result_effect_center_x = result_effect_center:getPositionX()
            local result_effect_center_y = result_effect_center:getPositionY()
            local action_move_up = cc.MoveTo:create(0.1,cc.p(result_effect_center_x,result_effect_center_y+50))
            local action_move_down = cc.MoveTo:create(0.1,cc.p(result_effect_center_x,result_effect_center_y))

            local action3 = cc.Sequence:create(cc.DelayTime:create(time_deley +0.3),cc.Show:create(),action_move_up,action_move_down,cc.DelayTime:create(0.05),cc.Hide:create())
            result_effect_center:runAction(action3)

 			local action4 = cc.Sequence:create(cc.DelayTime:create(time_deley + 0.5),cc.Show:create())
            result_effect_card:runAction(action4)


            time_deley = time_deley + 0.5

            if zhong_tbl[card_value] == 1 then
              result_effect_card:setColor(cc.c3b(250,250,0))
            end
        end
    end

    self.layout:setName("zhuaniaoLayout")
    SCENENOW["scene"]:addChild(self.layout)

    return time_deley
end

return ResultEffectLayout