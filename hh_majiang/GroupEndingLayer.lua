local GroupEndingLayer = class("GroupEndingLayer")

--显示一局结算的结算界面
function GroupEndingLayer:showGroupResult(pack)

	dump(pack, "-----一局结算信息-----")
	dump(ZZMJ_ROOM, "显示房间信息")

	--获取总结算界面
    local s = cc.CSLoader:createNode("zz_majiang/GameResult.csb")
    SCENENOW["scene"]:addChild(s)

    --退出按钮（当前组局结算，返回到大厅）
    local back_bt = s:getChildByName("back_bt")
    back_bt:addTouchEventListener(
        function(sender,event)
            --触摸开始
            if event == TOUCH_EVENT_BEGAN then
                sender:setScale(0.9)
            end

            --触摸取消
            if event == TOUCH_EVENT_CANCELED then
                sender:setScale(1.0)
            end

            --触摸结束
            if event == TOUCH_EVENT_ENDED then
                sender:setScale(1.0)

                --退出房间，返回大厅
                -- require("majiang.ddzSettings"):setEndGroup(2)
                require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])

            end
        end
    )

    --结果显示区域
    local content_ly = s:getChildByName("content_ly")
    local content_sv = content_ly:getChildByName("content_sv")

    --显示用户结算结果
    local playerlist = pack.playerlist
    if #playerlist > 0 then

    	--记录最佳炮手和大富豪
    	local paoshou_uid = nil
    	local lastPaoNum = 0

    	local fuhao_uid = nil
    	local lastChip = 0

    	for k,v in pairs(playerlist) do
    		
    		--获取用户id
    		local uid = v.uid

    		--获取用户信息以及结算情况
	    	local user_info = json.decode(v.user_info)

	    	if conditions then
	    		--todo
	    	end

	    	local dianpao_dahu_count = user_info.dianpao_dahu or 0
	    	local dianpao_xiaohu_count = user_info.dianpao_xiaohu or 0
	    	--获取用户点炮数
	    	local dianpao = dianpao_dahu_count + dianpao_xiaohu_count
	    	if dianpao ~= nil then
	    		--比较点炮数
	    		if dianpao > lastPaoNum then
	    			--记录最新点炮数和点炮id
	    			lastPaoNum = dianpao
	    			paoshou_uid = uid
	    		end
	    	end
            

	    	--获取用户分数
	    	local chips = user_info.chips
	    	if chips ~= nil then
	    		--比较分数
	    		local cha = chips - 2000
	    		if cha > lastChip then
	    			--记录最新点炮数和点炮id
	    			lastChip = cha
	    			fuhao_uid = uid
	    		end
	    	end

    	end

    	local zOrder = 10

    	--生成界面
    	for k,v in pairs(playerlist) do

    		--获取用户id
    		local uid = v.uid

    		--获取用户信息以及结算情况
	    	local user_info = json.decode(v.user_info)

	    	--定义结果分项
	    	local result_Item = cc.CSLoader:createNode("zz_majiang/GameResult_Item.csb")
	    	result_Item:setLocalZOrder(zOrder)
	    	zOrder = zOrder - 1
	    	content_sv:addChild(result_Item)

	    	local item_ly = result_Item:getChildByName("item_ly")
	    	item_ly:setPosition(219 * (k - 1), content_sv:getContentSize().height)

	    	--显示最佳炮手
	    	local paoshou_im = item_ly:getChildByName("paoshou_im")
    		if paoshou_uid ~= nil then
    			if paoshou_uid == uid then
    				paoshou_im:setVisible(true)
    			end
    		end

    		--显示大富豪
    		local winner_im = item_ly:getChildByName("winner_im")
    		if fuhao_uid ~= nil then
    			if fuhao_uid == uid then
    				winner_im:setVisible(true)
    			end
    		end

	    	local top_ly = item_ly:getChildByName("top_ly")

	    	--用户头像
	    	local head_im = top_ly:getChildByName("head_im")
	    	require("hall.GameCommon"):getUserHead(user_info.photo_url, v.uid, user_info.sex, head_im, 61, false)

	    	--是否为房主
	    	local roomowner_im = top_ly:getChildByName("roomowner_im")
	    	--只有房主才出现房主标志
    		local group_owner = tonumber(USER_INFO["group_owner"])
			if group_owner == v.uid then
				roomowner_im:setVisible(true)
			else
				roomowner_im:setVisible(false)
			end

	    	--用户昵称
	    	local name_tt = top_ly:getChildByName("name_tt")
	    	name_tt:setString(user_info.nick_name)

	    	--用户id
	    	local id_tt = top_ly:getChildByName("id_tt")
	    	id_tt:setString("ID:" .. tostring(v.uid))

	    	--中间区域
	    	local content_sv = item_ly:getChildByName("content_sv")

	    	--自摸
	    	local dhzm_ly = content_sv:getChildByName("dhzm_ly")
	    	local dhzm_itemNum_tt = dhzm_ly:getChildByName("itemNum_tt")
	    	if user_info.zimo ~= nil then
	    		dhzm_itemNum_tt:setString(tostring(user_info.zimo))
	    	end

	    	--点炮
	    	local xhzm_ly = content_sv:getChildByName("xhzm_ly")
	    	local xhzm_itemNum_tt = xhzm_ly:getChildByName("itemNum_tt")
	    	if user_info.dianpao ~= nil then
	    		xhzm_itemNum_tt:setString(tostring(user_info.dianpao))
	    	end

	    	--接炮
	    	local dhdp_ly = content_sv:getChildByName("dhdp_ly")
	    	local dhdp_itemNum_tt = dhdp_ly:getChildByName("itemNum_tt")
	    	if user_info.jiepao ~= nil then
	    		dhdp_itemNum_tt:setString(tostring(user_info.jiepao))
	    	end

	    	--暗杠
	    	local xhdp_ly = content_sv:getChildByName("xhdp_ly")
	    	local xhdp_itemNum_tt = xhdp_ly:getChildByName("itemNum_tt")
	    	if user_info.angang ~= nil then
	    		xhdp_itemNum_tt:setString(tostring(user_info.angang))
	    	end

	    	--明杠
	    	local dhjp_ly = content_sv:getChildByName("dhjp_ly")
	    	local dhjp_itemNum_tt = dhjp_ly:getChildByName("itemNum_tt")
	    	if user_info.minggang ~= nil then
	    		dhjp_itemNum_tt:setString(tostring(user_info.minggang))
	    	end

	    	--大叫
	    	local xhjp_ly = content_sv:getChildByName("xhjp_ly")
	    	local xhjp_itemNum_tt = xhjp_ly:getChildByName("itemNum_tt")
	    	if user_info.jiepao_xiaohu ~= nil then
	    		xhjp_itemNum_tt:setString(tostring(user_info.jiepao_xiaohu))
	    	end

	    	--底部区域
	    	local bottom_ly = item_ly:getChildByName("bottom_ly")

	    	--总成绩
	    	--用户当前的积分
	    	local chips = user_info.chips - 2000

	    	if chips == -2000 then
	    		--todo
	    		chips = 0
	    	end

	    	local socre_tt = bottom_ly:getChildByName("socre_tt")
	    	socre_tt:setString(tostring(chips))

    	end

    end

    local share_ly = s:getChildByName("share_ly")
    share_ly:addTouchEventListener(
        function(sender,event)
            --触摸开始
            if event == TOUCH_EVENT_BEGAN then
                sender:setScale(0.9)
            end

            --触摸取消
            if event == TOUCH_EVENT_CANCELED then
                sender:setScale(1.0)
            end

            --触摸结束
            if event == TOUCH_EVENT_ENDED then
                sender:setScale(1.0)
                share_ly:setTouchEnabled(false)
                --通知APP分享结果
                if device.platform == "android" then
                	require("hall.common.ShareLayer"):showShareLayer("分享结果","","screen","",share_ly)
                elseif device.platform ~= "windows" then
                	require("hall.common.ShareLayer"):shareGroupResultForIOS(share_ly)
                end

            end
        end
    )

end

return GroupEndingLayer