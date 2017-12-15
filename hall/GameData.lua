
--获取当前系统平台
local targetPlatform = cc.Application:getInstance():getTargetPlatform()

--定义用户数据类
local GameData  = class("GameData")


local nFreeGameCounts = 0
local nMatchGameCounts = 0
local bNotMoreMoney = false

function GameData:InitData()

    MUSIC_ON = cc.UserDefault:getInstance():getBoolForKey("music_on",true)   --声音控制开关   -- 参数 第一个值为定义，第二个值为初始值
    SOUND_ON = cc.UserDefault:getInstance():getBoolForKey("sound_on",true)
    SHOCK_ON = cc.UserDefault:getInstance():getBoolForKey("shock_on",true)
    print("GameSetting||music state:"..tostring(MUSIC_ON))
    print("GameSetting||sound state:"..tostring(SOUND_ON))
    print("GameSetting||shcok state:"..tostring(SHOCK_ON))
    local audioEngine = cc.SimpleAudioEngine:getInstance()
    local music_value = cc.UserDefault:getInstance():getIntegerForKey("music_value", -1)  --音量控制开关  --同上参数
    local sound_value = cc.UserDefault:getInstance():getIntegerForKey("sound_value", -1)

    -- print("showSettings sound_slide", tostring(sound_value))
    -- print("showSettings music_slide", tostring(music_value))

    if music_value == -1 then
        audioEngine:setMusicVolume(0.5)
    else
    print("InitData music_slide", tostring(music_value))
        audioEngine:setMusicVolume(music_value/100.0)
    end
    if sound_value == -1 then
        audioEngine:setEffectsVolume(0.5)
    else
    print("InitData sound_slide", tostring(sound_value/100.0))
        audioEngine:setEffectsVolume(sound_value/100.0)
    end

    print("InitData sound_slide", tostring(audioEngine:getEffectsVolume()))
    print("InitData music_slide", tostring(audioEngine:getMusicVolume()))
    -- USER_INFO["enter_mode"] = gameTypeTTT
    if (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) or (cc.PLATFORM_OS_MAC == targetPlatform) then
        --todo
        self:getUserInfo()
    end
    -- self:setVolume()

end

function GameData:setVolume()

  local audioEngine = cc.SimpleAudioEngine:getInstance()
  local MusicVolume = cc.UserDefault:getInstance():getFloatForKey("MusicVolume")  
  local EffectsVolume = cc.UserDefault:getInstance():getFloatForKey("EffectsVolume")
  audioEngine:setMusicVolume(MusicVolume)
  audioEngine:setEffectsVolume(EffectsVolume)
  
end

