
local targetPlatform = cc.Application:getInstance():getTargetPlatform()
local MatchSetting  = class("MatchSetting")
-- local PROTOCOL = require("majiang.scenes.Majiang_Protocol")
-- local ddzHandle  = require("majiang.scenes.MajiangroomHandle")
local MajiangroomServer = require("xl_majiang.scenes.MajiangroomServer")

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
local match_state = 0

--设置当前轮次人数
function MatchSetting:setRankInfo(tbRank)
    -- body
    if tbRank == nil then
        return
    end
    for j,v in ipairs(tbRank) do
        matchInfoList[j] = tbRank[j]
    end
    dump(tbRank,"tbRank----------------")
end
--获取比赛奖励
--level,比赛场id
--rank，玩家名次
function MatchSetting:getIncentive(level,rank)
    -- body
--    if level == 30 then
 --      level = 61 
 --   end

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
    return 0
end

--比赛场奖励方案文案
--level,那个比赛场
function MatchSetting:getIncentiveHelp(level)
    -- -- body
    -- local sch = matchIncentive[level]
    -- if sch == nil then
    --     return "  （游戏说明：此游戏最终解释权归兜游网络科技有限公司。）"
    -- end

    -- local strHelp = ""
    -- for i, v in ipairs(sch) do
    --     if v[3] > 0 then
    --         local str = 1
    --         if v[1] == v[2] then
    --             str = "第"..tostring(v[1]).."名："
    --             for i=string.len(str),15 do
    --                 str = str.." "
    --             end
    --             str = str..tostring(v[3]).."兜币"
    --         else
    --             str = "第"..tostring(v[1]).."-"..tostring(v[2]).."名："
    --             for i=string.len(str),15 do
    --                 str = str.." "
    --             end
    --             str = str..tostring(v[3]).."兜币"
    --         end
    --         if i > 1 then
    --             strHelp = strHelp .. "\n"
    --         end
    --         strHelp = strHelp .. str
    --     end
    -- end
    -- strHelp = strHelp .. "\n\n  （游戏说明：此游戏最终解释权归兜游网络科技有限公司。）"
    -- print("level:"..tostring(level).."  -->"..strHelp)
    -- return strHelp
end

--设置比赛奖励
function MatchSetting:setIncentive( data )
    -- -- body
    -- print(tolua.type(data["data"]))
    -- if data["data"][1] == nil then
    --     return
    -- end
    -- local level = data["data"][1]["level"]
    -- matchIncentive[level] = {}
    -- for i,v in ipairs(data["data"]) do
    --     print(i)
    --     print_lua_table(v)
    --     local str = v["rank"]
    --     print(str)
    --     local pos = string.find(str,"-")
    --     local hi = tonumber(string.sub(str,1,pos-1))
    --     print("setIncentive:",v["level"],"hi:",hi)
    --     local low = tonumber(string.sub(str,pos+1,string.len(str)))
    --     print("setIncentive:",v["level"],"low:",low)
    --     local sch = matchIncentive[v["level"]]
    --     sch[i] = {}
    --     sch[i][1] = hi
    --     sch[i][2] = low
    --     sch[i][3] = v["coin"]
    -- end
    -- dump(matchIncentive,"matchIncentive")

    -- if tolua.isnull(SCENENOW["scene"]) == false then
    --     local layer = SCENENOW["scene"]:getChildByName("layer_sign")
    --     if layer then
    --         local txt_detail = layer:getChildByName("txt_match_detail")
    --         if txt_detail then
    --             txt_detail:setString(self:getIncentiveHelp(level))

    --             txt_detail:ignoreContentAdaptWithSize(false)
    --             local tmp_width = txt_detail:getContentSize().width
    --             local end_height = (tmp_width/240+1)*30*2
    --             txt_detail:setSize(240,end_height)
    --         end
    --     end
    -- end
end

