
--定义选择牌控件类
local SelectCardView = class("SelectCardView")

local CARD_PATH_MANAGER = require("majiang.card_path")
CARD_PATH_MANAGER:init()

--显示选牌区域
function SelectCardView:showView(x, y, handle, cards)

	if handle == nil then
		return
	end

	if cards == nil then
		return
	end

	if SCENENOW["scene"] then

		local selectCard_ly = SCENENOW["scene"]:getChildByName("selectCard_ly")
		if selectCard_ly then
			selectCard_ly:removeSelf()
		end

		selectCard_ly = ccui.Layout:create()
		selectCard_ly:setSize(0,0)
		selectCard_ly:setAnchorPoint(0,1)
		selectCard_ly:setName("selectCard_ly")
		SCENENOW["scene"]:addChild(selectCard_ly)

		local selectCardBg_iv = ccui.ImageView:create()
		selectCardBg_iv:ignoreContentAdaptWithSize(false)
		selectCardBg_iv:setScale9Enabled(true)
	    selectCardBg_iv:loadTexture("majiang/image/moniao_box01.png")
	    selectCardBg_iv:setAnchorPoint(0,1)
	    selectCardBg_iv:setPosition(cc.p(0,0))
	    selectCard_ly:addChild(selectCardBg_iv)

	    local x_start = 27
	    local y_start = -28

	    local x_space = 8

	    local x_last = 0

	    local card_width = 27

	    --添加杠牌
	    for i,v in ipairs(cards) do

	    	local cardPath = CARD_PATH_MANAGER:get_hand_card_path(v)

	    	for j=0,3 do

		    	local card_sp = display.newSprite(cardPath)
		    	card_sp:setTouchEnabled(true)
		    	card_sp:setScale(0.5)
		    	card_sp:setPosition(cc.p(x_start + 27 * 4 * (i - 1) + x_space * (i - 1) + card_width * j, y_start))
		    	card_sp:addNodeEventListener(
		            cc.NODE_TOUCH_EVENT,function (event)

		            	if event.name == "began" then

	                        require("majiang.scenes.MajiangroomServer"):requestHandle(handle, v)

	                        self:removeView()

	                    end

		            end
		        )

		    	selectCard_ly:addChild(card_sp)

		    	x_last = x_start + 27 * 4 * (i - 1) + x_space * (i - 1) + card_width * j

			end

	    end

	    --设置背景长度
	    selectCardBg_iv:setSize(x_last + (card_width + x_start) / 2, 55)

	    --设置区域显示位置
	    selectCard_ly:setPosition(cc.p(x - (x_last + (card_width + x_start) / 2) / 2, y))

	end

end

--移除选牌区域
function SelectCardView:removeView()

	local selectCard_ly = SCENENOW["scene"]:getChildByName("selectCard_ly")
	if selectCard_ly then
		selectCard_ly:removeSelf()
	end

end

return SelectCardView