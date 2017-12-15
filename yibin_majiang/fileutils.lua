local FileUtils = class("FileUtils")

function FileUtils:ctor()
end

function FileUtils:getStringFromFile(filepath)
	-- body
	local writepath = cc.FileUtils:getInstance():getWritablePath()
	local test_filepath = writepath .. GAMEBASENAME.."/"..filepath
	local filedata = cc.FileUtils:getInstance():getStringFromFile(test_filepath)

	if filedata == "" then
 		filedata = cc.FileUtils:getInstance():getStringFromFile(GAMEBASENAME.."/"..filepath)
	end

	return filedata
end

function FileUtils:isFileExist(test_path)
	-- body
	local ret = false
	local writepath = cc.FileUtils:getInstance():getWritablePath()
	local w_test_path = writepath .. GAMEBASENAME.."/"..test_path

	ret = cc.FileUtils:getInstance():isFileExist(w_test_path)
	if ret == false then
		ret = cc.FileUtils:getInstance():isFileExist(GAMEBASENAME.."/"..test_path)
	end
	return ret
end

return FileUtils