--比赛报名
--flag 是不显示
--signcount 已报名人数
--totalcount 满多少人开赛
--entryFee 报名费
--code 游戏
--比赛等级（对应报名费）
function MatchSetting:showMatchSignup(flag,signcount,totalcount,entryFee,code,matchlevel,matchId)
    -- if flag == false then
    --     SCENENOW["scene"]:removeChildByName("layer_sign")
    --     return
    -- end

    -- local gameLevel = matchlevel
    -- code = code or "hall"

    -- require("xl_majiang.HallHttpNet"):requestIncentive(matchlevel)


    -- if SCENENOW["scene"]:getChildByName("layer_sign") then
    --     return
    -- end

    -- local layer_sign = cc.CSLoader:createNode(code.."/match/LayerSignup.csb"):addTo(SCENENOW["scene"])
    -- layer_sign:setName("layer_sign")

    -- local txt_detail = layer_sign:getChildByName("txt_match_detail")
    -- if txt_detail then
    --     txt_detail:setString(self:getIncentiveHelp(matchlevel))

    --     txt_detail:ignoreContentAdaptWithSize(false)
    --     local tmp_width = txt_detail:getContentSize().width
    --     local end_height = (tmp_width/240+1)*30*2
    --     txt_detail:setSize(240,end_height)
    -- end


    -- local function actionEnd()
    --     local layout_join = layer_sign:getChildByName("layout_join")
    --     local txt_match_detail = layer_sign:getChildByName("txt_match_detail")

    --     local txt = layer_sign:getChildByName("layout_join"):getChildByName("txt_playercount")
    --     if txt then
    --         local str = "已报名:"..tostring(signcount)
    --         txt:setString(str)
    --     end
    --     txt = layer_sign:getChildByName("txt_start_count")
    --     if txt then
    --         local str = "满"..tostring(totalcount).."人开赛"
    --         txt:setString(str)
    --     end
    --     txt = layer_sign:getChildByName("layout_join"):getChildByName("txt_entryFee")
    --     if txt then
    --         local str = "报名费:"..tostring(entryFee)
    --         txt:setString(str)
    --     end
    --     --报名
    --     local btnSignup = layer_sign:getChildByName("btn_join")
    --     if btnSignup then
    --         btnSignup:setVisible(true)
    --         btnSignup:setEnabled(true)
    --     end
    --     --退赛
    --     local btnMatchLogout = layer_sign:getChildByName("btn_match_logout")
    --     if btnMatchLogout then
    --         btnMatchLogout:setVisible(false)
    --         btnMatchLogout:setEnabled(false)
    --     end

    --     --再次参赛
    --     if USER_INFO["match_fee"] > 0 then
    --         self:setJoinMatch(true)
    --     end
    --     --比赛详情
    --     local btn_detail = layer_sign:getChildByName("btn_detail")
    --     if btn_detail then
    --         btn_detail:setVisible(false)
    --         btn_detail:setEnabled(false)
    --     end
    --     --收起比赛详情
    --     local btn_detail_out = layer_sign:getChildByName("btn_detail_out")
    --     if btn_detail_out then
    --         btn_detail_out:setVisible(true)
    --         btn_detail_out:setEnabled(true)
    --     end
    --     --奖励方案
    --     local btn_incentive = layer_sign:getChildByName("btn_incentive")
    --     if btn_incentive then
    --         btn_incentive:setVisible(true)
    --         btn_incentive:setEnabled(true)
    --     end
    --     local btn_incentive_out = layer_sign:getChildByName("btn_incentive_out")
    --     if btn_incentive_out then
    --         btn_incentive_out:setVisible(false)
    --         btn_incentive_out:setEnabled(false)
    --     end
    --     --退出
    --     local btn_exit = layer_sign:getChildByName("btn_exit")
    --     local function showDetail(flag)
    --         if layout_join then
    --             layout_join:setVisible(flag)
    --         end
    --         if txt_match_detail then
    --             txt_match_detail:setVisible(not flag)
    --         end
    --         if btn_detail_out then
    --             btn_detail_out:setVisible(flag)
    --             btn_detail_out:setEnabled(flag)
    --         end

    --         if btn_detail then
    --             btn_detail:setEnabled(not flag)
    --             btn_detail:setVisible(not flag)
    --         end

    --         if btn_incentive then
    --             btn_incentive:setVisible(flag)
    --             btn_incentive:setEnabled(flag)
    --         end
    --         if btn_incentive_out then
    --             btn_incentive_out:setVisible(not flag)
    --             btn_incentive_out:setEnabled(not flag)
    --         end
    --     end
    --     showDetail(true)
    --     local function exit( ... )
    --         -- body
    --         --已报名，不能退出
    --         if USER_INFO["match_fee"] then
    --             if USER_INFO["match_fee"] > 0 then
    --                 print("match fee:"..USER_INFO["match_fee"])
    --                 return
    --             end
    --         end

    --         require("hall.GameCommon"):playEffectSound("hallAudio_Button_Click.mp3")
    --         local function endLayout()
    --             SCENENOW["scene"]:removeChildByName("layer_sign")
    --         end

    --         local st = cc.ScaleTo:create(0.2,0)
    --         local seq = cc.Sequence:create(st,cc.CallFunc:create(endLayout))
    --         layer_sign:runAction(seq)
    --     end
    --     --事件回调
    --     local function touchEvent(sender, event)
    --         --缩小ui
    --         if sender.id == "math" then
    --             print("match logout")
    --         end
    --         if event == TOUCH_EVENT_BEGAN then
    --             require("hall.GameCommon"):playEffectSound("hall/Audio_Button_Click.mp3")
    --             sender:setScale(0.9)
    --         end
    --         if event == TOUCH_EVENT_CANCEL then
    --             sender:setScale(1)
    --         end
    --         if event == TOUCH_EVENT_ENDED then
    --             sender:setScale(1)
    --             --调出出报名页面
    --             if sender == btnSignup then
    --                 print("================signup=============="..gameLevel)
    --                 MajiangroomServer:c2s_CLIENT_CMD_JOIN_MATCH(gameLevel)
    --                 local  rantch  = require("majiang.ddzSettings"):getMatchLevelRankInfo(gameLevel)
    --                 print(rantch,"-------------------rantch----------------")

    --                 USER_INFO["curr_match_level"] = gameLevel
    --                 self:setRankInfo(rantch)
                    
    --                 btnSignup:setEnabled(false)
    --                 btnSignup:setVisible(false)
    --                 USER_INFO["match_fee"] = entryFee
    --                 ddzGameMode = 1
    --                 btn_exit:setEnabled(false)
    --                 btn_exit:setColor(cc.c3b(125,125,125))
    --             end
    --             --退出比赛
    --             if sender == btnMatchLogout then
    --                 print("================match logout=============="..gameLevel)
    --                 MajiangroomServer:c2s_CLIENT_QUIT_MATCH(matchId,USER_INFO["uid"])
    --                 USER_INFO["curr_match_level"] = 0
                    
    --                 -- local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_SEND_LOGOUT_MATCH)
    --                 -- :setParameter("MatchID", USER_INFO["match_id"])
    --                 -- :setParameter("nUserId", USER_INFO["uid"])
    --                 -- :build()
    --                 -- bm.server:send(pack)
    --                 btnMatchLogout:setEnabled(false)
    --                 btnMatchLogout:setVisible(false)
    --                 btn_exit:setEnabled(true)
    --                 btn_exit:setColor(cc.c3b(255,255,255))
    --                 USER_INFO["match_fee"] = 0 
    --             end
    --             --比赛详情
    --             if sender == btn_detail then
    --                 showDetail(true)
    --             end
    --             --奖励方案
    --             if sender == btn_incentive then
    --                 showDetail(false)
    --             end
    --             if sender == btn_exit then
    --                 print("signup exit")
    --                 exit()
    --             end

    --         end
    --     end
    --     if btnSignup then
    --         btnSignup:addTouchEventListener(touchEvent)
    --     end
    --     if btnMatchLogout then
    --         btnMatchLogout.id="math"
    --         btnMatchLogout:addTouchEventListener(touchEvent)
    --         print()
    --     end
    --     if btn_detail then
    --         btn_detail:addTouchEventListener(touchEvent)
    --     end
    --     if btn_detail_out then
    --         btn_detail_out:addTouchEventListener(touchEvent)
    --     end
    --     if btn_incentive then
    --         btn_incentive:addTouchEventListener(touchEvent)
    --     end
    --     if btn_incentive_out then
    --         btn_incentive_out:addTouchEventListener(touchEvent)
    --     end
    --     if btn_exit then
    --         btn_exit:addTouchEventListener(touchEvent)
    --     end
    --     --退出
    --     local back = layer_sign:getChildByName("baoming")
    --     if back then
    --         back:addTouchEventListener(function(event,type)
    --             if(type == 2) then
    --                 exit()
    --             end
    --         end)
    --     end
    -- end

    -- layer_sign:setScale(0.5)
    -- local st = cc.ScaleTo:create(0.2,1)
    -- local seq = cc.Sequence:create(st,cc.CallFunc:create(actionEnd))
    -- layer_sign:runAction(seq)

