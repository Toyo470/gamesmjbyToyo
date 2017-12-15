local UserInfoPlaneOperator = class("UserInfoPlaneOperator")

local CHILD_NAME_PORTRAIT = "portrait"
local CHILD_NAME_NICK = "nick_lb"
local CHILD_NAME_COINS = "coins_lb"
local CHILD_NAME_ZHUANG_SIGNAL = "zhuang_signal"
local CHILD_NAME_OFFLINE_ICON = "offlineIcon"

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
	local coins = userInfo["coins"]

	local portrait = plane:getChildByName(CHILD_NAME_PORTRAIT)
	local nick_lb = plane:getChildByName(CHILD_NAME_NICK)
	local coins_lb = plane:getChildByName(CHILD_NAME_COINS)
	coins_lb:setScale(0.6)
	local infos = {}
	infos["icon_url"] = photoUrl
	infos["uid"] = userInfo["uid"]
	infos["sex"] = userInfo["sex"]
	require("hall.GameCommon"):setPlayerHead(infos, portrait, 46)

	nick_lb:setString(require("hall.GameCommon"):formatNick(nickname))

	-- require("hall.GameCommon"):formatLabelStr(nickname, nick_lb, nick_lb:getSize().width)
	coins_lb:setString(coins)
	-- 绑定玩家位置，语言
    local x = 0
    local y = 0
    x = plane:getPositionX()
    y = plane:getPositionY() - plane:getContentSize().height/2
    x = x + portrait:getPositionX() + portrait:getContentSize().width/2
    y = y + portrait:getPositionY()
    require("hall.view.voicePlayView.voicePlayView"):updateUserPosition(tonumber(userInfo["uid"]), cc.p(x, y))
end

-- 设置玩家离线/在线状态
function UserInfoPlaneOperator:setUserOnline(plane, _isOnline)
	local p = plane:getChildByName("player_plane")
	-- local portrait = p:getChildByName(CHILD_NAME_PORTRAIT)
	local offlineIcon = p:getChildByName(CHILD_NAME_OFFLINE_ICON)
	offlineIcon:setVisible(not _isOnline)

	local network = p:getChildByName("network")
	if not tolua.isnull(network) then
		network:removeSelf()
	end
	if not _isOnline then
		network = cc.Sprite:create("cs_majiang/image/duanxianchonglian_bt.png")
		p:addChild(network)
		network:setName("network")
		network:setPosition(cc.p(0,0))
		network:setScale(1.4)
	end
end


function UserInfoPlaneOperator:showZhuang(isShow, plane)
	local zhuang_signal = plane:getChildByName(CHILD_NAME_ZHUANG_SIGNAL)

	zhuang_signal:setVisible(isShow)
end

function UserInfoPlaneOperator:getHeadNode(plane)
	return plane:getChildByName(CHILD_NAME_PORTRAIT)
end

return UserInfoPlaneOperator
