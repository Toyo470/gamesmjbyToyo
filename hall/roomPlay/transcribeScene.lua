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
    self:initData();
    self.rootNode            = cc.CSLoader:createNode("hall/room_vedio.csb"):addTo(self)
    for k,v in pairs(hide_ui) do
        local node=self.rootNode:getNode(v)
        node:hide();
    end
    print("ui_set.handcardlayer")
    local node_card_par=self.rootNode:getNode(ui_set.handcardlayer)--手牌
    for i=1,4 do
        local node_card=cc.Node:create()--手牌这个图层
        node_card_par:addChild(node_card)
       -- node_card:setPosition(v.x,v.y);
        node_card:setAnchorPoint(cc.p(0,0))
        --node_card_par:hide()
        table.insert(self.nodeCard,node_card)
    end
    
    node_card_par=self.rootNode:getNode(ui_set.tecard) --特殊的手牌
    for k,v in pairs(daCardstartPos) do
        local node_card=cc.Node:create()--特殊的牌这个图层
        node_card:setAnchorPoint(cc.p(0,0))
        node_card_par:addChild(node_card) 
        table.insert(self.teCard,node_card);
        node_card:setPosition(v)
    end

    node_card_par=self.rootNode:getNode(ui_set.dacard)
    for k,v in pairs(da_card_pos) do
        local node_card=cc.Node:create()--出的牌
        node_card:setAnchorPoint(cc.p(0,0))
        node_card_par:addChild(node_card) 
        table.insert(self.daCard,node_card);
        node_card:setAnchorPoint(cc.p(0,0));
        node_card:setPosition(v.x,v.y);
        --endDa_pos[k]={x=v[1],y=v[2]};
    end
    
    self.zhua_cards={} --零食抓牌
    node_card_par=self.rootNode:getNode(ui_set.zhua_cars)
    for i=1,4 do
        local node=cc.Node:create()
        node:setAnchorPoint(cc.p(0,0))
        node_card_par:addChild(node)
       -- node:setScale(0.6);
        table.insert(self.zhua_cards,node)
    end

    
    self.txt_bureauNum=self.rootNode:getChildByName("Text_12")

    local transcribeNode=self.rootNode:getChildByName("caozuo")
    local btn_play=transcribeNode:getChildByName("Button_19")
    local btn_speed=transcribeNode:getChildByName("Button_21")
    local btn_back=transcribeNode:getChildByName("Button_18")
    local btn_exit_vedio=transcribeNode:getChildByName("Button_1")
    
    
    btn_play.noScale=true
    btn_play:onClick(handler(self, self.play))
    btn_speed.noScale=true
    btn_speed:onClick(handler(self, self.play))
    btn_back.noScale=true
    btn_back:onClick(handler(self, self.play))
    btn_exit_vedio.noScale=true
    btn_exit_vedio:onClick(handler(self, self.play))
    btn_play.isPlay=false

     --btn_play:loadTextures("hall/roomPlay/video_stop.png","hall/roomPlay/video_stop.png")

    if device.platform~="windows" then
        --todo
        audio.playMusic("hall/roomPlay/music/BG_283.mp3", true)
    end
    
    self.isPlayMusic=true


    self.panAccoutUI=self.rootNode:getNode("Panel_1")
    if self.panAccoutUI then
        --todo
        self.panAccoutUI:hide();
    end
   
    self.panAccoutUI:onClick(function()

            local tb_ui={self.nodeCard,self.teCard,self.daCard,self.zhua_cards}
            for k,v in pairs(tb_ui) do
                for k1,v1 in pairs(v) do
                    v1:show();
                end
            end
            self.panAccoutUI:hide()
        end)


    self.cs_manyou=self.rootNode:getNode("Panel_4")
    --长沙麻将 漫游
    if self.cs_manyou then
        --todo
        self.cs_manyou:hide();
    end

    self:cleanUI();
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
        [2]={x=0,y=0},
        [3]={x=0,y=0}
    }--手牌起始的坐标 


    self.currCards=nil --正在打出的牌


    self.daDataCard={
         [0]={index_key=0,lie=1,pos={x=0,y=0}},
         [1]={index_key=0,lie=1,pos={x=0,y=0}},
         [2]={index_key=0,lie=1,pos={x=0,y=0}},
         [3]={index_key=0,lie=1,pos={x=0,y=0}}

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
    else
        self.cardsPos[seatId].y=self.cardsPos[seatId].y+pos.y-12
    end

end

function transcribeScene:cleanUI()

    local tb={self.nodeCard,self.teCard,self.daCard,self.zhua_cards}
    for k,v in pairs(tb) do
        for k1,v1 in pairs(v) do
            v1:removeAllChildren();
        end
    end

    --方向
    local sp_rotary=self.rootNode:getChildByName(ui_set.sp_Rotary)
    --sp_rotary:hide()

    for k,v in pairs(sp_rotary:getChildren()) do
        if v:getName()~="Sprite" then
            --todo
            v:stopAllActions()
            v:hide();
        end
        
    end

    --把可以做的操作那些移除掉
    for i=0,3 do
        local sp_perform=self.rootNode:getChildByName(ui_set.sp_perform..i) --可以做的操作的显示
        --sp_perform:removeAllChildren();
        sp_perform:hide();

        for k,v in pairs(sp_perform:getChildren()) do
            --v:setScale(0.5)
            v:stopAllActions();
        end
    end


    if not tolua.isnull(self.currCards) then
        --todo
        self.currCards:removeAllChildren();
    end


    for k,v in pairs(self.user_head) do

        local c=v:getChildByName("magnify_card")
        local c1=v:getChildByName("pengzhuantexiao")
        local c2=v:getChildByName("hu_pao");
        local c3=v:getChildByName("hu");
        if not tolua.isnull(c) then
            --todo
            c:removeSelf()
            c=nil;
        end

        if not tolua.isnull(c1) then
            --todo
            c1:removeSelf()
            c1=nil;
        end

        if not tolua.isnull(c2) then
            --todo
            c2:removeSelf()
            c2=nil;
        end

        if not tolua.isnull(c3) then
            --todo
            c3:removeSelf()
            c3=nil;
        end

        
    end

    -----------------------
    self.cs_manyou:hide()
    local _sp_bg_=self.cs_manyou:getNode("effect_light_6")
    _sp_bg_:stopAllActions()
end



--设置低注
function transcribeScene:setBase(base,zhuanid,num)
    local txt_base=self.rootNode:getNode(ui_set.txt_base)
    txt_base:setString(base);
    txt_base:show()
    self.txt_bureauNum:setString(num)

    -- if not  zhuanid or zhuanid<=0 then
    --     --todo
    --     return;
    -- end
    --local seatid=self:getseat_id(zhuanid)
    local panle=self:getPanleForSeatId(zhuanid);
    local zhuang_sp=panle:getChildByName(ui_set.zhuang_sp)
    zhuang_sp:show()


end

function transcribeScene:updateStep(num)
    self.txt_bureauNum:setString(num)
end


--显示panle
function transcribeScene:setHead(userInfo)
    print_lua_table(userInfo)
    for k,v in pairs(userInfo) do
        local panle=self.rootNode:getChildByName(ui_set.headPnale..k);
        panle.seatid=k;
        panle.uid=v.uid
        local sp_head=panle:getChildByName(ui_set.head_sp);
        local nickName=panle:getChildByName(ui_set.nick_txt);
        local QUE=panle:getChildByName(ui_set.sp_Que)
        local zhuang_id=panle:getChildByName(ui_set.zhuang_sp);
        local my_textGold=panle:getChildByName("gold")
        QUE:hide()
        zhuang_id:hide()

        if sp_head then
            print("++++++++++++++++++++++sp_head++++++++++++++++++++++++++++++++++++")
            local user_inf = {}
            user_inf["uid"] = v.uid
            user_inf["icon_url"] =v.icon_url
            user_inf["sex"] = v.sex
            user_inf["nick"] = v.nick
            require("hall.GameCommon"):setPlayerHead(user_inf,sp_head,70*0.77)
        end
        my_textGold:setString(v.gold)
        if string.utf8len(v.nick)>9 then
            --todo
            v.nick=string.sub(v.nick,1,9)
            v.nick=v.nick..".."
        end
        nickName:setString(v.nick)
        panle.sex=v.sex
        print("性别是",panle.sex)

        table.insert(self.user_head,panle)

    end
end

function transcribeScene:getPanleForSeatId(seatid)
    for k,v in pairs(self.user_head) do
        if v.seatid==seatid then
            --todo
            return v;
        end
    end
    print(seatid)
    printError("error getPanle is nil")
    return nil
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
-- 1 you
-- 2 shang 
-- 3 zuo
-- 4 xia
function transcribeScene:showHandCards(seat_id,cards)

    --local seat_id=self:getseat_id(uid);
    -- dump(self.cardsPos[seat_id],"desciption3")
    local par=self.nodeCard[seat_id+1]
    par:removeAllChildren();

    local parPos=self.cardsPos[seat_id]

    local node,pos=self:drawcards3(seat_id,cards)
    --local node,endPos=self:drawCars(seat_id,cards,par)
    par:addChild(node)

    par:setPosition(parPos)

    -- self.handCardEndPos[seat_id].x=pos.x
    -- self.handCardEndPos[seat_id].y=pos.y

end



--绘制一段牌
--牌的节点
--最后一张牌所在的父节点的位置
--牌的起始摆放点是右下
local sp_bg_cards={
    [0]="Image_13",
    [1]="Image_1",
    [2]="Image_4",
    [3]="Image_1_0",
    [4]="myTeCard",--自己特殊的碰杠
    [5]="Image_2"--我自己打出的牌
}

local sp_anCard={
    [0]="my_small_back_card01.png",
    [1]="lr_back_card01.png",
    [2]="top_back_card01.png",
    [3]="lr_back_card01.png",    
}


--这里只是显示绘制一张牌
--按的id
function transcribeScene:drawCards2(card,cloneTb,isan)

    local sp= self.rootNode:getChildByName(sp_bg_cards[cloneTb]):clone();
    sp_bgCard=sp:getChildByName("Image_14");
    if isan then
        --todo
        sp:loadTexture("hall/roomPlay/"..sp_anCard[isan])
        sp_bgCard:hide()
    else
        if  card.type_color then
            if self._handle:getGameType()==4 and card.val==65 then
                --todo
                 sp_bgCard:loadTexture(cardsImg..card.type_color.."/".."65_1"..".png")

            else
                 sp_bgCard:loadTexture(cardsImg..card.type_color.."/"..card.val..".png")
            end
        end
       
    end
    --sp:setAnchorPoint(cc.p(0,0));
    sp.card=card
    return sp;
end

--画一些牌
function transcribeScene:drawcards3(seat_id,cards,isan)
    local pos={x=0,y=0};
    local z=0
    local node_pr=cc.Node:create()
    --node_pr:setAnchorPoint(0,0)
    for k,v in pairs(cards) do
        local node=self:drawCards2(v,seat_id,isan)
        node:setPosition(pos)
        if seat_id==0 or seat_id==4 or seat_id==5 then
            --todo
            pos.x=pos.x+node:getWidth();
        elseif seat_id==1 then
            z=50-k
            pos.y=pos.y+node:getHeight()-11;
        elseif seat_id==2 then
            pos.x=pos.x-node:getWidth()+2;
        else
            pos.y=pos.y-node:getHeight()+11;
        end
        node_pr:addChild(node,z)
    end
    return node_pr,pos;
end

--碰撞吃的牌的显示
--414,{type=1,card={}}0 吃 type==1 碰 type==2 明杠 type==3暗杠 
function transcribeScene:showPengZhuanCards(seat_id,cards)

    local par=self.teCard[seat_id+1]
    local card_id=seat_id
    if seat_id==0 then
         --todo
        card_id=4
    end 
    local strPos={x=0,y=0}

    par:removeAllChildren();
    --local interval=3--间隔

  

    for k,v in pairs(cards) do
        
        local node,endpos
        if v.type>=1 then
            --todo
            if v.type==3 then
                --todo
                node,endpos=self:drawcards3(card_id,{v.card,v.card,v.card},seat_id)
            else
                node,endpos=self:drawcards3(card_id,{v.card,v.card,v.card})
            end

            if v.type~=1  then --杠的话要在中间补一张牌
                
                --dump(endPos,"myTest position")
                local node_=self:drawCards2(v.card,card_id);
                node_:setAnchorPoint(0.5,1)
                node:addChild(node_,50)
                node_:setPosition(gangPos[seat_id])
                local sex=self:getPanleForSeatId(seat_id).sex
                if self.isPlayMusic then
                    --todo
                    if sex=="1" then
                    --todo
                        audio.playSound("hall/roomPlay/music/malesound/male1_gang0.mp3")
                    else
                        audio.playSound("hall/roomPlay/music/femalesound/female1_gang0.mp3")
                    end
                end
                
            else
                local sex=self:getPanleForSeatId(seat_id).sex
                if self.isPlayMusic then
                    --todo
                    if sex=="1" then
                    --todo
                        audio.playSound("hall/roomPlay/music/malesound/male1_peng0.mp3")
                    else
                        audio.playSound("hall/roomPlay/music/femalesound/female1_peng0.mp3")
                    end
                end
                
            end--
        else--吃
            node,endpos=self:drawcards3(card_id,{v.card[1],v.card[2],v.card[3]})
            local sex=self:getPanleForSeatId(seat_id).sex
            if self.isPlayMusic then
                --todo
                if sex=="1" then
                --todo
                    audio.playSound("hall/roomPlay/music/malesound/male1_peng0.mp3")
                else
                    audio.playSound("hall/roomPlay/music/femalesound/female1_peng0.mp3")
                end
            end
        end
        par:addChild(node)
        if seat_id==0 then
            --todo
            node:setPositionX(strPos.x)
            strPos.x=strPos.x+endpos.x+3
            strPos.y=daCardstartPos[seat_id].y
        elseif seat_id==1 then
            node:setPositionY(strPos.y)
            strPos.y=strPos.y+endpos.y+8
            strPos.x=daCardstartPos[seat_id].x
        elseif seat_id==2 then
            node:setPositionX(strPos.x)
            strPos.x=strPos.x+endpos.x-3
            strPos.y=daCardstartPos[seat_id].y
        else
             node:setPositionY(strPos.y)
            strPos.y=strPos.y+endpos.y-8
            strPos.x=daCardstartPos[seat_id].x
        end

        
    end

    dump( strPos,"setter end pos")
    self:resetHandleCardPos(seat_id,strPos)

end

-- local hu_image={
--     [0]="majong_hu_bt_p",
--     [1]="majong_zimo_bt_p",--自摸
--     [2]="majong_pinghu_bt_p",--平湖
--     [3]="mahjong_dianpao_bt_p"--点炮
-- }
-- function transcribeScene:hu_effrct(seat_id,t,pao_seatid)
--     --胡了一个了
--     --先显示胡牌的特效
--     print("播放胡牌特效",seat_id)
--     local panle=self:getPanleForSeatId(seat_id);
--     local sp=cc.Sprite:create("hall/roomPlay/"..hu_image[t]..".png")


--     if seat_id==0 then
--         --todo
--         sp:setAnchorPoint(cc.p(0,0))
--     elseif seat_id==1 then
--         sp:setAnchorPoint(cc.p(1,0))
--     elseif seat_id==2 then 
--         sp:setAnchorPoint(cc.p(0,1))
--     else
--         sp:setAnchorPoint(cc.p(0,0))
--     end
--     panle:addChild(sp)
--     sp:setName("hu");

--     -- local panle=self:getPanleForSeatId(pao_seatid);
--     -- local sp=cc.Sprite:create("hall/roomPlay/"..hu_image[3]..".png")
--     -- panle:addChild(sp)
--     -- sp:setName("hu_pao");
--     -- local ac=cc.Sequence:create(cc.DelayTime:create(2),cc.RemoveSelf:create())
--     -- sp:runAction(ac);

-- end

--设置剩余的牌输
function transcribeScene:setCardsNum(num_)
    local num=self.rootNode:getChildByName("left_card_num")
    num:setString(num_);
end


--插入一张牌
function transcribeScene:insertDa_cards(seat_id,card)
    local data=self.daDataCard[seat_id] --打的牌的数据
    --local index_key=data.index_key --当前这一排打到弟多少个了
    --local lie=data.lie  --当前是第多少列
    --local pos=data.pos --当前打到的牌的标


    local cardId=seat_id
    if cardId==0 then
        --todo
        cardId=5
    end
    local node=self:drawCards2(card,cardId);
    node:setPosition(data.pos)

    data.index_key=data.index_key+1



    if data.index_key>=5+(data.lie-1)*2 then --超过一行了 没有超过
        data.index_key=0;
        data.lie=data.lie+1;
        --设置节点的位置
        if seat_id==0 then
            --todo
            data.pos.x=0-node:getWidth()*(data.lie-1);
            data.pos.y=data.pos.y-35
        elseif seat_id==1 then
            data.pos.x=data.pos.x+35;
            data.pos.y=0-(node:getHeight()-11)*(data.lie-1)
        elseif seat_id==2 then
            data.pos.x=0+(node:getWidth()+2)*(data.lie-1);
            data.pos.y=data.pos.y+35
        else
            data.pos.x=data.pos.x-37;
            data.pos.y=0+(node:getHeight()-11)*(data.lie-1)
        end
    else
        if seat_id==0 or seat_id==4 or seat_id==5 then
            --todo
            data.pos.x=data.pos.x+node:getWidth();
        elseif seat_id==1 then
            --z=50-k
            data.pos.y=data.pos.y+node:getHeight()-11;
        elseif seat_id==2 then
            data.pos.x=data.pos.x-node:getWidth()+2;
        else
            data.pos.y=data.pos.y-node:getHeight()+11;
        end
    end

    
    return node;
end

--绘制所有的牌
function transcribeScene:darwAllDaCards(seat_id,cards)
    local par=self.daCard[seat_id+1];
    par:removeAllChildren();

    local data=self.daDataCard[seat_id] --打的牌的数据
    data.index_key=0;
    data.lie=1;
    data.pos={x=0,y=0};
    self.daDataCard[seat_id].k= 0

    
    print("showCards",#cards);
    local z=0
    for k,v in pairs(cards) do
        local node=self:insertDa_cards(seat_id,v)
   
  
        if seat_id==1 or seat_id==2 then
            --todo'
            z=100-(#par:getChildren()+1)
        end
        par:addChild(node,z)
    end

    --dump(self.daDataCard, "desciptiondaDataCard")

end



-- 3吃 1杠 0碰 2胡 4过
local hu_type_image={

    [0]="majong_peng_bt_p",
    [1]="majong_gang_bt_p",
    [2]="majong_hu_bt_p",
    [3]="majong_chi_bt_p",
    [4]="majong_guo_bt_p",
    [5]="majong_ting_bt01",
    [6]="majong_chi_bt_p",
}

--显示碰撞特效

--4 听
--5亮
function transcribeScene:showPengGang(seatid,type_)
    --local seatid=self:getseat_id(uid)
    local panle=self:getPanleForSeatId(seatid);
    local pos=panle:getPosition()

    local sp=cc.Sprite:create("hall/roomPlay/"..hu_type_image[type_]..".png")

    sp:setName("pengzhuantexiao")

    panle:addChild(sp)
    if seat_id==0 then
            --todo
        --pos.y=pos.y+100;
        pos.x=pos.x+50;
    elseif seat_id==1 then
        --todo
        pos.x=pos.x-50;
    elseif seat_id==2 then
        --todo
        pos.y=pos.y-50;
    else
        pos.x=pos.x+50;
        --pos.y=pos.y+50;
    end

    sp:setPosition(pos);
    sp:setScale(0)
    local ac=cc.ScaleTo:create(0.2, 1)
    --if type_~=2 then
        --todo

        ac=cc.Sequence:create(ac,cc.DelayTime:create(1),cc.RemoveSelf:create())
    --end
    sp:runAction(ac)
    

end

local que_image_tb={
    [1]="mahjong_wan01_bt",
    [2]="mahjong_tong01_bt",
    [3]="mahjong_suo01_bt"
}
--选缺
function transcribeScene:setSelectQue(que_tb)
    if not que_tb then
        --todo
        return;
    end

    for k,v in pairs(que_tb) do
        if v<0 then
            --todo
            return;
        end
        local panle=self:getPanleForSeatId(k-1);

        if not panle then
            --todo
            return;
        end
        local sp_que=panle:getChildByName("sp_clock")
        if not sp_que then
            --todo
            return;
        end
        sp_que:setTexture("hall/roomPlay/"..que_image_tb[v+1]..".png");
        sp_que:show()
    end

end

--抓牌
--用指标显示器显示牌的位置
--
local zhua_pos={
    [0]={x=750,y=130},
    [1]={x=780,y=440},
    [2]={x=420,y=460},
    [3]={x=180,y=177}
}
function transcribeScene:Zhua_card(seat_id,card)
    --local seatid=self:getseat_id(uid)


    --todo
    local node=self:drawCards2(card,seat_id);
    local par=self.zhua_cards[seat_id+1];
    local pos=zhua_pos[seat_id]
    par:removeAllChildren();

    node:setColor(cc.c4b(255, 255, 0,255))

    node:setPosition(pos)
    par:addChild(node)

   
end



--插入一张胡的牌
function transcribeScene:hu(seat_id,card)
    local node=self:drawCards2(card,seat_id);
    local par=self.zhua_cards[seat_id+1];


    local pos=zhua_pos[seat_id]
    par:removeAllChildren();

    node:setColor(cc.c4b(255, 0, 0,255))

    node:setPosition(pos)
    par:addChild(node)
    local ac=cc.Blink:create(5,2);
    node:runAction(cc.RepeatForever:create(ac))

    local sex=self:getPanleForSeatId(seat_id).sex
    if self.isPlayMusic then
        --todo
        if sex=="1" then
        --todo
            audio.playSound("hall/roomPlay/music/malesound/male1_hu0.mp3")
        else
            audio.playSound("hall/roomPlay/music/femalesound/female1_hu0.mp3")
        end
    end
    


end


function transcribeScene:deleteZhua_card(seat_id)
    local par=self.zhua_cards[seat_id+1];
    par:removeAllChildren();
end 


--插入 抓鸟的四张牌
function transcribeScene:insertZN_card(seat_id,cards)
    local par=self.daCard[seat_id+1];

    local z=0
   
    local sex=self:getPanleForSeatId(seat_id).sex

    for k,v in pairs(cards) do
        local node=self:insertDa_cards(seat_id,v,true)
         if seat_id==1 or seat_id==2 then
            --todo'
            z=100-(#par:getChildren()+1)
        end
        par:addChild(node,z)
        node:setColor(cc.c3b(56, 89, 128))
        node:runAction(cc.RepeatForever:create( cc.Sequence:create(cc.ScaleTo:create(1, 0.8),cc.ScaleTo:create(1, 1.1))))
    end
end

--出牌
--打出去的牌需要有放大的效果
--他所做的事件
--
--重新弄一张小牌
--小牌有一个指示 代表打出那一个  选择最后一个
--

function transcribeScene:Chu_card(seat_id,card)

    print("出牌",seat_id,card)
    self:deleDa_card()
    local par=self.daCard[seat_id+1];

    local node=self:insertDa_cards(seat_id,card,true)
   
    local z=0
    if seat_id==1 or seat_id==2 then
        --todo'
        z=100-(#par:getChildren()+1)
    end

    par:addChild(node,z)
    local sex=self:getPanleForSeatId(seat_id).sex
    

 
    local color=card.type_color
    local v_sound_id=card.val
    if color=="tong" then
        v_sound_id=v_sound_id+4
    elseif color=="tiao" then
        v_sound_id=v_sound_id-22
    end
    print("播放声音的值是:",v_sound_id,color,sex)
    if self.isPlayMusic then
        if sex=="1" then
            --todo
             
             audio.playSound("hall/roomPlay/music/malesound/male0_"..v_sound_id..".mp3")
        else
             audio.playSound("hall/roomPlay/music/femalesound/female0_"..v_sound_id..".mp3")
        end
    end
    
    self:add_card_tip(seat_id,card)
end

--添加打出去的牌的指示
function transcribeScene:add_card_tip(seat_id,card)
    local par=self.daCard[seat_id+1];
    local nodes=par:getChildren()
    print("nodes",#nodes)
    local node=nodes[#nodes]


    --todo
    local sp=cc.Sprite:create("hall/roomPlay/mahjong_point01.png")
    node:addChild(sp)
    sp:setName("card_tip")
    sp:setPosition(node:getWidth()/2,node:getHeight())

    local ac=cc.Sequence:create(cc.MoveBy:create(0.2,cc.p(0,2)),cc.MoveBy:create(0.2,cc.p(0,-2)),cc.DelayTime:create(0.2))
    sp:runAction(cc.RepeatForever:create(ac))

    
    local node_=self:drawCards2(card,0) --放大的支持牌
    local panle=self:getPanleForSeatId(seat_id);
    local panle_node=panle:getChildByName("magnify_card")
    if panle_node then
        --todo
        panle_node:removeSelf();
    end
    local spBg=cc.Sprite:create() --放大牌的背景
    spBg:addChild(node_)
    spBg:setScale(1.5)
    node_:setPosition(50,50)
    spBg:setName("magnify_card")

    panle:addChild(spBg,999)
    if seat_id==1 then
        --todo
        spBg:setPositionX(-20)
    elseif seat_id==2 then
        spBg:setPositionY(-100)
    end

    spBg:runAction(cc.Sequence:create(cc.DelayTime:create(2),cc.RemoveSelf:create()))

    self.currCards=node
end



--移除打出去的牌
function transcribeScene:deleDa_card()
    if self.currCards and  not tolua.isnull(self.currCards)  then
        --todo
        local node=self.currCards:getChildByName("card_tip")
        node:removeSelf();
        self.currCards=nil
    end
    
end

--切换显示
--切换到的类型 可以做的操作
--先是方向
-- 0 1 2 3 4 东 南 西 北
function transcribeScene:cut(seatid)
    --print("设置方向",seatid)
    local sp_rotary=self.rootNode:getChildByName(ui_set.sp_Rotary)
    sp_rotary:show()

    for k,v in pairs(sp_rotary:getChildren()) do
        if v:getName()~="Sprite" then
            v:stopAllActions()
            v:hide();
        end
    end
    --方向
    --local seatid=self:getseat_id(uid)
    local node= sp_rotary:getChildByName("Sprite_"..seatid)
    node:show()
    node:runAction(cc.RepeatForever:create(cc.Blink:create(4, 4)))
end

--type 0吃 1、过 2、 碰 3 杠 4胡
--可以执行的操作
local _cuozuo_png={
    [0]="majong_chi_bt_n",
    [1]="majong_guo_bt_n",
    [2]="majong_peng_bt_n",
    [3]="majong_gang_bt_n",
    [4]="majong_hu_bt_n",
}
local _cuozuo_hui_png={
    [0]="majong_chi_bt_d",
    [1]="majong_guo_bt_d",
    [2]="majong_peng_bt_d",
    [3]="majong_gang_bt_d",
    [4]="majong_hu_bt_d",
}

--ktype 可以执行的操作 

function transcribeScene:performOperation(seatid,ktype,notShowChi)

    local sp_perform=self.rootNode:getChildByName(ui_set.sp_perform..seatid)
    for k,v in pairs(sp_perform:getChildren()) do
        --v:setScale(0.5)
        v:stopAllActions();
    end
    if notShowChi then
        --todo
        sp_perform:getChildByName("majong_guo_0"):hide()
        sp_perform:ssize(sp_perform:getWidth(),207)
    end
    sp_perform:show()

  
    local _path="hall/roomPlay/"

    for i=1,4 do
        local nod_=sp_perform:getChildByName("majong_guo_"..i)
        nod_:setTexture(_path.._cuozuo_hui_png[i]..".png"); --先全部是灰色的
    end

    for k,v in pairs(ktype) do
         local nod_=sp_perform:getChildByName("majong_guo_"..v)
        nod_:setTexture(_path.._cuozuo_png[v]..".png")
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

--换三张
function transcribeScene:inCutthreeCard(cardstart,endCard,callBack)
    --绘制玩手牌之后
    

    local function iscard(i,card)
        local par_card=cardstart[i]  
        for k,v in pairs(par_card) do
            if v.type_color==card.type_color and v.val==card.val then
                table.remove(cardstart[i],k)
                return card
            end
        end
        return nil;
    end
    local my_huanCard={}
    for i=1,4 do
        local par=self.nodeCard[i]:getChildren()[1]
        my_huanCard[i]={}

        print_lua_table(self._handle.cards[i-1])
        for k,v in pairs(par:getChildren()) do
            local c=v.card;
            if #cardstart[i]<=0 then
                break;
            end
            if iscard(i,c)~=nil then
                --todo
                --牌移出来
                table.insert( my_huanCard[i],v)
                if i==1 then
                    --todo
                    v:runAction(cc.MoveBy:create(0.5,cc.p(0,50)))
                elseif i==2 then
                    v:runAction(cc.MoveBy:create(0.5,cc.p(-40,0)))
                elseif i==3 then
                    v:runAction(cc.MoveBy:create(0.5,cc.p(0,-40)))
                else
                    v:runAction(cc.MoveBy:create(0.5,cc.p(40,0)))
                end    
                local function get_cards(cds)

                    for k1,v1 in pairs(self._handle.cards[i-1]) do
                       if cds.val==v1 then
                           --todo
                           return k1
                       end
                    end
                end
                table.remove(self._handle.cards[i-1],get_cards(c))           
            end 
        end
    end

    local action=cc.Sequence:create(cc.DelayTime:create(2),cc.CallFunc:create(function()
            --换牌
            for k,v in pairs(endCard) do
                local cards=v

                local cardsNode=my_huanCard[k]-- 当前手上的牌
                for k1,v1 in pairs(cards) do
                    cardsNode[k1]:getChildByName("Image_14"):loadTexture(cardsImg..v1.type_color.."/"..v1.val..".png")
                    --cardsNode[k1]:loadTexture(v1.colot,v.png);
                    cardsNode[k1]:setColor(cc.c3b(255, 255, 0))
                    cardsNode[k1]:runAction(cc.RepeatForever:create(cc.Blink:create(2, 2)))

                    table.insert(self._handle.cards[k-1],tonumber(v1.card))

                    print("insertCard",k1,v1.card)

                end
                self._handle.parsing_tb.handlecards=self._handle.cards
            end


        end),cc.DelayTime:create(2),cc.CallFunc:create(callBack))
    self:runAction(action)
end

--显示结算界面
function transcribeScene:showAccount(tb)
    self.panAccoutUI:show()

    local tb_ui={self.nodeCard,self.teCard,self.daCard,self.zhua_cards}
    for k,v in pairs(tb_ui) do
         for k1,v1 in pairs(v) do
            v1:hide();
        end
        
    end



    if not self.panAccoutUI.set then
        --todo
        self.panAccoutUI.set=true
        

        local panle_zhua=self.panAccoutUI:getNode("Panel_3");

        
        if tb.game_type==1 then --四川麻将没有抓鸟
            --todo
            
            panle_zhua:hide()
        else
            panle_zhua:show()

            print("tb_game_type",tb.game_type)
            local node,endpos=self:drawcards3(4,tb.zhuaCards)
            
            for k,v in pairs(node:getChildren()) do
                v:setColor(cc.c3b(128, 223, 18))
            end
           
            panle_zhua:addChild(node)
            node:setPosition(90,20)
            --panle_zhua:setPosition(50,0)

        end

        local panAccoutClonetb=self.rootNode:getNode("Panel_2");

        local p=self.panAccoutUI
        local txt_activityId=p:getNode("Text_9")
        txt_activityId:setString("房号"..tb.roomId)

        local gametxt_inof=p:getNode("Text_9_0")
        local str=""
        if tb.game_type==1 then
            --todo
            str="四川麻将"
        elseif tb.game_type==2 then
            str="长沙麻将"
        elseif tb.game_type==3 then
            str="转转麻将"
        elseif tb.game_type==4 then
            str="广东麻将"
        else
            str="红中麻将"

        end
        --str=str
        gametxt_inof:setString(str)

            --todo
        local txt_speci=p:getNode("Text_9_0_0")
        txt_speci:setString(tb.special)
        
        

        local txt_tiemr=p:getNode("Text_9_0_0_0")
        txt_tiemr:setString(tb.timer)


        local _list_view=p:getNode("ListView_1")

        for i=1,4 do
            local data=tb[i]
            local p_=panAccoutClonetb:clone()


            local txt_nick=p_:getNode("Text_5");
            txt_nick:setString(data.nick)

            local txt_inf=p_:getNode("Text_6")--打的牌的信息
            txt_inf:setString(data.card_info)

            --庄家的图标
            local sp_zhuan=p_:getNode("Image_7");
            if data.zhuan then
                --todo
                sp_zhuan:show()
            else
                sp_zhuan:hide()
            end

            --开始绘制牌----------------------------------------------
            --先绘制碰杠过的牌

            --{type=1,card={}}0 吃 type==1 碰 type==2 明杠 type==3暗杠 
            --
            local pos={x=86,y=35}
            local _cout=8
            for k,v in pairs(data.te_card) do
                local node,endpos
                if v.type==0 then
                    --todo
                    node,endpos=self:drawcards3(4,{v.card[1],v.card[2],v.card[3]})
                else
                    if v.type==3 then
                        --todo
                        node,endpos=self:drawcards3(4,{v.card,v.card,v.card},0)
                    else
                        node,endpos=self:drawcards3(4,{v.card,v.card,v.card})
                    end

                    if v.type~=1  then --杠的话要在中间补一张牌
                        --dump(endPos,"myTest position")
                        local node_=self:drawCards2(v.card,4);
                        node_:setAnchorPoint(0.5,1)
                        node:addChild(node_,50)
                        node_:setPosition(gangPos[0])
                       -- node_:setPositionX(node_:getPositionX()+5)
                    end
                end
                node:setAnchorPoint(cc.p(0,0))
                p_:addChild(node)
                node:setPosition(pos)
                pos.x=pos.x+endpos.x+_cout
            end
            --绘制手牌
            local node,endpos=self:drawcards3(4,data.hand_card)
            p_:addChild(node)
            node:setPosition(pos)
            pos.x=pos.x+endpos.x+_cout

            --绘制胡牌
            local sp_hu=p_:getNode("Image_8")

            if data.hu then
                --todo
                local node=self:drawCards2(data.hu, 4)
                p_:addChild(node)
                node:setPosition(pos)
                node:setColor(cc.c3b(255, 0, 0))
                txt_nick:setColor(cc.c3b(255, 255, 255))
                sp_hu:show()

               
                if tb.game_type==1 then--四川麻将有胡的顺序
                    --todo
                    local txt_=sp_hu:getNode("Text_10");
                    txt_:setString(data.huOrder)
              
                end
            else

                sp_hu:hide()
            end
            
            --四川麻将才有番数
            local txt_fan=p_:getNode("Text_7")
            if tb.game_type==1 then
                --todo
                txt_fan:setString(data.fanshu_data)
            else
                txt_fan:hide()
            end
            
            -- 
            local txt_score=p_:getNode("Text_11")   
            txt_score:setString(data.sore)

            _list_view:pushBackCustomItem(p_)


            


        end


    end
end

--长沙麻将漫游
function transcribeScene:showCSRroam(seat_id,card)
    local btn_yao,btn_buyao,sp_an
    if not self.cs_manyou:isVisible() then --没有显示
        --todo
        self.cs_manyou:show()
        sp_an=self:drawCards2(card,4,0)
        self.cs_manyou:addChild(sp_an)
        sp_an:setPosition(480,270)
        sp_an:setScale(2);

        local _sp_bg_=self.cs_manyou:getNode("effect_light_6")
        _sp_bg_:runAction(cc.RepeatForever:create(cc.RotateBy:create(0.1,2)))
    end

     local pos_tb={
        [0]={x=450,y=130},
        [1]={x=680,y=270},
        [2]={x=450,y=450},
        [3]={x=250,y=300},
    }

    
    local btn_acckep =self.rootNode:getNode("Image_12"):clone();--莫

    self.cs_manyou:addChild(btn_acckep)
    btn_acckep:setPosition(pos_tb[seat_id])
    btn_acckep:setRotation(seat_id*90)

    if card==0 then --不要
        --todo
        btn_acckep:getNode("Image_16"):loadTexture("hall/roomPlay/text_bumo.png")

    else
        sp_an:removeSelf();
        local sp_card=self:drawCards2(card,4)
        self.cs_manyou:addChild(sp_card)
        sp_card:setPosition(480,270)
        sp_card:setScale(2);
        --return;

    end

    btn_acckep:setScale(0)

    btn_acckep:runAction(cc.Sequence:create( cc.ScaleTo:create(0.5,2),cc.DelayTime:create(1),cc.RemoveSelf:create()))



end

function transcribeScene:onExit()

end

return transcribeScene