end
--
function MatchSetting:setJoinMatch(flag)
    -- -- body
    -- bJoin = flag

    -- local layer_sign = SCENENOW["scene"]:getChildByName("layer_sign")
    -- if layer_sign then
    --     --报名
    --     local btnSignup = layer_sign:getChildByName("btn_join")
    --     --退赛
    --     local btnMatchLogout = layer_sign:getChildByName("btn_match_logout")

    --     if btnSignup then
    --         btnSignup:setVisible(not bJoin)
    --         btnSignup:setEnabled(not bJoin)
    --     end
    --     if btnMatchLogout then
    --         btnMatchLogout:setVisible(bJoin)
    --         btnMatchLogout:setEnabled(bJoin)
    --     end

    --     local btn_exit = layer_sign:getChildByName("btn_exit")
    --     if btn_exit then
    --         btn_exit:setEnabled(not bJoin)
    --         if bJoin then
    --             btn_exit:setColor(cc.c3b(125,125,125))
    --         else
    --             btn_exit:setColor(cc.c3b(255,255,255))
    --         end
    --     end
    -- end
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
    -- -- body
    -- local layer = cc.Layer:create()
    -- local x = 0
    -- local y = 0
    -- local width = 0
    -- dump(matchInfoList,"matchInfoList")
    -- for i, v in ipairs(matchInfoList) do
    --     --横杠
    --     if i > 1 then
    --         local spLine = display.newSprite("majiang/match/line.png")
    --         if spLine then
    --             layer:addChild(spLine)
    --             x = x + spLine:getContentSize().width/2
    --             spLine:setPosition(cc.p(x,0))
    --             x = x + spLine:getContentSize().width/2
    --             width = width + spLine:getContentSize().width
    --             layer:setContentSize(cc.size(width,spLine:getContentSize().height))
    --         end
    --     end
    --     local str = ""
    --     if i == round then
    --         str = "majiang/match/level_focus.png"
    --     else
    --         str = "majiang/match/level.png"
    --     end
    --     local scale = 0.6
    --     local sp = display.newSprite(str)
    --     local lb = require("hall.GameCommon"):showNums(tonumber(v),cc.c3b(82,15,33))
    --     lb:setScale(scale)
    --     sp:addChild(lb)
    --     lb:setPosition(cc.p(sp:getContentSize().width/2-lb:getContentSize().width/2*scale,sp:getContentSize().height/2))
    --     layer:addChild(sp)
    --     x = x + sp:getContentSize().width/2
    --     sp:setPosition(cc.p(x,0))
    --     x = x + sp:getContentSize().width/2
    --     width = width + sp:getContentSize().width
    --     layer:setContentSize(cc.size(width,sp:getContentSize().height))
    -- end
    -- return layer

