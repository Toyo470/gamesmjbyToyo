
local NetworkLoadingView = class("NetworkLoadingView")

function NetworkLoadingView:showLoading(msg)

	if SCENENOW["scene"] then

		--释放之前的
        local s = SCENENOW["scene"]:getChildByName("NetworkLoadingView")
        if s then
            s:removeSelf()
        end

        s = cc.CSLoader:createNode("hall/NetworkLoadingView/NetworkLoadingLayer.csb")
        s:setName("NetworkLoadingView")

        local load_iv = s:getChildByName("load_iv")
        local actionBy = cc.RotateBy:create(2 , 360)
	    load_iv:runAction(cc.RepeatForever:create(actionBy))

        local load_tt = s:getChildByName("load_tt")
        load_tt:setString(msg)
        local x = 1
        load_tt:runAction(cc.RepeatForever:create(

        	cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function()

	        	local s = SCENENOW["scene"]:getChildByName("NetworkLoadingView")
	        	if s then
	        		local load_tt = s:getChildByName("load_tt")
		        	if x == 1 then
		        		load_tt:setString(msg)
		        	elseif x == 2 then
		        		load_tt:setString(msg .. ".")
		        	elseif x == 3 then
		        		load_tt:setString(msg .. "..")
		        	elseif x == 4 then
		        		load_tt:setString(msg .. "...")
		        	end
	        	end

	        	x = x + 1

	        	if x == 5 then
	        		x = 1
	        	end

	        end))

        ))

        SCENENOW["scene"]:addChild(s,99999)

	end

end

function NetworkLoadingView:removeView()

	if SCENENOW["scene"] then

		--释放之前的
        local s = SCENENOW["scene"]:getChildByName("NetworkLoadingView")
        if s then
            s:removeSelf()
        end

	end
	
end

return NetworkLoadingView