--
-- Author: ZT
-- Date: 2016-11-18 16:21:18
--
if device.platform=="android" or device.platform=="windows" then

    return require("hall.ScoketGame2")
end


local SocketService=class("SocketService")
-- local PING_TOOL = import("hall.GetPingValue")


local PacketParser = import("socket.PacketParser")

local PacketBuilder = import("socket.PacketBuilder")

local scheduler = require("framework.scheduler")
local PROTOCOL         = import("hall.HALL_PROTOCOL")

function SocketService:ctor(name,protocol,isChat_Msg)

    self.isChat_Msg=isChat_Msg
    self.name_=name

end

function SocketService:setProtocol(protocol)
    if protocol == nil then
        return
    end
    print("protocol")
   -- dump(protocol)
    self.protocol_ = protocol or PROTOCOL
    self.parser_ = PacketParser.new(protocol.CONFIG.SERVER, self.name_,self.isChat_Msg)
end

function SocketService:getProtocol()
    return self.protocol_
end


function SocketService:getSocketTCP()
    return self.socket_
end


function SocketService:isConnected()
    if self.socket_ then
        --todo
        return self.socket_.isConnected
    end
    return false
end

function SocketService:createPacketBuilder(cmd)

    if  not self.protocol_ then
        self.protocol_ = PROTOCOL
    end
    return PacketBuilder.new(cmd, self.protocol_.CONFIG.CLIENT[cmd], self.name_,self.isChat_Msg)
end

function SocketService:connect(host, port, retryConnectWhenFailure)
	if self:isConnected()  then
		--todo
		return;
	end

    host = host or self.host
    port = port or self.port
   print("connect----------------")
	if not self.socket_  then
		--todo
        print("connect in ----------------")
		self.socket_ = cc.net.SocketTCP.new(host, port)
		self.socket_:addEventListener(cc.net.SocketTCP.EVENT_CONNECTED, handler(self, self.onConnected))
	    self.socket_:addEventListener(cc.net.SocketTCP.EVENT_CLOSE, handler(self, self.onClose))
	    self.socket_:addEventListener(cc.net.SocketTCP.EVENT_DATA, handler(self, self.onData))
        self.socket_:addEventListener(cc.net.SocketTCP.EVENT_CLOSED, handler(self, self.onClosed))
	end
	
	self.host=host
	self.port=port
    self.socket_:setName(self.name_):connect(self.host,self.port)
end



function SocketService:send(data)

	--if self.socket_ then

	-- 	 --if not self:isConnected() then
	-- 	-- 	--todo
	-- 	-- 	-- print("info: socke is not connect",self.name_)
 --  --           self:reConnect()
 --         --   return;
 --    else

 --        self:connect()
 --        return;
	-- end

  if self:isConnected() == true then
        if type(data) == "string" then
            self.socket_:send(data)
        else
            self.socket_:send(data:getPack())
        end
   -- else
   --      self:connect()
  end
end


function SocketService:reConnect()

	print("-----------reConnect---1-------------------")

	if not self.socket_ then
		--todo
		return;
	end
    print("-----------reConnect---2-------------------")
    -- print("reConnect",self.name_,self.socket_)
    ---self.socket_:close()
    if self.parser_ then
        self.parser_:reset()
    end

	

	--self:unscheduleHeartBeat()
    self:disconnect()
    self:connect()
	-- if self.socket_.isConnected then
	-- 	self.socket_:_onDisconnect()
	-- else
	-- 	self.socket_:_connectFailure()
	-- end
    


    --self:disconnect();
   

end


function SocketService:onClosed(evt)
    --完全断开 --
    print("oncloseed------")
    --self:unscheduleHeartBeat()
end


function SocketService:disconnect()
	--self:unscheduleHeartBeat()
    if self.parser_ then
        self.parser_:reset()
    end

    if not self.socket_ then
        return;
    end
	self.socket_:disconnect();
    --printError("SocketService:disconnect");
    self.socket_=nil
end

function SocketService:onConnected(evt)
    print("NEO [%d] onConnected. %s", evt.target.socketId_, evt.name)
    self:unscheduleHeartBeat()
    self:scheduleHeartBeat(2)--开始心跳
    self:onAfterConnected()

  
    
end 

--这里有可能是服务器发过来的断开

function SocketService:onClose()
    print("onclose---------------------")
	--self:unscheduleHeartBeat()
	self:netClose()
end


