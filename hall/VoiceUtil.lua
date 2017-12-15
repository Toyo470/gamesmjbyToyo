local VoiceUtil = class("VoiceUtil")

function VoiceUtil:playEffect(sound_path,a)

	-- if bm.isRecordingVoice == 1 then
	-- 	return
	-- end

	cc.SimpleAudioEngine:getInstance():playEffect(sound_path,a)
	
end

return VoiceUtil