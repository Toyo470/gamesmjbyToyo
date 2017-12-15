local socket			= require "socket"
local GetPingValue		= class("GetPingValue")
local MAX_LEN_TMP_ARR	= 100


function GetPingValue:ctor()
	self.tbBegTimeStamp	= {}
	self.tbEndTimeStamp	= {}
	self.recvCursor		= 0
	self.tbPingValue	= {}
end



function GetPingValue:getPreciseDecimal(nNum, n)
    if type(nNum) ~= "number" then
        return nNum;
    end
    n = n or 0;
    n = math.floor(n)
    if n < 0 then
        n = 0;
    end
    local nDecimal = 10 ^ n
    local nTemp = math.floor(nNum * nDecimal);
    local nRet = nTemp / nDecimal;
    return nRet;
end



function GetPingValue:getFormatPingValue(_pingValue)
	local result = ""
	local tmp = _pingValue 
	result = string.format("%010.3f", tmp)
	return result
end



function GetPingValue:init()
	if self.tbBegTimeStamp == nil then
		self.tbBegTimeStamp	= {}
	end

	if self.tbEndTimeStamp == nil then
		self.tbEndTimeStamp	= {}
	end

	if self.recvCursor == nil then
		self.recvCursor	= 0
	end

	if self.tbPingValue == nil then
		self.tbPingValue = {}
	end
end



function GetPingValue:getTimeStampOfSendHeart()
	self:init()
	table.insert(self.tbBegTimeStamp, socket.gettime())
end



function GetPingValue:getTimeStampOfRecvHeart()
	table.insert(self.tbEndTimeStamp, socket.gettime())
	self.recvCursor = self.recvCursor + 1

	local tmpPingValue = self.tbEndTimeStamp[self.recvCursor] - self.tbBegTimeStamp[self.recvCursor]
	tmpPingValue = self:getPreciseDecimal(tmpPingValue, 3)
	table.insert(self.tbPingValue, tmpPingValue)

	local strTime = self:getFormatPingValue(tmpPingValue)
	
	if self.callBackFunc ~= nil then
		if bm.isInGame ~= nil then				-- 此条件不可靠
			if bm.isInGame == true then		
				self.callBackFunc(strTime)
			end
		end
	end
	

	if #self.tbPingValue > MAX_LEN_TMP_ARR then
		table.remove(self.tbPingValue, 1)
	end

	if #self.tbBegTimeStamp == #self.tbEndTimeStamp then
		self.tbBegTimeStamp = {}
		self.tbEndTimeStamp = {}
		self.recvCursor = 0
	end
end



function GetPingValue:setUpdateCallBackFunc(_callBackFunc)
	self.callBackFunc = _callBackFunc
end



return GetPingValue
