require("framework.init")


local NiuniuroomServer = class("NiuniuroomServer")
local PROTOCOL         = import("..Niuniu_Protocol")
function NiuniuroomServer:ctor()
	
end


--退出房间
function NiuniuroomServer:quickRoom()

    dump("", "-----用户发送退出房间1002-----")

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_QUIT_ROOM)
        :build()
    bm.server:send(pack)

end

--用户发送准备
function NiuniuroomServer:readyNow(val)

    dump(val, "-----用户发送准备2001-----")

    -- if  USER_INFO["enter_mode"] ~= 0 and not val then
    --     --todo
    --     bm.runScene:getChips()
    -- end

	local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_READYNOW_ROOM)
        :build()
    bm.server:send(pack)

end

--不抢庄
function NiuniuroomServer:noQiang()

    dump("0", "-----用户发送不抢庄2007 不抢庄-----")

	local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_QIANGZHUANG)
		:setParameter("if_qiang", 0)
        :build()
    bm.server:send(pack)

end

--抢庄
function NiuniuroomServer:qiang()

    dump("1", "-----用户发送抢庄2007 抢庄-----")

	local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_QIANGZHUANG)
		:setParameter("if_qiang", 1)
        :build()
    bm.server:send(pack)

end

--加倍倍数
function NiuniuroomServer:addBase(base)

    dump(base, "-----加倍倍数 2008-----")

	local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_USER_BASES)
		:setParameter("bases", base)
        :build()
    bm.server:send(pack)

end

--发送牌数据
function NiuniuroomServer:sendMycards()

    dump("", "-----发送牌数据sendMycards 2003-----")

    local tmp = {}

    -- 选牌是否合法
    if #bm.Room.Mychoice == 3 then -- 合法选牌
        for i,v in pairs(bm.Room.Mychoice) do
            local tmp_c = {}
            tmp_c['card'] = v.cardUint_
            table.insert(tmp,tmp_c)
        end
    else -- 系统选牌
        bm.Room.Mychoice = {}
        local vCombination = {}
        table.insert(vCombination, {1,2,3})
        table.insert(vCombination, {1,2,4})
        table.insert(vCombination, {1,2,5})
        table.insert(vCombination, {1,3,4})
        table.insert(vCombination, {1,3,5})
        table.insert(vCombination, {1,4,5})
        table.insert(vCombination, {2,3,4})
        table.insert(vCombination, {2,3,5})
        table.insert(vCombination, {2,4,5})
        table.insert(vCombination, {3,4,5})
        for k, v in pairs(vCombination) do
            local value = 0
            for kk, vv in pairs(v) do
                local card = bm.User.Cards[vv].cardValue_
                if card > 10 and card <14 then
                    card = 10
                elseif card > 13 then
                    card = 1
                end
                value = value + card
            end
            if value % 10 == 0 then --插入牌值
                for kk, vv in pairs(v) do
                    local card = bm.User.Cards[vv]
                    table.insert(bm.Room.Mychoice,card)
                    local tmp_c = {}
                    tmp_c['card'] = card.cardUint_
                    table.insert(tmp,tmp_c)
                end
                break
            end
        end
        -- 没牛
        if #bm.Room.Mychoice < 3 then
            for i = 1, 3 do
                local card = bm.User.Cards[i]
                table.insert(bm.Room.Mychoice,card)
                local tmp_c = {}
                tmp_c['card'] = card.cardUint_
                table.insert(tmp,tmp_c)
            end
        end
        dump(bm.Room.Mychoice, "sendMycards", nesting)
    end

    dump(tmp, "sendMycards tmp", nesting)

    if #tmp >= 3 then
        local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_PLAY_CARD)
            :setParameter("mount", #tmp)
            :setParameter("cards",tmp)
            :build()
        bm.server:send(pack)
    end

end


--发送牌数据
function NiuniuroomServer:sendMycards_no()

    dump("", "-----发送牌数据sendMycards_no 2003-----")

    local tmp = {}
    local ik = 1
    local kkk = {7,11,28} 
    for i,v in pairs(bm.Room.Mychoice) do
        local tmp_c = {}
        tmp_c['card'] =kkk[ik] --v.cardUint_
        print("+++++++++++++chen++++++++++++++++++")
        print(v.cardUint_)
        table.insert(tmp,tmp_c)
        ik = ik +1
    end
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_PLAY_CARD)
        :setParameter("mount", #tmp)
        :setParameter("cards",tmp)
        :build()
    bm.server:send(pack)

end


--发送假的不要牛的牌数据
function NiuniuroomServer:sendNotNiuPaiMsg()

    dump("", "-----发送假的不要牛的牌数据 2003-----")

    -- 获得牌值
    local function getValue(card)
        local value = bit.band(card, 0x0F)
        if value == 1 then
            value = 14
        end
        return value
    end

    local tmp = {}
    table.insert(tmp,{card = 10})
    table.insert(tmp,{card = 11})
    table.insert(tmp,{card = 56})
    printInfo("===========notniudata========================")
    printInfo(getValue(10))
    printInfo(getValue(11))
    printInfo(getValue(56))

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_PLAY_CARD)
        :setParameter("mount", #tmp)
        :setParameter("cards",tmp)
        :build()
    bm.server:send(pack)

end

--解散相关
--请求解散房间
function NiuniuroomServer:C2G_CMD_DISSOLVE_ROOM()

    dump("", "-----请求解散房间 808-----")

    local pack = bm.server:createPacketBuilder(PROTOCOL.C2G_CMD_DISSOLVE_ROOM)
    :build()
    bm.server:send(pack)

end

--回复请求解散房间
function NiuniuroomServer:C2G_CMD_REPLY_DISSOLVE_ROOM(agree)

    dump(agree, "-----回复请求解散房间 809-----")

    local pack = bm.server:createPacketBuilder(PROTOCOL.C2G_CMD_REPLY_DISSOLVE_ROOM)
    :setParameter("agree", agree)
    :build()
    bm.server:send(pack)
    
end

--聊天相关
function NiuniuroomServer:CLI_MSG_FACE(id)
    local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_MSG_FACE)
    :setParameter("type", id)
    :build()
    bm.server:send(pack)
end

--发送组局信息
function NiuniuroomServer:SendGameMsg(level,msg)

    dump(level, "-----当前组局level-----")
    dump(msg, "-----发送组局信息-----")

    local pack = bm.server:createPacketBuilder(PROTOCOL.CLIENT_CMD_FORWARD_MESSAGE)
                    :setParameter("level", level)
                    :setParameter("msg", msg)
                    :build()
    bm.server:send(pack)

end

return NiuniuroomServer