manager = nil

function get_player_account()
	if manager == nil then
		return nil
	end
	
	return manager.account_object
end