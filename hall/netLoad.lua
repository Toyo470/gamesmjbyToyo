--
-- Author: Your Name
-- Date: 2016-10-31 15:00:11
--
cct=cct or {}


cct.showLoading=function()
	local load=cc.Sprite:create("hall/common/loading01.png")

	SCENENOW["scene"]:addChild(load)
	load:setName("loading")
	local ac=cc.RotateBy:create(0.3,100)
	load:runAction(cc.RepeatForever:create(ac))
	load:setPosition(960/2,540/2)
end


cct.showLoadingTip=function(msg)
    local view = cc.CSLoader:createNode("hall/loading.csb"):addTo(SCENENOW["scene"])
    local load=view:getChildByName("loading01_1")
    local ac=cc.RotateBy:create(0.3,100)
	load:runAction(cc.RepeatForever:create(ac))
	load:setPosition(960/2,540/2)


	view:setName("loading")
end