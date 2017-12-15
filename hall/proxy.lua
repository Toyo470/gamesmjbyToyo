--
-- Author: Your Name
-- Date: 2017-04-21 08:59:44
--



local Proxy = class("Proxy") 


function Proxy:BindProxy(room_cards)  --创建代理界面
	local layoutBind = SCENENOW['scene']:getChildByName("Proxy")
	if not tolua.isnull(layoutBind) then
		layoutBind:removeSelf()
	end
	layoutBind = cc.CSLoader:createNode("hall/proxy/csb/Proxy.csb"):addTo(SCENENOW["scene"])
	layoutBind:setName("Proxy")
	layoutBind:setLocalZOrder(9999)
    local proxyid_xy = layoutBind:getChildByName('proxyid_in')
    local Text_1 = layoutBind:getChildByName('Text_1')
    if room_cards then
        Text_1:setString("请输入您的推荐人ID，即可领取房卡"..tostring(room_cards).."张！免费福利大放送。")
    else
        Text_1:setString("请输入您的推荐人ID。")
    end
	local tbNumber={}
	local numPos=0
	local str=1
	local function reFresh()
        dump(tbNumber, "tbNumber")
        -- for i = 1,5 do
        --     str = "num_box_"..tostring(i)
        --     local txt = layoutBind:getChildByName(str):getChildByName("Text_1")
        --     if tbNumber[i] then
        --         txt:setString(tostring(tbNumber[i]))  请输入您的推荐人ID，即可领取房卡5张！免费福利大放送。
        --     else
        --         txt:setString("")
        --     end
        -- end
        local txt = ""
        -- if #tbNumber > 0 then
            for k,v in pairs(tbNumber) do
                if v then
                    txt = txt..tostring(v)
                end
            end
        -- end
        print(#txt,"vvvvvvvvvvvvvvvvvv")
        if #txt > 0 then
            Text_1:setVisible(false)
        else
            Text_1:setVisible(true)
        end
        proxyid_xy:setString(txt)
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
        tbBtnNumbers[i] = layoutBind:getChildByName(str)
    end
    local btn_submit = layoutBind:getChildByName("btn_submit")
    local btn_del = layoutBind:getChildByName("btn_del")
    local panel_btn = layoutBind:getChildByName("btn_ext")  -- 点击X键删除当前代理页
    --设置确定按钮状态
    local function setSubmit(flag)
        if btn_submit then
            btn_submit:setTouchEnabled(flag)
            if flag == false then
                btn_submit:setColor(cc.c3b(125,125,125))
            else
                btn_submit:setColor(cc.c3b(255,255,255))
            end
        end
    end
    setSubmit(false)
     local function touchButtonEvent(sender, event)
        if event == TOUCH_EVENT_ENDED then
            if #tbNumber < 10 then
                for i=1,10 do
                    if sender == tbBtnNumbers[i] then
                        numPos = numPos + 1
                        tbNumber[numPos] = i
                        if tbNumber[numPos] >= 10 then
                            tbNumber[numPos] = 0
                        end
                        reFresh()
                        if #tbNumber >= 5 then
                            setSubmit(true)
                        end  
                    end
                end
            end
            -- --确定代理
            if sender == btn_submit then
                local strCode = ""
                -- for i = 1, 5 do
                --     strCode = strCode..tostring(tbNumber[i])
                -- end
                strCode = proxyid_xy:getString()
                print("inviteCode:",strCode)
                self:HttpProxy(strCode)    --使用接口
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
                layoutBind:removeSelf()
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

end

function Proxy:removeProxy(data,agentCode_1)
    local msg = data.msg
	if data.code =='1' then
		if not tolua.isnull(SCENENOW['scene']:getChildByName("Proxy")) then
			SCENENOW['scene']:removeChildByName('Proxy')
		end
        if SCENENOW["scene"] and SCENENOW["scene"].paySuccessHandle then
            SCENENOW["scene"]:paySuccessHandle()
        end
		require("hall.GameTips"):showTips("恭喜", "", 3, msg)
		USER_INFO['proxyId'] = agentCode_1
		bm.isProxy = false
        
	else
		self:BindProxy()
		require("hall.GameTips"):showTips("提示", "", 3, msg)
	end
end


function Proxy:HttpProxy(agentCode_1)  --绑定代理接口
	local uid = USER_INFO['uid']
	cct.createHttRq({
            url=HttpAddr2 .. "/front/player/bandAgent",
            date={
                playerId = tostring(uid),
                agentCode = agentCode_1
            },
            type_="GET",
            callBack = function(data)
            	local Netdata=json.decode(data.netData)
                if Netdata then 
                	self:removeProxy(Netdata,agentCode_1)
                end
            	dump(Netdata,"ssssssssssssssss")
        	end
	    })
end


function Proxy:InquireProxy()  --查询代理接口
     --代理
    local httpurl = HttpAddr2.."/front/player/selectAgentCodeFromPlayId"
    local uid = USER_INFO['uid']
    cct.createHttRq({
        url = httpurl,
        date = {
          playerId = uid
        },
        type_ = "GET", --"POST",

        callBack = function(data)
            local data_netData = json.decode(data["netData"])
            if not data_netData then
                print("查询代理信息, 解析失败。。。")
                return 
            end
            -- code = 1,请求成功
            dump(data_netData,"data_netData")
            if data_netData.code == "1" then
                --todo
                bm.isProxy = false
                USER_INFO['proxyId'] = data_netData.data
           else
                bm.isProxy = true
                if data_netData.data1 then
                    USER_INFO['romm_cards'] = data_netData.data1
                end
            end
        end
    })
end

return Proxy