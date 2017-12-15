
local T = bm.PACKET_DATA_TYPE
local HEAD_LEN = 18     -- 包头长度

local testLua  = class("testLua")

function testLua:init()

	potocal = {
	    ver = 1,
	    fmt = {
        {name = "from", type = T.INT}, --
        {name = "nTableType", type = T.SHORT}, --
        {name = "seat_id", type = T.SHORT}, --重连用户座位ID
        {name = "gold", type = T.INT}, --重连用户拥有金币数 
        {name = "nTingFlag", type = T.SHORT}, --

        --房间配置
        {name = "nBaseChips", type = T.INT}, --桌子信息: 
        {name = "nBaseRadix", type = T.INT}, --桌子信息: --底注基数
        {name = "nQuan", type = T.SHORT},
        {name = "nOutCardTimeout", type = T.SHORT}, --桌子信息: 出牌超时时间
        {name = "nOperationTimeout", type = T.SHORT}, --桌子信息: 出牌超时时间
        {name = "nCurQuan", type = T.SHORT},
        {name = "m_nEastSeatId", type = T.SHORT},
        {name = "m_nBankSeatId", type = T.SHORT}, --桌子信息: 庄家位置
        {name = "m_nShaiZi", type = T.SHORT}, --桌子信息: 筛子数
        {name = "card_less", type = T.SHORT}, --//桌上剩余麻将数

        {name = "nPlayerCount", type = T.SHORT}, --其他用户信息:其他用户数
        {name = "users_info", type = T.ARRAY,fixedLengthParser = "nPlayerCount",fixedLength = 0,
            fmt = {
                    {name = "uid", type = T.INT},--其他用户信息:用户id
                    {name = "seat_id", type = T.SHORT},--其他用户信息:用户座位id
                    {name = "m_bAI", type = T.SHORT},--其他用户信息:用户是否托管
                    {name = "nTingFlag", type = T.SHORT},--
                    {name = "countHandCards", type = T.SHORT},--
                    {name = "user_info", type = T.STRING},
                    {name = "user_gold", type = T.INT},--其他用户信息: 用户金币数量
                    --花牌
                    {name = "huaCount", type = T.SHORT},
                    {name = "huaCards", type = T.ARRAY,fixedLengthParser = "huaCount",fixedLength = 0,
                        fmt = {
                                {name = "card", type = T.BYTE},--其他用户信息: 用户所碰的牌
                            }
                    },
                    --吃牌
                    {name = "cCount", type = T.SHORT},--其他用户信息: 用户碰牌数量
                    {name = "cCards", type = T.ARRAY,fixedLengthParser = "cCount",fixedLength = 0,
                        fmt = {
                                {name = "card", type = T.BYTE},--其他用户信息: 用户所碰的牌
                            }
                    },
                    --碰牌
                    {name = "pCount", type = T.SHORT},--其他用户信息: 用户碰牌数量
                    {name = "pCards", type = T.ARRAY,fixedLengthParser = "pCount",fixedLength = 0,
                        fmt = {
                                {name = "card", type = T.BYTE},--其他用户信息: 用户所碰的牌
                            }
                    },
                        
                    --杠牌
                    {name = "gCount", type = T.SHORT},--其他用户信息: 用户杠牌数量
                    --明杠
                    {name = "gCards", type = T.ARRAY,fixedLengthParser = "gCount",fixedLength = 0,
                        fmt = {
                                {name = "card", type = T.BYTE},--其他用户信息: 用户所杠的牌，0是明杠。1是暗杠
                                {name = "isAg", type = T.BYTE},--其他用户信息: 杠牌的类型 0 不是 1 暗杠
                            }
                    },
                    --出牌
                    {name = "outCount", type = T.SHORT},--其他用户信息: 其他用户所出牌的数量
                    {name = "outCards", type = T.ARRAY,fixedLengthParser = "outCount",fixedLength = 0,
                        fmt = {
                                {name = "card", type = T.BYTE},--其他用户信息: 所出的牌
                        }
                    },
            }
        },

        {name = "handCount", type = T.SHORT}, --重连用户信息:手牌数量
        {name = "handCards", type = T.ARRAY,fixedLengthParser = "handCount",fixedLength = 0,
            fmt = {
                    {name = "card", type = T.BYTE},--重连用户信息:手牌的值
                }
        },
        -- 花牌
        {name = "huaCount", type = T.SHORT},--重连用户信息:碰牌的数量
        {name = "huaCards", type = T.ARRAY,fixedLengthParser = "huaCount",fixedLength = 0,
            fmt = {
                    {name = "card", type = T.BYTE},--重连用户信息:碰牌的值
                  }
        },
        -- 吃牌
        {name = "cCount", type = T.SHORT},--重连用户信息:碰牌的数量
        {name = "cCards", type = T.ARRAY,fixedLengthParser = "cCount",fixedLength = 0,
            fmt = {
                    {name = "card", type = T.BYTE},--重连用户信息:碰牌的值
                  }
        },
        -- 碰牌
        {name = "pCount", type = T.SHORT},--重连用户信息:碰牌的数量
        {name = "pCards", type = T.ARRAY,fixedLengthParser = "pCount",fixedLength = 0,
            fmt = {
                    {name = "card", type = T.BYTE},--重连用户信息:碰牌的值
                  }
        },

        --杠牌
        {name = "gCount", type = T.SHORT},--重连用户信息:杠牌的数量
        --明杠
        {name = "gCards", type = T.ARRAY,fixedLengthParser = "gCount",fixedLength = 0,
            fmt = {
                    {name = "card", type = T.BYTE},--重连用户信息:杠牌的值
                    {name = "isAg", type = T.BYTE},--重连用户信息:0表示明杠，1表示暗杠
                  }
        },

        -- 出牌历史
        {name = "outCount", type = T.SHORT},--重连用户信息:出牌历史
        {name = "outCards", type = T.ARRAY,fixedLengthParser = "outCount",fixedLength = 0,
            fmt = {
                    {name = "card", type = T.BYTE},--重连用户信息:所出的牌
                  }
        },
        {name = "gameStatus", type = T.SHORT, cache = 1},
        {name = "currentPlayerId", type = T.INT, request="gameStatus", requestValue = 2},
        {name = "currentPlayerId", type = T.INT, request="gameStatus", requestValue = 3},
        {name = "handle", type = T.INT, request="gameStatus", requestValue = 3},
        {name = "handleCard", type = T.BYTE, request="gameStatus", requestValue = 3},

        -- 开杠数据
        {name = "bonusLen", type = T.BYTE, request="gameStatus", requestValue = 4},
        {name = "bonusSet", type = T.ARRAY, fixedLengthParser = "bonusLen", fixedLength = 0, 
            fmt = {
                    {name = "bonusOpCard", type = T.BYTE, request="gameStatus", requestValue = 4},
                    {name = "bonusOpCode", type = T.INT, request="gameStatus", requestValue = 4},
                    {name = "bonusFinalCard", type = T.BYTE, request="gameStatus", requestValue = 4},
                    {name = "bonus", type = T.BYTE, request="gameStatus", requestValue = 4},

                    {name = "gangCardSet", type = T.ARRAY, fixedLength = 8,
                        fmt = {
                                {name = "gangCards", type = T.BYTE, request="gameStatus", requestValue = 4},
                                }
                    },

                    }
        },
    }
	}

	self.config_ = {}
	self.config_[0x1009] = potocal

    local buf = cc.utils.ByteArray.new(cc.utils.ByteArray.ENDIAN_BIG)
	local list = string.split("00 00 02 A3 42 59 00 00 00 00 10 09 00 00 00 00 00 00 00 00 00 CA 00 04 00 03 00 00 07 D0 00 00 00 00 00 01 00 00 00 00 00 01 00 3C 00 3C 00 00 00 00 00 00 00 07 00 37 00 03 00 00 03 AB 00 00 00 00 00 00 00 0E 00 00 00 AB 7B 22 69 70 22 3A 22 31 32 37 2E 30 2E 30 2E 31 22 2C 22 6C 65 76 65 6C 22 3A 31 2C 22 6D 6F 6E 65 79 22 3A 30 2C 22 6E 69 63 6B 4E 61 6D 65 22 3A 22 E7 94 A8 E6 88 B7 39 30 31 30 38 22 2C 22 70 68 6F 74 6F 55 72 6C 22 3A 22 68 74 74 70 3A 2F 2F 68 62 69 72 64 74 65 73 74 2E 6F 73 73 2D 63 6E 2D 73 68 65 6E 7A 68 65 6E 2E 61 6C 69 79 75 6E 63 73 2E 63 6F 6D 2F 75 3D 33 36 30 36 34 35 35 35 39 2C 34 30 39 37 35 35 37 35 32 26 66 6D 3D 32 31 26 67 70 3D 30 2E 6A 70 67 22 2C 22 73 65 78 22 3A 22 31 22 7D 0A 00 00 00 07 D0 00 00 00 00 00 00 00 00 00 00 00 00 03 AC 00 01 00 00 00 00 00 0D 00 00 00 A3 7B 22 69 70 22 3A 22 31 32 37 2E 30 2E 30 2E 31 22 2C 22 6C 65 76 65 6C 22 3A 31 2C 22 6D 6F 6E 65 79 22 3A 32 31 38 30 2C 22 6E 69 63 6B 4E 61 6D 65 22 3A 22 E7 94 A8 E6 88 B7 39 30 31 30 39 22 2C 22 70 68 6F 74 6F 55 72 6C 22 3A 22 68 74 74 70 3A 2F 2F 68 62 69 72 64 74 65 73 74 2E 6F 73 73 2D 63 6E 2D 73 68 65 6E 7A 68 65 6E 2E 61 6C 69 79 75 6E 63 73 2E 63 6F 6D 2F 64 65 66 61 75 6C 74 5F 70 68 6F 74 6F 25 32 38 33 39 25 32 39 2E 6A 70 67 22 2C 22 73 65 78 22 3A 22 31 22 7D 0A 00 00 00 07 D0 00 00 00 00 00 00 00 00 00 00 00 00 03 AD 00 02 00 00 00 00 00 0D 00 00 00 A1 7B 22 69 70 22 3A 22 31 32 37 2E 30 2E 30 2E 31 22 2C 22 6C 65 76 65 6C 22 3A 31 2C 22 6D 6F 6E 65 79 22 3A 30 2C 22 6E 69 63 6B 4E 61 6D 65 22 3A 22 E7 94 A8 E6 88 B7 39 30 31 33 30 22 2C 22 70 68 6F 74 6F 55 72 6C 22 3A 22 68 74 74 70 3A 2F 2F 68 62 69 72 64 74 65 73 74 2E 6F 73 73 2D 63 6E 2D 73 68 65 6E 7A 68 65 6E 2E 61 6C 69 79 75 6E 63 73 2E 63 6F 6D 2F 64 65 66 61 75 6C 74 5F 70 68 6F 74 6F 25 32 38 31 33 36 25 32 39 2E 6A 70 67 22 2C 22 73 65 78 22 3A 22 32 22 7D 0A 00 00 00 07 D0 00 00 00 00 00 00 00 00 00 00 00 0D 02 02 03 06 07 07 17 19 22 24 25 28 28 00 00 00 00 00 00 00 00 00 00 00 03 00 00 03 AB 00 00 00 00 00"," ")
	dump(list, "desciption")
	for k, v in pairs(list) do
		local value = "0x"..v
		print("init ",tonumber(value))
		buf:writeByte(tonumber(value))
	end

	self:parsePacket_(buf)

	return 0