function GameData:getUserInfo()

    if (cc.PLATFORM_OS_ANDROID == targetPlatform) then

        --安卓平台

        local args = {}
        local luaj = require "cocos.cocos2d.luaj"
        local className = luaJniClass
        local sigs = "()I"

        --获取用户ID
        local ok,ret  = luaj.callStaticMethod(className,"getUserID",args,sigs)
        if not ok then
            print("luaj error:", ret)
        else
            USER_INFO["uid"] = ret
            print("getUserInfo uid:"..ret)
            UID = USER_INFO["uid"]
        end

        --获取用户金币
        sigs = "()I"
        ok,ret  = luaj.callStaticMethod(className,"getScore",args,sigs)
        if not ok then
            print("luaj error:", ret)
        else
            USER_INFO["gold"] = ret
            print("getUserInfo gold:"..ret)
        end

        --获取用户昵称
        sigs = "()Ljava/lang/String;"
        ok,ret  = luaj.callStaticMethod(className,"getNickName",args,sigs)
        if not ok then
            print("luaj error:", ret)
        else
            USER_INFO["nick"] = ret
        end

        --获取校验Token
        ok,ret  = luaj.callStaticMethod(className,"getToken",args,sigs)
        if not ok then
            print("luaj error:", ret)
        else
            token = ret
            print("getUserInfo nick:"..ret)
        end

        --获取进入的游戏
        if gameTypeTTT == nil then
            sigs = "()I"
            ok,ret  = luaj.callStaticMethod(className,"getEnterGame",args,sigs)
            if not ok then
                print("luaj error:", ret)
            else
                USER_INFO["enter_mode"] = ret
            end
        end

        --用户类型
        sigs = "()Ljava/lang/String;"
        ok,ret  = luaj.callStaticMethod(className,"getUserType",args,sigs)
        if not ok then
            print("luaj error:", ret)
        else
            USER_INFO["type"] = ret
        end

        --主播id
        sigs = "()I"
        ok,ret  = luaj.callStaticMethod(className,"douniuComchorId",args,sigs)
        if not ok then
            print("luaj error:", ret)
        else
            USER_INFO["duniuCompId"] = ret
            print("douniuCompidis",USER_INFO["duniuCompId"])
        end

        --获取游戏level
        sigs = "()I"
        ok,ret  = luaj.callStaticMethod(className,"getGroupLevel",args,sigs)
        if not ok then
            print("luaj error:", ret)
        else
            USER_INFO["GroupLevel"] = ret
            print("GroupLevel",USER_INFO["GroupLevel"])
        end

        --code
        sigs = "()Ljava/lang/String;"
        ok,ret  = luaj.callStaticMethod(className,"getGameCode",args,sigs)
        if not ok then
            print("luaj error:", ret)
        else
            USER_INFO["enter_code"]  = ret
            print("enter_code",USER_INFO["enter_code"])
        end

        --获取房卡
        sigs = "()I"
        ok,ret  = luaj.callStaticMethod(className,"getCardCount",args,sigs)
        if not ok then
            print("luaj error:", ret)
        else
            USER_INFO["cardCount"]  = ret
            print("cardCount",USER_INFO["cardCount"])
        end


        --获取渠道号
        sigs = "()Ljava/lang/String;"
        ok,ret  = luaj.callStaticMethod(className,"getChannel",args,sigs)
        if not ok then
            print("luaj error:", ret)
        else
            USER_INFO["channel"]  = ret
            print("channel",USER_INFO["channel"])
        end


        

    elseif (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) or (cc.PLATFORM_OS_MAC == targetPlatform) then

        --iOS平台
        if bm.isQuickLogin == "1" then

            local uid_arr = {}

            for i = 100, 119 do
                table.insert(uid_arr, i)
            end

            math.randomseed(tostring(os.time()):reverse():sub(1, 6))
            local num = math.random(20)

            if not USER_INFO["uid"] or string.len(string.trim(USER_INFO["uid"])) <= 0 then
                UID = uid_arr[num]
                USER_INFO["uid"] = UID
            else
                UID = USER_INFO["uid"]
            end
            USER_INFO["nick"] = tostring(UID)
            USER_INFO["diamond"] = confilg_manager:get_diamond()
            USER_INFO["enter_mode"] = confilg_manager:get_enter_mode()
            USER_INFO["enter_code"] = confilg_manager:get_enter_code()
            USER_INFO["type"] ="P"
            USER_INFO["duniuCompId"]=confilg_manager:get_duniuCompId()
            USER_INFO["GroupLevel"]=confilg_manager:get_GroupLevel()

        else

            local args = {}
            local luaoc = require "cocos.cocos2d.luaoc"
            local className = "CocosCaller"

            --获取用户ID
            local ok,ret  = luaoc.callStaticMethod(className,"getUserID")
            if not ok then
                cc.Director:getInstance():resume()
            else
                USER_INFO["uid"] = ret
                UID = USER_INFO["uid"]
            end

            --获取用户金币
            ok,ret  = luaoc.callStaticMethod(className,"getScore")
            if not ok then
                cc.Director:getInstance():resume()
            else
                USER_INFO["gold"] = ret
            end

            ok,ret  = luaoc.callStaticMethod(className,"getNickName")
            if not ok then
                cc.Director:getInstance():resume()
            else
                USER_INFO["nick"] = ret
            end

            ok,ret  = luaoc.callStaticMethod(className,"getToken")
            if not ok then
                cc.Director:getInstance():resume()
            else
                token = ret
            end

            if gameTypeTTT == nil then
                ok,ret  = luaoc.callStaticMethod(className,"getEnterGame")
                if not ok then
                    cc.Director:getInstance():resume()
                else
                    USER_INFO["enter_mode"] = ret
                    print("enter mode--------------------------------->",USER_INFO["enter_mode"])
                end
            else
                USER_INFO["enter_mode"] =gameTypeTTT
            end

            ok,ret  = luaoc.callStaticMethod(className,"getGameCode")
            if not ok then
                cc.Director:getInstance():resume()
            else
                USER_INFO["enter_code"] = ret
            end

            --用户类型
            ok,ret  = luaoc.callStaticMethod(className,"getUserType")
            if not ok then
                cc.Director:getInstance():resume()
            else
                USER_INFO["type"] = ret
            end

            --主播id
            ok,ret  = luaoc.callStaticMethod(className,"douniuComchorId")
            if not ok then
                cc.Director:getInstance():resume()
            else
                USER_INFO["duniuCompId"] = ret
                print("douniuCompidis",USER_INFO["duniuCompId"])
            end

            --获取游戏level
            ok,ret  = luaoc.callStaticMethod(className,"getGroupLevel")
            if not ok then
                cc.Director:getInstance():resume()
            else
                USER_INFO["GroupLevel"] = ret
                print("GroupLevel",USER_INFO["GroupLevel"])
            end

            --  获取微信openid
            ok,ret = luaoc.callStaticMethod(className,"getWXOpenId")
            if ok then
                if type(ret) == "string" and string.len(ret) > 0 then
                    cc.UserDefault:getInstance():setStringForKey("ios_openid", ret);
                end
            end

            --  获取微信token
            ok,ret = luaoc.callStaticMethod(className,"getWXAccessToken")
            if ok then
                if type(ret) == "string" and string.len(ret) > 0 then
                    cc.UserDefault:getInstance():setStringForKey("ios_token", ret);
                    cc.UserDefault:getInstance():setStringForKey("refer_token_time", os.time())
                end
            end

            -- 获取微信refreshtokenn
            ok,ret = luaoc.callStaticMethod(className,"getWXRefreshToken")
            if ok then
                if type(ret) == "string" and string.len(ret) > 0 then
                    cc.UserDefault:getInstance():setStringForKey("ios_refres_token", ret);
                end
            end        

            --获取房卡
            ok,ret  = luaoc.callStaticMethod(className,"getCardCount")
            if not ok then
                cc.Director:getInstance():resume()
            else

                -- USER_INFO["cardCount"] = ret

                -- dump(USER_INFO["cardCount"], "-----GameData cardCount 1-----")

            end

        end
        
    else
        --其他平台

        if bm.isQuickLogin == "1" then

            dump("快速登陆", "-----快速登陆-----")

            local uid_arr = {}
            for i = 100, 119 do
                table.insert(uid_arr, i)
            end

            math.randomseed(tostring(os.time()):reverse():sub(1, 6))
            local num = math.random(20)

            UID = uid_arr[num]

            USER_INFO["uid"] = UID
            USER_INFO["nick"] = tostring(UID)
            USER_INFO["diamond"] = confilg_manager:get_diamond()
            USER_INFO["enter_mode"] = confilg_manager:get_enter_mode()
            USER_INFO["enter_code"] = confilg_manager:get_enter_code()
            USER_INFO["type"] ="P"
            USER_INFO["duniuCompId"]=confilg_manager:get_duniuCompId()
            USER_INFO["GroupLevel"]=confilg_manager:get_GroupLevel()

        else

            dump("正常登陆", "-----正常登陆-----")

            UID = confilg_manager:get_user_id("UID")
            USER_INFO["uid"] = UID
            USER_INFO["nick"] = tostring(UID)
            -- USER_INFO["gold"] = confilg_manager:get_type()
            USER_INFO["diamond"] = confilg_manager:get_diamond()
            USER_INFO["enter_mode"] = confilg_manager:get_enter_mode()
            USER_INFO["enter_code"] = confilg_manager:get_enter_code()
            -- USER_INFO["type"] =confilg_manager:get_type()
            USER_INFO["type"] ="P"
            USER_INFO["duniuCompId"]=confilg_manager:get_duniuCompId()
            USER_INFO["GroupLevel"]=confilg_manager:get_GroupLevel()

            -- USER_INFO["cardCount"] = 1000

            -- dump(USER_INFO["cardCount"], "-----GameData cardCount 2-----")

        end

    end

    -- if USER_INFO["enter_mode"] == 7 then
    --     USER_INFO["enter_game"] = 7
    -- end
    -- print("user id:"..USER_INFO["uid"].. USER_INFO["enter_mode"])
   -- print("user type:"..USER_INFO["type"])
