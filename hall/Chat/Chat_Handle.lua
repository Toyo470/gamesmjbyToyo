--
-- Author: ZT
-- Date: 2016-09-03 19:45:35
--
local PROTOCOL = import(".Chat_PROTOCAL")

--
local Chat_Handle = class("Chat_Handle")

function Chat_Handle:ctor()
	self.func_ = {
        [PROTOCOL.SVR_SUCCESS] = {handler(self, self.SVR_SUCCESS)},
    }

    bm.chat_hertNum = 0
end


function Chat_Handle:callFunc(pack)
	 if self.func_[pack.cmd] and self.func_[pack.cmd][1] then
        self.func_[pack.cmd][1](pack)
    end
end

-- --收到广播消息
-- --收到系统的消息
-- --有可能收到的是其他好友发过来的消息（在线聊天、非在线聊天）
-- --收到视频的广播
-- --离线立马收到加好友的请求

-- --     cmd="103",
-- --     data={
-- --         url="saaddda",
-- --     }



-- local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")

-- function Chat_Handle:heartStart()
-- 	scheduler.performWithDelayGlobal(function()
-- 			if self.hertNum<3 then
-- 				--todo
-- 				scheduler.unscheduleGlobal(bm.chatData_glHand)

-- 				bm.chat_server:reConnect()
-- 				self.hertNum=0
-- 				-- bm.chat_server:disconnect();
-- 				-- bm.chat_server:connect("120.76.103.204",12358,0) --再次连接
-- 				-- self.hertNum=0
-- 			else
-- 				self.hertNum=0
-- 				self:heartStart();
-- 			end
-- 		end, 5)
-- end


function Chat_Handle:SVR_SUCCESS(pack)

	local data=json.decode(pack.data)
	--local data=pack.data

	
	if data.cmd=="100" then --
		--todo
       -- print("-----------data.cmd==100 ---------------------------")
        bm.chat_hertNum = bm.chat_hertNum or 0
		bm.chat_hertNum = bm.chat_hertNum + 1
	else
		dump(data,"Chat_Handle")
	end

	if data.cmd=="103" then --播放视频
		--todo
		print(data.data.videoUrl)
		local function onRequestFinished(event,filename)
            -- body    
            local ok = (event.name == "completed")
            print("onRequestFinished")
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
            print("savedataVideo:"..filename)
            while (not request:saveResponseData(filename)) and times < 60 do
                times = times + 1
            end
            local isOvertime = (times == 60) --是否超时
            if isOvertime then --超时了
            	--todo
            	print("失败超时")
            else
            	
            	cct.vedio_manage:addVedio(filename,data.data.userNickName)
            end

  
    
        end



		local pathinfo  = io.pathinfo(data.data.videoUrl)

		local file_name=pathinfo.filename

		print("pathinfo.extname",file_name)


        local request = network.createHTTPRequest(function (event)
            -- body
            if event.name == "completed" then
            	if pathinfo.extname==".aac" and device.platform=="ios" then
            		--todo
            		file_name=pathinfo.basename..".arm"
            	end
                onRequestFinished(event,device.writablePath..file_name)
            end
        end,data.data.videoUrl,"GET")
        request:start()


		


	end

	--是广播消息
	-- local pao_node= SCENENOW["scene"]._scene:getChildByName("paomadeng")
	-- if pao_node and not tolua.isnull(pao_node) then
	-- 	--todo
	-- 	pao_node:showTips(msg)
	-- end


	-- local SJ_=SCENENOW["scene"]._scene:getChildByName("wordUi")
	-- if sj_ and not tolua.isnull(SJ_) then
	-- 	SJ_:delayMsg(timer,nick,msg)
	-- end
	
	--是【普通的好友消息

end


function Chat_Handle:setScene(scene)
	self.scene=scene;
end





return Chat_Handle