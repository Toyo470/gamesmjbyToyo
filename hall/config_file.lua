-- --
-- -- Author: chen
-- -- Date: 2016-05-23-10:48:17
-- --
-- --读取指定文件
-- function getFile(file_name)
--   local f = assert(io.open(file_name, 'r'))
--   local strr = f:read("*all")
--   f:close()
--   return strr
-- end

-- --字符串写入
-- function writeFile(file_name,strr)
--  local f = assert(io.open(file_name, 'w'))
--  f:write(strr)
--  f:close()
-- end
require("hall.dataConfig")
local Config_File = class("Config_File")

function Config_File:ctor(file_name)
	print("gao xiao ba")
	 -- self.key_value_dic = {}
	 -- self.file_name = file_name

	 -- self.enter_code = ""
end

function Config_File:init()
	--  local file_path = self.file_name 
	 
	--  local targetPlatform = cc.Application:getInstance():getTargetPlatform()
	--  if  cc.PLATFORM_OS_WINDOWS  ~= targetPlatform then
	--  	local path = device.writablePath
	-- 	file_path = path .. "/"..self.file_name 
	--  end

	-- if io.open(file_path, 'r') ~= nil then
		
	-- 	 local str = getFile(file_path)
	-- 	 dump(json.decode(str))
	-- 	 --print(str,"--------------------------str-----",))
	-- 	 self.key_value_dic = json.decode(str)

	-- else
	-- 	-- print("con't open file",self.file_name)
	-- 	--printError("con't open json file")
	-- end
end

function Config_File:out_put_file()
	-- local dict = {}
	-- dict["UID"] = 524

	-- dict["user_info"] = {}
	-- dict["user_info"]["uid"] = dict["UID"]
	-- dict["user_info"]["nick"] = tostring(dict["UID"])
	-- dict["user_info"]["gold"] = 2000000000
	-- dict["user_info"]["enter_mode"] = 0
	-- dict["user_info"]["type"] = "p"
	-- dict["user_info"]["duniuCompId"] = 204
	-- dict["user_info"]["GroupLevel"] = 36

	-- local str = json.encode(dict)

	-- writeFile(self.file_name,str) 

end


-- function Config_File:get_value_one(key)
-- 	return self.key_value_dic[key] or ""
-- end

-- function Config_File:get_value(key_1,key_2)
-- 	if key_2 == nil then
-- 		return self:get_value_one(key_1)
-- 	else
-- 		local dict =  self.key_value_dic[key_1] or {}
-- 		return dict[key_2] or ""
-- 	end
-- end





--0是大厅，大于0以上是组局模式进入
--niuniu majiang
-- function Config_File:set_eter_code(enter_code)
-- 	enter_code = enter_code or ""
-- 	self.enter_code = enter_code
-- end

function Config_File:get_user_info()
	-- local user_info_str = "user_info"
	-- self.enter_code = self.key_value_dic["enter_game"] or ""
	-- if self.enter_code ~= "" then
	-- 	user_info_str = user_info_str .. "_"..self.enter_code
	-- end
	-- return self.key_value_dic[user_info_str] or {}
	--return dataConfig.UID
	--self:get_user_info()
end


function Config_File:get_user_info_value(key_1)
	-- local value_dict =  self:get_user_info()
	-- return value_dict[key_1] or ""
end

function Config_File:get_duniuCompId()
	-- local value_dict =  self:get_user_info()
	-- return value_dict["duniuCompId"] or 0

	return dataConfig.user_info_douniu.duniuCompId
end

function Config_File:get_enter_mode()
	-- local value_dict =  self:get_user_info()
	-- return value_dict["enter_mode"] or 0
	return  dataConfig.enter_mode
end


function Config_File:get_enter_code()
	local v = dataConfig[dataConfig.comb[dataConfig.enter_mode]]
	return  v.enter_code
end

function Config_File:get_diamond()
	local v = dataConfig[dataConfig.comb[dataConfig.enter_mode]]
	return  v.diamond
end

function Config_File:get_gold()
	local v = dataConfig[dataConfig.comb[dataConfig.enter_mode]]
	return  v.gold
end

function Config_File:get_type()
	
	local v = dataConfig[dataConfig.comb[dataConfig.enter_mode]]
	return  v.type
end

function Config_File:get_nick()
	local v = dataConfig[dataConfig.comb[dataConfig.enter_mode]]
	return  v.nick
end

function Config_File:get_activity_id()
	local v = dataConfig[dataConfig.comb[dataConfig.enter_mode]]
	return  v.activity_id
end

function Config_File:get_invote_code()
	local v = dataConfig[dataConfig.comb[dataConfig.enter_mode]]
	return  v.invote_code
end

function Config_File:get_group_tableid()
	local v = dataConfig[dataConfig.comb[dataConfig.enter_mode]]
	return  v.group_tableid
end

function Config_File:get_GroupLevel()
	local v = dataConfig[dataConfig.comb[dataConfig.enter_mode]]
	return  v.GroupLevel
end




function Config_File:get_verify()
	local isVerify = isVerify--self.key_value_dic["isVerify"]
	if not isVerify then
		isVerify = false
	end
		-- isVerify = true
	return  isVerify
end

--获取用户id
function Config_File:get_user_id()
	--我所知道的可以用的id
	--504,514,524,534,274,284,294,304,314,324,334,
	--354,364,384,394,404,414,424,444,454
	return dataConfig.UID
end


--获取ip地址
function Config_File:get_ip()
	return dataConfig.ip
end

--获取ip端口
function Config_File:get_ip_port()
	return dataConfig.port
end

--是否需要检查更新
function Config_File:get_needUpdate()
	--print("self.key_value_dic[needUpdate]========",self.key_value_dic["needUpdate"])
	local needUpdate = needUpdate--self.key_value_dic["needUpdate"]
	if not needUpdate == nil then
		needUpdate = false
	end
	--	needUpdate = true
	return  needUpdate
end

return Config_File
-- function Init_config_file(file_name)

-- 	return  Config_File.new(file_name)
	
-- end


-- require("chq_tool.Config_File")
-- Init_config_file(file_name)
