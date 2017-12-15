HttpRq_Manager = class("HttpRq_Manager")

function HttpRq_Manager:ctor()
	-- body
end

function HttpRq_Manager:initialize()
    -- body
    print("-----------HttpRq_Manager---initialize----------------")
end
function HttpRq_Manager:createHttRq( data_tbl,url )
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON

    local date = {
        userId = 517
    }

    local str="?"
    for k,v in pairs(date) do
        str=str..k.."="..v.."&"
    end
    if str ~= "?" then
        url=url..str
    end
    
    xhr:open("POST",url)

    local function onReadyStateChanged()
        if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then

            print("xhr.statusText------------------",type(xhr.statusText))
            dump(xhr.statusText)
            --print("xhr.statusText----------",xhr.statusText)

            local response   = xhr.response
            local output = json.decode(response,1)
            dump(output)

            --table.foreach(output,function(i, v) print (i, v) end)
            
        else
            print("xhr.readyState is:", xhr.readyState, "xhr.status is: ",xhr.status)
        end
        xhr:unregisterScriptHandler()
    end

    xhr:registerScriptHandler(onReadyStateChanged)


    xhr:send()
end

-- function HttpRq_Manager:createHttRq( parm )
-- 	-- body
-- 	local url=parm.url;
--     local date=parm.date or {}
--     local callBack=parm.callBack 
--     local type_=parm.type_ or "POST"
--     local arg=parm.arg or {}
--     -- body
--     local function reqCallback(event)
--         -- body
--         local ok = (event.name == "completed")
--         local request = event.request
     
--         if not ok then
--             -- 请求失败，显示错误代码和错误消息
--             print(request:getErrorCode(), request:getErrorMessage())
--             return
--         end

     
--         local code = request:getResponseStatusCode()
--         if code ~= 200 then
--             -- 请求结束，但没有返回 200 响应代码
--             print("getHttp error",url)
--             return
--         end
     
--         -- 请求成功，显示服务端返回的内容
--         local response = request:getResponseString()
--         arg.net=event
--         arg.netData=response
--         callBack(arg)

--         --xpcall(callBack, cct.runErrorScene,arg)
--         --callBack(json.decode(response))

--     end
--     if type_=="GET" then
--         local str="?"
--         for k,v in pairs(date) do
--             str=str..k.."="..v.."&"
--         end
--         url=url..str
--     end

--     local request = network.createHTTPRequest(reqCallback, url, type_)
--     request:addRequestHeader('Content-Type:application/x-www-form-urlencoded')
--     if type_=="POST" then
--         for k,v in pairs(date) do
--             request:addPOSTValue(k, v)
--         end
--     end
--     request:setTimeout(30)
--     -- 开始请求。当请求完成时会调用 callback() 函数
--     request:start()
--     return request
-- end
    --使用示例
     --    httprq.manager:createHttRq({
     --        url=HttpAddr .. "/game/freeGameList",--http://120.76.133.49:80/hbiInterface/goods/queryGoodsList
     --        date={
     --        },
     --        type_="POST",
     --        callBack = function(data)
     --        self:freegamelistcallback(data)
     --     end
     -- })
