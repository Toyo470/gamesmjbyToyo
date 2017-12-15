local targetPlatform = cc.Application:getInstance():getTargetPlatform()
local pdkSettings  = class("pdkSettings")

local tbPDKErrorCode = {
    [0] = "成功创建新连接",
    [1] = "重连成功",
    [2] = "成功踢其他玩家",
    [3] = "玩家密匙错误",
    [4] = "数据库连接错误",
    [5] = "无此房间",
    [6] = "玩家登录房间错误",
    [7] = "无房间分配",
    [8] = "没有空桌子",
    [9] = "玩家余额不足",
    [10] = "游戏策略错误",
    [11] = "未知错误",
    [12] = "黑名单",
    [13] = "玩家请求准备",
    [14] = "添加黑名单错误",
    [15] = "您当前不能进低分场",
    [16] = "等级不够",
    [17] = "等级太高",
    [18] = "经验不够",
    [19] = "经验太多",
    [20] = "比赛中退赛马上有报名错误",
    [21] = "比赛场金币不足",
    [22] = "比赛场钻石不足",
}

local gameData = {}
local gameMode = {"free","match","group"}

function pdkSettings:reset()
    -- body
    gameData = {}
end

function pdkSettings:getErrorCode( type )
    -- body
    return tbPDKErrorCode[type]
end
function pdkSettings:getDOS(seat)

    --位置的位移
    local u_seat = tonumber(seat)
    if USER_INFO["seat"] == 1 then
        u_seat = 2 + seat
    elseif USER_INFO["seat"] == 2 then
        u_seat = 1 + seat
    end

    --位置调整
    if(u_seat >= 3) then
        u_seat = u_seat -3
    end

    local dos
    if u_seat==0 then
        dos = "touxiangbufen_0"
    end
    if u_seat==1 then
        dos = "touxiangbufen_1"
    end
    if u_seat==2 then
        dos = "touxiangbufen_2"
    end    
    return dos,u_seat
end


local tbMatchRank = {}
local matchData = {}
--重置比赛轮次
function pdkSettings:resetMatchRank()
    -- body
    tbMatchRank = {}
end
--比赛轮次设置
function pdkSettings:addMatchRank(level,tbRank)
    -- body
    tbMatchRank[level] = tbRank
    print("addMatchRank:",level)
end
--根据level获取轮次信息
function pdkSettings:getMatchLevelRankInfo(level)
    -- body
    if level == nil then
        return nil
    end
    return tbMatchRank[level]
end

--设置游戏模式
--free 自由场
--match 比赛场
--group 组局
function pdkSettings:setGameMode( mode )
    -- body
    if gameData == nil then
        gameData = {}
    end
    gameData["gameMode"] = mode
end
function pdkSettings:getGameMode()
    -- body
    local mode = gameData["gameMode"] or "free"
    return mode
end

--设置玩游戏次数
function pdkSettings:addGame()
    -- body
    if gameData == nil then
        gameData = {}
    end
    local modeCount = ""
    modeCount = require("hall.gameSettings"):getGameMode().."Counts"
    if gameData[modeCount] == nil then
        gameData[modeCount] = 0
    end
    gameData[modeCount] = gameData[modeCount] + 1
end
--设置玩游戏次数
function pdkSettings:setGameCount(round)
    if gameData == nil then
        gameData = {}
    end
    local modeCount = ""
    modeCount = require("hall.gameSettings"):getGameMode().."Counts"
    if gameData[modeCount] == nil then
        gameData[modeCount] = 0
    end
    gameData[modeCount] = round or 0
end
--获取玩了多少次
function pdkSettings:getGameCount()
    -- body
    local modeCount = ""
    modeCount = require("hall.gameSettings"):getGameMode().."Counts"
    local counts = gameData[modeCount] or 0
    print("getGameCount",modeCount,gameData[modeCount],counts)
    return counts
end

--请求退出游戏
function pdkSettings:requestExit()
    -- body
    local mode = require("hall.gameSettings"):getGameMode()
    if mode == "free" or mode == "group" then
        require("pdk.pdkServer"):CLI_LOGOUT_ROOM()
    elseif mode == "match" then
        require("pdk.pdkServer"):CLI_SEND_LOGOUT_MATCH(self:getMatchId())
    end
end

--设置当前比赛场id
function pdkSettings:setMatchId( id )
    -- body
    if matchData == nil then
        matchData = {}
    end
    matchData["tid"] = id
