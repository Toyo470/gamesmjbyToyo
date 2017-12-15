--
-- Author: Zeng Tao
-- Date: 2017-04-21 14:35:59
--


local dlTips=class("dlTips",function ()
	-- body
	return cc.Scene:create();
end)



local WinSize=cc.Director:getInstance():getWinSize()



function dlTips:ctor( ... )
	-- body


	dump(WinSize)



	local layout=ccui.Layout:create()
    layout:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid);
    layout:setBackGroundColor(cc.c3b(0,0,0));
    layout:setBackGroundColorOpacity(128)
    layout:setContentSize(cc.size(960,540))
    layout:setPosition(cc.p(WinSize.width/2,WinSize.height/2));

    
    self:addChild(layout)

    layout:onClick(function ( ... )
    	-- body
    	self:removeSelf()
    end)



	local sp_bg=cc.Sprite:create("hall/dlTip/bg.png");
	self:addChild(sp_bg)
	sp_bg:setPosition(cc.p(WinSize.width/2,WinSize.height/2));


	self:showtext()
end

function dlTips:showtext( ... )
	-- body

	local text={
		"0000",
		"0001",
		"0002",
	}

	local text2={
		"购卡咨询:",
		"代理招募:",
		"公众号:   ",
	}

	local text3={
		"[微信号]",
		"[微信号]",
		"[微信号]",
	}
	local startX=WinSize.width/2
	local StartY=WinSize.height/2
	for i=1,3 do
		local label = display.newTTFLabel({
		    text = text2[i]..text[i],
		    font = "Arial",
		    size = 40,
		    color = cc.c3b(255, 128, 0), -- 使用纯红色
		
		})

		label:setAnchorPoint(cc.p(0,0.5));
		self:addChild(label)

		local _y=(i-1)*(40+40)*-1
		label:setPosition(cc.p(startX-270,StartY+50+_y));
		

	

		local label2 = display.newTTFLabel({
		    text = text3[i],
		    font = "Arial",
		    size = 20,
		    color = cc.c3b(255, 128, 0), -- 使用纯红色

		})
		self:addChild(label2)

		label2:setPosition(cc.p(startX+120,StartY+50+_y))


		local btn=ccui.ImageView:create("hall/dlTip/copy.png");
		self:addChild(btn)
		btn.text=text[i]
		btn:setPosition(cc.p(startX+150+80,StartY+50+_y))

		btn:onClick(function ( b )
			-- body
			local t=b.text
			if device.platform=="android" then
				cct.getDateForApp("copyClips",{t},"V");
			end
		end)

	end
end


return dlTips;