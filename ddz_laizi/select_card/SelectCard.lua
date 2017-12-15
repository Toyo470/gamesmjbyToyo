
local PROTOCOL         = import("ddz_laizi.ddz_PROTOCOL")
local SelectCard  = class("SelectCard")

local multiCards = {}
local selectCards = {}

function SelectCard:reset()
    -- body
    multiCards = {}
    selectCards = {}
end


function SelectCard:addCards(cards)
    -- body
    table.insert(multiCards,cards)
end
function SelectCard:showSelect()
    -- body
    if #multiCards <= 0 then
		SCENENOW["scene"]:cancelSelectCard()
    	return
    end
    if SCENENOW["scene"] == nil then
    	return
    end
    if #multiCards == 1 then
		selectCards = multiCards[1]
		dump(selectCards, "select cards")
		self:sendPlayCard()
		return
    end

    local cardDis = 30
    local lineCount = 1
    if #multiCards > 2 then
    	lineCount = 2
    end
    local width_back = #multiCards[1]*cardDis+50
    local line_height = 50
    local height_back = line_height + 30
    if #multiCards > 1 then
    	width_back = width_back*2
    end
    if #multiCards > 2 then
    	height_back = height_back*2
    else
    	height_back = height_back + 30
    end
	local layerBack = ccui.Layout:create()
	SCENENOW["scene"]:addChild(layerBack)
	layerBack:setContentSize(cc.size(960,540))
	layerBack:setName("layer_select_card")
	layerBack:setBackGroundColorType(2)
	layerBack:setBackGroundColorOpacity(125)
	layerBack:setBackGroundColor(cc.c3b(0,0,0),cc.c3b(125,125,125))
	layerBack:setTouchEnabled(true)
	layerBack:addTouchEventListener(function(sender,event)
            if event == 2  then
            	SCENENOW["scene"]:cancelSelectCard()
            	layerBack:removeSelf()
            end
        end)

    local spBack = cc.Scale9Sprite:create("ddz_laizi/select_card/game_box01.png"):addTo(layerBack)
    spBack:setAnchorPoint(cc.p(0.5,0.5))
    local _size = spBack:getContentSize()
    spBack:setCapInsets(cc.rect(20,20,_size.width-40,_size.height-40))
    spBack:setPreferredSize(cc.size(width_back,height_back))
    spBack:setPosition(cc.p(480,200))
    --txt
    local spTxt = display.newSprite("ddz_laizi/select_card/text_xuanzeleixing.png"):addTo(spBack)
    spTxt:setPosition(width_back/2, height_back-spTxt:getContentSize().height/2+20)
    local offset_y = 20
    --新建内容
    for i, v in pairs(multiCards) do
    	if i > 3 then
    		break
    	end
	    local start_x = 10
    	local len = (#v)*cardDis + start_x*2
    	local spCardBack = cc.Scale9Sprite:create("ddz_laizi/select_card/game_box02.png"):addTo(spBack)
	    spCardBack:setAnchorPoint(cc.p(0.5,0.5))
	    _size = spCardBack:getContentSize()
	    spCardBack:setCapInsets(cc.rect(10,10,_size.width-20,_size.height-20))
	    spCardBack:setPreferredSize(cc.size(len,line_height))
	    -- spCardBack:setScale(0.7)
	    if i < 3 then
	    	if #multiCards < 2 then
	    		-- spCardBack:setPosition(cc.p(width_back/2,line_height*2-line_height/2+offset_y))
	    		spCardBack:setPosition(cc.p(width_back/2,line_height/2+offset_y))
	    	else
	    		print("run line this",tostring(lineCount))
	    		if lineCount < 2 then
	    			spCardBack:setPosition(cc.p(width_back/2-len/2-10+(i-1)*(len+20),line_height/2+offset_y))
	    		else
	    			spCardBack:setPosition(cc.p(width_back/2-len/2-10+(i-1)*(len+20),line_height*2-line_height/2+offset_y))
	    		end
	    	end
	    else
	    	spCardBack:setPosition(cc.p(width_back/2,line_height/2+offset_y))
	    end

	    dump(v,"showSelect"..tostring(i))
	    for k,m in pairs(v) do
	        local isLaizi = 0
	        if m[2] > 4 then
	        	isLaizi = 1
	        end
	        local img = require("ddz_laizi.Card"):getSmallCard(m[1],m[2],isLaizi,1)
	        img:addTo(spCardBack)
	        img:setPosition(cc.p(start_x+(k-1)*cardDis+cardDis/2,line_height/2))
	        img:setScale(0.65,0.7)
	    end
	    --点击区域
	    local layerTouch = ccui.Layout:create()

	    spCardBack:addChild(layerTouch)
	    layerTouch:setContentSize(spCardBack:getContentSize())
	    layerTouch:setTouchEnabled(true)
        layerTouch:addTouchEventListener(function(sender,event)
                if event == 2  then
                    print("select touch",tostring(i))
                    selectCards = v
                    dump(selectCards, "select cards")
                    self:sendPlayCard()
                end
            end)
    end
end

function SelectCard:sendPlayCard()
    local cardAmount = 0
    local cards = {}
    for key,value in pairs(selectCards) do
		local cardvalue = value[1] + value[2]*16
        if value[1] == require("ddz_laizi.Card"):getLaizi() then
            cardvalue = value[1] + 5*16
        end
		print("out card:%d   value:%d    type:%x",cardvalue,value[1],value[2]*16)
		cardvalue = require("ddz_laizi.Card"):Encode(cardvalue)
		local card = {}
		card["card"] = cardvalue
		table.insert(cards,card)
		cardAmount = cardAmount + 1
    end
    print("out cards----------->%s",json.encode(cards))
    --出牌
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_PLAYER_CARD)
                :setParameter("Cardcount", cardAmount)
                :setParameter("Cardbuf", cards)
                :build()
    bm.server:send(pack)

    local layer = SCENENOW["scene"]:getChildByName("layer_select_card")
    if layer then
    	layer:removeSelf()
    end
end

return SelectCard