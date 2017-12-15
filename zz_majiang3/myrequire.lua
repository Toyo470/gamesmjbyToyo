--2015/1/25
local function useModuleRequire() 

local function importModule(name)
	local package_name = nil
	local pos = string.find(name, ".init")
	if pos ~= nil then
		package_name = string.sub(name, 1, pos -1)
		--print (string.format("package_name=%s", package_name))
		package.loaded[package_name] = true
	else
		package.loaded[name] = true
	end
	
	--local MiddleApi = luanet.import_type("MiddleApi")
	local filepath = string.gsub(name, "%.", "/") .. ".lua"
	--print ("***filepath = ",filepath)
	
	--local filedata = MiddleApi.getFileDataFromScript(filepath)
	--cc.FileUtils:getInstance():addSearchPath("zz_majiang3/")
	local FileUtils = require("zz_majiang3.fileutils")
	local filedata = FileUtils:getStringFromFile(filepath)

	--print("filedata",type(filedata),"---------",filedata)
	if filedata == "" then
			printError ("***fail to get file = ",filepath)
		 return nil
	end
	
	local loadRes,error_str = loadstring(filedata)
	--print("-----------loadRes-----------",loadRes)
	if loadRes == nil then
			print("error_str",error_str)
			--printError ("***fail to loadstring = ",filepath)
		return nil
	end
	
	local target_env = nil
	--print ("**********package_name = ",name,"-------",filepath,"*******************",loadRes)
	
	if package_name ~= nil then--如果是包模块(packag.init)
		--new package
		--print("---------zzzz",name)
		 local package_dict = _G["package_dict"]
		 package_dict[package_name] = {}
		 
		 local env={}
		 local function find_key(table, key)
				local package_dict = _G["package_dict"]
				local package_info = package_dict[package_name]
				--print("********************key*******************",key)
				if package_info ~= nil and package_info[key] then
					return package_info[key]
				else
				 return _G[key]
				end
		 end
		 setmetatable(env, {__index = find_key})
		 local env2 = setfenv(loadRes,env)()
		 if env2 ~= nil and type(env2) == "table" then
			 env = env2
		 end
		 
		 _G[package_name] = env
		 target_env = env
		 package.loaded[package_name] = env
		--print(string.format("module %s loaded", package_name))
		--print("********************************type(env) = ",type(env),env)
		--print("name=================",package_name)
 
	elseif string.find(name, "%.") == nil then --纯粹的一个文件
		--a.lua
		 --print("---------xxxx",name)
		 local env={}
		 setmetatable(env, {__index = _G})
		 local env2 = setfenv(loadRes,env)()
		 if env2 ~= nil and type(env2) == "table" then
			 env = env2
		 end
		 
		 _G[name] = env
		 target_env = env
		 package.loaded[name] = env
		 local file_tbl = _G["file_dict"]
		 file_tbl[name] = {}
		-- print(string.format("module %s loaded", name))
		--print ("**********module loaded = ",name)
		--print("name=================",name)
	else--模块的文件
		--a/b.lua
		
		local env={}
		setmetatable(env, {__index = _G})
		local callback = setfenv(loadRes,env)
		--print("---------ssss",loadRes,"----",name,"------",callback)
		local env2 = callback()
		if env2 ~= nil and type(env2) == "table" then
			env = env2
		end
		
		pos = string.find(name, "%.")
		package_name = string.sub(name, 1, pos - 1) --获取包名，
		local package_dict = _G["package_dict"]
		local package_info = package_dict[package_name]
		local module_name = string.sub(name, pos + 1, string.len(name))--获取模块名
		package_info[module_name] = env
		
		_G[name] = env
		target_env = env
		package.loaded[name] = env
		--print(string.format("module %s loaded", name))
		--print("name---file--------",name,type(name))
		--print("name=================",name)
	end--if
	return target_env
 end







 local function moduleRequire(name)
	--print(string.format("-----load %s", name))
	if name == nil or string.len(name) == 0 then
		return nil
	end
	
	if package.loaded[name] then
		return package.loaded[name]
	end
	
	local env = nil
	local pos = string.find(name, "%.")--查找"."是否存在，存在的话，表示有多级test.layout,没有的话，就只有一个文件,如：common
	--print("name----------------",name,"pos-------------",pos)
	if pos == nil then
		--it's package?
		local test_path = name .."/init.lua"
		--print(test_path)
		
		--local MiddleApi = luanet.import_type("MiddleApi")
		--local ret = MiddleApi.hasScriptFile(test_path)
		--local ret = cc.FileUtils:getInstance():isFileExist(test_path)
		local FileUtils = require("zz_majiang3.fileutils")
		local ret = FileUtils:isFileExist(test_path)
		if ret == true then
			--is package
			--print(string.format("--%s--- is package", name))----------------加载包，其实是加载包的init文件
			env = importModule(name ..".init")
			
		else
			--print(string.format("------importModule(%s)", name))------------纯粹的加载一个文件
			env = importModule(name)
		end
	else
		local package_name = string.sub(name, 1, pos -1)
		--print("pacage_name---------------",package_name)
		local parent = package.loaded[package_name]------------------------加载包里的文件，先判断包的init文件是否被加载了，
		--print("parent---------------",parent)------------------------------没有的话，那就先加载，然后再加载包的文件
		if parent == nil then
			--require "a.b" a not loaded
			importModule(package_name ..".init")
		end
		env = importModule(name)
	end
	--print("******************env**********************",name,env)
	return env
 end --moduleRequire
-- _G.originalRequire = _G.require
 _G.mrequire = moduleRequire
 _G["package_dict"] = {}
 _G["file_dict"] = {}
-- print("----------newmyrequire----------")
end


if (_G["check_require"] == nil) then
	print("!!!!!!!!!!!!!_G.require")
	useModuleRequire()
	 _G["check_require"] = true
end

--print("********************_G.require*******************",_G.require)
