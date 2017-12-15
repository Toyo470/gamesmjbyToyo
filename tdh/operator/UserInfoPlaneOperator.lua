local UserInfoPlaneOperator = class("UserInfoPlaneOperator")

local CHILD_NAME_PORTRAIT = "portrait"
local CHILD_NAME_NICK = "nick_lb"
local CHILD_NAME_COINS = "coins_lb"
local CHILD_NAME_ZHUANG_SIGNAL = "zhuang_signal"
local CHILD_NAME_NETWORK_IMG = "network_img"

function UserInfoPlaneOperator:init(plane)
	plane:setVisible(false)

	local zhuang_signal = plane:getChildByName(CHILD_NAME_ZHUANG_SIGNAL)

	zhuang_signal:setVisible(false)
end

function UserInfoPlaneOperator:clearGameDatas(plane)
	local zhuang_signal = plane:getChildByName(CHILD_NAME_ZHUANG_SIGNAL)

	zhuang_signal:setVisible(false)
end

function UserInfoPlaneOperator:showInfo(userInfo, plane)
	if not plane then
		--todo
		return
	end

	plane:setVisible(true)

	local photoUrl = userInfo["photoUrl"]
	local nickname = userInfo["nick"]
	local coins = userInfo["coins"] -2000

	local portrait = plane:getChildByName(CHILD_NAME_PORTRAIT)
	local nick_lb = plane:getChildByName(CHILD_NAME_NICK)
	local coins_lb = plane:getChildByName(CHILD_NAME_COINS)

	local infos = {}
	infos["icon_url"] = photoUrl
	infos["uid"] = userInfo["uid"]
	infos["sex"] = userInfo["sex"]
	-- require("hall.GameCommon"):setPlayerHead(infos, portrait, 46)

	portrait:removeAllChildren()
	portrait:setAnchorPoint(0.2,1)
	-- portrait:getSize() or
	local portraitSize =  {["width"]=60,["height"]=60}
	local infoParams = {}
   
    infoParams.invote_code = USER_INFO["invote_code"]
	infoParams.uid = userInfo["uid"]
	infoParams.nickName = nickname or ""
	infoParams.ip = TDHMJ_USERINFO_TABLE[TDHMJ_SEAT_TABLE[userInfo["uid"] .. ""] .. ""].ip or ""
	infoParams.Longitude = userInfo.longitude or "10.00"
	infoParams.Latitude = userInfo.latitude  or "10.00"
	infoParams.isShowInGame = true

	-- require("hall.view.headView.headView"):addView(portrait, portraitSize.width / 2, portraitSize.height / 2, portraitSize.width, portraitSize.height, photoUrl, infoParams)

	require("hall.GameCommon"):setPlayerHead(infos, portrait, 46)

	nick_lb:setString(require("hall.GameCommon"):formatNick(nickname))

	-- require("hall.GameCommon"):formatLabelStr(nickname, nick_lb, nick_lb:getSize().width)
	coins_lb:setString(coins)

	self:showNetworkImg(plane, false)
end

function UserInfoPlaneOperator:showZhuang(isShow, plane)
	local zhuang_signal = plane:getChildByName(CHILD_NAME_ZHUANG_SIGNAL)

	zhuang_signal:setVisible(isShow)
end

function UserInfoPlaneOperator:getHeadNode(plane)
	return plane:getChildByName(CHILD_NAME_PORTRAIT)
end

function UserInfoPlaneOperator:showNetworkImg(plane, flag)
	-- dump(flag,"networkflag")
	local img = plane:getChildByName(CHILD_NAME_NETWORK_IMG)

	if img then
		--todo
		img:setVisible(flag)
	end
end

return UserInfoPlaneOperator