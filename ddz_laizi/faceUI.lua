--
-- Author: tao
-- Date: 2016-08-01 16:38:28
-- 表情


local faceUI=class("faceUI",function()
	return display.newScene("faceUI")
end)

local ddzSettings=import(".ddzSettings")

--动画数据
faceUI.animatePlist={
    plist="ddz/faceAnimate.plist",
    faceSpeed=8/32,
    frameName="ddz/faceUI/face_",
    animateList={
        [1]=4,
        [2]=3,
        [3]={1,2,3,3,4,4},
        [4]=2,
        [5]={ 1,3,1,3,1,2,1,2,1},
        [6]={1,2,3,2,1,2,3,2,4},
        [7]=2,
        [8]={1,2,1,1,2,3},
        [9]={1,2,1,2,1},
        [10]=2,
        [11]={1,2,3,2,3,2},
        [12]={1,2,1,2,3,4},
        [13]=7,
        [14]={1,2,1,2,1,2,3,4,3},
        [15]={1,2,1,3},
 
        
    },
    imageUse="ddz/faceUI/expression_box.png"
}

faceUI.faceData={
    faceSize={width=75,height=75},
    hNum=5,--一行多少个表情
    hTxtNum=5,--一行txt有多少
 
    faceNum=15,
    --scaleNum=0.5,
}

faceUI.txt={
    "大家好很高兴见到各位",
    "和你合作真太愉快了",
    "快点啊，等的花儿都泻了",
    "你的牌打的也太好了",
    "不要吵了不要吵了，专心玩游戏吧",
}

local isTest=false

function faceUI:ctor()
    
    local faceNum=self.faceData.faceNum
    local hNum=   self.faceData.hNum;
    local faceSize=self.faceData.faceSize
    local scaleNum=self.faceData.scaleNum
    local txt=self.txt

    --父容器
    self.rootNode=cc.CSLoader:createNode("ddz/csb/faceUI.csb")
  

	local rootNode=self.rootNode;
	self:addChild(rootNode);
	--self.rootNode:hide()
    
    
    --
    display.addSpriteFrames(self.animatePlist.plist,string.split(self.animatePlist.plist, ".")[1]..".png")
	--[[
	   滚动-----------------------------------------------------------------------
	]]--
    local face_panle=self:createPanle(faceNum,hNum,faceSize)
    --=self.rootNode:getChildByName("Image_1")  
    local face_node=face_panle:getInnerContainer()


	---------------------------------------------------------------------------
    self:setBagNode({
        tnum=faceNum,
        hNum=hNum,
        size=faceSize,
        par=face_node,
        scaleNum=scaleNum,
        click_call_bak=handler(self, self.onClickFace),
        idaddNum=50,--id的增加量
    })
    --play animate
    local index=0
    for k,v1 in pairs(face_node:getChildren()) do
     
        index=index+1
        local animateList=self.animatePlist.animateList
        local v=animateList[index]
        local frameName=self.animatePlist.frameName..index.."_"
        local frames={}
        local animateSpeed=self.animatePlist.animateSpeed
        if type(v)=="table" then --自定义整虚列
            for key, var in pairs(v) do
                local name=frameName..var..".png"
                local spriteFrame=cc.SpriteFrameCache:getInstance():getSpriteFrame(name)
                frames[#frames+1]=spriteFrame
            end
        else
            frames = display.newFrames(frameName.."%d.png", 1, v);
        end
        local animation = display.newAnimation(frames, animateSpeed)
        transition.playAnimationForever(v1.sp,animation)
    end
    
	self.show_face_node=cc.Node:create();
	local show_face_node=self.show_face_node
	self:addChild(show_face_node,2)

    --local txt_panle=self:createPanle(faceNum,hNum,faceSize)
    self.txt_panle=self.rootNode:getChildByName("Image_5") 
    local txt_panle=self.rootNode:getChildByName("ListView_1"):clone();
    self.txt_panle:addChild(txt_panle)
    txt_panle:setPosition(30,30)
    local itemClone=self.rootNode:getChildByName("Panel_1");
    txt_panle:setContentSize(itemClone:getContentSize().width,
                             itemClone:getContentSize().height*5)
    self.txt_panle:setContentSize(itemClone:getContentSize().width+50,
                             itemClone:getContentSize().height*5+50)
                             

    txt_panle:onEvent(handler(self,self.ClickIntemTxt))

    for key, var in pairs(txt) do
        local item=itemClone:clone();
        local itemTxt=item:getChildByName("Text_1");
        itemTxt:setString(var);
        txt_panle:pushBackCustomItem(item);
        item.id=key
    end
    

    self.noScale=true
    self:onClick(function()
        self:hidePanle()
    end)
    
    
    self:hidePanle()
end

function faceUI:ClickIntemTxt(event)
    if event.name=="ON_SELECTED_ITEM_END" then
        local list_v=event.target
        local _idex_=list_v:getCurSelectedIndex();
        local id=list_v:getItem(_idex_).id
        
        print("send click msg title",id)
        require("ddz_laizi.ddzServer"):CLI_MSG_FACE(id)
        self.txt_panle:hide();
	end
end

function faceUI:createPanle(t,h,fa)
    local face_panle=ccui.ScrollView:create()
    face_panle:setClippingEnabled(true)
    face_panle:setScrollBarEnabled(true)
    face_panle:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL) 
    local faceNum=t;
    local hNum=h
    local faceSize=fa
    local h_height=faceNum/hNum
    if faceNum%hNum~=0 then
        h_height=h_height+1
    end
  
    face_panle:setInnerContainerSize(cc.size( (faceSize.width+8)*hNum,(faceSize.height+8)*h_height))
    face_panle:setContentSize(cc.size((faceSize.width+8)*hNum,(faceSize.height+9)*3))
    local par=self.rootNode:getChildByName("Image_1")
    self.face_panle=par
    par:setContentSize(cc.size((faceSize.width+8)*hNum+50,(faceSize.height+9)*3+50))
    par:addChild(face_panle)
    face_panle:setName("face_panle")
    face_panle:setPosition(30,40)
    face_panle:setContentSize(cc.size((faceSize.width+8)*hNum,(faceSize.height+9)*3));
    return face_panle
