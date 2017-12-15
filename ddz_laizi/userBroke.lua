--
-- Author: ZT
-- Date: 2016-08-03 17:55:14
-- 破产逻辑

local isTest=true

local userBroke=class("userBroke",function()
    return display.newScene("userBroke");
end)


--破产了
function userBroke:ctor(isShowLinQu,callOk)
    print("先显示破产");
    local rootNode= cc.CSLoader:createNode("ddz/csb/userPoc.csb"):addTo(self)--先显示破产
    local pocsb=rootNode:getChildByName("Panel_2")
    self.rootNode=rootNode
    self.panle_pochang=pocsb
    self.isShowLinQu=isShowLinQu --是否显示领取 只有正在游戏中才会显示
    self.callOk=callOk

    if not isShowLinQu then
        local btn_quick=pocsb:getChildByName("Button_1")
        local btn_ok=pocsb:getChildByName("Button_2")


        local str=pocsb:getChildByName("Text_6")
        str:hide();
        if tbResult and tbResult["win"] then
            str:show()
            str:setString(tbResult["win"])
        end
        btn_quick:onClick(function()
            --离开返回大厅
            self:rtuHall()
        end)


        btn_ok:onClick(function()
            --
            if USER_INFO["isFirstCharged"] and USER_INFO["isFirstCharged"] == 1 then --you
                self:getPoChang()
            else
                self.panle_pochang:hide()
                require("hall.fRecharge"):showOut(handler(self, self.getPoChang));
            end
            
            -- require("hall.GameData"):setPlayerRoute("ddz","free",USER_INFO["base_chip"],0)
            -- display_scene("ddz.gameScene",1)
            -- if USER_INFO["hasBlueMonthCard"]==1 then--已经购买蓝卡
            --     self:getPoChang()
            -- else
            --     self:showBuyCard()
            -- end
        end)
    else
        self:getPoChang()
        self.panle_pochang:hide();
    end
    
    
    
    
    
    self.linquSuccess=rootNode:getChildByName("Panel_1")
    self.linquSuccess:hide();
     

     local rate=self.linquSuccess:getChildByName("subsidy_effect_light_2")
     rate:runAction(cc.RepeatForever:create(cc.RotateBy:create(0.1,10)))
     
    -- self.buyCard_panle=rootNode:getChildByName("Panel_3")
    -- self.buyCard_panle:hide();
    -- self.noScale=true
    
    -- self:onClick(function()
    --     if self.linquSuccess:isVisible() then

           

    --         if self.get_ok then
    --             require("hall.GameData"):setPlayerRoute("ddz","free",USER_INFO["base_chip"],0)
    --             display_scene("ddz.gameScene",1)
    --         else
    --             self:rtuHall()
    --         end

    --          self:removeSelf();
            
    --     end
    -- end)
    self.get_ok=1
   
end



function userBroke:rtuHall()

    if SCENENOW["name"]~="ddz.gameScene" then --zhangzai youxi zhong 
        return;
    end
    local next = require("app.scenes.MainScene").new()
    SCENENOW["scene"] = next
    SCENENOW["name"] = "app.scenes.MainScene"
    display_scene("app.scenes.MainScene")
end

--显示购买蓝卡
function userBroke:showBuyCard(parameters)
    self.panle_pochang:hide();

    local BuyCard = require("hall.bug_card")
    local buy = BuyCard.new()
    self.buy=buy
    buy:set_content_txt(1) -- 0是红卡，1是蓝卡
    self:addChild(buy)


    -- local gift_6= self.panle_pochang
    
    -- local btn_ok=gift_6:getChildByName("Button_1");
    -- local btn_canle=gift_6:getChildByName("Button_2");


    -- btn_ok:onClick(function()
    --     --调用sdk支付购买蓝卡

    --     --直接调用商城ui支付
    --     local data={}    
    --     if isTest then
    --         data.payType="p";
    --         data.payAmount=6*100
    --         data.coinAmount=1500
    --     end

    --     self:pay_sdk(data.pay_type,data.payAmount,data.coinAmount)


    -- end)

    -- btn_canle:onClick(handler(self,self.getPoChang))
