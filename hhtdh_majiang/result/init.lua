manager = nil

XIAO_HU = "xiaohu"--#小胡
PENG_PENG_HU = "pph"--#大胡  碰碰胡
JIANG_JIANG_HU = "jjh"--#将将胡
QING_YI_SE = "qys"--#清一色
QI_XIAO_DUI = "qxd"--#七小队
HAO_QI_DUI = "hqd"--#豪华七小对
SHUANG_HAO_QI_DUI = "shqd"--#双豪华七小对
HAI_DI = "haidi"--#海底
HAI_DI_PAO = "haidipao"--#海底炮
GANG_SHANG_KAI_HUA = "gskh"--#杠上开花
QIANG_GANG_HU = "qgh"--#抢杠胡
GANG_SHANG_PAO = "gsp"--#杠上炮


function get_hu_style( hu_style )
	-- body
	if hu_style ==  "xiaohu" then--#小胡
		return "平胡"
	end

	if hu_style ==  "pph" then--#大胡  碰碰胡
		return "碰碰胡"
	end

	if hu_style ==  "jjh" then--#将将胡
		return "将将胡"
	end

	if hu_style == "qys" then--#清一色
		return "清一色"
	end

	if hu_style ==  "qxd" then--#七小队
		return "七小对"
	end

	if hu_style ==  "hqd" then--#豪华七小对
		return "豪华七小对"
	end

	if hu_style ==  "shqd" then--#双豪华七小对
		return "双豪华七小对"
	end

	if hu_style == "haidi" then--#海底
		return "海底"
	end

	if hu_style ==  "haidipao" then--#海底炮
		return "海底炮"
	end

	if hu_style ==  "gskh" then--#杠上开花
		return "杠上开花"
	end

	if hu_style ==  "qgh" then--#抢杠胡
		return "抢杠胡"
	end

	if hu_style ==  "gsp" then--#杠上炮
		return "杠上炮"
	end

end