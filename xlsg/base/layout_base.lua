LayoutBase = class("LayoutBase", function ()
    return ccui.Layout:create()
end
)

function LayoutBase:ctor(name,other_index)
 --print("name---LayoutBase----------------",name)
    if other_index ~= nil 
        then other_index = tostring(other_index)
    else
        other_index = ""
    end

    --self:enableNodeEvents()
    self.name_ = name..other_index
    self.child_object_flag = false
    self.is_hide_clear = true
    self.release_flag = false
    self.need_update = false
    self.resource_base_name = ""--csloader加载后返回的节点名（名字+index）
    self.child_layout_name_list = {}
    
   
   -- print("self.child_object_flag",self.child_object_flag)

end

function LayoutBase:initialize(other_index)
    -- body
    self:_do_prepare_init(other_index)
    self:_do_after_init() 
end

function LayoutBase:_do_after_init()
end

function LayoutBase:_do_prepare_init()
end

function LayoutBase:add_child_layout_name(layout_name)
   -- print("viewbase====================",layout_name)
    if type(layout_name) == "string" then
        table.insert(self.child_layout_name_list,layout_name)
    end
end

function LayoutBase:getName()
    return self.name_
end

function LayoutBase:getResourceNode()
    return self.resourceNode_
end

function LayoutBase:set_resource_base_name(name)
    self.resource_base_name = name
end

function LayoutBase:get_resource_base_name()
    return self.resource_base_name
end

function LayoutBase:set_child_flag(flag)
    self.child_object_flag = flag
end

function LayoutBase:get_child_flag()
    return self.child_object_flag
end

function LayoutBase:set_hide_clear(flag)
    self.is_hide_clear = flag
end

function LayoutBase:get_hide_clear()
    return self.is_hide_clear
end

function LayoutBase:get_update_flag()
    return self.need_update
end

function LayoutBase:set_update_flag(flag)
    self.need_update = flag
end


function LayoutBase:is_release()
    return self.release_flag
end

function LayoutBase:update(dt)
end

function LayoutBase:show_layout()
    self:setVisible(true)
end

function LayoutBase:hide_layout()
    self:setVisible(false)
    --print("self.is_hide_clear-----------------",self.is_hide_clear,"--self.release_flag-------",self.release_flag)

    if self.is_hide_clear == true and self.child_object_flag == false then
        self.release_flag = true
    end
end

function LayoutBase:release()
    --print("releaselayout----------------layout_name:", self.name_)
    self:before_release()
    
    if layout.manager ~= nil then
        for _,_layout_name in pairs(self.child_layout_name_list)do
            layout.manager:del_layout_object(_layout_name)
        end
    end
    layout.manager:del_layout_object(self.name_)

   -- print("===============================================")
   -- ui.dump_widget()
    local getChildren = self:getChildren()
    for _,child in pairs(getChildren) do
        ui.manager:release_widget(child)
    end

   -- ui.dump_widget()

    self:removeSelf()
end


function LayoutBase:before_release()
    -- body
end



