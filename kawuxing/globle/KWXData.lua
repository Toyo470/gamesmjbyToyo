
local KWXData = class("KWXData")

KWX_GAME_PLANE = nil -- 游戏面板
KWX_MANYOU_PLANE = nil -- 漫游面板
KWX_CARD_POINTER = nil -- 牌指针
KWX_CURRENT_CARDNODE = nil

KWX_CONTROLLER = nil

KWX_MY_USERINFO = {}
KWX_SEAT_TABLE = {} -- key = uid
KWX_USERINFO_TABLE = {} -- key = seat_id
KWX_ROOM = {}
KWX_ROOM.positionTable = {}
KWX_ROOM.userInfos = KWX_USERINFO_TABLE
KWX_GAMEINFO_TABLE = {} -- key = seat_id
KWX_SEAT_TABLE_BY_TYPE = {} -- key == playerType
KWX_ZHUANG_UID = nil -- 庄家id

KWX_CONTROL_TABLE = nil --操作数据

KWX_STATE = 0 -- 1 进入组局  2 开始组局 3 结束一局 4组局结束

KWX_CHUPAI = 0 -- 0 不能出牌 2 必须等待操作 1 可以出牌

KWX_GAME_STATUS = 0 -- 0 未开始 1 进行中

KWX_LG_CARDS = {}

KWX_TING = 0

KWX_TOTAL_ROUNDS = nil
KWX_ROUND = nil

KWX_CARDS_LESS_INIT = 45
KWX_REMAIN_CARDS_COUNT = KWX_CARDS_LESS_INIT

KWX_ENDING_DATA = nil
KWX_GROUP_ENDING_DATA = nil

return KWXData