end

--获取用户地理位置信息
function GameData:getLocation()

    if (cc.PLATFORM_OS_ANDROID == targetPlatform) then

        local args = {}
        local sigs = "()Ljava/lang/String;"
        local luaj = require "cocos.cocos2d.luaj"
        local className = luaJniClass

        ok,ret  = luaj.callStaticMethod(className,"getLongitude",args,sigs)
        if not ok then
            print("luaj error:", ret)
        else
            USER_INFO["Longitude"] = ret
        end

        ok,ret  = luaj.callStaticMethod(className,"getLatitude",args,sigs)
        if not ok then
            print("luaj error:", ret)
        else
            USER_INFO["Latitude"] = ret
        end

    elseif (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) or (cc.PLATFORM_OS_MAC == targetPlatform) then

        USER_INFO["Latitude"] = cct.getDataForApp("getLatitude", {}, "string")
        USER_INFO["Longitude"] = cct.getDataForApp("getLongitude", {}, "string")

    else

        USER_INFO["Longitude"] = "113"
        USER_INFO["Latitude"] = "23"

    end
    
end

--获取验证地址
function GameData:getVerificationAddr()
    -- body
    if USER_INFO["type"] then
        if USER_INFO["type"] == "P" or USER_INFO["type"] == "p" then
            return HttpAddr.."/playerUser/getUserInfo4GameServer"
        elseif USER_INFO["type"] == "C" or USER_INFO["type"] == "c" then
            return HttpAddr.."/compereUser/getUserInfo4GameServer"
        end
    end
    return ""