end

function userBroke:getPoChang()
        --
        
        cct.createHttRq({
            url=HttpAddr.."/user/getAllowance",

            date={userId=USER_INFO["uid"]},
            callBack=function(data)
                local data=json.decode(data.netData)
                dump(data,"httpReq")
                print("data.returnCode",data.returnCode)
                if data.returnCode=="0" then--请求破产补助成功
                    --todo
                    --
                    local val=data.data.coinAmountReceived
                    -- require("hall.GameData"):getUserInfo()
                    -- USER_INFO["gold"]=data.data.coinAmountReceived
                    if SCENENOW["scene"] then
                        -- if _G.runScene and _G.runScene.goldUpdate  then
                        --     --todo
                        --     _G.runScene:goldUpdate()
                        -- else
                        --     SCENENOW["scene"]:goldUpdate()
                        -- end

                    end
                    require("hall.HallHttpNet"):viewAccount(0)

                    --self:removeSelf();
                    local txt=self.linquSuccess:getChildByName("Text_5")
                    txt:setString(val.."金币");
                    
                    self.linquSuccess.noScale=true
                    self.linquSuccess:onClick(function()
                        if SCENENOW["name"]=="ddz.gameScene" then --正在游戏中
                            --self.linquSuccess:removeSelf();
                            require("hall.GameData"):setPlayerRoute("ddz","free",USER_INFO["base_chip"],0)
                            display_scene("ddz.gameScene",1)   
                        end
                        self:removeSelf();
                    end)
                    self.panle_pochang:hide();

                    self.linquSuccess:show();
                    
                    if self.callOk then
                        --todo
                        self.callOk("ok");
                    end

                    

                else
                    
                    if USER_INFO["hasBlueMonthCard"]==1 then--已经购买蓝卡
                        --require("hall/GameTips"):showTips("今日破产补助领取完了")
                        self.panle_pochang:hide();
                        --self.get_ok=false
                        

                        if self.callOk then
                            --todo
                            self.callOk("nok");
                        end
                        if self.isShowLinQu and SCENENOW["name"]~="ddz.gameScene" then --正在游戏中
                            local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
                             scheduler.performWithDelayGlobal(function()
                                 -- 返回大厅界面
                                 self:rtuHall();
                                 self:removeSelf();
                             end, 2)
                            
                        else
                            self:removeSelf();
                        end 

                        require("hall.GameTips"):showTips("你的余额已经不足，并且今日破产补助已经领取完毕")
                    else
                        self:showBuyCard()
                    end


                    --self:removeSelf()
                     
 

                end
            end
        })
    
end

function userBroke:pay_sdk(pay_type,payAmount,coinAmount,callBack)
	local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
        print("call pay")
        local args = {payAmount, pay_type, coinAmount}
        local sigs = "(ILjava/lang/String;I)V"

        local luaj = require "cocos.cocos2d.luaj"
        local className = luaJniClass
        local ok,ret  = luaj.callStaticMethod(className,"recharge",args,sigs)
        if not ok then
            print("market_buy__call_back luaj error:", ret)
        end

    elseif (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) or (cc.PLATFORM_OS_MAC == targetPlatform) then
        local args = {}
       
        args["payAmount"] = payAmount
        args["payType"] = pay_type
        args["coinAmount"] =coinAmount

        local luaoc = require "cocos.cocos2d.luaoc"
        local className = "CocosCaller"
        local ok,ret  = luaoc.callStaticMethod(className,"recharge",args)

        if not ok then
            print("market_buy__call_back luaj error:", ret)
        end
    else
        if callBack then
            callBack();
        end
        
    end 
    
end


--goumai 蓝卡 成功
function userBroke:refresh_layout(flag) --1成功 0关闭 -1 失败

    print("refresh_layout",flag)

    
    if flag==-1 then
        self.buy:removeSelf()
    end
    self.buy=nil  

    if flag==1 then
         self:getPoChang()--重新请求破产补助
        USER_INFO["hasBlueMonthCard"]=1
    else
        self:rtuHall();
        self:removeSelf();
    end 
end


return userBroke