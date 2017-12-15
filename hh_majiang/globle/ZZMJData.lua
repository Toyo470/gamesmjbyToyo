
local ZZMJData = class("ZZMJData")

ZZMJ_GAME_PLANE = nil -- 游戏面板
ZZMJ_MANYOU_PLANE = nil -- 漫游面板
ZZMJ_CARD_POINTER = nil -- 牌指针
ZZMJ_CURRENT_CARDNODE = nil

ZZMJ_CONTROLLER = nil

ZZMJ_MY_USERINFO = {}
ZZMJ_SEAT_TABLE = {} -- key = uid
ZZMJ_USERINFO_TABLE = {} -- key = seat_id
ZZMJ_ROOM = {}
ZZMJ_ROOM.positionTable = {}
ZZMJ_ROOM.userInfos = ZZMJ_USERINFO_TABLE
ZZMJ_GAMEINFO_TABLE = {} -- key = seat_id
ZZMJ_SEAT_TABLE_BY_TYPE = {} -- key == playerType
ZZMJ_ZHUANG_UID = nil -- 庄家id

ZZMJ_CONTROL_TABLE = nil --操作数据

ZZMJ_STATE = 0 -- 1 进入组局  2 开始组局 3 结束一局 4组局结束

ZZMJ_CHUPAI = 0 -- 0 不能出牌 2 必须等待操作 1 可以出牌

ZZMJ_GAME_STATUS = 0 -- 0 未开始 1 进行中

ZZMJ_LG_CARDS = {}

ZZMJ_TING = 0

ZZMJ_TOTAL_ROUNDS = nil
ZZMJ_ROUND = nil

ZZMJ_CARDS_LESS_INIT = 60
ZZMJ_REMAIN_CARDS_COUNT = ZZMJ_CARDS_LESS_INIT

ZZMJ_ENDING_DATA = nil
ZZMJ_GROUP_ENDING_DATA = nil

return ZZMJData