manager = nil


function display.newBMFontLabel(params)
    assert(type(params) == "table",
           "[framework.display] newBMFontLabel() invalid params")

    local text      = tostring(params.text)
    local font      = params.font
    local textAlign = params.align or cc.TEXT_ALIGNMENT_LEFT
    local maxLineW  = params.maxLineWidth or 0
    local offsetX   = params.offsetX or 0
    local offsetY   = params.offsetY or 0
    local x, y      = params.x, params.y
    assert(font ~= nil, "framework.display.newBMFontLabel() - not set font")

    local label = cc.Label:createWithBMFont(font, text, textAlign, maxLineW, cc.p(offsetX, offsetY));
    if not label then return end

    if type(x) == "number" and type(y) == "number" then
        label:setPosition(x, y)
    end

    return label
end

function get_card_path( card_value )
	-- body
	-- local CARD_INDEX_LIST = {
	-- 			101,201,301,401,
	-- 			102,202,302,402,
	-- 			103,203,303,403,
	-- 			104,204,304,404,
	-- 			105,205,305,405,
	-- 			106,206,306,406,
	-- 			107,207,307,407,
	-- 			108,208,308,408,
	-- 			109,209,309,409,
	-- 			110,210,310,410,
	-- 			111,211,311,411,
	-- 			112,212,312,412,
	-- 			113,213,313,413}

	local card_path = "xlsg/res/image/pokercard/lord_card_diamond_14.png"
	local value = card_value % 100
	local hua =math.modf( card_value / 100)
	
	--图片的1（A）被放到了14的位置
	if value == 1 then
		value = 14
	end

	if hua == 1 then
		card_path = "xlsg/res/image/pokercard/lord_card_diamond_"..tostring(value)..".png" --方块

	elseif hua == 2 then 
		card_path = "xlsg/res/image/pokercard/lord_card_spade_"..tostring(value)..".png" --梅花

	elseif hua == 3 then
		card_path = "xlsg/res/image/pokercard/lord_card_heart_"..tostring(value)..".png" --红桃
		
	else
		card_path = "xlsg/res/image/pokercard/lord_card_club_"..tostring(value)..".png" -- 黑桃
	end

	return card_path
end


-- DSG_HANDLER_INDEX = "dsg" --大3公
-- XSG_HANDLER_INDEX = "xsg"--小3公
-- HSG_HANDLER_INDEX = "hsg"--混3公
-- BP_HANDLER_INDEX = "bp"--大点数
-- SP_HANDLER_INDEX = "sp"--小点数

function handler_result(handler_data )
	-- body
	local base_tip = ccui.ImageView:create()
	base_tip:loadTexture("xlsg/res/image/hongtiao.png")

	local account_conbination_style = handler_data["account_conbination_style"] or ""
	if account_conbination_style == "dsg" then
		local text_dasangong = ccui.ImageView:create()
		text_dasangong:loadTexture("xlsg/res/image/text_dasangong.png")
		base_tip:addChild(text_dasangong)
		text_dasangong:setPosition(cc.p(base_tip:getContentSize().width/2,base_tip:getContentSize().height/2))

	elseif account_conbination_style == "xsg" then
		local text_xiaosangong = ccui.ImageView:create()
		text_xiaosangong:loadTexture("xlsg/res/image/text_xiaosangong.png")
		base_tip:addChild(text_xiaosangong)
		text_xiaosangong:setPosition(cc.p(base_tip:getContentSize().width/2,base_tip:getContentSize().height/2))

	elseif account_conbination_style == "hsg" then
		local text_hunsangong = ccui.ImageView:create()
		text_hunsangong:loadTexture("xlsg/res/image/text_hunsangong.png")
		base_tip:addChild(text_hunsangong)
		text_hunsangong:setPosition(cc.p(base_tip:getContentSize().width/2,base_tip:getContentSize().height/2))
	else
		local account_handcard = handler_data["account_handcard"] or {}
		local sum = 0
		for _,card_value in pairs(account_handcard) do
			local value = tonumber(card_value) % 100
			if value > 10 then
				value = 10
			end
			sum = sum + value
		end
		if sum > 0 then
			sum = sum % 10
		end

		local label = display.newBMFontLabel({
		    text = tostring(sum),
		    font = "xlsg/res/fonts/sangong_num.fnt",
		})
		base_tip:addChild(label)
        label:setPosition(cc.p(base_tip:getContentSize().width/2 - 20,base_tip:getContentSize().height/2-10))
		
		local text_dian = ccui.ImageView:create()
		text_dian:loadTexture("xlsg/res/image/text_dian.png")
		base_tip:addChild(text_dian)
		text_dian:setPosition(cc.p(base_tip:getContentSize().width/2  + 20,base_tip:getContentSize().height/2))
	end


	return base_tip
end



function handler_num( num_str )
	-- body
		local label = display.newBMFontLabel({
		    text = tostring(num_str),
		    font = "xlsg/res/fonts/num.fnt",
		})
	return label
end

