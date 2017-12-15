--
-- Author:ZT
-- Date: 2016-08-25 17:34:39
--
local VideoPlayC=class("VideoPlayC",function()
		return cc.Layer:create()
end)

local visibleRect = cc.Director:getInstance():getOpenGLView():getVisibleRect()
local centerPos   = cc.p(visibleRect.x + visibleRect.width / 2,visibleRect.y + visibleRect.height /2)

function VideoPlayC:ctor()
    local str="http://hbirdtest.oss-cn-shenzhen.aliyuncs.com/%E9%99%88%E5%A5%95%E8%BF%85%20-%20%E9%99%80%E9%A3%9E%E8%BD%AE.mp4"
	local function onVideoEventCallback(sener, eventType)
        if eventType == ccexp.VideoPlayerEvent.PLAYING then
            print("play")
        elseif eventType == ccexp.VideoPlayerEvent.PAUSED then
            print("pause")
        elseif eventType == ccexp.VideoPlayerEvent.STOPPED then
            print("stoping")
        elseif eventType == ccexp.VideoPlayerEvent.COMPLETED then
            print("bofangsuccess")
        end
    end


	local videoPlayer = ccexp.VideoPlayer:create()
    videoPlayer:setPosition(centerPos)
    videoPlayer:setAnchorPoint(cc.p(0.5, 0.5))
    videoPlayer:setContentSize(cc.size(widgetSize.width * 0.4,widgetSize.height * 0.4))
    videoPlayer:addEventListener(onVideoEventCallback)
    self:addChild(videoPlayer)

    videoPlayer:setURL(str)



end




