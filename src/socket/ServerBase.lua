--
-- Author: LeoLuo
-- Date: 2015-05-09 09:59:20
--
local ServerBase = class("ServerBase")

ServerBase.EVT_PACKET_RECEIVED     = "ServerBase.EVT_PACKET_RECEIVED"
ServerBase.EVT_CONNECTED         = "ServerBase.EVT_CONNECTED"
ServerBase.EVT_CONNECT_FAIL        = "ServerBase.EVT_CONNECT_FAIL"
ServerBase.EVT_CLOSED             = "ServerBase.EVT_CLOSED"
ServerBase.EVT_ERROR             = "ServerBase.EVT_ERROR"

function ServerBase:ctor(name, protocol,isChat_Msg)

    cc.bind(self,"event")
    --cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    self.PROTOCOL = protocol
    
    self.socket_ = bm.SocketService.new(name, protocol,isChat_Msg)
    self.socket_:addEventListener(bm.SocketService.EVT_PACKET_RECEIVED, handler(self, self.onPacketReceived))
    self.socket_:addEventListener(bm.SocketService.EVT_CONN_SUCCESS, handler(self, self.onConnected))
    self.socket_:addEventListener(bm.SocketService.EVT_CONN_FAIL, handler(self, self.onConnectFailure))
    self.socket_:addEventListener(bm.SocketService.EVT_ERROR, handler(self, self.onError))
    self.socket_:addEventListener(bm.SocketService.EVT_CLOSED, handler(self, self.onClosed))
    self.socket_:addEventListener(bm.SocketService.EVT_CLOSE, handler(self, self.onClose))
    self.name_ = name
    -- self.shouldConnect_ = false
    -- self.isConnected_ = false
    -- self.isConnecting_ = false
    -- self.isProxy_ = false
    -- self.isPaused_ = false
    -- self.delayPackCache_ = nil
    -- self.retryLimit_ = 3
    self.heartBeatSchedulerPool_ = bm.SchedulerPool.new()

    --self.logger_ = bm.Logger.new(self.name_)

    self.isChat_Msg=isChat_Msg

end


function ServerBase:setProtocol(protocol)
    self._protocol=protocol
    self.socket_:setProtocol(protocol)
end

function ServerBase:getProtocol()
    return self._protocol
end

function ServerBase:isConnected()
    return self:getSocket():isConnected()
end

function ServerBase:connect(ip, port, retryConnectWhenFailure)
    self.disCon=false
    self.ip_ = ip
    self.port_ = port
    if self:isConnected() then
        --self.logger_:debug("isConnected true")
        print("isConnected true")
    else
    
        --self.logger_:debugf("direct connect to %s:%s", self.ip_, self.port_)
        print("direct connect to %s:%s", self.ip_, self.port_)
        self.socket_:connect(self.ip_, self.port_, retryConnectWhenFailure)
        
    end
end

function ServerBase:reConnect()
    if self.disCon then
        --todo
        return;
    end
    self.socket_:reConnect()
end

function ServerBase:disconnect(noEvent)
    -- self.shouldConnect_ = false
    -- self.isConnecting_ = false
    -- self.isConnected_ = false
    self.disCon=true
    self.ip_ = nil
    self.port_ = nil
    self:unscheduleHeartBeat()
    self.socket_:disconnect(noEvent)
    -- if noEvent then
    --     self.logger_:error("noEvent true")
    -- end
end

function ServerBase:pause()
    --self.isPaused_ = true
    --self.logger_:debug("paused event dispatching")
    print("paused event dispatching")
end

function ServerBase:resume()
    --self.isPaused_ = false
    --self.logger_:debug("resume event dispatching")
    print("resume event dispatching")
    -- if self.delayPackCache_ and #self.delayPackCache_ > 0 then
    --     for i, v in ipairs(self.delayPackCache_) do
    --         self:dispatchEvent({name=ServerBase.EVT_PACKET_RECEIVED, packet=v})
    --     end
    --     self.delayPackCache_ = nil
    -- end
