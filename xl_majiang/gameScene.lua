--
-- Author: ZT
-- Date: 2016-05-11 10:43:49
-- 组局调用
require("xl_majiang.card_path")
local mjscene=import(".majiangScene")
local gameScene=class("gameScene",mjscene)
local PROTOCOL         = import("xl_majiang.scenes.Majiang_Protocol")
local state=0 -- 1 进入组局  2 开始组局 3 结束一局 4组局结束
function gameScene:groupRun()
	--登陆房间
    state=0
    require("xl_majiang.majiangServer"):LoginGame(USER_INFO["GroupLevel"])
end

function gameScene:hideGropMenu(s)

	-- --设置组局菜单
 --    local this=s;
 --    local root=this._scene;

 --    local btnexit=root:getChildByName("quit_room")
 --    local btnmune=root:getChildByName("btn_menu")
 --    local textTimer=root:getChildByName("Txttimer")

 --    local groupMune
 --    local groupMuneP
 --    local view


 --    state=1;
 --    -- if bm.isGroup then
 --    if require("hall.gameSettings"):getGameMode() == "group" then
 --        require("xl_majiang.ddzSettings"):setEndGroup(0)
 --        --groupMuneP:setLocalZOrder(999999)
 --        btnexit:hide()
 --        btnmune:show()

 --        --组局时间
 --        textTimer:show()

 --        local function setGroup()
           

 --            local btnsee=groupMune:getChildByName("btn_sideSee")
 --            btnsee:onClick(function()
 --                --围观  暂时没做

 --            end)

 --            local btnaddBet=groupMune:getChildByName("btn_addBet")
 --               btnaddBet:onClick(function()

 --                require("hall.GameCommon"):showChange(true)
 --            end)

 --            local btnaHis=groupMune:getChildByName("btn_records")
 --            btnaHis:onClick(function()
 --                require("hall.GameCommon"):getHistory();
 --            end)

 --            local btnaexitGrop=groupMune:getChildByName("btn_exitGroup")
 --            btnaexitGrop:onClick(function()
 --                print("btn_exitGroup",tostring(state))
 --                if state == 0 then
 --                    require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])
 --                elseif state==2 then
 --                    --todo
 --                    require("hall.GameTips"):showTips("提示", "", 3, "游戏已开始，不能退出")
 --                -- elseif state==3 then
 --                else
 --                    require("xl_majiang.ddzSettings"):setEndGroup(2)
 --                    require("xl_majiang.scenes.MajiangroomServer"):quickRoom()
 --                end

 --            end)
 --        end

 --    	btnmune:onClick(function()
 --                view            = cc.CSLoader:createNode("xl_majiang/scens/GroupScene.csb"):addTo(this,99999)
                   
 --                groupMune=view:getChildByName("Panel_1"):getChildByName("layout_group")
 --                groupMuneP=view:getChildByName("Panel_1")
 --                groupMuneP:setScale(0.1)

 --    		    btnmune:setTouchEnabled(false)
 --    	        groupMuneP:setScale(1)
 --                groupMuneP:addTouchEventListener(function(sender, state)
                    
 --                    if state == 2 then
 --                        if groupMune:getScale()==1 then
 --                            --todo
 --                            local ac=cc.Sequence:create(cc.ScaleTo:create(0.4,0.01),cc.CallFunc:create(function()
 --                               view:removeFromParent();
 --                            end))
 --                            groupMune:runAction(ac);
 --                        end
 --                    end
 --                end)
   
 --    			local ac=cc.Sequence:create(cc.ScaleTo:create(0.4,1),cc.CallFunc:create(function()
 --                        setGroup()
 --    					btnmune:setTouchEnabled(true)
 --    				end))
 --    			groupMune:runAction(ac);

 --    	end)

 --    else
 --    	textTimer:hide();
 --    	btnexit:show();
 --        btnmune:hide()
 --    	--btnmune:hide();
 --    end

 --    textTimer:hide();
 
end

function gameScene:checkChip(s)
    print("checkChip",tostring(bm.isGroup))
	local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_GET_CHIP)
    :setParameter("uid", USER_INFO["uid"])
    :build()
    bm.server:send(pack)
end


--获取筹码
function gameScene:onNetGetChip(pack)
    USER_INFO["chips"] = pack["chip"]

    --检查筹码是否足够
    if require("hall.common.GroupGame"):checkMoney2Chips() then

        if require("hall.common.GroupGame"):checkChips() then
            --发送准备消息
            SCENENOW["scene"]:gameReady();
        else
            require("hall.GameCommon"):showChange(true)
        end
    end

end

