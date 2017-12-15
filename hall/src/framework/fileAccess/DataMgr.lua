

local DataMgr = class("DataMgr")

function DataMgr:getInstance()
	if DataMgr.instance == nil then
		DataMgr.instance = DataMgr.new()	
	end
	return DataMgr.instance
end

function DataMgr:delInstance()
	if DataMgr.instance == nil then
		DataMgr.instance = nil
	end
end

function DataMgr:ctor( )
	self._DataList = {} 
end

function DataMgr:addJsonFile(name, filePath)

	local path = cc.FileUtils:getInstance():fullPathForFilename(filePath)
	if not cc.FileUtils:getInstance():isFileExist(path) then
		print("file not exist : %s", filePath)
		return
	end

	local contents = cc.FileUtils:getInstance():getStringFromFile(path)
	local jsonStr = json.decode(contents)
	self._DataList[name] = jsonStr
end

function DataMgr:getData( name )
	if nil ~= self._DataList[name] then
		return self._DataList[name]
	end
end

function DataMgr:delData(name)
	if nil ~= self._DataList[name] then
		self._DataList[name] = nil
	end
end

function DataMgr:delAllData()
	self._DataList = {}
end

function DataMgr:getDataBykey( name , key )
	if nil ~= self._DataList[name] then
		local data = self._DataList[name]
		return data[key]
	end
end

function DataMgr:delDataByKey( name , key )
	if nil ~= self._DataList[name] then
		local data = self._DataList[name]
		if nil ~= data[key] then
			data[key] = nil
		end
	end
end

rawset(_G, "DataMgr", DataMgr)