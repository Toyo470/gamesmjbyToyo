--
-- Author: zt
-- Date: 2016-08-18 17:58:21
--

--录制视频的播放
--



local transcribeScene=class("transcribeScene",function()
        return display.newScene();
    end)

local hide_ui={
    
}

local ui_set={
    headPnale="Panel_head_",
    txt_base="score_base_txt",
    zhuang_sp="zuan_tip",
    head_sp="Image_3",
    nick_txt="Text_1",
    handcardlayer="Panel_18_shoupai",
    tecard="Panel_20_te",
    dacard="Panel_21_da",
    sp_Que="sp_clock",
    zhua_cars="Panel_22_zhua",
    sp_Rotary="Panel_timer",
    sp_perform="Panel_15_"
}



local cadrsdir={
    [0]="",
    [1]="",
    [2]="",
    [3]="",
}



--杠的时候第四张牌要摆放的偏移量
local gangPos={
    [0]={x=40,y=40},
    [1]={x=0,y=44},
    [2]={x=-27,y=30},
    [3]={x=0,y=0}
}


local da_card_pos={
    [0]={x=420,y=220},
    [1]={x=593,y=252},
    [2]={x=523,y=367},
    [3]={x=337,y=338}
}--出的牌的起始坐标

local daCardstartPos={
    [0]={x=40,y=40},
    [1]={x=820,y=120},
    [2]={x=795,y=495},
    [3]={x=145,y=510}
}--碰撞牌的起始坐标

local cardsImg="hall/majiangCard/"

function transcribeScene:ctor(handle)
    self._handle=handle
    self:initData()
    self.rootNode = cc.CSLoader:createNode("hall/roomPlay/PokerGame/poker_record.csb"):addTo(self)

    local transcribeNode=self.rootNode:getChildByName("caozuo")
    local btn_play=transcribeNode:getChildByName("btn_play")
    local btn_speed=transcribeNode:getChildByName("btn_speed")
    local btn_back=transcribeNode:getChildByName("btn_back")
    local btn_exit_vedio=transcribeNode:getChildByName("btn_exit_vedio")
    
    
    btn_play.noScale=true
    btn_play:onClick(handler(self, self.play))
    btn_speed.noScale=true
    btn_speed:onClick(handler(self, self.play))
    btn_back.noScale=true
    btn_back:onClick(handler(self, self.play))
    btn_exit_vedio.noScale=true
    btn_exit_vedio:onClick(handler(self, self.play))
    btn_play.isPlay=false
end

function transcribeScene:play(sender)
    self._handle:onControllBack(sender);
end


function transcribeScene:initData()
    self.user_head={}
    self.nodeCard={} --手牌
   

    self.teCard={} --彭转
    self.daCard={}--打出的牌


     self.cardsPos={
        [0]={x=0,y=0},
        [1]={x=0,y=0},
        [2]={x=0,y=0}
    }--手牌起始的坐标 


    self.currCards=nil --正在打出的牌


    self.daDataCard={
         [0]={index_key=0,lie=1,pos={x=0,y=0}},
         [1]={index_key=0,lie=1,pos={x=0,y=0}},
         [2]={index_key=0,lie=1,pos={x=0,y=0}}
    }


    for k,v in pairs(self.cardsPos) do
        self:resetHandleCardPos(k,{x=0,y=0})
    end

end

--重新设置手牌的位置
--终点的坐标
-- pos 代表打出的牌的寛高
function transcribeScene:resetHandleCardPos(seatId,pos)

    self.cardsPos[seatId].x=daCardstartPos[seatId].x
    self.cardsPos[seatId].y=daCardstartPos[seatId].y
    if seatId==0 then
        --todo
        self.cardsPos[seatId].x=self.cardsPos[seatId].x+pos.x+10;
    elseif seatId==1 then

        self.cardsPos[seatId].y=self.cardsPos[seatId].y+pos.y+8
    
    elseif seatId==2 then
        self.cardsPos[seatId].x=self.cardsPos[seatId].x+pos.x-10
    end

