--
-- Author: Zeng Tao
-- Date: 2017-04-02 17:29:43
--


--通用的更新下载类
--修改
local downLoading=class("downLoading")
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")

function downLoading:ctor(url,callBack,writePath)
	-- body
	local pathinfo  = io.pathinfo(url)

	writePath = writePath or ""

	self.baseName=pathinfo.basename

	local filename=pathinfo.filename




	self.filename=filename


	print("")

	self:crateAssert(url,filename,writePath)

	self.callBack=callBack or function () end
		-- body
	self.dowmCout=0

end

function downLoading:DelayRun( dey )
    -- body
     local handle

     if self.dowmCout>=3 then
     	self.assetsManager:release()
		self.assetsManager=nil
		self.callBack("5");
     	return;
     end
     self.dowmCout=self.dowmCout+1;
     handle = scheduler.performWithDelayGlobal(function (  )
        -- body
            self:startupdate()

    end, dey)

end


function downLoading:getCode( ... )
	-- body
	return self.baseName
end

function downLoading:crateAssert( url, pathinfo,writePath)
	-- body

	if self.assetsManager then return end
	local function onError(errorCode)
		if errorCode == cc.ASSETSMANAGER_NO_NEW_VERSION then
			self.callBack("1")
	
		elseif errorCode == cc.ASSETSMANAGER_NETWORK then --网络错误更新失败
			self.callBack("2")
			self:DelayRun(4)
		else
			self.callBack("3")
			self:DelayRun(4)
		end

	end

	local function onProgress( percent )
		self.callBack(percent)
	end

	local function onSuccess()
		self.assetsManager:release()
		self.assetsManager=nil
		self.callBack("4",self)
	end
	local assetsManager
	assetsManager = cc.AssetsManager:new(url,pathinfo,writePath)
    assetsManager:retain()
    assetsManager:setDelegate(onError, cc.ASSETSMANAGER_PROTOCOL_ERROR )
    assetsManager:setDelegate(onProgress, cc.ASSETSMANAGER_PROTOCOL_PROGRESS)
    assetsManager:setDelegate(onSuccess, cc.ASSETSMANAGER_PROTOCOL_SUCCESS )
    assetsManager:setConnectionTimeout(3)
    self.assetsManager=assetsManager
end

function downLoading:startupdate()

	self.assetsManager:update()
end




local net_woek_down=class("net_woek_down")

function net_woek_down:ctor(url,fileName,callBack,data,md5)
    self.fileName=device.writablePath..fileName
    self.url=url
    self.data=data
    self.md5=md5
    print(self.url)
    dump(self.data,"test1")
    cct.createHttpDwon(url,function(event)
            local ok = (event.name == "completed")

            local request = event.request
            if not ok then
                -- 请求失败，显示错误代码和错误消息
                print(request:getErrorCode(), request:getErrorMessage())
                return
            end

            local code = request:getResponseStatusCode()
            if code ~= 200 then
                -- 请求结束，但没有返回 200 响应代码
                print(code)
                return
            end


            -- 请求成功，显示服务端返回的内容
            local response = request:getResponseString()
            
            --保存下载数据到本地文件，如果不成功，重试30次。
            local times = 1
            print("正在保存",self.fileName)
            while (not request:saveResponseData(self.fileName)) and times < 30 do
                times = times + 1
            end
            local isOvertime = (times == 30) --是否超时
            if isOvertime then --超时了
                --todo
                print("失败超时")
            else

                local netSpriteDtat=cc.UserDefault:getInstance():getStringForKey("netSpriteData", "")
                if netSpriteDtat=="" then
                    --todo
                    netSpriteDtat={}
                else
                    if type(netSpriteDtat)=="string" then
                        --todo
                        netSpriteDtat=cct.unserialize(netSpriteDtat)
                    end
                end

                netSpriteDtat[self.md5]=self.fileName;

                cc.UserDefault:getInstance():setStringForKey("netSpriteData", cct.serialize(netSpriteDtat))

                print("下载文件成功",self.url,self.fileName)
                callBack(self.fileName,self.data)
            end


        end)

end



--下载头像

cct.downloader_smallFile=function(data)
    if type(data.url)~="string" then
        --todo
        print("error downloader_smallFile url")
        return;
    end

    local netSpriteDtat=cc.UserDefault:getInstance():getStringForKey("netSpriteData", "")
    if netSpriteDtat=="" then
        --todo
        netSpriteDtat={}
    else
        netSpriteDtat=cct.unserialize(netSpriteDtat)
    end

    local dataMd5=crypto.md5(data.url) --
    if netSpriteDtat[dataMd5] then--存在的
        --todo
        data.callBack(netSpriteDtat[dataMd5],data.data)
        return;
    else
        local exname=".png"
        if io.pathinfo(data.url).extname then --有后缀名
            --todo
            exname=io.pathinfo(data.url).extname
        end
        data.filename=dataMd5..exname

    end


    if not data.callBack then
        --todo
        data.callBack=function () end
    end
    net_woek_down.new(data.url,data.filename,data.callBack,data.data,dataMd5)
    
end

return downLoading
