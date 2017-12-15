--
-- Author: Zeng Tao
-- Date: 2017-05-03 10:08:10
--
local httpReq=class("httpReq")

 local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
function httpReq:ctor( ty,parm)
	-- body
	 self.url=parm.url;
	 self.data=parm.data or parm.date or  {}
	 self.callBack=parm.callBack or function ( ... ) end
	 self.type_=parm.type_ or "GET"
	 self.arg=parm.arg or {}
	 self.requType=parm.requType or cc.XMLHTTPREQUEST_RESPONSE_JSON
	 self.oldapi=parm.oldapi

	 self.ty=ty

	 if ty==1 then
	 	--todo
	 	self:httpReq1(parm)
	 else
	 	self:httpReq2(parm)
	 end

end



function httpReq:httpReq1( parm )
	-- body
    

	local requType=self.requType
	local oldapi=self.oldapi
	 
     local date=self.data
    local url=self.url
    local type_=self.type_
    local callBack=self.callBack
 
    local arg=self.arg


    --[[-----------------------------------------------]]
    
    if device.platform~="windows" then
        --todo
        parm.type=parm.type_ or "GET"
        parm.data=json.encode(date)


      
        print(json.encode(parm),"wangnima")

        cct.getDataForApp("httpReq",{json.encode(parm),function ( response )
            -- body
            print(data,"httpReq1")
            if response=="error" then
                --todo
                 local function call(code,datas)
   
                    if self.ty==1 then
                        --todo
                        cct.httpReq2(datas)
                    else
                        cct.createHttRq(datas)
                    end

                end
               -- require("app.HallUpdate"):showTips("网络异常，是否在次尝试",1,call,parm)
                return;
            end


           if oldapi then
                 --todo
                 arg.net=xhr
                 arg.netData=response
                 callBack(arg)
             else
                
                output = json.decode(response,1)
                callBack(output,parm)
             end

        end},"V")
        return;
    end

    --[[-----------------------------------------------]]



     local xhr = cc.XMLHttpRequest:new()
     xhr.responseType = requType


     dump(date);

     url=url.."?"
     for k,v in pairs(date) do
 
        url=url..k.."="..v.."&"

        
     end
     xhr:open(type_, url)

     print("send http require",url)



     local function onReadyStateChanged()
         if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then

             local response   = xhr.response
             local output = response
             scheduler.unscheduleGlobal(self.handle)

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
     self:setTimeOut(1,parm)
end

function httpReq:setTimeOut( t,parm )
	-- body
	local handle=scheduler.performWithDelayGlobal(function ( ... )
        -- body
        local function call(code,datas)
   
            if self.ty==1 then
            	--todo
            	cct.httpReq2(datas)
            else
            	cct.createHttRq(datas)
            end

        end
        require("app.HallUpdate"):showTips("网络异常，是否在次尝试",1,call,parm)
            
    end, 10)

	self.handle=handle


end

function httpReq:httpReq2( parm )
	-- body



   
	local requType=self.requType
	local oldapi=self.oldapi
	 
     local date=self.data
    local url=self.url
    local type_=self.type_
    local callBack=self.callBack
 
    local arg=self.arg



     --[[-----------------------------------------------]]
    if device.platform~="windows" then
        --todo
        parm.type=parm.type or "POST"
        parm.data=json.encode(date)


      
        print(json.encode(parm),"wangnima")

        cct.getDataForApp("httpReq",{json.encode(parm),function ( response )
            -- body
            print(data,"httpReq1")
             if response=="error" then
                --todo
                 local function call(code,datas)
   
                    if self.ty==1 then
                        --todo
                        cct.httpReq2(datas)
                    else
                        cct.createHttRq(datas)
                    end

                end
                --require("app.HallUpdate"):showTips("网络异常，是否在次尝试",1,call,parm)
                return;
            end

            
           if oldapi then
                 --todo
                 arg.net=xhr
                 arg.netData=response
                 callBack(arg)
             else
                
                output = json.decode(response,1)
                callBack(output,parm)
             end

        end},"V")
        return;
    end

    --[[-----------------------------------------------]]




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
        
        scheduler.unscheduleGlobal(self.handle)

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



    local request = createHTTPRequest(reqCallback, url, type_)
    --request:addRequestHeader(0)

    if type_=="POST" then
        for k,v in pairs(date) do
            request:addPOSTValue(k, v)
        end
    end
    request:setTimeout(9)
    -- 开始请求。当请求完成时会调用 callback() 函数
    request:start()
    self:setTimeOut(2, parm)

end

return httpReq