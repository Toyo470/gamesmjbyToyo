local SZKWXController = class("SZKWXController")

function SZKWXController:control(controlType, value)
	if SZKWX_CHUPAI == 2 then
		--todo
		SZKWX_CHUPAI = 1
	end

	if bit.band(controlType, GANG_TYPE_AN) > 0 and bit.band(controlType, GANG_TYPE_BU) > 0 then
		--todo
		local count = 0

		for i,v in ipairs(SZKWX_GAMEINFO_TABLE[SZKWX_MY_USERINFO.seat_id .. ""].hand) do
			if v == value then
				--todo
				count = count + 1
			end
		end

		if count == 4 then
			--todo
			require("szkawuxing.handle.XGKWXSendHandle"):requestHandle(GANG_TYPE_AN, value)
		else
			require("szkawuxing.handle.XGKWXSendHandle"):requestHandle(GANG_TYPE_BU, value)
		end

		return
	end
	
	require("szkawuxing.handle.SZKWXSendHandle"):requestHandle(controlType, value)
end

function SZKWXController:acceptManyou(isAccept)
	if isAccept then
		--todo
		require("szkawuxing.handle.SZKWXSendHandle"):requestHandle(0x2000, 0)
	else
		require("szkawuxing.handle.SZKWXSendHandle"):requestHandle(0, 0)
	end
end

function SZKWXController:playCard(value)
	dump(value, "out card value ")

	SZKWX_CHUPAI = 0

	self:hideControlPlane()
	require("szkawuxing.handle.SZKWXSendHandle"):sendCard(value)
end

--请求解散房间
function SZKWXController:C2G_CMD_DISSOLVE_ROOM()
    require("szkawuxing.handle.SZKWXSendHandle"):C2G_CMD_DISSOLVE_ROOM()
end

--回复请求解散房间
function SZKWXController:C2G_CMD_REPLY_DISSOLVE_ROOM(agree)
    require("szkawuxing.handle.SZKWXSendHandle"):C2G_CMD_REPLY_DISSOLVE_ROOM(agree)
end

function SZKWXController:showTingCards(tingSeq)
	require("szkawuxing.operator.GamePlaneOperator"):showTingCards(tingSeq)
end

function SZKWXController:hideTingHuPlane()
	require("szkawuxing.operator.GamePlaneOperator"):hideTingHuPlane()
end

function SZKWXController:showTingHuPlane(playerType, tingHuCards)
	require("szkawuxing.operator.GamePlaneOperator"):showTingHuPlane(playerType, tingHuCards)
end

function SZKWXController:replyLiangdaoRemaid(confirm)
	if confirm then
		--todo
		require("szkawuxing.handle.SZKWXSendHandle"):CLIENT_REPLY_LIANGDAO_REMAID(SZKWX_ROOM.dianpao_card)
	else
		-- require("szkawuxing.handle.SZKWXSendHandle"):CLIENT_REPLY_LIANGDAO_REMAID(0)
		SZKWX_CHUPAI = 1
	end

end

function SZKWXController:showLgSelectBox(lgCards)
	require("szkawuxing.operator.GamePlaneOperator"):showLgSelectBox(lgCards)
end

function SZKWXController:requestLiang(card, componentIndexs)
	require("szkawuxing.handle.SZKWXSendHandle"):CLI_REQUEST_LIANG(card, componentIndexs)
end

function SZKWXController:requestLiangGang()
	require("szkawuxing.handle.SZKWXSendHandle"):CLI_REQUEST_LIANG_GANG(SZKWX_LG_CARDS)
end

function SZKWXController:requestJiapiao(piao)
	require("szkawuxing.handle.SZKWXSendHandle"):CLI_REQUEST_JIAPIAO(piao)
end

function SZKWXController:clearGameDatas()
	require("szkawuxing.operator.GamePlaneOperator"):clearGameDatas()
end

function SZKWXController:hideControlPlane()
	require("szkawuxing.operator.GamePlaneOperator"):hideControlPlane()
end

function SZKWXController:revertOutCardPosition()
	require("szkawuxing.operator.GamePlaneOperator"):revertOutCardPosition()
end

function SZKWXController:showComponentSelectBox(outCardParam)
	require("szkawuxing.operator.GamePlaneOperator"):showComponentSelectBox(outCardParam)
end

return SZKWXController