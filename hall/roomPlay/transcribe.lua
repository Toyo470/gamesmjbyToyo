--
-- Author: zeng tao
-- Date: 2016-08-18 17:58:21
--
--

local transcribe_Scene=import(".transcribeScene")
local frame_timer=2;--
local speedNum=4--
local isTest=false
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler") 
local Total_Card=56
local isRun=false;

local trans_accout=import(".hu_type_accout")
--


local function cardToShow(card)
    return trans_accout:getCardData(card)
end




local transcribe=class("transcribe")



function transcribe:getSeat_ud(uid)
    return trans_accout:getSeatid(uid)
end

function transcribe:ctor()
  
end


function transcribe:getData(activityId_,roundIndex_)
    print(activityId_,roundIndex_,"开始回访") 
    if isRun then
        --todo

    print(activityId_,roundIndex_,"开始回访 2") 
        return;
    end


    if  activityId_ then
        cct.httpReq2({
            url=HttpAddr.."/freeGame/queryFreeGameRound",
            data={
                activityId=activityId_  or 2358,
                roundIndex=roundIndex_ or 1

            },
            callBack=function(data)
                if data.returnCode=="0" then
                    --todo
                    if isRun then
                        --todo
                        return;
                    end
                    data=data.data
                    self.game_type=data.gameName
                    --print_lua_table(data)
                    local jsonUrl=data.replayUrl;

                    cct.httpReq2({
                        url=jsonUrl,
                        type_="GET",
                        callBack=function(jsonData)
                            print_lua_table(jsonData)
                            xpcall(function()
                                if isRun then
                                    --todo
                                    return;
                                end
                                    print("没有到这里？")
                                    isRun=true
                                    self.parsing_tb={}--记录的本地转换数据
                                    self.isRunFrame=false --
                                    self.currFrame=1 --
                                    self:cleanData()
                                    self.activityId_=activityId_
                                    self.isCutthree=false--
                                    self:parsing(jsonData)
                                    
                                end,cct.runErrorScene)
                        end
                    })
                    
                end

            end
        })
    else
        print("执行了测试")
        -- self.game_type="转转麻将"
        -- local jsonData=json.decode(tb_test_json)
        --                     self:parsing(jsonData);

        --  cct.httpReq2({
        --     url=HttpAddr.."/freeGame/queryFreeGameRound",
        --     data={
        --         activityId= 2358,--2091,
        --         roundIndex= 1

        --     },
        --     callBack=function(data)
        --         if data.returnCode=="0" then
        --             --todo
        --             data=data.data
        --             self.game_type=data.gameName
        --             --print_lua_table(data)
        --             local jsonUrl=data.replayUrl;

                    cct.httpReq2({
                        url="http://hbirdtest.oss-cn-shenzhen.aliyuncs.com/201611/10118_63_10_0614460124",
                        type_="GET",
                        callBack=function(jsonData)

                            isRun=true
                            self.parsing_tb={}--记录的本地转换数据
                            self.isRunFrame=false --
                            self.currFrame=1 --
                            self:cleanData()
                            self.activityId_=activityId_
                            self.isCutthree=false--

                              self.game_type="广东麻将"
                            self:parsing(jsonData)
                             

                            -- print("执行了测试val")
                      
                            self:parsing(jsonData);
                        end
                    })
                    
        --         end

        --     end
        -- })
    end
end

function transcribe:cleanData()
   
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

    self.accoutData=nil--结算数据

end

