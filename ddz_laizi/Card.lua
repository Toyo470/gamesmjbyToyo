
local tbKindValue = {
    [0] = "small_card_num_balck_",
    [1] = "small_card_num_",
    [2] = "small_card_num_balck_",
    [3] = "small_card_num_",
    [4] = "joker",
    [5] = "small_card_num_invisible_"
}
local tbKind = {
    [0] = "spades",
    [1] = "hearts",
    [2] = "clubs",
    [3] = "diamonds",
    [4] = "joker_tb",
    [5] = "invisible"
}

local VALUE = {
    
}


cc.utils                = require("framework.cc.utils.init")
cc.net                  = require("framework.cc.net.init")
require("config")

local Card  = class("Card");

function Card:init(value)
    self._value  = bit.band(15,value)
    self._kind   = bit.brshift(value,4)

end
--张林转易伟
function Card:Decode(value)
    local card = 0
    if value == 78 then
        card = 1 + 16*4
    elseif value == 79 then
        card = 2 + 16*4
    else
        local low = bit.band(15,value)
        if low == 1 then
            low = 14
        elseif low == 2 then
            low = 15
        end
        local hi = bit.brshift(value,4)
        card = low + hi*16
    end
    return card
end
--易伟转张林
function Card:Encode(value)
    local card = 0
    if value == 65 then
        card = 78
    elseif value == 66 then
        card = 79
    else
        local low = bit.band(15,value)
        if low == 14 then
            low = 1
        elseif low == 15 then
            low = 2
        end
        local hi = bit.brshift(value,4)
        card = low + hi*16
    end
    return card
end


--获得花色下的点数
function  Card:getCard(value,kind,isLandlord,isLaizi,bShow)

    local sizeWidth = 118
    local sizeHeight = 150
    local x = 1
    local y = 1
    local show_logo = isLandlord or 0
    local show_laizi = isLaizi or 0
    --底
    local spBack = cc.Scale9Sprite:create("ddz/Game/cards/small_card_bg.png")
    spBack:setAnchorPoint(cc.p(0.5,0.5))
    spBack:setPreferredSize(cc.size(sizeWidth,sizeHeight))
    --字
    local path = "#"..tbKindValue[tonumber(kind)]..tostring(value)..".png"
    if show_laizi == 1 then
        path = "#"..tbKindValue[tonumber(5)]..tostring(value)..".png"
    end
    local spUpValue = display.newSprite(path)
    spBack:addChild(spUpValue)
    x = 10 + spUpValue:getContentSize().width/2
    y = spBack:getContentSize().height - 10 - spUpValue:getContentSize().height/2
    spUpValue:setPosition(x, y)

    --花
    if kind == 4 then
        path = "#"..tbKind[tonumber(kind)]..tostring(value)..".png"
        local spUpKind = display.newSprite(path)
        spBack:addChild(spUpKind)
        x = sizeWidth/2
        y = 10 + spUpKind:getContentSize().height/2
        spUpKind:setPosition(x, y)
    else
        local spBottomValue = display.newSprite(path)
        spBottomValue:setRotation(180)
        spBack:addChild(spBottomValue)
        x = spBack:getContentSize().width - 10 -spBottomValue:getContentSize().width/2
        y = 10 + spBottomValue:getContentSize().height/2
        spBottomValue:setPosition(x, y)
        
        path = "#"..tbKind[tonumber(kind)]..".png"
        if show_laizi == 1 then
            path = "#"..tbKind[tonumber(5)]..".png"
        end
        local spUpKind = display.newSprite(path)
        spBack:addChild(spUpKind)
        x = spUpValue:getPositionX()
        y = spUpValue:getPositionY() - spUpValue:getContentSize().height/2 - 3 - spUpKind:getContentSize().height/2
        spUpKind:setPosition(x, y)

        local spBottomKink = display.newSprite(path)
        spBack:addChild(spBottomKink)
        x = spBottomValue:getPositionX()
        y = spBottomValue:getPositionY() + spBottomValue:getContentSize().height/2 + 3 + spBottomKink:getContentSize().height/2
        spBottomKink:setPosition(x, y)
    end
    if show_logo == 1 then
        local spLogo = self:getLogo(true)
        print("getCard")
        if spLogo then
            spBack:addChild(spLogo)
            spLogo:setPosition(cc.p(69,103))
        end
    end

    return spBack

end

