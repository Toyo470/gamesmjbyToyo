--[[
    网络模块的绝对父级
]]


local PacketBuilder = import("socket.PacketBuilder")
local PacketParser = import("socket.PacketParser")

local SocketService = class("SocketService")

SocketService.EVT_PACKET_RECEIVED     = "SocketService.EVT_PACKET_RECEIVED"
SocketService.EVT_CONN_SUCCESS         = "SocketService.EVT_CONN_SUCCESS"
SocketService.EVT_CONN_FAIL         = "SocketService.EVT_CONN_FAIL"
SocketService.EVT_ERROR             = "SocketService.EVT_ERROR"
SocketService.EVT_CLOSED             = "SocketService.EVT_CLOSED"
SocketService.EVT_CLOSE             = "SocketService.EVT_CLOSE"

local SOCKET_ID = 1

function SocketService:ctor(name, protocol,isChat_Msg)
    --cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    cc.bind(self,"event")
    self.name_ = name
    self.protocol_ = protocol
    self.parser_ = PacketParser.new(protocol.CONFIG.SERVER, self.name_,self.isChat_Msg)
    self.log = bm.Logger.new(name)
    self.isChat_Msg=isChat_Msg
end

function SocketService:setProtocol(protocol)
    self.protocol_ = protocol
    self.parser_ = PacketParser.new(protocol.CONFIG.SERVER, self.name_,self.isChat_Msg)
end
function SocketService:setParserClass(ParserClass)
    self.parser_ = ParserClass.new(self.protocol_, self.name_,self.isChat_Msg)
end

function SocketService:createPacketBuilder(cmd)
    return PacketBuilder.new(cmd, self.protocol_.CONFIG.CLIENT[cmd], self.name_,self.isChat_Msg)
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

function SocketService:connect(host, port, retryConnectWhenFailure)

    --self:disconnect()
    if not self.socket_ then
        SOCKET_ID = SOCKET_ID + 1
        self.socket_ = cc.net.SocketTCP.new(host, port, retryConnectWhenFailure or false)
        self.socket_.socketId_ = SOCKET_ID
        self.socket_:addEventListener(cc.net.SocketTCP.EVENT_CONNECTED, handler(self, self.onConnected))
        self.socket_:addEventListener(cc.net.SocketTCP.EVENT_CLOSE, handler(self, self.onClose))
        self.socket_:addEventListener(cc.net.SocketTCP.EVENT_CLOSED, handler(self, self.onClosed))
        self.socket_:addEventListener(cc.net.SocketTCP.EVENT_CONNECT_FAILURE, handler(self, self.onConnectFailure))
        self.socket_:addEventListener(cc.net.SocketTCP.EVENT_DATA, handler(self, self.onData))
    end
 
    self.socket_:setName(self.name_):connect()
end

function SocketService:send(data)
--    print("sendDataSeuccess",data)
    if self.socket_ then
        if type(data) == "string" then
            self.socket_:send(data)
        else
            self.socket_:send(data:getPack())
        end
    end
end

function SocketService:disconnect(noEvent)

    print("disconnect")
    if self.socket_ then
        local socket = self.socket_
        self.socket_ = nil

        if noEvent then
            socket:removeAllEventListeners()
            socket:disconnect()
        else
            socket:disconnect()
            socket:removeAllEventListeners()
        end
    end
end


function SocketService:reConnect()
    self.socket_:_disconnect()
    self.socket_:_reconnect()
end

function SocketService:onConnected(evt)
    --self.log:debugf("[%d] onConnected. %s", evt.target.socketId_, evt.name)
    print("NEO [%d] onConnected. %s", evt.target.socketId_, evt.name)
    self.parser_:reset()
    self:dispatchEvent({name=SocketService.EVT_CONN_SUCCESS})
end

function SocketService:onClose(evt)
    --self.log:debugf("[%d] onClose. %s", evt.target.socketId_, evt.name)
    print("[%d] onClose. %s", evt.target.socketId_, evt.name)
    self:dispatchEvent({name=SocketService.EVT_CLOSE})
end

function SocketService:onClosed(evt)
    --self.log:debugf("[%d] onClosed. %s", evt.target.socketId_, evt.name)
    print("[%d] onClosed. %s", evt.target.socketId_, evt.name)
    self:dispatchEvent({name=SocketService.EVT_CLOSED})
end

function SocketService:onConnectFailure(evt)
    --self.log:debugf("[%d] onConnectFailure. %s", evt.target.socketId_, evt.name)
    print("[%d] onConnectFailure. %s", evt.target.socketId_, evt.name)
    self:dispatchEvent({name=SocketService.EVT_CONN_FAIL})
end

function SocketService:onData(evt)
    if isShowNetLog and not self.isChat_Msg then
        --todo
         print("socket receive raw data:", cc.utils.ByteArray.toString(evt.data, 16))
    end
   
    local buf = cc.utils.ByteArray.new(cc.utils.ByteArray.ENDIAN_BIG)
    buf:writeBuf(evt.data)
    buf:setPos(1)
    local success, packets = self.parser_:read(buf)
    if not success then
        self:dispatchEvent({name=SocketService.EVT_ERROR})
    else
        for i, v in ipairs(packets) do
            --self.log:debugf("[====PACK====][%x][%s]\n==>%s", v.cmd, table.keyof(self.protocol_, v.cmd), json.encode(v))
            if v.cmd~=272 and not self.isChat_Msg then
                --todo
                print("NEO[====PACK====][%x][%s]\n==>%s", v.cmd, table.keyof(self.protocol_, v.cmd), json.encode(v))
            end
            
            self:dispatchEvent({name=SocketService.EVT_PACKET_RECEIVED, data=v})
        end
    end
end

return SocketService