--[[
    解包
]]
local TYPE = import("src.socket.PACKET_DATA_TYPE")


local HEAD_LEN = 18     -- 包头长度

local PacketParser = class("PacketParser")
local isEncrypt=false
function PacketParser:ctor(protocol, socketName,encrypt)
    self.isEncrypt=encrypt
    self.config_ = protocol
    if socketName=="scoket_chat" then
        --todo
        self.isEncrypt=true
    end

    isEncrypt=self.isEncrypt

    self.logger_ = bm.Logger.new(socketName .. ".PacketParser"):enabled(true)
end

function PacketParser:reset()
    self.buf_ = nil
end

--[[
    校验包头，并返回包体长度与命令字, 校验不通过则都返回-1
]]
local function verifyHeadAndGetBodyLenAndCmd(buf)
    local cmd = -1
    local len = -1

    local pos = buf:getPos()
    buf:setPos(5)

    if buf:readStringBytes(2) == "BY" then
        buf:setPos(9)
        cmd = buf:readInt()
        buf:setPos(1)
        len = buf:readInt()
    end

    buf:setPos(pos)
    if cmd~=272 and not isEncrypt and cmd~=100 then
        --todo
        --printf("PacketParser cmd is %02x ",cmd)
    end
    
    return cmd, len
end