end

--获取抢主播参数
function GameData:getZbzdInfo()
    -- body
    print("getZbzdInfo")
    bm.zbzdInfo = {}

    bm.zbzdInfo["present_id"] = 200
    bm.zbzdInfo["present_sex"] = 2
    if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
        local args = {}
        local sigs = "()I"
        local luaj = require "cocos.cocos2d.luaj"
        local className = luaJniClass
        local ok,ret  = luaj.callStaticMethod(className,"getUserID",args,sigs)
        if not ok then
            print("luaj error:", ret)
        else
            bm.zbzdInfo["uid"] = ret
        end
        ok,ret  = luaj.callStaticMethod(className,"getSex",args,sigs)
        if not ok then
            print("luaj error:", ret)
        else
            bm.zbzdInfo["player_sex"] = ret
        end
        ok,ret  = luaj.callStaticMethod(className,"getPresenterId",args,sigs)
        if not ok then
            print("luaj error:", ret)
        else
            bm.zbzdInfo["present_id"] = ret
        end
        ok,ret  = luaj.callStaticMethod(className,"getPresenterSex",args,sigs)
        if not ok then
            print("luaj error:", ret)
        else
            bm.zbzdInfo["present_sex"] = ret
        end

        if gameTypeTTT == nil then
            ok,ret  = luaj.callStaticMethod(className,"getEnterGame",args,sigs)
            if not ok then
                print("luaj error:", ret)
            else
                USER_INFO["enter_mode"] = ret
            end
        end
    elseif (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) or (cc.PLATFORM_OS_MAC == targetPlatform) then
        local args = {}
        local luaoc = require "cocos.cocos2d.luaoc"
        local className = "CocosCaller"
        local ok,ret  = luaoc.callStaticMethod(className,"getUserID")
        if not ok then
            cc.Director:getInstance():resume()
        else
            bm.zbzdInfo["uid"] = ret
        end
        ok,ret  = luaoc.callStaticMethod(className,"getSex")
        if not ok then
            cc.Director:getInstance():resume()
        else
            bm.zbzdInfo["player_sex"] = ret
        end
        ok,ret  = luaoc.callStaticMethod(className,"getPresenterId")
        if not ok then
            cc.Director:getInstance():resume()
        else
            bm.zbzdInfo["present_id"] = ret
        end

        ok,ret  = luaoc.callStaticMethod(className,"getPresenterSex")
        if not ok then
            cc.Director:getInstance():resume()
        else
            bm.zbzdInfo["present_sex"] = ret
        end

        if gameTypeTTT == nil then
            ok,ret  = luaoc.callStaticMethod(className,"getEnterGame")
            if not ok then
                cc.Director:getInstance():resume()
            else
                USER_INFO["enter_mode"] = ret
                print("enter mode--------------------------------->",USER_INFO["enter_mode"])
            end
        end
    else
        bm.zbzdInfo["uid"] = 228
        bm.zbzdInfo["player_sex"] = 1
        bm.zbzdInfo["present_id"] = 208
        bm.zbzdInfo["present_sex"] = 2
    end
