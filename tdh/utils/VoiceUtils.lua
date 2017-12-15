local VoiceUtils = class("VoiceUtils")

local SOUND_TYPE_TDH_MAN = "malesound"
local SOUND_TYPE_TDH_WOMEN = "femalesound"

local SOUND_HU_COUNT = 5
local SOUND_GANG_COUNT = 3
local SOUND_PENG_COUNT = 4
local SOUND_LIANGXI_COUNT = 1
local SOUND_TING_COUNT = 4

function VoiceUtils:GET_CARD_SOUND(sex, card_value)
    -- body
    local sound_path = ""
    if sex == 1 or sex == "1" then
        sound_path = "tdh/voice/" .. SOUND_TYPE_TDH_MAN .. "/mj" .. card_value .. ".mp3"
    else
        sound_path = "tdh/voice/" .. SOUND_TYPE_TDH_WOMEN .. "/mj" .. card_value .. ".mp3"
    end
    return sound_path
end

function VoiceUtils:GET_CONTROL_SOUND(sex, handle,huType)
    -- body
    local sound_path = ""

    local sexPath
    if sex == 1 or sex == "1" then
        sexPath = SOUND_TYPE_TDH_MAN
    else
        sexPath = SOUND_TYPE_TDH_WOMEN
    end

	huType = tonumber(huType)
	print("&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&", huType)

    local controlType
    local index
    if bit.band(handle, CONTROL_TYPE_HU) > 0 then
          if  bit.band(handle, HU_TYPE_ZM)> 0 then
              if huType==0 then
                controlType = "zimo"
                index = math.random(1, 3)  
			  elseif huType == 20 then
                 controlType = "zimojia"
                 index = math.random(1, 4)
			  elseif huType == 8 then
                controlType = "piao"
                index = math.random(1, 3)
			  elseif huType == 17 then
                 controlType = "qixiaodui"
                index = 1          
			  elseif huType == 18 then
                 controlType = "qixiaodui"
                index = 1          
			  elseif huType == 24 then
                 controlType = "qixiaodui"
                index = 1          
			  else
                controlType = "zimo"
                index = math.random(1, 3)  
			 end


              -- elseif HU_TYPE_TABLE[huType]=="夹胡" then
              --   controlType = "zimojia"
              --   index = math.random(1, 4)
              -- end
          else 
            if huType==0 then
                controlType = "hu"
                index = math.random(1, SOUND_HU_COUNT)
			  elseif huType == 20 then
				controlType = "jiahu"
				index = math.random(1, 4)
			  elseif huType == 8 then
                controlType = "piao"
                index = math.random(1, 3)
			  elseif huType == 17 then
                 controlType = "qixiaodui"
                index = 1          
			  elseif huType == 18 then
                 controlType = "qixiaodui"
                index = 1          
			  elseif huType == 24 then
                 controlType = "qixiaodui"
                index = 1          
			  else
                controlType = "hu"
                index = math.random(1, SOUND_HU_COUNT)
			 end


            -- elseif HU_TYPE_TABLE[huType]=="夹胡" then
            --     controlType = "jiahu"
            --     index = math.random(1, 4)
            -- elseif HU_TYPE_TABLE[huType]=="飘胡" then
            --     controlType = "piao"
            --     index = math.random(1, 3)
            -- elseif HU_TYPE_TABLE[huType]=="七小队" then
            --      controlType = "qixiaodui"
            --     index = 1          
            -- -- elseif HU_TYPE_TABLE[huType]=="豪华七小队" then
            -- --     controlType = ""
            -- --     index = math.random(1, SOUND_HU_COUNT)            
            -- -- elseif HU_TYPE_TABLE[huType]=="小胡"
            -- --     controlType = ""
            -- --     index = math.random(1, SOUND_HU_COUNT)
			-- else
            --     controlType = "hu"
            --     index = math.random(1, SOUND_HU_COUNT)
            -- end
         end
    elseif bit.band(handle, CONTROL_TYPE_GANG) > 0 then
        controlType = "gang"
        index = math.random(1, SOUND_GANG_COUNT)
    elseif bit.band(handle, CONTROL_TYPE_PENG) > 0 then
        controlType = "peng"
        index = math.random(1, SOUND_PENG_COUNT)
    elseif bit.band(handle, CONTROL_TYPE_LIANGXI) > 0 then
        controlType = "liangxi"
        index = 1
    elseif bit.band(handle, CONTROL_TYPE_TING) > 0 then
        controlType = "ting"
        index = math.random(1, SOUND_TING_COUNT)
    -- else
    --     controlType = "chi"
    --     index = math.random(1, SOUND_CHI_COUNT)
    end

    sound_path = "tdh/voice/" .. sexPath .. "/" .. controlType .. index .. ".mp3"

    return sound_path
end

-- 出牌播放声音
function VoiceUtils:playCardSound(seatId,card_value)

    local sex = TDHMJ_USERINFO_TABLE[seatId .. ""].sex

    local sound_path = self:GET_CARD_SOUND(sex, card_value)

    dump(sound_path, "card voice")

    cc.SimpleAudioEngine:getInstance():playEffect(sound_path, false)
    
end

function VoiceUtils:playControlSound(seatId, handle, huType)
    -- body
    local sex = TDHMJ_USERINFO_TABLE[seatId .. ""].sex

    local sound_path = self:GET_CONTROL_SOUND(sex, handle, huType)

    cc.SimpleAudioEngine:getInstance():playEffect(sound_path, false)
end

function VoiceUtils:playBackgroundMusic()
    audio.playMusic("tdh/voice/BG_283.mp3",true)
end

return VoiceUtils
