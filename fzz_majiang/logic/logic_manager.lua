Logic_Manager = class("Logic_Manager")
mrequire("account.account_operator")

function Logic_Manager:ctor()
	-- body
	self.HttpAddr = ""
	self.usertype = "P"
    self.Profile = "playerProfile"

    self.enter_mode = 0 --进入的方式，是组局还是普通的进大厅
    self.reloadTable = 0 --重登的桌子id
    self.reload_gameid = 0--重登的游戏id

    self.hall_gamelist = {}
end

function Logic_Manager:initialize()

    --创建用户，初始化用户数据内容
    account.account_operator.init_account_object(USER_INFO["icon_url"],USER_INFO["nick"],0,USER_INFO["sex"],USER_INFO["uid"])

   --  local ZZ_Handle = require("fzz_majiang.ZZ_Handle")
   --  local tbl = {}
   --  tbl.gold = 100
   --  tbl.seat_id = 0
   -- ZZ_Handle:SVR_LOGIN_ROOM(tbl)
    
    -- local tbl = {
    --     ["deuceCount"]=23,
    --     ["level"]=3,
    --     ["levelName"]="高级士兵",
    --     ["smallHeadPhoto"]="http://tp3.sinaimg.cn/1345557342/50/5604388985/1",
    --     ["nickName"]="Lander",
    --     ["money"]=6473,
    --     ["largeHeadPhoto"]="http://tp3.sinaimg.cn/1345557342/180/5604388985/1",
    --     ["sex"]=0,
    --     ["winCount"]=50,
    --     ["loseCount"]=84
    -- }
   
