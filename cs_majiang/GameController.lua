local CSMJController = class("CSMJController")

function CSMJController:control(controlType, value, _user_bonus)
	if CSMJ_CHUPAI == 2 then
		--todo
		CSMJ_CHUPAI = 1
	end

	if _user_bonus == nil then 
		_user_bonus = 0 
	end

	print("---------- SEND USER OPERATOR:", controlType, value, _user_bonus)

	require("cs_majiang.handle.CSMJSendHandle"):requestHandle(controlType, value, _user_bonus)
end

function CSMJController:acceptManyou(isAccept)
	if isAccept then
		--todo
		require("cs_majiang.handle.CSMJSendHandle"):requestHandle(0x2000, 0)
	else
		require("cs_majiang.handle.CSMJSendHandle"):requestHandle(0, 0)
	end
end

function CSMJController:playCard(value)
	dump(value, "out card value ")

	CSMJ_CHUPAI = 0

	require("cs_majiang.handle.CSMJSendHandle"):sendCard(value)
end

--请求解散房间
function CSMJController:C2G_CMD_DISSOLVE_ROOM()
    require("cs_majiang.handle.CSMJSendHandle"):C2G_CMD_DISSOLVE_ROOM()
end

--回复请求解散房间
function CSMJController:C2G_CMD_REPLY_DISSOLVE_ROOM(agree)
    require("cs_majiang.handle.CSMJSendHandle"):C2G_CMD_REPLY_DISSOLVE_ROOM(agree)
end

function CSMJController:clearGameDatas()
	require("cs_majiang.operator.GamePlaneOperator"):clearGameDatas()
end

return CSMJController