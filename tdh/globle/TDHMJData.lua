local TDHMJData = class("TDHMJData")

TDHMJ_GAME_PLANE = nil -- 游戏面板
-- TDHMJ_MANYOU_PLANE = nil -- 漫游面板
TDHMJ_CARD_POINTER = nil -- 牌指针
TDHMJ_CURRENT_CARDNODE = nil

TDHMJ_CONTROLLER = nil

TDHMJ_MY_USERINFO = {}
TDHMJ_SEAT_TABLE = {} -- key = uid
TDHMJ_USERINFO_TABLE = {} -- key = seat_id
TDHMJ_ROOM = {}
TDHMJ_ROOM.positionTable = {}
TDHMJ_ROOM.userInfos = TDHMJ_USERINFO_TABLE
TDHMJ_GAMEINFO_TABLE = {} -- key = seat_id
TDHMJ_SEAT_TABLE_BY_TYPE = {} -- key == playerType
TDHMJ_ZHUANG_UID = nil -- 庄家id

TDHMJ_ting = nil    --听状态为0

TDHMJ_CONTROL_TABLE = nil --操作数据

TDHMJ_STATE = 0 -- 1 进入组局  2 开始组局 3 结束一局 4组局结束

TDHMJ_CHUPAI = 0 -- 0 不能出牌 2 必须等待操作 1 可以出牌

TDHMJ_TOTAL_ROUNDS = nil
TDHMJ_ROUND = nil

TDHMJ_REMAIN_CARDS_COUNT = 68

TDHMJ_ENDING_DATA = nil
TDHMJ_GROUP_ENDING_DATA = nil

return TDHMJData