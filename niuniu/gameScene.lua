--//牛牛组局
cc.FileUtils:getInstance():addSearchPath("niuniu/")
TpackageName="niuniu"
require(TpackageName.."/untilT/init")

local PROTOCOL = import("niuniu.Niuniu_Protocol")
local NiuniuhallHandle  = import("niuniu.hallScene.NiuniuhallHandle")
local NiuniuhallServer  = import("niuniu.hallScene.NiuniuhallServer") --后台服务
import("src.socket.functions").exportMethods(bm)
bm.User             = {}  --用户信息
bm.Room             = {}  --房间信息

local niuniuGroupScene=class("niuniuGroupScene",function ()
	-- body
	return display.newScene("niuniuGroupScene");
end)

function niuniuGroupScene:ctor(http)
	bm.server:setProtocol(PROTOCOL)
    bm.server:setHandle(NiuniuhallHandle.new())

    bm.Room = {}
    bm.Room.isOver = 0
end

function niuniuGroupScene:onEnter( )
	--发送服务器
	-- print("niuniuGroupScene:onEnter---------------------")
	-- local level = 21
	-- NiuniuhallServer:enterRoom(level)

	require("hall.GameCommon"):landLoading(true)

	-- -- 1001
	-- print("tableIdReload.....................",tableIdReload)
	-- if tableIdReload > 0 then --表示重连
	-- 	local pack = {}
	-- 	pack.tid = tableIdReload  --tid表示的是桌子id
	-- 	NiuniuhallHandle:SVR_GET_ROOM_OK(pack)
	-- else
	-- 	local level = USER_INFO["GroupLevel"]
	-- 	local activity_id = USER_INFO["activity_id"]
	-- 	local clip = USER_INFO["group_chip"]
	-- 	local Sid  =  36
	-- 	NiuniuhallServer:enterGroupRoom(level,1,Sid,activity_id)
	-- end

	local level = USER_INFO["GroupLevel"]
	local activity_id = USER_INFO["activity_id"]
	local clip = USER_INFO["group_chip"]
	local Sid = 36
	NiuniuhallServer:enterGroupRoom(level,1,Sid,activity_id)

end

return niuniuGroupScene