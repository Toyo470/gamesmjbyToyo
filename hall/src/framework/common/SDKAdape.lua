

-- 这里不应该放在框架里面，本应该放在工具分类里面
-- 有时间再归类下，请谅解
local SDKAdape = {}

local ios_class_name = "SDKAdape"
local jni_class_name = "com/cocos2dx/sample/LuaJavaBridgeTest/LuaJavaBridgeTest"

function SDKAdape.callAppMethod(method, args, sig)

    if type(method) ~= "string" then
        return
    end

    local ok,ret
    if device.platform == "ios" then

    	local className = ios_class_name
        local luaoc = require "cocos.cocos2d.luaoc"

        if table.nums(args) > 0 then
            ok, ret  = luaoc.callStaticMethod(className, method, args)
        else
            ok, ret  = luaoc.callStaticMethod(className, method)
        end
        
    elseif device.platform == "android" then
        
        local args =args or {}
        local luaj = require "cocos.cocos2d.luaj"
        local className = jni_class_name

         local sigs="("
         for k,v in pairs(args) do
             local t=type(v)
             if t=="string" then
                 sigs=sigs.."Ljava/lang/String;"
             elseif t=="number" or t=="function" then
                 sigs=sigs.."I"
             end
         end
         sigs=sigs..")"
         sigs=sigs..sig


        ok, ret = luaj.callStaticMethod(className, method, args, sigs)
    end

    return ok, ret
end

-- 支付宝支付
function SDKAdape.onAlipayPay(args, sig)
	local method_name = "onAlipayPay"
	return SDKAdape.callAppMethod(method_name, args, sig)
end

-- 微信支付
function SDKAdape.onWechatPay(args, sig)
    local method_name = "onWxPay"
    return SDKAdape.callAppMethod(method_name, args, sig)
end

-- 统计
function SDKAdape.onLoginSuccess(gameid)
    local method_name = "onLoginSuccess"
    local args = { gameid = tostring(gameid) }
    -- 只有ios接了talkingData
    if device.platform == "ios" then
        SDKAdape.callAppMethod(method_name, args, "V") 
    end
end

rawset(_G, "SDKAdape", SDKAdape)