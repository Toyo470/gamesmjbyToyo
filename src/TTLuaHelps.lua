--
-- Author: tao
-- Date: 2016-03-16 12:39:22
-- 
--

local Node=cc.Node
function Node:gsize()
    -- body
    return {width=self:getContentSize().width,height=self:getContentSize().height}
end
function Node:ssize(width,height)
    -- body
    return self:setContentSize(width,height)
end

function Node:getWidth()
    return self:gsize().width
end

function Node:getHeight()
    return self:gsize().height
end

function Node:getPosition()
    return {x=self:getPositionX(),y=self:getPositionY()}
end

function Node:seekNodeByName(parNode,name)
    return parNode:getNode(name)
end


-- function Node:setNodeEventEnabled()
--     self:enableNodeEvents()
-- end

-- function Node:setTouchEnabled(isTouch)
--     if isTouch then
--         --todo
--         local listener = cc.EventListenerTouchOneByOne:create()
--         --listener:setSwallowTouches(self._swallowsTouches)
--         self.event_touch=listener
       
        
--     else
--         if not self.event_touch then
--             --todo
--             return;
--         end
--         local eventDispatcher = self:getEventDispatcher()
--         eventDispatcher:removeEventListener(self.event_touch)
--         self.event_touch=nil;
--         self._swallowsTouches=nil;
--         self._TouchCall=nil;

--     end
    
-- end


function Node:performWithDelay(callback, delay)
    local action = transition.sequence({
        cc.DelayTime:create(delay),
        cc.CallFunc:create(callback),
    })
    self:runAction(action)
    return action
end

-- function Node:setTouchSwallowEnabled(bl)

--      if not self.event_touch then
--             --todo
--             return;
--         end
--         self._swallowsTouches=bl
--     self.event_touch:setSwallowTouches(self._swallowsTouches)
-- end



--点击的处理
local widget=ccui.Widget
local playdefine_sound="hall/audio/Audio_Button_Click.mp3"--默认播放的声音
local btnsoundoff=false --按钮声音的开关
function Node:onClick(callback,playSound)
    if  not self.noScale then 
        --todo
        self:setAnchorPoint(cc.p(0.5,0.5))
    end

    local isWidget=false
    self:setTouchEnabled(true);
   
    playSound=playSound or playdefine_sound

    local function clickCallfun(event)
         print(self.onTouch,"claickjhhh",self:getName(),tolua.type(self),event.name)

        if event.name=="began" then --按下
            --todo
            if not self.noScale then
                self:setScale(0.8)
            end


            if self.isNetClick then
                --todo
                self:setTouchEnabled(false)
            end

            if not tolua.isnull(self) and  not isWidget then
                 callback(event.target)
            end
    
        end
        
        if event.name=="ended" or event.name == "cancelled" then
            --todo
            if btnsoundoff then
                --todo
                audio.playEffectSound(playSound, false)
            end

            if not tolua.isnull(self) then
                --todo
                if not self.noScale then
                    self:setScale(1)
                end
                event.target=event.target or self;
                callback(event.target)
            end
            
        end

        if not isWidget then
            --todo
            --print("notISWidget")
            return false-- false吞噬事件   true   不吞噬事件  
        end

    end


    if self.onTouch then -- is widget
        --todo
        isWidget=true
        self:onTouch(clickCallfun)
       
    else --is node
        isWidget=false 
       -- self:setTouchSwallowEnabled(false)  
       -- self:addNodeEventListener( cc.NODE_TOUCH_EVENT,clickCallfun)
        
    end
end


-- cc.NODE_TOUCH_EVENT="node_touch_event"
-- cc.NODE_ENTER_FRAME_EVENT="node_event_frame_event"
-- function Node:addNodeEventListener(eventType,callFunc)
--     if eventType==cc.NODE_TOUCH_EVENT then
--         --todo
--          local function onTouchBegan(touch, event)