--出牌
function Card:getOutCard(value,kind,isLandlord,isLaizi)
    local sizeWidth = 86
    local sizeHeight = 100
    local x = 1
    local y = 1
    local scale = 0.86
    local show_logo = isLandlord or 0
    local show_laizi = isLaizi or 0
    --底
    local spBack = cc.Scale9Sprite:create("ddz/Game/cards/small_card_bg.png")
    spBack:setAnchorPoint(cc.p(0.5,0.5))
    spBack:setPreferredSize(cc.size(sizeWidth,sizeHeight))
    --字
    local path = "#"..tbKindValue[tonumber(kind)]..tostring(value)..".png"
    if show_laizi == 1 then
        path = "#"..tbKindValue[tonumber(5)]..tostring(value)..".png"
    end
    local spUpValue = display.newSprite(path)
    spBack:addChild(spUpValue)
    x = 10 + spUpValue:getContentSize().width/2*scale
    y = spBack:getContentSize().height - 10 - spUpValue:getContentSize().height/2*scale
    spUpValue:setPosition(x, y)
    spUpValue:setScale(scale)


    if kind < 4 then
        --花
        path = "#"..tbKind[tonumber(kind)]..".png"
        if show_laizi == 1 then
            path = "#"..tbKind[5]..".png"
        end
        local spUpKind = display.newSprite(path)
        spBack:addChild(spUpKind)
        x = spUpValue:getPositionX()
        y = spUpValue:getPositionY() - spUpValue:getContentSize().height/2*scale - 3 - spUpKind:getContentSize().height/2*scale
        spUpKind:setPosition(x, y)
        spUpKind:setScale(scale)
    elseif kind == 5 then
        path = "#"..tbKind[5]..".png"
        local spUpKind = display.newSprite(path)
        spBack:addChild(spUpKind)
        x = spUpValue:getPositionX()
        y = spUpValue:getPositionY() - spUpValue:getContentSize().height/2*scale - 3 - spUpKind:getContentSize().height/2*scale
        spUpKind:setPosition(x, y)
        spUpKind:setScale(scale)
    else
        path = "#"..tbKind[tonumber(kind)]..tostring(value)..".png"
        if kind == 5 then
            path = "#"..tbKind[5]..".png"
        end

        local spUpKind = display.newSprite(path)
        spBack:addChild(spUpKind)
        x = sizeWidth/2
        y = 10 + spUpKind:getContentSize().height/2*0.5
        spUpKind:setPosition(x, y)
        spUpKind:setScale(0.5)

        local scale_x = 0.81
        local scale_y = 0.61
        x = 8 + spUpValue:getContentSize().width/2*scale_x
        y = spBack:getContentSize().height - 8 - spUpValue:getContentSize().height/2*scale_y
        spUpValue:setPosition(x, y)
        spUpValue:setScaleX(scale_x)
        spUpValue:setScaleY(scale_y)
    end

    if show_logo == 1 then
        local spLogo = self:getLogo()
        local scale = 0.75
        if spLogo then
            spBack:addChild(spLogo)
            spLogo:setScale(scale)
            spLogo:setPosition(cc.p(sizeWidth-spLogo:getContentSize().width*scale/2-5,spLogo:getContentSize().height*scale/2+6))
        end
    end

    return spBack
end

--地主logo
function Card:getLogo(flag)
    local rat = flag or false
    local spBack = display.newSprite("ddz/images/lord_bar.png")
    if spBack then
        local sp = display.newSprite("ddz/images/lord_bar_text_dizhu.png")
        spBack:addChild(sp)
        sp:setPosition(59, 56)
        if rat == true then
            sp:setRotation(45)
        else
            sp:setRotation(-135)
        end
    end
    if rat == false then
        spBack:setRotation(90)
    end
    return spBack
end


