local targetPlatform = cc.Application:getInstance():getTargetPlatform()
local MatchSetting  = class("MatchSetting")
local PROTOCOL = require("ddz.ddz_PROTOCOL")
local ddzServer = import("ddz.ddzServer")
local ddzHandle  = require("ddz.ddzHandle")

local matchInfoList = 
{
    [1] = 66,
    [2] = 45,
    [3] = 21,
    [4] = 6,
    [5] = 3
}

local matchIncentive = 
{
    [22] = {
    [1] = {1,1,450},
    [2] = {2,2,300},
    [3] = {3,3,210},
    [4] = {4,15,60},
    [5] = {16,30,0},
    },
    [23] = {
    [1] = {1,1,4500},
    [2] = {2,2,3000},
    [3] = {3,3,2100},
    [4] = {4,15,600},
    [5] = {16,30,0},
    },
    [24] = {
    [1] = {1,1,450},
    [2] = {2,2,300},
    [3] = {3,3,210},
    [4] = {4,15,60},
    [5] = {16,30,0},
    },
    [25] = {
    [1] = {1,1,4500},
    [2] = {2,2,3000},
    [3] = {3,3,2100},
    [4] = {4,15,600},
    [5] = {16,30,0},
    }
}
local currentRound = 1
local bJoin = false
local tbResult = {}

--设置当前轮次人数
function MatchSetting:setRankInfo(tbRank)
    -- body
    if tbRank == nil then
        return
    end
    for j,v in ipairs(tbRank) do
        matchInfoList[j] = tbRank[j]
    end
    print("neo")
    print_lua_table(matchInfoList)
end
--获取比赛奖励
--level,比赛场id
--rank，玩家名次
function MatchSetting:getIncentive(level,rank)
    -- body
    print("getIncentive:",level,rank)
    local sch = matchIncentive[level]
    if sch == nil then
        return 0
    end
    local hi = 1
    local low = 1
    for i,v in ipairs(sch) do
        if rank >= v[1] and rank <= v[2] then
            return v[3]
        end
    end
    print("getIncentive: 0",level,rank)
    return 0
end
--设置比赛奖励
function MatchSetting:setIncentive( data )
    -- body
    print(tolua.type(data["data"]))
    if data["data"][1] == nil then
        return
    end
    local level = data["data"][1]["level"]
    matchIncentive[level] = {}
    for i,v in ipairs(data["data"]) do
        print(i)
        local str = v["rank"]
        print(str)
        local pos = string.find(str,"-")
        local hi = tonumber(string.sub(str,1,pos-1))
        local low = tonumber(string.sub(str,pos+1,string.len(str)))
        local sch = matchIncentive[v["level"]]
        sch[i] = {}
        sch[i][1] = hi
        sch[i][2] = low
        sch[i][3] = v["coin"]
    end
    print("setIncentive seted")
    dump(matchIncentive,"setIncentive")
    if tolua.isnull(SCENENOW["scene"]) == false then
        local layer = SCENENOW["scene"]:getChildByName("layer_sign")
        if layer then
            self:getIncentiveList(level)
        end
    end
end

--比赛场奖励方案文案
--level,那个比赛场
function MatchSetting:getIncentiveHelp(level)
    -- body
    local sch = matchIncentive[level]
    if sch == nil then
        return "  （游戏说明：此游戏最终解释权归兜游网络科技有限公司。）"
    end

    local strHelp = ""
    for i, v in ipairs(sch) do
        if v[3] > 0 then
            local str = 1
            if v[1] == v[2] then
                str = "第"..tostring(v[1]).."名："
                for i=string.len(str),15 do
                    str = str.." "
                end
                str = str..tostring(v[3]).."兜币"
            else
                str = "第"..tostring(v[1]).."-"..tostring(v[2]).."名："
                for i=string.len(str),15 do
                    str = str.." "
                end
                str = str..tostring(v[3]).."兜币"
            end
            if i > 1 then
                strHelp = strHelp .. "\n"
            end
            strHelp = strHelp .. str
        end
    end
    strHelp = strHelp .. "\n\n  （游戏说明：此游戏最终解释权归兜游网络科技有限公司。）"
    print("level:"..tostring(level).."  -->"..strHelp)
    return strHelp
