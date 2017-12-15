local Recharge = class("Recharge")

function Recharge:call_recharge( price,pay_type,amount )
    -- body
    print("call_recharge",tostring(price),tostring(pay_type),tostring(amount))
    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
        print("call pay")
        local args = {price, pay_type, amount}
        local sigs = "(ILjava/lang/String;I)V"

        local luaj = require "cocos.cocos2d.luaj"
        local className = luaJniClass
        local ok,ret  = luaj.callStaticMethod(className,"recharge",args,sigs)
        if not ok then
            print("market_buy__call_back luaj error:", ret)
        end

    elseif (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) or (cc.PLATFORM_OS_MAC == targetPlatform) then
        local args = {}
        local tem_price = tonumber(price * 100)
        args["payAmount"] = tem_price
        args["payType"] = pay_type
        args["coinAmount"] = amount

        local luaoc = require "cocos.cocos2d.luaoc"
        local className = "CocosCaller"
        local ok,ret  = luaoc.callStaticMethod(className,"recharge",args)

        if not ok then
            print("market_buy__call_back luaj error:", ret)
        end
    else
    end 
end

return Recharge
