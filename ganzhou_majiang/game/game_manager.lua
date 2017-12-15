mrequire(names)

GameManager = class("GameManager")

function GameManager:ctor()
	self.game_attr_dict = {}
end
		
function GameManager:set_game_attr(key,value)
	self.game_attr_dict[key] = value
end
		
function GameManager:get_game_attr(key)
	return self.game_attr_dict[key]
end

function GameManager:set_up_jing_list(up_jing_list)
	self:set_game_attr(names.GAME_UP_JING_CARD_LIST,up_jing_list)
end
		
function GameManager:get_up_jing_list()
	return self.game_attr_dict[names.GAME_UP_JING_CARD_LIST] or {}
end
