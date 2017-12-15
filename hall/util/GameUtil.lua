
local GameUtil = class("GameUtil")

--通知进入房间
function GameUtil:LoginRoom(roomId)

	if mediaSendMode ~= 1 then
		return
	end

	if device.platform == "android" then

		dump("Android进入房间", "-----GameUtil-----")

		local arr = {}
		table.insert(arr, roomId)
		cct.getDateForApp("LoginRoom", arr, "V")

	elseif device.platform == "ios" then

		dump("ios进入房间", "-----GameUtil-----")

		local arr = {}
		arr["roomId"] = roomId
		arr["uid"] = tostring(USER_INFO["uid"])
		if not isiOSVerify then
			cct.getDateForApp("LoginRoom", arr, "V")
		end

	else

		dump("进入房间", "-----GameUtil-----")
	
	end

end

--通知退出房间
function GameUtil:LogoutRoom()

	if mediaSendMode ~= 1 then
		return
	end

	if device.platform == "android" then

		dump("Android退出房间", "-----GameUtil-----")

		local arr = {}
		cct.getDateForApp("LogoutRoom", arr, "V")

	elseif device.platform == "ios" then

		dump("iOS退出房间", "-----GameUtil-----")

		local arr = {}
		if not isiOSVerify then
			cct.getDateForApp("LogoutRoom", arr, "V")
		end
	else

		dump("退出房间", "-----GameUtil-----")
	
	end

end

return GameUtil