local XYKWXController = class("XYKWXController")

function XYKWXController:control(controlType, value)
	if XYKWX_CHUPAI == 2 then
		--todo
		XYKWX_CHUPAI = 1
	end

	if bit.band(controlType, GANG_TYPE_AN) > 0 and bit.band(controlType, GANG_TYPE_BU) > 0 then
		--todo
		local count = 0

		for i,v in ipairs(XYKWX_GAMEINFO_TABLE[XYKWX_MY_USERINFO.seat_id .. ""].hand) do
			if v == value then
				--todo
				count = count + 1
			end
		end

		if count == 4 then
			--todo
			require("xykawuxing.handle.XGKWXSendHandle"):requestHandle(GANG_TYPE_AN, value)
		else
			require("xykawuxing.handle.XGKWXSendHandle"):requestHandle(GANG_TYPE_BU, value)
		end

		return
	end
	
	require("xykawuxing.handle.XYKWXSendHandle"):requestHandle(controlType, value)
end

function XYKWXController:acceptManyou(isAccept)
	if isAccept then
		--todo
		require("xykawuxing.handle.XYKWXSendHandle"):requestHandle(0x2000, 0)
	else
		require("xykawuxing.handle.XYKWXSendHandle"):requestHandle(0, 0)
	end
end

function XYKWXController:playCard(value)
	dump(value, "out card value ")

	XYKWX_CHUPAI = 0

	self:hideControlPlane()
	
	require("xykawuxing.handle.XYKWXSendHandle"):sendCard(value)
end

--请求解散房间
function XYKWXController:C2G_CMD_DISSOLVE_ROOM()
    require("xykawuxing.handle.XYKWXSendHandle"):C2G_CMD_DISSOLVE_ROOM()
end

--回复请求解散房间
function XYKWXController:C2G_CMD_REPLY_DISSOLVE_ROOM(agree)
    require("xykawuxing.handle.XYKWXSendHandle"):C2G_CMD_REPLY_DISSOLVE_ROOM(agree)
end

function XYKWXController:showTingCards(tingSeq)
	require("xykawuxing.operator.GamePlaneOperator"):showTingCards(tingSeq)
end

function XYKWXController:hideTingHuPlane()
	require("xykawuxing.operator.GamePlaneOperator"):hideTingHuPlane()
end

function XYKWXController:showTingHuPlane(playerType, tingHuCards)
	require("xykawuxing.operator.GamePlaneOperator"):showTingHuPlane(playerType, tingHuCards)
end

function XYKWXController:replyLiangdaoRemaid(confirm)
	if confirm then
		--todo
		require("xykawuxing.handle.XYKWXSendHandle"):CLIENT_REPLY_LIANGDAO_REMAID(XYKWX_ROOM.dianpao_card)
	else
		-- require("xykawuxing.handle.XYKWXSendHandle"):CLIENT_REPLY_LIANGDAO_REMAID(0)
		XYKWX_CHUPAI = 1
	end
end

function XYKWXController:showLgSelectBox(lgCards)
	require("xykawuxing.operator.GamePlaneOperator"):showLgSelectBox(lgCards)
end

function XYKWXController:requestLiang(card, componentIndexs)
	require("xykawuxing.handle.XYKWXSendHandle"):CLI_REQUEST_LIANG(card, componentIndexs)
end

function XYKWXController:requestLiangGang()
	require("xykawuxing.handle.XYKWXSendHandle"):CLI_REQUEST_LIANG_GANG(XYKWX_LG_CARDS)
end

function XYKWXController:requestJiapiao(piao)
	require("xykawuxing.handle.XYKWXSendHandle"):CLI_REQUEST_JIAPIAO(piao)
end

function XYKWXController:clearGameDatas()
	require("xykawuxing.operator.GamePlaneOperator"):clearGameDatas()
end

function XYKWXController:hideControlPlane()
	require("xykawuxing.operator.GamePlaneOperator"):hideControlPlane()
end

function XYKWXController:revertOutCardPosition()
	require("xykawuxing.operator.GamePlaneOperator"):revertOutCardPosition()
end

function XYKWXController:showComponentSelectBox(outCardParam)
	require("xykawuxing.operator.GamePlaneOperator"):showComponentSelectBox(outCardParam)
end

return XYKWXController