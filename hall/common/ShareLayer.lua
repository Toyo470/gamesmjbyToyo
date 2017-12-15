local ShareLayer = class("ShareLayer")

--微信分享下载页面
function ShareLayer:showShareLayerInHall(title, url, imagePath, desc)

    print(SCENENOW["name"],"///////////////////////////////////////////")
    title = "【789广东麻将】汇聚各地麻将一体，内含斗牛、斗地主、炸金花等扑克类游戏，公测福利送不停！"
    url = "http://download.789youxi.com"

    local scene = cc.CSLoader:createNode("hall/common/shareLayer.csb"):addTo(SCENENOW["scene"])
    scene:setName("shareLayer")
    scene:setLocalZOrder(9999)

    local floor = scene:getChildByName("floor")
    local wx_bt = floor:getChildByName("wx_bt")
    local pyq_bt = floor:getChildByName("pyq_bt")

    floor.noScale=true
    floor:onClick(function()
        scene:removeFromParent()
    end)
        
    local function touchEvent(sender, event)
        if event == TOUCH_EVENT_CANCELED then
            sender:setScale(1.0)
        end

        if event == TOUCH_EVENT_ENDED then
            sender:setScale(1.0)
            require("hall.GameCommon"):playEffectSound("hall/Audio_Button_Click.mp3")

            if sender == wx_bt then
                print("share wx")
                local args = {}
                args["channel"] = "wx"
                args["title"] = title
                if url ~= nil then
                    --todo
                    args["url"] = url
                end
        
                if imagePath ~= nil then
                    --todo
                    args["imagePath"] = imagePath
                end
                args["desc"] = desc

                if device.platform=="android" then
                    local share_content = {}
                    table.insert(share_content,"wx")
                    table.insert(share_content,title)
                    if url ~= nil then
                        table.insert(share_content,url)
                    else
                        table.insert(share_content,"")
                    end
                    if imagePath ~= nil then
                        table.insert(share_content,imagePath)
                    else
                        table.insert(share_content,"")
                    end
                    table.insert(share_content,desc)
                    cct.getDateForApp("share", share_content, "V")
                else
                    cct.getDateForApp("share", args, "V")
                end

                scene:removeFromParent()
                

            elseif sender == pyq_bt then
                print("share pyq")
                local args = {}
                args["channel"] = "pyq"
                args["title"] = title
                if url ~= nil then
                    --todo
                    args["url"] = url
                end
                
                if imagePath ~= nil then
                    --todo
                    args["imagePath"] = imagePath
                end
                args["desc"] = desc

                if device.platform=="android" then
                    local share_content = {}
                    table.insert(share_content,"pyq")
                    table.insert(share_content,title)
                    if url ~= nil then
                        table.insert(share_content,url)
                    else
                        table.insert(share_content,"")
                    end
                    if imagePath ~= nil then
                        table.insert(share_content,imagePath)
                    else
                        table.insert(share_content,"")
                    end
                    table.insert(share_content,desc)
                    cct.getDateForApp("share", share_content, "V")
                else
                    cct.getDateForApp("share", args, "V")
                end

                scene:removeFromParent()

            end
        end
    end

    wx_bt:addTouchEventListener(touchEvent)
    pyq_bt:addTouchEventListener(touchEvent)
end

