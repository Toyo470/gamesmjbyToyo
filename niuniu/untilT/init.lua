--
-- Author: ZT
-- Date: 2016-03-17 11:40:05
--

cct=cct or {}
local cpat=TpackageName.."/untilT/"

require(cpat.."TTLuaHelps")
cct.netSprite=require(cpat.."NetSprite")

cct.GameData={}
cct.GameState=require(cpat.."GameState")
cct.GameState.init(function (param)
	-- body
	if param.errorCode then
       printError("errorCode",param.errorCode)
    end
    return param.values

end)
if io.exists(cct.GameState.getGameStatePath()) then
    cct.GameData=cct.GameState.load()
    print("savePath:"..cct.GameState.getGameStatePath())
end

cct.scoket=require("src/socket/ServerBase")
-- cct.scoketSend=require(TpackageName..TpackageName.."ServerSend")
-- cct.socketRev=require(TpackageName..TpackageName.."ServerRev")
-- cct.socketPro=require(TpackageName..TpackageName.."ServerPro")
--cct.HttpGet=require(TpackageName.."/"..TpackageName.."_Http")

