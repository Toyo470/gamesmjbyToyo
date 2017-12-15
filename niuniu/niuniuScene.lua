cc.FileUtils:getInstance():addSearchPath("niuniu/")
TpackageName="niuniu"
require(TpackageName.."/untilT/init")

local PROTOCOL = import("niuniu.Niuniu_Protocol")
local NiuniuhallServer  = import("niuniu.hallScene.NiuniuhallServer") --后台服务
local NiuniuhallHandle  = import("niuniu.hallScene.NiuniuhallHandle")--protocal 协议
import("src.socket.functions").exportMethods(bm)

local HttpNet = import("niuniu.NiuniuHttp")
bm.User             = {}  --用户信息
bm.Room             = {}  --房间信息

local NiuniuhallScenes  = class("NiuniuhallScenes", function()
    return display.newScene("NiuniuhallScenes")
end)
--niu niu 游戏类型  单人百人
function NiuniuhallScenes:ctor()

    bm.server:setProtocol(PROTOCOL)
    bm.server:setHandle(NiuniuhallHandle.new())
end

function NiuniuhallScenes:onEnter( ... )
	-- body
	local scene = require(TpackageName.."/hallScene/NiuniuHallScene").new(HttpNet)
	display.replaceScene(scene)
	SCENENOW["scene"] = scene
	SCENENOW["name"] = TpackageName.."/hallScene/NiuniuHallScene"
    
end


return NiuniuhallScenes
