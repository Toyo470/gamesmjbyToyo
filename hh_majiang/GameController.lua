local ZZMJController = class("ZZMJController")

function ZZMJController:control(controlType, value)
	if ZZMJ_CHUPAI == 2 then
		--todo
		ZZMJ_CHUPAI = 1
	end

	require("zz_majiang.handle.ZZMJSendHandle"):requestHandle(controlType, value)
end

function ZZMJController:acceptManyou(isAccept)
	if isAccept then
		--todo
		require("zz_majiang.handle.ZZMJSendHandle"):requestHandle(0x2000, 0)
	else
		require("zz_majiang.handle.ZZMJSendHandle"):requestHandle(0, 0)
	end
end

function ZZMJController:playCard(value)
	dump(value, "out card value ")

	ZZMJ_CHUPAI = 0

	self:hideControlPlane()
	
	require("zz_majiang.handle.ZZMJSendHandle"):sendCard(value)
end

--请求解散房间
function ZZMJController:C2G_CMD_DISSOLVE_ROOM()
    require("zz_majiang.handle.ZZMJSendHandle"):C2G_CMD_DISSOLVE_ROOM()
end

--回复请求解散房间
function ZZMJController:C2G_CMD_REPLY_DISSOLVE_ROOM(agree)
    require("zz_majiang.handle.ZZMJSendHandle"):C2G_CMD_REPLY_DISSOLVE_ROOM(agree)
end

function ZZMJController:showTingCards(tingSeq)
	require("zz_majiang.operator.GamePlaneOperator"):showTingCards(tingSeq)
end

function ZZMJController:hideTingHuPlane()
	require("zz_majiang.operator.GamePlaneOperator"):hideTingHuPlane()
end

function ZZMJController:showTingHuPlane(playerType, tingHuCards)
	require("zz_majiang.operator.GamePlaneOperator"):showTingHuPlane(playerType, tingHuCards)
end

function ZZMJController:replyLiangdaoRemaid(confirm)
	if confirm then
		--todo
		require("zz_majiang.handle.ZZMJSendHandle"):CLIENT_REPLY_LIANGDAO_REMAID(ZZMJ_ROOM.dianpao_card)
	else
		-- require("zz_majiang.handle.ZZMJSendHandle"):CLIENT_REPLY_LIANGDAO_REMAID(0)
		ZZMJ_CHUPAI = 1
	end
end

function ZZMJController:showLgSelectBox(lgCards)
	require("zz_majiang.operator.GamePlaneOperator"):showLgSelectBox(lgCards)
end

function ZZMJController:requestLiang(card)
	require("zz_majiang.handle.ZZMJSendHandle"):CLI_REQUEST_LIANG(card)
end

function ZZMJController:requestLiangGang()
	require("zz_majiang.handle.ZZMJSendHandle"):CLI_REQUEST_LIANG_GANG(ZZMJ_LG_CARDS)
end

function ZZMJController:requestJiapiao(piao)
	require("zz_majiang.handle.ZZMJSendHandle"):CLI_REQUEST_JIAPIAO(piao)
end

function ZZMJController:clearGameDatas()
	require("zz_majiang.operator.GamePlaneOperator"):clearGameDatas()
end

function ZZMJController:hideControlPlane()
	require("zz_majiang.operator.GamePlaneOperator"):hideControlPlane()
end

return ZZMJController