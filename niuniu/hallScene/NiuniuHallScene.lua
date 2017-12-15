--
-- Author: ZT
-- Date: 2016-03-10 15:20:32
--//牛牛选分界面
require("niuniu.setting_help")
local NiuniuhallServer  = import("niuniu.hallScene.NiuniuhallServer") --后台服务
local niuniuHallScene=class("niuniuHallScene",function ()
	-- body
	return display.newScene("niuniuHallScene");
end)
local http_
function niuniuHallScene:ctor(http)
	-- body
	http_=http
	http_:setScene(self)
	self.rootNode=cc.CSLoader:createNode("niuniu/seletedModeRoom.csb")
	self.userInfonode=cc.CSLoader:createNode("niuniu/seleduser.csb")
	self:addChild(self.rootNode)
	self.rootNode:addChild(self.userInfonode)
	self:getUerInfoPanl()
	bm.niuniuscene = self

end

 
function niuniuHallScene:onEnter( ... )
	-- body
	printInfo("=============niuniuHallScene:onEnter==================================================")
	cct.createHttRq({
			url=HttpAddr .. "/game/freeMatch",
			date={
				gameId=5,
			},
			type_="GET",
			callBack=handler(self, self.HttpFreeLoadBattles)
		})
	self:setUerInfoPanl()

    local lbVersion = ccui.Text:create()
    lbVersion:setString("version:"..require("hall.GameData"):getGameVersion("niuniu"))
    lbVersion:setFontSize(18)

    self:addChild(lbVersion,888)
    lbVersion:setColor(cc.c3b(255,127,39))
    lbVersion:setPosition(cc.p(lbVersion:getContentSize().width/2,lbVersion:getContentSize().height/2))




	local NiuniuManager = require("niuniu.niuniumanager")
	if NiuniuManager:get_need_tip_flag() == true then
		local gametips = require("hall.GameTips")
		gametips:showTips("你已破产，不能进行游戏!去充值吧！")

		NiuniuManager:set_need_tip_flag(false)
	end
end

function niuniuHallScene:setDate()
	-- body
	niu_http:setUserDate()

end

--设置用户性息面板
function niuniuHallScene:getUerInfoPanl()
	-- body
	self.imgHead=self.userInfonode:seekNodeByName(self.userInfonode, "Image_4");
	self.txtUsername=self.userInfonode:seekNodeByName(self.userInfonode, "Text_1");
	--self.txtGold=self.userInfonode:seekNodeByName(self.userInfonode, "Text_47");
	-- self.btnAddMoeny=self.userInfonode:seekNodeByName(self.userInfonode, "Image_5");

	-- self.btnAddMoeny:setTouchEnabled(true)
	-- self.btnAddMoeny:onTouch(function (event)--点击了增加金币
	-- 	if event.name == "began" then
	-- 		event.target:setScale(1.05)
	-- 	end

	-- 	if event.name == "ended" then
	-- 		event.target:setScale(1.0)
	-- 		require("hall.GameCommon"):gRecharge()
	-- 	end
	-- end)

	--help
	self.btnHelp=self.userInfonode:seekNodeByName(self.userInfonode, "Button_25");
	self.btnHelp:onClick(function ()
		-- body
		show_help_layout(self.rootNode)
	end)

	self.btnSetter=self.userInfonode:seekNodeByName(self.userInfonode, "Button_27");
	self.btnSetter:onClick(function ()
		-- body
		show_setting_layout(self.rootNode)
	end)

	--
	self.btnExit=self.userInfonode:seekNodeByName(self.userInfonode, "Button_26");
	self.btnExit:onClick(function ()
		-- body
		display_scene("hall.hallScene")
	end)


end

--金币充值返回
function niuniuHallScene:goldUpdate()
	-- body
	local layer_num = self.rootNode:getChildByName("gold")
	if layer_num then
		layer_num:removeSelf()
	end

	local layer_num = require("hall.GameCommon"):showNums(USER_INFO["gold"],cc.c3b(125,125,125),true)
	self.rootNode:addChild(layer_num)
	layer_num:setAnchorPoint(cc.p(0.0,0.5))
	layer_num:setPositionX(190.59)
	layer_num:setPositionY(445.94)
	layer_num:setName("gold")
end

