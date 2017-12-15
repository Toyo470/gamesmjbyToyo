manager = nil

XIAO_HU = "xiaohu"--#小胡
PENG_PENG_HU = "pph"--#大胡  碰碰胡
QI_XIAO_DUI = "qxd"--#七小队
GANG_SHANG_KAI_HUA = "gskh"--#杠上开花
QIANG_GANG_HU = "qgh"--#抢杠胡
SHI_SAN_LAN_HU = "ssl"--#十三烂
QI_XING_SHI_SAN_LAN_HU = "qxssl"--#七星十三烂
DE_GUO_HU = "dg"--#德国
DE_ZHONG_DE_HU = "dzd"--#德中德
JING_DIAO_HU = "jd"--#精钓
TIAN_HU = "th"--#天胡
DI_HU = "dh"--#地胡

JIANG_JIANG_HU = "jjh"--#将将胡
QING_YI_SE = "qys"--#清一色
HAO_QI_DUI = "hqd"--#豪华七小对
SHUANG_HAO_QI_DUI = "shqd"--#双豪华七小对
HAI_DI = "haidi"--#海底
HAI_DI_PAO = "haidipao"--#海底炮
GANG_SHANG_PAO = "gsp"--#杠上炮


function get_hu_style( hu_style )
	-- body
	if hu_style ==  "xiaohu" then--#小胡
		return "平胡"

	elseif hu_style ==  "pph" then--#大胡  碰碰胡
		return "碰碰胡"

	elseif hu_style ==  "jjh" then--#将将胡
		return "将将胡"

	elseif hu_style == "qys" then--#清一色
		return "清一色"

	elseif hu_style ==  "qxd" then--#七小队
		return "七小对"

	elseif hu_style ==  "hqd" then--#豪华七小对
		return "豪华七小对"

	elseif hu_style ==  "shqd" then--#双豪华七小对
		return "双豪华七小对"

	elseif hu_style == "haidi" then--#海底
		return "海底"

	elseif hu_style ==  "haidipao" then--#海底炮
		return "海底炮"

	elseif hu_style ==  "gskh" then--#杠上开花
		return "杠上开花"

	elseif hu_style ==  "qgh" then--#抢杠胡
		return "抢杠胡"

	elseif hu_style ==  "gsp" then--#杠上炮
		return "杠上炮"

	elseif hu_style == "ssl" then--#十三烂
		return "十三烂"

	elseif hu_style ==  "qxssl" then--#七星十三烂
		return "七星十三烂"

	elseif hu_style == "dg" then--#德国
		return "德国"

	elseif hu_style ==  "dzd" then--#德中德
		return "德中德"

	elseif hu_style ==  "jd" then--#精钓
		return "精钓"

	elseif hu_style ==  "th" then--#天胡
		return "天胡"
		
	elseif hu_style == "dh" then--#地胡
		return "地胡"
	else
		return ""
	end

end