end

function ServerBase:createPacketBuilder(cmd)
    return self.socket_:createPacketBuilder(cmd)
end

function ServerBase:send(pack)
    if self:isConnected() then
        self.socket_:send(pack)
    else
        --self.logger_:error("sending packet when socket is not connected")
        print("sending packet when socket is not connected")
    end
end

function ServerBase:onConnected(evt)
    --print("ServerBase connected")
    -- self.isConnected_ = true
    -- self.isConnecting_ = false
    self.heartBeatTimeoutCount_ = 0

    --self.retryLimit_ = 3
    self:onAfterConnected()
    --self:dispatchEvent({name=ServerBase.EVT_CONNECTED})
end

function ServerBase:scheduleHeartBeat(command, interval, timeout)
    self.heartBeatCommand_ = command
    self.heartBeatTimeout_ = timeout
    self.heartBeatTimeoutCount_ = 0
    self.heartBeatSchedulerPool_:clearAll()
    self.heartBeatSchedulerPool_:loopCall(handler(self, self.onHeartBeat_), interval)
end

function ServerBase:unscheduleHeartBeat()
    self.heartBeatTimeoutCount_ = 0
    self.heartBeatSchedulerPool_:clearAll()
end

function ServerBase:buildHeartBeatPack()
    --self.logger_:debug("not implemented method buildHeartBeatPack")
    print("not implemented method buildHeartBeatPack")
    return nil
end

function ServerBase:onHeartBeatTimeout(timeoutCount)
    --self.logger_:debug("not implemented method onHeartBeatTimeout")
    print("not implemented method onHeartBeatTimeout")
end

function ServerBase:onHeartBeatReceived(delaySeconds)
    --self.logger_:debug("not implemented method onHeartBeatReceived")
    print("not implemented method onHeartBeatReceived")
end

function ServerBase:onHeartBeat_()
    local heartBeatPack = self:buildHeartBeatPack()
    if heartBeatPack then
        self.heartBeatPackSendTime_ = bm.getTime()
        self:send(heartBeatPack)
        self.heartBeatTimeoutId_ = self.heartBeatSchedulerPool_:delayCall(handler(self, self.onHeartBeatTimeout_), self.heartBeatTimeout_)
        --self.logger_:debug("send heart beat packet")
--        print("send heart beat packet heartBeatTimeoutId_:"..self.heartBeatTimeoutId_)
    end
    return true
end

function ServerBase:onHeartBeatTimeout_()
    self.heartBeatTimeoutId_ = nil
    self.heartBeatTimeoutCount_ = (self.heartBeatTimeoutCount_ or 0) + 1
    self:onHeartBeatTimeout(self.heartBeatTimeoutCount_)
    --self.logger_:debug("heart beat timeout", self.heartBeatTimeoutCount_)
    print("heart beat timeout;%d", self.heartBeatTimeoutCount_)
end

function ServerBase:onHeartBeatReceived_()
    local delaySeconds = bm.getTime() - self.heartBeatPackSendTime_
    self.heartBeatTimeoutCount_ = 0
    self:onHeartBeatReceived(delaySeconds)
    self.heartBeatSchedulerPool_:clear(self.heartBeatTimeoutId_)
    self.heartBeatTimeoutId_ = nil
--    if self.heartBeatTimeoutId_ then
--        print("heart beat received:%d   heartBeatTimeoutId_:%d", delaySeconds, self.heartBeatTimeoutId_)
--        --self.logger_:debug("heart beat received", delaySeconds)
--    else
--        --self.logger_:debug("timeout heart beat received", delaySeconds)
--        print("timeout heart beat received:%d", delaySeconds)
--    end
end

