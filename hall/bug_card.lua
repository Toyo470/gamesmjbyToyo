--创建一个http请求
cct = cct or {}
function cct.createHttRq(parm)
    local url=parm.url;
    local date=parm.date or {}
    local callBack=parm.callBack 
    local type_=parm.type_ or "POST"
    local arg=parm.arg or {}
    -- body
    local function reqCallback(event)
        -- body
        local ok = (event.name == "completed")
        local request = event.request
     
        if not ok then
            -- 请求失败，显示错误代码和错误消息
            print(request:getErrorCode(), request:getErrorMessage())
            return
        end

     
        local code = request:getResponseStatusCode()
        if code ~= 200 then
            -- 请求结束，但没有返回 200 响应代码
            print("getHttp error",url)
            return
        end
     
        -- 请求成功，显示服务端返回的内容
        local response = request:getResponseString()
        arg.net=event
        arg.netData=response
        callBack(arg)

        --xpcall(callBack, cct.runErrorScene,arg)
        --callBack(json.decode(response))

    end
    if type_=="GET" then
        local str="?"
        for k,v in pairs(date) do
            str=str..k.."="..v.."&"
        end
        url=url..str
    end

    local request = network.createHTTPRequest(reqCallback, url, type_)
    request:addRequestHeader('Content-Type:application/x-www-form-urlencoded')
    if type_=="POST" then
        for k,v in pairs(date) do
            request:addPOSTValue(k, v)
        end
    end
    request:setTimeout(30)
    -- 开始请求。当请求完成时会调用 callback() 函数
    request:start()
    return request
end

local BuyCard = class("BuyCard",function()
    return display.newNode()
end)

function BuyCard:ctor()


    --self:call_http()
end

function BuyCard:init( csb_path_name )
    -- body
    local view = cc.CSLoader:createNode(csb_path_name):addTo(self)
   local btn_close = view:getChildByName("btn_close")
    btn_close:onTouch(handler(self,self.close_call_back))
    local btn_buy = view:getChildByName("btn_buy")
    btn_buy:onTouch(handler(self,self.close_call_back))

    self.view = view
    self.buy_flag = false
end

function BuyCard:set_content_txt( card_type)
    -- body
    self.card_type = 0
    self.card_type  = card_type or 0 
    local  csb_path_name = "hall/monthcard/buy_card_red.csb"
    if self.card_type == 1 then
        csb_path_name = "hall/monthcard/buy_card_blue.csb"
    end
    self:init(csb_path_name)
    

    if self.card_type == 0  then
        local Text_5 = self.view:getChildByName("Text_5") 
        local Text_11 = self.view:getChildByName("Text_11")  -- 价格
        local red_amount = USER_INFO["redMonthCardSignInAmount"] or 2500
        Text_5:setString("       每天登陆即送"..tostring(red_amount).."金币\n连送30天，总额高达"..tostring(red_amount*30).."金币")

        local price =  USER_INFO["redMonthCardPrice"] or 12
        Text_11:setString("有效期30天  价格:"..tostring(price).."元")
    end
end

function BuyCard:close_call_back( event )
    -- body
    if event.name == "began" then
        event.target:setScale(0.7)
    elseif  event.name == "moved" then
       event.target:setScale(1.0)
    elseif event.name == "ended" then
       event.target:setScale(1.0)
       local target_name = event.target:getName()
       if "btn_close" == target_name then
            local parent = self:getParent()
            if parent then
                if parent.refresh_layout then
                    parent:refresh_layout(0)
                end
            end

            self:removeSelf()
            return
       elseif "btn_buy" == target_name then
            if  self.buy_flag == false then
                self:call_http(self.card_type)
                 self.buy_flag = true
            end

       end

    end
end

function  BuyCard:call_http(card_type)
    -- body
    -- HttpAddr = "http://120.76.133.49/hbiInterface"
    card_type = card_type or 0
    cct.createHttRq({
            url=HttpAddr .. "/user/buyMonthCard",--http://120.76.133.49:80/hbiInterface/goods/queryGoodsList
            date={
                userId = USER_INFO["uid"],
                cardType = card_type,--0是红卡，1是兰卡
                interfaceType = "json"
            },
            type_="GET",
            callBack = function(data)
            self:buy_monthcard_data_callBack(data)
         end
        })
end

function BuyCard:buy_monthcard_data_callBack( data )
    data = data.netData
    data = json.decode(data)
    dump(data,"buy_monthcard_data_callBack")

    if data.returnCode == "0" then
        local GameTips = require("hall.GameTips")
        if self.card_type == 0 then
            GameTips:showTips("购买红卡成功")
        else
            GameTips:showTips("购买蓝卡成功")
        end

        local parent = self:getParent()
        if parent then
            if parent.refresh_layout then
                parent:refresh_layout(1)
            end

            self:removeSelf()
        end
    else
        self.buy_flag = false
        local parent = self:getParent()
        if parent then
            if parent.refresh_layout then
                parent:refresh_layout(-1)
            end
        end
    end
end


return BuyCard
