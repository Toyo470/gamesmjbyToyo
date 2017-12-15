local Scene = class("Scene")

local responseData

local back_bt

local tab_sv

local content_ly
local majiang_content_sv

local majiang_a_content_ly
local majiang_b_content_ly
local majiang_c_content_ly

local create_ly

local mjnamelist = {"sc"}

local roundlist = {"4","8"};
local round_select_ly_list = {}

local playType = {"2番","3番","4番"};
local playType_select_ly_list = {}

local canpick_check_1 = {"自摸加底","自摸加番"}
local canpick_check_1_select_ly_list = {}

local canpick_check_2 = {"点杠花","点杠花"}
local canpick_check_2_select_ly_list = {}

local canpick = {"换三张","幺九将对","门清中张","天地胡"};
local canpick_select_ly_list = {}
local canpick_select_list = {}

local tab_item_ly_list = {}
local content_ly_list = {}

--记录最终提交的参数
local parameter = {}

--记录单选项所有选择项控件
local radio_view = {}
local radio_value = {}

--记录多选项所有选择项控件
local checkbox_view = {}
local checkbox_value = {}
local checkbox_select = {}

function Scene:CreateScene()
    print("new group_create_mj scene")

    parameter = {}

    --获取界面
    local s = cc.CSLoader:createNode("hall/group/create/group_create_mj.csb")
    s:setName("group_create_mj")
    SCENENOW["scene"]:addChild(s)

    --定义控件
    --返回按钮
    back_bt = s:getChildByName("back_bt")
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

                s:removeSelf()

            end
        end
    )

    --内容区域
    content_ly = s:getChildByName("content_ly")
    --内容滑动区域
    majiang_content_sv = content_ly:getChildByName("majiang_content_sv")
    majiang_content_sv:setAnchorPoint(cc.p(0,1))
    majiang_content_sv:setContentSize(cc.size(893, 255))

    --tab分页
    --tab标签滑动区域
    tab_sv = s:getChildByName("tab_sv")
    for k,v in pairs(mjnamelist) do

        -- 获取组局创建配置数据
        if bm.groupGameConfig == nil then
            return
        end
        
        -- local xzConfig = bm.groupGameConfig[1]
        local xzConfig
        if #bm.groupGameConfig > 0 then
            for k,v in pairs(bm.groupGameConfig) do
                --获取选中的游戏的组局配置
                if USER_INFO["enter_mode"] == v.gameId then
                    xzConfig = v
                    break
                end
            end
        end
        
        if xzConfig == nil then
            return
        end

        local otherGame = xzConfig.otherGame
        dump(otherGame, "-----当前选中游戏的其他配置-----")

        local new_arr = {}
        table.insert(new_arr, xzConfig)

        if otherGame ~= nil and #otherGame > 0 then
            for i,v in ipairs(otherGame) do
                table.insert(new_arr, v)
            end
        end

        for i,v in pairs(new_arr) do
            
            --显示游戏名
            --定义分页标签
            local ly = cc.CSLoader:createNode("hall/group/create/tab_item_ly.csb")
            if #new_arr > 3 then
                ly:setScale(0.78)
            end
            tab_sv:addChild(ly)

            local tab_item_ly = ly:getChildByName("tab_item_ly")
            tab_item_ly:setAnchorPoint(cc.p(0,0))
            tab_item_ly:setPosition(263 * (i-1), 0)
            tab_item_ly_list[i] = tab_item_ly

            local gameName = v.gameName
            if gameName == "血战麻将" then
                tab_item_ly:getChildByName("tab_item_text"):loadTexture("hall/group/create/text_xuezhandaodi.png")
            elseif gameName == "转转麻将" then
                tab_item_ly:getChildByName("tab_item_text"):loadTexture("hall/group/create/text_zhuanzhuanmajiang.png")
            elseif gameName == "二人转转" then
                tab_item_ly:getChildByName("tab_item_text"):loadTexture("hall/group/create/text_errenhongzhong.png")
            elseif gameName == "三人转转" then
                tab_item_ly:getChildByName("tab_item_text"):loadTexture("hall/group/create/text_sanrenhongzhong.png")
            elseif gameName == "快速红中" then
                tab_item_ly:getChildByName("tab_item_text"):loadTexture("hall/group/create/text_kuaisuhongzhong.png")
            elseif gameName == "长沙麻将" then
                tab_item_ly:getChildByName("tab_item_text"):loadTexture("hall/group/create/text_changshamajiang.png")
            elseif gameName == "广东麻将" then
                tab_item_ly:getChildByName("tab_item_text"):loadTexture("hall/group/create/text_guangdongmajiang.png")
            elseif gameName == "血流麻将" then
                tab_item_ly:getChildByName("tab_item_text"):loadTexture("hall/group/create/text_xueliuchenghe.png")
            elseif gameName == "推倒胡" then
                tab_item_ly:getChildByName("tab_item_text"):loadTexture("hall/group/create/text_tuidaohu.png")
            elseif gameName == "卡五星" then
                tab_item_ly:getChildByName("tab_item_text"):loadTexture("hall/group/create/text_kawuxing.png")
            elseif gameName == "随州卡五星" then
                tab_item_ly:getChildByName("tab_item_text"):loadTexture("hall/group/create/text_suizhoukawuxing.png")
            elseif gameName == "襄阳卡五星" then
                tab_item_ly:getChildByName("tab_item_text"):loadTexture("hall/group/create/text_xiangyangkawuxing.png")
            elseif gameName == "斗牛" then
                tab_item_ly:getChildByName("tab_item_text"):loadTexture("hall/group/create/text_douniu.png")
            elseif gameName == "德州扑克" then
                tab_item_ly:getChildByName("tab_item_text"):loadTexture("hall/group/create/text_dezhoupuke.png")
            elseif gameName == "斗地主" then
                tab_item_ly:getChildByName("tab_item_text"):loadTexture("hall/group/create/text_doudizhu.png")
            elseif gameName == "诈金花" then
                tab_item_ly:getChildByName("tab_item_text"):loadTexture("hall/group/create/text_zhajinhua.png")
            elseif gameName == "跑得快" then
                tab_item_ly:getChildByName("tab_item_text"):loadTexture("hall/group/create/text_paodekuai.png")
            elseif gameName == "三公" then
                tab_item_ly:getChildByName("tab_item_text"):loadTexture("hall/group/create/text_sangong.png")
            elseif gameName == "跑胡子" then
                tab_item_ly:getChildByName("tab_item_text"):loadTexture("hall/group/create/text_paohuzi.png")
            elseif gameName == "海南麻将" then
                tab_item_ly:getChildByName("tab_item_text"):loadTexture("hall/group/create/text_hainanmajiang.png")
            elseif gameName == "营口麻将" then
                tab_item_ly:getChildByName("tab_item_text"):loadTexture("hall/group/create/text_yingkongmajaing.png")
            elseif gameName == "湘阴麻将" then
                tab_item_ly:getChildByName("tab_item_text"):loadTexture("hall/group/create/text_xiangyinmajiang.png")
            end

            local tab_item_im = tab_item_ly:getChildByName("tab_item_im")
            tab_item_im:loadTexture("hall/group/create/red_button_n.png")

            --分页标签点击事件
            tab_item_ly:addTouchEventListener(
                function(sender,event)
                    --触摸开始
                    if event == TOUCH_EVENT_BEGAN then
                        -- sender:setScale(0.9)
                    end

                    --触摸取消
                    if event == TOUCH_EVENT_CANCELED then
                        -- sender:setScale(1.0)
                    end

                    --触摸结束
                    if event == TOUCH_EVENT_ENDED then
                        -- sender:setScale(1.0)

                        for k,v in pairs(tab_item_ly_list) do

                            local tab_item_im = v:getChildByName("tab_item_im")
                            tab_item_im:loadTexture("hall/group/create/red_button_n.png")
                            if v == sender then
                                tab_item_im:loadTexture("hall/group/create/red_button_p.png")
                            end

                        end

                        --记录当前游戏的游戏id
                        parameter["gameId"] = v.gameId

                        --记录当前游戏对应的等级
                        parameter["level"] = v.level

                        --记录当前游戏对应的底注
                        parameter["diZhu"] = v.diZhu

                        --记录当前游戏对应的筹码
                        parameter["chouMa"] = v.chouMa

                        self:showConfigView(v)

                    end
                end
            )

            --记录默认游戏配置
            if i == 1 then

                tab_item_im:loadTexture("hall/group/create/red_button_p.png")
                
                --记录当前游戏的游戏id
                parameter["gameId"] = v.gameId

                --记录当前游戏对应的等级
                parameter["level"] = v.level

                --记录当前游戏对应的底注
                parameter["diZhu"] = v.diZhu

                --记录当前游戏对应的筹码
                parameter["chouMa"] = v.chouMa

                self:showConfigView(v)

            end

        end

    end

    --创建房间按钮
    create_ly = s:getChildByName("create_ly")
    create_ly:addTouchEventListener(
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

                 require("hall.group.GroupSetting"):create(1, 1, 1, parameter["level"], parameter)

            end
        end
    )

