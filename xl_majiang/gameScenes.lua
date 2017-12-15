
--local MajianghallHandle  = require("majiang.scenes.MajianghallHandle")

--选择场的类型
--
--
--local PROTOCOL         = import("majiang.scenes.Majiang_Protocol")
local mjSetting = require("xl_majiang.setting_help")
majiangGameMode = 0
local datamanager = require("xl_majiang.datamanager")


local MajianghallScenes  = class("MajianghallScenes", function()
    return display.newScene("MajianghallScenes")
end)

function MajianghallScenes:ctor()
	local view            = cc.CSLoader:createNode("xl_majiang/scens/SelectMode.csb"):addTo(self)
	self._scene           = view

	--自由场
	local btn_free_mode  = self._scene:getChildByName("btn_mode_free")
	local btn_mode_game  = self._scene:getChildByName("btn_mode_game")
	local btn_mode_more  = self._scene:getChildByName("btn_mode_more")

	btn_free_mode:hide();
	--btn_mode_game:hide();
	cct.createHttRq({
            url=HttpAddr .. "/game/matchLoading",
            date={
            	userId=USER_INFO['uid'],
                gameId=4,
            },
            type_="GET",
            callBack= function ( date)
            	date.netData=json.decode(date.netData)
            	dump(date.netData, "ceshi2")
            	btn_free_mode:show();
            	if date.netData.returnCode == "0" then
	            	local lbCount = btn_free_mode:getChildByName("txt_count_0")
	            	if lbCount then
	            		lbCount:setString("在场人数 "..date.netData.data.freeCount)
	            		lbCount:setColor(cc.c3b(249,245,198))
	            	end
	            	--print(date.netData.data.playerCount,"0")
	            	lbCount = btn_mode_game:getChildByName("txt_count_0")
	            	if lbCount then
	            		lbCount:setString("在场人数  "..date.netData.data.matchCount)
	            		lbCount:setColor(cc.c3b(249,245,198))
	            	end
            	end
           	end
    })

	--退出
	local back_btn  = self._scene:getChildByName("btn_back")

	bm.buttontHandler(back_btn,function()
		--bm.display_scenes("hall.Hall")
		display_scene("hall.hallScene")
	end)

	 --head
    local head = self._scene:getChildByName("head")
    if head then
        require("hall.GameCommon"):getUserHead(USER_INFO["icon_url"],USER_INFO["uid"],USER_INFO["sex"],head,81,true)
    end

	--玩家名称
    local txt_nick = self._scene:getChildByName("txt_nick")
    txt_nick:enableShadow(cc.c4b(255,255,255,255),cc.size(1,0),0)
	txt_nick:setString(USER_INFO["nick"])

	--金币
	local btn_recharge = self._scene:getChildByName("btn_recharge")
	local txt_score = btn_recharge:getChildByName("txt_score")
 	-- txt_score:setString(require("net.HttpNet"):formatGold(USER_INFO["gold"]))
 	if txt_score then
 		txt_score:setString(tostring(USER_INFO["gold"]))
 	end

    local txt_level = self._scene:getChildByName("txt_level")
    txt_level:setString(USER_INFO["pLevel"])

	--帮助，设置
	local btn_help = self._scene:getChildByName("btn_help")
	local btn_setting = self._scene:getChildByName("btn_setting")

	local function touchButtonEvent(sender,event)
		-- body
		print("touchButtonEvent",event)
        if event == TOUCH_EVENT_BEGAN then
            require("hall.GameCommon"):playEffectSound("xl_majiang/music/Audio_Button_Click.mp3")
            sender:setScale(0.9)
        end
        if event == 3 then
            sender:setScale(1)
        end

		if event == TOUCH_EVENT_ENDED then --帮助
            sender:setScale(1)
			if sender == btn_help then

				mjSetting:show_help_layout(self._scene)
			elseif sender == btn_setting then
				mjSetting:show_setting_layout(self._scene)
				
			elseif sender == btn_recharge then
				require("hall.GameCommon"):gRecharge()
			end

			if sender == btn_free_mode then
    			require("hall.gameSettings"):setGameMode("free")
				majiangGameMode = 1
				datamanager:set_game_mode(1)

				display_scene("xl_majiang.MJselectChip",1)

				---http请求。。。。。。。。。。。。。
			elseif sender == btn_mode_game then
    			require("hall.gameSettings"):setGameMode("match")
				majiangGameMode = 2
				datamanager:set_game_mode(2)
				display_scene("xl_majiang.MJselectChip",1)
				
				---http请求。。。。。。。。。。。。。s
			elseif sender == btn_mode_more then
				majiangGameMode = 3 

			end
		end
	end
	
	btn_help:addTouchEventListener(touchButtonEvent)
	btn_setting:addTouchEventListener(touchButtonEvent)
	btn_recharge:addTouchEventListener(touchButtonEvent)

	btn_free_mode:addTouchEventListener(touchButtonEvent)
	btn_mode_game:addTouchEventListener(touchButtonEvent)
	btn_mode_more:addTouchEventListener(touchButtonEvent)

	--btn_mode_game:setVisible(false)
	btn_mode_more:setVisible(false)
	--btn_free_mode:setPositionX(480)
	--快速进入自由场
	require("xl_majiang.majiangServer"):LoginGame(USER_INFO["gameLevel"])
    require("hall.GameCommon"):landLoading(true,self)
end

function MajianghallScenes:goldUpdate()
	--金币
	local btn_recharge = self._scene:getChildByName("btn_recharge")
	local txt_score = btn_recharge:getChildByName("txt_score")
 	-- txt_score:setString(require("net.HttpNet"):formatGold(USER_INFO["gold"]))
 	if txt_score then
 		txt_score:setString(tostring(USER_INFO["gold"]))
 	end
end

function MajianghallScenes:onEnter()
	--显示版本号
    local version_str = require("hall.GameData"):getGameVersion("majiang")
    local lbVersion = cc.Label:createWithTTF("version:"..version_str, "fonts/fzcy.ttf", 18)
    self:addChild(lbVersion,888)
    lbVersion:setColor(cc.c3b(255,127,39))
    lbVersion:setPosition(cc.p(lbVersion:getContentSize().width/2,lbVersion:getContentSize().height/2))
end

function MajianghallScenes:onExit()
end


return MajianghallScenes
