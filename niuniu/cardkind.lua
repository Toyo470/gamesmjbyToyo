require("framework.init")

CARDTYPE = {
	[0] = '非法' ,
	[1] = '没牛',
	[2] = '牛一',
	[3] = '牛二',
	[4] = '牛三',
	[5] = '牛四',
	[6] = '牛五',
	[7] = '牛六',

	[8] = '牛七',
	[9] = '牛八',
	[10] = '牛九',--2

	[11] = '牛牛',--3

	[12] = '四炸',--
	[13] = '五花牛',
	[14] = '五小牛',
}

CARDTYPE_IMAGE = 
{
	[0] = '' ,
	[1] = 'niuniu/newimage/result_1.png',
	[2] = 'niuniu/newimage/result_2.png',
	[3] = 'niuniu/newimage/result_3.png',
	[4] = 'niuniu/newimage/result_4.png',
	[5] = 'niuniu/newimage/result_5.png',
	[6] = 'niuniu/newimage/result_6.png',
	[7] = 'niuniu/newimage/result_7.png',
	[8] = 'niuniu/newimage/result_8.png',
	[9] = 'niuniu/newimage/result_9.png',
	[10] = 'niuniu/newimage/result_10.png',--2
	[11] = 'niuniu/newimage/result_11.png',--3
	[12] = 'niuniu/newimage/result_12.png',--
	[13] = 'niuniu/newimage/result_13.png',
	[14] = 'niuniu/newimage/result_14.png',
}


---没牛-牛7是1，
-- 计分方式
-- 炸弹——————————6 倍与压注筹码
-- 全花牌牛牛—————— 5 倍与压注筹码
-- 四张花牌牛牛—————4 倍与压注筹码
-- 牛牛—————————3 倍与压注筹码 -- 对了
-- 牛7、牛8、牛9－－－－2 倍与压注筹码 对了
-- 无牛—————————1 倍与压注筹码
--对应上面的各种牛的声音
CARD_SOUND = 
{
	[0] = "",
	[1] = "bull0.mp3",
	[2] = "bull1.mp3",
	[3] = "bull2.mp3",
	[4] = "bull3.mp3",
	[5] = "bull4.mp3",
	[6] = "bull5.mp3",
	[7] = "bull6.mp3",
	[8] = "bull7.mp3",
	[9] = "bull8.mp3",
	[10] = "bull9.mp3",
	[11] = "bull10.mp3",
	[12] = "bull11.mp3",
	[13] = "bull12.mp3",
	[14] = "bull13.mp3",--五小牛
}


NIUNIU_BG_SOUND = "niuniu/sound/".."bg-room.mp3" --背景音乐

NIUNIU_FAPAI_SOUND = "niuniu/sound/".."poker.mp3" --发牌音效

function GET_CARD_RESULT_SOUND( index )
	-- body
	local path = "niuniu/sound/"..CARD_SOUND[index]
	return path
end