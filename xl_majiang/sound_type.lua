
local SoundPathManager=class("SoundPathManager")

function SoundPathManager:ctor()

    self.SOUND_NAME = 
    {
        [0x01] = "mjt1_1.mp3",
        [0x02] = "mjt1_2.mp3",
        [0x03] = "mjt1_3.mp3",
        [0x04] = "mjt1_4.mp3",
        [0x05] = "mjt1_5.mp3",
        [0x06] = "mjt1_6.mp3",
        [0x07] = "mjt1_7.mp3",
        [0x08] = "mjt1_8.mp3",
        [0x09] = "mjt1_9.mp3",

        [0x11] = "mjt2_1.mp3",
        [0x12] = "mjt2_2.mp3",
        [0x13] = "mjt2_3.mp3",
        [0x14] = "mjt2_4.mp3",
        [0x15] = "mjt2_5.mp3",
        [0x16] = "mjt2_6.mp3",
        [0x17] = "mjt2_7.mp3",
        [0x18] = "mjt2_8.mp3",
        [0x19] = "mjt2_9.mp3",

        [0x21] = "mjt3_1.mp3",
        [0x22] = "mjt3_2.mp3",
        [0x23] = "mjt3_3.mp3",
        [0x24] = "mjt3_4.mp3",
        [0x25] = "mjt3_5.mp3",
        [0x26] = "mjt3_6.mp3",
        [0x27] = "mjt3_7.mp3",
        [0x28] = "mjt3_8.mp3",
        [0x29] = "mjt3_9.mp3"
    }

end

function SoundPathManager:GET_CARD_SOUND(sex, card_value)

    local sound_path = ""

    if sex == 1 then
        sound_path = "hall/majiangsound/common_man/" .. self.SOUND_NAME[card_value]
    else
        sound_path = "hall/majiangsound/common_woman/" .. self.SOUND_NAME[card_value]
    end

    return sound_path
    
end

function SoundPathManager:GET_GANG_PENG_SOUND(sex, index)

    local sound_path = ""
    if sex == 1 then
        sound_path = "hall/majiangsound/common_man/"
    else
        sound_path = "hall/majiangsound/common_woman/"
    end

    local type = ""
    local random = 1
    if index == 1 then
        --胡
        type = "hu"
        random = math.random(3)

    elseif index == 2 then
        --碰
        type = "peng"
        random = math.random(5)

    elseif index == 3 then
        --杠
        type = "gang"
        random = math.random(3)

    end

    sound_path = sound_path .. type .. tostring(random) .. ".mp3"

    return sound_path
end

return SoundPathManager