--
function transcribe:parsing(datatb)
    if not datatb then
        return;
    end

    if self.game_type == "跑得快" then

        isRun=false
        require("hall.roomPlay.PokerGame.gameData"):parsing(datatb)
        return
    end
    print(self.game_type,"parsing_test2")
    if self.game_type=="血战麻将" then
        --todo
        self.game_type=1;
    elseif self.game_type=="长沙麻将" then
        --todo
        self.game_type=2;
    elseif self.game_type=="转转麻将" then
        self.game_type=3;
    elseif self.game_type=="广东麻将" then
        self.game_type=4
    else
        return;
    end


    self.game_type= self.game_type or 1


    local cmd_type={
        [12290]=1,--抓牌
        [16644]=2,--出牌
        [16389]=3,--执行的操作
        [12293]=4,--可以执行的操作

    }


    self.parsing_tb.step=datatb.frame
    for k,v in pairs(self.parsing_tb.step) do
        --operationBitset  
        --opeType          
        --card             
        --type              
        --uid              
        local type_=cmd_type[v.type]
        if type_==4 then
            --todo
            v.canOperation={}
            v.type_=8
            local result,_=trans_accout:getHandles(v.operationBitset)
            local tb={1}--过
            for k1,v1 in pairs(result) do
                if k1=="p" then
                    --todo
                    table.insert(tb,2)
                end
                if k1=="pg" then
                    --todo
                    table.insert(tb,2)
                    table.insert(tb,3)
                end
                if k1=="h" then
                    --todo
                    table.insert(tb,4)
                end
                if k1=="g" then
                    --todo
                    table.insert(tb,3)
                end
                if k1=="lc" or k1=="cc" or k1=="rc" then
                    --todo
                    table.insert(tb,0) --吃
                end
             

            end
            v.canOperation[v.uid]=tb
        elseif type_==3 then
            if v.opeType==0x4010 then --蛮游
                --todo
                v.type_=12--漫游
            elseif v.opeType == 0x1000 then--听
                v.type_=13
            elseif v.opeType == 0x10000 then--亮喜
                v.type_=14
            else
                local result,index=trans_accout:getHandles(v.opeType)
                if v.opeType==0 then
                    --todo
                    v.type_=3-- 过
                elseif result["p"] then
                    v.type_=4
                elseif result["g"] or result["pg"]  then
                    if index==1 then
                        v.type_=6
                    else
                        v.type_=5
                    end
                elseif result["h"] then
                    v.type_=7
                    --v.canOperation=result
                elseif result["lc"]  then --左吃
                    --v.type_=3
                    v.type_=9
                elseif result["cc"] then --中吃
                    v.type_=10
                elseif result["rc"] then --右吃
                    v.type_=11              
                end
            end

            

        else
             v.type_=cmd_type[v.type]
        end
    
        dump(v, "parsing")
           
        if not v.type_ then
            --todo
            --print("当前在多少步")
            print("当亲在",k)
            print_lua_table(v)
            print("服务器数据异常,第"..k.."步".."类型不存在")
          --  error("服务器数据异常,第"..k.."步".."类型不存在");

            return;
        end

            
  

    end

    --
    self.parsing_tb.userinfos={}
    for k,v in pairs(datatb.userinfos) do
        local tb={}
        tb.icon_url=v.photoUrl
        tb.gold=v.chips
        tb.nick=v.nickName
        tb.uid=v.uid
        tb.sex=v.sex
        tb.score=v.score
        self.parsing_tb.userinfos[k-1]=tb
    end
    trans_accout:setranInfo(self.parsing_tb.userinfos,self.game_type)
    --
    self.parsing_tb.handlecards={}
   -- print_lua_table(datatb.cards)
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


    self.parsing_tb.zhuang_id=datatb.zhuang_id--庄UID
    --self.parsing_tb.zhuang_id=self.parsing_tb.userinfos[datatb.zhuang_id].uid
    self.parsing_tb.getSimputerNum=datatb.remainCardCount or Total_Card--剩余牌数
    self.cardnum=self.parsing_tb.getSimputerNum  --

    self.parsing_tb.select_Que=datatb.select_Que

    ---结算的数据-----------------------------------------
    self.parsing_tb.endDataInof={}
    if datatb.settlements then
        --todo
       
        for k,v in pairs(datatb.settlements) do
            --print(k,v)
       
            local tb=trans_accout:getHuInfoStr(v)
            self.parsing_tb.endDataInof[tb.seat_id]=tb

        end
    else
        self.parsing_tb.endDataInof={
            [0]={fanshu_data=3,card_info="还没数据啊",score=5},
            [1]={fanshu_data=3,card_info="还没数据啊",score=5},
            [2]={fanshu_data=3,card_info="还没数据啊",score=5},
            [3]={fanshu_data=3,card_info="还没数据啊",score=5}
        }
    end

    self.parsing_tb.special=datatb.special
    ------------------------------------------------------

    if self.game_type==1 then --四川麻将 有换3张
        --todo
        if  datatb.changeCardsRemoved and  datatb.changeCardsAdded then --有可能他不换
            --估计有BUG 有可能只有部分用户有换3张
  
            self.parsing_tb.startCutthree={}
            self.parsing_tb.endCutThree={}
           
            for k,v in pairs(datatb.changeCardsRemoved) do
                local tb=cct.split(v, ",")
                local new_tb={}
                for k1,v1 in pairs(tb) do
          
                    if v1~="" then
                        --todo
                        local tb=cardToShow(tonumber(v1))
                        tb.card=v1

                        new_tb[k1]=tb;
                    end
                    
                end
                self.parsing_tb.startCutthree[k]=new_tb
            end

            for k,v in pairs(datatb.changeCardsAdded) do
                local tb=cct.split(v, ",")
                local new_tb={}
                for k1,v1 in pairs(tb) do

                    if v1~="" then
                        local tb=cardToShow(tonumber(v1))
                        tb.card=v1
                        new_tb[k1]=tb;
                    end
                end
                self.parsing_tb.endCutThree[k]=new_tb
            end
        end

        self.parsing_tb.special="血战到底"
   
    else -- 
        self.parsing_tb.zn_card={}
        -- if not datatb.niao_card then
        --     --todo
        --     datatb.niao_card="1,2,3"
        -- end
 
        
        local tb_zn_cards=cct.split(datatb.niao_card, ",")
        for k,v in pairs(tb_zn_cards) do
            if v and v~="" then
                --todo
            end
            self.parsing_tb.zn_card[k]=v;
        end
        self.parsing_tb.special="抓"..#self.parsing_tb.zn_card.."鸟"
        --dump(self.parsing_tb.zn_card,"cesh dataTb")
    end
    --


    self.parsing_tb.timer=os.date("%c",datatb.gameTime)

    self:repleaseRoomScene()
