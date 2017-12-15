--
-- Author: Your Name
-- Date: 2017-02-08 14:49:53
--
-- ios 帮助

local getTokenUrl="https://api.weixin.qq.com/sns/oauth2/access_token";


local jyTokenurl='https://api.weixin.qq.com/sns/auth'


local WECHAT = "wechat";


local ios_help=class("ios_help")

if device.platform=="android" then
	local dowloading=require("downLoading");
end



function ios_help:ctor(callBack)
	if device.platform=="android" then
		local function func(data)
			local data=json.decode(data)
			dump(data,"授传")

			local loginScene = SCENENOW["scene"]:getChildByName("loginLayer")
			if loginScene ~= nil then
				--todo
				loginScene:removeFromParent()
			end



			if data.cmd=="sc" then--授传
				--todo
				self.callBack("正在登录");
				print(self.appid,self.appdes,"test")

				local args={
					appid=self.appid,
					secret=self.appdes,
					code=data.code,
					grant_type="authorization_code"
				}
				cct.httpReq2({
					url=getTokenUrl,
					data=args,
					type_="GET",
					oldapi=true,
					callBack=function(data_wx)
						dump(data_wx,"1")

						data_wx=json.decode(data_wx.netData)
						dump(data_wx,"2");


						if data_wx.errcode then
							self.callBack("GETtoken错误："..data_wx.errmsg)
							require("hall.LoginScene"):show();
							self:exitLogin()
							cct.getDateForApp("loginfail",{},"V");
							return;
						end

						cc.UserDefault:getInstance():setStringForKey("ios_refres_token",data_wx.refresh_token);
						cc.UserDefault:getInstance():setStringForKey("ios_token",data_wx.access_token);
						cc.UserDefault:getInstance():setStringForKey("ios_openid",data_wx.openid);
						cc.UserDefault:getInstance():setStringForKey("refer_token_time", os.time())
						self:xyToken();
					end,

				})
			elseif data.cmd=="play" then
				local url=data.url;
				local t=data.type
				local pathinfo  = io.pathinfo(url).filename
				local sd_card=cc.UserDefault:getInstance():getStringForKey("sdCard", "")
				local owloading=dowloading.new(url,function (evt)
					-- body
					if evt=="5"then --下载失败
						if t=="downvoice" then--是下载视屏
							cct.getDateForApp("playVieos", {"error","1"},"V")
						else
							cct.getDateForApp("playVe", {"error","1"},"V")
						end
					elseif evt=="4" then
						if t=="downvoice" then
							cct.getDateForApp("playVieos", {"success",pathinfo},"V")
						else
							cct.getDateForApp("playVe", {"success",pathinfo},"V")
						end
					end
				end,sd_card)


				owloading:startupdate();

			end

			print("function Run")
		end
		local jsons = cct.getDateForApp("wxLoginCall", {func},"Ljava/lang/String;")

		print("ios_help>>>>>>>",jsons)
		local jo=json.decode(jsons)

		self.appid=jo.appid;
		self.appdes=jo.secret

		
	end

	self.callBack=callBack;
end

function ios_help:ios_call(data)



	

end


function ios_help:ios_wx_login()
	local refre_time=cc.UserDefault:getInstance():getStringForKey("refer_token_time", "")
	--self.callBack("正在授传")

	self.callBack("正在登录");
    print(refre_time,"refre_time")
	if refre_time=="" then --还没有拉过授传
		--todo
		cct.getDateForApp("wecharLogin",{1},"V");
	else
		local curr=os.time()-tonumber(refre_time)--秒数差

		local timeDay                   = math.floor(curr/86400)
 		print("weixincha",curr,timeDay)
		if timeDay>=29 then --refresh的有效期是29天 需要重获获取refresh
			--todo
			
			cct.getDateForApp("wecharLogin",{1},"V");
		else--refresh有效  我验证下  token有没有效

			self:xyToken()
		end
	end

end

