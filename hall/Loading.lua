
local Loading = class("Loading")

--显示加载圈
function Loading:showLoading()

	if SCENENOW["scene"] then

		--释放之前的
        local s = SCENENOW["scene"]:getChildByName("loading")
        if s then
            s:removeSelf()
        end

        --添加加载圈
        s = cc.CSLoader:createNode("hall/common/Loading.csb")
        s:setName("loading")
        SCENENOW["scene"]:addChild(s,99999)

        --获取加载圈图片
        local loading_im = s:getChildByName("loading_ly"):getChildByName("loading_im")

        --旋转加载圈
        
        
	end

end

--隐藏加载圈
function Loading:hideLoading()

	if SCENENOW["scene"] then

		--释放之前的
        local s = SCENENOW["scene"]:getChildByName("loading")
        if s then
            s:removeSelf()
        end

	end

end

cct.showLoadingTip= Loading:showLoading()

return Loading