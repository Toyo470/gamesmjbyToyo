local YKMJController = class("YKMJController")

function YKMJController:control(controlType, value)
	if YKMJ_CHUPAI == 2 then
		--todo
		YKMJ_CHUPAI = 1
	end
    
	require("yk_majiang.handle.YKMJSendHandle"):requestHandle(controlType, value)
end

function YKMJController:acceptManyou(isAccept)
	if isAccept then
		--todo
		require("yk_majiang.handle.YKMJSendHandle"):requestHandle(0x2000, 0)
	else
		require("yk_majiang.handle.YKMJSendHandle"):requestHandle(0, 0)
	end
end

--显示相同出牌
function YKMJController:showSameCard(value)
    require("yk_majiang.operator.GamePlaneOperator"):showSameCard(value)
end

--隐藏显示
function YKMJController:hideSameCard()
	require("yk_majiang.operator.GamePlaneOperator"):hideSameCard()
end


function YKMJController:playCard(value)

	YKMJ_CHUPAI = 0

	self:hideControlPlane()
	
	require("yk_majiang.handle.YKMJSendHandle"):sendCard(value)
end

--请求解散房间
function YKMJController:C2G_CMD_DISSOLVE_ROOM()
    require("yk_majiang.handle.YKMJSendHandle"):C2G_CMD_DISSOLVE_ROOM()
end

--回复请求解散房间
function YKMJController:C2G_CMD_REPLY_DISSOLVE_ROOM(agree)
    require("yk_majiang.handle.YKMJSendHandle"):C2G_CMD_REPLY_DISSOLVE_ROOM(agree)
end

function YKMJController:showTingCards(tingSeq)
	require("yk_majiang.operator.GamePlaneOperator"):showTingCards(tingSeq)
end

function YKMJController:hideTingHuPlane()
	require("yk_majiang.operator.GamePlaneOperator"):hideTingHuPlane()
end

function YKMJController:showTingHuPlane(playerType, tingHuCards)
	require("yk_majiang.operator.GamePlaneOperator"):showTingHuPlane(playerType, tingHuCards)
end

function YKMJController:replyLiangdaoRemaid(confirm)
	if confirm then
		--todo
		require("yk_majiang.handle.YKMJSendHandle"):CLIENT_REPLY_LIANGDAO_REMAID(YKMJ_ROOM.dianpao_card)
	else
		-- require("yk_majiang.handle.YKMJSendHandle"):CLIENT_REPLY_LIANGDAO_REMAID(0)
		YKMJ_CHUPAI = 1
	end
end

function YKMJController:showLgSelectBox(lgCards)
	require("yk_majiang.operator.GamePlaneOperator"):showLgSelectBox(lgCards)
end

function YKMJController:requestLiang(card)
	require("yk_majiang.handle.YKMJSendHandle"):CLI_REQUEST_LIANG(card)
end

function YKMJController:requestLiangGang()
	require("yk_majiang.handle.YKMJSendHandle"):CLI_REQUEST_LIANG_GANG(YKMJ_LG_CARDS)
end

function YKMJController:requestJiapiao(piao)
	require("yk_majiang.handle.YKMJSendHandle"):CLI_REQUEST_JIAPIAO(piao)
end

function YKMJController:clearGameDatas()
	require("yk_majiang.operator.GamePlaneOperator"):clearGameDatas()
end

function YKMJController:hideControlPlane()
	require("yk_majiang.operator.GamePlaneOperator"):hideControlPlane()
end

return YKMJController