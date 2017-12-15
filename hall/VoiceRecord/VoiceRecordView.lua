
local VoiceRecordView = class("VoiceRecordView")

function VoiceRecordView:showView(x,y,o)

    if isiOSVerify then
        return
    end
	local order = o or 500

	if SCENENOW["scene"] then

		--释放之前的
        local s = SCENENOW["scene"]:getChildByName("VoiceRecordView")
        if s then
            s:removeSelf()
        end

		local button = ccui.Button:create()
	    button:setTouchEnabled(true)
	    button:setAnchorPoint(cc.p(0.5,0.5))
	    button:setSize(40.00, 57.00)
	    button:setPosition(x , y)
	    button:loadTextures("hall/VoiceRecord/voice_bt.png", nil, nil)
	    button:setName("VoiceRecordView")

	    button:addTouchEventListener(
	        function(sender,event)

	            --触摸开始
	            if event == TOUCH_EVENT_BEGAN then
	            	sender:setScale(0.8)

	            	dump("触摸开始", "-----录音按钮-----")

	            	--暂停背景音乐
	            	audio.pauseMusic()

	            	-- ccexp.AudioEngine:stopAll()

	            	-- cc.SimpleAudioEngine:getInstance():pauseAllEffects()

	            	bm.isRecordingVoice = 1

	            	require("hall.recordUtils.RecordUtils"):showRecordFrame(cc.p(480, 270), cc.size(264, 218), -1)

	            end

	            --触摸取消
	            if event == TOUCH_EVENT_CANCELED then
	            	sender:setScale(1.0)

	            	dump("触摸取消", "-----录音按钮-----")

	            	--恢复背景音乐
	            	audio.resumeMusic()

	            	bm.isRecordingVoice = 0

	            	require("hall.recordUtils.RecordUtils"):showRecordFrame(cc.p(480, 270), cc.size(264, 218), -3)

	            end

	            --触摸结束
	            if event == TOUCH_EVENT_ENDED then
	            	sender:setScale(1.0)

	            	dump("触摸结束", "-----录音按钮-----")

	            	--恢复背景音乐
	            	audio.resumeMusic()

	            	bm.isRecordingVoice = 0

	            	require("hall.recordUtils.RecordUtils"):showRecordFrame(cc.p(480, 270), cc.size(264, 218), -2)

	            end

	        end
	    )


	    dump("添加按钮", "-----录音按钮-----")
	    
	    if order == -1 then
	    	--todo
	    	SCENENOW["scene"]:addChild(button)
	    else
	    	SCENENOW["scene"]:addChild(button,order)
	    end

	end

end

function VoiceRecordView:removeView()

	if SCENENOW["scene"] then

		--释放之前的
        local s = SCENENOW["scene"]:getChildByName("VoiceRecordView")
        if s then
            s:removeSelf()
        end

	end
	
end

return VoiceRecordView