end

--生成配置界面
function Scene:showConfigView(nowGame)

    --释放之前的
    local s = majiang_content_sv:getChildByName("config_ly")
    if s then
        s:removeSelf()
    end

    --清空选线控件记录数组
    --记录单选项所有选择项控件
    radio_view = {}
    radio_value = {}

    --记录多选项所有选择项控件
    checkbox_view = {}
    checkbox_value = {}
    checkbox_select = {}

    --定义选项区域
    local content_ly = ccui.Layout:create()
    content_ly:setName("config_ly")
    content_ly:setAnchorPoint(cc.p(0,1))
    content_ly:setContentSize(cc.size(0, 0))

    --把选项区域添加到滚动区域
    majiang_content_sv:addChild(content_ly)

    --定义选项区域高度
    local content_ly_height = 0

    --获取当前游戏配置
    local gameConfig = nowGame.gameConfig
    if #gameConfig > 0 then

        dump(gameConfig, "------配置分类-----")

        for k,v in pairs(gameConfig) do

            --添加配置分类显示区域
            local class_ly = ccui.Layout:create()
            class_ly:setAnchorPoint(cc.p(0,1))
            class_ly:setContentSize(cc.size(0, 0))
            class_ly:setTouchEnabled(false)
            -- class_ly:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
            -- class_ly:setBackGroundColor(cc.c3b(0, 0, 0)) 
            content_ly:addChild(class_ly)

            --定义配置分类显示区域高度
            local class_ly_height = 0

            --添加配置分类标题
            local itemName_iv = ccui.ImageView:create()
            itemName_iv:setAnchorPoint(cc.p(0,1))
            itemName_iv:setPosition(0, 0)
            itemName_iv:setScale(0.8)
            
            --获取配置分类名
            local configShowName = v.configShowName
            dump(configShowName, "------配置分类名-----")
            if configShowName == "局数" then
                itemName_iv:loadTexture("hall/group/create/text_jushu.png")
            elseif configShowName == "玩法" then
                itemName_iv:loadTexture("hall/group/create/text_wanfa.png")
            elseif configShowName == "可选" then
                itemName_iv:loadTexture("hall/group/create/text_kexuan.png")
            end
            class_ly:addChild(itemName_iv)

            --获取配置选项组
            local configGroup = v.configGroup
            if #configGroup > 0 then
                for k,v in pairs(configGroup) do

                    local group_ly = ccui.Layout:create()
                    group_ly:setAnchorPoint(cc.p(0,1))
                    group_ly:setContentSize(cc.size(0, 0))
                    group_ly:setTouchEnabled(false)
                    class_ly:addChild(group_ly)

                    local config = v.config
                    dump(config, "------配置组名,用作key-----")

                    local isCheckBox = v.isCheckBox
                    dump(isCheckBox, "------是否多选-----")

                    local configOption = v.configOption
                    dump(configOption, "------配置选项-----")

                    if #configOption > 0 then

                        --根据选项数计算显示区域行高
                        local line = #configOption / 3
                        if line > 0 and line <= 1 then
                            line = 1
                        elseif line > 1 and line <= 2 then
                            line = 2
                        elseif line > 2 and line <= 3 then
                            line = 3
                        end
                        local group_ly_height = 43 * line

                        group_ly:setPosition(0, class_ly_height * -1)

                        class_ly_height = class_ly_height + group_ly_height

                        if isCheckBox == 0 then

                            --记录当前选项所有数据
                            radio_value[config] = configOption

                            --初始化当前选择对应控件缓存数组
                            radio_view[config] = {}

                            for k,v in pairs(configOption) do

                                --定义单选项
                                local circle_select = cc.CSLoader:createNode("hall/group/create/circle_select.csb")
                                group_ly:addChild(circle_select)

                                local select_ly = circle_select:getChildByName("select_ly")
                                select_ly:setAnchorPoint(cc.p(0,1))
                                select_ly:setScale(0.8)
                                radio_view[config][k] = select_ly

                                --按顺序排列显示选项
                                local x = 0
                                local y = 0
                                local a = k - 1
                                if configShowName == "玩法" then
                                    if a % 3 == 0 then
                                        x = (select_ly:getContentSize().width + 12) * 0 + itemName_iv:getContentSize().width + 22
                                    elseif a % 3 == 1 then
                                        x = (select_ly:getContentSize().width + 12) * 1 + itemName_iv:getContentSize().width + 22
                                    elseif a % 3 == 2 then
                                        x = (select_ly:getContentSize().width + 12) * 2 + itemName_iv:getContentSize().width + 22
                                    end
                                else
                                    if a % 3 == 0 then
                                        x = (select_ly:getContentSize().width + 12) * 0 + itemName_iv:getContentSize().width + 20
                                    elseif a % 3 == 1 then
                                        x = (select_ly:getContentSize().width + 12) * 1 + itemName_iv:getContentSize().width + 20
                                    elseif a % 3 == 2 then
                                        x = (select_ly:getContentSize().width + 12) * 2 + itemName_iv:getContentSize().width + 20
                                    end
                                end
                                y = (select_ly:getContentSize().height + 5) * math.floor(a / 3) * -1
                                select_ly:setPosition(x, y)
                                
                                --设置选项显示内容
                                local select_im = select_ly:getChildByName("select_im")
                                local select_tt_1 = select_ly:getChildByName("select_tt_1")
                                select_tt_1:setString(v.optionName)

                                local select_tt_2 = select_ly:getChildByName("select_tt_2")
                                if isiOSVerify then
                                    select_tt_2:setString("")
                                else
                                    select_tt_2:setString("")
                                    if config == "round" then
                                        if v.cardCount ~= nil then
                                            select_tt_2:setString("（房卡X" .. v.cardCount .. ")")
                                        end
                                    end
                                end

                                if v.isDefualt == 1 then
                                    --记录默认值到控件
                                    select_im:loadTexture("hall/group/create/creat_point_p.png")
                                    -- select_tt_1:setTextColor(cc.c3b(233, 76, 46))
                                    -- select_tt_2:setTextColor(cc.c3b(233, 76, 46))

                                    --记录默认上传参数
                                    local select = {}
                                    select["optionName"] = v.optionName
                                    select["optionValue"] = v.optionValue

                                    parameter[config] = select

                                else
                                    select_im:loadTexture("hall/group/create/creat_point_n.png")
                                    -- select_tt_1:setTextColor(cc.c3b(100, 33, 2))
                                    -- select_tt_2:setTextColor(cc.c3b(100, 33, 2))
                                end

                                --选项点击事件
                                select_ly:addTouchEventListener(
                                    function(sender,event)
                                        --触摸开始
                                        if event == TOUCH_EVENT_BEGAN then

                                        end

                                        --触摸取消
                                        if event == TOUCH_EVENT_CANCELED then

                                        end

                                        --触摸结束
                                        if event == TOUCH_EVENT_ENDED then

                                            for k,v in pairs(radio_view[config]) do
                                                local select_im = v:getChildByName("select_im")
                                                select_im:loadTexture("hall/group/create/creat_point_n.png")

                                                local select_tt_1 = v:getChildByName("select_tt_1")
                                                local select_tt_2 = v:getChildByName("select_tt_2")
                                                -- select_tt_1:setTextColor(cc.c3b(100, 33, 2))
                                                -- select_tt_2:setTextColor(cc.c3b(100, 33, 2))

                                                if v == sender then
                                                    select_im:loadTexture("hall/group/create/creat_point_p.png")
                                                    -- select_tt_1:setTextColor(cc.c3b(233, 76, 46))
                                                    -- select_tt_2:setTextColor(cc.c3b(233, 76, 46))

                                                    -- parameter[config]["optionName"] = radio_value[config][k].optionName
                                                    -- parameter[config]["optionValue"] = radio_value[config][k].optionValue

                                                    local select = {}
                                                    select["optionName"] = radio_value[config][k].optionName
                                                    select["optionValue"] = radio_value[config][k].optionValue

                                                    parameter[config] = select

                                                    dump(parameter, "-----更新后的提交配置-----")

                                                end
                                            end

                                        end
                                    end
                                )
                            
                            end

                        else

                            --记录当前选项所有数据
                            checkbox_value[config] = configOption

                            --初始化当前选择对应控件缓存数组
                            checkbox_view[config] = {}

                            --初始化缓存多选项选择结果数组
                            checkbox_select[config] = {}

                            --添加默认值到提交参数
                            local select = {}
                            select["optionName"] = ""
                            select["optionValue"] = ""

                            for k,v in pairs(configOption) do

                                --定义选择项
                                local tick_select = cc.CSLoader:createNode("hall/group/create/tick_select.csb")
                                group_ly:addChild(tick_select)

                                local select_ly = tick_select:getChildByName("select_ly")
                                select_ly:setAnchorPoint(cc.p(0,1))
                                select_ly:setScale(0.8)
                                checkbox_view[config][k] = select_ly
                                -- checkbox_select[config][k] = 0

                                local x = 0
                                local y = 0
                                local a = k - 1
                                if a % 3 == 0 then
                                    x = (select_ly:getContentSize().width + 28) * 0 + itemName_iv:getContentSize().width + 21
                                elseif a % 3 == 1 then
                                    x = (select_ly:getContentSize().width + 28) * 1 + itemName_iv:getContentSize().width + 21
                                elseif a % 3 == 2 then
                                    x = (select_ly:getContentSize().width + 28) * 2 + itemName_iv:getContentSize().width + 21
                                end
                                y = (select_ly:getContentSize().height + 5) * math.floor(a / 3) * -1
                                select_ly:setPosition(x, y)
                                
                                local select_im = select_ly:getChildByName("select_im")
                                local select_tt_1 = select_ly:getChildByName("select_tt_1")
                                select_tt_1:setString(v.optionName)

                                --添加默认选项
                                if v.isDefualt == 1 then

                                    if parameter["gameId"] == 43 then

                                        if v.optionValue == 3 then

                                            --查找关联项是否已经选择
                                            local selectValue_arr = LuaSplit(select["optionValue"], ",")
                                            local isHas = 0
                                            for i,v in ipairs(selectValue_arr) do
                                                if v == "1" then
                                                    --记录关联项已经选择
                                                    isHas = 1
                                                end
                                            end

                                            --关联项没有选择
                                            if isHas == 0 then

                                                --查找关联项所在位置
                                                local position = 0
                                                for i,v in ipairs(configOption) do

                                                    local tmp = tonumber(v.optionValue)

                                                    if tmp == 1 then
                                                        --记录关联项位置
                                                        position = i
                                                    end
                                                end

                                                --设置关联项选择
                                                if position > 0 then

                                                    local pei_im = checkbox_view[config][position]:getChildByName("select_im")
                                                    pei_im:loadTexture("hall/group/create/point01_p.png")
                                                    checkbox_select[config][position] = 1
                                                    select["optionName"] = select["optionName"] .. checkbox_value[config][position].optionName .. " "
                                                    select["optionValue"] = select["optionValue"] .. checkbox_value[config][position].optionValue .. ","

                                                end

                                            end

                                            select_im:loadTexture("hall/group/create/point01_p.png")
                                            checkbox_select[config][k] = 1

                                            select["optionName"] = select["optionName"] .. v.optionName .. " "
                                            select["optionValue"] = select["optionValue"] .. v.optionValue .. ","

                                        else

                                            select_im:loadTexture("hall/group/create/point01_p.png")
                                            checkbox_select[config][k] = 1

                                            select["optionName"] = select["optionName"] .. v.optionName .. " "
                                            select["optionValue"] = select["optionValue"] .. v.optionValue .. ","

                                        end

                                    else

                                        select_im:loadTexture("hall/group/create/point01_p.png")
                                        checkbox_select[config][k] = 1

                                        select["optionName"] = select["optionName"] .. v.optionName .. " "
                                        select["optionValue"] = select["optionValue"] .. v.optionValue .. ","

                                    end

                                else
                                    select_im:loadTexture("hall/group/create/point01_n.png")
                                    checkbox_select[config][k] = 0
                                end

                                --选项点击事件
                                select_ly:addTouchEventListener(
                                    function(sender,event)
                                        --触摸开始
                                        if event == TOUCH_EVENT_BEGAN then

                                        end

                                        --触摸取消
                                        if event == TOUCH_EVENT_CANCELED then

                                        end

                                        --触摸结束
                                        if event == TOUCH_EVENT_ENDED then

                                            for k,v in pairs(checkbox_view[config]) do

                                                if v == sender then

                                                    local select_im = v:getChildByName("select_im")
                                                    local select_tt_1 = v:getChildByName("select_tt_1")

                                                    if checkbox_select[config][k] == 0 then
                                                        select_im:loadTexture("hall/group/create/point01_p.png")
                                                        -- select_tt_1:setTextColor(cc.c3b(233, 76, 46))
                                                        checkbox_select[config][k] = 1

                                                        if parameter["gameId"] == 43 then

                                                            if k == 3 then
                                                                
                                                                dump(parameter[config]["optionValue"], "-----当前已经选择-----")

                                                                --查找关联项是否已经选择
                                                                local selectValue_arr = LuaSplit(parameter[config]["optionValue"], ",")
                                                                local isHas = 0
                                                                for i,v in ipairs(selectValue_arr) do
                                                                    if v == "1" then
                                                                        --记录关联项已经选择
                                                                        isHas = 1
                                                                    end
                                                                end

                                                                dump(isHas, "-----查找关联项是否已经选择-----")

                                                                --关联项没有选择
                                                                if isHas == 0 then

                                                                    --查找关联项所在位置
                                                                    local position = 0
                                                                    for i,v in ipairs(checkbox_value[config]) do

                                                                        local tmp = tonumber(v.optionValue)

                                                                        if tmp == 1 then
                                                                            --记录关联项位置
                                                                            position = i
                                                                        end
                                                                    end

                                                                    dump(position, "-----查找关联项所在位置-----")

                                                                    --设置关联项选择
                                                                    if position > 0 then
                                                                        local pei_im = checkbox_view[config][position]:getChildByName("select_im")
                                                                        pei_im:loadTexture("hall/group/create/point01_p.png")
                                                                        checkbox_select[config][position] = 1
                                                                    end

                                                                end

                                                            end

                                                        end

                                                    else
                                                        select_im:loadTexture("hall/group/create/point01_n.png")
                                                        -- select_tt_1:setTextColor(cc.c3b(100, 33, 2))
                                                        checkbox_select[config][k] = 0

                                                        if parameter["gameId"] == 43 then

                                                            if k == 1 then
                                                                
                                                                dump(parameter[config]["optionValue"], "-----当前已经选择-----")

                                                                --查找关联项是否已经选择
                                                                local selectValue_arr = LuaSplit(parameter[config]["optionValue"] .. ",0", ",")
                                                                dump(selectValue_arr, "-----当前已经选择-----")

                                                                local isHas = 0
                                                                for i,v in ipairs(selectValue_arr) do
                                                                    if v == "3" then
                                                                        --记录关联项已经选择
                                                                        isHas = 1
                                                                    end
                                                                end

                                                                dump(isHas, "-----查找关联项是否已经选择-----")

                                                                --关联项已经选择
                                                                if isHas == 1 then

                                                                    --查找关联项所在位置
                                                                    local position = 0
                                                                    for i,v in ipairs(checkbox_value[config]) do

                                                                        local tmp = tonumber(v.optionValue)

                                                                        if tmp == 3 then
                                                                            --记录关联项位置
                                                                            position = i
                                                                        end
                                                                    end

                                                                    dump(position, "-----查找关联项所在位置-----")

                                                                    --设置关联项选择
                                                                    if position > 0 then
                                                                        local pei_im = checkbox_view[config][position]:getChildByName("select_im")
                                                                        pei_im:loadTexture("hall/group/create/point01_n.png")
                                                                        checkbox_select[config][position] = 0
                                                                    end

                                                                end

                                                            end

                                                        end

                                                    end


                                                    --更新多选配置选项
                                                    local newPick_str = ""
                                                    local newPick = ""
                                                    for k,v in pairs(checkbox_select[config]) do
                                                        if v == 1 then
                                                            newPick_str = newPick_str .. checkbox_value[config][k].optionName .. " "
                                                            newPick = newPick .. checkbox_value[config][k].optionValue .. ","
                                                        end
                                                    end
                                                    parameter[config] = string.sub(newPick, 1, string.len(newPick) - 1)

                                                    local select = {}
                                                    select["optionName"] = string.sub(newPick_str, 1, string.len(newPick_str) - 1)
                                                    select["optionValue"] = string.sub(newPick, 1, string.len(newPick) - 1)
                                                    parameter[config] = select

                                                    dump(parameter, "-----更新后的提交配置-----")

                                                end

                                            end

                                        end
                                    end
                                )
                            
                            end

                            --添加默认项
                            select["optionName"] = string.sub(select["optionName"], 1, string.len(select["optionName"]) - 1)
                            select["optionValue"] = string.sub(select["optionValue"], 1, string.len(select["optionValue"]) - 1)
                            parameter[config] = select

                        end
                        
                    end

                end
            end

            class_ly:setPosition(0, content_ly_height * -1)
            content_ly_height = content_ly_height + class_ly_height

        end

        --设置内容显示位置
        content_ly:setPosition(67, content_ly_height + 80)

        --设置内容显示区域大小
        majiang_content_sv:setInnerContainerSize(cc.size(893, content_ly_height + 80))

        dump(parameter, "-----默认配置-----")

    end

