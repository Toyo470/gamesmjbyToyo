
local userInfoView = class("userInfoView")

local userInfo_arr = {}

function userInfoView:showView(url, userInfo)
    dump(userInfo,"userInfo")
	if userInfo == nil then
		return
	end

	if SCENENOW["scene"] then

		local s = SCENENOW["scene"]:getChildByName("userInfoView")
	    if s then
	        s:removeSelf()
	    end

	    if userInfo["isShowInGame"] then
            if device.platform == "ios" then
                if isiOSVerify then
                    s = cc.CSLoader:createNode("hall/view/userInfoView/userInfoView_game_Layer.csb")
                else
                    s = cc.CSLoader:createNode(cc.FileUtils:getInstance():getWritablePath() .. "hall/view/userInfoView/userInfoView_game_Layer.csb")
                end
            else
                s = cc.CSLoader:createNode("hall/view/userInfoView/userInfoView_game_Layer.csb")
            end
	    else
            if device.platform == "ios" then
                if isiOSVerify then
                    s = cc.CSLoader:createNode("hall/view/userInfoView/userInfoView_nomal_Layer.csb")
                else
                    s = cc.CSLoader:createNode(cc.FileUtils:getInstance():getWritablePath() .. "hall/view/userInfoView/userInfoView_nomal_Layer.csb")
                end
            else
                s = cc.CSLoader:createNode("hall/view/userInfoView/userInfoView_nomal_Layer.csb")
            end
	    end

    	s:setName("userInfoView")
    	SCENENOW["scene"]:addChild(s, 10000)

    	local bg_ly = s:getChildByName("Panel_1")
    	bg_ly:setTouchEnabled(true)
    	bg_ly:addTouchEventListener(
                function(sender,event)

                    if event == TOUCH_EVENT_BEGAN then
                    	
                    end

                    --触摸取消
                    if event == TOUCH_EVENT_CANCELED then

                    end

                    --触摸结束
                    if event == TOUCH_EVENT_ENDED then
                        self:removeView()
                    end

                end)

    	local root_ly = s:getChildByName("root_ly")
        root_ly:setPosition(cc.p(480, 270))
    	root_ly:setTouchEnabled(true)
    	root_ly:addTouchEventListener(
            function(sender,event)

                if event == TOUCH_EVENT_BEGAN then
                	
                end

                --触摸取消
                if event == TOUCH_EVENT_CANCELED then

                end

                --触摸结束
                if event == TOUCH_EVENT_ENDED then
                    self:removeView()
                end

            end)

        local head_ly = root_ly:getChildByName("head_ly")
        require("hall.view.headView.headView"):addView(head_ly, 50, -55, 80, 80, url)


        local id_tt = root_ly:getChildByName("id_tt")
        -- id_tt:setAnchorPoint(cc.p(0,0.5))
        if userInfo["uid"] then
        	id_tt:setString("ID:" .. userInfo["uid"])
        end

        --在游戏中显示
        if bm.isInGame then
            dump(userInfo_arr, "userInfo_arr----------------------------------------------------")

            local distance_sv = root_ly:getChildByName("distance_sv")
            local content_ly = distance_sv:getChildByName("content_ly")

            --获取房间中的玩家地理位置
            local location_arr = {}
            for k,v in pairs(userInfo_arr) do
                if v.invote_code == USER_INFO["invote_code"] then
                    table.insert(location_arr, v)
                end
            end

            if #location_arr > 0 then

                local count = 0
                local isCompare_arr = {}
                for k,v in pairs(location_arr) do
                        
                    --获取当前用户的id
                    local uid = v["uid"]
                    

                    if tonumber(uid) == tonumber(userInfo["uid"]) then
                        -- root_ly:getChildByName("name_tt"):setString(v["nickName"])  --设置昵称
                        local txt_nick = root_ly:getChildByName("name_tt")
                        if txt_nick then
                            txt_nick:setString("昵称:"..v["nickName"])
                        end
                        root_ly:getChildByName("ip_tt"):setString("IP:" .. (v["ip"] or "0.0.0.0")) --设置IP
                    end

                    if tonumber(uid) ~= tonumber(USER_INFO["uid"]) then

                        --获取当前用户的经纬度
                        local latitude = v["latitude"]
                        if latitude == nil then
                            latitude = ""
                        end
                        if latitude == "" then
                            latitude = "0"
                        end
                        latitude = tonumber(latitude)

                        local longitude = v["longitude"]
                        if longitude == nil then
                            longitude = ""
                        end
                        if longitude == "" then
                            longitude = "0"
                        end
                        longitude = tonumber(longitude)


                        if latitude ~= 0 and longitude ~= 0 then

                            dump("用户有经纬度信息", "----------")

                            for a,b in pairs(location_arr) do

                                local b_uid = b["uid"]

                                local b_latitude = b["latitude"]
                                if b_latitude == nil then
                                    b_latitude = ""
                                end
                                if b_latitude == "" then
                                    b_latitude = "0"
                                end
                                b_latitude = tonumber(b_latitude)

                                local b_longitude = b["longitude"]
                                if b_longitude == nil then
                                    b_longitude = ""
                                end
                                if b_longitude == "" then
                                    b_longitude = "0"
                                end
                                b_longitude = tonumber(b_longitude)

                                local b_nickName
                                if tonumber(b_uid) == tonumber(USER_INFO["uid"]) then
                                    b_nickName = "我"
                                else
                                    b_nickName = b["nickName"]
                                end

                                --判断当前用户之前是否已经比较
                                local isCompare = 0
                                for q,w in pairs(isCompare_arr) do
                                    if w == b_uid then
                                        isCompare = 1
                                    end
                                end

                                print(v.uid, b.uid, "正在进行比较")
                                if v.uid ~= b.uid then
                                    --当前用户未进行比较
                                    if isCompare == 0 then
                                        local distanceLayer
                                        if device.platform == "ios" then
                                            distanceLayer = cc.CSLoader:createNode("hall/view/userInfoView/distanceLayer.csb")
                                        else
                                            distanceLayer = cc.CSLoader:createNode("hall/view/userInfoView/distanceLayer.csb")
                                        end
                                        distanceLayer:setScale(0.8)
                                        distanceLayer:setPosition(10, 30 * count * -1)

                                        local root_ly = distanceLayer:getChildByName("root_ly")
                                        local distance_tt = root_ly:getChildByName("distance_tt")

                                        if b_latitude ~= 0 and b_longitude ~= 0 then
                                            local s = require("hall.util.LocationUtil"):getDistance(latitude, longitude, b_latitude, b_longitude)
                                            if s >= 0 then

                                                content_ly:addChild(distanceLayer)
                                                count = count + 1

                                                if s < 1000 then
                                                    distance_tt:setString(self:formatName(v.nickName) .. "与" .. self:formatName(b_nickName) .. "相距" .. tostring(s) .. "米")
                                                else
                                                    s = s / 1000
                                                    s = math.floor(s)
                                                    distance_tt:setString(self:formatName(v.nickName) .. "与" .. self:formatName(b_nickName) .. "相距" .. tostring(s) .. "千米")
                                                end
                                            end
                                        end
                                    else
                                        dump(b["uid"], "-----isCompare_arr-----当前用户已比较")
                                    end
                                end
                            end
                        else

                            local txt_distance = root_ly:getChildByName("distance")
                            if txt_distance then
                                txt_distance:setString("玩家IP")
                            end
                            print(uid, USER_INFO["uid"], v.nickName)
                            dump("用户无经纬度信息", "----------")

                            local distanceLayer
                            if device.platform == "ios" then
                                distanceLayer = cc.CSLoader:createNode("hall/view/userInfoView/distanceLayer.csb")
                            else
                                distanceLayer = cc.CSLoader:createNode("hall/view/userInfoView/distanceLayer.csb")
                            end
                            distanceLayer:setScale(0.8)
                            content_ly:addChild(distanceLayer)

                            distanceLayer:setPosition(10, 30 * count * -1)

                            count = count + 1

                            local root_ly = distanceLayer:getChildByName("root_ly")
                            local distance_tt = root_ly:getChildByName("distance_tt")
                            distance_tt:setString(self:formatName(v["nickName"]) .. ":" .. require("hall.GameData"):getUserIP(v["uid"]))
                        end
                        table.insert(isCompare_arr, uid)
                    end
                end

                distance_sv:setCascadeOpacityEnabled(true)
                distance_sv:setInnerContainerSize(cc.size(283, 30 * count))
                if count > 2 then
                    content_ly:setPosition(0, 30 * count)
                end
            end
        else
            print(USER_INFO['proxyId'],"ssssssssssssssss")
            local txt_nick = root_ly:getChildByName("name_tt")
            if txt_nick then
                txt_nick:setString("昵称:"..USER_INFO["nick"])
            end
            local txt_ip = root_ly:getChildByName("ip_tt")
            if txt_ip then
                txt_ip:setVisible(false)
            end
            if USER_INFO['proxyId'] then
                if txt_ip then
                    txt_ip:setString("代理ID："..USER_INFO['proxyId'])
                    txt_ip:setVisible(true)
                end
                -- local proxyId = cc.Label:createWithTTF("代理ID："..USER_INFO['proxyId'],"res/fonts/fzcy.ttf",24)
                -- proxyId:setColor(cc.c3b(160, 50, 30))
                -- proxyId:setAnchorPoint(cc.p(0,0.5))
                -- proxyId:setName("proxyId")
                -- root_ly:addChild(proxyId)
                -- proxyId:setPosition(id_tt:getPositionX(),id_tt:getPositionY()+30)

            end
        end
        -- dump(require("hall.util.LocationUtil"):getDistance(29.490295, 106.486654, 29.615467, 106.581515), "-----经纬度计算-----")
	end
