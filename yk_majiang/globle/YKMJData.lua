
local YKMJData = class("YKMJData")

YKMJ_GAME_PLANE = nil -- 游戏面板
YKMJ_MANYOU_PLANE = nil -- 漫游面板
YKMJ_CARD_POINTER = nil -- 牌指针
YKMJ_CURRENT_CARDNODE = nil

YKMJ_CONTROLLER = nil

YKMJ_MY_USERINFO = {}
YKMJ_SEAT_TABLE = {} -- key = uid
YKMJ_USERINFO_TABLE = {} -- key = seat_id
YKMJ_ROOM = {}
YKMJ_ROOM.positionTable = {}
YKMJ_ROOM.userInfos = YKMJ_USERINFO_TABLE
YKMJ_GAMEINFO_TABLE = {} -- key = seat_id
YKMJ_SEAT_TABLE_BY_TYPE = {} -- key == playerType
YKMJ_ZHUANG_UID = nil -- 庄家id

YKMJ_CONTROL_TABLE = nil --操作数据

YKMJ_STATE = 0 -- 1 进入组局  2 开始组局 3 结束一局 4组局结束

YKMJ_CHUPAI = 0 -- 0 不能出牌 2 必须等待操作 1 可以出牌

YKMJ_GAME_STATUS = 0 -- 0 未开始 1 进行中

YKMJ_LG_CARDS = {}

YKMJ_TING = 0

PLAYERNUM = 4

XFGNUM = 200

YKMJ_TOTAL_ROUNDS = nil
YKMJ_ROUND = nil

YKMJ_CARDS_LESS_INIT = 82
YKMJ_REMAIN_CARDS_COUNT = YKMJ_CARDS_LESS_INIT

YKMJ_ENDING_DATA = nil
YKMJ_GROUP_ENDING_DATA = nil

return YKMJData