--请求兑换筹码返回
function gameScene:onChipSuccess(pack)

    dump(pack, "onChipSuccess")
    if tonumber(pack["uid"]) == tonumber(USER_INFO["uid"]) then
        USER_INFO["chips"] = pack["chip"]
        USER_INFO["score"] = pack["money"]
        USER_INFO["gold"] = pack["money"]
        
        SCENENOW["scene"]:set_player_gold(0,USER_INFO["chips"])
        print("USER_INFOchips",USER_INFO["chips"])
        if require("hall.common.GroupGame"):checkChips() then
            --发送准备消息
            SCENENOW["scene"]:gameReady();

        else
            require("hall.GameCommon"):showChange(true)
        end
    else
        local index=require("xl_majiang.scenes.MajiangroomHandle"):getIndex(pack["uid"])
        --show other user id 
        SCENENOW["scene"]:set_player_gold(index,pack["chip"])
    end


end



--游戏开始剩余显示时间
function gameScene:showTimer(time)


    -- USER_INFO["group_lift_time"] = time
    -- local textTimer = SCENENOW["scene"]._scene:getChildByName("Txttimer")
    -- textTimer:show()
    -- textTimer:setString("当前第".. bm.round .. "局")

 --    local function transformTimer(times)
	-- 	--timer is sec
 --        if times<=0 then
 --            --todo
 --            return "0";
 --        end
	-- 	local h=0
	-- 	local m=0
	-- 	local s=0
	-- 	local function toStr(m_)
	-- 		local str=""
	-- 		if m_==0 or m_=="0" then
	-- 			--todo
	-- 			str="00"
	-- 		elseif m_<10 then
	-- 			--todo
	-- 			str="0"..m_
	-- 		elseif m_>99 then
	-- 			str="99"
	-- 		else
	-- 			str=m_
	-- 		end

	-- 		return str
	-- 	end
	-- 	if times>60*60 then
	-- 			--todo
	-- 		h=math.floor(times/(60*60))
	-- 		times=times-h*(60*60)
	-- 	end
		
	-- 	if times>60 then
	-- 			--todo
	-- 		m=math.floor(times/(60))
	-- 		times=times-m*(60)
	-- 	end
	-- 	s=math.floor(times)

	-- 	local str=""
	-- 	str=toStr(h)..":"..toStr(m)..":"..toStr(s)

	-- 	return str;

	-- end
 --    textTimer:setColor(cc.c3b(0, 255, 0))

 --    local ac=cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function()
 --            USER_INFO["group_lift_time"]=USER_INFO["group_lift_time"]-1;
 --            if USER_INFO["group_lift_time"]<=10*60 then
 --                --todo
 --                textTimer:setColor(cc.c3b(255, 0, 0))
 --            end
 --            textTimer:setString(transformTimer(USER_INFO["group_lift_time"]))
 --        end)))
 --    textTimer:setString(transformTimer(USER_INFO["group_lift_time"]))
 --    textTimer:runAction(ac)
 --    -- textTimer:setPositionY(textTimer:getPositionY())
 --    textTimer:setPosition(960-textTimer:getContentSize().width/2-20, textTimer:getContentSize().height/2+10)
 --    textTimer:setLocalZOrder(9999);

end


--获取历史记录
function gameScene:onNetHistory(pack)
    -- body
    -- local info = json.decode(pack["playerlist"])
    local playerlist = {}
    for i, v in ipairs(pack["playerlist"]) do
        playerlist[v["uid"]] = json.decode(v["user_info"])
    end




    print_lua_table(playerlist)
    local his = json.decode(pack["history"])
    dump(his, "userHistory")
    dump(playerlist, "playerlist")

    if his ~= null then
        for i,v in ipairs(his) do
            local tbPlayers = {}
            --print_lua_table(v)
            for j, k in ipairs(v) do
                local uid = k["user_id"]
                table.insert(tbPlayers,{uid,playerlist[uid]["nick_name"],k["user_chip_variation"],playerlist[uid]["photo_url"],playerlist[uid]["sex"]})
            end
            require("hall.GameCommon"):addHistoryItem(i,tbPlayers,0.75)
        end
    end
    require("hall.GameCommon"):showHistory(true)
end


--排行榜
function gameScene:onNetBillboard(pack)
	-- body
    dump(pack,"onNetBillboard")
    self:setGameState(4)
    --dump(pack)
    local info = pack["playerlist"]

    groupRanking = {}
    for i,v in pairs(info) do
        groupRanking[v["uid"]] = json.decode(v["user_info"])
    end
    group_game_amount = pack["game_amount"]


    require("hall.common.GroupGame"):showRanking(groupRanking,group_game_amount)
    require("xl_majiang.ddzSettings"):setEndGroup(1)
    require("xl_majiang.scenes.MajiangroomServer"):quickRoom()

end


function gameScene:setGameState(s)
    state=s
end
return gameScene