-- 刷新用户信息，暂时只在ios下使用
function ios_help:flushUserInfo()

	if isiOSVerify then 
		return
	end

	local token=cc.UserDefault:getInstance():getStringForKey("ios_token","");
	local openId=cc.UserDefault:getInstance():getStringForKey("ios_openid","");
	if string.len(token) <= 0 or string.len(openId) <= 0 then
		return
	end

	local args={
		access_token=token,
		openid=openId
	}
	cct.httpReq2({
		url=jyTokenurl,
		data=args,
		olds=true,
        oldapi=true,
        type_="GET",
		callBack=function(data_wx)
			if not data_wx then
				return
			end
			data_wx=json.decode(data_wx.netData)
			if not data_wx then
				return
			end
			if data_wx.errcode==0 then --有效果的
				--todo
				self:getUserInfo(true)
			elseif data_wx.errcode==40003 then
				
			else
				--没有效果了 我续期一下
				self:xq_toekn();
			end

		end
	})
end

function ios_help:xyToken(refsh)

	--self.callBack("正在验证Token是否过期")
	local token=cc.UserDefault:getInstance():getStringForKey("ios_token","");
	local openId=cc.UserDefault:getInstance():getStringForKey("ios_openid","");
	local args={
		access_token=token,
		openid=openId
	}
	cct.httpReq2({
		url=jyTokenurl,
		data=args,
        oldapi=true,
        type_="GET",
		callBack=function(data_wx)
			data_wx=json.decode(data_wx.netData)


			if data_wx.errcode==0 then --有效果的
				--todo
				self:getUserInfo(refsh)
			elseif data_wx.errcode==40003 then
				if refsh then
					return;
				end
				print(data_wx.errcode,data_wx.errmsg)
				cct.getDateForApp("loginfail",{},"V");
				self:exitLogin()
				require("hall.LoginScene"):show()
			else
				--没有效果了 我续期一下
				self:xq_toekn(refsh);
			end

		end,
	
	})
end

function ios_help:xq_toekn(refsh)

	local wx_apid = self.appid
	if device.platform == "ios" then
		wx_apid = cct.getDateForApp("getWXAppid", {}, "V");
    end

    if not wx_apid then
    	return
    end
	--token失去效果了  重新续期

	--self.callBack("正在续期Token")
	local args={
		appid=self.appid,
		grant_type="refresh_token",
		refresh_token=cc.UserDefault:getInstance():getStringForKey("ios_refres_token","")
	}
	cct.httpReq2({
		url="https://api.weixin.qq.com/sns/oauth2/refresh_token",
		data=args,
		olds=true,
        oldapi=true,
        type_="GET",
		callBack=function(data_wx)
			if not data_wx then
				return
			end
			data_wx=json.decode(data_wx.netData)
			if not data_wx then
				return
			end
			cc.UserDefault:getInstance():setStringForKey("ios_refres_token",data_wx.refresh_token);
			cc.UserDefault:getInstance():setStringForKey("ios_token",data_wx.access_token);
			cc.UserDefault:getInstance():setStringForKey("ios_openid",data_wx.openid);
			self:getUserInfo(refsh)
		end,
		type_="GET"
	})


end

function ios_help:getUserInfo(refsh)

	--self.callBack("获取用户信息")
	--self.callBack("正在登录")
	local args={
		access_token=cc.UserDefault:getInstance():getStringForKey("ios_token","");
		openid=cc.UserDefault:getInstance():getStringForKey("ios_openid","");
	}
	cct.httpReq2({
		url="https://api.weixin.qq.com/sns/userinfo",
		data=args,
		olds=true,
        oldapi=true,
        type_="GET",
		callBack=function(data_wx)
			if not data_wx then
				return
			end
			data_wx=json.decode(data_wx.netData)
			if not data_wx then
				return
			end
            dump(data_wx,"zengtaotest")

			local data_info={}
			data_info.code=1;--成功
			data_info.type=2;--微信登录
			local data3={}
			data3.unionid=data_wx.unionid;
			data3.nickname=data_wx.nickname;
			data3.headimgurl=data_wx.headimgurl;
			data3.sex=data_wx.sex;
			data3.channelGroupId=1;
			data_info.data=json.encode(data3)

			--保存一下账户的信息
			if device.platform ~= "ios" then
				local infoString=cct.serialize(data3)
				cc.UserDefault:getInstance():setStringForKey("WXINFO",infoString);
		    end

			if not refsh then
				self:getIsZC(data3)
			else
				--if not bm.notupload then --避免多次上传
					--直接走上传接口
					cct.httpReq2({
						url=HttpAddr2.."/front/player/updatePlayerInfo",
						data={
							playerId=USER_INFO["uid"],
							headPhoto=data_wx.headimgurl,
							nickName = data_wx.nickname
						},
						callBack=function ( ... )
							-- body
							bm.notupload =true;
						end



					})
				--end

			end
		end,
		type_="GET"
	})

