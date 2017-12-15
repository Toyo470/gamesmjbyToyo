-- module(..., package.seeall)
PlayerManager = class("PlayerManager")

function PlayerManager:ctor()
end

function PlayerManager:initialize()
	self.player_object_dict = {}
	
end

function PlayerManager:release()
	self.player_object_dict = nil
end
