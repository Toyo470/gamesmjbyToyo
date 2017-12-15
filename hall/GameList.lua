

local targetPlatform = cc.Application:getInstance():getTargetPlatform()
local GameList  = class("GameList")

local gameList = {}
local levelList = {}
local updateIndex = 1

function GameList:addGame(gameid,code,name,version)
    -- body
    table.insert(gameList,{gameid,code,name,version})
end

--加载游戏列表
function GameList:loadGameList(data)

	-- if not data then
	-- 	print("!!![ERROR]", "GameList:loadGameList(), the @param(data) is nil...")
	-- 	return 
	-- end

    gameList = {}
    for i, v in ipairs(data) do
      table.insert(gameList,{v["gameId"],v["code"],v["name"],v["version"],v["playerCount"],v["freeGamePhoto"],v["isMainPage"],v["isShow"]})
    end

end
-- 更新游戏level
function GameList:loadGroupConfig( data )
  if data == nil then
    return
  end
  levelList = {}
  for k, v in pairs(data) do
    local strs = string.split(v["level"], "|")
    if strs then
      for kk, vv in pairs(strs) do
        levelList[tonumber(vv)] = {}
        levelList[tonumber(vv)]["gameId"] = v["gameId"]
        levelList[tonumber(vv)]["gameName"] = require("hall.GameList"):getGameName(v["gameId"])
        levelList[tonumber(vv)]["gameConfig"] = v["gameConfig"]
      end
    end
  end
  dump(levelList, "loadGroupConfig", nesting)
end

function GameList:getGameNameByLevel( level )
  -- body
  if levelList == nil then
    return ""
  end
  local data = levelList[level]
  if data then
    return data["gameName"]
  end
  return ""
end

function GameList:getGameCode(gameid)
    -- body
    for i,v in ipairs(gameList) do
        if v[1] == gameid then
            return v[2]
        end
    end
    return ""
end

--根据gameid，查找游戏名
function GameList:getGameName(gameid)
    -- body
    for i,v in ipairs(gameList) do
        if v[1] == gameid then
            return v[3]
        end
    end
    return ""
end

--获取单个游戏信息
function GameList:getInfoByCode(code)
    for i,v in ipairs(gameList) do
        if v[2] == code then
            return v
        end
    end
    return nil
end

--获取当前更新游戏信息
function GameList:getCurrentUpdateGame()
    updateIndex = updateIndex + 1
    return gameList[updateIndex - 1]
end

--是否最后一个游戏更新
function GameList:isLastUpdate()
    print("isLastUpdate",tostring(updateIndex),tostring(#gameList))
    dump(gameList, "-----isLastUpdate-----")
    if updateIndex >= #gameList then
        return true
    end
    return false
end

function GameList:resetUpdateList()
    updateIndex = 1
end

function GameList:getList(isVerify_)
    -- body

    if isVerify_ then
            --todo

           local data={
                 {
                     1,
                      "ddz",
                      "¶·µØÖ÷",
                      "1.0.5",
                      1,
                      "http://hbirdtest.oss-cn-shenzhen.aliyuncs.com/game1.png",
                 },
                  {
                      5,
                      "niuniu",
                      "¶·Å£",
                      "1.0.0",
                      5,
                      "http://hbirdtest.oss-cn-shenzhen.aliyuncs.com/game2.png",
                 },
                 {
                      4,
                      "majiang",
                      "¶·Å£",
                      "1.0.0",
                      4,
                      "http://hbirdtest.oss-cn-shenzhen.aliyuncs.com/game2.png",
                 },
                 {
                      6,
                      "top11",
                      "¶·Å£",
                      "1.0.0",
                      6,
                      "http://hbirdtest.oss-cn-shenzhen.aliyuncs.com/game2.png",
                 }
             }

        return data
    end

    return gameList
end

local reloadTable = 0
--设置重连tid
function GameList:setReloadTable( tid )
  -- body
  reloadTable = tid
end
function GameList:getReloadTable( ... )
  -- body
  return reloadTable
end
--设置重连模式
local reloadOnlookUser = 0
function GameList:setReloginMode(on_look_user)
  reloadOnlookUser = on_look_user
end
function GameList:getReloginMode()
  return reloadOnlookUser
end

return GameList