end

function transcribeScene:cleanUI()

end



--设置低注
function transcribeScene:setBase(base)
    print("setBase",tostring(base))
    local txt_base_chip = self.rootNode:getChildByName("txt_base_chip")
    print(type(txt_base_chip))
    if txt_base_chip then
        txt_base_chip:setString("底分:"..tostring(base))
    end

end

function transcribeScene:updateStep(num)
    local txt_step = self.rootNode:getChildByName("txt_step")
    if txt_step then
        txt_step:setString(num)
    end
end


--显示panle
function transcribeScene:setHead(userInfo)
    dump(userInfo,"transcribeScene:setHead")
    for k,v in pairs(userInfo) do
        print("···","touxiangbufen_"..tostring(v["seat_id"]))
        local panle = self.rootNode:getChildByName("touxiangbufen_"..tostring(v["seat_id"]))
        local sp_head = panle:getChildByName("head")
        local nickName = panle:getChildByName("Text_13")
        local my_textGold = panle:getChildByName("gold_mine")

        if sp_head then
            print("++++++++++++++++++++++sp_head++++++++++++++++++++++++++++++++++++")
            local user_inf = {}
            user_inf["uid"] = v.uid
            user_inf["icon_url"] =v.icon_url
            user_inf["sex"] = v.sex
            user_inf["nick"] = v.nick
            require("hall.GameCommon"):setPlayerHead(user_inf,sp_head,70)
        end
        my_textGold:setString(v.gold)
        my_textGold:setVisible(true)
        if string.utf8len(v.nick)>9 then
            --todo
            v.nick=string.sub(v.nick,1,9)
            v.nick=v.nick..".."
        end
        nickName:setString(v.nick)
        panle.sex=v.sex
        panle.uid = v.uid
        panle.seatid = v.seat_id
        panle.gold = v.gold
        print("性别是",panle.sex)

        table.insert(self.user_head,panle)

    end
end


function transcribeScene:getseat_id(uid)
    for k,v in pairs(self.user_head) do
        if v.uid==uid then
            --todo
            return v.seatid;
        end
    end
    printError("error getPanle is nil", uid)
end

