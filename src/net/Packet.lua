


local Packet  = class("Packet")


--协议包格式化
function Packet:Prase(_string)
    local buf = cc.utils.ByteArray.new()
    buf:writeBuf(_string)
    -- local ttlen =buf:getLen()
    local ttlen = #_string
    buf:setPos(1)
    self._cmd         = tonumber(buf:readInt())
    self._length      = tonumber(buf:readInt())
    self._hall_addr   = tonumber(buf:readLong())
    self._cente_addr  = tonumber(buf:readLong())

    
    local rest = tonumber(buf:getLen()) - tonumber(buf:getPos())
   
           
 

    if( rest ~= self._length -1) then
        self._error = 1
        return
    end


    self._json_str    = buf:readString(self._length) 
    self._val         = json.decode(self._json_str)
end

--协议打包
function Packet:Pack()
    
    local buf = cc.utils.ByteArray.new()
    
    local len  = #json.encode(self._val)
    
    buf:writeInt( self._cmd )
    buf:writeInt( len )
    buf:writeLong( 0 )
    buf:writeLong( 0 )
    buf:writeLong( 0 )
    buf:writeLong( 0 )
    buf:writeString(json.encode(self._val))
    
    
    return buf:getPack()
end


return Packet