end

--
function transcribe:repleaseRoomScene()
    self._scene=transcribe_Scene.new(self);
    SCENENOW["name"]  = "majiang.scenes.transcribe_Scene";
    SCENENOW["scene"]=self._scene
    display.replaceScene(self._scene)

    self._scene:retain();
    SCENENOW["scene"]:retain();
    SCENENOW["scene"]:setHead(self.parsing_tb.userinfos);
    SCENENOW["scene"]:setBase(self.parsing_tb.base,self.parsing_tb.zhuang_id)
    
    print("currr ",self.cardnum)
    if self.game_type==1 then
        --  
        SCENENOW["scene"]:setSelectQue(self.parsing_tb.select_Que)
    end
    
    self.cards=clone(self.parsing_tb.handlecards)


    --
    self:redrow_node()
    if self.game_type==1 and self.parsing_tb.startCutthree and self.parsing_tb.endCutThree then --
        --todo
        --
        self._scene:inCutthreeCard(self.parsing_tb.startCutthree,
                                self.parsing_tb.endCutThree,handler(self, self.startPlay))
    else
        --
        self:startPlay()
        -- test
        -- self.userPlay={
        --     [0]={
        --         {type=0,card={1,2,3}},
        --         {type=1,card=5},
        --         {type=1,card=4},
        --     },
        --     [1]={},
        --     [2]={},
        --     [3]={}
        -- }
        -- self:pengGane(0)--



    end

   

end

function transcribe:getGameType()
    return self.game_type
end

--
function transcribe:startPlay()
    for i=1,4 do
        self:draw_handle_cards(i-1); 
    end

    
    self.isRunFrame=true
    self.isRun=true
    self.isCutthree=true 
    self._schhandle=scheduler.scheduleGlobal(handler(self, self.update), 0.1);
end