end

--获取组局参数
function GameData:getGroupInfo()
    print("getGroupInfo")
    USER_INFO["invote_code"] = "000000"
    USER_INFO["group_cost_rate"] = 20
    -- if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
    --     local args = {}
    --     local sigs = "()I"
    --     local luaj = require "cocos.cocos2d.luaj"
    --     local className = luaJniClass
    --     local ok,ret  = luaj.callStaticMethod(className,"getGroupTableId",args,sigs)
    --     if not ok then
    --         print("luaj error:", ret)
    --     else
    --         USER_INFO["group_tableid"] = ret
    --     end
    --     ok,ret  = luaj.callStaticMethod(className,"getReganizeId",args,sigs)
    --     if not ok then
    --         print("luaj error:", ret)
    --     else
    --         USER_INFO["activity_id"] = ret
    --     end
    --     sigs = "()Ljava/lang/String;"
    --     ok,ret  = luaj.callStaticMethod(className,"getCurrentInviteCode",args,sigs)
    --     if not ok then
    --         print("luaj error:", ret)
    --     else
    --         USER_INFO["invote_code"] = ret
    --     end
    --     sigs = "()I"
    --     ok,ret  = luaj.callStaticMethod(className,"getGroupChip",args,sigs)
    --     if not ok then
    --         print("luaj error:", ret)
    --     else
    --         USER_INFO["group_chip"] = ret
    --     end
    --     --服务费税率
    --     -- ok,ret  = luaj.callStaticMethod(className,"getGroupCostRate",args,sigs)
    --     -- if not ok then
    --     --     print("luaj error:", ret)
    --     -- else
    --     --     USER_INFO["group_cost_rate"] = ret
    --     -- end
    -- elseif (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) or (cc.PLATFORM_OS_MAC == targetPlatform) then
    --     local args = {}
    --     local luaoc = require "cocos.cocos2d.luaoc"
    --     local className = "CocosCaller"
    --     local ok,ret  = luaoc.callStaticMethod(className,"getGroupTableId")
    --     if not ok then
    --         cc.Director:getInstance():resume()
    --     else
    --         USER_INFO["group_tableid"] = ret
    --     end
    --     ok,ret  = luaoc.callStaticMethod(className,"getReganizeId")
    --     if not ok then
    --         cc.Director:getInstance():resume()
    --     else
    --         USER_INFO["activity_id"] = ret
    --     end
    --     --邀请码
    --     ok,ret  = luaoc.callStaticMethod(className,"getCurrentInviteCode")
    --     if not ok then
    --         cc.Director:getInstance():resume()
    --     else
    --         USER_INFO["invote_code"] = ret
    --     end
    --     --组局带入筹码
    --     ok,ret  = luaoc.callStaticMethod(className,"getGroupChip")
    --     if not ok then
    --         cc.Director:getInstance():resume()
    --     else
    --         USER_INFO["group_chip"] = ret
    --     end

    --     --服务费税率
    --     -- ok,ret  = luaoc.callStaticMethod(className,"getGroupCostRate")
    --     -- if not ok then
    --     --     cc.Director:getInstance():resume()
    --     -- else
    --     --     USER_INFO["group_cost_rate"] = ret
    --     -- end

    -- else
    --     USER_INFO["group_tableid"] = confilg_manager:get_group_tableid()
    --     USER_INFO["activity_id"] = confilg_manager:get_activity_id()
    --     USER_INFO["invote_code"] = confilg_manager:get_invote_code()
    --     USER_INFO["chips"] = 0
    --     USER_INFO["group_chip"] = 5000
    --     USER_INFO["start_time"] = os.time()
    --     USER_INFO["group_lift_time"] = 1000
    --     USER_INFO["group_cost_rate"] = 20
    -- end

    --检查兜币是否足够兑换
    -- print("getGroupInfo",USER_INFO["gold"])
    -- if USER_INFO["group_chip"] + USER_INFO["group_chip"]*USER_INFO["group_cost_rate"]/100 > USER_INFO["gold"] then
    --     bNotMoreMoney = true
    --     require("hall.GameTips"):showTips("兜币余额不足，请充值","change_money2chips",1)
    --     return false
    -- end
    -- bNotMoreMoney = false
    return true
