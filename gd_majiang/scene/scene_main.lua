mrequire "mymodules"
MainScene = class("MainScene", function ()
	-- body
	return display.newScene("MainScene")
end)

function MainScene:ctor()
	self:enableNodeEvents()
	
	-- add HelloWorld label
    cc.Label:createWithSystemFont("Hello World", "Arial", 40)
        :move(display.cx, display.cy + 200)
        :addTo(self)
end

function MainScene:onEnter()
	print("-----------MainScene:onEnter()----------------")

	local function update(dt)
		if mymodules.manager ~= nil then
			mymodules.manager:update(dt)
		end
	end

	self:scheduleUpdateWithPriorityLua(update,0)

end

function MainScene:onExit()
	print("-----------MainScene:onExit()----------------")

	if mymodules.manager ~= nil then
		mymodules.manager:release()
	end

end