function PacketParser:read(buf,service)
    local ret = {}
    local success = true
    while true do
        if not self.buf_ then
            self.buf_ = cc.utils.ByteArray.new(cc.utils.ByteArray.ENDIAN_BIG)
        else 
            self.buf_:setPos(self.buf_:getLen() + 1)
        end

        local available = buf:getAvailable()
        local buffLen = self.buf_:getLen()
        if available <= 0 then
            break
        else
            local headCompleted = (buffLen >= HEAD_LEN)
            --先收包头
            if not headCompleted then
                if available + buffLen >= HEAD_LEN then
                    --收到完整包头，按包头长度写入缓冲区
                    for i=1, HEAD_LEN - buffLen do
                        self.buf_:writeRawByte(buf:readRawByte())
                    end
                    headCompleted = true
                else
                    --不够完整包头，把全部内容写入缓冲区
                    for i=1, available do
                        self.buf_:writeRawByte(buf:readRawByte())
                    end
                    break
                end
            end
            if headCompleted then
                --包头已经完整，取包体长度并校验包头
                local command, bodyLen = verifyHeadAndGetBodyLenAndCmd(self.buf_)

                --self.logger_:debugf("command %x bodylen %d", command, bodyLen)
                --print("command %x bodylen %d,string:%s", command, bodyLen,cc.utils.ByteArray.toString(self.buf_, 16))

                if bodyLen == 14 then
                    --无包体，直接返回一个只有cmd字段的table，并重置缓冲区

                    ret[#ret + 1] = { cmd = command }
                    self:reset()
                elseif bodyLen > 0 then
                    --有包体
                    available = buf:getAvailable()
                    buffLen = self.buf_:getLen()
                    if available <= 0 then
                        break
                    elseif available + buffLen >= 4 + bodyLen - HEAD_LEN then
                        -- 收到完整包，向缓冲区补齐当前包剩余字节
                        for i=1, bodyLen + 4 - HEAD_LEN do
                            self.buf_:writeRawByte(buf:readRawByte())
                        end
                        -- 开始解析
                        --解密
                        local debuffer = cc.utils.ByteArray.new(cc.utils.ByteArray.ENDIAN_BIG)
                        if not self.isEncrypt then
                            --todo
                            debuffer = require("src.socket.Encrypt"):DecryptBuffer(self.buf_)
                        else
                            debuffer=self.buf_
                        end
                        
                        --print("recv PACKET(de) ==> %x(%d) [%s]", command, debuffer:getLen(), cc.utils.ByteArray.toString(debuffer, 16))
                        -- by tao
                        -- 对解包做异常监听
                        local packet 
                        xpcall(function()
                                packet = self:parsePacket_(debuffer)
                            end,function(msg)
                            local str="zt trace:\n"..msg.."\n".."解析数据包出现了异常。协议号："..command.."\n 数据是"..cc.utils.ByteArray.toString(debuffer, 16)
                            cct.runErrorScene(str)
                        end)


                        if packet then
                            ret[#ret + 1] = packet
                        end

                        -- service:dispatchEvent({name="SocketService.EVT_PACKET_RECEIVED", data=packet})
                        --重置缓冲区
                        self:reset()


                    else
                        --不够包体长度，全部内容写入缓冲区
                        for i=1, available do
                            self.buf_:writeRawByte(buf:readRawByte())
                        end
                        break
                    end
                else
                    -- 包头校验失败
                    return false, "PKG HEAD VERIFY ERROR, " .. cc.utils.ByteArray.toString(self.buf_, 16)
                end
            end
        end
    end
    return true, ret
end

function PacketParser:readData_(ctx, buf, dtype, thisFmt)

    local ret
    if buf:getAvailable() <= 0 and thisFmt.optional == true then
        return nil
    end
    local pos = buf:getPos()

    if dtype == TYPE.UBYTE then
        ret = buf:readUByte()
        if ret < 0 then
            ret = ret + 2^8
        end
    elseif dtype == TYPE.BYTE then
        ret = buf:readByte()
        if ret > 2^7 -1 then
            ret = ret - 2^8
        end
    elseif dtype == TYPE.INT then
        ret = buf:readInt()
    elseif dtype == TYPE.UINT then
        ret = buf:readUInt()
    elseif dtype == TYPE.SHORT then
        ret = buf:readShort()
    elseif dtype == TYPE.USHORT then
        ret = buf:readUShort()
    elseif dtype == TYPE.LONG then
        local high = buf:readInt()
        local low = buf:readUInt()
        ret = high * 2^32 + low
    elseif dtype == TYPE.ULONG then
        local high = buf:readInt()
        local low = buf:readUInt()
        ret = high * 2^32 + low
    elseif dtype == TYPE.STRING then
        if not self.isEncrypt then
            --todo
            print("read data string pos:%d",buf:getPos())
        end

        local len = buf:readUInt()

        if not self.isEncrypt then
            print("read data string len:%d",len)
        end
        -- 防止server出尔反尔，个别协议中出现字符串不以\0结尾的情况，这里做个判断
        local pos = buf:getPos()
        buf:setPos(pos + len -1)
        local lastByte = buf:readByte()
        buf:setPos(pos)

        if lastByte == 0 then
            ret = buf:readStringBytes(len - 1)
            buf:readByte() -- 消费掉最后一个字节
        else
            --self.logger_:error("#################################### NOT END WITH 0")
            if not self.isEncrypt  then
                --todo
                print("#################################### NOT END WITH 0")
            end
            
            ret = buf:readStringBytes(len)
        end
    elseif dtype == TYPE.ARRAY then
        ret = {}
        local contentFmt = thisFmt.fmt
        if not thisFmt.fixedLength then
            --配置文件中未指定长度，从包体中得到
            if thisFmt.lengthType then
                -- 配置文件中指定了长度字段的类型
                if thisFmt.lengthType == TYPE.UBYTE then
                    len = buf:readUByte()
                    --self.logger_:debug("read ubyte length")
                    print("read ubyte length")
                elseif thisFmt.lengthType == TYPE.BYTE then
                    --self.logger_:debug("read byte length")
                    print("read byte length")
                    len = buf:readByte()
                elseif thisFmt.lengthType == TYPE.INT then
                    --self.logger_:debug("read int length")
                    print("read int length")
                    len = buf:readInt()
                elseif thisFmt.lengthType == TYPE.UINT then
                    --self.logger_:debug("read uint length")
                    print("read uint length")
                    len = buf:readUInt()
                elseif thisFmt.lengthType == TYPE.LONG then
                    --self.logger_:debug("read long length")
                    print("read long length")
                    local high = buf:readInt()
                    local low = buf:readUInt()
                    len = high * 2^32 + low
                elseif thisFmt.lengthType == TYPE.ULONG then
                    --self.logger_:debug("read ulong length")
                    print("read ulong length")
                    local high = buf:readInt()
                    local low = buf:readUInt()
                    len = high * 2^32 + low
                end
            else
                -- 未指定长度字段类型，默认按照无符号byte类型读
                len = buf:readUByte()
            end
        else
            -- 配置文件中直接指定了长度
            len = thisFmt.fixedLength
        end
        if len > 0 then
            if #contentFmt == 1 then
                local dtype = contentFmt[1].type
                for i = 1, len do
                    if contentFmt[1].depends ~= nil then
                        if contentFmt[1].depends(ctx) then
                            ret[#ret + 1] = self:readData_(ctx, buf, dtype, contentFmt[1])
                        end
                    else            
                        ret[#ret + 1] = self:readData_(ctx, buf, dtype, contentFmt[1])
                    end
                end
            elseif #contentFmt == 0 and contentFmt.type then
                for i = 1, len do
                    if contentFmt.depends ~= nil then
                        if contentFmt.depends(ctx) then
                            ret[#ret + 1] = self:readData_(ctx, buf, contentFmt.type, contentFmt)
                        end
                    else
                        ret[#ret + 1] = self:readData_(ctx, buf, contentFmt.type, contentFmt)
                    end
                end
            else

                for i = 1, len do
                    local ele = {}
                    ret[#ret + 1] = ele
                    for i, v in ipairs(contentFmt) do
                        local name = v.name
                        local dtype = v.type
                        local cache = v.cache
                        if v and v.depends ~= nil then
                            if v.depends(ctx, ele) then
                                ele[name] = self:readData_(ctx, buf, dtype, v)
                            end
                        elseif v.request ~= nil then
                            if self.cache_[v.request] == v.requestValue then
                                ele[name] = self:readData_(ctx, buf, dtype, v)
                            end
                            
                        else
                            if v.fixedLengthParser ~= nil then
                                v.fixedLength = ele[v.fixedLengthParser]
                                if v.fixedLengthOffset then
                                    v.fixedLength = v.fixedLength + v.fixedLengthOffset
                                end
                                -- print("[array item:%s][readData_]array fixedLength:%d   fixedLengthParser:%s",name,v.fixedLength,v.fixedLengthParser)
                            end
                            ele[name] = self:readData_(ctx, buf, dtype, v)
                            -- print("[array item:%s][readData_]---->%s",name,json.encode(ele[name]))
                        end

                        if cache == 1 then
                            self.cache_[name] =  ele[name]
                        end
                    end
                end
            end
        end
    else
        --self.logger_:error("type is wrong!!!")

        -- print(thisFmt)
        print("type is wrong!!!")
    end

    return ret


end

function PacketParser:parsePacket_(buf)
    self.cache_ = {}
    --self.logger_:debug("#[PACK_PARSE] len:" .. buf:getLen() .. " [" .. cc.utils.ByteArray.toString(buf, 16) .. "]")
    if not self.isEncrypt then
        --todo
        print("#[PACK_PARSE] len:" .. buf:getLen() .. " [" .. cc.utils.ByteArray.toString(buf, 16) .. "]")

    end
    local ret = {}
    local cmd = buf:setPos(9):readInt()

    local config = self.config_[cmd]

    if config ~= nil then
        local fmt = config.fmt
        
        buf:setPos(HEAD_LEN + 1)
        if type(fmt) == "function" then
            fmt(ret, buf)
        elseif fmt then
            for i, v in ipairs(fmt) do

                local name = v.name
                local cache = v.cache
                local dtype = v.type
                local depends = v.depends
                if v.request ~= nil then

                    if ret[v.request] == v.requestValue then
                        local fpos = buf:getPos()
                        if v.fixedLengthParser ~= nil then
                            v.fixedLength = ret[v.fixedLengthParser]
                            if v.fixedLengthOffset then
                                v.fixedLength = v.fixedLength + v.fixedLengthOffset
                            end
                             print("%zt[parsePacket_]array fixedLength:d",v.fixedLength)
                        end
                        ret[name] = self:readData_(ret, buf, dtype, v)
                        --                        print("read data[name:%s value:%s]",name,ret[name])
                        local epos = buf:getPos()
                        if not self.isEncrypt then
                            --todo
                        
                        if type(ret[name]) == "table" then
                            --self.logger_:debugf("[%03d-%03d][%03d]%s=%s", fpos, epos-1, epos - fpos, name, json.encode(ret[name]))
                            print("[%03d-%03d][%03d]%s=%s", fpos, epos-1, epos - fpos, name, json.encode(ret[name]))
                        else
                            --self.logger_:debugf("[%03d-%03d][%03d]%s=%s", fpos, epos-1, epos - fpos, name, ret[name])
                            print("[%03d-%03d][%03d]%s=%s", fpos, epos-1, epos - fpos, name, ret[name])
                        end
                        end
                        buf:setPos(epos)
                    end
                else

                    if depends ~= nil then
                        if depends(ret) then
                            local fpos = buf:getPos()
                            if v.fixedLengthParser ~= nil then
                                v.fixedLength = ret[v.fixedLengthParser]
                                if v.fixedLengthOffset then
                                    v.fixedLength = v.fixedLength + v.fixedLengthOffset
                                end
                                print("array fixedLength:%d",v.fixedLength)
                            end
                            ret[name] = self:readData_(ret, buf, dtype, v)
                            print("read data[name:%s value:%s]",name,ret[name])
                            local epos = buf:getPos()

                            if type(ret[name]) == "table" then
                                --self.logger_:debugf("[%03d-%03d][%03d]%s=%s", fpos, epos-1, epos - fpos, name, json.encode(ret[name]))
                                print("[%03d-%03d][%03d]%s=%s", fpos, epos-1, epos - fpos, name, json.encode(ret[name]))
                            else
                                --self.logger_:debugf("[%03d-%03d][%03d]%s=%s", fpos, epos-1, epos - fpos, name, ret[name])
                                print("[%03d-%03d][%03d]%s=%s", fpos, epos-1, epos - fpos, name, ret[name])
                            end
                            buf:setPos(epos)
                        end
                    else

                        local fpos = buf:getPos()
                        if v.fixedLengthParser ~= nil then
                            v.fixedLength = ret[v.fixedLengthParser]
                            if v.fixedLengthOffset then
                                v.fixedLength = v.fixedLength + v.fixedLengthOffset
                            end
                            print("[parsePacket_]array fixedLength:%d",v.fixedLength)
                        end

                        local epos = buf:getPos()
                        

                        ret[name] = self:readData_(ret, buf, dtype, v)

                
                        
--                        print("read data[name:%s value:%s]",name,ret[name])
                        local epos = buf:getPos()
                        if not self.isEncrypt then
                        if type(ret[name]) == "table" then
                            --self.logger_:debugf("[%03d-%03d][%03d]%s=%s", fpos, epos-1, epos - fpos, name, json.encode(ret[name]))
                            print("[%03d-%03d][%03d]%s=%s", fpos, epos-1, epos - fpos, name, json.encode(ret[name]))
                        else
                            --self.logger_:debugf("[%03d-%03d][%03d]%s=%s", fpos, epos-1, epos - fpos, name, ret[name])
                            print("[%03d-%03d][%03d]%s=%s", fpos, epos-1, epos - fpos, name, ret[name])
                        end
                        end
                        buf:setPos(epos)
                    end

                    if cache == 1 then
                        self.cache_[name] = ret[name]
                    end

                end

            end
        end
        if buf:getLen() ~= buf:getPos() - 1 and DEBUG > 0 and not self.isEncrypt then
            print("buf len: " .. buf:getLen() .. " pos:" .. buf:getPos())
            --error(string.format("PROTOCOL ERROR !!!!! %x bufLen:%s pos:%s [%s]", cmd,buf:getLen(), buf:getPos(), cc.utils.ByteArray.toString(buf, 16)))
        end
        ret.cmd = cmd
        return ret
    else
        --self.logger_:debugf("========> [NOT_PROCESSED_PKG] ========> %x", cmd)
        print("========> [NOT_PROCESSED_PKG] ========> %x", cmd)
        return nil
    end
end

return PacketParser