end

--牌局结束，晋级成功
--rank_c 当前名次
--rank_b 之前名次
--round 比赛轮次
--code 游戏
function MatchSetting:showMatchWin(rank_c,rank_b,round,code)
    -- self:offLayers()

    -- code = code or "hall"

    -- local match_win = cc.CSLoader:createNode(code.."/match/MatchWin.csb")
    -- SCENENOW["scene"]:addChild(match_win, 30000)
    -- match_win:setName("match_win")

    -- local lbPos = match_win:getChildByName("txt_rank")
    -- local txt_rank = require("hall.GameCommon"):showNums(rank_c,cc.c3b(82,15,33))
    -- match_win:addChild(txt_rank)
    -- txt_rank:setPosition(lbPos:getPosition())
    -- lbPos:removeSelf()

    -- lbPos = match_win:getChildByName("txt_rank_before")
    -- local txt_rank_before = require("hall.GameCommon"):showNums(rank_b,cc.c3b(82,15,33))
    -- match_win:addChild(txt_rank_before)
    -- txt_rank_before:setPosition(lbPos:getPosition())
    -- lbPos:removeSelf()

    -- lbPos = match_win:getChildByName("txt_eliminate")
    -- local txt_eliminate = require("hall.GameCommon"):showNums(matchInfoList[round+1],cc.c3b(82,15,33))
    -- match_win:addChild(txt_eliminate)
    -- txt_eliminate:setPosition(lbPos:getPosition())
    -- lbPos:removeSelf()
    -- -- currentRound = currentRound + 1
    -- print("round-------------------------------------",round)
    -- local ranking = self:createRanking(round+1)
    -- if ranking then
    --     match_win:addChild(ranking)
    --     ranking:setPosition(cc.p(480-ranking:getContentSize().width/2,118))
    -- end

    -- if rank_c == rank_b then
    --     -- txt_rank_before:setString(tostring(rank_c))
    --     txt_rank:setVisible(false)
    --     if rank_c==1 then
    --         txt_rank_before:runAction(cc.Sequence:create(
    --             cc.ScaleTo:create(0.1,1.2),
    --             cc.ScaleTo:create(0.1,1),
    --             cc.ScaleTo:create(0.1,1.2),
    --             cc.ScaleTo:create(0.1,1),
    --             cc.ScaleTo:create(0.1,1.2),
    --             cc.ScaleTo:create(0.1,1),
    --             cc.ScaleTo:create(0.1,1.2),
    --             cc.ScaleTo:create(0.1,1)
    --         ))
    --     end
    -- else
    --     local time = 0.5
    --     if txt_rank then
    --         -- txt_rank:setString(tostring(rank_c))
    --         txt_rank:setOpacity(0)
    --         local fo = cc.FadeIn:create(time)
    --         local mt = cc.MoveTo:create(time,cc.p(txt_rank:getPositionX(),txt_rank:getPositionY()-50))
    --         local spawn = cc.Spawn:create(fo,mt)
    --         txt_rank:runAction(spawn)
    --     end

    --     if txt_rank_before then
    --         -- txt_rank_before:setString(tostring(rank_b))
    --         local fi = cc.FadeOut:create(time)
    --         local mt = cc.MoveTo:create(time,cc.p(txt_rank_before:getPositionX(),txt_rank_before:getPositionY()-50))
    --         local spawn = cc.Spawn:create(fi,mt)
    --         txt_rank_before:runAction(spawn)
    --         USER_INFO["match_rank"] = rank_c
    --     end
    -- end

