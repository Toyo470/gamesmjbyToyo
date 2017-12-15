--
-- Author: zeng tao
-- Date: 2016-08-18 17:58:21
--
--

local transcribe_Scene=import("hall.roomPlay.PokerGame.transcribeScene")
local frame_timer=2;--
local speedNum=3--
local isTest=false
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler") 
local isRun=false;

local trans_accout=import(".hu_type_accout")
--


local function cardToShow(card)
    return trans_accout:getCardData(card)
end




local gameData=class("gameData")

require("config")



function gameData:getSeat_ud(uid)
    return trans_accout:getSeatid(uid)
end

function gameData:ctor()
  
end


function gameData:cleanData()
   
    self.dtTimer=0 --

    self.cards={ --
        [0]={},
        [1]={},
        [2]={},
        [3]={},
    }

    self.userknockouts={ --
        [0]={},
        [1]={},
        [2]={},
        [3]={},
    }

    
    self.userPlay={
        [0]={},
        [1]={},
        [2]={},
        [3]={},
    }

    self.cardnum=0

    self.currChu_card={
        t="",
        uid=-1,
        card=0
    }

    --cards pao_id
    self.curr_hu={
        [0]={},
        [1]={},
        [2]={},
        [3]={},
    }

    self.zhuaniao_card={ --
        [0]={},
        [1]={},
        [2]={},
        [3]={}
    }
    self.currCaozuoUId=0--

    self._man_data_={}-- 漫游

end

--
function gameData:parsing(datatb)
    if not datatb then
        return;
    end
    self.parsing_tb={}--记录的本地转换数据
    self.isRunFrame=false --
    self.currFrame=1 --
    self:cleanData()
    self.activityId_=activityId_
    self.isCutthree=false--

    dump(datatb,"parsing_test2 gameData")

    display.addSpriteFrames("hall/roomPlay/PokerGame/res/cards.plist", "hall/roomPlay/PokerGame/res/cards.png")

    if self.game_type=="跑得快" then
        --todo
        self.game_type=11
    elseif self.game_type=="斗地主" then
        --todo
        self.game_type=1
    end


    self.game_type= self.game_type or 1


    self.parsing_tb.step=datatb.frame

    --
    self.parsing_tb.userinfos={}
    for k,v in pairs(datatb.userinfos) do
        local tb={}
        tb.icon_url=v.photo_url
        tb.gold=v.chips
        tb.nick=v.nickName
        tb.uid=v.uid
        tb.sex=v.sex
        tb.score=v.score
        tb.seat_id= v.seat_id
        self.parsing_tb.userinfos[k-1]=tb
    end
    trans_accout:setranInfo(self.parsing_tb.userinfos,self.game_type)

    dump(self.parsing_tb.userinfos, "parsing userinfos", nesting)

    --玩家手牌
    self.parsing_tb.handlecards={}

    for k,v in pairs(datatb.cards) do
        local tb=cct.split(v, ",")
        local tb_num={}
        for k,v in pairs(tb) do
            if v~="" then
                --todo
                table.insert(tb_num,tonumber(v))
            end
        end
        self.parsing_tb.handlecards[k-1]=tb_num
    end


    self.parsing_tb.base=datatb.base--

    ---结算的数据-----------------------------------------
    self.parsing_tb.endDataInof={}
    if datatb.settlements then
        --todo
       
        for k,v in pairs(datatb.settlements) do
            --print(k,v)
       
            local seat_id = self:getSeat_ud(v["uid"])
            self.parsing_tb.endDataInof[seat_id]=v
            --加入玩家信息
            for kk, vv in pairs(self.parsing_tb.userinfos) do
                if vv["uid"] == v["uid"] then
                    self.parsing_tb.endDataInof[seat_id]["nickName"] = vv["nick"]
                    self.parsing_tb.endDataInof[seat_id]["photo_url"] = vv["icon_url"]
                    self.parsing_tb.endDataInof[seat_id]["seat_id"] = vv["seat_id"]
                    self.parsing_tb.endDataInof[seat_id]["gold"] = vv["gold"]
                    self.parsing_tb.endDataInof[seat_id]["sex"] = vv["sex"]
                    vv["gold"] = vv["gold"] - v["win"]
                    break
                end
            end

        end
    else
        self.parsing_tb.endDataInof={
            [0]={fanshu_data=3,card_info="还没数据啊",score=5},
            [1]={fanshu_data=3,card_info="还没数据啊",score=5},
            [2]={fanshu_data=3,card_info="还没数据啊",score=5},
            [3]={fanshu_data=3,card_info="还没数据啊",score=5}
        }
    end

    dump(self.parsing_tb.endDataInof, "gameData endDataInof")

    self.parsing_tb.special=datatb.special

    self.parsing_tb.timer=os.date("%c",datatb.gameTime)

    self:repleaseRoomScene()
