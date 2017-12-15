local targetPlatform = cc.Application:getInstance():getTargetPlatform()
local GroupGame  = class("GroupGame")
local PROTOCOL = require("hall.HALL_SERVER_PROTOCOL")

function GroupGame:showInvoteCode()
    -- body
    if SCENENOW["scene"] == nil then
        return
    end
    local spBack = display.newSprite("hall/common/invote_code.png")
    local lb = ccui.Text:create()
    lb:setString("邀请码:"..USER_INFO["invote_code"])
    lb:setFontSize(18)
    lb:setColor(cc.c3b(0x01,0xc6,0x55))
    spBack:addChild(lb)
    lb:setPosition(cc.p(spBack:getContentSize().width/2,spBack:getContentSize().height/2))
    SCENENOW["scene"]:addChild(spBack,100)
    spBack:setPosition(cc.p(480,270))

end

--组局排行榜
function GroupGame:showRanking(playerlist,game_amount)
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
            head_info["url"] = richId["photo_url"]
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
            head_info["url"] = loserId["photo_url"]
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
            head_info["url"] = mvpId["photo_url"]
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
        head_info["uid"] = USER_INFO["uid"]
        head_info["sex"] = USER_INFO["sex"]
        head_info["url"] = USER_INFO["icon_url"]
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
        lbChips:setString(playerlist[USER_INFO["uid"]]["chips"])
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
function GroupGame:addGroupRecord(nick,buyChip,chip)
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


--检查筹码
function GroupGame:checkChips()
    -- body
    --低于三倍底分
    USER_INFO["chips"] = USER_INFO["chips"] or 0
    USER_INFO["base_chip"] = USER_INFO["base_chip"] or 0
    if USER_INFO["chips"] > USER_INFO["base_chip"]*3 then
        return true
    else
        return false
    end
end

--检查兑换筹码所需的兜币
function GroupGame:checkMoney2Chips()
    -- body
    print("getGroupInfo",USER_INFO["gold"])
    USER_INFO["chips"] = USER_INFO["chips"] or 0
    USER_INFO["base_chip"] = USER_INFO["base_chip"] or 0
    USER_INFO["group_chip"] = USER_INFO["group_chip"] or 0
    USER_INFO["group_cost_rate"] = USER_INFO["group_cost_rate"] or 0
    USER_INFO["gold"] = USER_INFO["gold"] or 0

    local needMoney = USER_INFO["group_chip"] - USER_INFO["chips"]

    print("checkMoney2Chips",needMoney,USER_INFO["gold"])

    if needMoney + needMoney*USER_INFO["group_cost_rate"]/100 > USER_INFO["gold"] then
        require("hall.GameTips"):showTips("兜币余额不足，请充值","change_money2chips",1)
        return false
    end

    return true
end

return GroupGame