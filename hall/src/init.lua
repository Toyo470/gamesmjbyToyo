
-- 初始化
local writepath = cc.FileUtils:getInstance():getWritablePath()
local hall_src = "hall/src/"
local hall_res = "hall/res/"
local write_hall_src = string.format("%s%s",writepath, hall_src)
local write_hall_res = string.format("%s%s",writepath, hall_res)
cc.FileUtils:getInstance():addSearchPath(write_hall_src)
cc.FileUtils:getInstance():addSearchPath(write_hall_res)
cc.FileUtils:getInstance():addSearchPath(hall_src)
cc.FileUtils:getInstance():addSearchPath(hall_res)
-- 加载框架
import(".framework.loader")

-- 加载文件
import(".FileMgr")
