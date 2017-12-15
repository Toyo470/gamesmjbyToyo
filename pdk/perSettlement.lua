local PerSettlement = class("PerSettlement", function() 
	return display.newScene("PerSettlement")
end)



-- 组局简单结算界面 
function PerSettlement:ctor()
	self._scene = cc.CSLoader:createNode("pdk/csb/perSettlement.csb"):addTo(self)

	btn = self._scene:getChildByName("Button_1")
	btn:addTouchEventListener(function(sender,event)
        if event==2 then
			require("pdk.pdkServer"):CLI_READY_GAME()
			self._scene:removeSelf()
        end
    end)  
end



-- 添加新的数据条目
-- @param:_userName:玩家名称 
-- @param:_lastCardNum:剩余牌数
-- @param:_boomNum:炸弹数量 
-- @param:_pointValue:变化的钱
function PerSettlement:addRecord(_userName, _lastCardNum, _boomNum, _pointValue)
	-- local layer = self._scene:getChildByName("Layer")
	if self == nil then
		return
	end
	if self._scene == nil then
		return
	end
	local panel = self._scene:getChildByName("Panel_1")
	local item = panel:getChildByName("userDataTmpPanel")
	item:setVisible(false)
	local newItem = item:clone()
	newItem:setVisible(true)
	item:getParent():addChild(newItem)

	local childen = panel:getChildren()

	local posY = newItem:getPositionY() - newItem:getContentSize().height * (#childen - 4)
	newItem:setPositionY(posY)

	local name = newItem:getChildByName("txt_username")
	local lastCard = newItem:getChildByName("txt_overCardNum")
	local boomNum = newItem:getChildByName("txt_boomNum")
	local point = newItem:getChildByName("pointNum")

	name:setString(tostring(_userName))
	lastCard:setString(tostring(_lastCardNum))
	boomNum:setString(tostring(_boomNum))
	point:setString(tostring(_pointValue))
end



-- 关闭界面接口
function PerSettlement:onClose()
	self:removeSelf()
end

return PerSettlement
