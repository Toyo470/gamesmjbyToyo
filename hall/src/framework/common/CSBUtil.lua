
local CSBUtil = {}

--[[ 
    @读取csb文件
    CONTROLS_LIST: csb里面的子控件列表
]]
function CSBUtil.load(strFilePath, CONTROLS_LIST , owner)
	local node = cc.CSLoader:createNode(strFilePath)
 	CSBUtil.bind(node, strFilePath, CONTROLS_LIST, owner)
    return node
end

function CSBUtil.bind(root, strFilePath, CONTROLS_LIST, owner) 
	local controlsListEnpty = true
	for k, config in pairs(CONTROLS_LIST) do
		controlsListEnpty = false
		local name = k
		local saveName = name
		if nil ~= config.name then
			saveName = config.name
		end
		CSBUtil._bindItem(root, owner, name, saveName, config)
	end
end

function CSBUtil._bindItem(root, owner, name, saveName, config)
	
	local child = root
	local pointIndex = string.find(name, "%.")
	if nil ~= pointIndex then 
		while true do
			pointIndex = string.find(name, "%.")
			if nil == pointIndex then
				break
			end
			local newname = string.sub(name, 1, pointIndex - 1) 
			child = child:getChildByName(newname) 
			if nil == child then
				print("child is not found:", newname)
			end
			if child == root then
				owner[newname] = child
			else
				child[newname] = child
			end
			name = string.sub(name, pointIndex + 1) 
		end 

		child = child:getChildByName(name)  
	else
		child = root:getChildByName(name)
		
	end
	 
	if nil == child and nil == config.empty then
		print("child:::", child, name)
		return
	end

	owner[saveName] = child 

	--开始绑定事件
	if nil ~= config.click then
		child:addClickEventListener(function(sender)
				owner[config.click](owner, sender)
			end)
	elseif nil ~= config.onTouch then
		child:addTouchEventListener(handler(owner, owner[config.onTouch]))
	elseif nil ~= config.onEvent then--进度条 Slider
		child:addEventListener(function(sender, eventType) 
			owner[config.onEvent](owner, sender, eventType)
		end)
	elseif nil ~= config.onSelect then--复选框
		child:addEventListener(function(sender, eventType)
			owner[config.onSelect](owner, sender, eventType)
		end)
	end
end

rawset(_G,"CSBUtil", CSBUtil)
--return CSBUtil