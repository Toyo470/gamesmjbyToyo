local SelectOpeLayer = class("SelectOpeLayer")



-- widgets name
local WIDGETNAMES = {
	txt_brief		= "Text_1",

	img_mahjong1	= "Image_10",
	img_mahjong2	= "Image_11",

	lyr_operate		= "Panel_1",
		img_pnlMahjong	= "Image_9",
		btn_operate1	= "Button_2",
		btn_operate2	= "Button_3",
		btn_operate3	= "Button_4",
		btn_operate4	= "Button_5",
		btn_operate5	= "Button_6",

	lyr_operate_clone	= "Panel_1_clone",

	btn_close		= "btnClose",
}



-- btn res name
local resPath = "cs_majiang/image/"


-- 顺序:吃 碰 杠 补 胡
local RESNAMES = {
	resPath .. "majong_chi_bt_d.png",	-- 吃
	resPath .. "majong_chi_bt_n.png", 

	resPath .. "majong_peng_bt_d.png",	-- 碰
	resPath .. "majong_peng_bt_n.png", 

	resPath .. "majong_gang_bt_d.png",	-- 杠
	resPath .. "majong_gang_bt_n.png", 

	resPath .. "majong_bu_bt_d.png",	-- 补
	resPath .. "majong_bu_bt_n.png",

	resPath .. "majong_hu_bt_d.png",	-- 胡
	resPath .. "majong_hu_bt_n.png", 

}

local function getMahjongRes(_value)
	return "cs_majiang/image/card/" .. _value .. ".png"
end


-- COMMON DATA
local OPE_CHI_TYPE_TB = {CHI_TYPE_RIGHT, CHI_TYPE_LEFT, CHI_TYPE_MIDDLE}


function SelectOpeLayer:pop(_uid, _cardValue1, _cardValue2, _opeCode1, _opeCode2, _hasBonus1, _hasBonus2)
	-- if _opeCode1 == 0 and _opeCode2 == 0 then return end -- 没操作就不用显示了

	self._scene = cc.CSLoader:createNode("cs_majiang/seleteOpeLayer.csb")
	self._scene:setName("seleteOpeLayer")
	SCENENOW["scene"]:addChild(self._scene)
	self:initWidgets()
	self:initCloseBtn()

	self:setTitleCard(_cardValue1, _cardValue2)
	self:setTitleBrief(tostring(uid) .. "打了两张牌")

	local layer1 = self._scene:getChildByName(WIDGETNAMES.lyr_operate)
	local layer2 = self._scene:getChildByName(WIDGETNAMES.lyr_operate_clone)
	self:setOperateLayer(layer1, _opeCode1, _cardValue1, _hasBonus1)
	self:setOperateLayer(layer2, _opeCode2, _cardValue2, _hasBonus2)
end



function SelectOpeLayer:setTitleCard(_value1, _value2)
	local mahjong1 = self._scene:getChildByName(WIDGETNAMES["img_mahjong1"])
	local mahjong2 = self._scene:getChildByName(WIDGETNAMES["img_mahjong2"])
	self:drawCard(mahjong1, _value1)
	self:drawCard(mahjong2, _value2)
end



function SelectOpeLayer:setTitleBrief(_str)
	local txtTitle = self._scene:getChildByName(WIDGETNAMES["txt_brief"])
	txtTitle:setString(_str)
end



function SelectOpeLayer:initWidgets()
	local function initOpePanel(_layerWidget)
		local btnBaseName = "btn_operate"
		for i = 1, 5, 1 do
			local btnName = btnBaseName .. i
			local resIndex = (i-1)*2 + 1
			local btnResName = RESNAMES[resIndex]
			local btn = _layerWidget:getChildByName(WIDGETNAMES[btnName])
			btn:loadTextures(btnResName, btnResName)
		end
	end

	local layer = self._scene:getChildByName(WIDGETNAMES["lyr_operate"])
	initOpePanel(layer)

	local y_offset = 63
	local layerClone = layer:clone()
	layerClone:setName(WIDGETNAMES["lyr_operate_clone"])
	self._scene:addChild(layerClone)
	layerClone:setPositionX(layer:getPositionX())
	layerClone:setPositionY(layer:getPositionY() - y_offset)
	initOpePanel(layerClone)

	-- init data
	self.curDisplayCard = 0
end



