
local YaYaVoiceServerUtil = class("YaYaVoiceServerUtil")

local loginState = 0

local micState = 0

--进入房间
function YaYaVoiceServerUtil:LoginRoom()

	dump("进入房间", "-----YaYaVoiceServerUtil-----")

	loginState = 0

end

--进入房间成功
function YaYaVoiceServerUtil:LoginRoomSuccess()

	dump("进入房间成功", "-----YaYaVoiceServerUtil-----")

	loginState = 1

end

--退出房间成功
function YaYaVoiceServerUtil:LogoutRoomSuccess()

	dump("退出房间成功", "-----YaYaVoiceServerUtil-----")

	loginState = 0

end

--获取当前登录状态
function YaYaVoiceServerUtil:getLoginState()

	return loginState

end

--上麦
function YaYaVoiceServerUtil:micUp()

	if loginState == 0 then
		require("hall.GameTips"):showTips("呀呀语音服务", "", 3, "语音服务正在启动")
		return
	end

	if micState == 1 then
		return
	end

	micState = 0

	if device.platform == "android" then

		local arr = {}
		cct.getDateForApp("micUp", arr, "V")

	elseif device.platform == "ios" then

		local arr = {}
		cct.getDateForApp("micUp", arr, "V")

	else

		self:micUpSuccess()
	
	end

end

--上麦成功
function YaYaVoiceServerUtil:micUpSuccess()

	dump("上麦成功", "-----YaYaVoiceServerUtil-----")

	micState = 1

	require("hall.view.chatView.chatView"):setVoiceBtImg(micState)

	--停止背景音乐
	-- audio.stopMusic(true)

	-- local mode = USER_INFO["enter_mode"]
	-- if mode == 44 then
	-- 	require("szkawuxing.gameScene"):setVoiceBtImg(1)

	-- elseif mode == 47 then
	-- 	require("xykawuxing.gameScene"):setVoiceBtImg(1)


	-- elseif mode == 50 then
	-- 	require("xgkawuxing.gameScene"):setVoiceBtImg(1)

	-- end

end

--下麦
function YaYaVoiceServerUtil:micDown()

	if micState == 0 then
		return
	end

	if device.platform == "android" then

		local arr = {}
		cct.getDateForApp("micDown", arr, "V")

	elseif device.platform == "ios" then

		local arr = {}
		cct.getDateForApp("micDown", arr, "V")

	else

		self:micDownSuccess()
	
	end

end

--下麦成功
function YaYaVoiceServerUtil:micDownSuccess()

	dump("下麦成功", "-----YaYaVoiceServerUtil-----")

	micState = 0

	require("hall.view.chatView.chatView"):setVoiceBtImg(micState)

	--恢复背景音乐
	-- audio.resumeMusic()

	-- local mode = USER_INFO["enter_mode"]
	-- if mode == 44 then
	-- 	require("szkawuxing.gameScene"):setVoiceBtImg(0)

	-- elseif mode == 47 then
	-- 	require("xykawuxing.gameScene"):setVoiceBtImg(0)


	-- elseif mode == 50 then
	-- 	require("xgkawuxing.gameScene"):setVoiceBtImg(0)

	-- end

end

--获取当前上麦状态
function YaYaVoiceServerUtil:getMicState()

	return micState

end

return YaYaVoiceServerUtil