end
function pdkSettings:getMatchId( ... )
    -- body
    local id = matchData["tid"]
    return id
end
--设置当前比赛场level
function pdkSettings:setMatchLevel( level )
    -- body
    if matchData == nil then
        matchData = {}
    end
    matchData["level"] = level
end
function pdkSettings:getMatchLevel( ... )
    -- body
    local id = matchData["level"]
    return id
end
--设置位置tid
function pdkSettings:setOnlookTable(tid)
    if gameData == nil then
        gameData = {}
    end
    gameData["on_look_table"] = tid
end
function pdkSettings:getLookingTable()
    return gameData["on_look_table"]
end
--设置围观状态
---1,初始化值，玩家第一次进入
--0,非围观状态，默认值
--1，准备围观
--2，进入围观
function pdkSettings:setLookState(state)
    if gameData == nil then
        gameData = {}
    end
    gameData["look_state"] = state
end
function pdkSettings:getLookState()
    if gameData == nil or gameData["look_state"] == nil then
        return -1
    end
    return gameData["look_state"]
end

--组局排行榜
function pdkSettings:showRanking(playerlist,game_amount)
    -- body

    local group_result = SCENENOW["scene"]:getChildByName("group_result")
    if group_result == nil then
        group_result = cc.CSLoader:createNode("hall/group/GroupResult.csb"):addTo(SCENENOW["scene"],100000)
        group_result:setName("group_result")
    end

    --退出
    local btn_exit = group_result:getChildByName("btn_exit")
    if btn_exit then
        btn_exit:addTouchEventListener(function(sender,event)
            if event == 0 then
                sender:setScale(1.1)
            end

            if event == 2 then
                sender:setScale(1)
                require("app.HallUpdate"):enterHall()
                -- require("hall.GameCommon"):gExitGroupGame(1)
            end
        end)
    end

    local rich = -99999999999
    local richId = {}--充值最多
    local loser = 99999999999
    local loserId = {}--输最多
    local mvp = 0
    local mvpId = {}--赢最多
    local total_chips = 0
    local pos = 1
    print("playerlist :"..tostring(#playerlist))
    for i,k in pairs(playerlist) do
        print("playerlist :"..tostring(i))
        print_lua_table(k)
        local add = k["add_chips"]
        local chips = k["chips"]
        if (chips - add) > mvp then
            mvpId = k
            mvp = chips - add
        elseif pos == 1 then
            mvpId = k
        end
        if (chips-add) < loser then
            loserId = k
            loser = chips - add
        end
        if add > rich then
            richId = k
            rich = add
        end
        total_chips = total_chips + add
        pos = pos + 1
    end
    if mvpId == {} then
        mvpId = richId
    end
  --  printLog("xxxxxxxxxxxxxxxxxxxxxx")
  --  print(debug.traceback())

    print("onNetBillboard total_chips:"..tostring(total_chips))
    --土豪
    local layer = group_result:getChildByName("layer_richman")
    if layer then
        local spHead = layer:getChildByName("sp_head")
        if spHead then
            local head_info = {}
            head_info["uid"] = 1
            head_info["sex"] = richId["sex"]
            head_info["icon_url"] = richId["photo_url"]
            head_info["sp"] = spHead
            head_info["size"] = 82
            head_info["touchable"] = 1
            head_info["use_sharp"] = 1
            head_info["vip"] = richId["isVip"]
            -- require("hall.GameCommon"):getUserHead(head_info)
            require("hall.GameCommon"):setPlayerHead(head_info,spHead,82)
        end
        local lbNick = layer:getChildByName("txt_nick")
        if lbNick then
            lbNick:setString(require("hall.GameCommon"):formatNick(richId["nick_name"]))
        end
    end
    --大鱼
    local layer = group_result:getChildByName("layer_loser")
    if layer then
        local spHead = layer:getChildByName("sp_head")
        if spHead then
            local head_info = {}
            head_info["uid"] = 1
            head_info["sex"] = loserId["sex"]
            head_info["icon_url"] = loserId["photo_url"]
            head_info["sp"] = spHead
            head_info["size"] = 82
            head_info["touchable"] = 1
            head_info["use_sharp"] = 1
            head_info["vip"] = loserId["isVip"]
            -- require("hall.GameCommon"):getUserHead(head_info)
            require("hall.GameCommon"):setPlayerHead(head_info,spHead,82)
        end
        local lbNick = layer:getChildByName("txt_nick")
        if lbNick then
            lbNick:setString(require("hall.GameCommon"):formatNick(loserId["nick_name"]))
        end
    end
    --MVP
    -- userinfo = pack["mvp_info"]
    local layer = group_result:getChildByName("layer_mvp")
    if layer then
        local spHead = layer:getChildByName("sp_head")
        if spHead then
            local head_info = {}
            head_info["uid"] = 1
            head_info["sex"] = mvpId["sex"]
            head_info["icon_url"] = mvpId["photo_url"]
            head_info["sp"] = spHead
            head_info["size"] = 82
            head_info["touchable"] = 1
            head_info["use_sharp"] = 1
            head_info["vip"] = mvpId["isVip"]
            -- require("hall.GameCommon"):getUserHead(head_info)
            require("hall.GameCommon"):setPlayerHead(head_info,spHead,82)
        end
        local lbNick = layer:getChildByName("txt_nick")
        if lbNick then
            lbNick:setString(require("hall.GameCommon"):formatNick(mvpId["nick_name"]))
        end
    end
    --个人信息
    local spMyHead = group_result:getChildByName("sp_my_head")
    if spMyHead then
        local head_info = {}
        head_info["uid"] = tonumber(UID)
        head_info["sex"] = USER_INFO["sex"]
        head_info["icon_url"] = USER_INFO["icon_url"]
        head_info["sp"] = spMyHead
        head_info["size"] = 82
        head_info["touchable"] = 1
        head_info["use_sharp"] = 1
        head_info["vip"] = USER_INFO["isVip"]
        -- require("hall.GameCommon"):getUserHead(head_info)
        require("hall.GameCommon"):setPlayerHead(head_info,spMyHead,82)
    end
    local lbChips = group_result:getChildByName("txt_my_chip")
    if lbChips then
        -- lbChips:setString(tostring(pack["chips"]))
        lbChips:setString(playerlist[tonumber(UID)]["chips"])
        lbChips:enableShadow(cc.c4b(0xff,0xff,0xff,255),cc.size(1,0))
    end
    local lbCountGame = group_result:getChildByName("txt_game_count")
    if lbCountGame then
        lbCountGame:setString(game_amount)
        lbCountGame:enableShadow(cc.c4b(0xff,0xff,0xff,255),cc.size(1,0))
    end
    local lbTotalChips = group_result:getChildByName("txt_total_chips")
    if lbTotalChips then
        -- lbTotalChips:setString(pack["total_chips"])
        lbTotalChips:setString(tostring(total_chips))
        lbTotalChips:enableShadow(cc.c4b(0xff,0xff,0xff,255),cc.size(1,0))
    end
    --记录
    -- for i,v in pairs(pack["playerList"]) do
    for i,l in pairs(playerlist) do
        -- userinfo = json.decode(v["user_info"])
        -- self:addGroupRecord(v["nick"],v["add_chips"],v["chips"])
        local win = l["chips"] - l["add_chips"]
        self:addGroupRecord(l["nick_name"],l["add_chips"],win)
    end
end

--组局，添加玩家记录
function pdkSettings:addGroupRecord(nick,buyChip,chip)
    -- body
    local layerGroupRecord = SCENENOW["scene"]:getChildByName("group_result")
    if layerGroupRecord == nil then
        layerGroupRecord = cc.CSLoader:createNode("hall/group/GroupResult.csb"):addTo(SCENENOW["scene"],100000)
        layerGroupRecord:setName("group_result")
    end
    local lsPlayer = layerGroupRecord:getChildByName("lv_players")
    if lsPlayer then
        local layout = ccui.Layout:create()
        layout:setContentSize(cc.size(363,30))

        local strNick = require("hall.GameCommon"):formatNick(nick)
        -- local lbNick = ccui.Text:create()
        local lbNick = cc.Label:createWithTTF("","res/fonts/fzcy.ttf",20)
        lbNick:setString(strNick)
        layout:addChild(lbNick)
        lbNick:setPosition(cc.p(lbNick:getContentSize().width/2+10,15))
        lbNick:setColor(cc.c3b(0x27,0x8f,0xe6))
        -- lbNick:enableShadow(cc.c4b(0x27,0x8f,0xe6,255),cc.size(1,0))

        -- local lbBuy = ccui.Text:create()
        local lbBuy = cc.Label:createWithTTF("","res/fonts/fzcy.ttf",20)
        lbBuy:setString(tostring(buyChip))
        -- lbBuy:setFontSize(20)
        layout:addChild(lbBuy)
        lbBuy:setPosition(cc.p(136,15))
        lbBuy:setColor(cc.c3b(0x27,0x8f,0xe6))
        -- lbBuy:enableShadow(cc.c4b(0x27,0x8f,0xe6,255),cc.size(1,0))

        -- local lbChip = ccui.Text:create()
        local lbChip = cc.Label:createWithTTF("","res/fonts/fzcy.ttf",20)
        lbChip:setString(tostring(chip))
        -- lbChip:setFontSize(20)
        layout:addChild(lbChip)
        lbChip:setPosition(cc.p(210,15))
        lbChip:setColor(cc.c3b(0,0xff,0))
        -- lbChip:enableShadow(cc.c4b(0,0xff,0,255),cc.size(1,0))

        lsPlayer:insertCustomItem(layout, 0)
    end
end

--显示一局结算的结算界面
function pdkSettings:showGroupResult(groupRanking)

    dump(groupRanking, "-----一局结算信息-----")

    --去掉提示弹框
    local layer_tips = SCENENOW["scene"]:getChildByName("layer_tips")
    if layer_tips then
        layer_tips:removeSelf()
    end

    --获取总结算界面
    local s = cc.CSLoader:createNode("pdk/csb/GameResult.csb")
    s:setName("GameResult")
    SCENENOW["scene"]:addChild(s,9998)

    local Panel_8 = s:getChildByName("Panel_8")
    if Panel_8 then
        Panel_8:setTouchEnabled(true)
        Panel_8:addTouchEventListener(function(sender,event) end)
    end

    --退出按钮（当前组局结算，返回到大厅）
    local back_bt = s:getChildByName("back_bt")
    back_bt:addTouchEventListener(
        function(sender,event)
            --触摸开始
            if event == TOUCH_EVENT_BEGAN then
                sender:setScale(0.9)
            end

            --触摸取消
            if event == TOUCH_EVENT_CANCELED then
                sender:setScale(1.0)
            end

            --触摸结束
            if event == TOUCH_EVENT_ENDED then
                sender:setScale(1.0)

                --退出房间，返回大厅
                require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])

            end
        end
    )

    --结果显示区域
    local content_ly = s:getChildByName("content_ly")
    local content_sv = content_ly:getChildByName("content_sv")

    --显示用户结算结果
    local playerlist = groupRanking.playerlist
    if #playerlist > 0 then

        --记录最佳炮手和大富豪
        local paoshou_uid = nil
        local lastPaoNum = 0

        local fuhao_uid = nil
        local lastChip = 0

        for k,v in pairs(playerlist) do
            
            --获取用户id
            local uid = v.uid

            --获取用户信息以及结算情况
            local user_info = json.decode(v.user_info)

            --获取用户分数
            local chips = user_info.chips
            if chips ~= nil then
                --比较分数
                local cha = chips - USER_INFO["group_chip"]
                if cha > lastChip then
                    --记录最新点炮数和点炮id
                    lastChip = cha
                    fuhao_uid = uid
                end
            end

        end

        local zOrder = 10

        --生成界面
        for k,v in pairs(playerlist) do

            --获取用户id
            local uid = v.uid

            --获取用户信息以及结算情况
            local user_info = json.decode(v.user_info)

            --定义结果分项
            local result_Item = cc.CSLoader:createNode("pdk/csb/GameResult_Item.csb")
            result_Item:setLocalZOrder(zOrder)
            zOrder = zOrder - 1
            content_sv:addChild(result_Item)

            local item_ly = result_Item:getChildByName("item_ly")
            item_ly:setPosition(219 * (k - 1), content_sv:getContentSize().height)

            --显示大富豪
            local winner_im = item_ly:getChildByName("winner_im")
            if fuhao_uid ~= nil then
                if fuhao_uid == uid then
                    winner_im:setVisible(true)
                end
            end

            local top_ly = item_ly:getChildByName("top_ly")

            --用户头像
            local head_im = top_ly:getChildByName("head_box")

            local head_info = {}
            head_info["icon_url"] = user_info.photo_url
            head_info["uid"] = uid
            head_info["sex"] = user_info.sex
            head_info["sp"] = head_im
            head_info["size"] = 61
            head_info["touchable"] = 0
            head_info["use_sharp"] = 1
            require("hall.GameCommon"):setPlayerHead(head_info,head_im,61)
            -- require("hall.GameCommon"):getUserHead(user_info.photo_url, v.uid, user_info.sex, head_im, 61, false)

            --是否为房主
            local roomowner_im = item_ly:getChildByName("roomowner_im")
            --只有房主才出现房主标志
            local group_owner = tonumber(USER_INFO["group_owner"])
            if group_owner == v.uid then
                print("kjdlafjalkjfe;alkjef;la")
                roomowner_im:setVisible(true)
            else
                roomowner_im:setVisible(false)
            end

            --中间区域
            local content_sv = item_ly:getChildByName("content_sv")

            --单局最高分
            local high_score = content_sv:getChildByName("high_score")
            local zimo_itemNum_tt = high_score:getChildByName("itemNum_tt")
            if user_info.high_scord ~= nil then
                zimo_itemNum_tt:setString(tostring(user_info.high_scord))
            else
                zimo_itemNum_tt:setString(tostring(0))
            end

            --打出炸弹数
            local boom_times = content_sv:getChildByName("boom_times")
            local dianpao_itemNum_tt = boom_times:getChildByName("itemNum_tt")
            local count_boom = 0
            if user_info.boom_times then
                count_boom = user_info.boom_times
            end
            if user_info.missile_times then
                count_boom = count_boom + user_info.missile_times
            end
            dianpao_itemNum_tt:setString(tostring(count_boom))

            --胜局数
            local win_count = content_sv:getChildByName("win_count")
            local jiepao_itemNum_tt = win_count:getChildByName("itemNum_tt")
            if user_info.win_times ~= nil then
                jiepao_itemNum_tt:setString(tostring(user_info.win_times))
            else
                jiepao_itemNum_tt:setString(tostring(0))
            end

            --负局数
            local lose_count = content_sv:getChildByName("lose_count")
            local jiepao_itemNum_tt = lose_count:getChildByName("itemNum_tt")
            if user_info.lose_times ~= nil then
                jiepao_itemNum_tt:setString(tostring(user_info.lose_times))
            else
                jiepao_itemNum_tt:setString(tostring(0))
            end

            --用户昵称
            local name_tt = top_ly:getChildByName("name_tt")
            name_tt:setString(user_info.nick_name)

            --用户id
            local id_tt = top_ly:getChildByName("id_tt")
            id_tt:setString("ID:" .. tostring(v.uid))

            --底部区域
            local bottom_ly = item_ly:getChildByName("bottom_ly")

            --总成绩
            --用户当前的积分
            local chips = user_info.chips - user_info.add_chips
            -- if bm.round == 1 then
            --     chips = 0
            -- else
                -- chips = chips - USER_INFO["group_chip"]
            -- end
            local socre_tt = bottom_ly:getChildByName("socre_tt")
            socre_tt:setString(tostring(chips))

        end

    end

    local share_ly = s:getChildByName("share_ly")
    share_ly:addTouchEventListener(
        function(sender,event)
            --触摸开始
            if event == TOUCH_EVENT_BEGAN then
                sender:setScale(0.9)
            end

            --触摸取消
            if event == TOUCH_EVENT_CANCELED then
                sender:setScale(1.0)
            end

            --触摸结束
            if event == TOUCH_EVENT_ENDED then
                sender:setScale(1.0)
                share_ly:setTouchEnabled(false)
                --通知APP分享结果
                -- require("hall.common.ShareLayer"):showShareLayer("分享结果","","screen","")
                if device.platform == "android" then
                    require("hall.common.ShareLayer"):showShareLayer("分享结果","","screen","",share_ly)
                elseif device.platform ~= "windows" then
                    require("hall.common.ShareLayer"):shareGroupResultForIOS(share_ly)
                end

            end
        end
    )

end

local group_state = -1
function pdkSettings:setGroupState(state)
    group_state = state
    print("setGroupState",group_state)
end

function pdkSettings:getGroupState(state)
    print("getGroupState",group_state)
    return group_state
end

-- 设置玩家ip地址
local user_ip = {}
function pdkSettings:setUserIP(uid,ip)
    if uid ~= 0 and ip then
        user_ip[uid] = ip
    end
end
function pdkSettings:getUserIP(uid)
    if user_ip == nil then
        return ""
    end
    return user_ip[uid]
end

return pdkSettings