-- 微信分享魔窗页面
function ShareLayer:showShareLayer(title, url, imagePath, desc, sender_btn,isHistory)
    
    print(SCENENOW["name"],"///////////////////////////////////////////")
    if isHistory then
        url = "https://a.mlinks.cc/AKmX?invitationCode=0&activityId=0&level=0"
    else
        url = "https://a.mlinks.cc/AKmX?invitationCode=" .. USER_INFO["invote_code"] .. "&activityId=" .. USER_INFO["activity_id"] .. "&level=" .. USER_INFO["GroupLevel"]
    end


	local scene = cc.CSLoader:createNode("hall/common/shareLayer.csb"):addTo(SCENENOW["scene"])
	scene:setName("shareLayer")
    scene:setLocalZOrder(9999)

	local floor = scene:getChildByName("floor")
	local wx_bt = floor:getChildByName("wx_bt")
	local pyq_bt = floor:getChildByName("pyq_bt")

	floor.noScale=true
	floor:onClick(function()
		scene:removeFromParent()
        if sender_btn then
            sender_btn:setTouchEnabled(true)
        end
	end)
		
	local function touchEvent(sender, event)
        if event == TOUCH_EVENT_CANCELED then
            sender:setScale(1.0)
        end

        if event == TOUCH_EVENT_ENDED then
            sender:setScale(1.0)
            require("hall.GameCommon"):playEffectSound("hall/Audio_Button_Click.mp3")
    

            if sender == wx_bt then
                print("share wx")
				local args = {}
    			args["channel"] = "wx"
    			args["title"] = title
    			
                if url ~= nil then
                    -- 点了分享导致报错，HistoryLayer 495 USER_INFO未更新
                    if USER_INFO["invote_code"] and USER_INFO["activity_id"] and USER_INFO["GroupLevel"] then
                        args["url"] = url
                    end
                end
    	
    			if imagePath ~= nil then
    				--todo
    				args["imagePath"] = imagePath
    			end
    			args["desc"] = desc

    			if device.platform=="android" then
    				local share_content = {}
    				table.insert(share_content,"wx")
    				table.insert(share_content,title)
    				
                    if url ~= nil then
                        table.insert(share_content,url)
                    else
                        table.insert(share_content,"")
                    end

    				if imagePath ~= nil then
	    				table.insert(share_content,imagePath)
	    			else
	    				table.insert(share_content,"")
    				end
    				table.insert(share_content,desc)
    				cct.getDateForApp("share", share_content, "V")
                    -- 开放分享按钮
                    if sender_btn then
                        sender_btn:setTouchEnabled(true)
                    end
    			else
    				cct.getDateForApp("share", args, "V")
    			end

				scene:removeFromParent()

            elseif sender == pyq_bt then
                print("share pyq")
				local args = {}
		    	args["channel"] = "pyq"
		    	args["title"] = title
		    	
                if url ~= nil then
                    args["url"] = url
                end
		    	
		    	if imagePath ~= nil then
		    		--todo
		    		args["imagePath"] = imagePath
		    	end
		    	args["desc"] = desc

		    	if device.platform=="android" then
    				local share_content = {}
    				table.insert(share_content,"pyq")
    				table.insert(share_content,title)
    				
                    if url ~= nil then
                        table.insert(share_content,url)
                    else
                        table.insert(share_content,"")
                    end
                    
    				if imagePath ~= nil then
	    				table.insert(share_content,imagePath)
	    			else
	    				table.insert(share_content,"")
    				end
    				table.insert(share_content,desc)
    				cct.getDateForApp("share", share_content, "V")
                    -- 开放分享按钮
                    if sender_btn then
                        sender_btn:setTouchEnabled(true)
                    end
    			else
    				cct.getDateForApp("share", args, "V")
    			end

				scene:removeFromParent()

            end
        end
    end

    wx_bt:addTouchEventListener(touchEvent)
    pyq_bt:addTouchEventListener(touchEvent)
end

function ShareLayer:shareGroupResultForIOS(sender_btn)

    local scene = cc.CSLoader:createNode("hall/common/shareLayer.csb"):addTo(SCENENOW["scene"])
    scene:setName("shareLayer")
    scene:setLocalZOrder(9999)

    local floor = scene:getChildByName("floor")
    local wx_bt = floor:getChildByName("wx_bt")
    local pyq_bt = floor:getChildByName("pyq_bt")

    floor.noScale=true
    floor:onClick(function()
        scene:removeFromParent()
        if sender_btn then
            sender_btn:setTouchEnabled(true)
        end
    end)
        
    local function touchEvent(sender, event)
        if event == TOUCH_EVENT_CANCELED then
            sender:setScale(1.0)
        end

        if event == TOUCH_EVENT_ENDED then
            sender:setScale(1.0)
            require("hall.GameCommon"):playEffectSound("hall/Audio_Button_Click.mp3")

            if sender == wx_bt then
                print("share wx")
                local args = {}
                args["channel"] = "wx"
                args["title"] = "我的战果"
                if url ~= nil then
                    --todo
                    args["url"] = url
                end
        
                args["desc"] = "快来一起玩吧"

                print("luaCall 截屏",png_name)
                local function afterCaptured(succeed,sp_png)
                    if succeed then
                        print("截屏success",sp_png)
                        args["imagePath"] = sp_png
                        cct.getDateForApp("shareGroupResult", args, "V")
                        if sender_btn then
                            sender_btn:setTouchEnabled(true)
                        end
                    end
                end
                cc.utils:captureScreen(afterCaptured,"gameScreen.png")

                scene:removeFromParent()
                

            elseif sender == pyq_bt then
                print("share pyq")
                local args = {}
                args["channel"] = "pyq"
                args["title"] = "我的战果"
                if url ~= nil then
                    --todo
                    args["url"] = url
                end
        
                args["desc"] = "快来一起玩吧"

                print("luaCall 截屏",png_name)
                local function afterCaptured(succeed,sp_png)
                    if succeed then
                        print("截屏success",sp_png)
                        args["imagePath"] = sp_png
                        cct.getDateForApp("shareGroupResult", args, "V")
                        if sender_btn then
                            sender_btn:setTouchEnabled(true)
                        end
                    end
                end
                cc.utils:captureScreen(afterCaptured,"gameScreen.png")

                scene:removeFromParent()
                if sender then
                    sender:setTouchEnabled(true)
                end
            end
        end
    end

    wx_bt:addTouchEventListener(touchEvent)
    pyq_bt:addTouchEventListener(touchEvent)

    
end

function hideShareLayer()
	singleton:removeFromParent()
end
	
return ShareLayer