local HNMJController = class("HNMJController")

function HNMJController:control(controlType, value)
	if HNMJ_CHUPAI == 2 then
		--todo
		HNMJ_CHUPAI = 1
	end

	require("hn_majiang.handle.HNMJSendHandle"):requestHandle(controlType, value)
end

function HNMJController:acceptManyou(isAccept)
	if isAccept then
		--todo
		require("hn_majiang.handle.HNMJSendHandle"):requestHandle(0x2000, 0)
	else
		require("hn_majiang.handle.HNMJSendHandle"):requestHandle(0, 0)
	end
end

function HNMJController:playCard(value)
	-- dump(value, "out card value ")
	HNMJ_CHUPAI = 0
	self:hideControlPlane()
	require("hn_majiang.handle.HNMJSendHandle"):sendCard(value)
end

--显示相同出牌
function HNMJController:showSameCard(value)
    require("hn_majiang.operator.GamePlaneOperator"):showSameCard(value)
end

--隐藏显示
function HNMJController:hideSameCard()
	require("hn_majiang.operator.GamePlaneOperator"):hideSameCard()
end


--请求解散房间
function HNMJController:C2G_CMD_DISSOLVE_ROOM()
    require("hn_majiang.handle.HNMJSendHandle"):C2G_CMD_DISSOLVE_ROOM()
end

--回复请求解散房间
function HNMJController:C2G_CMD_REPLY_DISSOLVE_ROOM(agree)
    require("hn_majiang.handle.HNMJSendHandle"):C2G_CMD_REPLY_DISSOLVE_ROOM(agree)
end

function HNMJController:showTingCards(tingSeq)
	require("hn_majiang.operator.GamePlaneOperator"):showTingCards(tingSeq)
end

function HNMJController:hideTingHuPlane()
	require("hn_majiang.operator.GamePlaneOperator"):hideTingHuPlane()
end

function HNMJController:showTingHuPlane(playerType, tingHuCards)
	require("hn_majiang.operator.GamePlaneOperator"):showTingHuPlane(playerType, tingHuCards)
end

function HNMJController:replyLiangdaoRemaid(confirm)
	if confirm then
		--todo
		require("hn_majiang.handle.HNMJSendHandle"):CLIENT_REPLY_LIANGDAO_REMAID(HNMJ_ROOM.dianpao_card)
	else
		-- require("hn_majiang.handle.HNMJSendHandle"):CLIENT_REPLY_LIANGDAO_REMAID(0)
		HNMJ_CHUPAI = 1
	end
end

function HNMJController:showLgSelectBox(lgCards)
	require("hn_majiang.operator.GamePlaneOperator"):showLgSelectBox(lgCards)
end

function HNMJController:requestLiang(card)
	require("hn_majiang.handle.HNMJSendHandle"):CLI_REQUEST_LIANG(card)
end

function HNMJController:requestLiangGang()
	require("hn_majiang.handle.HNMJSendHandle"):CLI_REQUEST_LIANG_GANG(HNMJ_LG_CARDS)
end

function HNMJController:requestJiapiao(piao)
	require("hn_majiang.handle.HNMJSendHandle"):CLI_REQUEST_JIAPIAO(piao)
end

function HNMJController:clearGameDatas()
	require("hn_majiang.operator.GamePlaneOperator"):clearGameDatas()
end

function HNMJController:hideControlPlane()
	require("hn_majiang.operator.GamePlaneOperator"):hideControlPlane()
end

return HNMJController