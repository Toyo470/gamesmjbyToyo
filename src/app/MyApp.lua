local MyApp = class("MyApp")
--3780
function MyApp:ctor()

   
    MyApp.super.ctor(self)
end

function MyApp:run()
    collectgarbage("collect")
    USER_INFO  = {}
    SCENENOW   = {}
    SCENE={}
    bm = {}
    TABLE={}
    WinSize=cc.Director:getInstance():getWinSize()

    cc.UserDefault:getInstance():setStringForKey("isInstall", "");
    
    --这里增加一个获取是debug还是release
    if device.platform=="android" then
        local val= cct.getDateForApp("getBuildTypeInfo",{_G.resetSreen},"Ljava/lang/String;");

        val=json.decode(val)

        HttpAddr2=val.url2;
        HttpAddr=val.url1;
        isShowErrorScene=val.showerror;


        print("val",val,HttpAddr2,HttpAddr,isShowErrorScene)
    end


    isTaoAndroid=true

    if device.platform=="windows" then
        cc.Director:getInstance():getOpenGLView():setFrameSize(640, 400)
        cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(960, 540, cc.ResolutionPolicy.SHOW_ALL)
        display_scene("app.scenes.MainScene");
    else
        
        local isNeedupdateApp=cct.getDateForApp("isNeedupdateApp",{},"I");
        if isNeedupdateApp ==1 then
            display_scene("app.androidUpdate");
        else
            display_scene("app.scenes.MainScene");
        end

    end




   


    
end


function display_scene(name,flag)
     print("display_scene",name)
    if not SCENE[name] or flag == 1 then
        local next = require(name).new()
        SCENENOW["scene"] = next
        SCENENOW["name"]  = name
    else
        SCENENOW["scene"] = SCENE[name]
        SCENENOW["name"]  = name
    end
    display.replaceScene(SCENENOW["scene"])
    
end



_G.resetSreen=function ( jsons )
    -- body
   

    local data=json.decode(jsons)


    local width= cc.UserDefault:getInstance():getStringForKey("pwidth", "");

    local height= cc.UserDefault:getInstance():getStringForKey("pheight", "");

    if width=="" or height=="" then
        width=data.screenWidth
        height=data.screenHeight
        cc.UserDefault:getInstance():setStringForKey("pwidth", tostring(width));
        cc.UserDefault:getInstance():setStringForKey("pheight", tostring(height));    
    end

        
    dump(data,"应用恢复")
  --  cc.Director:getInstance():getOpenGLView():setFrameSize(tonumber(width), tonumber(height))

  --  cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(960, 540, cc.ResolutionPolicy.SHOW_ALL)

    if data.needReInstall then
        cc.UserDefault:getInstance():setStringForKey("isInstall", "");
        display_scene("app.androidUpdate");
    end
end



return MyApp
