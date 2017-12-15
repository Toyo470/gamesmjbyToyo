require("cocos.framework.extends.UIWidget")

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


local Signin_layer = class("Signin_layer",function()
    return display.newNode()
end)

function Signin_layer:ctor()
    local  csb_path_name = "hall/monthcard/signin_layer.csb"
    
    self:init(csb_path_name)

    self:set_txt_num()
end

function Signin_layer:init( csb_path_name )
    -- body
    local view = cc.CSLoader:createNode(csb_path_name):addTo(self)
    self.view = view

    --local btn_close = view:getChildByName("btn_close")
   -- btn_close:onTouch(handler(self,self.close_call_back))

    local btn_gain = view:getChildByName("btn_gain")
    btn_gain:onTouch(handler(self,self.close_call_back))

    local btn_buy = view:getChildByName("btn_buy")
    btn_buy:onTouch(handler(self,self.close_call_back))

end

function Signin_layer:close_call_back( event )
    -- body
    if event.name == "began" then
        event.target:setScale(0.7)
    elseif  event.name == "moved" then
       event.target:setScale(1.0)
    elseif event.name == "ended" then
       event.target:setScale(1.0)


       local target_name = event.target:getName()
       if "btn_close" == target_name then
            self:removeSelf()
            return
       elseif "btn_gain" == target_name then
            self:call_http()

       elseif "btn_buy" == target_name then
            local BuyCard = require("hall.bug_card")
            local buy = BuyCard.new()
            buy:set_content_txt(0) -- 0是红卡，1是蓝卡

            self:addChild(buy)
       end

    end
end

function Signin_layer:set_txt_num()
    -- body
    local hasRedMonthCard = USER_INFO["hasRedMonthCard"] or 0
    local red_amount = USER_INFO["redMonthCardSignInAmount"] or 2500
    local monthCardSignInAmount  = USER_INFO["monthCardSignInAmount"] or 300

    local Image_4 =  self.view:getChildByName("Image_4")
    local Text_4 = Image_4:getChildByName("Text_4")

    Text_4:setString(tostring(monthCardSignInAmount))

   -- local extern_num = red_amount - monthCardSignInAmount
   -- hasRedMonthCard = 0
    if hasRedMonthCard ~= 0 then
        Text_4:setString(tostring(monthCardSignInAmount))
        
        local btn_buy = self.view:getChildByName("btn_buy")
        btn_buy:setVisible(false)

       -- if extern_num > 0 then
            local Text_5 = self.view:getChildByName("Text_5")
            Text_5:setString("你拥有月卡喔，可以额外获得"..tostring(red_amount).."金币")
       -- end
    end

end

function Signin_layer:refresh_layout(flag)
    -- body
    if flag ~= 1 then
        return
    end

    local red_amount = USER_INFO["redMonthCardSignInAmount"] or 2500
    local monthCardSignInAmount  = USER_INFO["monthCardSignInAmount"] or 300
   -- local extern_num = red_amount - monthCardSignInAmount

    local btn_buy = self.view:getChildByName("btn_buy")
    btn_buy:setVisible(false)
    
    local Image_4 =  self.view:getChildByName("Image_4")
    local Text_4 = Image_4:getChildByName("Text_4")
    Text_4:setString(tostring(monthCardSignInAmount))

   --if extern_num > 0 then
        local Text_5 = self.view:getChildByName("Text_5")
        Text_5:setString("你拥有月卡喔，可以额外获得"..tostring(red_amount).."金币")
   -- end

end

function  Signin_layer:call_http()
    -- body
    -- HttpAddr = "http://120.76.133.49/hbiInterface"
    print("USER_INFO[uid]---------------------",USER_INFO["uid"])
   -- USER_INFO["uid"] = 517
    cct.createHttRq({
            url=HttpAddr .. "/user/gameSignIn",--http://120.76.133.49:80/hbiInterface/goods/queryGoodsList
            date={
                userId = USER_INFO["uid"],
                interfaceType = "json"
            },
            type_="POST",
            callBack = function(data)
            if data then
                self:sign_in_callBack(data)
            end
         end
        })
end

function Signin_layer:sign_in_callBack(data)
    -- body
    
    data = data.netData
    data = json.decode(data)
    dump(data,"sign_in_callBack")

    if data.returnCode == "0" then
        local data_tbl =  data.data or {}
        local GameTips = require("hall.GameTips")
        USER_INFO["isGameSignIn"] = 1
        if data_tbl.isSignIn == true then
            GameTips:showTips("提示", "", 3, "签到成功！")
            --获取本地金币数据
            
            local coinAmount =  data_tbl.coinAmount or 0
            if coinAmount ~= 0 then
                USER_INFO["gold"] = coinAmount
            end
            
            --更新前端金币
            if SCENENOW["scene"] then
                if _G.runScene and _G.runScene.goldUpdate  then
                   --todo
                    _G.runScene:goldUpdate()
                else
                    SCENENOW["scene"]:goldUpdate()
                end
                    
            end
            
            self:removeSelf()

        else
            GameTips:showTips("提示", "", 3, "你今天已经签到过了喔！")

            self:removeSelf()
        end
    end

    if data.returnCode == "1" then
        print(data.error,"----")
        local GameTips = require("hall.GameTips")
        GameTips:showTips("提示", "", 3, data.error)
    end
end

return Signin_layer