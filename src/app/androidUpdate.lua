--
-- Author: Zeng Tao
-- Date: 2017-04-02 10:27:45
--
local HallUpdate = require("app.HallUpdate")
local androidUpdate=class("androidUpdate",function ( ... )
	-- body
	return display.newScene("androidUpdate")
end)

local dowloading=require("downLoading");
function androidUpdate:ctor( ... )
	-- body
    print("androidUpdate")
	cct.httpReq2({

        url=HttpAddr.."/version/queryVersion",
        data={
        	type=1,
        	applicationType=4
    	},
        oldapi=true,
    	callBack=function ( data )
    		-- body
			dump(data,"helllo");
            data=data.netData
            data=json.decode(data)

    		if data.returnCode=="0" then

    			require("app.HallUpdate"):showLoadingTips("有新的版本必须更新");
    			data=data.data
    			local serverVer=data.version;
    			local isManual=data.isManual;
				local fileName  = io.pathinfo(data.updateUrl).filename


				self.fileName=fileName


    			local appv=cct.getDataForApp("getVer",{},"Ljava/lang/String;")

    			appv=json.decode(appv)

    			local appver=appv.ver;
    			local sdCard=appv.sdcard

               

                cc.UserDefault:getInstance():setStringForKey("androidVer",appver)
                cc.UserDefault:getInstance():setStringForKey("sdCard", sdCard)

                local androidVer=cc.Label:createWithTTF("","res/fonts/fzcy.ttf",20):addTo(self)  --显示版本号
                androidVer:setName("androidVer")
                androidVer:setPosition(cc.p(820,45))
                local banbenhao=cc.UserDefault:getInstance():getStringForKey("androidVer","")
                androidVer:setString("版本号："..banbenhao)

                local function update( ... )
                    -- body
                    local owloading=dowloading.new(data.updateUrl,handler(self, self.updateState),sdCard)
                    owloading:startupdate();
                    HallUpdate:showLoadingTips("正在更新");
                end
                if tonumber(cct.split(appver,".")[1])<tonumber(cct.split(serverVer,".")[1]) or
                 tonumber(cct.split(appver,".")[2])<tonumber(cct.split(serverVer,".")[2]) or 
                 tonumber(cct.split(appver,".")[3])<tonumber(cct.split(serverVer,".")[3]) then
                    HallUpdate:showLoadingTips("准备更新");
                    cct.getDataForApp("chekneedUpdateApp",{fileName,update},"V") --走本地更新
                else
                    self:EnterHall()--不需要走更新
                end

    		else
    			self:EnterHall()
    		end
    	end
    })


end



local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
function androidUpdate:DelayRun( dey )
    -- body
     local handle
     handle = scheduler.scheduleGlobal(function (  )
        -- body
        dey=dey-1;
        HallUpdate:showLoadingTips("下载异常，"..dey.."秒后再次尝试更新")
        if dey<=0 then
            HallUpdate:showLoadingTips("正在更新")
            -- self.owloading:startupdate();
            scheduler.unscheduleGlobal(handle);
        end
    end, 1)

end


function androidUpdate:onEnter()

	HallUpdate:landLoading(true)
	HallUpdate:showLoadingTips("正在检查更新");
end


function androidUpdate:updateState( val )
	-- body
	if type(val)=="number" then
		require("app.HallUpdate"):setLoadingProgress(val);
	else
		if val =="1" then --没有新的版本
		elseif val=="2" then--网络错误更新失败
			self:DelayRun(4)
		elseif val=="3" then --位置的错误
			self:DelayRun(4)
		elseif val=="4" then --下载成功
				-- body
			cct.getDataForApp("installApp",{self.fileName},"V")
            
		end

	end


end



function androidUpdate:EnterHall( ... )
	-- body
	display_scene("app.scenes.MainScene");
end


return androidUpdate