end

--牌局结束，晋级失败
--rank_c 当前名次
--rank_b 之前名次
--round 比赛轮次
--code 游戏
function MatchSetting:showMatchLose(rank_c,rank_b,round,code)
    -- self:offLayers()
    -- code = code or "hall"

    -- local match_lose = cc.CSLoader:createNode(code.."/match/MatchLose.csb")
    -- SCENENOW["scene"]:addChild(match_lose, 30000)
    -- match_lose:setName("match_lose")

    -- local lbPos = match_lose:getChildByName("txt_rank")
    -- local txt_rank = require("hall.GameCommon"):showNums(rank_c,cc.c3b(82,15,33))
    -- match_lose:addChild(txt_rank)
    -- txt_rank:setPosition(lbPos:getPosition())
    -- lbPos:removeSelf()

    -- lbPos = match_lose:getChildByName("txt_rank_before")
    -- local txt_rank_before = require("hall.GameCommon"):showNums(rank_b,cc.c3b(82,15,33))
    -- match_lose:addChild(txt_rank_before)
    -- txt_rank_before:setPosition(lbPos:getPosition())
    -- lbPos:removeSelf()

    -- lbPos = match_lose:getChildByName("txt_eliminate")
    -- local txt_eliminate = require("hall.GameCommon"):showNums(matchInfoList[round+1],cc.c3b(82,15,33))
    -- match_lose:addChild(txt_eliminate)
    -- txt_eliminate:setPosition(lbPos:getPosition())
    -- lbPos:removeSelf()

    -- -- currentRound = currentRound + 1

    -- local ranking = self:createRanking(round+1)
    -- if ranking then
    --     match_lose:addChild(ranking)
    --     ranking:setPosition(cc.p(480-ranking:getContentSize().width/2,118))
    -- end

    -- if rank_c == rank_b then
    --     -- txt_rank_before:setString(tostring(rank_c))
    --     txt_rank:setVisible(false)
    -- else
    --     local time = 0.5
    --     if txt_rank then
    --         -- txt_rank:setString(tostring(rank_c))
    --         txt_rank:setOpacity(0)
    --         local fo = cc.FadeIn:create(time)
    --         local mt = cc.MoveTo:create(time,cc.p(txt_rank:getPositionX(),txt_rank:getPositionY()-50))
    --         local spawn = cc.Spawn:create(fo,mt)
    --         txt_rank:runAction(spawn)
    --     end

    --     if txt_rank_before then
    --         -- txt_rank_before:setString(tostring(rank_b))
    --         local fi = cc.FadeOut:create(time)
    --         local mt = cc.MoveTo:create(time,cc.p(txt_rank_before:getPositionX(),txt_rank_before:getPositionY()-50))
    --         local spawn = cc.Spawn:create(fi,mt)
    --         txt_rank_before:runAction(spawn)
    --     end
    --     if USER_INFO["match_rank"] == nil then
    --         USER_INFO["match_rank"] = 0
    --     end

    --     USER_INFO["match_rank"] = 0
    -- end
