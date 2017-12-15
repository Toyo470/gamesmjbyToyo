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



--胡类型CONTROL_TYPE_HU
HU_TYPE_H  = 0x040
HU_TYPE_GH = 0x080
HU_TYPE_HH = 0x100
HU_TYPE_ZM = 0x800



-- 起手胡具体类型(与服务端对应)
HU_TYPE_SI_XI			= 1	-- 四喜
HU_TYPE_BAN_BAN_HU		= 2 -- 板板胡
HU_TYPE_QUE_YI_SE		= 3 -- 缺一色
HU_TYPE_LIU_LIU_SHUN	= 4 -- 六六顺


-- 亮牌显示的时间
COMMON_SHOW_HU_CARD_TIME= 5	



--杠类型
GANG_TYPE_PG = 0x010
GANG_TYPE_HUA = 0x020
GANG_TYPE_AN = 0x200
GANG_TYPE_BU = 0x400

--碰类型
PENG_TYPE_P = 0x008

--吃类型
CHI_TYPE_RIGHT = 0x001
CHI_TYPE_MIDDLE = 0x002
CHI_TYPE_LEFT = 0x004

-- 补张类型
BU_ZHANG_TYPE = 0X1000


--界面操作类型
CONTROL_TYPE_HU = bit.bor(bit.bor(bit.bor(HU_TYPE_H, HU_TYPE_GH), HU_TYPE_HH), HU_TYPE_ZM)
CONTROL_TYPE_GANG = bit.bor(bit.bor(bit.bor(GANG_TYPE_PG, GANG_TYPE_HUA), GANG_TYPE_AN), GANG_TYPE_BU)
CONTROL_TYPE_PENG = PENG_TYPE_P
CONTROL_TYPE_CHI = bit.bor(bit.bor(CHI_TYPE_RIGHT, CHI_TYPE_MIDDLE), CHI_TYPE_LEFT)
CONTROL_TYPE_BUZHANG = BU_ZHANG_TYPE
CONTROL_TYPE_NONE = 0


--胡牌类型
HU_TYPE_TABLE = {"四喜", "板板胡", "缺一色", "六六顺", "小胡", "天胡", "地胡", "碰碰胡", "将将胡", "清一色", "海底捞月", "海底炮", "七小对", "杠上开花", "抢杠胡", "杠上炮", "七小对", "豪华七对", "全求人"}
STR_HU_TYPE_QISHOU = "起手胡:"