--
-- Author: ZT
-- Date: 2016-11-18 16:21:18
--
local SocketService=class("SocketService")


local PacketParser = import("socket.PacketParser")

local PacketBuilder = import("socket.PacketBuilder")

local scheduler = require("framework.scheduler")
local PROTOCOL         = import("hall.HALL_PROTOCOL")

function SocketService:ctor(name,protocol)

    self.name_=name
    self:setProtocol(protocol)
end

function SocketService:setProtocol(protocol)
    if protocol == nil then
        printError("error SocketGame:setProtocol:protocol is nil")
        return
    end
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
		self.socket_ = cc.net.SocketTCP.new(host, port,1)
		self.socket_:addEventListener(cc.net.SocketTCP.EVENT_CONNECTED, handler(self, self.onConnected))
        self.socket_:addEventListener(cc.net.SocketTCP.EVENT_CONNECT_FAILURE, handler(self, self.onConnecfailed))
	    self.socket_:addEventListener(cc.net.SocketTCP.EVENT_CLOSE, handler(self, self.onClose))
	    self.socket_:addEventListener(cc.net.SocketTCP.EVENT_DATA, handler(self, self.onData))
        self.socket_:addEventListener(cc.net.SocketTCP.EVENT_CLOSED, handler(self, self.onClosed))
	end
	
	self.host=host
	self.port=port
    self.socket_:setName(self.name_):connect(self.host,self.port)
end


function SocketService:onConnecfailed( ... )
    -- body
    print("连接失败");
    self:unscheduleHeartBeat()
    if SCENENOW["name"]=="hall.loginGame" then
        --todo
        require("hall.GameCommon"):showLoadingTips("连接失败，正在重试");

    else
        self:netClose("连接失败");
    end
    

end

function SocketService:send(data)

      if self:isConnected() == true then
            if type(data) == "string" then
                self.socket_:send(data)
            else
                self.socket_:send(data:getPack())
            end
      end
end

--[[
心跳断线手动重连
]]
function SocketService:reConnect()

	print("-----------reConnect---1-------------------")

	if not self.socket_ then
		--todo
		return;
	end

    if self.parser_ then
        self.parser_:reset()
    end

	self.socket_:reconnect()

end


function SocketService:onClosed(evt)
    --user完全断开 --
    print("oncloseed------")
    self:unscheduleHeartBeat()
    
end


function SocketService:disconnect()
    if self.parser_ then
        self.parser_:reset()
    end

    if not self.socket_ then
        return;
    end
	self.socket_:disconnect();
    self.socket_=nil
end

function SocketService:onConnected(evt)
    print("NEO [%d] onConnected. %s", evt.target.socketId_, evt.name)
    
    self:sendHeartBeat()--开始心跳
    self:onAfterConnected()

end 

--这里有可能是服务器发过来的断开
function SocketService:onClose()
    print("onclose---------------------")
	self:unscheduleHeartBeat()
	self:netClose("网络断开连接")
end

--发送心跳
function SocketService:sendHeartBeat()
    -- body
    if self.revhert then
        --todo
        return;
    end
    self.delayTime=0
    self.revhert=true
    self:send(self:buildHeart())

    local handle2=scheduler.scheduleGlobal(function ( ... )
        -- body
        self.delayTime=self.delayTime+1/60

    end,1/60)


    local handle=scheduler.performWithDelayGlobal(function ()
        -- body
        --断线
        self:reConnect();
    end, 10)

  



    self.hertHandle=handle

    self.pingHandloe=handle2
end




function SocketService:unscheduleHeartBeat()
    print("unschduleHeartBeat----------------------")
	   
    if  self.hertHandle then
        --todo
        scheduler.unscheduleGlobal(self.hertHandle)
        self.hertHandle =nil;

    end

    if self.pingHandloe then
        --todo
        scheduler.unscheduleGlobal(self.pingHandloe)
        self.pingHandloe =nil;
        self.delayTime=0;
    end

    self.revhert=false
end


function SocketService:onData(evt)
	
  
    local buf = cc.utils.ByteArray.new(cc.utils.ByteArray.ENDIAN_BIG)
    buf:writeBuf(evt.data)
    buf:setPos(1)
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

     

                local deay=self.delayTime
                deay=math.floor(deay*1000)
                print( deay,"当前网络的延迟是")

                if _G.notifiLayer then
                    _G.notifiLayer:setNetping(deay)
                end

                self:unscheduleHeartBeat()

                scheduler.performWithDelayGlobal(function ()
    
                     self:sendHeartBeat();
                end, 10)

               

        
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
