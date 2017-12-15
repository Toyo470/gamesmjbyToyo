local KWXController = class("KWXController")

function KWXController:control(controlType, value)
	if KWX_CHUPAI == 2 then
		--todo
		KWX_CHUPAI = 1
	end

	if bit.band(controlType, GANG_TYPE_AN) > 0 and bit.band(controlType, GANG_TYPE_BU) > 0 then
		--todo
		local count = 0

		for i,v in ipairs(KWX_GAMEINFO_TABLE[KWX_MY_USERINFO.seat_id .. ""].hand) do
			if v == value then
				--todo
				count = count + 1
			end
		end

		if count == 4 then
			--todo
			require("kawuxing.handle.KWXSendHandle"):requestHandle(GANG_TYPE_AN, value)
		else
			require("kawuxing.handle.KWXSendHandle"):requestHandle(GANG_TYPE_BU, value)
		end

		return
	end
	
	require("kawuxing.handle.KWXSendHandle"):requestHandle(controlType, value)
end

function KWXController:acceptManyou(isAccept)
	if isAccept then
		--todo
		require("kawuxing.handle.KWXSendHandle"):requestHandle(0x2000, 0)
	else
		require("kawuxing.handle.KWXSendHandle"):requestHandle(0, 0)
	end
end

function KWXController:playCard(value)
	dump(value, "out card value ")

	KWX_CHUPAI = 0

	self:hideControlPlane()

	require("kawuxing.handle.KWXSendHandle"):sendCard(value)
end

--请求解散房间
function KWXController:C2G_CMD_DISSOLVE_ROOM()
    require("kawuxing.handle.KWXSendHandle"):C2G_CMD_DISSOLVE_ROOM()
end

--回复请求解散房间
function KWXController:C2G_CMD_REPLY_DISSOLVE_ROOM(agree)
    require("kawuxing.handle.KWXSendHandle"):C2G_CMD_REPLY_DISSOLVE_ROOM(agree)
end

function KWXController:showTingCards(tingSeq)
	require("kawuxing.operator.GamePlaneOperator"):showTingCards(tingSeq)
end

function KWXController:hideTingHuPlane()
	require("kawuxing.operator.GamePlaneOperator"):hideTingHuPlane()
end

function KWXController:showTingHuPlane(tingHuCards)
	require("kawuxing.operator.GamePlaneOperator"):showTingHuPlane(tingHuCards)
end

function KWXController:replyLiangdaoRemaid(confirm)
	if confirm then
		--todo
		require("kawuxing.handle.KWXSendHandle"):CLIENT_REPLY_LIANGDAO_REMAID(KWX_ROOM.dianpao_card)
	else
		-- require("kawuxing.handle.KWXSendHandle"):CLIENT_REPLY_LIANGDAO_REMAID(0)
		KWX_CHUPAI = 1
	end
end

function KWXController:showLgSelectBox(lgCards)
	require("kawuxing.operator.GamePlaneOperator"):showLgSelectBox(lgCards)
end

function KWXController:showComponentSelectBox(outCardParam)
	require("kawuxing.operator.GamePlaneOperator"):showComponentSelectBox(outCardParam)
end

function KWXController:requestLiang(card, componentIndexs)
	require("kawuxing.handle.KWXSendHandle"):CLI_REQUEST_LIANG(card, componentIndexs)
end

function KWXController:requestLiangGang()
	require("kawuxing.handle.KWXSendHandle"):CLI_REQUEST_LIANG_GANG(KWX_LG_CARDS)
end

function KWXController:hideControlPlane()
	require("kawuxing.operator.GamePlaneOperator"):hideControlPlane()
end

function KWXController:revertOutCardPosition()
	require("kawuxing.operator.GamePlaneOperator"):revertOutCardPosition()
end

return KWXController