--
-- Author: ZT
-- Date: 2016-09-03 19:38:21
--
-- require("hall.Chat.ChatServer").getInstanse("192.168.1.106",12358)

local ServerBase = require("socket.ServerBase")

local PROTOCOL = import(".Chat_PROTOCAL")
local Chat_handle=import(".Chat_Handle")

local scoket_chat=class("scoket_chat",ServerBase)

local handle_chat=nil

local socket_clss=nil


local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
--广播socket连接成功
function scoket_chat:onAfterConnected()
	-- if not self.isFirstConnect then
	-- 	--todo
		
	-- 	self.isFirstConnect=true
	-- else
	-- 	print("chat msg connect")
	-- end

	if self.ip_  ~= nil then
		self.chat_ip = self.ip_
	end 

	if self.port_  ~= nil then
		self.chat_port = self.port_
	end 


    if self.chatData_glHand then
        scheduler.unscheduleGlobal(self.chatData_glHand)
    end

	self.chatData_glHand = scheduler.scheduleGlobal(function()
			self:sendLogin();
		end, 1)



	if self.check_chat_networking then
		scheduler.unscheduleGlobal(self.check_chat_networking)
	end

	
	self.check_chat_networking = scheduler.scheduleGlobal(function()
		print("---check_chat_networking------hertNum-----",bm.chat_hertNum,"self.chat_ip=",self.chat_ip,"  self.chat_port==",self.chat_port)
			if bm.chat_hertNum < 3 then
				--todo

				bm.chat_server:disconnect()
				bm.chat_server:connect(self.chat_ip,self.chat_port)

				bm.chat_hertNum = 0
			else
				bm.chat_hertNum = 0
			end
		end, 5)

end




--连接出现异常
function scoket_chat:onAfterConnectFailure()
	print("chatServerClose")
	-- self.isFirstConnect=false
	-- if tolua.isnull(SCENENOW["scene"]) == false then
 --        require("hall.GameTips"):showTips("提示", "network_disconnect", 1, "分发服断开")
 --        self:reconnect_()
 --    end
end



function scoket_chat:getHandle()
	return handle_chat
end

--注册
function scoket_chat:sendLogin()
	local tb={
		cmd="100",
		data={
			userId=tostring(USER_INFO["uid"]),
			token="daadadadad"
		}
		
	}

	local pack = self:createPacketBuilder(PROTOCOL.MSG_LOGIN)
        :setParameter("data", json.encode(tb))
        :build()
    self:send(pack)
end



--发送消息 1——>1 
function scoket_chat:sendMsg(msg_,friendId_)
	local tb={
		cmd="101",
		data={
			userId="514",
			token="daadadadad",
			msg=tostring(msg_),
			friendId=tostring(friendId_)
		}
	}
	local pack = self:createPacketBuilder(PROTOCOL.MSG_LOGIN)
        :setParameter("data", json.encode(tb))
        :build()
    self:send(pack)
end

--102广播消息

--103视频



function scoket_chat:sendVideo(list_uid,url)
	local list_={}
	for k,v in pairs(list_uid) do
		table.insert(list_,tostring(v))
	end

	
	dump(list_uid,"uidListView")
	local now_user_info = json.decode(USER_INFO["user_info"])
	local user
	local pathinfo  = io.pathinfo(url)
	if pathinfo.extname  == ".aac" or  pathinfo.extname  == ".mp3" or  pathinfo.extname  == ".wav" then
		user=tostring(USER_INFO["uid"])
	else
		user=now_user_info.nickName
	end 

	local tb={
		cmd="103",
		data={
			userIdList=list_,
			videoUrl=url,
			userNickName=user,
			token="ddsjkdjksjk"
		}
	}
	print("nick_____name",user)
	local pack = self:createPacketBuilder(PROTOCOL.MSG_LOGIN)
        :setParameter("data", json.encode(tb))
        :build()
    self:send(pack)

	
end



function scoket_chat.getInstanse(ip,port)

	if not socket_clss then
		--todo
		socket_clss=scoket_chat.new("scoket_chat",PROTOCOL,true)
		handle_chat=Chat_handle.new()
		socket_clss:setHandle(handle_chat)
		socket_clss:connect(ip,port,0)
	end
	return socket_clss
end


return scoket_chat