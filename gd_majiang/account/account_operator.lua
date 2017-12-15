--
-- Author: chen
-- Date: 2016-07-12-17:33:41
--`
mrequire("account.account_manager")

function init_account_object(icon_url,nick,gold,sex,uid)
	--print("icon_url,nick,gold,sex,uid",icon_url,nick,gold,sex,uid)
	local account_object = account.manager:create_account_object()
	account_object:set_account_gold(gold)
	account_object:set_account_name(nick)
	
	account_object:set_account_iconrul(icon_url)
	account_object:set_account_sex(sex)

	account_object:set_account_id(uid)

end