function niuniuHallScene:setUerInfoPanl()
	-- body
	require("hall.GameCommon"):getUserHead(USER_INFO["icon_url"],tonumber(UID),USER_INFO["sex"],self.imgHead,81,true,USER_INFO["nick"])
	self.txtUsername:setString(USER_INFO["nick"])
	--self.txtGold:setString( USER_INFO["gold"])

	local layer_num = require("hall.GameCommon"):showNums(USER_INFO["gold"],cc.c3b(125,125,125),true)
	self.rootNode:addChild(layer_num)
	layer_num:setAnchorPoint(cc.p(0.0,0.5))
	layer_num:setPositionX(190.59)
	layer_num:setPositionY(445.94)
	layer_num:setName("gold")


	local Panel_5 = self.userInfonode:getChildByName("Panel_5")
	Panel_5:setTouchEnabled(true)
	Panel_5:onTouch(function (event)--点击了增加金币
		if event.name == "began" then
			layer_num:setScale(1.05)
		end

		if event.name == "ended" then
			layer_num:setScale(1.0)
			require("hall.GameCommon"):gRecharge()
		end
	end)


	-- --模拟虚假数据
 --    if isVerify then
	-- 	local date={
	-- 	    		{{
	-- 		         name  = "海泉",
	-- 		         minScore = 300,
	-- 		         playNum = 200,
	-- 		         level = 21,
	-- 				 },
	-- 				}
	-- 			}

	-- self:setListRoom(date)
 --    end
end

--设置列表
function niuniuHallScene:setListRoom(listTable)
	printInfo("================setListRoom========================")
	dump(listTable)
	-- body
	local pagePanle=self.rootNode:seekNodeByName(self.rootNode, "PageView_1")
	-- pagePanle:setUsingCustomScrollThreshold(true)
	-- pagePanle:setCustomScrollThreshold(30)

	local len=0
	for k,v in pairs(listTable) do--页
		local onePage=ccui.Layout:create();
		onePage:setContentSize(cc.p(960,400))
		len=0
		for k1,v1 in pairs(v) do--每一页
			local _pppan=self.rootNode:seekNodeByName(self.rootNode, "Panel_1"):clone();
			onePage:addChild(_pppan)
			local x,y
			len=len+1;
			if len >6 then
				break;
			end

			if len<=3 then
				y=231
				x=142 + (len -1)*255
			else 
				y=44.5
				x=142 + (len-4)*255
			end
			_pppan:setPosition(x,y)

			--shezhiVal
			local playNum=_pppan:seekNodeByName(_pppan, "Text_1")
			--roomName:setString(v1.name or "自由场"..len)
			--playNum:setVisible(false)
			--local posx = playNum:getPositionX()
			--local posy = playNum:getPositionY()
			local num = v1.playNum or 600
			playNum:setString(v1.name or "自由场"..len)
			--playNum:setString(tostring(num).."人在玩")
		 --    local params =
			--     {
			--     text = v1.name or "自由场"..len,
			--     font = "res/fonts/wryh.ttf",
			--     size = 24,
			--     color = cc.c3b(255,243,223), 
			--     align = cc.TEXT_ALIGNMENT_LEFT,
			--     valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
			-- }
			-- local niu_txt = display.newTTFLabel(params)
			-- _pppan:addChild(niu_txt)
			-- niu_txt:setPositionX(posx)
			-- niu_txt:setPositionY(posy)


			local minScore=_pppan:seekNodeByName(_pppan, "Text_3")
			local minScoretxt = v1.minScore or 200
			print("===================minScoretxt====================",minScoretxt)

			--根据数字的大小做相应的缩放
			if minScoretxt <= 100 then
				minScore:setScale(0.95)
			elseif minScoretxt > 100 then
				minScore:setScale(0.71)
			elseif minScoretxt >10000 then
				minScore:setScale(0.56)
			end
			minScore:setString(tostring(minScoretxt))

			local playNum=_pppan:seekNodeByName(_pppan, "Text_4")
			playNum:setString(tostring(num).."人在玩")
			--playNum:setVisible(false)
			-- local posx = playNum:getPositionX()
			-- local posy = playNum:getPositionY()
			-- local num = v1.playNum or 600
			-- --playNum:setString(tostring(num).."人在玩")
		 --    local params =
			--     {
			--     text = tostring(num).."人在玩",
			--     font = "res/fonts/wryh.ttf",
			--     size = 14,
			--     color = cc.c3b(238,115,69), 
			--     align = cc.TEXT_ALIGNMENT_LEFT,
			--     valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
			-- }
			-- local niu_txt = display.newTTFLabel(params)
			-- niu_txt:enableShadow(cc.c4b(238,115,69,255), cc.size(1,0))
			-- _pppan:addChild(niu_txt)
			-- niu_txt:setPositionX(posx)
			-- niu_txt:setPositionY(posy)


			--local playNum=_pppan:seekNodeByName(_pppan, "Text_2")
			--playNum:setVisible(false)
			-- local posx = playNum:getPositionX()
			-- local posy = playNum:getPositionY()
		 --    local params =
			--     {
			--     text = "底分",
			--     font = "res/fonts/wryh.ttf",
			--     size = 16,
			--     color = cc.c3b(255,230,137), 
			--     align = cc.TEXT_ALIGNMENT_LEFT,
			--     valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
			-- }
			-- local niu_txt = display.newTTFLabel(params)
			-- niu_txt:enableShadow(cc.c4b(255,230,137,255), cc.size(1,0))
			-- _pppan:addChild(niu_txt)
			-- niu_txt:setPositionX(posx)
			-- niu_txt:setPositionY(posy)



			local btnClick=_pppan:seekNodeByName(_pppan, "Button_1")
			btnClick.level= v1.level
			btnClick.minScore = v1.minScore 
			btnClick:onTouch(handler(self, self.Onselect))
		end
		pagePanle:addPage(onePage)
	end    