end

function userInfoView:upDateUserInfo(uid, info)

    userInfo_arr[uid] = info

    dump(userInfo_arr, "-----userInfoView 当前缓存的用户数据-----")

end

function userInfoView:removeView()

	local s = SCENENOW["scene"]:getChildByName("userInfoView")
    if s then
        s:removeSelf()
    end

end

--获取经纬度,并发送到游戏服 --0x165
function userInfoView:sendUserPosition(ip)
    local latitude = "0.00"
    local longitude = "0.00"

    if device.platform == "ios" then

        latitude = cct.getDataForApp("getLatitude", {}, "string")
        longitude = cct.getDataForApp("getLongitude", {}, "string")

    elseif device.platform == "android" then

        local args = {}
        local sigs = "()Ljava/lang/String;"
        local luaj = require "cocos.cocos2d.luaj"
        local className = luaJniClass

        ok,ret  = luaj.callStaticMethod(className,"getLongitude",args,sigs)
        if not ok then
            print("luaj error:", ret)
        else
            longitude = ret
        end

        ok,ret  = luaj.callStaticMethod(className,"getLatitude",args,sigs)
        if not ok then
            print("luaj error:", ret)
        else
            latitude = ret
        end
    end
    
    local msg={}
    msg["ip"] = ip
    msg["uid"] =  tonumber(USER_INFO["uid"])
    msg["nickName"] =  USER_INFO["nick"]
    msg["latitude"] =  latitude
    msg["longitude"] = longitude
    msg["invote_code"] = USER_INFO["invote_code"]
    msg = json.encode(msg)

    dump(msg,"0x165")
    if bm.forward_msg_flag then
        dump(bm.forward_msg_flag,"forward_msg_flag")
    end
    if bm.forward_msg_flag and bm.forward_msg_flag["invote_code"] and bm.forward_msg_flag["invote_code"] == USER_INFO["invote_code"] then
        return
    else
        if bm.server then
            bm.forward_msg_flag = {}
            bm.forward_msg_flag["invote_code"] = USER_INFO["invote_code"]

            print("0x165------------向服务器发送向组局里发送的文字信息")
            if USER_INFO["GroupLevel"] then
                local pack = bm.server:createPacketBuilder(0x165) --向服务器发送向组局里发送的文字信息
                :setParameter("level", tonumber(USER_INFO["GroupLevel"]))
                :setParameter("msg", msg)
                :build()

                bm.server:send(pack)
            end
        end
    end
end

function userInfoView:formatName( name )
    return require("hall.GameCommon"):formatNick(name, 5)
end

return userInfoView