end

--返回数据后操作
function Scene:HandleResponseData(data)

    --记录返回数据到全局变量
    responseData = json.decode(data);

    --输出返回值
    dump(data)

    -- self:ShowSiChuanSetting(responseData)
    
end

--显示四川麻将设置
function Scene:ShowSiChuanSetting(data)

    dump('-----------------四川麻将-----------------')

    --切换标签
    -- majiang_a_im:loadTexture("hall/group/create/red_button_p.png")

    --切换显示内容
    majiang_a_content_ly:setVisible(true)
    majiang_b_content_ly:setVisible(false)
    majiang_c_content_ly:setVisible(false)

end

--按照传入的分隔符，切割字符串
function LuaSplit(str, split_char)  
    if str == "" or str == nil then   
        return {};  
    end  
    local split_len = string.len(split_char)  
    local sub_str_tab = {};  
    local i = 0;  
    local j = 0;  
    while true do  
        j = string.find(str, split_char,i+split_len);--从目标串str第i+split_len个字符开始搜索指定串  
        if string.len(str) == i then   
            break;  
        end  
  
  
        if j == nil then  
            table.insert(sub_str_tab,string.sub(str,i));  
            break;  
        end;  
  
  
        table.insert(sub_str_tab,string.sub(str,i,j-1));  
        i = j+split_len;  
    end  
    return sub_str_tab;  
end

return Scene
