--
-- Author: Your Name
-- Date: 2017-04-02 15:45:43
--
local targetPlatform = cc.Application:getInstance():getTargetPlatform()
local GameUpdateLoading = class("GameUpdateLoading")




function GameUpdateLoading:updateLoading()  --更新时点击其他地方弹出来的正在更新提示框
    if SCENENOW['scene']:getChildByName("update_loading") then
        SCENENOW['scene']:removeChildByName("update_loading")
    end
    if SCENENOW['scene'] then
        self.update_loading = cc.CSLoader:createNode("hall/tips/Update_Loading.csb")
        local update_loading=self.update_loading
        update_loading:setName("update_loading")
        local LoadingLaylout =update_loading:getChildByName("Image_2")
        local LoadingBar_01=LoadingLaylout:getChildByName("LoadingBar_1")
        local loading_txt=LoadingLaylout:getChildByName("Text_4")
        local a= 100
        loading_txt:setString(tostring(a).."%")
        LoadingBar_01:setPercent(a)     
        SCENENOW["scene"]:addChild(update_loading,99999)
        
    end

end
function GameUpdateLoading:setpercent(percent)
	-- body
	if SCENENOW['scene']:getChildByName("update_loading") then
		local update_loading=self.update_loading
		local LoadingLaylout =update_loading:getChildByName("Image_2")
        local LoadingBar_01=LoadingLaylout:getChildByName("LoadingBar_1")
        local loading_txt=LoadingLaylout:getChildByName("Text_4")
        if percent>100 then
        	percent=100
        end
        local a=percent or 100
        loading_txt:setString(tostring(a).."%")
        LoadingBar_01:setPercent(a)
	end

end
return GameUpdateLoading