--连接出错
function ServerBase:onConnectFailure(evt)
    --self.isConnected_ = false
    --self.logger_:debug("connect failure ...")
    print("connect failure ...")

    -- if not self:reconnect_() then        
    --     self:onAfterConnectFailure()
    --     self:dispatchEvent({name=ServerBase.EVT_CONNECT_FAIL})
    -- end
end

-- function ServerBase:onError(evt)
--     -- self.isConnected_ = false
--     -- self.socket_:disconnect(true)
--     -- --self.logger_:debug("data error ...")
--     -- print("data error ...")
--     -- if not self:reconnect_() then       
--     --     self:onAfterDataError()
--     --     self:dispatchEvent({name=ServerBase.EVT_ERROR})
--     -- end
-- end

--网络断开
function ServerBase:onClosed(evt)
    --self.isConnected_ = false
    self:unscheduleHeartBeat()
  
    
end

--手动断开
function ServerBase:onClose(evt)
    self:unscheduleHeartBeat()
end

-- function ServerBase:reconnect_()

--     self.socket_:disconnect(true)
--     self.retryLimit_ = self.retryLimit_ - 1
--     local isRetrying = true    
--     if self.retryLimit_ > 0 or self.retryConnectWhenFailure_ then
--         print("reConnet重连",self.ip_,self.port_)
--         self.socket_:connect(self.ip_, self.port_, self.retryConnectWhenFailure_)
--     else
--         isRetrying = false
--         self.isConnecting_ = false
--     end    
--     return isRetrying
-- end

function ServerBase:getSocket()
    return self.socket_
end
function ServerBase:onPacketReceived(evt)
    local pack = evt.data
    --print("onPacketReceived:%x",cc.utils.ByteArray.toString(pack, 16))
    if pack.cmd == self.heartBeatCommand_ then
        --print("heartBeatCommand_:%x    pack command:%x",self.heartBeatCommand_,pack.cmd)
        self:onHeartBeatReceived_()
    else
        self:onProcessPacket(pack)
        -- if self.isPaused_ then
        --     if not self.delayPackCache_ then
        --         self.delayPackCache_ = {}
        --     end
        --     self.delayPackCache_[#self.delayPackCache_ + 1] = pack
        --     --self.logger_:debugf("%s paused cmd:%x", self.name_, pack.cmd)
        --     print("%s paused cmd:%x", self.name_, pack.cmd)
        -- else
        --     --self.logger_:debugf("%s dispatching cmd:%x", self.name_, pack.cmd)
        --     if self.name_~="scoket_chat" then
        --         --todo
        --         print("%s dispatching cmd:%x", self.name_, pack.cmd)

        --     end
        --     local ret, errMsg = pcall(function() self:dispatchEvent({name=ServerBase.EVT_PACKET_RECEIVED, packet=evt.data}) end)
        --     if errMsg then
        --         --self.logger_:errorf("%s dispatching cmd:%x error %s", self.name_, pack.cmd, errMsg)
        --         print("%s dispatching cmd:%x error %s", self.name_, pack.cmd, errMsg)
        --     end            
        -- end
    end
end

-- function ServerBase:onProcessPacket(pack)
--     --self.logger_:debug("not implemented method onProcessPacket")
--     print("not implemented method onProcessPacket")
-- end

function ServerBase:onAfterConnected()
    --self.logger_:debug("not implemented method onAfterConnected")
    print("not implemented method onAfterConnected")
end

function ServerBase:onAfterConnectFailure()
    --self.logger_:debug("not implemented method onAfterConnectFailure")
    print("not implemented method onAfterConnectFailure")
end

function ServerBase:onAfterDataError()
    --self:onAfterConnectFailure()
    --self.logger_:debug("not implemented method onAfterDataError")
    --print("not implemented method onAfterDataError")
end




--
function ServerBase:setHandle(handle)
    self._handle = handle
end

function ServerBase:getHandle()
    return self._handle
end
--接收
function ServerBase:onProcessPacket(pack)
    self._handle:callFunc(pack) 
end


return ServerBase