function SelectOpeLayer:setOperateLayer(_layer, _opeCode, _cardValue, _hasBonus)
	-- local tmpChi		= 0x0000
	local tmpChi		= CONTROL_TYPE_CHI
	local tmpBu			= 0x0000
	local tb_opeCode	= {tmpChi, CONTROL_TYPE_PENG, CONTROL_TYPE_GANG, tmpBu, CONTROL_TYPE_HU,}

	local btnNum		= 5
	local btnBaseName	= "btn_operate"
	for i = 1, btnNum, 1 do
		print("---------------------- SelectOpeLayer:setOperateLayer <<< i:", i, bit.band(_opeCode, tb_opeCode[i]))
		local btnName		= btnBaseName .. i
		local btn			= _layer:getChildByName(WIDGETNAMES[btnName])
		local btnResName	= nil

		local showBtnFlag = bit.band(_opeCode, tb_opeCode[i]) > 0

		if showBtnFlag then
			btnResName	= RESNAMES[i*2]
			self:setOpeBtnEvent(btn, _cardValue, bit.band(_opeCode, tb_opeCode[i]))
		else
			btnResName	= RESNAMES[(i-1)*2 + 1]
		end

		btn:loadTextures(btnResName, btnResName)

		-- 补张另外处理
		if i == 4 then
			if _hasBonus == 1 then
				btnResName	= RESNAMES[i*2]
				self:setOpeBtnEvent(btn, _cardValue, bit.band(_opeCode, tb_opeCode[i]))
			else
				btnResName	= RESNAMES[(i-1)*2 + 1]
			end
			btn:loadTextures(btnResName, btnResName)
		end
		
		-- 吃牌另外处理
		if i == 1 then
			local resultChiCode = bit.band(_opeCode, tmpChi)
			local chiOpeCode = 0
			for j = 1, #OPE_CHI_TYPE_TB, 1 do
				-- local resultOpeCode = bit.band(_opeCode, OPE_CHI_TYPE_TB[j])
				local resultOpeCode = bit.band(resultChiCode, OPE_CHI_TYPE_TB[j])
				if resultOpeCode > 0 then
					chiOpeCode = chiOpeCode + resultOpeCode
				end
			end

			print("@@@@@@@@@@@@@@@@@@@@@@@ -- chiOpeCode:", chiOpeCode, "_opeCode", chiOpeCode)

			if chiOpeCode ~= 0 then
				btnResName	= RESNAMES[i*2]
				self:setOpeChiBtnEvent(btn, _cardValue, chiOpeCode)
				btn:loadTextures(btnResName, btnResName)
			else
				btnResName	= RESNAMES[(i-1)*2 + 1]
				btn:loadTextures(btnResName, btnResName)
			end

		end
	end

	local cardBg = _layer:getChildByName(WIDGETNAMES["img_pnlMahjong"])
	self:drawCard(cardBg, _cardValue)
end



function SelectOpeLayer:setOpeBtnEvent(_btn, _cardValue, _opeCode)
	if _btn == nil or _opeCode == nil then return end
	local use_bonus = 0
	print(" ------ set --------- SelectOpeLayer:setOpeBtnEvent(:", _cardValue, _opeCode)
	local clickCallBack = function(_sender, _event)
		if _event == TOUCH_EVENT_ENDED then
			print(" --------------- SelectOpeLayer:setOpeBtnEvent(:", _cardValue, _opeCode)
			require("cs_majiang.handle.CSMJSendHandle"):requestHandle(_opeCode, _cardValue, use_bonus)
			self._scene:removeFromParent()
		end
	end

	_btn:addTouchEventListener(clickCallBack)
end



function SelectOpeLayer:setOpeChiBtnEvent(_btn, _cardValue, _opeCode)
	if _btn == nil or _opeCode == nil then return end

	if self.curDisplayCard ~= nil then
		if self.curDisplayCard == _cardValue then -- 仍然是当前的吃操作界面
			return 
		else -- 关闭当前吃操作UI
			local gamePlaneOperator	= require("cs_majiang.operator.GamePlaneOperator")
			local playerPlaneOperator = require("cs_majiang.operator.PlayerPlaneOperator")
			local playerPlane = gamePlaneOperator:getPlayerPlane(CARD_PLAYERTYPE_MY)
			playerPlaneOperator:hideControlPlane(playerPlane)
		end
	end

	self.curDisplayCard = _cardValue

	print("@@@@@@@@@@@@@ _opeCode:", _opeCode)

	-- 过滤掉非吃操作
	-- local opeType = 0
	-- for i = 1, #OPE_CHI_TYPE_TB, 1 do
	-- 	if bit.band(_opeCode, OPE_CHI_TYPE_TB[i]) then
	-- 		opeType = opeType + OPE_CHI_TYPE_TB[i] 
	-- 		print("------------- opeType;", opeType)
	-- 	end
	-- end

	-- 模拟包结构
	local pack = {}

	-- print("------ result opeType:", opeType)
	-- pack.handle	= opeType
	pack.handle	= _opeCode
	pack.card	= _cardValue

	-- 点击吃之后关闭当前的界面
	local clickChiCallBack = function()
		self._scene:removeFromParent()
	end

	-- 打开吃操作的选择界面
	local clickCallBack = function(_sender, _event)
		if _event ~= TOUCH_EVENT_ENDED then return end
		local cardUtils			= require("cs_majiang.utils.cardUtils")
		local gamePlaneOperator	= require("cs_majiang.operator.GamePlaneOperator")
		local controlTable		= cardUtils:getControlTable(pack, pack.card)
		gamePlaneOperator:showControlPlane(controlTable, clickChiCallBack)
	end

	_btn:addTouchEventListener(clickCallBack)
end



function SelectOpeLayer:drawCard(_cardBg, _value)
	local cardImgRes	= getMahjongRes(_value)
	local cardFaceImg	= ccui.ImageView:create()
    cardFaceImg:loadTexture(cardImgRes)
	_cardBg:addChild(cardFaceImg)

	local scaleFactor = _cardBg:getSize().width / cardFaceImg:getSize().width
	cardFaceImg:setScale(scaleFactor)

	local posX = cardFaceImg:getPositionX() + cardFaceImg:getSize().width/2 - 13
	local posY = cardFaceImg:getPositionY() + cardFaceImg:getSize().height/2 - 3
	cardFaceImg:setPosition(cc.p(posX, posY))
end



function SelectOpeLayer:initCloseBtn()
	local closeBtn = self._scene:getChildByName(WIDGETNAMES.btn_close)
	local clickCallBack = function(_sender, _event)
		if _event == TOUCH_EVENT_ENDED then 
			require("cs_majiang.handle.CSMJSendHandle"):requestHandle(0, 0, 0)
			self._scene:removeFromParent()
		end
	end
	closeBtn:addTouchEventListener(clickCallBack)
end



function SelectOpeLayer:onClose()
	if self._scene ~= nil then
		print("------------- SelectOpeLayer:onClose", type(self._scene))
		if self._scene:getParent() then
			self._scene:removeFromParent()
			self._scene = nil
		end
	end
end


return SelectOpeLayer
