local CSMJData = class("CSMJData")

CSMJ_GAME_PLANE = nil -- 游戏面板
CSMJ_MANYOU_PLANE = nil -- 漫游面板
CSMJ_CARD_POINTER = nil -- 牌指针
CSMJ_CURRENT_CARDNODE = nil

CSMJ_CONTROLLER = nil

CSMJ_MY_USERINFO = {}
CSMJ_SEAT_TABLE = {} -- key = uid
CSMJ_USERINFO_TABLE = {} -- key = seat_id
CSMJ_ROOM = {}
CSMJ_ROOM.positionTable = {}
CSMJ_ROOM.userInfos = CSMJ_USERINFO_TABLE
CSMJ_GAMEINFO_TABLE = {} -- key = seat_id
CSMJ_SEAT_TABLE_BY_TYPE = {} -- key == playerType
CSMJ_ZHUANG_UID = nil -- 庄家id

CSMJ_CONTROL_TABLE = nil --操作数据

CSMJ_STATE = 0 -- 1 进入组局  2 开始组局 3 结束一局 4组局结束

CSMJ_CHUPAI = 0 -- 0 不能出牌 2 必须等待操作 1 可以出牌

CSMJ_TOTAL_ROUNDS = nil
CSMJ_ROUND = nil

CSMJ_REMAIN_CARDS_COUNT = 56

CSMJ_ENDING_DATA = nil
CSMJ_GROUP_ENDING_DATA = nil

CSMJ_CURRENT_QI_SHOU_PLAYER_TYPE = nil -- 标记当前起手胡玩家

return CSMJData