end

function GameData:isNotMoreMoney(  )
    -- body
    return bNotMoreMoney
end

--获取本地重连的gameid
function GameData:getReloadGame()
    -- body
    print("getReloadGame")
    local gameid = 0
    if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
        local args = {}
        local sigs = "()I"
        local luaj = require "cocos.cocos2d.luaj"
        local className = luaJniClass
        local ok,ret  = luaj.callStaticMethod(className,"getReloadGameId",args,sigs)
        if not ok then
            print("luaj error:", ret)
        else
            gameid = ret
        end
    elseif (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) or (cc.PLATFORM_OS_MAC == targetPlatform) then
        local args = {}
        local luaoc = require "cocos.cocos2d.luaoc"
        local className = "CocosCaller"
        local ok,ret  = luaoc.callStaticMethod(className,"getReloadGameId")
        if not ok then
            cc.Director:getInstance():resume()
        else
            gameid = ret
        end
    else
        gameid = 1
    end

    return gameid
end

--游戏轨迹
--code 游戏字符串
--mode 游戏模式，自由场-->free,比赛场-->match
--chips 底分，报名费
--isPlay 0意图参加，1开始游戏
function GameData:setPlayerRoute(code,mode,chips,isPlay)
    -- body
    local str = code.."_"..mode.."_"..tostring(chips).."_"..tostring(isPlay)
    print("setPlayerRoute",str)
    if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
        -- local args = {str}
        -- local sigs = "(Ljava/lang/String;)V"
        -- local luaj = require "cocos.cocos2d.luaj"
        -- local className = luaJniClass
        -- local ok,ret  = luaj.callStaticMethod(className,"LuaMobClick",args,sigs)
        -- if not ok then
        --     print("luaj error:", ret)
        -- end
    elseif (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) or (cc.PLATFORM_OS_MAC == targetPlatform) then
        local args = {str1=str}
        local luaoc = require "cocos.cocos2d.luaoc"
        local className = "CocosCaller"
        local ok,ret  = luaoc.callStaticMethod(className,"LuaMobClick",args)
        if not ok then
            cc.Director:getInstance():resume()
        end
    end