--             print("nimade",self:getWidth(),self:getHeight())
--             local pos = touch:getLocation()
--             local mytets=self:convertToNodeSpace(pos)
--             if cc.rectContainsPoint(cc.rect(0,0,self:getWidth(),self:getHeight()), mytets ) then
--                 self.ismoveIn=true
--                 return callFunc({
--                     name="began",
--                     target=self,
--                     x=pos.x,
--                     y=pos.y,
--                 })
--             end
--             return false

--         end

--         local function onTouchMoved(touch, event)
--             local pos = touch:getLocation()
--             local mytets=self:convertToNodeSpace(pos)
            
              
--             if cc.rectContainsPoint(cc.rect(0,0,self:getWidth(),self:getHeight()), mytets ) then
--                 self.ismoveIn=true
--                 callFunc({
--                     name="moved",
--                     target=self,
--                     x=pos.x,
--                     y=pos.y,
--                 })
--             else --called
--                 self.ismoveIn=false
--                 if self.ismoveIn  then
--                     --todo
--                     callFunc({
--                     name="ended",
--                     target=self,
--                     x=pos.x,
--                     y=pos.y,
--                 })
--                 end
                
--             end
--         end

--         local function onTouchEnded(touch, event)
--             local pos = touch:getLocation()

--             local mytets=self:convertToNodeSpace(pos)

--             if cc.rectContainsPoint(cc.rect(0,0,self:getWidth(),self:getHeight()), mytets ) then
--                 self.ismoveIn=false
--                 callFunc({
--                     name="ended",
--                     target=self,
--                     x=pos.x,
--                     y=pos.y,
--                 })
--             end
--         end



--         local listener = self.event_touch
--         listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
--         listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
--         listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
--         local eventDispatcher = self:getEventDispatcher()
--         eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
--     end
-- end

cct=cct or {}
local isFirst=false
function cct.luataoPrint(...)
    -- body
    if device.platform~="windows" then
    	return;
    end

    local tbpri={...}
    local str=""
    for i,v in ipairs(tbpri) do
        if type(v)=="table" then
            dump(v)
        else
            str=str..v.."  "
        end
    end

    local file
    if not isFirst then
        --todo
        file = io.open("./taoLog.log","w")
        isFirst=true
    else
        file = io.open("./taoLog.log","a")
    end
    io.output(file)
    io.write(str.."\n")
    io.close(file)
end

local function createHTTPRequest(callback, url, method)
    if not method then method = "GET" end
    if string.upper(tostring(method)) == "GET" then
        method = 0
    else
        method = 1
    end
    return cc.HTTPRequest:createWithUrl(callback, url, method)
end

 local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
function cct.createHttpDwon(url,callBack)
    if type(url)~="string" or type(callBack)~="function" then
        --todo
        return;
    end
    local req=createHTTPRequest(callBack,url,"GET")
    req:start()
    return req
end
network = network or {}
network.createHTTPRequest=createHTTPRequest

--创建一个http请求
function cct.httpReq1(parm)
    print("parm==",parm)
    local url=parm.url;
    local date=parm.date or parm.data or  {}
    local callBack=parm.callBack 
    local type_=parm.type_ or "POST"
    local arg=parm.arg or {}
    -- body
    local function reqCallback(event)
        -- body
        local ok = (event.name == "completed")
        local request = event.request
        print("ok====",ok)
        if not ok then
            -- 请求失败，显示错误代码和错误消息
            print(request:getErrorCode(), request:getErrorMessage())

            if request:getErrorCode()~=0 then
                --todo
                local errorMsg=request:getErrorMessage();

                print("getHttp error1",code,url)
                print("errorMsg",errorMsg);
  
            end
            return;
        end

     
        local code = request:getResponseStatusCode()
        print("code-======",code)
        if code ~= 200 then
            -- 请求结束，但没有返回 200 响应代码
            return
        end
        
        scheduler.unscheduleGlobal(parm.handle)

        -- 请求成功，显示服务端返回的内容
        local response = request:getResponseString()
        if parm.oldapi then
                --todo
            arg.net=event
            arg.netData=response
            callBack(arg)
        else
           
            output = json.decode(response,1)
            callBack(output,parm)
        end

    end

    print(type_,"请求类型");
    if type_=="GET" then
        local str="?"
        for k,v in pairs(date) do
            str=str..k.."="..v.."&"
        end
        url=url..str
    end

    print("getHttpUrl",url,type_);
    dump(date)


    local request = createHTTPRequest(reqCallback, url, type_)
    request:addRequestHeader(0)

    if type_=="POST" then
        for k,v in pairs(date) do
            request:addPOSTValue(k, v)
        end
    end
    request:setTimeout(30)
    -- 开始请求。当请求完成时会调用 callback() 函数
    request:start()
    parm.handle=scheduler.performWithDelayGlobal(function ( ... )
        -- body
        local function call(code,data)
            if code=="canle" then
                    --todo
                cct.httpReq1(data)
            else
                cct.httpReq1(data)
            end
        end
        require("app.HallUpdate"):showTips("连接超时了",1,call,parm)
            
    end, 31)


    return request