end



	
--广播显示动画
function faceUI:showGetFace(uid,faceid)


    print("getMessageshowGetFace",faceid)
    local faceNum=self.faceData.faceNum
    local txt=self.txt 
    if faceid>=65537 then --机器人发过来
        --todo
        local val =faceid-65537
        local val2=0

        if val>7 then --表情

            if val<faceNum then
                val2=50+val

            else
            val2=50+val%faceNum+1

        end
        else --文本
            if val<#txt then
                val2=val

            else
                val2=val%#txt+1

            end
        end
        self:showGetFace(uid,val2)
        print(val2,"showGetFace")
        return;
    end


	local uid_seat=SCENENOW["scene"]:getUSERID2SEAT()

	local seat=uid_seat[uid]
    local name,index=ddzSettings:getDOS(seat)

    local node_head=SCENENOW["scene"]._scene:getChildByName(name)
    local pos=node_head:getPosition()
    
    local sp,node;
    --self.show_face_node:stopAllActions()
    if node_head and node_head.sp_face  then

        node_head.sp_face:removeSelf();
        node_head.sp_face=nil
    end

   
   if faceid>=50 then --玩家发过来的表情
		--todo
        pos.x=pos.x+30
        pos.y=pos.y-30
		sp=cc.Sprite:create();

		
        local animateList=self.animatePlist.animateList
        local v=animateList[faceid-50]
		
        local frameName=self.animatePlist.frameName..(faceid-50).."_"
        local frames={}
        local animateSpeed=self.animatePlist.animateSpeed
        --local m="{"decodeType":"0","liveAddress":"rtmp://rtmp.doudougame.com.cn/live/mp4_ddz_513","returnCode":"0"}"

        if type(v)=="table" then --自定义整虚列
            for key, var in pairs(v) do
                local name=frameName..var..".png"
                local spriteFrame=cc.SpriteFrameCache:getInstance():getSpriteFrame(name)
                frames[#frames+1]=spriteFrame
            end
        else
            frames = display.newFrames(frameName.."%d.png", 1, v);
        end
		
		local animation = display.newAnimation(frames, animateSpeed)
		transition.playAnimationForever(sp,animation)
		
	
	else --玩家发货来的语音
        
        pos.x=pos.x+30
        pos.y=pos.y-50
        if index~=1 then
            sp=self.rootNode:getChildByName("Panel_2_0"):clone()
        else
            sp=self.rootNode:getChildByName("Panel_2"):clone()
        end
        sp:setPosition(0,0)
        local txtss=sp:getChildByName("Text_2")
        txtss:setString(self.txt[faceid]);
        local img=sp:getChildByName("Image_4")
        
        img:setContentSize(txtss:getContentSize().width+100,img:getContentSize().height)
        --print("test txt len",,txtss:getFontSize(),txtss:getStringLength());
        
	end
    

    node=cc.Node:create();
    node_head.sp_face=node;
    
    

    
    self.show_face_node:addChild(node)
    node:setPosition(pos)
    node:addChild(sp);

    local ac=cc.Sequence:create(
		cc.DelayTime:create(2),
		cc.CallFunc:create(function(args,arg2)
             
				args:removeSelf();
                arg2[1].sp_face=nil
        end,{node_head})
		)
		
    node:runAction(ac)

end


function faceUI:showTxtPanle(pos)
    pos.x=pos.x-300
	self.face_panle:hide();
	self.txt_panle:show();
	self.txt_panle:setPosition(pos);
end
--
function faceUI:showFacePanle(pos)
    pos.x=pos.x-100
    self.txt_panle:hide()
    self.face_panle:show();
    self.face_panle:getChildByName("face_panle"):jumpToTop()
    self.face_panle:setPosition(pos);

end
	


--send message
function faceUI:onClickFace(sender)

   
	local id =sender.id;
    print("send facaui onClickFace",id)
	require("ddz_laizi.ddzServer"):CLI_MSG_FACE(id)
	self.face_panle:hide();
end

function faceUI:hidePanle()
    self.face_panle:hide();
    self.txt_panle:hide()

end


function faceUI:setBagNode(data)
    local temp=0
    local x=0
    local y=0

    local faceNum=data.tnum
    local hNum=data.hNum
    local faceSize=data.size
    local face_node=data.par
    local id_addNum=data.idaddNum or 0
    local click_call_bak=data.click_call_bak
    local scaleNum=data.scaleNum or 1

    
    local size=face_node:getContentSize();
    
    faceSize.width=faceSize.width*scaleNum
    faceSize.height=faceSize.height*scaleNum
    y=size.height-faceSize.height/2+faceSize.height
    print(y,"nimab2",faceNum)
    for var=0, faceNum-1 do
        local x=(var%hNum)*(faceSize.width+8)+faceSize.width/2;
        if x==faceSize.width/2 then
            y=y-(faceSize.height+8)
            temp=0
        end
        temp=temp+1
        local image=ccui.ImageView:create(self.animatePlist.imageUse);
        --image:setAnchorPoint(cc.p(0,0))
        --image:setOpacity(0);--透明度

        local sp=cc.Sprite:create()
        image:addChild(sp)
        image.sp=sp
        image.id=var+1+id_addNum
        sp:setPosition(faceSize.width/2,faceSize.height/2)
        --sp:setOpacity(0)
        image:setPosition(x,y)
        face_node:addChild(image)
        image:setScale(scaleNum)
        if click_call_bak then
            image.noScale=true
            image:onClick(click_call_bak)
        end

    end
end


return faceUI