end

--等待比赛结算
function MatchSetting:showMatchWait(flag,code)
    -- if flag == false then
    --     SCENENOW["scene"]:removeChildByName("match_wait")
    --     bShowMatchWait = false
    --     return
    -- end
    -- self:offLayers()
    -- code = code or "hall"

    -- local match_wait = cc.CSLoader:createNode(code.."/match/MatchWait.csb")
    -- SCENENOW["scene"]:addChild(match_wait, 30000)
    -- match_wait:setName("match_wait")

    -- local loading = match_wait:getChildByName("wait_loading")
    -- if loading then
    --     local rb = cc.RotateBy:create(1,180)
    --     loading:runAction(cc.RepeatForever:create(rb))
    -- end

    -- local ranking = self:createRanking(currentRound)
    -- if ranking then
    --     match_wait:addChild(ranking)
    --     ranking:setPosition(cc.p(480-ranking:getContentSize().width/2,118))
    -- end


    -- fTimeMatchWait = 0
    -- idxRound = 1
    -- bShowMatchWait = true
end

--比赛结果
--rank 最终名次
--maxnumber 最大报名人数
--time 颁奖时间
--code 游戏
function MatchSetting:showMatchResult()
    -- currentRound = 1
    -- self:offLayers()

    -- print_lua_table(tbResult)
    -- --给用户加金币
    -- USER_INFO["gold"] = USER_INFO["gold"] + tbResult["incentive"]

    -- --退出比赛
    -- require("hall.GameSetting"):enterMatch(0)
    -- local match_result = cc.CSLoader:createNode("majiang/match/MatchResult.csb")
    -- SCENENOW["scene"]:addChild(match_result, 30000)
    -- match_result:setName("match_result")


    -- match_result:setVisible(true)
    -- local lbRank = match_result:getChildByName("txt_rank")
    -- if lbRank then
    --     lbRank:setString(tostring(tbResult["rank"]))
    --     local scale = 0.6
    --     print("showMatchResult rank:"..tostring(tbResult["rank"]))
    --     local lbOnline = require("hall.GameCommon"):showNums(tbResult["rank"],cc.c3b(82,15,33))
    --     -- lbOnline:setScale(scale)
    --     match_result:addChild(lbOnline)
    --     -- lbOnline:setPosition(lbRank:getPosition())
    --     lbOnline:setPosition(cc.p(lbRank:getPositionX()-lbOnline:getContentSize().width/2+10,lbRank:getPositionY()))
    --     lbRank:removeSelf()
    --     lbOnline:setName("txt_rank")
    -- end
    -- local lbNick = match_result:getChildByName("txt_nickName")
    -- if lbNick then
    --     lbNick:setString(USER_INFO["nick"])
    -- end
    -- local Text_1_0 = match_result:getChildByName("Text_1_0")
    -- Text_1_0:setString("恭喜您在兜游斗地主\n大奖赛中"..tostring(tbResult["maxnumber"]).."人中荣获")

    -- local Text_1 = match_result:getChildByName("Text_1")
    -- Text_1:setString(os.date("%Y-%m-%d %H:%M", tbResult["time"]))

    -- --奖励
    -- local txt_incentive = match_result:getChildByName("txt_incentive")
    -- if txt_incentive then
    --     local str = "奖励:"..tostring(tbResult["incentive"]).."  宝贝币"
    --     txt_incentive:setString(str)
    -- end

    -- local btnExit = match_result:getChildByName("btn_exit")
    -- if btnExit then
    --     btnExit:addTouchEventListener(function(event,type)
    --         if(type == 2) then
    --             require("hall.GameCommon"):playEffectSound("audio/Audio_Button_Click.mp3")
    --             --退出游戏
    --             MajiangroomServer:c2s_CLIENT_QUIT_MATCH(matchId,USER_INFO["uid"])
    --             --避免重复点击
    --             btnExit:setVisible(false)
    --             btnExit:setEnabled(false)
                
    --             ddzGameMode = 1
    --             USER_INFO["match_fee"] = 0
    --             display_scene("majiang.MJselectChip",1)
    --         end
    --     end)
    -- end
    -- local btnHall = match_result:getChildByName("btn_hall")
    -- if btnHall then
    --     btnHall:addTouchEventListener(function(event,type)
    --         if(type == 2) then
    --             require("hall.GameCommon"):playEffectSound("audio/Audio_Button_Click.mp3")
                
    --             --返回大厅
    --             USER_INFO["match_fee"] = 0
    --             require("app.HallUpdate"):enterHall()
    --         end
    --     end)
    -- end
    -- local btnMatch = match_result:getChildByName("btn_match")
    -- if btnMatch then
    --     btnMatch:addTouchEventListener(function(event,type)
    --         if(type == 2) then
    --             require("hall.GameCommon"):playEffectSound("audio/Audio_Button_Click.mp3")
    --             --重新报名
    --             require("hall.gameSettings"):setGameMode("match")
    --             majiangGameMode = 2
    --             display_scene("majiang.MJselectChip",1)
    --         end
    --     end)
    -- end
