--
-- Author: http://blog.csdn.net/dd135373/article/details/46468505
-- Date: 2016-09-16 14:52:42
--quick 方式网络图片

require "lfs"
local NetSprite = class("NetSprite",function()
	return display.newSprite()
end)

function NetSprite:ctor(url,image)--创建NetSprite
	self.path = device.writablePath.."netSprite/" --获取本地存储目录
	if not io.exists(self.path) then
		lfs.mkdir(self.path) --目录不存在，创建此目录
	end
	self.url  = url
	self.image=image
	self:createSprite()
end

function NetSprite:getUrlMd5()
	local tempMd5 = crypto.md5(self.url)
    if GameData.netSprite == nil then --判断本地保存数据是否存在
        GameData.netSprite = {} --如果不存在，先创建netSprite数组，保存
        GameState.save(GameData)
	else
        for i=1,#(GameData.netSprite) do
            if GameData.netSprite[i] == tempMd5 then
                return true,self.path..tempMd5..".png" --存在，返回本地存储文件完整路径
            end
        end
	end
	return false,self.path..tempMd5..".png" --不存在，返回将要存储的文件路径备用
end

function NetSprite:setUrlMd5(isOvertime)
	if not isOvertime then --如果不是超时
		table.insert(GameData.netSprite,crypto.md5(self.url)) --保存下载后的文件MD5值
		GameState.save(GameData)
	end
end

function NetSprite:createSprite()
	local isExist,fileName = self:getUrlMd5()
	if isExist then --如果存在，直接更新纹理
		self:updateTexture(fileName) 
	else --如果不存在，启动http下载
		--phone
		-- if network.getInternetConnectionStatus() == cc.kCCNetworkStatusNotReachable then
		-- 	print("not net")
		-- 	return
		-- end
		print("执行下载")
		local request = network.createHTTPRequest(function(event)
			print("成功了？？？")
			self:onRequestFinished(event,fileName)end,self.url, "GET")
		request:start()
	end
end

function NetSprite:onRequestFinished(event,fileName)
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
    print(response)
    
    --保存下载数据到本地文件，如果不成功，重试30次。
    local times = 1 
    while (not request:saveResponseData(fileName)) and times < 30 do
    	times = times + 1
    end
    local isOvertime = (times == 30) --是否超时
    self:setUrlMd5(isOvertime) --保存md5
    self:updateTexture(fileName) --更新纹理
end

function NetSprite:updateTexture(fileName)
	local sprite = display.newSprite(fileName) --创建下载成功的sprite
	if not sprite then return end
	local texture = sprite:getTexture()--获取纹理
	local size = texture:getContentSize()
	self:setTexture(texture)--更新自身纹理
	self:setContentSize(size)
	self:setTextureRect(cc.rect(0,0,size.width,size.height))

	local scaleX=self.image:gsize().width/size.width;
	local scaleY=self.image:gsize().height/size.height
	self:setScaleX(scaleX);
	self:setScaleY(scaleY)
	self:setAnchorPoint(cc.p(0,0))


	print("load Textture success",fileName)
end

return NetSprite