end


function testLua:parsePacket_(buf)
    self.cache_ = {}

    print("#[PACK_PARSE] len:" .. buf:getLen() .. " [" .. cc.utils.ByteArray.toString(buf, 16) .. "]")

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

                	print("[parsePacket_] request:"..tostring(v.request),tostring(ret[v.request]),tostring(v.requestValue))
                    if ret[v.request] == v.requestValue then
                        local fpos = buf:getPos()
                        if v.fixedLengthParser ~= nil then
                            v.fixedLength = ret[v.fixedLengthParser]
                            if v.fixedLengthOffset then
                                v.fixedLength = v.fixedLength + v.fixedLengthOffset
                            end
                             print("[parsePacket_]array fixedLength:",v.fixedLength)
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
            print("buf len: ",buf:getLen()," pos:" ,buf:getPos())
            --error(string.format("PROTOCOL ERROR !!!!! %x bufLen:%s pos:%s [%s]", cmd,buf:getLen(), buf:getPos(), cc.utils.ByteArray.toString(buf, 16)))
        end
        ret.cmd = cmd
        return ret
    else
        return nil
    end
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

function testLua:read(buf,service)
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

function testLua:readData_(ctx, buf, dtype, thisFmt)

    local ret
    if buf:getAvailable() <= 0 and thisFmt.optional == true then
        return nil
    end
    local pos = buf:getPos()

    if dtype == T.UBYTE then
        ret = buf:readUByte()
        if ret < 0 then
            ret = ret + 2^8
        end
    elseif dtype == T.BYTE then
        ret = buf:readByte()
        if ret > 2^7 -1 then
            ret = ret - 2^8
        end
    elseif dtype == T.INT then
        ret = buf:readInt()
    elseif dtype == T.UINT then
        ret = buf:readUInt()
    elseif dtype == T.SHORT then
        ret = buf:readShort()
    elseif dtype == T.USHORT then
        ret = buf:readUShort()
    elseif dtype == T.LONG then
        local high = buf:readInt()
        local low = buf:readUInt()
        ret = high * 2^32 + low
    elseif dtype == T.ULONG then
        local high = buf:readInt()
        local low = buf:readUInt()
        ret = high * 2^32 + low
    elseif dtype == T.STRING then
        if not self.isEncrypt then
            --todo
            print("read data string pos:",buf:getPos())
        end

        local len = buf:readUInt()

        if not self.isEncrypt then
            print("read data string len:",len)
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
    elseif dtype == T.ARRAY then
        ret = {}
        local contentFmt = thisFmt.fmt
        if not thisFmt.fixedLength then
            --配置文件中未指定长度，从包体中得到
            if thisFmt.lengthType then
                -- 配置文件中指定了长度字段的类型
                if thisFmt.lengthType == T.UBYTE then
                    len = buf:readUByte()
                    --self.logger_:debug("read ubyte length")
                    print("read ARRAY ubyte length",len)
                elseif thisFmt.lengthType == T.BYTE then
                    --self.logger_:debug("read byte length")
                    len = buf:readByte()
                    print("read ARRAY byte length",len)
                elseif thisFmt.lengthType == T.INT then
                    --self.logger_:debug("read int length")
                    len = buf:readInt()
                    print("read ARRAY int length",len)
                elseif thisFmt.lengthType == T.UINT then
                    --self.logger_:debug("read uint length")
                    len = buf:readUInt()
                    print("read ARRAY uint length",len)
                elseif thisFmt.lengthType == T.LONG then
                    --self.logger_:debug("read long length")
                    local high = buf:readInt()
                    local low = buf:readUInt()
                    len = high * 2^32 + low
                    print("read ARRAY long length",len)
                elseif thisFmt.lengthType == T.ULONG then
                    --self.logger_:debug("read ulong length")
                    local high = buf:readInt()
                    local low = buf:readUInt()
                    len = high * 2^32 + low
                    print("read ARRAY ulong length",len)
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
                            
                            print("[array item:",tostring(name),tostring(dtype),"]","pos:"..tostring(buf:getPos()),"[readData_]---->",json.encode(ele[name]))
                        else
                            if v.fixedLengthParser ~= nil then
                                v.fixedLength = ele[v.fixedLengthParser]
                                if v.fixedLengthOffset then
                                    v.fixedLength = v.fixedLength + v.fixedLengthOffset
                                end
                                print("[array item:",tostring(name),tostring(dtype),"]","pos:"..tostring(buf:getPos()),"[readData_]array fixedLength:"..tostring(v.fixedLength),"fixedLengthParser:"..tostring(v.fixedLengthParser))
                            end
                            ele[name] = self:readData_(ctx, buf, dtype, v)
                            print("[array item:",tostring(name),tostring(dtype),"]","pos:"..tostring(buf:getPos()),"[readData_]---->",json.encode(ele[name]))
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

return testLua