function transcribe:redrow_node()
    --
    self._scene:updateStep(self.currFrame.."/"..#self.parsing_tb.step)
    SCENENOW["scene"]:setCardsNum( self.cardnum);
  
    for i=1,4 do
        self:da_card(i-1) --
        self:pengGane(i-1)--
        self:draw_handle_cards(i-1);   --
    end

    if self.currChu_card.t=="zhua" then--
        self._scene:Zhua_card(self.currChu_card.uid,cardToShow(self.currChu_card.card))
    elseif self.currChu_card.t=="chu" then -- 
        self._scene:add_card_tip(self.currChu_card.uid,cardToShow(self.currChu_card.card))
    end

    if self.currCaozuoUId~=0 then --
        --todo
        self._scene:cut(self:getSeat_ud(self.currCaozuoUId)) --
    end


    --当前胡
    for k,v in pairs(self.curr_hu) do
        if type(v)=="table" and v.card then
            --todo

            self._scene:hu(k,cardToShow(v.card))
            if self.game_type~=1 then
                --todo
                self:zn_cards(k) --
            end
        end
    end

    if self._man_data_.card then
         --todo
        self._scene:showCSRroam(self._man_data_.seat_id,self._man_data_.card)
    end 
    
    
  

end


--绘制手牌
function transcribe:draw_handle_cards(seat_id,getData)

    local tb={}

    local cards=self.cards[seat_id]

    dump(cards,"gameCards")

    if not cards then
        --error("transcribe:draw_handle_cards error "..seat_id)
        return;
    end

    for k1,v1 in pairs(cards) do
        local m=cardToShow(v1)
        table.insert(tb,m)
    end

    dump(tb,"wcaomi")
    --
    table.sort(tb,function(a,b)
            return a.val<b.val
        end)
    if getData then
        --todo
        return tb;
    end

    self._scene:showHandCards(seat_id,tb)
end



--
function transcribe:da_card(seat_id)
 
    local cards=self.userknockouts[seat_id]
    local tb={}
    for k,v in pairs(cards) do
        table.insert(tb,cardToShow(v));
    end
    self._scene:darwAllDaCards(seat_id,tb)
end

--
--
function transcribe:pengGane(seat_id,getData)
    local data=self.userPlay[seat_id]
    local tb={}
    for k,v in pairs(data) do
        local myTest={}
        myTest.type=v.type --type
        if type(v.card)=="table" then --这是吃!!!
            --todo

            if self.game_type==1 then --
                --todo
                table.remove(self.userPlay[seat_id],k);
            else
                myTest.card={}
                --³ÔÓÐ3ÕÅÅÆ
                for _,_card in pairs(v.card) do
                    table.insert(myTest.card,cardToShow(_card))
                end
            end
        else
            myTest.card=cardToShow(v.card)
        end
        
        table.insert(tb,myTest)
    end
    if getData then
        --todo
        return tb;
    end
    self._scene:showPengZhuanCards(seat_id,tb)
end

--抓鸟
function transcribe:zn_cards(seat_id,getData)
    local cards=self.parsing_tb.zn_card
    local te={}
    for k,v in pairs(cards) do
        if v and v~="" and v~="nil" then
            --todo
            local v=tonumber(v)
            table.insert(te,cardToShow(v))
        end
    end

     dump(cards,"zncard")

    if getData then
        --todo
        return te;
    end
   

    self._scene:insertZN_card(seat_id,te)
end




function transcribe:update(dt)

    if not self.isRunFrame then
        --todo
        return;
    end

    print(self.currFrame,#self.parsing_tb.step,"当前 所在的补数")
    if self.currFrame>#self.parsing_tb.step then --最后一步了
        self.isRunFrame=false
        self:setAccoutData()--显示结算界面
        return;
    end
    if self.isRun  then
        self.dtTimer= self.dtTimer+dt
        if  self.dtTimer >=frame_timer then
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
function transcribe:parsing_one(data)
    --数据不存在
    if not data then
        --todo
        return
    end

  
    local type_=data.type_

    if type_==8 then --可以执行的操作
        for k,v in pairs(data.canOperation) do
            local uid=k
            local seat_id=self:getSeat_ud(uid)
            if self.game_type==1 then
                --todo
                self._scene:performOperation(seat_id,v,true);
            else
                self._scene:performOperation(seat_id,v)
            end
            
            self.isRun=true
        end
        return;
    end


    local seat_id = self:getSeat_ud(data.uid)
    if not seat_id then
        --todo
        printError("seat_id is null")
    end
    if self.currCaozuoUId~=data.uid then --
        --todo
        self.currCaozuoUId=data.uid
        self._scene:cut(seat_id) --
        self._scene:deleDa_card();--
    end

    if type_==1 then --  抓牌
        --todo

     
        self._scene:Zhua_card(seat_id,cardToShow(data.card));
       
        
       
        SCENENOW["scene"]:setCardsNum(self.cardnum);
        self.cardnum=self.cardnum-1
        self.currChu_card={
            t="zhua",
            uid=seat_id,
            card=data.card
        }
        self.isRun=true
    elseif type_==2 then --
        --todo
        if self.currChu_card.t=="zhua"  then --
           --
           --删除抓的牌
            self._scene:deleteZhua_card(self.currChu_card.uid)
            table.insert(self.cards[seat_id],self.currChu_card.card);

        end
        --删除手牌
        cct.tableremovevalue(self.cards[seat_id],data.card)

        self:draw_handle_cards(seat_id)
        --插入打的牌
        table.insert(self.userknockouts[seat_id],data.card);
        self._scene:Chu_card(seat_id,cardToShow(data.card))
       --- self.zhu_id_cards[seat_id]=0
        self.currChu_card={
            t="chu",
            uid=seat_id,
            card=data.card
        }
        self.isRun=true
    elseif type_>=3 and type_<=14 and type_~=12 then --4 碰 5 明杠 6暗杠 7 胡 9左吃 10中吃 11 右吃

        ---print("执行了什么？",type_)



        local function runNext(seat_id)
            
            if type_==3 then --抓到的牌  下一步 会打出去   可以操作的牌不管
                --todo
                
                self.isRun=true--
                self._scene:showPengGang(seat_id,4) --
                return;
            end

            local card_=data.card
            --操作的牌s
            local operation_card=card_ 
            if self.currChu_card.t=="zhua" then--抓的牌操作
                --todo
                --把抓的牌删除掉
                self._scene:deleteZhua_card(self.currChu_card.uid)
            elseif self.currChu_card.t=="chu" then 

                local id=self.currChu_card.uid


                --print(id,cd,self.userknockouts[id])
                if id~=-1 and self.userknockouts[id]  then
                    cct.tableremovevalue(self.userknockouts[id],operation_card)
                    self:da_card(id) --刷新打的牌s
                end
            end


            ----------------------------------------------------
            --userplay
            --1 碰 2 明杠 3暗杠 4 胡 6左吃 7中吃 8 右吃

            local type_texiao=-1
            if type_>=9 then--吃
                --todo
                local card1,card2,card3

                if type_==9 then
                    --todo
                    --删除手牌
                    cct.tableremovevalue(self.cards[seat_id],card_+1)
                    cct.tableremovevalue(self.cards[seat_id],card_+2)
                    card1=operation_card;
                    card2=card_+1
                    card3=card_+2
                    type_texiao=3
                elseif type_==10 then --中吃
                    cct.tableremovevalue(self.cards[seat_id],card_-1)
                    cct.tableremovevalue(self.cards[seat_id],card_+1)
                    card1=card_-1
                    card2=operation_card
                    card3=card_+1
                    type_texiao=3
                elseif type_==11 then --右吃
                    cct.tableremovevalue(self.cards[seat_id],card_-1)
                    cct.tableremovevalue(self.cards[seat_id],card_-2)
                    card1=card_-2
                    card2=card_-1
                    card3=operation_card
                    type_texiao=3
                elseif type_==13 then--听
                 
                     type_texiao=5
                elseif type_==14 then--亮
                     type_texiao=6
                    card1=0x41
                    card2=0x42
                    card3=0x43;

                    cct.tableremovevalue(self.cards[seat_id],card1);
                    cct.tableremovevalue(self.cards[seat_id], card2)
                    cct.tableremovevalue(self.cards[seat_id], card3)


                end
   
                if type_~=13 then
                    --todo
                    table.insert(self.userPlay[seat_id],{type=0,card={card1,card2,card3}})

                end
                
            elseif type_>=4 and type_<=6 then  --碰杠   
                local isLastPeng=false
                if type_>4 then --杠
                    --todo
                    type_texiao=1
                    for k,v in pairs(self.userPlay[seat_id]) do
                        if v.card==card_ then --在杠之前有碰了   那么直接杠
                            --todo
                            self.userPlay[seat_id][k].type=type_-3
                            isLastPeng=true
                            break;
                        end
                    end

                    --
                    if not isLastPeng  then
                        --todo
                        for i=1,3 do
                            cct.tableremovevalue(self.cards[seat_id],card_)--杠 删除3张手牌
                        end
                        table.insert(self.userPlay[seat_id],{type=type_-3,card=card_})
                    end
                else
                    type_texiao=0--碰
                    for i=1,2 do
                        cct.tableremovevalue(self.cards[seat_id],card_)
                    end
                    table.insert(self.userPlay[seat_id],{type=type_-3,card=card_})
                end
            elseif type_==7 then--胡
                if self.game_type~=1 then --四川麻将没有抓鸟
                    --todo
                    self:zn_cards(seat_id) --抓鸟  
                end
                --print("hu",data.uid,seat_id)
                self._scene:hu(seat_id,cardToShow(card_))
                self.curr_hu[seat_id]={
                    card=card_,
                    pao_id=0,
                    hu_t=0
                } 
                type_texiao=2
            end
            
      
            self.currChu_card={
                t="",
                uid=-1,
                card=0
            }

            --刷新碰杠牌
            self:pengGane(seat_id)

            --显示碰杠过的特效 
            self._scene:showPengGang(seat_id,type_texiao) --

            --画手牌
            self:draw_handle_cards(seat_id)
            self.isRun=true

        end

        local perform_id=1 --过
        if type_>=9 then --吃
            --todo
            perform_id=0;--吃
        elseif type_==4 then
            perform_id=2;--Åö 
        elseif type_==5 or type_==6 then
            perform_id=3 --杠
        elseif type_==7 then
            perform_id=4 --胡

        end
      
        --
        self._scene:execute(seat_id,perform_id,runNext)
    
    elseif type_==12 then
        --todo
        local card=data.card

        self._scene:showCSRroam(seat_id,card)
        

    end

end


function transcribe:onControllBack(sender)
    print("transcribe",sender:getName(),self.isCutthree)
    if not self.isCutthree then
        return;
    end
    local name=sender:getName()
    if name=="Button_19" then --播放
        --todo
        if not self.playSender then
            --todo
           self.playSender=sender; 
        end
        self:play(sender);
    elseif name=="Button_18" then
        --todo
        self:goBack()
    elseif name=="Button_21" then
        --todo
        self:speed()
    else
        self:exitvedio()
    end
end


function transcribe:play(sender)


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


function transcribe:updateData(start,en)

    --print("快进或者快退",start,en)
    self.isRunFrame=false --先暂停
    self:cleanData()
    self.cardnum=self.parsing_tb.getSimputerNum


    print("开始加速----------------------------------------------------------------")
    self.cards=clone(self.parsing_tb.handlecards) --手牌还原
    for i=start,en do

        local data=self.parsing_tb.step[i];
        local type_=data.type_

        if type_~=8 then --可以执行的操作
      
        



        if not type_ then
            --todo
            print(type_,"type_",i)
            error("快进出现问题了")
            return;
        end

        local seat_id = self:getSeat_ud(data.uid) 
        if self.currCaozuoUId~=data.uid then --切换正在操作的用户
            self.currCaozuoUId=data.uid
        end

        if type_==1 then
             --todo
            self.cardnum=self.cardnum-1
            self.currChu_card={
                t="zhua",
                uid=seat_id,
                card=data.card
            }

            print("抓了一张牌",data.card,i,seat_id)
        elseif type_==2 then
            --todo
            if self.currChu_card.t=="zhua"  then --大之前有抓拍
                table.insert(self.cards[seat_id],self.currChu_card.card);
            end
            --移除手牌
            cct.tableremovevalue(self.cards[seat_id],data.card)
            --插入打出的牌
            table.insert(self.userknockouts[seat_id],data.card);



            self.currChu_card={
                t="chu",
                uid=seat_id,
                card=data.card
            }
            print("出了一张牌",data.card,i,seat_id)
        elseif type_>3 and type_<=11 then --吃碰杠胡
  
           
            local card_=data.card
            --操作的牌
            local operation_card=card_
            if self.currChu_card.t=="zhua" then--
                --

            elseif self.currChu_card.t=="chu" then --打出的牌操作 

                --print("")
                local id=self.currChu_card.uid
                if id~=-1 and self.currChu_card.card then
                    --todo
                
                   print("operation_card",operation_card,type_)
                    cct.tableremovevalue(self.userknockouts[id],operation_card)
                else
                    error("快进出现异常")
                    return;
                end
            end
            ----------------------------------------------------

            if type_>=9 then--吃
                --todo
                local card1,card2,card3

                if type_==9 then
                    --todo
                    --删除手牌
                    cct.tableremovevalue(self.cards[seat_id],card_+1)
                    cct.tableremovevalue(self.cards[seat_id],card_+2)
                    card1=operation_card;
                    card2=card_+1
                    card3=card_+2
                elseif type_==10 then --中吃
                    cct.tableremovevalue(self.cards[seat_id],card_-1)
                    cct.tableremovevalue(self.cards[seat_id],card_+1)
                    card1=card_-1
                    card2=operation_card
                    card3=card_+1
                else --右吃
                    cct.tableremovevalue(self.cards[seat_id],card_-1)
                    cct.tableremovevalue(self.cards[seat_id],card_-2)
                    card1=card_-2
                    card2=card_-1
                    card3=operation_card
                end
                print("吃",data.card,i,seat_id)

                table.insert(self.userPlay[seat_id],{type=0,card={card1,card2,card3}})
            elseif type_>=4 and type_<=6 then     
                local isLastPeng=false
                if type_>4 then --杠
                    --todo
                    for k,v in pairs(self.userPlay[seat_id]) do
                        if v.card==card_ then --杠之前有碰 就直接杠了
                            --todo
                            self.userPlay[seat_id][k].type=type_-3
                            isLastPeng=true
                             print("杠   之前有碰",data.card,i,seat_id)
                            break;
                        end
                    end

                    --
                    if not isLastPeng  then
                        --todo
                        for n_i=1,3 do
                            cct.tableremovevalue(self.cards[seat_id],card_)--移除3张手牌 杠
                        end
                        print("杠",data.card,i,seat_id)

                        table.insert(self.userPlay[seat_id],{type=type_-3,card=card_})
                    end
                else --碰牌  移除2张
                    for n_i=1,2 do
                        cct.tableremovevalue(self.cards[seat_id],card_)
                    end
                    table.insert(self.userPlay[seat_id],{type=type_-3,card=card_})
                    print("碰",data.card,i,seat_id)

                end
            elseif type_==7 then--胡

                self.curr_hu[seat_id]={
                    card=card_,
                    pao_id=0,
                    hu_t=0
                } 
                    print("胡了",data.card,i,seat_id)

            end
            
            self.currChu_card={
                t="",
                uid=-1,
                card=0
            } 
        
        elseif type_==3 then --过
            print("过了",data.card,i,seat_id)
            
            --todo
        elseif type_==12 then --12 
            print("这一步是在海底",data.card,i,seat_id)

            self._man_data_.seat_id=seat_id
            self._man_data_.card=data.card
        end


    end --if

     print("结束了----------------------------------------------------------------")

     print("碰杠的拍")
     print_lua_table(self.userPlay)

     print("出的牌")
     print_lua_table(self.userknockouts)
     end--for


end

--快进
function transcribe:speed()
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
end

--快退
function transcribe:goBack()
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


    --清理UI
    self._scene:cleanUI();

    self.currFrame=self.currFrame-addNum;

    self:redrow_node();


    self.currFrame=self.currFrame+1


    self.isRunFrame=true
    self.isRun=true
end

--设置结算数据
function transcribe:setAccoutData()



        print("得到的结算数据是222")
    if not self.accoutData then
        self.accoutData={}
        --todo
        --print_lua_table(self.parsing_tb.endDataInof)
        for i=1,4 do
            local tb={}
            tb.te_card=self:pengGane(i-1,true) --碰杠吃牌
            tb.hand_card=self:draw_handle_cards(i-1,true)
            if  type(self.curr_hu[i-1])=="table" and self.curr_hu[i-1].card then --这个人胡了
                --todo
                tb.hu=cardToShow(self.curr_hu[i-1].card)
            end
            tb.nick=self.parsing_tb.userinfos[i-1].nick
            if self.parsing_tb.zhuang_id==i-1 then
                tb.zhuan=true--是否是庄
            end

            tb.card_info=self.parsing_tb.endDataInof[i-1].card_info
            tb.fanshu_data=self.parsing_tb.endDataInof[i-1].fanshu_data
            tb.sore=self.parsing_tb.endDataInof[i-1].score
            tb.huOrder=self.parsing_tb.endDataInof[i-1].huOrder
            table.insert(self.accoutData,tb)



        end

        print("得到的结算数据是")
         print_lua_table(self.accoutData)


        self.accoutData.game_type=self.game_type
        self.accoutData.roomId=self.activityId_ or "667852"
        self.accoutData.special=self.parsing_tb.special or "" --特殊规则
        self.accoutData.timer=self.parsing_tb.timer --时间
        if self.game_type~=1 then
            --todo
            self.accoutData.zhuaCards=self:zn_cards(nil,true)
        end

    end

    
    self._scene:showAccount(self.accoutData)

end

--退出
function transcribe:exitvedio()
    scheduler.unscheduleGlobal(self._schhandle)
    isRun=false
    self._scene:removeFromParent();
    self._scene=nil;
    display_scene("hall.gameScene")
    audio.stopMusic(false);
    cc.Director:getInstance():resume();
end



return transcribe