end
--比赛奖励方案
function MatchSetting:getIncentiveList(level)
    local layerSign = SCENENOW["scene"]:getChildByName("layer_sign")
    if layerSign == nil then
        return
    end
    local sch = matchIncentive[level]
    dump(sch, "getIncentive")
    if sch == nil then
        return
    end
    table.sort(sch,function(a,b)
        return a[3] > b[3]
        end)

    local lv = layerSign:getChildByName("lv_jiangli")
    local sizeWidth = 500
    local sizeHeight = 62
    local startY = 124
    local pos = 0
    if lv then
        lv:removeAllChildren()
        for i, v in ipairs(sch) do
            if v[3] > 0 then
                local layout = cc.Layer:create()
                layout:setContentSize(cc.size(sizeWidth,sizeHeight))
                lv:addChild(layout)
                layout:setPosition(0, startY-pos*sizeHeight)
                local str = 1
                if v[1] == v[2] then
                    str = "第"..tostring(v[1]).."名："
                    for i=string.len(str),15 do
                        str = str.." "
                    end
                    str = str..tostring(v[3]).."兜币"
                else
                    str = "第"..tostring(v[1]).."-"..tostring(v[2]).."名："
                    for i=string.len(str),15 do
                        str = str.." "
                    end
                    str = str..tostring(v[3]).."兜币"
                end
                print("getIncentive",str)
                local lb = cc.Label:createWithTTF(str,"res/fonts/fzcy.ttf",34)
                lb:setColor(cc.c3b(0x27,0x8f,0xe6))
                lb:setPosition(sizeWidth/2, sizeHeight/2)
                layout:addChild(lb)
                local spLine = display.newSprite("hall/monthcard/chat_line.png")
                spLine:setPosition(sizeWidth/2, lb:getPositionY()-lb:getContentSize().height/2-10)
                layout:addChild(spLine)
                pos = pos + 1
            end
        end
    end

