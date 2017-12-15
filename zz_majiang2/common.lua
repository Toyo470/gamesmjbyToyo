--
-- Author: chen
-- Date: 2016-07-05-17:18:47
--
function getChildbyspecname(resourceNode_,name,tag)
    tag = tag or -1 -- -1是node tag的默认值
    local node = resourceNode_:getChildByName(name)
    
    if node ~= nil and node:getTag() == tag then 
        return node
    else
        local getChildren = resourceNode_:getChildren()
        for _,child in pairs(getChildren) do
            local childfindnode = getChildbyspecname(child,name,tag)
            if childfindnode ~= nil then
                node = childfindnode
                break
            end

        end
    end
    return node
end


function get_file_list_from_config(file_dir)
    local define_path = "config/"..tostring(file_dir).. "/file_list.json"
    print("---------------------get_file_list_from_config-----------------------",define_path)
    local FileUtils = require("zz_majiang2.fileutils")
    local str = FileUtils:getStringFromFile(define_path)
    print("str",str)
    local root_table = json.decode(str)
    local file_table = root_table["file_list"]
    dump(file_table,"file_table")
    return file_table
end


