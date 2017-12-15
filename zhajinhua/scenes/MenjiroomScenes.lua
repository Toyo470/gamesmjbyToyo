local MenjiroomView   = import("zhajinhua.view.MenjiroomView")
local MenjiroomHandle = import("zhajinhua.ZjhHandle")
local seatProgressTimer = import("zhajinhua.common.SeatProgressTimer")
local UiCommon        =  import("zhajinhua.common.UiCommon")
local MenjiroomScenes = class("MenjiroomScenes", function()
    return display.newScene("MenjiroomScenes")
end)

function MenjiroomScenes:ctor()
	self.view  = MenjiroomView.new():addTo(self)

	display.addSpriteFrames("zhajinhua/res/common_texture.plist", "zhajinhua/res/common_texture.png")
	display.addSpriteFrames("zhajinhua/res/NewImg/card/Plist.plist", "zhajinhua/res/NewImg/card/Plist.png")


    display.addSpriteFrames("zhajinhua/res/room/animation/headWin.plist", "zhajinhua/res/room/animation/headWin.png")

    display.addSpriteFrames("zhajinhua/res/room/compareCard/winner.plist", "zhajinhua/res/room/compareCard/winner.png")
    display.addSpriteFrames("zhajinhua/res/room/compareCard/boom.plist", "zhajinhua/res/room/compareCard/boom.png")
    display.addSpriteFrames("zhajinhua/res/room/compareCard/allCompare.plist", "zhajinhua/res/room/compareCard/allCompare.png")
end

function MenjiroomScenes:onEnter()

end


return MenjiroomScenes