--获得小牌
function Card:getSmallCard(value,kind,isLaizi,state_select)

    local sizeWidth = 118
    local sizeHeight = 155
    local x = 1
    local y = 1
    local scale = 0.75
    local show_laizi = isLaizi or 0
    local isSelect = state_select or 0
    --底
    local spBack = display.newSprite("ddz/Game/cards/small_card_bg.png")
    spBack:setAnchorPoint(cc.p(0.5,0.5))
    --字
    local path = "#"..tbKindValue[tonumber(kind)]..tostring(value)..".png"
    if show_laizi == 1 then
        path = "#"..tbKindValue[tonumber(5)]..tostring(value)..".png"
    end
    local spUpValue = display.newSprite(path)
    spBack:addChild(spUpValue)
    x = 8 + spUpValue:getContentSize().width/2*scale
    y = spBack:getContentSize().height - 8 - spUpValue:getContentSize().height/2*scale
    spUpValue:setPosition(x, y)
    spUpValue:setScale(scale)

    if kind < 4 or isSelect == 1 then
        --花
        path = "#"..tbKind[tonumber(kind)]..".png"
        if show_laizi == 1 then
            path = "#"..tbKind[tonumber(5)]..".png"
        end
        local spUpKind = display.newSprite(path)
        spBack:addChild(spUpKind)
        -- x = spBack:getContentSize().width - 8 - spUpKind:getContentSize().width/2*scale
        x = spBack:getContentSize().width/2
        y = spUpValue:getPositionY() - spUpValue:getContentSize().height/2*scale - 3 - spUpKind:getContentSize().height/2*scale
        spUpKind:setPosition(x, y)
        spUpKind:setScale(scale)
    elseif kind == 5 then
        path = "#"..tbKind[5]..".png"
        local spUpKind = display.newSprite(path)
        spBack:addChild(spUpKind)
        -- x = spBack:getContentSize().width - 8 - spUpKind:getContentSize().width/2*scale
        x = spBack:getContentSize().width/2
        y = spUpValue:getPositionY() - spUpValue:getContentSize().height/2*scale - 3 - spUpKind:getContentSize().height/2*scale
        spUpKind:setPosition(x, y)
        spUpKind:setScale(scale)
    else
        scale = 0.35
        local scale_x = 0.5
        local scale_y = 0.35
        x = 8 + spUpValue:getContentSize().width/2*scale_x
        y = spBack:getContentSize().height - 8 - spUpValue:getContentSize().height/2*scale_y
        spUpValue:setPosition(x, y)
        -- spUpValue:setScale(scale)
        spUpValue:setScaleX(scale_x)
        spUpValue:setScaleY(scale_y)
    end

    return spBack
end
--给用的牌组增加
function Card:addCard(card)
    local key = self:getKey(card._value,card._kind)
    if  not USER_INFO["cards"] then
        USER_INFO["cards"] = {}
    end
    table.insert(USER_INFO["cards"], {card._value,card._kind,0,0,0})
    return key
end

--将用户的牌排序
function Card:sortCard()

    table.sort(USER_INFO["cards"],function(a,b) 
        -- if a[1] == self._laiziValue then
        --     print("Card:sortCard",tostring(self._laiziValue))
        --     return true
        -- end
        if( a[2]  == 4 and b[2] == 4) then
            return a[1]>b[1]
        end

        if(a[2] == 4 and b[2] ~= 4) then
            if self._laiziValue then
                if b[1] == self._laiziValue then
                    return false
                end
            end
            return true
        end

        if(a[2] ~= 4 and b[2] == 4) then
            if self._laiziValue then
                if a[1] == self._laiziValue then
                    return true
                end
            end
            return false
        end

        if(a[2] ~= 4 and b[2] ~= 4) then
            if a[1] == b[1] then
                return a[2] < b[2]
            else
                if self._laiziValue then
                    if a[1] == self._laiziValue then
                        return true
                    end
                    if b[1] == self._laiziValue then
                        return false
                    end
                end
                return a[1]>b[1]
            end

        end

    end )

end
--获得拍的唯一索引
function Card:getKey(value,kind)
    local re = value + (kind + 100) * 20
    return re
end

--通过tag找寻card数组的下表
function Card:getCardIndex(tag)

    for key,value in pairs(USER_INFO["cards"]) do
        local now_tag = self:getKey(value[1],value[2])
        if now_tag == tag then
            return key
        end
    end
end



--将牌组装成字符串
function Card:dealCardToString(table_tmp)
    local str  = ""

    for key,value in pairs(table_tmp) do

        local kind      = bit.blshift(value[2],4)
       
        local  value           = bit.band(15,value[1]) 
        

        local all = kind + value
        
        local byte = string.char(all)
        str  = str..byte 
    end

    return str
end

--设置癞子牌值
function Card:setLaizi(card)
    self._laiziValue = card
end
--获取癞子牌
function Card:getLaizi()
    return self._laiziValue
end
--是否癞子牌
function Card:isLaizi(value)
    if self._laiziValue then
        if self._laiziValue == value then
            return 1
        end
    end
    return 0
end

return Card