--手牌的牌
--牌已经排好了
--手牌的起始位置
function transcribeScene:showHandCards(seat_id,cards)

    dump(cards, "seat_cards "..tostring(seat_id))
    local pl_hand_card = self.rootNode:getChildByName("pl_hand_card")
    if pl_hand_card == nil then
        return
    end
    local par = pl_hand_card:getChildByName("hand_card"..tostring(seat_id))
    if par then
        par:removeSelf()
        self.nodeCard[seat_id+1] = nil
    end
    par = self.nodeCard[seat_id+1]
    if par then
        print("showHandCards removeAllChildren")
        par:removeAllChildren()

    else
        par = cc.Node:create():addTo(pl_hand_card,90)
        par:setAnchorPoint(cc.p(0.5,0.5))
        self.nodeCard[seat_id+1] = par
        par:setPosition(cc.p(0,0))
        par:setName("hand_card"..tostring(seat_id))
    end



    local len = #cards

    if seat_id == 0 then
        local startx = 30
        local xCenter = 480
        local dis    = (960-startx*2)/len
        if dis > 52 then
            dis = 52
        end
        startx = (960 - (len-1)*dis)/2--(100+dis*(len - 1))/2--480-(len-1)*25
        -- print("dis",tostring(dis),tostring(startx))
        for key, v in pairs(cards) do
            -- print("showHandCards ",tostring(key))
            local spCard = require("hall.roomPlay.PokerGame.Card"):getCard(v[1],v[2])
            if spCard then
                spCard:setPosition(startx + dis*(key-1), 90)
            end
            par:addChild(spCard)
        end
    elseif seat_id == 1 then
        local startx = 840
        local dis = 25
        if #cards > 10 then
            startx = 840 - dis*10
        else
            startx = 840 - dis*(#cards)
        end
        -- print("dis",tostring(dis),tostring(startx))
        local row = 0
        local count = 1
        for key, v in pairs(cards) do
            -- print("showHandCards ",tostring(key),tostring(v[1]),tostring(v[2]))
            local spCard = require("hall.roomPlay.PokerGame.Card"):getCard(v[1],v[2])
            if key > 10 then
                if key == 11 then
                    count = 1
                    startx = 840 - dis*(#cards-10)
                end
                row = 1
            end
            if spCard then
                spCard:setScale(0.5)
                spCard:setPosition(startx + dis*(count-1), 480-row*30)
            end
            par:addChild(spCard)

            count = count + 1
        end
    elseif seat_id == 2 then
        local startx = 140
        local dis = 25
        local row = 0
        local count = 1
        for key, v in pairs(cards) do
            local spCard = require("hall.roomPlay.PokerGame.Card"):getCard(v[1],v[2])
            if key > 10 then
                if key == 11 then
                    count = 1
                    startx = 140
                end
                row = 1
            end
            if spCard then
                spCard:setScale(0.5)
                spCard:setPosition(startx + dis*(count-1), 480-row*30)
            end
            par:addChild(spCard)

            count = count + 1
        end
    end
end

--出牌
function transcribeScene:Chu_card(seat_id,cards)

    local pl_out_card = self.rootNode:getChildByName("pl_out_card")
    if pl_out_card == nil then
        return
    end
    local node = pl_out_card:getChildByName("node"..tostring(seat_id))
    if node then
        node:removeSelf()
    end

    local tb={}
    for k1,v1 in pairs(cards) do
        local card = require("hall.roomPlay.PokerGame.Card"):Decode(v1)
        local _value  = bit.band(15,card)
        local _kind   = bit.brshift(card,4)
        table.insert(tb,{_value,_kind})
    end
    table.sort(tb,function(a,b)
            if a[1] == b[1] then
                return a[2] > b[2]
            else
                return a[1]>b[1]
            end
        end)

    dump(tb, "Chu_card "..tostring(seat_id))
    offerx = offerx or 35
    node = display.newNode()

    node:addTo(pl_out_card,100)

    node:setName("node"..seat_id)
    local start = 0
    local  yh   = 0
    if seat_id==0 then
        local count = #tb 
        start       = 480 - ((count-1)*offerx)  /2
        yh          = 230
    elseif seat_id==1 then        
        local count = #tb 
        start       = 800 - ((count-1)*offerx+50)
        yh          = 390
    elseif seat_id==2 then
        yh    = 390
        start = 200
    end
    local i = 0

    for k,v in pairs(tb) do
        local img = require("hall.roomPlay.PokerGame.Card"):getOutCard(v[1],v[2],0)
        img:addTo(node)
        img:setPosition(cc.p(start+i*offerx,yh))
        i = i + 1
    end
end

local v_pos_effect = {{480,250},{760,400},{200,400}}
--pass
function transcribeScene:Pass( seat_id )
    -- body
    local pl_out_card = self.rootNode:getChildByName("pl_out_card")
    if pl_out_card == nil then
        return
    end
    local node = pl_out_card:getChildByName("node"..tostring(seat_id))
    if node then
        node:removeSelf()
    end

    local sp = display.newSprite("hall/roomPlay/PokerGame/res/ddz_text_buchu.png")
    -- sp:setScale(0.8)
    sp:setName("node"..tostring(seat_id))
    
    sp:addTo(pl_out_card,100)
    sp:setPosition(cc.p(v_pos_effect[seat_id+1][1],v_pos_effect[seat_id+1][2]))

end

--清桌子
function transcribeScene:clearDesktop()
    local pl_out_card = self.rootNode:getChildByName("pl_out_card")
    if pl_out_card == nil then
        return
    end
    for k, v in pairs(self.user_head) do
        local node = pl_out_card:getChildByName("node"..tostring(v["seatid"]))
        if node then
            node:removeSelf()
        end
    end
    
end

--ytype 执行的操作
--执行了的操作
function transcribeScene:execute(seatid,ytype,callfun)

    local sp_perform=self.rootNode:getChildByName(ui_set.sp_perform..seatid)
    local node=sp_perform:getChildByName("majong_guo_"..ytype)
    local ac=cc.RepeatForever:create(cc.Sequence:create(cc.ScaleTo:create(0.2, 0.55),cc.ScaleTo:create(0.2, 0.65)))
    node:runAction(ac);

    
    local ac2=cc.Sequence:create(cc.DelayTime:create(2),cc.CallFunc:create(function()
            --隐藏所有的额
            for i=1,4 do
                local sp_perform=self.rootNode:getChildByName(ui_set.sp_perform..(i-1))
                sp_perform:hide()
            end
            callfun(seatid);
        end))
    sp_perform:runAction(ac2);

end

--隐藏结果页面
function transcribeScene:unshowResult()
    local result = self.rootNode:getChildByName("pl_out_card"):getChildByName("result_node")
    if result then
        result:removeSelf()
    end
end
--显示结算界面
function transcribeScene:showAccount(tb)

    dump(tb, "showAccount")
    local result_node = cc.CSLoader:createNode("hall/roomPlay/PokerGame/game_result.csb"):addTo(self.rootNode:getChildByName("pl_out_card"),1000)
    for k, v in pairs(tb) do
        local pl_userinfo = result_node:getChildByName("pl_userinfo_"..tostring(v["seat_id"]))

        if pl_userinfo then
            local sp_head = pl_userinfo:getChildByName("gold_28")

            if sp_head then
                local user_inf = {}
                user_inf["uid"] = v["uid"]
                user_inf["icon_url"] =v["photo_url"]
                user_inf["sex"] = v["sex"]
                user_inf["nick"] = v["nickName"]
                require("hall.GameCommon"):setPlayerHead(user_inf,sp_head,70)
            end
            local txt_nick = pl_userinfo:getChildByName("txt_nick")
            if txt_nick then
                txt_nick:setString(require("hall.GameCommon"):formatNick(v["nickName"]))
            end
            local txt_card_num = pl_userinfo:getChildByName("txt_card_num")
            if txt_card_num then
                txt_card_num:setString(v["card_count"])
            end
            local txt_bomb_times = pl_userinfo:getChildByName("txt_bomb_times")
            if txt_bomb_times then
                txt_bomb_times:setString(v["bomb_times"])
            end
            local txt_win = pl_userinfo:getChildByName("txt_win")
            if txt_win then
                txt_win:setVisible(false)
            end
            local txt_lose = pl_userinfo:getChildByName("txt_lose")
            if txt_lose then
                txt_lose:setVisible(false)
            end
            if v["win"] > 0 then
                if txt_win then
                    txt_win:setVisible(true)
                    txt_win:setString(v["win"])
                end
            else
                if txt_lose then
                    txt_lose:setVisible(true)
                    txt_lose:setString(v["win"])
                end
            end
        end

        --设置分数
        local panle = self.rootNode:getChildByName("touxiangbufen_"..tostring(v["seat_id"]))
        if panle then
            local my_textGold = panle:getChildByName("gold_mine")
            if my_textGold then
                my_textGold:setString(v["gold"])
                my_textGold:setVisible(true)
            end

        end
    end

    local txt_game_no = result_node:getChildByName("txt_game_no")
    if txt_game_no then
        txt_game_no:setVisible(false)
    end
    result_node:setName("result_node")
end

function transcribeScene:onExit()

end

return transcribeScene