--    local pack =  {

--         ["cmd"]       = 4109

--         ["if_ready"]  = 1

--         ["seat_id"]   = 1

--         ["uid"]       = 1345557342

--         ["user_gold"] = 6473

--         ["user_info"] = jsn.encode(tbl)
-- }
  --  ZZ_Handle:SVR_SEND_USER_CARD(pack)



 --    self:getReloadGameId()
 --    self:init_gametype()
    
 --    if self.enter_mode >=1 and  self.enter_mode < 7 then`
 --        self:getGroupInfo()
 --    end

	-- self:init_HttpAddr()
	-- self:init_usertype()
	-- self:Request_Userdata()
    
    --组局方式


    -- body
    --print("self.HttpAddr------------",self.HttpAddr)

    --连接socket
    -- 发送登陆消息
    -- 0x116    --登录大厅
    
    -- local pack = bm.server:createPacketBuilder(PROTOCOL.CLI_LOGIN)
    --     :setParameter("uid", UID)
    --     :setParameter("storeId", 1)
    --     :setParameter("kind", 1)
    --     :setParameter("userInfo", USER_INFO["user_info"])       
    --     :build()

   -- local pack = {} 
    --pack["Ver"] = 1
    --pack["Tid"] = 0

   --self:SVR_LOGIN_OK(pack)


  
end

function Logic_Manager:init_gametype()
    -- body
     local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if (cc.PLATFORM_OS_IPHONE == targetPlatform) 
        or (cc.PLATFORM_OS_IPAD == targetPlatform) 
        or (cc.PLATFORM_OS_MAC == targetPlatform) then

        local args = {}
        local luaoc = require "cocos.cocos2d.luaoc"
        local className = "GlobalVariable"

         --获取游戏的类型
        local ok,gameType  = luaoc.callStaticMethod(className,"getEnterGame")
        if not ok then
            cc.Director:getInstance():resume()
        else
            -- USER_INFO["enter_mode"] = ret
            -- print("enter mode--------------------------------->",USER_INFO["enter_mode"])
        end

        --获取当前的分辨率
        local ok,ret 
        ok,ret= luaoc.callStaticMethod(className,"getDeviceSize")
        if not ok then
            cc.Director:getInstance():resume()
        else
            local str,swidth,sheight
            str = ret
            print(string.len(str))
            swidth=tonumber(string.sub(str,1,string.find(str,",")-1))
            sheight = tonumber(string.sub(str,string.find(str,",")+1,string.len(str)))
            self.enter_mode =gameType

            
            if gameType==7 then
                --todo
                cc.Director:getInstance():getOpenGLView():setFrameSize(swidth,(swidth/640)*500);
                cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(640,500,0)
            else
                cc.Director:getInstance():getOpenGLView():setFrameSize(swidth,sheight);
                cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(960,540,cc.ResolutionPolicy.SHOW_ALL)
            end
        end
    elseif device.platform == "android" then
        local args = {}
        local sigs = "()I"
        local luaj = require "cocos.cocos2d.luaj"
        local className = luaJniClass
        --local ok,ret  = luaj.callStaticMethod(className,"getUserID",args,sigs)

        --获取游戏level
        --sigs = "()I"

        local ok,ret  = luaj.callStaticMethod(className,"getEnterGame",args,sigs)
        if not ok then
            print("luaj error:", ret)
             self.enter_mode = 0
        else
             self.enter_mode = ret
           -- print("getEnterGame",USER_INFO["GroupLevel"])
        end

        --获取当前的分辨率
        local ok,ret 
        sigs = "()Ljava/lang/String;"
        ok,ret= luaj.callStaticMethod(className,"getDeviceSize",args,sigs)
        if not ok then
            cc.Director:getInstance():resume()
        else
            local str,swidth,sheight
            str = ret
            print(string.len(str))
            swidth=tonumber(string.sub(str,1,string.find(str,",")-1))
            sheight = tonumber(string.sub(str,string.find(str,",")+1,string.len(str)))
            
            if  self.enter_mode == 7 then
                --todo
                cc.Director:getInstance():getOpenGLView():setFrameSize(swidth,(swidth/640)*500);
                cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(640,500,0)
            else
                cc.Director:getInstance():getOpenGLView():setFrameSize(swidth,sheight);
                cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(960,540,cc.ResolutionPolicy.SHOW_ALL)
            end
        end
    else
    end
end

function Logic_Manager:init_HttpAddr()
	-- body
	local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
        local args = {}
        local sigs = "()Ljava/lang/String;"
        local luaj = require "cocos.cocos2d.luaj"
        local className =luaJniClass
        local ok,ret  = luaj.callStaticMethod(className,"getHttpAddr",args,sigs)
        if not ok then
            print("luaj error:", ret)
        else
            self.HttpAddr = ret
        end

    elseif (cc.PLATFORM_OS_IPHONE == targetPlatform) 
    	or (cc.PLATFORM_OS_IPAD == targetPlatform) 
    	or (cc.PLATFORM_OS_MAC == targetPlatform) then

        local args = {}
        local luaoc = require "cocos.cocos2d.luaoc"
        local className = "GlobalVariable"
        local ok,ret  = luaoc.callStaticMethod(className,"getHttpAddr")
        if not ok then
           print("get HttpAddr error-------------------------")
        else
            self.HttpAddr = ret
        end
    else
    	self.HttpAddr = macros.get_macros_str_value("HttpAddr")
    end
end

function Logic_Manager:init_usertype( )
	-- body
	local targetPlatform = cc.Application:getInstance():getTargetPlatform()

	if (cc.PLATFORM_OS_IPHONE == targetPlatform) 
		or (cc.PLATFORM_OS_IPAD == targetPlatform) 
		or (cc.PLATFORM_OS_MAC == targetPlatform) then

        local args = {}
        local luaoc = require "cocos.cocos2d.luaoc"
        local className = "GlobalVariable"
        --用户类型
        ok,ret  = luaoc.callStaticMethod(className,"getUserType")
        if not ok then
        else
            self.usertype = ret
        end

    end
end

function Logic_Manager:Request_Userdata()
	-- body

    local httpurl  = ""
 	if self.usertype == "P" or  self.usertype == "p" then
 		httpurl = macros.get_macros_str_value("pHttpAddr")
         self.Profile = "playerProfile"

 	elseif self.usertype == "C" or  self.usertype == "c" then
 		httpurl = macros.get_macros_str_value("cHttpAddr")
         self.Profile = "compereProfile"
 	end

 	if httpurl ~= "" then
 		httpurl = self.HttpAddr .. httpurl
 	end
 	if httprq == nil then
 		print("nil--------httprq----------")
 	end
    print("httpurl-----",httpurl)

    local url = "http://douyou.net.cn/hbiInterface/playerUser/getUserInfo4GameServer"
    local tbl = {}
    tbl["userId"] = 517

 	httprq.createHttRq(tbl,url)
end

function Logic_Manager:rq_gamelist_callback(callback_data)
	dump(callback_data)
    local gamelist = json.decode(callback_data.netData)
    local data = gamelist["data"]
    if data == nil then
        -- require("hall.GameCommon"):showLoadingTips("登录验证出错")
    else
      local profile = data[self.Profile]
      if profile == nil then
         -- require("hall.GameCommon"):showLoadingTips("登录验证出错")
      else
            if userinfo["mtKey"] == nil then
                -- require("hall.GameCommon"):showLoadingTips("登录验证出错")
            else

                local tbData = {}
                tbData["level"] = profile["level"]
                tbData["nickName"] = profile["nickName"]
                tbData["photoUrl"] = profile["photoUrl"]
                tbData["sex"] = profile["sex"]
                tbData["money"] = profile["coinAmount"]

                USER_INFO["user_info"] = json.encode(tbData)
                USER_INFO["gold"] = data["coinAmount"] or 1000000
                USER_INFO["diamond"] = data["jewelAmount"] or 10000
                USER_INFO["nick"] = data["nickName"] or "luoye"
                USER_INFO["pLevel"] = data["level"] or 100
                USER_INFO["sex"] = tonumber(data["sex"]) or 1
                USER_INFO["icon_url"] = data["photoUrl"] or ""

                local hall = data["hall"] or {}
                self.port = hall["port"]
                self.ip = hall["ip"]
            end
      end
    end
end


function Logic_Manager:SVR_LOGIN_OK( pack )
    -- body
    if pack and pack["Ver"] == 1 then
       self.reloadTable = pack["Tid"]

       if self.reloadTable == 0 and self.enter_mode  == 0 then

            if macros.get_macros_number_value("test_flag") == 1 then

                local FileUtils = require("fzz_majiang.fileutils")
                local str = FileUtils:getStringFromFile("config/test/" .. "gamelist.json")

                local root_table = json.decode(str)
                dump(root_table)
                --display_scene("hall.gameScene",1)

                --直接进大厅
            local layout_object = layout.reback_layout_object("Hall")
            layout_object:set_game_list(root_table.data)
             
             --layout.reback_layout_object("guide")
            end
       end

        -- if self.enter_mode > 0 then --组局方式

        --     if self.reloadTable > 0 then
        --     else
        --         require("hall.GameUpdate"):enterScene(USER_INFO["enter_code"])
        --     end

        -- else --大厅
        --     if self.reloadTable > 0 then

        --     else

        --     end
        -- end
    end
end

--获取组局参数
function Logic_Manager:getGroupInfo()

    if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
        local args = {}
        local sigs = "()I"
        local luaj = require "cocos.cocos2d.luaj"
        local className = luaJniClass
        local ok,ret  = luaj.callStaticMethod(className,"getGroupTableId",args,sigs)
        if not ok then
            print("luaj error:", ret)
        else
            USER_INFO["group_tableid"] = ret
        end
        ok,ret  = luaj.callStaticMethod(className,"getReganizeId",args,sigs)
        if not ok then
            print("luaj error:", ret)
        else
            USER_INFO["activity_id"] = ret
        end
        sigs = "()Ljava/lang/String;"
        ok,ret  = luaj.callStaticMethod(className,"getCurrentInviteCode",args,sigs)
        if not ok then
            print("luaj error:", ret)
        else
            USER_INFO["invote_code"] = ret
        end
        sigs = "()I"
        ok,ret  = luaj.callStaticMethod(className,"getGroupChip",args,sigs)
        if not ok then
            print("luaj error:", ret)
        else
            USER_INFO["group_chip"] = ret
        end
        --服务费税率
        -- ok,ret  = luaj.callStaticMethod(className,"getGroupCostRate",args,sigs)
        -- if not ok then
        --     print("luaj error:", ret)
        -- else
        --     USER_INFO["group_cost_rate"] = ret
        -- end
    
    elseif (cc.PLATFORM_OS_IPHONE == targetPlatform) 
    or (cc.PLATFORM_OS_IPAD == targetPlatform) 
    or (cc.PLATFORM_OS_MAC == targetPlatform) then
        local args = {}
        local luaoc = require "cocos.cocos2d.luaoc"
        local className = "GlobalVariable"
        local ok,ret  = luaoc.callStaticMethod(className,"getGroupTableId")
        if not ok then
            cc.Director:getInstance():resume()
        else
            USER_INFO["group_tableid"] = ret
        end
        ok,ret  = luaoc.callStaticMethod(className,"getReganizeId")
        if not ok then
            cc.Director:getInstance():resume()
        else
            USER_INFO["activity_id"] = ret
        end
        --邀请码
        ok,ret  = luaoc.callStaticMethod(className,"getCurrentInviteCode")
        if not ok then
            cc.Director:getInstance():resume()
        else
            USER_INFO["invote_code"] = ret
        end
        --组局带入筹码
        ok,ret  = luaoc.callStaticMethod(className,"getGroupChip")
        if not ok then
            cc.Director:getInstance():resume()
        else
            USER_INFO["group_chip"] = ret
        end

        --服务费税率
        -- ok,ret  = luaoc.callStaticMethod(className,"getGroupCostRate")
        -- if not ok then
        --     cc.Director:getInstance():resume()
        -- else
        --     USER_INFO["group_cost_rate"] = ret
        -- end

    else
        USER_INFO["group_tableid"] = confilg_manager:get_group_tableid()
        USER_INFO["activity_id"] = confilg_manager:get_activity_id()
        USER_INFO["invote_code"] = confilg_manager:get_invote_code()
        USER_INFO["chips"] = 0
        USER_INFO["group_chip"] = 5000
        USER_INFO["start_time"] = os.time()
        USER_INFO["group_lift_time"] = 1000
        USER_INFO["group_cost_rate"] = 20
    end
end

--获取本地重连的gameid
function Logic_Manager:getReloadGameId()
    if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
        local args = {}
        local sigs = "()I"
        local luaj = require "cocos.cocos2d.luaj"
        local className = luaJniClass
        local ok,ret  = luaj.callStaticMethod(className,"getReloadGameId",args,sigs)
        if not ok then
            print("luaj error:", ret)
        else
            self.reload_gameid  = ret
        end
    elseif (cc.PLATFORM_OS_IPHONE == targetPlatform) 
        or (cc.PLATFORM_OS_IPAD == targetPlatform) 
        or (cc.PLATFORM_OS_MAC == targetPlatform) then

        local args = {}
        local luaoc = require "cocos.cocos2d.luaoc"
        local className = "GlobalVariable"
        local ok,ret  = luaoc.callStaticMethod(className,"getReloadGameId")
        if not ok then
            cc.Director:getInstance():resume()
        else
            self.reload_gameid  = ret
        end
    else
        self.reload_gameid  = 4
    end
end