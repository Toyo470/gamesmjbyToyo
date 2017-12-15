--
-- Author: Zeng Tao
-- Date: 2017-04-25 11:31:02
--
local notificationPhoneInfo=class("notificationPhoneInfo",function ( ... )
	-- body
	return cc.Layer:create()
end)
local scheduler = require("framework.scheduler")

function notificationPhoneInfo:ctor( ... )


	--
	
	cc.Director:getInstance():setNotificationNode(self);





	scheduler.scheduleGlobal(handler(self, self.setTime),1)

	scheduler.scheduleGlobal(handler(self, self.updateInfo),5)

	self:initUI()


	self:setTime();
end

function notificationPhoneInfo:setNetping(ping)
	-- body
	local text=self.rootNode:getChildByName("Text_1")
	text:setString(ping.."ms")
	if ping>1000 then
		text:setColor(cc.c3b(255,0,0));
	else
		text:setColor(cc.c3b(255,255,0));
	end
end


function notificationPhoneInfo:initUI( ... )
	-- body
	local scene=cc.CSLoader:createNode("hall/notifiLayer.csb")

	self:addChild(scene)
	self.rootNode=scene:getChildByName("Node_1");


	self.batter=self.rootNode:getChildByName("batter_2")

	self.wifi_sp=self.rootNode:getChildByName("Sprite_1")

	--self.rootNode:setOpacity(0.6);
	self.rootNode:setScale(0.6);

end



function notificationPhoneInfo:updateInfo()
	-- body




	local json_val=cct.getDateForApp("getPhoneInfo",{},"Ljava/lang/String;"); --注册
	local json_tb=json.decode(json_val)





	local batterval=math.floor(json_tb.batter*4/100)+1



	local wifival=json_tb.wifival


		print(json_val,"updateInfo",batterval,wifival)


	if wifival==0 then
		--todo
		wifival=1
	end

	if batterval>=5 then
		batterval=4
	end


	if json_tb.wifitype==2 and json_tb.wifival==0 then --是手机信号
		--todo
		wifival=4
	end


	self.batter:setTexture("hall/wifi"..batterval..".png");
	self.wifi_sp:setTexture("hall/batter"..wifival..".png");

end

function  notificationPhoneInfo:setTime()
	-- body
	local date=os.date("%H:%M:%S");
	local text=self.rootNode:getChildByName("Text_2")
	text:setString(date) 
end






return notificationPhoneInfo