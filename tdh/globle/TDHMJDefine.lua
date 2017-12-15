CARD_PLAYERTYPE_MY = 1
CARD_PLAYERTYPE_LEFT = 2
CARD_PLAYERTYPE_RIGHT = 3
CARD_PLAYERTYPE_TOP = 4

CARD_TYPE_INHAND = 1
CARD_TYPE_OUTHAND = 2
CARD_TYPE_LEFTHAND = 3

CARD_DISPLAY_TYPE_OPPOSIVE = 1
CARD_DISPLAY_TYPE_SHOW = 2
CARD_DISPLAY_TYPE_HIDE = 3

--胡类型
HU_TYPE_H  = 0x040        --胡
HU_TYPE_GH = 0x080        --抢杠胡
HU_TYPE_HH = 0x100
HU_TYPE_ZM = 0x800        --自摸


--杠类型
GANG_TYPE_PG = 0x010      --碰杠
GANG_TYPE_HUA = 0x020     --花杠，无用
GANG_TYPE_AN = 0x200      --暗杠
GANG_TYPE_BU = 0x400      --补杠，明杠

--听
TING_TYPE_T = 0x1000

--晾喜
LIANGXI_TYPE_L = 0x10000

--碰类型
PENG_TYPE_P = 0x008

--界面操作类型
CONTROL_TYPE_HU = bit.bor(bit.bor(bit.bor(HU_TYPE_H, HU_TYPE_GH), HU_TYPE_HH), HU_TYPE_ZM)
CONTROL_TYPE_GANG = bit.bor(bit.bor(bit.bor(GANG_TYPE_PG, GANG_TYPE_HUA), GANG_TYPE_AN), GANG_TYPE_BU)
CONTROL_TYPE_PENG = PENG_TYPE_P
-- CONTROL_TYPE_CHI = bit.bor(bit.bor(CHI_TYPE_RIGHT, CHI_TYPE_MIDDLE), CHI_TYPE_LEFT)
CONTROL_TYPE_TING = TING_TYPE_T
CONTROL_TYPE_LIANGXI = LIANGXI_TYPE_L
CONTROL_TYPE_NONE = 0


--胡牌类型
HU_TYPE_TABLE = {"四喜", "板板胡", "缺一色", "六六顺", "小胡", "天胡", "地胡", "飘胡", "将将胡", "清一色", "海底捞月", "海底炮", "七小对", "杠上开花", "抢杠胡", "杠上炮", "七小对", "豪华七对", "全求人","夹胡","飘胡","七小队","豪华七小对","超豪华七小队"}
STR_HU_TYPE_QISHOU = "起手胡"