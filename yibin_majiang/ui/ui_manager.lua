-- module(..., package.seeall)
UiManager = class("UiManager")

function UiManager:ctor()
end

function UiManager:initialize()
	self.widget_object_dict = {}
	
end

--ui更新貌似可以不用了。C++那边已经做了
function UiManager:update()
	-- for _,widget_object in pairs(self.widget_object_dict) do
	-- 	if widget_object:check_widget_update() == true then
	-- 		widget_object:update()
	-- 	end
	-- end
end

function UiManager:release()
	self.widget_object_dict = {}
	print("-------------------------UiManager:release()--")
end

function UiManager:get_widget_object_dict()
	return self.widget_object_dict
end

function UiManager:release_widget(widget_object)
	local name = widget_object:getName()
	--print("name------------------",name)
	self.widget_object_dict[name] = nil  ----从widget_object表删除

	local getChildren = widget_object:getChildren()
    for _,child_widget in pairs(getChildren) do
    	self:release_widget(child_widget)
    end
end

function UiManager:get_widget_object(widget_name)
	return self.widget_object_dict[widget_name]
end

function UiManager:add_widget_object(widget_name,widget)
	--print("add_widget_object-----------------",widget_name)
	self.widget_object_dict[widget_name] = widget
end

function UiManager:register_widget_object(widget_name,other_index)
	other_index = other_index or ""
	return self.widget_object_dict[widget_name..other_index]
end