end
--比赛报名
--flag 是不显示
--signcount 已报名人数
--totalcount 满多少人开赛
--entryFee 报名费
--code 游戏
--比赛等级（对应报名费）
function MatchSetting:showMatchSignup(flag,signcount,totalcount,entryFee,code,matchlevel)
    if flag == false then
        USER_INFO["match_fee"] = 0
        require("ddz.MatchSetting"):setJoinMatch(false)
        SCENENOW["scene"]:removeChildByName("layer_sign")
        return
    end

    local gameLevel = matchlevel
    code = code or "hall"

    require("ddz.DDZHttpNet"):requestIncentive(matchlevel)

    if SCENENOW["scene"]:getChildByName("layer_sign") then
        print("exist layer_sign")
        local btnMatchLogout = SCENENOW["scene"]:getChildByName("layer_sign"):getChildByName("btn_match_logout")
        if btnMatchLogout then
            --btnMatchLogout:setVisible(true)
            --btnMatchLogout:setEnabled(true)
        end
        return
    end

    local layer_sign = cc.CSLoader:createNode(code.."/csb/LayerSignup.csb"):addTo(SCENENOW["scene"])
    layer_sign:setName("layer_sign")

    local function actionEnd()
        local layout_join = layer_sign:getChildByName("layout_join")

        local txt = layer_sign:getChildByName("txt_baoming")
        if txt then
            txt:setString(tostring(signcount))
        end
        txt = layer_sign:getChildByName("txt_full")
        if txt then
            txt:setString(tostring(totalcount))
        end
        --报名
        local btnSignup = layer_sign:getChildByName("btn_join")
        if btnSignup then
            btnSignup:setVisible(true)
            btnSignup:setEnabled(true)
        end
        --退赛
        local btnMatchLogout = layer_sign:getChildByName("btn_match_logout")
        if btnMatchLogout then
            btnMatchLogout:setVisible(false)
            btnMatchLogout:setEnabled(false)
        end

        --再次参赛
        if USER_INFO["match_fee"] > 0 then
            self:setJoinMatch(true)
        end
        --退出
        local btn_exit = layer_sign:getChildByName("btn_exit")
        local function exit( ... )
            -- body
            --已报名，不能退出
            if USER_INFO["match_fee"] then
                if USER_INFO["match_fee"] > 0 then
                    print("match fee:"..USER_INFO["match_fee"])
                    return
                end
            end

            require("hall.GameCommon"):playEffectSound("hallAudio_Button_Click.mp3")
            local function endLayout()
                SCENENOW["scene"]:removeChildByName("layer_sign")
            end

            local st = cc.ScaleTo:create(0.2,0)
            local seq = cc.Sequence:create(st,cc.CallFunc:create(endLayout))
            layer_sign:runAction(seq)
        end
        --事件回调
        local function touchEvent(sender, event)
            --缩小ui
            if sender.id == "math" then
                print("match logout")
            end
            if event == TOUCH_EVENT_BEGAN then
                require("hall.GameCommon"):playEffectSound("hall/Audio_Button_Click.mp3")
                -- sender:setScale(0.9);
            end
            if event == TOUCH_EVENT_CANCEL then
                -- sender:setScale(1)
            end
            if event == TOUCH_EVENT_ENDED then
                -- sender:setScale(1)
                --调出出报名页面
                if sender == btnSignup then
                    print("================signup=============="..gameLevel)
                    ddzServer:CLI_SEND_JOIN_MATCH(gameLevel)
                    self:setRankInfo(require("ddz.ddzSettings"):getMatchLevelRankInfo(gameLevel))

                    btnSignup:setEnabled(false)
                    btnSignup:setVisible(false)
                    USER_INFO["match_fee"] = entryFee
                    require("hall.gameSettings"):setGameMode("match")
                    btn_exit:setEnabled(false)
                    btn_exit:setVisible(false)
                end
                --退出比赛
                if sender == btnMatchLogout then
                    print("================match logout=============="..gameLevel)
                    require("ddz.ddzServer"):CLI_SEND_LOGOUT_MATCH(gameLevel)
                    btnMatchLogout:setEnabled(false)
                    btnMatchLogout:setVisible(false)
                end
                if sender == btn_exit then
                    print("signup exit")
                    exit()
                end

            end
        end
        if btnSignup then
            btnSignup:addTouchEventListener(touchEvent)
        end
        if btnMatchLogout then
            btnMatchLogout.id="math"
            btnMatchLogout:addTouchEventListener(touchEvent)
        end
        if btn_exit then
            btn_exit:addTouchEventListener(touchEvent)
        end
        --退出
        local back = layer_sign:getChildByName("baoming")
        if back then
            back:addTouchEventListener(function(event,type)
                if(type == 2) then
                    exit()
                end
            end)
        end
    end

    layer_sign:setScale(0.1)
    layer_sign:setAnchorPoint(cc.p(0.5,0.5))
    layer_sign:setPosition(cc.p(480,270))
    local st = cc.ScaleTo:create(0.2,1)
    local seq = cc.Sequence:create(st,cc.CallFunc:create(actionEnd))
    layer_sign:runAction(seq)

end
--
function MatchSetting:setJoinMatch(flag)
    -- body
    bJoin = flag

    local layer_sign = SCENENOW["scene"]:getChildByName("layer_sign")
    if layer_sign then
        --报名
        local btnSignup = layer_sign:getChildByName("btn_join")
        --退赛
        local btnMatchLogout = layer_sign:getChildByName("btn_match_logout")

        if btnSignup then
            btnSignup:setVisible(not bJoin)
            btnSignup:setEnabled(not bJoin)
        end
        if btnMatchLogout then
            btnMatchLogout:setVisible(bJoin)
            btnMatchLogout:setEnabled(bJoin)
        end

        local btn_exit = layer_sign:getChildByName("btn_exit")
        if btn_exit then
            btn_exit:setEnabled(not bJoin)
            btn_exit:setVisible(not bJoin)
        end
    end
