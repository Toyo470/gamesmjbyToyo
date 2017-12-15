--
-- Author: Zt
-- Date: 2016-09-12 11:16:35
--
-- 零时视频


local Video=class("Video",function()
		return cc.Node:create()
	end)
local isRun=true
--local nick=""
function Video:ctor(url)

	local s = cc.CSLoader:createNode("hall/vedioScene.csb"):addTo(self)
	self.rootNode=s
	
	local bg=self.rootNode:getNode("Image_3")
	bg:setOpacity(0)


	local close_btn2=self.rootNode:getNode("Image_2");
	close_btn2.noScale=true;
	if close_btn2 then
		--todo
		print("close play video")
		close_btn2:onClick(handler(self, self.Remove))
	end

	local txt_nick=self.rootNode:getNode("Text_1");
	txt_nick:setString(tostring(url.data).."的视频")

	print("startPlayUrl",url.file)
	
	if device.platform=="windows" then
		--todo
		return;
	end


	local videoPlayer = ccexp.VideoPlayer:create()
	self.videoPlayer=videoPlayer
	videoPlayer:ssize(bg:getWidth(),bg:getHeight())
	local function onVideoEventCallback(sener, eventType)
		if eventType == ccexp.VideoPlayerEvent.COMPLETED then --播放成功
			print("play video success")
            self:Remove()
        end
	end
	videoPlayer:setAnchorPoint(cc.p(0,0))
	videoPlayer:addEventListener(onVideoEventCallback)
	videoPlayer:setFileName(url.file)

	videoPlayer:play()

	
	bg:addChild(videoPlayer);
end


function Video:Remove()
	print("exit video")
	self.videoPlayer:stop()
    self:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function()
    		
    		self:removeSelf();
    		isRun=true
    	end)))

    audio.resumeMusic()
end


local music=class("music")
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
function music:ctor(url)
	print("start play music",url.file)
	--url.file=device.writablePath..url.file
	if  device.platform=="android" then
		--todo
		ccexp.AudioEngine:preload(url.file);
	end

	self.url=url
	-- if bm.isRecordingVoice and  bm.isRecordingVoice==1 then --当前正在录音的话 不播了 
	-- 		--todo

	-- else
	-- 	scheduler.performWithDelayGlobal(handler(self, self.startPlay), 0.5)	
	-- end

	scheduler.performWithDelayGlobal(handler(self, self.startPlay), 0.5)
	
end

function music:startPlay(url)
	local url=self.url

	local imagePlay=cc.Sprite:create("hall/images/hear_02.png")

	if  device.platform=="android" then 
		--todo



		local audio_id=ccexp.AudioEngine:play2d(url.file,false)
		local _shd_id
		_shd_id=scheduler.performWithDelayGlobal(function()
				print("playSuccess",audioID,filePath)
		 		audio.resumeMusic();
		 		isRun=true
		 		imagePlay:removeSelf()
			end, 10)


		ccexp.AudioEngine:setFinishCallback(audio_id,function(audioID,filePath)
		 		print("playSuccess",audioID,filePath)
		 		scheduler.unscheduleGlobal(_shd_id)
		 		audio.resumeMusic();
		 		isRun=true
		 		imagePlay:removeSelf()
		 	end)

	elseif device.platform=="ios" then
		--todo
		local _shd_id
		scheduler.performWithDelayGlobal(function()
				--print("playSuccess",audioID,filePath)
		 		audio.resumeMusic();
		 		isRun=true
		 		imagePlay:removeSelf()
		 		audio.stopSound(_shd_id)
			end, 5)
		_shd_id=audio.playSound(url.file)
	end
	


	SCENENOW["scene"]:addChild(imagePlay)

	imagePlay.text=1
	imagePlay:retain()
	local position = require("hall.GameSetting"):getPos(url.data)
	dump(position, "-----录音播放效果位置-----")
	if position then
		imagePlay:setPosition(position.x , position.y)
	else
		imagePlay:setPosition(0 , 0)
	end
	
	local action = cc.Sequence:create(cc.DelayTime:create(0.3),cc.CallFunc:create(function()

		if imagePlay.text==1 then

			imagePlay:setTexture("hall/images/hear_01.png")
			imagePlay.text=2

		elseif imagePlay.text==2 then

			imagePlay:setTexture("hall/images/hear_02.png")
			imagePlay.text=1

		end

	end))

	imagePlay:runAction(cc.RepeatForever:create(action))

end


local vedio_manage=class("vedio_manage")


function vedio_manage:ctor()
	self.myPlayVedio={}--需要播放的视频列表 

	scheduler.scheduleUpdateGlobal(function()
			if isRun then
				--todo
				self:playNextVedio()
			end
		end)
end


function vedio_manage:addVedio(url,niack)
	if url==nil or type(url)~="string" or url=="" then
		--todo
		error("错误的视频地址"..tostring(url))
		return;
	end
	print("addVedio",url,niack)
	--nick=niack
	local tb={file=url,data=niack}
	table.insert(self.myPlayVedio,tb)
end


function vedio_manage:playNextVedio()

	local url=self.myPlayVedio[1]

	if not url or not url.file or tolua.isnull(SCENENOW["scene"]) then
		--todo
		--error("播放出现异常"..tostring(url))
		return
	end

	local data=url

	print(data.file,"zt test")
	isRun=false
	table.remove(self.myPlayVedio,1)

	--audio.stopMusic() --先暂停背景音乐
	audio.pauseMusic()
	--audio.pausem(false)

	local pathinfo  = io.pathinfo(data.file)
	if pathinfo.extname  == ".aac" or pathinfo.extname  == ".mp3" or pathinfo.extname  == ".wav" or pathinfo.extname  == ".arm" then
		--todo
		music.new(data)
	else
		local v=Video.new(data);
		SCENENOW["scene"]:addChild(v);
	end

	
end


cct.vedio_manage=vedio_manage.new()