end




 function cct.httpReq(parm)


     local url=parm.url;
     local date=parm.data or parm.date or  {}
     local callBack=parm.callBack
     local type_=parm.type_ or "GET"
     local arg=parm.arg or {}
     local requType=parm.requType or cc.XMLHTTPREQUEST_RESPONSE_JSON
     local oldapi=parm.oldapi


     local handle = 1

     local xhr = cc.XMLHttpRequest:new()
     xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON

    dump(date);

     url=url.."?"
     for k,v in pairs(date) do
         --[[if type(v)~="number" or type(v)~="string" then
            local message=debug.traceback("", 2)
            if device.platform ~= "windows" then
                
                buglyReportLuaException(tostring(message), debug.traceback())
            else
                error(message);
            end
         else]]
            url=url..k.."="..v.."&"
         --end
         
     end
     xhr:open(type_, url)

     print("send http require",url)

     local function onReadyStateChanged()
         if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then

             local response   = xhr.response
             local output = response
             scheduler.unscheduleGlobal(parm.handle)

             if oldapi then
                 --todo
                 arg.net=xhr
                 arg.netData=response
                 callBack(arg)
             else
                 if requType==cc.XMLHTTPREQUEST_RESPONSE_JSON then
                     --todo
                     output = json.decode(response,1)
                 end

                 callBack(output,parm)
             end
            

         else
             print("xhr.readyState is:", xhr.readyState, "xhr.status is: ",xhr.status)
         end

         xhr:unregisterScriptHandler()
     end


     xhr:registerScriptHandler(onReadyStateChanged)
     xhr:send()


     parm.handle=scheduler.performWithDelayGlobal(function ( ... )
        -- body
        local function call(code,data)
            if code=="canle" then
                    --todo
                -- cc.Director:getInstance():endToLua()
                -- os.exit(0);
                cct.httpReq(data)
            else
                cct.httpReq(data)
            end
        end
        require("app.HallUpdate"):showTips("连接超时了",1,call,parm)
            
    end, 31)

 end

