local FileUtils = class("FileUtils")

function FileUtils:ctor()
end

function FileUtils:getStringFromFile(filepath)
	-- body


	local writepath = cc.FileUtils:getInstance():getWritablePath()

	local filedata;


	local test_filepath = writepath .. "fzz_majiang/"..filepath

	if cc.FileUtils:getInstance():isFileExist(test_filepath..".luac") then --luac在写入路径
		--todo
		filedata=cc.Crypto:decryptFileXXTEA(test_filepath..".luac")
	elseif cc.FileUtils:getInstance():isFileExist("fzz_majiang/"..filepath..".luac") then --luc 在本地
		--todo
		filedata=cc.Crypto:decryptFileXXTEA("fzz_majiang/"..filepath..".luac")
	elseif  cc.FileUtils:getInstance():isFileExist(test_filepath..".lua") then --lua 在写入路劲
		filedata = cc.FileUtils:getInstance():getStringFromFile(test_filepath)
	else 
		filedata = cc.FileUtils:getInstance():getStringFromFile("fzz_majiang/"..filepath)
	end


	return filedata

end

function FileUtils:isFileExist(test_path)
	-- body
	local ret = false
	local writepath = cc.FileUtils:getInstance():getWritablePath()
	local w_test_path = writepath .. "fzz_majiang/"..test_path

	ret = cc.FileUtils:getInstance():isFileExist(w_test_path)
	if ret == false then
		ret = cc.FileUtils:getInstance():isFileExist("fzz_majiang/"..test_path)
	end
	return ret
end

return FileUtils