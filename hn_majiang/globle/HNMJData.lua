
local HNMJData = class("HNMJData")

HNMJ_GAME_PLANE = nil -- 游戏面板
HNMJ_MANYOU_PLANE = nil -- 漫游面板
HNMJ_CARD_POINTER = nil -- 牌指针
HNMJ_CURRENT_CARDNODE = nil

HNMJ_CONTROLLER = nil

HNMJ_MY_USERINFO = {}
HNMJ_SEAT_TABLE = {} -- key = uid
HNMJ_USERINFO_TABLE = {} -- key = seat_id
HNMJ_ROOM = {}
HNMJ_ROOM.positionTable = {}
HNMJ_ROOM.userInfos = HNMJ_USERINFO_TABLE
HNMJ_GAMEINFO_TABLE = {} -- key = seat_id
HNMJ_SEAT_TABLE_BY_TYPE = {} -- key == playerType
HNMJ_ZHUANG_UID = nil -- 庄家id

HNMJ_CONTROL_TABLE = nil --操作数据

HNMJ_STATE = 0 -- 1 进入组局  2 开始组局 3 结束一局 4组局结束

HNMJ_CHUPAI = 0 -- 0 不能出牌 2 必须等待操作 1 可以出牌

HNMJ_GAME_STATUS = 0 -- 0 未开始 1 进行中

HNMJ_LG_CARDS = {}

HNMJ_TING = 0

PLAYERNUM = 4

HNMJ_TOTAL_ROUNDS = nil
HNMJ_ROUND = nil

HNMJ_CARDS_LESS_INIT = 92
HNMJ_REMAIN_CARDS_COUNT = HNMJ_CARDS_LESS_INIT

HNMJ_ENDING_DATA = nil
HNMJ_GROUP_ENDING_DATA = nil

return HNMJData