end

--设置比赛结果
function MatchSetting:setMatchResult(rank,maxnumber,time,code,incentive)
    -- -- body
    -- tbResult["rank"] = rank
    -- tbResult["maxnumber"] = maxnumber
    -- tbResult["time"] = time
    -- tbResult["code"] = code
    -- tbResult["incentive"] = incentive

    -- print_lua_table(tbResult)
end

--获取当前比赛轮次
function MatchSetting:getCurrentRank()
    -- body
    return currentRound
end


function MatchSetting:joinMatch(signcount,totalcount)
    -- local layer_sign = SCENENOW["scene"]:getChildByName("layer_sign")

    -- if layer_sign then
    --     local txtSign = layer_sign:getChildByName("layout_join"):getChildByName("txt_playercount")
    --     if txtSign then
    --         local str = "已报名:"..tostring(signcount)
    --         txtSign:setString(str)
    --     end
    --     local txtTotal = layer_sign:getChildByName("txt_start_count")
    --     if txtTotal then
    --         local str = "满"..tostring(totalcount).."人开赛"
    --         txtTotal:setString(str)
    --     end
    --     --人数已满，准备开始
    --     if signcount >= totalcount then
    --         if txtSign then
    --             local str = "准备开赛"
    --             txtSign:setString(str)
    --         end
    --         local btnLogout = layer_sign:getChildByName("btn_match_logout")
    --         if btnLogout then
    --             btnLogout:setTouchEnabled(false)
    --             btnLogout:setColor(cc.c3b(125,125,125))
    --         end
    --         local btnJoin = layer_sign:getChildByName("btn_join")
    --         if btnJoin then
    --             btnJoin:setVisible(false)
    --         end
    --     end
    -- end

end

function MatchSetting:setMatchState(state)
    -- body
    match_state = state
end
function MatchSetting:getMatchState(  )
    -- body
    return match_state
end

return MatchSetting