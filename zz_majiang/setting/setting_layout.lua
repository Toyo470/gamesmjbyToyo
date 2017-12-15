
local zz_majiangServer = require("zz_majiang.zz_majiangServer")


mrequire("setting.setting_template")
SettingLayout = class("GitemLayout", setting.setting_template.setting_Template)

function SettingLayout:_do_after_init()
	self.setting_Text_1:setString("设置")
	self.setting_Text_2:setString("音效")
	self.setting_Text_3:setString("音乐")

	self:init_setting_data()
end

function SettingLayout:click_setting_close_bt_event()
	self:hide_layout()
end

function SettingLayout:click_setting_logout_bt_event()
	self:hide_layout()
    require("hall.gameSettings"):disbandGroup("hz")
	-- zz_majiangServer:c2s_request_dissove()

end

function SettingLayout:init_setting_data()
	-- body
	local audioEngine = cc.SimpleAudioEngine:getInstance()

    local function sliderChanged(sender,eventType)
        if eventType == ccui.SliderEventType.percentChanged then
            local amount = sender:getPercent()
            local audioEngine = cc.SimpleAudioEngine:getInstance()
            -- amount = math.modf(amount/20)*20
            if sender == self.setting_music_slide then
                --todo
                audioEngine:setMusicVolume(amount / 100)
                if amount == 0 then
                    --todo
                    self.setting_music_bt:setColor(cc.c3b(125,125,125))
                else
                    self.setting_music_bt:setColor(cc.c3b(255,255,255))
                end
            elseif sender == self.setting_sound_slide then
                audioEngine:setEffectsVolume(amount / 100)
                if amount == 0 then
                    --todo
                    self.setting_sound_bt:setColor(cc.c3b(125,125,125))
                else
                    self.setting_sound_bt:setColor(cc.c3b(255,255,255))
                end
            end
        end
    end

    self.setting_sound_slide:setPercent(audioEngine:getEffectsVolume() * 100)
    self.setting_music_slide:setPercent(audioEngine:getMusicVolume() * 100)

    self.setting_sound_slide:addEventListener(sliderChanged)
    self.setting_music_slide:addEventListener(sliderChanged)
end


function SettingLayout:click_setting_music_bt_event()
	local audioEngine = cc.SimpleAudioEngine:getInstance()
	if audioEngine:getMusicVolume() == 0.0 then
	    --todo
	    audioEngine:setMusicVolume(1.0)
	    self.setting_music_slide:setPercent(100)
	    self.setting_music_bt:setColor(cc.c3b(255,255,255))
	else
	    audioEngine:setMusicVolume(0.0)
	   	self.setting_music_slide:setPercent(0)
	    self.setting_music_bt:setColor(cc.c3b(125,125,125))
	end
end

function SettingLayout:click_setting_sound_bt_event()
	local audioEngine = cc.SimpleAudioEngine:getInstance()
    if audioEngine:getEffectsVolume() == 0.0 then
        --todo
        audioEngine:setEffectsVolume(1.0)
        self.setting_sound_slide:setPercent(100)
        self.setting_sound_bt:setColor(cc.c3b(255,255,255))
    else
        audioEngine:setEffectsVolume(0.0)
        self.setting_sound_slide:setPercent(0)
        self.setting_sound_bt:setColor(cc.c3b(125,125,125))
    end
end