end

--
function gameData:repleaseRoomScene()
    self._scene=transcribe_Scene.new(self);
    SCENENOW["name"]  = "majiang.scenes.transcribe_Scene";
    SCENENOW["scene"]=self._scene
    display.replaceScene(self._scene)

    self._scene:retain();
    SCENENOW["scene"]:retain();
    SCENENOW["scene"]:setHead(self.parsing_tb.userinfos);
    SCENENOW["scene"]:setBase(self.parsing_tb.base)
    
    self.cards=clone(self.parsing_tb.handlecards)

    --
    self:redrow_node()

    self:startPlay()
end

function gameData:getGameType()
    return self.game_type
end

--
function gameData:startPlay()

    print("startPlay",tostring(#self.parsing_tb.userinfos))
    for i=1,#self.parsing_tb.userinfos + 1 do
        self:draw_handle_cards(i-1); 
    end

    
    self.isRunFrame=true
    self.isRun=true
    self.isCutthree=true 
    self._schhandle=scheduler.scheduleGlobal(handler(self, self.update), 0.1);
end



function gameData:redrow_node()
    --
    self._scene:updateStep(self.currFrame.."/"..#self.parsing_tb.step)

end


--绘制手牌
function gameData:draw_handle_cards(seat_id,getData)

    local tb={}

    local cards=self.cards[seat_id]

    dump(self.cards,"gameCards seat:"..tostring(seat_id))
    for k1,v1 in pairs(cards) do
        local card = require("hall.roomPlay.PokerGame.Card"):Decode(v1)
        local _value  = bit.band(15,card)
        local _kind   = bit.brshift(card,4)
        table.insert(tb,{_value,_kind})
    end

    -- dump(tb,"wcaomi")
    --
    table.sort(tb,function(a,b)
            if a[1] == b[1] then
                return a[2] > b[2]
            else
                return a[1]>b[1]
            end
        end)
    if getData then
        --todo
        return tb;
    end

    self._scene:showHandCards(seat_id,tb)
end


function gameData:update(dt)

    if not self.isRunFrame then
        --todo
        return;
    end
    if self.currFrame>#self.parsing_tb.step then --最后一步了
        self.isRunFrame=false
        self:setAccoutData()--显示结算界面
        return;
    end
    if self.isRun  then
        self.dtTimer= self.dtTimer+dt
        if  self.dtTimer >= frame_timer then
            self.isRun=false
            print("当前执行",self.currFrame)
            local data=self.parsing_tb.step[self.currFrame];--
            if not self._scene.isPlayMusic then
                --todo
                self._scene.isPlayMusic=true
            end
            self:parsing_one(data);
            self._scene:updateStep(self.currFrame.."/"..#self.parsing_tb.step)
            self.currFrame=self.currFrame+1;
            self.dtTimer=0
        end
    end

end


--解析每一步的操作
function gameData:parsing_one(data)

    dump(data, "parsing_one ")
    print("parsing_one",tostring(data["uid"]))
    local seat_id = self._scene:getseat_id(data["uid"])

    if data["type"] == 0x6005 then--出牌
        dump(data.cards,"parsing_one seat:"..tostring(seat_id))

        local tb_split = cct.split(data.cards, ",")
        local tb_cards = {}
        for k,v in pairs(tb_split) do
            if v~="" then
                --todo
                table.insert(tb_cards,tonumber(v))
            end
        end

        self._scene:Chu_card(seat_id,tb_cards)
        self:removeCards(seat_id,tb_cards)
        self.isRun=true
    elseif data["type"] == 0x6006 then --过
        self._scene:Pass(seat_id)
        if data["round_win_uid"] ~= 0 then
            local spAction = display.newSprite():addTo(self._scene)
            spAction:runAction(cc.Sequence:create(cc.DelayTime:create(1), 
                        cc.CallFunc:create(function() self._scene:clearDesktop() self.isRun=true end)))
        else
            self.isRun=true
        end
    end
end

--移除打出的牌
function gameData:removeCards(seat,cards)

    local hand_cards = self.cards[seat]

    for i=#hand_cards,1,-1 do
        local value = hand_cards[i]
        for k,v in pairs(cards) do
            if v == value then
                table.remove(hand_cards,i)
            end
        end
    end

    self:draw_handle_cards(seat)
end
--加入牌队列
function gameData:addCards(seat, cards)
    local hand_cards = self.cards[seat]

    for k, v in pairs(cards) do
        table.insert(hand_cards,v)
    end
    dump(self.cards[seat], "addCards "..tostring(seat), nesting)

    self:draw_handle_cards(seat)
end


function gameData:onControllBack(sender)
    print("gameData",sender:getName(),self.isCutthree)
    if not self.isCutthree then
        return;
    end
    local name=sender:getName()
    if name=="btn_play" then --播放
        --todo
        if not self.playSender then
            --todo
           self.playSender=sender; 
        end
        self:play(sender);
    elseif name=="btn_back" then
        --todo
        self:goBack()
    elseif name=="btn_speed" then
        --todo
        self:speed()
    else
        self:exitvedio()
    end
end


function gameData:play(sender)


    if self.isRunFrame then --暂停
        self.isRunFrame=false
        sender:loadTextures("hall/roomPlay/video_stop_p.png","hall/roomPlay/video_stop_p.png")
        --event.loadTexture(json);
    else --播放
        --event.loadTexture(json);
        self.isRunFrame=true
        self.isRun=true
        sender:loadTextures("hall/roomPlay/video_stop.png","hall/roomPlay/video_stop.png")
        --self:gotoAndPlay()

    end
end


function gameData:updateData(start,en)

    --print("快进或者快退",start,en)
    if self._updateData then
        return
    end
    self:cleanData()
    self._updateData = true
    self.isRunFrame=false --先暂停
    self.dtTimer = 0
    local step_frame = 1
    if self.currFrame > en then
        step_frame = -1
    end

    print("开始加速----------------------------------------------------------------",tostring(en),tostring(self.currFrame))
    self.cards = clone(self.parsing_tb.handlecards) --手牌还原
    for i = start, en do

        local data = self.parsing_tb.step[i]

        if data then
            local tb_split = cct.split(data.cards, ",")
            local tb_cards = {}
            for k,v in pairs(tb_split) do
                if v~="" then
                    --todo
                    table.insert(tb_cards,tonumber(v))
                end
            end
            dump(data, "updateData "..tostring(i))
            
            local seat_id = self._scene:getseat_id(data["uid"])
            self:parsing_one(data)

            -- if step_frame > 0 then--前进
            --     self:parsing_one(data)
            -- else--后退
            --     self:addCards(seat_id, tb_cards)
            --     --回滚步骤
            --     if step_frame < 0 then
            --         if i - speedNum < 1 then
            --             data = nil
            --         else
            --             data = self.parsing_tb.step[i-speedNum]
            --         end
            --     end
            --     if data then
            --         self:parsing_one(data)
            --     end
            -- end
        end
        
    end --if

    print("结束了----------------------------------------------------------------")

    self._updateData = false
end

--快进
function gameData:speed()
    --看是否是最后i一步了

    print("speed快进")
    if self.currFrame>=#self.parsing_tb.step then
        --todo
        return;
    end
    if self.playSender then
        self.playSender:loadTextures("hall/roomPlay/video_stop.png","hall/roomPlay/video_stop.png")
    end
    self._scene.isPlayMusic=false
    local addNum=speedNum
    if self.currFrame+addNum>#self.parsing_tb.step then
        --todo
        addNum=#self.parsing_tb.step-self.currFrame
    end

    self:updateData(1,self.currFrame+addNum)
    
    --清理UI
    self._scene:cleanUI();

    --前进几步
    self.currFrame=self.currFrame+addNum;
    self:redrow_node()

    self.currFrame=self.currFrame+1


    --继续跑
    self.isRunFrame=true
    self.isRun=true
    self.dtTimer = 0
end

--快退
function gameData:goBack()
    if self.currFrame==1 then
        return;
    end
    if self.playSender then
        --todo
        self.playSender:loadTextures("hall/roomPlay/video_stop.png","hall/roomPlay/video_stop.png")
    end
    self._scene.isPlayMusic=false


    local addNum=speedNum
    if self.currFrame-addNum<1 then
        addNum=self.currFrame-1
    end

    self:updateData(1,self.currFrame-addNum)

    --隐藏结果界面
    if self._show_result then
        self._scene:unshowResult()
    end

    --清理UI
    self._scene:cleanUI();

    self.currFrame=self.currFrame-addNum;

    self:redrow_node();


    self.currFrame=self.currFrame+1


    self.isRunFrame=true
    self.isRun=true

    self.dtTimer = 0
end

--设置结算数据
function gameData:setAccoutData()

    print("setAccoutData")
    self._show_result = true
    
    self._scene:showAccount(self.parsing_tb.endDataInof)

end

--退出
function gameData:exitvedio()
    scheduler.unscheduleGlobal(self._schhandle)
    isRun=false
    self._scene:removeFromParent();
    self._scene=nil;
    display_scene("hall.gameScene")
    audio.stopMusic(false);
    cc.Director:getInstance():resume();
end



return gameData