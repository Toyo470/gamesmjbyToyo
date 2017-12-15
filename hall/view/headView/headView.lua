
local headView = class("headView")

local userInfo_arr = {}

function headView:addView(view, x, y, width, height, url, userInfo)

	x = x or 0
	y = y or 0
	width = width or 100
	height = height or 100
	url = url or ""

	if view then
		
		local s = view:getChildByName("headView")
	    if s then
	        s:removeSelf()
	    end

        if device.platform == "ios" then
            if isiOSVerify then
                s = cc.CSLoader:createNode("hall/view/headView/headView_Layer_168.csb")
            else
            s = cc.CSLoader:createNode(cc.FileUtils:getInstance():getWritablePath() .. "hall/view/headView/headView_Layer_168.csb")
            end
        else
            s = cc.CSLoader:createNode("hall/view/headView/headView_Layer_168.csb")
        end
        
    	s:setName("headView")
    	s:setAnchorPoint(0, 1)
    	s:setPosition(x, y)
    	view:addChild(s)

    	local root_ly = s:getChildByName("root_ly")
    	root_ly:setTouchEnabled(true)
    	root_ly:setScale(width / root_ly:getContentSize().width, height / root_ly:getContentSize().width)

    	--设置头像
    	local head_iv = root_ly:getChildByName("head_iv")
        head_iv:loadTexture("hall/view/headView/image/blank.png")

        --创建裁切蒙版
        local spStnecil = display.newSprite("hall/view/headView/image/stencil.png")
        local stencil = cc.Node:create()
        stencil:addChild(spStnecil)

        --添加裁切节点
        local clipnode = cc.ClippingNode:create()
        clipnode:setAnchorPoint(0.5, 0.5)
        clipnode:setScale(1.3)
        clipnode:setPosition(head_iv:getContentSize().width / 2, head_iv:getContentSize().height / 2)
        clipnode:setInverted(false)
        clipnode:setAlphaThreshold(0)
        clipnode:setStencil(stencil)
        head_iv:addChild(clipnode)

    	if url ~= "" then
            local content = display.newSprite(url)
            content:setScale((width / content:getContentSize().width) * 0.9, (height / content:getContentSize().height) * 0.9)
            clipnode:addChild(content)
    	end

    	--设置点击事件
    	if userInfo then

    		userInfo_arr[userInfo["uid"]] = userInfo

    		root_ly:addTouchEventListener(
                function(sender,event)

                    if event == TOUCH_EVENT_BEGAN then

                    end

                    --触摸取消
                    if event == TOUCH_EVENT_CANCELED then

                    end

                    --触摸结束
                    if event == TOUCH_EVENT_ENDED then

                        if userInfo["isShowInGame"] then

                            local location_arr = {}

                            --获取当前在游戏中的所有玩家的经纬度
                            for k,v in pairs(userInfo_arr) do

                                local invote_code = v["invote_code"]
                                local x = 1
                                if invote_code then

                                    --判断用户是否在当前用户所在的组局
                                    if invote_code == USER_INFO["invote_code"] then

                                        if v["Latitude"] and v["Longitude"] then

                                            local a = {}
                                            a["uid"] = v["uid"]
                                            a["nickName"] = v["nickName"]
                                            a["latitude"] = v["Latitude"]
                                            a["longitude"] = v["Longitude"]

                                            table.insert(location_arr, a)

                                        end

                                    end

                                end

                            end

                            if #location_arr > 0 then
                                userInfo_arr[userInfo["uid"]]["location_arr"] = location_arr
                            end
                            
                        end

                        require("hall.view.userInfoView.userInfoView"):showView(url, userInfo_arr[userInfo["uid"]])
                        
                    end

                end
            )

    		-- userInfo["uid"] = ""
    		-- userInfo["nickName"] = ""
    		-- userInfo["ip"] = ""
    		-- userInfo["longitude"] = 0
    		-- userInfo["latitude"] = 0
    		-- userInfo["isShowInGame"] = true
    		-- userInfo["location_arr"] = {
    		-- 	{"nickName": "玩家1", "longitude": 0, "latitude": "0"},
    		-- 	{"nickName": "玩家2", "longitude": 0, "latitude": "0"},
    		-- 	{"nickName": "玩家3", "longitude": 0, "latitude": "0"},
    		-- }
    		
    	end

	end

end

--更新用户数据
function headView:updateUserInfo(userInfo)
	userInfo_arr[userInfo["uid"]] = userInfo
end

--更新用户ip
function headView:updateUserInfoForIp(uid, ip)
    userInfo_arr[uid]["ip"] = ip
end

--更新用户经纬度
function headView:updateUserInfoForLocation(uid, invote_code, lat, lng)
    userInfo_arr[uid]["invote_code"] = invote_code
    userInfo_arr[uid]["Latitude"] = lat
    userInfo_arr[uid]["Longitude"] = lng
end

--检查图片格式
function headView:getUrlPicture(url)
    -- body
    if url == "" or url == nil then
        return ""
    end
    -- dump(url,"getUrlPicture")
    local strLower = string.lower(url)
    if string.find(strLower,".jpg") == nil and string.find(strLower,".png") == nil then
        return self:getUnformatPic(url)
    end
    local strUrl = string.reverse(url)
    local nPos = string.find(strUrl,"/")
    local strPic = string.sub(strUrl,1,nPos-1)
    strPic = string.reverse(strPic)
    -- print("getUrlPicture:",strPic)
    return strPic
end

--获取非格式化图片名称
function headView:getUnformatPic(url)
    local strUrl = string.reverse(url)
    local nPos = string.find(strUrl,"/")
    strUrl = string.sub(strUrl,nPos+1,string.len(strUrl))
    nPos = string.find(strUrl,"/")
    local strPic = string.sub(strUrl,1,nPos-1)
    strPic = string.reverse(strPic)
    -- print("getUnformatPic:",strPic)
    return strPic..".jpg"
end

function headView:removeView(view)

	local s = view:getChildByName("headView")
    if s then
        s:removeSelf()
    end

end

return headView