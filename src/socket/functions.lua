--
-- Date: 2014-07-11 13:47:18
--
require("lfs")

local functions = {}
local socket = require("socket")

function functions.getTime()
    return socket.gettime()
end

function functions.isFileExist(path)
    return CCFileUtils:sharedFileUtils():isFileExist(path)
end

function functions.isDirExist(path)
    local success, msg = lfs.chdir(path)
    return success
end
 
function functions.mkdir(path)
    cc.LuaLog("mkdir " .. tostring(path))
    if not functions.isDirExist(path) then
        local prefix = ""
        if string.sub(path, 1, 1) == device.directorySeparator then
            prefix = device.directorySeparator
        end
        local pathInfo = string.split(path, device.directorySeparator)
        local i = 1
        while(true) do
            if i > #pathInfo then
                break
            end
            local p = string.trim(pathInfo[i] or "")
            if p == "" or p == "." then
                table.remove(pathInfo, i)
            elseif p == ".." then
                if i > 1 then
                    table.remove(pathInfo, i)
                    table.remove(pathInfo, i - 1)
                    i = i - 1
                else
                    return false
                end
            else
                i = i + 1
            end
        end
        for i = 1, #pathInfo do
            local curPath = prefix .. table.concat(pathInfo, device.directorySeparator, 1, i) .. device.directorySeparator
            if not functions.isDirExist(curPath) then
                --print("mkdir " .. curPath)
                local succ, err = lfs.mkdir(curPath)
                if not succ then 
                    cc.LuaLog("mkdir " .. path .. " failed, " .. err)
                    return false
                end
            else
                --print(curPath, "exists")
            end
        end
    end
    cc.LuaLog("done mkdir " .. tostring(path))
    return true
end
 
function functions.rmdir(path)
    cc.LuaLog("rmdir " .. path)
    if functions.isDirExist(path) then
        local function _rmdir(path)
            local iter, dir_obj = lfs.dir(path)
            while true do
                local dir = iter(dir_obj)
                if dir == nil then break end
                if dir ~= "." and dir ~= ".." then
                    local curDir = path..dir
                    local mode = lfs.attributes(curDir, "mode") 
                    if mode == "directory" then
                        _rmdir(curDir.."/")
                    elseif mode == "file" then
                        --print("remove file ", curDir)
                        os.remove(curDir)
                    end
                end
            end
            --print("rmdir ", path)
            local succ, des = lfs.rmdir(path)
            if not succ then cc.LuaLog("remove dir " .. path .. " failed, " .. des) end
            return succ
        end
        _rmdir(path)
    end
    cc.LuaLog("done rmdir " .. path)
    return true
end

function functions.readFile(path)
    local file = io.open(path, "rb")
    if file then
        local content = file:read("*all")
        io.close(file)
        return content
    end
    return nil
end

function functions.removeFile(path)
    io.writefile(path, "")
    if device.platform == "windows" then
        os.execute("del " .. string.gsub(path, '/', '\\'))
    else
        os.execute("rm " .. path)
    end
end

function functions.checkFile(fileName, cryptoCode)
    if not io.exists(fileName) then
        return false
    end

    local data=functions.readFile(fileName)
    if data==nil then
        return false
    end

    if cryptoCode=="nil" or cryptoCode == "" or cryptoCode == nil then
        return true
    end
    local ms = crypto.md5file(fileName)
    if ms==cryptoCode then
        return true
    end

    return false
end

function functions.checkDirOK( path )
    local oldpath = lfs.currentdir()
    CCLuaLog("old path------> "..oldpath)
    if lfs.chdir(path) then
        lfs.chdir(oldpath)
        CCLuaLog("path check OK------> "..path)
        return true
    end

    if lfs.mkdir(path) then
        CCLuaLog("path create OK------> "..path)
        return true
    end
end

--获取APP版本号
function  functions.getAppVersion()
    local ok, version
    if device.platform == "android" then
        ok, version = luaj.callStaticMethod("com/boyaa/cocoslib/core/functions/GetAppVersionFunction", "apply", {}, "()Ljava/lang/String;")
        if ok then
            return version
        end
    elseif device.platform == "ios" then
        ok, version = luaoc.callStaticMethod("LuaOCBridge", "getAppVersion", nil)
        if ok then
            return version
        end
    end
end

function functions.getVersionNum(version, num)
    local versionNum = 0
    if version then
        local list = string.split(version, ".")
        for i = 1, 4 do
            if num and num > 0 and i > num then
                break
            end
            if list[i] then
                versionNum = versionNum  + tonumber(list[i]) * (100 ^ (4 - i))
            end
        end
    end
    return versionNum
end


function functions.buttontHandler(obj,method)

    
    obj:addTouchEventListener(function(event,type)
         if(type == 2) then

            cc.SimpleAudioEngine:getInstance():playEffect("music/Audio_Button_Click.mp3",false)
            event.obj = obj
            method(event,type)            
        end

    end)
            
end

function functions.exportMethods(target)
    for k, v in pairs(functions) do
        if k ~= "exportMethods" then
            target[k] = v
        end
    end
end

return functions