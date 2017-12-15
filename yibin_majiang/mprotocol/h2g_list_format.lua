local T = bm.PACKET_DATA_TYPE
PROTOCOL_FORMAT_DICT = {}

PROTOCOL_FORMAT_DICT[0x1001] = {fmt={
{name = "table_id", type = T.INT},
{name = "nUserId", type = T.INT},
{name = "strKey", type = T.STRING},
{name = "strInfo", type = T.STRING},
{name = "iflag", type = T.INT},
{name = "version", type = T.STRING},
{name = "activity_id", type = T.STRING},
}}

PROTOCOL_FORMAT_DICT[0x1004] = {fmt={
{name = "type", type = T.INT},
}}
PROTOCOL_FORMAT_DICT[0x1200] = {fmt={{name = "msg_data", type = T.STRING}}}--用户准备
PROTOCOL_FORMAT_DICT[0x1201] = {fmt={{name = "msg_data", type = T.STRING}}}--请求解散房间
PROTOCOL_FORMAT_DICT[0x1202] = {fmt={{name = "msg_data", type = T.STRING}}}--回应解散房间
PROTOCOL_FORMAT_DICT[0x1203] = {fmt={{name = "msg_data", type = T.STRING}}}--账号选择牌
PROTOCOL_FORMAT_DICT[0x1204] = {fmt={{name = "msg_data", type = T.STRING}}}--选择目标选项
PROTOCOL_FORMAT_DICT[0x1205] = {fmt={{name = "msg_data", type = T.STRING}}}--配置牌型
PROTOCOL_FORMAT_DICT[0x1206] = {fmt={{name = "msg_data", type = T.STRING}}}--选择定飘
PROTOCOL_FORMAT_DICT[0x1207] = {fmt={{name = "msg_data", type = T.STRING}}}--选择定缺
