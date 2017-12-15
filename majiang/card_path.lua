--
-- Author: chen
-- Date: 2016-05-27-10:26:42
--
----声音相关路径

--按钮点击声音
audio_path = "music/music/Audio_Button_Click.mp3"

--定义资源管理类
local CARD_PATH_MANAGER=class("CARD_PATH_MANAGER")

--定义卡片路径字典
local card_path_dic = {}

function CARD_PATH_MANAGER:ctor()

end

--卡片管理类初始化方法
function CARD_PATH_MANAGER:init()
	
	--定义图片路径
	local image_path = "majiang/image/"

	--定义卡片路径
	local card_path = "card/"

	--刮风
	card_path_dic["guafeng"] = image_path.. "guafeng.png"
	--下雨
	card_path_dic["xiayu"] = image_path.. "xiayu.png"
	--发炮（点炮）
	card_path_dic["fangpao"] = image_path .."fangpao.png"
	--自摸
	card_path_dic["path_zimo"] = image_path .. "zimo.png"
	--胡
	card_path_dic["path_hu"]  = image_path .. "hu.png"

	--左边玩家手上的牌
	card_path_dic["path_lefthandcard"] = image_path..card_path.."lefthandcard.png"
	--右边玩家手上的牌
	card_path_dic["path_righthandcard"] = image_path..card_path.."righthandcard.png"
	--对家玩家手上的牌
	card_path_dic["path_tophandcard"] = image_path..card_path.."tophandcard.png"
	--左右两边玩家盖下的牌
	card_path_dic["path_leftright_gai"] = image_path..card_path.."left_right_gai.png"
	--对家玩家手上的牌
	card_path_dic["path_top_gai_pai"] = image_path..card_path.."top_gai_pai.png"
	--自己盖下的牌
	card_path_dic["path_myback"] = image_path..card_path.."myback.png"
	-- 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09,    //万
	-- 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19,    //饼
	-- 0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29,    //条

	--用户默认头像
	card_path_dic["path_default_image"] = "majiang/image/photo_default.png"

	--杠
	card_path_dic["path_other_gang"] =  "majiang/image/quan_gang.png"
	--碰
	card_path_dic["path_other_peng"] = "majiang/image/quan_peng.png"
	--胡
	card_path_dic["path_other_hu"] = "majiang/image/quan_hu.png"
	--听
	card_path_dic["path_ting"] = "majiang/image/quan_ting.png"

	--骰子图片资源
	card_path_dic["shaizi_path"] = "majiang/image/shaiziPin.png"

	--背景光
	card_path_dic["path_guan"] = "majiang/image/Resources/guan.png"

	--数字字体
	card_path_dic["path_font_res"] ="majiang/image/font/num.fnt"

end

--获取图片资源
function CARD_PATH_MANAGER:get_card_path(card_name)
	return card_path_dic[card_name] or ""
end

--获取左边用户打出的牌
function CARD_PATH_MANAGER:get_left_out_card_path(card_value)
	return "majiang/image/card/leftout/"..tostring(card_value)..".png"
end

--获取右边用户打出的牌
function CARD_PATH_MANAGER:get_right_out_card_path(card_value)
	return "majiang/image/card/rightout/"..tostring(card_value)..".png"
end

--获取对家用户打出的牌
function CARD_PATH_MANAGER:get_top_topout_card_path(card_value)
	return "majiang/image/card/topout/"..tostring(card_value)..".png"
end

--获取我手中的牌
function CARD_PATH_MANAGER:get_hand_card_path(card_value)
	return "majiang/image/card/handcard/"..tostring(card_value)..".png"
end

--012对应万筒条
function CARD_PATH_MANAGER:get_que_tip(index)
	return "majiang/image/que_"..tostring(index)..".png"
end

return CARD_PATH_MANAGER