end




--[[

判断是否已经注册
]]
function ios_help:getIsZC( data3 )
	-- body
	--self.callBack("正在判断是否已经注册")
	print("getIsZC")
	cct.httpReq2({
		oldapi=true,
		type_="POST",
		url=HttpAddr.."/playerUser/OAuthCheck",
		data={
			type=WECHAT,
			code=data3.unionid,

		},

		callBack=function ( datas )
			-- body


			dump(datas)
			datas=json.decode(datas.netData)
			if datas.returnCode=="1" then

				 --没有注册
				 self:accoutZC(data3);
			else
				datas=datas.data
				--已经注册
				local phone=datas.phone
				local password=datas.password
				
				local infoString=cct.serialize(datas)
				cc.UserDefault:getInstance():setStringForKey("loginData", infoString) 

				self:login(phone,password,datas)

			end


		end

	})
end

--注册

function ios_help:accoutZC( data )
	-- body

	--self.callBack("正在注册")
	cct.httpReq2({
		oldapi=true,
		type_="POST",
		url=HttpAddr.."/playerUser/quickRegister",
		data={
			photo=data.headimgurl,
			nickname=data.nickname,
			sex=data.sex,
			wechat=data.unionid
		},
		callBack=function ( datas )

			dump(datas,"正在注册")
			-- body
			datas=json.decode(datas.netData).data
			local phone=datas.phone
			local password=datas.password
			local infoString=cct.serialize(datas)
			cc.UserDefault:getInstance():setStringForKey("loginData", infoString) 
			self:login(phone,password,datas)

			
		end

	})
end


function ios_help:login( pohnoe,passeord,data )
	-- body

	self.callBack("正在登录")
	cct.httpReq2({
		oldapi=true,
		type_="POST",
		url=HttpAddr.."/userLogin",
		data={
			phone=pohnoe,
			password=passeord,
			photo=data.headimgurl,
			nickname=data.nickname,
			gender=data.sex,
			type="P",
			device="1",

			longitude="0",
			latitude="0"
		},
		callBack=function ( datas )
			-- body
			dump(datas,"正在登录帐号")


			local infoData=json.decode(datas.netData)
			if infoData.returnCode=="0" then
				infoData=infoData.data
				USER_INFO["uid"]=infoData.userId
				USER_INFO["gold"]=infoData.account
				USER_INFO["cardCount"]=infoData.cardCount
				USER_INFO["nick"]=infoData.nickName
				USER_INFO["headUrl"]=infoData.photoUrl
				USER_INFO["type"]="P"

				local userinfo=cct.serialize(USER_INFO)
				cc.UserDefault:getInstance():setStringForKey("USER_INFO", userinfo)

				self:PHPLogin(USER_INFO["uid"])

			else
				--self.callBack(infoData.error)
				--cct.getDateForApp("loginfail",{},"V");
				require("hall.GameTips"):showTips("提示", "", 3, infoData.error)


				SCENENOW["scene"]:performWithDelay(function ( ... )
					-- body
					self:exitLogin()
					--cct.getDateForApp("loginfail",{},"V");
					require("hall.LoginScene"):show()
				end, 1)

				
			end

		end

	})



end


