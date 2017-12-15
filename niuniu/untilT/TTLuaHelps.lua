--
-- Author: tao
-- Date: 2016-03-16 12:39:22
--
local Widget = ccui.Widget

function Widget:onTouch(callback)
    self:addTouchEventListener(function(sender, state)
        local event = {x = 0, y = 0}
        if state == 0 then
            event.name = "began"
        elseif state == 1 then
            event.name = "moved"
        elseif state == 2 then
            event.name = "ended"
        else
            event.name = "cancelled"
        end
        event.target = sender
        callback(event)
    end)
    return self
end


-- function Widget:onClick( callback )
--     -- body
--     self:setTouchEnabled(true);
--     self:onTouch(function ( event )
--         -- body
--         if event.name=="ended" then
--             --todo
--             callback(event.target)
--         end
--     end)
-- end

local Node=cc.Node
function Node:gsize()
    -- body
    return self:getContentSize()
end

function Node:ssize(  )
    -- body
    return self:setContentSize()
end


function Node:seekNodeByName(root,name)

    if not root then
        --todo
        return null
    end
    if root:getName()==name then
        return root;
    end

    local rootChildren=root:getChildren()
    for k,v in pairs(rootChildren) do
        local _root=v
        if _root then
            --todo
            local node=_root:seekNodeByName(_root,name)
            if node then
                return node
            end
        end

    end

    return null;
end

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




--创建一个http请求
function cct.createHttRq(parm)
    local url=parm.url;
    local date=parm.date or {}
    local callBack=parm.callBack 
    local type_=parm.type_ or "POST"
    local arg=parm.arg or {}
    print("===========createHttRq==1====================================")
    -- body
    local function reqCallback(event)
        -- body
        local ok = (event.name == "completed")
        local request = event.request
        print("===========createHttRq==4====================================")
        if not ok then
            -- 请求失败，显示错误代码和错误消息
            print(request:getErrorCode(), request:getErrorMessage())
            return
        end

        print("===========createHttRq==5===================================")
        local code = request:getResponseStatusCode()
        if code ~= 200 then
            -- 请求结束，但没有返回 200 响应代码
            print("getHttp error",url)
            return
        end
        print("===========createHttRq==6===================================")
        -- 请求成功，显示服务端返回的内容
        local response = request:getResponseString()
        arg.net=event
        arg.netData=response
        callBack(arg)

        --xpcall(callBack, cct.runErrorScene,arg)
        --callBack(json.decode(response))

    end
    print("===========createHttRq==2====================================")
    if type_=="GET" then
        local str="?"
        for k,v in pairs(date) do
            str=str..k.."="..v.."&"
        end
        url=url..str
    end

    local request = network.createHTTPRequest(reqCallback, url, type_)
    if type_=="POST" then
        for k,v in pairs(date) do
            request:addPOSTValue(k, v)
        end
    end
    print("===========createHttRq==3====================================")
    -- 开始请求。当请求完成时会调用 callback() 函数
    request:start()
    return request
end

uiloader={}
-- start --

--------------------------------
-- 按tag查找布局中的结点
-- @function [parent=#uiloader] seekNodeByTag
-- @param node parent 要查找布局的结点
-- @param number tag 要查找的tag
-- @return node#node 

-- end --

function uiloader:seekNodeByTag(parent, tag)
    if not parent then
        return
    end

    if tag == parent:getTag() then
        return parent
    end

    local findNode
    local children = parent:getChildren()
    local childCount = parent:getChildrenCount()
    if childCount < 1 then
        return
    end
    for i=1, childCount do
        if "table" == type(children) then
            parent = children[i]
        elseif "userdata" == type(children) then
            parent = children:objectAtIndex(i - 1)
        end

        if parent then
            findNode = self:seekNodeByTag(parent, tag)
            if findNode then
                return findNode
            end
        end
    end

    return
end

-- start --

--------------------------------
-- 按name查找布局中的结点
-- @function [parent=#uiloader] seekNodeByName
-- @param node parent 要查找布局的结点
-- @param string name 要查找的name
-- @return node#node 

-- end --

function uiloader:seekNodeByName(root, name)

    if not root then
        --todo
        return null
    end
    if root:getName()==name then
        return root;
    end

    local rootChildren=root:getChildren()
    for k,v in pairs(rootChildren) do
        local _root=v
        if _root then
            --todo
            local node=_root:seekNodeByName(_root,name)
            if node then
                return node
            end
        end

    end

    return null;
    -- if not parent then
    --     return
    -- end

    -- if name == parent.name then
    --     return parent
    -- end

    -- local findNode
    -- local children = parent:getChildren()
    -- local childCount = parent:getChildrenCount()
    -- if childCount < 1 then
    --     return
    -- end
    -- for i=1, childCount do
    --     if "table" == type(children) then
    --         parent = children[i]
    --     elseif "userdata" == type(children) then
    --         parent = children:objectAtIndex(i - 1)
    --     end

    --     if parent then
    --         if name == parent.name then
    --             return parent
    --         end
    --     end
    -- end

    -- for i=1, childCount do
    --     if "table" == type(children) then
    --         parent = children[i]
    --     elseif "userdata" == type(children) then
    --         parent = children:objectAtIndex(i - 1)
    --     end

    --     if parent then
    --         findNode = self:seekNodeByName(parent, name)
    --         if findNode then
    --             return findNode
    --         end
    --     end
    -- end

    -- return
end



-- start --

--------------------------------
-- 按name查找布局中的结点
-- 与seekNodeByName不同之处在于它是通过node的下子结点表来查询,效率更快
-- @function [parent=#uiloader] seekNodeByNameFast
-- @param node parent 要查找布局的结点
-- @param string name 要查找的name
-- @return node#node 

-- end --

function uiloader:seekNodeByNameFast(parent, name)
    if not parent then
        return
    end

    if not parent.subChildren then
        return
    end

    if name == parent.name then
        return parent
    end

    local findNode = parent.subChildren[name]
    if findNode then
        -- find
        return findNode
    end

    for i,v in ipairs(parent.subChildren) do
        findNode = self:seekNodeByName(v, name)
        if findNode then
            return findNode
        end
    end

    return
end

-- start --

--------------------------------
-- 根据路径来查找布局中的结点
-- @function [parent=#uiloader] seekNodeByPath
-- @param node parent 要查找布局的结点
-- @param string path 要查找的path
-- @return node#node 

-- end --

function uiloader:seekNodeByPath(parent, path)
    if not parent then
        return
    end

    local names = string.split(path, '/')

    for i,v in ipairs(names) do
        parent = self:seekNodeByNameFast(parent, v)
        if not parent then
            return
        end
    end

    return parent
end


function printf(fmt, ...)
    -- body 
    if device.platform~="windows" then
        --todo
        return;
    end
    --cct.luataoPrint(string.format(tostring(fmt), ...))
    print(string.format(tostring(fmt), ...))
end


__G__TRACKBACK__ = function(msg)
    local msg = debug.traceback(msg, 3)
    print(msg)
--    cct.runErrorScene(msg)
    return msg
end



function cct.setUI(sef,tb)
    -- body
    if not sef.root then
        return;
    end
    for k,v in pairs(tb) do
        local vtype=type(v)
        local node;
        if vtype=="string" then
            --todo
            node=uiloader:seekNodeByName(sef.root, v)
        elseif vtype=="number" then
            node=uiloader:seekNodeByTag(sef.root, v)
        else
            --print()

        end
        k=k or node:getName()
        k=tostring(k)
        sef.usernode=sef.usernode or {}

        
        sef.usernode.k=node



    end


end