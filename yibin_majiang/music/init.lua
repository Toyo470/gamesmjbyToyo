manager = nil


function get_account_sex( account_id )
	-- body
	local account_data = zzroom.manager:get_user_data(tonumber(account_id))
	account_data = account_data or {}
	
	local account_sex = account_data["account_sex"] or 2
	return account_sex
end

--碰的声音
function playEffectPeng( account_id )
	-- body
	if manager ~= nil then
		local sex = get_account_sex(account_id)
		manager:playEffectPeng( sex )
	-- body
	end

end

--吃的声音
function playEffectChi( account_id )

	if manager ~= nil then
		local sex = get_account_sex(account_id)
		manager:playEffectChi( sex )
	-- body
	end

end

--杆的声音
function playEffectGang( account_id )
	-- body
	if manager ~= nil then
		local sex = get_account_sex(account_id)
		manager:playEffectGang( sex )
	end
end

--胡的声音
function playEffectHu( account_id )
	-- body
	if manager ~= nil then
		local sex = get_account_sex(account_id)
		manager:playEffectHu( sex )
	end
end

function playEffectCard( account_id,card_value )
	-- body
	card_value = tonumber(card_value)

	if manager ~= nil and card_value ~= nil then
		local sex = get_account_sex(account_id)
		manager:playEffectCard( sex ,card_value)
	end
end
