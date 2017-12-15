local SingleSettle = class("SingleSettle", function() 
	return display.newScene("SingleSettle")
end)

-- widgets name --
-- "Image_2"
local rootPanel = "Panel_6"
-- "Image_18"
-- "Image_20"
-- "Image_22"
-- "Button_17"
-- "Image_21"
-- "Image_16"
-- "Image_17"
-- "Image_19"
-- "Text_11"
-- "Panel_20"
-- "Image_23"
-- "Image_24"
-- "Image_25"
-- "Image_26"
-- "Panel_21"
-- "Image_30"
-- "Image_28"
-- "Image_29"
-- "Text_20"
-- "BitmapFontLabel_8"
-- "BitmapFontLabel_9"
-- "BitmapFontLabel_10"
-- "Image_31"
-- "Image_32"

local img_title_win			= "Image_20"
local img_title_lose		= "Image_22"
local btn_startGame			= "Button_17"
local txt_roundInfo			= "Text_11"

local pnl_userInfoItem	= {"Panel_21", "Panel_21_0", "Panel_21_1"}

local img_head 		 	= "Image_28"
local txt_name 		 	= "Text_20"
local fnt_lastCard	 	= "BitmapFontLabel_8"
local fnt_boom		 	= "BitmapFontLabel_9"
local fnt_point_red	 	= "BitmapFontLabel_10"
local fnt_point_green	= "BitmapFontLabel_11"




-- 组局简单结算界面 
function SingleSettle:ctor()
	self:initWitgets()
	self:initBtnEvent()
	print("           --------    function SingleSettle:ctor()")
end



function SingleSettle:setShow()
	if SCENENOW["scene"]:getChildByName("singleSettlement") == nil then
		return
	end

	self.rootPanel = SCENENOW["scene"]:getChildByName("singleSettlement"):getChildByName(rootPanel)

	local btn_txt = self.rootPanel:getChildByName(btn_startGame):getChildByName("Image_21")
	if btn_txt then
		print("SingleSettle getGroupState", tostring(require("pdk.pdkSettings"):getGroupState()))
		if require("pdk.pdkSettings"):getGroupState() == 1 then--组局结束
			btn_txt:loadTexture("pdk/images/fin_text_paijujiesu.png")
		else
			btn_txt:loadTexture("pdk/images/text_kaishiyouxi.png")
		end
	end

	if self._scene then
		self._scene:setVisible(true)
	end
end

-- 重置单局结算按钮
function SingleSettle:resetButton()
	if SCENENOW["scene"]:getChildByName("singleSettlement") == nil then
		return
	end
	
	self.rootPanel = SCENENOW["scene"]:getChildByName("singleSettlement"):getChildByName(rootPanel)

	local btn_txt = self.rootPanel:getChildByName(btn_startGame):getChildByName("Image_21")
	if btn_txt then
		print("SingleSettle resetButton", tostring(require("pdk.pdkSettings"):getGroupState()))
		if require("pdk.pdkSettings"):getGroupState() == 1 then--组局结束
			btn_txt:loadTexture("pdk/images/fin_text_paijujiesu.png")
		else
			btn_txt:loadTexture("pdk/images/text_kaishiyouxi.png")
		end
	end
end


function SingleSettle:setWin(_isWin)
	if SCENENOW["scene"]:getChildByName("singleSettlement") == nil then
		print("SingleSettle:setWin(_isWin)  :getChildByName == nil")
		return
	end

	local title_win = SCENENOW["scene"]:getChildByName("singleSettlement"):getChildByName(rootPanel):getChildByName(img_title_win)
	local title_lose = SCENENOW["scene"]:getChildByName("singleSettlement"):getChildByName(rootPanel):getChildByName(img_title_lose)
	if _isWin then
		title_win:setVisible(true)
		title_lose:setVisible(false)
	else
		title_win:setVisible(false)
		title_lose:setVisible(true)
	end
end



function SingleSettle:initBtnEvent()
	if SCENENOW["scene"]:getChildByName("singleSettlement") == nil then
		return
	end

	self.rootPanel = SCENENOW["scene"]:getChildByName("singleSettlement"):getChildByName(rootPanel)

	local btn = self.rootPanel:getChildByName(btn_startGame)
	btn:addTouchEventListener(function(sender,event)
        if event==2 then
        	if self.callBack ~= nil then
				self.callBack()
			end

			-- self._scene:removeSelf()
			self:onClose()
        end
    end)  

	self.rootPanel:addTouchEventListener(function(sender,event)
        if event==2 then

        end
    end)  