end

--选择的
function niuniuHallScene:Onselect(event)
	-- body
	
	if event.name == "began" then
		event.target:getParent():setScale(1.2)
	end

	if event.name == "ended" then
		event.target:getParent():setScale(1)

		local minScore = event.target.minScore or 2000
		print("user gold-----------------",USER_INFO["gold"],type(USER_INFO["gold"]))
		if tonumber(USER_INFO["gold"]) > minScore * 3 then
			local level = event.target.level
			print("============================level..................",level)
			NiuniuhallServer:enterRoom(level)--发送113消息
		else
			require("hall.GameTips"):showTips("你的余额已不足，去商城充值吧","change_money",1)
		end
	end



end


--进入游戏界面
function niuniuHallScene:selectOk()
	-- body

	


end


function niuniuHallScene:HttpFreeLoadBattles( date )
	-- body
	printInfo("=============qingqiu===========HttpFreeLoadBattles=========================")
	local da=date.netData
	local strResponse = string.trim(da)
	local gameList  = json.decode(strResponse)
	if gameList.returnCode~="0" then
		--todo
		print("net error")
		return;
	end



------测试代码，或许有时候有用,不要删
				-- local test_data = {
				-- 	coins     = 2000,
				-- 	extract     = 20,
				-- 	gameId     = 5,
				-- 	id         = 19,
				-- 	level      = 21,
				-- 	name      = "world2Loc",
				-- 	playerCount = 0,
				-- 	status    = 1
				-- }
				-- table.insert(gameList.data,test_data)
				-- table.insert(gameList.data,test_data)
				-- table.insert(gameList.data,test_data)
				-- table.insert(gameList.data,test_data)
				-- table.insert(gameList.data,test_data)
				-- table.insert(gameList.data,test_data)
				-- table.insert(gameList.data,test_data)
				-- table.insert(gameList.data,test_data)

				-- print("gameList.data-----------len",#gameList.data)

	local tb={}
	local num=0
	local te={}
	table.sort(gameList.data,function(v1,v2)return v1.coins < v2.coins end)
	for k,v in pairs(gameList.data) do
		local tp={}
		tp.name=v.name -- 名字
		tp.playNum=v.playerCount --玩得人数
		tp.minScore=v.coins -- 低分
		tp.level = v.level

		num=num+1;
 		if num>6 then --last
			table.insert(tb,te)
			te={}
			num=0
		end--游戏的level
		table.insert(te,tp)
	end

	if num ~= 0 then --num == 0表示刚刚好上面6个6个的插入好
		table.insert(tb,te)
		te={}
		num=0
	end

	dump(tb)
	bm.niuniuscene:setListRoom(tb)

end

return niuniuHallScene