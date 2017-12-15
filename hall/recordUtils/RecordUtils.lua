local RecordUtils = class("RecordUtils")

local is_recording = false

--控件描点 为 0.5 0.5 
function RecordUtils:showRecordFrame(recordFramePosition, recordFrameSize, activityId)

	-- if is_recording then
	-- 	--todo
	-- 	return
	-- end
	if is_recording then
		--todo
		return
	end
	
	local args = {}
	args.x = math.floor(recordFramePosition.x)
	args.y = math.floor(recordFramePosition.y)
	args.width = math.floor(recordFrameSize.width)
	args.height = math.floor(recordFrameSize.height)
	args.activityId = tonumber(activityId)

	--发送模式，1为呀呀，2为游戏服
	-- args.mode = mediaSendMode

	if device.platform=="android" then

		local content = {}
		table.insert(content, tostring(args.x))
		table.insert(content, tostring(args.y))
		table.insert(content, tostring(args.width))
		table.insert(content, tostring(args.height))
		table.insert(content, tostring(args.activityId))
		-- table.insert(content, tostring(args.mode))

		dump(content, "-----显示视频录像框-----")

		cct.getDateForApp("showRecordFrame", content, "V")

	else
		if not isiOSVerify then
			cct.getDataForApp("showRecordFrame", args, "V")
		end

	end

	if activityId ~= -1 and activityId ~= -2 and activityId ~= -3 then
		is_recording = true
	end
	
end

function RecordUtils:didClose()
	is_recording = false
end

function RecordUtils:isRecording()
	return is_recording
end

function RecordUtils:closeRecordFrame()
	if device.platform ~= "windows" and device.platform ~= "android" then
		--todo
		local args = {}
		
		cct.getDataForApp("closeRecordFrame", args, "V")
	end
end

return RecordUtils