local TDHMJController = class("TDHMJController")

--碰杠晾喜操作
function TDHMJController:control(controlType, value)
	if TDHMJ_CHUPAI == 2 then
		--todo
		TDHMJ_CHUPAI = 1
	end

	require("tdh.handle.TDHMJSendHandle"):requestHandle(controlType, value)
end

-- function TDHMJController:acceptManyou(isAccept)
-- 	if isAccept then
-- 		--todo
-- 		require("tdh.handle.TDHMJSendHandle"):requestHandle(0x2000, 0)
-- 	else
-- 		require("tdh.handle.TDHMJSendHandle"):requestHandle(0, 0)
-- 	end
-- end


--显示相同出牌
function TDHMJController:showSameCard(value)
    require("tdh.operator.GamePlaneOperator"):showSameCard(value)
end

--隐藏显示
function TDHMJController:hideSameCard()
	require("tdh.operator.GamePlaneOperator"):hideSameCard()
end

--出牌
function TDHMJController:playCard(value)
	TDHMJ_CHUPAI = 0

	require("tdh.handle.TDHMJSendHandle"):sendCard(value)
end

--请求解散房间
function TDHMJController:C2G_CMD_DISSOLVE_ROOM()
    require("tdh.handle.TDHMJSendHandle"):C2G_CMD_DISSOLVE_ROOM()
end

--回复请求解散房间
function TDHMJController:C2G_CMD_REPLY_DISSOLVE_ROOM(agree)
    require("tdh.handle.TDHMJSendHandle"):C2G_CMD_REPLY_DISSOLVE_ROOM(agree)
end

--清除游戏数据
function TDHMJController:clearGameDatas()
	require("tdh.operator.GamePlaneOperator"):clearGameDatas()
end

--请求加飘
function TDHMJController:requestJiapiao(piao)
	require("tdh.handle.TDHMJSendHandle"):CLI_REQUEST_JIAPIAO(piao)
end

--显示听牌暗化
function TDHMJController:showTingCards(tingSeq)
	require("tdh.operator.GamePlaneOperator"):showTingCards(tingSeq)
end

--显示听牌队列
function TDHMJController:showComponentSelectBox(outCardParam)
	require("tdh.operator.GamePlaneOperator"):showComponentSelectBox(outCardParam)
end

function TDHMJController:hideTingHuPlane()
	require("tdh.operator.GamePlaneOperator"):hideTingHuPlane()
end

function TDHMJController:showTingHuPlane(tingHuCards)
	dump(tingHuCards, "TDHMJController:showTingHuPlane")
	require("tdh.operator.GamePlaneOperator"):showTingHuPlane(tingHuCards)
end

return TDHMJController