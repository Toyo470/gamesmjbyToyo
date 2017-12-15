local FileUtils = class("FileUtils")

function FileUtils:ctor()
end

function FileUtils:getStringFromFile(filepath)
	-- body
	local writepath = cc.FileUtils:getInstance():getWritablePath()
	local test_filepath = writepath .. "zz_majiang3/"..filepath
	local filedata = cc.FileUtils:getInstance():getStringFromFile(test_filepath)

	if filedata == "" then
 		filedata = cc.FileUtils:getInstance():getStringFromFile("zz_majiang3/"..filepath)
	end

	return filedata
end

function FileUtils:isFileExist(test_path)
	-- body
	local ret = false
	local writepath = cc.FileUtils:getInstance():getWritablePath()
	local w_test_path = writepath .. "zz_majiang3/"..test_path

	ret = cc.FileUtils:getInstance():isFileExist(w_test_path)
	if ret == false then
		ret = cc.FileUtils:getInstance():isFileExist("zz_majiang3/"..test_path)
	end
	return ret
end

return FileUtils