end
--收起所有结果显示
function MatchSetting:offLayers()
    if SCENENOW["scene"]:getChildByName("match_win") then
        SCENENOW["scene"]:removeChildByName("match_win")
    end
    if SCENENOW["scene"]:getChildByName("match_lose") then
        SCENENOW["scene"]:removeChildByName("match_lose")
    end
    if SCENENOW["scene"]:getChildByName("match_wait") then
        SCENENOW["scene"]:removeChildByName("match_wait")
    end
    if SCENENOW["scene"]:getChildByName("match_result") then
        SCENENOW["scene"]:removeChildByName("match_result")
    end
end

--设置比赛当前轮次
--round,当前轮次
--sheaves，当前轮次局数
--默认round==0 只打一局
function MatchSetting:setCurrentRound(round,sheaves)
    -- body
    if round == 0 then
        currentRound = sheaves
    elseif round == 1 then
        currentRound = sheaves + 1
    end
end

function MatchSetting:createRanking(round)
    -- body
    local layer = cc.Layer:create()
    local x = 0
    local y = 0
    local width = 0
    local offsetX = 10
    for i, v in ipairs(matchInfoList) do
        --横杠
        if i > 1 then
            local spLine = display.newSprite("ddz/match/promotion_mingci_box01.png")
            if spLine then
                layer:addChild(spLine)
                x = x + spLine:getContentSize().width/2 - offsetX
                spLine:setPosition(cc.p(x,0))
                x = x + spLine:getContentSize().width/2
                width = width + spLine:getContentSize().width - offsetX
                layer:setContentSize(cc.size(width,spLine:getContentSize().height))
            end
        end
        local str = ""
        local strFont = ""
        if i == round then
            str = "ddz/match/promotion_mingci_p.png"
            strFont = "ddz/match/promotion_mingci_green.fnt"
        else
            str = "ddz/match/promotion_mingci_n.png"
            strFont = "ddz/match/promotion_mingci.fnt"
        end
        local spBack = display.newSprite("ddz/match/promotion_mingci_box02.png")
        local sp = display.newSprite(str)
        spBack:addChild(sp)
        sp:setPosition(spBack:getContentSize().width/2, spBack:getContentSize().height/2)

        local lb = cc.Label:createWithBMFont(strFont,tostring(v))
        sp:addChild(lb)
        lb:setPosition(cc.p(sp:getContentSize().width/2,sp:getContentSize().height/2))
        layer:addChild(spBack)

        x = x + spBack:getContentSize().width/2 - offsetX
        spBack:setPosition(cc.p(x,0))
        x = x + spBack:getContentSize().width/2
        width = width + spBack:getContentSize().width - offsetX
        layer:setContentSize(cc.size(width,spBack:getContentSize().height))
    end
    return layer
end