local http= require("httpReq")
function cct.httpReq2(parm)
    --req.new(parm)
    -- local httpAre=NewHttpAddr

    -- if parm.isnew then
    --     --todo
    --     httpAre=NewHttpAddr
    -- end
    -- parm.urls=parm.url
    -- print(parm.url,#cct.split(parm.url,"http"),"reqhttpurl")

    -- if #cct.split(parm.url,"http")<2 then
    --     --todo
    --     parm.url=httpAre..parm.url
    -- end


    http.new(1,parm)  --1111




    --cct.httpReq(parm)
end

cct.createHttRq=function(parm)


    if parm.oldapi~=nil then
        parm.oldapi=parm.oldapi
    else
        parm.oldapi=true
    end


    -- parm.urls=parm.url
    -- print(parm.url,#cct.split(parm.url,"http"))
    
    http.new(2,parm)




    --cct.httpReq1(parm)
end

function cct.seekNode(root,seekVal)
    if not root then
        --todo
        return null
    end
    local t=type(seekVal)
    if t=="string" then
        --todo
        if root:getName()==seekVal then
            return root;
        end
    else
        if root:getTag()==seekVal then
            return root;
        end
    end
    local rootChildren=root:getChildren()
    for k,v in pairs(rootChildren) do
        local _root=v
        if _root then
            --todo
            local node=nil
            if t=="string" then
                node=cct.seekNode(_root,seekVal)
            else
                node=cct.seekNode(_root,seekVal)
            end
            if node then
                return node
            end
        end

    end

    return nil;
end

function Node:getNode(name)
    local node=nil
    local t=type(name)
    if t=="string"  then
        --todo
        if name=="" then
            --todo
            return node;
        end
        node=self:getChildByName(name)
    else
        node=self:getChildByTag(name)
    end
    
    if not node then
        node=cct.seekNode(self,name)
    end
    return node;
end

function cct.getTabMax(tb,key)
    -- body
    local max=0
    for k,v in pairs(tb) do
        if key then
           v=v[key]
        end
        if type(v)=="number" then
            --todo
            if v>max then
                --todo
                max=v;
            end
        end 
    end
    return max
end


function cct.LuaReomveChar(str,remove)  
    local lcSubStrTab = {}  
    while true do  
        local lcPos = string.find(str,remove)  
        if not lcPos then  
            lcSubStrTab[#lcSubStrTab+1] =  str      
            break  
        end  
        local lcSubStr  = string.sub(str,1,lcPos-1)  
        lcSubStrTab[#lcSubStrTab+1] = lcSubStr  
        str = string.sub(str,lcPos+1,#str)  
    end  
    local lcMergeStr =""  
    local lci = 1  
    while true do  
        if lcSubStrTab[lci] then  
            lcMergeStr = lcMergeStr .. lcSubStrTab[lci]   
            lci = lci + 1  
        else   
            break  
        end  
    end  
    return lcMergeStr  
end  

--从App获取数据

function cct.getDataForApp(method,args,sig)

    if type(method) ~="string" then
        --todo
        return;
    end
    local retval
    if device.platform=="ios" then
        --todo
        -- local args = args or {}
        local luaoc = require "cocos.cocos2d.luaoc"
        local className =ios_class

        local ok,ret
        if table.nums(args) > 0 then
            --todo
            ok,ret  = luaoc.callStaticMethod(className,method,args)
        else
            ok,ret  = luaoc.callStaticMethod(className,method)
        end
        if not ok then
            cc.Director:getInstance():resume()
        else
            retval=ret
        end
    elseif device.platform=="android" then
        --todo
        local args =args or {}
        local luaj = require "cocos.cocos2d.luaj"
        local className =luaJniClass

         local sigs="("
         for k,v in pairs(args) do
             local t=type(v)
             if t=="string" then
                 --todo
                 sigs=sigs.."Ljava/lang/String;"
             elseif t=="number" or t=="function" then
                 sigs=sigs.."I"
             end
         end
         sigs=sigs..")"
         sigs=sigs..sig


        local ok,ret  = luaj.callStaticMethod(className,method,args,sigs)
        if not ok then
            print("luaj error:", ret)
        else
            retval = ret
        end
    else

    end

    return retval
end

cct.getDateForApp=cct.getDataForApp

-- Compatibility: Lua-5.1
function cct.split(str, pat)


   -- local t = {}  -- NOTE: use {n = 0} in Lua-5.0
   -- local fpat = "(.-)" .. pat
   -- local last_end = 1
   -- local s, e, cap = str:find(fpat, 1)
   -- while s do
   --    if s ~= 1 or cap ~= "" then
   --   table.insert(t,cap)
   --    end
   --    last_end = e+1
   --    s, e, cap = str:find(fpat, last_end)
   -- end
   -- if last_end <= #str then
   --    cap = str:sub(last_end)
   --    table.insert(t, cap)
   -- end
   -- return t
    return string.split(str,pat);
end

---- 通过日期获取秒 yyyy-MM-dd HH:mm:ss
function cct.GetTimeByDate(r)
    local a = cct.split(r, " ")
    local b = cct.split(a[1], "-")
    local c = cct.split(a[2], ":")
    local t = os.time({year=b[1],month=b[2],day=b[3], hour=c[1], min=c[2], sec=c[3]})
    return t;
end


--设置当前表只读
function cct.setTableOnRead(t)
    local temp= t or {} 
    local mt = {
        __index = function(t,k) return temp[k] or printError("error seek table %s not found", k) end;--查key
        __newindex = function(t, k, v) --设置表值
            error("attempt to update a read-only table!")
        end
    }
    setmetatable(temp, mt) 
    return temp
end


-- 移除表中的值
function cct.tableremovevalue(array,value,removeall)
    return table.removebyvalue(array, value, removeall)
end

-- tiemr 秒 返回 str00:00:00
--v 显示的数目
function cct.timerstostr(times,v)

    --timer is sec
    local h=0
    local m=0
    local s=0
    local function toStr(m_)
        local str=""
        if m_==0 or m_=="0" then
            --todo
            str="00"
        elseif m_<10 then
            --todo
            str="0"..m_
        elseif m_>99 then
            str="99"
        else
            str=m_
        end

        return str
    end
    if times>60*60 then
            --todo
        h=math.floor(times/(60*60))
        times=times-h*(60*60)
    end
    
    if times>60 then
            --todo
        m=math.floor(times/(60))
        times=times-m*(60)
    end
    s=math.floor(times)

    local str=""

    if v==1 then
        --todo
        str=toStr(s);
    elseif v==2 then
        str=toStr(m)..":"..toStr(s)
    else
        str=toStr(h)..":"..toStr(m)..":"..toStr(s)
    end
    

    return str;
end

--从内存中卸载没有使用 Sprite Sheets 删除材质 
--  purgeCachedData  删除所有的缓存
function cct.removeUnusedSpriteFrames()
    display.removeUnusedSpriteFrames()
end

--裁剪规则的图片
--通过自定义字典
function cct.addSpriteFrames(dict,png)
    display.addImageAsync(png, function()end)
    for k,v in pairs(dict) do
       local spr = cc.SpriteFrame:create(png,v)
       cc.SpriteFrameCache:getInstance():addSpriteFrame(spr,k);
    end
    cc.TextureCache:getInstance():removeTextureForKey(png)
end


function cct.nodeActionRepeat(node,callBack,delay)
    node:runAction(cc.RepeatForever:create(
            cc.Sequence:create(
                    cc.DelayTime:create(delay or 1),
                    cc.CallFunc:create(callBack)
                )
        ))
end


function cct.devlayCall( node,callBack,delay )
    -- body
    
    print(node,callBack,delay,"devlayCall")
    local ac= cc.Sequence:create(
                    cc.DelayTime:create(delay or 1),
                    cc.CallFunc:create(callBack)
                )
    node:runAction(ac)
end



cct.runErrorScene=function (msg)
   

    if not isShowErrorScene then --不显示错误的提示
        --todo
        print("监听到错误")
        -- print("App  is error");
        -- require("app.MyApp").new():run()
        return
    end
    --display.removeUnusedSpriteFrames()

    local lab=display.newTTFLabel({
        text = msg,
        font = "Arial",
        size = 18,
        color = cc.c3b(255, 0, 0), -- 使用纯红色
        align = cc.TEXT_ALIGNMENT_LEFT,
        valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
        dimensions = cc.size(960, 540)}
    )


    print("runErrorScene by tao")

    lab:setAnchorPoint(0,0)
    local scene=cc.Scene:create()
    scene:addChild(lab)
    display.runScene(scene)
   
    if bm.SocketService then
        --todo
        bm.SocketService:disconnect();
    end

    cc.Director:getInstance():pause();
    --pause thread
    --os.execute("ping -n " .. tonumber(1+1) .. " localhost > NUL")

 end


function cct.tableSplice(table,start,endin)
    endin=endin or #table
    start=start or 1
    local tab={}
    for i=start,endin do
        table.insert(tab,table[i])
    end
    return tab
end


--lua中截屏
function cct.getScreenPic(png_name)
    print("luaCall 截屏",png_name)
    local function afterCaptured(succeed,sp_png)
        if succeed then
            print("截屏success",sp_png)
            cct.getDataForApp("captureScreen_success",{sp_png},"V")
        end
    end
    cc.utils:captureScreen(afterCaptured,"gameScreen.png")
end

--在最新的cocos中
--子节点的透明度会随着父节点的变化而变化
--将setCascadeOpacityEnabled 设置false将取消这个机制
function cct.setCascadeOpacityEnabled(node,iscontroll)
    iscontroll=iscontroll or false
    if node.setCascadeOpacityEnabled then
        --todo
        return node:setCascadeOpacityEnabled(iscontroll)
    end
end

--table 转string
function cct.serialize(obj)  
    local lua = ""  
    local t = type(obj)  
    if t == "number" then  
        lua = lua .. obj  
    elseif t == "boolean" then  
        lua = lua .. tostring(obj)  
    elseif t == "string" then  
        lua = lua .. string.format("%q", obj)  
    elseif t == "table" then  
        lua = lua .. "{\n"  
    for k, v in pairs(obj) do  
        lua = lua .. "[" .. cct.serialize(k) .. "]=" .. cct.serialize(v) .. ",\n"  
    end  
    local metatable = getmetatable(obj)  
        if metatable ~= nil and type(metatable.__index) == "table" then  
        for k, v in pairs(metatable.__index) do  
            lua = lua .. "[" .. cct.serialize(k) .. "]=" .. cct.serialize(v) .. ",\n"  
        end  
    end  
        lua = lua .. "}"  
    elseif t == "nil" then  
        return nil  
    else  
        error("can not serialize a " .. t .. " type.")  
    end  
    return lua  
end  

--string zhuan table
function cct.unserialize(lua)  
    local t = type(lua)  
    if t == "nil" or lua == "" then  
        return nil  
    elseif t == "number" or t == "string" or t == "boolean" then  
        lua = tostring(lua)  
    else  
        error("can not unserialize a " .. t .. " type.")  
    end  
    lua = "return " .. lua  
    local func = loadstring(lua)  
    if func == nil then  
        return nil  
    end  
    return func()  
end  

function cct.netLog(...)
    local tb={...}

    if tb[1]=="scoket_chat" then
        --todo
        return;
    end
    print(...)
end

----------------------------------一下只是为了做项目版本的兼容加上的API-----------------------------------------------------------
function print_lua_table (lua_table, indent)
    if lua_table == nil or type(lua_table) ~= "table" then
        return
    end

    local function print_func(str)
        print("[Dongyuxxx] " .. tostring(str))
    end
    indent = indent or 0
    for k, v in pairs(lua_table) do
        if type(k) == "string" then
            k = string.format("%q", k)
        end
        local szSuffix = ""
        if type(v) == "table" then
            szSuffix = "{"
        end
        local szPrefix = string.rep("    ", indent)
        formatting = szPrefix.."["..k.."]".." = "..szSuffix
        if type(v) == "table" then
            print_func(formatting)
            print_lua_table(v, indent + 1)
            print_func(szPrefix.."},")
        else
            local szValue = ""
            if type(v) == "string" then
                szValue = string.format("%q", v)
            else
                szValue = tostring(v)
            end
            print_func(formatting..szValue..",")
        end
    end

end

----------
function display_scene(name,flag)
    print("display_scene",name)
    print("flag",flag)
    local next = require(name).new(flag)
    print("next",next)
    SCENENOW["scene"] = next
    SCENENOW["name"]  = name
    
    SCENENOW["scene"]:enableNodeEvents()

    display.runScene(SCENENOW["scene"])


end

-- start --

--------------------------------
-- 使用 TTF 字体创建文字显示对象，并返回 Label 对象。
-- @function [parent=#display] newTTFLabel
-- @param table params 参数表格对象
-- @return Label#Label ret (return value: cc.Label)  Label对象

--[[--

使用 TTF 字体创建文字显示对象，并返回 Label 对象。

可用参数：

-    text: 要显示的文本
-    font: 字体名，如果是非系统自带的 TTF 字体，那么指定为字体文件名
-    size: 文字尺寸，因为是 TTF 字体，所以可以任意指定尺寸
-    color: 文字颜色（可选），用 cc.c3b() 指定，默认为白色
-    align: 文字的水平对齐方式（可选）
-    valign: 文字的垂直对齐方式（可选），仅在指定了 dimensions 参数时有效
-    dimensions: 文字显示对象的尺寸（可选），使用 cc.size() 指定
-    x, y: 坐标（可选）

align 和 valign 参数可用的值：

-    cc.TEXT_ALIGNMENT_LEFT 左对齐
-    cc.TEXT_ALIGNMENT_CENTER 水平居中对齐
-    cc.TEXT_ALIGNMENT_RIGHT 右对齐
-    cc.VERTICAL_TEXT_ALIGNMENT_TOP 垂直顶部对齐
-    cc.VERTICAL_TEXT_ALIGNMENT_CENTER 垂直居中对齐
-    cc.VERTICAL_TEXT_ALIGNMENT_BOTTOM 垂直底部对齐

~~~ lua

-- 创建一个居中对齐的文字显示对象
local label = display.newTTFLabel({
    text = "Hello, World",
    font = "Marker Felt",
    size = 64,
    align = cc.TEXT_ALIGNMENT_CENTER -- 文字内部居中对齐
})

-- 左对齐，并且多行文字顶部对齐
local label = display.newTTFLabel({
    text = "Hello, World\n您好，世界",
    font = "Arial",
    size = 64,
    color = cc.c3b(255, 0, 0), -- 使用纯红色
    align = cc.TEXT_ALIGNMENT_LEFT,
    valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
    dimensions = cc.size(400, 200)
})

~~~

]]
-- end --


function display.newTTFLabel(params)
    assert(type(params) == "table",
           "[framework.display] newTTFLabel() invalid params")

    local text       = tostring(params.text)
    local font       = params.font or display.DEFAULT_TTF_FONT
    local size       = params.size or display.DEFAULT_TTF_FONT_SIZE
    local color      = params.color or display.COLOR_WHITE
    local textAlign  = params.align or cc.TEXT_ALIGNMENT_LEFT
    local textValign = params.valign or cc.VERTICAL_TEXT_ALIGNMENT_TOP
    local x, y       = params.x, params.y
    local dimensions = params.dimensions or cc.size(0, 0)

    color.a = color.a or 255

    assert(type(size) == "number",
           "[framework.display] newTTFLabel() invalid params.size")

    local label
    if cc.FileUtils:getInstance():isFileExist(font) then
        label = cc.Label:createWithTTF(text, font, size, dimensions, textAlign, textValign)
        if label then
            label:setColor(color)
        end
    else
        label = cc.Label:createWithSystemFont(text, font, size, dimensions, textAlign, textValign)
        if label then
            label:setTextColor(color)
        end
    end

    if label then
        if x and y then label:setPosition(x, y) end
    end

    return label
end

function display.newAnimation(frames, time)
    local count = #frames
    -- local array = Array:create()
    -- for i = 1, count do
    --     array:addObject(frames[i])
    -- end
    time = time or 1.0 / count
    return cc.Animation:createWithSpriteFrames(frames, time)
end


function display.newAnimations(...)
    local params = {...}
    local c = #params
    
    if c == 2 then
        -- frames, time
        return newAnimation(params[1], params[2])
    elseif c == 4 then
        -- pattern, begin, length, time
        local frames = display.newFrames(params[1], params[2], params[3])
        return newAnimation(frames, params[4])
    elseif c == 5 then
        -- pattern, begin, length, isReversed, time
        local frames = display.newFrames(params[1], params[2], params[3], params[4])
        return newAnimation(frames, params[5])
    else
        error("display.newAnimation() - invalid parameters")
    end
end

function transition.playAnimationForever(target, animation, delay)
    local animate = cc.Animate:create(animation)
    local action
    if type(delay) == "number" and delay > 0 then
        target:setVisible(false)
        local sequence = transition.sequence({
            cc.DelayTime:create(delay),
            cc.Show:create(),
            animate,
        })
        action = cc.RepeatForever:create(sequence)
    else
        action = cc.RepeatForever:create(animate)
    end
    target:runAction(action)
    return action
end

-------------------------------------------------------------------------------------------------------------------------------------------
