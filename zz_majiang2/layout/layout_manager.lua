-- module(..., package.seeall)
mrequire("scene.scene_main")

LayoutManager = class("LayoutManager")

function LayoutManager:ctor()
	self.layout_object_dict = {}
	self.layout_style_dict = {}

	self.running_scene = nil

	self.layout_file_path = "res/layout/layout_define.json"
end

function LayoutManager:release()
	self.layout_object_dict = {}
	self.layout_style_dict = {}
	self.running_scene = nil
	-- local pathlog = "D:/project/DouYouGame/simulator/win32/log.txt"
	-- local content = "function MainScene:onExit()------"
	-- io.writefile(pathlog, content)
	print("-------------------------LayoutManager:release()--")
end

function LayoutManager:set_runningscene(scene)
	print(scene.name_,"----set_runningscene-------scene.name_------------------")
	self.running_scene = scene
end

function LayoutManager:get_runningscene()
	local scene =  cc.Director:getInstance():getRunningScene()
	if scene ~= nil then
		--print("return ------------------running----------")
		return scene
	else
		--print("return ------------------save----------")
		return self.running_scene
	end
end

function LayoutManager:del_layout_object(layout_name)
	if self.layout_object_dict[layout_name] == nil then
		return
	end
	self.layout_object_dict[layout_name] = nil
end

function LayoutManager:initialize()
	--local scene = scene.scene_main.MainScene.new()
	--display.runScene(scene)

	--self:set_runningscene(scene)

	self:init_layout_file()
end

function LayoutManager:update_layout(dt)
	local release_layout_list = {}
	for layout_index, layout_object in pairs(self.layout_object_dict) do
		-- print("-----layout_object:is_release() == true-------------",layout_index,layout_object)
		if layout_object:get_child_flag() == false and layout_object:is_release() == true then	
			table.insert(release_layout_list,layout_index)
		end
		
		if layout_object:get_update_flag() == true then
			layout_object:update(dt)
		end
	end
	
	for _,layout_index in pairs(release_layout_list) do
		--print("layout_index-----------------------------",layout_index)
		local layout_object = self.layout_object_dict[layout_index]
		if layout_object ~= nil then
			layout_object:release()
			--ui.dump_widget()
		end
	end
end


function LayoutManager:hide_all_layout()
	for _,layout_object in pairs(self.layout_object_dict) do
		layout_object:hide_layout()
	end
end

function LayoutManager:init_layout_file()
	local layout_file_path = self.layout_file_path
	local FileUtils = require("zz_majiang2.fileutils")
    local str = FileUtils:getStringFromFile(layout_file_path)

	local root_table = json.decode(str)
	local file_table = root_table["file_list"]
	--print("*********************************************LayoutManager:init_layout_file = ",define_path,"--------",file_table)
	if file_table == nil then
	 	return
	end
	
	for _,layout_table in pairs(file_table) do
		local layout_style = layout_table["layout_style"]
		local layout_name = layout_table["layout_name"]
		--print("---------layout_style = ",layout_style,"--------------",layout_name)
		self.layout_style_dict[layout_name] = layout_style
	end

	--dump(self.layout_style_dict)
end

function LayoutManager:parser_csb_node(resourceNode_,other_index)
	if resourceNode_ == nil then
		return
	end
	local widget_name = resourceNode_:getName()..tostring(other_index)
	--print("widget_name-------------------------",widget_name)
	resourceNode_:setName(widget_name)
	ui.manager:add_widget_object(widget_name,resourceNode_)
	--print("resourceNode_------------",resourceNode_:getName())

    local getChildren = resourceNode_:getChildren()
    for _,child in pairs(getChildren) do
    	self:parser_csb_node(child,other_index)
    end
end

function LayoutManager:create_layout_object(layout_name, other_index,parent_widget,is_need_game_bg,is_hide_clear,item_layout)
	item_layout  = item_layout or false
	local other_index = other_index or ""
	--print("------------------------other_index-----------------",other_index)
   -- ui.dump_widget()

	local layout_object  = nil 
	local packageName = self.layout_style_dict[layout_name]

	local packageName_tbl = string.split(packageName,".")
	-- print("pos++++++++++++++++++++++++++++++-----",pos)
	-- dump(pos)
	local path_str = packageName_tbl[1]
	for i=2,table.nums(packageName_tbl)-1 do
		path_str = path_str ..".".. packageName_tbl[i]
	end

	--print("path_str++++++++++++++++++",path_str)

	local module_state = mrequire(path_str)
	--print("----------------1-----------------------------------")
	local full_object_path  = ""
	if module_state ~= nil then
		full_object_path = "layout_class = " .. packageName
		
		loadstring(full_object_path)()
	else
		_G.layout_class = nil
	end
	
	if _G.layout_class == nil then
		
		layout_object = layout.layout_object.LayoutObject.new(layout_name, other_index)
	else
		--print("----------------2-----------------------------------")
		layout_object = _G.layout_class.new(layout_name, other_index)
	end
	--print(layout_object.__cname,"-------------__cname----------")
	if layout_object == nil then
		printError("layout_object == nil "..packageName)
		return nil
	end


	local resourceFilename = "zz_majiang2/res/layout/"..tostring(layout_name) .. ".csb"
	local resourceNode_ = cc.CSLoader:createNode(resourceFilename)
	if resourceNode_ == nil then
		printError("resourceNode_== nil "..resourceFilename)
		return nil
	end
    
    --这个是为了去掉csb到进来的基础节点
	local getChildren = resourceNode_:getChildren()
    for _,child in pairs(getChildren) do
    	--child:removeFromParentAndCleanup(false)
    	child:removeFromParent()
    	layout_object:addChild(child)
    end

    --这个是为了去掉csb到进来的基础节点
    local getChildren = layout_object:getChildren()
    for _,child in pairs(getChildren) do
    	self:parser_csb_node(child,other_index)
    end


    layout_object:initialize(other_index)
	--print("resourceNode_++++++++++++++++++++++++++++",resourceNode_:getName())
	--layout_object:set_resource_base_name(resourceNode_:getName())
	layout_object:set_hide_clear(is_hide_clear)
	layout_object:setVisible(true)
	if item_layout ~= true then
		if parent_widget == nil then 
		    local scene = self:get_runningscene()
		    if scene ~= nil then
		        if scene:getChildByName(layout_name .. other_index) == nil then
		           scene:addChild(layout_object)
		        end
		    end
		    layout_object:setName(layout_name .. other_index)
		    layout_object:set_child_flag(false)
		else
			parent_widget:addChild(layout_object)
			parent_widget:add_child_layout_name(layout_name .. other_index)
			layout_object:setName(layout_name .. other_index)
			layout_object:set_child_flag(true)
		end
	else
		--print("---------------------+++++----------------------------")
		parent_widget:add_child_layout_name(layout_name .. other_index)
		layout_object:set_child_flag(true)
		layout_object:retain()
	end

	self.layout_object_dict[layout_name .. other_index] = layout_object

	return layout_object
end

function LayoutManager:get_layout_object(layout_name,other_index)
	other_index = other_index or ""
	layout_name = layout_name ..other_index
	return self.layout_object_dict[layout_name]
end


function LayoutManager:hide_layout(layout_name)
	local layout_object = self:get_layout_object(layout_name)
	
	if layout_object ~= nil then
		layout_object:hide_layout()
	end
end

function LayoutManager:dump_layout_name()
	for _name,_object in pairs(self.layout_object_dict) do
		print("layout_name---_object------------------",_name,"-----",_object)
	end
end