--牌局结束，晋级成功
--rank_c 当前名次
--rank_b 之前名次
--round 比赛轮次
--code 游戏
function MatchSetting:showMatchWin(rank_c,rank_b,round,code)
    self:offLayers()

    code = code or "hall"

    local match_win = cc.CSLoader:createNode(code.."/match/MatchWin.csb"):addTo(SCENENOW["scene"])
    match_win:setName("match_win")

    local txt_rank = match_win:getChildByName("txt_rank")
    txt_rank:setString(tostring(rank_c))

    local txt_rank_before = match_win:getChildByName("txt_rank_before")
    txt_rank_before:setString(tostring(rank_b))

    local txt_eliminate = match_win:getChildByName("txt_eliminate")
    txt_eliminate:setString(tostring(matchInfoList[round+1]))

    local ranking = self:createRanking(round+1)
    if ranking then
        match_win:addChild(ranking)
        ranking:setPosition(cc.p(480-ranking:getContentSize().width/2,118))
    end

    if rank_c == rank_b then
        -- txt_rank_before:setString(tostring(rank_c))
        txt_rank:setVisible(false)
        if rank_c==1 then
            txt_rank_before:runAction(cc.Sequence:create(
                cc.ScaleTo:create(0.1,1.2),
                cc.ScaleTo:create(0.1,1),
                cc.ScaleTo:create(0.1,1.2),
                cc.ScaleTo:create(0.1,1),
                cc.ScaleTo:create(0.1,1.2),
                cc.ScaleTo:create(0.1,1),
                cc.ScaleTo:create(0.1,1.2),
                cc.ScaleTo:create(0.1,1)
            ))
        end
    else
        local time = 0.5
        local rankY = txt_rank_before:getPositionY()
        if txt_rank then
            -- txt_rank:setString(tostring(rank_c))
            txt_rank:setOpacity(0)
            local fo = cc.FadeIn:create(time)
            local mt = cc.MoveTo:create(time,cc.p(txt_rank:getPositionX(),rankY))
            local spawn = cc.Spawn:create(fo,mt)
            txt_rank:runAction(spawn)
        end

        if txt_rank_before then
            -- txt_rank_before:setString(tostring(rank_b))
            local fi = cc.FadeOut:create(time)
            local mt = cc.MoveTo:create(time,cc.p(txt_rank_before:getPositionX(),rankY-50))
            local spawn = cc.Spawn:create(fi,mt)
            txt_rank_before:runAction(spawn)
            USER_INFO["match_rank"] = rank_c
        end
    end
end
--牌局结束，晋级失败
--rank_c 当前名次
--rank_b 之前名次
--round 比赛轮次
--code 游戏
function MatchSetting:showMatchLose(rank_c,rank_b,round,code)
    self:offLayers()
    code = code or "hall"

    local match_lose = cc.CSLoader:createNode(code.."/match/MatchLose.csb"):addTo(SCENENOW["scene"])
    match_lose:setName("match_lose")

    local txt_rank = match_lose:getChildByName("txt_rank")
    txt_rank:setString(tostring(rank_c))

    local txt_rank_before = match_lose:getChildByName("txt_rank_before")
    txt_rank_before:setString(tostring(rank_b))

    local txt_eliminate = match_lose:getChildByName("txt_eliminate")
    txt_eliminate:setString(tostring(matchInfoList[round+1]))

    local ranking = self:createRanking(round+1)
    if ranking then
        match_lose:addChild(ranking)
        ranking:setPosition(cc.p(480-ranking:getContentSize().width/2,118))
    end

    if rank_c == rank_b then
        -- txt_rank_before:setString(tostring(rank_c))
        txt_rank:setVisible(false)
    else
        local time = 0.5
        local rankY = txt_rank_before:getPositionY()
        if txt_rank then
            -- txt_rank:setString(tostring(rank_c))
            txt_rank:setOpacity(0)
            local fo = cc.FadeIn:create(time)
            local mt = cc.MoveTo:create(time,cc.p(txt_rank:getPositionX(),rankY))
            local spawn = cc.Spawn:create(fo,mt)
            txt_rank:runAction(spawn)
        end

        if txt_rank_before then
            -- txt_rank_before:setString(tostring(rank_b))
            local fi = cc.FadeOut:create(time)
            local mt = cc.MoveTo:create(time,cc.p(txt_rank_before:getPositionX(),rankY-50))
            local spawn = cc.Spawn:create(fi,mt)
            txt_rank_before:runAction(spawn)
        end
        if USER_INFO["match_rank"] == nil then
            USER_INFO["match_rank"] = 0
        end

        USER_INFO["match_rank"] = 0
    end
end

--等待比赛结算
function MatchSetting:showMatchWait(flag,code)
    if flag == false then
        SCENENOW["scene"]:removeChildByName("match_wait")
        bShowMatchWait = false
        return
    end
    self:offLayers()
    code = code or "hall"

    local match_wait = cc.CSLoader:createNode(code.."/match/MatchWait.csb"):addTo(SCENENOW["scene"])
    match_wait:setName("match_wait")

    local ranking = self:createRanking(currentRound)
    if ranking then
        match_wait:addChild(ranking)
        ranking:setPosition(cc.p(480-ranking:getContentSize().width/2,118))
    end


    fTimeMatchWait = 0
    idxRound = 1
    bShowMatchWait = true
