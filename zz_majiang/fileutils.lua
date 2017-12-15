local FileUtils = class("FileUtils")

function FileUtils:ctor()
end

function FileUtils:getStringFromFile(filepath)
	-- body
	local writepath = cc.FileUtils:getInstance():getWritablePath()

	local filedata;


	local test_filepath = writepath .. "zz_majiang/"..filepath

	print(filepath,"nimaB")

	if cc.FileUtils:getInstance():isFileExist(test_filepath) then --luac在写入路径
		--todo
		print("1",cc.FileUtils:getInstance():getFileExtension(test_filepath))
		if cc.FileUtils:getInstance():getFileExtension(test_filepath)==".luac"  then
			--todo
			filedata=cc.Crypto:decryptFileXXTEA(test_filepath)
		else
			filedata=cc.FileUtils:getInstance():getStringFromFile(test_filepath)
		end
		
	elseif cc.FileUtils:getInstance():isFileExist("zz_majiang/"..filepath) then --luc 在本地
		--todo
		if cc.FileUtils:getInstance():getFileExtension("zz_majiang/"..filepath)==".luac"  then
			--todo
			filedata=cc.Crypto:decryptFileXXTEA("zz_majiang/"..filepath)
		else
			filedata=cc.FileUtils:getInstance():getStringFromFile("zz_majiang/"..filepath)
		end

		print("2",cc.FileUtils:getInstance():getFileExtension("zz_majiang/"..filepath))

	else
		filedata=cc.FileUtils:getInstance():getStringFromFile("zz_majiang/"..filepath)
		if filedata=="" then
			filedata=cc.FileUtils:getInstance():getStringFromFile(test_filepath)
		end
		print("5")
	end


	return filedata



end

function FileUtils:isFileExist(test_path)
	-- body
	local ret = false
	local writepath = cc.FileUtils:getInstance():getWritablePath()
	local w_test_path = writepath .. "zz_majiang/"..test_path

	ret = cc.FileUtils:getInstance():isFileExist(w_test_path)
	if ret == false then
		ret = cc.FileUtils:getInstance():isFileExist("zz_majiang/"..test_path)
	end
	return ret
end

return FileUtils