end



function SingleSettle:setBtnCallBack(_callBack)	
	if SCENENOW["scene"]:getChildByName("singleSettlement") == nil then
		return
	end
	self.callBack = _callBack
	self.itemCounter = 0
end



-- @brief:设置右下角的局数信息
function SingleSettle:setRoundInfo(_strInfo)
	self._scene = SCENENOW["scene"]:getChildByName("singleSettlement")
	print("SingleSettle:setRoundInfo(_strInfo)")
	if self._scene == nil then
		return
	end
	print("SingleSettle:setRoundInfo(_strInfo)")

	self.rootPanel = SCENENOW["scene"]:getChildByName("singleSettlement"):getChildByName(rootPanel)
	
	local txtWidget = self.rootPanel:getChildByName(txt_roundInfo)
	txtWidget:setString(tostring(_strInfo))
	txtWidget:setVisible(false)
end



-- 添加新的数据条目
-- @param:_userName:玩家名称 
-- @param:_lastCardNum:剩余牌数
-- @param:_boomNum:炸弹数量 
-- @param:_pointValue:变化的钱
function SingleSettle:addRecord(_headImg, _userName, _lastCardNum, _boomNum, _pointValue,uid,sex)
	self._scene = SCENENOW["scene"]:getChildByName("singleSettlement")
	if self._scene == nil then
		return
	end

	self.rootPanel = SCENENOW["scene"]:getChildByName("singleSettlement"):getChildByName(rootPanel)
	
	if self.itemCounter == nil then
		self.itemCounter = 3
	end
	self.itemCounter = self.itemCounter + 1 -- 记录生成的item数量

	print("pnl_userInfoItem:", self.itemCounter, pnl_userInfoItem[self.itemCounter])
	if self.itemCounter > #pnl_userInfoItem then
		print("settle data error.", self.itemCounter)
		return 
	end

	local itemPanel = self._scene:getChildByName(pnl_userInfoItem[self.itemCounter])
	itemPanel:setVisible(true)
	if itemPanel:getChildByName("gold_28") then
		print("0000000000000000000000000000000")
	end

	local name  		= itemPanel:getChildByName(txt_name)
	local lastCard 		= itemPanel:getChildByName(fnt_lastCard)
	local boom 			= itemPanel:getChildByName(fnt_boom)

	local head = itemPanel:getChildByName("gold_28")
    if head ~= nil then
        local head_info = {}
        head_info["uid"] = uid
        head_info["icon_url"] = _headImg
        head_info["sp"] = head
        head_info["sex"] = sex
        head_info["size"] = 50
        head_info["touchable"] = 0
        head_info["use_sharp"] = 1
        dump(head_info,"addRecord")
        require("hall.GameCommon"):setPlayerHead(head_info,head,63)
    end

	name:setString(require("hall.GameCommon"):formatNick(_userName))
	lastCard:setString(_lastCardNum)
	boom:setString(_boomNum)

	local red_point = itemPanel:getChildByName(fnt_point_red)
	local green_point = itemPanel:getChildByName(fnt_point_green)
	if tonumber(_pointValue) >= 0 then
		red_point:setVisible(false)
		green_point:setVisible(true)
		red_point:setString("0")
		green_point:setString(_pointValue)
	else
		red_point:setVisible(true)
		green_point:setVisible(false)
		red_point:setString(_pointValue)
		green_point:setString("0")
	end

	-- local posY = itemPanel:getPositionY() 
	-- posY = posY - (itemPanel:getContentSize().height + 15)* self.itemCounter
	-- itemPanel:setPositionY(posY)

end


-- 关闭界面接口
function SingleSettle:onClose()
	self.itemCounter = nil
	
	self._scene = SCENENOW["scene"]:getChildByName("singleSettlement")
	if self._scene == nil then
		return
	end
	SCENENOW["scene"]:removeChildByName("singleSettlement")
	self = nil
end

return SingleSettle