--请求PHP登录验证
function ios_help:PHPLogin(uid,token,type)

	if device.platform ~= "windows" then
		buglySetUserId(uid);
	end

    local httpurl = require("hall.GameData"):getVerificationAddr()
    print("请求地址：",httpurl)
    print("当前登录的用户Id：",USER_INFO["uid"])
    cct.httpReq2({
    	oldapi=true,
		type_="POST",
		url = httpurl,
		date={
			userId = uid
		},
		callBack=function(data)

			local gameList = json.decode(data.netData)

			if gameList.returnCode=="1" then

				require("hall.GameTips"):showTips("提示", "", 3, gameList.error)
				

				SCENENOW["scene"]:performWithDelay(function ( ... )
					-- body
					self:exitLogin()
					--cct.getDateForApp("loginfail",{},"V");
					require("hall.LoginScene"):show()
				end, 1)
				return;
			end

				dump(gameList,"-----请求PHP登录验证返回-----")

				--假如返回数据为空
				if gameList["data"] == nil then
					-- if  SCENENOW["name"] == "hall.hallScene" then
					-- 	SCENENOW["scene"]:HttpLogin(gameList["data"],0)
					-- end
					-- return false
					require("hall.GameTips"):showTips("提示", "", 3, "数据异常，请联系客服处理")
					return false
				end
				-- {
				-- 	data={
				-- 		playerProfile={
				-- 			nickName="",
				-- 		},

				-- 	},
				-- 	returnCode="0"
				-- }

				--获取用户个人信息
				local data = nil
				if USER_INFO["type"] == "P" or USER_INFO["type"] == "p" then
					data = gameList["data"]["playerProfile"]
				elseif USER_INFO["type"] == "C" or USER_INFO["type"] == "c" then
					data = gameList["data"]["compereProfile"] or gameList["data"]["playerProfile"]
				end

				--假如返回数据为空
				if data == nil then
					require("hall.GameTips"):showTips("提示", "", 3, "用户数据异常，请联系客服处理")
					return
				end

				local tbData = {}
				tbData["level"] = data["level"]
				tbData["nickName"] = data["nickName"]
				tbData["photoUrl"] = data["photoUrl"]
				tbData["sex"] = data["sex"]
				tbData["money"] = data["coinAmount"]
				USER_INFO["user_info"] = json.encode(tbData)
				USER_INFO["phone"] = data["phone"]

				local data={}
		        data.uid=tostring(uid)
		        data.nickName=data["nickName"]
		        data.level=data["level"]
		        data.sex=data["sex"]

		        cct.getDateForApp("setInfo",{json.encode(data)},"V")

				--是否首充
				USER_INFO["isFirstCharged"] = gameList["data"]["isFirstCharged"]
				USER_INFO["hasRedMonthCard"] = gameList["data"]["hasRedMonthCard"]
				USER_INFO["hasBlueMonthCard"] = gameList["data"]["hasBlueMonthCard"]
				USER_INFO["isGameSignIn"] = gameList["data"]["isGameSignIn"]

				USER_INFO["blueMonthCardEndDate"] = gameList["data"]["blueMonthCardEndDate"]
				USER_INFO["blueMonthCardSignInAmount"] = gameList["data"]["blueMonthCardSignInAmount"]
				USER_INFO["monthCardSignInAmount"] = gameList["data"]["monthCardSignInAmount"]
				USER_INFO["redMonthCardSignInAmount"] = gameList["data"]["redMonthCardSignInAmount"]
				USER_INFO["redMonthCardPrice"] = gameList["data"]["redMonthCardPrice"]

				print("当前场景:" .. SCENENOW["name"])

	
				require("hall.loginGame"):HttpLogin(gameList["data"])

		end,
		type="POST"
	})
    
	return true

end

function ios_help:exitLogin()
	print("exitLogin")
	-- cc.UserDefault:getInstance():setStringForKey("ios_refres_token","");
	-- cc.UserDefault:getInstance():setStringForKey("ios_token","");
	-- cc.UserDefault:getInstance():setStringForKey("ios_openid","");
	-- cc.UserDefault:getInstance():setStringForKey("refer_token_time", "")

	-- cc.UserDefault:getInstance():setStringForKey("USER_INFO","");
	-- cc.UserDefault:getInstance():setStringForKey("loginData","");
	-- cc.UserDefault:getInstance():setStringForKey("WXINFO", "")

	bm.notupload =false;
	--bm.server:disconnect();
	
end



return ios_help;


