-- module(..., package.seeall)
MusicManager = class("MusicManager")

function MusicManager:ctor()

end

function MusicManager:initialize()
	math.randomseed(os.time())
end

function MusicManager:playEffect(sound_path)
	
	cc.SimpleAudioEngine:getInstance():playEffect(sound_path,false)
end

--碰的声音
function MusicManager:playEffectPeng( sex )
	-- body
	local random = math.random(5)
	local sound_path = ""
	if tonumber(sex) == 1 then
		sound_path = "hall/majiangsound/common_man/".."peng"..tostring(random)..".mp3"
		
	else
		sound_path = "hall/majiangsound/common_woman/".."peng"..tostring(random)..".mp3"
	
	end
	self:playEffect(sound_path)
end

--吃的声音
function MusicManager:playEffectChi( sex )
	-- body
	local random = math.random(4)
	local sound_path = ""
	if tonumber(sex) == 1 then
		sound_path = "hall/majiangsound/common_man/".."chi"..tostring(random)..".mp3"
		
	else
		sound_path = "hall/majiangsound/common_woman/".."chi"..tostring(random)..".mp3"
	
	end
	self:playEffect(sound_path)

end


--杆的声音
function MusicManager:playEffectGang( sex )
	-- body
	local random = math.random(3)
	local sound_path = ""
	if tonumber(sex) == 1 then --男
		sound_path = "hall/majiangsound/common_man/".."gang"..tostring(random)..".mp3"

	else
		sound_path = "hall/majiangsound/common_woman/".."gang"..tostring(random)..".mp3"

	end
	print("playEffectGang-------random---",random,"sound_path----",sound_path)
	self:playEffect(sound_path)
end

--胡的声音
function MusicManager:playEffectHu( sex )
	-- body
	local random = math.random(3)
	local sound_path = ""
	if tonumber(sex) == 1 then --男
		sound_path = "hall/majiangsound/common_man/".."hu"..tostring(random)..".mp3"

	else
		sound_path = "hall/majiangsound/common_woman/".."hu"..tostring(random)..".mp3"
	end
	
	self:playEffect(sound_path)
end

function MusicManager:playEffectCard( sex,card_value )
	-- body

	if card_value < 0 then
		card_value = card_value + 256
	end
	
	local value_path_dict = {
	[101] = "mjt1_1.mp3",
	[102] = "mjt1_2.mp3",
	[103] = "mjt1_3.mp3",
	[104] = "mjt1_4.mp3",
	[105] = "mjt1_5.mp3",
	[106] = "mjt1_6.mp3",
	[107] = "mjt1_7.mp3",
	[108] = "mjt1_8.mp3",
	[109] = "mjt1_9.mp3",

	[201] = "mjt2_1.mp3",
	[202] = "mjt2_2.mp3",
	[203] = "mjt2_3.mp3",
	[204] = "mjt2_4.mp3",
	[205] = "mjt2_5.mp3",
	[206] = "mjt2_6.mp3",
	[207] = "mjt2_7.mp3",
	[208] = "mjt2_8.mp3",
	[209] = "mjt2_9.mp3",

	[301] = "mjt3_1.mp3",
	[302] = "mjt3_2.mp3",
	[303] = "mjt3_3.mp3",
	[304] = "mjt3_4.mp3",
	[305] = "mjt3_5.mp3",
	[306] = "mjt3_6.mp3",
	[307] = "mjt3_7.mp3",
	[308] = "mjt3_8.mp3",
	[309] = "mjt3_9.mp3",

	-- [0x31] = "mjt4_7.mp3",--//白
	-- [0x41] = "mjt4_5.mp3",--//中
	-- [0x51] = "mjt4_6.mp3",--//发

	-- [0x61] = "mjt4_1.mp3",--//东
	-- [0x71] = "mjt4_2.mp3",--//南
	-- [0x81] = "mjt4_3.mp3",--//西
	-- [0x91] = "mjt4_4.mp3",--//北
	}

	local sound_path = ""
	local p = value_path_dict[card_value] or ""

	if tonumber(sex) == 1 then --男
		sound_path = "hall/majiangsound/common_man/".. p
	else
		sound_path = "hall/majiangsound/common_woman/".. p
	end

	self:playEffect(sound_path)
end

function MusicManager:get_bg_music_path()
	-- body
	local sound_path = "hall/majiangsound/bg.mp3"
	return sound_path
end