--
-- Author: Zeng Tao
-- Date: 2017-04-24 09:59:46
--


local tupdate={}

tupdate.__index=tupdate
local tassetsManagerEx=nil
local downLoading=require("downLoading");

function tupdate.checkUpdate( code,callBack )
	-- body

	local function startCheckUpdate( ... )
		-- body
		local isfirst=cc.UserDefault:getInstance():getBoolForKey(code.."_isFirst", true)
		if isfirst then
			local down=downLoading.new(downUpdateUrl.."/"..code..".zip",callBack,device.writablePath)
			down:startupdate()
		else
			local adown=tupdate.createUpdate( code,callBack )
			adown:chekupdate();
		end
	end 

	if not downUpdateUrl then
		 cct.createHttRq({

            url=HttpAddr.."/version/queryVersion",
            data={
                type=1
            },
            callBack=function ( data )
            	-- body
            	data = json.decode(data)
            	downUpdateUrl=data["updateUrl"]
            	startCheckUpdate();
            end
           })
    else
    	startCheckUpdate();
	end

end



function tupdate.createUpdate( code,callBack )
	-- body
	if tassetsManagerEx~=nil then
		callBack("更新异常code:0x0001")
		return 0;
	end

	tassetsManagerEx = cc.AssetsManagerEx:create(code.."/"..code..".manifest", cc.FileUtils:getInstance():getWritablePath())
    tassetsManagerEx:retain()
    if not tassetsManagerEx:getLocalManifest():isLoaded() then --本地local 没有准备好s
    	callBack("更新异常code:0x0002")
    	return 1;
    end
	local function onUpdateEvent( eventCode )
		-- body
		 local eventCode = event:getEventCode()
		 if eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_NO_LOCAL_MANIFEST then
		 	callBack("更新异常code:0x0003")
		 end


		if (cc.EventAssetsManagerEx.EventCode.NEW_VERSION_FOUND == event:getEventCode()) then
		    callBack("发现新版本，开始升级")

		 	

		end

		if cc.EventAssetsManagerEx.EventCode.UPDATE_PROGRESSION == event:getEventCode() then
	    
		    local assetId = event:getAssetId()
		    local percent = math.floor(event:getPercent())
		    local msg=event:getMessage()
		    local strInfo = ""

		    if assetId == cc.AssetsManagerExStatic.VERSION_ID then
		        strInfo = string.format("Version file: %d%%", percent)
		        updateScene:setProgress(percent)
		    elseif assetId == cc.AssetsManagerExStatic.MANIFEST_ID then
		        strInfo = string.format("Manifest file: %d%%", percent)
		  
		         updateScene:setProgress(percent)
		    else
		        strInfo = string.format("%d%%", percent)
		        -- updateScene:setProgress(percent)
		        
		    end
		    
		   	callBack("正在下载更新"..msg..strInfo)
		    print("更新进度="..percent,strInfo)

	 		
		end

		if eventCode==cc.EventAssetsManagerEx.EventCode.UPDATE_FINISHED then
			callBack("更新成功")
		end

		if eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_DOWNLOAD_MANIFEST then 
                    
            callBack("下载异常code:0x0004")
        end

        if  eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_PARSE_MANIFEST then
        	callBack("下载异常code:0x0007")
        end

        if eventCode == cc.EventAssetsManagerEx.EventCode.ALREADY_UP_TO_DATE  then
            callBack("已经最新版本");
        end

        if eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_UPDATING then
        	callBack("下载异常code:0x0005")
        end

	end 



    local listener = cc.EventListenerAssetsManagerEx:create(tassetsManagerEx,onUpdateEvent)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, SCENENOW["scene"])



    return tassetsManagerEx;
end




return tupdate;