function SocketService:scheduleHeartBeat(time)
	self.HeartNum = 0
    self.reconnect_num = 0
	self.connectTimeTickScheduler = scheduler.scheduleGlobal(function()
			-- self:send(PacketBuilder.new():buildHeart());
            if  bm.checknetworking ~= false then

				----------------------------------------------
				-- if PING_TOOL ~= nil then
				-- 	PING_TOOL:getTimeStampOfSendHeart()
				-- end
				----------------------------------------------

			    self:send(self:buildHeart())
            end

		end, time)

	self:startHeart()
end

function SocketService:startHeart()
    if self.check_networking_scheduler then
        scheduler.unscheduleGlobal(self.check_networking_scheduler)
    end

    --self.connecting = true
    self.check_networking_scheduler = scheduler.scheduleGlobal(function()   --在退出的时候偶现出了scheduler.unscheduleGlobal() 的参数爆空的错误
	--scheduler.performWithDelayGlobal(function()
			-- if self.HeartNum<4 then --断线
			-- 	--todo
			-- 	self:reConnect()
			-- else
			-- 	self.HeartNum=0
			-- 	self:startHeart()
            -- print(self.HeartNum)
            print("-------------self.HeartNum-----",self.HeartNum,bm.checknetworking)

            if  bm.checknetworking ~= false then  
                if self.HeartNum>0 then
                    --todo
                    self.HeartNum=0
                    --self:startHeart()
                    self.reconnect_num = 0

                    if SCENENOW["scene"]:getChildByName("loading") then
                        SCENENOW["scene"]:removeChildByName("loading")
                    end

                else --断线
                    -- print("----reConnect-now-------------------")
                    -- if self.reconnect_num > 3 then
                    --     --self.reconnect_num  = 0 --考虑到网络要是忽然好了，还是给重登的机会
                    --     require("hall.GameTips"):showTips("提示", "", 3, "网络异常，请重新登录!")
                    -- else
                    --     self.reconnect_num = self.reconnect_num + 1
                        self.HeartNum = 0

                        self:reConnect()
                    -- end
                end
            end
			print("check networking-----")
		end, 6)

end

function SocketService:unscheduleHeartBeat()
    print("unschduleHeartBeat----------------------")
    self.HeartNum=0
    if self.connectTimeTickScheduler then
        --todo
         scheduler.unscheduleGlobal(self.connectTimeTickScheduler)
    end
	
end


function SocketService:onData(evt)
	
  
    local buf = cc.utils.ByteArray.new(cc.utils.ByteArray.ENDIAN_BIG)
    buf:writeBuf(evt.data)
    buf:setPos(1)
    if not self.parser_ then
        return
    end
    local success, packets = self.parser_:read(buf)

   
    if not success then
        error("数据解析异常")
    else
        for i, v in ipairs(packets) do
            if v.cmd~=272  and isShowNetLog then
                --todo
                print("NEO[====PACK====][%x][%s]\n==>%s", v.cmd, table.keyof(self.protocol_, v.cmd), json.encode(v))
            end
            

            if v.cmd == 0x110 then
				----------------------------
				-- print("################# RECEIVE HEART BEAT ################")
				-- if PING_TOOL ~= nil then
				-- 	PING_TOOL:getTimeStampOfRecvHeart()
				-- end
				----------------------------
            	self.HeartNum=self.HeartNum+1;
    		else
        		self._handle:callFunc(v) 
        	end
        end
    end

end
    





function SocketService:setHandle(handle)
    if handle == nil then
        return
    end
    
    self._handle = handle
end

function SocketService:getHandle()
    return self._handle;
end

function SocketService:onAfterConnected()
end


function SocketService:netClose()
	print("netClose")
end


--直接发送心跳
function SocketService:buildHeart()

    local buf = cc.utils.ByteArray.new(cc.utils.ByteArray.ENDIAN_BIG)
    --写包头，包体长度先写0
    buf:writeInt(15)--包体长度
    buf:writeStringBytes("BY")-- 魔数
    buf:writeUShort(1)-- 版本号
    buf:writeInt(0x110)                    -- 命令字
    buf:writeUShort(0)                            -- gameid
    buf:writeUShort(0)                            -- 业务id
    buf:writeByte(0)                              --平台ID
    buf:writeByte(0)                              --平台ID

     --修改包体长度
    buf:setPos(1)
    buf:writeInt(buf:getLen()-4)
    buf:setPos(buf:getLen() + 1)

    buf = require("src.socket.Encrypt"):EncryptBuffer(buf)

    return buf
end


return SocketService