end

--获取本地游戏版本号
function GameData:getGameVersion(game)

    local strKey = game.."_current-version"
    print("get version key:"..strKey)
    local strVersion = cc.UserDefault:getInstance():getStringForKey(strKey,"")
    print("-----获取["..game.."] 版本号是：["..strVersion.."]")
    return strVersion
    
end

--比较本地版本
function GameData:compareLocalVersion(version,game)
    -- body
    if version == nil then
        return 0
    end


    local lVersion = self:getGameVersion(game)
    local tbLocal = {}
    local tbRemote = {}

    local tem,nPos = string.find(lVersion,"%.")
    for i = 1, string.len(lVersion) do
        local strPic = string.sub(lVersion,1,nPos-1)
        table.insert(tbLocal,strPic)
        lVersion = string.sub(lVersion,nPos+1,string.len(lVersion))
        tem,nPos = string.find(lVersion,"%.")
        if tem == nil then
            table.insert(tbLocal,lVersion)
            break
        end
    end

    lVersion = version
    local tem,nPos = string.find(lVersion,"%.")
    for i = 1, string.len(lVersion) do
        local strPic = string.sub(lVersion,1,nPos-1)
        table.insert(tbRemote,strPic)
        lVersion = string.sub(lVersion,nPos+1,string.len(lVersion))
        tem,nPos = string.find(lVersion,"%.")
        if tem == nil then
            table.insert(tbRemote,lVersion)
            break
        end
    end

    if #tbLocal == 0 then
        return 1
    end

    for i = 1,#tbRemote do
        local subLocal = tonumber(tbLocal[i])
        local subRemote = tonumber(tbRemote[i])
        print("subLocal:"..subLocal.."   subRemote:"..subRemote)
        if subRemote > subLocal then
            print("new version["..game.."]")
            return 1
        end
    end

    return 0
end

--loading

function GameData:getFreeGameCount(  )
	-- body
	return nFreeGameCounts
end
function GameData:getMatchGameCount(  )
	-- body
	return nMatchGameCounts
end
function GameData:addFreeGame()
	-- body
	nFreeGameCounts = nFreeGameCounts + 1
	require("hall.GameSetting"):HttpAddFreeGame()
    cc.UserDefault:getInstance():setIntegerForKey("free_game_counts", nFreeGameCounts)
end

function GameData:addMatchGame()
	-- body
	nMatchGameCounts = nMatchGameCounts + 1
	--如果够100次，发送任务请求
	if nMatchGameCounts >= 100 then
		self:HttpAddMatchGame()
	end
    cc.UserDefault:getInstance():setIntegerForKey("match_game_counts", nMatchGameCounts)
end

--进入比赛
function GameData:enterMatch(gid)
    -- body
    USER_INFO["match_game_id"] = gid

    
end

-- 设置玩家IP
function GameData:setUserIP(_uid, _ip)
    if bm.Room == nil then
        bm.Room = {}
    end
    if bm.Room.ipList == nil then
        bm.Room.ipList = {}
    end
    bm.Room.ipList[tonumber(_uid)] = _ip
end
-- 获取玩家IP
function GameData:getUserIP(_uid)
    if bm.Room == nil then
        return "0.0.0.0"
    end
    if bm.Room.ipList == nil then
        return "0.0.0.0"
    end
    if bm.Room.ipList[tonumber(_uid)] == nil then
        return "0.0.0.0"
    end
    return bm.Room.ipList[tonumber(_uid)]
end


return GameData