end

--比赛结果
--rank 最终名次
--maxnumber 最大报名人数
--time 颁奖时间
--code 游戏
function MatchSetting:showMatchResult()
    currentRound = 1
    self:offLayers()

    dump(tbResult,"showMatchResult")
    --给用户加金币
    USER_INFO["gold"] = USER_INFO["gold"] + tbResult["incentive"]

    --退出比赛
    require("hall.GameSetting"):enterMatch(0)
    local match_result = cc.CSLoader:createNode("ddz/match/MatchResult.csb"):addTo(SCENENOW["scene"])
    match_result:setName("match_result")


    match_result:setVisible(true)
    local lbRank = match_result:getChildByName("txt_ranking")
    if lbRank then
        lbRank:setString(tostring(tbResult["rank"]))
    end
    local lbNick = match_result:getChildByName("txt_nickName")
    if lbNick then
        local strNick = require("hall.GameCommon"):formatNick(USER_INFO["nick"])
        lbNick:setString(strNick)
    end

    local txt_time = match_result:getChildByName("txt_time")
    txt_time:setString(os.date("%Y-%m-%d %H:%M", tbResult["time"]))

    --奖励
    local txt_incentive = match_result:getChildByName("txt_incentive")
    if txt_incentive then
        txt_incentive:setString(tostring(tbResult["incentive"]))
    end

    local btnExit = match_result:getChildByName("btn_exit")
    if btnExit then
        btnExit:addTouchEventListener(function(event,type)
            if(type == 2) then
                require("hall.GameCommon"):playEffectSound("audio/Audio_Button_Click.mp3")
                --退出游戏
                require("ddz.ddzServer"):CLI_SEND_LOGOUT_MATCH(require("ddz.ddzSettings"):getMatchId())
                --避免重复点击
                btnExit:setVisible(false)
                btnExit:setEnabled(false)
                require("hall.gameSettings"):setGameMode("match")
                USER_INFO["match_fee"] = 0
                display_scene("ddz.SelectChip",1)
            end
        end)
    end
    local btnMatch = match_result:getChildByName("btn_match")
    if btnMatch then
        btnMatch:addTouchEventListener(function(event,type)
            if(type == 2) then
                require("hall.GameCommon"):playEffectSound("audio/Audio_Button_Click.mp3")
                --重新报名
                require("hall.gameSettings"):setGameMode("match")
                display_scene(tbResult["code"]..".SelectChip",1)
            end
        end)
    end
end

--设置比赛结果
function MatchSetting:setMatchResult(rank,maxnumber,time,code,incentive)
    -- body
    print("incentive",type(incentive))
    tbResult["rank"] = rank
    tbResult["maxnumber"] = maxnumber
    tbResult["time"] = time
    tbResult["code"] = code
    tbResult["incentive"] = 0
    tbResult["incentive"] = incentive

    dump(tbResult,"setMatchResult")
end

--获取当前比赛轮次
function MatchSetting:getCurrentRank()
    -- body
    return currentRound
end

function MatchSetting:joinMatch(signcount,totalcount)
    local layer_sign = SCENENOW["scene"]:getChildByName("layer_sign")

    if layer_sign then
        local txtSign = layer_sign:getChildByName("txt_baoming")
        if txtSign then
            txtSign:setString(tostring(signcount))
        end
        --人数已满，准备开始
        if signcount >= totalcount then
            local btnLogout = layer_sign:getChildByName("btn_match_logout")
            if btnLogout then
                btnLogout:setTouchEnabled(false)
                -- btnLogout:setColor(cc.c3b(125,125,125))
                btnLogout:loadTextureNormal("hall/common/small_disable_bt_n.png")
            end
            local btnJoin = layer_sign:getChildByName("btn_join")
            if btnJoin then
                btnJoin:setVisible(false)
            end
        end
    end

end

return MatchSetting