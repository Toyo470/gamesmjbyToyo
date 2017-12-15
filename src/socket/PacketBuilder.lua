--[[
    封包
]]

local TYPE = import("src.socket.PACKET_DATA_TYPE")

local PacketBuilder = class("PacketBuilder")
local isEntry=false
function PacketBuilder:ctor(cmd, config, socketName,isEntry)
    self.cmd_ = cmd    
    self.config_ = config
    self.params_ = {}
    --print("build packet socketName:%s cmd:%x  config:%s",socketName,cmd,config)
    self.logger_ = bm.Logger.new(socketName .. ".PacketBuilder"):enabled(true)
    self.isEntry=isEntry
    isEntry=self.isEntry
end

function PacketBuilder:setParameter(key, value)
    self.params_[key] = value
    return self
end

function PacketBuilder:setParameters(params)
    table.merge(self.params_, params)
    return self
end

local function writeData(buf, dtype, val, fmt,arrayLen)
    arrayLen = arrayLen or 1
    if dtype == TYPE.UBYTE then
        if type(val) == "string" and string.len(val) == 1 then
            buf:writeChar(val)
        else
            buf:writeUByte(tonumber(val) or 0)
        end
    elseif dtype == TYPE.BYTE then
        if type(val) == "string" and string.len(val) == 1 then
            buf:writeChar(val)
        else
            local n = tonumber(val)
            if n and n < 0 then
                n = n + 2^8
            end
            buf:writeByte(n or 0)
        end
    elseif dtype == TYPE.INT then
        buf:writeInt(tonumber(val) or 0)
    elseif dtype == TYPE.UINT then
        buf:writeUInt(tonumber(val) or 0)
    elseif dtype == TYPE.SHORT then
        buf:writeShort(tonumber(val) or 0)
    elseif dtype == TYPE.USHORT then
        buf:writeUShort(tonumber(val) or 0)
    elseif dtype == TYPE.LONG then
        val = tonumber(val) or 0
        local low = val % 2^32
        local high = val / 2^32
        buf:writeInt(high)
        buf:writeUInt(low)
    elseif dtype == TYPE.ULONG then
        val = tonumber(val) or 0
        local low = val % 2^32
        local high = val / 2^32
        buf:writeInt(high)
        buf:writeUInt(low)
    elseif dtype == TYPE.STRING then
        if not isEntry then
            --print("write data string:"..val)
        end
        val = tostring(val) or ""
        buf:writeInt(#val + 1)
        buf:writeStringBytes(val)
        buf:writeByte(0)
    elseif dtype == TYPE.STRINGBYTES then
        buf:writeStringBytes(val)
    elseif dtype == TYPE.ARRAY then
        local len = 0
        if val then
            len = #val
            print("array len:%d",len)
        end
        if fmt == nil then
            print("ERROR------------build packet array,not difine format")
        end

        --没有指定依赖值，存入array的长度
        if arrayLen == 1 then
            if fmt.lengthType then
                if fmt.lengthType == TYPE.UBYTE then
                    buf:writeUByte(len)
                elseif fmt.lengthType == TYPE.BYTE then
                    buf:writeByte(len)
                elseif fmt.lengthType == TYPE.INT then
                    buf:writeInt(len)
                elseif fmt.lengthType == TYPE.UINT then
                    buf:writeUInt(len)
                elseif fmt.lengthType == TYPE.LONG then
                    local low = len % 2^32
                    local high = len / 2^32
                    buf:writeInt(high)
                    buf:writeUInt(low)
                elseif fmt.lengthType == TYPE.ULONG then
                    local low = len % 2^32
                    local high = len / 2^32
                    buf:writeInt(high)
                    buf:writeUInt(low)
                end
            else
                buf:writeUByte(len)
            end
        end
        if len > 0 then
            for i1, v1 in ipairs(val) do
                for i2, v2 in ipairs(fmt) do
                    local name = v2.name
                    local dtype = v2.type
                    local fmt = v2.fmt
                    
                    local value = v1[name]
                    
                    writeData(buf, dtype, value, fmt)
                end
            end
        end

    end
end

function PacketBuilder:build(flag)
    local buf = cc.utils.ByteArray.new(cc.utils.ByteArray.ENDIAN_BIG)
    --写包头，包体长度先写0
    buf:writeInt(15)--包体长度
    buf:writeStringBytes("BY")-- 魔数
    buf:writeUShort(1)-- 版本号
    buf:writeInt(tonumber(self.cmd_))                    -- 命令字
    buf:writeUShort(0)                            -- gameid
    buf:writeUShort(0)                            -- 业务id
    buf:writeByte(0)                              --平台ID
    buf:writeByte(0)                              --平台ID
    --lenght 15
    if self.cmd_~=272 and not self.isEntry then
        --todo
        print("build cmd:%x header lenght:%d",tonumber(self.cmd_),buf:getLen())

        print("-----------------------------build packet body",self.isEntry)
    end
    
    flag = flag or 0
    if flag == 1 then
        print("self.config_  neo")
        print_lua_table(self.config_)
    end
    local ret = {}

    if self.config_ and self.config_.fmt and #self.config_.fmt > 0 then
        -- 写包体
        for i, v in ipairs(self.config_.fmt) do
            local name = v.name
            local dtype = v.type
            local fmt = v.fmt
            local value = self.params_[name]
            ret[name] = value
            if fmt ~= nil then
                print("sub array fmt:%s",json.encode(fmt))
                if v.fixedLengthParser ~= nil then
                    v.fixedLength = ret[v.fixedLengthParser]
                    print("array[%s] length:%d",v.fixedLengthParser,v.fixedLength)
                end
                print("name[%s-----------%s----------->%s]",name,dtype,json.encode(value))
            end

            --print(name,buf, dtype, value, fmt,"st222222")
            --print("build packet body-- name:%s type:%d fmt:%s value:%s",name,dtype,fmt,value)
            writeData(buf, dtype, value, fmt, 0)
        end
    end
    --修改包体长度
    buf:setPos(1)
    buf:writeInt(buf:getLen()-4)

    buf:setPos(buf:getLen() + 1)
    if self.cmd_~=272 and isShowNetLog then
        --todo
         print("BUILD PACKET ==> %x(%s) [%s]", self.cmd_, buf:getLen(), cc.utils.ByteArray.toString(buf, 16))
    end
    --self.logger_:debugf("BUILD PACKET ==> %x(%s) [%s]", self.cmd_, buf:getLen(), cc.utils.ByteArray.toString(buf, 16))
    --print("BUILD PACKET ==> %x(%s) [%s]", self.cmd_, buf:getLen(), cc.utils.ByteArray.toString(buf, 16))
    if not self.isEntry then
        --todo
        buf = require("src.socket.Encrypt"):EncryptBuffer(buf)
    else
        buf=buf
    end

    --isShowNetLog=true
    if self.cmd_~=272 and isShowNetLog then
        -- print("BUILD PACKET(en) ==> %x(%s) [%s]", self.cmd_, buf:getLen(), cc.utils.ByteArray.toString(buf, 16))
    end
    
    return buf
end

return PacketBuilder