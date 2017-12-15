

local targetPlatform = cc.Application:getInstance():getTargetPlatform()
local GroupSetting  = class("GroupSetting")
local PROTOCOL = require("hall.HALL_SERVER_PROTOCOL")

--创建组局
function GroupSetting:create(time,basechip,coin,level,parameter)

    --处理入参
    local configJson = {}
    local discription = ""
    for k,v in pairs(parameter) do
        if k ~= "gameId" and k ~= "diZhu" and k ~= "chouMa" and k ~= "level" then

            if v.optionName ~= nil then
                discription = discription .. v.optionName .. " "
            end

            if v.optionValue ~= nil then
                configJson[k] = v.optionValue
            end

        end
    end
    discription = string.sub(discription, 1, string.len(discription) - 1)

    local tbl = {}
    tbl.userId = tostring(USER_INFO["uid"])--用户ID
    tbl.phone = tostring(USER_INFO["phone"])--电话
    tbl.coins = tonumber(basechip)--底注
    tbl.gameId = tostring(parameter["gameId"])--游戏ID
    tbl.minutes = tonumber(time)--时长
    tbl["type"] = tostring(USER_INFO["type"])--用户类型
    tbl.oriCoins = tonumber(1000)-- 带入筹码
    tbl.name = tostring(USER_INFO["nick"].."的组局")--组局名称
    -- tbl.level = tonumber(level)--level
    tbl.level = GroupSetting:randLevel(level)
    print("GroupSetting:create level", tostring(tbl.level))
    tbl.round = parameter["round"].optionValue--局数
    tbl.json = json.encode(configJson)
    tbl.discription = discription
    tbl.interfaceType = "J"

    dump(tbl, "-----创建组局请求入参-----")

    require("hall.groudgamemanager"):createfreegame(USER_INFO["uid"],tbl)

end

-- 随机一个level
function GroupSetting:randLevel( strLevel )

    local strs = string.split(strLevel, "|")
    math.randomseed(os.time())
    local index = math.random(1, #strs)

    dump(strs, "randLevel", nesting)
    print("randlevel ", tostring(index), tostring(strs[index]))
    return tonumber(strs[index])
end

--加入组局
function GroupSetting:enterRoom(inviteCode)

    -- -- 获取组局创建配置数据
    -- if bm.groupGameConfig == nil then
    --     return
    -- end
    
    -- -- local xzConfig = bm.groupGameConfig[1]
    -- local xzConfig
    -- if #bm.groupGameConfig > 0 then
    --     for k,v in pairs(bm.groupGameConfig) do
    --         --获取选中的游戏的组局配置
    --         if USER_INFO["enter_mode"] == v.gameId then
    --             xzConfig = v
    --             break
    --         end
    --     end
    -- end
    
    -- if xzConfig == nil then
    --     return
    -- end

    --记录当前游戏对应的等级
    -- local level = xzConfig.level
    if inviteCode then
        require("hall.groudgamemanager"):join_freegame(USER_INFO["uid"],inviteCode)
    else
        local layerEnter = SCENENOW["scene"]:getChildByName("enter_room")
        if layerEnter == nil then
            layerEnter = cc.CSLoader:createNode("hall/group/enter_room/enter_room.csb"):addTo(SCENENOW["scene"])
            layerEnter:setName("enter_room")
        end
        local tbNumber = {}
        local numPos = 0
        local str = 1
        local function reFresh()
            dump(tbNumber, "tbNumber")
            for i = 1,6 do
                str = "num_box_"..tostring(i)
                local txt = layerEnter:getChildByName(str):getChildByName("Text_1")
                if tbNumber[i] then
                    txt:setString(tostring(tbNumber[i]))
                else
                    txt:setString("")
                end
            end
        end
        reFresh()

        --按钮
        local tbBtnNumbers = {}
        for i = 1,10 do
            if i < 10 then
                str = "btn_"..tostring(i)
            else
                str = "btn_0"
            end
            tbBtnNumbers[i] = layerEnter:getChildByName(str)
        end
        local btn_submit = layerEnter:getChildByName("btn_submit")
        local btn_del = layerEnter:getChildByName("btn_del")
        -- local btn_exit = layerEnter:getChildByName("btn_exit")
        local panel_btn = layerEnter:getChildByName("Panel_1")  -- 点击黑屏删除当前加入房间页
        local btn_re_enter = layerEnter:getChildByName("btn_re-enter") --重输
        --设置确定按钮状态
        local function setSubmit(flag)
            if btn_submit then
                btn_submit:setTouchEnabled(flag)
                if flag == false then
                    btn_submit:setColor(cc.c3b(125,125,125))
                else
                    -- btn_submit:loadTextureNormal("hall/group/enter_room/btn.png")
                    btn_submit:setColor(cc.c3b(255,255,255))
                end
            end
        end
        setSubmit(false)

        --按钮事件
        local function touchButtonEvent(sender, event)
            if event == TOUCH_EVENT_ENDED then
                if #tbNumber < 6 then
                    for i=1,10 do
                        if sender == tbBtnNumbers[i] then
                            numPos = numPos + 1
                            tbNumber[numPos] = i
                            if tbNumber[numPos] >= 10 then
                                tbNumber[numPos] = 0
                            end
                            reFresh()
                            if #tbNumber == 6 then
                                setSubmit(true)
                                -- local strCode = ""
                                -- for i = 1, 6 do
                                --     strCode = strCode..tostring(tbNumber[i])
                                -- end
                                -- print("inviteCode:",strCode)
                                -- require("hall.groudgamemanager"):join_freegame(USER_INFO["uid"], strCode, "", false, level, false)
                            end  --不用确定进入组局
                        end
                    end
                end
                -- --确定进入组局
                if sender == btn_submit then
                    local strCode = ""
                    for i = 1, 6 do
                        strCode = strCode..tostring(tbNumber[i])
                    end
                    print("inviteCode:",strCode)
                    require("hall.groudgamemanager"):join_freegame(USER_INFO["uid"],strCode)
                end
                
                if sender == btn_del then
                    if numPos > 0 then
                        table.remove(tbNumber,numPos)
                        numPos = numPos - 1
                        reFresh()
                        setSubmit(false)
                    end
                end
                if sender == panel_btn then
                    layerEnter:removeSelf()
                end

                if sender == btn_re_enter then
                    tbNumber = {}
                    numPos = 0
                    reFresh()
                    setSubmit(false)
                end
            end
        end

        --按钮注册
        for i = 1,10 do
            if tbBtnNumbers[i] then
                tbBtnNumbers[i]:addTouchEventListener(touchButtonEvent)
            end
        end

        --确定，删除
        btn_submit:addTouchEventListener(touchButtonEvent)
        btn_del:addTouchEventListener(touchButtonEvent)
        panel_btn:addTouchEventListener(touchButtonEvent)
        btn_re_enter:addTouchEventListener(touchButtonEvent)
    end
end

--重连组局提示
function GroupSetting:showTips(data,exit,join)

    require("hall.GameTips"):showTips("提示","reloadGame", 1, "是否重连房间?", data)

end

--进入组局
function GroupSetting:enterGroup()

    require("hall.GameUpdate"):enterGroup(USER_INFO["enter_code"])

end

--是否组局创建者
function GroupSetting:isGroupOwner()
    if USER_INFO["enter_mode"] ~= 4 then
        print("不是组局游戏")
        return false
    end
    if tonumber(USER_INFO["group_owner"]) ~= tonumber(USER_INFO["uid"]) then
        print("不是组局创建者")
        return false
    end
    return true
end

return GroupSetting